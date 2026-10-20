o-08-pad-owner : each guest can tell which pad is theirs (pad research J7, coordinator 2026-10-19)
effort: medium

Build and test as section "J7" of tools/handoff/pad-research/best-practices.md:
- When a window claims or reclaims its pad, send a short rumble (about 250 ms at 0.6) to that pad only.
- Show a 2-second lower-case tag by the player: "p1" in amber, "p2" in cyan.
- If the pause menu has a swap-pads entry, it must be usable with a pad alone.
- His rule stays: first pad = p2, second pad = p1.
Checks (each control must FAIL on the old build): two stub pads connected A then B give p2 pad A and p1 pad B; the rumble spy
fires on the right pad; the tag shows in the right window; unplug A and replug it, and the same player gets it back with no
rumble on the other pad.
TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
