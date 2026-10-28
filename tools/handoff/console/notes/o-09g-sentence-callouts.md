
--- codex run 2026-10-28 19:30 ---
2026-10-28, o-09g-sentence-callouts, first preparation run on v36.09.

Prepared one batch key, cw-cx-sentence-callouts, for all 15 audited call sites (the map detail occurs twice). Checked every old text against the parsed 71-key TXSHIP object: none is protected. TXSHIP is unchanged. The older core-source line already says elite pillagers on this build; the replacement keeps that word.

Replaced sentences with short callouts and removed their periods. Kept one per raid as the spent-revive detail. Kept next-raid intel, core sources, the packed core count and rack costs. Undercroft say() sends only the main text to hubToast(), so the core and rack details remain in the main text with a colon or slash; putting those details in sub would hide them. Gameplay values and item spending are unchanged.

Fixture retarget request: four small edits in checks 26.13 and 11.94. Both accept the old and new text, so they can run before shipping. Check 11.94 still verifies one per raid, including the new detail field. The new check covers all 15 actual say() sites and drives both self-revive outcomes, both core guards, and spending a packed core.

Local validation passed: mk script prints written; all 15 anchors match exactly once; patched inline JavaScript parses; new check and both retargeted checks parse; all four camera recipes parse; output files are ASCII. No game file or tracked fixture edits. Browser checks cannot run in this sandbox.

Camera handoff: four custom recipes show packed-core success, missing rack parts, and revive/heal-selection callouts in each player layout. The heal-selection guard is staged with temporary target/selection helpers; it does not connect to another peer. This is a text-only change. Pictures, critic results, preflight, shipping and ON HIS PC are still for the lane to return.

Watch on the next play: spent self-revive keeps one per raid, and slotting a packed core still names the used item and next-raid intel.


--- codex run 2026-10-28 19:31 ---
2026-10-28, o-09g-sentence-callouts, preflight correction on v36.09.

The preflight failure was a mistake in my source assertion. tools/mkfixture.ps1:1585 saves updatePlayer in _tpl, then replaces updatePlayer with a timing wrapper that calls _tpl. Inspecting String(updatePlayer) therefore cannot find any seal callout, even on the drafted build. The check now inspects _tpl when that fixture alias exists, otherwise updatePlayer. It checks the exact original function used by the timing wrapper. The old build still fails because its detail has capitals and a period; the drafted detail is lower case without the period.

No player text, camera recipes or ship edits changed in this correction. Retarget commit 0ac107b46 is already applied, and the lane confirmed checks 11.94 and 26.13 passed before shipping. The local validator now accepts that already-applied retarget rather than demanding the old anchors again.

Regenerated the draft successfully: written. Local validation passes for all 15 unique anchors, unchanged TXSHIP, patched JavaScript, new check, retargeted checks, four camera recipes and ASCII output. The same key remains in keys.txt. Lane preflight, pictures, critic review, shipping and ON HIS PC confirmation remain.


--- codex run 2026-10-28 19:34 ---
2026-10-28, o-09g-sentence-callouts, older-check correction on v36.09.

Preflight found check 35.33 searches netAidHold source for the case-sensitive fragment Bandage, Medkit. The callout now uses lower case. New fixture-retarget.json changes that check to compare the existing call and detail strings without case sensitivity; its key-presence assertion is unchanged.

Audited the fixture for all listed old callout phrases and shorter fragments. Found two more affected older checks and included their retargets now: 16.16 accepts Enter a name first. or name required; 15.53 accepts the lower-case core-slotted headline and the short 1 packed data core used phrase. Check 15.53 still verifies loose copies are spent first, the packed copy is consumed, and its belt key is cleared. Its old exact headline guards would otherwise skip the new core path before checking those facts.

This retarget request has only six NEW edits in checks 35.33, 16.16 and 15.53. The already-committed 11.94/26.13 edits are omitted. All requested checks accept the current old build as well as the drafted wording. Same single ship key, same 15 text edits, same camera recipes; no new visible changes in this run.

Local results: all six new fixture anchors occur exactly once; mk prints written; all 15 game anchors are unique; TXSHIP unchanged; patched game script, new check, all five relevant older checks and four camera recipes parse; all handoff files ASCII. No browser tests are available in the sandbox. Lane retarget checks, preflight, photographs, critic, shipping and ON HIS PC remain.


--- codex run 2026-10-28 19:46 ---
2026-10-28, o-09g-sentence-callouts, shipped batch review and one text follow-up.

Confirmed from lane: cw-cx-sentence-callouts shipped as v36.10; ON HIS PC v36.10, 49 seconds after shipping. Retarget commit 3bdd0db2f passed 15.53, 16.16 and 35.33 before shipping. All first-round pictures staged at 1080 and 4k with no camera-lint findings. First-round critic scores are 2 for each view; not accepted as finished visual review.

Looked at the four attached 1080 images. The mainframe toasts show the new lower-case text clearly. Rack costs still repeat the whole existing cost row, a text-specific P1: follow-up cw-cx-rack-short-answer now says only not enough parts. The existing rack-cost row stays intact. One new retarget lets check 36.10 accept either refusal before this ships. The new follow-up check drives an unaffordable rack and asserts the exact short answer and no rack built.

The first raid pictures do not show the revive answer because the heal answer immediately replaces it. The heal answer is drawn under the player, as his newer cw-answerline ruling requires, and the open controls cover its left side. Round-two recipes photograph each answer separately in each player layout, with the existing career controls folded and the player away from the map edge. They verify ANSBOX is actually drawn and contains the expected headline and detail, rather than accepting only a run-log entry. Hub recipes show the answer persisting after closing the mainframe to review the changed toast without grading the unrelated racks layout again.

The critic demand to delete the Claude paragraph conflicts with the explicit task order to leave TXSHIP alone. It is a TXSHIP value and questions.md already logs that exact b-31 conflict. Kept it and did not ask again. Shrinking the mainframe card also conflicts with his Q43 near-full-screen card order. HUD panels, timer, status chips, control typography and the legacy control/answer overlap belong to open task 186f-hud-panel-consistency; coordinator handoff is in alarms-new.md. This task is text polish only.

Local follow-up validation: mk prints written; game and fixture anchors each match once; patched JavaScript, new check, retargeted 36.10 and six camera recipes parse; all output files ASCII. The original shipped key remains listed, followed by the new text key. Lane preflight, follow-up ship, ON HIS PC and corrected camera review remain.

