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

Lane note 2026-10-19 19:09: shipped cw-cx-padowner and parked: only lane-side steps are left. Codex's last words:
`cw-cx-padowner` shipped in v31.93. Added the coordinator’s camera command and updated recipes for pictures from both windows.

TASK PARTIAL: coordinator must run the camera recipes and return pictures and critic results.

Coordinator note 10-20 00:20: back in tasks/ for the lane-side step it waited for. The lane now photographs camera-recipes.json itself (first 6 screens, critic on each) and sends you the pictures; the first pass spends no Codex run. Already shipped (do not ship again): cw-cx-padowner . Review the pictures and the critic: end TASK DONE if they hold, or fix P0/P1 findings with a NEW key.
