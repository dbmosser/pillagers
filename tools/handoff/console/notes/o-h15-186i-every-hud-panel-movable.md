
--- codex run 2026-11-08 12:25 ---
2026-11-08: Stopped at the task's explicit fixture restriction: "if a check must change, put the finding and exact change in your notes and stop." No key is queued and no game or fixture file was edited.

LOCAL: no linked review. Own-window drawing/input/layout storage only.

Prepared mk-cw-cx-hudmoveall.ps1 in this output directory. Its anchors pass against v37.65 and it prints written. It is an unfinished draft, NOT ready to ship: its new check still needs actual transient-panel draw/drag staging instead of synthetic rectangles, cleanup of layout storage, syntax verification of the patched JavaScript, and review of overlapping-panel input priority. No browser gate or pictures were run. Do not ship this draft until a subsequent run finishes that work.

Implementation findings: gear already IS the gun card and already drags/resizes; keep that control. The minimap is currently explicitly non-draggable despite the task body's older description. An independent belt handle above the cells preserves item dragging. saveProfile refuses all arcade saves and stale shared saves, so persisting layouts only through it would miss arcade reloads and independent player 2 layout storage. The draft uses a separate SKEY/role/mode layout record as well as the existing profile offsets.

Required coordinator retarget: tools/mkfixture.ps1 check 34.88, around lines 20297-20362, currently demands a fold-tab-only open minimap hit box, shots beside that tab, and no drag on its folded strip. These expectations conflict with the owner's newer every-HUD-panel order. Accept the existing fixed behavior before the new key and draggable behavior after it by branching on typeof hudMoveGrab==='function'. Preserve the fold/chevron, baking, Settings, run-info overlap, off/map-open, seat and 4K tests.

Exact change 1, replace this assertion:
```js
       if(Math.abs(HUDBOX.mmap.x-tg.x)>1||Math.abs(HUDBOX.mmap.y-tg.y)>1||Math.abs(HUDBOX.mmap.h-tg.h)>1||!drawnAs(HUDBOX.mmap)) bad.push(tag+': the click box of the open fold ('+[HUDBOX.mmap.x,HUDBOX.mmap.y,HUDBOX.mmap.w,HUDBOX.mmap.h].map(Math.round).join(',')+') is not the tab that is drawn');
```
with:
```js
       if(typeof hudMoveGrab==='function'){
         if(Math.abs(HUDBOX.mmap.x-b0.x)>1||Math.abs(HUDBOX.mmap.y-b0.y)>1||Math.abs(HUDBOX.mmap.w-b0.w)>1||Math.abs(HUDBOX.mmap.h-b0.h)>1) bad.push(tag+': the movable minimap hit box does not match the drawn map');
       }else if(Math.abs(HUDBOX.mmap.x-tg.x)>1||Math.abs(HUDBOX.mmap.y-tg.y)>1||Math.abs(HUDBOX.mmap.h-tg.h)>1||!drawnAs(HUDBOX.mmap)) bad.push(tag+': the click box of the open fold ('+[HUDBOX.mmap.x,HUDBOX.mmap.y,HUDBOX.mmap.w,HUDBOX.mmap.h].map(Math.round).join(',')+') is not the tab that is drawn');
```

Exact change 2, replace this block (including the point list so it continues testing the actual fold tab edges):
```js
       [{x:q.x,y:Math.round(HUDBOX.mmap.y+HUDBOX.mmap.h)+3,s:'under'},{x:Math.round(HUDBOX.mmap.x)-3,y:q.y,s:'left of'}].forEach(function(q3){
         var fired=press(q3,1);
         if(P.hud&&P.hud.mmap&&P.hud.mmap.c){ bad.push(tag+': a press on the map just '+q3.s+' the fold tab folded the minimap'); P.hud.mmap.c=false; }
         else if(!fired) bad.push(tag+': a press on the map just '+q3.s+' the fold tab did not fire');
       });
```
with:
```js
       [{x:q.x,y:Math.round(tg.y+tg.h)+3,s:'under'},{x:Math.round(tg.x)-3,y:q.y,s:'left of'}].forEach(function(q3){
         var movable=typeof hudMoveGrab==='function', dragged=movable?press(q3,0):null, fired=movable?false:press(q3,1);
         if(P.hud&&P.hud.mmap&&P.hud.mmap.c){ bad.push(tag+': a press on the map just '+q3.s+' the fold tab folded the minimap'); P.hud.mmap.c=false; }
         else if(movable?dragged!=='mmap':!fired) bad.push(tag+': a press beside the fold tab did not '+(movable?'grab the map':'fire'));
       });
```

Exact change 3, replace:
```js
         hh=hudHit(q2.x,q2.y); if(hh&&hh.part==='bar') bad.push(tag+': over the strip the pointer is the move cross');
         if(press(q2)||P.hud.mmap.dx||P.hud.mmap.dy) bad.push(tag+': a press on the strip started a drag');
```
with:
```js
         hh=hudHit(q2.x,q2.y);
         if(typeof hudMoveGrab==='function'){
           if(!hh||hh.id!=='mmap'||hh.part!=='bar') bad.push(tag+': folded minimap has no move pointer');
           if(press(q2)!=='mmap'||P.hud.mmap.dx||P.hud.mmap.dy) bad.push(tag+': pressing the folded minimap did not grab it without moving');
         }else{
           if(hh&&hh.part==='bar') bad.push(tag+': over the strip the pointer is the move cross');
           if(press(q2)||P.hud.mmap.dx||P.hud.mmap.dy) bad.push(tag+': a press on the strip started a drag');
         }
```

Also update check 34.88's what prose to describe the conditional fixed/movable behavior. These changes accept the current build and retain the minimap folding regression coverage. The new task check must separately verify a real drag changes the rendered position, survives reloading layout storage, and resets for every requested element. No fixture-retarget.json was written, per the addendum.

Watch: whether grabbing a panel ever fires the gun or opens something under it.


11-08 13:36 coordinator: check 34.88 retargeted as these notes asked (commit 839c17dc2, fixture rebuilt, JS ok); the cw-hudmoveall build can go on, no fixture edit needed from lane o.
