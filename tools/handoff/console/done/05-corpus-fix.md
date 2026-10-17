Fix the next 8 OPEN rows of tools\handoff\console\notes\corpus-triage.md (if none are OPEN, reply TASK DONE at once).
- STALE: retarget the old check in tools\mkfixture.ps1 so it tests the same intent on today's design. If his order removed the
  feature, make it return 'SKIP: removed by his order (WHAT)'. Never weaken a check to hide a real bug. Commit with
  bash "S/fixq.sh" "retarget vX.YY: reason" (S is the scratchpad in your rules).
- REAL: fix the game through an mk-cw-KEY.ps1 and bash "S/shipq.sh" cw-KEY, one fix per key.
- FLAKY: rerun it alone with runchk.sh (holding the lock); if it passes three times, mark it FLAKY-OK.
Confirm each retargeted check passes with runchk.sh, then set its status to DONE (or STUCK: why). TASK DONE when the 8 rows
(or all that were left) are DONE or STUCK.
