
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


--- codex run 2026-10-29 14:14 ---
2026-10-29, run 2, v36.55.

Lane confirmation: fixture retarget committed as 3321d1fff. Checks 20.76, 35.74 and 36.52 passed on v36.54 before the game word changes. cw-cx-marklegacy shipped v36.55. ON HIS PC v36.55: 8802 served it 65 seconds after ship; he reloads to play it.

Round 1 pictures reviewed: mark-legacy-demo-p1-1080.jpg and mark-legacy-demo-p2-1080.jpg show both amber/cyan marks, one N mark row in p1, one D-UP mark, hold: map row in p2. Old saved controls visibly remain K reload, V melee and Z drop on the keyboard. The real two-window recipes passed at both 1080p and 4K: both sender directions, both shared mark records, same-spot clear/replace in both windows, two raid markers, two minimap glyphs, one map glyph per mark, unchanged old keys and exactly one mark row per device legend. These are actual paired arcade windows, not role simulations.

Solo recipe failure was my camera assertion, not game input: it incorrectly required a keyboard party row with NET.on=false. The raid/map/minimap assertions precede that assertion. Corrected readLegacy to expect zero keyboard mark rows in solo, one in a party, and one controller mark/map row in either mode. It still requires one actual solo mark drawn in all three views. This is a camera-only change; no additional ship key is needed. All three generated recipes parse. Resubmitting camera-recipes.json for final round 2.

Round 1 critic scores: p1 3, p2 2, solo 2. The critic mistook the deliberately opened controls lists for an arrival default. Recipe descriptions now explicitly state that these lists were opened by the test to show the changed word; this task changes no arrival behavior. Existing overall HUD findings concern timer/score layout, hp/armour bars, hotbar, current-pillagers roster, world labels, feed/shield overlap and compass/world mark-distance presentation. Logged for coordinator rather than bundling an unrelated HUD redesign into this party input regression. The tested mark and legend behavior is green in both real demo windows. Overall raid HUD visual acceptance remains below 4; no acceptance claim is made.

Pictures: tools/handoff/console/notes/shots/o-00w-244-ping-after-mark-merge-recipes-1/mark-legacy-demo-p1-1080.jpg; same folder mark-legacy-demo-p2-1080.jpg and mark-legacy-solo-1080.jpg. Retain the two demo pictures as functional evidence; the solo picture accompanied failed staging and is not a successful solo test record.

LOCAL: no linked review. Shipped code changes only two legend words. Watch: middle mouse sets one mark, pressing that spot again clears it in both windows, and D-UP marks on a pad. Old saved key assignments should stay where they were.


--- codex run 2026-10-29 14:17 ---
2026-10-29, final run, v36.55.

Final camera round 2 passed solo and both actual demo roles at 1080p and 4K. Solo has one persistent mark, raid=1, minimap=1, map=[1], D-UP mark/map row once, and the correctly absent party-only keyboard row. Both real arcade windows have two marks (one per seat), raid=2, minimap=2, map=[1,1], N mark once and D-UP mark/map once. The recipes also verified genuine middle mouse events from each window with the old keymap shape, both-way png delivery, clear/replace delivery and old key assignments unchanged.

All task-specific checks and live-window requirements are complete. cw-cx-marklegacy is shipped v36.55 and ON HIS PC was confirmed by the lane (65 seconds after ship). Retarget commit 3321d1fff; checks 20.76, 35.74 and 36.52 passed before the word changes, and the new regression shipped with the key. Root cause was stale test assumptions, not a missing middle mouse route: the old test pressed one persistent spot twice and correctly cleared it. The actual game change aligns the compact keyboard word and static pad fallback with the merged mark action.

Final pictures inspected: notes/shots/o-00w-244-ping-after-mark-merge-recipes-2/mark-legacy-demo-p1-1080.jpg and mark-legacy-demo-p2-1080.jpg show both colored marks and one mark row per device. mark-legacy-solo-1080.jpg is now a successfully staged solo test. Round 2 remains overall HUD critic p1=3, p2=2, solo=2. Two permitted camera rounds are exhausted; do not present the overall HUD as visually accepted. Its unrelated existing findings were already handed to the coordinator. The controls list is deliberately opened in these test pictures, not an arrival-default change. No additional game changes are needed for this input/legend regression.

Best retained evidence: round-2 demo p1 and demo p2 pictures, with their paired reports proving all three views; round-1 demo pair is retained as the other complete version of the evidence. Both sets have the same shipped code and critic scores. The corrected round-2 solo picture supersedes its failed-staging round-1 version.

LOCAL: no linked review. Explicit task-required linked functional verification has nevertheless passed in actual demo windows. Watch at the party: middle mouse sets one mark; pressing that spot again clears it in both windows; moving it replaces the old mark. D-UP marks on a pad. Old saved keys stay where they were. Task complete; no pending key, retarget or camera work.

