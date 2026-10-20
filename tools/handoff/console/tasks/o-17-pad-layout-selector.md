o-17-pad-layout-selector : the pad layout picker's arrow overlaps the layout name box (planner draft 2026-10-20)
effort: low

Source: tools/handoff/console/alarms.md (o-11 handoff, 10-20): "button#padlayoutprev overlaps button#padlayout by 6x48 in both layouts".
Not done (planner, 10-20): o-11 left it on purpose ("Change nothing else on the card"). The camera lint in
tools/handoff/console/notes/shots/o-11-pad-card-fixes-recipes-1/report.json reports the overlap on 74-pad-pillagers and
74-pad-call-of-duty; accept.json 74-pad-lefty is 2 and every 74-pad-* finding opens with a P0 on the selector focus box. The selector CSS
(dark_raiders.html about 1468-1494, #padlayoutprev at 1492) was last changed by v32.55; the markup is near 19512 (padlayoutrow). No ship
v32.84 to v32.90 mentions it.

1. The picker (#padlayoutprev, #padlayout, #padlayoutnext and the "n / 6" counter) is one row: both arrows sit fully clear of the name
   box, at 1080p and 4K, for every layout name (the longest too).
2. One focus outline around the focused part, not two rings.
3. Change nothing else on the card: the diagram, legend and list stay as o-11 left them (74-pad-pillagers and call of duty already scored
   3, his finish line for this screen).
Check (control must FAIL on v32.90): on each of the 6 layouts the arrow boxes do not intersect the name box, and only one focus ring shows.
Pictures: reuse the o-11 camera recipes (74-pad-* screens), first 6.
Party risk: low (the Settings pad screen; guests use it to pick a layout).

TASK DONE when shipped, the check passes and the camera lint shows 0 overlaps on the 74-pad screens; TASK PARTIAL with what is left.
