
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
