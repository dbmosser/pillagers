# z-125-gfx-machine-damage (lane c, 11-01)
Earlier notes: notes/125-gfx-machine-damage.md.
- Why his v34.78 photo showed no smoke: the puffs started at the top of the body and rose 18 units into the name plate (drawn later, covers them); also small, 0.4 opaque, dark on dark.
- v37.10 (cw-machsmoke): puffs start on the upper body, bigger, 0.7 opaque, grey rim. Picture notes/shots/125/smoke-after: still weak (faint squares on the grey body).
- v37.12 (cw-machsmoke2): near solid dark (0.9, 1.0 near death), grey rim, puffs vent out to both sides as they rise. Pictures notes/shots/125/smoke2-after (1080 and 4k): reads clearly on both bulwarks.
- v37.13 (cw-nomachpip), g-83: machines no longer draw the 3 px health pip under the name plate (if(ne.hp<ne.maxhp&&!GFXDMG_KINDS[ne.kind])). Picture notes/shots/125/nopip-after: plate and smoke, no bar. The check spies fillRect in _wtA: hurt sentry 0 bars, hurt pillager bot keeps its bar.
- Frame cost: the 34.74 check holds the 0.5 ms a frame budget and passed on every ship. 4K two-window numbers: tools/handoff/spare/perf-4k.txt had only v36.95 (p1 p50/p95/p99 5.25/10.75/14.75 ms) before these ships; compare with the next line for v37.13 or later when the main PC robot writes it.
- Not done: a player 2 window picture (needs a host pair, no recipe). The effect is render only and the same code runs in both windows.
- Watch (his next play): dark smoke blocks on a machine under half health, sparks under a fifth; machines now show no health bar, only the name; pillager bots still do. He should say if he wants the bar back.
