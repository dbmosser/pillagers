57-retarget-repairs-2 : put back what the job 53 retargets loosened (coordinator 2026-10-20, second audit)
effort: high

Same as job 55 (read notes/55-retarget-repairs.md for how it went), for the second audit: every finding with evidence and a proposed
fix is in tools/handoff/console/notes/57-retarget-audit.md. Read it first.

In this order:
1. 29.31 (CONFIRMED, high): the backpack cue colour check can no longer fail (the corner "backpack" label drawn later overwrites what
   it read). Match the cue by its own text and keep the first match, then prove it: with the cue colour changed to amber in a copy of
   the check's staging the check must go red (mutation test), and it must PASS on HEAD.
2. 27.56 (CONFIRMED): exclude full-screen rects and require the card-sized rect at full alpha, so a card drawn at 94 percent fails again.
3. 29.33 (CONFIRMED): the "no raw colour or font-size literals in the ui-shared block" scan was cut to the title rules. Put the
   block-wide scan back for colour and font-size literals, and pin today's offenders (about 19 rules, listed in the audit) as known
   debt with a list that may only shrink, so any NEW literal fails. Do not restyle those rules in this job: list them in your notes
   as a follow-up token pass.
4. UNVERIFIED low ones (20.95, 24.37, 26.54, 27.75): check each claim yourself first; fix the ones that hold, "not a problem" otherwise.

How: plan before the lock; bash S/lock.sh, edit tools/mkfixture.ps1, runchk.sh on what you touched, HELD=1 bash S/fixq.sh "MESSAGE",
bash S/unlock.sh; short holds. Every restored assertion PASSes on HEAD and would FAIL on the bug it guards (say how you know). If one
fails on HEAD, that is a REAL bug: fix the game through the ship queue, never loosen the check again. Leave 28.20 to job 56.
One line per finding in tools/handoff/console/notes/57-retarget-repairs-2.md: check, FIXED / REAL (game fix vNN.NN) / NOT A PROBLEM, reason.

TASK DONE when every finding in the audit file has a line in your notes; TASK PARTIAL with the ones left.
