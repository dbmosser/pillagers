# 112 raid hud style mockups (lane b, 2026-10-24)
Nothing here is shipped. Each mockup is the test fixture page plus a small draw override, served on a test port, so the real game file is untouched.

## How to rebuild a mockup
- mk scripts (run in the scratchpad S, copies kept here too): mk-cw-mockA/B/C.ps1 read tools\fixture.html, put notes\112-mockups\mock-X.js inside the game closure and write tools\fxmock-X.html.
- The draw code is in notes/112-mockups/mock-A.js, mock-B.js, mock-C.js. Each redefines hudPanel, hudPlate and trPlate (the cash block plate) and sets TYPE.micro and TYPE.body to the label spec (one type scale).
- Pictures: notes/shots/112-mockups/<now|A|B|C>/ screens 19, 33, 37 at 1080p. Camera: uishots with -Url http://localhost:8803/fxmock-A.html (8804 B, 8805 C).
- To ship the picked one later: the same functions go into dark_raiders.html as a real cw- key (hudPanel at ~46000, hudPlate at ~13171, trPlate at ~5744), with the fixture checks that read panel fills retargeted.

## Critic scores (one run per set of the 3 pictures; a 3-picture run gives one score for the set)
| set | score | finish line |
|---|---|---|
| now (current build) | 2 | 4 |
| A quiet | 2 | 4 |
| B bare | 2 | 4 |
| C one rail | 2 | 4 |
No mockup moved the score. Plain reading: the three panel styles are a small part of what the critic marks down. Every run names the same top items, which none of the mockups touched (draw-only, no layout change):
1. the controls legend in the middle of the play space (P0, all four runs); 2. the top right stack (cash block + run info) is dense, 3. alerts and feed lines shown twice (centre banner plus left log, his feed-all order, question 91 open); 4. the extraction banner and the hostiles strip glued together and crowding the hotbar; 5. the clock is not a 56px hero; 6. hp bar louder than the ammo number.
Critic on C: asked for one Panel P on all three top panels with 16px padding (it saw the rail as separate boxes); on B: world labels and bare text on tinted floors read thin. Run B and C results are the closest to "shared style" but still 2.
Side effect: the critic wrote these runs over the accept.json entries for 19, 33 and 37 (the last writer, mockup C, stays; the score 2 and need 4 are unchanged, the verdict and findings text are mockup C's). The real build score is still 2.

## The three mockups
**A, quiet.** In plain words: every box on the HUD is the same dark panel with the same thin border and the same small rounded corners, and all small text is one size.
- Changes: hudPanel (chamfer corner becomes 4px round, 1px line-hi border, flat fill), hudPlate (same panel with a 3px colour bar for tags and log rows), trPlate (cash block plate), and TYPE.micro and TYPE.body set equal to TYPE.label. The lime tab stays only on non-plain panels (the ammo card, the star).
- A player sees: tags and left log rows now have a border like every other panel, the cut corners are gone, small text is a little bigger (board and legend rows get tighter, the board header outweighs its rows). Otherwise close to today.
**B, bare.** In plain words: only the ammo, the vitals and the hotbar keep a box; the info boxes lose theirs and the text floats on a soft dark shadow.
- Changes: hudPanel and hudPlate draw a feathered shadow instead of a panel for everything that is not in the bottom band and not a danger or extraction plate; trPlate does the same for the cash block; type as in A. Log rows keep their 3px colour bar.
- A player sees: the world shows through behind run info, the cash block, the pillager list, the legend and the left log. Text is readable on dark floors and thinner on light or tinted ones (the pink floor on screen 33). Fewer boxes, so fewer edges.
**C, one rail.** In plain words: boxes in the same corner become one box with thin dividers.
- Changes: hudPanel, hudPlate and trPlate collect the rects of each corner group (top right: cash block plus run info; top left: pillager list; left: every feed row) and draw one union panel from last frame's rects (one frame of lag), members draw only a divider or their colour bar; type as in A. Everything else is Panel P as in A.
- A player sees: one panel top right holding cash and run info with a hairline between them, one panel behind the whole left log (rows sit as lines in it), the pillager list unchanged but as a square-cornered 4px panel. The left rail grows and shrinks with the feed.

## What to ship if he picks one
Picking is about the look only. Whatever he picks, the critic's repeated big items need their own jobs (legend after 20 s, one alert surface, extraction banner as one card, clock as hero); those are layout or order-reversing changes (feed-all, question 91, controls card kept on), so they wait for his answers.
