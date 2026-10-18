# c-31-ui-pause-settings (notes)

State 2026-10-18 09:10 (run 3): PARTIAL.
Shipped this run: v29.54 card P12 (stamp), v29.55 cw-pausestack (pause card as 56px button column), v29.56 cw-pausetidy (640 wide card, scrim 99%, Esc hint, danger-red leave buttons), v29.57 cw-pausefit (frame measure counts the Esc hint pseudo: title gets 32px top air).
Scores (accept.json): 25 = 3, 42 = 3 (round before fit), 49 = 3, 18 = 2-ish (not stored high), 32 keys = 2.
Pictures: shots/c-31f-before (v29.53), c-31g-after, c-31h-after, c-31i-after (all 19 screens at v29.57).

Critic keeps asking for (shared, not pause-specific): 48x48 header close X on EVERY modal, full-screen slab -> centred 960x680 card, key cap + word footer hint, chamfer corner removal, focus ring on ghost buttons, toast not over a modal (the toast is positioned above settings footer by an old check on purpose).
These are shared-shell changes (one X for every modal, replacing footer Close buttons that old checks click by id) so they need a separate shell task, not a pause/settings task.

Keys window P1s still open: lowercase action names, per-row Rebind button duplicate, instruction bar, 13-15px text.
Settings hub P0/P1: two stacked tab strips, subtitle "So you are too good for default settings, eh?" is his line (do not reword/delete), toast over footer (kept on purpose).

Old pins: REGRESS 6137 wants pause title 32px / legend 16px; 27283 wants legend >=15px with keycaps; ui-shared check 29.33 forbids raw px/rgba literals in ui-shared (use var()).
Genp: next card number is P13.
