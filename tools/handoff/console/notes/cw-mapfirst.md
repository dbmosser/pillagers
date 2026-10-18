# cw-mapfirst (his note 2026-10-18 11:48, build 30.57)

His words: "raid should show map at the beginning of the game and player has to click to proceed into the actual raid, clock/game doesn't start until map is dismissed, that way player can see where relevant hotspots, etc are".

Shipped: v31.09 (cw-mapfirst, commit 9d8daa08) and v31.23 (cw-mapfirst2, commit 3afb7e6f, the prompt as the style guide primary button and the footer the map leaves for it). Fixture commit 90543fe2 (MAPFIRST.skip=1 in the fixture) and 4bdd87c9 (check 31.09 accepts both wordings).

## What a raid start is now (DEMO and CAREER, 1 or 2 players)
- startRaid ends with mapFirstBegin: G.mapFirst=1, G.mapOpen=true, over a frozen world. The freeze is the one there already (syncPause sets G.paused while mapFirstOn(); netPauseLive is false while it is up). No second clock: the raid clock, enemies, weather, bleed, spawns, superhot and the ambient bed do not move. The rise-from-underground animation waits for the press too (the first click no longer skips it).
- One prompt under the map, lower case, the last device used: lime button "click to start" with the key chip e on keys and mouse; "start" with the a button on a pad. After the press the same-size panel button says "waiting for p2" (or the other seat name) with three dots.
- Start: left click, E, Space, Enter, Esc, Tab or M, or pad A. B and D-up shut the map and count as the press too (the map is forced back up until the press is answered, so a map never "closes" into a live raid by accident). The press must come 0.25 s of loop time into the raid, so the click or key that launched it cannot also start it; a key repeat never counts; the click is never a shot and is not left held. Every other key is held back while the map waits (P still pauses, F5 and friends still work).
- 2 players (same PC or linked): each state word carries mf (0 running, 1 on the map, 2 pressed). The clock starts for a window when it has pressed and no shown seat is still on its map; a window that has not pressed yet follows any seat that is already running; a seat that said it came up but sent no word yet is waited for 4 s; a shared raid lets go by itself after 60 s. Late joiners are joined on the map only if the host is still on it. A benched arcade host (player 2 started a fresh raid) has nothing to press.
- PARTY arcade (?party): nobody may be at the machine, so the map closes by itself after 20 s for both windows and the clock starts. A non-party arcade or career raid has no timeout for one player.
- Not held up: the bot sim (G.sim) and every fixture raid (MAPFIRST.skip=1 in the fixture; check 31.09 turns it back on itself). verifySafe fingerprint unchanged (ents 85/374, containers 165/593).
- No settings row (one control per job). The map header hint "click to set a waypoint" is blank while the map waits (the click starts the raid there); a map opened with M is as before.

## Pictures
- before: notes/shots/cw-mapfirst-before/20-raid-hud-drop-*.jpg (the raid he used to land in), 22-raid-map-open-*.jpg (the map he had to open with M).
- after v31.09: notes/shots/cw-mapfirst-after/ (60 keys, 61 pad, 62 waiting for p2; 1080 and 4k). At 4K the pill sat on the map frame.
- after v31.23: notes/shots/cw-mapfirst-after2/ (same three, 1080 and 4k). Recipes: notes/shots/cw-mapfirst-recipes.json (lane h camera port 9368).

## Critic
- 1080 keys picture (before 22 vs after2 60): score 2, same as before. All P0/P1 left are the old map art (palette and frame, label collisions, zone names unreadable, no header row or X); the prompt findings from the first run were fixed in v31.23. Logged once in questions.md. Findings I did not follow because they reverse his words: "start run" (his note and the lore say click to start; you ascend).

## Left
- A restyle of the whole sector map (its own UI job, see questions.md).
- Real-game CDP tools and soak runs that deploy a raid on the real page (not the fixture) now see the map first and must press.
- Non-party arcade and career raids with one player never time out on the map; shared (non-arcade) raids let go after 60 s.
