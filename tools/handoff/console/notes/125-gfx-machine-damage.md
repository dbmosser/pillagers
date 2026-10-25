# 125-gfx-machine-damage (lane a, 10-25)
- Built S\mk-cw-machdmg.ps1 (gfxDmgLevel, gfxDamageFx, gfxBodyFx now calls it). PREFLIGHT PASS as v34.73.
- shipq.sh cw-machdmg STOPPED 3 times: tools/mkfixture.ps1 has uncommitted edits (modified 10:19, not mine, git diff --stat empty).
- (lane b, 10-25) Shipped by the coordinator as v34.74. Pictures: notes/shots/125/after/01-machdmg-1080.jpg and -4k.jpg (own recipe notes/shots/125/recipe.json, run with uishots -Recipes; one machine at 40 percent hp, another at 15 percent, player beside them, single window).
- Look: the damaged machine is in view but the dark smoke is hard to see (small, 0.4 alpha dark puffs on dark ground). Sparks and eye flicker are not caught in a still. Watch in play; maybe raise puff alpha or size if it cannot be seen.
- NOT done: player 2 window picture (needs a host pair, no recipe), and the 4K frame numbers (GFX is a closure variable, unreachable from the camera script; needs tools/fuzz.ps1 -Size 3840x2160 on a scratch port).
- (old) Next run: run shipq.sh cw-machdmg again; then 1080p and 4k pictures (uishots) and the frame numbers in the DESIGN line (check budget 0.5 ms a frame).
