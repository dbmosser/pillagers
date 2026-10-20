o-19-duplicate-check-ids : give every duplicated check id its own name, so each check can be run alone (planner draft 2026-10-20)
effort: medium

Source: tools/handoff/console/notes/50-corpus-old-a.md: "a version number used twice (8.65) cannot be run alone by runchk.sh".
Not done (planner, 10-20): grep -o "{v:'[0-9.]*[a-z]*'" tools/mkfixture.ps1 | sort | uniq -c shows 8.55 x2, 8.58 x3, 8.59 x2, 8.60 x2,
9.03 x2, 15.91 x2, 29.59 x3 and 30.79 x6: 22 checks on 8 ids, 14 of which cannot be run alone, because shipkit/runchk.sh line 11 picks
__REGRESS.find(x.v===V), the first match only. Job 50 fixed only 8.65 (renamed 8.65h). Real harm already: job 50 marked v8.58 "FIXED
SINCE" after runchk ran the FIRST 8.58 (closest extract, near fixture line 2133); the red one is the sector board 8.58 near line 2147, still
red in tools/handoff/corpus-fails-v32.83.txt line 5.

1. Rename every second and later copy with a letter suffix, as 8.65h was done (8.58 gets 8.58h and 8.58i, 30.79 gets h to l, and so on).
   Change nothing else in any check.
2. Deliver it as .codex-work/o-19-duplicate-check-ids/fixture-retarget.json: each anchor is the {v:'..' text plus enough of its own
   description to occur exactly once. At most 30 checks per file (you have 14). No keys are needed (fixture only).
3. Put the renamed sector-board 8.58 in "run", so the lane runs it on HEAD: if it is red, say so in alarms-new.md (job 58 or a later job
   judges it; do not fix the game here).
4. Check whether anything else keys on these version strings (tools/stable.sh known-red prefixes, tools/corpus-slices.sh output, the gate's
   "newest ~80 checks" choice) and write what you find in notes-new.md.
Party risk: none (fixture only). If job 58 is open, it may be judging one of these ids: the renames do not change what any check does.

TASK DONE when the retarget is applied and every check id in tools/mkfixture.ps1 is unique; TASK PARTIAL with what is left.
