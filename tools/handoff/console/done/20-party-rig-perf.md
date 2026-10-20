# 20-party-rig-perf : frame rate in the 2-player demo (his round 2 answers; TRIMMED 2026-10-19)

TRIMMED 2026-10-19 by his order 2026-10-19: "'party' and 'demo' need to be synonymous --- you are doing too much to try to make the party demo polished. for the party demo, we need to just open the game on the localhost and then click the demo -- don't overengineer this". The party is the normal demo, opened from the title at localhost. No launcher, no operator card, no corner dot, no special rig test. What is left is plain frame rate, which guests feel (stutter is the worst problem on his list, Q27).

Two windows on this PC, each full screen on a 4K TV at 120 or 144 Hz (his 2.11 note).
- 2.43 a: janky means under 60 frames a second for more than a few seconds. Measure the 2-player demo (two windows, 4K) against that and fix the worst causes.
- 2.44 b: the quality ladder may drop effects, but never picture sharpness below 75 percent.
- 2.11 a and 2.57: each window draws at its full size, capped at the screen's refresh rate. Confirm with a check; do not rebuild it if it is already so.
- 2.27 b: measure player 2's extra delay over player 1. Only if it is over 50 ms, fix it.
- CUT: the corner dot (2.45 a), the launcher (2.13 a), the operator self-check (2.18 b), the 3-hour rig run (2.33 a; the overnight robots already play 2-player demo raids), and "same drawing while nobody plays" (2.19 a).

## How
- His answers are in tools/handoff/q-round3/answers.md (the decoded list, then "How I read them"). He said they are guidance: if something in the game makes one wrong, do the sensible thing and write down why.
- Read the code first. Some of these are already in the game: confirm each one with a check, and do not rebuild it.
- Ship in small pieces, one ship per item or a few related ones. Each ship needs a check that fails on the old build, and the fingerprint must hold. For 2-player items, it is done only when you have seen it work in both windows, with a picture from each (his 2.86 a).
- Write in plain language, with no explaining sentences on screen. All lower case.
