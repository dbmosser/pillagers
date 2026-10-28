
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
