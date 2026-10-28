
--- codex run 2026-10-28 14:45 ---
2026-10-28: Prepared cw-cx-duosearch for lane o. No game or fixture file edited.

Added DUO_SRCH=1.5, DUO_R=200 and duoAt(ct,seat) in the draft. It requires the current party raid seed and a fresh live nearby teammate. Downed, dead, extracted, departed and spectating teammates do not count. The host himself counts for a partner hold. All three progress paths use it: the host own search, host running a partner hold and partner predicted bar. The partner bar also keeps the existing arcade multiplier so all three formulas agree.

The draft check stages seed 4242, the host 30 units from a box and a partner 120 versus 600 units away. It measures one second at all three search paths in career and demo, and tests eligibility, radius and unchanged solo speed. The before build will have equal nearby and distant rates. No seeded draws added. The required playtest watch line is in draft.why, which gen-draft.ps1 writes into DESIGN.md.

Sandbox verification: mk printed written; four literal edit anchors each matched once; applied the draft to an output-only syntax copy; Node syntax checks passed for the patched game JS, the new regression check and camera script. The temporary full-game copy was removed. Browser checks cannot run in this sandbox.

Handed over four smooth-look camera recipes: real connected career host/player 2 and demo host/player 2. Each verifies the host near/far rate, requests a partner search through the live link, checks the authoritative and predicted progress steps and requires the other pillager visible in both windows. Photos and critic results are pending, as are preflight, ship and ON HIS PC confirmation. The lane must return those results before this task is done.

Camera setup uses the real player 2 query without netslot (NETP2 is disabled by netslot), and adds arc=1 for the demo player 2 boot. Both windows use the standard party opener and live search grant.

