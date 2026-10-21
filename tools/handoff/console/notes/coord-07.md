# coord-07: frame times on a weak-laptop stand-in (2026-10-21 01:00 to 01:29)

Bottom line: no. A 1080p raid under CPU throttle does not hold 60 fps, for 1 player or for the 2-player pair, even after the
quality ladder has shed what it can. The pixel bake (86a to 86j) is the big cut; job 94 makes the ladder honest; job 95 looks at the pair.

How (workflow wf_402525c4-ae2: one measuring agent, then a skeptic and a ladder reader; raw files in notes/coord-07/):
- Headless Chrome on debug port 9371, page :8809/fixture.html, canvas forced to 1920 x 1080 at scale 1, 20 s samples after 3 s
  warm-up, 3 repeats each. Builds: A on v33.41, B on v33.44 to v33.46, C on v33.46 (lanes shipped UI changes meanwhile). All before 86c.
- The throttle was nominally 4x but really about 5x on this VM (calibration loop 205 to 246 ms against 41 to 44 ms; the skeptic's
  own spot check 5.0x). So the fps below are about 20 percent worse than a true 4x.
- This headless Chrome ticks frames at about 32 a second even on a blank page, so unthrottled gaps (31 ms) show that cap, not the cost.
  Unthrottled work per frame: about 8 ms for 1 player (fits 60), about 17 to 18 ms per window for the pair (does not).
- The brief said headless draws in software; here chrome://gpu reports hardware canvas on the passed-through desktop card. So fill
  and raster costs are UNDERSTATED for a laptop with built-in graphics, and the throttle slows only scripts and canvas calls.
- Other helpers shared the machine (lanes, two robots, 7 gate ships). Medians held steady; p95 spread widely (below).

Results (median of 3 repeats; true worst in brackets):
| run | throttle | p50 gap | p95 gap (spread) | about fps |
| A, 1 player raid, walking | 1x | 31.2 ms (cap) | 33.5 | capped at 32 |
| A, 1 player raid, walking | ~5x | 40.8 ms | 50.1 (45 to 75) [135] | 24 |
| B, stress 40 bodies | ~5x | 55.6 ms | 83 (72 to 128) | 18 |
| B, stress 80 bodies plus bullets | ~5x | 92.1 ms | 125 (115 to 151) | 11 |
| C, 2-player demo, host window | ~5x | 148.5 ms | 187 (184 to 343) [502] | 7 |
| C, 2-player demo, player 2 window | ~5x | 146.7 ms | 218 (200 to 352) [528] | 7 |
Where the 1 player frame goes at ~5x (G.tel.gfx.pass, mean of 3): world 12.7 ms (50 percent), HUD 8.7 (34), fog 3.2 (13), light 0.8, weather 0.02.

Findings
1. The ladder steers by the frame gap alone. A screen or browser held at 30 frames a second (this headless Chrome; also laptop
   battery saver) makes it shed every rung and drop sharpness to 0.75 with only 8 ms of work. That happened in every run, unthrottled too.
   Two of its three rungs (post fx, lamp shadows) have nothing behind them. Its slow line is 25 ms, so 40 to 59 fps sheds nothing.
   With a 120 or 144 cap it sheds at about 80 to 96 fps. Job 94 fixes this, with his 75 percent floor (2.44 b) kept.
2. Sharpness at 0.75 did not get frames under 40 ms at ~5x: the cost is script and canvas calls (bodies, walls, props, HUD), not pixels.
   That is what the pixel bake (86a to 86j: about 100 calls per body down to 1 to 3) cuts. Re-measure after 86c and after 86f
   (pixel plan) with runA.sh and runC.sh.
3. The two party windows run on ONE main thread. The game opens player 2 with window.open on the same origin and keeps the opener,
   so Chrome puts both pages in one renderer process (the host calls the guest synchronously; ending one DevTools session unthrottled
   both). Unthrottled, the pair already needs 17 to 18 ms per window on this VM. Job 95 checks this on a real pair and whether a
   separate process for player 2 is safe, together with coord-06 (does the pair link inside itch's frame).
4. The full test run's and robots' raids also sit at 0.75 sharpness, since their Chromes tick at about 32 a second. Checks that read
   pixels should pin the render scale (most already pin it through __pinDPR).

Skeptic (high confidence): the verdict stands. Corrections it made are applied above (5x not 4x, true worsts, render scale stepped
down during the sample rather than before it, pass numbers for the pair are whole-raid averages, so only the 1 player pass split is used).
