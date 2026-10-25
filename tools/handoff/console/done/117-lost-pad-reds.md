# 117-lost-pad-reds : two checks newly failing on v34.69 pass again (the lost pad pause, a raw colour in the lost pad title)
Queue (coordinator 10-25 09:25): party blocker, before any screen polish job.
effort: medium

Source: the main PC full test run corpus-1025-0741 on v34.69 (6da8c5943), failing 6, new 5; the stable picker (bash tools/stable.sh --dry) counts it. Read it with: git fetch origin spare-results; git show origin/spare-results:spare/JUL26/corpus/corpus-1025-0741.txt
Why now: the stable build is still v29.09 (10-18). The party copy on Fri 10/30 is the newest build that passed a full run, so these reds are the party blocker. Three jobs (117, 118, 119) split them so three helpers work at once.
Your FAIL lines (both likely from v34.67 and v34.68, job 114: "press a names the lost pad", "the lost pad title colours only its p1 or p2 tag"):
- v31.90 J8 polling: null and disconnected slots pause in two polls, same slot says press a and physical A resumes -> "no pad lost pause within two polls; returning slot did not say press a; physical A did not resume and spend its press" for host and p2, null and connected:false. If the pause no longer opens when a pad drops, that is a real break of his party order (a lost pad pauses and press a brings it back): fix the game first.
- v29.33 the title and mode menu run on the shared look -> "ui-shared has a NEW raw colour or font-size literal in: #root #pausebox.padlost h3 .pl.p1". dark_raiders.html about line 2042 sets color:#f5b73b and #5fd7e8 by hand; use the shared P1 and P2 colour tokens instead (his r3-13: P1 amber, P2 cyan).

Steps:
1. Run each check alone on the current build; drop any that pass and say so.
2. For each left, say which of two it is: a. the game really broke: fix the game in an mk script; b. the check went blind or the change was on purpose and within his orders: re-aim it so it proves the claim again. Never loosen a check until it passes.
3. One batch per cause, through preflight.sh and shipq.sh as usual. Take a picture of any screen you change (tools/uishots.ps1) and look at it. Note the cause per check in the ship's DESIGN.md section.
Rules: player text all lower case, short; rendering and HUD only unless the check is about input; no change to saves or the storage key salvagerun:profile.
TASK DONE when every check here passes on the drafted build or is fixed in a shipped batch; TASK PARTIAL with the ones left and why.
