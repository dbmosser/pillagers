# Spare PC setup: the brief for a Claude Code session on the spare PC (coordinator, 10-21)

The owner opens Claude Code on his spare PC and types one line pointing here. You are that session: set up this PC as the Pillagers
test and robot machine described in tools/spare/README.md, check that it is running, and stop. The owner is not a coder: do every step
yourself, and tell him only when he must click something (a Windows "allow changes" prompt, the GitHub sign-in window). The repo's
CLAUDE.md describes the VM's work (lanes, ship queue): none of it applies to this session.

## Limits (from tools/spare/README.md; do not loosen)

- This setup only. Never edit, commit or push the game, never ship, never start helper lanes. Only the VM ships.
- No firewall, Defender, UAC, power-plan or Windows Update command, here or anywhere. If something seems to need one, stop and ask him.
- No keys or passwords: never ask for, print or store one. The one sign-in is Git's own GitHub window, which he fills in himself.
- Never use port 8802. Stop at once if this computer is named JUL26 or VM_Oct2026 (the main PC and the VM).
- If a script here fails, fix the cause on this PC (a missing program, a PATH, a folder), not the scripts. If a script itself is wrong,
  tell him in one plain line that the VM must fix it, and stop.

## Steps

1. `$env:COMPUTERNAME`: stop if it is JUL26 or VM_Oct2026.
2. Install what is missing, with `--accept-source-agreements --accept-package-agreements`:
   Git (`winget install --id Git.Git -e`), Node (`winget install --id OpenJS.NodeJS.LTS -e`), and Chrome
   (`winget install --id Google.Chrome -e`) only if `C:\Program Files\Google\Chrome\Application\chrome.exe` is missing.
   Then reload PATH from the machine and user values, so the new programs are found.
3. If `C:\claudecode\dark raiders` does not exist: `git clone --depth 1 https://github.com/dbmosser/pillagers.git "C:\claudecode\dark raiders"`
   (public, no sign-in). If it exists, leave it as it is: the runner keeps it current.
4. Run `powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\spare\spare-setup.ps1"` (allow it up to 10 minutes).
   Before it reaches the first push, tell him: "a GitHub sign-in window will open: sign in and allow it". It must end with a green
   `DONE` line. A `STOP` line names what is missing: fix that and run it again.
5. Check it is rolling, within about 15 minutes:
   - the scheduled task "Pillagers spare runner" exists;
   - `C:\PillagersSpare\runner.log` shows the test build and the full test run starting, and `C:\PillagersSpare\status.txt` says
     `push_ok=1` after the first results push;
   - `http://127.0.0.1:9344/json/version` answers (the full test run's Chrome), and the robots' Chromes on 9331 and 9332 come up;
   - `git ls-remote https://github.com/dbmosser/pillagers.git refs/heads/spare-results` shows the branch.
6. Tell him in two plain lines, no code talk: it is done, and he should leave the PC on and signed in. Then stop. Nothing
   else runs Claude here: the runner needs no Claude, and a change to it comes from the VM through master within about 5 minutes.
