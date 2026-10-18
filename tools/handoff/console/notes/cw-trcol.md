# cw-trcol: the upper right corner of the raid is one column (2026-10-18, shipped as v31.32)

His order (10-18, verbatim): "everything in the right hand upper corner should be in a vertical 1 by 1 list and they should all be the same size".
This replaces his older Q58 (career top right as one row). The newer order wins; Q58 is no longer how the corner works.

## Before (v31.2x)
- credits and xp: loose page text in a big font, no plate (the page text on top of the game, not on the HUD canvas)
- a small "stash n bag n" line under it, and a grey "n notes logged" line when there were notes
- the minimap, 216 wide, with an amber frame
- the run info panel, wider than the minimap (about 268), so the corner had three different widths
- demo (arcade): only the minimap and the run info panel

## Now (v31.32), career and demo, 1080p and 4K, player 2 window too
One column from the top right corner down, one item per row, one width, one right edge, one gap (8 px, the style guide grid):
1. credits  2. xp  3. stash  4. backpack  5. notes logged (only when there are notes)  6. the minimap  7. the run info panel
- The five rows are the same plate (the same flat panel as the run info panel), the same height, the same type size, the label left and the figure right on one right edge.
- The minimap is a square as wide as the rows; the run info panel is the same width. Settings minimap size (small, normal, large) and the run info grip scale the whole column together, so nothing can be a different size from its neighbour.
- Demo: no wallet rows (as before); the column is the career width (about 321 at 1080p) even though the party screen uses the 1.5 text scale. A 401 wide minimap there would have been 37 percent of the screen height.
- The minimap frame is the same light grey 1px line as every other plate (the amber frame is gone).
- Nothing was dropped. The word is "backpack" on the row (his one name for it; check 9.90 forbids "bag" on a drawn surface). All words lower case.
- Scales with the screen like the rest of the HUD (hudRes); 60 fps, no per-frame allocation (the figures are formatted only when one changes).
- The old page text (#topright) still exists for the Undercroft and the menus; in a raid it is clipped away while the rows are drawn (class trcol, 200 ms hold so a skipped frame cannot flash it).
- The sector map header (time and weather) keeps clear of the column; the wallet rows draw over the map overlay and the backpack the way the page text did.

## What I did not make the same size, and why (his call if he wants it)
- The minimap and the run info panel are taller than a row. They are as wide as the rows. A row-high minimap would be unreadable.
- The extraction ring badge ("extraction c available") is a world label for the ring, held at the screen edge and sliding along it; it is not a corner item, so it is left alone. It steps aside for the column.
- The world's ground names (the faint "the long dock cache" under the corner in the career pictures) are world art under the HUD; they show faintly through any panel.

## Numbers (1080p career, v31.32)
rows 38 high at y 17, 63, 109, 155, 201; gap 8; minimap 321 square; column x 1582 to 1903; run info under the minimap with one gap.
4K: the same layout at 2x. Demo: column 1582 to 1903, minimap 321.

## Check 31.32 (fails on v31.31, passes twice on v31.32)
Reads a real drawn frame of a staged raid (every stub restored in a finally): the plates are one under another, one x-span, one gap, equal row heights, first plate in the corner, minimap square and the same width, labels in order and lower case, credits 4,471,337 and xp 98,761 on one shared right edge, one type size equal to the run info title, the page text clipped while the rows are drawn and back afterwards, the map header clear of the column (with a control arm that switches the avoidance off and sees the overlap), the demo column no wider than the career one. Cases: career 1080p with a note, career 4K, demo 1080p.

Older checks retargeted (fixture commit 4013e388): 26.48 and 25.33 measured the minimap against a fixed 216; they now measure large and small against the standard plate and the minimap against "not under 216". 19.32 and 19.33 stub the page readout's box; they now put the page readout back (trcol class off) first, so they hold on both builds whatever the last frame loop did.
Reds that failed on the control build too (not mine): 8.91, 27.36, 21.84, 18.17, 9.93, 19.73, 19.74, 19.89, 29.11, 8.96 and others in the wide run; they fail identically before and after.

## Pictures
Before: tools/handoff/console/notes/shots/cw-trcol-before/ (tr1 calm career, tr2 busy career with notes, tr3 demo, tr4 player 2 window, at 1080 and 4k; 22 map open, 23 backpack open, 37 extraction countdown at 1080).
After: tools/handoff/console/notes/shots/cw-trcol-after/ (the same names).
Corner crops used for the critic: tr2-career-busy-corner-1080.jpg and tr3-arcade-corner-1080.jpg in both folders.

## Critic (corner crops, before then after)
- career corner: 3 of 5, better than before: yes.
- demo corner: 2 of 5, same.
Findings I did not act on, because they reverse his order or his rulings or belong to other jobs (logged once in questions.md): fewer or shorter rows, drop "notes logged", a 240 minimap, a 5 percent margin for the whole HUD (the HUD sits 16 px from the edge today; his survey picture has a 96/54 margin as part of the HUD redesign), run info contents (rows, dividers, right-aligned counts), the extraction ring badge, the ground names showing through the panels. The critic also read the old amber frame off the old picture; the new frame is grey.
