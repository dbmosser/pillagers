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

# v12.47 CHECK, inserted before the v12.46 entry. It does NOT recompute the lift
# and grade itself against its own arithmetic. It hooks the canvas, draws a real
# frame with him standing on a real deck, and reads back WHERE THE KERB WAS
# ACTUALLY PAINTED, then compares that to the edge he actually collides with.
# It runs on both sectors and on every deck it finds. The control is an ordinary
# building wall in the same frame: it must still stand proud of its collider, so
# a build that had flattened every wall in the game would fail here rather than
# pass. If no ordinary wall was drawn there is nothing to control against and it
# says so instead of passing on one arm.
SubRx @'
  {v:'12.46',what:'auto-jog stops when he goes down: a man stood back up with no key held stays where he is instead of walking off toward the cursor at 40 health, while an armed auto-jog that never went down still walks him (2026-09-07 audit)',
'@ @'
  {v:'12.47',what:'a raised deck edge is painted where it is: no kerb on any deck on either sector is painted above the edge he collides with, so no part of the deck he can stand on is covered by a wall he can walk through, while ordinary building walls still stand proud of their colliders (his report of 2026-09-08, the long thin building)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__frame)) return 'SKIP: this fixture cannot deploy and draw a raid';
     var bad=[], proto=CanvasRenderingContext2D.prototype, oFR=proto.fillRect;
     var rects=[], watch=false, decksSeen=0, kerbsRead=0, plainRead=0;
     proto.fillRect=function(x,y,w,h){ if(watch) rects.push([x,y,w,h]); return oFR.apply(this,arguments); };
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __pinDPR(1); __forceSize(1920,1080);
       // Where a wall was ACTUALLY painted this frame: its own x and width, and a
       // y near enough to be its own paint rather than another wall's.
       function paintedTop(W){
         var best=null;
         for(var r=0;r<rects.length;r++){ var R=rects[r];
           if(Math.abs(R[0]-W.x)>0.6||Math.abs(R[2]-W.w)>0.6) continue;
           if(R[1]<W.y-60||R[1]>W.y+W.h+2) continue;
           if(best===null||R[1]<best) best=R[1];
         }
         return best;
       }
       for(var mi=0;mi<2;mi++){
         __deploy({kit:[],mapIx:mi,seed:4242});
         var g=__state(); if(!g||!g.player||!g.map) continue;
         g.ents.length=0; g.player.downed=false; g.player.hp=100;
         var M=g.map, plats=(M.plats||[]), i;
         if(!plats.length) continue;
         var PL=plats[0];
         for(i=1;i<plats.length;i++) if(plats[i].w*plats[i].h>PL.w*PL.h) PL=plats[i];
         g.player.x=PL.x+PL.w/2; g.player.y=PL.y+PL.h/2;
         rects=[]; watch=true; __frame(0.016); watch=false;
         decksSeen++;
         for(i=0;i<M.walls.length;i++){
           var W=M.walls[i];
           if(!W.ledge) continue;
           if(W.x>PL.x+PL.w+60||W.x+W.w<PL.x-60||W.y>PL.y+PL.h+60||W.y+W.h<PL.y-60) continue;
           var t=paintedTop(W);
           if(t===null) continue;
           kerbsRead++;
           var over=W.y-t;
           if(over>0.6)
             bad.push('sector '+mi+': the deck edge at '+Math.round(W.x)+','+Math.round(W.y)+' is painted '+Math.round(over)+' units above the edge he actually collides with, so that much of the deck he is standing on is covered by a wall he can walk straight through, and walking at it he stops '+Math.round(over)+' units short of where it looks like he should');
         }
         // CONTROL: an ordinary wall in the same frame must still stand proud,
         // or this check would pass on a build that flattened everything.
         for(i=0;i<M.walls.length;i++){
           var B=M.walls[i];
           if(B.ledge||B.w<100||B.h>60) continue;
           var bt=paintedTop(B);
           if(bt===null) continue;
           plainRead++;
           if(B.y-bt<10)
             bad.push('control: an ordinary wall at '+Math.round(B.x)+','+Math.round(B.y)+' on sector '+mi+' is painted only '+Math.round(B.y-bt)+' units above its collider, so walls no longer read as having any height at all');
           break;
         }
       }
       if(!decksSeen) return 'SKIP: neither sector built a raised deck to read';
       if(!kerbsRead) return 'SKIP: no deck edge was painted in the frame, so there was nothing to measure';
       if(!plainRead) return 'SKIP: no ordinary wall was painted in the same frame, so the control could not run';
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       watch=false; proto.fillRect=oFR;
       try{ var g2=__state(); if(g2&&!g2.over){ g2.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ __topClear(); __resetCfg(); __cleanProfile(); }catch(_c){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'12.46',what:'auto-jog stops when he goes down: a man stood back up with no key held stays where he is instead of walking off toward the cursor at 40 health, while an armed auto-jog that never went down still walks him (2026-09-07 audit)',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
