# cw-trcol2: the corner column is 300 wide, and world names stay out from under the HUD plates (2026-10-18, shipped as v31.50)

Follow-up on cw-trcol (v31.32) from the coordinator. The column stays exactly as built (one item per row, one width, one right edge); the two fixes below only change its width and what is drawn under it.

## 1. Width: 300 px at 1080p
- Was the run info panel's width, 321 px at 1080p (643 at 4K). His menu survey pick (q16 A and q20 A) is 300, so the column is 300 at 1080p and 600 at 4K. Every row, the minimap square and the run info panel move together.
- Scaled the same way as before (the HUD scale, the text scale capped at 1.2, the Settings minimap size small / normal / large); at 720p it is 250. The demo is the same width as career.
- Not done, on purpose (they undo his order or belong to task 02-raid-hud-redesign): fewer rows, dropping "notes logged", a 240 minimap, a 5 percent margin.

## 2. World name labels no longer show through the plates
- The purple cache names, nameplates, party names, the strongbox name and the forge name are drawn under the HUD plates, so they showed in the 8 px gaps between the rows and round the edges of the score and clock plate ("the long dock cache" between stash and backpack, "chill row cache" beside the demo score plate).
- A label is now not drawn while its screen rectangle (plus 3 px) overlaps the corner column (the rows, the minimap, the run info panel) or the score and clock plate at the top centre. Career, demo and the 2 player demo (the wider score plate), 1P and the player 2 window alike, at any size.
- How: render2D writes this frame's world-to-screen map (WTX); arcadeScoreHud writes the plate's box (SCOREBOX); wlUnder(x,y,w,h) tests a label rectangle against EDGEBOX.trcol, HUDBOX.cond and SCOREBOX. No allocation per frame.

## Check 31.50
Stages a named cache, a sentry nameplate and the strongbox at known screen places (read back from what is really drawn): hidden in the middle of the minimap, 24 px under the column's left edge, in the gap between the stash and backpack rows, in the middle of the score plate and on its right end; drawn 14 px left of the column, 14 px right of the plate and 14 px under it. Also asserts the column, every row and the run info panel are 300 wide at 1080p and 600 at 4K, and that the 2 player plate covers a place the 1 player plate leaves clear. Fails on the build before it, with the column 321 wide and every label arm drawn over the HUD.

## Pictures (1080p and 4K, before = the shipped fixture just ahead of v31.50, after = v31.50)
- tools/handoff/console/notes/shots/cw-trcol2-before/ and cw-trcol2-after/: tr1-career-calm, tr2-career-busy, tr3-arcade, tr4-p2-career (the four cw-trcol screens) and tr5-career-labels, tr6-arcade-labels (names put on purpose where they bled).
- Crops the critic saw: shots/cw-trcol2-crops/ (corner and top centre, before and after, from tr5-career-labels-1080).

## Critic (one run, after crops)
Score 3 of 5, better than before: yes. "the new top-right column is a tidier, more uniform stack with a narrower minimap, and the score block no longer clips". Its remaining asks (merge the four rows into one panel, a denser run info panel, a lime accent, a stronger focal point) undo his one-item-per-row order or belong to task 02-raid-hud-redesign (lane a); left alone.
