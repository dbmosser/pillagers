
--- codex run 2026-10-27 17:43 ---
2026-10-27: Prepared cw-cx-fpsscreen for o-93-fps-counter-screen-rate on v35.15.
The fps counter adds " | screen 60" when VSYNC.ms is positive and the cap exceeds 1000/VSYNC.ms by more than 5. VSYNC.ms stays zero until the existing measurement has enough refresh samples. The displayed screen rate is rounded; the threshold uses the unrounded measurement. Counter text is lower case. No cap, DRS, or pacing code changes.
The new check calls the real fpsTick at staged 16.7 ms intervals. It covers cap 144 / screen 60, cap 60, cap 30, cap off, the exact 5 fps boundary, cap 66, matching 144 Hz, no settled measurement, and counter off. It restores CFG, VSYNC, FPSV and the counter DOM in finally. The positive callout assertion fails on the current build.
Check 26.46 has two exact uppercase counter-text assertions. fixture-retarget.json accepts either case and the optional screen callout while retaining its measured 60 and 30 fps assertions. Both anchors match exactly once; the retarget accepts the current and proposed build.
Sandbox validation: mk script prints written; the game anchor matches exactly once; the draft replacement is limited to counter text; generated JavaScript and both camera recipes pass node --check; handoff files are ASCII. Browser checks cannot run in this sandbox.
Handed off a key, fixture retarget, and two camera recipes for the callout and 60 cap control. The recipes hold the screen measurement at 16.7 ms only in the fixture camera page. Lane must run preflight, ship, and capture/critic both pictures. No questions or known gameplay risk.

