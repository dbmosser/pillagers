
--- codex run 2026-10-29 05:07 ---
2026-10-29 - Prepared cw-cx-nokillstreak against v36.39. Dependency o-00f-223 is complete: its notes confirm cw-cx-damagestreaks shipped and ON HIS PC v36.27, with valid pictures of both linked windows. No dependency hold remains.

The draft removes score-chain multiplication and tracking from both arcadeKill and career scoreKill, their alert and medal sound calls, the climbing chain tick generators, score multiplier badge and spacing, old cursor ring, and the best-streak run-over row. It removes MULTI-KILL and GRENADE DOUBLE awards, icons, tiers and sound entries. Long shot, melee kill, untouched, team combo and screen clear remain. Base kill figures remain in the kill feed, following his newer no-floating-SP order. Hot-ground, final-rush and difficulty bonuses remain. No pickup stack, loot row or loot sound changes. Historical packet/save fields remain readable for old run records, but current kills neither advance nor display a score chain.

Cleaned the news/help lines promising streaks or the combo ring, the style-medal settings description, and the sound-lab medal names. The draft why field becomes the DESIGN.md entry through gen-draft.ps1: it says arcade scores run lower because earlier leaderboard nights had streak points, and includes the exact watch line: no more double or triple kill callouts; beast mode is the streak.

Handed over mk-cw-cx-nokillstreak.ps1 and keys.txt, plus fixture-retarget.json for 11 older checks. Retargets retain plain kills, no SP floats, retained medals, hot ground, run-over haul/distance and unrelated audio assertions. Deleted only checks 33.24 and 28.21, which exclusively require the removed chain tick and cursor ring. All other retargets accept both the old and new builds so they can run before the ship.

Local validation: all 24 exact anchors match once; sandbox mk execution prints written; game script and regression check parse; retarget replacements parse and their original-file anchors are unique; all four complete camera wrappers parse with the proven helper prelude and popups:true. Extracted real old/new score functions tested in Node: five one-second kills pay 50/100/150/150/200 before, 50/50/50/50/50 after, in both arcade and career. Extracted styleKill proves grenade double and multi-kill disappear while melee kill and long shot still pay. Browser regression check itself was not run in this sandbox. Local project lint reports SKIP because this worktree lacks its npm packages; lane preflight must run its normal lint.

The new browser check stages real host deaths and addressed partner kill messages in arcade and career, checking five one-second kills, base feed figures, beast mode stacks, no score-chain state, no badge/ring, no kill-count sounds/alerts, and two grenade casualties without a count bonus. Four custom camera recipes audit these behaviors in both real linked windows in demo and career. They reuse the successful linked-window setup from the active-reload and beast-mode jobs. Count medals are distinguished from retained team-combo medals during camera sound auditing.

Remaining lane work: apply/run fixture retargets, preflight, ship, obtain ON HIS PC, then photograph/review the four custom scenes. This run does not claim a shipped build or a critic score.


--- codex run 2026-10-29 05:09 ---
2026-10-29 - Fixed the rejected 33.01 retarget. The deployed raid applies MAIN_GAME, whose xfEvDebris, xfEvBounty and xfEvRamp values are zero. The old test checked the settings defaults before deployment, then incorrectly assumed all event switches stayed on afterwards. Its event section now explicitly enables all five switches and snapshots them before testing eligibility. The individual off, other-events-unchanged and all-off assertions remain; event prerequisites and game behavior are unchanged.

Regenerated fixture-retarget.json with the same 11 exact original-file anchors. All replacements parse. A local Node probe of the actual current and candidate xfSnap, xf and evEligible functions reproduces the exact three exclusions from the raid preset, then passes all-on, each individual off and all-off after the corrected staging. Rechecked extracted scoring and style behavior: candidate base kill scoring remains 50/50/50/50/50, removed medals stay absent, melee and long shot remain. This is isolated source validation; browser checks still belong to the lane.

Handed over the changed fixture-retarget.json. Existing cw-cx-nokillstreak key and four camera recipes remain ready. Nothing has shipped yet. Remaining lane work: retry fixture retargets, preflight and ship, confirm ON HIS PC, then photograph and review both linked windows.

--- codex run 2026-10-29 05:12 ---
2026-10-29 - Preflight found one additional legacy assertion: 35.99 required exactly six run-over moments, counting the best-streak row removed by this task. The first retarget batch is already committed as ccf38fdec, so fixture-retarget.json now contains only the NEW 35.99 edit.

35.99 now requires crown, closest call, most damage, biggest haul and longest shot exactly once in their existing order. It accepts the legacy best-streak row while testing the old build and its absence on the candidate. The stat-grid alignment, label sizes, equal death counts, scrim, divider and crown color checks remain intact. The retarget is compatible before and after the ship.

Validation: the revised assertion passes DOM-shaped versions of both six-row and five-row layouts, and rejects missing, unknown and duplicate moments. The complete replacement check parses, its original-file anchor matches once, and the unchanged mk script still prints written against refreshed v36.39. No further game-code change was needed. Remaining lane work: apply/run the new retarget, retry preflight/ship, confirm ON HIS PC and review the linked-window pictures.
