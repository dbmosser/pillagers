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
ADDED 10-28 04:00 (sorted from run corpus-1028-0157 on v35.58, the stable triage commit after 35fcbf4d8), 4 more to retarget the same way:
- 34.26: concealed and in cover are state icons with a brief word on the vitals now (v35.49), at the vitals scale (24 px at 1080p); the check wants the old 19 px chip.
- 27.35: the feed zone is 28 percent of the width since v35.53 (cw-hudsize, 20 px feed text); the check allows a quarter at most. Retarget to 28 percent and keep the controls list inside 47 percent.
- 13.32: the loaner hint draws on the answer line under the character since v35.52 (cw-answerline), not in the feed; read the answer line (G.ans) for "equip your own gun".
- 16.44: kid mode is applied through _hitMul in damagePlayer since v35.54 (o-120e); replace the source-text read for "amt*=netKidMul()" with a real hit on player 2 that proves the cut (check the damage taken, not the text).
ADDED 10-28 07:50 (sorted from run corpus-1028-0442 on v35.65), 3 more to retarget the same way:
- 31.50: it finds the score and clock plate by y0 at 1 or less; v35.64 (cw-cx-hudtvread) insets the plate 16 px (times the hud zoom) from the top edge. Find it by being centred at the top and holding the SCORE label, keep the label-overlap asserts.
- 30.96: it wants the plate hung from the top edge (y at or under 0); it is inset since v35.64. Keep the centred and covers-the-clock-row asserts, expect y near 16 times the zoom.
- 27.22: the empty gun key ghost is 0.1215 alpha in a raid since v35.64 (GHOST_A times 0.45, empty belt slots quieter for tv); allow that value and keep the carried gun opaque and the dragged-off key returning to its ghost.
