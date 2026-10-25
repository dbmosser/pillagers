# 118-easy-card-and-corner-reds : two checks newly failing on v34.69 pass again (key letters on the easy mode card, the top right corner list)
Queue (coordinator 10-25 09:25): party blocker, before any screen polish job.
effort: medium

Source: the main PC full test run corpus-1025-0741 on v34.69 (6da8c5943), failing 6, new 5; the stable picker (bash tools/stable.sh --dry) counts it. Read it with: git fetch origin spare-results; git show origin/spare-results:spare/JUL26/corpus/corpus-1025-0741.txt
Why now: the stable build is still v29.09 (10-18). The party copy on Fri 10/30 is the newest build that passed a full run, so these reds are the party blocker. Three jobs (117, 118, 119) split them so three helpers work at once.
Your FAIL lines:
- v30.75 the arcade and Undercroft prompts follow the last input device -> "with the keyboard in use the easy mode card reads 'want easy mode? | y  yes | n  no | 12', not Y yes and N no; with the pad in use ... 'a  yes | b  no', not A yes and B no". Likely v34.67 (job 114, the easy mode card as a solid dialog). The style guide's key cap rule: a key hint is a cap plus a word ("E  Loot"), so the cap letter stays upper case while the word is lower case. Fix the card, do not re-aim the check.
- v31.32 cw-trcol, his order 2026-10-18: everything in the right hand upper corner in a vertical 1 by 1 list, all the same size -> "career 1080p and 4k: expected compact wallet, minimap and run info plates; found 2; the demo 1080p: found 1". Likely v34.69 (job 116, one corner panel look). If wallet, minimap and run info still read as a vertical list of same-size items inside the one panel, re-aim the check to count those items; if one of them is gone or a different size, fix the game to his order.

Steps:
1. Run each check alone on the current build; drop any that pass and say so.
2. For each left, say which of two it is: a. the game really broke: fix the game in an mk script; b. the check went blind or the change was on purpose and within his orders: re-aim it so it proves the claim again. Never loosen a check until it passes.
3. One batch per cause, through preflight.sh and shipq.sh as usual. Take a picture of any screen you change (tools/uishots.ps1) and look at it. Note the cause per check in the ship's DESIGN.md section.
Rules: player text all lower case, short; rendering and HUD only unless the check is about input; no change to saves or the storage key salvagerun:profile.
TASK DONE when every check here passes on the drafted build or is fixed in a shipped batch; TASK PARTIAL with the ones left and why.
