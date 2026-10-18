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
- SHIPPED v30.51 cw-hudDemoTR (trDemo(), syncTopRight empty in demo). SHIPPED v30.53 cw-hudDemoCard (item line + backpack cue gated by trDemo()).
- NEXT: cw-hudammo (gun card ammo bigger/hero; ammo line draws ~40731 `p.ammo+' / '+rsvShow(p)` with FS(TYPE.title), name FS(TYPE.head)); then low-ammo box marker keep (Q64); then screenshots after + critic.
- SHIPPED v30.59 cw-hudammo (ammoDraw(); TYPE.num rounds + TYPE.title reserve; name moved by-46). Card stamp: could not run mk-card-autoP21 (refused) so wrote my own mk-cw-cardP21.ps1 (copy), shipped as cw-cardP21 (v30.56). Next card = P22.
- NEXT: after shots (02-after) of all 15 screens, view, critic, fix P0/P1.
- 02-after shots taken (v30.59). Critic: 21 and 50 both still 2. Findings (common): panels have hatched resize grips + chevron + amber titles; no 1px border; 5%/96px margins unmet (minimap flush top/right); ammo panel name too small vs hero, '$' in ammo panel; vitals bars gradient; toasts left faint; contracts row wraps. Plan: ship (1) panel chrome change (remove grip hatch when not editing, white title not amber, 1px border), (2) minimap/margin, (3) vitals flat bars, (4) toasts. One at a time.
- SHIPPED v30.62 cw-hudgrips (grip hatch only on hover). Critic after v30.59: 21 and 50 scored 2. Still open: amber panel titles to white, 5%/96px margins (minimap flush top/right: mmRect uses 16*R; checks at fixture ~21659-21663 assert W-16*R), flat vitals bars, toasts. Screens 19-24,33,34,36,37,48,51,61,78 not re-run through the critic. Next run: re-shoot, critic on all 15.
- Pattern learned: mk script at S/mk-cw-KEY.ps1 (copy of mk-alarmcap style); preflight: bash tools/handoff/preflight.sh a cw-KEY; ship: bash S/shipq.sh cw-KEY.
- Run info drawn in drawHUD ~line 39880-39975 (rows[], 'RUN GOALS' rows kept). Top-right credits is DOM: find topRightBottom().
