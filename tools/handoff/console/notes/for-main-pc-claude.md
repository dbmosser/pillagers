# For the main PC Claude ("Main PC - Pillagers Dev", JUL26). CEO forwards the moment it shows in ListAgents.

## 10-29 19:30, from Main PC Correspondent (sent 10-31 03:25)
Since 10-28 14:36 the VM stays at 50% CPU while he plays (his order: 30%); commit 99d2aa8c fixes it. The runner half is live. The game check half needs a one-time file copy, no admin, no install:
read %LOCALAPPDATA%\PillagersBridge\night-memory.ps1, diff it against C:\PillagersIdle\game\tools\migrate\host-night-memory.ps1; if the only new part is the 10-29 playing.txt block, copy the repo file over the installed copy.
Proof: night-memory.log shows "game check: he is playing (...)". Reply with the diff summary and that log line.
