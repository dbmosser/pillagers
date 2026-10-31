# 241-redraw-not-steady : find why two identical redraws of a frozen frame differ in the full test run
model: opus
Queue (CEO 10-29 04:00). Polish of the test bed, HIGH: it blocks stable and each new case is waved off as a flake.
Five checks now fail in full corpus runs with the same family of message and pass alone: v8.85, v8.89 ("the renderer is not deterministic at dt 0"), v9.07 ("two identical redraws differ"), v34.90 ("1 unsteady / 2 unsteady"), v33.51 ("the frozen raid frame is not steady"). See tools/handoff/stable-known-red.txt lines for each. They pass alone and after their own slice, so something earlier in a long run leaves state that makes a dt-0 redraw change between two calls.
Suspects to rule in or out: anything drawn from performance.now / Date.now / Math.random at draw time rather than sim time (the v36.26 raid heartbeat, the v36.12-36.14 world tag stacking and its per-frame cap, damage number growth v36.07, status pulses v36.17-36.27, weather and fog shimmer); a cache that warms on the first draw; a canvas state (globalAlpha, filter, transform) left set.
Do: reproduce with a long run in corpus order (tools/handoff and the corpus runner), bisect which earlier check leaves the state, find the time source or leak, fix it in the game so a dt-0 redraw is identical, then take the five lines out of stable-known-red.txt.
Check (must FAIL on the current build): run the leaking earlier check, then draw the frozen raid frame twice at dt 0: the two pictures are identical.
Rules: no player-visible change; seed 4242 fingerprint must hold. Say plainly in DESIGN.md what was leaking.
TASK DONE when it shipped and is ON HIS PC and the five checks pass in the next full run.
