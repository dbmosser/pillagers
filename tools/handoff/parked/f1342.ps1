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

# v13.41 CHECK, inserted before the v13.40 entry. Built on check 13.40's helpers: X held
# beside an ordinary box through the frame loop until it opens, the player placed on a
# clear spot, and the message line read after whole frames. Machines, waves and the
# clock are held, and the hot ground is moved off the map so no bonus line joins in.
SubRx @'
  {v:'13.40',what:'a box searched on the hot ground says so: after a held X search through the frame loop, the hot ground bonus line is shown after the Found line instead of being written over by it in the same call, and a box off the hot ground never says it',
'@ @'
  {v:'13.41',what:'searching a box that finishes an open contract shows CONTRACT DONE on screen, instead of the Found line writing over it in the same call',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__vpAlive)) return 'SKIP: this fixture cannot deploy a raid or step the loop';
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     if(typeof openContainer!=='function'||typeof contractOpen!=='function'||typeof spotFree!=='function'||typeof losClear!=='function') return 'SKIP: this build has no search path or no open contracts';
     var bad=[], g=null, keepC=P.contracts, t0=performance.now(), f=0, i;
     var HEAD=['CONTRACT','DONE'].join(' ');
     function endAny(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; g0.searching=null; __endRaid('abandon'); } }catch(_0){} }
     function note(seen){ var gg=__state(); if(seen&&gg&&gg.msg&&gg.msgT>0&&(seen.length===0||seen[seen.length-1]!==String(gg.msg))) seen.push(String(gg.msg)); }
     function step(nn,seen){ for(var s=0;s<nn;s++){ __loop(t0+(++f)*16.7); note(seen); if(__state()!==g||g.over) return false; } return true; }
     function pick(){
       var best=null, segs=g.vseg||g.map.segs;
       for(var c=0;c<g.containers.length;c++){
         var ct=g.containers[c];
         if(!ct||ct.opened||ct.cache||ct.strong||ct.mercSrc||ct.auto||ct.dropped||(ct.prog||0)>0) continue;
         if(!(ct.time>0)||!ct.loot||ct.loot.length<1) continue;
         if(ct.type!=='crate'&&ct.type!=='locker'&&ct.type!=='safe') continue;
         if(best&&ct.time>=best.ct.time) continue;
         var spot=null;
         for(var rad=20;rad<=36&&!spot;rad+=8){
           for(var a=0;a<16&&!spot;a++){
             var sx=ct.x+Math.cos(a*Math.PI/8)*rad, sy=ct.y+Math.sin(a*Math.PI/8)*rad;
             if(!spotFree(g.map,sx,sy,16)||!losClear(sx,sy,ct.x,ct.y,segs)) continue;
             var rival=false;
             for(var o=0;o<g.containers.length&&!rival;o++){ var c2=g.containers[o]; if(c2&&c2!==ct&&!c2.opened&&Math.hypot(c2.x-sx,c2.y-sy)<=rad+1) rival=true; }
             if(!rival) spot={x:sx,y:sy};
           }
         }
         if(spot) best={ct:ct,spot:spot};
       }
       return best;
     }
     function drive(ct,spot,seen){
       var p=g.player;
       p.x=spot.x; p.y=spot.y; p.downed=false;
       g.msgQ=[]; g.msgT=0;
       keys={}; keys['KeyX']=true;
       for(var s=0;s<1500&&!ct.opened;s++){
         __loop(t0+(++f)*16.7); note(seen);
         if(__state()!==g||g.over) break;
       }
       keys={};
       return !!ct.opened;
     }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); endAny();
       keys={};
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state();
       if(!g||g.over||g.sim) return 'SKIP: staging: no live raid started';
       if(!step(420,null)) return 'SKIP: staging: the raid ended while landing settled';
       // Nothing else may speak: no machines, no wave, no clock warning, no hot ground.
       g.ents.length=0; g.waveT=-1e9;
       if(g.hotZone){ g.hotZone.x=-99999; g.hotZone.y=-99999; g.hotZone.at=0; }
       if(CFG.raidSec>0&&g.timeLeft<600) g.timeLeft=600;
       g.bag.length=0;
       var A=pick();
       if(!A) return 'SKIP: no ordinary box on this seed has a clear spot beside it to search from';
       // An open contract one box short, for exactly this box type, with a description the game never rolls.
       var desc=['Search','2','boxes','for','check','13','41'].join(' ');
       var C={type:'open',ct:A.ct.type,n:2,prog:1,reward:300,desc:desc};
       P.contracts=[C];
       g.tel=g.tel||{}; g.tel.contractsMid=g.tel.contractsMid||[];
       var mid0=g.tel.contractsMid.length;
       var seen=[];
       if(!drive(A.ct,A.spot,seen)) bad.push('control: holding X beside the '+A.ct.type+' for 25 seconds never finished the search');
       else {
         step(900,seen);
         var cIx=-1;
         for(i=0;i<seen.length;i++){ if(seen[i].indexOf(HEAD)===0&&seen[i].indexOf(desc)>=0){ cIx=i; break; } }
         var shown=' [shown: '+seen.join(' | ').slice(-240)+']';
         if(C.prog!==C.n) bad.push('control: opening the box did not finish the contract (progress '+C.prog+' of '+C.n+')');
         if(g.tel.contractsMid.length!==mid0+1) bad.push('control: the finished contract was not recorded for the report');
         if(C.prog===C.n&&cIx<0) bad.push('the line that says the contract is done was written over by the Found line in the same call and never shown'+shown);
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       keys={};
       endAny();
       try{ P.contracts=keepC; saveProfile(); }catch(_p){}
       try{ __topClear(); }catch(_c){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.40',what:'a box searched on the hot ground says so: after a held X search through the frame loop, the hot ground bonus line is shown after the Found line instead of being written over by it in the same call, and a box off the hot ground never says it',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
