
--- codex run 2026-10-21 02:10 ---
2026-10-21, o-91b-report-news-style, prepared on v33.55.
Started from the unshipped cw-cx-reportnewsstyle script in o-91-circle-only-text. Its style-end anchor still matches exactly once. No tracked game or fixture files were edited.
The saved critic scores of 2 under both requested names are bare-hub pictures: the news window and recorder did not open. Their hub findings are outside this CSS-only task. The previous worker corrected the recipes to click wnbtn and exportbtn and reject an unopened window; those two recipes are included here.
Prepared the single key cw-cx-reportnewsstyle. Recorder: top-aligned column, fixed 240px preview with 16px/24px text, copy as the filled 56px/20px primary button, clear as a 56px ghost, restore label/field/action spacing of 8/16/32px, readable existing restore help and confirmation. News: shared 20px body, 32px title, divided rows, muted version, existing close button positioned as a 48px header X. All words, controls, report data, copy and restore handlers are preserved. CSS visually lowercases the raw preview without changing its value.
The new check stages the recorder at 1920x1080 through the existing force-size helper and menu zoom, measures the preview and controls, verifies raw value preservation and copy fill, then opens news and compares its computed body size to the shared token. Cleanup restores fixture canvas sizing through runPrep. The old build fails on its 14px news list and unfixed recorder styles. Runtime checks and the seed 4242 fingerprint remain for the lane; no browser is available in this sandbox.
Local validation passed: generator prints written, draft anchor matches once, replacement adds CSS only, generated check and both recipes parse with node, handoff files are ASCII. Existing recorder copy regression 33.43 remains valid; no fixture retarget is needed.
Watch line: the news and report windows look tidier; copy still copies the whole report.
Remaining: lane preflight/ship, both windows at 1080p and 4k, critic scores at least 3 for both names. Please retain correct before pictures as well as after pictures; see alarms-new.md.


--- codex run 2026-10-21 02:11 ---
2026-10-21 continuation on refreshed v33.55: renamed the conflicting key to cw-cx-o91b-newsreport in keys.txt, the mk script filename and comments, and the generated draft filename. The old mk and draft filenames were moved, so this task no longer hands them to the lane. No styling or behavior changed in this continuation. The renamed generator prints written; its anchor matches exactly once against refreshed HEAD and its check parses with node. Still needs lane preflight/ship and 1080p/4k photographs with critic scores of at least 3 for both windows. Watch: the news and report windows look tidier; copy still copies the whole report.


--- codex run 2026-10-21 02:13 ---
2026-10-21 preflight repair on v33.55, same key cw-cx-o91b-newsreport.
The lane reported two repeat failures on the drafted build. Source inspection found both causes: P.menuZoom defaults to 1.3, so the original 240 CSS-pixel preview measured 312 screen pixels at 1080p; and the global * { text-transform:none !important } overrode the preview lowercase declaration.
Fixed the actual CSS, without weakening the check. The preview min/height/max are now calc(240px / 1.3), which the normal 130 percent menu scale renders as 240 screen pixels at 1080p. Text remains 16px/24px before the normal menu scaling. The scoped lowercase declaration now has !important and wins over the global reset while leaving textarea data untouched. Other controls and all words/handlers are unchanged. The check keeps its actual screen-height limit and now reports measured height, menu zoom and computed typography if another failure occurs.
Regenerated draft: written; unique anchor and CSS-only replacement validated; check JavaScript syntax passed. Browser checks and screenshots still belong to the lane. Watch: the news and report windows look tidier; copy still copies the whole report.

