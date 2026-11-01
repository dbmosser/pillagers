# 261-check-3490-tracer-height : check 34.90 fails on the tracer height, not on an unsteady redraw
Queue (coordinator 11-01, split out of job 241). LOW, tests first; no player change unless the check proves a real bug.
effort: low to medium (Sonnet high; edit tools/mkfixture.ps1 through fixq only; grep the id, read about 150 lines around it)

What: once job 241 (fixture commit a673cf901, cw-steadyraster) made frozen redraws pixel exact, check 34.90 (cw-thirdsize, his
10-25 note on figure size) still fails, on the VM alone and in the VM full runs corpus-1101-0634 and corpus-1101-1057, with
"the survivor tracer is drawn 19.1 over the round, his flash 21.6 up". It is a lineTo capture of where the tracer starts, not a
pixel compare, so the old "1 unsteady" text was hiding it (the full run cuts each message at 400 characters).
Do: find which shipped change moved the muzzle or tracer start (git log -S on the tracer and muzzle code after v34.90; the figure
size and muzzle height changes since v36.xx are the first suspects), then either
  a) retarget 34.90 so it proves the same claim (the tracer leaves from the gun at the new figure size) on the current build, or
  b) if the tracer really starts off the gun on screen, stop and write a game job for it (it would be a visible bug).
Then delete the v34.90 line from tools/handoff/stable-known-red.txt (coordinator step if that file is not on your write list).
Rules: tests only unless b; seed 4242 fingerprint unchanged; never touch the pickup stack, loot sounds or loot rows.
TASK DONE when 34.90 passes on the current build (runchk.sh) and its known-red line is gone, or a game job is written for b.
