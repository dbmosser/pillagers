# 109-ui-raid-downed-card-run-info : the downed card is the standard panel with the timer as its hero, and no run info row wraps (coordinator 2026-10-24)
effort: medium

Queue (coordinator 10-24 15:25): keeps three jobs waiting for the helpers (his 10-24 order to spend the week before the reset). This
is the leftover work job 106 named for its own task (notes/106-ui-raid-column-overlaps.md): 106 found the right column overlap gone
and the second alert copy is his 10-15 feed-all order (question 91, open: do not remove feed rows).

Screen (names as in tools/handoff/shots/ui-screens-js.json and notes/ui/accept.json), target 4 (raid screen):
- 34-raid-downed-pickups 2 (HEAD pictures, job 106): "P0 downed card is a flat box, not the standard panel; wants a 3px danger top
  tab and one red bar. P1 contract rows wrap (run info), one long 'contract done' sentence over the top, left toast stack of six rows,
  right chips staggered."
Also keep 36-raid-low-health (2) from getting worse: it shares the panels.

Fix, in this order:
1. Run info rows never wrap: at 1080p and at 4K, for P1 and for P2, every contract row in the run info panel stays on one line inside
   the panel. Fit the panel to its rows; do not drop a contract row or shorten a contract name below what the player needs to read.
   This is a defect: a check for it.
2. The downed card is the guide's standard panel (the same fill, border and radius as the other raid panels) with one hero: the bleed
   out timer at the guide's hero size, the "down" label in the danger colour, one danger bar, and the revive or crawl prompt with the
   live key or pad glyph his 10-18 orders ask for (never a fixed letter). Keep every line it shows now.
3. Only then, if the critic still asks: the long "contract done" line shortened with a logged reason (Q8, notes/ui/changes.md), and
   the right-hand chips on one edge.
Do not touch the controls card in the centre (it waits on his answer about the key legend, questions.md) or remove any feed row
(question 91).

Rules: read style-guide.md and shared-style.md first. All player text lower case, short. Rendering and HUD only: no change to the
simulation, the downed timer's length, saves or the storage key. The HUD must not add draw calls a frame (measure DRS.workMs before
and after on a busy raid).

Checks (each must FAIL on the old build): no run info row's text box is taller than one line or wider than the panel at 1080p and 4K;
the downed card's fill and border match the shared panel; the timer is the largest text on the card.
Pictures: camera-recipes.json with 34 and 36 at 1080p, then the critic.
TASK DONE when the wrap defect is gone (checked) and 34 reaches 4 from the critic (never your own grade), or is stopped at 6 tries
with its best two versions noted and 36 not lower than 2; TASK PARTIAL with what is left.
