# b-20-quality-pass: verdicts, v28.79 through v29.25 (lane b, 2026-10-20)

Method: git show of each ship's game diff, plus before pictures of screens 03, 05, 21, 23, 33 and 41 (notes/shots/b20-before).
Leftover probes in tools/mkfixture.ps1: the temporary 11.90 and 19.00 diagnostics were already removed (commits 3ec6c253, d36ff6e9). grep for DBG/temporary/diag found only comments about old probes. Clean.

## Fixed by this task
- v28.91 / v28.94 pre-raid pack row (cw-preraid, cw-cashpick): the PACK ALL and NONE buttons stood at the far end of the row, right after the CASH chip and its MAX, so they read as cash buttons. Fixed in v29.26 (cw-packbulk): they follow the PACK label, named Pack all and Clear, the check fails on the old order.
- v29.10 ctrl drag asks how many (cw-stashqty): only a Ctrl drag opened the prompt, and a pad has no Ctrl, so a controller player could never reach it (one control per job, and his standing pad rule). Fixed in v29.27 (cw-padqty): pad A on the other side of a stack of 2+ opens the same qtyDrag prompt. The prompt itself is a .modal, so the pad already reaches its - + Half All Move Cancel buttons.

## Verdicts (ok = no jank found)
- v28.79 heavy helmet loses neon bar: ok.
- v28.80 fewer guns in loot: ok (no UI).
- v28.81 sp figure in feed: ok.
- v28.82 held gun shadow: ok (drawn with the operator, under the gun).
- v28.83 guns cost twice to craft: ok (value only).
- v28.84 dead deer is a deer: ok.
- v28.85 operator soft shadow: ok.
- v28.86 stash and bag line top right: ok. Seen at 1080p ("Stash 0 bag 1,770" under credits and xp), small, right aligned, same font. The minimap sits just under it, no overlap.
- v28.87 / .88 / .92 / .95 / .97 / .99 / v29.07 / v29.08 player 2 sync (phase, blasts, hit stop, near misses, ricochets, spin-up, crowbar, muzzle flash): ok, net and fx only, nothing drawn that the host does not see.
- v28.89 hard enemies drop better loot: ok.
- v28.90, v28.74, v29.06, v29.22 what is new cards: ok, stamped by the gate.
- v28.91 pre-raid pack: see fixed above.
- v28.93 / v29.00 mimic: ok (pops away from the player, drawn in the entity pass).
- v28.94 cash pick: see fixed above. The chip and MAX stay at the end of the row, which is where the cash belongs.
- v28.96 heal bar over the walls: ok, it is a world text pass draw, like the cache names.
- v28.98 red barrels leave fire: ok.
- v29.01 gate breach needs hold, garrison stays: ok, E hold only, fixtures retargeted.
- v29.02 rarer gun copy fights like plain gun: ok.
- v29.03 all on-screen text into the feed: ok on the 33 picture: four rows, one plate colour per kind, glyphs aligned, nothing overlapped with the legend. One note: a lore name is still upper-cased in loreTick (L.name toUpperCase) but it passes through the all-caps filter on draw and the feed, so no change.
- v29.04 next gun keycap says rb on pad: ok.
- v29.05 aim lane at the player the machine will shoot: ok.
- v29.09 no stronghold over the forge: ok.
- v29.11 / v29.14 no all caps: ok, checks made case blind. Menus keep their caps by his ruling.
- v29.12, .13, .16, .17, .19, .20, .21, .24, .25 dead machines leave wreckage, not a box: ok by diff (same drop path, art only). Not shot individually.
- v29.15 / v29.18 gun keys renumbered, rocket on key 0: ok. The hotbar in the 33 picture shows slots 1 to 9 and 0 in the same cell style. Pad is untouched (next gun cycles).
- v29.23 support mg loosens on a long burst: ok (feel, his order).
- v29.26, v29.27: this task.

## Open (for him, in questions.md)
- The Current pillagers board and the run score rows draw $ (for example $2,950) while score is SP in his ruling of 10-18. They are credit or haul values in the code (val/haul), not the score, so I did not change them.
