
--- codex run 2026-10-28 23:34 ---
Prepared cw-cx-slowerswitch. All class draw times increase by half (pistol rounded to 0.38 s), fallback 0.5 to 0.75 s. Switching status now follows drawT rather than the flat 0.45 s stamp. Shared drawTick and the firing guard remain the path for either seat and every input. Reload cancel and active reload chain break are unchanged.
New check stages rifle swaps and hotbar selections in host and p2 roles, requires drawT and drawLen 0.825, holds the trigger through 0.82 s without a shot, then requires a shot when the timer reaches zero. It checks the live switching status, all class times, fallback, melee, reload cancel and chain break. No pickup stack, loot sound or loot row edits.
The 26.16 check hard-coded old draw times. Retarget accepts either the complete original timings or the complete new timings based on the rifle value, so it can pass before shipping. The new check requires the new values.
DESIGN.md watch text is in the draft why field (gen-draft.ps1 writes that field to the design entry): "switching guns takes half again as long".
Camera recipes request each local seat showing the real rifle draw after 0.5 s. They stop only the camera fixture player update after staging to hold the short-lived status for a picture.
Sandbox validation: mk anchors matched once and wrote the draft. Lane still needs to run fixture retarget, preflight, ship, fingerprint, camera/critic and ON HIS PC verification.

--- codex run 2026-10-28 23:36 ---
The first preflight passed the direct swap case but failed host/hotbar. Cause: the check replaced the held rifle with a pistol for the next case while leaving G.hot on the rifle cell from the preceding swap. setHot ignored a repeated selection of the already highlighted cell. The check now restores the selected cell to the staged held pistol with heldGunCell(hotbarSlots()) before each case, then selects the stowed rifle. No production code change was needed for this failure.
The 26.16 retarget is already committed as 5dbfefa8f and passed before shipping. Rebuilt the same key; unique game anchors, patched JavaScript, check and camera recipe syntax, and ASCII handoff checks pass locally. Lane must rerun preflight, shipping, pictures/critic and ON HIS PC confirmation.


--- codex run 2026-10-28 23:40 ---
The rifle timing check now passes twice. Preflight stopped on 36.22 and 36.20: measured detail text 15.391 px and title text 14.429 logical px. drawStatusIcons has an explicit fit-to-space scale that uses cached HUDBOX, FEEDBOX, MEDALBOX and NETTEAMBOX rectangles. These font checks call the component without refreshing those rectangles, so a prior raid layout can shrink their supposedly isolated type measurement.
Prepared new fixture retargets for only 36.22 and 36.20. Each saves the four layout objects, measures the same real status renderer with an empty collision layout and room for both rows, then restores the objects. All original font floors, colors and panel-border assertions remain. No production font or layout change. The earlier 26.16 retarget is already committed and is not included again.
Added config/profile cleanup to the new timing check. Lane must apply and run the two font retargets on the current build, then rerun preflight and ship cw-cx-slowerswitch. Pictures, critic and ON HIS PC confirmation remain outstanding.


--- codex run 2026-10-28 23:46 ---
The refused anchors match the worktree exactly, but the real repo fixture has mixed line endings: these two checks use LF within a file that also contains CRLF. retarget.mjs converts every multiline anchor to CRLF when it detects CRLF anywhere in the file, which prevents matching these blocks. Rebuilt the retarget as four unique single-line anchors copied from the current checks, avoiding line-ending conversion entirely.
The same two font checks now save and clear cached HUD collision rectangles in their unique variable lines, then restore the rectangles after drawing and before their first assertions. Font floors, colors and panel-border assertions are unchanged. The timing key and camera recipes are unchanged. Lane still needs to apply and run retargets, preflight, ship, pictures/critic and ON HIS PC verification.


--- codex run 2026-10-28 23:54 ---
cw-cx-slowerswitch shipped as v36.28, commit bf7e8a222. The lane confirmed ON HIS PC v36.28 after 113 seconds. Font-check retargets committed as dc5565eaf and passed 36.20/36.22 on v36.27 before the ship. Rifle timing check and shipping gates passed.
Camera round 1 did not stage either seat: my reduced prelude omitted prep(), which tools/uishots.ps1 always calls before the screen body. Both attached pictures show the title, so that critic result does not evaluate the switching-status change. Corrected the prelude with the standard async prep() that pins DPR to 1. Both full camera wrapper bodies and expectations parse, and prep exists in a local VM check. No further game patch is needed; request another recipe camera round and critic on the actual raid pictures.

