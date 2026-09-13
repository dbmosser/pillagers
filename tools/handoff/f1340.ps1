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

# v13.40 CHECK, inserted before the v13.39 entry.
#
# ON THE PLAY PATH: X held beside an ordinary box through the frame loop, staged pulls and
# all, until it opens; the player is placed on a clear spot, never walked. Arm one moves
# the hot ground onto the box; arm two moves it off a second box and requires silence.
# Machines, waves, the clock warning and the hot ground drift are held (13.33, r1334b,
# r1334c). The tail after the open is 900 frames, not the draft 600, on its reviewer's
# advice: since v13.35 a where-it-went line can wait ahead of the hot ground line.
SubRx @'
  {v:'13.39',what:'helping the survivor while carrying notoriety shows the line about the cache, the pay and the salvage he hands over, and the notoriety line follows it when that one runs out instead of writing over it in the same frame (2026-09-13 hunt)',
'@ @'
  {v:'13.40',what:'a box searched on the hot ground says so: after a held X search through the frame loop, the hot ground bonus line is shown after the Found line instead of being written over by it in the same call, and a box off the hot ground never says it',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__vpAlive)) return 'SKIP: this fixture cannot deploy a raid or step the loop';
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so the frame loop cannot draw';
     if(typeof updatePlayer!=='function'||typeof openContainer!=='function'||typeof spotFree!=='function'||typeof losClear!=='function') return 'SKIP: this build has no search path to drive';
     var bad=[], g=null, keepZone=null, keepProg=[], t0=performance.now(), f=0, i;
     // Assembled, never written whole: the fixture is part of the page.
     var HOT=['Hot','ground.'].join(' '), FOUND=['Found',' '].join(':');
     function endAny(){ try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; g0.searching=null; __endRaid('abandon'); } }catch(_0){} }
     // What the HUD draws: G.msg while G.msgT is above zero, read after each whole frame.
     function note(seen){ var gg=__state(); if(seen&&gg&&gg.msg&&gg.msgT>0&&(seen.length===0||seen[seen.length-1]!==String(gg.msg))) seen.push(String(gg.msg)); }
     function step(nn,seen){ for(var s=0;s<nn;s++){ __loop(t0+(++f)*16.7); note(seen); if(__state()!==g||g.over) return false; } return true; }
     // An ordinary box, shortest search first, with a spot beside it that is clear of every
     // wall, in clear sight of the box, and nearer to it than to any other unopened box.
     // He is placed there, never walked, so the frame collides him with nothing.
     function pick(skip){
       var best=null, segs=g.vseg||g.map.segs;
       for(var c=0;c<g.containers.length;c++){
         var ct=g.containers[c];
         if(!ct||ct===skip||ct.opened||ct.cache||ct.strong||ct.mercSrc||ct.auto||ct.dropped||(ct.prog||0)>0) continue;
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
     // The real search: X held through the frame loop, staged pulls and all, until the box opens.
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
       if(!g.hotZone) return 'SKIP: this raid has no hot ground to search on';
       keepZone={x:g.hotZone.x,y:g.hotZone.y,at:g.hotZone.at};
       for(i=0;i<(P.contracts||[]).length;i++) keepProg.push({c:P.contracts[i],prog:P.contracts[i].prog});
       // Let landing say what it says, so the lines read below come from the search itself.
       if(!step(420,null)) return 'SKIP: staging: the raid ended while landing settled';
       // Nothing else may speak while they are read (13.33, r1334b and r1334c): no machines,
       // no wave, no clock warning, and the hot ground holds still.
       g.ents.length=0; g.waveT=-1e9; g.hotZone.at=0;
       if(CFG.raidSec>0&&g.timeLeft<600) g.timeLeft=600;
       g.bag.length=0;
       // ARM ONE: a box on the hot ground.
       var A=pick(null);
       if(!A) return 'SKIP: no ordinary box on this seed has a clear spot beside it to search from';
       g.hotZone.x=A.ct.x; g.hotZone.y=A.ct.y;
       var seenA=[];
       if(!drive(A.ct,A.spot,seenA)) bad.push('control: holding X beside the '+A.ct.type+' for 25 seconds never finished the search (prog '+(+(A.ct.prog||0)).toFixed(2)+' of '+A.ct.time+')');
       else {
         if(!A.ct.hotPaid) bad.push('control: the box on the hot ground was not paid the bonus, so this arm measured nothing');
         step(900,seenA);
         var hotN=0, foundN=0;
         for(i=0;i<seenA.length;i++){ if(seenA[i].indexOf(HOT)===0) hotN++; if(seenA[i].indexOf(FOUND)>=0) foundN++; }
         var shownA=seenA.join(' | ').slice(-240);
         if(!foundN) bad.push('control: the Found line never showed after the search [shown: '+shownA+']');
         if(!hotN) bad.push('the hot ground bonus line was never on screen; the Found line wrote over it in the same call [shown: '+shownA+']');
         if(hotN>1) bad.push('the hot ground bonus line was shown '+hotN+' times for one box [shown: '+shownA+']');
       }
       // ARM TWO, the control: a box off the hot ground never says it.
       keys={}; g.bag.length=0; g.msgQ=[]; g.msgT=0;
       var B=pick(A.ct);
       if(!B) bad.push('control: no second box with a clear spot, so the off-ground arm could not run');
       else {
         g.hotZone.x=(B.ct.x<WORLD_W/2)?WORLD_W-1:1; g.hotZone.y=(B.ct.y<WORLD_H/2)?WORLD_H-1:1; g.hotZone.at=0;
         if(Math.hypot(B.ct.x-g.hotZone.x,B.ct.y-g.hotZone.y)<=g.hotZone.r) bad.push('control: the hot ground could not be moved off the second box');
         else {
           var seenB=[];
           if(!drive(B.ct,B.spot,seenB)) bad.push('control: the off-ground search never finished');
           else {
             step(300,seenB);
             var shownB=seenB.join(' | ').slice(-240);
             if(B.ct.hotPaid) bad.push('a box off the hot ground was paid the hot ground bonus');
             if(seenB.some(function(t){ return t.indexOf(HOT)===0; })) bad.push('a box off the hot ground said the hot ground line [shown: '+shownB+']');
             if(!seenB.length) bad.push('control: nothing showed on the message line during the off-ground search, so it was not being read');
           }
         }
       }
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       keys={};
       try{ if(g&&g.hotZone&&keepZone){ g.hotZone.x=keepZone.x; g.hotZone.y=keepZone.y; g.hotZone.at=keepZone.at; } }catch(_z){}
       endAny();
       for(i=0;i<keepProg.length;i++){ try{ keepProg[i].c.prog=keepProg[i].prog; }catch(_p){} }
       try{ saveProfile(); }catch(_s){}
       try{ __topClear(); }catch(_c){}
       try{ __cleanProfile(); }catch(_cp){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'13.39',what:'helping the survivor while carrying notoriety shows the line about the cache, the pay and the salvage he hands over, and the notoriety line follows it when that one runs out instead of writing over it in the same frame (2026-09-13 hunt)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
