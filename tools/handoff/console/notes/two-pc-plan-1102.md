# Who runs what, two PCs and two projects (11-02 night, his order to use all resources across both PCs)

## The machines, measured 11-02
| | Main PC (JUL26) | Spare PC (JTPC) |
|---|---|---|
| Processor | Ryzen 7 5800X3D, 16 threads, about 9% busy with the editor closed | i5-7600K, 4 threads |
| Memory | 32 GB, 2 x 16 GB at 3600, BAD SPOTS measured 21:35; 17.5 GB free | 32 GB, 22.7 GB free |
| Video card | RX 7900 XTX, idle unless he plays or the editor is open | RTX 2080, 8 GB, 4K display |
| Disk | C 149 GB free, D 968 GB, E 7.5 TB, G 142 GB | C 134 GB free, only drive |
| Fortnite | editor and game | Fortnite installed (35 GB), no editor |

## The assignment
- FnP editor, island building: main PC only. First call on memory and the video card. One helper at a time while the editor is open.
- HTML coding, helpers, shipping: main PC only. Only one machine ships.
- HTML tests, gate and full runs: spare PC only (his 11-02 order). Nothing covers for a pause.
- FnP second player: spare PC is the candidate, Fortnite is already there. The FnP chat decides if and when; it needs an Epic account signed in there.
- Claude plan: pace line 95% of the week (caps.txt), final burn near the reset. Lanes a, b, c on Opus can do about 2 points an hour, 0.6 is needed.
- While the helpers cannot run: the CEO chat runs up to 2 session workers (lanes g, h) on jobs nothing else waits on. Jobs with a WAIT ON guard stay in tasks/, because the guards do not look in in-session/ (a job moved there would let the jobs behind it start early).
- Codex: week used up, resets 11-04 01:35. Local AI stays off (LOCAL_AI=0 since 10-28).

## What is holding it back, biggest first
1. Main PC memory (his call). The island will not open and the 11/3 friend test and 11/7 first test depend on it. The game itself is not damaged so far: tools/handoff/flipscan.py over 300 builds of the game and fixture found no bit damage, and check-ins now run it on the newest 5.
2. Helper sign-in (his hands, one minute): the helpers' own sign-in is on the work account, so the account guard keeps them off. Never loosen the guard.
3. Spare PC speed: a full run took 90 min on 10-30, 183 to 215 min now, for about the same checks. Cause not known yet. The Claude app window on that PC uses a large share of its 4 threads (46% average over 100 s, with dwm). Being measured.
4. Spare PC pauses: 9.0 h paused of the last 48 h with the runner on, some false. The false-pause fix is being built there and comes to the main PC as a diff to land.
5. Keys (his hands): the itch key on this PC is refused, so builds do not reach itch (itch has v37.39).

## Parked
- Tests on the main PC while he is away: 16 threads sit idle, but this PC has bad memory, so results could be false reds, and his 11-02 order says no. Ask only after the memory is settled.
- Helpers on the spare PC: no, it risks two shippers and it has only 4 threads.
