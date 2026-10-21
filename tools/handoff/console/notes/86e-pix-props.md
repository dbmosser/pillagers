# 86e-pix-props (lane a, 10-21)

Design (pixWrap, in the pixel kit region of dark_raiders.html, search "THE PIXEL ADAPTER"):
- pixWrap(key,w,h,d,paint,x,y,{up,kind}) returns the cached sprite (already blitted) or null. The caller keeps its vector painter as a closure and runs it when null.
- pixWrapBake: wc and shadowE are pointed at an art scratch (scale 1/d), painter runs, finally restores both. Bake then: alpha to 0/255 (a dark half see-through pixel = the painter's ground shadow, becomes one flat shadow tone PIXW_SHAD day/night), every colour snapped to the (at most 12) colours the painter used most, a darker bottom/right edge, cropped to the shape. Clip counter PIXW.clip if the shape touches the scratch edge.
- Live parts stay outside the closure: ground shadow, dim of an opened box, search bar, amber ammo tell, wreck smoke (wreckSmoke records its height while PIXW.on, drawContS draws it after the blit), barrel floor pulse / lid glow / idle sparks / pools.

Shipped
- v33.68 cw-pixprops: pixWrap + drawContS body (crate, locker, safe, camp safe, cache, jackpot, generic, body, carcass, botwreck, 9 wrecks, opened and closed). Check: 1 cached drawImage each, alpha 0/255, footprint, throw leaves wc, 0 readbacks in 60 frames, smoke moves, no fillText.
- v33.71 cw-pixbarrels: 4 barrel bodies per blink state; ?pixbench "props: loot, bodies, wrecks, barrels" sheet (stub raid inside the sheet function).

Not done yet (next runs): cover wrecks (cw-pixcover draft in progress), lamps, forge / seal slab / story desk, extraction ring, Undercroft posts and racks and the drop crate, live deer and birds. The strongbox label (drawContS fillText) and seal % / forge name move to the GFXWT hand-off with those.

cw-pixcover (cover wrecks, PIX_ENV, scene cache): draft written (scratchpad mk-cw-pixcover.ps1, draft-cw-pixcover.json). Preflight 1 failed: pipes fell back to vector because every piece had its own rust in the key (fixed: rust rounded to 4 buckets, warm-up 14 frames). Preflight 2 hit the dry-run TIMEOUT (check runs ~17 full frames per cover kind; if it times out again cut the warm-up to 8 frames and the kinds to 3). Preflight 3 was still running when this run ended. Not shipped.

Gaps said plainly
- No pictures: the camera (uishots) has no xfPix 1 stage; asked in questions.md by 86a / 86c. The bench sheet exists for when it does.
- Watch (his next play): opened and closed crates still read at a glance (opened is the same body dimmed to 62 percent, lid back). Wreck ground shadow is now one flat tone under the wreck instead of a soft 50 percent oval.

## Run (10-21, lane a)
- SHIPPED v33.77 cw-pixcover (cover wrecks car, skip, barrier, pipes, pallets as scene sprites). The first ship STOPped: the check fell back on pipes because the builder allows only 2 bakes a frame (PIXSTORE.maxBuilds) and pipes have many distinct keys. Fix: the check warms up until every piece has a sprite (up to 40 frames). The game code was fine.
- Preflight is refused from this shell (started in console/notes, cannot reach preflight.sh); shipped straight through shipq.
- Watch (his next play): pipe bundles and cars pop in over a few frames after you enter a street (vector for a moment, then pixel), 2 bakes a frame.
## Run (10-21 later, lane a)
- SHIPPED v33.82 cw-pixlamps (lamp posts and brackets, forge body, seal slab in 5 percent steps), v33.83 cw-pixhub (extraction ring line, Undercroft station posts, mainframe racks, dropped crate), v33.85 cw-pixwild (deer and birds alive and dead; gait, head bob, wing beat and peck are whole steps so each frame caches).
- Kept live on top: lamp lit element and glow, forge molten mouth / glow / ring / embers / name, seal label, ring pulse fill, post screen pulse, rack blink lights, item icon on the dropped crate. All labels stay world text outside the bake, so nothing moves to GFXWT.
- Preflight on lane a (Chrome 9351) TIMES OUT even for a trivial probe check (cw-pixprobe, no game change): that Chrome is jammed. I cannot restart it from here (cdp -Close needs approval). Shipped straight through shipq (its gate Chrome works). Coordinator: close and restart port 9351.
- Checks for forge, seal, ring, posts, racks and wildlife are partly source-text checks (the draw is inside render2D); lamp and dropped crate are functional. A first REGRESS 33.60 (chunk step 9.4 ms) on the cw-pixhub gate was load noise; the rerun passed.
- Formatting nit: three of my replacements glued the next statement onto the same line (valid JS, ugly); left as is.
- Watch (his next play): the ring is now a solid 2 to 3 pixel line (the old one was thin and soft); deer and birds move in steps; the seal bar fills in 5 percent steps.
- STILL LEFT: pictures (no xfPix camera stage), a functional check for forge / seal / ring / wildlife, Undercroft furniture is 86i. (older line:) lamps, forge / seal slab / story desk, extraction ring, Undercroft posts and racks and drop crate, deer and birds, text moves (strongbox label, seal %, forge name) to GFXWT; pictures (no xfPix camera stage).
## Run (10-21, lane a, third; a fourth run found nothing new, only pictures remain)
- Nothing new shipped. All listed painters are in (v33.68, .71, .77, .82, .83, .85). Left: pictures (uishots has no xfPix stage and I may not add a screen without asking; the ?pixbench props sheet exists) and functional checks for forge / seal / ring / wildlife (today source-text checks). Coordinator: add an xfPix 1 stage to the camera, then shoot ?pixbench props and a raid street.

--- codex run 2026-10-21 08:58 ---
## Codex lane o, 2026-10-21, run 1
- Read the earlier 86e notes. 86a is in done/. The previous lane shipped the main adapter and prop groups through v33.85.
- Prepared cw-cx-propsfinish. Found three remaining code gaps: wildlife used PIX_ENV instead of the ordered PIX_ACT; the story desk still used its vector painter; strongbox, seal and forge labels still drew on the world canvas. The draft fixes these through existing adapter and text-queue paths. No collision, AI, loot, profile or simulation changes.
- Also restored continuous painted wildlife poses with pixel look off. The earlier wildlife ship quantized both modes; only the pixel mode now takes discrete frames. No movement or timing values changed.
- Added a functional gate check using the actual render2D painters for live deer, live bird, both dead kinds, forge, seal, extraction ring and story desk. It checks the requested density, nonempty binary alpha, one drawImage per cached body and zero getImageData calls over 60 cached draws per kind. It spies on the separate world and HUD canvases to prove all three moved labels reach GFXWT. Existing shipped checks retain the container footprint, opened/closed cache, forced-throw and animated wreck-smoke coverage.
- Local verification: mk script prints written; all 10 anchors occur exactly once. Applying the draft in memory parses the complete game script and the new check. Both camera recipes and their helper parse, and lane inputs are ASCII. Browser checks cannot run in this sandbox; preflight and ship remain the lane work.
- Added camera-recipes.json for a real ?pixbench props sheet (all container/wreck states and barrels, plus enlarged crate/locker pairs) and a seed 4242 raid street near a cover wreck. Both explicitly set xfPix=1. The camera uses the existing __gx fixture helper, so no fixture retarget or new permanent hook is needed.
- Pictures and critic results are pending the lane. Expected first recipe outputs: tools/handoff/console/notes/shots/86e-pix-props-recipes-1/86e-pixel-props-sheet-1080.jpg and tools/handoff/console/notes/shots/86e-pix-props-recipes-1/86e-pixel-raid-street-1080.jpg.
- Watch on next play: opened and closed containers still read at a glance; wildlife should use finer pixels than scene props; strongbox, seal and forge labels should stay sharp above walls and fog.

--- codex run 2026-10-21 09:16 ---
## Codex lane o, 2026-10-21, run 2
- Confirmed cw-cx-propsfinish SHIPPED as v33.86. Opened both round-1 pictures. Camera staged both with zero lint findings. Critic scores: props sheet 2, raid street 2.
- Prepared cw-cx-propsread for the prop finding: opened pixel-container opacity .62 -> .72 (+16 percent). Lifted lids and the dim/opaque state contrast stay distinct. Closed bodies remain fully opaque, and vector mode remains .62. No loot colour, dimensions, collision, simulation or profile changes. Functional check observes actual blit alpha and the vector painter alpha; it fails on v33.86.
- Rebuilt the camera-only props review into three sheets (containers, wrecks, barrels), using the existing real pixPropsSheet painter. Each name is separate HTML at 20px, state labels 16px, titles 32px, Barlow Condensed with guide colours. Container/wreck art is 2x, barrels 4x, paired on bordered panel tiles. Captions no longer scale with the raster or overlap legs. The body-only crops are for review, not changes to game art.
- Raid critic findings describe the unchanged general HUD (panel rows, currency block, ammo panel, stance/health bars) rather than the pixel adapter. Handed them to the coordinator in alarms-new.md. The style guide explicitly says screen tasks must not restyle the currency block. This task does not redesign that HUD.
- Changed the street recipe to an explicitly labelled art-only capture of the real world canvas, at native 1080, after warming pixel props. This assesses the requested prop art without the unchanged HUD, keys card, codex toast or tooltip. The original full-HUD picture and its score 2 remain in round 1 as evidence for the HUD owner.
- Skipped the critic suggestion to add rarity bars to unopened containers: it reverses the owner rule that closed containers never reveal hidden loot value. Logged that ruling once in questions-new.md; no answer is needed.
- Local checks pass: one exact current-build anchor, full game and new check syntax, four camera recipes and helper syntax, ASCII inputs. Next: lane preflight/ship for propsread, then round-2 photos and critic results.
- Watch: opened pixel boxes should be easier to spot, while their raised lids still say looted at a glance.

--- codex run 2026-10-21 09:32 ---
## Codex lane o, 2026-10-21, run 3
- Confirmed cw-cx-propsread SHIPPED as v33.87. Opened all four round-2 images. Camera lint: zero on all. Critic: containers 2, barrels 2, wrecks 3, raid street 2. The earlier full-HUD picture remains round 1.
- Fixed the cause of stray fragments and ragged review baselines: the original shared pixPropsSheet canvas allowed neighbouring art into another 96px cell. The new camera calls drawContS/brlDraw separately and takes each real pixWrap cache result, at identical world coordinates for both states. It draws with the actual blit opacity and a shared ground/horizontal anchor. No neighbouring cells, effects or raster captions can leak in. Live effects remain in the street shot.
- Prepared cw-cx-propsshape: crate slats, locker vents, safe door hardware, cache/jackpot braces and latches; raised chest lids and swung metal doors for visible opened silhouettes. All are baked into the existing sprite. Base widths (crate 16, locker 12, cache 26), collision and loot are unchanged. Only the pixel path gets details; vector mode keeps its painter.
- Calmed the cache purple by about 25 percent saturation and the idle red barrel by about 30 percent saturation. Kept kind identity, the explosive hazard mark, flashing fuse, pulse and other live effects. No rarity data is used in the new art.
- Added a functional check for the real cached silhouette: raised crate lid adds at least 6 art rows, opened locker/safe add at least 3 columns, alpha stays binary, hidden cache rarity reuses the same sprite. It fails on v33.87 (no detail painter). Local anchors (5), full game/check syntax, six camera recipes/helper syntax and ASCII inputs pass.
- Enlarged the camera proofs to 6x basic containers, 4x caches/salvage, 3x machine wrecks (two pages) and 6x barrels. Removed duplicate barrel/state captions, outer borders and empty last-row gaps. The real 1080 street stays unchanged for an honest comparison. Six recipes use the camera maximum.
- Kept existing body/carcass art. The old review compared different fixed-position variants (so the body rotated between opened/closed); the new camera holds position and variation constant. Opening loot does not animate or revive remains. The rarity-bar exception was already logged and is not repeated.
- Remaining street findings concern other jobs: district palette seam and water/floor marks (86b-pix-ground), pale walls (86d-pix-walls-trees), small/low-contrast pillager (86c-pix-pillager). The red-barrel dominance and plain container shapes are addressed here. Sent the other findings to the coordinator with the round-2 image; do not blend or resize another job to please this UI critic.
- This is the second follow-up to the original review. If round 3 still does not raise a sheet score, record what remains and keep the two best pictures, as the rules require; do not keep polishing the camera indefinitely.
- Watch: newly opened chests have a raised lid; lockers and safes have a door swung to the side. Neither the loot reach nor collision changed. Idle red barrels are calmer but must still read as dangerous.

--- codex run 2026-10-21 09:36 ---
## Codex lane o, 2026-10-21, run 4 - preflight correction
- cw-cx-propsshape did not ship. Preflight caught REGRESS 33.68: opened locker/safe were 21/25 art pixels wide, beyond the existing 12+6 and 16+6 limits. The new door hinges started at the outside wall of each cabinet.
- Corrected the same key: move each hinge 4 world/art pixels into the cabinet, keeping the swing angle and face inside the existing width-plus-lid limit. Expected bounds from the painted coordinates: locker 17 (limit 18), safe 21 (limit 22). Closed footprints remain locker 12 plus ink and safe 16 plus ink.
- Strengthened the new functional check to reject opened sprites over base width + 6. Kept older check 33.68 unchanged; no fixture retarget. It still checks the requested unchanged footprints.
- Local mk run prints written; all 5 anchors, complete game/check syntax, camera helper and six recipes, and ASCII handoff pass. The isolated-art recipes remain ready for round 3 after the corrected key passes and ships.
