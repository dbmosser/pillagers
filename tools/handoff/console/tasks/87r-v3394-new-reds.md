87r-v3394-new-reds : the 32 checks newly failing on v33.94 pass again, each fixed in the game or re-aimed at the pixel art (stable blocker)
Queue (coordinator 10-22 00:50): stable is stuck on v29.09; the newest finished full test run has 32 newly failing checks. Sorts before 88 on purpose.
effort: high

Source: tools/handoff/stable-status.txt (checked 10-21 23:49):
  corpus-1021-2139  v33.94  failing 37, new 32  (run on the spare PC, JTPC)
  corpus-1020-2300  v33.17  failing 3, new 1
Both run files are in the stable picker's scratch folder (C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad/corpus-1021-2139.txt and corpus-1020-2300.txt).
They are real, not the spare PC's setup: the VM's own run on the same build (corpus-1021-2302.txt, same folder) failed the same 21 checks in the slices it reached (0 to 2160).
Examples: v8.55 the two armoured heavies walk heavy; v8.61 the boarding hold cannot be done in instalments; the [2280,2400) slice (v10.82 to v12.05: fallen-building floors and map marks, machines routing out of buildings "13 of 13 buildings are boxes", SHIFT sprint, pause duck, headgear and beard drawn 0 pixels, Undercroft station names, your map marker 0 pixels).

Steps:
1. List the 32: the checks that FAIL in corpus-1021-2139 and did not fail in corpus-1020-2300 (tools/stable.mjs computes the same list as newFails).
2. For each, find the ship that broke it (git log between v33.17 and v33.94; the pixel art pass 86a to 86j shipped in between) and say which of two it is:
   a. the game really broke (the thing the check names no longer works for a player): fix the game in an mk script;
   b. the check went blind after the pixel art pass (its own control says it saw nothing: "0 pixels", "the map may not have drawn", "the instrument cannot see them"): re-aim the check at the pixel drawing, as the codex retargets 05c63b85 and e2fe87a5 did. Never loosen a check until it passes.
3. One batch per cause, through preflight.sh and shipq.sh as usual. Note the cause per check in the ship's DESIGN.md section.

TASK DONE when every check on the list either passes on the drafted build or is fixed in a shipped batch; TASK PARTIAL with the ones left and why.
