# 119-backpack-size-and-crowd-reds : two checks newly failing on v34.69 pass again (the backpack's 1080p size, builds in the Undercroft crowd)
Queue (coordinator 10-25 09:25): party blocker, before any screen polish job.
effort: medium

Source: the main PC full test run corpus-1025-0741 on v34.69 (6da8c5943), failing 6, new 5; the stable picker (bash tools/stable.sh --dry) counts it. Read it with: git fetch origin spare-results; git show origin/spare-results:spare/JUL26/corpus/corpus-1025-0741.txt
Why now: the stable build is still v29.09 (10-18). The party copy on Fri 10/30 is the newest build that passed a full run, so these reds are the party blocker. Three jobs (117, 118, 119) split them so three helpers work at once.
Your FAIL lines:
- v9.13 the backpack follows the monitor instead of staying its 1080p size -> "control: the 1080p panel changed to 862x596, it was 830x477". v34.65 and v34.66 (job 115) made the raid backpack tiles bigger on purpose, so the control's fixed size is likely out of date: re-aim the control to the new 1080p size and keep the claim (the panel scales with the monitor) tested at 1440p and 4K.
- v20.09 the Undercroft crowd has builds: in 300 rolled looks there are Broad and Curved people -> "no Broad or Curved in 300 crowd looks ({\"none\":300})". Not red on the 10-24 runs (v34.53), so something between v34.53 and v34.69 broke it, or the fixture now pins the build. Find which (git log on the crowd look roll, grep tools/mkfixture.ps1 for build overrides). A crowd with no builds is a real break of his 10-08 answer (BUILD changes the body): fix the game unless the fixture is the cause.

Steps:
1. Run each check alone on the current build; drop any that pass and say so.
2. For each left, say which of two it is: a. the game really broke: fix the game in an mk script; b. the check went blind or the change was on purpose and within his orders: re-aim it so it proves the claim again. Never loosen a check until it passes.
3. One batch per cause, through preflight.sh and shipq.sh as usual. Take a picture of any screen you change (tools/uishots.ps1) and look at it. Note the cause per check in the ship's DESIGN.md section.
Rules: player text all lower case, short; rendering and HUD only unless the check is about input; no change to saves or the storage key salvagerun:profile.
TASK DONE when every check here passes on the drafted build or is fixed in a shipped batch; TASK PARTIAL with the ones left and why.
