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
## Log
- SHIPPED v29.52 cw-endcard-shell, v29.53 cw-endcard-hero (haul total 56px hero, scrim .94).
- Run 2 (13-c1 shots taken on v29.80): critic 35=2, 77=2. Remaining: stats sentence -> 4 cell row, achievement sentences -> chips, buttons footer layout (ghost left, primary right), 16px floor, lost item list as tiles.
- Plan: cw-endcard-stats (ocStatRow fn before ocLedger, hidden .ocsr keeps old text for fixture checks like 22.02 'on the surface'; .ocstat/.ocach CSS). Then buttons, then 40 whats new, 59 confirm.
- Run 3: SHIPPED v29.81 cw-endcard-stats, v29.83 cw-endcard-lost. Critic (13-c3 shots): 35=3, 38=3. Next cw-endcard-polish: stat cells equal 120px no dividers 24/16px, chips no amber bar, hero label small over number, 16px floor on subtitle/XP/feedback, 'Killed by unknown' fix, 8px tile gap.
- $ stays: haulTotalLine and Credits use $ everywhere in game (not touching).
