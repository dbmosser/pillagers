
--- codex run 2026-10-19 18:54 ---
2026-10-19, o-07-pad-lost, first draft from v31.89.

Read J8 and the pad paths. No earlier task notes were present. The old path paused only on gamepaddisconnected and showed a reconnect promise without any A recovery. pollPad silently released input on a gap; netPadFor/netPadStick could forget a lost reservation.

Prepared cw-cx-padlost. pollPad tracks the slot used in the current raid and releases held input when that slot is null or connected:false. The existing pause box title says pad lost, then press a on the same slot returning. Physical A closes the box, resumes play and is recorded as spent. The event remains a fast path. A different pad cannot confirm recovery. No seeded random calls or feel values changed.

Same-machine reservations now survive a gap, on direct and forwarded input. A focused window sends an empty pad sample immediately when the covered window loses its slot, and includes both reservations and its own loss status in the existing pad message. The other window uses the existing small HUD plate for p1 pad lost or p2 pad lost and keeps its own controls running. Initial assignment remains first pad p2, second pad p1; explicit changes still clear saved reservations through netPadSet.

The new gate check exercises null and connected:false for both sides, two polling calls, held input release, slot preservation, press a, wrong-pad A rejection, physical A resume and spent press, solo ownership, both peer tag directions, empty-slot messages, and a covered receiver with no local pad exposure. Each recovery assertion includes its preceding pause/ready transitions, so the old build cannot pass by already being unpaused. No fixture retarget is needed by inspection; the event still emits the old disconnected notice without the false reconnect subtitle.

Local checks: mk prints written against the workspace game; all 10 anchors match exactly once; applying all edits in memory leaves the full inline game script syntactically valid. The new regression check and all six camera scripts/predicates parse. The mk script is ASCII. Runtime checks cannot run in this sandbox.

camera-recipes.json asks for six pictures: p1 lost, p2 seeing p1 lost, p2 lost, p1 seeing p2 lost, and press a in both windows. Each recipe runs TWO live game windows with two stub pads and the real pad serialization/receive code. It photographs one side and asserts the partner state too. The popup closes on camera navigation or after 20 seconds. These are controlled stub-pad pictures, not a physical cable test. The normal existing pause box and HUD plate are reused.

Lane work remaining: preflight, old-build negative control, ship, regression results, two-window camera results and critic. Follow up on any gate failure or P0/P1 finding. Expected finish line is 4 for the raid and pause pictures. keys.txt lists the ready draft; the game file was not edited.


--- codex run 2026-10-19 18:59 ---
2026-10-19, run 2 from v31.90.

Confirmed cw-cx-padlost shipped as 42137018. tools/handoff/cm3190.txt says Check 31.90 fails on v31.89; a3190.txt records that 31.90 passes and fails on v31.89. No new game change or fixture retarget is needed. Keep the shipped key in keys.txt so the lane skips it.

No o-07 picture, camera report or critic result exists in the shared notes. The installed tools/codex-lane.sh only reads shots.txt and calls the camera after SHIPPED_NOW. It has no camera-recipes support. This runner mismatch was already logged for the earlier camera/controls jobs, so no duplicate owner question was added. Do not spend another game ship merely to trigger the camera.

Replaced camera-recipes.json with six stronger scenes using actual linked CAREER windows, real party entry and BroadcastChannel pad messages. The old recipe independently deployed both windows and bridged messages directly; that was weaker than proving the shared raid. prepare-pair-camera.js is now the recipe generator, superseding make-camera.ps1. stage-pad-lost-pair.js is the generated standalone helper for review.

Each new scene first checks BOTH pad-loss directions, with null and connected:false. The affected window exposes no local pads, so the real other-window forwarding must deliver the loss and returning A. It checks the loss box within two polls after delivery, the partner tag, partner controls and advancing raid clock, preserved pad order, press a, wrong-pad A rejection, and actual resume with A spent. It then stages its assigned picture. Both real pillagers must be visible. These remain synthetic pad tests, not physical cable observations. All scripts and predicates parse; they have not run in Chrome.

Added camera-run-request.json with the exact authorized tools/uishots.ps1 command, port 9364, report/picture paths, and required critic score 4. Only the lane/coordinator can run it outside this sandbox. Return report.json, all six pictures and full critic findings. No code remains to ship; completion still needs this two-window visual proof and any resulting fixes. Park until that lane step supplies results instead of rerunning Codex on unchanged files.

