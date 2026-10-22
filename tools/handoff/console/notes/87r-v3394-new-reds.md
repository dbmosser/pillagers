
--- codex run 2026-10-22 01:20 ---
2026-10-22, run 1, v33.94. No game edits or ship keys this run.

Reproduced the stable picker's exact 32 by replaying its last twelve finished corpus files, four-run window, baseline and continuing-suspect rule. A direct two-file subtraction alone gives 35 after baseline exclusions. The extra three (29.33, 27.36, 26.38) were already known in the four-run window. This distinction is why the task says 32. The full list and original messages are saved in stable-new-failures.json in this task's workspace output folder; failures.json also preserves all 37 and the raw delta. inspect.cjs computes the inventory without changing the stable picker.

Exact 32: 8.55, 8.61, 9.27, 33.89, 33.76, 33.51, 33.33, 31.50, 31.32, 28.04, 27.93, 26.79, 26.50, 26.20, 25.33, 25.17, 24.39, 24.17, 24.00, 18.34, 14.71, 12.05, 11.14, 11.12, 10.99, 10.93, 10.87, 10.86, 10.84, 10.83, 10.82, 9.71.

Handed the lane fixture-retarget.json with 14 check updates, keys: []. These are proposed repairs to stale checks and their staging, NOT a claim of browser passes. No threshold was lowered, no check deleted, no SKIP added, and no known-red or baseline entry changed. The three wardrobe checks retain their original assertions on the vector path; the shipped 33.91 check covers the replacement four-rack pixel wardrobe and its sets. The Forge check records the real HUD world-text pass (_wtA), not just a queued label.

Validation completed locally: all 14 full-check anchors occur exactly once; official retarget.mjs plan accepts the packet; the altered fixture builds using Windows PowerShell; official retarget.mjs jscheck reports one inline script, 13,581,984 characters, compiles. The injected fixture JavaScript also parses independently. Browser assertions cannot run in this sandbox; the lane must execute these 14 before committing. The lane has no game key to ship. keys.txt is intentionally empty.

Cause per proposed update (also suitable for the DESIGN cause record when a later game batch needs it):
- 8.55: check/staging issue. 50923073 v33.34 deliberately gives the Howler stepHowl; the old ordinary-step list mistakes that for a heavy step.
- 8.61: check/staging issue. Rendering time is added to every synthetic timestamp; after the pixel pass 50 frames can exceed the 1.4 second boarding hold before the leave arm begins.
- 9.71: check/staging issue. The same moving performance.now base makes the one-second negative control last longer than a second on costly drawn frames.
- 33.76: check/staging issue. 2777558e v33.93 adds a deliberate pixel builder failure probe; the door check reads the lifetime fault counter rather than faults caused by doors.
- 28.04: check/staging issue. 283cb756 v33.91 replaces the scheme picker with four pixel racks. This legacy scheme check never resets xfPix and therefore addresses 13 unrelated pixel tiles.
- 14.71: check/staging issue. 283cb756 v33.91 intentionally lets the pixel Surprise Me roll owned full-body sets. The old check tests vector rack visibility without pinning that path.
- 25.17: check/staging issue. 283cb756 v33.91 has 120px pixel preview tiles; the old 156px vector rack minimum is still tested on the retained vector layout.
- 27.93: check/staging issue. b51c3b39 v33.49 replaces the old five-plus alpha notes with exactly three short public notes; open, Escape and Close must still work.
- 26.79: check/staging issue. 98bb3d2b v33.26 scales the Warden weak seam by 1.33. A rear shot 14 units off-centre now hits the seam (300) instead of testing ordinary rear armour (150).
- 26.20: check/staging issue. 57804f59 v33.86 moves the Forge name into CACHETAGS and the HUD world-text pass; the old recorder listens on wc only.
- 25.33: check/staging issue. 812f64be v33.36 replaces MINIMAP ON/OFF with the one mmSize row (OFF, S, N, L), default OFF. The old check still requires the deleted control.
- 31.50: check/staging issue. 7a96286a v33.38 merges the stash/backpack row plates. The negative label-overlap arm must target the protected gap under the compact block rather than a gap that no longer exists.
- 31.32: check/staging issue. 7a96286a v33.38 and 1aabe323 v33.39 replace four individual wallet plates with one two-column block, label cash, and a 20px internal gap. The old judge still demands seven equal-height plates.
- 12.05: check/staging issue. 7a96286a v33.38 moves notes logged into the compact HUD block. topRightBottom measures the hidden DOM readout and no longer describes the visible note row.

Still unresolved (18), with original symptoms preserved rather than loosened:
- 9.27: standing 13 units inside the container roof, nothing is drawn through it: 0 percent of the box responds to the dial
- 33.89: sentry bounds 3 differ from job 80 by 2 art px (-27,-72,54,0 vs -28,-73,55,2)
- 33.51: the raid frame is not steady between two frames, so it cannot be compared; with the pixel look off the raid frame differs from the frame with every pixel path stubbed off
- 33.33: group raid is 0px tall; group combat is 0px tall; group events is 0px tall; group extras is 0px tall
- 26.50: FOUR: control: with no muzzle flash the picture moved by 34542 with the row
- 24.39: the floor at (0,0) from the blast went from 114.0 to 114.0, not 12 or more darker; the floor at (12,0) from the blast went from 114.0 to 114.0, not 12 or more darker; the floor at (-12,0) from the blast went from 114.0 to 114.0, not 12 or more darker; the floor at (0,12) from the blast went from 114.0 to 114.0, not 12 or more darker; the floor at (0,-12) from the blast went from 114.0 to 114.0
- 24.17: the floor shows brass at only 0 of the 60 landing points, not 50 or more
- 24.00: the scorch darkened the floor by 0.0, not 20 or more (125.2 to 125.2)
- 18.34: control: the belt key is not painted inside (alpha 32); the belt key corner is square (corner 35, inside 32)
- 11.14: the crawler in building 8 got no closer than 400 units in fifteen seconds, so its doorway is still not walkable
- 11.12: guard: the crawler in building 14, which reached the player at 34 units before this build, now gets no closer than 400
- 10.99: headgear changes a pillager by 0 pixels against a noise floor of 0, so a rack he rolled is not drawn on him; control: headgear now changes the operator by only 0 pixels, so this was fixed by taking it off her; the beard changes a pillager by 0 pixels against a noise floor of 0, so a rack he rolled is not drawn on him; control: the beard now changes the operator by only 0 pixels, so this was fi
- 10.93: control: lift, trader, gamble, term, mf, bar, mirror, dev painted almost no ink either way, so the instrument cannot see them; the station names put only 0 of ink into the picture, which is the see-through look he reported; control: the room only went from 0.0 to 0.0 brightness, so the darkness test proves nothing
- 10.87: holding SHIFT does not sprint at all; the right SHIFT does not sprint; releasing and pressing SHIFT again does not sprint after getting your breath back
- 10.86: opening the pause box ducked the bed 0 times, and it should be exactly once; a second pause ducked the bed 0 times rather than once, so only the first pause in a raid is quiet
- 10.84: COLD STORAGE: 13 of 13 buildings are boxes a machine cannot route out of, against the 3 this build measured [5,6,8,9,10,11,13,14]; THE COLD MILE: 59 of 59 buildings are boxes a machine cannot route out of, against the 8 this build measured [0,1,2,3,4,6,7,8]
- 10.83: COLD STORAGE building 12 has fallen and only 0.0 percent of its square on the map is drawn any differently, under the 40 a mark has to clear; COLD STORAGE building 14 has fallen and only 0.0 percent of its square on the map is drawn any differently, under the 40 a mark has to clear; control: nothing at all differed on COLD STORAGE, so the map may not have drawn; THE COLD MILE building 7 has fa
- 10.82: COLD STORAGE building 0 is standing and 5.5 percent of its floor changed anyway; COLD STORAGE building 1 is standing and 5.1 percent of its floor changed anyway; COLD STORAGE building 2 is standing and 5.3 percent of its floor changed anyway; COLD STORAGE building 4 is standing and 6.9 percent of its floor changed anyway; COLD STORAGE building 5 is standing and 4.7 percent of its floor changed

Next investigation pointers, to avoid repeating large reads:
- 33.89: its own ship is 7214602f. rawBounds uses p.m and an unoutlined vector mask; pixMachFinish adds pixRing(s.c, PIX_INK, 0, 1). The sentry bottom differs by two art pixels, not one. Need determine whether sampling/outline alignment is responsible or the body actually grew; do not just raise tolerance. Source functions at dark_raiders.html 51051 (pose), 51084 (finish), 51192 (draw), 50803 (wrap bake). Check starts fixture 6458.
- 33.76 now tests the fault counter delta because 33.93 deliberately trips the guard. Do not reset the game's counter to hide faults.
- 33.51 compares whole rendered-frame hashes across successive __frame(.016) calls, with live rendering and its random/time-driven layers. Current setup is fixture 8394 onward. Need isolate the intended xfPix-off comparison while retaining a non-empty image and deterministic control.
- 33.33 group rows get a scoped 48px CSS rule only under #settingsmodal.expmode. The test uses modal.classList.add('on'), SETSUB='exp', renderSettings(). Adjacent 33.28 adds __setDetailSync(); both otherwise stage similarly. Source expPage at 3918, CSS 2284-2290, renderSettings 70589, detail sync 68280. No cause proven for its 0px rows yet.
- Timing probes: __loop is a fixture wrapper at line 564. loop calls frameCapSkip before updating lastTs, and exits immediately if ctxLost. __runPrep (102635) heals ctx prototype aliases and resets DPR/profile, but does not check a lost world canvas. 8.61 and 9.71 wrongly used performance.now() inside each frame; the submitted fixes use one base per trial and one monotonically increasing frame counter. Routing/sprint/pause checks already use a fixed base, so that repair must NOT be assumed to fix them.
- The blank 10.99/10.93/10.83/10.92 readings plus frozen routing/sprint/pause in the same [2280,2400) slice are consistent with lost/exhausted canvas contexts (loop returns on ctxLost), but that is a hypothesis, not a diagnosis. Never clear ctxLost or skip these checks to force a pass. 10.92 is baseline, outside the task's 32. 10.99 starts 93694; 10.93 94211; 10.83 94770; 10.82 94836; routing 11.14 92671, 11.12 92772, 10.84 94702; sprint 94559 and pause 94611.
- The Forge label changed in 57804f59 (33.86), verified with git log -S and its diff, rather than the earlier 33.82 Forge sprite ship. All modes now send the label through CACHETAGS. The submitted recorder allows the legacy wc draw and the actual _wtA HUD draw, with no empty-label success.
- Ground tests: 24.00 starts fixture 45461, 24.17 44750, 24.39 44058. bakeGround got half-density support in 14799c50 (33.60); scarOn at game 52613 scales stamps by ground._pe; scarPaint at 52557 dispatches pixScarPaint only if pixOn(). __resetCfg and __pinDefaults both pin xfPix=0, so first prove the current tests actually have a half-density ground before changing their samplers. The unchanged legacy floor should not produce zero stamp darkening.
- 26.50 has a whole-frame muzzle-flash A/B and a no-flash control; the no-flash image changes by 34,542. Its draw code reads performance time for some effects. Keep its 3,000 quiet-control bound and >4,000 muzzle-flash difference; isolate moving scenery before any retarget.
- 9.27 ghost sampler measures a 28x35 area just above the player foot. Source ghost branch is 40603 and still runs only on seeThrough, !G.sim, G.wgrid. It draws the real actor at .55 alpha when under a roof. Need see whether the measurement area/landing camera misses the current silhouette, or the player's ghost really disappeared. Do not delete its positive and negative controls.

This is a handoff for lane validation, not a completed task. On the next run, read the lane's results first. If the 14 edits commit, do not regenerate old edits using build-retarget.cjs against the already-edited fixture: keep their applied hashes and add only new edits to fixture-retarget.json. All 18 above still need diagnosis and then game fixes or justified retargets. No approval or owner question is needed.


--- codex run 2026-10-22 01:30 ---
2026-10-22, run 2, v33.94. No game edits or ship keys.

The first trial committed nothing. It reported failures only in 8.61 and 12.05; the other twelve submitted checks passed that trial. Corrected both failures:

- 8.61: my first clock edit covered the opening hold and leave leg but missed the return leg's variable named fr. That leg still added CPU/render time to its synthetic time, explaining extraction after 29 supposed frames. All three loops now call the same monotonic step() helper. The builder explicitly refuses an 8.61 replacement containing any remaining __loop(performance.now() call. The positive continuous-hold control and negative leave/return control are unchanged.
- 12.05: the prior-label recorder accepted every canvas and every y position. That let unrelated stash/backpack labels below the compact wallet count as prior wallet rows. It now records ctx only, and compares the note against cash/xp/stash/backpack labels strictly inside the compact wallet's vertical bounds. Missing notes, notes outside the wallet, missing wallet figures, notes above those figures, off-screen notes and conditions-panel overlap still fail.

Added two more proposed retargets, with their causes in retarget-causes.json:

- 33.89, cause 7214602f v33.89: pixMachFinish explicitly grows the rasterized machine with a one-pixel cross-shaped ink ring. Its old bounds test combines vector-to-raster rounding and the added ink into one one-pixel allowance. The check now captures the unoutlined sprite passed to the actual finisher. That body's bounds still must match the independent job-80 vector rendering within the ORIGINAL 1.01 pixels. It then tests EVERY final alpha pixel against the exact cross-dilation of that body, so missing ink, extra growth, missing body pixels and diagonal growth all fail. The original hard-alpha, hit-mask, cache, draw-budget, filter, alarm and title-sentry assertions remain. The wrapper is restored in finally. No size tolerance was increased and no game art changed.
- 33.51, cause the moving render comparison introduced in 2b74028b v33.51: the check hashes successive __frame(.016) images despite camera easing and cosmetic FXS consumption. Its comparison now warms with dt=0 and redraws from the same FXS value at dt=0 each time. The repeated-frame equality control remains. A new non-flat-image control rejects blank/empty captures instead of letting equal blank images pass. The real xfPix=0 frame must still equal the frame with pixOn stubbed false. FXS and pixOn are restored in finally. No hashing tolerance was added. This is a proposed staging repair, still needing browser validation.

The new fixture-retarget.json contains 16 edited checks plus run:[9.27,33.33,26.50,24.39,24.17,24.00,11.14,11.12,10.99,10.93,10.87,10.86,10.84,10.83]. Those fourteen additional checks are UNCHANGED. Run them before deciding that their assertions need retargeting. This uses exactly the lane's 30-check trial limit and supplies evidence on the blank pictures, stuck routing, sprint and pause failures without inventing fixes or relaxing controls. The trial's result will also show which failures depend on the longer corpus slice's preceding tests. An isolated pass alone does not prove a repeated corpus contamination issue has been fixed.

Not covered in this trial: 18.34 and 10.82. They remain pending, unchanged. Investigation notes for them:
- 18.34: its alpha sampler uses logical G.hotCells coordinates times world DPR. Source HUD cells are generated inside the belt transform at game 41726-41729; the HUD backing scale is DPRH and group plates lie behind the cells. Before changing alpha/shape thresholds, establish the actual drawing transform and whether the sample reaches the first cell. Preserve the positive painted-interior control. The source layout was not changed by pixel machinery in the v33.17..v33.94 range (git log -S G.hotCells has no hit in that range).
- 10.82: its paired ground canvases are still read as legacy full-density floors because __resetCfg and __pinDefaults pin xfPix=0. bakeGround's half-density path is conditional and writes _pe only in that path (game 13163 and 13503; pixGroundQueue 50916). A 5-percent change in standing floors must not be accepted merely because the pixel pass shipped. Check the cosmetic stream and the actual per-arm floor scale before changing samplers or thresholds.

Local validation of the final packet: official retarget.mjs plan STATUS ok, all 16 anchors unique against the current fixture, exactly 30 trial versions; edited fixture built in Windows PowerShell; official jscheck reports one inline script and 13,583,712 characters compile. The injected JavaScript also parses. The build and syntax checks do not execute browser assertions. keys.txt remains empty; no camera request is needed for fixture-only edits. No baseline, known-red list, tracked game file or tracked fixture was edited.

Next run: read the lane's 30-check results first. If it commits, preserve applied edit hashes and add only new edits. If it rolls back, correct the failing assertions/staging using those results; do not repeat the old notes-new.md. All task work remains authorized; no question or permission is needed.


--- codex run 2026-10-22 01:43 ---
2026-10-22, run 3, v33.94. Found and drafted a game fix; no tracked files edited.

The 30-check trial reported only 24.00, 24.17, 24.39 and 26.50 failing. Thus all sixteen edited probes held, and ten of the fourteen unchanged extra assertions held. Nothing committed because the batch correctly refused the four failures.

Confirmed the shared game fault, introduced in 14799c50 v33.60: bakeGround declares function-scoped var _px as the requested pixel-mode flag at game line 13165. Its pre-existing ruined-building rubble loop also declares var _px for each rubble fragment x-coordinate at 13233. JavaScript var has function scope. Any ruined building overwrites the boolean with a positive coordinate. The function then takes its pixel branch at line 13503 even when it allocated a full-size legacy canvas. pixGroundQueue tags that full-size canvas with _pe=2 and starts posterizing it incrementally. scarOn scales stamps by _pe while the legacy tests sample world coordinates directly. This exactly explains zero scorch/frag darkening and missing brass at the sampled locations. It also changes the floor under repeated no-flash captures and makes the ruin-on arm enter a different pipeline from the ruin-off arm in 10.82.

Prepared mk-cw-cx-groundmode.ps1. Its sole edit renames the rubble x-coordinate and its two fillRect references to _rubbleX. The pixel flag and its other callers stay as written. This fixes the game rather than loosening 24.00, 24.17, 24.39, 26.50 or 10.82. The draft why records the cause per check for the automatic DESIGN.md section. Watch: with pixel look off, verify stable floor texture and scorch/brass at the correct landing positions.

Local negative-control verification uses the ACTUAL original and patched bakeGround functions, executed with a recording canvas and one ruined building (validate-groundmode.cjs; results groundmode-validation.json):
- Original, pixel off: full 512x512 canvas, but enters pixel queue once and is tagged density 2. This reproduces the fault.
- Patched, pixel off: full 512x512 canvas, no pixel queue, density 1.
- Original and patched, pixel on: 256x256 canvas, one queue entry, density 2.
- Both versions in both modes draw 492 rectangles and make 3,280 random calls. Pixel-mode rectangle coordinates are identical. This probe verifies mode bookkeeping and drawing coordinates, not browser raster pixels.

The mk script was executed against local MK_SRC/MK_OUT_DIR, printed written, and produced a draft with exactly one unique anchor and exactly three renamed coordinate references. The patched game inline JavaScript compiles. The fixture with all sixteen retargets plus the patched game builds in Windows PowerShell and compiles (13,583,698 inline-script characters). The new regression object also parses.

The new game's regression first builds a real ruined map in both pixel modes and asserts requested density, dimensions and absence of a pixel queue in legacy mode. It then runs the ORIGINAL six remaining checks, without altering their assertions or allowing SKIP to pass: 24.00, 24.17, 24.39, 26.50, 18.34 and 10.82. Consequently a passing preflight will validate all six pending task checks on the drafted game. The belt check has no proposed retarget: run it on the clean draft before assuming that its old corpus failure requires a change.

Updated fixture-retarget.json so it runs only its sixteen edits and the ten unchanged checks already held in the latest trial (26 checks). Removed the four game-broken floor/flash checks from the BEFORE-game retarget run; they belong in the new game regression, not in a retarget that must pass on current v33.94. The packet keys list now correctly names cw-cx-groundmode as dependent. keys.txt lists that one key. The lane must apply the fixture retarget, then preflight and ship the game key. A failed retarget must still hold this key.

shots.txt requests 21-raid-hud-calm. Its existing recipe deploys seed 4242 on map 0 through the fixture, whose pixel dial is pinned off, so it shows the repaired legacy ground. Record the before/after pictures and critic result before marking the job done. changes-new.md contains the visible-change line with those expected paths. No player text or game-feel value changed.

Remaining: lane validation and commit of the sixteen retargets, preflight/ship of cw-cx-groundmode (which runs the six pending original assertions), and the requested picture/critic result. If one of the six still fails, use its unchanged assertion and the feedback to repair the cause. Do not declare a browser pass from the local canvas recorder. This run adds no owner question or approval request.


--- codex run 2026-10-22 01:54 ---
2026-10-22, run 4, v33.94.

The sixteen fixture repairs committed as 7b69c9e9. All 26 checks in that trial passed. The groundmode preflight then ran all six pending assertions twice on the drafted game: it reported only v26.50's no-flash control failing in the first pass (28,647), followed by PASS. This means the floor metadata, original scorch/brass/frag checks, original belt check and original ruined-floor check held in both drafted runs. The game key has not shipped yet.

Found two independent sources of contamination in 26.50's muzzle-only comparison:
- __resetCfg initially pins xfPix off, but the check calls __opts.apply() after replacing P.gameOpts with {}. applyGameOpts at game 70491 iterates every GAMEOPTS row and writes each default cfg, so the pixel row restores xfPix=1. The row was introduced in 2b74028b v33.51. The comparison therefore starts cold pixel sprite caches rather than the retained vector renderer used when the check was authored.
- Part TWO leaves a reduced burst of live sparks in g.sparks. Part FOUR clears flashes and muzzle state but never clears these sparks. The no-muzzle arm can therefore measure other emitters. Rendering also consumes the cosmetic FXS stream.

Prepared ONE new fixture retarget, for 26.50 only, in fixture-retarget.json. The sixteen already-committed edits were removed from the active packet; do not regenerate the old build-retarget.cjs against the refreshed fixture. build-flash-retarget.cjs builds the new packet from the current 26.50 block.

The new setup affects only Part FOUR: pin xfPix=0, clear sparks and flashes left by Part TWO, and snapshot the existing floor canvas into a temporary background with the SAME dimensions and _pe scale. The snapshot has no incremental paint queue, so the old v33.94 ground bug cannot change the background between captures; the real body/muzzle, lighting, frame rendering and pixel sampling still run. Each pair of __frame(0) calls starts from the same FXS value. The check restores the original ground, pixel dial and cosmetic RNG state in finally. It also rejects an empty finished world capture.

The existing s1>s2+4000 muzzle-reduction threshold and abs(s3-c)<=3000 no-flash control are unchanged, as are the earlier row/save/size/lifetime/spark-count/lightning assertions. No SKIP was added and no failure was retried into a pass. This retarget is staged to pass BEFORE the game fix, as the lane requires. It covers fixture interference, separately from the confirmed game bug in the floor mode flag.

The active retarget packet names cw-cx-groundmode as dependent and runs 26.50. The mk key retains the one game edit renaming the rubble coordinate. Its regression still invokes all six pending checks, including the updated flashing probe, so preflight must pass twice rather than relying on the earlier intermittent pass. Metadata was corrected to distinguish the five unchanged checks from the flashing probe's isolated comparison.

Local validation: the new retarget has one unique anchor; official plan STATUS ok and RUN 26.50; unchanged numerical controls and unchanged SKIP count checked; injected JavaScript parses. The mk script still prints written. Original/patched bakeGround negative-control verification still reproduces the bug and proves the renamed variable fixes legacy mode while preserving pixel drawing coordinates and the 3,280-call random count. The fixture with the patched game and new flashing retarget builds and compiles (13,584,603 inline-script characters). These are local checks, not browser passes.

Next lane actions: apply the new 26.50 retarget on v33.94, then retry cw-cx-groundmode preflight and ship. Keep shots.txt=21 for the before/after raid picture and critic. The game key, six-check preflight and picture review remain pending; no owner question or permission is needed. If 26.50 still fails, report the exact assertion; do not raise its thresholds or remove it from the six-check gate.

