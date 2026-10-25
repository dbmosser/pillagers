# 124-gfx-coloured-flash-light (lane b, 10-25)
- Change: three put() swaps in gfxLightPass: flashes use F.c, hunting machine eyes use the eye-glow red, the beacon uses teal. Same draw count (cached sprite per colour), so no frame cost. His lamp and the teammate lamp stay white.
- Draft: mk-cw-flashlight.ps1 (scratchpad), preflight PASS as v34.73.
- NOT shipped: shipq STOPs "the game or fixture has uncommitted changes". tools/mkfixture.ps1 shows M in git status but git diff HEAD is empty (stale index stat, not a real edit). Retried after two lock cycles, same.
- Left: coordinator runs git update-index --refresh, then bash shipq.sh cw-flashlight; then night pictures (both windows, 1080p and 4K) and 4K frame numbers for the DESIGN.md line.
