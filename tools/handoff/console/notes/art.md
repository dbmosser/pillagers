# art.md (see also c-01-art.md)

SHIPPED (run 3, 10-17 ~12:00): step 1, cw-helmbar = v28.79 (commit 3620a47c). The Heavy helmet crest is now a low steel ridge, the scheme
accent is a small brow lens (ink housing + white glint). Check measures pixels on schtoxic: accent column run <= 4.5 px and >= 20 accent pixels.

SHIPPED (run c-02-art): step 5 (gun half), cw-gunshadow = v28.82 (commit 995b327f). gunHeld paints one rgba(0,0,0,.26) strip under the gun sprite
(D.rv[0]+ext+1, D.by+1.2). Check paints gunHeld on an offscreen canvas twice, once with the black translucent fillRect swallowed by a spy, and
requires >=150 pixels whose alpha differs. Gotcha: canvas fillStyle reads back as 'rgba(0, 0, 0, 0.26)' (with spaces), so regex with \s*.
Fingerprint held (85/374, 165/593).

Findings about what already exists in the game (so do not redo): 1px INK outlines on every body part, lit cloth ramps (spr15 drawRigPC, cHi/cLo),
vest with bandolier and pouches (cosm4, ~line 32113 and 32351), goggles hat with lens glints (~33169), gas mask glints, baked gun sprites (gunBake).
So steps 2-4 are mostly shipped in earlier versions; what is left of them is only polish.

SHIPPED (run c-03-art): step a, cw-castshadow = v28.85 (commit 5bfd6fe2). drawOp ground shadow is now shadowE(x+1.5,y+1.5,10,4,.34) plus a
second lobe shadowE(x+6,y+2.5,6.5,2.5,.18). Check paints drawOp offscreen with and without shadowE, takes alpha diff on rows >= y+3: centroid >= +1.0,
right reach >= 11.8, left reach >= -10.6. Fingerprint held. Next ship number is 28.86. Step a is DONE; remaining: b, c, d below.

SHIPPED (run c-60-art, 10-18): step b, cw-setplates = v29.43 (commit 212d9689). Heavy Plates vest: 2 scheme colour stripes + 6 bare steel chips (#dfe6ec).
Big Pauldron: lower lip, seam, 3 rivets, 4 chips. Raider round pad: 2 chips (spiked pad stays clean). All inside the old outline. Check renders drawVest/drawPads
offscreen at 4x, counts #dfe6ec pixels, samples the stripe pixels, asserts bbox no bigger than the old outline. Fingerprint held. Step b is DONE.
Not drawn on: Raider vestband / tachelm helmet (could get a chip or two later). No picture taken (no UI screen shows a worn set).
REMAINING: c (bake sprites; biggest, riskiest, perf only, no visible gain), d (before/after pictures and a 2P frame; needs a staging screen for a worn set, ask in questions.md).

NEXT (each its own cw- key with a pixel/draw-call check):
a. Soft cast shadow on the ground: drawOp starts with shadowE(x,y+1,10,4,.38); idea: shift it a little right/down (light top-left) and add a
   small second lobe toward the lit side opposite. Check old shadow-position checks first (grep shadowE in mkfixture.ps1).
b. Heavy/Raider set plates (chipped paint edges, panel stripes, chunkier pauldrons), only for outfit/hat sets heavy and raider.
c. Bake each look to an offscreen sprite per facing and walk frame (biggest, riskiest; gun and arms stay live).
d. Before/after pictures and a 2P frame are still owed.
Draft key numbers: next ship is 28.83.
