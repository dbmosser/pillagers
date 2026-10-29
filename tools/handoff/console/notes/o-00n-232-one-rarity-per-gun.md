
--- codex run 2026-10-29 04:22 ---
2026-10-29, first preparation on v36.37.

Prepared cw-cx-onerarity. Each original gun id becomes its former higher copy: Compact SMG blue, Magnum/Burst Carbine/Riot Scattergun/Auto Rifle purple, Support MG gold. Damage is the former higher damage and item value is the former higher value. The other guns stay as they are. There is one live gun and item id per model; the six old _v ids are migration names only. All sources share the promoted definitions, including direct weapon grants and arcade loadouts. Field rolls still draw once; no source weights, pickup code, loot sounds or loot-row drawing code changed.

Lower copies keep their original permanent ids, so their cells, locks, kit slots, wear and Forge records do not move. Loading folds old higher ids into that same id before any item or Forge filter runs. This covers stash, armoury, equipped guns, kit/backpack plans, belt plans, locks, wear, Forge marks, floor drops, piled guns, codex and gun tallies. The same conversion runs before restore-code filtering. If old lower and higher records collide, keep the stronger Forge level, larger wear count, both stash copies and combined kill counts. The profile storage key is unchanged.

The draft why text becomes the DESIGN.md entry and includes the requested watch line: each gun has one rarity; the guns that had two are always the better one. These guns always hit 25 percent harder than their old common find, including guns carried by pillagers.

Local verification: mk script printed written, all three game anchors matched once, the patched full game JavaScript and the new regression parsed, and seven fixture retarget anchors matched once with all affected checks parsing. No tracked game or fixture edits. Browser checks, lint, seed fingerprint, shipping and ON HIS PC remain for the lane.

fixture-retarget.json keeps checks 26.26, 26.30, 26.36 and 29.02 testing the replacement behavior after the change, and their original behavior before it. The codex check 26.97 uses a surviving gun and accepts 16 guns before or 10 after. The extra run list includes 9.02 and 29.58.

camera-recipes.json supplies four scenes: migrated stash, Wirt odds, real linked co-op player 1, and real linked co-op player 2. The co-op scenes assert both rosters, migrated profiles, purple Auto Rifle damage 28.75, blue Compact SMG damage 15 and a visible teammate in each window. It opens and closes only its own camera popups and uses the camera browser profile. Await lane gate, camera/critic results and ON HIS PC before calling this task done.

