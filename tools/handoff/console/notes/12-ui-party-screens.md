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

## Run 5 (build v29.89 at start; shots notes/shots/12-e1; critic scores 10:41)
- Others shipped on party pages meanwhile: 29.84 one column+56px button, 29.87 slide ghost floats, 29.88 operator menu one red/solid backdrop, 29.89 abandon.
- Scores now: 46=3, 62=3, 58=2 (stack of small explaining sentences, amber 12px paragraph, mixed sizes), 63=2, 56=2, 64=2, 47=2, 49=3, 52=2, 55=2, 48/53/54=2 (HUD).
- Common P1 across critic: no close X, no key/pad hints, empty attract (no hook), type below floor.
- DON'T list scratchpad dir (huge). DON'T re-read old scores (accept.json 236-410 is the list).

## Run 6
- Shipped v29.91 cw-partyx: operator card close X + key strip; p2line one 16px label. Critic 62: 3 (better). Pictures 12-f1.
- Critic's remaining P1 on 62: delete Back row (checks mkfixture ~6228 and ~7327 pin 3 buttons: retarget under lock), hints 16px, backdrop is opaque by his order (do not dim world there).
- 58 is the shared title menu (lore, 3-step row, key legend, $ in save row): belongs to a title task, not a card fix.
- Still <4: 46,47,48,49,52,53,54,55,56,58,63,64. HUD screens 48/53/54 belong to hud.md work.
- mk script gotcha: anchor text mid-line: a // comment in a replacement swallows the rest of that line; use /* */.

## Lessons
- Edit mkfixture with 7-space indent in the 6100-6200 range; lock.sh first, then edit, then HELD=1 bash fixq.sh, then unlock.sh.
- Preflight takes ~2 min. Gate reruns old checks: any old check asserting centred/width will regress.
- Don't re-read the game CSS 1500-1630 more than once: it costs a lot. Notes first.

## Run 7 (lane d, Claude Code; start build v29.92)
- Critic at start (shots 12-g1): 46=3 55=3 49=3 56=2 (no row staged: board shows No scores yet; 55 shows Score 0 SP, extraction in the stager does not score).
- Shipped v29.93 cw-partykeys (key caps, ring glyph, 56px rows, ghost board rows, translucent backdrop), v29.94 cw-partystats (run over stat cells, no first run card while arcade is up).
- LEARNED: behind #attract is the Undercroft hub (labels, HUD). With the welcome pack open (fresh profile stage) it showed through at 46. Critic then: 46=2 (welcome pack ghost), 55=3, 56=2 (P0 hub legible, ghost rows read as clutter, button outside card, two titles).
- Plan v29.95 cw-partycard: button inside card bottom right (grid-area 1/1), wordmark absolute top-left logo, over card 720 wide, #attract backdrop-filter blur(--sp-2). Needs old checks 29.84/79/76/74/73/66/49 retargeted tolerant (accept old and new) under the lock.
- TODO after: close .modal.on in arcadeEnter (welcome pack open before arcade click at 46), pause box X (49), operator Back row (62/63), HUD controls card restyle (47/48). 58 title and HUD 48/53/54 stay PARTIAL.
