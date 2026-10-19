# 20-party-rig-perf : the two-TV rig and frame rate (his round 2 answers)

The rig: both screens are 4K at 120 or 144 Hz (his 2.11 note).
- 2.11 a and 2.57: each window draws at the TV's full size, capped at the TV's refresh rate (120 or 144).
- 2.44 b: the quality ladder may drop effects, but never picture sharpness below 75 percent.
- 2.43 a: janky means under 60 frames a second for more than a few seconds. Measure the two-window rig against that.
- 2.45 a: each window shows a tiny coloured dot (green fine, yellow slow, red struggling) in a corner, always.
- 2.19 a: while nobody is playing, the windows draw the same as in a raid.
- 2.13 a: the launcher puts player 1's window in front only at the start.
- 2.18 b: the operator card runs a quick self-check: pad found, both windows linked, sound on, frame rate fine.
- 2.27 b: player 2 may get no more than 50 ms (about 3 frames) of extra delay over player 1. Measure it first. If it is over, add prediction to player 2's own movement.
- 2.33 a: before the rehearsal (Wed 10/28, 2.31 c), a 3-hour non-stop run of scripted 2-player games on the two-window rig. Any slowdown or crash is a blocker. Write it so the runner can start it, and say in your notes how.

## How
- His answers are in tools/handoff/q-round3/answers.md (the decoded list, then "How I read them"). He said they are guidance: if something in the game makes one wrong, do the sensible thing and write down why.
- Read the code first. Some of these are already in the game: confirm each one with a check, and do not rebuild it.
- Ship in small pieces, one ship per item or a few related ones. Each ship needs a check that fails on the old build, and the fingerprint must hold. For 2-player items, it is done only when you have seen it work in both windows, with a picture from each (his 2.86 a).
- Write in plain language, with no explaining sentences on screen. All lower case.
