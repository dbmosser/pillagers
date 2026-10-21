# Pixel style sheet (job 86a, v33.51; every pixel job 86b to 86j follows it)

Match tools/handoff/art-survey/style-test/ (pix.js, pillager.js, machine.js, ground.js) and his lineup picture ref-his-lineup.webp. Plan: notes/pixel-plan.md.

## The switch
- CFG.xfPix, Settings, experimental, extras group, "pixel look", scope l, on by default. pixOn() gates EVERY pixel path. Off is today's game byte for byte.
- The fixture pins xfPix 0 (load, __resetCfg, __pinDefaults). A pixel check sets CFG.xfPix=1 and restores it in finally. notes: pixOn can be stubbed in a check (see the 86a kit check).
- Extend the smoke check (v33.53 cw-pixsmoke, tools/mkfixture.ps1, search pixFaults) when you add a scene or a kind.

## Density
- PIX_ACT = 1 world unit per art px: pillagers, sets, machines, wrecks, wildlife, containers, barrels, power-ups.
- PIX_ENV = 2 world units per art px: ground, walls, doors, windows, trees, bushes, shadows, cover, furniture.
- A sprite carries its own d (pixSprite(canvas, ax, ay, d)). pixBlit draws it at S = ZOOM() * d device px per art px.
- ZDEFAULT is 1.0 (v33.50): 1080p is S = 1 for actors and 2 for the scene, 4K is 2 and 4. Other scales are sharp-bilinear (nearest prescale to ceil(S), then smooth).

## Rules for a painter
- Whole pixels only: no anti-aliased arcs, no gradients, no dither inside a sprite. Build masks (Uint8Array) and fill with pixel centres.
- 4 tones from pixRamp(base) (warm light, cool shade) or a hand ramp; tone by position along the top-left light with pixTones(mask, w, h). Hand-place folds and speculars on top.
- Actors get a 1 px ink ring in PIX_INK #16121c (pixRing(canvas, PIX_INK) grows the art by 1 px each side: the anchor moves by +1,+1). Scene props get only a bottom and right edge in their own dark tone, no ink ring.
- Value bands (lightness percent), kept from the district palette: floor 42-50, wall face 54-60, wall top 72-78, actors and loot 80-94. Night keeps the order and the gaps, lower (PIX_BANDS.night). Read colours from PIXRAMPS (districts, plants, mb, skins), never hard-code a second palette.
- Red means enemy (pillager bots). No clothes in red, none in a seat colour (orange, cyan, lime, pink).
- Randomness: grit(x, y) and your own hash only. NEVER rr(), never Math.random(): the simulation, the seeds and the 4242 fingerprint must not move, and two windows must bake the same pixels.
- Rotation happens at art resolution (guns 32 steps, machine parts 16, topple 8), never on a finished sprite. Flash, pulse, elite ring and gold come from pixSilhouette / pixRing / pixSwap masks built at bake time. No getImageData at draw time, no ctx.filter per frame.

## Caches and budget
- Every baked sprite goes through pixFetch(kind, key, buildFn, family, pose): kind is 'actors' (24 MB cap) or 'scene' (16 MB cap). LRU by bytes. Key includes everything that changes the pixels (ramp, ink, look, flip, pose step).
- At most 2 builds or 2 ms of baking per drawn frame. A miss draws the nearest cached pose of the same family; with none cached pixFetch returns null: draw the old vector painter. Never leave a hole.
- A throw inside a builder is caught (PIX.errs); a draw that throws is logged as DRAWERR and the body is drawn in vector.
- Register every asset with pixReg(name, fn) so ?pixbench shows it at 1x and 4x. The bench also lists the ramps.
- G.tel.gfx.pix = {builds, ms, hits, miss, refused, bytes, S}.

## Pixel pillager look map (86c, 86g, 86h)
- pixLook(lk) maps netLook() (18 fields) to {head: short|long|hood, skin: fair|tan|umber, clothes: scav|recon|heavy, set: none|skeleton|trooper|android}. A set overrides the other three while worn. pixOwned(id) says what he may wear. Neither writes anything.
- Copyright: trooper and android are inspired by Master Chief and 2B. Original shapes, no names, logos or traced art.

## Words
- All lower case on screen, short, SP for score, $ for money, "pillager" and "pillager bots". Same as the main rules.
