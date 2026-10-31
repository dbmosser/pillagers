# 120j-coop-smooth-remote : the partner and the enemies on the other screen move at a steady speed
Queue (coordinator 10-25 12:45): his question "What can you do to improve gameplay/smoothness/mechanics" (Sun 10-25). Party fix (Fri 10/30 first). Read notes/gameplay-next-1025.md, idea 4, for the why, the cautions and the line numbers (check them on HEAD; they were read on v34.78).
Since v34.81 the SMOOTH look is the default (his 10-25 order "I want the graphics smooth"): test and take pictures in the smooth look.
effort: medium

His answer 2.27 b (guidance: no more than 50 ms extra for player 2, with prediction). Do: send velocity with the 10 Hz rows and draw remote bodies by interpolation with a short prediction instead of the exponential chase, so they stop surging and stalling ten times a second and sit closer to real time. Keep the 10 Hz send rate. Network code: test with two real windows (fuzz 2-player) and watch for jumps at a new raid, doors and deaths. Checks: a body walking at a steady speed moves a steady distance each frame on the far screen (spread under 20 percent); the lag is under the old number.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
TASK DONE when it shipped; TASK PARTIAL with what is left.
