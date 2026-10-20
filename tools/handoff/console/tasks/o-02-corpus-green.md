MAKE THE FULL TEST RUN GREEN AGAIN (coordinator, 2026-10-19). The full regression run (corpus) has had 84 to 107 failing checks since
10-18 afternoon. The last run, corpus-1019-0129 at v31.82, had 114 failure lines, all listed one per line in
tools/handoff/corpus-fails-v31.82.txt ("version what it checks -> what it saw"). Because the run is never clean, the stable build
has been stuck at v29.09, and his play window loads that old stable (his Q12 of 10-18). This job unsticks it.

Most of these are probably STALE checks: older checks whose behaviour a later ship changed on purpose (the UI redesign of 10-18,
lower case everywhere, the HUD rework, the party screens, "pillager" for "raider"). Some may be REAL regressions. For each line:
1. Find the check in tools/mkfixture.ps1 (search for its {v:'NN.NN' id) and the later ship(s) that changed what it measures
   (git log -S on the measured thing, and tools/handoff/console/notes/).
2. Decide:
   - STALE: the change was ordered by him, or was made deliberately by a ship with its own check. Retarget the old check so it
     holds on the old AND the new build (keep its intent, follow the new rule), or delete it only if its feature was removed.
   - REAL: the game broke something a ship did not mean to change. Fix the game, with a new check whose control fails on the old build.
   - HARNESS: the check is flaky or the run was broken (window size, timing; see RULES.md "Fixture gotchas"). Fix the staging.
3. Write each decision as one line in notes-new.md: version, STALE / REAL / HARNESS, and one-line reason.

How to deliver: retargets and deletions go in .codex-work/o-02-corpus-green/fixture-retarget.json (the lane applies it under
the ship lock and checks it; see RULES-codex.md step 5). Game fixes go in mk scripts as usual. Work in batches of about 15
checks per run, oldest version first, so each run lands something. Never weaken a check to make it pass: a retarget must still
catch the bug the check was written for.

TASK DONE when a fresh full run (the runner starts one on each new HEAD) shows 10 or fewer failing checks and every remaining
one is explained in notes. Otherwise TASK PARTIAL with the count left; the coordinator puts the job back.

## RE-QUEUED 10-20 03:55 (coordinator, in the VM). Read first; where it disagrees with the text above, this block wins.
- The fresh list: tools/handoff/corpus-fails-v32.16.txt (corpus-1019-2343, commit 1b8dc30b, v32.16, every slice finished, 132 failing).
  Compared with the v31.82 list: 108 are still red, 6 are fixed, and 24 are NEW since v31.82. The 24 new ones are listed in
  tools/handoff/corpus-fails-v32.16-new.txt: triage those FIRST (a ship of 10-19 night most likely broke or changed them, and
  some may be REAL regressions), then the rest oldest version first.
- The game has moved on since (HEAD is v32.66): before deciding, run the check on the current fixture; the lane's retarget trial
  runs your listed checks on the committed game anyway, so a check that already passes on HEAD is "FIXED SINCE", not a retarget.
- The lane applies fixture-retarget.json itself now (RULES-codex.md step 5): a trial copy first, then the commit under the lock.
  Keep batches to 15 checks or fewer per file (RETARGET_MAX_CHECKS is 30).
- A new full run started 03:51 on v32.66 (ends about 08:00); the coordinator will add its list when it finishes.

## NOTE 10-20 05:15 (coordinator)
The 03:51 full run on v32.66 was stopped at 05:02: it crawled (66 of the first 120 checks in 65 min, about 10x slower than the
v32.16 run) while its page grew to 1.9 GB and every helper waited on memory. There is no v32.66 list. Work from
tools/handoff/corpus-fails-v32.16.txt and its -new file, checking each on HEAD first as the block above says.
