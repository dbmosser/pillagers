**11-04 update:** a later test of all 2,880 checks changed my view of the frame cap. It took 96 min with the robot at 30 fps against 114 uncapped, and the robot had no problems. See `../robot-cap/NOTE.md`.

# Full runs on the spare PC: where the time goes (measured 11-03 night, v37.48)

All of this ran in a private hidden browser, opened with `tools/cdp.ps1` as a full run opens one, with a fresh browser per slice, on port 9345. The live robot kept running. No game file changed, and nothing ran during a gate job or a pause.

## The main result

The first 720 checks took 30 minutes here against 65 in the 05:10 run, with the same fail count in every slice. So those checks don't need 65 minutes on this PC. Something else slows a real run, and I haven't found it.

| Slice | 05:10 run (s) | First private pass (s) | All private runs (s) |
|---|---|---|---|
| 0 | 1622 | 944 | one run |
| 120 | 368 | 216 | one run |
| 240 | 568 | 262 | one run |
| 360 | 394 | 136 | 11 runs 120 to 166, one 525 |
| 480 | 336 | 130 | 11 runs 117 to 135 |
| 600 | 626 | 89 | 11 runs 80 to 108 |
| Total, 0 to 720 | 3914 | 1777 | |

The rest of that run took about 92 minutes. It may have slow stretches of its own, so a run with no stall should take under about two hours, against 157 minutes from the first slice to the last. That's an estimate; the next full run is the real test.

## The slowest checks

`checks-0-720.txt` has all of them. 33 checks over 10 s took 1029 s of the 1471 s spent inside checks. The 10 slowest took 667 s.

| s | Check |
|---|---|
| 157 | #74 v9.34 calling the ship names the siege |
| 107 | #75 v9.35 the raid clock has an off position |
| 85 | #23 v8.82 neither sector starts you in the same place |
| 80 | #355 v34.89 cw-hudcorner |
| 50 | #65 v9.25 a pillager who was not fighting you fights back |
| 42 | #5 v8.73 holding sprint through exhaustion |
| 38 | #66 v9.26 a round that goes past a pillager |
| 38 | #214 v36.29 ADS preserves the aimed ground point |
| 36 | #69 v9.29 a called crew comes from different sides |
| 35 | #68 v9.28 a pillager who spots you calls his crew |

Most are old simulation checks early in the list.

## What I tested and ruled out

| Suspect | Test | Result |
|---|---|---|
| Robot frame rate, long checks | 11 slow checks repeated with cap off and at 30 (`ab-checks.mjs`) | Off is 1.07 times slower by median, 1.14 by sum |
| Robot frame rate, short checks | Slices 360, 480, 600, three times each way (`ab-slices.mjs`) | Off is 1.10 times slower across 360 checks |
| The run's old browser profile | Slices 600 and 360 on a copy of it | 80 s and 153 s |
| Below normal priority (runner and robot have it) | Same slices, browser started below normal | 93 s and 135 s |
| My own job from 05:31 to 06:28 | Same slices with that job running (`stray-mutants.ps1`, about 6 minutes of it) | 108 s and 120 s |
| The run's own script | Same slices through a copy of `corpus-slices.sh` (`scaffold-test.ps1`) | 91 s and 525 s, then slice 360 again at 166 s |

The priority test and the copied script give the same class as a real run, so those aren't simply fast because they differ from it. None of these reproduced the slow run.

## The stall

The 525 s slice ran from 00:03 to 00:12. In the same minutes the robot nearly stopped: one raid logged 6 events in 223 s and the next ended in a hang. It looks like the 05:41 to 06:26 stretch of the 05:10 run, which had raids with 0 to 6 events, `nostart` and `reload`. So the slow times look like both browsers stalling together, which points at the PC and not at the checks. That's one case tonight plus a resemblance, not proof.

- Windows' System and Application logs show no display driver reset, no thermal or power event and no crash in either stretch.
- The robot's browser also went away at 00:00:34 (`FUZZ ERROR Unable to connect`), during the replay of my job. I don't know why, and I can't rule that job out as the trigger.
- I now log load every 20 s on this PC, kept here because it names programs: processor, disk queue, paging, the top five programs.

## Robot frame cap: please hold the diff

The cap doesn't shorten runs. For the robot itself the direction is good but the numbers are thin. These are 2-window raids during these test loads:

| | Raids | With a problem | Events in full-length raids |
|---|---|---|---|
| Cap off | 10 | 3 | 7,456 to 8,583 |
| Cap 30 | 7 | 0 | 9,197 to 9,540 (about the robot-alone figure) |

3 of 10 against 0 of 7 could easily be chance (about 18%). My test load also never reproduced the 19 of 31 from the 05:10 run, so that figure may owe a lot to stalls and not to the frame rate. I withdraw my recommendation to land it as is. At the next full run I still hold the live robot at 30, in memory, and compare.

## Corrections to what I told you

1. **The 05:10 run wasn't clean.** I called it clean, but my own job ran from 05:31 to 06:28 and a second runner lived until 05:19. It isn't a baseline.
2. **Newer checks were the wrong suspect.** The slowest are mostly v8 and v9.
3. **"0 to 720" in my earlier table included slice 720.** That's why it read 74 minutes there. Without it, the figure is 65.

## Also found

- **A check that flips:** in slice 480, 4 of 11 runs failed 4 checks and the rest failed 3. Where I kept the names, the extra one is #484 v33.60 cw-cx-pixground (86b). The other three runs only kept the count. It could read as newly failing to `tools/stable.mjs`.
- **Tonight's tests added robot problems to v37.48's log:** 7 of 38 raids with a problem between 21:29 and 00:37. These are from my load. v37.48 was already out of stable because of its earlier problems.
- **The robot with nothing else running:** 99 two-window raids from 11:00 to 21:19 on 11-03, 0 problems.

## Next

The next full run gets the per-check timer, the busy log, the load log and the robot at 30. A person, a gate job or a full run stops any private test at once. I won't run heavy jobs of my own during a real run.
