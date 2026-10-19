
--- codex run 2026-10-19 19:15 ---
2026-10-19, o-09-pad-name-entry, prepared cw-cx-padname on v31.93.

The title name field keeps its existing keyboard behavior. Pad A opens a 16-letter card, pre-filled from the name field (pillager by default). Up/down change the current letter; A/right advances; B/left goes back; Menu finishes. B at the first letter cancels. The alphabet includes lower case letters, a blank, digits and a dash. Menu trims trailing blanks; A through all 16 letters keeps the default. Finishing sends the normal input event, so the existing newNameKeep/newNameTake path recognizes the name as entered and carries it into a new save.

The arcade initials and career card share letter stepping and pad input helpers. The arcade behavior is otherwise unchanged. Unsupported text inputs, feedback textareas and editable text are removed from pad focus; career name is the exception. Delete and reset words keep their keyboard safety.

The stash brand now shows the save name. Reason for replacing the generic PILLAGERS word: J4 expressly requires the entered name to appear in the stash, and replacing the existing label avoids a second heading or extra row. No other owner wording changed.

Local verification: the mk script prints written, all 9 anchors match exactly once, the patched game script parses, the gate check parses, letter controls and stick latching pass, and 81 old/new arcade operations match. No tracked files were edited. verify.cjs can repeat those local checks after generating the draft. No Chrome, localhost, preflight or ship queue was started in the sandbox.

The gate check drives pollPad with a stub navigator.getGamepads. It tests held-button edges for up/down/A/B/Menu, A through the pre-filled name, the actual create-save button, the pending name at navigation, fresh-save boot, writing storage, reloading through applyLoadedProfile, the stash label, unsupported text focus filtering and repeated pad navigation. careerNewReload is only the browser navigation boundary, stubbed during that check; the real save button and boot consumer run normally. The lane must verify red on the old build and green on the new build.

Handed over keys.txt and four camera recipes: letter picker and named stash on both player 1 and player 2 pages. Browser gates, shipping, pictures at 1080p and 4K, and critic review remain the lane work. The finish line is critic 3 for these screens, with any P0/P1 fixed. No fixture retarget is expected; the existing new-save name check still sees newNameKeep in the real button handler.

