o-11-pad-card-fixes : two overlaps on the pad buttons card (coordinator 2026-10-20, from the o-05 pictures)
effort: low

Seen in tools/handoff/console/notes/shots/o-05-pad-presets-recipes-3/74-pad-call-of-duty-1080.jpg (v32.55; o-05 and o-06 are closed):
1. The layout picker's "2 / 6" counter sits under the focused layout name box: the lime focus ring covers the "2". The counter
   must sit fully clear of the ring at 1080p and 4K, for every layout name (the longest name too).
2. On the pad drawing, the "d-right" label overlaps the line that joins the d-pad to the right stick. Move the label or the line
   so no label touches a line.
Change nothing else on the card (sizes, words, order and colours stay as v32.55 shipped them).

Checks (each control must FAIL on the old build): with the pad buttons card open on each of the 6 layouts, the counter's box
does not intersect the focused name box's ring box; the d-right label's box does not intersect any connector line's box.

Pictures: camera-recipes.json with the card on the pillagers and call of duty layouts (one window, no player 2 needed).
TASK DONE when shipped, the checks pass and the pictures show both fixes; TASK PARTIAL with what is left.
