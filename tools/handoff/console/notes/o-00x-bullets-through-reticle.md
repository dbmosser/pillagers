
--- codex run 2026-10-30 10:43 ---
2026-10-30, o-00x-bullets-through-reticle, first preparation on v36.57.

LOCAL: no linked review. This changes only how each window draws its rounds. The existing shot word carries all needed values; no packet format, shared authority or damage state changes.

Prepared cw-cx-reticleflight in keys.txt. The whole streak used to stay 12-20 world pixels above its simulated flight. Its head, tail, rocket head and night core now independently ease from gun height to zero lift over 220 world pixels after the existing muzzle start. That puts the whole normal streak on the sim line by a target 300 world pixels away. The muzzle flash stays at its existing gun position. Received rounds reconstruct a cosmetic origin from the existing spawn position and velocity, including machines and legacy words. Received ricochets retain the existing bounce bit and stay at ground height rather than restarting a muzzle lift. No pickup, loot sound or loot row changes.

The sender function and fireWeapon body remain byte-for-byte identical after normalizing line endings. The helper is pure arithmetic and consumes no random values. No tracked game or fixture files were edited. The old freeze sentence in the task is superseded by his explicit 10-28 order and the rules about stale task holds.

Local validation: mk printed written; all three anchors occur exactly once; patched inline scripts and the new gate check parse. A Node recorder executed the actual old and new tracer loops for 120 combinations of angle, lift, local/received list, day/night and rocket/ordinary round. All old heads miss the cursor by more than 3 pixels; all new heads meet it. Receiver origin and ricochet probes pass. Draft artifacts are ASCII. This is local validation, not the Chrome gate.

The new gate check fires zero-spread rounds in both host and join roles, records actual Canvas line endpoints, checks their screen distance from the cursor at 300 world pixels, checks full muzzle height and the grounded tail, and exercises sent/received player, pillager and machine words. It restores its intercepted painters and NET state.

fixture-retarget.json adjusts only check 35.14: identify the fog-test tracer within its old-to-new vertical band at its unique x coordinate. It still requires the tracer to be absent with fog on and present with fog off. It accepts both builds so the lane can run it before shipping.

camera-recipes.json requests four actual raid frames at 1080 and 4k: P1 still, P1 moving, P2 still and P2 moving. Each includes local rounds, a partner body and rounds decoded through netFxShot/netFxTake, plus hostile rounds. Three frozen burst positions show the muzzle, middle and cursor portions. Moving uses the real bloom cone. These are independent role-staged fixture windows, not a live linked connection. The lane must return pictures for inspection and the critic result; none were available in this sandbox.

Watch: bullets now run through the middle of your reticle

Still required from the lane: retarget check 35.14, preflight and full gate including seed 4242 fingerprint, shipping, ON HIS PC, four role/movement picture sets and critic review. Do not report this shipped from the preparation alone.

