# b-30-ui-hud notes
- Before shots: notes/shots/b-30-before (screens 19-24,33,34,36,37,48,50,51,61,78), lane b port 9362.
- Critic on 21 and 33 (before only): both 2. Generic asks: legend table hides (already collapses after 3 raids, F1 cycles), toasts deduped, one panel style, 16px min text, SP not $ on pillagers board.
- Code: drawMinimap 38540, drawHUD 38573, pillagers board ~41395-41510 (title 'CURRENT PILLAGERS', '$'+val is LOOT VALUE like stash/bag, not score; left alone), Run info ~39197, legend 40345-40411, say() 19617.
- Do NOT change feel values. Fixture tests lock the HUD layout heavily (HUDBOX checks).
