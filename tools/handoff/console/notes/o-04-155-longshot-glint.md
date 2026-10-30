
--- codex run 2026-10-28 12:39 ---
2026-10-28, first Codex run, starting from v35.84.

Prepared cw-cx-longshotglint. An elite pillager holding any gun whose base is sniper gets a 0.5 second tell before a shot at a player. Hires and friendly pillagers are excluded. The throw attempt still comes first in chase. The original aim, spread and cooldown random draws remain in their original order when the shot actually fires. Cooldown subtracts the tell time. A blocked or out-of-range shot at expiry is dropped. Countdown runs once per entity frame, including frames that skip the firing branch; dying, downed and inactive bodies lose the tell.

Found a second player-directed firing path for pillagers waiting in an extraction ring. Applied the same tell there so it cannot bypass the warning. Other weapons keep their existing firing timing in both paths.

Drawing uses the existing gunMuzzleAt position. A white four-point star with a red core grows from radius 8 to 22 world units, with a 30 percent final flash during the last 0.05 seconds. A dark 3-unit outline separates it from bright ground. It runs in _wtA above the fog, outside the visible-body list, but only if the line to this window's player is clear. It does not read the aim-lanes switch. No new text or switch.

Ninth-field bit 4 carries the glint, retaining burn 1 and get-up 2 and leaving higher bits alone. Player 2 starts the animation and charge sound on the rising edge, preserves phase across repeat snapshots, and clears on the falling edge. Its last flash remains until the host clears the bit.

The draft check measures actual owned bullets through updateEnts: no round on frame one, one after 0.5 seconds; ordinary Auto Rifle immediately; warning also at the extraction ring; cancellation behind cover and out of range; independent burn/get-up/glint bits and repeat snapshots; hidden-body drawing only on a clear line; _wtA draw ordering. The control on the old build fails at its first elite shot assertion. It has not been run in Chrome here, per the sandbox rules.

Local validation passed: mk prints written; all nine anchors match once; all nine edits change their anchor; the patched complete game script, fixture check and four camera scenes parse; all handoff code is ASCII. No tracked file was edited. No fixture retarget is currently needed.

camera-recipes.json has four real paired-window scenes: p1/day, p2/day, p1/night, p2/night. Each has a visible elite Longshot on the right and a clear-line fog-hidden one on the left, uses the smooth look, starts both glints through the host firing code, and verifies the second window receives the network bit. Photograph ALL FOUR at BOTH 1080 and 4k as required by the task. The recipes reuse the established real-pair setup from task o-132, freeze only the disposable camera simulation after pairing, and close the extra window on cleanup. No separate shots.txt is needed for custom recipes.

The required DESIGN.md watch line is in the draft why field (gen-draft.ps1 uses why for DESIGN.md): the glint must read at range in the smooth look and at night; revealing a hidden Longshot pillager must not feel like a wallhack; Longshot pillagers should lose more duels because dodging is intended.

Pending lane work: preflight, ship, ON HIS PC receipt, all four paired camera scenes at both resolutions, and critic results. Review pictures and address P0/P1 findings before closing the job.


--- codex run 2026-10-28 12:40 ---
2026-10-28, preflight correction on v35.84.

Preflight reached the extraction-ring assertion twice and stopped with "ring shot bypassed the warning". That assertion also covered a missing tell, so its wording overstated the result. The ring staging left e.beat unset. updateEnts at line 32776 applies the existing first-contact reaction delay whenever a pillager is not in chase and has no beat: it floors cd to e.react or 0.5. Thus this fixture pillager was not yet ready to fire or begin a tell, despite the test setting cd=0 and acqT=1.

Fixed only the new fixture check: e.beat=1 stages an already-acquired target at the ring. The original assertions still require no immediate shot, a full 0.5 second glint, then exactly one owned bullet after 0.5 seconds. Split the initial failure into an actual early-shot message and a missing-tell message with state, cooldown, acquisition time and glint values. No gameplay, drawing or network code changed this run.

Re-ran the mk script: written. Local validation passed again: nine unique anchors, nine effective edits, the complete drafted game script and fixture check parse, and ASCII handoff files. No tracked file changed. keys.txt still requests cw-cx-longshotglint. The four real-pair camera scenes remain ready for both 1080 and 4k. Pending lane work is preflight, ship, ON HIS PC receipt and picture/critic review.

--- codex run 2026-10-28 12:55 ---
2026-10-28, v35.85 shipped and ON HIS PC confirmed by the lane (33 seconds after shipping). No new game key this run.

Reviewed the round-1 pictures and camera report. Only gl155-p2-day-1080 staged. It shows both white/red stars, including the left star without a visible body. Its actual network report proves both real windows were connected, smooth=true, glints=2, bodies=[true,false], phase about 0.04 seconds and ninth-field bits [4,4]. The other seven resolution/scene combinations were NOT STAGED, so their lobby/easy-mode pictures and critic comments are not acceptance evidence for this feature.

Fixed the camera recipes. The p1 query now includes netslot=A, exactly as the proven source recipe did; omitting it was the difference in the failed p1 pairing setup. The recipes now use normal co-op and the fixture deploy with fixed map 0, seed 4242, rather than random arcade maps. This also removes the unrelated arcade board from the setup. The clear-range search checks both players to both shooter positions, plus clearance around the four standing positions, on a 50-unit grid over the map. It no longer rejects an otherwise valid firing lane because there is a wall somewhere in an 870 by 130 unit rectangle. Freeze the disposable camera simulation and dismiss any easy prompt before the range search. Pin calm weather and the day/night condition in both windows. The final expectation also rejects visible modals and an easy prompt. Neither real raid geometry nor the game source is changed by these camera-only fixes.

Generated four revised recipes. The lane should photograph all four again at both 1080 and 4k. The shipped key stays in keys.txt and must be skipped, not rebuilt against its own applied anchors.

Round-1 critic score was 2 on each picture. Three critics judged unrelated screens because staging failed. The staged p2/day critic discussed pre-existing general HUD layout, bars, hotbar and labels; it did not identify a defect in the new glints. Those global HUD changes are not part of this attack-warning task and are handed to the coordinator. No HUD restyle is being mixed into this gameplay change. Pending: valid p1/p2 day/night pictures at both resolutions and their critic review.


--- codex run 2026-10-28 13:03 ---
2026-10-28, camera round 2 review on shipped v35.85.

The report confirms 7 of 8 scene/resolution combinations staged: p1/day, p2/day and p1/night at both 1080 and 4k, plus p2/night at 4k. Only p2/night at 1080 failed its real two-window handshake. Every successful scene reports two glints, visible-body states [true,false], phase 0.04 and ninth-field bits [4,4] in both real linked windows. Reviewed the attached 1080 pictures and opened gl155-p2-night-4k.jpg. The visible shooter star remains clear against the night scene. The fog-side star is covered by the fixture's forced-open controls list, so round 2 is still not a complete visual acceptance.

Prepared revised camera recipes for round 3. Fold the existing controls list with G.legendOn=0 and fold the existing pillager board with P.hud.raiders.c=1, in the disposable camera profile only. This addresses the critic's P0/P1 controls-list finding without changing game defaults; __deploy deliberately forces that list open for old checks. It also removes the unrelated dead/extracted staging rows from the picture. The new range-search margins account for both camera windows' current world viewport, so the player is centered away from map-edge camera clamps. The report now includes each muzzle star's screen coordinates and fails staging unless both are safely inside both viewports. It also requires the existing panels to be folded.

The player 2 host popup previously started pairing as soon as its APIs existed, before waiting for its profile to finish loading. Pair setup now waits for the main profile and popup host profile before picking co-op. This removes that race from the occasional failed link. All four generated recipes, prelude and expectations parse and are ASCII. No game source change and no new ship key.

Round-2 critic scores are 2. The controls-list P0/P1 is a fixture-staging defect and is addressed in this camera update. Other P1s concern inherited HUD styling, repeated extraction distance, cache-label colour and health-bar sizing; those were already handed to the coordinator. The title-screen review for failed p2/night-1080 is unrelated to the glint. No unrelated HUD redesign is included in this attack-warning task.

Pending lane work: run revised camera-recipes.json at 1080 and 4k, all four scenes, and critic review. cw-cx-longshotglint remains shipped v35.85 with ON HIS PC receipt; do not run its mk again.


--- codex run 2026-10-28 13:09 ---
2026-10-28, camera round 3 review, v35.85 remains shipped and ON HIS PC.

Reviewed all four attached 1080 scenes and opened p1/night and p2/day at 4k. Both stars are now unobstructed. The left body stays in fog and only its glint shows; the right body and its muzzle glint are visible. Day/night is apparent and the stars remain distinct against both backgrounds.

The NOT STAGED result is from my new companion-window viewport assertion, not a glint, pairing or capture failure. All eight reports contain two actual glints and bodies=[true,false] in both real linked windows. Each photographed window also has both stars safely on screen. The unphotographed companion popup is only about 800 pixels wide in headless Chrome; it fails the 100 pixel margin test (for example x=8 and x=710 in a p1 scene). Its own full-size pictures are taken separately by the corresponding p2 recipes, and vice versa. The camera should check screenshot bounds in the window it is photographing, not require that the smaller companion popup also fit a full-size composition.

Fixed that assertion for the final camera round. Keep every two-window state assertion (real connection, smooth, two glints, correct body visibility, unchanged phase and ninth-field bits) in both windows. Require both stars' screen bounds in report.views[report.captureIx], the actual photographed seat. Include viewport dimensions in the report to make the distinction explicit. All four revised programs, the prelude and expectations parse and are ASCII. No gameplay change or new ship key.

Critic round 3: p1/day 2, p1/night 3, p2/day 2, p2/night 2. Controls and roster folds are now acknowledged improvements. Remaining findings concern the existing HUD, not the glint: health-bar sizing and margins, retained party health card, extraction labels, hotbar, run-info/roster styling and cache colours. The request to hide current pillagers also conflicts with his fresh 10-28 order naming that HUD control (recorded at dark_raiders.html line 47386). Do not remove that feature to satisfy the critic. The alleged capital I in run info is not present in the attached picture. These inherited findings were already handed to the coordinator; this task has not earned a raid-HUD score of 4, and no claim otherwise is made.

Best current pictures: tools/handoff/console/notes/shots/o-04-155-longshot-glint-recipes-3/gl155-p1-night-4k.jpg and gl155-p2-day-1080.jpg. They show the new glint while keeping the other body in fog. Round 2 is retained in the adjacent recipes-2 folder as the earlier framing, with the fixture controls list open. The only game implementation is shipped v35.85.

Pending: final camera report with the corrected photographed-seat assertion. All implementation and shipping work is complete, including the regression gate and ON HIS PC receipt. Do not expand this feature task into an unrelated HUD redesign.


--- codex run 2026-10-30 07:28 ---
2026-10-30, final review of camera round 4.
Implementation cw-cx-longshotglint shipped v35.85; prior lane receipt confirms ON HIS PC. No new game change or key this run.

Final report: all eight photographs staged successfully: p1/p2, day/night, 1080/4k. Both real linked windows report smooth=true, two glints, bodies=[true,false], phases about 0.04 seconds and ninth-field bits [4,4]. Each photographed seat has both muzzle stars inside its viewport. Reviewed p1/day and p2/night at 1080 and p1/night and p2/day at 4k. The fog-hidden body remains hidden while its white/red star is visible. These are actual paired windows.

Critic round 4 scores remain p1/day 2, p1/night 3, p2/day 2, p2/night 2. The raid finish line of 4 was not reached. Rounds 3 and 4 did not improve these scores after the staging fixes; stop under the rule allowing two follow-ups without a score increase. Remaining P0/P1 findings concern inherited HUD panels, margins, hp, hotbar and extraction chips. They do not identify a glint defect. Do not expand this attack-warning job into a raid HUD redesign. The requested deletion of current pillagers conflicts with the owner's existing HUD ruling; retain the control.

Two best retained versions:
- Round 4, fully staged final composition: tools/handoff/console/notes/shots/o-04-155-longshot-glint-recipes-4/gl155-p1-night-4k.jpg and gl155-p2-day-1080.jpg. Scores 3 and 2 respectively; both warning stars are unobstructed, including the fog-side star.
- Round 3, previous composition: tools/handoff/console/notes/shots/o-04-155-longshot-glint-recipes-3/gl155-p1-night-4k.jpg and gl155-p2-day-1080.jpg. Scores 3 and 2; photographed seat was composed correctly but an over-strict companion viewport assertion marked staging failed. Round 4 corrects that assertion without gameplay changes.

Watch remains in the shipped draft why/ DESIGN handoff: readability at range in smooth/night, hidden-position reveal feeling fair, and the intended extra opportunity to dodge Longshot shots.
LINKED REVIEW NEEDED: synced. Entity row r[8] bit 4 carries the glint. Required paired-window pictures and snapshot assertions are complete; coordinator owns any separate linked review.
Task implementation and required camera work are complete. Close under the documented critic stop rule, without claiming the raid HUD passed.
