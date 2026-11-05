# Player 2's robot window draws on the processor by mistake (one-line fix)

Apply `p2-card.diff` on master. It changes only `tools/mkfixture.ps1`: base blob 027c3222, result blob e0dd42f5. Master is still 9e37c70e. The game isn't touched.

## The fault

`a673cf90` (11-01 10:26, job 241, cw-steadyraster) puts every 2D canvas on the processor on a check page, and it picks a check page by `if(location.search)`. Its comment says robots open the page with no query. That's true of player 1, but player 2's window opens with `?p2=1&mode=coop&pair=..&arc=1`.

Read from the live robot on 11-04:

| Window | Query | Patch active | `willReadFrequently` on its canvases |
|---|---|---|---|
| Player 1 | none | no | false |
| Player 2 | `?p2=1&mode=coop&pair=..&arc=1` | yes | true on all of them |

So since then the robot's second window hasn't drawn the way a player's does, on either PC.

## When it started, on both PCs

Two-window raids of a minute or more, median per build, from each PC's `fuzz.log`:

| PC | Build | Player 2 fps | Player 2 work per frame |
|---|---|---|---|
| JUL26 | v36.95 | 59 | 3.25 ms |
| JUL26 | v37.05 | 55 | 6.75 ms |
| JUL26 | v37.30 | 52 | 6.25 ms |
| This PC | v36.66 | 78 | 5.25 ms |
| This PC | v37.26 | 31 | 11.25 ms |
| This PC | v37.48 | 35 | 10.25 ms |

Player 1's work per frame didn't move on either PC. This PC's log has no two-window raids between v36.69 and v37.26, because it was paused. JUL26 narrows it to v36.96 to v37.05, and `a673cf90` is inside that range.

## The test

A private robot on port 9339, with its own log folder and served copy, on the frozen v37.48 copy with only this one line changed. Rounds of 7 minutes went as now, fixed, as now, fixed. All raids had two windows and ran 100 s. The live robot was held at 30 fps beside it. Raid by raid: `rounds.txt`.

| | Player 2 on the processor (as now) | Player 2 on the card (fixed) |
|---|---|---|
| Two-window raids | 5 | 6 |
| Player 2 fps, median and range | 17 (1 to 34) | 67 (46 to 74) |
| Player 2 work per frame, median | 13.25 ms | 6.25 ms |
| Raids under 5 actions a second | 3 of 5, one of them a hang | 0 of 6, lowest 8.0 |
| First raid after a browser start | 3.3 a second, and a hang | 30.2 and 18.0 a second |
| Page processes, median | 1.77 cores | 1.15 cores |
| Graphics process, median | 1.08 cores | 1.23 cores, for more frames |

The fix was read back in rounds 2 and 4: player 2's canvases were `false` and the patch wasn't active.

- The fixed copy's text is what the diff's `$steady` string produces. I evaluated that one line from the patched script and found it in the tested copy. The patched script parses in PowerShell 5.1, and the diff is ASCII.
- Check pages are unchanged: `?sliceN=1` and `?kzN=1` still get the processor. A window with `p2=1` anywhere in its query doesn't.

## What it may explain

These fit, but aren't proven:

- **Robot problems during full runs.** Before the change: 57 of 532 two-window raids, 10-27 to 10-30 (11%). After it: 48 of 92, 11-02 and 11-03 (52%).
- **The first raid after a restart having a problem 21 of 24 times.** That raid builds the picture stores, and player 2's are now drawn on the processor.
- **The latest stable build being v36.55,** which is from before this change.

It doesn't explain all of the slower full runs. Check pages moved to the processor on purpose in the same commit, and I'm timing that separately. Some of the slowness was also my own jobs and the second runner.

## Not proven

- It hasn't been through a real full run. Two robots ran here, and the machine was at 100% in many raids.
- 11 raids of 100 s is a small test, though the frame rate and work per frame are clear in every round.
- The robot will use more frames after this fix, about 130 a second across the two windows. The frame cap is still a separate choice.

## Ignore this robot record

The live robot's raid at 18:56:12 on 11-04 (a hang) ended while this test ran two robots side by side. It was held at 30 fps at the time, so the cap doesn't protect against that much load.
