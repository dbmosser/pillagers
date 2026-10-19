
--- codex run 2026-10-19 19:26 ---
2026-10-19: Prepared cw-cx-floorbag for J5. The open floor backpack now takes the pad before hub station bindings. D-pad goes through raidKey/bagArrow; A uses bagPadAct/bagPadCell and the existing floor mouse handlers; B closes through backOut; View and Menu keep their existing actions. Physical button edges spend held presses, including A held from a menu.
Y shares bagDropSel but routes hub items through unpackSome and hubDropMake. It updates the live floor bag and uses existing floor-crate persistence and sharing. No raid container is created in the hub.
The check uses a stub standard pad with no keyboard events. It checks View, every D-pad direction, A pickup and placement onto belt key 5, removal of that gun from the grid, one recoverable medkit floor drop on held Y, station-key isolation, and B close with the belt assignment saved. The old build records independent navigation, pickup, placement, drop and close failures; View already works there and is covered as a regression.
The existing 15.59 check forbids the obsolete D-pad-left drop hint, not D-pad movement, so no fixture retarget is needed. The floor keyboard hint is unchanged. Runtime checks, preflight, shipping and pictures belong to the lane.

Local verification: the mk script prints written; all three anchors match once; the patched inline game script and the regression check parse in Node; the mk script is ASCII. Two camera recipes stage the actual stub-pad highlight and a held shotgun over belt key 5.

