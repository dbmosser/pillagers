
--- codex run 2026-10-27 17:43 ---
2026-10-27: Prepared cw-cx-fpsscreen for o-93-fps-counter-screen-rate on v35.15.
The fps counter adds " | screen 60" when VSYNC.ms is positive and the cap exceeds 1000/VSYNC.ms by more than 5. VSYNC.ms stays zero until the existing measurement has enough refresh samples. The displayed screen rate is rounded; the threshold uses the unrounded measurement. Counter text is lower case. No cap, DRS, or pacing code changes.
The new check calls the real fpsTick at staged 16.7 ms intervals. It covers cap 144 / screen 60, cap 60, cap 30, cap off, the exact 5 fps boundary, cap 66, matching 144 Hz, no settled measurement, and counter off. It restores CFG, VSYNC, FPSV and the counter DOM in finally. The positive callout assertion fails on the current build.
Check 26.46 has two exact uppercase counter-text assertions. fixture-retarget.json accepts either case and the optional screen callout while retaining its measured 60 and 30 fps assertions. Both anchors match exactly once; the retarget accepts the current and proposed build.
Sandbox validation: mk script prints written; the game anchor matches exactly once; the draft replacement is limited to counter text; generated JavaScript and both camera recipes pass node --check; handoff files are ASCII. Browser checks cannot run in this sandbox.
Handed off a key, fixture retarget, and two camera recipes for the callout and 60 cap control. The recipes hold the screen measurement at 16.7 ms only in the fixture camera page. Lane must run preflight, ship, and capture/critic both pictures. No questions or known gameplay risk.


--- codex run 2026-10-27 18:43 ---
2026-10-27 continuation on v35.18: Verified ship commit 5d14d6468, v35.16 fps counter screen rate. Its commit records Check 35.16 and failure on v35.15. The shipped code and check are present. Fixture retarget commit is 3f9ef5afd. No further game change is needed.
Camera round 1 failed before either staging body ran: tools/uishots.ps1 always calls window.__uis.prep(), but my custom recipe had an empty prelude. Fixed camera-recipes.json to supply the required prep helper and pin DPR to 1. Checked the full camera wrapper and both bodies with node --check. Handed over the changed recipe for round 2.
Viewed both attached round 1 pictures. Neither contains the fps counter because staging failed. Their score 3 and P1 findings describe the unchanged title menu, not the counter; these pictures cannot verify or grade this task. No title restyling is included in this words-only counter fix. The valid callout/control captures and their critic results remain to be checked.


--- codex run 2026-10-27 18:45 ---
2026-10-27 completion on v35.18: Viewed both valid round 2 captures. The 144 cap / staged 16.7 ms screen shows "32 fps | screen 60"; the 60 cap control shows "32 fps" without a screen callout. The 32 fps is the camera browser throughput; the staged screen measurement is independently 60 Hz, as intended. Both views staged successfully, with zero camera lint findings.
Critic score 3 for each view meets the required 3 for these screens. Verified both accept.json entries have pass:true and need:3. Remaining P1 findings concern the existing wordmark, demo menu rows and saves block, outside this counter-text task. No P0/P1 finding concerns the counter. Optional P2 advice about the existing counter position is not needed for this words-only fix; hiding the counter would conflict with the requested behavior. No title-screen changes added.
Shipped cw-cx-fpsscreen as v35.16, commit 5d14d6468, with check 35.16. Fixture retarget is commit 3f9ef5afd. Game timing, cap and DRS are unchanged. Task complete.
Verified pictures: tools/handoff/console/notes/shots/o-93-fps-counter-screen-rate-recipes-2/fps-screen-rate-1080.jpg and tools/handoff/console/notes/shots/o-93-fps-counter-screen-rate-recipes-2/fps-screen-rate-control-1080.jpg.

