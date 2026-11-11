
--- codex run 2026-11-11 08:49 ---
# 2026-11-11: first run, stopped at required fixture handoff

Base: v37.67, commit 3b6a01fdb. No game files, fixture files, or tracked files changed. No ship key submitted.

The task says: "Codex: never change tools/mkfixture.ps1; if an old check must change, put the finding and the exact change in your notes and stop." That condition is met. Check v37.14 (cw-p0acct), tools/mkfixture.ps1:10054, loads a pre-season-zero save through applyLoadedProfile and requires its living pillager to have lvl 1. This task requires an old save to read level 0. Confirmed the same assertion in the real repo. The current pilMake defaults lvl to 1 and pilClean clamps it to at least 1.

Coordinator action before this job resumes: retarget v37.14 under the normal fixture lock. Use the following unique fragment so the check passes before and after the feature ship:

Before:
`r.best===4321&&r.lvl===1&&Array.isArray(r.traits)`

After:
`r.best===4321&&(r.lvl===0||r.lvl===1)&&Array.isArray(r.traits)`

The new survival-level check must require exactly level 0 on an old save, including a second reload. This transition-compatible old check must keep every other account, stash, weapons, reward, lifetime-earnings and lineage assertion. No fixture-retarget.json was written because that mechanism is off and the task explicitly forbids editing the fixture.

Implementation findings for the resumed run:
- Reuse P.pil.lsp and P.pil.lvl, pilMake/pilClean at dark_raiders.html:6706, pilNow/pilEnd/pilBirth at 7096 onward. Add no second progression store or save key. Keep ended hall records as recorded.
- Every live career SP writer calls csTally(cat,n) at 68645: vault 68613, flowChip bounty/strong 69572, sharedMachineScore 71507, scoreBonus style 71623, careerKill 71644. This is the single live-award hook. careerSettle at 68685 doubles extraction score and applies the raid condition separately; decide and document whether the settlement-only SP difference is credited as well, without double-counting the live total.
- saveProfile at 6674 serializes the full P record, with demo, stale-save and net-build holds already in place. applyLoadedProfile migration staging is at 7816 onward. New fields need born-set migration stamps; already established lsp/lvl fields still need old-save normalization.
- Do not derive lvl from lsp on every acctEnsure: existing retirement and restore checks deliberately set lvl 3 or 5 with lsp 0 and check the record is preserved. Normalize old saves once and make actual SP awards update both values. Do not alter historical hall levels.
- The vitals block starts at 48083; health is HBW 300, HBH 26 at 48133, with by=H-34. Any added row must update HUDBOX.body, VITBOX and the stack position so it clears the bottom edge, posture, stamina, armor and belt, including HUD scaling. Reuse the vitals transform and fade group.
- pilHeadName at 7233 must remain name-only: existing tests require the exact name and pn packet value. Remote raid head labels draw in netUpTags at 65059. Send level as a separate field on the existing state packet and draw the suffix only there; netSeatName is also used by feed, trade and revive callouts. Keep names intact at their 24-character network limit. Old packets with no level must keep the old name-only fallback to preserve compatibility and existing tests.
- NETP2 is the same-PC second window, with a numbered save of its own (5616). Some prior lineage rules exclude it. Resolve against this task's host/join requirement without altering demo behavior.
- This will be SYNCED because the level field must travel on t:'st'; LINKED REVIEW NEEDED: synced after implementation. No picks or shared boost belongs to this build.
- Use standalone camera recipes to get both 1080p and 4K (tools/codex-lane.sh:571 uses -Res 1080,4k; shots.txt only gets 1080). Set CFG.xfPix=0 for the smooth look. Need host and join role shots plus level-up and cap, at most six recipe screens.

Real-raid evidence found, not yet a shipped tuning curve:
- Source: exports/run-20261107-190409-065.txt, latest 60 recorded runs #31-90, 15 successful extractions.
- The export does not contain career SP totals. Printed kill breakdowns can give only a conservative base-SP proxy. Current base values used: sentry 100, crawler 50, pillager 150, snitch 75, howler 200, bulwark 300.
- Extraction proxies sorted: 400, 475, 1000, 1100, 1150, 1525, 1700, 1950, 2300, 2350, 2375, 2625, 2675, 3500, 5475. Median 1950; mean 2040; range 400 to 5475.
- Examples: #68 v36.11, 11 sentries and 17 crawlers, 6 elites, 398 seconds: base 1950. #82 v36.58, 14 sentries, 33 crawlers, 1 pillager and 1 bulwark, 4 elites, 309 seconds: base 3500. #90 v37.56, 4 crawlers, 1 snitch and 1 howler, 1 elite, 168 seconds: base 475.
- The formatter omits listener, warden and choir kills plus elite premiums, difficulty, style, vault and bounty SP. Do not present these proxies as actual earned SP or mix demo score records into career calibration.

Reading limitations: the requested external C:/Codex/FNP new 11082026/RULES.md and both named scratchpad mk examples were absent. The provided rules and local tools/handoff/shipkit/mk-cw-downgain.ps1 plus existing save-reload checks were available. No browser, localhost, tests, preflight or ship was run.

Remaining owner: coordinator retargets the one legacy assertion, then lane o implements and submits the change, checks and camera recipes, and waits for the gate, pictures, critic, linked review and ON HIS PC result.


11-11 09:00 coordinator: check 37.14 retargeted exactly as asked (commit 99be97c82, fixture rebuilt, JS ok). Resume the build.

--- codex run 2026-11-11 09:06 ---
# 2026-11-11: implementation prepared after the continuation order

The workspace and real fixture still have the conflicting v37.14 lvl 1 assertion. This run prepared the implementation without queuing a known failing ship. No tracked game or fixture file was edited. No preflight, Chrome, camera, game test or ship ran.

Ready for the coordinator and lane:
- mk-cw-cx-survivallevel.ps1: one draft, 18 unique and non-overlapping anchors, against v37.67. Reads MK_SRC and writes only draft-cw-cx-survivallevel.json to MK_OUT_DIR. Sandbox anchor run prints written. The draft JSON is in drafts/.
- keys.pending.txt: the intended key cw-cx-survivallevel. Intentionally no keys.txt yet.
- camera-recipes.pending.json: five screens, smooth look, with a real two-window WebRTC handshake for the ordinary career host and join shots, plus level-up, cap and demo. Intentionally does not end in camera-recipes.json, so the lane will not waste camera rounds on the old build. Once active, the lane runs both 1080p and 4K for recipe files.
- survivallevel.syntax.js: extracted new helpers, check and camera staging for standalone syntax inspection. node --check passed. This was a syntax check of the new JavaScript, not a build or game test.

To unblock: coordinator retargets v37.14 under the fixture lock and verifies it. Exact unique fragment:
`r.best===4321&&r.lvl===1&&Array.isArray(r.traits)`
becomes
`r.best===4321&&(r.lvl===0||r.lvl===1)&&Array.isArray(r.traits)`.
Then activate keys.pending.txt as keys.txt and camera-recipes.pending.json as camera-recipes.json in this output folder. The new feature check itself requires exactly 0 for both pre-m4 save shapes, including the second reload. No fixture-retarget.json was written.

What the draft does:
- Reuses P.pil.lsp and P.pil.lvl. New pillagers start at 0; missing SP repairs to 0; mig4a normalizes existing living records once, with a born-set stamp on new saves. Historical hall records stay as recorded.
- Uses csTally for every live career SP award: kills, shared machine score, styles, vaults, bounties and strongholds. Each award saves through the existing saver. Extraction adds only final SP minus already-counted live SP, once. Death takes the earned level into the existing hall record. No picks, upgrade effects or shared level boost in this build.
- Adds a 6-unit lime progress track and label directly below health, inside the same existing move, scale and fade controls. Raises the health stack 42 local HUD units and extends its bounds; updates the medal-feed fallback and TV belt clearance. A level crossing says only level n, once for the last crossed level of an award.
- Carries numeric pl on the existing t:st raid word, separately from pn. The host clamps and forwards it; only raid head labels append level n. Names, lobby, team feed and give prompts keep the name only. Missing and invalid values clear stale levels and use the old name-only fallback.
- Preserves the existing lineage exception for NETP2, the separate same-PC second-window mode. It supports host and ordinary career join (NETP2=false); the camera uses independent netslot A/B saves and a real handshake. It does not expand the separate same-PC lineage and birth rules, which would need a larger lifecycle change. Demo has no bar, progression, new packet field or level suffix.
- LINKED REVIEW NEEDED: synced. The shared field is pl in t:st. It is display data only; receiving another level never awards own SP.

Calibration for the DESIGN.md section is included in the draft why, with the Watch lines:
- Source: exports/run-20261107-190409-065.txt, the 15 successful extractions in runs 31-90. Printed kill-count SP at current prices has median 1950, mean 2040. The recorder omits actual career SP totals and some kill types and bonuses.
- Estimating plain elite premiums by distributing elites uniformly over killed types gives mean 2243.50 live kill SP, median 2367.86. This is an estimate because the recorder lacks elite types and affixes.
- The latest exported settings imply the current 1.10 score multiplier. With extraction x2, the kill-only estimate is mean 4935.69 SP and median 5209.29 per surviving raid, before medals, vaults, bounties, strongholds, conditions and per-award rounding. These are not measured final SP totals or historical multipliers.
- Total SP at level L is 700*L + 165*L*L, capped at 80000. Around 2600 live SP gets two early levels; around 5200 after extraction gets three. At that pace level 20 takes roughly 15 surviving raids. Marginal costs rise from 865 SP for the first level to 7135 SP for the twentieth.

| level | total SP |
| --- | --- |
| 0 | 0 |
| 1 | 865 |
| 2 | 2060 |
| 3 | 3585 |
| 4 | 5440 |
| 5 | 7625 |
| 6 | 10140 |
| 7 | 12985 |
| 8 | 16160 |
| 9 | 19665 |
| 10 | 23500 |
| 11 | 27665 |
| 12 | 32160 |
| 13 | 36985 |
| 14 | 42140 |
| 15 | 47625 |
| 16 | 53440 |
| 17 | 59585 |
| 18 | 66060 |
| 19 | 72865 |
| 20 | 80000 |

The new check fails the old build on missing helpers. It stages rich old saves with contracts, a forged gun, stash gear, worn boots, traits and a hall record; loads both old SP shapes twice; plays and earns SP through all six score doors; checks next-bar remainder, several levels in one award, cap 20, real save serialization and two reloads, extraction counted once, death and newborn; traces the actual HUD bar and raid head text; stages both network roles with a real host fanout assertion and malformed-field cleanup; and verifies the sim, finished raids and demo gain and show nothing. No old check besides the identified v37.14 assertion was found to require a change. Fixture and game behavior remain unverified until the spare-PC gate runs.

Remaining: coordinator fixture correction and activation of the pending key and recipes; then lane preflight, ship, pictures and critic, linked review, any resulting fixes, ON HIS PC, visible-change picture log and progression log entry. Do not report this draft as shipped.


--- codex run 2026-11-11 09:16 ---
# 2026-11-11: legacy check cleared, survival level submitted

Base: v37.67, workspace HEAD 842c0b628. Confirmed the exact v37.14 legacy assertion now accepts level 0 or 1 in both the workspace and the real repo. The coordinator blocker from the earlier runs is cleared. No tracked game or fixture file was edited.

Activated keys.txt with cw-cx-survivallevel and camera-recipes.json with five smooth-look scenes: real career host, real career join, level-up callout, level 20 cap, and the unchanged demo. The recipes require both 1080p and 4K. The host/join scenes use the existing WebRTC handshake and independent netslot A/B saves, not the separate NETP2 lineage exception.

Final review found and fixed a pre-m4 cached-heir edge case: pilBirth explicitly resets SP and level to zero, including an heir saved with placeholder level 1. Added a regression case for that birth. The extraction check now subtracts the actual live SP tally instead of a literal 500, so it remains correct with a score multiplier. Raised the new label font cap from 14 to 16 local HUD pixels to follow the style guide minimum; the existing health-group scale grows it at 4K.

The mk script prints written against the current workspace build. Its draft has 19 unique, non-overlapping literal anchors. The script is ASCII and writes only its draft JSON. Standalone syntax inspection of the new helpers, regression check and all camera staging JavaScript passed with node --check. These are anchor and syntax checks only. No game test, build gate, Chrome, localhost, camera, preflight or ship was run here.

The existing notes and draft why contain the full 0..20 SP table and calibration limits. Total SP is 700*level + 165*level*level, cap 80000. The raid recorder lacks final career SP totals; its kill counts, estimated elite premiums, current multiplier and extraction bonus suggest roughly 5200 SP per surviving raid. Watch the first two surviving raids and the pace toward level 20. Watch the health stack raised by 42 local HUD pixels.

LINKED REVIEW NEEDED: synced. Field pl travels on the existing t:st packet separately from pn, is clamped and forwarded by the host, and is display data only. Receiving peer levels never awards own SP. No picks, boost or new shared reward in this build.

Remaining lane/coordinator work: preflight and ship this key; obtain gate, seed fingerprint and ON HIS PC evidence; take both-resolution pictures and run the critic; complete the linked review; return results for any required fixes and the final visible-change/progression log entries. This run does not claim the build shipped or is ready.


--- codex run 2026-11-11 09:26 ---
# 2026-11-11: repair the failed preflight staging

The spare-PC preflight failed twice before the award assertions: staging did not enter a career raid, then g.cs was undefined. The fixture intentionally sets CAREER_ON=0 unless its URL has career=1 (tools/mkfixture.ps1:1440). __pinDefaults, __cleanProfile and __deploy do not turn it back on. I omitted the explicit career setup used by the existing career checks.

Fixed the new check in mk-cw-cx-survivallevel.ps1 to capture CAREER_ON, set it to 1 immediately before each stage deploy, and restore it in finally. This invokes the actual careerPostBuild and its real G.cs initialization instead of manufacturing score state. All 19 game edits and the curve are unchanged. The baseline still fails on the missing survival helpers.

Fixed camera-recipes.json clean() to set CAREER_ON=1 independently in each camera window, so host, ordinary join and solo career scenes enter the actual career raid. The demo still uses its actual arcade path. Kept the dormant pending recipe copy current as well.

Rebuilt the draft locally: mk prints written and all 19 anchors still match exactly once. The script is ASCII. Standalone syntax inspection of the new helpers, revised regression check, and all five camera stages/expectations passed with node --check. No tracked game or fixture file was edited, no game/build tests ran here, and no browser, localhost, preflight, ship or camera was started here. The lane must rerun the remote preflight.

keys.txt still contains cw-cx-survivallevel. Five camera recipes remain active for both 1080p and 4K. LINKED REVIEW NEEDED: synced, display field pl on t:st. Remaining: lane preflight, ship/gate and fingerprint, pictures/critic, linked review and ON HIS PC evidence; then final picture/progression log entries.


--- codex run 2026-11-11 10:21 ---
# 2026-11-11: required coordinator retarget for hall check v37.34

Base game remains v37.67. The second preflight got through the new survival check and found exactly one failure in the newest 80 older checks: v37.34 FOUR, the old totals on the living row, actual ["1","0","40","$9,000","15"]. No feature or new-check defect is reported in this result.

The task explicitly says: "Codex: never change tools/mkfixture.ps1; if an old check must change, put the finding and the exact change in your notes and stop." This condition is met again. No tracked game or fixture file was edited. No fixture-retarget.json was written.

Cause: v37.34 stage THREE clears the living record and calls pilNow, creating a fresh zero-SP pillager. Stage FOUR checks that same living record. The prior starting level was 1; this task requires level 0. The actual remaining generation, raids, haul and kills are correct. The hall renderer displays the recorded level. Historical hall levels are not migrated; the same older check separately still requires vex at level 7.

Coordinator: under the normal fixture lock, retarget this unique line in tools/mkfixture.ps1:8684. Confirmed the old line exists in both the workspace and the real repo.

Before:
```js
       need(J(t)===J(['1','1','40','$9,000','15']),'FOUR: the old totals on the living row: '+J(t));
```

After:
```js
       need(J(t)===J(['1',typeof pilSurvivalLevel==='function'?'0':'1','40','$9,000','15']),'FOUR: the old totals on the living row: '+J(t));
```

This expects exactly level 1 before the feature and exactly level 0 once the survival helper exists. It preserves every other living total, all historical hall assertions, old-save reload and hall-route checks. Run v37.34 under the normal coordinator process; do not weaken or delete the check.

To prevent another known failing preflight or pictures of an unshipped part, keys.txt is empty and camera-recipes.json is parked as camera-recipes.awaiting-fixture.json. The prepared key remains cw-cx-survivallevel in keys.pending.txt. The mk script and all game edits are unchanged from the draft whose new check just passed. Once the coordinator correction is verified and the workspace refreshed, restore keys.txt from keys.pending.txt and activate camera-recipes.awaiting-fixture.json as camera-recipes.json. Then rerun lane preflight and ship.

Remaining: coordinator v37.34 retarget, lane preflight/ship, both-resolution pictures and critic, LINKED REVIEW NEEDED: synced (pl on t:st), ON HIS PC evidence and final picture/progression log entries. This is a coordinator handoff, not an owner question.


11-11 11:02 coordinator: check 37.34 FOUR retargeted exactly as asked (0bda8fc94, fixture rebuilt, JS ok). Job back in tasks/ with fresh runs; resume the retained maker.
