67-controls-card-hand-panel : the compact controls list covers the title of the item-in-hand panel (planner draft 2026-10-20)
effort: medium

Source: tools/handoff/console/alarms.md (o-02, 10-20): "the controls card overlaps the top of the bandage-in-hand panel".
Not done (planner, 10-20): the picture notes/shots/o-02-corpus-green-recipes-4/corpus-air-hand-p1-1080.jpg (about v32.87) shows the
compact controls list (y about 697 to 865) over the "bandage readying" title (y about 850); the alarm says p2 shows the same.
handPlateBox (dark_raiders.html 23289) is used only by drawHand (23299) and the air plate obstacle list (62604), never by drawLegend
(44924). v32.88 to v32.90 do not touch the raid HUD. tasks/ was empty, so the alarm was never routed.

1. While an item is in hand (bandage, medkit, plate: the use panel), the compact controls list and the hand panel never intersect, at
   1080p and 4K, in career and demo, in both windows. The F1 full list too, if it can reach the panel.
2. Do NOT hide, shrink or reword the list: it is open on arrival by his order and folds after 30 s (his 3.32 a: "Keep"). c-02 used its 6
   tries on the raid HUD, so change nothing else on it.
3. Preferred fix: treat the hand panel as an obstacle the way v32.86 did for the air-strike plate (handPlateBox in the obstacle list) and
   place the list clear of it, or move the hand panel clear of the list. Pick the one that keeps both whole.
Check (control must FAIL on v32.90): with a bandage in hand, the list's box and handPlateBox() do not intersect at 1080p and 4K.
Pictures: the o-02 recipes-4 corpus-air-hand recipes, p1 and p2 (single-seat p2 scenes stage), before and after.
Party risk: low to medium (raid HUD layout; guests see the list in their first raids). Ship before the Thu 10/29 lock with pictures,
otherwise leave it until after 10/30.

TASK DONE when shipped, the check passes and the pictures show both panels whole; TASK PARTIAL with what is left.

COORDINATOR 10-20 18:53: taken by the coordinator (helpers are held by RAM); it ships from here.
