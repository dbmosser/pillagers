# 58-corpus-reds-v32-90 (lane b, 2026-10-20)

- v8.58: STALE (retargeted, commit a0223cae). It is the second 8.58 copy ("sector board reads in metres"). The redesigned board prints "W x H m"; check now accepts that or the old "by N metres". Hectares still banned. Not re-run (runchk only runs the first 8.58); text read from renderSector in the game.
- v20.89: FIXED SINCE. Passes alone on HEAD (job 52 retarget). Red in the corpus only: HARNESS (order/timing in the long run).
- v24.38: HARNESS. Passes alone on HEAD; red only inside the full run.
- v30.91: HARNESS. Passes alone on HEAD; red only inside the full run.
- v31.04: HARNESS. Passes alone on HEAD; red only inside the full run.
- v31.67: HARNESS. Passes alone on HEAD; red only inside the full run.
- v20.01, v20.11, v28.12, v28.13, v28.16: left to job 68 (still in tasks/), not run.

Note for the coordinator: four checks (24.38, 30.91, 31.04, 31.67) plus 20.89 pass alone but fail in the full run, so something earlier in the run leaves state behind. If they stay red on the next full run, they need a staging reset, not a game fix. No REAL bugs found, nothing proposed for the known-red list.
