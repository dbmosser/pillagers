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

## The main PC, while he is away (10-22)
His order: "When my main PC isn't being used, it should be used for testing too" and "its resources shouldn't be idle"; he said yes to it
checking how long since he last touched the keyboard, mouse or a pad. On JUL26 the same runner works in IDLE MODE from its own copy
(C:\PillagersIdle\game; his old C:\claudecode\dark raiders there is never touched). It starts nothing until nobody has used the keyboard,
mouse or a pad for 15 minutes and 6 GB are free, stops what it started within seconds of a touch (or under 4 GB free), and gives a build
the spare PC is testing or has tested robots only. The VM's nights come first (his 10-22 question "should it matter if its day or night?"):
the main PC's 23:00 task lends the VM about 6 GB until 06:00, sized from what is free at 23:00, so the runner holds nothing from 22:40 to
23:10 and until 06:45 starts only with 10 GB free. By day the spare memory tests on the main PC; by night it is the VM's. After 19:10 it
starts no full test run (2.5 to 3.5 hours would not end before 22:40): the robots get the build and the full run waits for the morning. A
copy that restarted itself for a new runner looks after the robots the old copy left running. Its results go to spare/JUL26/ on spare-results with mode=idle; the VM counts them but
never treats the main PC as the full-time spare. Set up once on the main PC, in a normal PowerShell window:
    git clone https://github.com/dbmosser/pillagers.git C:\PillagersIdle\game; powershell -ExecutionPolicy Bypass -File C:\PillagersIdle\game\tools\spare\spare-setup.ps1
Stop for good: the same setup with -Remove. Status: with -Status.

4K frame numbers (10-22, his "No we might as well get rolling on it"): on the main PC the second robot (9332) plays at 4K
(fuzz.ps1 -Size 3840x2160), both windows of a 2-player raid included, which is the party load on the party PC. Every raid line carries
work= (ms of the game's own work per drawn frame: frames/p50/p95/p99; 16.7 ms is the 60 fps line) and gfx= (the gap between frames).
spare-import.mjs puts the middle of the newest 40 windows in the status line. In the VM a hidden browser hands out only about 30 frames
a second, so there the gap reads 31 ms whatever the game does and work= is the measure. VM trial 10-22, one 4K window: 6.75/14.25/23.75;
two 4K windows: 8.25/13.75/40.75 and 6.75/12.75/28.75; 1080p: 5.75/9.75/14.25. The first robot shares the card, so the 4K numbers run high.
