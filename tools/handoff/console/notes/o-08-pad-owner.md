
--- codex run 2026-10-19 19:03 ---
2026-10-19 - First J7 handoff, based on v31.90.

Prepared cw-cx-padowner. The existing slot reservations stay unchanged: first pad A belongs to p2; second pad B belongs to p1. Each window tracks its own claim by pair and slot. A new claim or a claim after a gap pulses only that pad for 250 ms at 0.6 strength, adjusted by that pillager's rumble setting. Rumble off stays off. A forwarded claim names the exact slot; the other window rejects it if that is no longer the pad it reads for its partner.

The local pillager gets p1 in amber (#f5b73b) or p2 in cyan (#5fd7e8) beside them for two seconds. The same drawing runs in the raid and Undercroft. The tag is 22 px at 1080p, on a 32 px dark plate, 44 px below the pillager. Its timer uses elapsed time, so pausing cannot keep it up indefinitely.

No swap-pads entry exists in pause. The older PARTY controller-pick row is separate and intentionally excluded from pad navigation because cycling onto an absent slot loses input. J7 does not add or expose another control and does not change the owner's pad order.

The new fixture check fails explicitly on the old build without ownership feedback. It runs three trials with pads present on the first poll and three with A then B arriving later, for each window. It checks A=p2/B=p1, pulse index/type/250 ms/0.6, actual raid text drawing and colour beside the local pillager, two-second expiry, no repeated polling pulse, A reconnect without a B pulse, exact-slot forwarded rumble through the real message handler, wrong-slot rejection, and rumble off. It restores navigator, pad state, network state, rumble state, drawing and settings afterwards.

Sandbox validation passed: all six anchors match once, the mk script prints written, both original and patched inline game scripts parse, the fixture check parses, all four camera scripts and predicates parse, and the mk script is ASCII. No tracked game or fixture files were edited. Browser checks cannot run in this sandbox; lane o must run the preflight, old/new control, ship and camera.

Four camera recipes stage actual linked CAREER windows and synthetic pads: p1 and p2 in the Undercroft, then p1 and p2 in the raid. Each checks three trials with pads present and three with A then B arriving later, then A reconnect and pad-only resume. They leave the two-second claim tag visible for the picture, and close their partner window afterwards. Camera output and critic scores are still pending. No claim of a hardware test or a shipped result yet.

