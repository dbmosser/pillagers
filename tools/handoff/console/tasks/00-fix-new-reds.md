FIX THE NEWLY FAILING OLD CHECKS SO A STABLE VERSION CAN MOVE FORWARD (10-18). His order: his play window loads only the latest
STABLE version (tools/stable.sh; rules in tools/handoff/stable-status.txt), and stable is stuck at v29.09 because the overnight
test set found checks that newly fail since then (v29.32 had 25), mostly older checks of screens the helpers redesigned.
Notes: notes\00-fix-new-reds.md. Read tools/handoff/stable-status.txt for the list, then for EACH newly failing check decide:
(a) the game really broke something: fix the game (a cw- ship with a check), or (b) the check pins an old layout or wording that a
later ship changed on purpose: retarget the check in tools/mkfixture.ps1 (under the lock, HELD=1 fixq.sh, as RULES.md says) so it
tests the same promise on the new look. Never delete a check to make it pass, and never weaken one that guards gameplay.
Re-run the fixed checks with runchk.sh. Write one line per check in your notes (name, a or b, what you did).
TASK DONE when every check in the list is fixed or retargeted, or TASK PARTIAL with the rest.
