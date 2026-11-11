
--- codex run 2026-11-09 01:14 ---
2026-11-09 o-m04a-level-bar
Prepared cw-cx-levelbar against v37.67. Ten unique anchors; generator prints written; assembled game JavaScript and check both pass node --check. No game or fixture edits and no browser/test processes started here.

All five career SP writers already call csTally: vault, strongbox/bounty, shared machine credit, style and kills. That tally now adds living pillager SP immediately. Settlement adds only the extra extraction/condition SP, under its existing once-only settlement guard. Death keeps the earned level on the ended pillager record. No RNG calls, pickup stack, loot sounds or loot row changes.

Curve evidence: exports/run-20261107-190409-065.txt contains 37 extracted run lines. Reconstructing base kill SP from sentry/crawler/pillager/snitch counts gives median 1525, range 200 to 5925. Extraction doubles this to a 3050 baseline. Cost per next level is 1000 + 150*(level-1); level 20 needs 44650, or 14.64 median surviving raids before elite, difficulty, style and vault bonuses. 3050 earns two early levels; 3450 earns three. Bonus-heavy play can be faster; watch actual SP pace. The draft why carries these numbers into DESIGN.md.

Save fields lvl and lsp already exist, so no new migration stamp or storage key. The existing load cleaner stays unchanged so old hall and retirement records keep their saved levels. The check reloads old possessions and a partly filled pillager twice, then earned progression twice, checking credits, stash, weapons, equipped, contracts, forged guns, gear, worn, lineage and lifetime earnings.

Check also exercises career kills, style, vaults, all tally categories, multi-level overflow, cap, HUD fill/text, local head text, state-packet send/receive/relay, invalid peer levels, extraction bonus once, and demo/sim exclusion. The normal gate must still prove seed 4242 and regressions. No fixture retarget is expected.

LINKED REVIEW NEEDED: synced. New display-only pl metadata uses the existing state packet and host relay so other players see name and level; rewards remain local to each save. The lead must verify this metadata in actual linked windows.

Camera recipes stage player 1 partial progress, player 2 cap, and the existing live demo. The two career scenes are separate per-role camera stages, not evidence of a real linked session. REQUIRED: lane must photograph all three at -Res 1080,4k and run the critic. The camera recipes use __gx for internal game fields and the existing prelude. Critic target is 4 on the raid. No pictures have been reviewed yet.

After ON HIS PC, lead should add the actual version to notes/progression/log.md. The PC-protection addendum path C:/Codex/FNP new 11082026/RULES.md does not exist in this sandbox; the supplied protection rules were respected.


--- codex run 2026-11-09 01:41 ---
2026-11-09 continuation: the returned preflight log contains only spare PC occupancy waits for job preflight-cw-cx-levelbar-89897c753e98. It contains no executed-check result or code failure. Regenerated the unchanged draft against refreshed v37.67: all ten anchors remain unique; assembled game and check both pass node --check. No speculative code change made for an unavailable test machine. cw-cx-levelbar remains unshipped in keys.txt. Retry the same preflight when the spare PC is available, joining the existing job if it is still pending, as the remote-gate rules specify. Then ship and collect the required 1080p/4K critic pictures. Linked display metadata review remains required. No fixture edit or retarget.


--- codex run 2026-11-09 02:07 ---
2026-11-09 continuation, second occupancy-only return: preflight joined the same job preflight-cw-cx-levelbar-89897c753e98 and again supplied only someone-is-using-it waits. No parse, dry-check, control, lint or regression result was returned. This is an infrastructure wait, not evidence that cw-cx-levelbar or its check failed.

Read the remote-gate notes: when someone uses JTPC, Stop-Work stops tests and the existing job resumes from the start after the machine is available, with no try charged. Same-draft retries join the same pending job. The workspace has no spare-results git ref; querying the real repo git metadata is denied by the sandbox. No saved result is accessible here.

Coordinator handoff: keep the current draft and pending key unchanged. Obtain the actual job result when JTPC becomes available; avoid starting another Codex edit run solely for occupancy messages. Do not interrupt the person using JTPC, alter its idle protections, run tests on the main PC, or mark this build passed. The code is still unshipped. After an actual pass, ship, collect 1080p/4K critic pictures, and review pl display metadata in real linked windows. No new code defect or fixture change was identified this run.


--- codex run 2026-11-09 05:30 ---
2026-11-09 continuation, run 5: inspected this task's actual lane artifacts. tools/handoff/codex/log/o-m04a-level-bar-cw-cx-levelbar.preflight.txt still contains only joining preflight-cw-cx-levelbar-89897c753e98 and five spare-PC occupancy waits, last written 02:57:39. No check result, lint failure or code defect is present. tools/handoff/codex/work/o-m04a-level-bar/shipped.txt is empty; installed.txt only confirms cw-cx-levelbar was installed for the lane. Master remains v37.67. The draft, key and camera recipes remain unchanged.

No further edit is justified by this result. Coordinator: obtain an executed preflight result from the spare PC before spending another Codex repair run on this job. Retry the existing same-draft job once JTPC is available, respecting its occupancy protection. Then ship through the normal gate, obtain ON HIS PC, photograph all recipe scenes at 1080p and 4K, and return critic results. LINKED REVIEW NEEDED: synced, display-only pl state metadata. No fixture change or retarget. No build is claimed ready. All remaining validation and shipping require the lane or coordinator; this sandbox cannot execute them.
