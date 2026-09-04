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
  {v:'10.80',what:'both maps really build a town centre, monument and all, and no archetype the file defines is left as code no map calls',
'@ @'
  {v:'10.81',what:'some buildings on both maps are destroyed: whole runs of outer wall gone so you can walk in from any side, with their rooms still standing and nothing sealed behind them',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__cfg)) return 'SKIP: this fixture cannot build a map with a dial';
     var bad=[];
     // Both arms on the same seed: the dial is the only difference, so anything
     // that moves is this build's doing and nothing else's.
     function survey(rate,mi){
       __runPrep(); __resetCfg(); __pinDefaults(0);
       __cfg({bldgRuin:rate});
       __deploy({kit:[],safe:null,mapIx:mi,seed:4242});
       var g=__state(), M=g.map, B=M.buildings, W=M.walls, i, j;
       var ruined=0, shell={}, inner={};
       for(i=0;i<B.length;i++) if(B[i].ruined) ruined++;
       // Per building: how much of its own perimeter is still walled, and how
       // many interior partitions it still has.
       for(j=0;j<W.length;j++){
         var w=W[j];
         if(w.ib!==undefined){ inner[w.ib]=(inner[w.ib]||0)+1; continue; }
         if(w.wreck||w.ruin||w.tree||w.furn||w.noDes) continue;
         for(i=0;i<B.length;i++){
           var b=B[i], t=20;
           if(w.x<b.x-t||w.x+w.w>b.x+b.w+t||w.y<b.y-t||w.y+w.h>b.y+b.h+t) continue;
           if((Math.abs(w.y-b.y)<t)||(Math.abs(w.y+w.h-(b.y+b.h))<t)||
              (Math.abs(w.x-b.x)<t)||(Math.abs(w.x+w.w-(b.x+b.w))<t)){
             shell[i]=(shell[i]||0)+Math.max(w.w,w.h); break; }
         }
       }
       return {B:B,ruined:ruined,shell:shell,inner:inner,walls:W.length,
               ents:g.ents.length,cont:g.containers.length,log:M.ruinLog||null};
     }
     var mi, tot=0;
     for(mi=0;mi<2;mi++){
       var on=survey(0.09,mi), off=survey(0,mi);
       var nm=(mi===0?'COLD STORAGE':'THE COLD MILE');
       // 1. THE DIAL OFF IS THE OLD MAP, EXACTLY. This is what makes every
       //    number below attributable, and it is the promise the pass makes by
       //    running after all the rolls.
       if(off.ruined!==0) bad.push('control: '+nm+' ruins '+off.ruined+' buildings with the dial at zero');
       if(off.ents!==on.ents||off.cont!==on.cont)
         bad.push(nm+' moved its world: '+off.ents+'/'+off.cont+' with the dial off against '+
                  on.ents+'/'+on.cont+' with it on, so the pass is rolling dice');
       // 2. IT ACTUALLY DID SOMETHING.
       if(on.ruined<1){ bad.push(nm+' has no destroyed building on it at all'); continue; }
       tot+=on.ruined;
       if(on.walls>=off.walls)
         bad.push(nm+' keeps '+on.walls+' walls against '+off.walls+', so nothing was actually torn open');
       // 3. AND WHAT IT DID IS WHAT IT SAYS. Every ruined building must have
       //    LOST perimeter, must still have SOME, and must keep its rooms.
       for(var q=0;q<on.B.length;q++){
         if(!on.B[q].ruined) continue;
         var per=2*(on.B[q].w+on.B[q].h);
         var sOn=(on.shell[q]||0), sOff=(off.shell[q]||0);
         if(!(sOn<sOff)) bad.push(nm+' building '+q+' is flagged destroyed and its shell is unchanged at '+sOn);
         else if(sOn/per<0.12) bad.push(nm+' building '+q+' has only '+Math.round(sOn/per*100)+' percent of its perimeter left, which is a gap in the map, not a building');
         if((on.inner[q]||0)!==(off.inner[q]||0))
           bad.push(nm+' building '+q+' lost interior walls too, '+(on.inner[q]||0)+' against '+(off.inner[q]||0)+', and this pass is meant to leave the rooms standing');
       }
       // 4. AND THE ONES IT LEFT ALONE ARE UNTOUCHED, or the dial is doing
       //    something to the whole map rather than to the buildings it picked.
       for(q=0;q<on.B.length;q++){
         if(on.B[q].ruined) continue;
         if((on.shell[q]||0)!==(off.shell[q]||0))
           bad.push(nm+' building '+q+' is not flagged destroyed and its shell changed anyway');
       }
       // 5. A STRONGROOM IS NEVER OPENED FROM THE SIDE. It is the one room on
       //    the map you are meant to need a key for.
       var LK=(__lockedOf?__lockedOf(mi):null);
       if(LK) for(q=0;q<on.B.length;q++){
         if(!on.B[q].ruined) continue;
         var b2=on.B[q];
         for(var lq=0;lq<LK.length;lq++){ var L2=LK[lq];
           if(L2.x<b2.x+b2.w&&L2.x+L2.w>b2.x&&L2.y<b2.y+b2.h&&L2.y+L2.h>b2.y)
             bad.push(nm+' tore open building '+q+', which holds the strongroom '+(L2.name||L2.id)); }
       }
     }
     if(tot<2) bad.push('only '+tot+' destroyed buildings across both maps, which is not a feature anybody would notice');
     __resetCfg();
     return bad.length?bad.join('; '):null; }},
  {v:'10.80',what:'both maps really build a town centre, monument and all, and no archetype the file defines is left as code no map calls',
'@

SubRx @'
window.__frame=function(dt){ render2D(dt===undefined?0.016:dt); };
'@ @'
window.__frame=function(dt){ render2D(dt===undefined?0.016:dt); };
// v10.81: the authored strongrooms of a map, so a check can prove the ruin pass
// never tears one open. Read off the map definition rather than the built world,
// because a locked room is authored and a built one could be missing for the
// very reason a check is looking.
window.__lockedOf=function(mi){ try{ return (FIXED_MAPS[mi]&&FIXED_MAPS[mi].locked)||[]; }catch(e){ return []; } };
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
