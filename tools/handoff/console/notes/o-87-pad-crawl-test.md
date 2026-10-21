
--- codex run 2026-10-21 00:42 ---
2026-10-21, o-87-pad-crawl-test, first Codex run on v33.36.

Prepared fixture-retarget.json to add check 87.01, the J3 hub crawl. It covers title, saves, the delete confirmation, floor, stash, sector, shop, craft, hire, terms, all four mainframe tabs, bar, gambler, fashion, settings, controller settings, pause, outcome and floor backpack. It stubs navigator.getGamepads and counts keydown/keyup events; any keyboard event fails. Station panels are opened through the real pad-to-station input path. D-pad paths to tested controls are discovered and replayed with pad taps, without assigning the target focus or clicking it directly. Each panel tests one focused A action and its B exit. Sector A changes day to night. The title name picker, save rename, outcome feedback toggle and backpack pickup have state assertions. Other panels use A on their close control. The check does not audit the raid HUD; a raid is created and ended only to stage its real outcome card.

The pinned gap list in check 87.01 is:
- stash:field:stashsearch -- optional keyboard search, excluded from pad focus by the shipped J4 work.
- saves-delete:field:delword -- destructive confirmation deliberately stays keyboard only under J4.
- saves-delete:back -- actual bug: title padMenu consumes B before it can run KEEP. Prepared cw-cx-saveback to fix it now.
- pause:field:pausefb -- optional typed feedback, excluded from pad focus by J4.
- mainframe-racks:field:mfghostname -- optional friend name, excluded from pad focus by J4.
- outcome-feedback:field:oc_note -- optional typed feedback, excluded from pad focus by J4.

The field scan also fails on any unsupported field admitted to pad focus, even if that field has a pinned keyboard-only exception. The remove-one-debt control removes the real observed stash-search exception and requires the same gap filter to reject it. This tests a real missing pad text route, rather than an invented failure. These keyboard-only exceptions follow best-practices J4 lines 147-150; do not replace the destructive typed-word safeguards with pad confirmation.

Prepared mk-cw-cx-saveback.ps1 and keys.txt. B on an open title delete confirmation runs the existing KEEP action. Its ship check requires KEEP exactly once, no ERASE action, the confirmation hidden, the title retained, and zero keyboard events. Watch on the next play: open delete on a spare save and press B; it should cancel immediately and keep both saves.

Local validation passed: the mk printed written, its game anchor occurs exactly once, its output draft contains the intended single edit, the patched game JavaScript parses with node --check, both fixture checks parse, the fixture insertion anchor occurs exactly once, and mk/retarget output is ASCII. No tracked game or fixture file was edited. Browser checks and shipping cannot run in this sandbox.

Next run after the lane: inspect the 87.01 result and any newly reported gaps; fix those rather than adding unverified debt. Once cw-cx-saveback ships, remove saves-delete:back from the pinned list in a NEW fixture retarget so the fixed bug cannot regress silently. The first retarget must accept this old gap because the lane runs it before shipping the fix. Retain the real stash-search exception as the negative control. Check 87.01 saves its observed coverage, gaps and control rejection in window.__padCrawl87 for diagnosis. The editable check source is .codex-work/o-87-pad-crawl-test/crawl-check.js. Verify the final check passes on HEAD and the title picture meets its critic finish line before marking done.


--- codex run 2026-10-21 00:44 ---
2026-10-21, o-87-pad-crawl-test, second run on refreshed v33.38.

The lane reported that the trial fixture failed only at outcome top/focus/fbhead. The game deliberately returns to the floor without an outcome card on an immediate abandon with no distance, searches or shots (endRaid, current lines 33600-33607). My staging used exactly that instant-abandon path. Corrected the crawl to use the real death outcome, as existing fixture check 9.40 does. Death always counts as a run even at zero elapsed time. Added an explicit outcome-card staging assertion so a future staging failure reports its actual cause.

Regenerated fixture-retarget.json from the corrected crawl source against the current unique 31.98 anchor. The known-debt list and all pad assertions are unchanged; no new gap was allowed. Local JavaScript syntax, ASCII, fixture-anchor and saveback-draft validations passed. cw-cx-saveback still waits on the lane running the corrected fixture and shipping its existing key. After it ships, the saves-delete:back exception still needs a new fixture retarget removing it, as recorded in the first-run notes.

