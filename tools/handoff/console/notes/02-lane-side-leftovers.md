# 02-lane-side-leftovers (lane a, started 11-01)

Camera note: the 2 player recipes (job 2 style, popups) link fine on lane a. Job 1's own recipe does not link on the current build (details in block 1).

## Job 9: o-131-gun-impact-sound-caps (no pictures)
Report copied to tools/handoff/console/notes/131-sound-caps.md with the "copied 11-01" line on top. Unchanged otherwise.
Follow-ups: the Codex report itself lists two things nobody has done: capture window.__combatVoiceMeasure from the fixture (real browser numbers) and listen to the sound budget in two connected windows (LMG and shotgun near metal hits and explosions: listen for clicks, lost nearby shots, missing shotgun pumps). Not a camera job.

## Job 2: o-140-red-enemy-tracers (v35.67)
Pictures: notes/shots/02-o-140-red-enemy-tracers/red-tracers-{day,night}-{p1,p2}-{1080,4k}.jpg (all 8 staged; recipe report ok:true every time, enemy rounds #ff3b2f, player rounds #ffcf7a warm / shock for the forged gun).
Seen: in both windows, day and rainy night, the sentry and the hostile pillager fire short red dashes that read clearly against the red danger cone and the rain; the player rounds (warm white / blue shock) stay a different colour. At 4K the dashes are thin but still visible. Nothing clipped.
Critic: night p1 1080 = 3 ("yes" better than Codex round 3); day p2 1080+4K = 3 ("same"). Findings are all general raid HUD (hp bar too heavy, hotbar slots 2..0 are bare numerals, panels differ, bots list long, "25 / 24" ammo reads like a bug, 'chill row cache' label chip). None is about the tracers.
Follow-ups: (a) 4K raid: hotbar is small next to the ammo card and slot numerals 9/0 touch a building (day-p2-4k.jpg), looks like the hotbar does not scale with height at 4K; (b) ammo card shows "25 / 24" in the camera scene (probably staging, not a game bug; check only if it can happen in play).

## Job 1: o-00v-239-ping-and-map-mark-are-one (v36.53)
Pictures (solo, staged): notes/shots/02-o-00v-239-ping-and-map-mark-are-one/mark-solo-raid-{1080,4k}.jpg, mark-solo-map-{1080,4k}.jpg
Seen: solo, the middle mouse mark in the raid is an amber diamond with a "mark . 28m" tag at the reticle; the same amber diamond with a "mark" chip shows on the sector map and the top-right minimap. Same shape and colour in all three. Good at 4K, nothing clipped.
Linked pictures: the first try (the recipe as Codex left it) never linked ("player 2 not linked", the p2 popup lost its pair code). Try 2 used a corrected copy, notes/02-recipes/o-00v-239-ping-and-map-mark-are-one.json (linking steps copied from the working o-140 recipe: fixed pair that matches the p2 query, host.open override, a "ready" post, no net reset). It linked 7 of 8: notes/shots/02-o-00v-239-linked/mark-p{1,2}-partner-{raid,map}-4k.jpg, the same four at 1080 except mark-p2-partner-map-1080 (reused pair name right after the p2 raid shot, did not link; that jpg is the title screen, ignore it; the 4K one covers it).
Seen (both windows): P1 window shows P2 pad mark as a CYAN diamond with "pillager . 28m" in the raid and a cyan diamond on the minimap (and "mark" cyan diamond on the sector map); P2 window shows P1 mouse mark as an AMBER diamond, same spot, in the raid, minimap and map. One mark per window, same shape in raid, minimap and map. Colours are right (P1 amber, P2 cyan).
Critic: linked raid p1+p2 1080 = 3 ("yes" better than Codex round 2); p1 map 1080 + p2 map 4K = 3. Solo critic: raid 3 ("same"), map 3 ("same").
Follow-ups: (a) sector map in a linked raid: the partner tag reads "pillag" cut off by its "2" badge (mark-p1-partner-map-1080.jpg, near x585 y430); (b) the mark label "pillager . 28m" is about 14px at 1080 and the black diamond box does not match the label pill (critic P2); (c) camera only: the recipe in notes/02-recipes/ is the one to use for linked mark shots from now on.
Old solo critic line:
Critic: raid 3 (1080 vs old Codex 1080, "same"); map 3 ("same"). Findings are general raid HUD and sector map polish (hp bar in the corner, ten weapon slots, four world tag recipes, map label crowding, contract rows). None is about the mark, except one P1 on the map: extract c label sits close to the mark chip and the pin has no amber ring (P2-style polish). None reverses a ruling that I can tell.
