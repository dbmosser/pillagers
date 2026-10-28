
--- codex run 2026-10-28 10:07 ---
2026-10-28, first run, HEAD v35.77.
Prepared cw-cx-condition-sp for the lane. No game or fixture file was edited.
Read the revised decision as replacing the original night-cash request. No night-cash feature was added.
SP and XP are separate on HEAD: G.cs.s/careerBoard are raid SP; P.xp and xpBaseFor feed Mainframe rewards. Old conditions: night 1.20x XP, hard weather 1.10x XP; Terms add 25% each for blackout and short window and 30% each for patrols, known and silence, to haul cash and the spForRun portion of XP. The draft DESIGN text records these values.
The patch removes condition XP and hazard cash. Every active condition gives 1.05x SP; factors multiply. Terms effects remain active. Clear/partly weather and daytime blackout with no lamps earn no weather factor.
Career SP factors apply once at settlement and the leaderboard gets the adjusted score. Existing score-to-cash conversion uses the score before condition bonuses; the extraction ledger separates those numbers. Demo conditions apply through its earned-SP path. The existing DMUL_ON fixture switch controls these factors alongside the other score modifiers.
The old nightXp/wxXp function names remain for compatibility, with 1.05 values; neither is used in XP calculation. Legacy dial values cannot reintroduce condition XP.
Local validation: mk printed written; all 31 edit anchors occur once and apply sequentially; patched game JavaScript, the new regression check and all five retargeted checks and four camera recipes parse. All lane inputs are ASCII.
fixture-retarget.json updates 20.31, 15.94, 13.53, 11.00 and 10.06 to accept current and new behavior before the key ships. The new check tests actual old XP payout first, so it fails on this build.
Camera recipes request smooth sector/Terms plus two separate extraction stages: host choices and a guest with saved host Terms differing from its own. These are fixture stages, not evidence of a live linked two-window playtest.
Remaining: lane must apply retargets under the lock, preflight, ship, get ON HIS PC, photograph and run critic. A real linked two-window payout check is also still needed to meet the task brief.
Watch in play: equal actions under night, rain/fog or signed Terms raise SP only; cash and XP must stay the same. Multiple conditions must stack and the end-card money must match the bank.

--- codex run 2026-10-28 10:47 ---
2026-10-28, second run, HEAD v35.79.
Confirmed cw-cx-condition-sp SHIPPED v35.79 and ON HIS PC v35.79 (8802 served it 34 seconds after shipping). Fixture retarget commit bb8b4f90b passed 10.06, 11.00, 13.53, 15.94 and 20.31 on the trial old build.
Reviewed all four round-1 pictures. Critic scored sector 3, Terms 3, host result 3 and guest result 3. The result cards showed 2,000 SP with no condition rows because the camera wrote DMUL_ON outside game scope. This was a camera error; the shipped gate check runs inside game scope.
Prepared cw-cx-condition-ui, the first visual follow-up. Terms now have a 32px aligned header, 88px rows, 20px reward figures, explicit signed checks and focus styling. Short descriptions use pillagers, never pillager bots. The pre-raid pack collapses its empty expansion; condition labels are 18px, pack buttons 16px and the core says burn for intel. The map keeps its approved blue and proportions; text grows, uses a narrow halo and avoids room shapes and extraction rings.
The career ledger uses a 56px SP hero, 32px neutral money total, 16px captions and four secondary stats. Kill count moves into the combat row, so the count stays available. The secured tile gets its item name. Medals use neutral outlines with a narrow gold edge. Feedback remains functional as a quiet text control. No reward formula or feel value changes in this follow-up.
Replaced the old retarget file with only four NEW edits for this key, covering 32.42, 32.41, 32.57 and 28.03. They accept both old and new layouts before shipping.
Camera recipes now run game mutations through __gx, use smooth rendering and require 2,315 SP with $2,000 in score-conversion cash for night + fog + known, in both host and saved-host-Terms guest stages. Stage stats have four crawler kills, three containers and 150 seconds. The actual linked-window playtest remains the coordinator handoff from the first run.
Local checks: mk printed written; 19 anchors match once and apply in sequence. The patched game, new regression check, four retargeted checks and all camera scripts including their game-scope payloads parse. MK is ASCII. No tracked game or fixture file was edited.
Next: lane applies the four fixture updates, preflights and ships cw-cx-condition-ui, confirms ON HIS PC, then takes round-2 pictures and runs the critic. End-card target remains 4; sector and Terms target 3. This is one visual follow-up, not two.

--- codex run 2026-10-28 11:04 ---
2026-10-28, third run, HEAD v35.80.
cw-cx-condition-ui did not ship. Its new check passed twice on the drafted v35.81 and failed on the control as intended. The STOP was RECENT ERROR: dry=TIMEOUT while running the older-check batch, not an assertion failure in the new check. Control returning the new check failure is expected in that report. The gate does not report which older check timed out.
The second fixture retarget succeeded in d529d88bf; 28.03, 32.41, 32.42 and 32.57 passed first on v35.79. No new fixture retarget is needed; the existing file is already applied.
Kept the same cw-cx-condition-ui key. Removed the newly added CSS :has selectors in favor of direct signed-row and career-card classes, set once during rendering. Cached map room and label rectangles once per zone name, so candidate positions do not repeatedly concatenate arrays or measure the same room names. These are bounded performance reductions; the aggregate log does not prove the cause of the timeout.
The visual design and new regression assertions are unchanged. The follow-up now has 21 unique anchors; mk prints written. Patched game JavaScript, the new check, four already-applied retarget checks and all camera recipe payloads parse. MK is ASCII. No tracked files were changed.
Next: retry the same key through preflight and ship, confirm ON HIS PC, then run the corrected camera recipes and critic. If the older-check batch times out again, the coordinator needs to record per-check progress to identify the stalled check. The linked-window playtest remains in the earlier handoff.

--- codex run 2026-10-28 11:35 ---
2026-10-28, fourth run, HEAD v35.81.
Confirmed cw-cx-condition-ui SHIPPED v35.81 and ON HIS PC v35.81 after 49 seconds. The older-check timeout did not recur after the performance cleanup.
Reviewed the round-2 sector and Terms pictures. Both critic scores remain 3. Terms visibly improved, but has a detached total, excess bottom space and repeated lime. The sector blackout bonus wraps; the warning sits far below the belt. The map color/proportion exception remains as logged.
Round-2 camera errors were in our recipes: Terms expected U.modal after the minimal prelude removed that helper; extraction query was career=1 instead of ?career=1. uishots concatenates query directly to the URL, so it requested fixture.htmlcareer=1 and could not load. Fixed Terms expect to U.on and both extraction query strings to ?career=1. Set timeLeft to raidLen minus 150 so the staged time reads 2:30. No additional browser capability or coordinator camera change is needed.
Prepared cw-cx-condition-ui2, the SECOND visual follow-up. Conditions column is 24px wider, values are 16px and cannot wrap. Selected checks and focus outlines do not add extra inset bars. Belt targets are 48px in two rows; the warning follows the pack while ascend stays at the bottom. Terms rows are 100px; content expands to 1632px; idle buttons get 2px borders; only the signed control uses lime fill. The 56px total moves into the existing action footer. Descriptions lose sentences and repeated clock figures. Map names search nearby clear positions in both axes, with cached bounds and early exits, and the purple marker has a keyed legend.
New fixture-retarget.json contains only one NEW change: 32.57 accepts a readable warning up to 20px, including the current 16px and new 18px. It must pass on the old build before the new key ships.
Local validation: mk printed written, seven anchors apply once in sequence, patched game JS and the new check parse, the retargeted 32.57 parses, all four camera recipes and game-scope payloads parse. MK is ASCII. No tracked file was edited.
Next: preflight and ship cw-cx-condition-ui2, ON HIS PC, then round-3 camera and critic. Extraction cards still need their first correctly staged review of the shipped result design. Two camera rounds remain including round 3. Sector and Terms meet the score-3 target; if this second follow-up still does not raise them, use the stop-after-two-unimproved-follow-ups rule and record the best pictures. End cards still need 4 or the applicable stop rule. The real linked-window verification remains the earlier coordinator handoff.

--- codex run 2026-10-28 11:43 ---
2026-10-28, fifth run, HEAD v35.82.
Preflight stopped before building: the pending patrols-description anchor was changed by cw-pillagersword in v35.82.
Updated the SAME cw-cx-condition-ui2 key to anchor the current named list, "40% more sentries, crawlers, criers and pillagers.", and shorten it to "sentries, crawlers, criers, pillagers +40%". Preserved every named kind. Read the v35.82 regression entry: the new owner wording order forbids generic machine labels as well as pillager bots; this patch respects it.
No other anchors changed. MK prints written on v35.82; all seven edit anchors match once and apply in order. Patched game JS, the new check, the already-applied 32.57 retarget and all camera payloads parse. MK is ASCII.
Fixture retarget 29bec4d2e is already applied; it passed on v35.81. No new retarget is needed.
Remaining: preflight and ship the same key, ON HIS PC confirmation, corrected round-3 pictures and critic; linked-window verification remains the existing coordinator handoff. This anchor refresh is not another visual follow-up or critic try.
