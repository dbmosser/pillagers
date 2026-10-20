o-14-daily-save-backup : an automatic daily copy of the player's save, with a way back in Settings (planner draft 2026-10-20)
effort: medium

Source: memory pillagers-answers-third50-2026-10-12.md, Tech (binding): "An automatic daily save backup."
Not done (planner, 10-20): the only side keys of the profile are SKEY+':prerestore' (dark_raiders.html 4369), ':unreadable' (5326) and
':precrash' (49483). There is no dated or rolling copy. git log shows only v3.79 (manual backup to a file) and v12.85 (a restore can be
undone). The "daily backups" in tools/nightly.sh are the itch and GitHub pushes, not player saves.

1. On the first load of each day, copy the save to its own side key, keeping 3 rolling days (for example slotKey(n)+':daily1' to
   ':daily3', or keys with the date; the oldest is dropped). Each save slot keeps its own.
2. NEVER rename, rewrite or move salvagerun:profile or any slot's main key (CLAUDE.md rule 5).
3. Never copy from: the demo sandbox profile, a ?netslot window, or a player 2 window's save (netP2Key slots). A player 2 or demo profile
   must never land on his save.
4. Check the size before writing: if the copy would not fit in localStorage, skip it quietly (never throw), and note it in the run report.
5. A way back, in the EXISTING restore rows of Settings (about 67972-68060; one control per job, no new menu): the list offers the daily
   copies ("yesterday", "2 days ago"), using the same restore path and its undo (:prerestore).
Checks (control must FAIL on v32.90): a new day writes exactly one copy; a second load the same day writes none; the 4th day drops the
oldest; salvagerun:profile is byte-identical before and after; a player 2 window and the demo write nothing; restoring a daily copy
works and can be undone.
Picture: shots.txt with the Settings screen that holds the restore rows.
Storage limit (coordinator, 10-20): the browser gives each site about 5 MB. Measure the real profile size first (a long career save) and write it in
notes. Three copies must never push the main save out: if a copy will not fit, or setItem throws a quota error, drop the oldest copy and
try once more, then skip the backup quietly (the main save always wins). A check must cover the quota error path.
It is a FEATURE: ship by Mon 10/26. Party risk: low (a side key only).

TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
