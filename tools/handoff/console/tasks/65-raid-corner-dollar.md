65-raid-corner-dollar : the raid corner column still reads "credits 900"; money shows as $ (planner draft 2026-10-20)
effort: medium

Source: memory pillagers-answers-1-78-2026-10-18.md Q59: "$ for money, SP for score."; q-round3/helper-fixes.md item 27: 'Make the money line "$900" with a $'.
Not done (planner, 10-20): dark_raiders.html 5158 trRow(i++,'credits',TRV.c) and 5189 TRV.c=c (a plain toLocaleString, no $).
v32.50 (6f7e3ad6, cw-uc-trdollar) changed only the DOM #topright, which the raid hides. Picture
notes/shots/o-02-corpus-green-recipes-4/corpus-air-hand-p1-1080.jpg (v32.87) shows "credits 900", "stash 0", "backpack 1,560", while
the bots panel beside it already shows "$1,560". The hub picture o-08-pad-owner-recipes-4/j7-hub-p1-pad-owner-1080.jpg shows "stash 0 bag 0".

1. Career raid corner (trColDraw, about 5150-5160): the money row reads "$900" with no "credits" word, as v32.50 did in the Undercroft.
   The stash and backpack rows are money values too (trStash sums item values, trBag is bagValue): "$..." on both. xp stays a plain
   number. Every row keeps its size.
2. Hub DOM line (about 5190-5194, 'STASH '+sv+' BAG '+bv): $ on both values.
3. The demo hides the whole corner (trDemo, 5175): unchanged.
4. Retarget, through fixq and keeping their intent, the old checks that pin the word "credits" in the corner (the v11.52 family; v31.25
   and v30.51 have been red since v32.50 in corpus-1020-0828). If job 58 is running, tell it in notes which ids you took.
Checks (control must FAIL on v32.90): in a career raid the money rows trColDraw draws carry $ and no "credits" word; the hub line carries $.
Pictures: raid HUD corner and hub at 1080 (look at them; this applies his rule, so no critic taste loop). Log the change in notes/ui/changes.md.
Party risk: low (career only). Not a feature: may ship up to the Thu 10/29 lock.

TASK DONE when shipped, the checks pass and the pictures show $; TASK PARTIAL with what is left.
