# 86g-pix-pillager-states (lane b, 10-21)

Plan, small ships (86c is done; the plain rig is W36 H54 anchor 19,55 gun pivot 20):
1. cw-pixhurt: hit wash (white 0.066 s then red fade, silhouette tints cached per layer, pxTint), 1 px recoil, low health red ink-ring layer (pxRingRed) at the vector pulse alpha, shoulders 1 px lower, stains baked in the upper (low in the cache key), blood drops, walk 30 percent slower.
2. cw-pixdown: downed kneel + pulsing ring + gun on the floor (a14 B), player death topple in 8 baked frames (a15 B), pillager bot fall (a23 B raiderFallDraw).
3. cw-pixarmor: armour tiers, role marks re-anchored (one figure constant), exclamation + body tell, elite ring, golden bot as baked palette, seat trim, peddler / survivor.
Pictures at the end (camera cannot set xfPix, see 86c notes).

## Status
- SHIPPED v33.78 cw-pixhurt (37392f72). Fixture retarget 87989af6: the old pixbody check no longer expects a hit to stay vector. Watch: hits and low health read in a busy fight; the white flash covers each layer's own shape only.
