58-corpus-reds-v32-90 : sort the reds of the first full run on v32.90, so a build newer than v29.09 can become stable (planner draft 2026-10-20)
effort: high

STAGING NOTE (coordinator, remove when moving to tasks/): move this into tasks/ ONLY after corpus-1020-1250 (started 12:50 on 91a66a3d,
v32.90, about 3.5 hours) has finished and you have written tools/handoff/corpus-fails-v32.90.txt. Pairs with coord-02 (known-red file, robots).
Source: q-round3/answers.md 3.40: "b: The newest version that passed all the tests"; helper-fixes.md item 16: "Create the known-red tests list".
Not done (planner, 10-20): ls tools/handoff/stable-known-red.txt -> "No such file"; stable-status.txt "Latest stable: v29.09 (2026-10-18 10:23)",
"Result: no change" (checked 12:56); the newest finished run is corpus-1020-0828 on v32.83 (failing 101); jobs 52 to 57 retargeted after it.

Why: his play window loads the latest stable (his Q12), stable is the last version each night that passed all the tests (3.43 b), and the
party version is the newest version that passed all the tests (3.40 b). Today that is v29.09, two days and about 180 ships old.

1. The list is tools/handoff/corpus-fails-v32.90.txt ("version what it checks -> what it saw"). Oldest version first.
2. Run each red alone on HEAD first (runchk.sh). Passes now -> FIXED SINCE. Otherwise decide as jobs 52 to 54 did
   (notes/52-corpus-reds-a.md shows the pattern):
   - REAL: the game broke something a ship did not mean to change. Fix the game through the ship queue with a check whose control
     FAILS on the old build.
   - STALE: a later ship changed it on purpose (his order, or a ship with its own check). Retarget through fixq, keep the intent,
     never weaken it to make it pass.
   - HARNESS: flaky staging or timing. Fix the staging.
3. Duplicate ids: 8.55, 8.58, 8.59, 8.60, 9.03, 15.91, 29.59 and 30.79 each name 2 to 6 checks, and runchk.sh runs only the FIRST
   (shipkit/runchk.sh line 11, __REGRESS.find). If one of these is red, find the copy by its description before judging it (job 50 judged
   the wrong 8.58). Codex job o-19 renames them; if it has landed, use the new ids.
4. Checks that pin the word "credits" in the raid corner (the v11.52 family): leave them to job 65 if it is in tasks/ or done/.
5. A red that is only an out-of-date check and cannot be retargeted safely here: one line in notes/58-known-red-proposal.txt,
   "vNN.NN reason" (the prefix format tools/stable.sh line 17 reads). The coordinator copies it to tools/handoff/stable-known-red.txt
   (lanes may not write there). Never put a REAL bug on that list.
6. Do not touch the checks of a job that is still in tasks/.

Notes: one line per red in notes/58-corpus-reds-v32-90.md: version, FIXED SINCE / REAL (vNN.NN) / STALE (retargeted) / HARNESS /
KNOWN-RED, one-line reason.
Party risk: low (fixture edits and real-bug fixes only). Not a feature, so it may continue after Mon 10/26, up to the Thu 10/29 lock.

TASK DONE when every line of the list has a verdict and every red left is either fixed or proposed for the known-red list with a reason;
TASK PARTIAL with the count left.
