$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

if ($s.Contains("  {v:'35.52',what:")) { throw "check 35.52 is in the fixture already" }

SubRx @'
  {v:'35.51',what:
'@ @'
  {v:'35.52',what:'cw-answerline, his ask 2026-10-27 (the hud messaging is a clusterfuck, make it AAA), the research rule for the centre: the answer to a try that did not work (health full, no ammo, locked) is one small line about 70 px under the character (over the head when the character stands low on a short window), at least 20 px, for 2 s, once per press (said again while it shows or while the key is held it does not restart or come back), and not in the left feed; backpack full stays in the pickup stack and contract item nearby stays in the feed',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid)) return 'SKIP: this fixture cannot deploy';
     if(typeof drawHUD!=='function'||!window.__textTrace||typeof w2s!=='function'||typeof feedDraw!=='function') return 'SKIP: no hud here';
     var bad=[], g, p, tr, o, ps, Tn=0, oSN=statusNow, i, a0, all=null;
     function feedHas(s){ var F=(g.fd&&g.fd.lines)||[], c=0; for(var j=0;j<F.length;j++) if(String(F[j].txt).indexOf(s)>=0) c++; return c; }
     function clr(){ g.fd={t:0,seq:0,lines:[]}; g.alert=null; g.alertQ=[]; g.pick=[]; g.ans=null; g.ansSeen={}; }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ __pinDPR(1); __forceSize(1920,1080); }catch(_fs){}
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); if(!g||g.over||!g.player||g.sim) return 'SKIP: staging: no raid';
       p=g.player; keys={}; g.mapOpen=false; g.bagOpen=false; g.paused=false; all=g.ents.slice(); g.ents=[];
       try{ render2D(0); }catch(_r0){}
       if(typeof ansSay!=='function'||typeof ansDraw!=='function') return 'no answer line under the character (ansSay, ansDraw)';
       statusNow=function(){ return Tn; };
       // ONE: an answer draws under the feet, at least 20 px, and not in the feed
       clr(); Tn=100; say('HEALTH FULL');
       if(feedHas('HEALTH FULL')) bad.push('health full still goes into the left feed');
       Tn=100.5; tr=__textTrace(function(){ drawHUD(); }); ps=w2s(p.x,0,p.y);
       o=null; for(i=0;i<tr.length;i++) if((/^health full$/i).test(tr[i].t)){ o=tr[i]; break; }
       if(!o) bad.push('health full is not drawn');
       else {
         if(!(Math.abs(o.x-ps.x)<40&&((o.y-ps.y>40&&o.y-ps.y<120)||(ps.y+70>H-150&&o.y<ps.y-40)))) bad.push('health full is drawn at '+Math.round(o.x)+','+Math.round(o.y)+', not about 70 px under the feet at '+Math.round(ps.x)+','+Math.round(ps.y));
         if(!(o.px>=20)) bad.push('the answer line is '+o.px.toFixed(1)+' px, under 20');
       }
       // TWO: two seconds, then gone
       Tn=102.2; tr=__textTrace(function(){ drawHUD(); });
       for(i=0;i<tr.length;i++) if((/^health full$/i).test(tr[i].t)) { bad.push('health full still draws 2.2 s later'); break; }
       // THREE: once per press: said again while it shows it does not restart; held (said every 30 ms) it does not come back; pressed again it shows
       clr(); Tn=200; say('THROW BLOCKED'); a0=g.ans&&g.ans.at;
       for(Tn=200.03;Tn<203;Tn+=0.03) say('THROW BLOCKED');
       if(!(g.ans&&g.ans.at===a0)) bad.push('throw blocked said while the key is held restarted the line');
       if(ansUp()) bad.push('throw blocked came back while the key was still held');
       Tn=205; say('THROW BLOCKED'); if(!(ansUp()&&g.ans.at===205)) bad.push('throw blocked pressed again does not show again');
       Tn=205.3; say('TOO TIRED TO ROLL'); if(!(ansUp()&&g.ans.m==='TOO TIRED TO ROLL')) bad.push('a new answer does not replace the last one');
       // FOUR: backpack full stays in the pickup stack; contract item nearby stays in the feed
       clr(); Tn=300; say('BACKPACK FULL','pick',{key:'bagfull',sub:'drop something'});
       if(ansUp()) bad.push('backpack full went to the answer line');
       if(!(g.pick&&g.pick.length&&(/backpack full/i).test(g.pick[g.pick.length-1].m))) bad.push('backpack full is no longer a pickup row');
       clr(); say('CONTRACT ITEM NEARBY','obj',{sub:'GOLD GLOW MARKS THE BOX',key:'needhint'});
       if(ansUp()||feedHas('CONTRACT ITEM NEARBY')!==1) bad.push('contract item nearby left the feed');
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       statusNow=oSN; keys={};
       try{ if(g){ g.ans=null; if(all) g.ents=all; } }catch(_z){}
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'35.51',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
