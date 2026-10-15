# COSMETICS: what is weak, and the plan (2026-10-15, v27.92)

His words: "player cosmetics still need major improvements". Party 10/30, 2-player DEMO. Bar: ARC Raiders grit, Fortnite pick-up fun, top-down 2.5D.
Pictures: tools/handoff/shots/cosmetics/before/ (c01 appearance default, c02 appearance unlocked, c03-c06 four looks in a raid at 1080p,
lineup-raid-7x.jpg the four cropped and enlarged 7x, c07 the 2-player staging). After pictures go in tools/handoff/shots/cosmetics/after-cosmN/.

## What is weak (seen, not guessed)

1. AT RAID ZOOM ONLY THE HEAD READS. The figure is about 45 px tall at 1080p. The held gun (GUNK 1.3) and both arms cover the torso, so
   the four test looks (default, Spartan/moss/broad, hood/rust/curved, ghost mask/indigo) differ in the head and almost nowhere else.
   The clothing colour (moss, rust, indigo) is invisible: the plate carrier is drawn in a near black ramp of the coat (rg = darkHex(cc,.30)),
   so the coat only shows as a sliver of lit cloth at the shoulders.
2. THE HERO'S SLEEVES ARE ALWAYS NAVY. The player body call passes coat '#242832' (arms and gun sleeve), while other bodies pass their fit
   colour (netUpDrawOne passes fit[1]). Your own gun arm never matches your clothes, but your teammate's does.
3. EVERY LOOK HAS THE SAME OUTLINE. Hats are flat 3-5 unit bars (band, cap, beanie, bandana); the pack is one rounded box that changes colour only
   (PACKCOL), hidden behind the body when facing left; boots change colour only; shoulders are two team-coloured caps that are the same on every
   look. Nothing changes the silhouette except BUILD (Lean, Broad, Curved) and the hood/Spartan/ghost mask.
4. A TWO-PLAYER FRAME CAN BE TWIN BODIES. Both players wear ally-blue shoulder caps and the ally lamp; two fresh profiles are the same default
   operator. The other player only carries the racks (NET_LOOK) and a name over his head; your own body carries no seat mark at all.
5. THERE IS NO COLOUR SYSTEM. Clothing is one of 11 coat colours; boots, pack and gloves are separate unrelated colours, so a matched
   look takes five clicks across five racks and still reads as a random mix.
6. NO COMPLETE LOOKS. The only complete looks are the 8 novelty suits (Skeleton, Machine...) that overrule everything, and 3 saved slots.
7. THE APPEARANCE SCREEN: 15 racks in one tall scrolling wall (OUTFIT, BUILD, SKIN, EYES, FACE ... BACKPACK), no categories; the preview is a
   small front-on picture in a 260 px column, cut off by the slot list, never moves; the tiles are mostly empty space; no rarity read.
   What is GOOD and stays: the locked tiles already say how to earn them in caps (12 EXTRACTIONS, PUT 3 WARDENS DOWN (0 OF 3)), slots on the
   left switch the racks on the right, SURPRISE ME and the 3 saved looks.

## Plan: small builds, keys cosm1 onward (each: one behaviour, a check that fails on the build before and passes twice)

- cosm1 THE THREE-PART COLOUR SCHEME. New rack SCHEME (profile cosScheme, default Standard Issue = exactly today's look). A preset is
  primary + secondary + accent. Primary paints the coat, sleeves and trousers; secondary the plate, pack and boots (anything left at its
  default rack id; an item you chose wins); accent is a bold trim: a band on the gun arm, a rank stripe on the plate, the pack flap, boot
  collar. 12 presets chosen to read on the dark ground (Ember, Frost, Verdant, Crimson, Royal, Dune, Carbon-Toxic, Nightshade, Brass, Whiteout,
  Gilded...), four always owned, the rest earned like the other racks. The hero sleeve now follows the clothes (item 2). Carried across the
  two-window link (NET_LOOK + netUpDrawOne) and kept in saved looks. Old saves: no field means Standard Issue; old cosFit ids still work.
- cosm2 TWO PLAYERS NEVER LOOK ALIKE. A seat mark on every human body when a party is on: a seat-coloured ring under the feet and a small
  numbered chevron over the head (P1 amber, P2 cyan), both seen from either window, on top of the existing name. And in a party, a body left at
  Standard Issue plus the default clothes wears its seat's preset (P1 Ember, P2 Frost), so two fresh profiles are still different at a glance.
- cosm3 HEAD LAYER. Six new headgears that change the head silhouette at raid zoom (Boonie with a wide brim, Tactical Helmet with ear pro and
  lamp, Hard Hat, Gas Mask with filter, Goggles-up cap, Heavy Helmet with a ridge), each trimmed in the scheme accent, ears and grit edges kept.
- cosm4 BODY LAYER. Two new racks in BODY: VEST (plate carrier stays default; light harness, bandolier, utility vest, heavy plates) and
  SHOULDER (none, round pads, spiked pads, one big pauldron), drawn over the carrier so shoulders and chest change the outline.
- cosm5 PACK AND BOOT SHAPES. Pack shapes (bedroll, radio with antenna, jerry can, frame pack) drawn on the pack side, boot shapes (shin guards,
  tall gaiters), all in the scheme colours.
- cosm6 OUTFIT SETS. SETS rack of complete looks built from the layers: SCAVENGER, RAIDER, ENGINEER, RECON, HEAVY (plus single items to mix after).
  A set applies its parts and scheme in one click and is owned when every part is owned; the locked tile names the first missing part.
- cosm7 THE APPEARANCE SCREEN, same modal, one control per job: a large turntable preview (facing turns slowly, left panel widened), category
  tabs HEAD, BODY, PACK, COLOURS, SETS above the racks (the slot list keeps working and jumps to its tab), rarity frames on tiles (common to gold
  from the unlock requirement), locked tiles keep the caps requirement.
- cosm8 PICTURES AND FRAME COST. Bake the static layers if the frame cost grows (measure drawOp before and after), both-players DEMO picture,
  final before/after contact sheet.

## Rules kept
Cosmetic only (no hitbox, speed or stat); no draw from the seeded stream (G.t and entity fields only); seed 4242 fingerprint (ents 85/374,
containers 165/593); every new profile field has a default and old ids map; every new line of text in the game's caps HUD voice; his rulings
stay (Curved stays clearly female, the 2026-10-08 build ruling; cosmetics are earned; toggles).

## STATUS (updated as builds ship; the scripts are in the session scratchpad mk-cosm*.ps1)
- cosm1 SHIPPED v28.04 the colour scheme (19 presets, three colours, sleeve follows clothes, old clothing ids map to their scheme twin).
- cosm2 SHIPPED v28.09 two players never look alike (seat ring and number badge in a party; same scheme at two seats goes to the next free preset in both windows).
- cosm3 SHIPPED v28.16 six headgears (boonie, tactical helmet, hard hat, goggle cap, gas mask, heavy helmet).
- cosm4 SHIPPED v28.13 vests (bandolier, light harness, utility, heavy plates) and shoulder pads (round, spiked, big pauldron).
  FAULT FOUND IN IT by running the older appearance checks against it: the vest line sat between the plate carrier and its else, so every default body got the old dark chest band. Fixed by cosm4fix (see below).
- cosm5 SHIPPED v28.12 pack shapes (bedroll, radio, fuel can, frame pack) and boot shapes (shin guards, tall gaiters).
- cosm6 SHIPPED v28.18 outfit SETS (Scavenger, Raider, Engineer, Recon, Heavy), owned when every piece is.
- cosm4fix, cosm7 (the tabbed appearance screen with a turning picture and rarity bars) and the older-check retargets (v10.54, v9.99, v10.47) are in the ship queue.
- Frame cost measured (drawOp, minimum of nine batches of 1500): hero body 77-90 us before, 103-112 us after; a pillager body 75-96 us before and after. Nothing needed baking.
