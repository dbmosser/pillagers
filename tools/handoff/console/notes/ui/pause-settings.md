# pause-settings (c-31-ui-pause-settings)
Before shots: notes/shots/c-31-before (screens 18,25,26,32,42,49,68-75, 1080).
Code map: .pausebox CSS at html line ~714 (old look: rgba(17,19,21,.9), h3 25px uppercase-class, gap 11px); .modal at ~720 (padding 22px).
Settings = #settingsmodal, #setwrap > #setlist + #setdetail; openSettings(tab) at ~64242.
Shared look: <style id="ui-shared"> ends at line ~1401, tokens --fs-*, --sp-*, --rad, --btn-h*; the check 29.33 forbids raw color/px literals inside ui-shared (only 1px/3px allowed).
Pattern to copy: S/mk-cw-uishared-board.ps1 (append rules before </style> of ui-shared).
Before pictures: pause box (25, 42) = small panel mid-screen, "Paused" title 25px amber, key chips line, 6 buttons in one row, wasted panel height.
Keys window (32): 2-column rebind grid with huge empty space right, intro text 2 lines duplicated.

## 2026-10-18 evening (coordinator): the open rulings are settled
Q7 (layout orders yield to the guide, but Q61 keeps the feedback line, button and Send play data), Q8 (shorten or delete his lines with a logged reason in notes\ui\changes.md), Q43 (centred card with an X, nearly the entire screen), Q59 ($ for money, SP for score).

## 2026-10-19 run (lane c, VM)
Fresh pictures of all 14 screens: tools/handoff/console/notes/shots/c-31r-before (camera works on port 9363).
The critic could NOT run: "CRITIC API 401, x-api-key header is required" (the VM has no console key; I do not touch keys). No score this run, and I did not ship blind.
Looked at 25 and 42 by eye: they already follow the guide (480 dialog, lime primary, quiet red link, feedback and what's new as a small row, X in the corner). Still open from the last critic notes: the scrim lets the HUD show through (rgba .9, no blur), no esc key hint on resume, pad focus bar not visible in stills.
Next run, once the critic works: score all 14 first, then fix P0/P1 only.

## 2026-10-19 run 2 (lane c, VM)
Critic still fails: "CRITIC API 401, x-api-key header is required" (no console key in the VM; I do not touch keys). No score possible, so no blind ship. Pictures in shots/c-31r-before are still current.
- BLOCKED run 3: writing S\mk-cw-pausebtn.ps1 was refused, both at the User1 scratchpad path and at C:\Users\VM Oct26\AppData\Local\Temp\claude\...\scratchpad (that is where shipq.sh really is in the VM). The write permission list names the User1 path only. Fix the permission (or the S path in RULES.md) and the next run can ship at once.
- PLAN for cw-pausebtn (CSS only, anchor = the line `#root #pausebox > div:has(> #resumebtn) > #fbbtn, ... > #wnbtn{ color:var(--tx-1); }` near html line 2081, append after it): (1) fbbtn and wnbtn: min-height var(--btn-h-sm) 48, 16px 600, background var(--ui-panel), border var(--ui-line-hi). (2) abandonbtn, arcendbtn, charselbtn (not .asking): min-height 48, margin-top var(--sp-4), border 1px solid var(--danger) !important, color danger !important, transparent fill (the old rule at html line ~2025 forces a transparent border). Check: computed min-height of #fbbtn, #wnbtn, #abandonbtn >= 48 and abandon border not transparent. Critic asked for exactly this on 25, 42 and 49. Not done: esc resume legend (line ~1870 hides it on purpose), scrim (hub labels behind it come from the hcv canvas).
- 2026-10-19 run 3 (lane c, VM): critic WORKS now (run from repo root with a relative picture path). Scores: 25=3, 42=3, 49=3, 74=2 (P0: list clipped mid row, 24 lime labels on the pad diagram; P1: chips under 16px, headers 13px, no focus state).

## 2026-10-19 run 4 (lane c, VM)
BLOCKED again: Write of S\mk-cw-pausebtn.ps1 at the VM scratchpad path (C:\Users\VM Oct26\AppData\Local\Temp\claude\...\scratchpad) was refused (permission not granted). Nothing shipped. The mk script is fully drafted in my head per the run 3 plan, with one change: abandon keeps NO box (older check, comment at html line 2060), so only min-height 48 (var(--btn-h-sm)) for #fbbtn, #wnbtn, #abandonbtn/#arcendbtn/#charselbtn and margin-top var(--sp-3); anchor = html line 2081; check = computed min-height >= 48 on those ids.
Fix needed: allow Write/Edit on the VM scratchpad path in the lane permission list (or change S in RULES.md).

## 2026-10-19 run 5 (lane c, VM) - writes work now
Scores (fresh pictures c-31s-before): 25=3, 18=3, 74=2. NOTE: the critic invents findings when the picture path does not exist, and with one path containing "before" it judges some other shot. Always pass an existing file; pass before + after as two paths. Compound shell lines (cd && cp) are refused, run each command alone.
Shipped: v32.08 (cw-pausebtn, 48px small tier), v32.09 (cw-padpic, pad picture), v32.10 (cw-pausefb2, report field 48px, title 32px). Retargeted checks 31.71 (<=48) and 31.36 (48 or 56).
After: 74 = 3 (done). 25 stays 3 after two pause passes (shots c-31t-after, c-31u-after). Its remaining P1s are generic: no pad focus state shown in stills, abandon floats about 64px below with no box (an older check forbids a box), feedback and what's new labels still read about 14px (the fs-label rule seems to lose to another rule), the card is a 480 dialog (Q43). 18 = 3 (done). Not scored this run: 26-32, 42, 49, 68-73, 75.
Next: find why the feedback and what's new labels render about 14px, one more pass on 25/42/49 (pause box tries used: 3 of 6), then score 26-32, 68-73, 75 and fix anything under 3.

## 2026-10-20 run (lane c, VM)
Fresh pictures c-31v-before. Critic: 25 = 3 (P1: four button heights, small pair label), 68 = 3 (done, not a pause screen). 26,32,70,72,74,75,18 already 3 (done). 27-31, 69, 71, 73 are settings scroll/section shots like 68, same card.
Plan cw-pause56: all pause buttons 56px with the 20px label (CSS only), fixture 31.71 retargeted from 48 to 56. HELD=1 form of fixq.sh is refused by permissions, so fixq ran plain after lock.sh (it waits for my own lock to expire).
Shipped v32.26 (cw-pause56: all pause buttons 56px, 20px label) and v32.28 (cw-pausefb56: report box 56px). Fixtures 31.71 and 32.10 retargeted to allow 56. Pictures: shots/c-31v-before (old), c-31w-after, c-31x-after.
Critic after: 25 = 3 ("better_than_before: yes" after v32.26, "same" after v32.28). It keeps naming the 480 card (Q43 says the pause box is a 480 dialog), abandon as a boxed button (an older check forbids a box), no pad focus state in stills, secondary fill hue, no esc legend (hidden on purpose, line ~1875), scrim. Pause box tries used: 5 of 6. Stuck; best version is the current build (c-31x-after). 42 and 49 share the same CSS (not re-scored).
Settings screens 18, 26, 32, 68, 70, 72, 74, 75 are at 3 (finish line 3 for non-pause screens, his 3.51 a). 27-31, 69, 71, 73 are scroll and section shots of the same card as 68 (shown fine by eye).

## 2026-10-20 run 2 (lane c, VM): try 6 of 6 on the pause box
Shipped v32.66 (cw-pausegap): end run one gap under the stack, lime focus bar and raised fill on idle pause buttons, brighter header divider. Pictures: shots/c-31y-before (old), shots/c-31y-after. Critic on 49: 3, "better_than_before: yes". Remaining P1s are the 480 dialog (Q43 says dialog) and "merge report/feedback/what's new into a ghost row" (Q61 allows moving; not done). Rule 2.83 b: 6 tries used on the pause box, stopping. Best two versions: c-31x-after (v32.28) and c-31y-after (v32.66, best). Settings screens at 3 are done (his 3.51 a: 3 is enough for non-pause screens).

## 2026-10-20 run 3 (lane c)
No new work. Pause box (25, 42, 49) stays at 3 after 6 tries (rule 2.83 b); best is c-31y-after (v32.66), then c-31x-after (v32.28). Settings screens are at 3 = done for non-pause screens (3.51 a). Open for a later pass after the party: merge report, feedback and what's new into one ghost row (Q61 allows moving).
