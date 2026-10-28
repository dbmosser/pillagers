
--- codex run 2026-10-28 02:21 ---
2026-10-28, o-137-os-reduce-motion, preparation against v35.60.

Prepared cw-cx-osmotion. The existing Screen Shake row has light (0.5); Effect Intensity has half (0.5). gameOptIx now supplies those indices for an unset row when prefers-reduced-motion: reduce matches. Saved selections win independently for each row, including off and full. applyGameOpts still preserves tuning-console claims. No preference is saved as a manual choice. Missing or throwing matchMedia falls back to existing defaults. Other defaults, including itch difficulty and smooth look, are untouched.

Found that the existing effect-intensity hint promised to control hit pause, but hitStopOn always used 60 ms. Connected that existing setting to the duration: full 60 ms, half 30 ms, off zero. The damage threshold, boss exclusion and 300 ms immunity stay unchanged. Co-op still uses the host for enemy hit pause. Watch for this shorter enemy hold on heavy hits when playing with half intensity. This watch line is in the draft why text, which gen-draft.ps1 puts into DESIGN.md on shipping.

The regression check stages a live seed-4242 raid and tests host/player-2 roles, unchanged ordinary defaults, reduced defaults without saving them, all saved shake and intensity choices, console tuning, missing/throwing media APIs, itch defaults, actual gfxTrauma amplitude (one quarter with both lighter controls), and hitStopOn duration/immunity. No seeded draws or generation code changed; the lane must verify the standard fingerprint.

Sandbox verification: mk printed written; both anchors matched exactly once; both draft edits were inspected. All drafted inline JavaScript and the new check parse with node vm.Script. The mk is ASCII. No browser or game behavior test was run here, as required by the sandbox addendum.

Handed over keys.txt plus camera-recipes.json with four smooth-look views: display settings and raid for player 1, then the actual ?p2=1 profile route for player 2. Recipes emulate only the reduced-motion media query and assert the live values and player identity. Still pictures do not establish motion timing; the regression check does. Await lane preflight, ship, ON HIS PC confirmation, pictures and critic. No fixture retarget expected.


--- codex run 2026-10-28 02:24 ---
2026-10-28, o-137-os-reduce-motion, follow-up to failed preflight on v35.60.

The new motion check passed far enough for preflight to reach recent checks, which reported 34.93 and 34.92. Both older checks assumed that an unset non-itch profile always had standard shake and the main-game difficulty label. Reduced-motion defaults correctly make that shake light, so the difficulty label becomes custom.

Added fixture-retarget.json for those two checks, tied to cw-cx-osmotion. Each now explicitly stages no reduced-motion request by wrapping only that matchMedia query, delegates unrelated queries, and restores the original function in finally. Their full difficulty, hint, row-presence, saved-selection and toggle assertions remain intact. Their descriptions now state the no-request condition. These checks should pass on both old and new builds; reduced-motion behavior remains covered by the new ship check for both player roles.

No game change was needed beyond the original mk. Re-ran the mk against refreshed v35.60: written. Both game anchors match once; drafted JavaScript and new check parse. Both fixture anchors match once, do not overlap, and their ASCII replacements parse. Existing four camera recipes remain ready. Handing the lane the fixture retarget, then the same cw-cx-osmotion key for preflight and shipping. Still awaiting browser verification, ON HIS PC, pictures and critic.

