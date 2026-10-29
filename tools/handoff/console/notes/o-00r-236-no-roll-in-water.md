
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

