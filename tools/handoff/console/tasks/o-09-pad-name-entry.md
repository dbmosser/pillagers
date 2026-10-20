o-09-pad-name-entry : a new career save can be named with only a pad (pad research J4, coordinator 2026-10-19)

The career name box cannot be reached with a pad today. Build and test as section "J4" of tools/handoff/pad-research/best-practices.md:
- Reuse the arcade initials card as a letter picker: up/down changes the letter, A moves on, B steps back, Menu is done.
- Lower case, with a pre-filled default so pressing A straight through still works. His order: the typed name goes into the new save.
- Any other text field with no pad route (stash search, feedback box, friend name) is skipped by pad focus.
- The delete-save and reset words stay keyboard only.
Checks (each control must FAIL on the old build): a stub pad creates a new save with a typed name; the name shows in the stash
and survives a reload; pad focus never lands on a text field that has no pad route.
TASK DONE when shipped and the checks pass; TASK PARTIAL with what is left.
