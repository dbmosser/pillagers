o-12-menu-stick-repeat : menus step at a normal stick push and a held D-pad repeats (pad research J10, coordinator 2026-10-19)
effort: medium

Build and test as section "J10" of tools/handoff/pad-research/best-practices.md. This changes padMenu only, never gameplay. Checks (each control must FAIL on the old
build): a stub stick at raw 0.52 steps focus at the LARGE and HUGE deadzones; D-down held 1.2 s steps about 8 times; a tap steps once.
TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
