
--- codex run 2026-11-07 14:38 ---
2026-11-07: Prepared cw-cx-overseertarget against v37.51. Five edits; no game or fixture files edited.
The host records positive Overseer health losses against the current player-hit seat before the hit timer decays. The highest-damage shown, standing player gets the boss; ties and no eligible damage use the existing nearest rule. Downed, spectating, extracted and stale damage leaders are excluded. Solo and ordinary enemies keep their current rules.
The existing ninth snapshot field keeps bits 1/2/4/8/16. Bits 5-7 now carry (target seat + 1). Joining windows resolve that seat to the local player or the shown party body; a cleared field removes the cached seat.
Regression check stages a real host tick for both damage seats, repeated ticks, healing and expired hit tags; tests the required 300 versus 900 distance case, downed/stale/extracted/spectating leaders, ties, solo and ordinary enemies; then checks snapshot round trips and local/remote seat resolution on a joining role. Read the existing machine-opening and longshot snapshot checks for staging. No old checks appear to need retargeting.
Sandbox validation: mk printed written; all five anchors matched exactly once. Applied edits in memory and parsed the inline game script plus the regression check with Node. All files for the lane are ASCII. Browser regression, seed fingerprint and ship are for the lane; none have run here.
LINKED REVIEW NEEDED: synced. The shared field is the Overseer entity snapshot row r[8], bits 5-7. After shipping, verify the same chosen target in both real windows in the smooth look and retain one picture from each. This is a gameplay targeting change, with no UI/art/text change to critic-score.
Watch is in draft why for DESIGN.md: the higher-damage partner holds the Overseer all fight; watch that the other player does not feel left out and that the target does not flip back and forth.

--- codex run 2026-11-07 14:53 ---
2026-11-07 completion: The lane reports cw-cx-overseertarget SHIPPED as v37.52 and ON HIS PC v37.52 (67 seconds after ship). Verified the refreshed master contains the ledger, damage-based target selection, snapshot seat encoding and joining-window decoding. All task code is shipped; no further patch is needed.
LINKED REVIEW NEEDED: synced remains a coordinator handoff already recorded in alarms. The snapshot field is r[8], bits 5-7. Actual linked play and pictures were not performed in this sandbox; do not treat the role regression as a live two-window observation. Review in smooth look, keeping one picture from each window.
