# 12-ui-party-screens notes

Run 3 (lane a). Before pics: notes/shots/12-c1 (all 13 screens). Critic via node tools/console-sdk/critic.mjs.

## Shipped this run (screens 52, 55 run over card)
- v29.73 over3: one centred column + button; v29.74 over4: video absolute; v29.76 over5: grid column, solid accent button, light score.
- v29.79 over6: button 56px high, flush right, tokens (ui-shared forbids raw px literals in CSS bodies: use --btn-h, --fs-body, --menu-w, --sp-N).
- Old checks 29.73/29.74/29.76 retargeted to "flush right or centred" via fixq.
- Critic on 55 after v29.76: score 2 (better than before). Remaining critic asks: hero 56px, 4 stat cells (value over label: Kills, Extractions, Deaths), card 720px (regression 29.49 demands 840 x scale, do not change), real label, backdrop world dim. Shots after v29.79 in 12-c5; critic on c5/55 = 2 (better). Critic on 62 (operator menu, c5) = 3: asks close X + header row (skip: one control per job), hide attract prompt behind modal, uneven button gaps (56/54/56 heights), subtitle 14px.
- Logged in changes.md and index.html. Not done: 46,47,48,49,53,54,56,58,63,64 and the 55 stat cells/hero 56px. Run ended there to save credits.

## Lessons
- Edit mkfixture with 7-space indent in the 6100-6200 range; lock.sh first, then edit, then HELD=1 bash fixq.sh, then unlock.sh.
- Preflight takes ~2 min. Gate reruns old checks: any old check asserting centred/width will regress.
- Arcade code: run over card built in arcadeOverSync (~line 60822 of game), CSS at lines 1521-1600 (body #attract ...). arcadeOverRow builds stat line.

## Todo
- Screens 46,47,48,49,53,54,56,58,62,63,64 untouched. Take 12-c5 shots, critic them, fix worst first.
