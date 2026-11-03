# What uses the processor on the spare PC during a full run

Measured 2026-11-03, 03:53 to 04:01, on DESKTOP-82BKOP4 (i5-7600K, 4 cores, 4 threads). Measured only; nothing on the PC was changed.

## Answer

- **The "100% busy" figure was wrong.** It was a bug in my script: it printed 100 whatever the machine was doing. Real figures are below.
- **The rest is test work.** With the crash robot running it takes 57% of the machine, more than twice the full run's 26%. During a gate job with no robot, the gate job's Chrome takes 31%.
- **There is nothing to close on this PC.** Game launchers and helper programs add up to about 0.5%. I left them alone. Defender takes about 2%.
- **There is real waste: the robot's restarts.** Gate jobs arrive so often that the robot keeps being started and killed. It has not finished a clean raid in this run. A small fix is attached for the CEO to land.
- **None of this explains why full runs doubled.** The full run gets nearly a whole core in both readings. More free processor will not bring back 90 minutes.

## Readings

Percent of all 4 threads, from the kernel's per-process totals (`cpu-nt.ps1`).

| | Robot on, no gate job (03:53, 199 s) | Gate job on, no robot (03:59, 122 s) |
|---|---|---|
| **Machine busy** | **94.1** | **70.3** |
| Full run's Chrome (port 9344) | 25.9 | 28.2 |
| Crash robot's Chrome (9331) | 57.1 | 0 |
| Gate job's Chrome (9347) | 0 | 30.7 |
| Defender | 2.4 | 1.7 |
| Windows kernel (System) | 0.6 | 2.7 |
| PowerShell (runner and its helpers) | 1.4 | 1.5 |
| The Claude app | 0.9 | 0.9 |
| Everything else | 3.6 | 2.0 |
| Ended between looks, not attributed | 2.2 | 2.6 |

- **One core is the limit for the full run.** Its working renderer got 21.9 of a possible 25 with the robot on, and 25.1 with the gate job on. So the robot slows it by about 12% while the robot is up, and this gate job did not slow it at all.
- **The robot's load:** its graphics process alone used 24.0, a whole core. Its two game windows used 16.9 and 15.5. Size 1920x1080.
- **Other limits are not the problem:** disk was 97% or more idle and about 20 GB of memory was free in the earlier readings at 03:37 and 03:44. The clock read 100% of its maximum at 03:44.
- **These are two short readings from today.** They say nothing direct about how the machine behaved on 10-30.

## The waste: robot restarts

From `runner.log` and `fuzz.log`.

| Full run | Gate jobs | Robot starts | Raids | Clean raids | Robot problems |
|---|---|---|---|---|---|
| 10-30 14:45 (90 min) | 0 | 2 | 18 | 18 | 1 |
| 11-02 00:48 (215 min) | 0 | 5 | 55 | 37 | 23 |
| 11-02 21:52 (223 min, 27 of them paused) | 46 | 17 | 10 | 1 | 9 |
| 11-03 01:35 (141 min so far, at check 1994 of 2874) | 39 | 13 | 7 | 0 | 8 |

- A gate job was running for 111 of those last 141 minutes.
- 28 of the 33 gaps between gate jobs in this run were 0 to 1 minute. A raid needs 5 minutes.
- The log shows the robot started and killed within the same minute (01:43).
- **Not checked:** whether those 8 problems are false, and whether they count against the build in `tools/stable.mjs`. The runner's own notes say robot problems have blocked stable before, so the CEO should look.

## The fix, for the CEO to land

`runner-quiet.diff`: the robot does not start within 5 minutes of a gate job ending. Five lines change. Master's runner blob is affb21b2; the result is 6ea27db2.

- **Effect on these two runs:** robot starts drop from 13 to 1 and from 17 to 2. A 10-minute rule gives the same counts for these runs, so I kept the shorter one and the robot comes back sooner.
- **Gain is modest:** in this run the robot was up for at most 30 of 141 minutes, so the full run gains about 3%. The main gain is no more wasted Chrome starts and no more problems from cut-short raids.
- **Cost:** while gate jobs keep flowing, the build gets no robot evidence. It is getting no clean raids today anyway.
- **Idle mode on the main PC is untouched:** the changed line is in the `else` of `if($Idle)`, and gate jobs never run in idle mode.
- **Proof:** `quiet-check.ps1` runs the real line from the patched runner with only its calls stubbed. 16 checks, 0 wrong: parses in PowerShell 5.1, ASCII, 5 lines differ, and the timing cases (299 s waits, 300 s starts, fresh runner starts, gate job running waits, robot already running, someone at the PC). It has not run on a live runner.

## Why full runs doubled: still open

10-30 14:45 took 90 minutes and 11-02 00:48 took 215. What did not change between them:

- **Robots:** one robot in both, at 1920x1080.
- **Gate jobs:** none in either.
- **Number of checks:** 2,799 and 2,873, 3% more.
- **The game's own work per frame:** the robot's median was 6.75 ms and then 6.25 ms.

So the time is going inside the checks, on one core. The robot's problem count also rose from 1 to 23 over the same two runs, which points the same way. The slice-by-slice comparison goes to the CEO when this run ends.

## Bigger option, not tested

The full run uses one thread on a 4-core machine. Running two slices side by side could cut its time a lot, more than anything above. It needs changes to the runner and `corpus-slices.sh`, and I do not know whether the checks can safely share the PC that way. This is the CEO's call.

## Where this file is

You asked for `tools/handoff/spare/`. That folder is on master, and this PC's setup rules say no commits to the game, so this is in `spare-results` instead. The raw readings stay on the spare PC because they list the programs on a PC the owner's son uses, and this repository is public.
