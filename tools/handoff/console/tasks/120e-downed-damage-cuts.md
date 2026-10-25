# 120e-downed-damage-cuts : a hit on a downed player follows the same damage cuts as a standing one
Queue (coordinator 10-25 12:45): his question "What can you do to improve gameplay/smoothness/mechanics" (Sun 10-25). Party fix (Fri 10/30 first). Read notes/gameplay-next-1025.md, idea 6, for the why, the cautions and the line numbers (check them on HEAD; they were read on v34.78).
Since v34.81 the SMOOTH look is the default (his 10-25 order "I want the graphics smooth"): test and take pictures in the smooth look.
effort: small

Do: a hit on a downed player goes through the same damage scaling a standing player gets (demo half, kid mode, easy mode), so a partner can finish a revive. Checks: the same round on a downed player in the demo does the demo share; normal career damage on a downed player is unchanged (control).

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.
