
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
