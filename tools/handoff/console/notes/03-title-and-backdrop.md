# 03-title-and-backdrop notes
- Before shots: notes/shots/03-before (01,44,45,46,56,57 at 1080). Port 9361.
- Title HTML: dark_raiders.html ~2298-2400 (#title .titlecol). Story div (max-width:760px) line ~2310, 3 .tcard lines ~2315-2331, kbrow/padrow after.
  Old checks touching them in mkfixture.ps1: ~8529 (.tcard,.tstep), ~27525 (max-width:760px div + .tcard .tbody), ~48808 (.tcard), ~50002 (cards).
- Behind title today: Undercroft hub floor (HB) via titleSceneReady (line ~46313), drawn in frame loop ~47496 (updateHubWorld/drawHubWorld ~47435), blurred+dimmed by CSS.
- Attract (arcade): ATT/attEl ~46328, arcadeAttLoop ~60752 (pages board/howto over a <video> clip at opacity .22). No clip file => black.
- buildRaid(sim) ~14410, runSim ~32095, render2D ~36020, startRaid ~15724, WORLD_W 2663.
- Plan: (1) title copy -> one line "Ascend. Pillage. Extract." (2) live sim backdrop.
