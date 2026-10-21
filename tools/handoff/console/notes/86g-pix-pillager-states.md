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
