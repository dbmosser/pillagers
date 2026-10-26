# 120k-two-player-frame-cost : find and cut what made the 2-player frame grow since v34.18
Queue (coordinator 10-25 12:45): his question "What can you do to improve gameplay/smoothness/mechanics" (Sun 10-25). Party fix (Fri 10/30 first). Read notes/gameplay-next-1025.md, idea 2, for the why, the cautions and the line numbers (check them on HEAD; they were read on v34.78).
Since v34.81 the SMOOTH look is the default (his 10-25 order "I want the graphics smooth"): test and take pictures in the smooth look.
effort: medium

Do: compare the time of each draw pass (G.tel.gfx.pass: world, HUD, fog, light) on one fixture seed at v34.18 and at HEAD in a 2-player raid at 1080p, narrow it to the ships that added the most, and cut their cost or move them to ladder rung 1, keeping the look (pictures for anything a player sees). Measure the per-frame garbage too (drsTick sorts twice a frame, render2D builds closures, the vignette builds a gradient each frame). Write the numbers in notes/120k-frame-cost.md. The graphics jobs 128, 129 and 130 wait in waiting/ for your numbers.

Rules: the seed 4242 fingerprint (ents 85/374, containers 165/593) must hold unless this brief says otherwise; the check must FAIL on the build before; both windows; player text all lower case. Say in DESIGN.md what he should watch for in a playtest.
Also (coordinator 10-26, from job 127): include the 127 glow (POST FX on and off, the forge and burning bodies in view; camera screens 81 to 92 stage them) in the 4K two-window frame time, and say in DESIGN.md what it costs. That is the last open part of 127-gfx-glow-pools.
TASK DONE when it shipped; TASK PARTIAL with what is left.
