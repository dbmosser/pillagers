96-demo-easy-card-and-board-words : the demo's easy mode question is seen before it runs out, and the initials card names the board as it is (coordinator 2026-10-21)
Queue (coordinator 10-21 04:30): found by the 2-player test sheet check (workflow wf_1236bdbd-42c, journal in the coordinator's session); his 10-20 23:00 order: nothing waits for the party.
effort: low

Source, read in the code by two checkers and confirmed by the fixer (dark_raiders.html, line numbers as of v33.61, grep the names):
- easyStartAsk starts its 12 s timer with Date.now() as the demo raid builds (called from arcadeDeploy). The frozen opening map is up at
  that moment (MAPFIRST, closes when both players click or after 20 s). drawHUD draws the easy card (easyHud via arcadeHud) BEFORE
  drawMapOverlay, so the map covers the card while its 12 s run out. A pair that reads the map for 12 s never sees the question and the
  run is quietly normal. His pick 2.28 c (tools/handoff/q-round3/answers.md): each player chooses easy or normal before the run starts.
- arcadeIniHud draws "top 10 tonight · enter initials" but ARCADE_BOARD keeps 20 rows (top:20), and a run in tonight's top 20 asks.
  His answers conflict on 10 or 20 rows (sweep-3-newer-rulings.md); do not pick one: name the board by its title instead.

1. The easy question's 12 s start when the opening map closes in that window (or when the map is not shown), not when the raid builds.
   Nothing else about it changes: the same words, keys and 12 s, both windows, no answer means no.
2. The initials card says "tonight's best · enter initials" (lower case, as the party screen names the board), in solo and 2 player.
3. Checks (new, each must fail on the build before): (a) with the opening map up for 15 s, the easy card is still asking after the map
   closes and its countdown starts there; (b) the initials card text has no "top 10" and names "tonight's best". Drive the clocks
   through seams, no real waits.
Watch line: "the want easy mode? question now comes after the opening map"
Size: one ship.
