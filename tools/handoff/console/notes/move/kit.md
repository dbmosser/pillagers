# Move kit: piece B of tools/handoff/move-to-main-pc-1102.md

Nothing here has run for real yet. The VM can only parse-check and dry-run it. Windows PowerShell 5.1, normal windows, no administrator.

## What is where
- tools/migrate/vm-pack-for-main.ps1: VM. Scratchpad, memory, .claude/settings.local.json and butler to the bridge share, secret scan first, parts of 11 MiB, devpack-manifest.json last. Also puts main-dev-setup.ps1 and main-dev-tasks.ps1 in the share, because the main PC's old folder has neither.
- tools/migrate/main-dev-setup.ps1: main PC. Old folder renamed, fresh clone, restore, Git bash on his user PATH, npm, fixture, marker, STOP, desktop items. `-DryRun` prints each step. `-Refresh` brings a folder already set up to master and the newest pack.
- tools/migrate/main-dev-tasks.ps1: main PC. Tasks "Pillagers runner" and "Pillagers dev services" (the dashboard only).
- tools/migrate/vm-go-dark.ps1, vm-stay-off.ps1: VM.
- tools/migrate/main-helper-signin.ps1, main-enter-keys.ps1, main-dev-services.vbs: used by the shortcuts and the task.
- tools/handoff/machine.sh: every per-machine difference, keyed on COMPUTERNAME=JUL26; ON_MAIN=0 and no effect elsewhere. Sourced by nightly, the lanes, health, checkin and onhispc.
- tools/handoff/main-pc-first-message.md, tools/handoff/his-one-sitting.md: for him.
- Cutover copies, not live until step 8: CLAUDE.md.new, tools/handoff/START-HERE.md.new, tools/handoff/console/checkin-prompt.txt.new. RULES.md needs no change for the move; line 8 and the Chrome lines belong to the remote gate job (piece A).

## Order
1. VM: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\migrate\vm-pack-for-main.ps1`. It says what the secret scan left out, by name only. A left out ship script stops it.
2. Main PC Claude, from a chat or window whose folder is NOT the old dev folder (that holds the rename; exit code 2 says so): `powershell -NoProfile -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\PillagersBridge\share\main-dev-setup.ps1" -DryRun`, read it, then without -DryRun.
3. Main PC Claude: `powershell -NoProfile -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\main-dev-tasks.ps1"`. No administrator needed. nightly.sh exits at once on JUL26 while console/STOP stands, so this starts nothing. Not a separate task, by reading nightly.sh: itch-follow (4b), spare-import (1c), dashboard (10), lanes (5).
4. He does tools/handoff/his-one-sitting.md. The sign-in writes only to %USERPROFILE%\.claude-pillagers.
5. VM, once piece A is proved and he has done step 4: `powershell -NoProfile -ExecutionPolicy Bypass -File tools\migrate\vm-go-dark.ps1`. It ends with vm-dark.txt in the share. It does not shut down yet: it waits for his main PC's first ship. It refuses to say dark if a ship outlasts the wait, the push fails or the pack fails.

## The new main PC chat (his first message points here)
6. Read tools/handoff/console/checkin-prompt.txt.new; that is the check-in from now on. Create a scheduled task every 2 hours with it (mcp__scheduled-tasks__create_scheduled_task), and run `bash tools/handoff/console/ceo-watch.sh` in the background.
7. Wait for vm-dark.txt in %LOCALAPPDATA%\PillagersBridge\share. Do not go on without it: two shippers is the one thing this move must never do.
8. `powershell -NoProfile -ExecutionPolicy Bypass -File "%LOCALAPPDATA%\PillagersBridge\share\main-dev-setup.ps1" -Refresh`. Then land the cutover copies: compare each .new with its original first (`git log -1 -- FILE`); if the original changed after this kit's commit, carry the same edits over by hand, or the newer text is lost. Move each .new over its original, then `git commit -- paths` and push.
9. Delete tools/handoff/console/STOP and tools/handoff/codex/STOP. Run `bash tools/health.sh --dry` and `bash tools/handoff/console/checkin.sh`; fix what they say. Helpers need the sign-in: `status-a.txt` says "helpers off" until it is right.
10. Ship one build the normal way (tools/handoff/console/RULES.md, "How a change ships"; take the smallest waiting job). GATE_REMOTE=1 in caps.txt, piece A, puts the gate on the JTPC. If it is not set, stop: no gate may run on this PC. Done is the ON HIS PC line.
11. SKIPPED, his order 11-02 evening: the VM stays up because his TbT work runs in it. Never write vm-off-now.txt, never run vm-go-dark.ps1 -ShutdownNow, leave vm-wanted.txt in the share. Only Pillagers dev left the VM. The old step, for the record: write a file named vm-off-now.txt in the bridge share. The VM's watcher looks every 5 minutes and shuts it down 2 minutes later. If it stays up, the VM's own chat runs vm-go-dark.ps1 -ShutdownNow.
12. Memory: add a note that dev moved 11-02 and mark as superseded pillagers-all-dev-in-the-vm-2026-10-19, pillagers-host-bridge-2026-10-19 (the bridge now also runs jobs in-process here), pillagers-main-pc-claude-2026-10-27, pillagers-vm-memory-follows-him-2026-10-24. After a few days, the devpack-* files in the share can go.
13. Dashboard (the Dashboard chat's upkeep ends with the VM): check `ps -ef | grep dashwatch` first so only one runs, then start `bash tools/devdash/dashwatch.sh` in the background (run_in_background; it exits and wakes you on DASH DOWN, PAGE BROKEN, SERVER CRASH or EDITED: handle it, start it again). Create a scheduled task at 07:13 and 19:13: read the page text and the last 40 commit subjects, fix stale wording. The server has not run on JUL26 yet, so look at the page once. Memory note: pillagers-dashboard-correspondent-2026-10-27.

## Decisions worth knowing
- Line endings: Git for Windows has core.autocrlf=true, which would check out every text file CRLF. The VM's folder is LF nearly everywhere (5637 ps1 lf, 114 crlf), and the helpers' edit scripts match that. The clone checks out with autocrlf off, then sets it true for commits: the VM's exact state. A plain `git pull` here would turn each changed file CRLF, hence `-c core.autocrlf=false` in -Refresh. Nothing but the shipper moves master, so normal work needs no pull.
- hostctl on JUL26 runs the named job in its own process: no network and no key. The agent binds only the Default Switch address, which moved three times in October and may not hold with the VM off, and the default gateway there is his router. Tested in the VM with --local and a throwaway share folder: put, list, get.
- gaming.txt: "gaming=1, what=pillagers 0%" comes from playing.txt, written for a Pillagers window in front, a pad, or the Fortnite editor. On JUL26 nightly now passes that for the editor and for a window with no input for over 2 minutes. Still holds: another program working the card, a pad, the Fortnite client, Pillagers in front and in use. lane vmback is ignored there. The check itself is the memory floor: nightly 4, helper 5.
- STOP is what the runner and lanes obey. shipq.sh does not read it, so a chat could still ship by hand; steps 7 to 10 are the only guard for that, and they are in the first message.
- The marker stays status=stopped so the host guards behave as they do today (the play relay's sign-in start included); devMovedHere=yes is the new line checkin.sh reads. host-stop.ps1 -Undo is never run: it would start tools/party-start.ps1, which starts servers here.
- Tracked job files and notes reach the main PC only through git, so vm-go-dark commits what is under tools/handoff and exports. move-to-main-pc-1102.md goes with that commit if nobody committed it earlier. Gitignored things stay on the VM: exports/run-*.txt, builds, shots.

## Could not be checked from the VM
Register-ScheduledTask without administrator on JUL26 (the script falls back and says so); whether butler and Codex's sign-in are there (butler travels in the pack, Codex's sign-in does not, and its lane then rests by itself); that the Claude app's bypass switch has the words his-one-sitting.md uses; the helper sign-in; what else holds the old folder; npm and the fixture on that PC; the first real ship.
