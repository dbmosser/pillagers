
--- codex run 2026-10-20 13:28 ---
2026-10-20: Prepared cw-cx-flashdefault for lane preflight and shipping. Read binding answers 2.61 and 3.15. No pictures requested by this task.

Settings live in P.gameOpts as row indexes; saveProfile also writes CFG into P.cfg. There is no change to salvagerun:profile or any other storage key. The new profile literal stores gameOpts.flashRed=1, and the Settings row defaults to on. On loading an existing profile with no row choice, it gets an explicit 0; an existing saved CFG value of 1 is preserved as 1. Explicit row choices stay as saved. Storing the new profile choice prevents a new save from being mistaken for an older save at its next load.

Reduced flashing uses one per-raid 334 ms visual limiter shared by flash(), barrage blooms and local/peer lightning. Lightning still sets its original gameplay timer; suppressed bolts only lose the drawn sheet and fog lift. Damage, bot sight, sound, shake and timing are unchanged. Barrage radius draws are still taken when a bloom is suppressed, preserving the seeded stream. The existing softer light, muzzle and spark settings remain.

Both demo sandbox roles start with reduced flashing on, including when the career save chose off or tuned the dial. The sandbox restores the career choice when leaving.

New gate check stages the real profile loader, both demo roles, ten light requests in one second, ten lightning requests with actual full-screen sheet draw counting, off behavior, and the shared blast/lightning/barrage budget. Control fails on v32.90 at the new-profile default assertion. Browser execution remains the lane's work.

Fixture retarget: 26.50 accepts either row default and tests cycling relative to that default. It retains all original brightness, spark, muzzle and save checks. Retarget runs 26.50 and 27.67 before shipping; it is valid on the current default-off build as well as the new build.

Local validation passed: mk prints written; all 11 edit anchors match exactly once; patched game JavaScript and the new check parse; all three fixture anchors match once; mk script is ASCII. No tracked game or fixture file was edited.

TV watch: blasts and lightning may look softer on his TVs. During rapid blasts or storm effects, bright lights should be spaced out with reduced flashing on. Off should look and repeat as before. Confirm that lightning still lands and sounds normally, and that leaving the demo returns to the career choice.


--- codex run 2026-10-20 13:36 ---
2026-10-20 completion: lane shipped cw-cx-flashdefault as game v32.91 (50fb1362). Fixture retarget bcaac697 passed checks 26.50 and 27.67 on the v32.90 trial build before shipping. Verified the refreshed master contains the profile migration, new default, shared limiter, both lightning paths, barrage limiter and demo override. The shipped fixture includes the v32.91 regression check. No further changes or pictures are required by this task. TV watch remains: blasts and lightning may look softer with reduced flashing on.

