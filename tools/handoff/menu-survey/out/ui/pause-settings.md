# pause-settings (c-31-ui-pause-settings), rev 2026-10-18 evening: his picks q29, q30, q31, q32, q05
Before shots: notes/shots/c-31-before (screens 18,25,26,32,42,49,68-75, 1080).
Code map: .pausebox CSS at html line ~714 (old look: rgba(17,19,21,.9), h3 25px uppercase-class, gap 11px); .modal at ~720 (padding 22px).
Settings = #settingsmodal, #setwrap > #setlist + #setdetail; openSettings(tab) at ~64242.
Shared look: <style id="ui-shared"> ends at line ~1401, tokens --fs-*, --sp-*, --rad, --btn-h*; the check 29.33 forbids raw color/px literals inside ui-shared (only 1px/3px allowed). With the new look every new size and colour (glass, 4px, 6px, 12px, 16px, 56px, 72px) must be a :root token first (tasks 20, 21a and 21b), or the 29.33 allow-list is extended in the same ship by fixq.sh. Do not add raw literals.
Pattern to copy: S/mk-cw-uishared-board.ps1 (append rules before </style> of ui-shared).

## What his picks replace
Before pictures: pause box (25, 42) = small panel mid-screen, "Paused" title 25px amber, key chips line, 6 buttons in one row, wasted panel height. Keys window (32): 2-column rebind grid with huge empty space right, intro text 2 lines duplicated.
- Pause (q29 C): a tile grid. "paused" 48 centred at y200; six tiles 300x200 (3 columns x 2 rows, gap 24, from x486 y330): resume (lime fill, ink), settings, controls, feedback, what's new, end run (2px danger). Solid 56px icons. Focus = 4px lime ring + scale 1.05; opens on resume. Feedback line under the tiles (small 24 muted, y790). Hint bar "a select   b resume". Backdrop = blurred world under 55 percent black (q07), HUD hidden. A pause stays paused (Q29).
- Settings (q30 C): one long page in a glass window W (1728x972 at x96 y54), header "settings" 48 + X; sticky chip row (the raid, audio, controls, controller, display, accessibility) that jump-scrolls 250 ms; sections stacked with a heading (body 32), rows 72 high 1000 wide centred, "< value >" steppers; one help line under the focused row; thin 6px lime scrollbar; no help box on the right (the old #setdetail pane goes for settings); save file, restore and tuning at the very bottom; "send play data" moves to the feedback window.
- Controls (q31 D): ONE window "controls" with tab chips keyboard / controller (lb rb); one column 700 wide; section headers move/fight/world; rows 72 with the key cap or pad glyph right; the rebinding row says "press a key" or "press a button"; "reset to defaults" ghost; hint "esc cancel   del clear". Replaces the keys window (32) and the separate pad-buttons window.
- Buttons (q05 C): bar and wash; danger = 2px #ff5a3c.
- Motion (q09, q10, q32): pop open, spring glide on the tile ring, rows rise on controls tab switch (see motion.md).
- Text lower case (his 10-18 order): "paused", "end run", "what's new". The old 'Abandon run' / 'Resume' mixed casing is gone.
Jobs: task 30a = the pause tiles and the abandon confirm; task 30b = the settings page; task 23a = the key and pad glyphs; task 23b = the controls window (q31 D). v30.89 (cw-cardwide) already makes Settings and Keys fill the screen less 48 px each side with one 960 wide column: task 22a sets the exact window (1728x972 at x96 y54), 30b the 1000 wide rows, 23b the 700 wide controls column.
Critic baseline stays as before until the new shots are taken.
