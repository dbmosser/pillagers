97-hub-belt-and-window-reds : three checks newly failing on v34.18 pass again (Undercroft belt, gambler window, experimental page), each fixed in the game or re-aimed
Queue (coordinator 10-24 09:20): split from 87r so three helpers work the newest run's nine new reds at once; his 10-24 order to spend the week before the reset.
effort: medium

Source: tools/handoff/stable-status.txt (checked 10-24 08:25), run corpus-1023-2304 (v34.18, failing 14, new 9). The run file is in the stable picker's scratch folder:
C:/Users/VMOCT2~1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/corpus-1023-2304.txt
Your three FAIL lines:
- v21.42 the Undercroft floor belt is centred on the screen like the key line above it -> "with the Undercroft backpack open the belt is centred at x 728, -213 px off the middle, under a backpack that is centred". v34.07 and v34.08 (hub backpack readability, hub backpack detail and belt) changed this screen.
- v18.78 text in the framed windows stays inside the frame -> "gamblemodal text lines are capped at 1060px, its list at none".
- v33.33 the four experimental group names show with a real height on the experimental page -> "group raid is 0px tall; group combat is 0px tall; group events is 0px tall; group extras is 0px tall".

Steps:
1. Run each check alone on the current build; drop any that pass.
2. For each left, find the ship that broke it (git log since v34.03, the last run where it passed) and say which of two it is:
   a. the game really broke (a player sees the belt off centre, a gambler line running past the frame, an empty group name): fix the game in an mk script;
   b. the check went blind or reads an old layout: re-aim it at what the screen draws now. Never loosen a check until it passes.
3. One batch per cause, through preflight.sh and shipq.sh as usual; take pictures (tools/uishots.ps1) of the Undercroft backpack and the gambler window and look at them. Note the cause per check in the ship's DESIGN.md section.

TASK DONE when the three pass on the drafted build or are fixed in a shipped batch; TASK PARTIAL with the ones left and why.
