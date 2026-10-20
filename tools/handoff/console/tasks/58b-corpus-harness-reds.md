58b-corpus-harness-reds : five checks pass alone but fail inside the full run; find what leaks into them and fix the staging (coordinator 2026-10-20)
effort: high

Source: tools/handoff/console/notes/58-corpus-reds-v32-90.md (job 58, lane b): "four checks (24.38, 30.91, 31.04, 31.67) plus 20.89 pass
alone but fail in the full run, so something earlier in the run leaves state behind ... they need a staging reset, not a game fix."
Why: stable (his play window, the party version: his 3.40 b and 3.43 b) moves past v29.09 only when the full run is clean or every red is
on the known-red list, and these five are not game bugs, so they must not go on that list as a cover.

The full run (corpus-1020-1250, v32.90) ran slices of 120 checks, each slice in a fresh page (tools/corpus-slices.sh: it opens
fixture.html?sliceA=1 and calls __regressBg(A,B)). The five reds and their slices (tools/handoff/corpus-fails-v32.90.txt):
  v20.89 in [1200,1320)   v24.38 in [840,960)   v30.91 and v31.04 in [240,360)   v31.67 in [120,240)
(Slice index = position in __REGRESS; find each check's index with __REGRESS.findIndex on its description, not its id: ids repeat.)

1. Reproduce each with the slice tool (added 10-20 14:56 for this job; the first run could not drive a Chrome). It runs checks in
   order in one fresh page, as the full run does, on YOUR lane's own Chrome (never 9344 or 8802):
     bash <scratchpad>/slicechk.sh <lane> find:TEXT          the place of a check (search its description; ids repeat)
     bash <scratchpad>/slicechk.sh <lane> 120:229            places 120 to 228 in order (A:B is [A,B)), then the failures
     bash <scratchpad>/slicechk.sh <lane> 120:150,228        a range, then one check: this is how you bisect
     bash <scratchpad>/slicechk.sh <lane> 120:150,228 draft  the same on a fixture built from your UNCOMMITTED mkfixture.ps1 edit
   (<scratchpad> is the same folder as shipq.sh.) Start with sliceStart:redIndex+1. If it does not go red, run the whole slice.
   Write in notes whether it reproduced. ADD pin AS THE LAST WORD WHEN YOU BISECT (slicechk.sh <lane> 120:229 pin): every ship
   rebuilds the fixture and moves every place by one; pin freezes a copy (unpin when done). The coordinator's bisect is in the notes.
   COORDINATOR 10-20 15:38: slicechk.sh is now on your allowed list. Six reds were one leak and are FIXED (7fda5220: the v32.70 pad
   name check left an own ctx.fillText that hid later checks' PR.fillText recorders). Still yours: v31.67 (it stays red after that
   fix), v20.89, v24.38, v30.91, v31.04.
2. Bisect the checks before it in the same slice until you find the one that leaves state behind (a profile or setting written, a timer
   or listener left running, a screen left open, a global flag, the zoom, the sandbox, a stubbed function not restored).
3. Fix the STAGING, never the assertion: the leaking check cleans up after itself (try/finally restores what it changed), or the red
   check stages its own preconditions first. Through the fixture queue (fixq), like jobs 52 to 57. The red check must still FAIL on a
   build where the thing it tests is really broken: prove that once per check (break it on a scratch copy, or run it on the commit
   before the feature it tests) and say how in notes.
4. Afterwards run each whole slice again: the red passes and no other check in the slice turns red.
5. If a red cannot be reproduced in its slice at all (it only fails in the long run), say so in one line; do not guess at a fix.
Do not touch v20.01, v20.11, v28.12, v28.13, v28.16 (job 68 owns them) or v8.58 (done by job 58).
Notes: tools/handoff/console/notes/58b-corpus-harness-reds.md, one line per check: the leaking check found, the fix, the proof it can still fail.
Party risk: none (test staging only).

TASK DONE when all five pass inside their slices with the proof lines; TASK PARTIAL with what is left.
