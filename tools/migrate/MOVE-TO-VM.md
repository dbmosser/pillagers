# Moving Pillagers into the VM - your step-by-step guide

You are moving all Pillagers work from the main PC (name: JUL26) into the virtual machine (name: Pillagers_Oct26), so your work Claude Code can have the main PC to itself.

Plain picture: the VM is a second computer that lives inside a window on your main PC. We give it more memory and a share of your graphics card, install the same tools, copy every Pillagers file into it, and then turn Pillagers off on the main PC so only the VM runs it. Nothing is deleted from the main PC at any step. Every step can be undone (see "Going back").

How to read this guide:
- **[MAIN PC]** means do it on JUL26. **[IN THE VM]** means do it inside the VM window.
- Each step says what to click or type, roughly how long it takes, and what you should see. The times are my best guesses; the scripts print their own progress.
- Gray boxes are commands. Copy a whole box, click into the PowerShell window, right-click once (that pastes), press Enter.
- One rule for everything: never run Pillagers helpers on both machines at once. The scripts enforce this for you.

---

## The plan on one page

| # | Where | What | About how long |
|---|---|---|---|
| 0 | both | Learn the 4 basic moves (admin window, VM window, full screen, reading results) | 10 min, once |
| 1 | MAIN PC | Boost the VM: more memory, more processors, graphics share | 15-30 min |
| 2 | MAIN PC | First push of your files (Pillagers keeps running on the main PC) | 30-90 min, leave it |
| 2B | both | Optional: send the Claude conversation and memory ahead (the session pack) | 10-15 min |
| 3 | IN THE VM | Sign in, make the window full screen, update Windows | 30-60 min |
| 4 | IN THE VM | Run vm-setup (installs tools, tidies Windows, copies the look, unpacks files) | 40-90 min |
| 5 | IN THE VM | Restart for the graphics card, check it | 10 min |
| 6 | IN THE VM | Your sign-ins and keys (only you can do these) | 15-20 min |
| 7 | both | Test the Xbox pads | 10-20 min |
| S1-S7 | both | SWITCH-OVER DAY: stop Pillagers on the main PC, final push, start it in the VM, paste the first message to Claude | 1.5-2.5 hours |
| K1-K8 | both | KEEPING IT ALL WORKING: the local AI bridge, the VM's settings and keys, the pad route, auto-start and auto-sign-in, the must-pass lists, the party fallback | about 1.5 hours in all, spread over the days |

Steps 1 to 7 can be done over a day or two, any time, while Pillagers keeps working on the main PC. Switch-over day is the only moment that matters. Pick a day when you are not in the middle of something. Do it by Mon 10/26 if you can, so the pad route is proven well before the Fri 10/30 party. Part 3 (K1-K8, after the switch-over steps) says which pieces to set up before S2 and which after.

---

## Step 0 - The four basic moves

### 0A. Open an administrator PowerShell on the MAIN PC
1. Press the Windows key, type `powershell`.
2. Click "Run as administrator" on the right side of the Start menu (or press Ctrl+Shift+Enter instead of Enter).
3. A box asks "Do you want to allow this app to make changes to your device?" The app should say Windows PowerShell and the publisher Microsoft Windows. Click **Yes**. (If it names something you did not just start, click No and tell Claude.)
4. You should see a blue window whose title says **Administrator: Windows PowerShell**.

If the title does not say Administrator, close it and do it again. The scripts that talk to the VM refuse to run without it and say "needs an administrator window".

### 0B. Open the VM window and make it fill your screen
1. On the main PC press the Windows key, type `Hyper-V Manager`, press Enter. (If it is missing, tell Claude; it is a Windows feature that must be switched on.)
2. Double-click **Pillagers_Oct26** in the middle list (or right-click it and choose Connect).
3. A small "Display configuration" box may appear first. Drag the slider all the way to the right until it says **Full Screen**. Tick **Use all my monitors** only if you want the VM to cover every screen. Click **Show Options**, tick **Save my settings for future connections to this virtual machine**, then click **Connect**.
4. The VM's desktop appears. In full screen your 4K picture should be sharp. If text looks too big or too small: inside the VM go to Settings, System, Display, Scale, and choose the same percentage as your main PC (look on the main PC in the same place).
5. To get out of full screen without closing anything: move the mouse to the very top edge of the screen; a small bar drops down with a restore button. Ctrl+Alt+Break also switches full screen on and off.
6. If you have several monitors and want a specific one: drag the VM window onto that monitor first, then press Ctrl+Alt+Break.

What you should see: the VM's own desktop and taskbar. If the screen stays black after the graphics share is turned on (Step 1), use the window's **View** menu and untick **Enhanced session** (that gives the plain "Basic session"). If it is still black, see "If a step says FAIL".

Tip: in a normal (Enhanced) session, copy and paste work between the main PC and the VM, so you can copy a command here and paste it inside the VM. In Basic session they do not; you would type the short commands instead.

### 0C. Open an administrator PowerShell INSIDE the VM
Same as 0A, but inside the VM window. If the VM asks for a password in the permission box, type the VM user's own password (the one you sign in with). The title must say **Administrator: Windows PowerShell**.

### 0D. How to read what the scripts print
- Green lines (OK, DONE) are good. Yellow lines (WARN, SKIP) are things to read, usually not bad. Red lines (FAIL) mean that part did not work.
- Every script ends with a line `log file: ...` that tells you where the full record is. Main PC logs go to `C:\claudecode\dark raiders\tools\migrate\logs`. VM logs go to `C:\PillagersMove\kit\logs`.
- Every script is safe to run again. If something fails, fix the cause and run the same command again.
- Every script has a **-DryRun** version. It prints what it WOULD do and changes nothing. Always run that first.
- Nothing prints a password or key. If you ever see one, stop and tell Claude.

---

## PART 1 - Preparation (Pillagers keeps running on the main PC)

### Step 1 - Boost the VM [MAIN PC, administrator window]
What it does: gives the VM 12 GB of memory and 12 processors, shares 80 percent of your Radeon graphics card with it, makes the file-copy channel work, and sends the setup kit into the VM (to `C:\PillagersMove\kit`). It also reads your main PC's look and settings (read only) so the VM can copy them. It shuts the VM down for a moment and starts it again, but only when a setting really has to change: if the VM already has everything, it is left running.

First look, nothing changes (1-2 minutes):

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-vm-boost.ps1" -DryRun
```

You should see a list of what it would change (memory, processors, graphics share) and a line about how much memory it can give. Then do it for real (15-30 minutes: it builds the graphics driver package, shuts the VM down, changes it, starts it, and sends files):

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-vm-boost.ps1"
```

You should see: green OK lines, "kit: N file(s) copied", "driver pack sent", then a block called **NEXT, inside the VM**.

Things that may happen:
- It says the VM has **checkpoints** (save points). A graphics share does not work with them. Your choices: run it again with `-RemoveCheckpoints` added, or add `-NoGpu` (keep checkpoints, skip the graphics share, slower). `-RemoveCheckpoints` merges the save points into the VM's disk for good, so before it deletes anything it EXPORTS the whole VM, checkpoints included, to a folder named `export-before-checkpoint-removal-<time>` next to the VM's disk. It checks first that there is room for that export (the size of the VM's disk files plus 20 GB) and stops without deleting anything if there is not. You can delete that folder later when you are sure. Add `-SkipExportBackup` only if you do NOT want that rollback copy (the checkpoints are then gone for good). `-BackupVhdx` additionally copies the VM's disk after the changes.
- It says Windows in the VM did not shut down in time (after 240 seconds): it stops there and changes nothing. Sign in to the VM, shut it down yourself (Start, Power, Shut down), then run the same command again. `-ShutdownTimeoutSec 600` waits longer. `-ForcePowerOff` cuts the power instead; it is off by default because it loses unsaved work in the VM and can damage its disk. Use it only on a VM that holds nothing you need.
- The look export (below) asks winget nothing on your behalf: the package-source terms are accepted only if you add `-AcceptSourceAgreements` yourself.
- It says it can only give **10 or 8 GB** instead of 12. Pillagers is still using memory on the main PC. That is fine for now; you raise it on switch-over day (S3).
- It says "waiting for the file-copy channel". Open the VM window (0B) and sign in once, wait a minute. It continues by itself, or run the same command again.

### Step 1B - Read your main PC's look on its own (optional) [MAIN PC, normal window]
Step 1 already does this for you. Run it by hand only if you changed your wallpaper, theme or language afterwards and want the VM to copy the new look. It reads Windows settings and changes nothing on the main PC:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-settings-export.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-settings-export.ps1"
```

- It writes into `C:\Users\User1\AppData\Local\PillagersMove\settings`, OUTSIDE the game folder, so a ship can never publish your desktop picture, Start pins or program list. `-OutDir PATH` picks another folder (the push scripts only look in the default one).
- It records whether your desktop is a picture or a solid colour, and the VM copies exactly that. It also records the region format, system locale and home location. It does not copy the power plan (the VM sets its own) or `start-layout.json` (Windows 11 uses `start2.bin`).
- `-AcceptSourceAgreements` passes winget's source-terms flag. It is off unless you add it; without it the program list falls back to the Store app names.
- Older copies of `start2.bin`, `wallpaper.jpg` and `host-settings.json` from an earlier run already sit in the game repository, and so in the public GitHub history (the repository is public). The scripts warn about this and print the one command that stops tracking them (`git rm --cached ...`). They never run it for you. Run it yourself if you want those files out of future ships; they stay in the old history.

### Step 2 - First push of your files [MAIN PC, administrator window]
What it does: packs the Pillagers files (the game, its history, the helpers, Claude's memory notes, your Desktop "dark raiders" folder, the scratch folder with the ship scripts, the newest game builds) into archive files and sends them into the VM. It never packs sign-in files, keys, browser profiles or the old test junk; anything that looks like a key is left out and only its name is logged. The archives are kept outside the game folder (`C:\Users\User1\AppData\Local\PillagersMove\out`), so a ship can never commit them, and `tools\migrate\.gitignore` keeps the kit's own logs, state and generated files out of every ship too.

This first pass is a rehearsal and a head start: Pillagers is still running here, so the copy will be a little stale. The final push on switch-over day brings it up to date.

First look (a few minutes). You can even do this in a normal window:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-push-files.ps1" -DryRun
```

You should see the groups and their sizes and a total. It also checks that the main PC has 20 GB free and the VM has 10 GB free; if it says the VM disk is too small, see "If a step says FAIL". Then for real, in the administrator window (30-90 minutes depending on the total; leave it running and do something else):

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-push-files.ps1"
```

You should see "[1/N] sending ... sent in N s" for each archive, then "sent manifest.json", then **DONE**.

Optional extras, only if you want them (they make the push much bigger):
- `-IncludeTranscripts` (about 3.4 GB) lets you resume old Claude conversations in the VM. Not needed: the memory notes carry everything that matters.
- `-IncludeOldBuilds` (about 6 GB) sends game builds older than v30. Do this one last, or never.

### Step 2B - Optional: send the Claude conversation and memory ahead [MAIN PC, then IN THE VM]
What it does: builds one small zip (the Claude conversation, the Claude memory notes, the notes in your Desktop "dark raiders" folder, and this kit), sends it into the VM, and unpacks it there, so a Claude window in the VM can start with the same memory. The big files (game, history, builds) still go through Step 2. Three scripts, each with a `-DryRun`:

1. [MAIN PC, normal window] build the pack. It copies every file to a private snapshot first (the live conversation is still being written), scans the snapshot with the same secret rules as the file push, and LEAVES OUT any file whose name or content looks like a key or login. It prints only the file's name and the kind of pattern, never the text. The zip, a `pack-manifest.json` (size and SHA-256 of the zip) and a copy of `unpack-session.ps1` go to `C:\Users\User1\AppData\Local\PillagersMove\out\pack`, outside the game folder. Build it again right before pushing: it is a snapshot.

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\build-pack.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\build-pack.ps1"
```

2. [MAIN PC, administrator window, VM running] send it. It checks the zip against the manifest first and refuses a pack that does not match. The only change to the VM is turning on its file-copy channel if that is off. Files land in `C:\PillagersMove`.

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\push-pack.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\push-pack.ps1"
```

3. [IN THE VM, normal window] unpack it. Look first, then for real:

```powershell
powershell -ExecutionPolicy Bypass -File C:\PillagersMove\unpack-session.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File C:\PillagersMove\unpack-session.ps1
```

What the unpack does and does not do:
- It checks the zip's SHA-256 against `pack-manifest.json` (a wrong fingerprint is never used). With no manifest it stops unless you add `-Force`.
- Per file: a missing file is copied; an identical file is left alone; a file the VM already has in a NEWER version is kept; an older VM file is first moved to `C:\PillagersMove\undo\unpack-<time>\` and then replaced. Nothing is deleted. It is safe to run twice.
- It never writes a file with a login-looking name, and never takes `host-stopped.txt` or `kit-manifest.json` from the pack (the main PC sends those on its own).
- It resumes the OLD conversation only when `C:\PillagersMove\kit\host-stopped.txt` is valid (Step S4 puts it there). Before that it opens a FRESH Claude window instead and tells you to paste `VM-CLAUDE-FIRST-MESSAGE.md` as the first message, so nothing in the VM believes it may ship while the main PC still runs. `-Force` resumes anyway; `-NoOpen` opens no window.
- If Claude Code is not installed it asks first (Y or N), downloads the official installer to a file, shows its size and fingerprint, then runs it. `-InstallClaude` answers yes in advance. If that fails it tries `winget install --id Anthropic.ClaudeCode --exact --source winget` interactively (winget asks its own licence questions; that package id is the one in Anthropic's own setup docs, checked 10-19, and the agy id Google.AntigravityCLI was found on the Flutter docs and a winget listing the same day).
- The log is `C:\PillagersMove\kit\logs\unpack-session-<time>.log` (names only).
- An old `pillagers-session-pack.zip` in `tools\migrate\out` is NOT used any more (it was never scanned and holds old kit files). You can delete it yourself; it holds your private conversation.

### Step 3 - Sign in to the VM and match its Windows version [IN THE VM]
1. Open the VM window (0B) and sign in with your VM password.
2. Windows in the VM must be exactly the same version as on the main PC, or the graphics share will not work. On the main PC press Windows key + R, type `winver`, Enter, and note the "OS Build" number (the main PC was on 26300.9711 when this was written; use whatever yours says today). Do the same inside the VM.
3. If the VM's number is lower: Settings, Windows Update, Check for updates, install everything, restart. Repeat until the build number matches. This can take two rounds (20-60 minutes).
4. Do not update Windows on the main PC while the move is going on. If the main PC updates later, the VM may need the same update (see "If a step says FAIL").

### Step 4 - Run vm-setup inside the VM [IN THE VM, administrator window]
What it does, in this order (it prints START for each stage, then DONE, SKIP or FAIL with the reason):

| Stage | In plain words |
|---|---|
| preflight | looks around: disk space, memory, internet, what arrived from the main PC |
| gpu | puts the AMD graphics driver files into the VM (needs a restart afterwards). It saves a copy of every Windows file it replaces first, so `-UndoGpu` can put them back |
| apps | installs Chrome, Git, Node, Python, PowerShell 7, 7-Zip, Claude, Claude Code, Codex, Gemini, and the Google checker (agy). Installs nothing until you add `-AcceptLicences` |
| debloat | removes consumer Windows apps and nags; writes undo files first |
| look | copies your main PC's look: dark theme, accent colour, taskbar, wallpaper (a picture or a solid colour, as on the main PC), mouse and keyboard, time zone, region and system locale |
| perf | high-performance power plan, no sleep, search index leaves the game folder alone |
| files | checks every archive against its fingerprint and unpacks it to the SAME paths as on the main PC. Refuses to overwrite game-folder work that was done in the VM (see S5) |
| services | sets up the helpers, the runner (behind a guard that checks the marker every time) and the servers. Refuses until the main PC is stopped (that is on purpose) |
| health | checks the tools and keys (names only), runs the Pillagers health sweep, prints your sign-in list |

Heads-up on the apps stage: it installs programs with the Windows installer (winget) and with the official installers of Claude Code and Google agy. Each program has its own licence and the winget sources have terms of use. Accepting those is YOUR decision, so without the switch `-AcceptLicences` the apps stage installs nothing: it prints the list and the line that tells winget you accept (the other stages still run). Run the dry run below and read the list; when you agree, add `-AcceptLicences` to the real run. If you would rather read and accept each licence yourself, leave it off (or use `-Skip apps`) and install those programs by hand.

What it never touches, no matter what: Microsoft Defender, the firewall, UAC, SmartScreen, Windows Update, BitLocker, and the virtualization security features. It never reads, prints, copies or logs a key or login file. The one thing it overwrites on its own is a handful of Windows graphics files (System32 and SysWOW64) from the driver pack, and it copies each original to `C:\PillagersMove\undo\gpu-orig` first (see "Going back").

First look (3-5 minutes, changes nothing):

```powershell
cd C:\PillagersMove\kit
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -DryRun
```

Then for real (40-90 minutes, mostly downloads and installs; leave it). This is the command that accepts the programs' licences, so add `-AcceptLicences` only after you read the list from the dry run:

```powershell
cd C:\PillagersMove\kit
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -AcceptLicences
```

What you should see at the end, under **SUMMARY**:
- preflight, gpu, apps, debloat, look, perf, files: DONE. (apps says REFUSED and installs nothing if you left out `-AcceptLicences`.)
- services: **SKIP**, with a message that the main PC is not marked as stopped. That is correct and expected for now. It protects you from two copies of Pillagers running at once.
- health: DONE (a few yellow lines are normal now; the health sweep runs in look-only mode until the main PC is stopped).
- A yellow line **RESTART THE VM when this run is over**. The script never restarts the VM for you.
- A yellow line saying the VM has 12 GB and the helpers want more. Ignore it for now (see "The numbers").

Optional switches (all off unless you add them; add them to the same command):
- `-AcceptLicences` you accept the programs' licences and the winget source terms yourself (see the heads-up above). Without it no program is installed.
- `-NoRunner` creates the "Pillagers runner" task but leaves it switched off.
- `-IncludeOptionalApps` also removes Phone Link, Sticky Notes, Mail and Calendar, Quick Assist and similar.
- `-LeanVisuals` switches off window and menu animations.
- `-DefenderExclusion` tells Defender not to scan `C:\claudecode`. That makes tests faster, but it is a real security trade-off, so it is off by default and your call (see "What stays yours").

### Step 5 - Restart the VM for the graphics card, then check it [IN THE VM]
1. Start menu, Power, **Restart** (not Shut down). 3-5 minutes. Sign in again.
2. Open an administrator PowerShell (0C) and run:

```powershell
cd C:\PillagersMove\kit
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -Only gpu,health
```

3. You should see a display adapter line naming your **Radeon** with status OK and problem code 0. Also open Chrome, type `chrome://gpu` in the address bar, and check that Canvas and WebGL say **Hardware accelerated**.
4. If the Radeon is missing or shows an error, the graphics share is not working. Nothing else depends on it; Pillagers still runs. See "If a step says FAIL", then decide whether to keep trying, run `vm-setup.ps1 -UndoGpu` in the VM (puts the original Windows graphics files back, then restart), or run `host-vm-boost.ps1 -Undo` / `-NoGpu` on the main PC.

### Step 6 - Your sign-ins and keys [IN THE VM] (only you can do these)
The health stage printed a SIGN-IN CHECKLIST. It lists what is missing without ever reading a login. Do these in a normal PowerShell window in the VM (not administrator):

1. **Claude Code** - type `claude`, press Enter, then type `/login`. A browser window opens; sign in with the Claude account you use for Pillagers (not your work account). Then type `/exit`.
2. **Claude desktop app** - open Claude from the Start menu and sign in. Not essential for the helpers.
3. **ChatGPT / Codex** - type `codex`, choose **Sign in with ChatGPT**. Never choose the API key option.
4. **Google checker (agy)** - type `agy` and sign in with your Google account. (If `agy` is not found, run `& "$env:LOCALAPPDATA\agy\bin\agy.exe"`.)
5. **GitHub** - the repository is public, so downloading from it (`git fetch`) never asks you to sign in, and a fetch proves nothing about signing in. The sign-in window (Git Credential Manager) opens the first time something is SENT to GitHub. To do it now without sending anything, run this once and choose to sign in with your browser; it talks to GitHub the way a push does, so the window opens, but it uploads nothing:

```powershell
git -C "C:\claudecode\dark raiders" push --dry-run origin master
```

If no window opens, nothing is wrong: the first real ship asks. `vm-verify.ps1` (K7) tells you whether a GitHub sign-in is stored, by name only.

6. **API keys** - only if you use them. Run this yourself; the key you paste stays hidden and is saved under a PILLAGERS_ name. Claude never sees it:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\ai-keys.ps1"
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\ai-keys.ps1" gemini
```

The first command only shows which keys are set. The second asks for the Gemini key; other names are `openai`, `xai`, `openrouter`, and for your Anthropic Console account `console` (your normal Console API key, saved as `PILLAGERS_API_KEY`, used by the Console helper lanes) and `admin` (your Anthropic Admin key, saved as `PILLAGERS_ADMIN_KEY`, used by the real-spend cost report). The two Anthropic slots cannot be swapped by mistake: the script looks at the start of what you paste (never shows it) and refuses the wrong kind. See K3. Never use the names ANTHROPIC_API_KEY, OPENAI_API_KEY or CODEX_API_KEY; they make tools bill by the token instead of using your sign-in, and the health check warns if they exist.

If a helper says it is waiting for a key right after you saved it, sign out of the VM and in again once.

### Step 7 - Test the Xbox pads [MAIN PC and IN THE VM]
The honest truth: nobody has proven that Xbox pads work inside a Hyper-V window on this exact PC. The VM window is built for keyboard and mouse and very probably does not pass game pads through. So test early, and have a plan that does not depend on the answer.

The test:
1. Plug both Xbox pads into the MAIN PC. Open the VM window in a normal (Enhanced) session.
2. Inside the VM, open Chrome, search for `gamepad tester`, open any tester page, and press A on a pad.
3. If the page shows the button lighting up, pads pass through. If it shows nothing, they do not.

The options, best first:

1. **RECOMMENDED - play in the MAIN PC's own Chrome while the game runs in the VM.** The pads stay plugged into the main PC and work exactly as they do today, with your real graphics card, sound and 4K screen. A tiny forwarder program on the main PC makes `http://localhost:8802/dark_raiders.html` on the main PC show the game that runs in the VM (it forwards ports 8802 and 8799). On the party night nothing changes for you: Chrome, localhost, click the demo. It is already built (`play-relay.mjs` and `host-play-relay.ps1` for the main PC, `vm-pad-route-firewall.ps1` for the VM); K4 and K5 in Part 3 say how to set it up and test it. The cost: the VM needs one firewall allow-rule that lets only the main PC reach those two ports. That rule is yours to approve and run (see "What stays yours"). Nothing uses the old 8802 server on the main PC any more, because host-stop turns it off.
2. **Fallback for the Fri 10/30 party - play on the main PC from a frozen copy.** After the Thu 10/29 lock, `party-host-copy.ps1` (K8) downloads the final version from GitHub into its own folder on the main PC and serves only the game and the run-report collector, at the same address. The VM can be off and the relay is not needed. This is the plain version of the same night and needs no tricks. Do NOT use `host-stop.ps1 -Undo` for this once the VM has started working; that turns the helpers back on too.
3. **Pass the pad's USB into the VM** with usbipd-win on the main PC and usbip-win2 inside the VM. It is reported to work for some pads and is shaky on Windows client Hyper-V. Only try it if you want to play inside the VM window itself.
4. **RdpGamepad, or streaming the VM's picture (Sunshine plus Moonlight, or Parsec).** Adds delay, needs the graphics share working perfectly, and is a lot of fuss for a party. Not recommended.

Whichever you pick, test with both pads and both players before the party. Pad 1 is player 2 and pad 2 is player 1, as in the game.

---

## PART 2 - SWITCH-OVER DAY

Only start this when Part 1 is done and the Radeon check passed (or you decided to live without it). This is the moment Pillagers stops on the main PC and starts in the VM.

### S1 - Close the Pillagers Claude Code window on the main PC [MAIN PC]  (1 minute)
Close the Claude Code window you use for Pillagers on the main PC (type `/exit`, or close the window). Reason: that session checks in every 30 minutes and quietly restarts helpers when it finds them stopped. Left open, it would fight the VM. Your work Claude Code on this PC is not affected; it is a different session.

### S2 - Stop Pillagers on the main PC [MAIN PC]  (5-50 minutes, usually under 15)
This does not need an administrator window unless Windows says "Access is denied" for the scheduled task; if it does, run it again in an administrator window.

First look:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-stop.ps1" -DryRun
```

Then for real. It asks you to confirm: type `YES` (all capitals) and press Enter; anything else cancels and changes nothing:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-stop.ps1"
```

What it does, in 8 steps: puts up the stop signs so no new work starts, switches off the "Pillagers runner" scheduled task and the startup shortcut, stops the runner, lets helpers and any running ship finish by themselves (up to 20 minutes), stops the helpers, lanes, robots and reviewers, stops the hidden test browsers and the servers (the play server on 8802 and the collector on 8799 too), waits for the ship lock to clear (up to 30 minutes), checks that everything is really stopped, and finally writes the marker file `host-stopped.txt` that tells the VM it is allowed to start. The marker ends with a `check=` line, a fingerprint of all the other lines. The VM accepts a marker only when it says exactly `status=stopped`, names the main PC, has the full 40-character commit and `shipLockClear=yes`, and its `check=` line matches. A marker that is missing, empty, edited by hand, cut short or glued together from two runs is refused.

It never touches your normal Chrome, the Claude desktop app, any Claude Code session of yours, Ollama (unless you add `-StopOllama`), Windows settings or security settings.

You should see: eight "Step N of 8" blocks, STOPPED lines, then **DONE. Pillagers is stopped on this PC.**

If it says **NOT FINISHED** and wrote no marker: read the line above it (something is still running or locked) and run the same command again; it is safe to repeat. A ship that is still running after the wait is never interrupted: the script stops there (exit code 2) and touches nothing more. If the ship lock will not clear after waiting, add `-ClearStale`, which asks the official tool whether the lock is really stale. If someone is connected to the play server (8802) or the collector (8799) right now, it asks before stopping them (`-Yes` skips that question).

### S3 - Give the VM its full memory [MAIN PC, administrator window]  (5-10 minutes; skip if Step 1 already said 12 GB)
Now that Pillagers is off, the main PC has memory to spare. This brings the VM up to the full amount; it shuts the VM down for a minute and starts it again. If everything already matches, it does nothing.

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-vm-boost.ps1" -NoPush
```

Since the main PC will now only play games and run your work Claude Code, you can go bigger for the helpers. Optional:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-vm-boost.ps1" -MemoryGB 16 -NoPush
```

### S4 - Final push of the files [MAIN PC, administrator window]  (20-60 minutes)
Packs everything again, now that nothing changes any more, and sends it, plus the `host-stopped.txt` marker as the very last thing. It refuses if Pillagers is not stopped (a missing or invalid marker, a changed git commit, a runner, helper or ship running, a held ship lock, or a Pillagers scheduled task switched on again). The pack also carries a list of every repository file (`repo-files.txt`, with its own fingerprint) so the VM can tell which files are leftovers from the first pass.

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-push-files.ps1" -Final
```

You should see: archives sent, "sent manifest.json", "sent host-stopped.txt ... the VM may now start the runner and helpers", **DONE**.

If the archives were built earlier and only the sending failed, `host-push-files.ps1 -PushOnly -Final` sends what is already staged. It first re-checks every archive's size and fingerprint, and it refuses a set that was not built by a `-Final` run, that was built at a different git commit than the marker names, or that is older than the marker.

### S5 - Finish the setup inside the VM [IN THE VM, administrator window]  (10-20 minutes)
This unpacks the final files, sets up the helpers and starts the servers, and runs the health sweep.

```powershell
cd C:\PillagersMove\kit
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -Only files,services,health
```

You should see: files DONE, services DONE (it lists the play server 8802, the dev console 8820 and the collector 8799 as answering, and says "the runner is alive"), health DONE. Two new desktop shortcuts appear: **Pillagers Dev** (the dashboard) and **Claude Code - Pillagers**.

If services says **REFUSED** or SKIP: the marker is missing, is not accepted (the line says why), or says the main PC is running again. Do S2 and S4 again. Do not use `-Force` unless you are certain the main PC is stopped.

Good to know:
- **The files stage will not overwrite work done in the VM.** S5 unpacks the game folder a second time (the first time was Step 4). That is allowed only while the VM's game folder is exactly as the first unpack left it (the same git commit and the same list of changed files, remembered in `C:\PillagersMove\state\repo-baseline.json`). If you or Claude changed or committed anything in `C:\claudecode\dark raiders` in the VM in between, it says `REFUSED to unpack ... VM repo changed since the last unpack` and overwrites nothing. If the work matters, commit and push it first. If it is only test runs, run `vm-setup.ps1 -Only files,services,health -Force` to overwrite. Running the files stage twice without VM-side changes is fine.
- **Leftover files are reported, not deleted.** After the final unpack the files stage lists files in the VM game folder that the final copy from the main PC does not contain (leftovers of the first push, or files made in the VM) in `C:\PillagersMove\state\extra-files.txt`. Look at the list and decide; the script never deletes them.
- **The runner starts through a guard.** The "Pillagers runner" task runs `C:\PillagersMove\launchers\runner-guard.ps1` every 15 minutes. The guard starts the runner only while `host-stopped.txt` is a valid stopped marker, so if you later switch Pillagers back on on the main PC (`host-stop.ps1 -Undo` sends a "revoked" marker), the VM stops starting the runner at the next tick. It writes one line per tick to `C:\PillagersMove\launchers\runner-guard.log`. To pause the runner by hand, create an empty file `C:\PillagersMove\launchers\RUNNER-OFF.txt` there (delete it to let the runner start again). The "Pillagers dev services" task (the servers and the dev console) is not guarded on purpose: it ships nothing.

### S6 - Give Claude its first message [IN THE VM]  (5 minutes, then Claude works for ~10)
1. Double-click **Claude Code - Pillagers** on the VM desktop.
2. Open the message file in Notepad, select everything between the two marker lines, copy it:

```powershell
notepad C:\PillagersMove\kit\VM-CLAUDE-FIRST-MESSAGE.md
```

3. Paste it into the Claude Code window and press Enter.
4. Claude will confirm it is on the VM and not on the main PC, read the memory and handoff, run the health sweep and fix what it finds, re-arm its 30-minute check-in, and tell you in plain words what is running and what is yours to do. If it says a sign-in is missing, that is Step 6.
5. For the pad route nothing has to be built any more: the relay and the firewall-rule script already exist (K4 and K5 in Part 3). Claude does not run any firewall command. If you have not done K4 yet, you run `vm-pad-route-firewall.ps1` yourself in an administrator PowerShell in the VM (0C); it prints the one rule and the command that removes it again before it asks you to type YES.
6. Claude runs `vm-verify.ps1` (K7) on its first pass and works through every FAIL line it prints. The lines marked WAIT are yours or come later; it tells you which.

### S7 - From now on [BOTH]
- Work on Pillagers only inside the VM. Open Claude Code from the desktop shortcut there.
- On the main PC, do not start Pillagers helpers, the runner, ships or the old servers. Do not run `party-start`. The main PC is for your work Claude Code and for playing.
- The memory notes and handoff in the VM are now the live copy. The copy on the main PC is frozen.
- Only one machine ever ships to GitHub. That is now the VM.

---

## PART 3 - Keeping everything working after the move

Moving the files is only half of it. On the main PC four things were free because everything shared one computer: the local AI on the graphics card, the settings and keys, playing with the Xbox pads, and "it is simply on". With Pillagers in the VM each of them needs one small, visible piece. All the pieces are built and checked; none of them runs by itself, and none is done for you without you seeing it.

Two of them change a firewall (K1 on the main PC, K4 in the VM). Those are scripts YOU run in an administrator window. Each prints the exact change first, waits for you to type `YES` yourself (a script that tries to type it for you is refused), and has an undo. Claude never runs them, and it never changes Defender, UAC, SmartScreen, Windows Update or BitLocker. A password is typed only by you, only into Windows' own Autologon window (K6).

| # | Where | What | When |
|---|---|---|---|
| K1 | MAIN PC, administrator | Let the VM use the main PC's Ollama (the local AI) | any time after Step 1; before S2 is best |
| K2 | IN THE VM, normal | The VM's own settings: where the Ollama is, Claude on the PATH | after K1 (before it, it just says "waiting") |
| K3 | IN THE VM, normal | Keys that do not travel: the Console key and the Admin key | with Step 6 |
| K4 | IN THE VM, administrator | Pad route, the VM's half: one firewall rule | before you test the pads (Step 7) |
| K5 | MAIN PC, normal | Pad route, the main PC's half: the relay and its shortcuts | try early on a test port; install after S2 |
| K6 | both | The VM comes back by itself: auto-start and auto sign-in | after Step 5 |
| K7 | both | The must-pass lists: `vm-verify.ps1` and `host-verify.ps1` | before S2, after S5, and whenever something feels off |
| K8 | MAIN PC, normal | The party fallback: a frozen copy of the game on the main PC | prepare after the Thu 10/29 lock |

The scripts named here sit in `C:\PillagersMove\kit` inside the VM and in `C:\claudecode\dark raiders\tools\migrate` on the main PC. If one is missing in the VM, run the Step 1 command again: when the VM's settings already match, it only sends the kit again.

### K1 - Let the VM use the main PC's Ollama [MAIN PC, administrator window]  (5 minutes)
What it is for: Ollama is the local AI on your graphics card that the audit helpers (`ship-review.ps1`, `llm-night.ps1`, the Dev Console) ask. It lives on the main PC. The VM can only reach it over the Hyper-V "Default Switch" network, and Ollama normally answers only the PC it runs on.

What `host-ollama-bridge.ps1 -Install` does, three things:
1. Adds ONE inbound firewall rule named "Pillagers Ollama for VM": TCP 11434, only from the Default Switch network (192.168.160.0/20 today, read from the live switch), only on that network card, only for `ollama.exe`.
2. Sets YOUR user variable `OLLAMA_HOST` to `0.0.0.0:11434`. What was there before is remembered, and `-Undo` puts it back. (Ollama takes only one address, and binding just the switch address would cut off the tools on this PC that use 127.0.0.1.)
3. Stops Ollama and starts it again as you (not as administrator) so it picks the setting up. `-NoRestart` leaves that to you.

What it exposes, plainly: Ollama has no password. Afterwards anything inside a VM on this PC's Default Switch can ask your Ollama for its model list and use your graphics card. Computers on your Wi-Fi, home network or VPN cannot, as long as the Windows Firewall does its job. That is why `-Install` first READS the firewall and REFUSES (nothing is changed, exit code 2) when: the firewall is off or cannot be read for Domain, Private or Public; any profile lets inbound connections in by default; another enabled rule already lets other computers reach `ollama.exe` or port 11434; or the Default Switch network card cannot be found (start the VM once, or open Hyper-V Manager, then try again).

Look first (a normal window is enough; nothing changes):

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-ollama-bridge.ps1" -Status
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-ollama-bridge.ps1" -Install -DryRun
```

Then for real, in the administrator window. It prints the rule and the warning above and waits: type `YES` and press Enter yourself (there is no switch that answers for you):

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-ollama-bridge.ps1" -Install
```

You should see: OK lines, then "answers on the Default Switch address". If Windows shows "Allow Ollama on networks?", do NOT tick Private or Public (that would let your Wi-Fi in); close the window without allowing. Pressing Cancel there can make Windows add a BLOCK rule for Ollama, which beats the allow rule; `-Status` lists such a rule and prints the exact command that removes it.

To undo: the same command with `-Undo` (removes the rule, puts `OLLAMA_HOST` back, restarts Ollama so it listens on this PC only again). Your other tools that call 127.0.0.1:11434 keep working the whole time.

### K2 - The VM's own settings [IN THE VM, normal window]  (2 minutes)
No administrator window needed: it changes only YOUR user settings in the VM. Four small steps, safe to repeat:
1. Sets your user variable `PILLAGERS_OLLAMA_URL` to `http://192.168.160.1:11434` (the main PC's Ollama). The helpers read it; without it they look for an Ollama inside the VM, which does not exist. Only a private address is accepted. If the switch network ever changed, it reads the right address from the VM's default gateway and says so (`-HostIp` forces one).
2. Adds the Claude Code folder to your user PATH, so `claude` works in any new window. The old PATH value is written to the log before it changes.
3. Prints the NAMES (never the values) of helper keys still missing, and the command that asks you for each.
4. Asks the main PC's Ollama for its model list (3 seconds at most) and prints PASS, or "waiting for host-ollama-bridge.ps1" when K1 is not done yet.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\PillagersMove\kit\vm-user-settings.ps1" -DryRun
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\PillagersMove\kit\vm-user-settings.ps1"
```

Exit code 0 = done and PASS, 2 = done but the main PC is not answering yet (do K1, then run it again), 1 = could not do it. Programs that were already running keep the old values; the runner restarts its lanes every 15 minutes, so open a new PowerShell window or sign out of the VM and in again to be sure. It refuses to run on the main PC (it has the Hyper-V service), and the dry run and the main-PC case write no log.

### K3 - Keys that do not travel [IN THE VM, normal window]  (3 minutes, only if you use those helpers)
Keys never travel with the files; you type them again in the VM. The two Anthropic ones now have their own slots in `ai-keys.ps1`. Run each yourself; what you paste stays hidden, and Claude never sees it:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\ai-keys.ps1" console
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\ai-keys.ps1" admin
```

- `console`: your normal Anthropic Console API key, saved as `PILLAGERS_API_KEY`. The Console helper lanes use it.
- `admin`: your Anthropic ADMIN key, saved as `PILLAGERS_ADMIN_KEY`. Only the real-spend cost report uses it.
- The script refuses the wrong kind in each slot (it looks only at the start of what you paste, never shows it). A key typed on the command line instead of pasted at the prompt is refused and not echoed back; if that was a real key, make a new one at the provider, because the old one is now visible in that window.
- Never ANTHROPIC_API_KEY, OPENAI_API_KEY or CODEX_API_KEY: `vm-verify.ps1` fails if they exist.

### K4 - Pad route, the VM's half: one firewall rule [IN THE VM, administrator window]  (3 minutes; you run it)
Why: the relay on the main PC (K5) connects to ports 8802 (the game) and 8799 (run reports) inside the VM, and the VM's firewall blocks inbound connections by default.

What `vm-pad-route-firewall.ps1` adds: ONE inbound rule named "Pillagers pad route": allow, TCP, ports 8802 and 8799 only, from the main PC's address ONLY (normally 192.168.160.1), all network profiles. Nothing is opened to "Any". It takes the main PC's address from the VM's default gateway, but only when that gateway is on the Hyper-V Default Switch (192.168.160.0/20, or an adapter whose DNS suffix is `mshome.net`). If the gateway is anything else (a router on a bridged network), it refuses and asks you to give the address yourself with `-HostAddress`. It refuses to run on the main PC and writes nothing there.

```powershell
powershell -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-pad-route-firewall.ps1 -Status
powershell -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-pad-route-firewall.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-pad-route-firewall.ps1
```

The first two change nothing. The third prints the exact `New-NetFirewallRule` command and the command that removes it, then waits for you to type `YES`. You should see "The rule is in place" and what Windows reads back. A log is written only when the firewall really changes. If the main PC's Default Switch address changes (it can after a reboot), run it again; it replaces the rule. To undo: run it with `-Undo`, or `Remove-NetFirewallRule -DisplayName 'Pillagers pad route'`.

Optional, normal window: `vm-address-report.ps1` shows the VM's address and the name the main PC uses to find it (`VM_Oct2026.mshome.net`), and whether the rule is there. Only if the main PC says it cannot find the VM, copy the one line it prints under "ONLY IF THE MAIN PC CANNOT FIND THIS VM" and run it on the main PC.

### K5 - Pad route, the main PC's half: the relay [MAIN PC, normal window]  (10 minutes)
What it is: `host-play-relay.ps1` runs `play-relay.mjs`, a small Node program (no administrator needed) that makes `http://localhost:8802/dark_raiders.html` and port 8799 on this PC show the game that runs in the VM. It listens on 127.0.0.1 only, so nothing on the network can reach it, and it passes the connection through without reading it. Chrome on the main PC then sees the game at "localhost", which the browser treats as a safe page, so the Xbox pads work as they do today (a plain VM address would not).

Look first (changes nothing):

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-play-relay.ps1" -Status
```

Try it BEFORE the switch-over without touching your own running server (needs K4 done and the VM's servers running). It listens on a different port here and forwards to the VM's real one:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-play-relay.ps1" -Start -Ports 18802:8802
```

Open `http://localhost:18802/dark_raiders.html` in Chrome (the browser treats that as a different site, so it has its own saved data), plug in both pads, play. Stop the test with `-Stop`.

After S2 (the main PC stopped), make it permanent:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-play-relay.ps1" -Install
```

It puts a Startup shortcut "Play relay (VM)" (the relay then starts at every logon) and a desktop shortcut "Pillagers play" that opens the game address in Chrome, and starts the relay now. It refuses until `host-stopped.txt` is valid and ports 8802 and 8799 on this PC are free, so it can never take over your own server while Pillagers still runs here. The same marker check applies to any relay that would listen on 8802 or 8799, however `-Ports` is written; only a test on other ports skips it. At logon the shortcut does nothing unless the marker says stopped. `-Uninstall` stops the relay and removes exactly those two shortcuts. Do not use `-Force` to get around the marker.

You should see: "The relay is running ... localhost:8802 -> VM port 8802" and "The VM is at ..." (found by its name). If the game page says "the vm is not answering", the VM is off or the K4 rule is missing. Test with both pads and both players before the party: pad 1 is player 2 and pad 2 is player 1, as in the game.

### K6 - The VM comes back by itself [BOTH]  (15 minutes, once)
Two halves:

**The VM starts when the main PC starts [MAIN PC].** Step 1's `host-vm-boost.ps1` sets the VM's Automatic Start Action to "Start" with a 60 second delay, and its stop action to a clean shutdown with this PC. If you ever see `host-verify.ps1` complain about it, run the Step 1 command again, or in Hyper-V Manager: right-click the VM, Settings, Management, Automatic Start Action, "Always start this virtual machine automatically", delay 60 seconds.

**The VM signs itself in [IN THE VM, normal window].** The runner, the servers, headless Chrome and the Console lanes all live in your signed-in Windows session in the VM. After ANY restart (a Windows Update, a power cut, the main PC rebooting) Windows stops at the sign-in screen and nothing runs until somebody types the password. `vm-autologon.ps1` fixes that with Microsoft's own Sysinternals Autologon tool:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-autologon.ps1 -DryRun
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-autologon.ps1
```

The first line changes nothing. The second asks you to type `YES` before it downloads Autologon (only if it is not installed; the program must carry a valid Microsoft signature or the script refuses to open it), then opens Autologon in ITS OWN window. Windows asks permission: click Yes. YOU type the VM user's password into Autologon's Password box and click Enable. The script only waits for that window to close; it cannot see the box, never asks for, stores or logs the password, and Claude never does this step. Afterwards it reads three Windows settings to confirm.

Then test it once, watching: Start menu, Power, Restart. Do not type anything at the sign-in screen. The desktop should appear on its own within about 5 minutes. Wait about 2 minutes more and run `vm-verify.ps1` (K7): "signs in by itself" must be PASS, the servers must answer, and the runner heartbeat is fresh again within about 25 minutes.

Things that block it, which the script checks and reports but never changes: the Windows setting "only allow Windows Hello sign-in for Microsoft accounts on this device" (switch it off in Settings, Accounts, Sign-in options), a legal notice shown before sign-in, and holding Shift while the VM boots. If you change the Windows password later, run it again with `-Reconfigure`.

The weak point, said plainly: Windows keeps the password encrypted, but an administrator inside the VM can still read it, and the VM's sign-in screen no longer stops anyone who reaches the VM's console. That console is reachable only through Hyper-V Manager on the main PC, and the VM already holds your Claude, GitHub and Console sign-ins, so little is added. If that is not acceptable, run `vm-autologon.ps1 -Undo` and sign in by hand after every restart.

Optional, `-ResumeClaude`: also puts a shortcut in the VM's Startup folder that reopens the coordinator Claude Code after each sign-in (it continues the last conversation). The shortcut is only made once `host-stopped.txt` is valid, and the message it types first makes Claude check the marker again and start nothing when it is not valid, so it can never start a second shipper while the main PC still runs Pillagers. Use it after S4. Without it you open Claude Code from the desktop shortcut after a restart; the runner and the lanes keep working either way.

### K7 - The must-pass lists: vm-verify and host-verify [BOTH]  (2 minutes each)
Two read-only checks, one inside the VM and one on the main PC. Each prints one line per item and ends with a count and one verdict line. Neither starts, stops or changes anything; the only thing they write is their own log.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-verify.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-verify.ps1"
```

The first runs in the VM, the second on the main PC; both in a normal window. Add `-DryRun` to list the checks without testing, `-NoNetwork` to skip the GitHub and Ollama requests.

- **PASS**: right. **FAIL**: wrong; the `fix:` line under it says how. **WAIT**: not wrong yet; it is a step that is yours, or that cannot happen until an earlier step is done (a sign-in, a key, the switch-over itself). **WARN**: worth a look, not a failure (the graphics card and the pad-route pieces).
- Exit code: 0 = no FAIL and no WAIT, 1 = at least one FAIL, 2 = no FAIL but something is WAIT.

The rule for using them:
1. **Before S2 (stopping the main PC)**: run `vm-verify.ps1` in the VM. Everything that can be true by now must be PASS: the tools, the keys, git and the GitHub sign-in, the servers, the Ollama request, the disk and memory. The lines that depend on the switch-over (the marker, the runner heartbeat, the last ship) show WAIT; that is fine. Any FAIL means do not stop the main PC yet: fix it first (the fix line says whether it is Claude's job or yours).
2. Also before S2, run `host-verify.ps1` on the main PC. The VM line, the Ollama bridge lines and (once K5 is done) the pad-route lines should be PASS. The lines about "no Pillagers program runs on this PC", "the scheduled tasks are off" and the marker will FAIL or WAIT, because Pillagers still runs here. That is exactly what S2 turns around.
3. **After S5**: run both again. Both must end with no FAIL and no WAIT.
4. From then on the VM's Claude runs `vm-verify.ps1` at every check-in and works through every FAIL line by itself. You run `host-verify.ps1` after anything that touches the main PC (a Windows update, a restart).

A normal window is often not allowed to read Hyper-V; `host-verify.ps1` then says WAIT for the VM lines and tells you how to read them (an administrator window, or Hyper-V Manager). It sends a request only to the relay itself, never to your own play server or collector.

### K8 - The party fallback: a frozen copy on the main PC [MAIN PC, normal window]  (1-2 minutes to prepare)
Why: if anything about the VM or the relay is in doubt on Fri 10/30, the party must not depend on it. `party-host-copy.ps1` keeps a frozen copy of the game in its own folder on the main PC (`C:\claudecode\pillagers-party`) and serves it at the same address, `http://localhost:8802/dark_raiders.html`, with the run-report collector on 8799. It needs nothing from the VM: no relay, no running VM, and no internet once the copy is prepared. It never touches `C:\claudecode\dark raiders`.

When: after the Thu 10/29 lock, once Claude in the VM has pushed the final version and told you the tag or commit. A rehearsal a few days earlier is a good habit: prepare, start, play, stop.

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\party-host-copy.ps1" -Status
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\party-host-copy.ps1" -Prepare
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\party-host-copy.ps1" -Start
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\party-host-copy.ps1" -Stop
```

- `-Status` looks only. It asks the game port a question only while the copy's own servers are running.
- `-Prepare` needs the internet (about a minute) and no login: it downloads only the game file and the two small servers from the public GitHub repository. `-Ref` picks a tag or a full 40-character commit instead of the newest; `-Full` takes the whole history (about 800 MB). Run it again later to bring the copy forward; it only fast-forwards and refuses to overwrite edits. It accepts only `https://github.com/...` addresses, refuses any Pillagers working folder as the copy folder, and updates only a git folder it made itself.
- `-Start` stops the play relay if it runs, then serves the copy. It will not stop your own servers (host-stop.ps1 did that at S2) and refuses if something else already uses 8802 or 8799. Open `http://localhost:8802/dark_raiders.html` in Chrome as usual; `/stable.html` shows the same frozen build.
- `-Stop` stops those two servers; add `-RestartRelay` to get the VM route back afterwards.
- While the copy is served, do not run `host-stop.ps1` or `party-stop.ps1`: they recognise `tools\serve.ps1` in a command line and would stop it. And do not use `host-stop.ps1 -Undo` for the party; that turns the helpers back on too.

---

## The numbers: memory and processors, and why

Your main PC: Ryzen 7 5800X3D (8 cores, 16 threads), 31.9 GB memory, Radeon RX 7900 XTX.

| What | VM gets | Why |
|---|---|---|
| Memory | **12 GB**, fixed (not flexible) | A graphics share needs memory that does not move, so it cannot be "flexible". 12 GB runs Windows, Chrome test browsers, Node, the helpers and Claude comfortably. The script always leaves the main PC at least 6 GB free (it counts 6.5 to be safe), so if only 10 or 8 GB fits right now, it picks that and says so. After switch-over the main PC is idle, so you can raise it (16 GB is a good size). |
| Processors | **12** of your 16 threads | Leaves 4 threads for the main PC, so games, your work Claude Code and the VM window itself never starve. |
| Graphics card | **80 percent** share | The VM gets most of the card for Chrome and the game; the main PC keeps enough for its own screen. Change with `-GpuPercent`. |
| Disk | 128 GB, grows as needed | Set when the VM was made. The game, its history and the builds fit; very large extras (old builds, transcripts) may not. |

Why the helpers care: they wait until about 6 GB of the VM's memory is free before they start a new job (the runner's rule), and the setup script prints a yellow warning when the VM has under 14 GB. At 12 GB that warning is normal and the helpers still run, just with fewer test browsers at once. If the dashboard shows jobs waiting a lot, go to 16 GB (S3, second command).

---

## Going back (rollback)

- **Take the graphics share away / go back to the old VM size** [MAIN PC, administrator window]:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-vm-boost.ps1" -Undo
```

It removes the graphics share and puts the VM back as it was before the first boost (8 GB and 4 processors if it was never recorded). If the graphics share only gives trouble, `host-vm-boost.ps1 -NoGpu` is the gentler fix: memory and processors stay, the share is skipped.

- **Switch Pillagers back on on the main PC** [MAIN PC]:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-stop.ps1" -Undo
```

Run it in an administrator window and type `RESUME` when it asks (`-Yes` does not skip this question). It re-enables the scheduled tasks and startup shortcuts it switched off itself (and only those), removes the stop signs and the main PC's marker file, overwrites the VM's marker with a "revoked" note (so the VM refuses to start helpers from then on), and starts everything again through `party-start.ps1`. If the VM is running and the "revoked" note could not be delivered, it will NOT start Pillagers here unless you type `START ANYWAY`; the safe order is to stop the helpers in the VM first (below).

**Before you run that once the VM has done real work**, do these three things in order, or two machines will fight over GitHub and the main PC will be missing the VM's work:
1. In the VM, ask Claude to finish what it is doing, push everything to GitHub, and stop the helpers. Or do it yourself in an administrator PowerShell in the VM: `Disable-ScheduledTask -TaskName "Pillagers runner"` and `Disable-ScheduledTask -TaskName "Pillagers dev services"`, then sign out of the VM.
2. On the main PC, bring the game files up to date from GitHub: `git -C "C:\claudecode\dark raiders" pull`.
3. Then run `host-stop.ps1 -Undo`.
Things that are not in GitHub (Claude's memory notes, helper job folders) stay in the VM; ask Claude there to copy them back.

- **Put back the Windows graphics files in the VM**: `vm-setup.ps1 -UndoGpu` (administrator window in the VM) copies the originals back from `C:\PillagersMove\undo\gpu-orig`, removes the files the pack added, and asks for a restart. It refuses a record that points outside System32 and SysWOW64.
- **Undo the Windows tidying inside the VM**: `vm-setup.ps1` wrote undo files to `C:\PillagersMove\undo` before it changed anything (double-click a `.reg` file to put those settings back; the app lists say what was removed). It changes nothing on the main PC.
- **Throw the VM away and start over**: always possible; the main PC still has all its files.

---

## What stays yours

Claude and the scripts never do these for you:
- **Sign-ins**: Claude Code, Claude desktop, ChatGPT/Codex, Google (agy), GitHub (Step 6). The scripts only check whether a login file exists, never what is in it.
- **Keys**: you type them yourself with `tools\ai-keys.ps1` (hidden input). Claude never sees, prints, copies or logs one, and neither do the move scripts. Do not paste a key into any chat.
- **The Defender exclusion (optional, off by default)**: `-DefenderExclusion` tells Microsoft Defender to skip `C:\claudecode`. It makes tests faster but means a file there is no longer scanned. If you want it, run in the VM: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -Only perf -DefenderExclusion`.
- **Any firewall change**: `vm-setup.ps1`, `host-vm-boost.ps1` and the other move scripts never change the firewall, and Claude does not run a firewall command either. Only two small scripts do, and only when YOU run them in an administrator window: `vm-pad-route-firewall.ps1` in the VM (K4: one rule that lets only the main PC reach ports 8802 and 8799 inside the VM) and `host-ollama-bridge.ps1` on the main PC (K1: one rule that lets only the Default Switch network reach Ollama's port 11434). Each prints the exact change and the command that removes it, waits for you to type `YES` yourself, and refuses to be answered by a script.
- **Your Windows password for automatic sign-in**: you type it only into the Autologon window that `vm-autologon.ps1` opens (K6). The script cannot see it, and nothing logs it.
- **Licence agreements for the installed programs**: you accept them yourself by adding `-AcceptLicences` to the apps stage (Step 4 heads-up). Without it nothing is installed. The same goes for the winget source terms in the look export (`-AcceptSourceAgreements`).
- **The old personal files in the public repository**: `start2.bin`, `wallpaper.jpg` and `host-settings.json` are tracked by git and already public (Step 1B). Whether to stop tracking them (one `git rm --cached` command the scripts print) is your call; the scripts never change the git index.
- **Windows updates on the main PC**: yours to decide. If you update the main PC, update the VM to the same build afterwards.

---

## If a step says FAIL

First: a FAIL line always says what went wrong in plain words. Fix that, then run the same command again. Nothing is lost by running again.

| You see | What it means | What to do |
|---|---|---|
| "needs an administrator window" (exit code 3) | Not an administrator window | Reopen PowerShell as in 0A or 0C and run the command again |
| Boost: the VM has checkpoints | A graphics share does not work with them | Add `-RemoveCheckpoints` (merges the VM's save points into its disk) or `-NoGpu`; add `-BackupVhdx` for a safety copy first |
| Boost or push: "file-copy channel (Guest Service Interface) not ready", "the VM must be running" | The VM is not up or nobody signed in yet | Open the VM (0B), sign in, wait a minute, run the command again |
| Boost: VM will not start, or screen stays black after the graphics share | The share is not accepted | In the VM window View menu untick Enhanced session. If still black: `host-vm-boost.ps1 -Undo`, or `-NoGpu`. If Device Manager in the VM shows code 12, try `-HighMmioGB 48` |
| Boost: it picked 10 or 8 GB | Not enough free memory right now | Fine for now; run the S3 command after host-stop |
| Push: not enough room on the VM disk, or main PC free space | Disk is full | Free space, or ask Claude to grow the VM disk (a short job done with the VM switched off). For the main PC, the push needs 20 GB free |
| vm-setup preflight: "build X vs build Y" | VM Windows is a different version from the main PC | Step 3: Windows Update in the VM until the numbers match, then `vm-setup.ps1 -Only gpu` |
| vm-setup gpu: Radeon missing or error code 43 | Graphics share not working, usually a version mismatch | Match the builds, restart the VM, `-Only gpu,health`. If the main PC updated Windows or the AMD driver since, run on the main PC `host-vm-boost.ps1 -RebuildDriver -ResendDriver`, then `-Only gpu` in the VM, then restart |
| vm-setup apps: an install failed or "no internet" | The VM could not download | Check the VM can open a website; run `vm-setup.ps1 -Only apps` again |
| vm-setup apps: REFUSED, "you did not type -AcceptLicences" | By design nothing is installed until you accept the licences yourself | Read the list the dry run prints, then add `-AcceptLicences` |
| vm-setup files: "manifest.json is missing" or a fingerprint does not match | An archive did not arrive whole | On the main PC run `host-push-files.ps1 -PushOnly`, then `-Only files` in the VM. Do not use `-Force` for this |
| vm-setup files: REFUSED to unpack ... "VM repo changed since the last unpack" | The VM game folder has work (commits or edited files) made after the last unpack | Commit and push that work first; or, if it is only test runs, run `-Only files,services,health -Force` (see S5) |
| vm-setup: "host-stopped.txt is not accepted: ..." | The marker is wrong in the way the line says (not stopped, no check= line, check= does not match, written on this VM, no full commit) | Run `host-stop.ps1` again on the main PC and then `host-push-files.ps1 -Final`. Never edit the marker by hand |
| push-pack or unpack-session: "does not match pack-manifest.json" / "damaged" | The pack changed or was cut short after it was built | Run `build-pack.ps1` again, then `push-pack.ps1` |
| vm-setup services: REFUSED / SKIP "main PC is not marked as stopped" | Correct before switch-over. After it, the marker did not arrive | Do S2 (host-stop), S4 (final push), then S5 again |
| vm-setup services: "ship lock was NOT clear" | A ship was running on the main PC when it stopped | On the main PC finish or clear the ship, run host-stop again (with `-ClearStale` if needed), final push again |
| host-stop: NOT FINISHED, no marker | Something is still running or locked | Read the line above it, run host-stop again |
| health: lines starting PROBLEM | Something in Pillagers needs fixing | That is Claude's job: it fixes these by itself after the first message (S6) |
| Any key variable warning (OPENAI_API_KEY, CODEX_API_KEY, ANTHROPIC_API_KEY set) | A key under a standard name would bill by the token | Remove that variable in Edit environment variables (Step 6). The scripts never set or remove it for you |
| host-ollama-bridge -Install: "REFUSED" (firewall off, unreadable, allows inbound by default, another rule opens Ollama, or no Default Switch card) | The bridge relies on the Windows Firewall to keep your Wi-Fi out, so it will not run when the firewall cannot be trusted | Read the line it prints; fix that (switch the firewall on, remove the other rule with the command it prints, start the VM once so the Default Switch card exists), then run it again. Nothing was changed |
| host-ollama-bridge -Status: a BLOCK rule for Ollama | Windows added it when "Allow Ollama on networks?" was cancelled; a block beats the allow rule | Run the removal command that -Status prints, then check again |
| vm-user-settings: "waiting for host-ollama-bridge.ps1" (exit code 2) | K1 is not done on the main PC yet | Do K1, then run vm-user-settings again |
| vm-pad-route-firewall: "default gateway ... does not look like the Hyper-V Default Switch" | The VM's gateway is a router, not the main PC, so the script will not let it in | Give the main PC's address yourself: `-HostAddress 192.168.160.1` (on the main PC `Get-NetIPAddress -InterfaceAlias "vEthernet (Default Switch)" -AddressFamily IPv4` shows it) |
| vm-pad-route-firewall, vm-address-report or vm-user-settings: "this looks like the MAIN PC" | You ran a VM script on the main PC | Nothing was changed or written. Run it inside the VM |
| Any script: "must be answered by a person typing at the keyboard" | Something tried to answer the YES question for you | Run it in a normal window of your own and type YES yourself |
| host-play-relay -Start/-Install: "Not starting the relay on the real ports" | The main PC is not marked as switched over (no valid host-stopped.txt), or 8802/8799 are in use | Do S2 (host-stop), then -Install. To try the route earlier use `-Start -Ports 18802:8802` |
| Game page says "the vm is not answering" | The VM is off, its servers are not running, or the K4 rule is missing | `host-play-relay.ps1 -Status`, then `vm-pad-route-firewall.ps1 -Status` in the VM, then `vm-verify.ps1` |
| Windows in the VM stops at the sign-in screen after a restart | Automatic sign-in is not on, or something blocks it | `vm-autologon.ps1 -Status` (K6) names the blocker |
| party-host-copy: refuses the folder or the address | The copy folder is a Pillagers working folder or a git folder it did not make, or the address is not https://github.com/... | Use the default `-Dir` and `-RepoUrl`, or pick an empty folder of your own |
| Anything else | | Open the log named on the last line, copy the last 30 lines, and paste them to the Pillagers Claude Code (the VM one once switched, otherwise the one on the main PC) with the words "this step failed" |

Still stuck, or the VM looks wrong? Stop. Nothing has been deleted from the main PC, and `host-vm-boost.ps1 -Undo` plus `host-stop.ps1 -Undo` put things back.

---

## All the commands in one place

[MAIN PC, administrator window]

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-vm-boost.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-vm-boost.ps1"
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-push-files.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-push-files.ps1"
```

[MAIN PC, optional: look export (normal window), session pack (build in a normal window, push in an administrator window)]

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-settings-export.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\build-pack.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\build-pack.ps1"
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\push-pack.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\push-pack.ps1"
```

[MAIN PC, switch-over day]

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-stop.ps1" -DryRun
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-stop.ps1"
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-vm-boost.ps1" -NoPush
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-push-files.ps1" -Final
```

[IN THE VM, administrator window]

```powershell
cd C:\PillagersMove\kit
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -DryRun
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -AcceptLicences
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -Only gpu,health
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -Only files,services,health
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\vm-setup.ps1 -UndoGpu
```

[IN THE VM, normal window, optional session pack]

```powershell
powershell -ExecutionPolicy Bypass -File C:\PillagersMove\unpack-session.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File C:\PillagersMove\unpack-session.ps1
```

[MAIN PC, Part 3: the local AI bridge in an administrator window, the rest in a normal window]

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-ollama-bridge.ps1" -Status
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-ollama-bridge.ps1" -Install -DryRun
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-ollama-bridge.ps1" -Install
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-play-relay.ps1" -Status
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-play-relay.ps1" -Start -Ports 18802:8802
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-play-relay.ps1" -Install
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-verify.ps1"
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\party-host-copy.ps1" -Status
```

[IN THE VM, Part 3: the firewall rule in an administrator window, the rest in a normal window]

```powershell
powershell -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-pad-route-firewall.ps1 -DryRun
powershell -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-pad-route-firewall.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-user-settings.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-autologon.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File C:\PillagersMove\kit\vm-verify.ps1
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\ai-keys.ps1" console
```

Rollback [MAIN PC]:

```powershell
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-vm-boost.ps1" -Undo
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\migrate\host-stop.ps1" -Undo
```

Rollback of the Part 3 pieces (each one is separate): the local AI bridge `host-ollama-bridge.ps1 -Undo` [MAIN PC, administrator]; the pad route `host-play-relay.ps1 -Uninstall` [MAIN PC] and `vm-pad-route-firewall.ps1 -Undo` [VM, administrator]; automatic sign-in `vm-autologon.ps1 -Undo` [VM]; the party copy `party-host-copy.ps1 -Stop` and then delete its folder `C:\claudecode\pillagers-party` yourself.

Where things live:
- The kit (scripts and this guide) on the main PC: `C:\claudecode\dark raiders\tools\migrate`. Inside the VM: `C:\PillagersMove\kit`.
- Archives waiting to be sent, on the main PC: `C:\Users\User1\AppData\Local\PillagersMove\out`. Inside the VM: `C:\PillagersMove\payload`.
- The session pack (zip, manifest, unpack script) on the main PC: `C:\Users\User1\AppData\Local\PillagersMove\out\pack`. Inside the VM: `C:\PillagersMove`.
- The look-and-feel export on the main PC: `C:\Users\User1\AppData\Local\PillagersMove\settings` (outside the game folder, on purpose). Inside the VM it lands in the kit folder.
- Inside the VM: undo files and replaced-file backups `C:\PillagersMove\undo` (including `gpu-orig` and `unpack-<time>`), reports `C:\PillagersMove\state` (`repo-baseline.json`, `extra-files.txt`), runner guard `C:\PillagersMove\launchers`.
- Logs: main PC `C:\claudecode\dark raiders\tools\migrate\logs`; VM `C:\PillagersMove\kit\logs`.
- Part 3 on the main PC: the relay's own log and status are in the kit folder `tools\migrate\logs` and `tools\migrate\state`; the party copy lives in `C:\claudecode\pillagers-party` (its own folder, outside the Pillagers repository). The VM's address, if the main PC ever needs it by hand, is written by `vm-address-report.ps1` to `C:\PillagersMove\kit\vm-address.txt` inside the VM.
- The "main PC is stopped" marker: `host-stopped.txt` in the kit folder (and a reminder inside `.git`).
- Inside the VM the game lives at the same address as before: `C:\claudecode\dark raiders`.
