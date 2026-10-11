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

if ($s.Contains("  {v:'23.38',what:")) { throw "check 23.38 is in the fixture already" }

SubRx @'
  {v:'23.37',what:
'@ @'
  {v:'23.38',what:'arcade15, his order 2026-10-11: popups and streaks, two crawler kills 0.5 s apart chain a x2 streak, the second scores 100 with a +100 popup, DOUBLE KILL takes the alert lane, the x2 badge shows beside TEAM SCORE, a kill 5 s later starts again, and a normal raid gets none of it',
   run:function(){
     var bad=[], g=null, g2=null, m0, d, rs=say, own=false, lines=[], cx=null, ft=null, ownF=false, seen=[], f, i, hasL=false, nD='DOUBLE '+'KILL';
     function kill(gg,dx){ var q=mkCrawler(gg.player.x+dx,gg.player.y); q.byPlayer=1; q.elite=0; q.hp=0; gg.ents.push(q); __ents(0.016); return gg.ents.indexOf(q)<0; }
     function hasLbl(gg,s){ var j; for(j=0;j<(gg.labels||[]).length;j++) if(gg.labels[j]&&gg.labels[j].txt===s) return true; return false; }
     try{
       __topClear(); __runPrep();
       if(typeof arcadeDeploy!=='function'||typeof ARCADE!=='object') return 'no arcadeDeploy in this build';
       if(ARCADE.on) return 'SKIP: the arcade is on after __topClear';
       if(!arcadeDeploy({mapIx:0,seed:4242})) return 'SKIP: arcadeDeploy built no arcade raid';
       g=__state(); keys={}; ARCADE.holdT=0; ARCADE.waveT=0;
       say=function(m,k,o){ lines.push(String(m)+'|'+String(k||'')); try{ var kk=msgKind(k); if(msgAlertK(kk)) alertSay(m,kk,o); }catch(_as){} }; own=true;
       g.alert=null; g.alertQ=[]; g.labels=[];
       m0=ARCADE.mine|0;
       if(!kill(g,300)) return 'SKIP: staging: the first crawler did not die';
       d=(ARCADE.mine|0)-m0;
       if(d!==50) bad.push('the first crawler kill scored '+d+', not 50');
       if(!hasLbl(g,'+50')) bad.push('no +50 popup for the first kill');
       g.t+=0.5; m0=ARCADE.mine|0;
       if(!kill(g,340)) return 'SKIP: staging: the second crawler did not die';
       d=(ARCADE.mine|0)-m0;
       if(!ARCADE.streak||ARCADE.streak.n!==2) bad.push('two kills 0.5 s apart give a streak of '+(ARCADE.streak?ARCADE.streak.n:'none')+', not 2');
       if(d!==100) bad.push('the second kill of a streak scored '+d+', not 100 (x2)');
       if(!hasLbl(g,'+100')) bad.push('no +100 popup in G.labels ('+(g.labels||[]).map(function(l){ return l&&l.txt; }).join(',')+')');
       if(lines.indexOf(nD+'|ext')<0) bad.push('DOUBLE KILL was not said in the ext lane ('+lines.slice(-3).join(' / ')+')');
       if(!g.alert||g.alert.m!==nD) bad.push('the alert lane holds '+(g.alert?g.alert.m:'nothing')+', not DOUBLE KILL');
       if(!g.over&&__state()===g){
         cx=hcv.getContext('2d'); ft=cx.fillText; ownF=true;
         cx.fillText=function(s){ seen.push(String(s)); return ft.apply(this,arguments); };
         for(f=0;f<3;f++) __loop(performance.now()+f*16.7);
         if(!seen.length){ try{ drawHUD(); }catch(_dh){} }
         delete cx.fillText; ownF=false;
         if(seen.indexOf('x2')<0) bad.push('no x2 streak badge on the HUD');
       } else bad.push('the arcade raid ended');
       g.t+=5; m0=ARCADE.mine|0;
       if(kill(g,380)){
         d=(ARCADE.mine|0)-m0;
         if(d!==50) bad.push('a kill 5 s after the streak scored '+d+', not 50');
         if(!ARCADE.streak||ARCADE.streak.n!==1) bad.push('a kill 5 s later did not start the streak again ('+(ARCADE.streak?ARCADE.streak.n:'none')+')');
       } else bad.push('the third crawler did not die');
       say=rs; own=false;
       try{ if(ARCADE.on) arcadeLeave(); }catch(_l1){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e1){}
       __topClear(); __runPrep();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g2=__state();
       if(!g2) return bad.length?bad.join('; '):'SKIP: __deploy built no raid';
       if(g2.arcade) bad.push('a normal raid is flagged arcade');
       ARCADE.streak=null; g2.labels=[];
       kill(g2,300); g2.t+=0.5; kill(g2,340);
       if(ARCADE.streak) bad.push('a normal raid kill started an arcade streak');
       if(hasLbl(g2,'+50')||hasLbl(g2,'+100')) bad.push('a normal raid kill shows an arcade score popup');
     }catch(x){ bad.push('threw: '+(x&&x.message||x)); }
     finally{
       if(own) say=rs;
       if(ownF&&cx){ try{ delete cx.fillText; }catch(_df){} }
       keys={};
       try{ if(typeof ARCADE==='object'&&ARCADE.on) arcadeLeave(); }catch(_l){}
       try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
       try{ if(typeof ARCADE==='object'){ ARCADE.streak=null; ARCADE.mine=0; ARCADE.holdT=0; ARCADE.waveT=0; } }catch(_m){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.37',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
