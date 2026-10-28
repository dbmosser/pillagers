# Handoff: JT PC Correspondent (cloud session session_01LWYNPaJtr6mNcFnG4GzjXH), 10-28 15:15

## Role, in his words
"your job is to make sure we are getting our money's worth out of the JTPC's resources" (10-27 night). JTPC is the spare PC, DESKTOP-82BKOP4 (tools/spare/README.md).

## His standing orders to this chat
- 10-28: "i don't understand what any of this means. Im not a dev. Are you using the JTPC to improve the game or not?" Talk to him in plain words: what it does for the game, no code, ports, branches or tiers.

## Open work
None. Commit 07beed32 on branch claude/laughing-keller-gqp1xb is pushed and merged to master as 9de27644 (10-27 22:56). It changed three files:
- tools/spare/spare-import.mjs: puts STALLED at the start of spare-status.txt when the spare's game copy is 3 h behind the newest game change, or when no full run from any machine has finished in 5 h while the game changed.
- tools/health.sh: turns STALLED into a PROBLEM line (CRLF line endings kept).
- tools/spare/spare-runner.ps1: the status note now carries ram_total_gb, cpu_threads, cpu_pct and cpu.

## JTPC state, last seen 10-28 13:03
- Hardware: Intel i5-7600K (4 threads), 32 GB of memory.
- Load: about 80% of the processor in use, 22.7 GB of memory free.
- Work: one robot, plus a full run (corpus-1028-1222) on v35.83. Master was at v35.85 (12:43), which is normal lag.
- Push ok, runner 67F33AD0.
- Master 1db9cf53 (07:56) set it to one robot.

Findings from 10-22 to 10-27:
- Stalled 77 h on v34.13 (10-22 10:23 to 10-25 15:26), unflagged: the reason for the alarm.
- Full runs finished per day: 3, 0, 0, 1, 6, 10.
- Robot hours per day: about 47 through 10-25, about 21 on 10-27.
- The robot hang spike from 10-25 to 10-27 morning followed the builds (34.83 to 34.96), not the machine.
- The full run is serial on one Chrome and takes about 80 minutes.

Conclusion: the processor is the limit and near full; memory is about two thirds idle. The two-Chrome full run and second robot ideas are dropped (I had guessed more threads; wrong). The main PC covers the 4K party measurement (a159b743).

## Check-ins cancelled
- trig_01Boq6CgV1zAT4xCGygWPynW, "JTPC: read real CPU numbers", was due 10-28 00:26 Eastern. It fired and failed (ACCESS_DENIED, after he approved this chat's trust card) and was deleted about 13:07. No other scheduled task is bound to this session.

## The successor must not
- Raise the robot count or add a second corpus Chrome on this 4-thread machine without new numbers that show headroom.
- Let the spare ship, commit or edit the game, run any firewall, Defender, UAC, power or update command, or use port 8802 (README limits).
- Trust the hardware line in tools/spare/README.md ("AMD X3D, 16 GB"). It is wrong on the processor and on memory; correcting it is a doc-only fix.
- Tell him it works without checking spare-results first.
