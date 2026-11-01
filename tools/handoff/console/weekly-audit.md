# Weekly efficiency audit (11-01, his "Should you automate a daily audit like that?")

Daily: checkin.sh already flags the cheap signs every 2 h (pace line, stale usage, $0 runs, waiting/ jobs over 48 h, main PC over the bridge).
Weekly: the full audit, once, on the first check-in after Sunday 08:00 local (the plan week resets Sat/Sun midnight). Skip it if weekly-audit.last holds this Sunday's date.

Run two background subagents at once (default model), read-only, each reporting under 400 words with fixes marked SAFE or NEEDS-HIM:
A. Pipeline: last 7 days of runs.log, cli-spend.txt, spend.txt, onhispc.txt, git log: ships per day, jobs done on run 1, failed/, cost per shipped job, $0 runs, time lanes waited (RAM, lock, pace, STOP) vs ran; gate/shipq STOPs and why; how long stable has been stuck and what blocks it; queue health (tasks, failed, blocked, waiting); caps stricter than the week line needs; check-in false or missed alarms.
B. Machines and tools: VM RAM by process, main PC (hostctl.mjs main-status/stats), JTPC, robots, collector, devdash, itch-follow, nightly.sh and scheduled tasks: state, last useful work, verdict busy / idle-could-work / broken / not worth it.
Never list as broken anything he dropped for good (the local AI on his main PC, anything on the nevermind list).

Then one subagent applies the SAFE fixes (bash -n, .new then mv, one commit), and write today's date to weekly-audit.last.
Tell him only what changes for him, in game words, a few lines.
