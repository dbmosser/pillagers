
--- codex run 2026-10-29 11:42 ---
2026-10-29, first run from v36.50.

Prepared cw-cx-onemark. No tracked game or fixture file was edited. The draft uses the ping record as the mark; G.waypoint and remote NET.wps entries refer to that same record for existing callers and late arrival. A manual ping replaces the previous manual mark from its seat. Map mouse clicks and pad map placement call the same setter. Right click and pinging your own spot send png clr and clear every view. A spot lasts until moved or cleared. Entity pings keep their target tracking, ten-second life and double-tap danger. P1 is amber and P2 cyan in all three views.

The existing wp message remains accepted for late-arrival snapshots, carrying target id, spot flag and elapsed age. Live changes and clears use png through the existing host relay. No new network message family. Automatic dropped-item notices remain separate: they keep their timing and sound and are preserved by manual clear; their list cap cannot evict a persistent deliberate mark. No pickup, item row or loot sound code was edited.

Validation here: mk prints written; all 36 anchors apply exactly once to the sandbox HEAD. The complete resulting game script, the draft check, all retargeted check blocks and camera scripts parse in Node. A Node harness using the actual replacement functions passed persistence, same-spot toggle, map projection, replacement, entity following/danger/expiry, authenticated host relay, guest clear, seat colour, late target age/expiry, and isolation from automatic dropped-item notices. This is static/pure-function validation; no Chrome or browser was started. The new browser check fails on the old build at the first middle-mouse action because old netPingPush does not set G.waypoint.

fixture-retarget.json updates five older checks while accepting both old and new behavior: 16.61 explicitly stages an entity for double-tap danger; 23.08 permits the short lower-case mark messages; 31.09 and 22.00 accept mark or waypoint in the map hint; 22.99 accepts either old or new teammate label. The lane must apply these under the lock before shipping.

camera-recipes.json stages solo raid/minimap and sector map plus both real linked windows looking at the partner mark in raid and on map. It reuses the proven o-139 linking recipe. P2 pad input makes the cyan mark; a P1 actual map mouse click makes the amber mark. Each linked recipe proves one mark in each window, moves it through the real transport, clears it by right click and waits for both windows to clear, then restores it for the picture. Six recipes, the allowed standalone-camera maximum. Critic results and ON HIS PC remain pending the lane.

The on-screen rename follows his explicit order to use one name for the merged control. Existing ping/waypoint labels and hints become mark; the how-to sentence now also applies to solo. The draft why contains the exact Watch line: the ping and the map mark are one mark.

LINKED REVIEW NEEDED: synced. Shared fields: png x/y/id/spot/clr and the compatible wp late-arrival snapshot; G.waypoint and NET.wps alias NET.pings records. Please review move/clear and target expiry in both windows after shipping, using the attached recipe pictures.


--- codex run 2026-10-29 11:44 ---
2026-10-29, preflight repair on v36.50.

The failed gen-draft-pf ASCII gate came from the existing Unicode middle dot in the full map-header anchor. Reading that UTF-8 draft with the generator default encoding produced character 194. Replaced that single full-line edit with four unique ASCII text fragments; the existing separator stays untouched in the game. No behavior, wording or camera recipe changed from the first draft.

The mk script prints written. All 39 anchors apply once. The complete generated draft is now ASCII, including anchors, and every field passed the generator character test after Windows PowerShell default Get-Content decoding. The resulting game script, new check and the five already-retargeted check blocks parse. The same pure-function assertions for mark persistence, toggle, map placement, relay, entity timing, colours, late snapshots and loot isolation pass.

Fixture retarget is already committed as 45c0fea50; the lane reported checks 16.61, 22.00, 22.99, 23.08 and 31.09 passed on v36.50. Kept that file unchanged so its applied hashes remain valid. cw-cx-onemark stays in keys.txt for another preflight and ship attempt. Browser check, pictures, critic and ON HIS PC are still the lane work remaining.

LINKED REVIEW NEEDED: synced. The png mark/move/clear and wp late-arrival snapshot carry the shared state; existing recipes cover both real windows.
