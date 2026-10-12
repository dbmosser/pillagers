# THE SPRITE PROGRAM (spr), 2026-10-12

His orders, verbatim: "improve the sprites of all characters, bots, etc -- spend time on that -- make them all look better";
answer 24 "b" (redesign the character silhouettes for readability first); answer 20 "a" (gritty and grounded like ARC Raiders);
the pitch "arc raiders but with zero seivert graphics and fortnite levels of arcadey pick-up-and-play fun"; and "you should be
taking images and using other best practices to make damn sure that the revisions ... actually look good".

This file is the critique, the style guide, the per-sprite redesign spec and the ordered build list (three parallel groups).
Built against HEAD 7c0816f5 (game v23.96). The gfxC chain (gfxsil, gfx13-gfx21) had drafts queued but not shipped when the
"before" shots were taken, so the shots show the game before both programs.

## 0. The tools and the pictures

- `window.__spriteSheet(o)` in `tools/mkfixture.ps1` (fixture commit 7a0e208f, "spr0: __spriteSheet ..."; smoke-tested on the rebuilt fixture: machinesA, machinesB, boss and people pages draw with no cell throwing). It draws through the game's OWN
  draw functions with `wc` swapped to an offscreen canvas in try/finally (G.t, G.deathAnims and wc put back), stages a COLD
  STORAGE raid with `__gfxStage` when none is live and abandons it after. Returns a data URL; per-cell throws are drawn as a red
  cross and listed on `window.__spriteSheetErr`.
  - `o.page`: `humans` (Lean, Broad, Curved x idle, walk A, walk B, sprint, aim+fire, reload, hurt, crouch, downed, facing
    left), `people` (player, player ADS fire, pillagers with armour 1-3, elite pillager, hire, bag full, teammate via
    `netUpDrawOne`, three Undercroft looks, Peddler, Peddler fleeing, Survivor, Survivor helped, pillager death), `machinesA`
    (Sentry, Crawler, Crier, Listener) and `machinesB` (Warden, Bulwark, Howler, Pillbox), each x idle, move A, move B,
    alert/hunt, firing, hurt, elite, damaged 30%, venting, death .3 s; `boss` (the Overseer idle, hunting, firing, hurt, 30%,
    beside a Warden, plus death frames); `playsize` (the whole cast at z=2 = a 4K TV at zoom 1 and z=1 = a 1080p laptop at
    zoom 1, on mid grey and on a dark floor).
  - `o.w` 3840, `o.h` 2160, `o.z` 6 (world units to pixels), `o.bg` '#7a7d80', `o.fmt` 'jpeg' or 'png', `o.q` 0.92.
  - Machine cells copy the render2D dispatch for one entity (elite ring, the kind's draw, the weak-point glows), so the sheet
    shows what play shows.
  - Every spr build should shoot the page it changes before and after (sprA-shot.ps1 in the scratchpad: `-Build` makes a fixture
    of HEAD with a `__gx` eval hook on its own shard port and headless Chrome 9370, `-JsFile` runs a file, `-Out` saves the image).
- The "before" shots, `tools/handoff/shots/sprites-before/`:
  - `sheet-humans.jpg`, `sheet-people.jpg`, `sheet-machinesA.jpg`, `sheet-machinesB.jpg`, `sheet-boss.jpg`, `sheet-playsize.jpg`
    (all 3840x2160 at 6x unless named).
  - `fight-4k-day-z1.jpg`, `fight-4k-day-z2.2.jpg`, `fight-4k-night-z1.jpg`: a staged fight on COLD STORAGE at 4K (sentry,
    crawler, warden, crier, listener, bulwark, howler, pillbox and two pillagers placed around the player, all hunting).
  - `crop-fight-night-1to1.jpg`, `crop-playsize-4k-dark.jpg`: 1:1 crops, the size a player actually sees them.

Scale facts that drive everything below (world units; 1 unit = 1 CSS px at zoom 1, so x2 on a 4K TV and x1 on a 1080p laptop):
a human is 34 tall (head 15x13, eye 3), a gun about 13 long and 3 tall; Sentry 46 tall x 36 wide; Crawler 21 x 30; Crier a
19-unit cube hovering 17 up; Listener 47 tall but 11 wide (limbs 3.4); Warden 46 x 38 (Overseer x1.47); Bulwark 50-unit slab;
Howler 36 x 32; Pillbox 44 x 52. At 1080p zoom 1 a human eye is 3 px and a gun is 2-3 px tall.

## 1. Blunt critique

### Across the whole cast
1. **Two styles that do not belong to one game.** The humans are chibi cartoons (big round anime eyes on a box). The machines
   are flat vector toys. Neither is gritty, neither is grounded, and nothing reads as ARC Raiders' machines. The pitch was
   ARC Raiders with Zero Sievert clarity; today it is closer to a mobile idle game.
2. **No light direction.** The Sentry has a lit top lip, the Warden a lit top band, the rest are flat fills. No sprite is lit
   from one side and shaded on the other, so nothing has volume.
3. **The outline rule is broken by the two most common enemies.** The game's own convention is an INK (#120e0c) contour, and
   the Warden, Pillbox, Listener, Bulwark, Howler and the humans have it. The Sentry and the Crawler do not. On the dark floor
   (crop-playsize-4k-dark, crop-fight-night) the Sentry's grey hull melts into the floor and only its glows read.
4. **The brightest thing on a machine is the wrong thing.** The weak points (orange and cyan discs at the tread corners of the
   Sentry and Warden, the wheel discs of the Pillbox) outshine the eye. At play size a Warden reads as "two coloured wheels".
   Weak points should be findable, but the eye is the face and must win.
5. **The colour language is muddled.** Amber means idle AND suspicious (Sentry, Crawler, Crier, Warden). Purple is the Warden's
   body, the Pillbox's body AND the elite marker (lilac ring). Red is the Crawler's whole body AND the hunting eye AND the foe
   team colour (gfxsil). Orange is a weak point AND overheat.
6. **Elite is a thin lilac ring on the floor, nothing else.** The body is identical. At 1080p the ring is 1 px.
7. **Damaged at 30% looks exactly like full health on every machine.** (gfx20 plates and gfx21 smoke are queued for this.)
8. **Move A and move B are the same picture for most machines.** The Sentry tread churn is 1.4 units, the Warden tread .6, the
   Bulwark, Howler and Pillbox have no motion at all, the Crawler's legs wiggle inside its own outline.
9. **Facing is half done.** The Warden and Sentry only flip the gun arm and head; the hull never turns. The Howler's mortar
   points up-left forever, whatever it is shooting at. The Crier spins its whole body like a sticker.
10. **Hurt is a colour swap.** Torso or hull painted pink-red (the Bulwark and Howler switch the body to brown-red #8a4a42).
    It reads as "it changed colour", not "it was hit". (gfx19 white flash and gfx15 flinch are queued.)
11. **Every death is the same flat oval blob**, human or machine, sized by radius. (gfx17 makes humans fall; machines still
    need wrecks.)
12. **The Overseer is a Warden at 147 percent.** No crown, no extra weapon, no unique eye. Nothing says boss.
13. **Glows are too big and too pink.** The Warden's hunting visor halo (radius 16) washes its whole face pink; the Sentry
    firing halo covers the whole hull. Additive pink over grey reads as "out of focus", not "dangerous".

### Humans (drawOp)
- **Lean and Broad are the same person.** Broad's torso is about 2 units wider; at play size they are pixel-identical
  (sheet-playsize). Curved reads only through lashes, lips, chest and hips, which is fine at 6x and invisible at 1x.
- **Everyone faces the camera, always.** Facing left only mirrors the gun. Aiming north, a body still looks at you. In a
  top-down shooter "which way is he looking" is the first question, and the only answer is a 1-px pupil and the gun.
- **The rig is a striped shirt.** The chest rig and belt are horizontal dark bands across the coat; on every coat colour it
  reads as a prison jersey, and on the Peddler's amber it is a bumblebee.
- **Hostile pillagers look friendly.** Same big round white eyes, same smile, as the player. Nothing about a pillager says
  threat except the red shoulder caps gfxsil adds.
- **Armour reads as an ice-blue barrel.** Tier 1-3 is a light steel box (good: a silhouette per tier), but the value is so
  light it becomes the brightest thing on the body and makes T3 a pale cylinder with a head.
- **The gun is a pale slab.** Light blue-grey, no dark receiver, no lit edge, at chest height; at 1080p it is a 2-px line
  that disappears on light floors.
- **Downed** is four flat blocks (gfx16 queued). **Death** is the blob (gfx17 queued).
- **The hire** is a pillager with a red bandana. **The teammate** is a pillager. **The player** has nothing that says "you"
  except the HUD.
- **The Peddler** is the striped bumblebee behind a table with three coloured squares. The lantern and its warm pool are the
  best thing in the whole cast and must stay.
- **The Survivor** is a pillager in green with a faint green halo. Without the halo (helped, or at night under the light map)
  it is a hostile pillager in every way that matters, which is how survivors get shot.

### Machines, one by one
- **Sentry** (the best of the set): tread base, hull, hazard band, sensor head, gun. But no contour, one flat grey value for
  hull and head, a hazard band that is a dull brown line, a thin single barrel, and the weak points as the brightest pixels.
  Reads as a grey filing cabinet on a skateboard at 1080p.
- **Crawler**: a red bench. Six legs hang straight down under a flat red box; there are no knees, no splay, nothing
  insect. The three-eye cluster is a good idea lost in one glow disc. Red body equals foe team colour.
- **Crier**: a grey square tilted 45 degrees and spinning, with a bulb on top and a faint ellipse for rotors. Reads as a picture
  frame or a dice. Nothing says "drone" or "it is going to shout". The ALARM ring and word are good and stay.
- **Listener**: the strongest concept (tall, thin, faceless dish) and the weakest draw: a stick man with a satellite dish,
  limbs 3.4 wide (2-3 px at 1080p), dormant a black mailbox. The red dish glow when awake is right.
- **Warden**: a purple dustbin on treads with a yellow letterbox and a stub. Purple (the elite colour) and toy-like. Hunting,
  the pink halo blanks the face.
- **Bulwark**: the shield reads (a tall riveted slab), but it is light blue-grey, the same steel as human armour, and the body
  behind it is a dark lozenge with a blinking dot and two pebbles for feet. Clipped from below at idle: the slab hangs below
  its own shadow.
- **Howler**: a black lunchbox with a tube stuck in it at a fixed angle. Smallest value contrast in the cast; on the dark
  floor it is gone (crop-playsize-4k-dark). The mortar never points at its target.
- **Pillbox**: a purple drum with seven lilac bubbles and a black porthole. The pipes read as candles or bubbles, the mouth as
  a speaker, the colour as elite. The venting puffs are peach dots.
- **The Overseer**: see 12 above.

## 2. SPRITE STYLE GUIDE (binding for every spr build)

**The target:** ARC Raiders' machines (industrial, worn, purposeful, one glowing sensor that tells you its mood) drawn with
Zero Sievert's top-down clarity (every actor a dark-contoured, high-contrast shape you can name in a quarter second), at
Fortnite's pick-up-and-play legibility (bold shapes, one accent colour per role, nothing fussy that matters).

1. **Silhouette first.** Every sprite must be nameable from its filled black shape alone at 1080p zoom 1 (z=1 on the
   playsize page). Test: draw it in INK only at z=1; if two kinds look alike, the shape is wrong, not the colour. Each kind
   owns one unmistakable shape feature: Sentry the tall sensor mast over a tread, Crawler splayed legs, Crier four rotors and a
   horn, Listener a dish on stilts, Warden the hunched heavy with a cannon arm, Bulwark the slab, Howler the fat tube on legs,
   Pillbox the pipe crown on a bolted plinth, human the head-and-shoulders over two boots.
2. **One light, from the top left.** Top faces get the lit value, the left edge a 1-unit lit rim, right and front-bottom faces
   the shaded value. Contact shadow under everything (the existing `shadowE`, unchanged sizes). No sprite may be lit from the
   right. The coloured light map lights them in play; the sprite only carries the form.
3. **Dark contour on everything.** INK #120e0c, 1.2 units, around each separate mass (not every internal part). This is the
   game's own rule; the Sentry and Crawler join it. Internal separations are 1-unit dark seams in the shaded value, not ink.
4. **Values: four per material.** Ink, shade, mid, lit. Mid to lit about +20 percent lightness (`litHex(c,.20)`), mid to
   shade about -40 percent (`darkHex(c,.42)`), the ramps the human coat already uses. A sprite's lightest non-emissive value
   must be its top surface, never its feet.
5. **Materials:**
   - *Painted metal* (machine hulls): faction paint in the 4-value ramp, a hard 1-unit lit edge on top corners, panel seams,
     2-4 rivets (1-unit dark dots with a lit pixel above), chipped paint as 2-3 fixed bare-metal flecks on edges (fixed
     positions in code, never rnd), a warm grime band in the bottom 20 percent.
   - *Bare metal* (guns, barrels, legs, pistons): cool gunmetal ramp, one bright specular line along the top.
   - *Rubber and tread*: near-black #1b1f24 with tread teeth one step lighter.
   - *Cloth*: matte, no specular, lit on the left shoulder and shaded down the right; straps and pouches as darker shapes.
   - *Skin*: the existing warm ramp, never inked inside the face.
   - *Lens and glass*: a dark socket ring, the emissive core, one white specular dot top-left.
6. **Palette by faction (saturation is a team signal):**
   - *Team colours own full saturation.* Ally blue #4aa3ff, foe red #e2483a (gfxsil's shoulder caps), and the player-2 colour.
     No body may use a saturated red or blue.
   - *The Machines:* machine grey ramp (#2a2f35 / #3e454c / #59626b / #7c868f) with ONE accent, hazard ochre #c8962e (stripes
     and chevrons, 2-3 of them, never a whole panel). Heavies (Warden, Bulwark, Howler, Pillbox) add oxide red-brown plates
     (#4e2419 / #7a3a2a / #9c5038), desaturated so they never read as foe red. The Crawler's shell is oxide too.
   - *The Overseer:* black gunmetal (#16191d / #262b31 / #3a4149) with brass trim (#8a6a2a / #c9a24a) and a deep red eye.
   - *Pillagers:* the six earthy coats, dark steel armour (#3a434c / #55606b / #75818c), olive webbing #4a4a32.
   - *Neutrals:* the Peddler warm amber lantern and leather; the Survivor washed-out civilian colours and the green #7fc4a0
     halo kept for the unhelped state.
   - *Elite:* lilac #d08ce8 stays the elite colour and becomes exclusive (no purple bodies anywhere).
7. **Sensor language (the machines' faces), the same on every machine:**
   - Idle or patrolling: dim cool white #dfe9f0 at 45 percent, a small core and no halo.
   - Investigating or suspicious: amber #ffc04a, small halo.
   - Hunting or locked on: red #ff3b30, pulsing, halo at most 1.6x the lens radius (today it is up to 4x).
   - Winding up a shot: the existing `drawWindupGlow` (red growing to a hot core). Unchanged.
   - Venting or overheated (the weak window): orange #ff8a3c flicker.
   - Dead: the lens goes black.
   - Weak points are NOT eyes: a recessed dark socket with a thin coloured ring in their own `WEAKPTS` colour, at most 60
     percent of the eye's brightness, glowing full only when hot (overheat), as today.
8. **Scale and detail.** Smallest meaningful feature 2 units (2 px at 1080p, 4 at 4K). Texture details (rivets, seams, flecks)
   may be 1 unit and may vanish at 1080p without loss. Limbs at least 4 units wide. The identifying emissive (eye) at least 3
   units across. Collision radii, `shadowE` sizes, nameplate anchors and the 34-unit human envelope never change.
9. **Facing.** A sprite with a front turns: the whole body mirrors with `fl` (not just the gun), and turrets and tubes rotate
   toward the aim. Humans get a back view when aiming north.
10. **Motion belongs to gfxC** (walk, recoil, flinch, downed, fall, hit pause, white flash, plates, sparks). spr builds keep
    every gfxC hook they find in a function (`animHitShift`, plate lists, `HITSIL`, `entT(e)` if present) and redraw the body
    under them. spr only adds poses gfxC does not (machine legs and treads that visibly cycle).
11. **Frame cost.** A live machine body at most about 40 fills and paths. Static parts are baked: a sprite cache keyed by
    kind, `fl`, elite, state bucket (idle, alert, hunt) and a scale bucket from `DPR*zoom` (LRU, rebuilt on context loss and
    on a scale change with the gfx6 bake budget), and the live layer is only the eye, glows, muzzle, windup, plates and hit
    flash. No `createRadialGradient` per frame (the Listener dish glow and the Peddler lantern do it today): use baked glow
    discs as graphics-design item 296 says. No `shadowBlur`, no `ctx.filter`, no `getImageData` per frame.
12. **Cosmetic only.** Never `rnd`, `rr`, `ri` or `pick`; no write to `e.*` (render state in a WeakMap); the seed 4242
    fingerprint (ents 85/374, containers 165/593) holds; the sim is untouched.
13. **His standing rulings in drawOp stay:** Toriyama proportions inside the 34-unit envelope and a face with pupils that
    track the aim (his answers, v5-v10), every BUILD (Lean, Broad, Curved) seen by every viewer with the Curved jiggle, every
    rack (hair, beard, hat, tattoo, patch, boots, pack, outfit) reaching pillagers and the crowd (his NOTE 17), guns never wear.
    Grit comes from materials, rigs, shading and the gun, not from shrinking the head or deleting the face.
14. **Proof.** Every build: the before and after sheet page at 6x plus the playsize page, LOOKED AT, and a check that fails on
    the previous build (a pixel or draw-call signature of the new sprite on an offscreen canvas).

## 3. Redesign spec, sprite by sprite

Coordinates in world units with feet at (x, y), facing right (`fl`=1); mirror with `fl`. Sizes are envelopes: stay inside
today's height and shadow.

### Humans (drawOp, drawBuildTorso, netUpDrawOne, drawPeddlerS, the stray branch)
- **Rig, not stripes.** Replace the horizontal dark chest band and belt with a plate carrier: a darker panel 9-12 wide x 7
  tall on the chest (coat `cLo`), two shoulder straps, three magazine pouches across the belly (2.6 x 3 each, olive webbing
  #4a4a32 with a lit top pixel), a belt with a buckle pixel. The coat shows at the shoulders, arms and below the rig.
- **Cloth shading by light.** Torso and sleeves: lit strip down the left (1.5 units, `cHi`), shaded strip down the right
  (2 units, `cLo`), replacing the horizontal bands. Trousers get the same left-lit treatment. Boots get a lit toe cap.
- **Builds that read at 1x.** Lean: torso 11 wide, slimmer arms (2.6), a visible neck gap. Broad: shoulders 18 across with
  gfxsil's caps outside them, forearms 3.6, boots 7, a thicker neck, the rig wider. Curved keeps BUILD_CURVED and the jiggle;
  she gets the rig cut to her outline (as the armour already is). Target: at z=1 the three are distinguishable by width alone.
- **The gun reads.** Receiver and barrel in dark gunmetal (#2a2f35 / #3e454c) with a 1-unit lit top edge (#8d98a3), the
  family silhouette kept (v7.77), the tier colour as a stripe on the top edge as today, two hands on it (support hand on the
  handguard). At z=1 the gun must be the darkest and the most horizontal thing on the body.
- **Armour tiers, dark steel.** Same three silhouettes (plate; plus pauldrons; plus collar and ridge), in dark steel
  (#3a434c / #55606b / #75818c) with olive straps, so armour reads as heavier and darker, not paler. T3 adds a helmet shell
  over the crown in the same steel (hats still draw over it per the rack rules).
- **Back view.** When the aim points north (`sin(face) < -0.55`) the head draws its back: skin, then the hair mass over the
  whole face area in the hair colour (a bald or crop head gets a darker crown and a neck line), no eyes, mouth, face marks or
  beard; hats draw as normal; the pack moves to the centre of the back over the torso; the gun is drawn before the body so
  the body covers its stock. Curved keeps her silhouette and jiggle. Facing south or sideways is today's front view.
- **Hostile glare (his call, ship with a side-by-side picture).** Pillagers (`team==='foe'`) get a 1-unit brow bar over
  each eye angled down to the nose and the round white trimmed to an almond (lower lid line), pupils still tracking. The
  player, teammates, the crowd, the Peddler and the Survivor keep the round eyes. Gritty without touching his face ruling.
- **Team identity.** gfxsil's shoulder caps (ally blue, foe red) are the team code. Add a 2-unit lamp on the left shoulder
  strap in the team colour, so a back view still reads. The hire: an amber hi-vis armband on the gun arm and ally caps.
  Player 2 and teammates: their seat colour on the caps.
- **The Peddler.** Through a new non-cosmetic outfit id in OUTFITS (`outpeddler`, never listed in COSMETICS): a long leather
  duster in warm brown (#5a3f28 / #7a5a3a / #9a7650) down to the boots, a wide-brim hat (wider than the head, the shape no one
  else has), a tall pack frame rising above his head with three hanging goods (a pot, a coil, a bottle), no rig, no gun. The
  stall: table with a cloth over it (a strip in a muted teal #3e5a58 hanging off the front edge), the three stock items drawn
  as their item icons' main colour in proper little shapes (box, roll, can) instead of squares; the lantern and its pool stay
  as they are (the glow becomes a baked disc).
- **The Survivor.** Outfit `outsurvivor`: a torn civilian jacket in washed grey-beige (#6e6a60 / #8a8578), no rig, no pack,
  no gun (mode 'crouchnone' already), a head bandage (two white bands, one with a dark red fleck), one arm raised with an open
  hand when the player is near and unhelped. Helped: stands (mode 'none'), arm down, halo off. At z=1 it must read as
  "unarmed civilian" without the halo: no gun, no pack, pale.
- **Downed and fall**: gfx16 and gfx17. spr only makes them wear the new rig colours if the downed figure reads the torso
  colours (it should, through the same `cc` ramp).

### Machines A
- **Sentry** (r 22, "tracked gun turret"). INK contour around the tread block, hull, sensor head and gun. Tread: dark rubber
  with 6 teeth that visibly cycle with `e.step` (offset `(step*6)%7`), two road wheels showing in the gaps. Hull: machine
  grey ramp, lit top plate and left rim, a sloped glacis on the facing side (a 4-unit bevel in the lit value), two ochre
  chevrons on the side skirt (not a flat band; red-orange when alerted is dropped, the eye says that), four rivets, a grime
  band. Head: a camera block on a short mast (mast 3 wide) with a round lens (socket ring 4.4, core 3) in the sensor
  language; a 1-unit whip antenna at the back that leans with movement. Gun: twin barrels (2 units each, 1 gap) under a
  perforated cooling shroud (3 dark dots), muzzle brake block; the barrels rotate to the aim as today. Whole body mirrors with
  `fl`. Weak points stay where they are, drawn as sockets. Elite: brass edge on the top plate and a second antenna.
- **Crawler** (r 15, "six-legged rush drone"). Low oxide shell in three overlapping segments (front 9, middle 10, rear 8
  wide, each lit on top with a dark seam behind), a sensor head forward with two mandible blades (gunmetal, lit edge) and the
  three-eye cluster as three separate sockets (no single big disc). Six legs splayed OUT: three per side, each a thigh rising
  from under the shell to a knee 3-4 units above and outside the shell line, then a shin down to a planted foot 12-16 units
  from centre. Legs in gunmetal with ink, opposite legs on opposite phase (tripod gait from `e.legs`), so walking visibly
  steps. Hunting: shell drops 2 units and the front legs reach forward (today's `lunge`). Elite: brass shell edges and a
  fourth eye.
- **Crier** (snitch, r 11, "loudspeaker drone"). A central pod (machine grey, rounded box 12 x 9, lit top) on an X frame
  with four rotor hubs; each rotor a pale blur ellipse (`lighter`, 25 percent) that spins (the blur, not the body). Under the
  pod a loudspeaker horn (a flared trapezoid 6 to 11 wide, ochre ring at the mouth) pointing at its facing; the lamp on top
  in the sensor language. Hover bob as today; the body tilts 0.1 rad into its travel instead of spinning. ALARM: the horn
  mouth glows red and the existing expanding ring and countdown arc come from the horn; the ALARM word stays. Elite: brass
  frame and a second lamp.
- **Listener** (r 14). Keep tall, thin, faceless. Legs become digitigrade stilts (thigh forward, shin back, a hoof foot),
  4 units wide; arms long to the knee with three hooked fingers; torso a narrow ribbed spine (3 rib seams); the dish 12 x 7
  with a raised rim (lit top-left), an inner ring of five sensor pits, and two fin "ears" behind it. Dormant: hunched (the
  existing 26 height), near black with only the rim catching light. Awake: straightens to 40, the pits glow red one by one
  and the dish centre is the red eye (baked glow disc, not a per-frame gradient). Elite: lilac-free; brass rim and a third
  fin.
- **Weak points (all kinds, dispatch).** Socket: dark ring radius 0.62 `rad`, a thin coloured ring at 0.5 `rad`, a small
  core; glow only at 35 percent idle, full when hot. Today's full disc glow drops to a ring.
- **Machine wrecks (drawDeathAnims, after gfx17).** A dead machine leaves its own body: the kind's baked sprite at 45 percent
  brightness, the eye black, settled 3 units down and tilted 0.12 rad, fading over 0.8 s over today's blob (gfxOnDeath's
  burst and smoke stay).

### Machines B
- **Warden** (r 30, "the heavy"). A hunched walker-tank: twin tracks under a wide trapezoid chassis (38 wide at the tracks, 30
  at the top), track links that cycle with movement, road wheels. Upper body: a heavy armoured torso leaning toward its
  facing (gunmetal with oxide plates on the shoulders and front), a head set low between the shoulders with the visor slit in
  the sensor language (halo at most 1.6x, not a 16-radius wash), a heavy cannon arm on the facing side (barrel 5 thick,
  muzzle block, a hydraulic piston behind it), and on the off side a launcher pod with a 2x2 rack of tube mouths. Two ochre
  hazard stencils on the plates, rivets, chipped edges, two exhaust stacks at the back. The whole hull mirrors with `fl`.
  Elite: brass trim on the plates, a lilac-free elite antenna.
- **The Overseer** (warden r 44, `e.boss` or the BOSS_NAME). Drawn from the Warden at its scale, then: black gunmetal and
  brass instead of grey and oxide; TWIN cannon arms; a crown of three sensor masts with red tip lights above the head; one
  big round lens eye (socket 7, core 5) in place of the slit; cable bundles hanging off the back; brass rivets. Its eye is
  always deep red #d0202a when hunting. It must read as "the boss" at z=1 from the crown and the twin arms alone.
- **Bulwark** (r 24, "shield bearer"). A squat biped: two stompy feet (6 x 4) and short legs, a hunched gunmetal body behind
  the slab, a sensor eye peeking over the slab's top edge (sensor language). The slab: dark gunmetal (NOT the light human
  armour steel), oxide edge trim, an ochre-and-black chevron band along its top 5 units, three rivets, the viewing slit lit
  in the eye colour. Keep the slab's rotation to the facing, and move the body to the opposite side so the slab is always in
  front; the slab's foot no longer drops below the shadow (shorten to 46 and raise 2). Elite: brass slab edge.
- **Howler** (r 20, "mortar"). Four short splayed legs (quad stance) under a round turret ring; a FAT tube (9 wide) with an
  ochre muzzle ring, tilted at 0.9 rad elevation and turned toward the facing (the tube's foreshortened direction follows
  `e.face`, mirrored with `fl`); an ammo drum on the off side; a red spotting lamp in the sensor language. Its lightest value
  is the turret top so it reads on dark floors. Elite: brass muzzle ring.
- **Pillbox** (choir r 26, "emplacement"). Keep the bolted plinth (gunmetal, four bolts lit, sandbag-like lumps at the corners
  in oxide grime). The drum in gunmetal with oxide plates. The pipe crown in brass (#8a6a2a / #c9a24a lit top) - seven organ
  pipes of different heights in a ring, still slowly turning; that is its name. The mouth: a big round port with a six-blade
  iris (thin dark wedges) that opens when live; the charge glow inside the mouth in the sensor language (red when live, orange
  when venting) instead of pink-violet. Venting: orange heat puffs rise from the pipe tops (where the vents are), not from the
  drum. Elite: lilac-free; brass crown gets a ring.

## 4. Ordered build list (keys spr1 ...)

Rules for every build: one sprite or one behaviour; a check that FAILS on the previous build; re-read the current function
first (gfxC edits the same ones); keep gfxC hooks; cosmetic only; shoot the sheet page and the playsize page before and after
and look at them. Ship through `bash shipq.sh KEY` with `mk-KEY.ps1`.

**Coordination with gfxC.** gfxC owns motion and damage in the same functions: gfxsil and gfx13-gfx19 in drawOp, gfx17 in
drawDeathAnims, gfx20/gfx21 in all ten machine functions. HUMANS starts after gfx19 has shipped (or re-reads drawOp before
each build). The machine groups keep any plate list, shed state, spark and smoke calls gfx20/gfx21 put into a function and
draw the new body under them; if gfx20 has not shipped when a machine build starts, the new body names its plate anchors so
gfx20 can place plates on the new silhouette. spr8 waits for gfx17.

**spr1 (shared, ship first, before the groups):** `MPAL` (the machine, oxide, brass and steel ramps above as constants),
`machEye(e)` returning the sensor-language colour and pulse for a machine's state, `sprSocket(x,y,r,c,hot)` (the weak-point
socket draw) and `sprBake(key,w,h,ox,oy,fn)` (an LRU sprite cache keyed by DPR*zoom bucket, rebuilt on context restore, at
most 2 bakes a frame). New code only; no existing function changes. Check: `machEye({state:'chase'})` is red,
`({state:'patrol'})` the dim white, `({overheat:2})` orange; `sprBake` returns the same canvas on a second call and a new one
after a DPR bucket change. Old build: the names are missing.

### MACHINES A (drawSentryS, drawCrawlerS, drawSnitchS, drawListenerS; the weak-point lines of the render2D dispatch; drawDeathAnims last)
1. **spr2 SENTRY REDESIGN.** Contour, tread teeth that cycle, lit hull, glacis, ochre chevrons, camera mast and lens in the
   sensor language, twin-barrel shroud, antenna, whole-body flip, elite brass. Check: a Sentry drawn on an offscreen canvas at
   z=6 has at least N near-INK pixels on its hull outline (old: almost none, it has no contour) and the idle eye core pixel is
   the dim white, not amber.
2. **spr3 CRAWLER REDESIGN.** Segmented oxide shell, splayed jointed legs on a tripod gait, three socket eyes, mandibles.
   Check: the inked footprint at z=6 is at least 1.6x wider than tall (legs out; old: a box), and two leg phases differ at
   the foot pixels.
3. **spr4 CRIER REDESIGN.** Pod, X frame, four rotor blurs, horn, tilt instead of spin. Check: drawn at two G.t values a
   second apart the pod's ink bounding box is the same (old: it spins), and there are four rotor ellipses (stroke count).
4. **spr5 LISTENER REDESIGN.** Stilt legs, ribbed spine, clawed arms, big dish with pits and fins, baked glow. Check: limb
   ink at least 4 units wide at z=6, and no `createRadialGradient` call during the draw (old: one per frame).
5. **spr6 WEAK POINTS ARE SOCKETS.** The dispatch draws weak points with `sprSocket`. Check: the brightest pixel of a Sentry
   at idle is its eye, not a weak point (old: the weak point).
6. **spr7 MACHINES A BAKED.** Sentry and Crawler static bodies through `sprBake`; the live layer is eye, glows, muzzle,
   windup, plates and flash. Check: fills+paths per Sentry draw at least 50 percent fewer than spr2 (counted with
   `__gfxCount`), and a pixel diff baked vs live under 2 percent.
7. **spr8 MACHINE WRECKS** (after gfx17). drawDeathAnims draws a dead machine's own darkened, settled, tilted body over the
   blob. Check: a sentry death at f .3 issues the Sentry body draw with an eye colour of black (or `drawImage` of its baked
   sprite); old: one ellipse.

### MACHINES B (drawWardenS and drawWardenAt, drawBulwarkS, drawHowlerS, drawChoirS)
1. **spr9 WARDEN REDESIGN.** Walker-tank hull, oxide plates, low visor (small halo), cannon arm with piston, launcher pod,
   cycling tracks, whole-hull flip, elite brass. Check: no purple-dominant pixels in the Warden cell (hue 260-300 with
   saturation over 25 percent, under 2 percent of body pixels; old: most of the body), and the facing-left drawing is the
   mirror (the launcher pod's ink is on the right).
2. **spr10 THE OVERSEER.** Boss kit when `e.boss` or the boss name: black gunmetal and brass, twin cannons, a sensor crown,
   one big lens, cables. Check: the Overseer's ink silhouette is not a scaled Warden (crown pixels above the head line; old:
   none), and brass pixels present.
3. **spr11 BULWARK REDESIGN.** Dark slab with chevron band and slit eye, body behind the slab, stompy feet, slab inside the
   shadow. Check: the slab's mean lightness is below the human armour steel mid value (old: above), and the slab's lowest ink
   row is above the shadow's bottom.
4. **spr12 HOWLER REDESIGN.** Quad legs, turret ring, fat tube turned to the facing, ammo drum, spotting lamp. Check: the
   tube's ink centroid moves to the other side when `e.face` goes from 0 to pi (old: fixed up-left).
5. **spr13 PILLBOX REDESIGN.** Gunmetal drum and plinth, brass organ pipes, iris mouth, red charge glow, venting from the
   pipe tops. Check: brass pixels in the pipe band and no lilac or violet in the mouth when live (old: #e0a0ff).
6. **spr14 MACHINES B BAKED.** Warden (and Overseer at its scale bucket), Bulwark, Howler and Pillbox static bodies through
   `sprBake`. Check: draw-call count per Warden at least 50 percent fewer than spr9; pixel diff under 2 percent.

### HUMANS (drawOp, drawBuildTorso, BUILD_BROAD, netUpDrawOne, drawPeddlerS, OUTFITS, the stray branch of the dispatch)
1. **spr15 PLATE CARRIER, NOT STRIPES.** The rig, straps, pouches and belt; light-direction cloth shading on torso, sleeves
   and trousers for all three builds. Check: on a lean body the count of rows across the torso that are mostly the dark rig
   colour drops (old: two full-width dark bands), and the left torso edge is lighter than the right.
2. **spr16 THREE BODIES THAT READ.** Lean slimmer, Broad bulkier (shoulders, forearms, boots, neck), Curved rig cut to her.
   Check: at z=1 the inked width of Broad's torso exceeds Lean's by at least 4 px at z=6 equivalents (old: about 2).
3. **spr17 THE GUN READS.** Dark gunmetal receiver and barrel with a lit top edge, two hands, family silhouettes kept.
   Check: the gun's mean lightness is below the coat's and the top-edge highlight row exists (old: the pale slab).
4. **spr18 ARMOUR IN DARK STEEL.** Three tiers in the dark steel ramp with olive straps; T3 helmet shell. Check: the armour
   mean lightness is below the old #8fa3b5 ramp and T3 has helmet pixels above the brow.
5. **spr19 THE BACK VIEW.** Aiming north shows the back of the head, the pack centred and the gun behind. Check: drawOp with
   `face=-pi/2` paints no eye-white pixels (old: two eyes) and the pack's ink is centred on the body.
6. **spr20 THE PEDDLER.** `outpeddler` (duster, wide hat, pack frame with goods), the stall cloth and stock shapes, the
   lantern as a baked glow. Check: a hat brim wider than the head row in his cell, no amber-black stripe rows, and no
   `createRadialGradient` per frame.
7. **spr21 THE SURVIVOR.** `outsurvivor` (washed civilian jacket, bandage, no pack, no gun, raised open hand near the player);
   helped stands. Check: no pack pixels and no gun pixels, the bandage white present, and the raised hand above the shoulder
   line when the player is within reach.
8. **spr22 TEAM LAMP AND HIRE BAND.** A 2-unit team-colour lamp on the shoulder strap (reads from behind), the hire's amber
   armband, player 2's seat colour. Check: a foe and an ally drawn back to back differ by the lamp colour in the back view;
   the hire has amber band pixels on the gun arm.
9. **spr23 HOSTILE GLARE** (his call: ship with the side-by-side shot, and say so in the why so he can veto it). Pillagers get
   the brow bar and the almond eye; everyone else keeps round eyes. Check: a foe body has brow ink pixels above the eye white
   and an ally body does not.

Overlap notes: spr6 (MACHINES A) and spr21 (HUMANS) both touch the render2D entity dispatch, on different lines (the
weak-point block and the stray branch); shipq serializes ships and regenerates drafts against HEAD, so they cannot collide,
but they must not be drafted from the same stale copy. spr1 is the only shared prerequisite. Nothing in MACHINES B touches
the dispatch.
