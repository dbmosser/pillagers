# c-31-ui-pause-settings (lane b)
Run 1 shipped: v30.03 card P16, v30.05 cw-setnote, v30.09 cw-setname (fixture check retargeted, commit 0c48627a).
Critic scores now: 18:3 (was 2), 25:3, 72:2, 75:2 (after setnote; not re-shot after setname), 26/32/42/49:3 earlier.
Unscored this run: 27-31, 68, 69, 71, 73, 74.
Stuck / repeated findings (the staged shot has no focused row so the pane shows "Edit the words"; real play differs):
- pane copy "Don't use this unless you know what you are doing!" is the help of the first row (his wording, not touched).
- tabs 17px -> 20px with LB/RB glyphs; "Send play data" in tab strip; first section label repeats the tab (not hidden, Controls tab labels Move/Fight differ).
- list label-to-stepper gap ~400px; scrollbar 4px; backdrop ghost text; no key-hint strip on Settings (Esc/B glyph).
- Pause box: "Esc Resume" is a ::after text, a keycap needs a real element; HUD ghosts through at 99% void.
Next run: tab strip 20px + hint strip in Settings, scrollbar 6px, key-cap hint on pause box, then score 27-31/68-74.
