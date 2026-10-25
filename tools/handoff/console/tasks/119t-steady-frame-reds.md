# 119t-steady-frame-reds : two checks newly failing on v34.83 pass again (a frozen raid frame redraws differently)
Queue (coordinator 10-25 19:20): party blocker, before any screen polish job.
effort: medium

Source: the spare PC full test run corpus-1025-1526 on v34.83 (a475d2a1), failing 16, new 15; 13 of them are the same as corpus-1025-1332 and sit in jobs 117r, 118r, 119r and 119s. Read it with: git fetch origin spare-results; git show origin/spare-results:spare/DESKTOP-82BKOP4/corpus/corpus-1025-1526.txt
Why now: the stable build is still v29.09 (10-18). The party copy on Fri 10/30 is the newest build that passed a full run, so these reds are the party blocker.
Your FAIL lines (red on the spare PC run only, not on the VM run of the same build, so something in the redraw depends on time, the machine or its speed):
- v9.07 a noise you cannot see leaves a ring on the ground, and one you can see does not -> "two identical redraws differ, so no pixel measurement here means anything".
- v33.51 cw-pixkit (86a): the pixel look row, pinned off in the fixture -> "the frozen raid frame is not steady, so it cannot be compared; with the pixel look off the raid frame differs from the frame with every pixel path stubbed off".
Suspects, newest first: v34.83 and v34.82 (auto resolution chasing a frame cap, the VSYNC estimate and frame caps: does drsTick or frameCapSkip change the render scale between two redraws of a frozen frame?), v34.80 (flashes and machine eyes light the ground in their own colour), v34.76 (glow pools), v34.74 (machine smoke, sparks and a stuttering eye: anything read from performance.now or Math.random in the render pass makes two redraws differ). A redraw of a frozen frame must be identical: if a render effect animates from the clock, make it read the frozen game clock, not the wall clock.

Steps:
1. Run each check alone on the current build; drop any that pass and say so. Also run each 5 times in a row, since the spare PC saw it and the VM did not.
2. For each left, say which of two it is: a. the game really broke: fix the game in an mk script; b. the check went blind or the change was on purpose and within his orders: re-aim it so it proves the claim again. Never loosen a check until it passes.
3. One batch per cause, through preflight.sh and shipq.sh as usual. Note the cause per check in the ship's DESIGN.md section.
Rules: player text all lower case, short; rendering and HUD only; no change to the storage key salvagerun:profile. Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
TASK DONE when every check here passes on the drafted build or is fixed in a shipped batch; TASK PARTIAL with the ones left and why.
