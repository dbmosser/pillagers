
--- codex run 2026-10-30 13:34 ---
2026-10-30: HEAD v36.64 already implements the requested rule. No game edits or ship keys needed.
- dark_raiders.html:65048-65055 documents the v16.05 partner revive path, its 64-unit reach and 3.2-second hold.
- netMateDown at 65056 and netRevHold at 65074 select a downed partner and time each hold. Neither checks a per-raid pickup allowance. netRevDone prevents duplicate sends during one held press; it clears on release or confirmed recovery.
- netRevPass/netRevTake at 65109/65115 route the rev packet for host and join roles. netRevApply at 65123 checks the current downed state and distance, restores 40 percent health and grants two seconds of protection. G.tel.revives is a tally only, never a limit.
- selfRevive at 29631 alone checks p.revived for the one-per-raid self-revive. Partner revival ignores and preserves that flag.
Prepared camera-recipes.json with two per-role fixture pictures. Each recipe asserts twelve send/receive cycles, no send at 1.5 seconds, exactly one after a fresh 3.25-second hold, and successful pickup with self-revive already spent. These use fake peer transports, not two live linked windows. Await lane results before claiming runtime verification.
SYNCED existing path: packet t:rev; no game change and no linked review requested.
Watch: after spending self-revive, go down again and have the partner hold revive for 3.2 seconds; repeat in each window. Partner pickups should remain available.
No DESIGN.md change is needed because no build is changed; this watch line records what to check on the existing build.

--- codex run 2026-10-30 13:35 ---
2026-10-30 follow-up: examined both round-1 pictures; they show the title, not a raid. The camera wrapper always calls window.__uis.prep(), but the standalone recipes had an empty prelude. Neither twelve-cycle proof ran. Fixed camera-recipes.json to supply the required prep helper. No game or rule change.
The critic reviewed the unstaged title images; its title-screen findings are unrelated to this pickup task and do not justify changing the title here. Await a staged round before recording runtime success.

--- codex run 2026-10-30 13:38 ---
2026-10-30 completed on unchanged v36.64, under the task instruction to record and photograph an already implemented rule.
Round-2 report confirms all four recipe runs staged successfully: host and join at both 1080p and 4k. Each passed twelve repeated send/receive pickup cycles in one raid with p.revived=true throughout, no send after 1.5 seconds, one send after a fresh 3.25-second hold, and recovery at 40 percent health. These are fixture role tests with fake peer transports, not a live linked-session test.
Code remains the existing v16.05 path: dark_raiders.html:65048-65135; NET_REV_T=3.2 at 65055, netRevHold at 65074, netRevApply at 65123. No allowance or revival counter gates partner pickups. The tally only increments. One-per-raid selfRevive remains separate at 29631.
Viewed both attached 1080p pictures. Evidence folder:
C:/claudecode/dark raiders/tools/handoff/console/notes/shots/o-12-194-unlimited-partner-pickups-recipes-2/
Player 1: unlimited-pickups-player-1-1080.jpg
Player 2: unlimited-pickups-player-2-1080.jpg
Both show successful revival and hp 40. report.json contains the passing role results, with 4k copies alongside.
Critic scores are 2 for each staged raid image. The twelve-label column is caused by the synchronous proof: all twelve receives call label() without advancing simulation time. label() at 24251 gives non-item labels 1.9 seconds of life (24293), shorter than the 3.2-second normal pickup hold. The proof therefore retains twelve labels that would expire between normal pickups. The open controls panel is also forced by __deploy's fixture legend default (tools/mkfixture.ps1:114076). Neither is a new game defect introduced by this task. Other critic findings concern existing raid HUD design; no UI was changed, so no raid redesign is undertaken to meet a new-screen critic threshold. This closes via the task's explicit already-implemented/no-change route.
No ship, main-PC deployment or DESIGN.md edit is required for this no-change completion. Seed generation, storage key, game and fixture are unchanged.
Watch: spend self-revive, then have the partner pick you up repeatedly using a full 3.2-second hold; repeat with the player roles reversed.
SYNCED existing packet t:rev; no new sync change or linked-review request.
