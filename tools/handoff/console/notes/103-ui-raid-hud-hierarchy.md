# 103-ui-raid-hud-hierarchy (lane a, 2026-10-24)
Shipped: v34.27 cardstamp, v34.28 cw-h103type (16 px floor on belt digits/counts/minimap N, contract one-line short form), v34.29 cw-h103hero (legend words 80 pct, ammo card dips while ship inbound), v34.30 cw-h103fix (dip 70 pct, textRendering geometricPrecision).
Step 1 finding: NO capital is drawn. Probe (caps[] empty) shows every fillText string is lower case after TX. The critic's "run Info / In cover" is the small i of Barlow Condensed at 1080p reading as I (4k shows it fine). textRendering change did not fix it in the 1080 picture; harmless, can be undone (one line in drawHUD). Real fix would be a bolder/other face or larger size for the run info title: needs a font decision.
Critic (1080): 21 = 2 (before 2), 37 = 2 (before 3, the 60 pct dim hurt; now 70), 19 and 61 not re-run. The critic keeps naming things this job may not do (a cw-trcol 1x1 column that does not exist, closing the legend, hp bar size) and repeats "five panel styles" though fills are one now.
Best two versions: 103-before (v34.27) and 103-final (v34.30); roughly equal. Watch: belt digits bigger, ammo card fades 30 pct during extraction countdown.
Left: critic wants legend closed by default (his Q70/F1 orders: not done), hp bar quieter, stamina thin, top-right as one column.

## Run 2 (lane a, 10-24 late)
Critic on 103-final v34.30 vs 103-before: 19 = 2 (same), 61 = 2 (same). All four now: 21=2, 37=2, 19=2, 61=2. No new ship; the three steps are in (v34.28 to v34.30).
Best two versions unchanged: 103-before (v34.27) and 103-final (v34.30).
Open findings that need a decision or a bigger redo (not a small ship): the controls card is always on (critic wants first 20 s only; his Q70 and F1 orders keep it), top-right career and run info panels as one 16px+ column (his 10-18 notes place it), one panel style for tags, the left tag stack and the hint strip (scav pistol shows in three places), wheel labels under the icons with a scrim behind the wheel. Needs a fresh design pass with 2 or 3 mockups he picks from.
