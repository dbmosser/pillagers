
--- codex run 2026-10-29 14:03 ---
2026-10-29, run 1, starting v36.54.

Both spare failures are stale expectations following the mark merge. No broken old-map mouse route was found. keysMouse still dispatches Mouse1 through keyRemapEvent and raidKey to netPingMake. An old map containing KeyV:KeyV, KeyZ:KeyZ and KeyR:KeyK leaves Mouse1 on its default, preserves reload on K and preserves the old melee/drop pair.

35.74 presses middle mouse at the same cursor point first with defaults, then with an old map, without clearing the first mark. Spot marks now persist. The second press correctly clears that mark and NET.pingLast, causing the reported false failure. Retarget isolates these two independent input cases by clearing the previous mark before each. 36.52 continues testing same-spot toggle, persistence, expiry, one mark per seat and relay.

20.76 counts words beginning with ping. padMiniBuild already calls its D-UP row mark, hold: map. Retarget counts the action under either name so it passes before and after this ship, and checks D-UP beside it. No controller row was missing. The keyboard compact party row still said ping; cw-cx-marklegacy changes that word to mark and aligns the static controller fallback with its runtime builder. No input, network, timing, damage, profile storage or world-generation code changes.

New regression check: actual middle mouse DOM events on the old saved-map shape in solo, host and join roles; one shared mark record and actual raid/map/minimap drawing in each role; png reception and host relay; saved keys unchanged; compact keyboard and controller mark rows exactly once, with D-UP on a pad. It fails on the starting build at the keyboard compact row, which still says ping. The two replacements address that failure. Existing checks 35.74, 20.76 and 36.52 are listed in fixture-retarget.json for the lane to run before shipping.

Sandbox verification passed: mk printed written, both game anchors matched once, both retarget anchors matched once, check and recipe JavaScript parsed, mk and retarget are ASCII. verify-source.js executes the actual extracted mouse/remap/mark functions: default and old maps each set one spot; another press clears it. This is source-level evidence, not a browser or linked-window result. The game file and fixture were not edited.

LOCAL: no linked review. The game changes only local legend words. The task explicitly requests real two-window functional evidence, so camera-recipes.json supplies that without a helper review: solo, actual demo p1 and actual demo p2. The pair setup is reused from o-00u-238, with all status-specific staging removed. Each demo recipe opens and links real game windows, sends middle mouse events from both with old maps, waits for png arrival in both, checks same-spot clear and replace, and checks actual raid/map/minimap drawing and both device legends in each window. Each role gets a picture. The recipes throw on missing delivery or drawing. They use only the lane camera's disposable origin and close their popup.

Awaiting lane fixture retarget, preflight, ship, ON HIS PC, camera assertions and critic results. Do not call this shipped before that evidence arrives.

Watch: middle mouse places one mark; pressing that spot again clears it in both windows. Moving it replaces the old mark. D-UP marks on a pad, and old reload/melee/drop keys should stay where they were.

