
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

