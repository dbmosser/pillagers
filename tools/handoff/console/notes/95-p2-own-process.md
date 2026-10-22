
--- codex run 2026-10-22 09:45 ---
2026-10-22, run 1: 85a is complete (console/done/85a-itch-couch-link.md; final notes say no lane work remains). No game edits or ship keys: step 1 has no go decision yet.

Prepared camera-recipes.json for the lane's automatic before measurement: unchanged coord-07 c-stage, 3 simultaneous unthrottled host/guest samples, 3 host 2000 ms stalls with guest 10 ms gap measurements. Full numbers will be in the camera report screen note. This is a measurement, not a UI redesign or acceptance score.

Prepared measure95.mjs and c-stage-split.js for the coordinator/lane to run outside the sandbox on dedicated camera port 9364. They collect 3 shared/split repeats at nominal 1x/4x, matching guest targets through CDP, opener state, paired samples and PID evidence using renderer CPU deltas. Raw files and summary are written beside the scripts. Split staging uses a measurement-only dummy handle around the current null-return branch; it does not validate the future production handshake. Detailed instructions: .codex-work/95-p2-own-process/measurement-handoff.md.

node --check passed for the runner, split staging, and generated camera recipe body. Browser execution, PID evidence and go/stop numbers are not yet available. The sandbox forbids network/localhost and browser startup; the lane's supported recipe runner cannot itself attach through CDP. A coordinator run of measure95.mjs is needed for the split/PID/throttled half before implementation.

Important limit: direct guest fake pad matches coord-07's baseline, but is not forwarded-pad acceptance. Player 2 controls forwarded from player 1 still freeze during a player 1 hitch after a renderer split. The production switch must default OFF; before shipping, retain a pre95 party fallback tag, resolve party.cfg URL_OPTIONS=1, and keep 95 out of the prepared party copy until his two-TV rehearsal.


--- codex run 2026-10-22 09:50 ---
2026-10-22, run 2: Found and fixed the round-1 camera setup error. My recipe query was netslot=A, but uishots.ps1 appends query directly to its base URL (line 211), producing /fixture.htmlnetslot=A and a missing page. Changed it to ?netslot=A. Offline URL validation now confirms /fixture.html?netslot=A. This was a recipe error, not evidence of a game boot failure. The changed recipe is ready for the lane's second round.

The real tools/fixture.html exists (14,324,221 bytes), has both camera readiness helpers, and its inline JavaScript compiles with node vm.Script. check-fixture.mjs performed that offline inspection without executing browser code or printing the file. node --check also passes for the regenerated recipe body, measure95.mjs and c-stage-split.js.

Still no step-1 numbers or go decision; no game changes and keys.txt stays empty. The corrected recipe supplies the shared unthrottled baseline only. The existing coordinator handoff for the CDP shared/split/PID/throttled run remains required before implementation. No browser or localhost access was attempted here.


--- codex run 2026-10-22 09:55 ---
2026-10-22, run 3: Diagnosed the round-2 'both real windows did not link' as a second error in my camera harness. The generated pair used c95before plus an 8-character base36 timestamp: 17 characters. The actual game netPairOf parser accepts 4 through 16 and rejects that pair, so the guest could not join that host. Replaced the prefix with c95b (12 total). The offline recipe builder invokes the actual parser copied from current dark_raiders.html and proves the old form is rejected and the new one accepted. It also validates the exact camera URL and compiles the complete async recipe body. Coord-07's original c-stage function and sampler remain unchanged.

Round 3 recipe now validates pair parsing before opening. It wraps the entire stage/sample sequence in finally so failures close its own guest, and saves both windows' URL, role, pair, channel, roster, status, error, arcade and profile state if any future stage fails. This avoids another uninformative link timeout. build-camera.mjs and baseline-run.js are offline assembly source files beside the recipe; node compile checks pass.

Viewed the attached round-2 image: it is a how-to-play card over the title attract scene, not a linked pair or a completed performance run. The critic's 3 and its how-to-play P1 findings do not assess 95 and do not warrant unrelated card styling in this task. There are still no measured performance numbers and no go decision. No game changes or keys are queued. The existing separate coordinator CDP handoff remains necessary for split/PID/throttle measurements.


--- codex run 2026-10-22 10:01 ---
2026-10-22, run 4: Baseline recipe round 3 PASSED staging on v34.16. Both rosters 2, both profiles loaded, all six 20 s frame samples kept the raid alive. P1 p95 frame gaps across repeats: 33.1 / 32.4 / 32.9 ms (median 32.9). P2: 35.0 / 33.4 / 33.6 ms (median 33.6). P2 largest 10 ms timer gaps during host 2000 ms stalls: 2019.0 / 2010.1 / 2011.8 ms (median 2011.8, worst 2019.0). This confirms the current shared pair stalls together. The approximately 31.2 ms median frame gap is consistent with coord-07's headless cap, not a TV measurement.

Saved the entire camera numeric result to .codex-work/95-p2-own-process/measurements/raw-camera-shared-t1.json and wrote the table, method and limits in coord-07-95-before.md beside the scripts, ready for the coordinator to copy beside coord-07's numbers and into notes/95. MessageChannel p95 is a queue-delay proxy, not exact CPU work. Roster pid fields are game player IDs, not renderer IDs. Viewed the attached after-cleanup scoreboard picture; its critic 2/P1 findings do not assess 95 and no unrelated UI edits are queued.

Added run-measure95.ps1 as a one-command coordinator test launcher: refuses occupied 9364, checks 6 GiB free and test fixture 8808, starts only its own hidden lane-o Chrome with popups, invokes the existing shared/split CDP driver, and closes only its own browser through tools/cdp.ps1 after matching its unique debug URL. It has no autoplay-policy override, starts no server and does not delete profiles or write the game. Driver now checks 6 GiB free before each pair. PowerShell parser and node --check passed offline. No browser/network command was executed from the sandbox.

No split/PID/throttled measurements or go decision yet. The unchanged successful baseline recipe need not be rerun; keep the remaining camera round for acceptance after a go. No ship keys or game changes are queued. Remaining measurement requires coordinator/lane execution of the launcher, followed by a go/stop decision before the production implementation. The existing switch-off-by-default, pre95 fallback-tag, party.cfg and two-TV rehearsal requirements remain.


--- codex run 2026-10-22 10:02 ---
2026-10-22, run 5: Checked the refreshed task notes and measurement folders. No coordinator split/PID/throttled raw files, summary or go decision have arrived; only the completed shared baseline is present. The task still requires the step-1 measurement before implementation, so no game patch or ship key was prepared. The coordinator test launcher and full baseline handoff from run 4 remain ready. Do not rerun the successful baseline or consume the final camera round on it. Resume implementation only after the coordinator runs run-measure95.ps1 outside this sandbox and supplies the unthrottled split/PID/stall results and go decision. No further independent measurement work can run through the lane's camera-recipe interface.
