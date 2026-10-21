# The spare PC: the test and robot machine (2026-10-20)

His spare PC (RTX 2080, AMD X3D, 16 GB, always on and connected; his answer: "16gb ram, it can stay on and connected") takes the full test
run and the crash robots off the VM, so the VM's memory goes to the helper lanes and the stable build can move again.

## What runs where

| part | where | what |
|------|-------|------|
| `spare-setup.ps1` | spare PC, once, by him | checks Git, Node and Chrome; marks the game copy (`.spare-pc`) and makes it refuse every push; makes the results copy `C:\PillagersSpare\results` (branch `spare-results` only); first push (his GitHub sign-in); the task "Pillagers spare runner"; starts the runner. `-Status`, `-Remove`. |
| `spare-runner.ps1` | spare PC, always | every 5 min: newest master (detached checkout, never while a full run is going), test copy (`mkfixture.ps1`), full test run (`corpq.sh`, Chrome 9344) on each new game file, two robots (`fuzz.ps1` 9331 and 9332, 60 min blocks, on `fxcorpus.html`), results pushed to `spare-results` every 30 min and when a run ends. Restarts itself when master brings a new copy of it. |
| `serve.mjs` | spare PC | the test server on 127.0.0.1 and ::1, port 8806, root `tools\`. Never the network card, so no firewall question. |
| `spare-start.vbs` | spare PC | starts the runner hidden (the task runs it at sign-in and every 15 min). |
| `spare-import.mjs` | VM, every 5 min from `tools/nightly.sh` | fetches `spare-results` into `refs/spare-import/spare-results`; finished runs (with "ALL DONE" and a `.head`) go into the scratch folder `tools/stable.mjs` reads (never overwriting); robot logs are mirrored to `tools/handoff/spare/HOST/`; `tools/handoff/spare/live.txt` and `tools/handoff/spare-status.txt`. |

While a spare PC was seen in the last 3 hours, `tools/nightly.sh` starts no full test run and no robots in the VM (`spl=1`). When it goes
quiet for 3 hours the VM runs them again by itself. `tools/stable.mjs` reads the spare PC's robot logs with the VM's own.
`tools/health.sh` prints a `WAIT:` line while the spare PC is not set up or is quiet (it is his machine: nothing to fix from the VM).

## Limits (do not loosen)

- The spare PC never ships, never commits to the game, never edits the game. Its game copy's pre-push hook refuses every push; the results
  copy's hook allows only `refs/heads/spare-results`. Only one machine ships: the VM.
- No firewall, Defender, UAC, power-plan or Windows Update command anywhere in these files. The runner only asks Windows to stay awake
  while it runs (SetThreadExecutionState, the request a video player makes).
- No keys or passwords: the clone is public, and the one sign-in is Git's own GitHub window on the first push.
- Never port 8802. The test server listens on this PC only.
- Both scripts refuse to run on JUL26 (the main PC) and VM_Oct2026 (the VM).
- To change what the spare PC runs: change `spare-runner.ps1` on master. It picks the change up by itself within about 5 minutes of the
  next idle moment (no full run going). He never has to touch it again unless it restarts and waits at the sign-in screen.

## Tested in the VM (10-20 23:10)

Both scripts parse in Windows PowerShell 5.1 with no non-ASCII bytes, and both refuse on VM_Oct2026. `serve.mjs`: HEAD gives the
Content-Length the robots read, ::1 and 127.0.0.1 both answer, nothing outside `tools\`, POST refused, port 8802 refused. With a local
stand-in for GitHub: the results push works, a push to master from the results copy and any push from the game copy are refused by the
hooks; the import takes the finished run with its `.head`, skips the unfinished one, mirrors the robot log, writes `live.txt` and the
status line, takes nothing twice, and says "not set up yet" when the branch is missing; `stable.mjs --dry` counted 32 robot minutes from a
spare robot log. Not tested (needs the spare PC): the task, the GitHub sign-in, a full run and the robots on that machine.

Set up by Claude Code on the spare PC (10-21, his pick for reliability): he signs in to the Claude app there and types one line pointing at `tools/spare/claude-setup.md`, the brief that session follows.
