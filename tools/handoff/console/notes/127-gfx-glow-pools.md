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

## Glow pictures (10-26 about 03:40, on v34.86)
- 12 staged screens at 1080 and 4K, POST FX on and off: forge, burning bot, shocked crawler, frozen bot, forged gun, burning bot behind a wall.
  Recipes and shots: scratchpad glow127/ (recipes.json, shots/, crops/ side by side). Every screen: src 1, halos 1, pools 1 on; 0 and 0 off.
- Forge: reads well. Soft warm pool, fades out by about 200 units, no hard edge, no white blowout. The halo tints the furnace rust-brown like firelight.
- Burning, shocked, frozen bodies: a faint tint on the body only, no floor pool (the pool goes into the multiply light map, so on a near-black night
  floor it has almost nothing to lift; the additive halo is capped near 0.12 to 0.15 at night). Forged gun glow is effectively invisible.
  Not ugly anywhere: no banding at 4K, no halo off its source. Left as is: brighter body glow is a look call for him, not a defect.
- Bug found and fixed: drawElemFx drew flames, arcs, ice and their glow for bodies out of sight (floating flames in the fog). Shipped v34.87 (cw-elemseen).
- Pre-existing, minor: within forge reach (70) the "the forge . e upgrade" card sits over the furnace and hides most of its glow.
- Still NOT done: the 4K two-window frame time run (needs a quiet machine, no workflow).
