# The host bridge — the VM's Claude asks the main PC for jobs

This lets **the Claude running inside the VM** ask **the main PC** to do a fixed set of Pillagers jobs and get the answer back as JSON — **without Claude ever being signed in on the main PC**. The main PC can stay signed in to your *work* Claude; this bridge does not use Claude on the main PC at all. It is a plain Node program that runs as you.

## What it is (and is not)

It is **not** a "run any command on the main PC" shell. The only things it ever runs are the **named jobs** listed in `jobs.mjs`. A new job is a new named entry, added on purpose (one line + your OK). Today the jobs are:

| job | what it does | reads/writes |
|-----|--------------|--------------|
| `ping` | proves the bridge is up; says the PC name and repo path | read |
| `stats` | free RAM, total RAM, CPU name + load, graphics card + driver | read |
| `kit <key>` | runs one allowlisted move-kit script (`ollama-status`, `play-status`, `host-verify`) | read |
| `share-list` | lists the one shared folder | read |
| `share-get name=…` | reads a file **out of** the shared folder (capped 12 MB) | read |
| `share-put name=… ` | writes a file **into** the shared folder (capped 12 MB) | write (one folder) |

The shared folder is `C:\Users\<you>\AppData\Local\PillagersBridge\share` on the main PC — a drop box both sides use. The move-kit's own scripts (the Ollama firewall bridge, the pad play relay) stay as they are; the bridge just lets the VM trigger and read them.

## How it is kept safe

- The agent binds **only** to the Hyper-V Default Switch address (`192.168.160.1`), so nothing on your real network card can reach it.
- Every request is **signed** with a shared 32-byte key (HMAC-SHA256). No key, no answer.
- Each request carries a timestamp and a one-time nonce, so an old request **cannot be replayed**.
- The firewall rule limits callers to the Default Switch network and to this PC's `node.exe`.
- The agent runs **as you**, no administrator. Only the one-time firewall rule needs an administrator window (changing the Windows Firewall always does — that one is yours to run).

## Setup (once)

**On the main PC** (normal PowerShell window):
```
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\setup-key.ps1" -Show
```
This makes the shared key and prints it. Copy the whole line.

**On the main PC, in an ADMINISTRATOR window** (this is the one admin step):
```
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\host-bridge.ps1" -Firewall -DryRun
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\host-bridge.ps1" -Firewall
```

**Inside the VM** (normal PowerShell window) — paste the key the main PC printed. Run it from the Pillagers repo folder inside the VM (`tools\bridge` is part of the repo, so it is there once the VM has the repo):
```
powershell -ExecutionPolicy Bypass -File .\tools\bridge\setup-key.ps1 -Set <paste the line>
```

## Running

**On the main PC**, start the agent (and have it start at every logon):
```
powershell -ExecutionPolicy Bypass -File "C:\claudecode\dark raiders\tools\bridge\host-bridge.ps1" -Install
```
`-Status` looks, `-Start`/`-Stop` start/stop it now, `-Uninstall` removes the logon shortcut.

**Inside the VM**, the VM's Claude calls `hostctl.mjs` from the repo folder:
```
node tools\bridge\hostctl.mjs ping
node tools\bridge\hostctl.mjs stats
node tools\bridge\hostctl.mjs kit ollama-status
node tools\bridge\hostctl.mjs share-put name=note.txt --file .\note.txt
node tools\bridge\hostctl.mjs share-get name=report.json --save .\report.json
```
(If the VM ever cannot find the main PC: `--host 192.168.160.1`, or set `PILLAGERS_HOST_IP`.)

## Files

- `bridge-common.mjs` — shared helpers (key, signing, logging). No commands run here.
- `jobs.mjs` — **the allowlist.** Every job the bridge can run.
- `host-agent.mjs` — runs on the main PC; listens, checks the signature, runs the named job.
- `hostctl.mjs` — runs in the VM; what the VM's Claude calls.
- `host-bridge.ps1` — start/stop/status/install the agent, and the one-time firewall rule.
- `setup-key.ps1` — make/show/set the shared key.
