o-10-pad-floor-bag : the Undercroft floor backpack works on a pad (pad research J5, coordinator 2026-10-19)
effort: medium

View opens the floor backpack in the Undercroft, but a pad cannot use it. Build and test as section "J5" of tools/handoff/pad-research/best-practices.md, using the same
buttons and helpers as the raid bag (bagArrow / bagPadCell / bagPadAct): D-pad moves, A picks up and places, Y drops, B closes.
One control per job. Checks (each control must FAIL on the old build): with a stub pad in the hub, View opens it, the D-pad moves
the highlight, A picks up and A places (the item moved), and B closes it, with no keyboard events at all.
TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
