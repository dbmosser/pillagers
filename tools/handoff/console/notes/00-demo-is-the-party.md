
--- codex run 2026-10-19 11:02 to 11:07 (earlier runs, kept short) ---
Lane o prepared the draft cw-cx-demoplain (mk script in the scratchpad) and stopped because the older fixture checks still read PARTY. Details of the draft: it removes ?party=1 (parser, flag, CSS, boot, reload, nav, stale marks, title overrides), EXIT DEMO uses plain arcadeLeave, the demo map auto starts after MAPFIRST.auto, F2/F8 need Ctrl while the demo is on (demoKeysOn), labels and tag follow the demo.

--- claude lane a run 2026-10-19 21:15 to 21:35 ---
1. Fixture retarget committed (8c7bf0ee), done under the lock:
   - v30.79 "party launch mode" (six checks): kept in place but their guard now returns "SKIP: the party launch mode was retired" (nothing left to test; they SKIP instead of being deleted, to keep the edit small and safe).
   - v31.37 cw-partykeys: its own guard (typeof PARTY undefined) already SKIPs once PARTY is gone; the new ship check owns the Ctrl rule now.
   - v31.09 cw-mapfirst: removed oParty/PARTY arms; step SIX now only checks that a career raid never lets go of the map by itself. Demo auto start is owned by the new check.
2. preflight a cw-cx-demoplain: PREFLIGHT PASS as v32.01.
3. shipq.sh cw-cx-demoplain: printed SHIPPED v32.01, gate passed (fingerprint 85/374, 165/593 ok). BUT the commit step did not land: ship.sh commit printed "cp: cannot create tools/publish/index.html: No such file or directory" (the folder tools/publish does not exist in the VM), and no v32.01 commit exists. HEAD is still 29de0725. The working tree holds the shipped game (VER 32.01), DESIGN.md, AUDIT.md, tools/mkfixture.ps1 (the new check) and tools/handoff/cm3201.txt (the commit message), all UNCOMMITTED. My lane may not run git add/commit.
   NEEDED (coordinator): in the repo, run `bash tools/handoff/ship.sh commit 3201 cm3201.txt` from tools/handoff after creating tools/publish (mkdir tools/publish), or just git add -A + git commit -F tools/handoff/cm3201.txt, then git push. Until then every other ship STOPs on "uncommitted changes". Do NOT ship cw-cx-demoplain again.
4. Not done yet (after the commit): title picture, a ?party=1 comparison page, two-window demo run with a map picture from each window, critic on title and map.

--- claude lane a run 2026-10-19 (second run) ---
Pictures taken (tools/handoff/console/notes/shots/00-demoplain-after/): title (01, normal title, no party override, lint 0), map (22), p2 window title (58). All look right.
Still blocked: v32.01 is in the working tree but NOT committed (no tools/publish folder in the VM; my lane may not run git add/commit). Coordinator: mkdir tools/publish, then git add -A + git commit -F tools/handoff/cm3201.txt, then git push.
Not done: the check results are only the shipq gate's (passed); no live two-window demo run picture and no ?party=1 comparison page picture; critic not run.

--- claude lane a run 2026-10-19 (third run) ---
Verified: the working tree game (VER 32.01) has no partyHostBoot, partyP2Boot, partyReload, PARTY_EXIT or partyOf left. cw-cx-demoplain is in the file.
Still UNCOMMITTED: my lane cannot run git add/commit and tools/publish still does not exist in the VM. Coordinator: mkdir tools/publish, then git add -A and git commit -F tools/handoff/cm3201.txt, then git push. Do NOT ship cw-cx-demoplain again.
Not done: live ?party=1 comparison page and two-window demo run pictures (the camera cannot take a custom URL). The gate's check run is the only proof of the Ctrl+F8 and map auto start rules.

--- claude lane a run 2026-10-19 (fifth run) ---
No change: VER 32.01 still uncommitted, tools/publish still missing, my lane cannot commit or mkdir. Coordinator: mkdir tools/publish; git add -A; git commit -F tools/handoff/cm3201.txt; git push. Do not ship cw-cx-demoplain again.

--- claude lane a run 2026-10-19 (sixth run) ---
v32.01 is committed (17826203). No partyHostBoot, partyOf or PARTY_EXIT left in the game. The ship gate passed (Ctrl+F8 rule, demo map auto start, fingerprint).
Critic on the title picture: 3. The findings are general title polish (wordmark gradient, 5 mode rows, saves block, coming later row), not part of this task and some touch his row rulings, so left for the title task.
Not done: a live ?party=1 page and two-window run pictures (the camera takes no custom URL); the gate checks are the proof.

--- claude lane a run 2026-10-19 (fourth run) ---
Same state: VER 32.01 in the working tree, uncommitted (game, DESIGN, AUDIT, mkfixture); tools/publish still missing. My lane cannot run git add/commit or mkdir. Coordinator: mkdir tools/publish, git add -A, git commit -F tools/handoff/cm3201.txt, git push. Do not ship cw-cx-demoplain again. Still not done: two-window demo pictures, ?party=1 comparison, critic.

--- coordinator 2026-10-19 22:00 (VM) --- Requeued with fresh tries. The VM save block is FIXED (6dc93534): mk-cw-* writes to the scratchpad work again (the lane rules now also name the VM real path). v32.01 (the plain party demo) was committed and pushed by the coordinator at 21:4x; tools/publish exists. Carry on from your plan.
