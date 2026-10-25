# 124-gfx-coloured-flash-light (lane a, 10-25)
- SHIPPED v34.80 (fd55c26b6): three put() swaps in gfxLightPass: flashes use F.c, hunting machine eyes the eye-glow red, the beacon teal. Same draw count (cached sprite per colour), so no new frame cost. His lamp and the teammate lamp stay white.
- Why the earlier STOP: my check set P.cond='night' and never put it back, so the seed 4242 fingerprint run after it spawned 112/482 ents. Proved with a comment-only probe (v34.79 cw-fpprobe, shipped, fingerprint held). Check now restores P.cond.
- Lesson: a check that changes P.cond must restore it, the preflight does not run the fingerprint.
- Left: night pictures (both windows, 1080p and 4K) and 4K frame numbers for the DESIGN.md line (draw count unchanged by design).
