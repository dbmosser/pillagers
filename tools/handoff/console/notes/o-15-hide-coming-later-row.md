
--- codex run 2026-10-20 14:42 ---
2026-10-20: Prepared cw-cx-hidecoopsrv for his 2.R6 b: "Hide it completely until it works". Only the existing server co-op wrapper gains style="display:none", matching the hidden PvP wrapper. Its disabled button, tag, ID and wiring remain in the page. No other title layout or wording changes.
Keyboard netTitleRows already rejects disabled buttons and hidden wrappers. Pad padFocusables already rejects disabled buttons and zero-size controls, so navigation code needs no changes.
Check stages the host title, verifies both retained elements have no rendered rectangles and the wrapper is hidden, walks arrows in both directions through all four playable modes, and tests the pad focus list and downward movement. The unpatched host fails because the wrapper is visible. No fixture retarget needed: existing modecoopsrv checks found concern retained element styling, not visibility.
Sandbox validation: mk script printed written; exactly one anchor matched; inspected the single edit; check JavaScript syntax passes Node parsing. Browser checks, shipping, and before/after shot 01 with critic remain the lane's work. Game file was not edited.
