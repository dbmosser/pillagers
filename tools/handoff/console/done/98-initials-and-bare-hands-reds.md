98-initials-and-bare-hands-reds : two checks newly failing on v34.18 pass again (the arcade initials card, bare hands on the death screen), each fixed in the game or re-aimed
Queue (coordinator 10-24 09:20): split from 87r so three helpers work the newest run's nine new reds at once; his 10-24 order to spend the week before the reset.
effort: medium

Source: tools/handoff/stable-status.txt (checked 10-24 08:25), run corpus-1023-2304 (v34.18, failing 14, new 9). The run file is in the stable picker's scratch folder:
C:/Users/VMOCT2~1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/corpus-1023-2304.txt
Your two FAIL lines:
- v23.45 arcade22, his yes 2026-10-11: initials at the first qualifying extraction -> "no initials card drawn at the extraction; the card does not draw the letters QWB". v34.17 (job 96: the demo's easy question after the map, and the initials card names the board as it is) changed this card: check that first. If the card no longer opens for a qualifying extraction, that is a real break of his order (a player who earns a board place must get the card).
- v9.55 bare hands are not drawn as a gun, and one word for one outcome on the death screen -> "control: a pistol drawn as an item and drawn as a gun differ in 451 pixels, so guns no longer route to the gun painter and this comparison proves nothing". The control fails, not the claim: find where guns are painted now (the pixel art pass 86a to 86j moved item drawing) and re-aim the control so it proves the claim again.

Steps:
1. Run each check alone on the current build; drop any that pass.
2. For each left, say which of two it is: a. the game really broke: fix the game in an mk script; b. the check went blind: re-aim it. Never loosen a check until it passes.
3. One batch per cause, through preflight.sh and shipq.sh as usual; take a picture of the initials card (tools/uishots.ps1) and look at it. Note the cause per check in the ship's DESIGN.md section.

TASK DONE when both pass on the drafted build or are fixed in a shipped batch; TASK PARTIAL with the ones left and why.
