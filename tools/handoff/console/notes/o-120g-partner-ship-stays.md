
--- codex run 2026-10-28 01:40 ---
2026-10-28 - o-120g-partner-ship-stays - first Codex handoff, starting v35.57

Read gameplay-next-1025.md idea 8. No existing task notes were present in the real repo. Current cause confirmed at dark_raiders.html:65260: arcadeExtractEnd clears beaconT and hold for the ring the host stands in, even while the partner is still playing. netWorldSend/netWorldTake then send and accept that cleared ring. No new feature or player text is added.

Prepared cw-cx-partnership. The host-first both-out branch keeps the shared ship and its remaining time and clears pullT, boardT and pullFloor on all of the host window rings. Other extraction paths stay as they are. The draft why field includes the requested playtest watch line; gen-draft.ps1 writes this field into DESIGN.md automatically.

The new fixture check stages an actual partner beacon request on the host, lands it, boards the host via tryExtractTick, and checks host pull cleanup and unchanged remaining time. It sends the actual world packet to a fresh receiver in player 2 role with no pull or recent-call grace period, boards player 2, delivers arcx back to the extracted host and checks both-out score x2. A solo boarding control still ends at once with score x2. Both roles explicitly use smooth look. Existing Q65 check 30.33 needs no retarget.

Local validation: mk prints written and its single anchor matches once. Both old and patched full inline game scripts parse. The new fixture check and two camera recipes parse. An isolated VM run of the actual arcadeExtractEnd function reproduces old ship removal, then proves the patch retains the exact hold/beacon/HUD mirror values, clears the host pull, benches the host and preserves solo extraction x2. This isolated check is not a replacement for lane preflight. All handoff files are ASCII. No tracked game, fixture or DESIGN files were edited.

camera-recipes.json opens real linked demo windows using the same startup pattern as the existing 86c two-window camera. Player 2 calls, player 1 boards first, then the recipe waits two seconds beyond the recent-call grace period before checking both windows retain the ship. The player 1 picture shows the extracted host. The player 2 picture preserves the actual canvas frame during boarding, then the recipe completes that same boarding action and verifies both real windows receive run over; the result is in report.json. Only the camera inbound wait is advanced; the remaining boarding clock is not reset. Each scene closes its companion popup. Smooth look is explicit.

Remaining lane work: preflight, ship, ON HIS PC confirmation, both custom camera scenes and critic results. No live browser, gate, network or shipping was run in the sandbox. The seed 4242 fingerprint must still pass in the lane gate.


--- codex run 2026-10-28 01:41 ---
2026-10-28 - o-120g-partner-ship-stays - preflight check repair

The lane rejected the first new check twice with host did not transmit the live ship. The test incorrectly compared the unrounded live floating-point timer to the wire value. netWorldSend uses netNum, which rounds each ring clock to two decimal places. Repeated 0.1-second boarding steps leave a timer such as 28.449999999999978; its valid network value is 28.45.

Changed only the check in mk-cw-cx-partnership.ps1: the sent packet must contain netNum(remaining hold), exactly one peer must receive it, and the player 2 receiver must retain that same serialized clock. Added values to the failure message for any future staging problem. The product edit and keys.txt are unchanged. The original build still fails earlier because it clears the ship when the host extracts.

Local checks rerun: mk writes the draft with one matching anchor; old and patched inline scripts parse; fixture check and both camera recipes parse; isolated actual extraction behavior passes. Extended the local verifier to run actual netWorldSend, netNum and netEntsHost against the floating-point boarding timer: the old strict comparison fails and the corrected serialized comparison passes. This is local source execution, not a browser preflight result.

Remaining: lane preflight retry, ship, ON HIS PC, two-window camera scenes and critic results. No tracked game files edited.


--- codex run 2026-10-28 01:50 ---
2026-10-28 - o-120g-partner-ship-stays - shipped mechanics and two-window evidence

cw-cx-partnership shipped as v35.58, commit d6eaf0cbc. Read the lane logs: PREFLIGHT PASS; fixture check 35.58 PASS / PASS; verifySafe pass with entities 85/374 and containers 165/593; ON HIS PC v35.58, confirmed 64 seconds after shipping. DESIGN.md:40027 includes the requested playtest watch line.

Opened and inspected both supplied 1080p pictures with the image viewer. Camera report confirms two real linked windows in smooth look and seed 4242. After host extraction, host and partner both retain about 26 seconds of boarding time; host is out, partner is not out, and neither has a pull in progress. Partner then starts a 0.5-second boarding pull. The second recipe completes that same pull and records both real windows with run-over reason extract. The shipped regression also covers the unchanged solo extraction and score doubling.

Evidence: tools/handoff/console/notes/shots/o-120g-partner-ship-stays-recipes-1/120g-host-extracted-1080.jpg and 120g-partner-boarding-1080.jpg; report.json in that folder records the two-window states and bothOut results. Both scenes staged and DOM lint returned zero issues. These are evidence pictures of existing screens, not new screen designs.

Visual review remains below the full raid target: critic 3 for host how-to-play attract, 2 for partner raid. Do not record these as visual passes. The mechanics patch changes no drawing, label, menu, type or panel code. Existing HUD work 186f already owns timer/panel hierarchy, player tags, vitals and control-chip alignment, including prior findings from o-120d and o-120f; 186d owns the danger slot. Logged this round as a coordinator handoff in alarms-new.md rather than adding a HUD redesign to the shipped small extraction fix. Additional items are label collisions and attract-card opacity. No features disabled and no critique hidden through camera staging changes.

Two critic recommendations cannot be applied literally: the a in the extraction line is extraction ring A, not an accidental token; name the ring clearly in the HUD work rather than deleting its identity. The how-to-play corner x is required by his Q43; keep it. The extract in progress wording is identified as his phrase in tickExtractPoints; any rewording needs the Q8 reason in the UI change log. Preserve these when addressing the presentation issues.

The requested extraction fix is shipped and verified in both windows, with the solo control and fingerprint intact. No additional game key is needed for this task. Existing visual issues are handed to the coordinator and existing HUD jobs; no visual acceptance is claimed.

