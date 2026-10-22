
--- codex run 2026-10-22 10:08 ---
2026-10-22, task 96-demo-easy-card-and-board-words, first Codex run on v34.16.

Prepared one key: cw-cx-easymapwords. No tracked game or fixture files were edited.

The new demo question records that it is waiting for this window's opening map. While waiting it neither draws nor takes answers. mapFirstEnd starts its full 12 seconds. A demo without the opening map starts the question immediately. The words, keys, timeout, damage and medkit rules stay the same. The change applies to the start question only; the later death and career offers keep their existing timing.

The in-raid initials heading becomes "tonight's best - enter initials" (the game uses a middle dot). The solo run-over heading gets the same words. The two-player run-over card keeps its player 1/player 2 headings as required by Q62. Reason for changing the old words: the board keeps 20 rows, so "top 10 tonight" promises the wrong qualification rule; the board title avoids choosing between the conflicting row-count rulings.

The new check has independent timing and heading assertions. It drives Date.now and the map step directly, stages 15 seconds on the opening map for host and p2, checks 12 seconds at close, one second remaining after 11 seconds, default normal at 12 seconds, and the immediate no-map case. It captures actual heading calls for solo and both demo roles, plus the solo DOM heading. Both assertion groups fail on the old code. All clock, drawing and arcade state seams are restored in finally.

Fixture retarget supplied for 31.45: accept either the old solo heading or the new board title, preserving the player names and card order assertions. This passes before the key ships as required.

Local verification: mk printed written; all five edit anchors and the fixture retarget anchor match once; the patched inline game script, new check and four camera recipes parse. No browser, preflight or runtime check was run in the sandbox.

Four custom pictures requested: easy question after the opening map in the player 1 and player 2 windows, player 2 in-raid initials, and solo extraction/run-over initials. The lane must ship, take pictures, and run the critic. Actual picture paths and critic results remain pending.

Watch: the want easy mode? question now comes after the opening map


--- codex run 2026-10-22 10:11 ---
2026-10-22, second Codex run. Fixture retarget 31.45 is already committed as 2848f72b1 and passed on v34.16.

Fixed the cw-cx-easymapwords preflight parse failure. JavaScript accepted the draft, but the project parse checker misread the regex immediately following return in the new countdown assertion and reported one extra opening brace. Replaced that expression with a string search. The game edits are unchanged.

Expanded local validation to compile the complete generated fixture with the new check inserted, and run the same balance and duplicate-function scans as tools/parsecheck.html. The modeled v34.17 fixture now has zero unmatched parentheses, braces or brackets, no duplicate functions, a current DEVNOW line and a fresh news stamp. All five anchors remain unique. The mk script prints written. No runtime regression check or browser ran in this sandbox.

Same key remains in keys.txt. The lane still needs to rerun preflight, ship, take the four requested pictures and obtain critic results.


--- codex run 2026-10-22 10:20 ---
2026-10-22, third Codex run. cw-cx-easymapwords shipped as v34.17.

Looked at all four round-1 pictures. The solo run-over picture shows the correct "tonight's best" heading. The other three pictures show the wrong screens: the manually staged arcade had ownAt=0, so its background idle tick immediately ended the host raid or removed player 2. Their critic findings therefore describe unrelated attract/run-over cards, not the easy question or in-raid initials card.

Corrected camera-recipes.json only: start the real arcade idle clock when staging each manual arcade raid, keep the player invulnerable while paused, and require the intended live card with the attract overlay absent. The three corrected staging bodies and expectations parse. No game follow-up key is needed to fix the camera.

The solo picture is tools/handoff/console/notes/shots/96-demo-easy-card-and-board-words-recipes-1/96-initials-solo-run-over-1080.jpg. Its critic gave 3 with broader existing run-over typography, focus-colour and size findings. The task is the timer and board words, with a one-ship limit; a general run-over redesign is outside that scope. The same solo picture remains in the recipe set so the next review has context. The first three intended cards still need valid pictures and critic review.

Watch: the want easy mode? question now comes after the opening map


--- codex run 2026-10-22 10:24 ---
2026-10-22, final functional verification on v34.17. The lane reports cw-cx-easymapwords shipped, and the shipped fixture contains check 34.17. No new key is required.

Inspected all four round-2 pictures. All camera expectations passed, with zero lint findings. Both the player 1 and player 2 pictures show "want easy mode?" with the unchanged Y/N wording and 12 seconds after the simulated 15-second opening map. Player 2's score strip names p1 and player 1's names p2, confirming the two local roles. The in-raid initials picture shows "tonight's best - enter initials" (middle dot in game), as does the valid solo run-over picture. This completes the requested timing and wording evidence in both window roles.

Pictures: tools/handoff/console/notes/shots/96-demo-easy-card-and-board-words-recipes-2/96-easy-after-map-p1-1080.jpg; 96-easy-after-map-p2-1080.jpg; 96-initials-in-raid-p2-1080.jpg; 96-initials-solo-run-over-1080.jpg in that same directory.

The critic scores are 2, 2, 2 and 3. These are not visual passes. The remaining findings concern pre-existing panel opacity, type size, teal borders, initials focus colour, surrounding HUD clutter and run-over layout. They have been handed to the coordinator in alarms-new.md. I am preserving this task's explicit "Size: one ship" scope and "Nothing else about it changes: the same words, keys and 12 s" requirement, rather than adding a general presentation redesign or following suggestions to shorten the controls. In particular, adding selectable buttons, explanatory effect text, or removing keys would exceed the task. The critic also misread already-lowercase run info as capitalized, and extraction x2 is the score multiplier, not an extraction count.

Requested functional work is complete and shipped in one key. Presentation concerns are recorded honestly rather than reported as passing.

Watch: the want easy mode? question now comes after the opening map

