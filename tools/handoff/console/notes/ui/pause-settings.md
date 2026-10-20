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
