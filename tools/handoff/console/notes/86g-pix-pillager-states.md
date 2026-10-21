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
