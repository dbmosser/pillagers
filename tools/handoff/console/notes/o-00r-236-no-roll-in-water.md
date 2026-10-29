
--- codex run 2026-10-29 06:22 ---
2026-10-29 - prepared cw-cx-waterroll against v36.41.
- Water refuses tryRoll before the tired-stamina callout: one existing clank, no new text, no stamina debit.
- Existing wall collision steps are retained. A shared helper samples each step at no more than 1 px intervals and refines the first wet crossing to within 0.001 px. It cancels the remaining roll steps at the bank.
- A wet-entry flag makes the next movement update use existing wading speed immediately, including the shallow shore inset. Ordinary walking retains its existing shore inset. The flag clears on dry ground.
- Pillagers do roll. Both local-shot and partner-shot dodge starts now reject water, and their existing roll movement uses the same shoreline helper. No spawn, loot, or random-generation code changed. The lane must confirm the exact seed 4242 fingerprint; if it changes, remove the three AI-specific edits rather than changing the seed expectation.
- Check stages both host/p2 same-window input roles, both career and arcade, and actual keyboard Space / mapped pad A. It tests shallow/deep water and low stamina refusal, clank/no text, a dry roll from 60 px away, edge distance, the next movement at existing wading speed, and an ordinary dry roll.
- Sandbox validation: mk prints written; all 8 anchors match once; modified inline game JS and the regression check parse; extracted actual tryRoll fails both water cases on control and passes on draft. Actual movement code passes 20 shoreline direction/frame-time cases plus a thin-water-strip case. Dry displacement and the shared pillager stop also pass. This is local code validation, not the Chrome gate.
- Supplied two custom camera recipes for real authored shoreline movement in the host and join roles. They are independent camera pages, not a live linked two-window session. The lane still needs to see the fix in both linked windows if its role checks and pictures do not meet that requirement.
- DESIGN watch line is the draft now text verbatim: no rolling in water.
- Handed to lane: keys.txt, mk script, two-role camera recipes. Await preflight, full gate/fingerprint, critic/pictures, and SHIPPED / ON HIS PC. No claim of shipping yet.


--- codex run 2026-10-29 06:31 ---
2026-10-29 follow-up: cw-cx-waterroll shipped as v36.42. Lane confirms ON HIS PC v36.42: his 8802 serves 36.42, 17 seconds after shipping. He reloads to play it.
- Both round-1 photographs show the title, not the raid. Camera reported U.prep is not a function before the scenario could run. The title critic score 3 and its title-screen findings are unrelated to this gameplay change; those photographs do not establish the water behavior and are not accepted as evidence.
- Corrected camera-recipes.json to reuse the existing catalog prelude including U.prep. Verified that the required function exists and that the camera JavaScript parses.
- Replaced independent role staging with real linked same-machine host/player-2 windows, using the existing project camera linking pattern. Each photograph first exercises both actual local players: dry roll from 60 px away, stop inside 0.01 px of an authored bank, next movement at wading speed, and a fresh wet refusal with unchanged stamina. It requires a live two-window link before exposure and records both outcomes.
- Popup cleanup only concerns the disposable camera peers. The recipes do not touch his play port.
- No new game key, game change, or fixture retarget is needed. Awaiting the second and final camera round and its critic. keys.txt retains the already-shipped key for the lane to skip.

--- codex run 2026-10-29 06:35 ---
2026-10-29 complete - no rolling in water, v36.42.
- Shipped cw-cx-waterroll; ON HIS PC v36.42 was confirmed 17 seconds after the ship. The owner reloads to play it.
- AUDIT.md records check 36.42 passing on v36.42 and failing on v36.41. DESIGN.md has the v36.42 NO ROLLING IN WATER entry explaining the refusal, no stamina cost/callout, and shoreline stop. Watch: no rolling in water.
- Camera round 2 successfully staged real linked host and player-2 windows at both 1080p and 4k. In every exposure both reports have started=true, stopped=true, wet=true, wading=true, refused=true. Recorded shoreline error for both players: 5.684341886080802e-14 px.
- Opened and inspected both 1080p photographs. Both show the real pillagers together at the water bank. These supersede the failed round-1 title photographs.
- Final evidence: tools/handoff/console/notes/shots/o-00r-236-no-roll-in-water-recipes-2/report.json; water-roll-p1-1080.jpg; water-roll-p2-1080.jpg. The same directory also holds the successful 4k images.
- The shipped regression covers keyboard Space and actual mapped pad A in both seats, career and arcade; the real linked camera run additionally verifies both local movement/input paths together.
- Critic scored the whole existing raid HUD 3 for p1 and 2 for p2. It flagged timer/banner overlap, left-panel styling, feed placement, a suspected run-info capital, vitals, and ammo styling. These are HUD findings; no HUD layout or text was changed by this task. No claim that the raid HUD meets its design score. The findings and images are handed to the coordinator rather than folding a HUD redesign into the water movement fix.
- Camera round limit reached (2 of 2). No further camera run or game ship is requested. Gameplay request is complete, with linked-window evidence and ON HIS PC confirmation.
