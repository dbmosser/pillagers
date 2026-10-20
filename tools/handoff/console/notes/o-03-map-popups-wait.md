
--- codex run 2026-10-19 11:30 ---
2026-10-19, first Codex run, source v31.83.

Prepared one ship: cw-cx-mapwait. Its 20 edits cover all three requested fixes. The game file and fixture were not edited.

Notices enter a raid-owned queue while the sector map is open. This catches say(), sayWhenFree(), the corner feed through feedAdd() (including the current feed-only codex notice), and the page toast. They replay in arrival order after closing, with a full existing display period between entries. The queue has no size limit or stale-entry pruning. Existing message/feed timers stop behind the map; existing page toasts retain their remaining time. Existing message expiry/protection stamps also exclude time spent behind the ordinary M map. MAPFIRST still controls the raid-start clock; no world timing, random draw, generation code or game-feel value changes.

Removed the second message-lane draw after the map. Page toasts are hidden with the corner column while the map card is up. Each cache and strongbox now keeps its own label and exact icon anchor. Tags use separate placement rows with 4 scaled pixels of extra vertical space; a displaced tag gets a thin connector to its own icon. They no longer enter the old duplicate-cache suppressor or the overlapping important-label fallback. Player markers and teammate map markers use SEATCOL: solo/P1 #ffb02e and P2 #38d6ff.

Validation completed here: mk script prints written; all 20 anchors match exactly once and the draft applies cleanly in a private dry copy; the resulting inline JavaScript and new regression check parse; a pure-function crowded-room placement exercise retains every tag without overlaps. All handoff files are ASCII. Browser check, fingerprint, shipping and critic cannot run in this sandbox.

New regression check stages a codex notice with the map open BEFORE checking for the new helpers, so the old build fails on the actual over-map codex draw. It then checks 20 seconds of holding, arrival order and full lifetimes for codex/weather/page notices, preserved existing timers, MAPFIRST, actual marker painting for both seats, and separate non-overlapping cache/strongbox labels at 1080 and 4K. It restores globals and ends the raid in finally.

BEFORE PREFLIGHT: questions-new.md identifies fixture checks 31.41 and 22.87 that still demand behavior this task explicitly replaces. A Claude lane must retarget them with the lock. Do not weaken the new check or restore the obsolete colors/overlay behavior to satisfy those checks.

Required pictures: run screen 22 from shots.txt at BOTH -Res 1080,4k on lane camera port 9364, before and after the ship. Suggested folders: tools/handoff/console/notes/shots/o-03-map-popups-wait-before and tools/handoff/console/notes/shots/o-03-map-popups-wait-after. Run the critic on the map, old first, once these are available. The existing earlier reference inspected here was cw-mapstyle-after3/63-map-open-m-1080.jpg; do not count a self-grade as critic approval.

Also use the EXISTING tools/handoff/console/notes/shots/cw-mapstyle-recipes.json with -Recipes to photograph 60-mapfirst-1p and 66-map-open-p2 at 1080 and 4K (no new screen registration needed). The requested seat-color change needs evidence in both player windows; if those recipes stage a simulated peer rather than two real linked windows, the lane must supply a real linked-window map picture from each seat as well. Keep the same lane port. Return photo paths, critic result, gate result and fingerprint result for the next Codex run.

Pending: fixture retarget, lane preflight/ship, required pictures, and critic acceptance. Do not mark this task complete yet.


--- codex run 2026-10-19 11:32 ---
2026-10-19, retry after cw-cx-mapwait preflight failed twice on the new check.

Fixed two check defects; the 20 production edits are unchanged.

The codex text assertion expected one space after the middle-dot separator. feedSay actually assembles two. The assertion now compares lowercase text with whitespace normalized, preserving the complete headline and gun name. If it fails again it reports the actual feed texts.

The cache-label recorder called fn.call even though drawMapOverlay deliberately supplies null when the canvas has no own fillText override. That exception occurred on the first header label, was caught by the map renderer, and caused the test to record zero loot labels while the map fell back to drawing. The recorder now follows the same fallback as the production placer: fn or CanvasRenderingContext2D.prototype.fillText. It still counts every individual cache/strongbox label and rejects overlapping loot-label boxes at both resolutions.

Local validation passes: script prints written, 20 anchors apply exactly once, game JavaScript and check parse, crowded-room placement retains all labels without overlap, the actual corrected recorder captures all three synthetic loot tags with a null renderer, and the codex assertion matches text assembled by the real feedSay/feedAdd functions. This is local validation, not a browser gate pass.

keys.txt still lists cw-cx-mapwait. Retry the lane preflight. The previously recorded fixture-retarget request for 31.41/22.87 remains applicable; no duplicate question added. Shipping, fingerprint verification, before/after 1080p and 4K map pictures, both-seat evidence, and critic review still await the lane. No new visible change this retry, so changes-new.md remains empty.


--- codex run 2026-10-19 11:39 ---
2026-10-19, retry after the new check passed but older checks 31.55 and 31.41 failed.

Changed the packed cache/strongbox placement in the same cw-cx-mapwait draft. It now tries labels directly beside the icon, directly above/below it, and beside the bounds of nearby icons with 6 scaled px clearance. Side rows use the existing label height plus 4 scaled px. Candidate positions are ranked by distance to the nearby marker group, then by movement, instead of accepting the first distant vertical row. The exact own-icon anchor and connector remain, so adjacent caches can still be distinguished. No marker moves, world timing changes, or seeded draws were added. The draft still has 20 edits.

Local validation passes: all anchors apply once, JavaScript/check parse, all labels survive the synthetic packed-room case without overlap. With actual icon obstacles included, the three synthetic loot tags have gaps of 5.0, 6.0 and 23.6 px from the marker group, with only one needing a distant row. Distances from each own icon are 5.0, 26.0 and 23.6 px; displaced tags retain connectors to their own icons. The previous null-renderer recorder and real-feed text checks still pass. This does not establish that the real seeded 31.55 check passes; rerun it on the candidate.

ACTION REQUIRED BEFORE ANOTHER FULL PREFLIGHT: the latest failure confirms the already reported fixture-maintenance blocker in check 31.41, section SEVEN. It requires UIC.ally for the actual P2 marker, while his binding 3.13 a and this task require SEATCOL[1] cyan. A correct production change cannot satisfy that obsolete expectation. Route the existing retarget request in the task notes/questions to a Claude lane holding the fixture lock. Retarget the solo/P1 fill assertions to SEATCOL[0] and P2 to SEATCOL[1], preserving number badges and the neon-green rejection. The new check already verifies actual marker painting in both seat colors. Do not restore blue, recolor unrelated UI to trick this check, or put an invisible blue shape on the map. No duplicate owner question added.

Do not relax the 31.55 three-distant-tags allowance merely to ship. The revised adjacent candidates aim to satisfy it while retaining every loot label. If it still fails, return the actual distant tag names/positions and icon boxes so placement can be fixed using measured geometry.

The new hold/replay check passed twice in the previous lane run. keys.txt still contains cw-cx-mapwait. Fingerprint, shipping, before/after map pictures at 1080p and 4K, both-seat evidence and critic review remain pending. The earlier 22.87 fixture-retarget request also still applies when that older check is exercised.


--- codex run 2026-10-19 11:45 ---
2026-10-19, retry after 31.55 improved from six to four distant tags and 31.41 still required the obsolete P2 blue.

Improved the same cw-cx-mapwait draft again. The old row-sized jumps could skip a usable position only a few pixels away. Cache/strongbox placement now also considers exact positions beside the bounds of nearby labels and icons, and against the map frame. New label-edge candidates leave 4 scaled px vertically and at least 8 scaled px horizontally; icon clearance candidates use 6 scaled px. It ranks the candidates once before sorting, so scoring is not repeated inside the sort comparator. No labels or icons are deleted or moved in world space. Exact own-icon connectors remain.

Local crowded-room exercise now retains all labels without overlap and puts all three loot labels within 12 px of their OWN icons: gaps 0.4, 9.0 and 5.0 px. The prior pass had one 23.6 px own-icon gap in this same exercise. Anchor checks still pass for all 20 edits, and game/check JavaScript parses. The null-renderer recorder exercise and real-feed codex text exercise also pass. These are local results; the actual seed-4242 browser result is still pending.

The new regression check now stages the same nine contracts and hot-ground setup as 31.55 before checking label layout at both resolutions. It retains the three-distant-marker limit and now reports the actual distant tag texts, screen boxes, gaps and nearest icon boxes if the limit is exceeded. This makes another geometry failure actionable. It still begins by staging the codex popup over the map and covers notice retention/order/lifetime, MAPFIRST and painted seat colors.

31.41 remains a fixture-maintenance blocker independent of label layout. Investigation confirmed that UIC.ally is a generic teammate color and is also set by colorblind palettes. Changing it just to satisfy the old map test would affect other displays. The correct map identity is still SEATCOL amber/cyan; the old check must compare its actual marker fills with those values. questions-new.md supplements the earlier request with the exact three replacement assertions for a lock-owning Claude lane. It asks for no new owner decision.

keys.txt remains cw-cx-mapwait. Before another full preflight, route that fixture maintenance to a lane that can hold the lock; this sandbox cannot edit tools/mkfixture.ps1 or take the lock. The pending older 22.87 over-map-callout test was already reported and also needs retargeting when exercised. Shipping, seed fingerprint, 1080p/4K pictures, both-seat evidence and critic review remain pending.


--- codex run 2026-10-19 11:48 ---
2026-10-19, latest preflight: the new check and 31.55 pass. The only remaining newest-80 failure is the already reported obsolete P2 color expectation in fixture check 31.41.

No production changes are needed for this failure. cw-cx-mapwait correctly paints SEATCOL[1] cyan; 31.41 still expects UIC.ally blue. Reverting that behavior would violate his 3.13 a and task item 3.

Prepared an exact unified fixture patch at C:/claudecode/pillagers-codex/.codex-work/o-03-map-popups-wait/fixture-31.41-seat-colors.patch. It matches the current fixture block at lines 7356-7369 and changes exactly four lines: the section comment and the solo/P1/P2 fill-color assertions. It preserves player-number badges, the neon-green rejection, and every other assertion in 31.41. A lock-owning Claude lane must apply/test/commit it through fixture maintenance. The Codex addendum forbids this sandbox from making that fixture edit or taking the lock.

Do not repeat an unchanged full preflight before applying the fixture correction. The mk script cannot responsibly fix an obsolete assertion in a separate locked file. Its 20 production edits and regression check remain ready in keys.txt as cw-cx-mapwait. Local anchors, syntax, placement, recorder and feed-format validation still pass; no tracked files were edited.

After fixture maintenance, rerun preflight and ship the same key, then verify the seed fingerprint and complete the requested 1080p/4K photos, both-seat evidence, and critic review. The previously reported 22.87 fixture expectation also needs updating when the older corpus exercises it; it is outside this newest-80 failure.


--- codex run 2026-10-19 19:55 ---
2026-10-19, continued with the updated Codex addendum, which now lets the lane apply fixture-retarget.json under its lock. The earlier request for a separate Claude lane is superseded by this supported handoff.

Prepared fixture-retarget.json for cw-cx-mapwait with five exact anchors and checks 31.41 and 22.87. Check 31.41 accepts the old accent/ally marker colours before shipping or the seat colours after shipping; number badges and rejection of neon green remain. The new ship check still requires actual amber/cyan painting, so the old compatibility assertion does not weaken the requested result. Check 22.87 retains the shared control that info and alert notices draw with the map shut. Its obsolete demand for notices over the open map is replaced by the new ship check, which stages a codex popup on the old build and verifies holding, replay order and full lifetimes on the new build. Both retargeted checks are intended to pass before the key ships.

Local validation: all five fixture anchors occur once; the replacement 22.87 check parses. The unchanged mk script prints written, all 20 production anchors apply once, and game/check JavaScript parses. The synthetic crowded room retains every label without overlap, with own-icon gaps 0.4, 9.0 and 5.0 px. Recorder and actual-feed formatting exercises pass. All lane handoff files checked are ASCII. No tracked files were edited. No new visible change this run.

Lane next steps: apply the retarget under the lock and run 31.41/22.87 BEFORE preflight. Then preflight and ship the existing cw-cx-mapwait key. Do not count local exercises as browser passes. Return ship/check results and the seed-4242 fingerprint.

Picture gap confirmed on disk: o-03-map-popups-wait-before contains only 22-raid-map-open-1080.jpg. Before shipping, capture screen 22 at 4K as well. After shipping, capture screen 22 at BOTH 1080p and 4K, then run the critic once with the matching before picture first. shots.txt remains 22. The camera default supports both resolutions; do not restrict it to 1080 for this task. No custom recipe file was added because that would suppress the normal before/after screen capture.

Both-window evidence remains required. The existing cw-mapstyle-recipes.json recipe 66-map-open-p2 only overrides seatHere and is NOT a real linked player-2 window. Use the lane test scripts to capture a real linked map from each seat if available; do not label the simulated recipe as two-window verification. The existing recipes can still supply supplementary close inspection of marker colours.

Pending lane work: fixture checks, preflight/ship, fingerprint, missing before-4K picture, after pictures, both-window evidence and critic acceptance. No owner decision is needed for fixture maintenance.

--- codex run 2026-10-19 22:53 ---
2026-10-19, resumed after coordinator re-queue. Confirmed fixture-maintenance commit 863ad9c8 is in the current worktree history. The coordinator reports checks 31.41 and 22.87 pass; no further fixture changes are requested.

The existing cw-cx-mapwait production patch and regression check are unchanged. Regenerated its draft against this refreshed worktree: script prints written, all 20 anchors apply exactly once, game JavaScript and check parse. The local crowded-room exercise retains every label without overlap (own-icon gaps 0.4, 9.0 and 5.0 px), the null-renderer recorder captures all three loot labels, and the codex assertion matches actual feed formatting. These are local checks, not browser preflight results.

keys.txt still contains cw-cx-mapwait and shots.txt still contains 22. Lane next action: preflight and ship that key, return the gate and fingerprint results, then photograph the map and run the critic. Do not reapply already committed fixture edits. No new production or visible changes this run.

Remaining coordinator work from the re-queue: both-window map evidence and the missing 4K before picture. Existing recipe 66-map-open-p2 simulates a seat and does not prove two linked windows. Keep the requested after shots at 1080p and 4K and return the critic result. This sandbox cannot run Chrome, preflight or shipping.

--- codex run 2026-10-19 22:54 ---
2026-10-19, renamed the colliding ship key cw-cx-mapwait to cw-cx-sectorhold-o03 at the lane request. keys.txt, the mk filename, its code comments/check references, its output draft filename and the local validator now use the new key. Removed the old mk/draft filenames by renaming them. The already-applied fixture-retarget request now lists the new dependent key; its edit contents remain unchanged so their applied hashes remain valid. Fixture maintenance was already committed as 863ad9c8; no repeat maintenance is needed.

Regenerated draft-cw-cx-sectorhold-o03.json against refreshed v32.06: written; all 20 anchors apply exactly once; game JavaScript and regression check parse. Local crowded-room exercise retains all labels without overlap and within 12 px of their own icons. Null-renderer recorder and actual-feed text checks also pass. Production behavior is unchanged from the prior patch; these local results do not establish browser preflight or shipping success.

Lane next action: preflight and ship cw-cx-sectorhold-o03, then return the gate result and fingerprint. shots.txt remains screen 22 for the requested map pictures and critic. Outstanding coordinator picture work from the re-queue (both real player windows and 4K before evidence) still applies. No new visible change this run.

--- codex run 2026-10-20 00:37 ---
2026-10-20, fixed preflight REGRESS 32.25 in cw-cx-sectorhold-o03 against refreshed v32.25.

The older check is correct and unchanged. The patch removes the open-map _lanes call, which also means feedDraw no longer runs its normal FEEDBOX reset. Previous closed-map rows therefore remained in FEEDBOX even though no feed pixels were drawn. The open-map branch now clears FEEDBOX.on and FEEDBOX.rows before drawing the map. Actual feed entries and their clock are untouched, so notices still retain their content and lifetime.

Added a closed/open/closed draw sequence to this key's regression check. It requires feed layout with the map shut, no active layout or rows while open, and restored rows after closing. The existing codex-on-map staging and notice order/lifetime assertions remain.

Local validation: script prints written; all 20 anchors apply once; game JavaScript and regression check parse. The local exercise runs the actual map-branch replacement: the prior draft retains stale rows, while the fixed branch clears them and preserves feed entries and clock. Crowded-room, null-renderer recorder and actual-feed formatting exercises still pass. No fixture retarget is needed for 32.25. No tracked files were edited.

keys.txt still lists cw-cx-sectorhold-o03. Lane next: rerun preflight, ship, verify fingerprint, photograph screen 22 at requested resolutions, and return critic result. Coordinator's real two-window evidence and missing before-4K evidence remain outstanding. Browser gates and pictures cannot run in this sandbox.

--- codex run 2026-10-20 00:54 ---
2026-10-20, reviewed shipped v32.27 and opened the supplied 22-raid-map-open-1080.jpg. Round-one critic score is 3. The popup fix shipped as cw-cx-sectorhold-o03. Its feed/map behavior is preserved.

Prepared follow-up cw-cx-mapspace-o03 for the two label P1s and the contract-hierarchy P1. Label collision clearance grows from 1 vertical px / about 6 horizontal px to 12 scaled px on both axes. Cache/strongbox placement keeps icon obstacles on every pass, scores distance to its OWN icon rather than any nearby icon, and starts each leader at an 8px icon radius. Every individual label remains. No count merge, hidden-on-hover label or world marker move was added.

Contract names use tx-2, keeping tx-1 for the panel header. Removed row dividers because progress tracks already separate rows. The fixed status slot measures holding, broken and 99/99 once per row, so bars share both edges. Holding uses the existing ok token. Reward text uses the existing label size. Every contract remains visible. No tracking feature or main-button colour was invented. Tracks retain the style-guide ui_line_hi colour and 4px height.

The critic asks to restore lime/blue and says 3.13 is unanswered. That is stale: binding 3.13 a and this task explicitly require SEATCOL amber/cyan. Skipped that finding and recorded the conflict once in questions-new.md. Other requested presentation fixes are in the follow-up.

Fixture handoff now contains ONLY two NEW retarget edits, for 31.55 and 32.27. Their proximity allowance becomes 100 scaled px for cache/looted/strongbox tags with leaders; all other marker tags retain 12px and the maximum-three-distant-tag limit. These old proximity checks predate the requested 12px breathing room. They should pass before and after shipping. The new ship check separately verifies every individual tag, 12px clearance against every map label, distance to its own icon, an actual leader starting at that icon when displaced, and aligned contract tracks at 1080p and 4K. Existing popup lifetime/order and SEATCOL checks remain in 32.27.

Local validation: written; two production anchors apply once; game/check JavaScript parses. In a synthetic packed layout with ten loot tags and both locked-room outlines, all labels remain with 12px clearance at 1080p/4K. Greatest own-icon gap is 63.8px/61.9px respectively. The old renderer fails this clearance control. Actual contract renderer has ragged tracks before and equal widths after, with names in tx-2. Both fixture anchors occur once and retargeted checks parse. These are local exercises, not browser gate or critic passes.

Lane next: apply the two new retargets under its lock, run 31.55/32.27 before shipping, then preflight/ship cw-cx-mapspace-o03. keys.txt keeps the shipped key first so it is skipped. shots.txt remains 22. Return new critic findings and gate/fingerprint results. The supplied report still has ONLY 1080p; coordinator-owned 4K before/after and actual linked-window evidence remain pending. No tracked files were edited here.
