
--- codex run 2026-10-20 04:49 ---
2026-10-20 - first corpus batch, starting from workspace v32.70, HEAD 98694700.

No earlier task notes were available at the named real-repo path. The latest supplied completed corpus is still corpus-1019-2343 at v32.16: 132 failures. The announced v32.66 full-run list is not in this checkout. No current full-run count is claimed.

Prepared fixture-retarget.json with 10 checks from the 24 newly failing entries, including nine replacements and one deletion. No game changes, keys, screenshots or tracked-file edits are needed for this batch. The lane should apply and run the batch on the committed game before committing it. These source-based decisions remain subject to that browser trial; this sandbox cannot run Chrome, localhost, preflight or the corpus.

DECISIONS
9.92 HARNESS - refresh the live raid pause legend after deployment; the old check read the previous screen legend. Keep both real crouch keys, toggle, autoloot and legend assertions.
9.93 HARNESS - populate the keyboard raid pause legend before reading it and match drawn key labels without case assumptions. Preserve both RMB descriptions and the measured panel containment check.
12.74 STALE - v31.83 deliberately replaced the stall refusal with the exact dollar price. Still require carried sale proceeds on the panel, a refusal, an unsold item and no spending when the stash is empty.
17.87 STALE - v32.05 cw-systoastbare deliberately removed the slow-frame detail. Require the running slowly headline, silence on smooth frames and exactly one notification per session.
18.40 STALE - v32.11 cw-stamlabel deliberately moved stamina into a taller bar with capped type. Measure the actual bar and text bounds, accept the old outside label, and check that winded replaces stamina.
22.62 STALE - v31.83 uses need $price and v31.29 removed bag capacity. Preserve the legacy refusal checks when that branch exists and verify the new refusal price, no purchase, and no deduction from either balance.
23.12 STALE - the 10-slot belt uses slotKeyCode/slotKeyName, and v31.90 replaced the reconnect promise with pad lost. Keep gun-key accuracy, short wording exclusions and the real survivor refusal.
25.66 HARNESS - the lower-case text door changed the case of measured compass and alert labels. Normalize captured words for recognition, keep every collision assertion at both resolutions and in both modes, and restore a prototype spy cleanly.
30.10 STALE - Q70 removed the entire arcade tutorial card in v30.50. Remove only its card assertions; retain the independent run-over footer spacing test.
30.12 STALE - DELETE: this check only forces the arcade tutorial card on. Q70 removed that feature in v30.50; forcing arcadeCardOn to return 1 revives a vetoed screen in the harness.

Evidence: 0092c92c v31.83 deliberately changed the stall and forge to stash-funded purchases and short dollar-price refusals. fcfeb60c v32.05 removed slow-toast detail. da95b5d6 v32.11 deliberately moved the stamina word inside its bar. 42137018 v31.90 replaced the reconnect promise with pad lost / press a. 16e9200e v30.50 removed the tutorial card under Q70. e6851fe8 v29.55 made pause a button column; keysLegendApply remains the live controls-content writer. Read the relevant sections of cw-glyphs.md, 02-raid-hud-redesign.md, o-01-stash-pays-in-raid.md and o-07-pad-lost.md. Current source still shows carried stall proceeds on the trader panel, and gunKeyLine now deliberately uses slotKeyCode/slotKeyName.

Coverage retained: 9.92 still drives both crouch keys and verifies toggle/speed/autoloot. 9.93 still checks both RMB legend descriptions and measured compact-panel containment. 12.74 still requires the actual carried-sale amount on the panel and a refusal with an empty stash; it now also requires unsold stock and unchanged stash. 17.87 still checks silence on smooth frames and one notification on slow frames. 18.40 measures real text bounds and the real stamina bar, checks full/empty fill contrast for an inside label, and tests stamina-to-winded replacement. 22.62 retains its previous conditional legacy bag-full branches and tests an exact $999 refusal plus unchanged stock and both balances. 23.12 retains its old wording exclusions and real ammunition-refusal call. 25.66 retains all collision checks at 1080p and 4K in career/demo, normalizing only captured label case and restoring the canvas prototype cleanly. 30.10 retains the independent scaled run-over footer check. Only 30.12 is deleted, because its sole feature was explicitly removed; 30.10 no longer forces that removed feature on.

Local validation: prepare-batch.js generated the JSON successfully; every full-check anchor occurs exactly once in the current fixture; every nondeleted replacement parses as JavaScript; the generator parses and rejects non-ASCII output. The lane handoff is ASCII. No check runtime pass is claimed. No game or fixture file was edited directly.

Next batch, still prioritize the other 14 new failure entries: 15.77, 16.72, 17.00, 17.27, 19.87, 26.21, 26.25, 26.51, 26.53, 27.44, 27.58, 28.94, 29.26, 30.70. Current 26.21, 26.25, 28.94 and 29.26 already contain later retargets from the stash job: run them before changing them. Do not call them fixed since without a current PASS. Current 27.58 still assumes the old flat two-column pad list, but the newer pad-layout screen has a picker, action column and diagram; consult o-05-pad-presets before retargeting it.

19.87 REAL candidate, not changed in this batch: the v31.90 polling-loss path calls padLostStart, clears PAD.on and returns early from pollPad through padLostPoll, before padBodyCls can refresh an already-open pause legend. The old test sees a pad line after unplugging. Verify on current fixture and fix the live loss path with a control-failing game check rather than making the assertion disappear. Intentional pad-lost pause and same-slot A recovery must remain. This is logged separately for the coordinator.

Remaining count: the last supplied full run had 132 failures. Ten entries have proposed repairs here, not confirmed fixes. Fourteen new entries and the other 108 entries remain for later batches; a fresh full run after the lane commit must determine the actual remaining count.

--- codex run 2026-10-20 04:51 ---
2026-10-20 - retry after anchor refusal; workspace remains v32.70 / HEAD 98694700.

Fixed the handoff packaging bug. The private fixture uses CRLF and the real-repo fixture uses LF; their contents are equal after newline normalization. The previous generator sliced each check immediately before the next LF, leaving a lone trailing CR on every anchor. The lane normalizes CRLF pairs but preserves that lone CR, so its exact matches failed. The earlier local validation against the private CRLF file missed this.

prepare-batch.js now normalizes the source to LF BEFORE slicing check boundaries. Regenerated fixture-retarget.json: all anchors and replacements contain clean LF lines, without stray CR characters. The same ten check decisions and coverage are unchanged; no checks were weakened to fix this packaging issue.

Validation: ran the actual tools/handoff/codex/retarget.mjs planner against C:/claudecode/dark raiders/tools/mkfixture.ps1. STATUS ok, all ten edits anchors=1, deletion 30.12, and the exact runtime list is 9.92 9.93 12.74 17.87 18.40 22.62 23.12 25.66 30.10. Also ran the planner against the private CRLF fixture: STATUS ok and all ten anchors=1. The generator parses every replacement as JavaScript and enforces ASCII output. These are planner/syntax passes, not browser runtime passes. No planner output fixture was written, and no tracked game or fixture file was edited.

Lane: retry the corrected fixture-retarget.json, then return its browser trial results and the fresh full-run count. The last supplied completed corpus still has 132 failures; none is claimed fixed until the lane passes and commits this batch. The previously logged 19.87 live loss-path issue remains for its separate game fix.
