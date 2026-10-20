55-retarget-repairs : put back what today's corpus retargets loosened (coordinator 2026-10-20, from an independent audit)
effort: high

Today jobs 49 to 54 and Codex (o-02) rewrote about 100 old checks. An audit (two agents per finding: one finds, one tries to refute)
says some rewrites were loosened past what the cited change needed, which breaks the rule "never weaken a check to make it pass".
Every finding, with its evidence and a proposed fix, is in tools/handoff/console/notes/55-retarget-audit.md. Read it first.

Do them in this order:
1. 24.21 (CONFIRMED, high). The tolerance went from 2 px to 14 px and the stash left the one-height group, just enough to hide a real
   misalignment: the close X sits 43 px down in Settings, 55 in the shop, Mainframe and fashion, 8 in the stash. First find out whether
   each X sits at the same place inside its own window frame (then the audit's fix, measuring against each drawn frame, is a fair
   retarget with the 2 px tolerance back). If the X really sits at different places in the frame, that is a REAL bug: fix the game
   through the ship queue so every full window puts its X in one place (v31.02 "one close place now: the corner"), with pictures
   (tools/uishots.ps1) before and after, then put the 2 px tolerance back and the stash back in the group.
2. 25.01, 31.71, 15.86, 24.37 (CONFIRMED, medium): restore the lost assertion as the audit says, at the new layout or scale.
3. The UNVERIFIED low ones (20.89, 26.38, 19.64, 9.14, 10.13, 27.20, and the version labels in comments): check each claim yourself
   first; fix the ones that hold, write "not a problem" for the ones that do not.

How: plan each edit before you take the lock (bash S/lock.sh, edit tools/mkfixture.ps1, runchk.sh on the checks you touched, then
HELD=1 bash S/fixq.sh "MESSAGE", bash S/unlock.sh; short holds). Each restored assertion must still PASS on the current game, and
must FAIL on a build with the bug it guards (say how you know, for example by the audit's worked example). If a restored assertion
fails on the current game, that is a REAL bug: fix the game, do not loosen the check again. 31.71 and 27.20 are in o-02's 22 but are
yours (o-02 was told to leave them); do not touch o-02's other checks while it runs, or 53-corpus-reds-b's checks while that job is
still in tasks/.
Write one line per finding in tools/handoff/console/notes/55-retarget-repairs.md: check, FIXED / REAL (game fix vNN.NN) / NOT A PROBLEM, reason.

TASK DONE when every finding in the audit file has a line in your notes; TASK PARTIAL with the ones left.
