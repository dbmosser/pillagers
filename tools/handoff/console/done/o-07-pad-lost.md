o-07-pad-lost : a pad that drops pauses cleanly and comes back on A (pad research J8, coordinator 2026-10-19)
effort: medium

Today the disconnect box says "reconnect to resume" but nothing resumes. Build and test as section "J8" of tools/handoff/pad-research/best-practices.md:
- Detect a lost pad by polling (slot null or connected false), not only the event, which only the front window gets.
- The box reads "pad lost" (lower case). When the same pad returns it reads "press a", and A resumes. That press is also what
  Chrome needs before it shows the pad again.
- In two windows, the other window shows a small "p1 pad lost" or "p2 pad lost" tag and keeps running.
- The other pad never takes over the lost slot. The pad order rule stays: first pad = p2, second pad = p1.
Checks (each control must FAIL on the old build): stub getGamepads null for a slot, and the box shows within 2 frames; the stub
returns the pad, and the box says "press a"; a stub A press closes it and play resumes; the two-window case with one pad lost.
TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.

Lane note 2026-10-19 18:59: shipped cw-cx-padlost and parked: only lane-side steps are left. Codex's last words:
Shipped in v31.90. Check 31.90 passes and fails on v31.89.

Prepared stronger two-window camera recipes and `camera-run-request.json`; the installed runner skips recipe files.

TASK PARTIAL: coordinator must run the supplied camera command and return pictures and critic results.

Coordinator note 10-20 00:20: back in tasks/ for the lane-side step it waited for. The lane now photographs camera-recipes.json itself (first 6 screens, critic on each) and sends you the pictures; the first pass spends no Codex run. Already shipped (do not ship again): cw-cx-padlost cw-cx-o07-padreturn . Review the pictures and the critic: end TASK DONE if they hold, or fix P0/P1 findings with a NEW key.

Coordinator note 10-20 04:00 (in the VM): back in tasks/ once (run count reset) for the picture step only; your game fix is shipped. The camera now opens the second window (uishots -NoPopupBlock, or "popups": true in your recipe file), and on 02:20 a career pair linked in it (o-04, player 2 joined). The lane photographs your corrected recipes on its first pass (no Codex run). Then review: TASK DONE if they show the fix; if a pair still does not link in the camera, say so in one line and end TASK DONE, the two-window look goes to his playtest list.

Lane note 2026-10-20 06:28: shipped cw-cx-padlost cw-cx-o07-padreturn cw-cx-o07-reconnect cw-cx-o07-padcontrast and parked: only lane-side steps are left. Codex's last words:
All three fixes are shipped. Check 32.79 passes and fails on v32.78. The four-round camera limit is exhausted; corrected recipes are ready for coordinator verification.

TASK PARTIAL: player 2 pictures, post-fix critic review, and remaining valid UI findings.

DONE 10-21 00:40 (coordinator, coord-08): the corrected recipes staged all 6 scenes in real linked windows (5 in one run, j8-p2-press-a on a retry: notes/shots/o-07-pad-lost-coordinator-check and o-07-pad-lost-retry). Critic: j8-p1-pad-lost 3, j8-p2-pad-lost 3, the other four 2 (accept.json j8-*). Open findings are the whole raid HUD (owned by the HUD jobs) and the pad-lost tag (queued as 93); his titles pad lost and press a stay (his ruling, logged before).
