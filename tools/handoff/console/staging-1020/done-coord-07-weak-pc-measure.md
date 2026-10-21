coord-07-weak-pc-measure : measure frame times on HEAD on a "5-year-old laptop" class machine (planner draft 2026-10-20)
DONE 10-21 01:40 (coordinator): measured (workflow wf_402525c4-ae2, skeptic agrees, high confidence): 1 player about 24 fps and the 2-player pair about 7 fps per window at 1080p under the throttle. Write-up notes/coord-07.md; ladder job queued as tasks/94-ladder-sheds-sooner.md; the shared main thread of the pair goes to job 95 with coord-06. Re-measure after 86c and 86f with notes/coord-07/runA.sh and runC.sh.
effort: medium

SESSION AGENT OR COORDINATOR (tools/cdp.ps1 -Throttle and tools/handoff/stress.ps1 are not in the lane command list). Do not move into tasks/.
Source: memory pillagers-answers-third50-2026-10-12.md: "Minimum hardware: a 5-year-old laptop."; his 10-12 #21 (q-round3/sweep-2-older-rulings.md line 156): "60 fps also on a mid laptop at 1080p".
Not done (planner and skeptic, 10-20): the only 4x-throttle numbers are in tools/handoff/PC-HANDOFF.md (line 316, about 26 fps on a
v21-era build); grep -i throttle in tools/handoff/console, reports and nightly finds nothing; cdp.ps1 and stress.ps1 were last changed
10-02; done/20-party-rig-perf.md measured only his 4K PC; v32.64 alone once caused a 10x slowdown (done/00-perf-shadow-store.md).

1. Measure only: a 1080p raid on HEAD, 1 player and the 2-player demo, under 4x CPU throttle, on a lane test port (never 8802), at night
   when the VM has its night memory and no corpus runs.
2. Record p50, p95 and slow-frame counts from G.tel.gfx, in plain words, in notes/coord-07.md. Headless Chrome draws in software
   (PC-HANDOFF line 316): say plainly that the numbers overstate the cost.
3. If it is under 60: write a proposal for the quality ladder (shed effects sooner; never sharpness below 75 percent, his 2.44 b) as a
   lane job for after the Thu 10/29 lock, because the ladder also runs on his TVs.
Party risk: low (measurement only).
Done when: the numbers are written and, if needed, the ladder job is drafted.
