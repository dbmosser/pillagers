
--- codex run 2026-10-27 22:24 ---
2026-10-27, first run, base v35.38.

Cause: raidKey blocked middle mouse and N unless NET.on; d-up tapped the map in solo; netPingMake also required a shared raid seed and rejected enemies without a network id. World and full-map drawing were party-only. Minimap drawing already read the shared ping list, but target following and expiry happened later in the world drawing pass.

Prepared cw-cx-solopings (18 exact edits). Solo uses the existing ping list, marker, sound and 10 second lifetime. A local target reference follows a solo enemy without assigning network ids or changing generation. Party packets keep their existing fields and never contain that local reference. All three drawing passes refresh target positions and expiry. A new raid clears old marks and double-tap state. The pad tap pings; holding d-up still opens/closes the map. Input is refused on the Undercroft floor, behind panels, while paused or downed. No player wording changed.

The regression check stages an actual seed-4242 solo raid and tests middle mouse, N, repeat suppression, danger double-tap with target retention, physical pad tap and hold through pollPad, the ordinary pick blip, no solo broadcast, world HUD drawing, minimap glyphs and following, full-map glyphs/following/expiry, party host and guest send/receive/following, the share-by-drop routing, and cleanup on a second raid. It fails the old build at the first missing solo middle-mouse ping. The gate must still prove old failure/new pass in Chrome.

Local validation: mk printed written; all 18 anchors matched exactly once and sequential replacements remained unique; the patched inline game script, regression check and five complete camera bodies parse in Node. Handoff files are ASCII. No tracked files or real-repo files edited. No browser, localhost, network, agents or queue started.

The draft why text includes a plain-language playtest watch line and is copied into DESIGN.md by gen-draft.ps1. Generation and random calls are untouched; the lane must confirm the usual fingerprint.

camera-recipes.json requests three solo smooth-look pictures (world, minimap, full map) plus actual linked host and guest pictures. The host picture receives a real guest pad ping; the guest picture receives a real host middle-mouse ping. Pair startup follows the existing o-08-pad-owner recipes. Recipes report SKIP/failure if either window fails to link or receive the ping. The camera sets G.paused after placing the real ping to keep the staged scene steady; it does not extend the ping lifetime. Partner windows close on unload or after 55 seconds.

Remaining lane work: preflight, ship, ON HIS PC confirmation, all five camera pictures and critic review. No fixture retarget is needed: older synthetic glyph-test pings without timestamps remain accepted, and the drop auto-ping implementation is unchanged.


--- codex run 2026-10-27 22:47 ---
2026-10-27, run 2, refreshed base v35.42.

cw-cx-solopings shipped as v35.41. Confirmed the required main-PC record by reading console/onhispc.txt: "10-27 22:38 v35.41 cw-cx-solopings on his pc after 34s (8802 serves 35.41) week 68%". No play-port connection was made by this worker.

Round 1 pictures were inspected. Solo world, minimap and full map staged with a real target reference and smooth=true; host staged with a real guest pad ping and counts [1,1]. The guest recipe failed before the raid because it accepted only netSamePick result opened; an already linked pair returns linked and is also valid. Its title-screen critic result is not a ping review. Updated that guard to accept both, retaining the actual roster and both-raids/receipt checks. Camera scenes now explicitly enable the minimap size setting, fold the existing scoreboard, clear transient feed lines, and move an edge spawn inland to photograph the pings away from a clipped map edge. These are staging preferences only, not game changes.

Scores: world 2, minimap 3, map 3, host 3; guest NOT STAGED (title score 2 invalid for this task). Map meets the non-core-screen score-3 line; raid shots need ping readability work. No self-grade given.

Prepared follow-up cw-cx-pingread (4 exact edits). Existing ping words are unchanged. All seats get the same 16px-scaled bone text on an 85-percent shared HUD plate, lifted 88px from the marker with a below-marker fallback at the top edge; the 32px plate has 8px padding and stays on-screen. Minimap and full-map glyphs use scale 1.5 instead of .85/1, making the target shape 18px with its existing 21px dark backing at 1080p. Sound, life, target tracking and input are unchanged. The regression check draws the actual labels at 1080p and 4k in solo and party states, checks plate/text bounds and target clearance at screen edges, and checks the actual map glyph draws. The old build fails for its missing readable label.

Local validation: mk printed written; all four anchors unique; patched game, regression check and all five regenerated camera bodies parse; ASCII verified. Broad critic findings about the existing HUD and map labels are handed to the coordinator rather than expanding this ping fix into a HUD redesign. The DESIGN entry includes edge/4k playtest watch guidance.

Remaining lane work: preflight and ship cw-cx-pingread, main-PC confirmation, and camera/critic round 2, especially a valid player 2 picture. The already shipped key stays in keys.txt for the lane to skip.


--- codex run 2026-10-27 22:56 ---
2026-10-27, run 3, base still v35.42. cw-cx-pingread remains unshipped and in keys.txt under the same key.

The live-ship failure is a shared-file write failure, not a failed ping assertion. The reported WriteAllText($Game,...) line is tools/handoff/stamp-verat.ps1:20, which stamps the game date during ship.sh start. The live fixture then answered NO CHECK 35.43. The saved unshipped-3543-cw-cx-pingread-1027-2253.patch contains the intended four game changes but no mkfixture.ps1/check change. The queue restored HEAD as reported. verifySafe still reported the required 85/374 entities and 165/593 containers.

Regenerated the same draft against refreshed v35.42: written; four exact unique anchors; patched game/check and five camera bodies parse; ASCII passes. The code, regression assertions and camera recipes are unchanged. Added only an explanatory retry comment to the mk script. No tracked/shared files edited or shipping tools run here. The lane should retry the same pending key normally. If the same shared-file IOException repeats, the coordinator needs to investigate the shared writer/lock; changing the ping check cannot repair a missing check caused by the write failure.

Still outstanding: successful live ship and ON HIS PC for cw-cx-pingread, then camera/critic round 2 with a valid guest raid picture. Original solo behavior is already shipped and confirmed on his PC as v35.41.


--- codex run 2026-10-28 04:00 ---
2026-10-28, continuation on refreshed v35.64.

Both keys are already shipped. Read the saved ship reports: cw-cx-solopings is v35.41 (cd809033b), fixture PASS / PASS, ON HIS PC after 34s; cw-cx-pingread is v35.43 (34e36f915), fixture PASS / PASS, ON HIS PC after 17s. Both reports preserve the seed fingerprint: entities 85/374, containers 165/593. The earlier shared-file IOException is resolved. DESIGN.md at v35.43 includes the edge/4k playtest watch line. No new game change or fixture retarget is needed this run.

Inspected the four valid round-2 pictures. World ping uses the new padded plate above the sentry; minimap and full map have the larger target glyph. All three solo stages report smooth=true and followed=true. The host picture reports linked=true, counts [1,1], smooth=true, sender p2 pad. The guest picture is invalid: report.json says NOT STAGED, host did not link p2: p2raid. Saved accept.json still points to round-1 pictures for the three solo views; do not claim round-2 critic approval from those entries.

Updated camera-stage.js and regenerated camera-recipes.json for round 3. Before pairing, the camera now finishes any active staged/restored raid, clears the fixture G, enters the Undercroft and calls the real p2LiveBeat when in player 2. This clears the active-raid heartbeat through the normal game function rather than bypassing netSamePick or changing its guard. The newly opened host is also put on the floor before its real invite. Unload and timeout cleanup finish both staged raids before closing the partner, avoiding a lingering p2 raid mark between scenes. Both real roster and raid checks, actual mouse/pad input, receipt in both windows, and smooth-look assertions are retained. No synthetic network receipt or fake success was added.

Validation: camera-stage.js passes node --check; all five complete recipe bodies and their expect expressions parse; camera/key handoffs are plain ASCII. Only the private output folder changed. keys.txt still lists the two shipped keys for the lane to skip. No browser, localhost, shared writer, queue or agents used.

Remaining lane work: capture/critic round 3 on the current build, especially a valid player 2 raid picture receiving the host middle-mouse ping, then return those pictures and reviews. The requested three solo pictures and valid host picture already exist under tools/handoff/console/notes/shots/o-139-solo-pings-recipes-2/. The latest camera revision supplies new work to the lane; this is not a request to repeat an unchanged recipe.

--- codex run 2026-10-28 04:12 ---
2026-10-28, round-3 feedback on v35.64.

Inspected all five attached pictures. Solo world/minimap/map and the real host receipt are staged, smooth=true; solo target references follow. Critic scores: world 2, minimap 3, map 3, host 3. Guest is NOT STAGED (both real windows did not link); its welcome-pack score 3 is not a ping review. World P1 is the still-duplicated enemy name below the new ping plate. Map/minimap P1 includes a small crosshair, which is the target ping. Other P1 items describe the existing scoreboard, health/hotbar/ammo layout and map label/contracts presentation; the earlier coordinator handoff covers those outside this task. No HUD redesign or game-feel changes added.

Prepared cw-cx-pingmerge, seven unique edits. The live target ping plate now includes the specific enemy name plus distance and existing friendly/running detail. Its normal name text and backplate wait until expiry; crew and wounded-health marks remain. The peddler retains its existing deal prompt. Both map target glyphs grow from 18px to 24px, with 28px dark backing at 1080p. Existing sound, packets, share-by-drop, controls, lifetime and generation stay intact. This is follow-up 2 after the initial solo fix. The draft why gives the DESIGN.md playtest watch line.

The new regression check stages a real seeded sentry and first proves its normal name and wounded pip draw. It then measures the actual complete frame in solo and guest states: exactly one specific name with sender and distance; no old duplicate; health pip retained. Expiring the ping must restore the old name and pip. Both map drawing functions must draw the larger target glyph. The old build should fail at the generic ping plus old name; the lane must prove the Chrome old-fail/new-pass. No old fixture retarget is needed: check 35.43 accepts glyph sizes at least 1.5 and its synthetic target without an entity still exercises the same 16px label.

Camera repair: the earlier fold assignment changed hudOff(), which returns a copy; it now sets P.hud.raiders.c on the disposable camera profile. Both scenes use distinct valid pair codes. The guest scene waits for loaded profiles, resets both real connections, stops its old broadcast channel, and boots its real p2 channel with the scene pair before the host invite. This addresses a guest already auto-linked to the previous camera host, whose join role ignores a new offer. The host popup has a fresh unique name to avoid reading an old page while it navigates. Actual roster, both-live-raids, pad/mouse input and packet-receipt assertions remain. A failed final handshake now closes the partner and reports both real states/modes for the coordinator.

Validation: mk printed written on v35.64; seven exact anchors unique under sequential replacement; patched inline game, new regression and all five complete regenerated recipes parse in Node; handoffs ASCII. No shared/tracked file edits, browser, network, queue or agents. keys.txt includes cw-cx-pingmerge after the two shipped keys.

Remaining lane work: preflight/ship/ON HIS PC for cw-cx-pingmerge and camera/critic round 4 of 4. Need a valid player 2 picture receiving the real host middle mouse ping. If a broader HUD critique remains after this second follow-up without a score increase, retain round 3 and round 4 as the best-version evidence under the stopping rule; do not turn solo pings into an unrelated HUD redesign.
