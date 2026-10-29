
--- codex run 2026-10-29 07:03 ---
2026-10-29, first run, starting at v36.43.

LOCAL: no linked review. This changes only this window's status drawing. It changes no packets, shared state, combat rules, storage keys, or random draws.

Cause isolated before writing the fix: evaluated the actual drawStatusIcons, statusLive, FS and uiScale functions from v36.24, v36.25 (633d1c4e6), v36.26 (28cf4bb47), v36.27 (1283480e5), and current v36.43 with the same offline canvas mock. The first three keep 19.5px titles and 16px details in a crowded column. v36.27 adds steady hand and beast mode; the same setup now draws five panels and shrinks titles to 14.173px and details to 11.629px. Current v36.43 still does it. This isolates v36.27, rather than the reload damage change or name tag work.

Evaluated the exact existing 36.20 and 36.22 check bodies offline on current code, both in their normal empty-column setup and with all five statuses enabled. Both pass in the empty column. This agrees with the later green spare run; it does not cover the crowded-column defect. Browser reruns are not possible in the Codex sandbox; lane preflight must rerun these and the new check.

Prepared cw-cx-statuswrap. The only game edit is drawStatusIcons. Remove the crowding scale; keep at least 20px titles and 16px details before the existing resolution and UI scaling. Give each panel enough height for both lines. Measure the longest live label for column spacing. Wrap into another column when needed; if two columns cannot fit vertically, move beside the obstructing left HUD panels. Keep every active status visible. Recenter the existing glyph and dose badge inside the taller panel. No player wording changed.

New check stages stim, active reload x3 with its current +15% damage bonus, steady hand +15%, beast mode +15%, and liquor simultaneously. It checks every title and detail, all five panels, viewport bounds and panel overlap, in solo and both demo roles, at 1080p and 4K, with an empty column, a wrapping column and a column that must move beside the vitals. It restores viewport, HUD boxes, timers, profile values, input and role fields. Existing checks 36.20 and 36.22 remain unchanged.

Sandbox validation: mk script prints written; its single anchor matches exactly once. Patched game script and regression check parse. The exact new check fails on v36.27 and current v36.43 and passes on the patched source in the offline canvas harness. Existing 36.20 and 36.22 bodies pass on the patched source. Additional checks at 1888x977, 1920x1080 and 3840x2160 and UI scales 1 and 1.2 keep the floors, all panels in bounds and panels apart. Text widths in this harness are estimates; real browser checks, lint, the seed fingerprint and pictures remain the lane's gates.

Camera handoff: four recipe scenes, default 1080p and 4K: solo, solo with the full controls legend, actual linked arcade demo player 1, and actual linked arcade demo player 2. The demo setup reuses the working reload camera's handshake and normal arcade entry. All five statuses are held up only by camera staging. Both demo windows assert all ten status strings and panel bounds. Photograph both demo role scenes; this local HUD change needs no separate linked review. All recipe programs parse. Standalone recipe scenes have no BEFORE pictures under the addendum.

Watch: with five combat statuses, check the extra column clears the vitals and no status is missing. This is also in the draft why.

Pending: lane preflight, ship, ON HIS PC, camera results at both resolutions and critic review. Do not close until those results return.


--- codex run 2026-10-29 07:16 ---
2026-10-29, second run, v36.44.

cw-cx-statuswrap SHIPPED v36.44. ON HIS PC v36.44: his 8802 serves 36.44, 49 seconds after the ship. This is the lane's confirmation; Codex did not access the play port. LOCAL: no linked review.

Looked at all eight first-round pictures: the four attached 1080p pictures and all four 4K originals through the image viewer. Camera readings confirm 20px titles and 16px details after resolution scaling in solo and both actual demo windows. The full legend moves the statuses beside it without shrinking or overlapping. First-round critic scores: solo 2, full legend 2, demo P1 3, demo P2 2. These are recorded scores, not my own grades.

Found a camera mistake: the staged fifth status was liquor. Its intentional double-vision effect (buzzWarp) ghosts the whole HUD, which the critic described as blurry or overlapping text. The demo's normal initial easy-mode question was also left unanswered. The revised camera uses actual healing as the fifth status, keeps all four requested combat statuses, and answers easyAnswer(false) before staging. This changes only the test scene; no game feature is removed or bypassed. The second-round recipe still shows the ordinary HUD and the optional full legend. Status inspection suppresses its own fillText/statusPill repaint and waits for another live frame before capture. Every recipe parses.

Prepared follow-up cw-cx-statuspanels for the in-scope critic finding about ragged status rows. All panels now use the same measured width, at least 220 logical pixels, at least 48px height, and 8px gaps at UI scale 1. Longer labels can still widen the whole column. This keeps the 20px and 16px floors and existing semantic glyph colours. No words, simulation, storage or network changes. Watch: crowded statuses must clear the vitals and remain fully visible; the draft why carries this line.

The follow-up check requires the shared width and minimum dimensions in addition to the existing font floors, five visible panels, viewport bounds, no overlap, two resolutions, all three local roles and three levels of column crowding. Offline execution of the exact check fails on v36.44 and v36.27 and passes with the follow-up applied. 36.20 and 36.22 still pass offline on the patched renderer. The mk anchor is unique, the prospective game and check parse, and the additional gate/1080p/4K layouts at UI scales 1 and 1.2 pass the offline bounds and size checks. The lane still supplies the real browser gate and fingerprint.

Out-of-scope first-round critic findings about the clock/team-score/extraction cluster, easy-mode card, vitals, hotbar, player list and full controls legend are handed to the coordinator in alarms-new.md. This task remains a status type regression fix, not a redesign of the rest of the HUD. The easy-mode prompt and intoxication affected the first review and are corrected in the camera staging.

Pending: ship the new key, ON HIS PC, second camera round at 1080p and 4K, and critic results.


--- codex run 2026-10-29 07:27 ---
2026-10-29, final review, v36.45.

cw-cx-statuspanels SHIPPED v36.45. ON HIS PC v36.45: his 8802 serves 36.45, 18 seconds after the ship. Both keys in keys.txt have shipped. LOCAL: no linked review. The change is confined to drawStatusIcons; no combat, network, storage or seeded random logic changed.

Inspected all eight final pictures: the four attached 1080p pictures and all four 4K files through the image viewer. Final picture folder: tools/handoff/console/notes/shots/o-00u-238-status-type-regression-recipes-2/. Each scene shows healing, stim, active reload x3, steady hand +15% and beast mode +15% together. Both actual demo roles were photographed separately at both resolutions. The full controls column moves the stack beside it. No status title or detail is clipped or covered by another status in these pictures. The liquor double vision and initial easy-mode prompt from the first camera round are gone.

Read and summarized the final camera report. All four scenes staged at both resolutions. Every report, including both linked-role readings, has five panels, minimum title size 20px and minimum detail size 16px after resolution normalization. At the photographed 1080p size the five panels are each 220px wide; the 4K panels grow with hudRes. Solo and full-legend pictures have zero DOM lint findings at both resolutions. Both demo 1080p pictures also have zero; each demo 4K picture has one small-text finding for the unrelated keyboard indicator, not a status label. The report's actual canvas sizes are 1918x1078 and 3838x2158 inside the camera's 1920x1080 and 3840x2160 browser viewports.

Shipping audit tools/handoff/a3645.txt records that check 36.45 passes and fails on v36.44. The previous run established the crowding regression at v36.27 and retained 36.20/36.22 unchanged. The shipped font-floor and aligned-panel checks cover crowded layouts, both resolutions and solo/host/join rendering roles.

Final external critic scores are demo P1 3, demo P2 3, solo 2 and full legend 2. These are whole-HUD grades, below the general raid target of 4; do not describe them as a critic pass. The critic acknowledges the tidy shared-width rows and improvement in both demo shots. It still estimates the status glyphs as 18px/13px despite the browser measuring their Canvas font sizes as 20px/16px; the required floor refers to the latter. It also reports 4-7px gaps where the renderer uses 8px. Its suggestions vary among 200px, 220px and 240px widths and 48px or 56px heights. The final implementation uses one measured width with a 220px minimum, 48px height and 8px gaps, retains the existing HUD anchor, and keeps the requested damage and time details visible rather than moving them into a tooltip. I have not graded the screen myself.

The remaining critic findings concern a wider raid HUD restyle: player list, vitals, clock/team score/extract column, teammate plate, hotbar, ammo hint, full controls legend and margins. They remain handed off in alarms-new.md. The allowed two camera rounds are exhausted. No further status regression code is outstanding: the requested fix is shipped and ON HIS PC, five simultaneous statuses retain the specified floors, and all required solo/demo pictures at both resolutions have been inspected. Closing this regression task with the broader HUD score limitation recorded explicitly.

Watch: with five combat statuses, check that a second column clears the vitals and every status remains visible.

