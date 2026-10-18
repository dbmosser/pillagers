# cw-barrels3: shock, toxic waste and dry ice barrels (his note 2026-10-18 15:47, build 30.73)

His words: "add other exploding barrels, e.g. electricity, toxic waste, dry ice".

Shipped as v31.06 (cw-barrels3, the kinds, the blasts, the sounds, the look) and v31.12 (cw-barrels3b, a thicker frost fog after the pictures).

## What was built
Three kinds beside the red one, all on the Forge effects (ELEM); no parallel status system:
- shock (yellow drum, black bolt, a blue spark jumps off the lid now and then): smaller blast (reach 150), stuns what it strikes (the gun's stun: a machine 1 s, a pillager 0.6 s, never a boss) and throws arcs on to the next bodies (the gun's arc, sent to the other window as the gun's are).
- acid (green drum, black trefoil, a drip runs down the side): smallest blast (reach 120), eats armour (elemShred) and corrodes (elemHit acid), a machine takes a quarter more, and leaves a green pool for 6 s that hurts the body in it and keeps eating its plate, and eats 3 plate a tick off a player standing in it.
- cryo (ice-blue drum, deep blue snowflake, wisps of cold rise off the lid): frost burst (reach 150): the middle (inside 75) freezes, the rim is slowed, and a frost fog stays 5 s and keeps chilling, so a body that stays in it freezes. Any barrel blast shatters a frozen crawler.
- red is untouched. All four chain: a blast lights the barrels in its reach whatever their kind.

## Placement (the stream and the map did not move)
No barrel added, no draw on any stream. The kind of each existing barrel is a pure integer hash of the raid seed and its rounded spot (brlKindAt). Mix: 55 percent red, 15 each of shock, acid, cryo (BRL_MIX). Measured over 20 raids, 541 barrels: red 55, shock 16, acid 15, cryo 13 percent. The seed 4242 fingerprint held on both ships: ents 85/374, containers 165/593. Every window of a party sees the same kind (same seed and spot), so player 2 reads the same barrels.

## Players, party, cost
- A player is hurt as by the red one: only by a barrel no player lit, or one he lit himself (no team damage); same rule for the pools and fog. Each window runs its own blast and pool copy; the host window runs the bodies; a linked window still shows the shards when a frozen crawler breaks.
- DEMO and CAREER identical (no mode branch).
- Drawing: a handful of canvas calls from constants and the clock, the pool and fog are one baked 96 px sprite (brlSpr) drawn a few times, no gradient or string made in a frame. G.bfire is capped at 40 as the fire pool was.
- Sounds on the existing bus, from the existing recordings (no new file): barrelShock, barrelAcid, barrelCryo (SPK cues, SPK_LVL, noise marks).

## Checks
- 31.06 (the new check): all four kinds in six seeds, about the mix, same kinds on the same seed, laying again moved nothing, the fingerprint, a real frame drawing all four and a pool and a fog, a real round into a shock barrel lighting an acid and a cryo barrel in a chain, each blast's effect on staged crawlers and a pillager, pools and fog tick and go out, a shatter, and the party rules as player 2 (not hurt by a teammate's barrel, hurt by my own, the host runs the bodies). It failed on the old build and passed twice on the new.
- 31.12: the fog cover measured on a recording canvas (about 2.4 of the square of its radius before and about 4.1 after, by the sums; the bar is 3.2).
- Older check retargeted (tools/mkfixture.ps1, commit 7dd304e2): the fire pool check (28.98) lights barrel 0 and now sets it red first, since barrel 0 could have been any kind.

## Pictures (tools/handoff/console/notes/shots)
- before: barrels3-before/b1-red-closeup-{1080,4k}.jpg, b2-red-blast-{1080,4k}.jpg
- after: barrels3-after/b1..b8 (close-up and blast of each kind), b9-lineup-four-kinds, b10-lineup-lit, b11-acid-pool, b12-cryo-fog, each -1080.jpg and -4k.jpg
- recipes: barrels3-recipes-before.json, barrels3-recipes-after.json (the camera can be rerun with tools/uishots.ps1 -Recipes)

## Critic
Ran on b1 (before) and b9 (after): 2 of 5, "same". Every finding is about the HUD around the barrels (corners, panels, toasts, the controls list), which other workers own, none is about the barrels. The score is the HUD's, not the barrels', so nothing was changed for it here.

## Notes for the next person
- The fog is a pale white-blue cloud; if he wants it icier, change the fills in brlPoolDraw (cryo branch) and keep the cover at or above 3.2 (the 31.12 check).
- Arcs of a shock blast share the 24-arc cap of G.arcs with the gun's arcs; the barrel throws 5 cosmetic ones round itself first.
- A chained shock/acid/cryo barrel keeps its own sound (the red one plays the lighter barrelChain).
