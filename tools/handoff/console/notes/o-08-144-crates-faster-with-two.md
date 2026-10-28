
--- codex run 2026-10-28 14:45 ---
2026-10-28: Prepared cw-cx-duosearch for lane o. No game or fixture file edited.

Added DUO_SRCH=1.5, DUO_R=200 and duoAt(ct,seat) in the draft. It requires the current party raid seed and a fresh live nearby teammate. Downed, dead, extracted, departed and spectating teammates do not count. The host himself counts for a partner hold. All three progress paths use it: the host own search, host running a partner hold and partner predicted bar. The partner bar also keeps the existing arcade multiplier so all three formulas agree.

The draft check stages seed 4242, the host 30 units from a box and a partner 120 versus 600 units away. It measures one second at all three search paths in career and demo, and tests eligibility, radius and unchanged solo speed. The before build will have equal nearby and distant rates. No seeded draws added. The required playtest watch line is in draft.why, which gen-draft.ps1 writes into DESIGN.md.

Sandbox verification: mk printed written; four literal edit anchors each matched once; applied the draft to an output-only syntax copy; Node syntax checks passed for the patched game JS, the new regression check and camera script. The temporary full-game copy was removed. Browser checks cannot run in this sandbox.

Handed over four smooth-look camera recipes: real connected career host/player 2 and demo host/player 2. Each verifies the host near/far rate, requests a partner search through the live link, checks the authoritative and predicted progress steps and requires the other pillager visible in both windows. Photos and critic results are pending, as are preflight, ship and ON HIS PC confirmation. The lane must return those results before this task is done.

Camera setup uses the real player 2 query without netslot (NETP2 is disabled by netslot), and adds arc=1 for the demo player 2 boot. Both windows use the standard party opener and live search grant.


--- codex run 2026-10-28 15:01 ---
2026-10-28 follow-up: cw-cx-duosearch shipped as v35.92; lane confirmed ON HIS PC v35.92 (113 seconds after ship). Career 1080 captures staged in both actual connected windows. Both measured host alone=1.0, host together=1.5, host partner step=1.5, partner bar step=1.5, and visible=[1,1]. No game code follow-up needed.

Round 1 demo pictures did not stage: a leftover test host popup blocked its close with the normal live-raid beforeunload warning, leaving the player 2 heartbeat fresh. Updated camera-only cleanup to close its named test windows, clear test heartbeat marks, bypass that warning only in test windows, close the peer on pagehide, and use a unique party code per recipe. The live connection and normal keyboard search grant remain required. The controls list and current pillagers board are folded through their existing controls for cleaner search pictures. Node syntax checks run again. Request round 2 with these changed recipes; no new ship key.


--- codex run 2026-10-28 16:28 ---
2026-10-28 completion: Original feature shipped as cw-cx-duosearch, v35.92, and the lane confirmed ON HIS PC v35.92 (113 seconds after ship). Round 1 report.json records successful actual linked career windows at 1080p: hostAlone=1.0000000000000013, hostTogether=1.4999999999999987, ratio=1.4999999999999967, hostPartnerStep=1.5, partnerBarStep=1.5, visible=[1,1] for each seat. Successful pictures are tools/handoff/console/notes/shots/o-08-144-crates-faster-with-two-recipes-1/duo-search-career-p1-1080.jpg and duo-search-career-p2-1080.jpg. The gate shipped the regression check covering career and demo, and the required DESIGN watch line. No player text, layout, loot rows or sounds were changed.

The owner then corrected this rule at about 15:10: both players must actively loot, e.g. hold E. His new task tools/handoff/console/tasks/o-00a-crates-both-holding-e.md explicitly says this beats this task, calls this original task done, and owns the correction and its checks. The correction shipped as v35.96 (a8deb4b8d); its retarget keeps the v35.92 check compatible. Current duoAt requires local duoHolding and the remote shold packet bit. Therefore round 2 expected 1.5 for an idle partner and correctly got 1.0. Do not restore the old standing-near bonus or add another key from this task.

Archived camera-recipes.json as camera-recipes-obsolete-standing-near.json so the lane does not spend more camera rounds on the rejected rule. Original both-window functional evidence remains the successful round 1 career pair. Broader existing HUD critic findings were handed off previously; the feature adds no new visible text or layout. Scores: round 1 career p1=3, p2=2; round 2 p1=3 with folded controls, other pictures failed staging and cannot judge crate behavior. Best functional versions are the two successful round 1 photographs above. No further screen polish belongs to this speed-only task.

Task complete. Current both-holding behavior and any further camera verification belong to o-00a-crates-both-holding-e.
