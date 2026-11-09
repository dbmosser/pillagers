
--- codex run 2026-11-08 20:22 ---
2026-11-08: HEAD v37.66 (614e3bd5f) does not meet the order. The pause End run handler at dark_raiders.html:74756 calls arcadeRunEnd(menu); the host branch at 73118 settles and tears down the shared raid.
Prepared cw-cx-endseat. The button now uses arcadeMenuOut: host keeps authority and spectates, peer stays out locally and sends arcquit with run id and final score. Host accepts the peer exit once for the current run. The final exit or extraction settles with the existing early-end penalty; solo and whole-run burn/death endings keep their existing path. Uses existing spectator rendering and xOut gates. No seed generation or storage-key change.
All five anchors matched exactly once against v37.66, draft generated, patched game script and fixture check passed node --check. No game file or fixture edits. Browser check, preflight, shipping and ON HIS PC verification remain for the lane. No older fixture retarget identified; existing direct arcadeRunEnd(menu) checks retain whole-run settlement semantics.
Two custom camera recipes stage the out seat in host and peer roles. They use mocked transport and teammate liveness to expose the local spectator result; they do not prove a real link.
LINKED REVIEW NEEDED: synced. New pair packet arcquit, plus existing arcend, arcx and shared xOut. Verify both exit orders in actual linked windows, host continues simulation after own exit, peer can finish after host exit, and no seat comes back after End run.
Watch: try host exit then peer extraction, peer exit then host extraction, both exit orders, and repeated End run presses. The survivor must continue; run-over must wait for both out.
The required external C:/Codex/FNP new 11082026/RULES.md is absent in this sandbox. No external project files were changed.

