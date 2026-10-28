# Lines drawn a minute: the staged raid count (job 186c)

What it counts: every line that reaches the screen in about 3 minutes of a real raid run through the fixture (not G.sim). A left feed line drawn by a frame, a new top banner (alert) and a new pickup row each count once. Lines that only go into the run log do not count. It also counts every line said, drawn or not (the "staged raid" column of ../raid-messages.md).

The raid: seed 4242, map 0, no kit. drive.js plays it at 60 frames a second through __loop:

1. land (4 s);
2. loot: walk up to the nearest unopened box and hold the search key until it opens, box after box, to 70 s;
3. wade: map 0 has no water, so this phase is skipped (the game has no wading line either);
4. fight: stand 240 px from the nearest machine, aim at it and fire in bursts, reloading when empty, to 145 s;
5. extract: stand in the nearest open ring and call extraction, to 180 s.

Health is topped up below 35 and a downed player is stood up again, so the run always lasts the full 3 minutes.

How to rerun it:

1. Build the two fixture pages on a free lane, the draft and the current build, for example `bash <scratchpad>/pf-keep.sh h cw-msgroute` (it keeps tools/fxdrypfh.html and tools/fxctlpfh.html).
2. On each page run:

```
powershell -NoProfile -ExecutionPolicy Bypass -File tools/cdp.ps1 -Port 9358 -Match fxctlpfh -TimeoutSec 600 -Expr "(async function(){ var t=await (await fetch('/handoff/console/notes/fewer-msgs/drive.js')).text(); return await window.__gx(t); })()"
```

3. Read perMin, the lines drawn a minute, from the JSON it returns. It also returns feed, alert and pick, the counts by place, plus txt, the first 160 lines drawn with their second, and said, every line said with its count.

Results, 10-27:

| build | feed | alert | pick | total in 180 s | a minute |
|---|---|---|---|---|---|
| v35.37 (first try, every feed line added) | 43 | 22 | 44 | 109 | 36.3 |
| v35.42, the build before cw-msgroute | 63 | 23 | 44 | 130 | 43.3 |
| cw-msgroute draft (build 1) | 27 | 20 | 43 | 90 | 30.0 |

From v35.42 on, a feed line counts only once a frame has drawn it. Pickup rows are about the same on both builds, because looting is untouched (his order of 10-27 ~21:35). Without them, 86 lines became 47, 45 percent fewer. Each run plays its own fight, so counts move a few lines from run to run.
