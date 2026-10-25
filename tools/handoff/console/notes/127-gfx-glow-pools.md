# 127-gfx-glow-pools (lane b, 10-25)

Shipped v34.76 (cw-glowpools), after cw-cardstamp v34.75.
- GFX.emit (forge, forged gun, burning, shock, frozen) now feeds the light map (gfxLightPass, one pool per source, r x1.6, shared lamp sprite)
  and one cached halo sprite each before the fog (gfxGlowHalo, called from gfxPreFog with the camera). Pixel look: halo centre snapped to the art grid.
- POST FX on the quality ladder: GFXQ.post=0 from rung 2 (with HUD and weather), gfxqCan('post') true. Scales by EFFECT INTENSITY; POST FX off or intensity 0 draws none.
- POST FX hint now: "Glow pools from the forge, fire and shock. Off runs faster."
- Old ladder checks (34.xx, two lines in mkfixture) loosened first (commit 32d98e2d4) so they hold on both builds.
- New check: halo and pool counts with post on, off, intensity 0 and rung 2; 8 halos must cost under 1 ms per call.
- Pictures: shots/127-before and 127-after (screens 21 and 33, 1080 and 4k). No camera screen stages the forge or a burning body, so they only prove nothing else moved.
- NOT done: a 4K two-window frame time measurement and glow pictures. Needs a camera screen with the forge or a burning body (asked in questions.md).
