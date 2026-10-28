# 203-melee-z-middle-ping notes

- Approach: the game still reads melee as logical KeyV and drop as logical KeyZ (pad, finisher hold, raidKey, old checks unchanged). New KEYS_DEF {KeyV:KeyZ, KeyZ:KeyV} is the default physical key; keysOf falls back to keysDef; keysInv builds from every action; keysBind cleanup and the Keys window amber flag and legendKeys compare to the default. KEYS_V 3.
- Migration keysMig (called by applyLoadedProfile): v2 save that never touched V or Z gets the new defaults; one that moved melee/drop or put another action on V/Z keeps both pinned where they were. Storage key unchanged. ARCADE_SBX keymapV 3 (demo plays Z melee, V drop).
- Text: LEGEND / LEGEND_MINI labels Z melee, V drop (LEGEND_MINI_CODES Z -> KeyV, V -> KeyZ), party compact row V drop to trade, backpack hints name keyName(keysOf('KeyZ')). Pause box, Keys window, finish prompt follow keysOf already.
- Middle mouse: already pinged on the old build (control run of the new check had no ONE failure: default map and an old saved map both ping). No change.
- Old check 27.83 retargeted (HOLD [key] FINISH as set), fixture commit 4dd5ed4ef, 27.83 PASS.
- Preflight lane d PASS (control fails on TWO/THREE, newest 80: 0 new failures).
- Seen on the before shot: the raid HUD board says "current pillager bots 3" (his 10-28 AM words order: never "pillager bots"). Not this job; another lane (cw-clockcard fixture commit mentions "current pillagers").
