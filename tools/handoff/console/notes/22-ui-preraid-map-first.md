# 22-ui-preraid-map-first (lane a)

Status: shipped in 6 passes (v32.46, .48, .51, .52, .53, .57). Critic stuck at 3 (needs 4 for this screen? no: 3 is enough for non-raid screens, 3.51 a). Stopped after 6 tries (his 2.83 b).

## What is built (Design A, map first, his pick of 10-19)
- Map panel left two thirds, ice blue from the real cold storage data. Conditions list beside it (day/night, weather, xp badges, host sets read only for the guest).
- Right column: kit as 2x2 tiles, pack as grouped rows with one stepper each, pack all / clear, data core slot, going-up chips, big lime ascend plate. X and close top right.
- Pad: focus opens on ascend, LB/RB jump panels, d-pad inside a panel, A press, B close, X pack all, Y clear. Hint strip swaps keys and pad live.
- Long pack scrolls inside its own list; the plate never leaves the card.
- Checks: each ship carried its own check (map width, ice blue pixel, stats, controls, no cash, LB/RB order, one A press ascends, plate inside card with the biggest pack). All gates and fingerprint (85/374, 165/593) passed.

## Pictures (05-sector-page-1080.jpg and -4k.jpg in each)
- shots/22-before: old page (critic 2, "debug panel")
- shots/22-after: v32.46, 22-after2: v32.48 (critic 3), 22-after3: v32.51, 22-after4: v32.52, 22-after5: v32.53, 22-after6: v32.57

## Two best versions to leave
- v32.53 (22-after5): bigger map names, no pills, quieter selected state.
- v32.57 (22-after6): labels on dark pills, 32px window title, 44px steppers. The critic said "same" as v32.53 and called the warning row too small (P1).

## What the critic still says (score 3, v32.57)
- P1 warning row too small: I shrank it to 16px/500 with a bar; critic wants 16px/600 in a 32px row. Easy next step.
- P1 right column dense (8 rows, 4 cards, pack/clear, core, gun, warning). Next step: merge gun row and data core row into one extras group.
- P1 map labels still touch props. Next step: push labels clear of props (8px), exit rings 24px.
- P2 selected state has three signals; hint footer lacks ascend (I removed it on purpose, the plate already shows it; pad prompt lives in the plate).
- Skipped (would reverse his ruling): "tint the map to neutral grey". He asked for the map in a different colour to break up the monotony (10-19).

## Run of 10-20 (lane b)
Re-checked: shipped v32.46 to v32.57, six tries used (his 2.83 b), critic 3 = finish line for non-raid screens (3.51 a). No further ship. Optional next: 16px/600 warning row, merge gun and core rows, map labels 8px off props.

## Run of 10-20 (lane a)
Read the notes: all shipped (v32.46 to v32.57), six tries used (2.83 b), critic 3 meets the 3.51 a finish line for non-raid screens. No further work.

## Left to do
- 2-player pictures from both windows were not taken (the camera stages one window).
- Old checks likely red in the corpus, for coordinator to retarget (see alarms.md).
