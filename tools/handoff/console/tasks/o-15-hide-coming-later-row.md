o-15-hide-coming-later-row : hide the greyed "2 player co-op (server) / coming later" row on the title (planner draft 2026-10-20)
effort: low

Source: tools/handoff/q-round3/answers.md: "2.R6 b"; round 2 question R6, option: "b) Hide it completely until it works".
Not done (planner, 10-20): dark_raiders.html 2787: <div class="modelater"> holds button#modecoopsrv "2 PLAYER CO-OP (SERVER)" and the
"coming later" tag with no display:none, while the PvP rows (2788-2789) have it. No .modelater CSS rule hides it. netTitleInit (about
56000-56008) returns 'host' before its hide loop, so only the player 2 window hides it. The picture
tools/handoff/console/notes/shots/00-demoplain-after/01-title-mode-menu-1080.jpg shows the row.

1. Hide the server co-op row and its "coming later" tag on the title in every window, the same way the PvP rows are hidden (keep the
   element in the page so the wiring holds).
2. The arrows and the pad skip it.
3. Change nothing else on the title (03-title-and-backdrop used its tries; the mode rows are his ordered rows).
Check (control must FAIL on v32.90): in the host window #modecoopsrv and its tag are not visible, and moving down the mode list never
lands on it.
shots.txt: 01 (the title mode menu).
Party risk: low (the row is disabled; the party clicks the demo row).

TASK DONE when shipped, the check passes and the title picture shows no server row; TASK PARTIAL with what is left.
