# 58b-corpus-harness-reds (lane a, 2026-10-20)

Status: NOT reproduced, nothing changed. Reason: this run may not call tools/cdp.ps1 with -Port 9351 -Open/-Match/-Expr (only -Start -Port 9346 is allowed), and runchk.sh runs each check alone after __runPrep, which is exactly the way these five already pass. A leak from earlier checks in a slice cannot be seen that way. No fix guessed (task step 5). Alarm written in alarms.md.

Static clues only (not proof):
- v31.67 (mkfixture.ps1 line 9932): counts settings steppers whose border is not transparent and which are not hover, focus-within or padfocus. Game CSS boxes a stepper also when its row has class dshow (dark_raiders.html line 2037, detail pane row) or hover. A state left by an earlier check (a dshow row, or the mouse over a row) would give "3 idle steppers still boxed". Next run: in the slice [120,240) print document.querySelectorAll('#setlist .row.dshow').length and the last mouse position right before the check, then bisect the checks before index of v31.67.
- v30.91, v31.04, v24.38, v20.89: not read yet.

Next run (needs cdp on port 9351): __regressBg(120, idx31.67+1) first, then bisect.

## Coordinator 10-20 15:00 (slicechk.sh, lane a Chrome 9351, shipped fixture of v32.99; places shift by about 9 per new release, so
## always look a check up with find: first)
- REPRODUCED: `slicechk.sh a 120:229` (places 120 to 228 in order, 42 s) ends with 228 v31.67 "1 idle steppers still boxed". The same
  checks run alone in order (`slicechk.sh a 171,184,152,228`) all PASS, so it is a leak from earlier checks, as job 58 said.
- The same in-order run turned SIX MORE red that the 10-20 12:50 full run did not show (that run had different slice edges):
  152 v32.43 forge "current tier is not labeled"; 155 v32.40 forge "full forge action or dollar price did not draw";
  162 v32.33 map loot tags "missing contract track or status"; 171 v32.24 "the fire keycap was never drawn";
  184 v32.11 "the stamina word was not drawn"; 202 v31.93 J7 pad trials "tag not drawn beside its pillager".
  These are in scope for 58b too: same kind (pass alone, fail after earlier checks). Most say "not drawn", so look first for an
  earlier check that leaves a screen, the scrim, a pause or a stubbed draw function behind. Bisect 120:152,152 first (the first red).
