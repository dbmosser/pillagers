94-ladder-sheds-sooner : the quality ladder sheds real effects sooner, keeps sharpness at 75 percent or more, and never pumps (coord-07 measure, 2026-10-21)
Queue (coordinator): from coord-07. His 10-20 23:00 order means nothing waits for the party, so the brief's "after the 10/29 lock" no longer holds. Ship in small pieces, each with a watch line.
effort: medium
After: none required. Rung 1 trims particles when they spawn, so it works the same with 86j's pixel particles. If 86j is running, take steps 1, 4 and 6 first.

Source (his words, verbatim):
- 10-12 #21 (memory pillagers-fifty-answers-2026-10-12.md; q-round3/sweep-2-older-rulings.md line 156): "60 fps also on a mid laptop at 1080p (automatic render scale)."
- third50 (memory pillagers-answers-third50-2026-10-12.md): "Minimum hardware: a 5-year-old laptop."
- 2.44 (q-round3/answers.md line 48): "b: Effects can go down, picture sharpness no lower than 75 percent"
- 2.43 (answers.md line 47): "a: Anything under 60 for more than a few seconds"
- 2.11 (answers.md line 17): "a: The full size of each TV (sharpest, hardest on the PC) | NOTE: both screens are 4k, 144 or 120 hz". 2.57: "120 or 144hz"
- 1-78 #27: "Worst problems, in order: stutter or harsh sound; crash or freeze; ..."

Measured (coord-07, v33.41 to 33.46, 1080p, CPU throttle nominally 4x, really about 5x; notes/coord-07.md and notes/coord-07/summary.json):
- 1 player: p95 50 ms, about 24 fps median.
- 2-player demo: p95 187 ms in the host window and 218 ms in the player 2 window, about 7 fps.
- Every run shed the 3 rungs in warm-up and stepped sharpness from 1 down to 0.75 during the sample.
- Script time per pass at 4x, 1 player (G.tel.gfx.pass, mean of 3 runs): world 12.7 ms (50 percent), HUD 8.7 (34), fog 3.2 (13), light 0.8 (3), weather 0.02 (clear raid).
- The GPU here is a fast desktop card, so fill costs are understated. Headless rAF is capped near 32 Hz.

Not done (coordinator read of HEAD v33.49):
- Rungs 1 and 3 shed nothing. gfxqApply (about 34874) sets GFXQ.post and GFXQ.shadow, but gfxPostNow() and gfxLightNow() (about 34878) have no reader. The bloom, grade and grain hooks gfxPreFog, gfxPostFog and gfxScreen (about 50417) are empty stubs. Only rung 2 (soft sheets at 0.66, SOFTR about 34931) and the scale change the picture.
- The slow line is the frame gap's EMA over 1.5x the budget, 25 ms (drsTick about 34881-34888), so 40 to 59 fps sheds nothing. His own exports sit in that band (notes/pixel-plan.md "Speed budget": p50 17.4, p95 22.2 ms).
- It reads only the gap. A screen or browser that holds frames to about 30 a second sheds every rung and drops to 0.75 with about 8 ms of real work. Every coord-07 run did this.
- When a Frame cap is set, the budget is 1000/cap (about 34884). At 120 or 144 the ladder sheds and softens at about 80 to 96 fps.
- Every move calls resize() (loop, about 50778), which rebuilds cv, hcv, fogC and litC (about 34922-34933). That happens even for rungs that change no size: one hitch per move, 8 moves down to the floor.
- Every raid starts at full quality and sheds again over about 18 s (reset at about 50777).
- None of these is on the ladder:
  - particles: Effects row fxLevel, spark about 22723, boomFx about 50679
  - decals: about 22897, cap 420, 45 s life
  - the HUD corner vignette: drawHUD about 42218, a full-screen gradient at full HUD pixels every frame
  - weather: rain about 40811, haze and 7 fog banks about 40858
- Stale text: the Auto resolution hint (Settings, about 67906) says "never under Low", but the floor is 0.75.

What to do. DRS.min stays 0.75. No new Settings row. Lighting colour and every gameplay mark stay as they are.
1. Change what the ladder steers by. Keep the gap and add each frame's own work time (loop entry to the end of the HUD pass, performance.now). The budget is Math.max(16.7, 1000/cap), so a 120 or 144 cap never sheds above 60 fps (2.43 a, 2.11 a). The window is the last 2 s of frames.
   - slow: window p95 gap over 20 ms (more than 1 frame in 20 missed a 60 Hz frame)
   - clear: window p95 gap under 17.5 ms and work p95 under 10 ms
   - in between: hold, nothing moves
2. The new ladder, in order of measured cost:
   - rung 1 (world, about half the frame): particles at the Effects REDUCED counts (the fxLevel 0 path: spark n/3, boomFx thin). New ground decals live 15 s instead of 45. Both apply at spawn only, so live sparks finish their life and nothing pops.
   - rung 2 (HUD, about a third, plus weather): the HUD corner vignette fades out over 1 s. The low health edge, the hit flash and the scope vignette stay. Weather draws 3 fog banks instead of 7 and half the rain drops, eased in over 1 s.
   - rung 3 (fog, about an eighth): the soft sheets at two thirds size. This is today's rung 2, unchanged.
   - off the ladder: the empty POST FX and lamp shadow rungs. Make gfxqCan return false for them while they have no reader, and put them back the day bloom or lamp shadows ship. Lighting colour also stays off the ladder: it is 3 percent of the frame, and CLASSIC would change the whole look.
   - then sharpness, 0.05 a step down to 0.75 as today, but only if rung 3 (the fill rung) moved the window p50 gap down by 1 ms or more. If rung 3 moved nothing, the gap is the screen's or browser's own rate, or script time. Take no sharpness step and climb back after the normal wait. At 4x, 0.75 did not get frames under 40 ms.
3. Timing that cannot pump:
   - down: a rung after 2 s slow; a sharpness step after 2 s slow and 3 s since the last move (as today)
   - up: one step after 10 s clear and 10 s since the last move, sharpness first, then the rungs in reverse
   - never a step down and a step up within 10 s of each other
   - a step down within 30 s of a step up doubles the next up wait (10, 20, 40 s, at most 60 s). One doubling is dropped after 60 s with no step down.
4. No hitch: only moves that change a canvas size (rung 3 and sharpness) call resize(). Rungs 1 and 2 only flip GFXQ fields.
5. Carry over: a new raid in the same page session starts one step better than where the last raid settled, instead of at full (about 50777). Raid after raid at the party then does not soften again each time.
6. Fix the Auto resolution hint (about 67906): replace "never under Low" with the 75 percent floor. Keep his words, add no new sentence.

Check (new, must fail on the build before; feed synthetic gaps and work times into drsTick through its now argument):
- 22 ms gaps (45 fps) with 6 ms work, for 5 s: rung 1 is taken. Fails today: the 25 ms EMA line never fires.
- 33.3 ms gaps (a 30 Hz screen) with 6 ms work, for 60 s: sharpness stays 1. Fails today: 8 moves, ends at 0.75.
- cap 144, 11 ms gaps for 30 s: nothing moves. Fails today: the 10.4 ms line fires.
- 120 s alternating 3 s slow and 3 s fast: no step down and step up within 10 s of each other, and sharpness never under 0.75.
- moves on rungs 1 and 2 make no resize() call (count the calls).
- spark() on rung 1 spawns a third. The seed 4242 fingerprint holds (cosmetic stream only).
- a raid that settled at rung 3 and 0.85 starts the next raid at rung 3 and 0.9.
Then rerun coord-07's A-t4 and C-t4 (notes/coord-07/runA.sh and runC.sh, on your lane's own port, never 8802). Write the new p50 and p95 beside the old ones in notes/coord-07/.
Pictures: a 1080 firefight at rung 0 and at rung 2, side by side (uishots), and look at them.

What this does not fix: this job makes the ladder honest and quick, but it does not close the gap. The world pass is mostly bodies, walls and props, and no rung touches them. The big cut is the pixel bake (86a to 86j: about 100 vector calls per body down to 1 to 3). The 2-player pair at 4x (about 7 fps) is beyond any ladder: two full renders share one main thread (job 95 looks at that). The party itself runs on his own PC.

Party risk: medium. The ladder runs in both windows on his TVs every raid.
Watch line: "a raid that turns softer or loses sparks while nothing is happening, or sparks or haze that come and go; the first 20 seconds of each raid should look like the rest."
Size: about 0.6 lane-nights, in 3 ships:
(a) step 1, step 4 and taking the empty rungs off
(b) the new rungs 1 and 2
(c) steps 3, 5 and 6

TASK DONE when shipped with its checks, the re-measure written and the pictures looked at; TASK PARTIAL with what is left.
