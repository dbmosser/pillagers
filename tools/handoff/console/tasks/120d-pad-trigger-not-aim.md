# 120d-pad-trigger-not-aim : a pad trigger pull no longer counts as aiming (no sprint cut, no scope pulse)
Queue (coordinator 10-25 12:45): his question "What can you do to improve gameplay/smoothness/mechanics" (Sun 10-25). Party fix (Fri 10/30 first). Read notes/gameplay-next-1025.md, idea 3, for the why, the cautions and the line numbers (check them on HEAD; they were read on v34.78).
Since v34.81 the SMOOTH look is the default (his 10-25 order "I want the graphics smooth"): test and take pictures in the smooth look.
effort: medium

Do: an RT pull keeps its steadier pad spread, but it no longer sets G.player.ads, so it does not cancel a held or toggled sprint, slow the walk, or pulse a scoped view. Right mouse and LT still aim (his 10-20 order names only those). Checks: a held LS sprint survives RT pulls; a scoped rifle on RT does not change opticMag; LT still aims and cuts sprint; the spread on RT is still the pad spread.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.
