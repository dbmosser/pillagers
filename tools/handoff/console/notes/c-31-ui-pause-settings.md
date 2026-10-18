# c-31-ui-pause-settings (notes)

State 2026-10-18 07:50: PARTIAL. Critic scores for 18, 25, 26, 32 are all 2. Other screens (27-31, 42, 49, 68-75) not yet scored.

Shipped: v29.42 (cw-pausescrim): pause scrim 97 percent, Keys window intro sentence hidden. Score did not move (25 stays 2, 32 stays 2).

Why stuck (do before the next run):
- Old checks pin the pause design: REGRESS 6137 wants pause title 32px and legend 16px; 27283 wants legend >=15px with keycaps. Removing or shrinking the key legend needs those retargeted with fixq (hold lock, short).
- ui-shared check 29.33 forbids raw rgba literals in CSS; use var() or color-mix.
- Critic P1s that need real work (all structural, one change each):
  1. Pause card: cut legend to 4-6 essentials or drop it (F1 and Settings > Controls have the full list); delete the "Please provide feedback" sentence (the Feedback button says it); buttons 56px high, 16px gap; Abandon separated; left title + 48px close X.
  2. Keys window: sentence-case action names, drop the per-row Rebind button (row is the button), amber section headers to tx-2, instruction bar only while rebinding, double frame, 48px close X top right, fix dead 390px right strip.
  3. Settings hub: two stacked tab strips (Game / Send play data over The raid / Audio ...), toast over footer, detail pane small, dead right space. The subtitle "So you are too good for default settings, eh?" may be his line: do not reword.
- Hide-the-toast idea was dropped: check at fixture 41393/line 115 positions the toast above the settings footer on purpose.
- Pictures: shots/c-31d-now (before), shots/c-31e-after.
