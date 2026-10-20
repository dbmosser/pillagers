
--- codex run 2026-10-20 14:52 ---
2026-10-20: Prepared cw-cx-goldnames against v32.99. No tracked game file was edited.

The host now passes the fallen body kind into goldDrop and stores it for the death word. The word adds a fifth field, keeping the original four fields in place. The linked receiver uses that kind even when the body never reached its window. Older four-field words use a cached body when available. One helper produces golden sentry down, golden pillager bot down, golden crawler down, golden bulwark down, golden howler down and golden listener down. Search the hoard, loot, effects, timing and random draws stay as before.

The new fixture check tests every name directly, then exercises goldTick, goldDrop, goldNetOut and goldNetTake for all six kinds. It verifies the subtitle, one hoard on the host, no second hoard on the receiver, no repeated callout, and the older-word fallback. The control build lacks the helper and returns a failure. Three older checks expect the generic words; fixture-retarget.json keeps them valid on both old and new builds before shipping.

Local validation: mk script printed written; all eight anchors matched exactly once; patched inline JavaScript and the new check parse with Node; all three fixture anchors match exactly once. No Chrome or runtime check was run in this sandbox. The lane owns preflight, shipping and runtime results.

Four camera recipes stage sentry and pillager bot callouts through both the host death path and the linked receiver path. These are separate staged views, not a connected two-window play session. Pictures and critic results remain for the lane. No layout or game-feel changes are included.

