$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

SubRx @'
  {v:'15.46',what:
'@ @'
  {v:'15.47',what:'each run in your stats counts its Listener, Pillbox and Warden kills: a raid where one sentry, one Listener, one Warden and one Pillbox are destroyed by your fire in one frame and then abandoned draws its line in the Every run list with 4k, the count the Average kills per run card takes from the same run, while a run logged with only the older four kill counts still reads its 2k and a run with no kill record reads 0k (bodies audit finding)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot deploy or read the profile';
     if(typeof fmtRun!=='function'||typeof renderHub!=='function'||typeof statSummary!=='function'||typeof updateEnts!=='function'||typeof contractKill!=='function') return 'SKIP: this build has no run line, hub list, stats summary, entity update or kill contract step';
     if(typeof mkSentry!=='function'||typeof mkListener!=='function'||typeof mkWarden!=='function'||typeof mkChoir!=='function') return 'SKIP: this build cannot make a sentry, a Listener, a Warden and a Pillbox';
     var bad=[], g=null, P2=__P(), keepLog=null, keepKills=null, tookKills=false, keepEnts=null, _ck=contractKill, staged=[], ki, si;
     // The four kinds destroyed here: the sentry the old hand list counted, and the three it left out (choir is the Pillbox).
     var KINDS=['sentry','listener','warden','choir'];
     function total(k){ var t=0; for(var kk in k) t+=(k[kk]||0); return t; }
     // The kill figure a run line prints, as a number, or null when the line prints none.
     function figure(txt){ var m=(/ (\d+)k /).exec(String(txt||'')); return m?+m[1]:null; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(!P2||!P2.log||typeof P2.log.length!=='number') return 'SKIP: no run log in the profile';
       keepLog=P2.log.slice();
       // The lifetime kill tally the run banks when it ends (a Warden kill there unlocks cosmetics), put back in finally.
       keepKills=P2.kills?JSON.parse(JSON.stringify(P2.kills)):null; tookKills=true;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||!g.player||g.over||g.sim||!g.ents||!g.tel||!g.tel.kills) return 'SKIP: no live raid with a kill record';
       keepEnts=g.ents.slice();
       // CONTROL: the live raid record keeps a count for each of the four kinds, and nothing is counted on landing.
       for(ki=0;ki<KINDS.length;ki++) if(typeof g.tel.kills[KINDS[ki]]!=='number') return 'SKIP: the live raid record keeps no '+KINDS[ki]+' kill count here';
       if(total(g.tel.kills)!==0) return 'SKIP: the raid record already held '+total(g.tel.kills)+' kills on landing here';
       // No kill contract ticks for the probe kills, so the saved contracts are left as they were.
       contractKill=function(){};
       if(contractKill===_ck) return 'SKIP: the kill contract step could not be set aside here';
       // One of each, killed by your fire and the only things in the raid, down the ordinary death path in one frame.
       staged=[mkSentry(g.player.x+60,g.player.y),mkListener(g.player.x-60,g.player.y),mkWarden(g.player.x,g.player.y+60),mkChoir(g.player.x,g.player.y-60)];
       g.ents.length=0;
       for(si=0;si<staged.length;si++){ staged[si].hp=0; staged[si].byPlayer=true; staged[si].downed=0; g.ents.push(staged[si]); }
       updateEnts(0.016);
       contractKill=_ck;
       // CONTROL: all four died, and the raid record counted one of each and nothing else.
       for(si=0;si<staged.length;si++) if(g.ents.indexOf(staged[si])>=0) return 'SKIP: the staged '+staged[si].kind+' did not die here';
       for(ki=0;ki<KINDS.length;ki++) if(g.tel.kills[KINDS[ki]]!==1) return 'SKIP: the raid record counted '+g.tel.kills[KINDS[ki]]+' '+KINDS[ki]+' kills, not 1, here';
       if(total(g.tel.kills)!==4) return 'SKIP: the raid record counted '+total(g.tel.kills)+' kills, not 4, here';
       g.ents.length=0; for(var ke=0;ke<keepEnts.length;ke++) g.ents.push(keepEnts[ke]);
       // Walk out: the run is written to the log with its kills, as every run is. A raid abandoned with no time on the clock, no
       // step taken, nothing searched and nothing fired is thrown away as an instant quit and never logged, so he has walked 40 first.
       g.tel.distance=Math.max(g.tel.distance||0,40);
       __endRaid('abandon');
       var rec=P2.log[P2.log.length-1];
       // CONTROL: the newest run in the log is this one, with its four kills.
       if(!rec||(keepLog.length&&rec===keepLog[keepLog.length-1])||rec.outcome!=='abandon'||!rec.kills||total(rec.kills)!==4||rec.kills.listener!==1||rec.kills.warden!==1||rec.kills.choir!==1) return 'SKIP: the abandoned run was not written to the run log with its four kills here';
       // CONTROL: the Average kills per run card reads 4 kills off this run.
       var want=statSummary([rec]).kills;
       if(want!==4) return 'SKIP: the stats summary counted '+want+' kills on this run, not 4, so the list has nothing to agree with here';
       // The Every run list as the hub draws it, emptied first so no line from an earlier draw can be read.
       var ll=document.getElementById('loglist');
       if(!ll) return 'SKIP: no Every run list in this build';
       ll.innerHTML='';
       try{ renderHub(); }catch(_rh){ return 'SKIP: drawing the hub threw here: '+(_rh&&_rh.message||_rh); }
       var row=ll.children[0], txt=row?String(row.textContent||''):'';
       // CONTROL: the first line in the list is this run, and it prints a kill figure.
       if(txt.indexOf('ABN#'+rec.n+' ')!==0) return 'SKIP: the first line in the Every run list read ['+txt+'], not the abandoned run #'+rec.n;
       var got=figure(txt);
       if(got===null) return 'SKIP: the line for this run printed no kill figure ['+txt+']';
       // THE FIX: the line counts all four kills, the same as the stats card.
       if(got!==want) bad.push('a raid where one sentry, one Listener, one Warden and one Pillbox were destroyed by your fire and then abandoned drew its line in the Every run list as ['+txt+'], '+got+'k, while the Average kills per run card counts '+want+' kills on the same run');
       // KEPT: a run logged when the record kept only four kill counts still reads the kills it carries, and a run with no kill record reads 0k.
       var oldRow=String(fmtRun({n:7,preset:'probe',haul:0,dur:60,acc:0,outcome:'extract',kills:{sentry:0,crawler:0,raider:2,snitch:0}}).textContent||'');
       if(figure(oldRow)!==2) bad.push('a run logged with only the sentry, crawler, pillager and snitch kill counts and two pillager kills drew its line as ['+oldRow+'], not 2k');
       var noRow=String(fmtRun({n:8,preset:'probe',haul:0,dur:60,acc:0,outcome:'extract'}).textContent||'');
       if(figure(noRow)!==0) bad.push('a run logged with no kill record drew its line as ['+noRow+'], not 0k');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ contractKill=_ck; }catch(_k){}
       try{ if(g&&keepEnts){ g.ents.length=0; for(var kr=0;kr<keepEnts.length;kr++) g.ents.push(keepEnts[kr]); } }catch(_n){}
       try{ if(g&&!g.over) __endRaid('abandon'); }catch(_e){}
       try{ if(P2&&keepLog) P2.log=keepLog; }catch(_l){}
       try{ if(P2&&tookKills){ if(keepKills) P2.kills=keepKills; else delete P2.kills; } }catch(_pk){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
       try{ renderHub(); }catch(_r){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'15.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
