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
