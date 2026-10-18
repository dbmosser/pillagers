# c-31-ui-pause-settings (lane b) run 2026-10-19

Shipped: v29.96 cw-pausex (pause X, Settings focus row, Keys fade), v29.98 cw-xghost (ghost X, quieter focus box, Keys labels tx-1).
Critic after both: 25 = 3, 26 = 3, 32 = 3 (each "better/same", never 4). Screens 18, 27-31, 42, 49, 68-75 not re-scored this run
(42/49 share the pause card with 25).

## Stuck (same findings every round, not fixed)
- Backdrop: critic wants a baked world at 55% and HUD hidden under the pause card. Scrim is already .82; hiding the HUD
  or baking the world is a game-render change (not UI CSS), left for a task about it.
- Pad hint strip / B glyph / key caps in the footer ("Esc Resume" is bare text): needs a shared key-hint component for all
  modals. Best next step: one shared footer hint row (cap + word, live to last input device) in ui-shared.
- Settings: tab strip scrolls inside the list scroller, "Send play data" tab detached; detail pane repeats the row title.
- Keys: no focused cap; labels fixed column width.
- Pause card: chamfer corner and amber tab (critic wants 4px square + 36x2 tab), buttons 18px vs 20px, run-context line.
Next worker: do the shared key-hint footer first (it appears in every critic list), then the Settings tab strip out of the scroller.
