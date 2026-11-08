
--- codex run 2026-11-08 02:38 ---
2026-11-08: Prepared cw-cx-patrolroutes against v37.57. Five exact anchors validated and the entire staged game script plus the new fixture check pass node --check. No tracked game or fixture edits.
Setup runs only in career/demo post builds, after vaults, in sideStream(seed,81). Sentries precede crawlers; camp, elite, boss, sleeping, dormant and indoor bodies are excluded. The four nearest landmark centres are tried first, projected out of buildings; missing admissible stops use freeSpot. All four legs, including the closing leg, must be 400-1200. Reject disconnected navigation paths and circuits with more than 3350 routed units including the initial approach. Initial stop is within 650; geometric circuit limit is 2600 to leave time for the required two-second pauses.
The unchanged idle timer still calls freeSpot and rnd at expiry. Patrol targets override that random target and use navSeek at 45 percent speed. Stop arrival starts a two-second stationary turn toward the next stop. A host-tick flag remembers combat/investigate interruptions and chooses the nearest route point on resumption. Existing peer early return keeps AI on the host.
The draft check enables career, seed 4242, expects exactly three eligible four-stop patrols, validates all legs, then removes other combat/noise sources while preserving the real map and navigation. From natural spawn positions it steps 120 seconds and observes all four stops in order. It also tests nearest-stop resumption and the stationary two-second wait. This check has NOT run here; Chrome is unavailable by lane design.
Watch: patrols must read as a pattern you can learn and time; watch for a patroller hugging a wall on one leg.
Camera recipe requests the existing calm raid view with career enabled and CFG.xfPix=0 for the smooth look. No marker or player text added. Pictures and critic result remain with the lane.
LINKED REVIEW NEEDED: synced. Existing netEntRow position/state packets carry the host patrol motion; confirm it in both windows. No new packet fields.
No known older fixture check needs retargeting. Still required: lane preflight, ship, ON HIS PC, camera/critic and linked review.

--- codex run 2026-11-08 04:58 ---
2026-11-08 run 2: Confirmed existing key cw-cx-patrolroutes shipped as v37.58, commit 7e2f4f639. Preflight PASS; ship check 37.58 PASS / PASS; verifySafe retains ents 85/374 and containers 165/593. Ship receipt explicitly says ON HIS PC v37.58 after 36 seconds. Do not ship the implementation again.
Camera round 1 produced no pictures at either resolution: the fixture did not load (122 seconds each). This is a load failure before staging, not a critic finding. Updated recipe description to request the remaining retry. No gameplay or fixture edits this run.
LINKED REVIEW NEEDED: synced. Existing netEntRow packets carry host patrol positions/state. Coordinator still needs to confirm motion in both actual linked windows with one picture from each. Camera/critic and this review are the only remaining work.


--- codex run 2026-11-08 05:39 ---
2026-11-08 run 3: Read the second camera report: both 1080 and 4k again failed before staging with "the fixture did not load" (122.7 s and 122.4 s). Report: tools/handoff/console/notes/shots/o-h13-178-patrol-routes-recipes-2/report.json. No pictures or critic result exist. Both allotted camera rounds have now been used; changing the recipe cannot fix a failure before staging, so no further retry was requested.
Implementation remains shipped in v37.58 (7e2f4f639), ON HIS PC, with the earlier passing regression and unchanged fingerprint. DESIGN.md contains the requested Watch line. No implementation changes or new keys this run.
Remaining work belongs to the coordinator: repair the spare camera fixture loading, obtain the smooth career raid picture and critic result, and verify patrol movement in both actual linked windows with a picture from each. LINKED REVIEW NEEDED: synced, existing netEntRow position/state packets. Keep this job parked until those external results are available; do not reship cw-cx-patrolroutes.
