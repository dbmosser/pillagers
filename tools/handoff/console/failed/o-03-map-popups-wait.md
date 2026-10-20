# 45-map-popups-wait : nothing draws over the sector map (left open by cw-mapstyle, v31.55)

The sector map was restyled into a card (v31.41, v31.48 and v31.55; the critic gave it 4/5). The helper left two defects open:
1. Game popups draw over the open map: the "codex entry" card, the weather turn and the corner toasts. While the sector map is open, hold them, then show them in order once it closes. Do not drop any. The raid clock already waits at raid start until the map is dismissed (MAPFIRST), so a held popup must not eat time either.
2. In the locked-room corner, the labels of the two caches and the strongbox stack on top of each other above the room. Lay them out so they do not overlap: offset or stack them neatly, with each label next to its own icon.

3. His 3.13 a: player 1 is amber and player 2 is cyan everywhere, and lime only means "selected" and the main button. The map marker shipped in v31.55 is lime for player 1 and blue for player 2: make it amber and cyan, using the same colours as the seat ring (SEATCOL).

Pictures: the before shots are in tools/handoff/console/notes/shots/cw-mapstyle-after3/. Take before and after shots at 1080p and 4K, then run the critic once on the map. One ship, with a check that fails on v31.55 (stage a codex popup while the map is open). The fingerprint must not change.

## RE-QUEUED 10-19 22:55 (coordinator, in the VM)
- Done for you: your fixture-retarget.json is applied and committed (863ad9c8, under the ship lock, fixture rebuilt). On the current build 31.41 and 22.87 both PASS.
- Your run count was reset. What is left is lane work: preflight and ship cw-cx-mapwait. If the gate fails, read the gate log and fix that key only. shots.txt (screen 22) is photographed by the lane after the ship.
- Two-window map evidence and the 4K before picture: the coordinator takes them after the ship. Put any alarm for the coordinator in alarms-new.md (new file, see RULES-codex.md), not in questions-new.md.
