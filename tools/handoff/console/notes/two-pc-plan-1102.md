# Who runs what, two PCs and two projects (his 11-02 order to use all resources across both PCs; rewritten 11-02 23:40 after the memory change)

## His order, 11-02 23:40, on top of everything below
"FnP is the priority now, Pillargers-html takes a back seat." "if I'm away and the editor is closed, the first thing you should do is try to reopen the editor." Tests stay off the main PC.

## The machines, measured 11-02 night
| | Main PC (JUL26) | Spare PC (JTPC) |
|---|---|---|
| Processor | Ryzen 7 5800X3D, 16 threads, 4% busy at 23:33 with 3 helpers running | i5-7600K, 4 threads, full during a run |
| Memory | 48 GB, 3 x 16 GB at 2133 (XMP off, his choice), 25 GB free | 32 GB at 3000, 20.8 GB free during a run |
| Video card | RX 7900 XTX, idle unless he plays or the editor is open | RTX 2080, 8 GB, 4K display; use during tests being measured |
| Disk | C 149 GB free, D 968 GB, E 7.5 TB, G 142 GB | C 134 GB free, only drive |
| Fortnite | editor and game | Fortnite 43.00 installed, no editor |

## The assignment
- FnP editor, island building: main PC only. First call on memory and the video card. With the editor open, no helper starts under 14 GB free (machine_editor_open): about 10 for game launches (the FnP chat's ask), 1 for the helper and a margin. His 4 GB floor stays. Reopening: tools/fnp-scripts/editorwatch.py in the FnP folder watches and wakes the CEO chat; the FORTNITE chat reopens, and the CEO chat only if that fails. The graphics card is the FORTNITE chat's job alone.
- HTML coding, helpers, shipping: main PC only. Only one machine ships.
- HTML tests, gate and full runs: spare PC only (his 11-02 order). Nothing covers for a pause.
- FnP second player: spare PC is the candidate, Fortnite is already there. The FnP chat will ask once a raid works end to end, not before; it needs an Epic account signed in there. HTML tests pause then.
- Claude plan: FnP spends what it needs. Helpers pace to a line of 80% this week (caps.txt) and rest above it, and they rest until about 10:50 on 11-03, since the week was at 28% against 23.1 at 00:30. (PLAN_LINE_END must sit inside the week: at the reset itself the code ignored PLAN_LINE_TARGET.) The final burn spends what is left near the reset, after his Saturday morning test. PLAN_TARGET stays 95 for next week unless this order changes.
- CEO chat workers (lanes g, h): 266 and 267 finish; none new on HTML while FnP comes first. Jobs with a WAIT ON guard stay in tasks/, because the guards do not look in in-session/.
- Memory watch: tools/handoff/ramwatch.py on the main PC, once an hour for 2 minutes, in spare memory at low priority. With the editor open it is one worker on at most 6 GB and keeps 14 GB free; otherwise 3 workers and 8 free. It sits out while Fortnite runs, and a bad spot raises an alarm. It stops with the CEO chat or a reboot; the check-in restarts it.
- Codex: week used up, resets 11-04 01:35. Local AI stays off (LOCAL_AI=0 since 10-28).

## What is holding it back, biggest first
1. Graphics card hangs kill the editor (08:16, 16:12, 23:32 on 11-02, the last with plenty of memory free). The FORTNITE chat has it. Power Supply Idle Control in the BIOS is unconfirmed since the BIOS update, and that setting is his hands.
2. Spare PC speed: a full run took 90 min on 10-30, 183 to 215 min now, for about the same checks. Slowdown is uneven by slice and repeats, which points at the tests or the build. Change window 10-30 16:15 to 11-01 19:00. Fixed already: slices poll every 20 s, about 20 min a run. Open: slice table and video card reading due from the spare PC chat, a run on v36.66 to compare, per-check timing.
3. Spare PC pauses: 9.0 h paused of the last 48 h with the runner on, some false. The owner says the mouse moves by itself on a shaky table. The fix (5 mouse reports inside 10 s) comes to the main PC as a diff to land.
4. Memory confidence: the 3 sticks have only passed a quick test on 21.9 of 48 GB. A full Windows Memory Diagnostic (his hands, overnight) is still wanted; XMP stays off until then. Uneven channels: about 32 GB at full dual-channel speed, the rest slower. Removed stick is out and labelled.
5. Keys (his hands): the itch key on this PC is refused, so builds do not reach itch (itch has v37.39). "Pillagers keys" on the desktop replaces it.

## Parked
- Faster memory (a mid speed or XMP): only after the full test, with a before and after bandwidth reading. Two sticks on one channel makes 3600 harder.
- Helpers on the spare PC: no, it risks two shippers and it has only 4 threads.
