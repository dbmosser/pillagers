
--- codex run 2026-11-05 13:38 ---
2026-11-05: source triage on v37.48; no game change proposed.
LOCAL: no linked review.

18.34 is under-staged. __deploy({kit:[]}) clears the item kit, not P.weapons, P.equipped, P.equippedSec or P.gunKeys. __cleanProfile and __runPrep do not reset those four fields either. buildRaid deliberately retains an equipped owned gun. Only an absent/unowned/fists primary gets the scav pistol (FREEKIT_GUN is pistol); this fallback is still present. gunKeysSettle then assigns the actual gun to its class key and selects its held cell. Thus an inherited SMG or rifle can correctly leave key 1 vacant and unselected. The quiet belt correctly paints no slab there.

Evidence locations (workspace v37.48): fixture __cleanProfile 192, __runPrep 118441, __deploy 118564; game fallback 17945-17964, gun class table 29200-29212, gunKeysSettle 29294-29344, quiet belt 45002-45010. acctEnsure (6573) edits lineage/account fields, not the equipped gun or belt layout. commitKit (75312) packs items; it does not clear the equipped primary. A targeted git diff 81d104220 (v37.02) to 2686c0739 (v37.17) found no edits to the fallback, commitKit, hotbarSlots, gunKeysSettle, gunKeyTable, gunClassKey or initial hot selector. No evidence the spawn pistol was intentionally removed in those builds.

This establishes a test setup dependency, not which prior corpus check supplied the inherited profile. I could not run 18.34 or log live slots on either historic build: this sandbox has no browser, localhost, preflight or spare-PC access. Do not report a passing check or a proven first bad build from this source inspection.

Exact proposed check-only changes are in check-18.34-change.txt in this task output folder. They stage an owned pistol, default class keys, and a gun kit before measuring the same key-1 corner and inside pixels. They also assert that key 1 actually holds the selected pistol; neither pixel assertion is removed or weakened. Profile fields introduced by this staging are restored after cleanup. No fixture file was edited; no fixture-retarget.json was made, per task/addendum.

Coordinator/HTML CEO remaining work: run 18.34 alone on v37.02 and v37.17 and record P.equipped, P.weapons, P.gunKeys, hotbarSlots(), hotSel(), G.player.wep.id and G.hotAssign immediately after __deploy; repeat in the failing full-run order before applying the correction if possible. Apply the check-only correction via fixq, run it alone and in a full run on current build, and record the results. The task finish line (18.34 passing in a current full run) is not yet verified.

--- codex run 2026-11-05 13:40 ---
2026-11-05 continuation: no fixture correction or browser/full-run result has arrived; 18.34 is unchanged on refreshed master.

Added source-belt-probe.js and source-belt-probe-results.json. Ran the extracted production hotbarSlots, gunKeysSettle, hotSel, gun class and held-cell functions under Node on v37.02 (81d104220), v37.17 (2686c0739) and current HEAD. The probe supplies minimal weapon/item records and no non-gun class cells; it is NOT a browser, deploy, canvas or full-run test.

All three versions agree: pistol/fists -> key 1 pistol, selection 0; SMG/fists -> key 1 fists, selection 1; rifle/fists -> key 1 fists, selection 2; SMG/rifle -> key 1 vacant with null icon, selection 1, assignments {1:gun_smg,2:gun_rifle}. The last case reproduces the state that would correctly suppress key 1 slab painting, without any new spawn or belt regression.

Correction to previous notes: a single inherited SMG or rifle with a fists secondary does NOT by itself prove the vacant-key failure. Both inherited non-pistol guns (or another interfering class-key layout) can. The prior explanation was too broad. The exact corpus predecessor remains unknown without the requested live diagnostics.

Existing check-18.34-change.txt still applies: explicitly stage the pistol and default class layout, assert selected key 1 contains it, then retain both original pixel assertions. Per the task instruction, I have not edited tools/mkfixture.ps1 and have not created fixture-retarget.json. Only the HTML CEO can apply and validate the check correction via fixq. Required completion evidence remains 18.34 passing in a current full run.
LOCAL: no linked review.

--- codex run 2026-11-05 13:40 ---
2026-11-05 continuation: current v37.48 fixture still contains the unchanged 18.34 empty-kit deployment. Read the previous findings and existing exact correction; no further source investigation or game change is needed from this lane. No browser or full-run pass is claimed.
Coordinator/HTML CEO action: apply check-18.34-change.txt from this task output folder to check 18.34 only, through fixq, then run 18.34 alone and in the current full corpus. The correction explicitly stages an owned selected pistol on default class keys and retains both pixel assertions. Historical live diagnostics remain uncollected; the source probe is only evidence that inherited guns can explain the failure across all three versions.
No tools/mkfixture.ps1 edit, ship key, camera request or fixture-retarget.json was made. Remaining work requires the HTML CEO and browser/full-run runner. LOCAL: no linked review.

--- codex run 2026-11-05 13:41 ---
2026-11-05 continuation: refreshed master still has the original empty-kit 18.34 check; no browser or full-run validation result was supplied. Added check-18.34-replacement.txt, the COMPLETE replacement object for check 18.34 only (add its trailing comma when placing it in __REGRESS). This packages the previously documented correction without changing tools/mkfixture.ps1. check-18.34-syntax.js wraps the same object for node --check; syntax check passed. Both original alpha reads and pixel assertions remain unchanged. No runtime pass is claimed.
HTML CEO: apply the complete replacement through fixq and validate 18.34 alone and in a current full run. No fixture-retarget.json or ship key is permitted for this test-only handoff. The lane has completed its allowed investigation and correction preparation; further completion requires the fixture owner and browser runner. LOCAL: no linked review.

--- codex run 2026-11-05 13:42 ---
2026-11-05 continuation: verified current check 18.34 still deploys kit:[] without resetting inherited guns. Existing complete correction in check-18.34-replacement.txt stages a selected owned pistol on default class keys and retains both pixel assertions. No new game change is justified by the existing evidence. Per task instructions, stopped at the test-only finding; tools/mkfixture.ps1 was not edited. No live or full-run pass is claimed. Remaining work belongs to the HTML CEO/browser runner: apply the prepared replacement via fixq, collect historical live diagnostics if available, and verify 18.34 alone and in a current full run. LOCAL: no linked review.


--- codex run 2026-11-05 14:16 ---
2026-11-05 continuation: current check 18.34 remains unchanged. Reviewed the existing complete replacement and exact edit instructions; no new game change or further source probe is needed. The proposed correction stages an owned, selected pistol with default class keys and preserves both original pixel assertions. Browser reproduction and a current full-run pass remain unverified.
Per the task instruction to stop at a check-only finding, tools/mkfixture.ps1 was not edited. HTML CEO action: apply check-18.34-replacement.txt through fixq, then validate 18.34 alone and in a current full run. Existing historical diagnostics request remains in prior notes. LOCAL: no linked review.


--- codex run 2026-11-05 14:21 ---
2026-11-05: confirmed the current fixture still has the original 18.34 empty-kit setup at line 78931. Existing complete replacement remains ready in check-18.34-replacement.txt. Added an explicit coordinator handoff to route the test correction to the HTML CEO; further Codex reruns cannot apply or validate it under this task permission. No fixture or game edits and no runtime pass claimed. Remaining finish line: apply via fixq and record 18.34 passing in a current full run. LOCAL: no linked review.


--- codex run 2026-11-07 09:53 ---
2026-11-07 requeue: read prior findings and correction files. Current v37.48 check 18.34 at tools/mkfixture.ps1:78931 still deploys kit:[] without staging its gun or class-key layout. The same check-only blocker stands; no game change is justified by the existing evidence.
Exact complete replacement remains in .codex-work/o-264-belt-key-1-vacant-18-34/check-18.34-replacement.txt; individual edits are in check-18.34-change.txt. It explicitly stages an owned selected pistol on key 1 and retains both original pixel assertions.
Per this task instruction, tools/mkfixture.ps1 was not edited. HTML CEO must apply the prepared correction through fixq and verify 18.34 alone and in a current full run. Historical browser diagnostics remain uncollected. No runtime pass or shipped fix is claimed. LOCAL: no linked review.
