# 86g-pix-pillager-states (lane b, 10-21)

Plan, small ships (86c is done; the plain rig is W36 H54 anchor 19,55 gun pivot 20):
1. cw-pixhurt: hit wash (white 0.066 s then red fade, silhouette tints cached per layer, pxTint), 1 px recoil, low health red ink-ring layer (pxRingRed) at the vector pulse alpha, shoulders 1 px lower, stains baked in the upper (low in the cache key), blood drops, walk 30 percent slower.
2. cw-pixdown: downed kneel + pulsing ring + gun on the floor (a14 B), player death topple in 8 baked frames (a15 B), pillager bot fall (a23 B raiderFallDraw).
3. cw-pixarmor: armour tiers, role marks re-anchored (one figure constant), exclamation + body tell, elite ring, golden bot as baked palette, seat trim, peddler / survivor.
Pictures at the end (camera cannot set xfPix, see 86c notes).

## Status (10-21 later)
- SHIPPED v33.80 cw-pixdown (4bc996dd): kneel (crouch legs, 1 px bow, pulsing pixel ring, flat gun on the floor), player death topple in 8 baked frames + light dust, bot fall (pxFallTry, red body, fades by 0.7 s). The fall drops the role gear (pixel fall has none).
- SHIPPED v33.81 cw-pixgear (17e8449d): armour tiers 1-3 as plates (+ helmet shell at 3), golden bot = baked PXB_GOLD palette (bot:2) with a 5 px shine band, goldBodyBegin skips raiders with pixel on (no scratch canvas, no ctx.filter), elite ring = baked pixel ring (pxEliteRing), chase tell (eye halo, brows), seat trim check. Fixture retarget c5589a45 (armour).
- SHIPPED v33.84 cw-pixrole (2cbccb8c): figKS + PIX_FIGK 1.35 for the role gear (shoulder line 31.9 up vs pixel 32), aim dots take no build height with pixel on, peddler and survivor pixel suits. Fixture retarget 1ed636d7 (peddler).
- Hooks: opWash = pxTint layers (pxLayer), opKneel = pxKneelGround + crouch rig, opDeath = pxDeath/pxToppleSpr. One constant: PIX_FIGK (FIG_SCALE copies in drawRoleMark now come from figKS; drawAimMark and raiderFallDraw take the pixel path or [1,1]).
- Left: pictures (blocked, see alarms.md), critic, and the 2-window picture; the check item "a staged fight draws no vector pillager body" is only partly covered (each state has its own check). Watch next play: hits and low health read in a busy fight, red bots stand out at night, golden bot shine band, kneel/death look, role gear on the shoulders, aim dots start on the pixel gun.

## Status (earlier)
- SHIPPED v33.78 cw-pixhurt (37392f72). Fixture retarget 87989af6: the old pixbody check no longer expects a hit to stay vector. Watch: hits and low health read in a busy fight; the white flash covers each layer's own shape only.

--- codex run 2026-10-21 12:11 ---
2026-10-21, lane o continuation of 86g-pix-pillager-states, starting v33.89.

86c is in done/. Read the existing 86g notes first: hurt, downed/death/fall, armour/gold/elite/tell, role gear and civilian suits already shipped at v33.78, .80, .81 and .84. Do not repeat them. Their behavior checks are 33.78, 33.80, 33.81 and 33.84.

Remaining code gap found: pixDrawOp rejected iv > 0, so the invulnerable player and its see-through wall copy reverted to vector art. Prepared cw-cx-pixfight: accept that state, use the existing cached silhouette tint for its teal cue, draw hit white/red above it, and inherit caller alpha. No simulation, random draws, profile code, or timing changes. Warm-cache fallbacks remain available under the shared pixel safety rules.

New check stages an invulnerable body at wall-ghost alpha 0.55, verifies cached teal is drawn at 0.55 * 0.35 and caller alpha survives, then renders a real seeded gunfight with six regular bots, an elite and golden bot after warming caches. It counts vector body calls and requires nine pillagers per frame. It restores xfPix in finally. This check must fail before on the invulnerability vector fallback. Existing state checks retain the hit, outline pulse, gold filter, armour width, anchor, baked alpha and death-frame assertions.

Handed over six camera recipes: hurt/low/downed/ghost at native 1x and nearest 4x; eight death frames at both scales plus player light and bot fade; real day/night fight world captures; real linked player 1 and player 2 world captures. The pair recipes assert both SEATCOL[0] and SEATCOL[1] bands are actually requested in each window, without changing their colours. They reuse the successful 86c real-window staging, with fixture-only contact sheets and raw world PNGs in report notes. These are development proofs; the real game HUD is unchanged. The earlier camera blocker is addressed by lane o recipe support.

Validation here: mk script prints written, all three anchors match once, candidate inline game scripts and new fixture check parse, camera recipes parse as async JS, all handoff files are ASCII, and an isolated pxLayer probe confirms the new teal mask inherits ghost alpha and sits below the hit flash. Browser preflight, ship and critic belong to the lane and remain pending.

Watch next play: hits and low health in a busy fight; red bots at night; the invulnerable teal cue; the same translucent pixel body behind a wall.


--- codex run 2026-10-21 12:13 ---
2026-10-21, lane o preflight repair for cw-cx-pixfight, current master v33.89.

Preflight reached the new gunfight staging but failed twice: seed 4242 did not supply eight pillager bots under fixture defaults. The invulnerability/ghost assertions had already passed to reach this point. This was an incorrect population assumption in my check.

Fixed the same key: construct the eight test actors with the existing mkRaider factory and simBuild=true, as other fixture checks do. The fixture-only cast has six regular hostile bots, an elite and a golden bot. This protects identity history and does not depend on how many bots the test defaults spawn. The actual rendering code and three game edits are unchanged.

Fixed the same assumption in camera-helper.js and regenerated camera-recipes.json. The day/night scenes create their cast once, then reuse it while warming caches. No factory call was added to any game drawing path.

Validation: mk prints written; all three anchors match once; the patched game inline script, fixture check and six async camera recipes parse; cached teal alpha and hit/ring ordering still pass the local probe; handoff files remain ASCII. Ready for the lane to retry preflight and ship, then capture the six scenes and run the critic.

--- codex run 2026-10-21 12:15 ---
2026-10-21, lane o second preflight repair for cw-cx-pixfight, current master v33.89.

The new check reached the fight draw but counted 15 calls rather than 27. Source inspection found render2D recalculates every entity seen flag using canSee each frame; the seed map and player facing hid part of the staged cast despite setting seen=true.

Corrected fixture staging only: save canSee, expose the cast during the art render, and restore canSee in finally. This follows the existing art checks that temporarily expose their staged cast. The real renderer and all real body painters still run. Strengthened the draw assertion from a combined call threshold to a separate count for the player and each of the eight bots, requiring each in all three measured frames. Any vector pillager body or pixel fault still fails. The game edits are unchanged.

Camera correction: after moving the player to the chosen clear spot, snap the fixture camera anchor too, since a zero-dt frame cannot ease it there. Each camera art frame temporarily exposes the cast and restores visibility immediately afterward. Before capturing, both day and night scenes now require all eight bots visible, every cast member drawn, and zero vector bodies. Captions say staged visible cast; this does not claim a line-of-sight test. Product visibility, simulation and AI are unchanged.

Local validation passed: mk written; three unique anchors; patched game and fixture-check syntax; helper and six async camera recipes; cached mask alpha/order; ASCII files. Preflight retry, shipping and picture review remain with the lane.

--- codex run 2026-10-21 12:30 ---
2026-10-21, lane o visual follow-up 1, v33.90.

SHIPPED cw-cx-pixfight at v33.90. Its check passed. Round 1 camera evidence completed all six scenes; day/night cast reports each actor once, eight visible bots and zero vector bodies. Both real linked windows staged, with both SEATCOL bands verified and no faults. Evidence directory: tools/handoff/console/notes/shots/86g-pix-pillager-states-recipes-1/.

First critic scores: death 2, day fight 2, night fight 2, hurt 3, player 1 pair 3, player 2 pair 2. These are not passed release scores. The death P0 says to keep the proof out of the player build: that is already satisfied. The proof UI is injected only by camera-recipes.json; none of its markup, text, panels or controls is part of a ship key. Confirmed by reviewing the actual three game edits. Kept required native 1x evidence despite the suggestion to drop it.

Reviewed all six attached images. Improved the camera-only presentation for round 2: short titles; no explanatory footer; 48px close glyph with visible lime focus; shared left edges and 16px gaps; style-guide raised tile fill and clear 20px captions. Hurt uses five 4x states with native samples directly below; low bright and low dim native samples remain together. Armour grows from 2x to 3x and is drawn unarmed so its plates are not hidden by the gun. Widened source cells for the downed floor gun and death/fade endpoints to avoid camera clipping. Death uses two aligned four-frame rows with native 1x insets and one aligned fade row.

Day/night pictures now show a nearest 2x crop of the real world canvas centered on the nine actors. Both linked-player pictures show a nearest 4x crop around the two real bodies and their rings. Each keeps a full-view inset and lossless full/crop PNGs in the report note. No pixel colours, sizes, lighting or shaders are altered in these crops. This addresses the critic finding that the proof made the characters too small to judge. The actual game remains v33.90 with no new ship key.

Validation: helper parses, all six regenerated async recipes parse, ASCII output. New recipe file requests the lane second camera/critic round. Watch: red bots and low health in real night play; shared floor/wall grading concerns are handed off separately rather than changing scenery inside a character-state proof.

--- codex run 2026-10-22 10:27 ---
2026-10-22, lane o visual follow-up 2, starting v34.17.

86c remains done. cw-cx-pixfight already shipped v33.90 with its check. No new game change or ship key this run. Existing keys.txt is retained so the lane skips that shipped key.

Read the round-2 camera report and viewed the death, hurt, night-fight and player-2 pictures. All six scenes staged with zero lint issues. Day/night casts each reported nine bodies, eight visible bots and zero vector bodies. Both real linked windows staged, with no pixel faults. Round-2 accept entries rate death 3, day 3, night 2 and hurt 3; there are no pair entries in that file, so both linked-window critics are still needed. These are evidence-sheet scores, not a passed raid score.

Prepared round 3 camera recipes, the second visual follow-up. The camera shell now uses the style-guide panel fill and 24px padding; close gets a lime outline only while focused. The low-health sample or first death frame takes actual focus. Both state rows use identical five-column grids and 16px muted captions. Native death samples sit BESIDE the 4x frames, with no overlap. Recentered each topple sample inside its camera cell so the final frame is not clipped; this changes only proof positioning. Fade samples are nearest 2x with 16px captions and an explicit gone endpoint. Kept all eight 4x topple frames and native 1x samples, as the task requires.

The real-world review crops use a padded frame, equal side margins, and a full-view inset docked 16px inside the image. State labels sit below the crop. Both windows retain the same verified SEATCOL bands and actual ring numbers. Full raw world and crop PNGs remain in report notes. No game palette, body dimensions, lighting, simulation, AI, profile, visibility or timing was changed. The global night wash finding is P2 and was already handed to the shared night-read pass; this task does not recolour the world to improve a proof score.

Validation: camera-helper.js parses; all six generated async recipes parse; all handoff text is ASCII; tracked game and fixture files are clean. The lane should capture and run the critic on all six round-3 pictures, including BOTH linked windows. Requested evidence path: tools/handoff/console/notes/shots/86g-pix-pillager-states-recipes-3/. Remaining: inspect those pictures and resolve any P0/P1 or record the allowed stuck outcome. Do not mark complete before that evidence returns.

Watch next play: white/red hits and low health in a busy fight; red bots at night; the translucent pixel ghost behind a wall; both seat bands, rings and numbers.

--- codex run 2026-10-22 10:34 ---
2026-10-22, lane o final camera preparation, v34.17.

Reviewed all six attached round-3 pictures and the critic replies. Scores: death 3, day 3, night 2, hurt 3, linked window 1 3, linked window 2 2. All staged with zero lint findings. The night cast reported each of nine actors, eight visible bots and no vector bodies. Both real windows remained linked and fault-free. The window-2 wall hid the lower halves of both seat rings in its actual world capture, so that picture is inadequate ring evidence even though its trim assertions passed.

Prepared the fourth and final camera round. No new product change or ship key. Removed passive-image lime focus, nested world borders, all full-view insets, and the detached caption grid. Each real fight bot now has one 20px cream caption positioned from its own w2s foot anchor, 16px below the feet. The complete original world PNG remains in the report; no scenery pixels are erased, graded or replaced. Keep an actual raid scene as the task requires. The critic suggestion to replace the real scene with isolated sprites is not used as a substitute for the requested raid evidence.

For both real linked-window recipes, choose the dry map position with the greatest clearance around a rectangle covering both bodies, heads, rings and possible foreground walls. Move both real players with the existing fixture stand helper, wait until each real remote position reaches the other window, snap each fixture camera, and verify both SEATCOL bands again. Capture a tight nearest 4x crop with no inset or detached caption; the real ring numbers identify the seats. This stages a clear photograph and does not change product collision, visibility or networking. Report includes the chosen map point and clearance.

State and frame captions, including native tags, are now 20px cream. Section headings remain the actual 16px token, now cream with tracking; titles remain the actual 32px/700 token. The critic had estimated those font sizes smaller than the CSS values, so the captions were enlarged for visual readability while the title token stays correct. Only the functional 48px close button takes lime focus, with a 16px esc close hint; esc now dismisses the camera overlay too. Death sample positions move up three art pixels for shadow clearance. The eight 4x frames and native 1x evidence remain, and fades remain 2x.

Validation: helper and all six async recipes parse, all handoff files are ASCII, tracked game and fixture files are clean. cw-cx-pixfight remains already shipped at v33.90 with passing check. Lane should capture recipes-4 and run all six critics. This is the last allowed camera round. After reviewing it, retain the best two versions and document any stuck critic findings under the two-follow-up rule rather than doing more presentation passes.

Best existing alternatives for comparison: recipes-2 and recipes-3 under tools/handoff/console/notes/shots/86g-pix-pillager-states-. Same filenames in both: 86g-death-strip-1080.jpg, 86g-hurt-strip-1080.jpg, 86g-fight-day-1080.jpg, 86g-fight-night-1080.jpg, 86g-pair-p1-1080.jpg, 86g-pair-p2-1080.jpg. Night-world grade remains the shared handoff already in alarms.md; do not treat the current night score as a passed raid finish line.

Watch next play: hits and low health in a busy fight, red bots at night, the pixel ghost through a wall, and both trim bands with full ring numbers.

--- codex run 2026-10-22 10:38 ---
2026-10-22, final review and close under the stated visual stopping rule, v34.17.

All requested game work has shipped. Earlier keys: cw-pixhurt v33.78 (37392f72), cw-pixdown v33.80 (4bc996dd), cw-pixgear v33.81 (17e8449d), cw-pixrole v33.84 (2cbccb8c). Codex continuation: cw-cx-pixfight v33.90, shipped with its new check passing. Current master still contains the invulnerability silhouette change and its registered fixture check. keys.txt retains cw-cx-pixfight; it is already shipped and must be skipped. No new key or game edit this run.

Opened all six final round-4 JPGs with the image viewer. Requested evidence is present: white and red hit, bright/dim low health, kneel with ring and floor gun, translucent ghost, eight death topple frames at native 1x and nearest 4x, player light and bot fade, armour 1-3, peddler/survivor, real day/night cast with six ordinary bots plus elite and gold, and both real linked-window views. In the final linked pictures both complete rings and numbers are visible; the prior window-2 wall obstruction is gone.

Parsed the final report.json rather than relying on its truncated summary. All six scenes staged at 1920x1080; every lint count is zero. State/death faults: 0. Day and night each have cast [1,1,1,1,1,1,1,1,1], visible bots 8, vector bodies 0, pixel faults 0, nearest crop 2x. In BOTH pair recipes, both real windows report one live network link, xfPix 1, faults 0. In each window the actual requested trim bands include exactly the expected amber #ffb02e and cyan #38d6ff. Pair crops are nearest 4x. Raw world PNGs and these assertions remain in the report notes. Both windows were actually observed, not simulated by drawing a second isolated body.

Final critic scores (do not confuse with a release approval): death 3, day 2, night 3, hurt 3, linked window 1 2, linked window 2 2. Best prior scores: death 3, day 3, night 2, hurt 3, linked window 1 3, linked window 2 2. Death/hurt and window 2 did not gain score through multiple follow-ups; day/window 1 regressed in the final camera presentation; night improved to 3 but remains below the raid bar of 4. Camera budget is exhausted at 4/4. Stop the presentation pass under the instruction to record what is stuck after two follow-ups without a score rise. This is an allowed stuck outcome, NOT an assertion that every visual finish line passed.

What is stuck: the critic repeatedly treats the camera-only evidence card as a shipped player menu, requesting footer actions, ready-state columns, removal of required native samples, and changes to original world backgrounds. Remaining P0 findings are empty space in that evidence card. Confirmed state-art-proof is absent from dark_raiders.html: none of the proof card, captions, inset history, controls or titles ships to players. Font-size findings repeatedly estimate the implemented 32px title, 16px heading/hint and 20px captions smaller than their actual values, despite zero camera small-text or contrast lint findings. Actual night/world contrast concerns remain valid play-watch items and are handed off separately; they are not excused by the harness mismatch. Do not add a new player-facing screen or distort the world capture to make a proof score higher.

Retain these two complete versions and all their pictures, without deleting either:
- tools/handoff/console/notes/shots/86g-pix-pillager-states-recipes-3/ : scores death 3, day 3, night 2, hurt 3, linked window 1 3, linked window 2 2.
- tools/handoff/console/notes/shots/86g-pix-pillager-states-recipes-4/ : scores death 3, day 2, night 3, hurt 3, linked window 1 2, linked window 2 2. This contains the final unobstructed two-window seat evidence and final complete report assertions.
Each directory contains 86g-death-strip-1080.jpg, 86g-hurt-strip-1080.jpg, 86g-fight-day-1080.jpg, 86g-fight-night-1080.jpg, 86g-pair-p1-1080.jpg, 86g-pair-p2-1080.jpg and report.json. Use round 3 for the higher-rated day/window-1 camera layout; use round 4 for the clearer ring evidence and higher-rated night picture. Round 2 remains available as another score-3 state/death/day alternative. No self-assigned visual scores were used.

Task closed: shipped state behavior and regression coverage, all required picture subjects, and both actual network windows verified. Visual review stops with the recorded limitation under the task rules. No remaining ship key, retarget or camera request. Keep the shared night-read handoff visible for release review.

Watch next play: white/red hits and low-health outline during a busy fight, red bots against night floors, role marks around the pixel head, gold/elite separation, the translucent ghost through a wall, and amber/cyan trim plus ring numbers in both windows.
