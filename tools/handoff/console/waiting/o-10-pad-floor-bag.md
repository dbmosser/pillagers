o-10-pad-floor-bag : the Undercroft floor backpack works on a pad (pad research J5, coordinator 2026-10-19)
effort: medium

View opens the floor backpack in the Undercroft, but a pad cannot use it. Build and test as section "J5" of tools/handoff/pad-research/best-practices.md, using the same
buttons and helpers as the raid bag (bagArrow / bagPadCell / bagPadAct): D-pad moves, A picks up and places, Y drops, B closes.
One control per job. Checks (each control must FAIL on the old build): with a stub pad in the hub, View opens it, the D-pad moves
the highlight, A picks up and A places (the item moved), and B closes it, with no keyboard events at all.
TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.

Lane note 2026-10-19 19:44: shipped cw-cx-floorbag and parked: only lane-side steps are left. Codex's last words:
Shipped in v31.98. Preflight and behavior checks pass; the map fingerprint is unchanged.

Pictures remain unverified because the installed lane lacks the promised camera-recipe support. Recorded the blocker and camera handoff.

TASK PARTIAL: lane/coordinator must capture both window pictures and return critic results.
