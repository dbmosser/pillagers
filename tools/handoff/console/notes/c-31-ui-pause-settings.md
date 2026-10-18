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

Run 4 (v29.59 cw-keysclean): keys window lost the per-row Rebind buttons and amber section labels (key cap is the button now), min-width via var(). Critic on 32 keys: 2 (before 2), better_than_before yes. Still P0: full-bleed slab (list stops at x=1530 of 1900, dead right strip), no 48x48 header X, Reset to defaults on the left. Pictures: shots/c-31i-after -> c-31j-after.
Run 5 (v29.63 cw-setcard, v29.64 cw-setfeel, v29.65 cw-setone): Settings/Keys card 1360/1080 px via var(), row hover bar on keys, Send play data folded into the one section strip (title tabs hidden on Game page). Critic on 26: 2 (better_than_before yes). Open P1: controls ~700px from labels (limit 400), type 14/15/18 drift, footer hint strip + Done, list ends mid-row (no fade mask), detail pane mostly empty, close X glyph small. Subtitle is his line: leave. Pictures c-31k-before, c-31l/m/n-after.
Next step if resumed: shrink #setlist width so control sits within 400px of label, fade mask at list bottom, bigger header X (shared shell).
Run 6 (v29.67 cw-setslim): detail pane to bottom strip, pause card 480 wide, fixture 640 pins retargeted (fbf5baea). Critic: 26 = 2 (same), 25 = 3 (better), 32 = 2. Open: stepper 750px from label (cap rows ~900px), focus state on rows, 'Send play data' tab as separate nav, left-aligned pause title + header X + B glyph (shell). Subtitle is his line: keep. Pictures c-31o-before, c-31p-after.
Run 7 (v29.72 cw-setnear, v29.75 cw-setnear2, v29.77 cw-settab1, v29.78 cw-settoast): steppers now right-aligned at row edge (6x48 wide, card 15x48), section tabs one row (Send play data no longer wraps), toast hidden while Settings/Keys is open. Critic: 25 = 3, 70 = 2 (generic: pad focus state, tab padding, Edit the words footer, 'Send play data' as orphan tab). Pictures c-31s-after, after2, after3.
Run 8 (v29.80 cw-setheight): settings and keys card height fitted to the viewport. Critic: 32 keys = 2 (better yes; new P1: World row cut mid-row at list bottom, no pad focus ring on caps, 13px section labels), 18 = 2 (better yes), 70 = 2 (better yes; P1 cut half row, footer 'Edit the words' strip, tiny steppers). Pictures c-31t-before, c-31t-after. Next small step if resumed: 24px fade mask at list bottom or snap list to whole rows (56px pitch); section labels 16px.
STUCK: all remaining P0s are the shared modal shell (centred 960x680 card, header X on every modal). Needs its own shell task, not a pause/settings task. Ending PARTIAL.
