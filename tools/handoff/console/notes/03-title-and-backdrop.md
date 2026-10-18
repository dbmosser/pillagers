# 03-title-and-backdrop (lane c)

## Shipped
- v30.41 cw-title-line: story paragraph and the 3 step cards gone, one line "Ascend. Pillage. Extract." (id titletag). No raiders beside the logo. PvP row hidden by task 01.
- v30.48 cw-title-centre: the line centred, 20px tx-2.
- v30.60 cw-title-clean: the three explaining sentences gone from the title (fixture check 9.50 retargeted, 55b18e72).
- v30.55 cw-cardP20 (What's New stamp).
- Shots: shots/03-mid (after centre), shots/03-after (after clean). Critic on 01 after: 3 of 5 (was 2).

## Pending
- cw-title-scrim (S/mk-cw-title-scrim.ps1, preflight PASS as v30.62): centre scrim .9 to .58, blur 3px. Ship STOPPED 3 times: "RECENT ERROR: dry=TIMEOUT" in the old-check rerun (not my edit, ctl also fails 30.12 / 30.10, other lanes' checks). After 4th try see if it ships; if it does, re-shoot 01 and run the critic.

- Later tries (same run): STOP "uncommitted changes" twice. git status shows tools/handoff/recent.ps1, preflight.sh and tools/mkfixture.ps1 edited by someone else (the gate's own files changed: likely why dry=TIMEOUT). NEXT RUN: just run `bash S/shipq.sh cw-title-scrim` first.

## Critic findings left on 01 (score 3)  ($ is fine: Q59 "$ for money, SP for score")
- P1 saves block is a form on the title (label, amber row, all caps PILLAGER input, 2 buttons): collapse to one 48px row + Saves modal. Not done (big, touches many fixture checks).
- P1 five mode buttons, four ghosts equal weight; "coming later" chip. Maybe group the two demos behind one "Demos" button.
- P1 key legend 8 hints, 15px: cut to Enter, Esc, F1.
- P2 logo gradient+shadow, top-right buttons 44 -> 48px, version stamp, 1px frame border.

## Run 3 (this one)
- v30.65 cw-title-scrim shipped (centre scrim lighter). v30.69 cw-title-fight shipped: scripted pillager-vs-robot fight (tskInit/tskStep/tskDraw, sorted into the hub draw list when tskOn()) behind title, scoreboard, how-to. Cheap: 2 pillagers + robots, no sim.
- Shots shots/03-fight (01,45,46). Critic: 01 = 3, 46 = 3. Remaining findings are NOT the backdrop: capitals still on screen (lowercase door is another task), saves block, five buttons, legend, how-to needs close button + primary, logo gradient. 4K 60fps not measured.

## Not done (older; the live fight is now done by cw-title-fight)
- Q52/Q54 live backdrop with REAL pillager-vs-robot combat behind title, scoreboard, how-to (screens 45, 46, 56). Title shows the dimmed hub floor (titleSceneReady, ~46338; HB hub world with people milling, drawn in the main loop state==='hub' ~47519). Real combat needs either a raid sim (G, state='raid', runSim ~32155, G.sim skips draw) driven by a bot under the title at 60fps 4K, or hub NPCs with robots shooting. Big engineering task, not started: it needs its own multi-ship plan and a perf check at 4K.
- Screens 44, 45, 46, 56, 57 not scored by the critic yet (shots in shots/03-after).
