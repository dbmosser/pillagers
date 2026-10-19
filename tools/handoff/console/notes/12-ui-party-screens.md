# 12-ui-party-screens (lane b/c/a) notes

Screens 46 48 49 52 53 54 55 56 58 62 63 64 (47 dropped). All sit at 2-3 of 5 from the critic.

## Shipped (all runs)
- v30.24 cw-partyempty, v30.23 cw-modalflat, v30.30 cw-pausehint, v30.78 cw-partyx2, v30.97 cw-opclean, v31.07 cw-sticks
- v31.42-v31.46 cw-partylook4/5
- Run 5 (lane a, 10-19): v31.68 cw-partylook6 (labels >= 16px), v31.73 cw-partylook7 (prompt 24px + footer rule; old check 31.46 retargeted to 24px). Pictures shots/12-r5-before, 12-r5-after, 12-r5-after2.

## Critic after run 5: 55 = 3 same, 64 = 2 same (46/56 not re-judged after ship 2). Two ships did not lift a screen: stop per rule.

## Stuck: the critic flips between runs
- Prompt: asks for bigger, then tx-1 20px; asks for a "got it" button, then a key chip. Live any-key prompt stays (his 10-11 order).
- Asks repeatedly (still open, each one a safe next ship): "score" 16px label above the 56px hero (55); stat columns 3 equal; hide the zero-score at full brightness (dim to tx-2); the new divider under stats is wider than the content (626-1293 vs 634-1286): inset it 8px each side (55); ring glyph full accent; subline 16px with -50% in warn amber (55).
- 64: "seeded night - code" kept (the code is how the party matches the night, not debug); asks left-aligned empty state, key chip, a 90% window card, scrim .80.
- Next run: one mk script for 55 (inset divider, score label, dim zero, warn on the penalty) and one for 64 (left-align empty state).
- Run 6 (lane c, 10-19): shipped v31.77 cw-partylook8 (55: score label, dim zero, warn penalty, inset rule; 64: left empty state). uishots.ps1 and critic runs were REFUSED/unavailable in this run's command list, so no after pictures and no critic score. Next run: shoot 55 and 64, run critic with r5-after2 as the old picture, then do 58/63/48/49/53/54.
- 58/63/48/49/53/54 not re-shot in runs 4 and 5.
