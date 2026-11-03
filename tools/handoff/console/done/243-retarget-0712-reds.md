# 243-retarget-0712-reds : retarget 5 out-of-date checks that went red in run corpus-1029-0712 (v36.44)
Queue (check-in sort 10-29; full run corpus-1029-0712 on v36.44; all five green in corpus-1029-0502 on v36.39, red on HEAD v36.49 when run alone). LOW, no player change; they block stable until listed (now parked in tools/handoff/stable-known-red.txt) or retargeted.
effort: low (Sonnet high; edit tools/mkfixture.ps1 through fixq only)

Two causes, both a shipped owner order, not a bug:

A. His 10-28 order, shipped v36.40 (beast mode replaces kill streak rewards: no double kill or triple kill, no streak multiplier, plain kills pay base points, no streak medal pop). v36.40 retargeted 33.24, 28.21, 26.84, 23.38 but missed two:
- 25.13 (mkfixture.ps1 about line 52327): a CAREER raid second kill inside the streak gap expects g.cs.s 150 and the clock spot reading 150; it now scores 100 (50 + 50) and reads 100 SP. Retarget to: each plain kill pays its base points, no multiplier, score 100 and the clock spot reads 100, and a CAREER kill still never changes the DEMO score.
- 27.94 (about line 37802): the THREE section asserts String(arcadeKill) contains SPK_MEDALS (the streak pop) and no old chime ladder. Keep the no annCue assertion, drop the SPK_MEDALS one (SPK_MEDALS still drives the style medals, checked a few lines above).

B. His 10-28 order, shipped v36.41 (a fixed HUD panel over your pillager fades to 35 percent until you step clear). In a fixture raid the pillager stands at 2020,3300 at the south map edge, the camera clamps, and he draws at about y 793 of 973, right under the use bar (y 787) and the power-up chip row. Once the panel has been drawn once the fade starts and its text goes through HUDFADE's offscreen layer (ctx swapped to HUDFADE.layer's context in hudFadeBegin), so checks that stub ctx.fillText or ctx.fillRect on the main context see nothing. Reproduced: a bandage bar alone draws, bandage plus plate draws neither bar (layer alpha 0.35), a plate bar alone after a clear draws.
- 34.60 cw-airchips (about line 15038): "no power-up chips drawn".
- 22.74 (about line 61664): "a plate going on drew no SLOTTING line on the use bar".
- 18.75 (about line 73058): "no SLOTTING ARMOUR PLATE bar while a plate goes on".
Retarget: before drawing, move the player and camera to an open mid-map spot (or set the fade state clear each grab) so the panel does not overlap the pillager, or wrap the stub so it also watches the layer context. Keep every existing assertion. While there, search mkfixture.ps1 for other checks that stub ctx.fillText or ctx.fillRect and then call __frame at the spawn: if more go red later with a text-not-drawn message, the same fix applies.
Do: edit each through fixq (lock.sh, edit tools/mkfixture.ps1, HELD=1 fixq.sh "retarget NN.NN: reason", unlock.sh), then delete the five lines (v25.13, v27.94, v34.60, v22.74, v18.75) from tools/handoff/stable-known-red.txt.
Rules: tests only, never edit dark_raiders.html; seed 4242 fingerprint unchanged; never touch the pickup stack, loot sounds or loot rows.
TASK DONE when the five pass on the current build in a full run and their known-red lines are gone.
