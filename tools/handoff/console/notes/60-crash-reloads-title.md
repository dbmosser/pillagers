# 60-crash-reloads-title

Shipped v32.96 (cw-crashreload). Gate and fingerprint passed.

What it does: noteCrash tracks a run of the same fault (kind, message with digits ignored, place). If it repeats within 1 s of itself for 5 s or more, at least 10 times a second, the game stops saving, writes a note in sessionStorage and reloads. The title shows "restarted after an error" for 4 s, then fades.
Never triggers on: one error, a burst under 5 s, a hidden page, the fixture or gate pages (they have __runPrep), a second time after the first restart.
The crash entry is already in the run report from its first hit; later saves are skipped so the last good save stays.

Check: fake clock, stubbed reload. 6.5 s fault = exactly 1 reload and the note set; 3 s burst and a single fault = 0; hidden page = 0.

Not done: the 2-player partner. The reloading window closes its link like a closed window; I did not see it in two windows (needs the party rig). Watch for it.

Watch in the next playtest: a real run that restarts to the title by itself (should only happen when an error repeats every frame for 5 s), and that the title note appears and fades. The note is a plain DOM line, no picture was taken.
