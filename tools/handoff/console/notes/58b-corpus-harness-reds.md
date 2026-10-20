# 58b-corpus-harness-reds (lane a, 2026-10-20)

Status: NOT reproduced, nothing changed. Reason: this run may not call tools/cdp.ps1 with -Port 9351 -Open/-Match/-Expr (only -Start -Port 9346 is allowed), and runchk.sh runs each check alone after __runPrep, which is exactly the way these five already pass. A leak from earlier checks in a slice cannot be seen that way. No fix guessed (task step 5). Alarm written in alarms.md.

Static clues only (not proof):
- v31.67 (mkfixture.ps1 line 9932): counts settings steppers whose border is not transparent and which are not hover, focus-within or padfocus. Game CSS boxes a stepper also when its row has class dshow (dark_raiders.html line 2037, detail pane row) or hover. A state left by an earlier check (a dshow row, or the mouse over a row) would give "3 idle steppers still boxed". Next run: in the slice [120,240) print document.querySelectorAll('#setlist .row.dshow').length and the last mouse position right before the check, then bisect the checks before index of v31.67.
- v30.91, v31.04, v24.38, v20.89: not read yet.

Next run (needs cdp on port 9351): __regressBg(120, idx31.67+1) first, then bisect.
