
--- codex run 2026-10-21 14:54 ---
2026-10-21, run 1. Dependencies checked: 86c-pix-pillager and 81-powerups-half-size are in done; 86f-pix-machines is in failed, with its code already shipped at v33.89 and no running status for that job. Its remaining camera history is recorded in its notes. The corpus will cover the current shipped 86a-86i work, including any code added before the lane runs these recipes.

Prepared two small ships, in order:
- cw-cx-pixguard: a throwing bake returns to the existing vector body for that attempt. A cached nearby pose cannot hide the failure. Three throws put only that art kind into vector for the rest of the raid; a new raid object resets it. Pillager component bakes share one guard. Failed bakes consume the same per-frame build budget. One entry per disabled kind goes into the raid telemetry, saved run record and text recorder export. The pixel switch is untouched. The check injects failing bakes, counts actual vector fallback draws, exercises the public pillager dispatcher, proves other kinds still bake and proves a new raid retries.
- cw-cx-pixfx: whole-unit square sparks, blood and puffs; square flying debris; stepped fire and smoke sprites; pixel scorch, cracks, debris and brass stamps; pixel extraction, downed and seat-ring strokes; per-kind power-up medallions in four baked spin widths at job 81's half size, blitted on the HUD canvas. The surrounding power-up beam/glow remains live. Blast motion and lifetimes, muzzle flashes, tracers, simulation, seeded draws and saves are unchanged.

The effects check observes integer square particle calls and whole-grid stamp/ring calls, samples actual whole-scale medallion edge alpha and the real pwrDraw-to-HUD dispatch, measures the bright quarter of the rasterized standing torso against the brightest open-floor tone in all four district night ramps for all three clothes, and measures steady draw calls, readbacks, filters and cache bytes. Night ramps are not changed speculatively; a failed ratio will guide the follow-up. The cached-prop body cap excludes its existing separate ground-shadow draw; the full-raid count includes shadows.

Three lane camera recipes are ready: a real three-phase firefight strip, a night raid, and a real two-window demo proof. The firefight recipe first runs the newest 80 checks once, with fixture reset/pin doors choosing xfPix 1 for this pass only, and returns every red/skip in report.json's note. The pair recipe reuses 86c's real arcadePick/arcadeDropIn/arcadePadAtt staging, samples both windows for 60 seconds off and 60 seconds on after warm-ups, returns p50/p95, sample counts, faults and cache bytes, and photographs a native crop from each window in one proof strip. It explicitly reports failure if either window has too few frames, p95 rises more than 1 ms, cache caps are exceeded or resolution-step notes increase. All proof labels are development-only camera annotations.

Local validation: both mk scripts print written; 10 guard anchors and 9 effects anchors each match exactly once; the combined edited game script, both check objects and all three camera recipes parse in Node; all lane inputs are ASCII. No tracked game or fixture file was edited. Chrome gates, measured night ratios, critic scores and corpus results are still pending. No fixture retarget is guessed before seeing the red checks.

Watch on next play: square smoke and the blast should leave pillager silhouettes readable. If an art bake fails repeatedly, that kind should draw in vector only until the next raid. Power-up medallions should keep their half size while spinning in four pixel steps.

Remaining external work: tools/fuzz.ps1 with pixel on needs the coordinator's runner; see alarms-new.md. The sandbox cannot launch it. Shipping, corpus, two-window measurements and pictures are handed to the lane in the two keys and camera recipes; the next run should inspect their actual results before declaring the job done.


--- codex run 2026-10-21 15:04 ---
2026-10-21, run 2. cw-cx-pixguard shipped at v33.93. cw-cx-pixfx failed its first dry check with "medallions did not blit on the HUD canvas" and passed the second dry check.

The HUD probe ran before any real world frame. pwrDraw culls pickups through w2s, which reads VX/VY; render2D sets those camera coordinates. On the first run the staged raid could therefore use the preceding screen's camera and cull the pickups. The later performance warm-up rendered the raid, explaining why the repeated check passed.

Fixed only the effects check's staging and assertions. It now centers the input, clears the staged camera anchor and renders a real world frame before probing the HUD, matching the game's world-then-HUD order. The HUD probe also saves/restores its real DPRH transform. It now counts only successful pixBlit calls and requires every power-up kind to reach ctx, rather than accepting a total that repeated draws of one kind could satisfy. A failure names missing kinds, successful blit count and projected player position. The camera report's measurement includes the kinds observed. The shipped effects implementation is unchanged from the previous draft.

Local validation against refreshed v33.93: mk-cw-cx-pixfx.ps1 prints written; all nine anchors match exactly once; the revised check and drafted game script parse; lane inputs remain ASCII; tracked files are untouched. validate.js now accepts a key argument so it can validate only the unshipped effects key without trying to reapply the shipped guard. keys.txt retains both keys; the lane skips the shipped guard.

Remaining: lane retry of cw-cx-pixfx, then its camera/critic, newest-80 corpus and real two-window budget results. The coordinator's pixel-on tools/fuzz.ps1 handoff from run 1 is still outstanding. No new alarm or speculative fixture retarget is needed this run.


--- codex run 2026-10-21 15:17 ---
2026-10-21, run 3. The revised cw-cx-pixfx check now passes twice on the drafted build and twice on fixture.html. The real ship stopped at verifySafe: TIMEOUT and restored the tree to v33.93. Nothing from the effects key shipped; the guard remains shipped.

Inspected tools/gate.ps1, shipone.sh and the bounded __verify/__verifySafe code. The -Fix gate runs the new check twice, then gives __verifySafe 300 seconds. That verifier pins CFG.xfPix to 0 for each staged raid and runs the existing seeded fingerprints, live/sim parity, real looting loops, three endings and hub render. All new effects paint paths are gated by pixOn, so those raids use the existing vector paths. The result supplies no failed assertion or fingerprint, only a timeout. shipone.sh already documents an earlier verifySafe timeout caused by Windows virtual-memory exhaustion; that history does not establish the cause of this run.

No game or check change is justified by the timeout alone. Retained cw-cx-pixfx unchanged and logged the prescribed shared-gate Chrome recovery for the coordinator/runner in alarms-new.md. The Codex sandbox cannot launch or restart Chrome. A read-only RAM query was denied access to CIM, so available memory could not be measured here; no processes or settings were changed. The runner should recover only its shared gate on 9346, check the 6 GB free-memory requirement and retry this same key. No verifier timeout or assertion is weakened.

Local revalidation on refreshed v33.93: the mk script prints written; all nine effect anchors still match once; its check and drafted game script parse; lane inputs remain ASCII; git reports no tracked edits. Existing keys and all three camera recipes remain ready. After the ship, inspect actual pictures/critic scores, newest-80 pixel-on corpus reds and the two-window budget note; the coordinator's pixel-on fuzz run is also still required.

