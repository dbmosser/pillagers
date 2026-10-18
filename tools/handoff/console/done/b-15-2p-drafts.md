For his 2-player party on 10/30: 19 two-player drafts from the cloud STOPped at the gate and were never shipped. The list is in
the memory file pillagers-ten-answers-2026-10-15.md (search "19 unresolved"); magfence is obsolete, skip it. Keep progress in
tools\handoff\console\notes\2p-drafts.md (one row per draft: key, status, reason); this task is one of three that share it.
Take the next 6 drafts not yet DONE or DROPPED. For each: find its draft JSON (tools\handoff\drafts, tools\handoff\cloud\INDEX.md,
S\chain2-cloudkeys.txt) and why it STOPped (S\chain2.log). If it still applies cleanly, ship it with bash "S/shipdraft.sh" KEY.
If its anchors moved, rebuild it as S\mk-cw-KEY.ps1 against the current HEAD and ship with shipq.sh. If his later rulings make
it wrong (the magnet is removed, for one), mark it DROPPED with the ruling. TASK DONE when your 6 (or all left) are DONE,
DROPPED or STUCK.
