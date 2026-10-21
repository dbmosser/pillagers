# 86b-pix-ground (lane a, 10-21 02:30)

## State
- Ship 1 key cw-pixground (mk in the scratchpad, draft tools/handoff/drafts/draft-cw-pixground.json): PASSED preflight and the whole gate except the last step. ship.sh start applied it as v33.57 (game, fixture, DESIGN, AUDIT in the working tree), then verifySafe printed TIMEOUT on gate Chrome 9346 and shipone stopped before the commit. The tree is left patched and uncommitted. Alarm written in alarms.md (02:25): the coordinator either finishes it (gate -Fix, then ship.sh commit 3357 cm3357.txt; the message copy is /tmp/cm3357.txt) or undoes it with git checkout of the four files. I cannot do either (no git write or gate.ps1 in my list).
- Then I re-ship nothing for pixground until the tree is clean. If the coordinator undid it: bash tools/handoff/preflight.sh a cw-pixground, then shipq.sh cw-pixground (the mk is unchanged and works).

## What ship 1 does (v33.57 when it lands)
- bakeGround with pixOn(): canvas ceil(W/2) by ceil(H/2) on a CPU canvas (willReadFrequently), ctx.scale(1/PIX_ENV): the very same drawing code, so rr() order is unchanged (check compares RNGS after the bake in both modes).
- Thin lines widened to one art pixel (interior floor lines, manhole rings), shed number alpha x2.4 so it survives the snap.
- pixGroundQueue / pixGroundStep / pixGroundChunk / pixGroundFinish / pixGroundFinal: the pass runs in 64x64 art pixel chunks (256 took 5.8 ms and 128 took 4.1 ms on the VM, the check wants 4 ms or less; 64 passed). Chunks under the camera at once, the rest at most PIXG.budget (4 ms) a frame from render2D. When the last chunk is done the CPU canvas is copied to a plain canvas (G.ground is swapped).
- Snap: per district and day/night a palette of 5 families x 4 tones (open floor from PIXRAMPS.districts floor band, building floor, road, water, turf). A pixel goes to the family of its nearest reference colour (the bare ground colour and district floor, with darker shades, count as open floor), the tone by lightness. So fades and halos become steps.
- Texture (grit() and own hashes of the absolute art pixel only): slab seams (vertical every 24 px, jittered per 20 row band, horizontal every 20th row), 1x2 and 1x3 strokes in 1 of 5 eight pixel cells, water strokes, grass teeth on the turf edge, bitten notches and light blades.
- Blit: render2D halves the source rect; smoothing off when Z*PIX_ENV is whole, on otherwise.
- Scars: scarOn scales the context by 1/pe, stamps snap to the 2 unit grid, bounds use the world size. gfxScarReplay uses scarOn.
- onCtxRestored needs no change: it calls bakeGround, which now returns a queued ground, then the scar replay paints onto it before the chunks run.
- Check (new, fails before: no pixGroundFinish): rr position equal, off = full size, on = half size, 64x64 open floor window per present district at most 8 colours (control window with the look off must hold more than 8), no chunk over 4 ms, whole bake under 1500 ms, a far corner scar accepted, a real raid built with the look on has the half floor.

## Next ships (written or planned)
- cw-pixhub (mk written, not run): bakeHubGround at half density snapped to the 8 tones of two ramps (cool plating and the warm lift glow), follows the switch at the next floor frame, check included. Needs ship 1 in HEAD (it calls pixGroundNear / pixGroundHex).
- cw-pixdecal (not written): footprints and decals snap their draw position to the 2 unit grid in pixel mode (render2D around G.prints and G.decals, translate/fillRect).
- Pictures still to take: raid at 1080 and 4K, day and night, the hub. The camera (uishots) runs the fixture, which pins xfPix 0, so it shows the OLD ground; a staging that sets CFG.xfPix=1 needs a camera recipe (tools/handoff/console/notes/camera-recipes.json style) or a questions.md ask. Not done.

## 10-21 later run (lane a)
- Tree still dirty (v33.57 applied, uncommitted, not in git log). Nothing new done; no git write or gate.ps1 in my list. Waiting on the coordinator: finish (gate -Fix, ship.sh commit 3357) or undo (git checkout of the four files). Then: preflight and shipq cw-pixground, then cw-pixhub, cw-pixdecal and the pictures.

## Watch lines for him
- Any hitch at the start of a raid (chunks of the floor finish in the first seconds; the ones under the camera are done in the first frame).
- Pillagers or machines blending into the floor at night (the night ramps follow PIX_BANDS.night; 86j measures it).
- Scars and brass casings keep soft edges on the floor (they are painted after the snap).

## 10-21 02:42 run (lane a)
- Tried shipq cw-pixground: MK FAIL, anchor matches 0, because the dirty tree already holds the v33.57 pixground patch. Still waiting on the coordinator: commit it (gate -Fix, ship.sh commit 3357) or git checkout the four files, then I re-ship.

--- codex run 2026-10-21 03:09 ---
## 2026-10-21 - Codex lane o preparation, based on v33.56
- 86a is complete in done/86a-pix-kit-switch.md. The v33.56 worktree has no pixGroundQueue or pixHubSnap, so the old cw-pixground timeout did not leave a shipped patch in this checkout.
- Reused the earlier mk-cw-pixground.ps1 and mk-cw-pixhub.ps1 work, with new cw-cx- keys and sandbox-compatible output paths. No tracked game or fixture file was edited.
- Prepared keys, in order: cw-cx-pixground, cw-cx-pixhub, cw-cx-pixdecal. All three generated their drafts. Applying all 26 anchors in order in a private preview succeeded; the whole game script and all three check bodies parse. Each check rejects the build before its new function exists. Browser checks and timing remain for the lane; none were run in the sandbox.
- Raid: same painter and seeded draws into a half-size CPU canvas, day/night district ramps, palette bands, slab seams, short strokes, turf teeth, and a queue. Kept the measured 64x64 processing tiles: the previous VM run measured 5.8 ms at 256 and 4.1 ms at 128. This is a deliberate exception to the requested 256 tile size to meet the harder 4 ms budget.
- Fixed two problems in the old draft: the bake transform is reset before scars can use the canvas, and original palette classifications are cached at tile borders so a different camera/chunk order cannot change the texture.
- The spawn view is processed during buildRaid before the first frame, with a cursor lean margin. Later visible tiles and the remaining queue use the 4 ms frame budget. A transient slow tile does not stall the queue forever. Context restore keeps the raid's chosen pixel mode, primes the player view, and uses the same queue. Ground blits choose smoothing using the actual device scale.
- The ground check now compares real seed-4242 builds in both sectors and both pixel modes: seeded position, full netUpFp equality, the 85/165 and 374/593 counts, and canvas dimensions. It also checks raw and completed canvas transforms, samples, timing, the far-corner scar, and spawn readiness. The control samples must have more than 20 colours.
- Hub: same original painter at half density, eight cool/warm ramp colours, and a full palette-membership check. Fixed the earlier draft's live rebake: the switch now takes effect at hub entry, not while walking around the same hub visit.
- Marks: footprints, water-ring centres and decal origins follow the baked floor grid. Their stored coordinates, tracking, visibility gates and rotations are unchanged. A check records their actual Canvas calls in raid frames, including a live switch change before rebaking and the original full-size path.
- Four camera recipes explicitly enable xfPix, since the fixture pins it off: sector 0 day, sector 0 night, sector 1 night, and the Undercroft. Staging and expectation scripts parse. Recipes use existing __cfg, __P, __gx and raid/hub hooks, so no fixture retarget is needed.
- Still required: lane preflight and shipping; inspect returned 1080p pictures and critic findings; coordinator 4K captures because tools/codex-lane.sh fixes recipe cameras to -Res 1080. See alarms-new.md. No critic score is claimed.
- Watch on the next play: any hitch at ascend, especially in both windows, and pillagers or machines blending into the night floor. Temporary CPU/source buffers are released when the floor queue is finished; the retained floor canvas uses one quarter of the original pixels.


--- codex run 2026-10-21 03:13 ---
## 2026-10-21 - first preflight timing failure
- The lane rejected cw-cx-pixground twice: the slowest chunk took 47.6 ms and 45.7 ms. No other new-check failure was reported.
- The chunk timer starts before getImageData, unlike the earlier lane-a draft. Its first read can force all deferred ground drawing to finish, charging a whole-world raster to one 64x64 tile. That is the likely cause; the feedback did not include the tile position or phase, so it is not yet proved.
- Updated the same key: pixGroundQueue now reads one pixel during bake setup to drain the original painter before any timed tile. This cost is still inside the existing whole-bake timer and its unchanged 1500 ms limit. Every chunk still times its full read, classification, texture and write, with the unchanged 4 ms limit.
- Added slowest-tile coordinates and read/classification/texture/write timings to any future failure message, plus the initial raster time. This will distinguish a read stall from texture work or a later pause if the next preflight still fails.
- Regenerated the raid and hub drafts against v33.57. All 26 anchors apply in order in the private preview, and the whole game plus all three checks parse. The tracked game and fixture remain unchanged. Keys and camera recipes are unchanged. Lane preflight, shipping and pictures are still required; the existing coordinator handoff for 4K still applies.


--- codex run 2026-10-21 03:30 ---
## 2026-10-21 - raid ground shipped; hub stopped on the shared news stamp
- cw-cx-pixground shipped as v33.60; the workspace is now v33.61. The raster-flush repair passed preflight and the ship gate.
- cw-cx-pixhub passed its new check twice on the draft and failed twice on the control, as intended. The gate stopped only on the unrelated older check 33.46: the news stamp is stale. Nothing from the hub key shipped. Keeping the same key and its passing implementation/check.
- Confirmed the cause: dark_raiders.html has WHATSNEW_VER='33.46'. At v33.61 that is exactly the allowed 0.15 behind; drafting v33.62 exceeds it. Any next ordinary ship hits this same stamp check.
- The Codex addendum explicitly assigns What's New refreshes to a Claude lane and says to hand them over in questions-new.md. That handoff is written. Next unused generator number found is P45 (P44 is the highest existing mk-card-autoP script).
- Generator compatibility detail for the Claude lane: genP.sh still uses mk-card-autoA3.ps1. Its new check requires WHATSNEW[0] to begin with the old alpha text and WHATSNEW[1] with polish pass text. The current card's first three entries and wnList() were deliberately shortened by cw-cx-shortnews. Running the old generator unchanged would replace this stale-stamp failure with a new-card check failure. Preserve the three current short notes and adapt the refresh check, or update the notes through the normal UI process; do not restore the old long card just to satisfy the generator.
- Regenerated the unchanged hub and decal drafts against v33.61. All 10 remaining anchors apply in order and the resulting full game plus both checks parse. The tracked game and fixture are unchanged. keys.txt still lists the shipped ground key followed by the same hub and decal keys; the lane skips the shipped key.
- Remaining work: Claude lane news-card refresh, retry hub and decal, camera recipes/critic review, and the previously handed-over 4K capture. No new visual change was made in this run.


--- codex run 2026-10-21 03:36 ---
## 2026-10-21 - repeated stale-stamp stop; do raid photography meanwhile
- The workspace is still v33.61 and WHATSNEW_VER is still 33.46. The previous handoff reached questions.md but no refresh has shipped. The identical preflight stop has no new hub-code failure to repair. The explicit Codex addendum still assigns the card refresh to a Claude lane.
- Left the passing cw-cx-pixhub script and check unchanged, and preserved its exact key. Moved the two remaining keys to deferred-keys.txt; keys.txt now contains only the already-shipped cw-cx-pixground. This stops repeating a known external preflight failure.
- Enabled useful independent work: camera-recipes.json now contains the three shipped raid views only. The full four-view recipe is preserved in all-ground-recipes.json. The lane can take these pictures without attempting another blocked ship. No hub picture is claimed before its key ships.
- After the Claude lane refreshes the news stamp, restore deferred-keys.txt after the shipped ground key in keys.txt and run node .codex-work/86b-pix-ground/make-recipes.js without --raid-only to restore the full recipe. Then retry the same hub/decal keys, and capture the hub plus the required 4K views. The earlier questions.md handoff explains the legacy genP template mismatch; do not duplicate the owner question.
- Still partial: review returned raid pictures and critic findings, then finish the deferred ships and hub/4K pictures after the shared stamp is repaired. No game, fixture or player text was changed this run.


--- codex run 2026-10-21 03:41 ---
## 2026-10-21 - reviewed recipe round 1
- Opened and inspected all three returned raid images. All staged at 1920x1080 with zero camera lint findings. Picture paths and the complete follow-up are in .codex-work/86b-pix-ground/critic-followup.md.
- External results: raid night 2/4, cold-mile night 2/4. The day critic failed while writing accept.json (UNKNOWN/-4094), so it has no valid saved score. Cold-mile's recorded need:3 is a filename heuristic error; the task requires 4 for that raid too.
- Saved P0/P1 findings concern the existing right/left HUD panels, timer/extract hierarchy, ammo panel, hotbar, panel family, colours and health/stamina. None identifies a ground-specific defect. Kept these findings open and handed them to the coordinator for raid HUD work; no visual acceptance is claimed.
- Current game/stamp are unchanged at 33.61/33.46. Remaining hub and decal keys stay preserved in deferred-keys.txt until the required Claude-lane news refresh. No pointless preflight retry or new camera round was queued.
- Coordinator also needs to recover the day critic using the existing picture, then complete post-hub and actual 4K photography. Existing scripts, key names, recipes and tracked files are unchanged this run. Task remains partial.

