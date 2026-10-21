# pipeline-scratch: a copy of the build pipeline's helper scripts

The ship queue, the full test run and the lanes call these scripts from the coordinator scratchpad
(C:/Users/User1/AppData/Local/Temp/claude/...8a09e991.../scratchpad). That folder is not in git, so this copy keeps them on GitHub.
Every coordinator check-in runs tools/health.sh, which copies any of these that changed in the scratchpad (never one that looks like
it holds a key) and flags the copy until it is committed. Every other script they call is already in tools/.
If the scratchpad is ever lost, copy these files back into it. Do not edit them here: the scratchpad versions are the live ones.

10-21 03:58: corpq.sh line 12 now closes the corpus Chrome (9344) by its port and starts a fresh one at every full run. The one started
10-20 23:00 served two runs and its graphics process grew to 2.8 GB of committed memory; at 03:25 Windows ran low on virtual memory
(System log event 2004) with it as the top user. The line was rewritten at the same byte length because a run was reading the script.

10-21 04:40: mk-cw-cardstamp.ps1 is the one What's New stamp key (RULES.md item 5; genP.sh is retired). It reads VER at run time,
moves only WHATSNEW_VER to the build it ships as, and keeps the three short notes. When the stamp is within 0.10 of VER it stops at
the mk step ("the stamp is fresh"), so a lane that reaches it after another ship fixed the stamp ships nothing.

10-21 04:55: ending the corpus Chrome's graphics process mid-run (04:24 and 04:53, to stop low virtual memory) is a stopgap only.
Chrome restarts it with --gpu-recent-crash-count, it grew 2.2 GB in 28 minutes (about three times the first one's rate) and the
slices after it had 15 to 22 checks that could not run instead of 3 or 4. A run hit that way is not a fair stable baseline; the next
run (after 07:02, corpus_t plus 4 h) starts on a fresh Chrome (corpq.sh line 12).
10-21 05:16: he answered yes in chat: if memory gets tight again tonight, end the full test run (corpq.sh and corpus-slices.sh, not nightly.sh) and close 9344 by its port.

10-21 06:25: tools/memwatch.ps1 (read-only recorder, console/log/memwatch-1021.txt) caught the 06:03 low virtual memory moment: no
process grew, free RAM went to 0 and about 9.5 GB sat outside every process for under a minute while the VM shrank from 16 GB toward its
10 GB day size (the 06:00 "VM night memory down" task, his answer 45 a). So the handback itself squeezes whatever still runs at 06:00:
itch-daily.sh failed to fork at 06:03 (harmless: the 06:20 ship pushed v33.75 to itch) and the 03:02 corpus run, which ran across it,
stalled on the same check twice; it was ended at 06:22 on his 05:16 yes. Still open: whether 05:16 and 05:40 were the same kind of
squeeze (the recorder started at 05:53). Idea, not done: start no corpus run after about 02:30 and cap the 05:12-style robot run so both
end before 06:00 (nightly.sh is running, so that edit waits for a runner restart).
