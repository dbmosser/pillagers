# 02-raid-hud-redesign (lane a)
Before shots: notes/shots/02-before (screens 19-24,33,34,36,37,48,50,51,61,78 @1080).
Findings from before shots (demo screen 50): top-right still shows "900 Credits 0 XP Stash 0 bag 390" (Q55 hide in demo);
gun card bottom right has "B / I backpack" + "4 items $390" (Q56 hide in demo); gun card ammo "7 / 42" ~ size TYPE.title (Q57 make bigger).
Run info box (screen 37) lists ~8 contracts (Q1: max 3 closest to done).
Code: gun card at ~line 40692-40760 of dark_raiders.html (ctx.fillText(_cornName ...), ammo line, items line, backpack cue).
## Plan
1. cw-hudcontracts: Run info max 3 closest-to-done contracts.
2. cw-hudDemo: hide credits/XP/stash/bag, item-value line and backpack hint in demo.
3. cw-hudammo: bigger ammo.
## Log
- SHIPPED v30.49 cw-hudcontracts (runInfoCap, RUNINFO_MAX=3 at file scope before EDGEBOX).
- Pattern learned: mk script at S/mk-cw-KEY.ps1 (copy of mk-alarmcap style); preflight: bash tools/handoff/preflight.sh a cw-KEY; ship: bash S/shipq.sh cw-KEY.
- Run info drawn in drawHUD ~line 39880-39975 (rows[], 'RUN GOALS' rows kept). Top-right credits is DOM: find topRightBottom().
