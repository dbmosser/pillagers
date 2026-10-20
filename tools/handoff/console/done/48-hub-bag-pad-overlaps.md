48-hub-bag-pad-overlaps : the Undercroft floor backpack on a pad shows two item cards over its own edges (coordinator 2026-10-20, from the o-10 pictures)
effort: low

Seen in tools/handoff/console/notes/shots/o-10-pad-floor-bag-recipes-3/ (v32.83; o-10 itself is closed, the pad controls work):
1. 41-hub-backpack-pad-p1-1080.jpg: two item cards show at once over the open backpack. The focused cell's card (auto rifle) covers
   the panel's top right, hiding "view to close". A second card for belt slot 5 (riot scattergun) covers the item details and cuts
   the footer hint ("dpad move  a pick up or place  y drop  b close") in half.
2. 41-hub-backpack-pad-p2-held-1080.jpg: the same auto rifle card covers the top right corner, and the "keyboard" input tag sits on
   top of "the undercroft" title at the top left of player 2's window.

Fix (change nothing else; sizes, words and colours stay):
- While the floor backpack is open on a pad, show one item card at most: the focused cell's. No belt slot card at the same time.
- That card never covers the panel's header row or its footer hint row: place it beside the panel or inside the panel's free area.
- The input tag at the top left never overlaps the location title.

Checks (each control must FAIL on the old build), with a stub pad in the hub and the backpack open, at 1080p and 4K:
one visible item card; its box does not intersect the header row box or the footer hint box; the input tag box does not
intersect the location title box.

Pictures: tools/handoff/codex/work/o-10-pad-floor-bag/recipes.json (both recipes), at 1080p.
TASK DONE when shipped, the checks pass and the pictures show all three fixes; TASK PARTIAL with what is left.
