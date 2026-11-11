
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
