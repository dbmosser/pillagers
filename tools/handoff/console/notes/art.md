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

NEXT (each its own cw- key with a pixel/draw-call check):
a. Soft cast shadow on the ground: drawOp starts with shadowE(x,y+1,10,4,.38); idea: shift it a little right/down (light top-left) and add a
   small second lobe toward the lit side opposite. Check old shadow-position checks first (grep shadowE in mkfixture.ps1).
b. Heavy/Raider set plates (chipped paint edges, panel stripes, chunkier pauldrons), only for outfit/hat sets heavy and raider.
c. Bake each look to an offscreen sprite per facing and walk frame (biggest, riskiest; gun and arms stay live).
d. Before/after pictures and a 2P frame are still owed.
Draft key numbers: next ship is 28.83.
