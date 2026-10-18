# 12-ui-party-screens notes

Run 4 (lane a). Run 3 shipped 52,55 (over cards) - see below.

## Shipped earlier (screens 52, 55 run over card)
- v29.73 over3: one centred column + button; v29.74 over4: video absolute; v29.76 over5: grid column, solid accent button, light score.
- v29.79 over6: button 56px high, flush right, tokens (ui-shared forbids raw px literals in CSS bodies: use --btn-h, --fs-body, --menu-w, --sp-N).
- Old checks 29.73/29.74/29.76 retargeted to "flush right or centred" via fixq.
- Critic on 55 after v29.76: 2. c5/62 = 3.

## Run 4 critic scores (shots in notes/shots/12-d1, before any change)
- 46 how to play: 3. P1: prompt detached 150px, amber bolder than title; table bare (no keycaps); 'Hold X in a teal ring' text wrong for keyboard + explaining; row pitch 45 < 48; card padding 32 vs 24.
- 49 pause box: 3. P: HUD ghost shows through dim, no close X, footer Esc hint 14px, chamfer corner glyph.
- 48, 53, 54 are in-raid HUD screens: the critic grades the whole HUD (feed, score clipped at y0, $ in bag, extract x3). Mostly hud.md work, not reachable by a card fix. Likely stay <4; note and move on.
- Screens CSS: arcade page/over card in game CSS ~lines 1517-1591 (body #attract .arcpage/.arcover), pause 1598-1618.
- p2line at line 828; 46 how-to-play table built in script (arcpage).

## Lessons
- Edit mkfixture with 7-space indent in the 6100-6200 range; lock.sh first, then edit, then HELD=1 bash fixq.sh, then unlock.sh.
- Preflight takes ~2 min. Gate reruns old checks: any old check asserting centred/width will regress.
- Don't re-read the game CSS 1500-1630 more than once: it costs a lot. Notes first.
