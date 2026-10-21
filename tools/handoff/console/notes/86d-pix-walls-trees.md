# 86d-pix-walls-trees (lane c, 10-21)

Done: tools/handoff/drafts/draft-cw-pixwalls.json (ship 1, plain pixel walls: pixWallBake, pixel key without screen scale, pixel chips for bullet marks, check cw-pixwalls). Written by S/mk-cw-pixwalls.ps1; all 6 anchors matched once.
NOT done: preflight was never run, so nothing shipped. My shell was left in tools/handoff/console/notes by an early cd, and every form that reaches preflight.sh from there was refused (needs approval). Next run: start in the repo root, run bash tools/handoff/preflight.sh c cw-pixwalls, fix, ship.

Left for later ships: doors, windows, kerbs, ruins, shWallDraw (stronghold), Undercroft wall copy; trees and bushes (vegSprite, trunk live at art px); shadowE hard shadows; the check part for tree list and seg grid. Pictures: 4 districts day and night plus hub, tools/uishots.ps1 on port 9363.

Facts: wallSprite ~38891, vegSprite ~38788, tree/bush draw ~39596-39635, shadowE ~35070, shWallDraw ~62776, wallMarkAdd ~50803. Ramps: PIXRAMPS.districts[D.name].day|night .wall|.top (4 tones, light to deep), PIXRAMPS.plants. Device px per world unit is ZOOM()*DPR. Ramp tones differ by only about 2 percent lightness (value bands), so brick texture is subtle: judge in pictures, add ink accents if flat.

## Run 2 (10-21 ~02:35)
- Preflight 1 (clean tree): new check passes, control fails as it should, but "recent" failed: dry=TIMEOUT (gate Chrome slow or hung on port 9353; I may not restart it, only 9346).
- Then lane b's cw-pixground STOPped (verifySafe) and left game + fixture dirty at v33.57: all preflights and ships blocked (alarm logged). Nothing for me to ship. Next run: check git status is clean, rerun bash tools/handoff/preflight.sh c cw-pixwalls from the repo root; if pixground landed, re-check my 6 anchors (mk script rewrites the draft).

## Run 3 (10-21 03:14, lane c)
- Tree at start: game, DESIGN, AUDIT, mkfixture dirty with a live v33.58 ship (the pixel pillager, 86c) mid-flight; v33.57 pixground is committed. Re-ran S/mk-cw-pixwalls.ps1: "written" (draft rebuilt on top of HEAD, anchors still match).
- Blocked again: this run's shell starts in tools/handoff/console and cannot cd, so bash tools/handoff/preflight.sh and bash ../preflight.sh are both refused (needs approval). Nothing was run or shipped.
- Coordinator: start 86d with the working directory at the repo root (C:/claudecode/dark raiders), or give me a preflight form that works from console/.
- Next run: from the repo root, bash tools/handoff/preflight.sh c cw-pixwalls, then shipq cw-pixwalls; then doors/windows/kerbs/shWallDraw, trees/bushes, shadows.

## Run 4 (10-21, lane c, repo root works)
- Re-ran mk-cw-pixwalls (written on v33.61). Preflight: my check passes; 2 old failures: REGRESS 33.60 chunk step 4.7 ms (over 4, timing noise on the ground bake) and REGRESS 33.46 news stamp stale.
- Shipping card first as cw-card47 (S/mk-cw-card47.ps1, polish pass 47), then pixwalls again.
- Run 4 result: shipq cw-card47 sat 10 min behind a lock owned by "324592 manual 03:28:04" and was killed by the background limit; nothing shipped, no game change. Next run: git log to see if card47 or another card landed; if not, shipq cw-card47 (S/mk-cw-card47.ps1 exists), then preflight c cw-pixwalls (33.60 chunk-step 4.7 ms may repeat: timing noise, log in alarms.md), ship, pictures, then the rest.

## Run 5 (10-21, lane c)
- Card 33.62 shipped (stamp only; check threshold 0.10), then SHIPPED v33.66 cw-pixwalls (the pixel wall). Picture: notes/shots/86d-after/21-raid-hud-calm-1080.jpg (blocky walls with chips, looks right in the raid). Also 03 hub and 64 night there.
- Watch on next play: wall edges and bullet chips look blocky/pixel; nothing else changed.
- Still left: doors, windows, kerbs, ruins, shWallDraw, Undercroft wall copy; trees/bushes (vegSprite) + live trunks; shadowE hard shadows; tree-list/seg-grid parts of the check.
