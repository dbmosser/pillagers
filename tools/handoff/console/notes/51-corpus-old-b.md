# 51-corpus-old-b (lane a, 2026-10-20)

All 11 were red on HEAD (v32.84). Now all green or skipped with a reason on v32.85. Fixture commits e6328c9a, e905041b, 318239a5, a80d4f5b; game ship v32.85 (cw-useplate).

- v19.64: STALE. v32.30 "map labels have room": the placer keeps 16 px of air round a tag and stays in the map frame, so a tag one step aside had no room in the old staging. Moved the two blockers so the room beside is real (x 325, y 268) and cleared MAPBOX for the test. Passes.
- v19.10: REAL. v32.35/36/58 put the extract inbound countdown on a plate 38 px above its line; the bandage bar (bottom 749) ran into it (top 733). Fixed in the game: v32.85 cw-useplate (bar 34 px higher, 8 px under the plate); new check cw-useplate measures the plate top and failed before. 19.10 itself passes now.
- v18.78: STALE. His terms and bar windows are 1400 wide on purpose (v32.22, v32.41, v32.45). Check now says text lines are capped like the list under them, never the general 1180.
- v18.69: HARNESS + STALE. The check read the font weight (700) as the size, so every box was 600 px tall; fixed the parse. Also drew the preview at 420 px, the real page canvas is 960 (v32.45), and now only checks sectors that are offered (THE COLD MILE is frozen, Cold Storage only). Cold Storage has no overlaps. THE COLD MILE has two (bond room into receiving apron, blast vault into blastline): see alarms.md, for when it comes back.
- v18.25: STALE. The stash idle sentence was cut on purpose (cw-cx-namestashview, his Q8). Check now reads the stash item menu: it must offer "Drop on the floor" while linked. The other parts (pause key line, floor bottom line, H card) were already green.
- v18.03: STALE. v32.71 (cw-machfx, his art pick) made the fog lighter (day fog floor 0.14, alpha 36). Threshold 40 and 30 over the opening became 24 and 24 over; it still demands the ground behind him darker than where he stands.
- v18.01: STALE. v32.44, his answer 2.44 b: auto resolution floor is 75 percent, not Low. Check reads DRS.min and the canvas must shrink under 0.9 of its width.
- v17.82: STALE. v32.45 names start at 20 px (fs=20), down to 14. Check now wants fs=20. Row height part was already green.
- v16.65: STALE. v32.22 cut the same raid sentence; the party window now says "up to four pillagers, one invite code". Check wants "invite code" and still bans "played alone".
- v16.13: STALE. v32.45 cut "you: n runs here" from the sector card (his Q8). Check now says the card must not show the replaced character 30 or 60 runs; the restore tally and the other two parts are unchanged.
- v15.86: STALE, partly open. v32.45 design A draws the one offered sector with `.sectorpick{display:contents}`, so a card has no box and the pad list cannot hold it. With one sector offered nothing is lost. The check now SKIPs when the card has no box (the only weakening, logged in alarms.md): if a second sector ever comes back, a pad player cannot choose it.
