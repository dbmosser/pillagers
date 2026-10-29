
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

--- codex run 2026-10-29 12:08 ---
2026-10-29, after v36.52 shipped.

cw-cx-onemark SHIPPED. ON HIS PC v36.52: his 8802 serves 36.52, 65 seconds after the ship; he reloads to play it. Both real linked raid recipes staged, each with one mark in each window, after their move and right-click clear assertions succeeded. P1 sees the P2 cyan mark, and P2 sees the P1 amber map-click mark. The solo map and raid also staged. I inspected all six attached images. The two partner-map images are welcome-pack screens from failed setup, not map evidence.

Critic round 1: solo raid 3, solo map 3, P1/P2 partner raids 2 each. Partner-map scores 2 and 3 are invalid for this task because neither map staged. The specific mark findings are correct: world hollow diamond, minimap filled diamond, own map crosshair, and a label too far above the mark.

Prepared cw-cx-markread, a rendering-only follow-up. Actual spot marks use the same filled 24px diamond with dark backing and the same seat colour in raid, minimap and sector map. Spot plates have a 4px gap above the diamond plus a leader; the owner label says mark rather than you. Legacy ring callers remain compatible. Entity labels and markers keep their current body clearance. No timings, movement, shake, bounce, pickup, loot row or loot sound changes.

All eight anchors apply exactly once and the generated draft is ASCII, including every anchor and replacement. The complete resulting game script, new fixture check and 36.52 retarget parse. Node drawing checks using the actual functions pass shared filled glyph, both seat colours, 1080p/4K sizes and label gaps, with entity label spacing unchanged. The current v36.52 drawing fails the new filled-glyph assertion, as required.

New fixture-retarget.json contains only the new edit: check 36.52 now accepts an actual glyph draw at the mark location as well as its original arc draw. Its old ring-only map spy would reject the deliberately shared filled glyph. The spy still checks drawing at the same actual map location, and passes on the current old-ring build. Earlier retargets are already committed and are not repeated.

Updated camera-recipes.json for round 2. The project camera suppresses beforeunload registrations, so the old beforeunload cleanup never ran; changed recipe cleanup to pagehide. Every linked invocation now has a unique pair code, preventing old teardown messages from crossing into the next scene. The fixture-only setup removes a stale p2-raid heartbeat and clears the in-memory copy before it opens test P2. The spot is staged 280-400 world units away for separation from the player icon on the sector map. Six scenes remain, covering solo and both real roles on map and raid.

The critic capital-I finding is a font reading error: the actual title source at dark_raiders.html:45634 is already lower-case run info. The general corner/HUD, hp bar, hotbar, contract-panel and cache-label recommendations concern unchanged presentation and exceed this one-control job; recorded for the coordinator, without changing unrelated screens or the pickup rows. Welcome-pack findings came from the wrong stage and do not justify editing the welcome pack here.

LOCAL: no linked review for cw-cx-markread, which changes drawing only. The original cw-cx-onemark sync is already shipped; both actual linked raid recipes proved its move and clear behavior. The final linked map pictures and critic results remain lane work after the follow-up ships.

--- codex run 2026-10-29 12:27 ---
2026-10-29, after v36.53 shipped and the second camera round.

cw-cx-markread SHIPPED as v36.53 (76b7f3e83). ON HIS PC v36.53: his 8802 serves 36.53, 49 seconds after shipping; he reloads to play it. Retarget b13afe8c8 passed check 36.52 on the prior build before the ship. Both requested game keys are shipped and remain listed in keys.txt. No further game change is prepared in this run.

I inspected all six attached round-2 images. Solo raid and map show the shared filled amber diamond and nearby mark plate. Their critic scores stayed at 3. All four linked screenshots are welcome-pack images from failed handshakes, so none counts as mark evidence or a valid review of the mark. Round-1 real P1/P2 raid shots remain valid evidence of the original synchronized mark, including move and right-click clear in both windows before capture.

I caused the round-2 setup failure by changing pair codes to include underscores and a long decimal time. The actual netPairOf parser (dark_raiders.html:60610) accepts only 4-16 lowercase letters/digits. The report explicitly says player 2 is missing its pair code. Corrected camera-recipes.json to use cx239 + seat + a base36 timestamp (14 characters today). Verified the actual game parser accepts generated codes for both roles and both query shapes, rejects the old broken code, and all recipe scripts parse. Pagehide cleanup and stale fixture-heartbeat cleanup remain. This is a camera-only repair, with no game change or new ship key.

Both permitted automatic camera rounds have been consumed. I have not raised the cap, started a browser, or bypassed the camera limit. The coordinator must run the corrected four linked scenes, or raise this task camera allowance, to finish the missing current-version P1/P2 map and raid pictures. Mark-specific rendering is also covered by the shipped 36.53 check in both seat colours and three views; that does not replace the missing pictures.

Best current images: tools/handoff/console/notes/shots/o-00v-239-ping-and-map-mark-are-one-recipes-2/mark-solo-raid-1080.jpg (v36.53, critic 3), and mark-solo-map-1080.jpg in the same directory (v36.53, critic 3). Best valid linked images: recipes-1/mark-p1-partner-raid-1080.jpg and recipes-1/mark-p2-partner-raid-1080.jpg (v36.52, critic 2 each). Round-2 linked images are invalid and must not replace them as evidence.

The raid score of 3 is below its 4 finish line. Remaining round-2 raid findings concern unchanged hp, hotbar, corner headers and other world tags. Remaining map findings concern unchanged room/cache labels and contracts; its mark-label finding asks for 16px text and at least 8px from extract c, while the code already uses 16px and the image shows about 16px horizontally between the mark plate and extract label. I have not changed unrelated controls, pickup rows or loot sounds in pursuit of a screen-wide score. The coordinator has the full broader HUD findings from the prior alarm.

LOCAL: no linked review for the v36.53 rendering follow-up. Original synchronized png/wp behavior is shipped; the missing current-version linked-camera evidence and raid critic finish line remain coordinator work. Task is not reported complete.
