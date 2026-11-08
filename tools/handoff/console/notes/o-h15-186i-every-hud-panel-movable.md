
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

--- codex run 2026-11-08 15:18 ---
2026-11-08: Continued after coordinator commit 839c17dc2 cleared the minimap fixture blocker. Queued cw-cx-hudmoveall. No tracked game or fixture file edited.

LOCAL: no linked review. This changes own-window HUD coordinates, pointer handling and saved layouts; no packet or shared game state changes.

Added offsets and drawn hit boxes for the clock/weather, score, extraction pill, edge extraction arrow, belt handle, air strike meter, teammate strip, left feed, danger banner and power chips. The existing gun/gear handle stays. The minimap now drags while preserving its fold chevron and resize priority. Settings has one reset hud layout button for every offset, size and fold state. Existing obstacle readers receive the moved rectangles. New grabs take the click before belt items and the trigger.

Layouts have a separate storage record per save key, career/arcade mode and player role. This preserves arcade layouts even when saveProfile refuses arcade writes and keeps the two roles independent. Legacy player 1 profile offsets are imported when no separate record exists. Drag, resize, fold and clamp saves use the layout writer.

Replaced the unfinished synthetic-rectangle check with actual rendered HUD staging. It draws every requested panel, drags its actual handle with mouse events, verifies its rendered rectangle changes, reloads layout storage, checks the restored rendered rectangle and resets it. It also tests a clock placed on a belt cell, player-role isolation and the Settings reset button. Transient plates stage through their real alert/feed/power/air/team data and draw paths. It restores both role storage records and the original network fields in finally.

Local validation: mk prints written against v37.65; all 28 anchors match exactly once, including in sequential application; the patched game inline JavaScript and new regression check parse with Node; mk script is ASCII. The minimap rename anchor was widened to avoid matching the new public wrapper during sequential patching. Browser regression checks cannot run in this sandbox and remain the lane gate.

Camera handoff: camera-recipes.json contains the requested scenes 21,33,34,50. Each moves the clock and extraction readout 82 screen pixels down. Scenes 21/34 use player 1; 33/50 use player 2 layout storage. Recipe scripts parse. Lane must photograph, run the critic and return the pictures, gate result and ON HIS PC line. No additional fixture retarget identified in this run.

Watch: whether grabbing a panel ever fires the gun or opens something under it.

--- codex run 2026-11-08 15:44 ---
2026-11-08 retry: The returned preflight log contains only remote scheduling messages ending in waiting for the spare pc: someone is using it. It contains no lint, regression, parse or draft failure to correct. Revalidated the unchanged cw-cx-hudmoveall draft against refreshed v37.65: mk prints written, all 28 sequential anchors are unique, patched inline JavaScript and new check parse, mk is ASCII. keys.txt still queues cw-cx-hudmoveall and the four moved-panel camera recipes remain ready. Please retry preflight; the remote gate should rejoin the same pending job for an unchanged draft and base. No game or fixture file edited. LOCAL: no linked review. Awaiting actual gate result, pictures/critic and ON HIS PC confirmation.


--- codex run 2026-11-08 16:05 ---
2026-11-08: Fixed the new check after the remote dry run failed twice with legend draw path has no handle. The test staged G.legendOn=0, whose drawLegend branch intentionally renders only LEGHINT and deletes HUDBOX.legend. The existing draggable legend panel is the compact list (G.legendOn=1). paint(id) now explicitly opens the compact list for the legend test, leaves it folded for other panel tests, and marks the one-time clock/extraction autofolds complete so they cannot close it during staging. The test still uses the real drawHUD path, real handle and mouse events, and checks movement, persistence and reset. No game behavior change was needed for this failure.

Rebuilt the draft against v37.65: written; 28 unique sequential edits; patched inline JavaScript and updated check parse; mk ASCII. The changed check creates a new preflight draft hash. cw-cx-hudmoveall remains in keys.txt and all four moved-panel camera recipes remain ready. No game or fixture file edited.

LOCAL: no linked review. Still needs passing remote preflight, ship, pictures/critic and ON HIS PC confirmation.

--- codex run 2026-11-08 16:07 ---
2026-11-08: Fixed the preflight dry-check TypeError (Cannot set properties of null, setting onclick). The reset test rendered renderSettingsInner into a detached div, but that existing function wires set_tune, set_text and other buttons through document.getElementById. Those ids cannot be found in a detached element. The check now selects the main Settings page and calls renderSettings(), which mounts and wires the real #setlist. It verifies #set_hudreset has an onclick handler before clicking, then checks every offset is reset, reset persistence and the other role layout. The prior Settings subpage is restored and Settings rerendered in finally. No game behavior changed for this test setup fix.

Rebuilt against v37.65: written; all 28 anchors unique through sequential patching; patched game and new check JavaScript parse; mk ASCII. Updated draft/check is ready for another preflight. keys.txt retains cw-cx-hudmoveall and the four moved-panel camera recipes remain ready. No game or fixture file edited.

LOCAL: no linked review. Remote preflight, ship, pictures/critic and ON HIS PC confirmation remain.
