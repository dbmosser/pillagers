# 254-retarget-1031-reds (lane c, 2026-11-01)

Commits: b12050a24 (13 checks) and cad2f0aec (35.83, 26.69, 23.37 follow-up). Tests only, game file untouched.

Result on the shipped fixture (runchk.sh): all 16 PASS. 35.83, 26.69 and 23.37 passed twice in a row (random pack spots).
Runs: notes/254-base.txt (all 16 red before), 254-run2.txt, 254-run3.txt.

What each check now says:
- 18.78: Terms window has its own pair (text 1400px, list 1632px); party, gambler, bar still share one cap.
- 23.12: source needs 'saved to downloads' (lower case).
- 8.93: default board 388x218 from v36.76.
- 21.55: empty strip under the last name must be under the real row pitch (last name row to the row above), not a fixed 8 px.
- 30.73: gun card right edge found by hudIns() (W - hudIns()), as 34.89 does.
- 31.25: two small.trl labels STASH and BAG on the one row, three $ figures, none in a span of its own.
- 18.63: the experimental caption stands inside the sign plate and clear of the name (name baseline plus descent).
- 32.12: extract words stand inside CLKCARD (the clock card rect).
- 35.84, 35.83: g.alertSeen cleared per seat (each window has its own danger memory); 35.83 also sets ARCADE.waveN=1 before the normal interval asserts (first demo pack comes at 11 s).
- 34.41: hudKey is called with the F key label and the self-revive words are drawn to its right.
- 16.30: source text is '  INBOUND  ' (two spaces).
- 26.69: ambush staged with ARCADE.waveN=1; new part E: first pack (waveN 0, fresh Director) lands 480 to 640 from him give or take its 36 px body scatter (51 px), flags no ambush, calls none, and is 2 bodies fewer than the ambush.
- 23.37: first pack 480 to 640 (same 51 px scatter allowance), then a second pack asserts the 700 to 1200 landing.
- 32.30, 32.33: label to label air 8 px (7.5 floor) and icon air 6 px (5.5 floor), read from mapPlaceLabels (the anchored tag retry uses half the air, _rx 0.5); contract track alignment kept.

Not done (not on my write list): delete the 16 lines (and their header comment line) of the 11-01 block in tools/handoff/stable-known-red.txt, lines 137 to 153. Written to alarms.md for the coordinator.
