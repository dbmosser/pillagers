# 119s-body-art-reds : four checks newly failing on v34.83 pass again (pixel body checks under the smooth look, the crowbar and jersey at the smaller pillager)
Queue (coordinator 10-25 17:35): party blocker, before any screen polish job.
effort: medium

Source: the VM full test run corpus-1025-1332 on v34.83 (97a61533a), failing 14, new 13 (the stable picker, bash tools/stable.sh --dry, counts it). The file is in the coordinator scratchpad: C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/corpus-1025-1332.txt
Why now: the stable build is still v29.09 (10-18). The party copy on Fri 10/30 is the newest build that passed a full run, so these reds are the party blocker. Four jobs (117r, 118r, 119r, 119s) split them so four helpers work at once. Builds between v34.69 and v34.83 shipped today (v34.70 to v34.83): git log --since=2026-10-25 shows which job touched each area.
Your FAIL lines:
- v33.84 cw-pixrole (86g) -> "the aim dots move with the build on the pixel body" and v33.58 cw-pixbody (86c) -> "fists was drawn in pixels but is still the vector body". Both claim "with the pixel look on": since v34.81 the smooth look is the default (his 10-25 order), so the checks must turn the pixel look on themselves and restore it after. Re-aim; the pixel look must still work when chosen.
- v26.06 his note: the crowbar swing is larger -> "the crowbar is drawn 27.4 long, under 1.5 times the old 20.6". v34.81 drew the pillager at 0.8 (his 10-25 note "pillager still too big"); 20.6 x 1.6 x 0.8 is about 26.4, so the swing likely kept its size relative to the body: re-aim the check to the body scale, but confirm the swing is still 1.6 times the body-relative bar.
- v11.06 the 23 jersey reads as a jersey -> "the 23 shows only 1564 pale pixels, so something is painted across it". Check whether that is the 0.8 body (fewer pixels, scale the threshold by 0.64) or something really painted over the number.

Steps:
1. Run each check alone on the current build; drop any that pass and say so.
2. For each left, say which of two it is: a. the game really broke: fix the game in an mk script; b. the check went blind or the change was on purpose and within his orders: re-aim it so it proves the claim again. Never loosen a check until it passes.
3. One batch per cause, through preflight.sh and shipq.sh as usual. Take a picture of any screen you change (tools/uishots.ps1) and look at it. Note the cause per check in the ship's DESIGN.md section.
Rules: player text all lower case, short; rendering and HUD only unless the check is about input or saves; no change to the storage key salvagerun:profile. Since v34.81 the SMOOTH look is the default: test and take pictures in the smooth look.
TASK DONE when every check here passes on the drafted build or is fixed in a shipped batch; TASK PARTIAL with the ones left and why.
