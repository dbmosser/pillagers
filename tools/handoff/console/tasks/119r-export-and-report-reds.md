# 119r-export-and-report-reds : three checks newly failing on v34.83 pass again (the flight recorder export throws, the demo run report posts nothing)
Queue (coordinator 10-25 17:35): party blocker, before any screen polish job.
effort: medium

Source: the VM full test run corpus-1025-1332 on v34.83 (97a61533a), failing 14, new 13 (the stable picker, bash tools/stable.sh --dry, counts it). The file is in the coordinator scratchpad: C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/corpus-1025-1332.txt
Why now: the stable build is still v29.09 (10-18). The party copy on Fri 10/30 is the newest build that passed a full run, so these reds are the party blocker. Four jobs (117r, 118r, 119r, 119s) split them so four helpers work at once. Builds between v34.69 and v34.83 shipped today (v34.70 to v34.83): git log --since=2026-10-25 shows which job touched each area.
Your FAIL lines:
- v34.51 cw-playdata (job 113) and v32.92 daily save copies both throw inside buildExport: "TypeError: Cannot read properties of undefined (reading toUpperCase)" at dark_raiders.html about line 57360, r.outcome.toUpperCase() in the P.log loop. A run record with no outcome crashes his flight recorder export, which is how his playtest notes reach us: fix the game. Guard the export line (String(r.outcome||'?')) AND find who writes a record with no outcome (commitRun about 33506 pushes any rec; check every caller and the checks that plant P.log rows).
- v32.93 cw-demoreport, his answer 66: a finished demo run posts one run report to the local collector tagged demo and its seat -> "ONE: the run end made 0 posts, not 1; TWO: player 2 report is not tagged seat p2 (0 posts)". The party run report: if the export now throws, the post may die with it, so fix the first item first and re-run. Job 133 (demo run report fields) builds on this path: do not start 133 work here.

Steps:
1. Run each check alone on the current build; drop any that pass and say so.
2. For each left, say which of two it is: a. the game really broke: fix the game in an mk script; b. the check went blind or the change was on purpose and within his orders: re-aim it so it proves the claim again. Never loosen a check until it passes.
3. One batch per cause, through preflight.sh and shipq.sh as usual. Take a picture of any screen you change (tools/uishots.ps1) and look at it. Note the cause per check in the ship's DESIGN.md section.
Rules: player text all lower case, short; rendering and HUD only unless the check is about input or saves; no change to the storage key salvagerun:profile. Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
TASK DONE when every check here passes on the drafted build or is fixed in a shipped batch; TASK PARTIAL with the ones left and why.
