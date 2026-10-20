# 46-check-invite-and-pad-items : two checks from the fix list (coordinator 2026-10-20, helper-fixes items 41 and 43)
effort: low

1. Invite codes and the all-lower-case rule (item 41). Since v30.72 every player-facing word goes through the lower-casing
   (ncFix, NCLOWER). The same-machine pair code is a-z and 0-9, so it is safe. The online invite code is not: the party card says
   it "starts PTY1o" and it is mixed case. Prove with a check that a real invite code survives every path it takes: made by the
   host (NEW INVITE CODE), shown, copied, pasted into #partyin and read back by the join code. If any path lower-cases it, fix
   that path only (keep the words around it lower case), and the check must FAIL on the old build. If nothing breaks, the check
   still ships as a guard; say plainly in your notes that no bug was found.
   Also make sure the placeholder text on #partyin still names the start of the code the way it really looks.
2. Pad reach for the armour plate and the air strike (item 43). Melee is on the right stick click since o-06 (3.11 b). Check that
   a pad player can use an armour plate and call an air strike with every one of the 6 pad layouts (o-05), through whatever route
   the game offers (item wheel, belt, a button). A check that drives the pad (fake pad, not keys) for each. If one cannot be
   reached, do NOT design a new layout: write it in tools/handoff/console/questions.md as one short question for him (question
   13 decides pad layout work) and in your notes.
No visible change unless item 1 finds a bug. No pictures needed.
TASK DONE when the checks ship and pass (and any invite code bug is fixed); TASK PARTIAL with what is left.
