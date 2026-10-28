RETARGET 12 OUT-OF-DATE CHECKS NOW PARKED IN stable-known-red.txt (CEO 10-28 00:10; sorted by commit 4a5be82f7). Low priority, after the party is fine.
The quiet hud (v35.30 to v35.37) changed these on purpose, so each check now tests the old screen. Parked in tools/handoff/stable-known-red.txt so stable is not blocked; retarget each through fixq (lock.sh, edit tools/mkfixture.ps1, HELD=1 fixq.sh "retarget NN.NN: reason", unlock.sh) so it tests the new behaviour, then remove its known-red line.
- 9.09: aim at the pillager board, not the first minimise glyph (contracts card folds, v35.36).
- 9.66 and 12.80: the contracts card folds to 300x38 at rest; the note line shows only while the run info card is open (v35.36 change 3).
- 12.74: the "need $N" refusal goes to the left feed, not g.msg (v35.30).
- 13.08 and 32.24: the belt caption and its fire chip were deleted on purpose (v35.36 change 4); retarget or retire.
- 31.38 and 31.17: the stamina bar draws only below full stamina.
- 18.41: the posture word shows only when crouched or down. 18.49: the HIDDEN chip is a status icon now (cw-quiettext).
- 25.66: the boss-spotted alert replaces the location tag (one alert at a time at top centre); confirm with a probe first.
- 15.79: after an extraction out word a late position word no longer redraws the teammate (v35.37 cw-xsink, job 189).
TASK DONE when all 12 pass on the current build and their known-red lines are gone, or PARTIAL naming any that should be retired instead.
ADDED 10-28 02:00 (CEO; sorted from run corpus-1027-2310 by commit 35fcbf4d8), 5 more to retarget the same way:
- 16.43 and 16.46: they look for pinging only through NET.on, but pings work solo since v35.41 (task 139).
- 23.02: the ping label is a lower case plate since v35.43 (cw-cx-pingread); the check wants CRIER in capitals.
- 23.10: a finished goal now waits 4 s without a shot (v35.44 cw-msgroute); one line shows at once, the second 2.5 s later.
- 32.69: the stash item line is a fixed 160px box that always shows, since v35.42 (his stash hover order).
