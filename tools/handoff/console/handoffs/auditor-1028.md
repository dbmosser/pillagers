# Auditor handoff, 10-28 (cloud session session_01LWYNPYgAEE81ubAJphygF2)

## Role, in his words
He asked: "Is there a way to like audit the game for visual, code, etc inconsistencies or inefficiencies?" On the proposal (fill the
gaps, fix the blind check, sort the belt checks, one ranked list) he said: "All of it". Then: "i want you to do what you need to do
autonomously" (he does not paste or relay anything by hand).

## Standing orders to this seat
- Act on its own; never ask him to paste, run or relay anything.
- Plain words to him, no jargon ("I'm not a dev").
- Cloud rule: never push master; push only the claude/ branch and hand the work to the PC to ship.

## Done
- Branch claude/audit-2026-10-28, commit df2510888, pushed and merged into master (06f4cb66f).
- Two fixes shipped from its drafts and in the game: v35.47 (new saves count each kill once) and v35.48 (player 2 gets the easy or
  normal card in the demo).
- tools/lint.ps1 class A reads var DEF (it read an empty var CFG and printed zero); v23.05 and v11.96 added to
  tools/handoff/stable-known-red.txt; report tools/handoff/cloud/audit-2026-10-28.md; rerun scripts tools/cloud/audit/.

## Open work
- Five lane jobs sit in tools/handoff/cloud/audit-jobs/ (on master) and are NOT in console/tasks yet:
  a01 check 32.46 part ONE fails only in a true 1920x1080 window (the check, not the screen);
  a02 a feed row that is too long cuts the name instead of the detail ("select a ..." in player 2's window);
  a03 15 callouts written as sentences;
  a04 enemy name tags print over each other;
  a05 45 never-called functions plus the dead gun-jam branches, after the party only.
  Someone has to move a01 to a04 into console/tasks (fixes and polish, allowed before Nov 1) and a05 after Fri 10/30.
- Nothing else unpushed: working tree clean.

## Check-ins cancelled
- trig_013ii51a1Vrdz5PjcV4v2CTt "Check the two audit fixes shipped", one-shot, due 2026-10-28 03:54Z. It fired and failed
  (access denied, no output); deleted now. No other scheduled tasks from this session.

## The successor must not
- Push master, edit dark_raiders.html or tools/mkfixture.ps1, or bump versions by hand.
- Re-ship or re-draft the two fixes (already in v35.47 and v35.48).
- Re-bisect the belt checks: all 13 out-of-date ones are on the known-red list.
- Start new audit work without his order; the week's plan is over its pacing line.
