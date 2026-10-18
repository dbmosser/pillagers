# b-30-ui-hud notes
- Before shots: notes/shots/b-30-before (screens 19-24,33,34,36,37,48,50,51,61,78), lane b port 9362.
- Critic on 21 and 33 (before only): both 2. Generic asks: legend table hides (already collapses after 3 raids, F1 cycles), toasts deduped, one panel style, 16px min text, SP not $ on pillagers board.
- Code: drawMinimap 38540, drawHUD 38573, pillagers board ~41395-41510 (title 'CURRENT PILLAGERS', '$'+val is LOOT VALUE like stash/bag, not score; left alone), Run info ~39197, legend 40345-40411, say() 19617.
- Do NOT change feel values. Fixture tests lock the HUD layout heavily (HUDBOX checks).
- Style guide is READY (10-ui-look-book). Audit list is in notes/ui/hud.md.

## Run 2 (2026-10-18)
- SHIPPED v29.29 (cw-legend30): the compact controls list folds to its one-line hint 30 s into a raid, once (legendAuto in drawHUD); F1 still cycles; arrival stays open (his v6.68). Preflight PASS, gate PASS, fingerprint intact.
- Not shipped (each its own cw- ship, preflight lane b): run info 3 lines max + 16 px floor; one hero number (ammo) with credits 20 px; stamina label inside its bar; extraction chip gap 8 px; dedupe centre rows vs feed (touches v27.24 feed1 order, needs a fixture sweep).
- No after pictures or critic scores yet (screen 21 stages at t=0 so the legend change shows only after 30 s; need a screen staged at 31 s to see it).
- TASK PARTIAL.
