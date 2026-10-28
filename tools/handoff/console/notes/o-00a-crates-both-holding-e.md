
--- codex run 2026-10-28 15:23 ---
2026-10-28: Prepared cw-cx-bothsearch to correct v35.92. No game file was edited. Waiting for the lane browser gate, ship, ON HIS PC, and four real linked-window camera results.

The speed helper now requires both players to hold search. The local input check counts keyboard E and pad search at a reachable closed box, including a box owned by the other player. It does not depend on a granted search, which was essential for two players holding E at the same crate. It also accepts searching an adjacent box within the existing 200-unit radius. Releasing, leaving reach, going down, dying, extracting, rolling or opening a menu removes the local held state. Remote input defaults off when absent and uses the latest received position rather than the eased drawing position.

The existing player-state packet carries one new optional shold bit, received and forwarded in both directions. Input edges send in the current frame instead of waiting for the 10 Hz position clock. All three progress paths continue using the same speed helper. Loot grants, pickup stack, sounds and loot rows were not changed. No seeded draws were added.

fixture-retarget.json keeps the v35.92 check useful on both the old and corrected builds. Only when the new helper exists does its staged searcher hold E and stand within actual crate reach. The new check measures idle 1x, same-crate and adjacent-crate 1.5x, same-tick release, menu/down/range exclusions, pad input, missing bits from older windows, receiving/forwarding, immediate sends and all three progress paths in career and demo.

Local validation: mk script printed written; all eight anchors match once; the patched game script, new check, retarget and four camera bodies parse. An isolated helper probe reproduces the old standing-near bug and passes the corrected input cases. The browser fixture check itself cannot run in this sandbox.

The four camera recipes reuse the previous task's real host/player 2 link setup. They measure the real network state in both windows, including idle, same/adjacent boxes, release, pad and menu, then compare the host handling a guest search against the guest's predicted bar. Each recipe must report successful measurements before its photograph counts. No camera, Chrome or network was started here.

DESIGN.md watch line, carried in the draft why for the normal ship entry: two players holding E together search faster; one standing by does nothing


--- codex run 2026-10-28 15:25 ---
2026-10-28 follow-up: Replaced the refused whole-check fixture anchor with four exact single-line anchors from the current v35.92 check. The live fixture mixes line endings, while the private worktree uses CRLF; the lane validator normalizes multiline anchors using the file-wide convention, which missed this check. Single-line anchors avoid that mismatch and leave the retarget behavior unchanged.

Ran the lane own read-only retarget.mjs plan validator against both the private fixture and C:/claudecode/dark raiders/tools/mkfixture.ps1: STATUS ok on both; all four anchors occur exactly once; RUN 35.92. No fixture was written or committed. Regenerated the draft: written; eight game anchors unique; patched game, check and retarget parse; isolated input probe still reproduces the old bug and passes the corrected cases.

cw-cx-bothsearch remains in keys.txt. Camera recipes are unchanged. Remaining work belongs to the lane: apply and test the retarget, preflight and ship the key, confirm ON HIS PC, and return both-window camera results.
