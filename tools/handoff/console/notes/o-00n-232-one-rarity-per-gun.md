
--- codex run 2026-10-29 04:22 ---
2026-10-29, first preparation on v36.37.

Prepared cw-cx-onerarity. Each original gun id becomes its former higher copy: Compact SMG blue, Magnum/Burst Carbine/Riot Scattergun/Auto Rifle purple, Support MG gold. Damage is the former higher damage and item value is the former higher value. The other guns stay as they are. There is one live gun and item id per model; the six old _v ids are migration names only. All sources share the promoted definitions, including direct weapon grants and arcade loadouts. Field rolls still draw once; no source weights, pickup code, loot sounds or loot-row drawing code changed.

Lower copies keep their original permanent ids, so their cells, locks, kit slots, wear and Forge records do not move. Loading folds old higher ids into that same id before any item or Forge filter runs. This covers stash, armoury, equipped guns, kit/backpack plans, belt plans, locks, wear, Forge marks, floor drops, piled guns, codex and gun tallies. The same conversion runs before restore-code filtering. If old lower and higher records collide, keep the stronger Forge level, larger wear count, both stash copies and combined kill counts. The profile storage key is unchanged.

The draft why text becomes the DESIGN.md entry and includes the requested watch line: each gun has one rarity; the guns that had two are always the better one. These guns always hit 25 percent harder than their old common find, including guns carried by pillagers.

Local verification: mk script printed written, all three game anchors matched once, the patched full game JavaScript and the new regression parsed, and seven fixture retarget anchors matched once with all affected checks parsing. No tracked game or fixture edits. Browser checks, lint, seed fingerprint, shipping and ON HIS PC remain for the lane.

fixture-retarget.json keeps checks 26.26, 26.30, 26.36 and 29.02 testing the replacement behavior after the change, and their original behavior before it. The codex check 26.97 uses a surviving gun and accepts 16 guns before or 10 after. The extra run list includes 9.02 and 29.58.

camera-recipes.json supplies four scenes: migrated stash, Wirt odds, real linked co-op player 1, and real linked co-op player 2. The co-op scenes assert both rosters, migrated profiles, purple Auto Rifle damage 28.75, blue Compact SMG damage 15 and a visible teammate in each window. It opens and closes only its own camera popups and uses the camera browser profile. Await lane gate, camera/critic results and ON HIS PC before calling this task done.


--- codex run 2026-10-29 04:37 ---
2026-10-29, follow-up on shipped v36.38.

Lane reports fixture retarget commit 21e5949f0, all seven listed checks passed on the v36.37 trial first, cw-cx-onerarity shipped, and ON HIS PC v36.38 confirmed after 33 seconds. No further game change is needed from those results.

Reviewed round 1 pictures: the stash displays purple Magnum copies, blue SMG, purple Carbine/Scattergun/Rifle and gold Support MG. Wirt shows the promoted rifle and a gold probability row. The real linked host recipe passed in both resolutions, proving both local weapons, 28.75 Auto Rifle damage, 15 SMG damage, matching rarities, two-person rosters and a visible teammate in BOTH windows. The player 2 camera itself did not stage; its title screenshot is invalid as gun verification and its title critique does not apply to this task.

Changed camera recipes only for round 2. The reverse player 2 setup now waits for the popup host's complete profile boot before starting its link, resets the camera guest before pairing, uses separate pair codes for the two scenes, and sends ready again after host setup. Added state diagnostics if pairing still fails. This addresses the setup race without changing game networking. Both views use the existing folded controls and pillager-board settings to show the settled raid HUD. The stash focuses its existing Magnum hover card to show the upgraded damage. Wirt gets a funded test wallet. All camera scripts parse.

Round 1 critic: stash 3 (meets its score floor), host raid 3, player 2 title 3 (invalid stage), Wirt unscored because critic-cache.json could not be written. The broader stash/HUD layout suggestions concern unchanged UI and are handed to the UI lane in alarms; no loot-row changes or unrelated menu redesigns added to this gun rule task. Await corrected player 2 picture and critic round 2.


--- codex run 2026-10-29 04:42 ---
2026-10-29, final verification on v36.38.

Task shipped as commit 704100ed0 (cw-cx-onerarity). ON HIS PC v36.38 was confirmed by the lane. DESIGN.md contains the exact requested watch line and the 25 percent damage note. Check 36.38 passes on the new build and fails on v36.37. The seven retargeted/extra checks passed before shipping; the ship passed its normal gates, including the unchanged seed fingerprint requirement.

Camera round 2 succeeded for ALL FOUR scenes at BOTH 1080p and 4k. Reviewed the attached pictures from both actual linked raid windows. In each window the Auto Rifle is purple and the Compact SMG blue. Each view's recipe verified both peers: rifle id rifle, damage 28.75, rarity elite; secondary id smg, damage 15, rarity rare; roster 2 and one visible teammate. The player 2 camera setup race is fixed without any game/network changes.

The focused stash picture shows the migrated Magnum stack with its lock and 77.5 damage. Both lower and former higher saves now use that same purple gun. Wirt's rarity rows match the promoted item definitions; the green and common rows still correctly cover non-gun prizes. No pickup, sound or loot-row layout edits were made.

Pictures: tools/handoff/console/notes/shots/o-00n-232-one-rarity-per-gun-recipes-2/rarity-coop-p1-1080.jpg and rarity-coop-p2-1080.jpg are the valid two-window evidence; rarity-stash-1080.jpg shows the migrated Magnum and rarity-gamble-1080.jpg shows Wirt odds. Matching -4k.jpg files are in the same folder. report.json records all eight successful stages.

Critic scores remain host raid 3, guest raid 2, Wirt 2, stash 3. These do NOT meet the broader HUD/Wirt presentation targets. Their remaining findings are existing layout requests outside this gun rule change and are already handed to the UI lane; no unrelated redesign was added. The claimed capital I in run info is a false alarm: NCLOWER is 1, ncFix lowercases strings, and the shared canvas fillText wrapper passes them through TX. The task-specific finish condition (shipped and ON HIS PC), save migration check and both-window proof are complete. Stop here as ordered; no more game changes or camera rounds requested.

