TRIAGE ONLY, NO SHIPS. The last full regression corpus on the current HEAD failed 72 checks. The corpus file is named by
corpus_file= in tools\handoff\nightly\state.txt (lines that start with a range and FAIL xN, each failure split by ||, as
"vX.YY what the check claims -> why it failed"). For every failure, find the check in tools\mkfixture.ps1 by its version and
words (Grep, never read the whole file) and the game code it tests, then give one verdict:
- STALE: the check is right for an old design that his later orders changed on purpose (examples: the belt became the wheel,
  the kit question moved into map select, the run card chips, the Keys list, the starter guns, the magnet removed, the
  lockdown removed, the clue hunt cut). Name the order or build that changed it.
- REAL: the game is wrong today. Likely: v28.48 2P shield bubble, v27.00 needed-item glow, v25.26 Longshot length.
- FLAKY: timing or setup noise (it may pass alone).
Write tools\handoff\console\notes\corpus-triage.md as a table: row number, version, verdict, one-line reason, the fix to make,
and a status column set to OPEN. Group related rows together. TASK DONE when every failure has a row.
