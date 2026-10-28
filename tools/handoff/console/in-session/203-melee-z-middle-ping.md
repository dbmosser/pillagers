# 203-melee-z-middle-ping : melee on Z by default, middle mouse pings
His order 10-28 (verbatim, forwarded by the old intake chat): "can we move melee to z as default? and middle mouse should ping?"
Model: claude-opus-5-5, effort high (rung 3: key defaults, saved-profile migration, party controls).
Facts found by the old intake chat (check on HEAD): key list near dark_raiders.html:20392 has KeyV = melee (crowbar) and KeyZ = drop an item for a teammate. Middle mouse = ping is said to be the default already (~3791).
Do:
1. Melee default becomes Z. Drop-for-teammate moves to V (a swap, nothing lost). Profiles that never changed these keys get the new defaults; a profile where he rebound them keeps his choice. Do not change the storage key `salvagerun:profile`; if a migration is needed it follows CLAUDE.md rule 5. Update every help / controls / F1 list / Settings binding text that names V for melee or Z for drop.
2. Verify middle mouse really pings in a raid (solo and P2 window), also with a saved profile holding old bindings; fix it if it does not. His wording is a question, so if it already works, say so and leave it.
3. One control per job: no duplicate rows. Both windows (2 player); the pad is unaffected.
Rules: seed 4242 fingerprint unchanged; new checks FAIL on the build before; player text lower case; looting untouched; take pictures of the controls screen at 1080.
Done when ON HIS PC vNN.NN; move this file to done/, SHIPPED line in open-orders.md.
Watch for: melee on Z, drop on V; middle click pings.
