# Character art build brief (his pick 2026-10-15 ~13:00): start right after the Sun 10-18 01:00 usage reset

His words: "Refined Chibi with Gear-heavy raider as may be appropriate".

The source of truth is tools/handoff/research/char-art-concepts.html (concept 1 REFINED CHIBI, concept 2 GEAR-HEAVY RAIDER) and shots/cosmetics/concepts-1080.jpg.

## Direction
- **Base: REFINED CHIBI.** Keep today's proportions (34-42 px tall at raid zoom), so nameplates, hitboxes, the aim ring and anchors do not move. Add:
  - four-step hue-shifted ramps lit from the top-left;
  - a 1 px ink outline;
  - cloth, metal and leather that read differently;
  - pouches and bandolier;
  - goggles or a visor with a glint;
  - a soft cast shadow and a gun shadow.
- **"Gear-heavy as may be appropriate":** borrow concept 2's gear where it fits the chibi frame:
  - chunkier armour plates, packs and pauldrons;
  - chipped paint edges and colour-panel stripes on armour;
  - glowing accent lenses on visors and helmets.
  
  Do this most of all on the Heavy and Raider sets and the heavy headgear, so the gear-heavy look is a set identity, not the default. Do not change the body height or lift the anchors.
- **Keep everything shipped in cosm1-cosm7:** the 19 schemes drive the ramps; the headgear, vest/pads and pack/boots slots stay, redrawn in the new style; the sets; the appearance tabs; the P1/P2 seat rings.
- **Fix in passing:** the neon green bar on the Heavy helmet that reads like a glitch.

## Build
- Bake each look to an offscreen sprite per facing (right, plus mirrored left) and per walk frame (6). Rebuild only on a look change, so the frame cost is one drawImage per layer.
- The gun and arms stay live (they rotate).
- The pillagers and the Undercroft crowd may reuse the rig with scheme swaps; the new headgear stays the player's alone.
- Small builds, each checked (fail on the previous build, pass twice), with the seed 4242 fingerprint held (85/374, 165/593).
- Before and after pictures at raid zoom, plus a 2P frame.
- Budget: ONE lean Sonnet agent, at most about 4% of the week.
