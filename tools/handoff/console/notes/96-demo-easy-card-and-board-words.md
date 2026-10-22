
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

