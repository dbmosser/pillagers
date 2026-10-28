
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

