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

## Run 4
- v30.82 cw-title-see shipped: no floor labels/HUD drawn behind the attract pages, blur 16 to 5px, scrim lighter at edges, fights stand at y 300 (mid height). Fixture check 30.20 retargeted (cefdc363). Also cw-cardP22 (stamp). Fixture: 5 of 6 v30.79 party checks got "v:'30.79', what:" (space) so the gen anchor (above the previous version's first check) matches once.
- Shots shots/03-after. Critic: 45 = 3, 46 = 3 (card structure: lone "press any key", tiny close X, no header/footer rules; those are a shared attract-card task, not the backdrop), 01 = 3.
- Tried name box lower case: input value PILLAGER is stored uppercase and the global * rule sets text-transform none !important, so CSS cannot lower it; draft cw-title-name STOPPED, not shipped. Needs the name lowered where the input value is set (risk to saves/net names).
- 4K 60fps still not measured (the fight is 2 pillagers + robots, no sim).

## Run 5
- v30.90 cw-title-legend shipped: kbrow 8 hints to 5, top buttons 48px (check 30.88/30.90 uses computed min-height, the gate zoom is 0.9; textContent is lowercased so test /i). Scrim (v30.65) was already in.
- Shots shots/03-r5 (before), shots/03-r5after. Critic: 01 = 3 (same), 45 = 3, 57 = 3. Left, all structural, none is the backdrop: P0 name input shows PILLAGER in capitals (needs lowering where the value is set, saves/net risk); logo is a gold gradient (old check 18.11 demands a gradient, guide bans it: a fixture retarget plus his call, the brand mark); five mode rows incl. dead server row (his ordered rows); saves block 898px wide vs 558 column; attract card needs a primary "press any key" button, 56px header, 72px footer (shared attract-card task).
- Still not measured: 4K 60fps on the title (fight is 2 pillagers + robots, no sim).

## Run 6 (lane b)
- v31.00 cw-title-saves shipped: saves block max-width 900 to --menu-w (560); name box default shows "pillager" (titleNameShown; go() ignores the lowered default). Critic 01: 3, better than before. Left (all his rulings or structural): five mode rows (his ordered rows), logo gradient (check 18.11, brand mark), fullscreen button, saves block as a form (big, many checks), key legend. Nothing left that is the backdrop. 4K 60fps still not measured (no tool for it; the fight is 2 pillagers + robots, no sim). Shots shots/03-r6-before, 03-r6-after.
- Stuck: 01 stays at 3 after 6 runs; only the saves/mode/logo restructure would move it, and that needs his call.

## Run 7 (lane b)
- No ship. Re-shot 01/45/46/56 (shots/03-r7-before) and ran the critic on the current build: 46 = 3, 56 = 2 (old-only pictures, no comparison), 01 = 3 (r6). Its findings contradict the earlier rounds: it now asks for a 90 percent window card, while the 4th-time critic (cw-partyempty) asked for a card sized to its content. It also asks for a darker scrim (.80), which fights his order (Q52/Q54: live map dimmed, fight must be seen). Skipped both.
- Left on 46 (how-to): 9 rows with flat hierarchy, pad keys drawn as letter keycaps, "hold x" used for both extract and loot. The loot/extract clash is a controls question for him, not a style fix.
- Live fight backdrop: shipped (v30.69, v30.82). 4K 60 fps not measured (no browser rule; the fight is 2 pillagers and a few robots, no sim). Screens 44 and 57 share the title and card code, so they move with 01 / 45.
- Stuck: 01 = 3, 45/46/56 = 2 to 3. Only a card/saves restructure moves them, and the critic's advice flips between runs. Needs his call on the card size (content card vs 90 percent window).

## Not done (older; the live fight is now done by cw-title-fight)
- Q52/Q54 live backdrop with REAL pillager-vs-robot combat behind title, scoreboard, how-to (screens 45, 46, 56). Title shows the dimmed hub floor (titleSceneReady, ~46338; HB hub world with people milling, drawn in the main loop state==='hub' ~47519). Real combat needs either a raid sim (G, state='raid', runSim ~32155, G.sim skips draw) driven by a bot under the title at 60fps 4K, or hub NPCs with robots shooting. Big engineering task, not started: it needs its own multi-ship plan and a perf check at 4K.
- Screens 44, 45, 46, 56, 57 not scored by the critic yet (shots in shots/03-after).
