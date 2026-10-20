o-09-pad-name-entry : a new career save can be named with only a pad (pad research J4, coordinator 2026-10-19)

The career name box cannot be reached with a pad today. Build and test as section "J4" of tools/handoff/pad-research/best-practices.md:
- Reuse the arcade initials card as a letter picker: up/down changes the letter, A moves on, B steps back, Menu is done.
- Lower case, with a pre-filled default so pressing A straight through still works. His order: the typed name goes into the new save.
- Any other text field with no pad route (stash search, feedback box, friend name) is skipped by pad focus.
- The delete-save and reset words stay keyboard only.
Checks (each control must FAIL on the old build): a stub pad creates a new save with a typed name; the name shows in the stash
and survives a reload; pad focus never lands on a text field that has no pad route.
TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.

Lane note 2026-10-19 19:21: shipped cw-cx-padname and parked: only lane-side steps are left. Codex's last words:
Shipped in v31.95; check 31.95 passed both fixture gates. Added an explicit camera request because the lane skipped the custom recipes.

TASK PARTIAL: coordinator must capture both windows and return pictures and critic results.

Coordinator note 10-20 00:20: back in tasks/ for the lane-side step it waited for. The lane now photographs camera-recipes.json itself (first 6 screens, critic on each) and sends you the pictures; the first pass spends no Codex run. Already shipped (do not ship again): cw-cx-padname . Review the pictures and the critic: end TASK DONE if they hold, or fix P0/P1 findings with a NEW key.
