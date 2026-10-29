
--- codex run 2026-10-29 02:24 ---
2026-10-29: Prepared cw-cx-hubnohint for lane preflight and shipping; not yet shipped or confirmed ON HIS PC.

Removed the shared station sub-line draw for all stations, so keyboard and pad option rows disappear together. The E station prompt stays in its existing position. Replaced the footer drawing helper with toast positioning only, preserving toast clearance without its panel, key chips or words. Input handlers, station actions, pickup stack, loot rows, loot sounds and seeded world generation are untouched.

The floor F1 help already lists WASD, E and M. Added R quick ascent, T the terms and F party there, using the existing live keyboard/pad labels. This keeps the removed lift options discoverable through requested help.

The new check records actual HUD draws at all stations and mid-room, at 1080p and 4K, with both keyboard and pad labels. It rejects the removed words and station sub-lines, requires the E prompt, verifies lift shortcuts in F1, then sets KeyR at the lift and runs the real floor input handler to require a live raid. It returns a failure before the R test on the old build because the hint rows are present.

Five fixture retarget edits preserve title/station typography and open-window coverage while removing obsolete footer requirements. They accept both old and new builds. The old footer map assertion now checks the existing M entry in floor help. The lane must run these under its lock before shipping.

Local verification passed: all four game anchors and five fixture anchors occur once; the patched game script and new regression check parse; four camera scenes and their prelude parse; all lane handoff files are ASCII. The mk prints written with workspace MK_SRC/MK_OUT_DIR. Chrome checks and the 4242 fingerprint remain for the lane.

Camera request: camera-recipes.json contains lift and mid-room scenes for keyboard and pad. Please photograph all four at BOTH default resolutions, 1080 and 4k, then run the critic and return pictures for inspection. No camera or browser was started here. The DESIGN entry receives the required watch line through draft.why: "the undercroft has no key bars". Watch on next play: the E prompt stays visible at each station and R/T/F/E/M still work.


--- codex run 2026-10-29 02:26 ---
2026-10-29 follow-up: Fixed the preflight gen-draft non-ASCII failure. The old footer line has two literal middle dots. My original ASCII mk script copied that line into its draft anchor; validating only the mk file missed the decoded draft characters. The footer anchor now ends at the ASCII call prefix. Its replacement runs toast placement and comments out the retired argument tail, so no footer call or drawing remains. The generated edit anchors and replacements are now explicitly checked for ASCII before writing the draft.

Regenerated the draft: written. Local verification passes all four unique game anchors, game script parsing after replacement, new check syntax, the already-applied five fixture retargets, four camera recipes, and ASCII handoff files. Existing fixture retarget commit 9464b055a passed checks 21.30, 33.99 and 35.13 per lane feedback; no new retarget is needed. The same key and four-scene camera request remain ready. Shipping, fingerprint, pictures, critic and ON HIS PC confirmation still belong to the lane.
