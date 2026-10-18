# 13-ui-end-cards notes
Before shots: notes/shots/13-before (35 kia, 38 extracted, 40 whats new, 59 abandon confirm, 60 abandoned, 76/77 haul reveal).
Critic BEFORE: all 2. Common findings (35,38,60,77 share #outcome card, markup ~line 1560, fill code ~31229-31320):
- P0 HUD shows through scrim: hide HUD when #outcome.on, scrim rgba(6,7,8,.80)
- P0 no hero line; stats are dot sentences; amber text lines (XP, Achievement:); `$` banned
- P1 card shell: gradient, glow, 8-12px radius -> flat panel, 1px line-hi border, 4px radius, ~720px
- P1 buttons 44px -> 56px primary min 200, 20px 700 no tracking; feedback chip + Copy report are competing
- P1 tiles: full coloured border -> 3px rarity bar bottom
59 (pause+abandon confirm): key legend dominates, no primary; 'NO, keep playing' caps; Keep playing = amber primary; drop feedback sentence
40 (whats new): 1560px slab, no close/primary, centred title, filler repeat rows; wants 960 max card, Got it primary, header row
Plan (small ships, each its own cw- key): 
 1 cw-endcard-shell: #outcome scrim + HUD hide + card flat/720/radius + buttons 56px + title no glow
 2 cw-abandon-confirm: pause confirm buttons (keep playing primary, sentence case)
 3 cw-whatsnew-card: width cap, Got it button
## Log
