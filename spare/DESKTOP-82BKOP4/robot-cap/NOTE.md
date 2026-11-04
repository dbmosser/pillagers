**11-04 update: please hold this diff.** Later tests found the cap barely changes how long checks take and the robot evidence is thin, and the 05:10 run quoted below was not clean. See `../slow-checks/NOTE.md`.

# Robot frame cap on the spare PC: 30 frames a second

Apply `robot-cap.diff` on master. Result: `tools/fuzz.ps1` blob 24ac2f31, `tools/spare/spare-runner.ps1` blob 0ea34c02. Measured and tested on DESKTOP-82BKOP4, 11-03. Not yet proven in a full run.

It applies with `runner-stray.diff` and `runner-onecopy.diff`, first or last, and both orders give runner blob a6de0df7.

## The problem it goes after

`tools/stable.mjs` needs 0 robot problems on a build. This PC is the only robot now, and its problems are nearly all 2-window raids during a full run.

Raids with a problem, v37.26 to v37.48, this PC's `fuzz.log`:

| | During a full run | No full run |
|---|---|---|
| demo2p (two windows) | 87 of 164 | 5 of 117 |
| demo1 and career (one window) | 0 of 41 | 0 of 32 |

- The clean 05:10 run on v37.48 had problems in 19 of its 31 demo2p raids and in none of its other 9. In the 15 raids after it with no full run, 0 had a problem.
- In that run, 15 of the 17 demo2p raids that ended during slices 0 to 720 had a problem, against 3 of 13 later. One more ended before the first slice and had a problem.
- A demo2p raid during that run logs about 7,500 events against about 9,300 with the robot alone.
- The kinds: page not answering for 10+ s, raid did not start with a CDP timeout, watchdog reload.

All of this fits a PC out of processor, but it isn't proof, and a real hang could be among them.

## The numbers

The robot alone, no full run, 09:46 to 10:31. Whole-machine busy, one reading every 5 s, only while player 1 was in a raid. The cap changed every 60 s, and the first 10 s after a change weren't counted. Script: `cap-strat.mjs`.

| Busy % | Cap off | Cap 60 | Cap 30 |
|---|---|---|---|
| Two windows | 78.9 (140 readings) | 65.3 (148) | 41.9 (133) |
| One window | 41.8 (11) | 31.3 (6) | 16.2 (17) |

- The middle half of the two-window readings: 73 to 84 off, 59 to 70 at 60, 38 to 46 at 30. They don't overlap.
- The one-window row is thin.
- The screen here runs at about 100 Hz. Player 1 drew about 93 frames a second uncapped; the main PC's robot drew 60.
- The full run took 26% in the 11-03 reading. Two windows uncapped plus that is over 100%. Capped at 60 it's about 91%, capped at 30 about 68%. That's adding separate readings, not a measurement.
- No raid in the trial had a problem (12 raids), but those had no full run beside them.

## What it does

- **`fuzz.ps1 -FpsCap N`** sets the game's own `CFG.fpsCap`, the Off/60/30 setting a player has, on every robot window and again at every poll. A new raid can rebuild CFG. It changes no game file. With 0, the default, `$DeadDrop` and `$POLLX` stay exactly as they are. The FUZZ START line gets `fpscap=N` only when N is over 0.
- **The runner** passes `-FpsCap 30` for the spare PC's 1080p robot and `-FpsCap 0` in idle mode and for a 4K robot. Idle mode on JUL26 gets one extra argument and no change in behaviour. `Running 'fuzz\.ps1.*-Port 9331(\s|$)'` still matches.
- 75 stays as the 2-player share (the 10-18 note in `fuzz.ps1` quotes the owner's order on it), and only the frame rate changes.

## What it weakens

1. **`gfx=` and `gfx2=` on this robot show the cap, 30.25 ms, not the game's frame gaps.** `work=` stays the measure, as in the VM's hidden browser. `spare-import.mjs` builds its frame table only from 3840x2160 robots, so it's unaffected.
2. **The robot no longer plays at a high frame rate on this PC, and this is the only robot running.** A bug that shows only at 100 frames a second would be missed by it. Player 2 was already at 30 to 40. If you want that coverage, the cap could apply only while a full run is on, at the price of more runner code.
3. **Work per drawn frame rises a little** at 30 (p50 about 7 ms against about 6). Work per second falls by about half or more.

Play doesn't look thinner: raids in the private test logged about 30 events a second, the same as 9,300 in 305 s.

## Proof so far

- **Private robot, 10:37 to 10:45, with this exact `fuzz.ps1`,** its own port (9339), log folder and served copy, the real runner's arguments plus `-P2Share 67 -RaidSec 100`. 5 raids, 4 of them demo2p (1 cut to 17 s by the time limit), 0 problems. `capcheck-fuzz.log` here.
  - `gfx=` p50 was 30.25 on both windows from the first raid.
  - Read back every 5 s: `CFG.fpsCap` was 30 in all 73 player 1 readings and all 63 player 2 readings taken in a raid. It was 0 only before the first hook, at the hub.
- **Clean-up checked:** the served copy, profile and Chrome are gone, and the live robot read 0 again after I held it at 30 during the test so the PC wasn't overloaded. Its two raids that ended meanwhile had 0 problems.
- The patched files parse in PowerShell. The diff applies on master and the result matches the draft.

## Not proven yet

Whether the problems go away during a full run. That can't be tested without one. At the next full run I'm holding the live robot at 30 through the same setting and will compare its demo2p raids with the 87 of 164 above and the 19 of 31 in the clean run.
