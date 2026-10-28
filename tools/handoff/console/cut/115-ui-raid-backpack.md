# 115-ui-raid-backpack : the in-raid backpack reads as an inventory, not a debug panel (coordinator 2026-10-24)
Queue (coordinator 10-24 17:55): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). Feed
order: a screen the critic scored under 4. Every raid uses this screen; the score is from 10-20, before the hub backpack ships
(v34.07, v34.08) and the pixel item icons.
effort: medium

Screens (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json):
- 23-raid-backpack-open 2, target 4: "a flat, dark and quiet card with a good lime focus tile, but it is a small, under-filled box with
  weak hierarchy, a tiny 3-item grid and a loose type scale, so it reads as a debug panel and not as a Diablo/ARC inventory".
- Keep 41-hub-backpack (3) and 41-hub-backpack-pad-p1 (3) from getting worse: they share the backpack drawing.
Start with fresh pictures and a fresh critic score on HEAD; if 23 already meets 4, record it and stop.

Fix, in this order:
1. The grid at the guide's tile size (style-guide.md, Tile: square, rarity as a 3px bottom bar, count as a corner badge, 8px gutter),
   so the card is filled by the grid and not by empty space; the card sized to its grid. Same number of cells as now: this is the size
   of each cell, not more slots (no change to how much a pillager carries).
2. One hero (the focused item's name and value at the guide's title size) and one type scale for the rest (shared-style.md).
3. Then the critic's points the guide agrees with. No new readouts or controls.
The raid backpack opens over a live raid: it is a DIALOG-sized card unless the guide's Window list names it; follow the guide and give
the critic the rule with the picture.

Rules: read style-guide.md and shared-style.md first. All player text lower case, short, $ for money; log any reworded or removed line
with its reason in notes/ui/changes.md (Q8). Rendering only: no change to the inventory's rules, what fits, saves or the storage key
salvagerun:profile. Both windows look the same apart from their colour.
Checks (each must FAIL on the old build): each backpack cell is at least the guide's tile size at 1080p; no cell or label is drawn
outside the card.
Pictures: camera-recipes.json with 23, 41-hub-backpack and 41-hub-backpack-pad-p1 at 1080p, then the critic.
TASK DONE when 23 reaches 4 from the critic (never your own grade), or the fixes shipped and the scores are written with the reason
for any point left, and 41 is not lower; TASK PARTIAL with what is left.

CUT Tue 10-27 about 20:00 by his priorities page (https://claude.ai/artifact/8mXPSJ5fqq5DiV1Mxsy8Xr, db answers): he marked it NEVERMIND. Do not build it.
