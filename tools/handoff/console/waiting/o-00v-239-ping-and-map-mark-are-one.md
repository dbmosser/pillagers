# o-00v-239 ping-and-map-mark-are-one : the middle mouse ping and the map waypoint become one mark
HIS WORDS 10-28 about 23:40 EDT (in the Gameplay Edit Intaker chat): "if I mark a spot with middle mouse, it should show up on the map. If I mark a spot on the map, it should show up as a middle mouse vanguard in the raid -- the two need to become the same thing -- got it" ("vanguard" = the in-raid ping marker).

What is on HEAD (v36.26), dark_raiders.html:
- Middle mouse (Mouse1, rebindable; N on the keyboard; the pad equivalent) calls netPingMake (~18458; the net ping family ~63690-63800: netPingPush/Take/Update/Draw, netPingLabel, one readable target ping label since v35.65). It draws in the raid only.
- The map (M) sets a separate G.waypoint on a left click (~18826-18836, "WAYPOINT SET"), right click clears it ("WAYPOINT CLEARED"), the pad places it with the right stick + D-UP (~20173); netWpSend (~63452) shows it to the party. It draws on the map (and minimap?) only.
Build: ONE MARK per player.
1. A middle mouse/N/pad ping on a SPOT sets that player's mark: it shows in the raid as the ping marker (as now) AND on the sector map and the minimap (as the waypoint does now).
2. A click on the map (or the pad's D-UP on the map) sets the SAME mark: it shows on the map as now AND in the raid as the ping marker, with its distance like a ping.
3. One mark at a time per player: a new ping or map click moves it. Right click on the map clears it everywhere; pinging your own mark again clears it too. Decide how long a spot mark lasts (the waypoint lasted until cleared; a ping faded): make the spot mark last until moved or cleared, and keep entity pings (on an enemy, loot, a door) behaving as today (following the target, timing out), shown on the map at the target while they live.
4. Words: one name for it in player text, lower case ("mark set" / "mark cleared", or none if the marker itself says enough: he wants fewer messages). The key list says "mark".
5. Party: the partner sees your mark in the raid and on the map in your colour (P1 amber, P2 cyan), over the existing net messages (merge netWpSend into the ping message or keep both in step); solo works the same.
Check (must FAIL on the current build): middle-click a spot: G.waypoint (or the merged mark) is set and the map draws it; click the map: the raid draws a ping marker at that spot; a second ping moves it; right click on the map clears both.
Rules: seed 4242 fingerprint must hold; both windows; never touch the pickup stack, loot sounds or loot rows. Take pictures (uishots: raid with the mark, map with the mark, partner view). DESIGN.md watch line: "the ping and the map mark are one mark". Model: Opus high (net).
TASK DONE when it shipped and is ON HIS PC.

Lane note 2026-10-29 12:27: shipped cw-cx-onemark cw-cx-markread and parked: only lane-side steps are left. Codex's last words:
Both changes are shipped and ON HIS PC v36.53. Corrected the invalid camera pairing codes and verified them against the game’s parser.

TASK PARTIAL: coordinator must run corrected linked captures beyond the exhausted two-round limit; raid critic score remains 3/4
