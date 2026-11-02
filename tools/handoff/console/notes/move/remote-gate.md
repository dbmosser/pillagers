# The remote gate (piece A of tools/handoff/move-to-main-pc-1102.md)

His orders 11-02: "move pillagers html development to the main PC permanently", "use the JTPC for pillagers html testing". With GATE_REMOTE=1 in
tools/handoff/console/caps.txt (the environment wins) the machine that ships starts no Chrome: every Chrome stage of a preflight and a ship, and the
camera, runs on the JTPC (DESKTOP-82BKOP4). Off, every script does what it did before.

## How it works
| step | where | what |
|------|-------|------|
| 1 | shipper: preflight.sh or shipone.sh | the mk script, gen-draft, the patches on a scratch copy (dryrun -NoFixture), no test copies, no Chrome |
| 2 | shipper: tools/handoff/gate-remote.sh run | puts job.txt, draft.json, p.ps1, f.ps1 on the gate-jobs branch under gate/jobs/ID (a private index, so this copy's branch, index and tree are never touched) |
| 3 | JTPC: tools/spare/spare-runner.ps1 Gate-Tick | looks at gate-jobs every 30 s, one job at a time, ship jobs first, then the oldest |
| 4 | JTPC: tools/spare/gate-job.ps1 | its own copy C:\PillagersSpare\gate\game (a git worktree of the runner's copy) at the job's exact base commit, so a full run keeps its files. dryrun-pf -Root, then for a preflight the code checker, then gate.ps1 and recent.ps1, and for a ship gate.ps1 -Fix on the drafted build with its stamp. Chrome 9347, test server 8823 |
| 5 | JTPC: runner | publishes result.txt on spare-results as spare/DESKTOP-82BKOP4/gate/ID.txt at once |
| 6 | shipper: gate-remote.sh | polls, refuses a result unless id, kind, key, tag, v, new, base, draft_sha, p_sha, f_sha, game_sha, fix_sha and host all match, removes the job, prints the stage lines word for word |
| 7 | shipper: preflight.sh or shipone.sh | the same grep tests as the local gate read those lines. After ship.sh start, shipone also checks the game and fixture on disk hash to what was tested |

The gate's rules are unchanged: parse check, new check twice on the drafted build, FAIL on the build before, newest 80 older checks, seed 4242 fingerprint
(ents 85/374, containers 165/593). The JTPC decides nothing that counts. No answer, a timeout, or an answer for anything else prints a REMOTE: line and exits 3,
and the callers stop. Hashes: carriage returns removed, and the game without its VER_AT and WHATSNEW_AT lines, which ship.sh writes after the patch.

## Priorities on the JTPC
- A full run goes on beside the job at below-normal priority (re-applied every 30 s, normal again after), so it keeps its slices and its try.
- The robot stops at the job's start with a FUZZ ABORT reason=gate job line (tools/stable.mjs leaves out raids cut off by it) and starts at the next round.
- No new full run and no new runner while a job runs. When a job ends, a round goes before the next job, so back-to-back jobs do not starve them.
- Someone at the JTPC: Stop-Work stops the job with the other test parts (roles gatejob, cdp 9347, Chrome 9347 and uishots 9348). It waits and runs again from the start; that costs no try. A job that dies by itself has 3 tries, one over 45 minutes none; then the answer says infra=1, never a pass.
- The main PC's idle mode never calls any of this (Gate-Tick is only in the spare branches of the loop and Watch; gate-job.ps1 refuses on JUL26 and the VM), so NoTestsHere stays test-free.

## Waiting and the ship lock
gate-remote.sh prints and logs (S/shipq.log) "waiting for the spare pc: ..." when the reason changes and every 5 minutes; shipq.sh shows these through fd 8.
It waits at most GATE_WAIT_MIN (60) minutes for the job to start and GATE_RUN_MIN (50) once it has, then STOP or FAIL, and takes the job off the branch. The lock stays
held meanwhile; shipq's pid is alive, so clearstale.sh calls it held. A second call for the same draft on the same base joins the job, or reads its PASS; a FAIL is run again as ID-r2 and so on.

## Pictures
tools/uishots.ps1 keeps its command line. With the gate on it sends a shots job (the current build at base, the recipes at base or the -Recipes file sent along) and brings the pictures back into -Out. A -Url is refused: it names a page on the shipper that the JTPC cannot open. -Merge and -Port mean nothing there.

## How to read it
- Is it on: bash tools/handoff/gate-remote.sh on
- A job in the queue: git ls-tree -r --name-only origin/gate-jobs (after git fetch origin gate-jobs)
- An answer: git show origin/spare-results:spare/DESKTOP-82BKOP4/gate/ID.txt
- The JTPC: its status.txt on spare-results has gate_cap=1 once it has the code and gate=running ID during a job. C:\PillagersSpare\runner.log has "gate job ID started" and "done".
- Turn it off: GATE_REMOTE=0 in caps.txt. Local gates need a machine that may run Chrome (the VM, not the main PC).

## Tested so far
Stand-ins on the VM with no Chrome (a bare repo for GitHub, real patches from a real draft, the real gate block of the runner and the real gate-job.ps1, with gate.ps1 and recent.ps1 as stubs):
a passing job (hashes match after a real patch, real stamp and real mkfixture on the worker), reading a PASS again with no new job, a FAIL read as a FAIL and then a fresh -r2 run, no answer (REMOTE: after the wait, job removed), a result naming another base (REMOTE: refused), a result from another host (REMOTE: refused), a job stopped because someone came (waits, no try used). Game hash in PowerShell and in bash are equal on the real game.

## Proof on the JTPC
Not run yet: it needs the runner to take the new code (no full run going).
