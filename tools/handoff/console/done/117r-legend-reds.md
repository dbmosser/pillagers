# 117r-legend-reds : three checks newly failing on v34.83 pass again (the raid keys list: its width and two text collisions)
Queue (coordinator 10-25 17:35): party blocker, before any screen polish job.
effort: medium

Source: the VM full test run corpus-1025-1332 on v34.83 (97a61533a), failing 14, new 13 (the stable picker, bash tools/stable.sh --dry, counts it). The file is in the coordinator scratchpad: C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/corpus-1025-1332.txt
Why now: the stable build is still v29.09 (10-18). The party copy on Fri 10/30 is the newest build that passed a full run, so these reds are the party blocker. Four jobs (117r, 118r, 119r, 119s) split them so four helpers work at once. Builds between v34.69 and v34.83 shipped today (v34.70 to v34.83): git log --since=2026-10-25 shows which job touched each area.
Your FAIL lines:
- v8.91 the three in-raid panels are twice the size, at every resolution, and never touch -> "legend at 1920x1080 is 267 wide, smaller than it was before v8.91 grew it" (356 at 1440p, 534 at 4K).
- v18.60 the compact legend names the keys as set and never runs a key into its word -> "CTRL / C (ends at 58) runs into crouch (starts at 56)". A real text collision: fix the game (his photo notes of 10-25 asked for no text collisions).
- v17.76 the raid controls legend: its two columns no longer collide -> "TACTICAL BELT runs into the next column (152 past 113)". Same kind: a real collision, fix the game.
Likely from v34.78 (job 121, the career controls list as a clean panel and the folded chip) or the 112r fold (his rs-1: keys mid-bottom left, folded). If the narrower panel is that job's ordered look, re-aim v8.91 to the new panel; the two collisions are bugs either way.

Steps:
1. Run each check alone on the current build; drop any that pass and say so.
2. For each left, say which of two it is: a. the game really broke: fix the game in an mk script; b. the check went blind or the change was on purpose and within his orders: re-aim it so it proves the claim again. Never loosen a check until it passes.
3. One batch per cause, through preflight.sh and shipq.sh as usual. Take a picture of any screen you change (tools/uishots.ps1) and look at it. Note the cause per check in the ship's DESIGN.md section.
Rules: player text all lower case, short; rendering and HUD only unless the check is about input or saves; no change to the storage key salvagerun:profile. Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
TASK DONE when every check here passes on the drafted build or is fixed in a shipped batch; TASK PARTIAL with the ones left and why.
