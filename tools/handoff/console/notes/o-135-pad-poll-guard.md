
--- codex run 2026-10-28 02:10 ---
2026-10-28: Prepared cw-cx-padpollguard against v35.59. The browser API read is guarded, including its property access; unavailable or denied reads follow the existing empty-pad cleanup. The frame loop also catches a throwing pad handler and releases pad-owned keys, mouse buttons, sticks and rumble references while allowing the frame to continue. No player text, pad assignment, generation or feel values changed.

The regression check uses the standard raid staging at seed 4242, smooth look, and both host/p1 and p2 window roles. It injects a SecurityError from navigator.getGamepads, checks direct polling releases pad-owned input while retaining keyboard and mouse input, and steps three real frames per role. A second phase makes pollPad itself throw to exercise the outer guard. It counts completed render2D calls with actual canvas drawing and checks that raid time advances. All stubs are restored in finally and the raid ends there.

The draft why field is copied into DESIGN.md by the normal ship generator. It includes this playtest watch: inside the itch frame, both windows should keep animating and accept keyboard movement and mouse fire when pads are blocked; when allowed, the first pad remains p2 and the second p1.

Local validation: mk script printed written and both anchors matched once. Patched game scripts and the regression check receive a syntax-only parse in validate.cjs; no browser or localhost was used. The lane must run preflight, confirm the check fails before and passes after, retain the 4242 fingerprints, ship, and report ON HIS PC. No visual layout change needs critic pictures.

