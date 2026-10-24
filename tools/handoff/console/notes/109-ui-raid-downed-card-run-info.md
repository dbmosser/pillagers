# 109-ui-raid-downed-card-run-info (lane c, 2026-10-24)

Pictures: notes/shots/109-before (HEAD v34.38), 109-after (v34.39), 109-after2 (v34.41), 109-after3 (v34.44). Screens 34 and 36 at 1080.

## Shipped
- v34.39 cw-downedcard: run info panel fits its widest row (runInfoFitW, grows left, cap 1.6 x column), so no contract row wraps. Downed card uses the shared raid panel (hudPanel plain, .9) plus a 3px danger tab; timer at the num size (44, the HUD hero), "down" a danger label; bar and prompt colours from UIC. Check 34.39 fails on the old build (checked twice by preflight).
- v34.41 cw-downedcard2: "down" at the title size (26), the live self-revive key drawn in the accent (lime).
- v34.44 cw-downedcard3: downed wash 45 to 30 percent, bleed bar neutral (tx-2). Critic said "same" or worse.

## Critic on 34
2 (HEAD) -> 3 (v34.39 and v34.41) -> 2 (v34.44, "same"). The critic is noisy: its last pass says the card has no top tab and no radius, which it has. Remaining findings are outside this task: capital I misread of the condensed "i" (already handled by v28 cw-h103fix, the critic reads the picture), left feed duplicates the right pickup stack (his 10-15 feed-all order, question 91), panel styles across the HUD, 'extraction c available' string, the slider plus bleed bar both shown (slider is a mechanic; kept every line).
36: 2 before, 2 after (same, not lower).

## Not done
- 4 not reached on 34 after 3 tries. Best version is v34.41 (critic 3); v34.44 only lightens the wash. If a later run wants to go on: shorten "[f] self-revive, one per raid" (needs his OK, it is an existing line), decide the slider plus bleed bar, and the red wash as an edge vignette.
- 4k and P2 not shot: the fit is in HUD space and the same draw code, checked at 1080 only.

Run 4 (10-24 later): re-read the v34.44 picture; card is the shared panel with danger tab, hero timer, danger label, live key; wrap defect gone. No new ship: remaining critic findings are outside this task (feed duplicate = question 91, 'extraction c available' string, slider plus bleed bar are mechanics) and the critic is noisy (3, 3, 2). 3 of 6 tries used; best v34.41 (critic 3); 36 not lower than 2. Still open: 4k and P2 pictures, critic 4 on 34.

Watch on next play: the run info panel is wider (up to 1.6 x the column) when a contract is long; the downed card now has a danger tab and a lighter red tint.

Run 5 (10-24): no new ship. Re-read notes and check 34.39: wrap defect check covers rows inside panel at the staged viewport; same HUD-space code at 4k and P2. 3 of 6 tries used, best v34.41 (critic 3). Left: critic 4 on 34, 4k and P2 pictures.

Run 7 (lane a, 10-24): shipped v34.46 cw-cdoneshort (contract done line shortened, checks 23.10 and 53 retargeted, logged in changes.md). Critic on 34: 3 (same, no P0; the rest is HUD-wide panel styles, running slowly duplicate = feed-all order q91, world labels, hotbar). The "notch" it names is the intended 36px danger tab. 4 of 6 tries used, best v34.41 and v34.46 at 3. 36 unchanged. Not done: critic 4 on 34, P2 picture. Watch on next play: contract done shows only the contract words.

Run 6 (10-24): shot 34 at 4k (notes/shots/109-4k). Run info rows stay on one line, panel fits, downed card has the shared panel, danger tab, hero timer, danger label, live key. 4k confirmed. No new ship. P2 picture still not taken. Critic 4 on 34 not reached (best v34.41, critic 3); 3 of 6 tries used.
