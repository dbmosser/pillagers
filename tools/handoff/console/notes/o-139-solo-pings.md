
--- codex run 2026-10-27 22:24 ---
2026-10-27, first run, base v35.38.

Cause: raidKey blocked middle mouse and N unless NET.on; d-up tapped the map in solo; netPingMake also required a shared raid seed and rejected enemies without a network id. World and full-map drawing were party-only. Minimap drawing already read the shared ping list, but target following and expiry happened later in the world drawing pass.

Prepared cw-cx-solopings (18 exact edits). Solo uses the existing ping list, marker, sound and 10 second lifetime. A local target reference follows a solo enemy without assigning network ids or changing generation. Party packets keep their existing fields and never contain that local reference. All three drawing passes refresh target positions and expiry. A new raid clears old marks and double-tap state. The pad tap pings; holding d-up still opens/closes the map. Input is refused on the Undercroft floor, behind panels, while paused or downed. No player wording changed.

The regression check stages an actual seed-4242 solo raid and tests middle mouse, N, repeat suppression, danger double-tap with target retention, physical pad tap and hold through pollPad, the ordinary pick blip, no solo broadcast, world HUD drawing, minimap glyphs and following, full-map glyphs/following/expiry, party host and guest send/receive/following, the share-by-drop routing, and cleanup on a second raid. It fails the old build at the first missing solo middle-mouse ping. The gate must still prove old failure/new pass in Chrome.

Local validation: mk printed written; all 18 anchors matched exactly once and sequential replacements remained unique; the patched inline game script, regression check and five complete camera bodies parse in Node. Handoff files are ASCII. No tracked files or real-repo files edited. No browser, localhost, network, agents or queue started.

The draft why text includes a plain-language playtest watch line and is copied into DESIGN.md by gen-draft.ps1. Generation and random calls are untouched; the lane must confirm the usual fingerprint.

camera-recipes.json requests three solo smooth-look pictures (world, minimap, full map) plus actual linked host and guest pictures. The host picture receives a real guest pad ping; the guest picture receives a real host middle-mouse ping. Pair startup follows the existing o-08-pad-owner recipes. Recipes report SKIP/failure if either window fails to link or receive the ping. The camera sets G.paused after placing the real ping to keep the staged scene steady; it does not extend the ping lifetime. Partner windows close on unload or after 55 seconds.

Remaining lane work: preflight, ship, ON HIS PC confirmation, all five camera pictures and critic review. No fixture retarget is needed: older synthetic glyph-test pings without timestamps remain accepted, and the drop auto-ping implementation is unchanged.

