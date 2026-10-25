# 113a-raid-hud-reds (lane c)

Causes, one per check:
- 8.93, 9.14: v34.25 cw-hudtype (critic) made the pillager board 361x175 and the vitals 517 wide on purpose. Re-aimed in mkfixture (fixture commit a0e7c25d2).
- 31.03, 30.73: v34.24 panels share one fill: the gun card is 0.88, not 0.62. Check finds it as the one panel with the tab. Re-aimed.
- 17.49: v33.89 pixel machines bake wardens at their own size; the check now runs the vector draw (CFG.xfPix=0, restored).
- 31.50 width: v34.39 let the run info panel grow to 323 px past the 300 px column. His one column order wins: shipped v34.57 (cw-runinfocol). 34.39 now lets a long contract row wrap (count never alone, no row leaves the panel).
- 27.36: at 4K four power-up chips reached the air strike plate. Shipped v34.60 (cw-airchips): the plate treats the chip row as an obstacle.
- 31.50 nameplate arms: the label found was a second machine with the same name, offscreen (115,-1156, n2). Staging fix: give the probe sentry a unique name.
- 31.32, 30.75, 18.01 passed alone (state left by other checks); not touched yet.
Watch (next play): career run info panel is exactly column wide; a long contract row can wrap to two lines. Air strike bar steps up over the power-up chips at 4K with all four active.
