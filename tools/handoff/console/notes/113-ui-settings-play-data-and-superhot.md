# 113 notes (lane a, 2026-10-24)
Shipped v34.51 cw-playdata, v34.52 cw-playdata2, v34.53 cw-playdata3 (each with a check that failed on the build before). 33.70 retargeted (opens show data first, safe on old and new).
Screen 92 has no recipe in ui-screens-js.json: recipe in notes/113-recipes.json (use -Recipes). Staged 10-18 recipe never worked ("not staged").
Clipped row on 92: not found on HEAD (card has a rail, one tab strip, list ends on whole rows; job 107 fixed it). No check written for it.
Critic: 31 = 2 -> 3 -> 3 -> 3, 92 = 3 (old 2) -> 3 -> 3 -> 3. Stuck, my reading: the critic contradicts itself between rounds (fill the detail pane vs shrink it; headline loud vs quiet; centre vs top). What is left that is not contradictory and needs bigger jobs: move the volume rows to the audio tab (job 107 area), the stray 36px lime corner tick on every window (guide allows it, critic always calls it a glitch), tab contrast and 20px tabs, live key/pad footer hint, 'read code' beside its field.
Watch on next play: send play data page opens folded; copy still works with the data hidden; show data opens the text.

## Run 2 (lane b, 2026-10-25): the nine settings reds
Cause: my v34.51 to v34.53 gave the settings detail pane a hero value and a packed shape; older checks and rulings (30.05, 31.75, 33.28: no repeated value, full height) forbid that, and my own 34.52 and 34.53 asserted the opposite. Kept the older rulings.
Shipped v34.55 cw-setrevert (pane back to full height, no repeated value; a jump chip taking pad focus no longer scrolls the list; expmode mask hex to black), v34.56 to v34.62 (cw-setrevert2..5: raw px and hex in the expmode footer, play data text, news subtitle and restore helper rules moved to tokens, same pixels).
Fixture (commit 2615fafa1, 797b968c0): 34.52 and 34.53 lose their pane-shape asserts, 33.56 opens show data first, 31.59 skips the collapsed section heads, 26.38 looks for go_mmSize (the row was renamed v33.35), 33.33 opens its own settings state (a leftover play data tab hid the game pane).
All thirteen (nine reds, 34.51 to 34.53, 33.70) PASS in one run in the failing order on v34.62.
Critic 92 on v34.62: 3 (better than the hero version). It asks to shrink the pane, which check 31.75 forbids; log: the critic and 31.75 conflict, 31.75 kept. 31 unchanged by this run (3).
Watch on next play: the settings side pane is full height again with only the row name, a short line and the key chip.

## Run 3 (lane b, 2026-10-25)
Nothing left to ship. Both screens (31, 92) sit at critic 3; his round-3 finish line (3.51 a) is 3 for screens outside the raid, waiting, pause and run-over screens. Remaining critic points conflict with check 31.75 / his rulings or need bigger jobs (volume rows to the audio tab, corner tick, footer hint); listed in run 1 notes. All thirteen settings checks passed together on v34.62. No new picture or ship this run.
