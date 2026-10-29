
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

--- codex run 2026-10-29 05:26 ---
2026-10-29 - cw-cx-nokillstreak shipped as v36.40 and is ON HIS PC v36.40: his 8802 served 36.40 at 33 seconds after the ship. Both fixture-retarget commits are in: ccf38fdec and 718237cd4. The shipped gate passed the kill-chain regression.

Reviewed all four round-1 pictures. Demo p1 and p2 staged successfully: each local audit records seven base awards of 50 SP, no removed alerts or sounds, no old chain state/ring/badge, and live beast mode. The easy-mode opening question remained over the playfield in both pictures. Career p1/p2 did not stage, so their disconnected/non-career pictures and critic scores are invalid evidence for this task. They must not prompt a HUD redesign.

Changed camera setup only for round 2. Found the fixture explicitly sets CAREER_ON=0 unless its URL has career=1. Both real windows now set CAREER_ON=1 before building their raid, so careerKill and G.cs exist. The camera answers the real normal/easy question with easyAnswer(false), after the map-first overlay is closed. It holds the already earned beast timer and waits 6.5 seconds for ordinary transient kill labels and medal animations to expire naturally before photographing. It does not hide or alter live game HUD features. Added unobscured-play assertions and peer-state diagnostics for any remaining staging failure.

All four complete updated camera wrappers parse with the helper prelude and popups flag. Handed over changed camera-recipes.json. No new game script, fixture retarget or ship is needed. Remaining lane work: photograph round 2, obtain valid career evidence in both real windows and critic reviews of the unobscured scenes. No critic finish line is claimed from round 1.

--- codex run 2026-10-29 05:33 ---
2026-10-29 - Complete. cw-cx-nokillstreak shipped in commit d7aed4a66 as v36.40 and was confirmed ON HIS PC v36.40 (his 8802 served it 33 seconds after shipping). Both fixture batches shipped in ccf38fdec and 718237cd4. No further game edits are needed.

Round 2 used the second and final camera allowance. Valid demo p1 and p2 pictures staged at both 1080p and 4K, and career p2 staged at both resolutions. Each successful scene audited BOTH real linked peers: each peer received seven awards of exactly 50 SP (five kills one second apart and two grenade casualties), had beast mode at seven stacks, no score-chain state or ring, no old badge, no removed alert, no removed medal and no count sound. The shipped regression also exercises both arcade and career ownership paths. This supplies both-window pictures in demo and real linked host/guest career audits.

Best valid pictures, one from each window:
- tools/handoff/console/notes/shots/o-00p-234-no-kill-streak-callouts-recipes-2/no-kill-chain-demo-p1-1080.jpg
- tools/handoff/console/notes/shots/o-00p-234-no-kill-streak-callouts-recipes-2/no-kill-chain-demo-p2-1080.jpg
The corresponding 4K files pass staging too. Extra valid career evidence: no-kill-chain-coop-p2-1080.jpg and no-kill-chain-coop-p2-4k.jpg in the same folder. Full host/guest audit data are in report.json.

Career p1 photography remains NOT STAGED: the guest failed to link or enter while a welcome pack remained visible. Its picture and critic review do not assess this task. No game defect was established by that setup failure, and it does not invalidate the successful linked career p2 audit of both peers. No more photography is authorized by the two-round cap.

The critic gave the valid round-2 scenes 3/5. The existing review recorder keys these pictures as p1-1080 and p2-1080 and records score:3, need:3, pass:true. This is focused-scene acceptance, not a claim that the entire raid HUD reaches its broader 4/5 goal. The valid-scene findings concern existing hp/armour bars, loose empty-slot digits, panel margins, buff/roster alignment, team-score columns and goal-toast presentation. They are handed to the coordinator for the wider HUD work; no unrelated controls, loot rows or gameplay values were changed to chase those reviews. The removed score-chain UI is absent in every valid picture; the two requested beast-mode status rows remain.

Watch: no more double or triple kill callouts; beast mode is the streak. Arcade scores will run lower because earlier leaderboard nights included streak multipliers and count-medal points. DESIGN.md has this note from the shipped draft.
