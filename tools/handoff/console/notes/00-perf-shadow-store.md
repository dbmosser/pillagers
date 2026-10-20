# 00-perf-shadow-store

Shipped v32.75 (cw-shadowstore, commit 836e1b2d). shadowE key is now ss+':'+sizes; the "empty on a new ss" line is gone; 300 cap kept.
Check (fails on old build): 3 frames at ss 1 and ss 2 make no new shadow canvases after frame 1, the store holds one entry per scale,
and the drawn width at ss 1 and ss 2 matches (same size and place). Gate and seed 4242 fingerprint passed (ents 85/374, containers 165/593).

NOT DONE: the speed proof (__regressBg(0,120) under 20 min, page under 600 MB). I have no command in my list that runs it.
The coordinator should rerun the full test run on v32.75 and record the time.

Watch in the next playtest: raids should feel smoother with many bodies and boxes on screen (fewer frame hitches, less memory growth).
