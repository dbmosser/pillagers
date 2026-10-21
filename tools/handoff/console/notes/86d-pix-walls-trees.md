# 86d-pix-walls-trees (lane c, 10-21)

Done: tools/handoff/drafts/draft-cw-pixwalls.json (ship 1, plain pixel walls: pixWallBake, pixel key without screen scale, pixel chips for bullet marks, check cw-pixwalls). Written by S/mk-cw-pixwalls.ps1; all 6 anchors matched once.
NOT done: preflight was never run, so nothing shipped. My shell was left in tools/handoff/console/notes by an early cd, and every form that reaches preflight.sh from there was refused (needs approval). Next run: start in the repo root, run bash tools/handoff/preflight.sh c cw-pixwalls, fix, ship.

Left for later ships: doors, windows, kerbs, ruins, shWallDraw (stronghold), Undercroft wall copy; trees and bushes (vegSprite, trunk live at art px); shadowE hard shadows; the check part for tree list and seg grid. Pictures: 4 districts day and night plus hub, tools/uishots.ps1 on port 9363.

Facts: wallSprite ~38891, vegSprite ~38788, tree/bush draw ~39596-39635, shadowE ~35070, shWallDraw ~62776, wallMarkAdd ~50803. Ramps: PIXRAMPS.districts[D.name].day|night .wall|.top (4 tones, light to deep), PIXRAMPS.plants. Device px per world unit is ZOOM()*DPR. Ramp tones differ by only about 2 percent lightness (value bands), so brick texture is subtle: judge in pictures, add ink accents if flat.

## Run 2 (10-21 ~02:35)
- Preflight 1 (clean tree): new check passes, control fails as it should, but "recent" failed: dry=TIMEOUT (gate Chrome slow or hung on port 9353; I may not restart it, only 9346).
- Then lane b's cw-pixground STOPped (verifySafe) and left game + fixture dirty at v33.57: all preflights and ships blocked (alarm logged). Nothing for me to ship. Next run: check git status is clean, rerun bash tools/handoff/preflight.sh c cw-pixwalls from the repo root; if pixground landed, re-check my 6 anchors (mk script rewrites the draft).
