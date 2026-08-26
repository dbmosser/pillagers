> **SUPERSEDED, 2026-08-22.** `C:\Users\User1\Desktop\DARK_RAIDERS_SPEC.md` is now the definitive design document and governs wherever it conflicts with anything below. This file is retained as the build history and the record of what was measured and why. New design decisions live in the spec; this remains the changelog.
# DARK RAIDERS Design Bible
Prepared: August 20, 2026. Revised: August 20, 2026 (v0.6).

Single source of truth for the game's design intent. Add this file plus the latest `dark_raiders.html` to a Claude Project so every new conversation starts with full context. Update the changelog each version.

## 1. Pillars
1. **ARC Raiders' loop, 3/4 view.** Deploy, loot under pressure, decide when to leave, extract or lose it. Tension comes from the timer, the noise system, and what you are carrying.
2. **Information is the game.** Vision cone, fog, noise pings, scan cones, the snitch. You fight what you know more than what you see.
3. **Death costs, but does not zero you.** Safe pocket, stash, rep, and contracts persist. A death should sting and teach, not erase.
4. **Operators versus machines.** Raiders (the player and AI raiders) are human operators. The machines are industrial robots with readable patterns: the sentry patrols with a visible scan cone, the crawler rushes, the snitch drone flees and marks. AI raiders behave like players: loot, fight, run for the same extract you want.

## 2. Core loop
Kennel hub (sell, craft, buy, take contracts, tune) -> Deploy -> Loot and fight -> Extract before the timer -> Bank haul, claim contracts, upgrade -> repeat. Death loses carried loot minus the safe pocket, and the equipped weapon.

## 3. Presentation (v0.8)
StarCraft-style 3/4 2D view over the unchanged simulation. Flat baked ground, walls with raised top faces (26px buildings, 14px cover) and shaded front faces, everything drawn in one y-sorted painter's pass so characters walk behind walls and peek over low cover. Characters are upright pixel sprites with feet at their world position: human operators with visors, walk cycles, true-angle gun rotation, and backpacks that swell with loot; treaded sentries with glowing state-colored eyes and wall-clipped scan cones on the ground; four-legged crawlers; hovering diamond snitch drones with blinking beacons. Cursor aiming: the mouse is the reticle, WASD moves on world axes, right mouse steadies aim (60 percent spread, slower movement, camera leans further toward the cursor). Camera follows the player with cursor lean and screen shake. Atmosphere: dynamic lights punched through a darkness overlay with warm glows and flicker, muzzle light splashes, vision-cone fog of war with rear ambient awareness, decals, shell casings, and an extract beacon light shaft. No dependencies: fully offline, no WebGL needed.

## 4. Systems
- **Vision:** recursive raycast visibility polygon; forward cone (CFG.coneDeg wide, CFG.viewFar deep) plus all-around awareness (CFG.ambient). Smoke clouds add temporary occluder segments.
- **Sector map:** hold M for the full map: all walls, buildings tinted by district, all three extract rings with the active beacon highlighted, and your position. Hostile positions are never shown.
- **Noise:** every loud act emits a ping (radius scaled by CFG.noiseMult) that pulls enemies to the point of origin. Crouch is near-silent, sprint is loud.
- **Enemies:** Sentry (ranged treaded patroller, visible scan cone), Crawler (melee rusher), Snitch (never attacks: flees, marks your live position with hostile pings every 1.5s, converging everything on you; kill it or break line of sight for 3s), AI Raiders (operators that loot, fight, extract; drop their bags on death).
- **Dodge roll:** Space performs a Dark Souls style roll in your movement direction (facing if standing still): 0.38s tuck at high speed with 0.3s of invulnerability frames, costs 25 stamina, 0.85s cooldown, makes a small noise. No shooting or throwing mid-roll.
- **Field weapons:** guns spawn as loot in lockers, safes, and bodies, and every AI raider drops their own gun on death. Picking up a strictly better gun auto-equips it (half a magazine loaded) and moves your old one into your bag; extract to bank guns into your armory, and the safe pocket can save a carried gun from death. Ammo is a shared reserve pool. Starting reserve is 2 magazines, so scavenged ammo matters.
- **Downed state:** at 0 HP you go down instead of dying: crawl at 30 speed, bleed out over CFG.downTime, one self-revive per raid with F plus a medical item (back at 40 HP, 2s invulnerable). Getting shot while down cuts 3s off the bleed-out clock. Machines ignore a downed player; raiders finish the job.
- **Throwables:** smoke (blocks all sight lines through it, 12s), decoy (fake noise pings for 6s), frag (95 radius, friendly-fire on you). Q cycles, G throws toward cursor, max range 270. Pouch auto-loads up to 2 of each from stash on deploy; unused come home on extract.
- **Safe pocket:** your CFG.safeSlots highest-value bag items survive death to stash. Marked with a diamond in the Tab bag view.
- **Economy:** sell salvage for credits and rep; rep gates shop stock (frag 600, plate 800, SMG 1000, pack tier 3 at 1500, rifle 2500, DMR 5000). Backpack tiers cap carry weight at 40/60/80.
- **Crafting:** Workshop turns junk into Component Kits (3 scrap + 2 wire), and components into ammo, armor, medkits, and all three throwables.
- **Contracts:** three procedural contracts (kill X, search container type, search in district, extract carrying item, extract with haul value). Claim pays credits plus rep, then rerolls.
- **Tuning console:** backquote key or hub button. 19 live sliders over every tunable, presets A (Shadow: darker, slower, richer), B (Baseline), C (Surge: brighter, faster, deadlier). Copy config exports the JSON for Claude.
- **Bot sim:** hub button runs CFG.simRaids headless raids with a bot playing the player role, and reports extract rate, death causes, timer expiry, average haul, first-contact timing. Healthy extract-rate band: 35 to 60 percent.
- **Flight recorder:** full per-run telemetry, feeling tags, pause notes, Export for Claude (includes active config and last sim).

## 5. Config reference (DEF values)
coneDeg 100, viewFar 440, ambient 100, raidSec 300, pSpeed 158, extractTime 6, nSentry 7, nCrawler 9, nRaider 3, nSnitch 2, eDmg 1.35 (multiplier on damage the player takes), eHp 1, lootMult 1, contDens 1, noiseMult 1, safeSlots 2, downTime 12, simGreed 26 (bag weight at which the sim bot heads for extract), simRaids 30. Spawn counts, eHp, contDens, raidSec apply next raid; everything else is live.

## 6. Changelog
- **v0.1:** core loop: procedural map, cone vision and fog, noise pings, sentries and crawlers, 3 AI raiders, containers and loot, weight, weapons, extraction, timer, stash, shop, persistence.
- **v0.2:** visual overhaul: four districts with palettes, baked ground detail, dynamic lights, redesigned entities, screen shake, tracers, casings, decals, sector map.
- **v0.3:** flight recorder: per-run telemetry, pause notes, feeling tags, aggregate stats, Export for Claude.
- **v0.4:** tuning console with presets, headless bot sim, snitch, throwables, downed state with self-revive, safe pocket, crafting, contracts, vendor rep gates, backpack tiers, alert markers, configurable everything. Fixes: enemy damage double-scaling, bullets versus downed player, auto-loaded ammo.
- **v0.5:** renamed to Bark Raiders. 3/4 StarCraft-style presentation: y-sorted painter's rendering, walls with raised top faces and shaded front faces, all characters redrawn as upright sprites. Player and AI raiders are bipedal anthropomorphic dogs (walk cycles, wagging tails, aimed guns, loot-swollen backpacks); machines redesigned as canine robots (mastiff sentry, robo-pup crawler, eared snitch drone). Simulation untouched.

- **v0.6 (first playtest response):** dodge roll with i-frames; field weapons as loot with auto-equip upgrades and armory banking; ammo economy rebuilt (2-mag start, heavier ammo drops, sentries drop ammo, raiders drop their guns); enemies faster and deadlier across the board (speeds, damage, fire cadence, eDmg baseline 1.35); full sector map without hostile positions; bag is now a TAB or I toggle; persistent one-line key legend on the HUD. Saved tuning configs from v0.5 are reset once so the new combat baseline takes effect.
- **v0.7:** renamed to Dark Raiders, dog theme removed (same save key, progress carries over). Experimental third-person 3D with three.js: pointer-lock mouse look, ADS, shoulder camera. Superseded same day.
- **v0.8:** third person scrapped on playtest verdict; returned to the 3/4 StarCraft-style 2D view, rebuilt de-dogged: human operator sprites, industrial machines, y-sorted walls with top and front faces, vision-cone fog, dynamic lighting overlay, sentry ground cones, cursor aiming restored. Kept from v0.7: right-mouse steady aim (tighter spread, slower move, longer camera lean). three.js dependency removed, so the game runs fully offline again. Simulation, recorder, tuning console, and bot sim untouched throughout.

## 7. Backlog (not built, in rough priority)
Weapon rarity tiers (deferred: save-schema risk), weather and time-of-day conditions, location-based quest chains, vendor personalities, gear condition and repair, more machine types (Rocketeer analog: arcing projectiles; Bastion analog: shielded), hideout upgrades, multiple maps, keyed rooms, proximity events, operator cosmetics, co-op (hard wall: requires real netcode and an engine move to Godot).

## 8. Telemetry protocol
1. Daniel plays at least 3 runs, tags feelings, notes anything mid-run via pause.
2. Optionally runs the bot sim after any tuning-console changes.
3. Hits Export for Claude, pastes the block into chat.
4. Claude reads tags plus numbers plus config, proposes one batch of tuning changes with reasons, ships the updated file. One batch per cycle; no speculative changes without data.

## 9. Session protocol for a Claude Project
Project knowledge should contain: this file, the latest dark_raiders.html, and the most recent recorder export. Each new session: state the version, paste new exports, ask for the next build. Claude overwrites the game file in place and re-presents it; no version sprawl.

## 10. Known limits
Game feel cannot be specified in text; Daniel's playtests are the only feel signal. The bot sim measures balance, not fun. Netcode and true co-op are out of scope for the HTML prototype. Storage key remains `salvagerun:profile` from before the rename so existing progress carries over; do not change it without a migration. As of v0.6 the game saves to the claude.ai artifact storage API when present and falls back to browser localStorage when opened as a local file, so local play in Claude Code workflows keeps its save. The two stores do not sync with each other. As of v0.8 the game has no external code dependencies: no WebGL, no three.js, no libraries. It is not strictly offline, though. The stylesheet still @imports Oxanium and Roboto Mono from Google Fonts, so with no network the game runs normally but falls back to the browser's default sans-serif and monospace faces. Confirmed in v0.22: those two stylesheets are the only external resources the page requests.
- **v0.9 (auto-iteration tick 1, correctness only):** Fixed enemy patrol cooldown being decremented twice per frame, which made sentries, crawlers, and raiders repick wander destinations every 1.5 to 3.5s instead of the intended 3 to 7s. Version number is now a single `VER` constant driving all three strings (title-screen brand, flight recorder export header, config copy line); the config copy line previously carried no version at all. No tuning values changed.
- **v0.10 (auto-iteration tick 2, correctness only):** Sprint now requires actual movement input. Holding Shift while standing still drained stamina at 26/s to zero in under 4 seconds, which silently locked out the dodge roll (25 stamina) for no benefit, widened the crosshair, and inflated the flight recorder's sprint-time figure with stationary time. No tuning values changed.
- **v0.11 (auto-iteration tick 3, correctness only):** Bare Hands can attack. `fists` has `mag:0` and the fire path did `if(p.wep.mag===0){ p.lastShot=now; }`, swallowing the input without ever calling `fireWeapon`, so the fallback weapon after losing your gun and armory was completely inert. The HUD already printed MELEE for magazine-less weapons, so the UI was built for a working melee. Melee now swings for free, uses the thud sound instead of a gunshot, and ejects no shell casings or muzzle flash. No tuning values changed.
- **v0.12:** Auto-export. The full flight recorder now writes itself to the browser's download folder as `dark_raiders_runN.txt` every time a run is closed out, so telemetry no longer has to be copied and pasted by hand. Hub toggle `Auto-export: ON/OFF` next to Export for Claude; defaults ON for new and existing saves. No tuning values changed.
- **v0.13 (extraction rework, requested):** Extraction is now three phases instead of a 6 second hold. Stand in the ring and press E to call the beacon, which fires a loud hostile noise ping at the ring (radius 700) so every machine and raider in earshot converges on it. The inbound wait runs on the new `extractWait` tunable (DEF 25s, slider 8 to 60); you are free to move, fight, or keep looting during it. When it lands you must be standing in the ring or the beacon leaves without you and has to be called again. Removed the `extractTime` config key and its slider; old saved configs carrying it are ignored harmlessly, since `applyCfg` only copies keys present in DEF. Beacon light shaft now brightens, widens, and pulses faster as the landing approaches. Recorder and bot sim both report beacon calls and missed landings. Also fixed the `closestExt:1000000000` sentinel leaking into exports on runs that ended instantly; it now reads `none`.
- **v0.14 (correctness only):** Fixed a heuristic left stale by v0.13. The sim bot decided to head for extraction at a hardcoded `G.timeLeft<75`, a constant that silently encoded the old 6 second extract hold. With `extractWait` now tunable to 60s, the bot was committing to the beacon without enough clock left to sit through the landing, so it thrashed between approach and re-call and the sim's timer-death figure measured the heuristic rather than the balance. Threshold is now `CFG.extractWait+50`, identical to the old value at the 25s default. Calling the beacon with less raid clock left than the inbound wait now says so instead of failing silently. No tuning values changed.
- **v0.15 (correctness only):** Extract zones can no longer overlap. The three rings were each placed independently with only a "further than 900 from spawn" rule and no separation from one another, so two r=78 rings landed within 156 of each other on 2.9% of placements (measured over 500 generated maps, minimum separation seen was 21, effectively concentric). On the sector map that reads as a rendering fault and hides an extract option. Placement now also requires 420 between rings, with a best-effort fallback that never fails generation. Measured after the change over 500 maps: zero overlaps, minimum separation 420, fallback path never taken, spawn-distance rule unaffected. No tuning values changed.
- **v0.16 (readability pass, all requested):** (1) Enemy nameplates. Machines now carry stencilled unit designations (SENTRY K-44, CRAWLER H-12, SNITCH N-07) alongside the raiders' existing callsigns, shown above anything currently in your vision, tinted amber or red when that unit is hunting you, with a health pip once it is wounded. On death the name rises from the body as `NAME DOWN`. (2) Loot readout. Every item found now floats up from the container as its own line, coloured by rarity, showing value or the ammo/armour gained. The old single `Found:` HUD line was too easy to miss. (3) Inventory. TAB now opens a real inventory panel: equipped weapon with damage, range, fire mode and live ammo, body integrity and armour, the throwable pouch, then the bag with values and safe-pocket diamonds. Added a standing `TAB INVENTORY` cue to the HUD and rewrote the opening line to teach TAB, E and M, because the bag was previously findable only from a dim fourteen-item legend. (4) Out-of-combat regeneration: after `regenDelay` seconds without firing or being hit, integrity returns at 1 HP per `regenSec` seconds. New tunables `regenDelay` (DEF 10) and `regenSec` (DEF 3), both on sliders. Recorder logs HP regenerated per run.
- **v0.17 (graphics pass, slice 1 of 3: machine scale and silhouette):** All three machines are substantially bigger and redrawn. Collision radii sentry 16 to 22, crawler 11 to 15, snitch 9 to 11. Every sprite dimension is now derived from a scale factor off `e.r` (`SENTRY_R0`/`CRAWLER_R0`/`SNITCH_R0`) so visual bulk and the simulation can never drift apart, and nameplate height comes from a shared `spriteTop(e)` instead of hardcoded per-kind offsets. Sentry is now a hulking tracked gun platform: churning tread blocks, armoured hull with a hazard stripe that goes red when alerted, shoulder plate, raised sensor head, and an eye that pulses inside a swelling halo while hunting. Crawler gained six scuttling legs, a segmented carapace, mandibles, and a forward lunge stretch when it commits to a rush. Snitch gained a rotor blur ring that spins faster while it is marking you. **Balance side effect, measured not guessed:** larger hitboxes make machines easier to shoot. Bot accuracy across three 30-raid sims went 35/39/38 (mean 37) against a very stable 28/29/28/29/28/29 across the six prior sims. Extract rate 17/13/13 is within the existing noise band. Remaining slices: operator walk and reload animation, then lighting and effects polish.
- **v0.18 (graphics pass, slice 2 of 3: operator animation):** Operators (the player and AI raiders) are properly animated. The old "walk" was two leg rects sliding up and down on a sine; there is now a real stride: each leg swings along screen x and lifts on its forward half, with a torso bob that peaks on each footfall, a lean into the direction of travel, and a slow breathing rise when standing still. Sprint widens the stride, deepens the lean and drops the weapon off the shoulder. Steady aim pulls the weapon tight and squares the stance. New reload animation in four phases: muzzle drops, spent magazine tumbles away and fades, support hand carries a fresh magazine up to the well, weapon snaps back level; the pose returns exactly to idle at the end. Being hit now shows on the body as a red shimmer that decays with `hitFlash`. `drawOp` takes a new state object rather than more positional arguments, and entities now carry a `moving` flag set centrally in `moveToward` and cleared once per frame, so raiders animate from the same code path as the player. Melee has no reload animation because `fists` has `reload:0`, which is correct. Remaining slice: lighting and effects polish.
- **v0.19 (graphics pass, slice 3 of 3: lighting and effects, completes the pass):** Light is now event-driven instead of static. New transient light system (`flash()`): every muzzle flash from any shooter, and every frag detonation, punches a real hole in the darkness overlay and blooms in the weapon's own tint, rather than the old behaviour where only the player's own muzzle tinted the screen. Explosions flare wide and decay over 0.45s. Machines that have locked onto you now light their own patch of ground and bleed their eye colour into the air, so a hunting sentry is visible as a moving red pool before you can resolve the sprite, which serves the information pillar directly. The extract beacon is now a real light source that swells as it comes in: measured screen brightness 29 idle, 33 early inbound, 36 near landing. Walls gained baked contact shadows at their base and sides, so the raised faces sit in the ground instead of floating; baked once in `bakeGround` so it costs nothing per frame (measured ground luminance 66 at wall bases against 87 in the clear, over 60 sampled walls). **Queue item A (graphics and animation pass) is complete across v0.17, v0.18 and v0.19.**
- **v0.20 (both reported by Daniel):** (1) Loot text no longer stacks on itself. Multiple items from one container were all anchored to the same point and rose at the same rate, so a safe holding four things drew four lines on top of each other. `label()` now scans live labels and pushes any clash up by one line height, so a haul reads as a clean column; verified with five items on one anchor landing on five distinct rows 13px apart, painting 4.4x the pixels of a single line rather than 1x. (2) Brightness is now tunable and the default is brighter. New `bright` config (DEF 1.35, slider 0.6 to 2.2, live) scaling the darkness overlay, the player's own light pool, and the ambient awareness punch; the vision fog is only eased slightly because it is the fog of war, not a mood filter. Measured brightness of the lit area the player actually looks at: 28 at the darkest setting, 36 at the old v0.19 look, 41 at the new default, 47 at maximum. Presets carry sensible values: A (Shadow) 1.05, B (Baseline) 1.35, C (Surge) 1.75. Existing saved configs pick up the new default automatically because `applyCfg` only copies keys present in DEF.
- **v0.21 (correctness only):** Fixed the camera breaking on wide displays. `camX=clamp(camX,-80,WORLD_W-W+80)` inverts its own bounds once the viewport is wider than the world plus its slack (W above 2760, or H above 2160), and `clamp` with a minimum above its maximum returns one bound or the other depending on which side the value falls, so the camera stopped following the player and instead snapped between two fixed positions as they crossed the map. Reproduced at a 2984px viewport: the camera jumped between -80 and -304 and never tracked. That is any 4K display at 100% scaling (3840 wide) or a 3440 ultrawide, so a real player on a big monitor would have found the game close to unplayable. New `camClamp()` centres the world when the viewport is larger than it, and otherwise clamps as before; verified at 2984px the camera now holds a stable centred -192, and at a normal viewport it still tracks smoothly and still stops exactly on the old edge bounds. No tuning values changed.
- **v0.22 (correctness only):** Run notes no longer get mangled in the hub. `fmtRun` interpolated the free-text note straight into `innerHTML`, so an ordinary playtest note containing a bracket lost text: "sentry hp <sentry cap> needs work" rendered as "sentry hp  needs work", and "kept dying <one second from the beacon" rendered as "kept dying " with the rest of the line swallowed. That matters because notes are the channel telemetry actually travels on, so the bug quietly destroyed the data CLAUDE.md rule 1 depends on. Notes, tags and the killer name are now escaped through `escHtml`; verified all five reproduction cases render byte-for-byte intact through the real `fmtRun` path, and an embedded image handler no longer fires. The stored note was never corrupted, only its hub display, so nothing already logged was lost. Also corrected the "no external dependencies, runs fully offline" claim in section 10, which was wrong: the page still pulls two Google Fonts stylesheets. Checked and found healthy this tick, no change needed: frame cost is 0.76ms with 336 wall segments and 21 entities, and profile writes on slider drags cost 0.106ms against a full 49KB profile, so neither the visibility raycasting nor the unthrottled `saveProfile` is worth optimising.
- **v0.23 (correctness only):** AI raiders could lock onto an unreachable container for the rest of a raid. There is no pathfinding: `moveToward` steers straight at the target and stops dead against a wall. The raider loot branch only cleared `e.goal` when the container was opened or reached, so a raider that picked something behind a building wall ground against that wall permanently, never looting, never extracting, never re-targeting. The sim bot has had a stuck detector for exactly this (`p.lastPos` plus `goal.skip`) since v0.4; raiders never got one. They now abandon a container they have closed less than 14 units on in 3 seconds and add it to a per-raider skip list, so one raider giving up cannot poison another's options. **Evidence, stated honestly:** the defect is certain from the code, not inferred from a metric. The bot sim supports it but does not prove it: a controlled A/B on one origin with identical config and profile gave 17/32/27 AI raiders extracted with the detector on against 16/23/18 with it off, so the mean rises about a third but the ranges overlap at three runs per arm. Two earlier attempts at this measurement were invalid, one because the fixture origin still carried `extractWait:60` from the v0.14 tick and one because it carried a fists-only profile that ended raids early; both are recorded here because the raw numbers looked far more dramatic than the truth. Also checked and found healthy, no change made: bigger machines from v0.17 did not hurt navigation (door traversal 20% at r=22 against 21% at r=16), and a prototype wall-sliding steering fix did not help either (20% against 21%), so it was not shipped.
- **v0.24 (correctness only, fixing my own v0.16 regression):** Removed duplicated enemy overlays. v0.16 added world-pass nameplates carrying a name and a health pip for every visible entity, but the older HUD overlay was still drawing its own health bar for every wounded enemy and its own callsign for every raider. Since v0.16 shipped, every wounded machine has been showing two health indicators a few pixels apart and every visible raider its name twice. The HUD now draws only the alert marker, and it reads its height from `spriteTop(e)` rather than the pre-v0.17 hardcoded offsets (crawler 22, snitch 34, else 44) that went stale when the machines got bigger. The `[RUNNING]` tag on an extracting raider was HUD-only, so it moved onto the nameplate rather than being lost, and now recolours the whole plate teal. Verified: wounding an enemy adds exactly zero pixels to the HUD layer where it previously drew a second bar, the alert marker costs 103 pixels, and on the world layer the health pip, nameplate and running tag each still render exactly once.
- **v0.25 (correctness only, fixing my own v0.19 regression):** Closed a fog-of-war leak. The v0.19 hunting-machine lighting iterated `G.ents` rather than `VIS`, so a sentry or crawler that locked onto you punched a hole in the darkness overlay and bloomed red into the air *from wherever it was*, including behind solid walls and entirely outside your vision. Measured: a sentry hidden behind a wall at 240 units, absent from the visible set, changed 3005 pixels on screen the moment it switched from patrol to chase. That is a bright wallhack marking exactly where a hunting machine is, against pillar 2 and against the rule that hostile positions are never shown. Both the darkness hole and the air bloom now iterate `VIS`. After the fix the chase-specific tell on a hidden enemy is 140 pixels against 894 for its mere presence, meaning what remains is the ordinary 7% fog transmission that walls and containers leak too, not a state tell. A hunting enemy you can actually see still glows hard, 26255 pixels. Left deliberately unchanged: muzzle flashes still light from unseen shooters, because firing is an action that already emits a hostile noise ping, and seeing the flash of a gun being fired at you out of the dark is a fair combat cue rather than free information.
- **v0.26 (correctness only, fixing my own v0.16 regression):** Kill labels no longer print through walls. The `NAME DOWN` label added in v0.16 fired on every entity death regardless of whether you could see it. Machines and AI raiders shoot each other (`updateBullets` has cross-faction friendly fire) and frags hit everything, so a firefight across the map printed readable text at a position you had no way to observe, announcing both that something died and exactly where. Measured: a kill label at a spot with no line of sight painted 2718 pixels against 4187 for a visible one, so roughly two thirds as legible as a kill you actually witnessed, and unmistakably text rather than a smear. Now gated on `canSee` in the simulation layer, which is where the visibility decision belongs, keeping the render split intact per rule 6. Verified: the gate returns true for a kill in your cone and line of sight, false behind a wall, false across the map. Checked and deliberately left alone: the death spark burst and puff, which predate v0.16, leak only 220 pixels from a hidden position, twelve times dimmer than the label was and consistent with the ordinary fog transmission, so they read as atmosphere rather than a readout.
- **v0.27 (Daniel's playtest, item 1 of 6):** Enemies are no longer visible through walls. The y-sorted draw pass rendered every entity within the camera bounds and relied on the fog overlay to hide the unseen ones, but that fog is 93% opaque, not 100%, so every machine and raider on the map showed faintly through solid geometry. Measured before the fix: a sentry, crawler and raider hidden behind walls painted 61, 335 and 59 pixels respectively while absent from the visible set. Entity sprites now key off the same `seen` flag as the nameplates, so what you can see and what gets drawn finally agree. Measured after: exactly 0 pixels for all three when hidden, full sprites when visible. **Deliberately left alone and worth knowing:** sentry scan cones are still drawn from unseen sentries, because a cone is light cast on the ground rather than the machine itself, `conePoly` already clips it against walls, and watching a cone sweep around a corner toward you is the stealth read the design is built on. Enemy muzzle flashes and tracers likewise still show, since firing is an action that already emits a hostile noise ping. Also checked and healthy, no change: smoke blocks line of sight correctly at every normal range (200 to 420 units tested, blocked in all cases). It fails only when both parties stand inside the same cloud, which is what a boundary-ring occluder model does and is defensible, since you are both in the soup.
- **v0.28 (Daniel's request: "when you aren't topside it would be cool if you could see your character in the underground city and move around a lil bit"):** The hub is a place you stand in, not a menu. The Undercroft is a hand-authored 1180x760 interior walked with the same movement, collision and sprite code the surface uses, so the operator has the full v0.18 walk cycle down there. No timer, no fog, no machines, warm lamps. Five stations you walk up to and open with E: DEPLOY LIFT, REQUISITION, WORKSHOP, OPERATOR TERMINAL (the old stash, loadout, contracts and recorder panel) and TUNING CONSOLE. Every existing modal is reused unchanged, so nothing about the economy, crafting or recorder moved. Verified: hub builds on boot with 13 walls, 8 lights and 5 stations, renders, the operator walks and stays in bounds.
- **v0.28 (requested: the hub is a place, not a menu):** The Undercroft is now walkable. `state==='hub'` renders a hand-authored interior on the same canvas the surface uses, with the operator sprite, its v0.18 walk animation, `collide()` against real walls, camera follow through `camClamp`, and warm lighting with no fog and no timer. Five stations, each a lit floor pad with a post and a floating label: DEPLOY LIFT, REQUISITION, WORKSHOP, OPERATOR TERMINAL and TUNING CONSOLE. Walk up and press E to open the panel that already existed, so nothing about shop, crafting, stash, contracts or the recorder changed underneath. The old HTML hub panel is now the Operator Terminal station rather than the hub itself; Escape or "Back to the floor" returns you to walking, and movement freezes while any panel is up. Verified: walking moves and animates, collision holds inside the shell, all four non-lift stations detect proximity and open their own panel on E, and the player is frozen while the terminal is open.

### Read the sim extract rate as a floor, not as the difficulty (v0.62)
Three separate faults in the instrument have been found and fixed since v0.55: bullets that passed through walls and bodies, bodies that ground to a halt on the way to the extraction, and AI raiders that walked through walls. Each one moved the headline figure, twice upward and once down. As of v0.62 the physics finally match the game, but the bot has no pathfinding, so what the extract rate now measures is what a poor navigator achieves: 24 percent mean on the default Scav Pistol with the clock as the leading killer. Always quote the loadout. Never read it as how hard the game is for a person.

### Baseline withdrawn at v0.55
The v0.48 baseline and the crawler finding below were measured with a broken bullet collision test that made the bot miss roughly half its aimed shots while crawler contact damage never missed. Read them as history, not as the state of the game. Post-fix measurement: 63, 53, 63 percent extract, mean 60, sentries the leading killer. Nothing has been tuned on the strength of it.

## 11. Project split (August 20, 2026)
Dark Raiders is developed as three separate Claude projects, each a complete and independent instance of the game with no shared assets or code:
1. **This project: the 2.5D version.** The 3/4 StarCraft-style top-down renderer over a flat simulation, as described throughout this document. This is the line with the full history from v0.1 to now.
2. **First-person shooter.** A complete rewrite in its own project.
3. **Third-person shooter.** A complete rewrite in its own project.
They are not branches and they do not share a file. Nothing here should be ported into them and nothing from them should be ported in here. During v0.28 a concurrent process wrote first-person raycaster code, a WebGL renderer, and a "dream state" post-processing layer into this project's `dark_raiders.html` by mistake; all of it was parked on branches (`parked/first-person-raycaster`, `parked/dream-state`) and two stashes rather than shipped, and the canonical file was restored. The stray branches `dreamstate`, `first-person`, `third-person` and `sidescroller` also date from that incident and hold nothing unique.
- **v0.30 (first real playtest batch since v0.10, from the v0.28 export):** His run: died at 18s to an AI raider, tags Too dark, Too hard, Shooting felt weak, AI unfair, note "Kestral unfair". **The root cause was mine.** His config shows `preset: "C"`. Preset C was the brightest preset (bright 1.75) and also by far the deadliest: eDmg 1.6 against the 1.35 baseline, 8 sentries, and a 240s timer instead of 300. He had reported "too dark" twice already, reached for the brightest option, and silently bought 1.6x enemy damage with it. Brightness was welded to difficulty by my own v0.20 change. The batch, one line each: (1) removed `bright` from presets A and C, so a difficulty preset no longer changes how bright the game is; (2) `applyPreset` now preserves the brightness he set, because a display preference must not be reset by a difficulty choice; (3) DEF `bright` 1.35 to 1.7, since "too dark" is now his third report and 1.7 is roughly where he kept reaching; (4) AI raiders get a 0.38 to 0.62s reaction delay before their first shot on acquiring, because they previously acquired and fired in the same frame, which is what "AI unfair" describes; (5) raider HP 95 to 78, because a raider out-tanked a sentry while also being the thing that executes you when downed. Verified: presets now leave brightness untouched while still changing difficulty (bright held at 2.05 across A, B and C while eDmg still moved 1.35 to 1.6), console clean, three 30-raid sims at 23/23/20 percent extract against a prior band of 10 to 23, so no balance regression. **Not addressed this tick:** "Shooting felt weak" is partly explained by eDmg 1.6 making him fragile while machines took the same hits, which dropping back to preset B fixes, but there is still no hit feedback in the game; a hitmarker is the obvious follow-up and is not a tuning change.
- **v0.31 (queue item A: key legend and gear discoverability):** He said "I still have no idea how to change weapons, use explosives, equip gear like vests, etc. Do a better job with the key legend and make it vertical." The old legend was one 9px line of fourteen items across the bottom of the screen, which is where TAB BAG had been hiding all along. It is now a vertical grouped panel in the bottom-left: MOVE, FIGHT, GEAR, WORLD, each key on its own row with what it does in plain words. **The more important half:** two of the three things he could not find have no key at all, so a key list alone would have left him hunting. The panel now states the keyless rules directly, taken from the code rather than assumed: weapons have no swap key because a strictly better gun auto-equips on pickup and the loadout is changed at the Undercroft armory; armour has no equip key because plates apply themselves on pickup and from stash on deploy; throwables auto-load 2 of each and are Q to cycle, G to throw. The inventory panel also now says "better guns auto-equip" next to the bag header, because that is where he would look for how to equip something. H hides the panel down to a single "H controls" line for when he no longer needs it, and it defaults to on. Verified: panel paints 74,490 HUD pixels and defaults to on, the collapsed state still paints the reminder line, H toggles cleanly through the real key handler, console clean, 30-raid sim at 13 percent extract with no balance effect expected or seen from a HUD-only change.
- **v0.32 (queue item B: noise indicator for unseen enemies):** He asked for "some sort of visual indicator when an enemy makes noise even if they aren't in line of sight". Measuring first, as the note said to, found the premise was wrong in an important way: **enemies made almost no noise at all.** The only enemy noise emitter in the game was firing a weapon. Machines and raiders walking, patrolling and charging were completely silent, so there was nothing for an indicator to show. Measured on the old build: a gunshot ping 120 units away painted 311 pixels, the same ping 400 away painted **zero** because the source was outside the viewport and nothing marked it, and every ring expanded to the same 56px radius whether it was a footstep or a beacon call. Three fixes: (1) enemies now emit footstep noise while moving, crawlers every 0.34s at radius 150, sentries every 0.55s at 190, raiders every 0.50s at 130, snitches silent; (2) hostile noise outside the viewport now draws a chevron on the screen edge pointing at it, scaled by loudness and faded by distance; (3) ring radius now grows with the noise radius, capped, so a footstep and a detonation are visibly different. **The important safeguard:** enemy footsteps are player-facing only. `ping()` gained a `quiet` flag that skips the AI stimulus loop, because without it every machine would hear every other machine walking and the map would cascade into permanent alert. Verified: 127 enemy noise events in 3.2 seconds where there were previously zero, the off-screen chevron paints 148 HUD pixels where the old build painted zero, ring paint now scales 425 to 745 pixels from quiet to loud, and after 14 simulated seconds 18 of 21 enemies were still on patrol with only 2 alerted, so the quiet flag holds and there is no cascade. Footsteps are also distance-gated so a machine on the far side of the map does not spawn an invisible ring, and the ping array is capped at 140. Console clean, 30-raid sim at 13 percent extract, within the established band.
- **v0.33 (queue item C: day/night option):** He wanted to choose daytime or nighttime play. Shipped as an explicit hub choice, a `CONDITIONS: NIGHT / DAY` button next to Deploy, stored on the profile as `P.cond` and defaulting to night for both new and existing saves. **The design call, stated plainly: day is a look, not a difficulty.** Vision cone, awareness radius, view distance, enemy ranges, enemy damage and spawn counts are byte-identical in both conditions, verified by snapshotting the config across a condition switch. Choosing daylight is a preference, not an easier game, and it deliberately does not touch balance because there is no playtest data to justify a difficulty change. What actually changes: the sky behind the world, a lightened and warmed district palette for ground and walls via a `litHex` tint, the darkness overlay dropped to near nothing since there are no shadows to punch lamps through at noon, lamp glows cut to a third because daylight washes them out, and the fog of war recoloured from black to pale haze. **The fog stays in daylight on purpose:** it represents where your attention is, not how dark it is, so removing it would delete the entire information layer the game is built on. Verified: brightness of the area the player actually looks at goes 51 to 285, a 5.6x lift, whole-screen 35 to 359; the config is provably unchanged across the switch; and critically the v0.27 rule still holds in both conditions, with an enemy behind a wall painting exactly zero pixels in day as well as night, so daylight does not leak positions. Console clean. The headless bot sim cannot be affected by this change by construction, since every edit is in the render path the sim skips, so the sim numbers either side are variance and prove nothing.
- **v0.34 (queue item D: water):** New terrain type, with the rules decided and stated rather than left implicit. **Water never blocks movement and never blocks line of sight.** Blocking either would just make it another wall, and the map already has walls. What it does instead: it slows everything that walks through it to 0.55 speed, it forbids sprinting, and it is loud. That last rule is the point of it. Water is the anti-crouch, the one piece of ground where sneaking is not available, so crossing is a real commitment instead of a texture. Crouching on land silences you completely; crouching in water does not quiet a splash at all. The same rules apply to machines and raiders, and their splashing is louder and more frequent than their footsteps, using the v0.32 `quiet` flag so it informs the player without stimulating other AI. Water is baked into the ground texture so it costs nothing per frame, with a live shimmer pass over it, and it is drawn on the sector map because it is terrain worth planning around. Added to the legend as a keyless rule alongside the others. **A generation bug caught by measuring:** the first implementation rejected pool placements against buildings with no retry, which left 20 percent of maps with no water at all and an average of 1.48 pools. Placement now retries up to 48 times, shrinking the pool as attempts run out and rejecting overlaps; measured over 60 maps afterwards, zero maps without water and an average of 3.52 pools. Verified: dry walk 76 units against 42 in water for the same input, sprint gives 123 dry and 42 in water so it is genuinely denied, the player crosses water freely and line of sight passes through it, and on noise, dry walk 3 pings at radius 110, dry crouch 0 pings, water walk 7 pings at 290, water crouch 7 pings at 290. Console clean. **Balance note, stated honestly:** unlike day/night this does touch the simulation. Three sims came in at 10, 10 and 23 percent extract against a prior band of 13 to 30, with average raid length up from roughly 70s to 74 to 90s. The direction is consistent with everything moving slower, but at three runs per side it overlaps the noise band and I am not claiming it as proven.

## Open decision: verticality (queue item E, not started)
Daniel: "add verticality, I have not seen any option to climb on top of a building, hill, etc". This is the one request that fights the architecture, so per the queue it is written up rather than started. Grounded in a survey of the current file (3,553 lines), not estimates.

**What actually assumes a flat plane today.** 11 core functions across roughly 110 call sites: `dist` x47, `moveToward` x14, `freeSpot` x13, `collide` x10, `losClear` x6, `canSee` x4, `rayHit` x4, `inWater` x4, `spotIn` x3, `buildVisPoly` x2, `conePoly` x2. Height is currently a pure lie told by the renderer: a single `LIFT` constant of 14 or 26 pixels, plus one y-sort key per object. Bullets test walls with a 2D rectangle containment check. The headless bot sim reuses the entire simulation, so anything added has to work with no renderer at all.

**Option 1, true height (a Z axis).** Every entity gets a z and a height; collision becomes step-up/step-over; line of sight becomes 3D; AI needs to path between levels; bullets need a z; and the renderer's y-sort has to become a real depth sort, because a character on a roof must draw over a wall that is in front of them and a y-sort cannot express that. This is a rewrite of the simulation core rather than an addition, it touches most of the file, and it breaks comparability with every recorded run to date. It is also the change most likely to produce the failure mode this project has already hit three times: silent line-of-sight leaks that only a playtest catches.

**Option 2, roofs as separate walkable regions (cheapest).** The flat simulation is untouched. A roof is its own floor with its own walls, containers and entities; ladders are link points; climbing swaps which floor is active. Additive, roughly 150 to 250 lines, does not break the recorder or the sim. **What it does not give you: high ground.** You cannot shoot down at the street and the street cannot shoot up at you. Verticality becomes another room reached by ladder.

**Option 3, elevated platforms with sight advantage (middle).** Keep the flat simulation and the 2D collision. Tag some rects as climbable platforms with a height, and give each entity an `eyeZ`. That scalar is used in exactly one place: the occluder filter inside the raycast, so standing on a platform stops low cover from blocking you, and stops it hiding you. Real tactical high ground, no Z axis, no AI pathing rewrite, no renderer rebuild. Roughly 120 to 200 lines, and directly testable with the differential and line-of-sight harnesses already in use.

**Recommendation: option 3**, because the thing that makes verticality matter in this genre is sightlines, not altitude, and it is the only one of the three that delivers that without putting the fog-of-war correctness at risk. Option 2 is the fallback if what he wants is simply more map to explore.
- **v0.35 (hit feedback, the follow-up flagged in v0.30):** His v0.28 run tagged "Shooting felt weak" while the recorder showed 12 shots at 58 percent accuracy killing a sentry and a crawler, so the shooting was working and the feedback was not. The only confirmation a shot landed was a sprite flash and a spark burst, both of which happen out in the dark at whatever range the target is, so a hit could easily read as a miss. There is now a hitmarker at the reticle: four diagonal ticks that expand and fade over 0.26s on a hit, and a wider, bolder, amber version over 0.44s when the target drops, so a kill is distinct from a wound without reading a health bar. It is HUD only and touches no balance. Verified: state starts null, a non-lethal hit sets the standard marker, a lethal hit sets the kill variant, the kill marker paints 325 pixels against 78 for a normal hit so it is visibly bolder, the marker expires on schedule, and a shot that hits nothing does not mark. Console clean, 30-raid sim at 20 percent extract, within the band.
- **v0.36 (from the v0.35 export, two runs, both deaths):** Run 1 died at 19s to a raider; run 2 deployed with **Bare Hands**, met an enemy at 2 seconds and died at 14s. Three changes, one line each. (1) **Enemy spawn distance is now actually enforced.** `far()` picked a spot, and if it was too close to the player it fell back to a fresh spot *with no distance check at all*, so machines could spawn on top of you. Measured over 400 maps and 8400 placements: 2.6% spawned closer than their own minimum, 27 of them within 200 units, the closest at 35 units, which with a player radius of 11 is touching. That is roughly two raids in five carrying at least one bad spawn, and it is the direct explanation for first contact at 2 seconds. It now retries and keeps the furthest candidate: 0 violations of 8400, closest spawn 421. (2) **A loaner sidearm when the armoury is empty.** Losing your gun on death is meant to sting, not zero you, but with nothing banked he deployed with bare hands and lasted 14 seconds on three melee swings. The Undercroft now issues a Scav Pistol if you would otherwise deploy empty-handed; you still lost the good gun and the loaner dies with you. (3) **Raider sustained fire slowed**, cadence multiplier 1.0-1.9 to 1.7-2.9. Every one of his last three deaths was to an AI raider. A rifle raider landing 31 damage a hit against 100 health killed from full in 0.4 to 0.75 seconds of fire, which after a 0.4 to 0.6s reaction delay left no time to react at all; it is now 0.7 to 1.2 seconds. Verified: two clean 30-raid sims at 20% and 17% extract against a prior 13%, average raid length up from 64s to 135s and 90s, containers opened up from 7.6 to 9.3 and 8.6, downs down from 26 to 17 and 22. Timer deaths rose from 1 to 7 and 3, which is the expected shape of surviving longer and looting later; worth watching but not yet a problem.
- **v0.37 (correctness only):** You can no longer spawn standing in water. The v0.34 flooded ground is deliberately punishing, halving your speed and defeating crouch entirely so a splash is loud whatever you do, but spawn placement never checked for it. Measured across 400 generated maps: water covers 3.17% of the ground in an average 3.47 pools, and the operator started inside a pool on **4.75% of raids**, roughly one in twenty-one. That is a raid that opens slowed and announcing itself with no counterplay available, at second zero, before you can even read the map. The spawn now retries until it finds dry ground. Measured after, over 600 maps: 0% wet spawns, 3.3% of maps needed at least one retry, and the retry budget was never exhausted. Refactored `inWater` into a map-local `inWaterMap(map,x,y)` so placement code can ask the question during map generation, before the live game state exists. **Found and deliberately not changed:** an extract ring's centre lands in water on 4.9% of placements, but the ring is 78 units across, so a flooded centre still leaves dry ground to stand on, and you can see the water before deciding to call the beacon. That is tension rather than an unfair roll.
- **v0.38 (correctness only):** Off-screen sound was reaching further than on-screen sound. The v0.32 edge chevrons faded over `noise * 2.2` while the in-world noise rings fade over `noise * 1.5`, so any hostile sound between those two distances was completely invisible when it happened on camera but drew a directional arrow when it happened off camera. For an auto rifle that band runs 630 to 924 units wide, and for a snitch alarm 930 to 1364, over half the map. It meant what the operator could perceive depended on where the camera was pointing, which is the one thing pillar 2 cannot tolerate. Measured before: at 700 units a rifle shot had ring alpha 0.00 and chevron alpha 0.24. The chevron now uses the same 1.5 falloff as the ring. Verified after: an off-screen snitch alarm at 760 units still draws its chevron (184 pixels) and an off-screen frag at 780 still draws (174), while the same alarm at 1100 and a rifle shot at 800 now correctly draw nothing, where the rifle previously would have. 30-raid sim at 23 percent extract, the top of the current band. Also filed four stale recorder files in exports/, including one that was my own v0.12 self-test and had been showing up as new telemetry every tick.
- **v0.39 (correctness only):** In daylight the fog of war was brighter than the ground you could actually see, so unexplored space read as more visible than explored space and the vision cone stopped being legible at all. The v0.33 day fog was a pale grey haze, `rgba(126,134,146,~.87)`, painted over a lit daytime ground; the haze simply came out lighter than the terrain underneath. Measured with a same-run A/B over 8 generated maps each, sampling by true cone membership rather than fixed screen boxes: the old colour gave cone 322 against fog 370, a ratio of **0.87**, the wrong way round. It is now a dimming slate, `rgba(28,33,41,...)`, giving cone 157 against fog 127, a ratio of **1.24**, with night unchanged at 1.47 by the same method. Daylight is still unmistakably daylight, about 4x the overall screen brightness of night. No information was leaking, since enemy sprites have been gated on line of sight since v0.27, but the core visual language of pillar 2 was inverted for anyone playing in day. **A method note worth keeping:** my first two measurements of this used fixed screen regions and gave wildly different answers on different maps, including one that suggested night was broken too. Sampling by actual visibility across several maps is the only version of this test worth believing. Also audited and found clean this tick, no changes: the water rules, the day/night palette split including its correct decision to leave the underground hub dark in both conditions, and every claim in the key legend cross-checked against the real key handlers.
- **v0.40 (correctness only):** Medical items are now spent smallest first instead of whichever sat earliest in the bag. `findHeal` returned the first heal item it walked past, so carrying a Medkit and a Bandage meant a coin flip on which one a self-revive burned. That matters because a self-revive restores a flat 40 HP regardless of what it consumes, so spending a 210c Medkit where a 60c Bandage would have done exactly the same job was pure loss, and topping up a scratch with a Medkit throws away most of its 65 point heal. It now always picks the smallest heal in the bag, breaking ties on value, which fixes the self-revive, the F key top-up and the sim bot's healing in one place. Verified: with a Medkit and a Bandage it picks the Bandage regardless of which is listed first, falls back to the Medkit when that is all there is, and a self-revive now leaves the Medkit in the bag. **Audited and found correct this tick, no changes:** the safe pocket, tested by killing a player carrying five items of known value, which correctly saved the two most valuable, routed the field rifle into the armoury rather than the stash, lost exactly the right 130c of junk and reported it accurately; and the whole downed state, where the first self-revive returns you at 40 HP with two seconds of invulnerability, a second is correctly refused with no item consumed, and bleed-out kills at exactly the configured time.
- **v0.41 (correctness only):** Kills are now credited to whoever landed the killing blow. Every enemy death anywhere on the map incremented the player's kill count and advanced kill contracts, regardless of who caused it. Machines and AI raiders shoot each other constantly and frags hit everything, so a sentry destroyed by a raider on the far side of the map counted as yours. Two consequences, and the second is the one that matters: contract progress was free, and the kill figures in the flight recorder were inflated, which is the data CLAUDE.md rule 1 says tuning decisions come from. Measured over 30 simulated raids: 193 enemy deaths, of which **9, or 4.7 percent, were not caused by the player**, split 7 crawlers, 1 sentry, 1 snitch. That is a floor rather than a typical figure, since the sim bot rushes and fights everything head-on; a stealthier player who lets raiders and machines wear each other down would have been credited far more. The killing blow now tags the victim: player bullets and frag detonations mark it as yours, cross-faction enemy fire marks it as not, and the death handler only counts and advances contracts when the tag says yours. Last hit wins. Verified with a same-run instrumented count, and a 30-raid sim completes clean at 10 percent extract, which is within the noisy band and unaffected by this change since it is pure bookkeeping.
- **v0.42 (correctness only):** Armour plates you picked up were usually dead weight. A plate is worth 55 armour but only applied if you were already below 20, so the very common case of deploying with a plate from stash put you at 55 and made every plate you found for the rest of the raid unusable: it went silently into the bag with no way to apply it, while the in-raid legend promised "plates apply themselves on pickup". The threshold 20, the plate value 55 and the HUD bar's 60 scale were three unrelated numbers. There is now one `ARMOR_MAX` of 60 driving all of it: plates apply on pickup until armour is genuinely full, top up partially rather than being refused outright, the bar can no longer overflow, deploying stacks against the same ceiling, and the legend line was corrected to say "until armour is full". Verified across five starting values: from 0 goes to 55, from 19, 21 and 40 all top up to 60 where the last two previously went to the bag unusable, and only a genuinely full 60 bags the plate. Damage absorption is unchanged and still depletes correctly, 30 raw damage costing 18 health and 22 armour. 30-raid sim clean at 27 percent extract with 10.2 containers, both at the top of the recent range.
- **v0.43 (correctness only):** Your deploy kit was decided by the order items happened to sit in the stash. The three auto-load slots were filled by walking the stash backwards and taking the first three medical, ammo or armour items found, so the exact same stash could send you out with a full plate and two spare magazines, or with nothing but bandages. Demonstrated: `[bandage x4, ammobox, plate]` deployed 55 armour and 64 reserve, while `[plate, ammobox, bandage x4]`, the identical contents reordered, deployed 0 armour and 24 reserve, leaving the plate and the ammo sitting in the stash. This is the only route by which armour or ammo ever reaches the player, and Daniel has said he does not know how to equip gear, so it was silently deciding his survivability for him. Loading is now by category in the order that keeps you alive: armour, then ammo, then medical, with any slot left free by a missing category filled from whatever remains. Within a category, armour and ammo take the biggest since they are spent the instant you land, while medical takes the smallest since it is carried and you lose what you carry when you die, matching v0.40. A plate is also no longer spent when less than half of it would fit under the ceiling. Verified: the two reorderings above now produce identical kits, a medkit-and-bandage stash correctly carries the bandage and banks the medkit, three plates take exactly one, an all-bandage stash fills all three slots, and an empty stash deploys cleanly. 30-raid sim at 7 percent extract, which is the low end of a band that has run 7 to 27 across recent builds, and this change is loadout selection rather than balance.
- **v0.44 (usability, reported by Daniel):** "Why is windows constantly giving me a prompt to save txt files." The v0.12 auto-export fired a browser download at the end of every single run, and with his browser set to ask where to save each file, that meant a Windows save dialog after every raid. Reports now go out over a quiet local drop instead: the game POSTs the recorder to `http://localhost:8799/telemetry` and a small collector writes it straight into `exports/`, so nothing is downloaded and nothing is asked. The old download path still exists but is now off by default behind `P.autoDownload`, so the prompts cannot come back on their own. The hub button became `Auto-report` and shows the outcome of the last attempt, `saved`, `downloaded` or `not saved`, so a silent failure is visible rather than invisible. **What is verified and what is not:** the whole path is confirmed working when the game is loaded from the local address, a real run wrote `exports/run-<timestamp>.txt` on its own with no dialog and the hub reported `saved`. It could not be verified for the way Daniel actually plays, double-clicking the file, because the browser pane refuses to load a genuine `file://` page and renders a snapshot instead; a test from that snapshot origin was refused, but a snapshot has stricter network rules than a real local file so it proves nothing either way. Either outcome is still an improvement for him, since with the download off he gets no prompts regardless, and the report is retained in the game to hand over on request. Also confirmed while here: last tick's 7 percent extract could not have been caused by v0.43, because the sim bot uses a fixed kit and never runs the deploy loadout code at all. This build measured 17 percent, mid band.
- **v0.45 (correctness, and cleaning up after myself):** A recorder arrived showing "51 runs, 0 extracted", which read like a brutal difficulty problem. It was not. 49 of those 51 entries were empty: zero duration, zero distance, nothing searched, nothing fired, and one of them carried `killer:test`. **They were mine.** Every automated verification tick that deployed and immediately backed out logged itself as a real run, and until v0.44 also downloaded itself into Daniel's Downloads folder, which is a large part of the save prompts he reported. Two things follow. First, a raid with under 1.5 seconds elapsed, under 8 units walked, nothing searched and nothing fired is no longer recorded at all: no log entry, no counter increment, no report, and the outcome screen is skipped entirely, since that is a deploy you backed out of rather than a run. Verified: five instant back-outs in a row logged nothing and left the run counter untouched, while a run that only walked, a run that only searched, and a run that only fired one shot were all recorded correctly. Second, this also makes the automated testing harmless: the deploy-abandon pattern every verification tick uses can no longer pollute the history or trigger a report. **The lesson worth keeping:** the "0 extracted from 51 runs" figure was about to be read as evidence the game was unwinnable. It was evidence that the instrument was counting the tester. Check whether a striking number came from real play before acting on it.
- **v0.46 (correctness, fixing my own v0.45):** The "not a real run" filter I added last tick could silently discard a successful extraction. It skipped all bookkeeping for any raid under 1.5 seconds with no distance, no containers and no shots, but it applied to every outcome, so an extraction meeting those conditions banked nothing, counted nothing and left no record: the haul simply vanished. Found by finally testing the player's extraction path directly, which had been listed as unverifiable for a dozen builds because the browser pane suspends animation. The filter now only applies to an abandon. An extraction always banks a haul and a death always costs you your weapon, so both are real however short. Verified: a short extraction now banks both carried items and counts as an extraction, a short death still strips the weapon from the armoury while the safe pocket keeps the valuable item, and an instant deploy-and-back-out is still correctly ignored. **The extraction path itself is now verified end to end for the first time:** pressing use outside the ring does nothing, standing in the ring without pressing use does nothing, calling from inside starts the countdown and raises a hostile noise ping at the ring, the countdown continues while you leave, being away when it lands loses the beacon and increments the missed counter without ending the raid, and being back inside when it lands extracts you. Also audited and found healthy, no changes: throwables, where the pouch loads two smoke, one decoy and two frag from stash, smoke genuinely blocks a sight line that was clear before it, a decoy lives and emits repeated non-hostile pings, and a frag kills an 80 health sentry while taking the thrower from 100 to 37.
- **v0.47 (reported by Daniel: "there are random circles all over the map but its not clear to me what they mean"):** The three extraction rings were drawn as bare circles with no text anywhere: one teal, two faint grey, and nothing saying what any of them were. They are labelled now. The live one reads EXTRACTION in teal, the other two read EXTRACTION - COLD with "no beacon here" underneath in grey, and the sector map got the same treatment in short form. The key legend also gained two lines covering both kinds of circle he has now asked about, the rings on the ground and the expanding noise pings: "Teal ring is your extraction, grey rings are cold" and "Expanding rings are noise, white is yours, red is theirs". **Two iterations were needed and both were caught by actually looking rather than counting pixels.** Drawn first in the ground pass, a crate parked inside the ring painted over the text and it read "XTRACTION". Moved up with the nameplates, it was legible but the fog dimmed it to near invisibility. It now draws on the HUD above the fog, which is also correct in principle: where your extraction is was never secret. Verified by screenshot in both states. 30-raid sim at 30 percent extract with 10 containers, the best of the recent range.
- **v0.48 (robustness):** A saved stash or armoury containing an item this build no longer knows about would break the hub completely. Saved config has been filtered against the current key list since the start, so retiring `extractTime` in v0.13 was harmless, but the stash and armoury never had the same protection: `renderHub` sorts the stash by value with a bare `ITEMS[k].val`, so one unknown key threw and took the whole hub down, stranding a real save with no way back in. Confirmed rather than assumed, with a same-build A/B: with the filter disabled a save carrying two retired items threw "Cannot read properties of undefined (reading 'val')" on the first hub render; with it enabled the same save loaded, dropped exactly the two unknown items, kept the three real ones, dropped an unknown weapon, fell the equipped slot back to the pistol, and preserved credits and reputation. Also proven live on the real build, which cleaned a five-item poisoned stash down to three and ran normally. This costs nothing today and means a future item retirement cannot brick Daniel's progress. **Audited and found healthy this tick, no changes:** the whole economy. Selling banks exactly the junk value and correctly keeps usable gear back, crafting consumes precisely the listed ingredients and produces the right output with correct affordability gating, the shop's reputation locks hold even with unlimited money, backpack tiers correctly demand the previous tier, and there is no exploit loop in either direction: every shop item sells back for less than it costs, from 20 to 280 credits down, and every recipe's ingredients are worth more than its product, from 10 to 85 credits down, so crafting is for utility rather than profit.

### Baseline measurement at v0.48 (WITHDRAWN at v0.55, see below)
Four consecutive 30-raid batches on the shipped build, preset B: **33, 17, 20, 23 percent extract, mean 23.3, range 17 to 33.** The figure quoted in the working notes since v0.36 was "17 to 20 percent", which is now stale and pessimistic. Against a healthy band of 35 to 60 the game is still too hard, but the accumulated fixes from v0.36 onward, enforced spawn distance, the loaner sidearm, slower raider fire, plates that actually apply, and a deploy kit chosen by category, have moved it from roughly 13 percent to roughly 23. ~~Crawlers remain the dominant killer in every batch measured, 16 of 23 deaths in the last one, which is the single clearest lever if Daniel decides the game needs to be easier.~~ **THAT SENTENCE IS WITHDRAWN. It was an artefact of a broken bullet collision test that made the bot miss roughly half its aimed shots while crawler contact damage, which uses no projectile, never missed. Fixed at v0.55. Crawler deaths across every batch measured since are 1 to 4 out of about 20, with sentries and the clock leading. Do not act on the crawler claim; it is still repeated in the standing tick instructions and it is wrong there too.** Timer expiry sits at 10 percent, no longer a concern. No tuning was changed on the strength of this: it is a bot measurement, Daniel has not played the current build, and CLAUDE.md rule 1 puts his data ahead of the sim's.

**Systems audited this tick and found correct, no changes:** contracts, end to end. Kill contracts ignore the wrong target, count the right one and stop at the cap. Container contracts track by type and by district independently and simultaneously. Extract-carrying contracts require the full count rather than partial credit, and haul contracts respect their threshold exactly. Claiming pays the stated reward in both credits and reputation, rerolls only that slot to a fresh contract at zero progress, leaves the other two untouched, and the board always refills to three valid contracts.
- **v0.49 (cleanup only, no gameplay change):** Removed three dead fields from the per-raid state. `yaw` and `pitch` are debris from the v0.7 three.js first-person experiment that was scrapped in v0.8 and have been carried unread for forty versions. `explored` was presumably intended for persistent map memory and was never implemented, but its presence in the state object implies a feature that does not exist, which is the kind of thing that misleads whoever reads this next. Each was verified to appear exactly once in the whole file, in the initialiser and nowhere else, so nothing reads or writes them. A sweep for other dead code found none: every function is called and every top-level variable is used. **Audited this tick and found correct, no changes: carry weight.** The cap is a deliberate soft one, you cannot begin a search while full but a search already started completes in full, and the overshoot is mild: filling to 39 of 40 and then opening a safe holding a rifle, a plate and a medkit lands at 44, ten percent over, which puts you at the 55 percent speed floor. That test also incidentally confirmed two earlier fixes working together, the plate applying to armour rather than taking bag space per v0.42, and the better gun auto-equipping and displacing the old one per the original pickup rule.

### Findings at v0.49 (no code change)
**Performance is not a concern.** A frame costs 1.44ms clean and 2.44ms under a deliberately worst-case mess: the decal buffer saturated at its 220 cap, 880 sparks, 300 shell casings, 30 muzzle flashes, 40 floating labels and the ping buffer at its 140 cap. That is a 1.7x slowdown from an extreme that a real firefight would not sustain, and it leaves enormous headroom. Every long-lived buffer is capped and every short-lived one expires on a timer, so nothing grows without bound over a long raid.

**AI raiders almost never die, and that quietly disables one of their design purposes.** Across 30 simulated raids and 90 raiders: 35 extracted with their haul, 52 were still alive when the raid ended, and only **3 died**. DESIGN lists raiders dropping their bag and their gun on death as a reward for beating them to the punch; in practice that reward almost never fires. The cause is deliberate rather than broken: a rifle raider engages from 374 units while the player is at 420 with a pistol, and raiders actively back away when you get closer than about a third of their range, so they kite. They are built to behave like other players and they do. Two caveats before anyone acts on this: it is measured against the sim bot, which is a crude fighter that walks straight at things and only notices threats within 300 units, so a human who flanks, closes, or throws a frag will do considerably better; and the raid usually ends because the bot died at around 80 to 95 seconds of a 300 second raid, which is why so many raiders are simply unfinished rather than winning. Recorded for Daniel rather than acted on, per CLAUDE.md rule 1.
- **v0.50 (correctness):** The game could go permanently silent with no way back. The audio context was created lazily and never resumed, and nothing anywhere called `resume()`. Browsers suspend audio on backgrounded tabs and hold a context suspended on first load until you have interacted with the page, and once that happened the game stayed mute for the whole session: clicking, shooting and pressing keys all left it suspended, and `blip` carried on running without error while producing nothing. Demonstrated directly by suspending the context and confirming that touching audio, clicking the canvas and shooting all failed to bring it back. The context now attempts to resume whenever anything touches audio, and a keypress counts as a wake-up too, which matters because the walkable hub's press-E-to-deploy path runs from the animation loop rather than the key handler and so never counted as the kind of interaction browsers require. Verified after the change: from a deliberately suspended state, touching audio, clicking, and pressing a key each restore it to running, where none of the three did before. **This one could not be reproduced in the browser pane's own permissive settings**, so it was proven against a forced suspension rather than a naturally occurring one; the failure mode is real but how often it bites depends on Daniel's browser and whether the tab was backgrounded.
- **v0.51 (requested): you always deploy with medical.** The three stash slots are filled by category, so an empty stash or one with no bandages in it meant dropping in with nothing to patch yourself up with, which is the worst possible start given how the game already punishes a bad opening. The Undercroft now always issues two Bandages, on the same terms as the loaner sidearm: free, outside the three stash slots, and gone with you if you die. It tops up rather than replacing, so a stash with medical in it still supplies its own and the issued pair only makes up the shortfall. Verified across four stashes: empty, one with armour and ammo but no medical, one with a single bandage, and one full of medical, all four deploy carrying at least two heals, and the last correctly took its two from stash and left the medkit banked rather than spending it. Weight cost is 1 per bandage against a 40 capacity, so it does not eat into carrying capacity in any meaningful way.
- **v0.52 (requested): four issued starter weapons, rolled at random, plus a sidearm you can actually switch to.** Every deploy now rolls one of four starters as your primary, and the Scav Pistol is always issued as a secondary. **X swaps between them**, which is new: the game previously had no weapon-swap key at all, and "plus the starter pistol" means nothing if you cannot reach it. Each gun keeps its own loaded magazine across a swap while the reserve pool stays shared, so swapping is a way to keep fighting rather than a way to dodge running dry. The four are modelled on the ARC Raiders low-tier archetypes and sit at or just below the Scav Pistol and Compact SMG, so shop and loot weapons remain genuine upgrades: **Ferro**, an accurate semi-auto at 17 damage every 240ms; **Kettle**, a spray SMG at 11 every 80ms with the shortest reach; **Stitcher**, a balanced automatic at 20 every 150ms with the longest reach of the four; and **Hullcracker**, a shotgun firing five 9-damage pellets in one pull, devastating inside 210 units and useless past it. Shotguns needed a new `pellets` field, the first weapon in the game to put more than one projectile in the air per trigger pull. An armoury weapon you have deliberately equipped still takes the primary slot, so progression is untouched. Verified: 60 deploys rolled all four with a reasonable spread of 11 to 20 each, the pistol was the sidearm every single time, Hullcracker put exactly five pellets in the air against one for the others, and swapping twice returned the exact gun and magazine it started with. **One self-inflicted bug caught in the same tick:** the first sim after this change reported 60 percent bot accuracy, up from the usual 36, because a shotgun blast counted as one shot but up to five hits and accuracy could exceed 100 percent. Pellets now each count as a shot, and accuracy came back to 31 percent, in the normal band. Accuracy is a figure in Daniel's run reports, so leaving that would have quietly corrupted the data tuning decisions are made from.
- **v0.53 (correctness, fixing my own v0.52):** Looting a better gun stopped working the moment starters became standard. The upgrade check ranks weapons through a lookup table, and the four new starters were never added to it, so the comparison came back undefined and every upgrade was silently refused: you could find a Marksman Rifle, watch it drop into your bag, and carry on holding a Ferro with no way to use the thing you just found. Since v0.52 issues a starter on **every** deploy, this broke the find-a-better-gun mechanic for essentially every raid, one build after shipping it. The table now ranks all nine weapons, with Ferro alongside the Scav Pistol and Kettle, Hullcracker and Stitcher alongside the Compact SMG, so a Rifle or Marksman Rifle upgrades over any starter while a sidegrade correctly does not. A second bug lurked behind it: had the upgrade fired, the replaced starter would have been bagged as an item key that does not exist, which would have thrown on the inventory screen. Starters are issued kit with nothing to bank, so a replaced one is now simply left behind. Verified: all four starters now upgrade to a Marksman Rifle and leave nothing in the bag, an SMG does not displace a Stitcher and a Scav Pistol does not displace a Ferro, both correctly becoming loot instead, an owned pistol still banks properly when displaced, and the inventory screen renders without error afterwards. Sim came back at 33 percent extract with 10.2 containers, the top of the range.
- **v0.54 (correctness, fixing my own v0.52 again):** Two bugs in how the game decides which guns you own, both created when starters and a sidearm arrived in v0.52. First: extracting while holding an issued starter added it to your permanent armoury and equipped it. From that point on the deploy roll saw an owned equipped weapon and stopped rolling, so the "random one of four every raid" feature quietly switched itself off forever after your first successful extraction. Reproduced on v0.53: extract with a Ferro, then 24 consecutive deploys all issue the Ferro. Issued kit is a loaner and is now never banked. Second: only the gun in your hands counted at the end of a raid. Extracting with the sidearm up threw away the Marksman Rifle holstered in the other slot, and dying with your good gun holstered protected it from the death penalty, which is a free insurance policy for anyone who noticed. Both slots are now accounted for, best gun first, with issued kit excluded from both banking and loss. Tracked per slot on the operator rather than by weapon name, and the flags follow the gun through an X swap, so holding two of the same type cannot confuse it. The weapon ranking table also moved out of the container code so the end-of-raid bookkeeping ranks guns the same way the field upgrade does. Verified with a fixture across six cases: an issued starter is not banked and the roll still produces all four across 24 deploys, a looted rifle holstered in the sidearm slot is banked on extraction, an owned rifle is lost on death whether it is in hand or holstered, dying with nothing but issued kit costs nothing, and the ordinary case of deploying and extracting with your own rifle is unchanged. Sim 20 percent, inside the noise band, no balance signal.
- **v0.55 (correctness, and it invalidates every difficulty number in this document):** Bullets could pass through walls, and the bot sim could not reliably hit anything. Both came from the same line. A round was pushed forward in three fixed hops per frame and only tested for a hit at the end of each hop, so anything thinner than a hop was crossed without ever being sampled. In the live game a hop is 19.7 units. **Measured: 16 percent of shots pass clean through a 16 unit wall, 42 percent through a 12 unit wall, and 16 units is the median wall thickness in this game, with 689 of 1019 walls sampled across 12 maps falling between 12 and 20.** Roughly one shot in six ignored the most common piece of cover on the map, in both directions, which sits directly against the cover-and-line-of-sight pillar and next to his playtest complaint about enemies reaching him through walls. Rounds are now swept along their exact path against the wall geometry with the same ray routine line of sight already uses, and bodies are sampled in 8 unit steps so no hitbox can be stepped over. A round that starts inside geometry, which is only reachable by firing while pressed flat against a wall, dies at the muzzle instead of emerging out the far face; measured at 1 occurrence in 23,989 sampled legal firing positions. Verified: 0 percent pass-through at 12 and 16 units where it was 42 and 16, and 100 percent of perfectly aimed shots register on all three machine types at both timesteps. Cost is 0.15ms per frame with 40 rounds in the air, about 1 percent of a frame budget, and the sweep replaces three full wall scans with one, so it is not a regression. **The instrument was worse than the game.** The sim runs at a 0.15s step against the game's 0.05s, so its hops were 59 units and it missed even more: only 47 percent of perfectly aimed shots at a raider registered, 60 percent at a crawler, 83 percent at a sentry. Crawler contact damage is a direct call with no projectile and never missed at all. That asymmetry is the entire reason this document has said "crawlers are the dominant killer in every batch measured" since v0.48. It was an artefact. Three batches on the fixed build: **63, 53, 63 percent extract, mean 60, bot accuracy 63/54/64 against 38 before, and crawler deaths of 1, 3 and 1 out of 11, 14 and 11, with sentries now leading and the timer joint second.** The v0.48 baseline of 23 percent and the crawler finding are both withdrawn, and the difficulty work from v0.36 to v0.43 was aimed using a broken instrument. No tuning values were changed here and none should be until Daniel plays it: the only thing that changed for a human is that cover now stops bullets.
- **v0.56 (correctness):** The dodge roll went through walls. Space carries the operator at 440 a second against a sprint of 256, moved in a single hop per frame with the overlap resolved afterwards. That hop is 22 units, and the operator rests 11 units clear of a face, so a roll landed his centre 11 units past the near face of whatever he rolled into. When that lands past the middle of the wall, the push-out picks the far face as the nearest one and ejects him out the other side. **Measured on the shipped build: a roll passed through a 12, 16 and 20 unit wall 100 percent of the time, and stopped only at 24 units and above. The median wall in this game is 16.** Space was a teleport through most cover on the map, which is a hole straight through the stealth and cover pillar and would have looked like a broken game the first time he noticed it. The roll is now sliced so it never covers more ground between collision tests than a walk does. Verified: 0 through in 300 attempts at each of 12, 16, 20 and 24 units, driven through the shipped movement code rather than a copy of it, a roll in the open still travels its full 176 units, 1200 rolls into an L corner from random angles wedged nobody and all 1200 still moved, and 1200 rolls in random directions on 40 real maps wedged nobody. Also audited and found healthy, no change made: ordinary movement collision. Across 152,994 body samples of the player and every machine over full raids at the game timestep, **zero** bodies walked through a wall. At the sim's coarser timestep there are 30 in 53,257, which is 0.056 percent and not enough to distort a measurement. Sim 67 percent extract, in line with the 63/53/63 measured at v0.55; the bot never rolls, so this change should not move it and did not.
- **v0.57 (correctness, render layer only):** The sentry scan cone lied about its reach. A sentry that has heard anything at all, which includes any noise ping in its radius, gets 35 percent more detection range for as long as its alert timer runs, but the cone kept being drawn at the patrol figure. So it acquired you from ground it had never marked, and the only tell was a slight colour change once it was already chasing. Measured over 25 raids: **97 sentry acquisitions, of which 22 came from inside the cone angle but beyond the drawn range.** Thirteen more came from being shot or from a noise ping, which is fair and communicated. The cone is now drawn at the range the simulation actually uses, so an alerted sentry's cone visibly grows, which turns a surprise into a tell. Verified: with the operator positioned so the whole cone sits inside his own vision, raising alert changes 40,386 pixels and dropping it returns exactly the same 40,386, with a stable repaint in between. The changed pixels were then measured in world space rather than eyeballed: they reach exactly **460 units against the alert reach of 459**, and the widest one sits at **0.62 radians off the sentry's facing against a cone half angle of exactly 0.62**, so the growth is the cone and nothing spills outside it. No simulation value changed.
- **Instrument correction at v0.57, and it revises the v0.55 numbers:** the bot sim deploys with whatever the saved profile has equipped, so its extract rate depends on the player's armoury and not only on the build. One of my own earlier test fixtures had left an Auto Rifle in the test profile, and every figure quoted at v0.55 and v0.56 was measured with it. Measured this tick on one build, changing nothing but the loadout: **Auto Rifle owned 63 and 60 percent, the game's default Scav Pistol 33 and 30 percent, an empty armoury rolling a random starter 27 and 43 percent.** The loadout dominates the result. So "mean 60 percent" from v0.55 is withdrawn; **the honest default-player figure is around 30 percent**, still under the healthy band of 35 to 60. What does survive across every loadout tested is the crawler correction: crawler deaths were 4, 1, 2, 2, 2 and 1 out of roughly 20 per batch, against the 15 of 25 recorded before the v0.55 collision fix, with sentries and raiders now leading. Any future sim figure must be quoted with the loadout it was measured on.
- **v0.58 (Daniel's call: throwables stop at cover):** Answering the open question from the previous tick, and he was blunt about it. A thrown object was slid straight from hand to target with no wall test of any kind, so a frag reached into a room you had never seen and killed what was in it. There is no height in this simulation, every wall stops sight and gunfire outright, and nothing on the map throws anything back, so lobbing over cover was a player-only way through the pillar the whole game is built on. Throws now sweep against the wall geometry, using the same ray routine as line of sight and bullets, and stop a short way off the first face so the charge goes off against cover rather than inside it. Verified: smoke, decoy and frag all land 0 out of 150 past walls of 12, 16, 24 and 40 units, an enemy on the far side of a wall is hurt 0 out of 250 times by a frag aimed straight at it, and an unobstructed throw still travels its full 270. **The fix introduced a trap, so it needed a second pass.** A frag thrown into cover you are stood against lands inside its own blast: measured at a median 85 damage out of 100 to the thrower, worst 91, with nothing to warn him. Two changes: the standoff shrinks when the wall is close, so the charge is never placed behind the thrower (was landing 1 unit behind in the worst case, now always at least 7 in front), and a blocked short throw now calls it out the moment it leaves your hand, "It hit cover. MOVE." for a frag. That makes it a fair mistake rather than an ambush: the fuse is 1.1s, and measured across 100 trials, simply walking away, even after a 0.4s reaction delay, takes **zero** damage in every single case, while standing still takes 85. Warning fires 100 out of 100 times. The bot never throws, so the sim is unaffected: 40 percent extract on the default Scav Pistol loadout, in line with the 33 and 30 measured at v0.57 on the same loadout.
- **v0.59 (correctness, readability):** The coloured pip over an unlooted container lied on every enemy drop. That pip is the one thing that tells you, from across a room, whether the trip to a container is worth the risk: grey for common up to purple for elite, taken from the best item inside. It is worked out when the container is made, and all three enemy-drop paths made a container and then **replaced its contents afterwards**, leaving the pip showing the rarity of loot that had been thrown away. Measured on the shipped build across 40 raids with every enemy killed: **229 of 547 drops, 41.9 percent, showed the wrong colour.** 166 of those understated what was inside, so you walked past loot better than it looked, and 63 overstated it, so you crossed open ground for scrap. Ordinary map containers were correct, 38 of 38, so this was specific to bodies and machine wrecks. The rule now lives in one place, `bestRarity`, with a `setLoot` that assigns contents and recomputes the pip together, so nothing can replace one without the other again. Verified: **0 of 563** enemy drops wrong where it was 229 of 547, map containers still correct at 344 of 344, and the helper agrees with an independent implementation on edge cases including an empty container. Proved on screen rather than only in memory: with the pulse phase held still and only the contents swapped, a body drop repaints 215 pixels shifting grey toward blue for a rare item and 198 pixels shifting grey toward purple for the elite Black Box, which is the correct direction for both. Sim 43 percent on the default Scav Pistol loadout, in line with the 33, 30 and 40 measured on that same loadout at v0.57 and v0.58; this change touches no simulation value. **Worth a playtest note:** the pip is drawn at 0.28 alpha and pulses, so in an unlit corner the colour difference is only a few shades. It is now honest, but whether it is legible enough to act on is his call.
- **v0.60 (correctness, AI movement, and it moves the difficulty baseline again):** Bodies heading for an extraction walked in a straight line at it with no check that they were getting anywhere. There is no pathfinding, so anything with a building between it and the ring pushed on that wall until the raid ended. The container hunts already had a give-up rule for exactly this, with a comment saying so; the extraction run never got one. Measured on the shipped build: **of 44 AI raiders that set off for the ring, 14 ground against geometry for 45 seconds or more, worst case 291 seconds, which is the entire raid.** Walking past one of those is a visibly broken NPC. The same bare move is what the sim bot uses for its own extraction run, so the instrument had the fault too: a median longest stall of 29 seconds per run and 8 timer deaths in a 30-raid batch, all of which the report was blaming on the map being too big for the clock. Both now use `seekPoint`, which watches whether the distance is actually closing and, when it is not, slides along the obstruction for about a second before trying again, flipping to the other side if that was the wrong way round. It is used only where there is no alternative target to pick instead. Verified: raiders stalling 45s or more went **14 to 2** and the worst case 291s to 90s; sim timer deaths went **8 to 2**; and on open ground a run to the ring takes 12.4 seconds against a theoretical straight line of 12.3 with the slide never triggering once, so nothing changed when the way is already clear. **Baseline moves again, and for the same kind of reason as v0.57.** Three batches on the game's default Scav Pistol loadout: **53, 60 and 50 percent extract, mean 54**, against 33, 30, 40 and 43 on that same loadout before this change. The game did not get easier. The bot stopped losing raids to standing against a wall, so the figure is now measuring the raid rather than the fault. On that reading the default loadout sits inside the healthy 35 to 60 band for the first time, but the human number is still unknown because Daniel has not played any of this.
- **v0.61 (correctness, fixing my own v0.60):** The sidestep I added last build kept sidestepping after arrival. A body standing on its destination makes no progress by definition, the stall check read that as being blocked, and a raider that reached the extraction point set off on a lap around it while its timer ran. It stayed inside the ring and cost nothing measurable, missed landings were 1 in 30 beacon calls before and 1 in 30 after, but it was a visible wart I had just introduced. Bodies now stop when the remaining gap is smaller than a single step. Verified: the arrival lap is gone at both timesteps, 0 sidesteps and 0 drift where it previously wandered up to 57 units.
- **v0.62 (correctness, and the third fault found in the measuring instrument):** **AI raiders walked through walls in the bot sim.** Movement is resolved by pushing a body out of anything it overlaps after the step, so a step large enough to land its centre past the middle of a thin wall gets ejected out the far face. This is exactly the fault the dodge roll had at v0.56, which I fixed there and nowhere else. The live game never hits it, a raider covers 6.7 units a frame there and measured 0 pass-throughs, but the sim runs a step three times coarser and **97 percent of raiders walked clean through a 16 unit wall**, the median wall in this game. Crawlers and sentries are wide enough to be caught, so it was raiders specifically. Movement is now sliced so no single step outruns the collision test, which changes the live game not at all (one slice is all it ever needs there) and costs the sim three. Verified: pass-through is 0 percent at 12, 16, 20 and 24 units at both timesteps, and travel per frame is identical to the old code to the unit at four different speeds. Two knock-on repairs were needed once walls became real: the sidestep now applies to every walk toward a fixed point (containers, investigating a noise, extractions) rather than extractions alone, and the bot's give-up rule was rewritten to measure whether the gap to its goal is closing rather than whether it moved at all, because circling an unreachable crate counts as moving and the old check silently stopped firing the moment the sidestep went in. That one regression alone dropped containers opened from about 13 to 2.3 before it was caught. **The number, and what it is now worth.** Three batches on the default Scav Pistol: **27, 27 and 17 percent, mean 24**, with 7.5 to 9.8 containers and the clock as the leading killer. That is far below the 54 percent quoted at v0.60, and the reason is that the bot was walking through walls then. Read it as a floor, not as the difficulty: the bot navigates by walking straight at things and sidestepping when blocked, which is much worse than a person, and timer deaths at 8 to 11 per batch are mostly that weakness rather than the map. Until the bot can route around a building properly, the extract rate says what a poor navigator manages, and Daniel's own runs remain the only real measure.
- **v0.63 (correctness, fixing my own v0.62, instrument only):** The bot's give-up rule ran on a bare 2.5 second timer regardless of what the bot was doing, so a container got blacklisted for the rest of the raid if the bot simply happened to be in a firefight when the timer came round. Being shot at says nothing about whether a crate can be reached. The rule now only judges a goal on time the bot actually spent walking to it. Measured across three runs of 25 raids each, on the same build with only this changed: **containers dropped mid-firefight went from 34, 34 and 33 down to 4, 2 and 5**, and containers opened per raid went from 8.5, 8.5 and 8.0 up to 11.2, 8.6 and 10.9. One measurement mistake of my own is worth recording: a first pass labelled the bot's activity with a guessed approximation of its own branch conditions and reported 151 containers dropped "while running for the extraction". Re-measured against the bot's actual conditions that figure is zero, and the firefight case was the whole of it. The comment in the source carries the corrected numbers. **No effect on the headline.** Three 30-raid batches on the default Scav Pistol: 33, 23 and 13 percent, mean 23, against 24 at v0.62, with containers steady at 8.8 to 8.9. The clock is now the dominant killer at 11 to 13 deaths per batch, roughly 40 percent of raids, which is the bot's navigation and not the map: it spends about 200 of its 300 seconds walking. Nothing here touches the game Daniel plays; this is the test rig only.
- **v0.64 (text cleanup):** The contract board said "sentrys" and "snitchs". The kill contract built its line by bolting an s onto the unit name, which works for crawlers and raiders and not for the other two, so roughly one contract in seven read wrong. The four unit names never change, so the plurals are now spelled out. Verified: 4,000 generated contracts produce 36 distinct lines, all of them correct English, every contract still carries the fields its tracker needs, and across 197 kill contracts the text and the rule still describe the same target with nothing else advancing them. Contracts already sitting on the board keep their old wording until they are claimed and replaced, because rewriting them would mean regenerating them and throwing away progress. **Audited alongside it, no change needed:** all five contract types are actually tracked, including the two whose trackers live in a separate function from the others; the descriptions match the rules in every case; and the bot sim does not advance contract progress, confirmed live by running 30 simulated raids at 9.6 containers each against a profile whose three contracts all stayed at zero. **One observation, not acted on:** the haul contracts pay the most of any type, up to 960c, for extracting with 1600c of loot, and the average successful extraction already carries about 2700c. That makes the best-paying contract the one that asks for nothing you were not doing anyway. It is a tuning question and CLAUDE.md rule 1 puts Daniel's data ahead of my opinion, so it is recorded and left alone.

## Open decision: the Compact SMG is a trap purchase (measured at v0.64, nothing built)
When I added the four issued starters at v0.52 I wrote in the source that they were "tuned at or just under the Scav Pistol and Compact SMG so the shop and loot guns stay upgrades". That claim is false for one of them, and it is my error rather than a design drift.

Measured by firing each weapon at a live target for 20 seconds, three trials averaged, spread and reloads included, against both a stationary and a moving raider. Damage per second:

| weapon | still 150 | still 300 | moving 150 | moving 300 | range |
|---|---|---|---|---|---|
| **Stitcher** (free starter) | **22.0** | **12.7** | **16.0** | **9.3** | 470 |
| **Compact SMG** (2200c, 1000 rep) | 15.0 | 6.6 | 12.0 | 6.6 | 360 |
| Kettle (free starter) | 12.1 | 6.1 | 12.7 | 4.2 | 330 |
| Ferro (free starter) | 11.9 | 11.4 | 10.2 | 7.1 | 400 |
| Scav Pistol (600c) | 11.4 | 8.9 | 10.7 | 6.0 | 420 |
| Hullcracker (free starter) | 6.5 | 0 | 5.7 | 0.5 | 210 |
| Auto Rifle (3800c) | 28.8 | 17.6 | 27.2 | 13.1 | 520 |

**The Stitcher beats the Compact SMG on all four measurements and has 110 more range.** At 300 units it does nearly twice the damage. The SMG costs 2200 credits and 1000 reputation and you can be handed a Stitcher for free on any deploy, so buying it is strictly a waste. The Auto Rifle is comfortably ahead of everything, so the expensive end of the shop is fine; the SMG is the only trap. Ferro and the Scav Pistol are close enough to each other to be a fair trade, and the pistol is your sidearm anyway.

Two ways to fix it, and it is Daniel's call which:
1. **Raise the SMG** so a purchase beats issued kit. Damage 12 to 15 and spread .115 to .095 would put it around 21 at 150 and 10 at 300, just above the Stitcher. Nothing he already owns gets worse.
2. **Lower the Stitcher** so it meets the claim I originally made. Damage 20 to 16 or spread .085 to .105. Cheaper in credits terms but it weakens a gun he may enjoy, on a build he has not played yet.

Recommendation is 1: the shop should reward spending, and no existing gear gets nerfed. Not built, because it is a balance change on a build he has not played and CLAUDE.md rule 1 puts his data ahead of my measurement.
- **v0.65 (correctness, the off-screen noise cue he asked for):** The arrow that appears on the screen edge when something unseen makes a noise was pointing to the wrong place. The bearing to the noise is measured from the operator, correctly, but the arrow was then placed along that bearing **from the centre of the screen**. The camera does not sit on the operator: he rides 54 percent down the view and the whole thing leans toward the cursor, up to 30 percent of the cursor offset while aiming. So the two disagree, and they disagree most exactly when it matters. Measured across 36 bearings in four camera situations: **3.2 degrees out on average with the cursor centred, but 12.5 on average and 22.4 at worst with the cursor pushed into a corner while aiming**, which is the posture you are in during a fight. Twenty-two degrees is the difference between "behind that building" and "down the street". The arrow is now placed where the line from the operator to the noise leaves the viewport, so the cue and the bearing agree by construction. Verified two ways. Numerically: error is **0.00 degrees in all four camera situations** where it was up to 22.4, and all 144 test markers land inside the viewport. On screen: firing a real hostile ping and diffing the HUD layer to isolate the arrow's own pixels, the bearing from the operator to the drawn arrow matches the true bearing to within **0.2 degrees** across five directions, and the sixth correctly draws nothing because that noise was on screen and needs no marker. One measurement of mine to note: a first attempt found the arrow "in the wrong place" and was wrong twice over, once because the test noise was too far away to be audible so nothing was drawn at all, and once because colour matching picked up an unrelated red HUD element. The layer diff is the honest method. Sim 23 percent on the default Scav Pistol, in line with recent batches; this is HUD only and touches no simulation value.
- **v0.66 (correctness, the feedback loop itself):** A run report could vanish with no meaningful signal. Reports go to a local collector over the loopback address, and if that is not listening the code set `lastReport='no drop'` and stopped. The only trace was a small button reading "not saved", which reads like a shrug rather than "the thing this whole project runs on did not happen". That matters more than it looks: **the collector is only reachable over the local server, and Daniel opens the game by double-clicking the file, which is a different address entirely.** Whether a page loaded from a file can reach loopback is not something I could test from here, and I am not going to guess about it. Verified what I could: the collector is live and accepts a report over the server address, and a page on a null origin both fails the send and delivers nothing to the collector. His own history settles nothing either way, because every report in `exports/` predates the collector; he has not played since it was built. So the reporting is now built to survive either answer. If the drop cannot be reached, the report saves to Downloads instead, **once per sitting rather than once per run**, which is safe because `buildExport` writes the entire log and one file therefore carries every raid he has played. Verified: with the drop offline, four runs in one sitting produce exactly **one** file, not four and not zero; with the drop offline and the per-run download setting deliberately on, three runs produce three files as asked; with the drop reachable, **zero** files are saved and nothing prompts him, which was the point of building the collector in the first place. The status now says which of the two happened, "sent" or "saved to Downloads", instead of "not saved". Confirmed the export is genuinely cumulative: a five-raid log produces one file carrying all five runs, all five notes, the version header and the feeling tags. **My own slip, recorded:** one of these tests posted to the live collector and left a file in `exports/`. I removed it, but the rule is that test runs never file a report and I broke it. Sim 43 percent on the default Scav Pistol, console clean; nothing here touches the game itself.

- **v0.67 (readability, the panel he asked for):** Every line of the gear rules ran past the right edge of its own box. The controls panel is a fixed 222 wide and the rule text starts 52 in, leaving about 160 for the words, but all seven lines needed 245 to 392. Measured with the real font rather than eyeballed, they overflowed by **83 to 164 pixels each**, so the rules he specifically asked for spilled out of the panel and over the world behind it. Rendered proof rather than string arithmetic: with the panel open, **2,541 pixels of text sat outside the border before, and 5 after**, the five being antialiasing on the border stroke itself. Every rule is now inside its box with room to spare, split onto a second row where a rule needed the words, and no fact was dropped. The panel grows from 363 to 418 tall and still sits comfortably on screen, top edge at 286 of 720. THROWS also gained the rule that went missing when charges started stopping at walls at v0.58: "They stop at cover, not over." That is the behaviour most likely to read as a bug the first time a frag lands short, and the standing rules panel is where he would look for it. Sim 13 percent on the default Scav Pistol, console clean; this is HUD text only and touches no simulation value.

## Negative result: the residual route-finding failures do not have the cause I thought (v0.79 tick, change written then reverted)

Route finding was shipped at v0.72 with roughly one journey in seven never arriving, and that was recorded as unexplained. Traced properly this tick, and the traces do show a real mechanism: bodies walking 6,000 units while parked at the same distance from the target for the entire run, with sight to the target clear the whole time. Sight is not passage. A 40 unit slot between two buildings passes a ray but not a sentry, which is 44 across, and because sight stays clear the straight line shortcut never hands back to routing, so the body jams there forever.

So a fix was written: sight buys the shortcut only while it is still making ground, and once progress stops the body routes around regardless of what it can see. **Measured on 150 identical journeys on a seeded map, it changed nothing:** 79/89/92 percent arrival at 45/90/140 seconds before, 80/89/92 after. Within noise on every limit. The compound idea, that wider route clearance would only pay off once routing actually engaged, could not even be measured: at clearance 26 enough of the map becomes unroutable that the run bogs down in fruitless searches, which is its own answer.

The change was reverted rather than shipped. It added state and a branch to the most exercised movement function in the game and bought nothing measurable. Recorded here so a future tick does not rediscover the same appealing mechanism and reach for the same fix. What remains true: arrival is 92 percent given the time a real raid allows, the mechanism above is genuinely visible in traces, and it is apparently not what governs the failures.

## 12. Checked and healthy, no action needed

- **Smoke still blocks sight after the v0.78 visibility optimisation (v0.79 tick, no code change).** This was the real regression risk from that change, since it filters wall segments and smoke works by adding temporary ones. In the open the fan reaches exactly 620, matching `viewFar`, and an enemy at 300 units is visible; drop smoke at 150 and the fan cuts to 77 and that same enemy is not visible. Both the fan and `canSee` agree.
- **The dodge roll cannot clip through walls at the current density.** This broke at v0.56 and the map has since gained two and a half times more walls, so it was worth re-testing rather than trusting the old fix. 800 rolls straight into thin walls, from all four sides, at both the normal frame rate and the worst one the game allows: zero pass throughs.
- **A save from before this whole rebuild survives loading.** Four shapes tested, all booting with credits and progress intact and the raid timer correctly taking the new 600s default: a typical v0.67 save, an ancient one with no config version at all, one holding items and weapons that no longer exist, and one with outright wrong types throughout (stash as a string, weapons null, equipped as a number, an invalid condition). The retired entries are filtered out and the equipped weapon falls back safely rather than throwing.
- Bullets cannot tunnel walls by construction: each round is swept against the wall segments before it moves and its travel is clamped to the hit, so speed cannot outrun the test.

- **The path Daniel actually plays, verified end to end for the first time since the v0.70 to v0.79 rebuild (v0.79 tick, no code change).** Everything through that rebuild was checked through the bot, which runs a different code path from a human at the controls. A raid was driven through the live player path instead, with synthetic key presses doing the walking: reach the ring, press the extract key, sit through the inbound wait, raid ends. Three of five completed cleanly and the timing is exactly right, beacon called at 24s ending at 49s, called at 21 ending at 46, called at 37 ending at 62, against a 25 second inbound wait. Movement, collision, the beacon call, the wait and the extraction all work.
- The two that did not finish were the test harness, not the game, and were checked rather than assumed: one sat frozen for 6,991 straight frames with a movement key held, wedged against geometry, and two walked 7,700 units without ever freezing while circling a waypoint. The harness steers by pressing keys at a target with no unstick behaviour, which is the very failure the game's own bodies have `seekPoint` to avoid.
- **Run log growth is not a risk.** A real log row measures 569 characters and the browser accepted 12 million characters without complaint, which is thousands of raids of headroom. The log is never trimmed and the storage write swallows failures silently, which would be serious if the limit were reachable, but it is not. Recorded so it is not re-investigated.
A run of quiet ticks with no new data produced these. Each was measured, not assumed. Nothing here needs doing; the point of the section is so nobody spends another tick re-deriving it.

- **The feedback channel works end to end.** The tags and note box on the outcome screen were driven with real clicks across two raids. Nothing carries over between runs, four tags clicked with one of them clicked twice leaves exactly the right two selected, the highlight always matches the recorded state, and both runs' tags and notes come out in the report both per run and in the summary tally.
- **Whether a page opened as a file can reach the collector still cannot be tested from here.** The browsing tool forces an `https://` prefix and cannot navigate to a `file:` address; the preview pane loads local files as null-origin snapshots, which is a stricter case and proves nothing. The v0.66 fallback makes both outcomes safe and the answer arrives free on his next session: reaches the collector means it lands in `exports/`, fails means it lands in Downloads. **Do not spend another tick on this.**
- **Indoor lamps light through walls, and it does not matter.** 44 percent of an average indoor lamp's glow falls where the lamp has no line of sight, 122 of 179 lamps spilling over 40 percent. On screen, worst case: 1,284 street pixels, 0.51 percent of the street in view, brightened about 5 percent; move the lamp deeper into the room and it is 0.03 percent. Not built, because it needs a visibility polygon per lamp and would darken the streets, which is the one thing he has complained about. The recorder's "lit %" figure **does** test line of sight, so that number is honest.
- **Saved progress has 68 times the room it needs.** A maximally loaded profile, recorder full at its 60-run cap with notes and tags on every entry, 3,000 stash items and a saved bot report, is 73,496 bytes against a roughly 5,000,000 byte allowance. Round trip verified at that size: written bytes match memory, and it reads back with every stash item, run, note, tag and mid-raid note intact. The silent catch in `storeSet` stays as it is.
- **Day really is a look and not a difficulty.** All thirteen places the game asks whether it is daytime are rendering decisions; no gameplay value branches on it. The fog is deliberately thinner in daylight, 0.82 against 0.87, but an unseen safe behind a wall leaks at a peak of 7.8 to 8.2 percent at night against 8.6 in daylight, and night actually has more clearly visible pixels, 43 to 56 against 25. Neither condition gives an advantage. That containers bleed through fog at all is the accepted behaviour recorded in the v0.25 entry.
- **Every window shape works.** Tested at 320, 400, 500, 610, 900, 1280, 1920, 2560 and 3440 wide at the fixed 720 height, each with a full bag and pouch, a beacon inbound, and the inventory and sector map open: no errors, camera always finite, operator always on screen, zero HUD elements drawn off canvas, and resizing mid-raid is fine. Height only bites below 420, where the key legend runs off the bottom. **The 720 in the stylesheet is load-bearing**; if the play area ever becomes responsive in height, the legend breaks first.
- **No sealed buildings.** 2,717 buildings across 320 maps, every one enterable, none skipped, using a fine local fill per building rather than a coarse whole-map one. The earlier "one in 345" was an artefact of my own grid resolution, the same as the 0.6 percent figure that dissolved when it was refined. Building layout has no tunable, so this covers every case. Do not reopen without a concrete case from a real session.
- **The file is structurally clean after roughly twenty-five scripted splices.** No duplicate function or variable definitions, no fixture hooks left behind, no console or debugger statements, no unused top-level variables. 130 functions, 3,966 lines. Two warts to tidy whenever the file is next open for a real reason, never on their own. The sentry spawn line uses an inline closure and `apply` where its three siblings use a plain temporary. And in `bakeGround`, the last substantial function that had never been read end to end, the comment explaining the wall contact shadows sits above the water loop rather than above the shadow loop that runs later, so it describes the wrong code. Both are comment and style only, no behaviour either way.
- **Enemy nameplates read materially dimmer than loot names, and it may be deliberate.** Measured both in the same frame with the same method so the comparison is not an artefact: **nameplate 2.35 against loot label 3.99, about 40 percent less contrast.** Two causes, both plausibly intentional and both easy to change: the nameplate uses a 9px font where the loot label uses 10px, and the idle "has not noticed you" colour is `#9aa6b2` against the loot common `#b9c4cd`, a genuinely darker grey. The alerted states are bright red and orange, so the hierarchy of dim-when-idle and loud-when-hunting is clearly on purpose; the question is only whether the idle end has gone too far to read. **Caveat on the numbers:** absolute contrast figures move a lot with how the glyph pixels are separated from the plate, so only the same-frame comparison is trustworthy here, not the absolute value. Confirmed the plate really renders before measuring, 957 pixels changing when the enemy is added. Not built, because it is a look-and-feel call on a build he has not played. If he says he cannot read enemy names, the font size and the idle colour are one number each.
- **Floating loot names are readable in both conditions.** They are drawn straight onto the world with only a half-opaque backing plate, so daylight brightening the ground could have washed them out. Measured from rendered pixels, all four rarities in both conditions: **night 6.57, 5.89, 4.83, 4.79 and day 5.87, 6.26, 5.16, 4.93, every one above the 4.5 readability threshold**, weakest being elite purple at night. Two earlier passes gave failing numbers and both were my sampling, not the game: the first picked up bright ground instead of the backing plate, the second used a colour-distance test that missed glyphs dimmed by the night layer. Separating by brightness inside the plate rectangle is the method that works. If he ever says loot names are hard to read, the plate alpha is one number and raising it costs no world brightness.
- **The rest of the on-screen text fits, checked the same way the v0.67 overflow was found.** The inventory panel is the other fixed box full of text and it is clean: **not one bag row collides**, even with the safe-pocket diamond against the largest value in the game, the weapon stat line ends 81 pixels short of the edge, and the weapon name keeps a 97 pixel gap from the ammo readout at worst. The one thing with no width limit at all is the message line at the top left. At the default 610 wide everything fits, the longest possible message being a three-item safe haul of the longest-named items, which ends at 485. It would only clip in a window under about 500 wide, and the same information is already shown as floating labels beside the container, which is the readout he actually asked for. Not built. If he ever plays narrow and mentions text running off, `fillText` takes a max-width argument and it is a one-token fix.
- **Spawn distances hold at scale.** 150 maps, 3,150 spawns, not one enemy of any kind closer to the operator than its minimum, and the closest any ever got was exactly its threshold. Sentry 520, crawler 460, snitch 420, raider 700, average distance around 1,200.
- **The game runs at the same speed on any monitor.** At 30, 60, 144 and 240 frames a second: movement, sprinting, stamina drain and the raid clock are identical to the decimal, 604.5 units walked in four seconds, 734.5 sprinting with 22 stamina left, 4.00 seconds off the clock. Regeneration lands within one hit point. The one thing that varies is rate of fire, because a shot can only leave on a frame boundary: a 120ms weapon fires every 133ms at 60Hz and every 121ms at 240, so 30 shots against 34 over four seconds. Inherent to frame-gated firing and not built, since the usual fix trades it for catch-up bursts after a stutter. It shifts every weapon by the same proportion, so the Compact SMG finding below is unaffected by refresh rate.

## 13. What is waiting on Daniel
- **RESOLVED, and it was resolved by him in run #5 (closed v2.30).** This asked what the dropship should do if you are bleeding out inside the ring when it lands, and said the countdown freezes while you are down. Both halves are now out of date. His own run #5 note answered the question: "player should be able to use the beacon and extract while downed". It was built, and the code cites that note. Re-measured on the current build rather than trusted: the beacon TICKS while downed, 10.0 down to 7.0 across three seconds, against the 0.00 in 4.8 this entry recorded; a downed operator can CALL a ring, beacon reaching 22.6 with E held; and all four boarding combinations behave, standing with E extracts, standing without E does not, DOWNED WITH E EXTRACTS, downed without E does not. So a downed player boards by pulling, exactly like anyone else. This entry sat here for thirty builds describing a question that had been answered and a behaviour that had been changed, which is the specific way a stale open-question list wastes his attention and mine.
- **One good raid buys anything in the shop (v0.80 claim, RE-MEASURED v2.32, still true and now by a wider margin).** The v0.80 numbers are all stale and are kept here only so the drift is visible: it said a full bag is worth 4,400 to 5,000 credits and that the dearest item is the Marksman Rifle at 4,500. Current, 120 seeds on BURIED CITY at the default simGreed 52: an EXTRACTED raid banks a mean of 11,338 and a median of 10,885, never less than 5,687. The dearest item is now the Breacher Plate at 7,800, not the DMR, and buying literally everything in the shop costs 26,570. His own eighteen recorded runs are the honest counterweight: five extracted, mean 6,300, best 11,500, so one good raid of HIS does not quite cover the Breacher and two do. Either way the conclusion holds and has got stronger, and his profile is the proof: 13,085 credits banked, nothing bought, still wearing No Rig. Reputation gates still pace unlocks, but credits stop being a constraint almost immediately. This is not something the map change caused; it measures the same on the old map size. Whether that matters is a design call.
- **The clock decides almost nothing, but the backpack no longer decides anything either (RE-MEASURED v2.32, and the mechanism named here is now wrong).** The shape of the finding survives: 120 seeds at the default settings run a mean of 195 seconds and a median of 201 against a 600 second clock, and exactly ONE raid in 120 uses the full ten minutes. So the seven spare minutes he asked for are still spare. But the cause named above is gone. PACKCAP has been [99999,99999,99999] since 2026-08-22, at his own request for unlimited carry, so there is no carry limit to fill up and A HUMAN PLAYER IS NEVER PUSHED OUT BY HIS BAG AT ALL. What ends a bot raid now is simGreed, a bag WEIGHT threshold of 52 that exists only in the sim, so this entry was describing a measurement dial as if it were the game. The open question is real and unchanged in substance: if a raid is meant to be a ten minute commitment, nothing currently makes it one. Carry weight is no longer available as the lever, because he already spent it.
- **RESOLVED at v0.90, by him (closed v2.31).** This asked whether machines should walk around cover to reach you and said route finding was "deliberately not" wired into combat chasing. False: the chase branch calls navSeek at the player in five places, and measured over ten raids, 1,920 of 4,961 chase ticks carry a routed path, 38.7 percent, routes up to seven waypoints. v0.90's note records the decision: "Chase now routes around cover instead of clipping corners, because he approved letting them hunt." Answered by him and built forty builds before this entry was read again. ORIGINAL TEXT: **Should machines be able to walk around cover to reach you? (v0.72)** The game now has real route finding, and it is wired into looting, investigating and extraction but deliberately not into combat chasing. Switching chasing on would make sentries, crawlers and raiders pursue you around buildings instead of snagging on the corner. That is a straight difficulty increase and cuts against "the player is too fragile", which is why it is parked rather than shipped. One line either way settles it.
- **Extraction rings land inside a building about one time in eight (v0.71).** Measured 0 of 120 rings meaningfully obstructed, so they always work; it just means sometimes you extract from indoors. Cosmetic, and his call whether to push them into the open.
Three things, none of which should be built without him saying so.

1. **Verticality.** Cost analysis written, three options, no code. See the open decision section above.
2. **The Compact SMG is a trap purchase.** It costs 2200 credits and 1000 reputation and is beaten on all four measurements by the Stitcher, which is issued free. Two ways to fix it, recommendation is to raise the SMG so nothing he owns gets worse. See the open decision section above for the full table.
3. **A playtest.** He last played around v0.35. Everything since is unplayed, including the four separate fixes that stopped bullets, the dodge roll, thrown charges and AI raiders passing through walls. **The sim extract rate is a floor and not a difficulty reading**, so his own runs are the only real measure of whether the game is now too hard, too easy or about right.
- **v0.68 (his playtest, three notes in one batch):** First real player data since v0.35. He said he dies too fast, the maps feel crammed and want to be far bigger with sparser enemies more like ARC Raiders, he wants at least ten minutes to extract, and he wants to see more. One batch, each change with its reason.
  - **Enemy damage 1.35x down to 1.0x**, because he is too fragile. That multiplier was an arbitrary 35 percent penalty stacked on every listed damage number; removing it is a cleaner resting point than inventing a new advantage. Measured time to go down from full health with no armour: **sentry 4.35s to 5.9s, crawler 2.12s to 2.82s, raider 2.9s to 3.82s, so about a third longer against every threat.**
  - **Map doubled in both directions, 2600x2000 to 5200x4000**, because everything felt crammed. Four times the ground.
  - **Building grid 3x3 to 4x4**, so the extra ground has places in it: about 15.6 buildings a map against 8.5, but spread over four times the area.
  - **Enemies 21 to 26** while the ground quadrupled, because he asked for sparser. Density lands at **0.31x of before, so 3.2 times sparser**, and the nearest machine at drop is now a median 1006 units away against a worst case of 420 before. Measured across 30 raids: first contact moved from about 22 seconds to 59, with **8 of 30 raids having no enemy contact at all**.
  - **Raid clock 300s to 600s**, because he asked for at least ten minutes. The slider ceiling went from 600 to 900 as well, so he can push past ten without me.
  - **Vision cone 100 to 130 degrees, reach 440 to 620, awareness 100 to 150**, because he asked to see more. Measured by rendering a frame against a near-blind baseline: **the revealed part of the screen goes from 25.8 percent to 50.3, very nearly double.** Machine vision is untouched, so this is squarely a player gain.
  - Everything that had to move with the map did: extraction rings now need 1800 clear of the drop and 900 from each other, enemy spawn minimums scaled about 1.7x, loose containers 10 to 18 and loose lamps 14 to 28, ground scatter and water pools scaled off the new area, and the road grid follows the real grid instead of a hardcoded three.
  - **A config migration was needed and nearly missed.** The saved profile stores a full copy of every tunable and overlays it on load, so his v0.67 save would have silently pinned the old five minute clock and old enemy counts onto the new map. Caught in verification, not by reading. Saved configs are now version 3 and version 2 is dropped. Verified against a planted v0.67-era save: the new settings win and **credits, reputation, pack, stash, armoury, equipped weapon, run history, best haul, contracts and every recorder entry with its notes and tags all survive untouched**.
  - Also tidied, since the file was open on those exact lines for a real reason: the sentry spawn line now reads like its three siblings instead of using an inline closure and `apply`, and the wall contact shadow comment sits above the loop it describes.
  - **Verified:** builds clean at 5200x4000 with a 20.8 megapixel ground canvas painted correctly, no errors, 25ms to build a raid. Frame cost 2.1ms median and 3.7ms worst against a 16.7ms budget, so nearly eight times headroom despite 185 walls and 740 wall edges. A full ten minute raid runs to a real end well inside the step budget, 4001 steps used of 4200. Browser check substituted for node --check as usual.
  - **Audited the next tick, clean.** The three things v0.68 could plausibly have broken were checked on the reshaped map. Extraction rings satisfy the tightened rules every single time across 60 raids and 180 rings: closest to the drop 1808 against a required 1800, closest separation exactly 900 against a required 900, and **no pair overlapping and no fallback placements**. Building connectivity survived the grid going 3x3 to 4x4 and cover blocks going 36 to about 100: **1,085 buildings across 70 maps, every one enterable, none skipped**. And every enemy type honours its new minimum from the drop, closest seen being sentry 886 against 880, crawler 794 against 780, snitch 759 against 720, raider 1230 against 1190. The one-cell skip in the building grid is now off-centre rather than central, but it never carried a stated intent and reads as variety either way, so it is left alone.
  - **Hearing still works at the new scale, checked separately.** Noise radii did not move when the map doubled and enemies went 3.2x sparser, so the cue he asked for could have gone quiet without anyone noticing. Measured on a live raid rather than the sim: **401 hostile noise events over two minutes, 266 of them audible, 66 percent**, with something audible 64 percent of the time and the median audible cue at 103 units. It holds up because the footstep cue is already distance-gated at the source, so it only fires when a machine is close enough to matter. Two failed attempts worth recording so nobody repeats them: **the bot sim never fills the ping list at all**, `ping` skips it when `G.sim` is set, so measuring noise there returns a flat zero; and driving a live raid at full frame rate for four raids of two minutes is far too slow to finish, 50ms steps are the way.
  - **The sector map still reads, with room spare if it ever needs it.** Quadrupling the world halved the overlay scale, from 0.1808 to 0.0904, so everything on that screen is drawn at half the size it was. Measured across 40 maps and 120 rings: **no ring drawn off the panel, none too small to read, and not one label collision in 120 pairs**, with the closest two rings 86 pixels apart against label widths well under that. A ring is 10.1 pixels across against 17.1 before, and a building is 30 by 24. Worth knowing if it ever does need more detail: the overlay is limited by a 70 pixel horizontal padding and draws at 470 by 362 inside a 610 by 720 panel, so **there are about 358 pixels of unused height** and dropping that padding would buy roughly 21 percent more scale for one constant. Not built, because it measures as readable and he has not raised it.
  - **What the bot says, and why to discount it:** 33 percent extract, but **19 of 30 deaths are now the clock and only one is an enemy**. That is the bot's navigation, not the map. It walks straight at things and sidesteps when blocked, which compounds badly over four times the ground, and it barely meets an enemy any more. His own run is the only thing that can say whether ten minutes is enough.
- **v0.69 (correcting a false claim I made in v0.68):** Widening the awareness radius to help him see more also handed every machine 50 percent more rear detection, and the v0.68 note said the opposite: "machine vision is untouched, so this is squarely a player gain." It was not untouched. `canSee` used a single shared number for the out-of-cone limit, so `CFG.ambient` governed both how far he notices things behind him and how far every machine notices him from behind. Raising it 100 to 150 moved both. **Measured before the fix: sentry, crawler, raider and snitch all spotted the operator from directly behind at 150 units, against 100 at v0.67.** The two are now separate values: `ambient` is his, a new `eAmbient` is theirs, and only the enemy call site passes it. **Verified: all four machine types are back to noticing him from behind at exactly 100, while his own rear awareness stays at the widened 150 and his cone and view distance are unchanged.** A slider was added for enemy rear awareness so he can tune the two independently. No save migration needed: a v0.68 profile has no such key, so it falls through to the default, confirmed by loading a planted v0.68 save and finding enemy awareness at 100, his own at 150, and credits, reputation, armoury and run history intact. Sim 27 percent with 19 of 22 deaths still the clock, unchanged in character from v0.68. Browser check substituted for node --check.

- **v0.70 (the map was four times bigger but held the same fifteen buildings):** The district grid that lays out buildings was hardcoded at 4 by 4, so it never followed the world size. Quadrupling the map at v0.68 therefore quadrupled the empty ground and nothing else: cover, interiors and containers all stayed at their old absolute counts and so fell to a quarter of their tuned density, which is the opposite of what a longer raid needs. The grid now derives from the world dimensions, and the divisors chosen reproduce the original 4 by 4 exactly at the old 2600x2000 size, so this restores the tuned density rather than inventing a new one. Measured per raid, before and after: buildings 15 to 64, containers 59 to about 207, wall segments 768 to 1924. Enemy counts are untouched, so they stay as sparse as he asked for. The street grid is painted from the same numbers, so the big map now reads as a city rather than a field. Verified across ten generated maps: no overlapping buildings, no extraction ring inside a building, rings at least 988 apart with the nearest 1820 from the drop, nearest enemy spawn 828 away, and zero unreachable buildings at a 4 pixel flood fill. Frame cost went from 2.8ms to 5.5ms against a 16.7ms budget, so the denser map is still comfortably inside frame. Process note: a 10 pixel flood fill reported 1.4 percent of buildings sealed and that was quantisation in the doorways again, the same false alarm as before; I re-ran at 4 pixels before reporting anything. Also fixed my own render fixture, which had been silently half dead: it named castColumn, worldOf, rayRect, zbuf, VM and SPR, none of which exist in this game, and the resulting error killed every hook defined after them. Those names are first person leftovers that drifted in from another project.
- **v0.71 (finishing the density job, and the navigation failure it exposed):** v0.70 fixed the district grid but three more counts were fixed numbers that never followed the world size, all the same bug: street lights (a flat 28), loot left in the open (a flat 18) and water pools (6 to 9 per map). Each was tuned on the old 2600x2000 world, so each was four times too sparse. All three are per area now. The water fix needed a second pass: the shrink ramp that keeps a map from having no water at all was keyed to the raw attempt number, so it hit full shrink at attempt 39 no matter how big the attempt budget was, and every pool after the first few came out at 45 percent size. It now measures how far through the attempt budget it is, with a constant that reproduces the original ramp exactly at the old 48 attempt budget. Verified by rebuilding the map at both world sizes through the same code path rather than by arithmetic: water covers 3.32 percent of the map at 2600x2000 and 3.32 percent at 5200x4000, and buildings cover 26.4 percent against 26.9 percent. Density is now genuinely the tuned original, at four times the size. My earlier estimate of 8.6 percent water was wrong because it ignored the shrink ramp, which is exactly why the measurement was worth doing.
  - **The real find: bodies could not navigate the denser map.** With loot everywhere the sim bot stopped extracting entirely, 0 of 5 with every death to the clock and not one beacon called. Tracing a single raid showed it was not indecision: the bot decided to leave at 230 seconds from 3683 units out, then covered 125 units in the next 270 seconds. `seekPoint` sidestepped for a fixed 1.1 seconds and then flipped direction, which cannot get around anything longer than the sidestep and simply alternates in a corner. That was always latent; quadrupling the buildings gave it four times the concave geometry to catch on. It matters beyond the sim because the AI raider extraction race steers through the same function, so on the v0.70 map that whole feature was quietly dead. It now commits to one side, chosen by casting a ray each way and taking the more open one, and returns to heading straight only when the corridor ahead is clear and it is closer than when it started hugging. First attempt used clear line of sight to the target as the leave condition and barely helped, because sight to a target 1800 units away across a city is almost never clear; it hugged until the timer expired every time. Measured: 1 extract in 10 raids before, 8 in 12 after. Frame cost unchanged at 5.3ms of a 16.7ms budget.
  - **Not fixed, deliberately.** Local wall following still is not a pathfinder and one raid in four or five still fails to reach the ring. The honest fix is a coarse navigation grid with A star over the whole map, which is a real piece of simulation work and is the next thing worth building. Logged here rather than half done.
  - **Checked and healthy at the new density:** the sector map still reads at 64 buildings, 7 percent wall ink against 77 percent background, so it is not a mush. Extraction rings sit inside a building footprint 12.5 percent of the time now that buildings cover a quarter of the map, but 0 of 120 rings were meaningfully obstructed, so they are all still stand-in-able. Whether a dropship landing inside a warehouse is right is a look question and is Daniel's call, not a fault. Sealed buildings are a pre existing quirk of the internal dividing wall, measured at 1.48 percent on the old world size and 0 of 637 at the current one, so the density work did not cause it.
- **v0.72 (the game has route finding now):** v0.71 logged a coarse navigation grid with A star as the next real piece of work, so this is it. `buildMap` now also produces a walkability grid at 16 units a cell, 325 by 250 for the current world, 18.9 percent of it blocked. Cells are marked by testing their centre against walls grown by a body radius rather than by blocking every cell a wall touches; the tidier version closes the 64 unit doorways at this resolution, and a route finder that believes every door is bricked up is worse than none. `navPath` is A star over that grid with a binary heap, no corner cutting between diagonally touching walls, scratch arrays kept on the grid and stamped with a run number so repeat queries allocate nothing, and a string pulling pass that keeps only the corners a straight walk cannot see past. Measured over 25 random cross map routes: 24 found, median 3.7ms, worst 13.3ms, average 6 waypoints, and routes come out 7 percent longer than the straight line, so the smoothing is doing its job. Searches are rationed to one per frame in `refreshVseg`, the only call the live loop and the sim step both make exactly once a frame before anything moves, because a failed search is the most expensive one there is and several bodies repathing together is how you get a visible hitch. Frame cost 5.8ms median and 7.5ms worst against a 16.7ms budget.
  - **Where it is wired in, and where it deliberately is not.** Route finding drives the five places where being stuck is simply a bug: the sim bot heading for loot and for extraction, and raiders investigating a noise, going for a container and running for the extraction ring. Combat chasing still uses the old straight line move. That is a deliberate hold, not an oversight: giving machines the ability to walk around cover to reach you is a real difficulty increase, and Daniel has been asking for the game to be less lethal, not more. It is his call and it is waiting on him in section 13.
  - **Consequences worth stating plainly.** The AI raider extraction race went from effectively dead to roughly all four raiders extracting every raid, because they can now reach the ring. That changes the mid raid population: raiders fill a bag and leave rather than staying on the map, and the extraction announcement now fires about four times a raid. It also removes the reason for the give up hack that made a raider blacklist a container it was making no headway toward; the hack is left in as a safety net but should now almost never fire.
  - **The sim extract rate is no longer a difficulty reading at all.** It went to 20 out of 20 with zero deaths, average raid 160 seconds of 600. That is not the game getting easy, it is the asymmetry: the bot now navigates and the things hunting it still do not. Until chasing is settled either way, treat the sim as a check that nothing is stuck or crashing, and read nothing about balance from it. The old floor framing does not survive this change.
- **v0.73 (verifying v0.72 rather than piling on, and one real defect found):** Two things about the new route finding were unverified, so this tick tested them instead of adding anything. First defect, real and fixed: 4 route queries in 200 failed. Flood filling the walkability grid showed it is fully connected, 65,921 open cells with nothing stranded, so those routes existed and the search was giving up. The cause was the expansion cap at 26,000 against a grid with 65,921 open cells; raising it to 60,000 took failures to 0 in 200 with no change in worst case timing, which confirms the diagnosis rather than just papering over it. The heuristic is now also weighted at 1.25 so the search commits toward the target instead of fanning out across open ground: median query 1.7ms to 1.2ms, 95th 7.6ms to 5.0ms, worst 13.4ms to 11.2ms, and routes came out very slightly straighter rather than worse, 1.096 to 1.083 times the straight line distance. Worst case mattered because a search sharing a frame with a render was close to the 16.7ms budget.
  - **Wall pass through, the historical failure mode, is clean.** Route following makes bodies move more and take corners tighter, and this game has clipped bodies through 16 unit walls before at the coarse sim step. Measured by walking every body every step and testing the movement segment against every wall face: 0 pass throughs in 7,105 live moves and 0 in 8,637 sim moves, with the largest single step 2.0 units live and 22.5 sim.
  - **Process note, the same trap as always.** My first pass at that test reported 3 pass throughs and a largest step of 3,883 units. The step figure is what gave it away: the test tracked bodies by their position in the list, and when a body is removed the list shifts, so it was comparing two different bodies. Keyed on identity instead, the count is 0. The measurement was wrong, not the game, and the giveaway was a number that could not physically be true.
- **v0.74 (route finding made an old rule wrong, and the old rule was still running):** Both the raiders and the sim bot decide a container is unreachable by asking whether their straight line distance to it improved over the last few seconds. That was the best answer available when there was no route finding, and the comment in the code said so in as many words. It is the wrong question now: a route round a 400 unit building deliberately moves you away from the target for several seconds, which is exactly the signal the old rule reads as "cannot get there". Measured before the fix: raiders wrongly abandoned 2.1 containers each per raid, worst case 10. Unreachable now means what it should mean, that the route finder reports no route at all, with the distance test kept only as a long backstop at 12 seconds for a body genuinely wedged on scenery. Both copies of the rule were corrected, and both now clear their state when they pick a new target so a fresh container cannot inherit the previous one's failure. Measured after: 0.81 wrongly abandoned per raider, worst case 5, and the remainder are plausibly real dead ends. Nothing regressed: every raider still leaves with a full bag, average 7.6 items, and the bot still opens about 14 containers a raid.
  - **What this was not.** I expected this to explain why raiders now nearly all extract, and it does not. All 16 raiders measured left with a full bag rather than because they had run out of targets, both before and after. The hypothesis was wrong and the measurement said so; the fix stands on its own smaller merits, which are that a body detouring round a building and then abruptly turning away from its target looks broken.
- **v0.75 (two hypotheses refuted, one real fix, and the eye substitute is back):** `navSeek` threw the route away whenever the target came within 200 units and fell back to feeling along the wall for the last stretch. That is precisely where the route matters most: the last 200 units to a container inside a building is short and has a wall across it, so a body would walk the route perfectly, arrive at the doorway, drop to the dumb behaviour and never get in. It now keeps the route until the target is actually in sight. Measured on 90 identical journeys with a body that had to get somewhere out of sight: arrivals plateau at 86 percent against 82 before, and they arrive about 5 seconds sooner. The old wall hug on those same journeys plateaus at 60 percent, so the route finding is worth roughly 26 points of arrival rate.
  - **Two wrong hypotheses, both killed by measurement rather than by argument.** First, I thought the residual failures were sentries being routed through gaps too narrow for them, since the grid clears a radius of 12 and a sentry is 22. Built four grids at clearances of 12, 16, 22 and 26 and ran the same 90 journeys through each: 79, 82, 79 and 79 percent. Clearance makes no measurable difference and the change was reverted. Second, I thought quadrupling the lights at v0.71 had changed how bright the map looks. Rendered the same scene with all 211 lights and then thinned to 53, the old count: mean screen brightness moved by 0.11 out of 255. Only the handful of lights near you are ever on screen, so the count barely matters. Both of these are recorded because the plausible mechanism was wrong both times.
  - **Reading the finished frame works after all, so rendering claims can be measured again.** I had been telling Daniel for three builds that nothing was verified by eye because the preview pane will not composite for screenshots. The pane still will not, but the game draws straight to the visible canvas, so its pixels can be read directly. An earlier read that came back 96 percent black was correct and I misjudged it: a night scene under fog of war genuinely is mostly black. Confirmed the meter responds properly by sweeping the brightness setting, which moves the screen from 92.5 percent black at 0.6 to 29.6 percent at 3.5, so that control is working and is not the source of any darkness complaint.
  - **Checked and healthy:** loot clutter at the new density is fine, a median of 6 containers on screen with a median of 0 overlapping markers and a worst case of 2.
- **v0.76 (correcting my own performance claims, and one change that follows from it):** Every frame cost figure quoted from v0.70 to v0.75, all those "5.5ms against a 16.7ms budget" lines, measured only the JavaScript half of a frame. Canvas drawing commands are queued and return immediately, so stopping the clock after them times the script and not the picture. Worse, all of those readings were taken at the preview pane's 610x720, which is nothing like a real play window. Forcing the canvas to real sizes shows script cost is essentially flat, 5.7ms at 610x720 through to 5.5ms at 1920x1080 with a 3840x2160 backing store, which is itself the tell: genuine drawing cost cannot be flat across a tenfold increase in pixels. It is flat because it is not being measured.
  - **The drawing half cannot be measured in this environment at all.** Forcing a rasterisation flush by reading a pixel back gave 13ms, 90ms and 76ms at increasing sizes, but that reading is worthless: reading back from a canvas can drop it out of GPU acceleration entirely, so the probe was measuring the damage it had just caused. The honest method is frame pacing through requestAnimationFrame, and the pane suspends animation whenever it is not displayed, so it never fires. Recorded as a hard limit of this setup: script time here is real, drawing time is unknown, and no claim about frame rate should be made from this machine.
  - **The change this justifies.** The baked floor is 5200x4000, about 21 million pixels, and it was handed to the compositor whole every single frame with a clip doing the work of hiding it. At most a screenful can ever be visible. It now submits only the on screen rectangle. Verified pixel identical against the previous build on a seeded map: 4 camera positions at 1280x800 and 7 more at 1920x1080, deliberately including all four map corners and positions pushed past the edges, all identical. Stated plainly: the saving is not measured, because it cannot be measured here. This rests on submitting ten to twenty times less image per frame, not on a number, and Daniel's machine is where it would show.
  - **Checked and healthy with the restored pixel meter:** an enemy body against the floor at 200 units in the cone reads at 0.6 Weber contrast, mean body luminance 34.7 against floor 22 and peaks over 54, so bodies are clearly distinguishable and are not the source of any "renders black" complaint. At a realistic 1600x900 window, 71 percent of the screen is fog black and 29 percent carries content, which is the fog of war working as designed rather than a fault, though it is the number to look at if he ever asks again to see more.
- **v0.77 (a quarter of the drawing work was for cones nobody could see):** The sentry scan cones on the ground were rebuilt for every sentry on the map every frame, with no check for whether the sentry was anywhere near the view. A cone is 19 raycasts and each raycast tests every wall segment in the world, which is now 1,924 of them. Measured at a 1600x900 window across 10 raids: 9 sentries a raid, an average of 0.4 of them with a cone able to touch the screen, so 96 percent of that work produced nothing. The loop now skips any sentry whose cone cannot reach the view, tested against the alert reach so a cone can never pop in late. Measured before and after on the same seeded map: render script time 4.6ms down to 3.5ms, a saving of 1.1ms and 24 percent, which matches the 1.1ms the cone work was measured to cost. Verified pixel identical across 5 frames with sentries planted at deliberate boundary distances including 790 and 900 units, straddling the cutoff.
  - **Why this was worth doing even though frame rate is unmeasurable here.** Unlike the floor change at v0.76, this saving is in the half that can be measured on this machine, so it is a number rather than an argument. It was also spotted and waved past at v0.70 on the grounds that performance "seemed fine", which was exactly the reasoning that turned out to be built on a half measurement.
- **v0.78 (the visibility fan was testing the whole world for every ray):** Following the same class of waste found at v0.77. The player's visibility polygon costs 2.45ms and is 74 percent of all render script time, and it casts roughly 250 rays each of which tested every one of the map's 1,934 wall segments. Measured, only 152 of those segments are within reach of the fan at all, so 92 percent of the work was testing geometry no ray could ever touch. A new `segsNear` filters to the segments whose bounding box lies within the ray reach, once per fan rather than once per ray. This is an exact filter and not an approximation: a ray capped at r cannot reach a box outside r. Filtered by the wider of `viewFar` and `ambient`, since out of cone rays use the second. The sentry cones now use the same filter.
  - **Measured before and after on the same seeded map at 1600x900:** the visibility fan went from 2.6ms to 0.3ms, down 88 percent, and whole render script time from 3.5ms to 1.1ms, down 69 percent. With v0.77 in front of it, render script time has gone 4.6ms to 1.1ms across two builds, a 76 percent reduction, and total script time per frame is now 2.1ms.
  - **Verified equivalent rather than assumed.** A wrong filter here would silently punch holes in the fog, which is why this was checked on the visibility shape itself and not only on pixels: 14 positions and facings across the map, tight interiors and open ground, with both the polygon and the rendered frame identical in all 14.
  - **Still unmeasurable:** none of this touches how long the drawing itself takes, which this environment cannot time at all. See the v0.76 note.
- **v0.79 (the pipeline this whole loop runs on was dropping five raids in six):** Eight ticks without data prompted a check of the reporting path rather than more of the game. Reports go first to a quiet local drop and fall back to saving into Downloads. The fallback saved exactly once per sitting and never again, and because the file is written at the moment of saving, the single copy he ever handed over contained his first raid and nothing after it. Proven by driving the real code path with the drop unreachable rather than by reading it: six raids played, one file saved, five lost silently. Now it saves again once raids pile up, on every second one, which the same probe confirms: six raids, three saves, at most one raid ever waiting. The whole log goes into every save, so a save at raid five carries raids one to five, and the one raid that can still be pending is picked up at the start of the next sitting.
  - **A second defect in the same place, arguably worse because it was reassuring.** When a raid was not saved, the status read "in Downloads already". That state means the opposite: the raid was not written anywhere. It now says how many raids are actually waiting, confirmed rendering as "Auto-report: ON (1 raid not saved yet)".
  - **What could not be tested.** Whether the quiet drop is reachable when he opens the game by double-clicking the file, which is the case that matters most since the collector is only running while I am working. The pane has no genuine file address to test from; the closest available reported a null origin and the request failed, which is suggestive but is not the same thing and is not being treated as a result. This is exactly why the fallback matters, and the fallback is now the part that works.
- **v0.80 (a sale that trusted a button, and the economy measured properly):** Started by checking a consequence of my own density work, since quadrupling the loot on the map should in principle have inflated the economy. It did not, and now that is measured rather than assumed: with the bot looting to its carry limit, a raid yields 4,793 credits on the pre-v0.70 map size and 5,012 on the current one, with 30 and 29 items out. Carry weight is the binding constraint, not how much loot is lying about, so the map change left the economy alone.
  - **The defect found on the way.** The shop's purchase handler re-checked the price and then trusted the button for everything else, so the reputation gate and the backpack tier order existed only as a disabled attribute. Measured: re-enabling a locked row and clicking it completed the sale, 280 credits spent and a locked item added to the stash. Six such forced purchases now all refuse, with credits, weapons, stash and pack tier untouched, while legitimate buying still works exactly, 9,000 credits less an SMG, a Tier 2 and a Tier 3 leaving precisely 5,050. Honest about reach: there is no path to this in normal play, since reputation only ever rises and the shop redraws after every purchase. It is fixed because a sale should stand on its own conditions rather than on the state of a button drawn earlier, and because the handler already re-checked one of its three conditions, which makes the other two an oversight rather than a decision.
- **v0.81 (the same fault as v0.80 in two more places, and one of them was worse):** v0.80 found a shop sale that trusted the button rather than checking its own conditions. That is a class rather than a one off, so the other transactions were swept: crafting, contract claims, selling and equipping. Two more instances, and crafting was the worst of the three.
  - **Crafting never checked the materials at all.** It walked the recipe removing each ingredient it could find, silently tolerated any that were missing, and awarded the output regardless. Measured: 7 recipes forced against a completely empty stash produced 7 items out of nothing, an armour plate and a frag charge among them. It now verifies the whole recipe first and builds the new stash to one side, committing only at the end, so a craft either happens in full or not at all and can never eat half the ingredients for nothing. Verified both ways: 7 forced crafts on an empty stash now yield 0 items, and a legitimate craft consumes exactly 3 scrap and 2 wire from a stash of 12 and returns 8 with the output present.
  - **Contract claims did not re-check completion or which contract they were paying.** Now they do both, so a row drawn earlier cannot pay out twice. Verified: a legitimate claim pays exactly 450 credits and 450 rep, a repeat click on the same stale row pays nothing, and an unfinished contract offers no button at all.
  - **Reach, stated honestly as with v0.80:** none of this is reachable by playing normally, because every one of these panels redraws after each action. It is fixed because the pattern is now demonstrably repeated across three separate transactions, and because crafting in particular failed open rather than closed, which is the worse direction for a rule to fail in.
  - Selling and equipping were checked in the same sweep and are sound: both verify the item is actually held before acting.
- **v0.82 (going down stopped the recorder, and stops the dropship):** The downed branch of `updatePlayer` returns before any of the recorder or extraction work, which turns out to have two separate consequences.
  - **Fixed: a crawl was not counted as movement.** Distance walked and closest approach to extraction both stopped updating the moment the player went down. Measured before: crawled 38 units nearer the ring and the record still read the distance from where the crawl began, with zero distance walked. Dying a short crawl from extraction is one of the most telling moments in a raid and it was being filed as never having moved. Both now count the crawl: 216 units crawled records exactly 216 and closest approach follows it down, while upright movement still records exactly one to one with no double counting. This is recorder only and changes nothing about play, but it feeds the death reports these builds are tuned from.
  - **Not fixed, because it is a design call: the beacon stops counting while you are down.** The inbound countdown lives in the same skipped work, so it freezes. Measured: upright it ticks 4.99 seconds in 5, downed it ticks 0.00 in 4.8, while the bleed out timer and the raid clock both keep running normally. So one timer stops and two carry on, and the dropship effectively waits for you to get up. It also means the landing cannot resolve at all while you are down: it can neither take you nor leave without you. The question is what should happen when the ship lands on a player bleeding out inside the ring, and there is a real choice: hauled aboard unconscious, which is generous and dramatic, or the ship leaves and you have to call it again, which is harsh and makes the ring a place you have to be standing. Both change the feel of the most tense moment in the game, which is why this is his and not mine.
- **v0.83 (dodging was quietly costing you health):** Same shape of fault as v0.82, in the other branch that returns early. The dodge roll skipped the recovery tick, which also drives the out of combat timer that gates recovery, so rolling held back healing without saying so. Measured over 40 seconds from 40 health: standing still recovers 10, rolling as often as stamina allows recovers 7, and 8.4 seconds of out of combat timer simply never happen. Time spent mid roll was 21 percent, which lines up with the loss. Nothing in the design says a defensive move should cost healing, and the roll is precisely what a player under pressure does over and over, so the penalty landed hardest exactly when it hurt most.
  - Verified all four ways after the fix: rolling and standing still now both recover 10 health over the same 40 seconds, the out of combat timer reaches 40 either way, stamina is still drained by rolling (23 against 100) so the meter still means something, and the delay before recovery starts is untouched, with nothing healed during the first 8 seconds of the 10 second wait.
  - Stamina recovery is deliberately still skipped during a roll. Not recovering stamina while exerting yourself is the point of that meter, so that one is a rule rather than an oversight.
- **v0.84 (Chrono Trigger art direction, on request):** Daniel asked for graphics in the style of Chrono Trigger. Read as wanting that game's art LANGUAGE applied to this setting rather than turning a dark stealth shooter into a bright daytime JRPG, which would have gutted the tension the whole game rests on. Three independent art directions were developed and judged against each other; the winner recolours by HOLDING LUMINANCE AND MOVING HUE, which is the only approach that repaints the value structure without paying for it in stealth.
  - **What changed.** Darkness is deep indigo instead of neutral black. Lamps lay down warm pooled light in two flat concentric steps rather than a smooth falloff, and this is now the only place a lamp's own hue reaches the screen at all, which previously made the district light column very nearly decorative. The four district palettes were re-authored as genuine hue families, terracotta, cold steel blue, verdant green and violet stone; three of the four floors used to be indistinguishable greys so the district system did no visual work whatsoever. The flat black wash that multiplied every wall front face by 0.78 is deleted, which is what lets the authored wall/top pair actually separate, and walls gained a warm top lip and two ink creases. Every body on the map now carries a hard dark contour, which nothing in the game had before. The operator was rebuilt to Toriyama proportions inside the SAME 34px envelope: head 8x8 to 12x10, from 23 percent of the figure and narrower than its own shoulders to 31 percent and shoulder width, boots 4.8 to 6.2 wide, torso shortened. Big head, big feet, short torso is literally the formula. The interface became navy windows with light double borders, the CRT scanline overlay is gone, and the three overlays that were a flat black wash with content floating loose on them now have real frames.
  - **The plan's central claim was arithmetically wrong and measurement caught it.** The whole justification for the winning direction was that its new navy fog holds luminance: quoted as 6.5 against the old 6.7. Recomputed, rgb(5,6,26) is luma 7.98, not 6.5. Measured in the build, the hidden 92 percent of the screen went from 9.76 to 14.07, a 44 percent brightening of exactly the thing that hides enemies. The values were re-authored by iteration against the meter rather than by trusting the arithmetic.
  - **Stealth verified by the test that actually matters.** A sentry placed outside the vision cone produces a pixel-for-pixel identical frame, before and after, mean and max both unchanged: enemies remain completely invisible through fog, because entities are gated on `e.seen`. What did move is fogged ground, up 1.25 out of 255, because walls and floors are drawn unconditionally and 13 percent of the world reads through the fog. So the map layout is very slightly more legible through fog than it was. That is the honest price of making the world colourful and it is stated rather than buried.
  - **Two genuine day-mode bugs fixed on the way.** Day/night is consulted in only three places in the entire ground bake, so roads were hardcoded to a night value and stayed dark at noon, reading as trenches cut through a lit city, and building interiors stayed night-dark while the world outside them lightened.
  - **Cost and safety.** Frame script time 1.1ms to 1.4ms of render, 2.6ms total against a 16.7ms budget. Bot sim statistically unchanged (5/5 extract, 15.4 containers, no hangs), which is the negative control: nothing here touches simulation, AI, collision or line of sight, so a shifted sim result would have meant something was edited that should not have been. `roundRect` is new API surface in this file and is feature-tested, degrading to square silhouettes rather than throwing inside the draw loop.
  - **Not verified: the interface.** The HUD and hub changes are in the HTML layer, which cannot be exported as an image the way the canvas can, so the new window frames are confirmed by reading back computed styles (panel borders are periwinkle at 5px radius, window gradients live) and not by looking at them. Worth his eye.
- **v0.85 (the interface got looked at, and it was hiding a button):** v0.84 shipped the whole HTML interface layer unverified, on the stated grounds that it cannot be exported as an image the way the canvas can. That turned out to be wrong, and the technique is worth recording: serialise the live DOM through `XMLSerializer`, wrap it in an SVG `foreignObject`, strip the font `@import` (an external fetch makes the SVG silently fail to load), rasterise it to a canvas and read it back. A raw `cloneNode` will not do, because a foreignObject must be well formed XML and the DOM is not; validating with `DOMParser` first turns a silent blank image into a real error message. So the interface can now be inspected exactly like the world.
  - **What it found.** Below roughly 820 pixels of window width the six button row at the bottom of the terminal, which is `flex-wrap:nowrap`, ran off the edge and clipped the last button entirely. That button is TUNING, the console he adjusts the whole game from, so in a narrow window it was not cramped, it was unreachable. Measured across seven widths: clipping from 520 through 700, clean from 820 up. Mostly pre-existing, but v0.84 took the button borders from 1px to 2px and moved the threshold about 12 pixels the wrong way. The row now wraps: measured across the same widths, zero clipped buttons everywhere, two rows below 820 and the wide layout untouched at one.
  - **Checked and healthy.** The new inner window border is an `::after` overlay covering each panel, which is exactly the shape of change that swallows clicks. It carries `pointer-events:none` and an in-panel SELL button hit tests to itself, so interaction is intact. One earlier reading suggested the deploy button was unclickable; that was the preview pane being 550 tall while the game is 722, so the hit test was landing below the pane's viewport rather than on an obstruction. Checked before claiming.
  - At a realistic width the terminal reads as intended: navy windows with light double borders, gold accents, the primary action on a gold plate. The squashed four-line button text in the first capture was purely the 612 pixel pane and not a fault.
- **v0.86 (looked at the rest of the interface, which v0.84 recoloured blind):** With the DOM capture from v0.85 working, the four surfaces that got new window frames without anyone ever seeing them were inspected: requisition, the tuning console, the outcome screen and the note fields. All four frame correctly. One real gap found and fixed: text fields kept the old near-black background while everything around them moved to navy, so the run note box and the bot sim output read as holes punched in the window rather than recessed fields in it. Both now sit in the navy family with an inset shadow. Two hover states were also still using the pre-v0.84 amber and now match.
  - **A false alarm, caught before it was reported.** In the captured tuning console every slider thumb sat at the same position regardless of its value, which would have been a serious bug across 23 sliders. It is an artefact of the capture technique: native form controls do not rasterise faithfully inside an SVG `foreignObject`. Reading the DOM directly shows 23 sliders with 18 distinct thumb positions spanning 18 to 93 percent of range, so they are all correct. **Recorded as a standing limitation of this tool: it is reliable for layout, colour, borders and text, and not for the rendered state of range inputs, checkboxes or selects. Verify those by reading values, never from the picture.**
  - **A second false alarm from the same tick.** The outcome screen appeared to be missing its feeling tags, which would matter a great deal since those are how Daniel reports back. The container is `#tagwrap`; the test had guessed `#oc_tags` and so populated nothing. Rendering the real tag list confirms the screen is complete: ten tags, selected ones in gold with dark text, unselected periwinkle on navy, all legible.
- **v0.87 (the key legend was drawn on top of the health bars):** Captured the last two surfaces the v0.84 art pass had recoloured without anyone seeing them, the walkable Undercroft and the in-raid HUD. The Undercroft reads as intended, navy stone under a warm pool with the station lights carrying the only other colour in the room. The HUD showed a real collision.
  - **The fault.** `drawLegend` sized its panel as `top=H-16-boxH`, so the box bottom landed 12 pixels from the screen edge. The armour, health and stamina meters sit from 42 to 13 pixels from that same edge. The legend is drawn AFTER the bars, so it painted its own panel straight over all three. Since the legend is on by default this was the normal state of the screen and not an edge case, and it is long standing rather than anything the art pass introduced: the geometry was untouched by it. Confirmed by arithmetic rather than by eye, after a first pixel based attempt at measuring the overlap turned out to be detecting the legend's own green section headings and not the health bar at all.
  - The panel now stops at 48 pixels from the edge, clearing the meters by 6, and is clamped so a short window loses the bottom of the list rather than the top, since the headings are what make it navigable. Verified in a capture at 1280x720: meters legible, panel clear of them.
  - Sim unchanged at 5/5 with no hangs, frame script 2.4ms of a 16.7ms budget. This is an overlay-only change and touches nothing in the simulation.
- **v0.88 (the sector map was the last surface still wearing the old palette):** Found by continuing to look at states nobody had seen. Holding M dropped you out of a navy and amber game into a grey one: `drawMapOverlay` still used the pre-v0.84 near-black backdrop, grey frame, grey wall marks, old amber title and old ash subtitle. The district block fills had come through correctly on their own, because they read `DISTRICTS` directly, which is exactly what made the mismatch look deliberate rather than missed.
  - Backdrop is navy, the frame is the same double border as the terminal windows, wall marks moved from grey to periwinkle, water and the extraction ring to the new teal, and the operator marker got an ink ring so a gold dot can never vanish into a gold district block. The periwinkle wall marks are also plainly more legible than the grey they replaced, which is a readability gain rather than only a colour match.
  - Cost is irrelevant here and worth stating so it is not re-examined: the overlay is only drawn while M is held, and it measures 0.2ms. Frame script is unchanged at 2.5ms of a 16.7ms budget and the sim is unaffected, this being an overlay-only change.
  - **Running note on the method.** Three consecutive real defects have now come from capturing a surface and looking at it: the tuning button clipped out of reach at narrow widths, the key legend painted over the health bars, and this. None were findable by reading the code, because none of them are wrong in isolation; they are only wrong in combination or in context. The remaining never-captured states are combat with muzzle flash and tracers, the downed crawl, the inventory panel and smoke.
- **v0.89 (opened it in his own Chrome, which found two things immediately):** Daniel asked to play it in Chrome rather than the preview pane. Two faults were visible in the first screenshot, neither of which any amount of code reading had turned up.
  - **The header separator was mis-encoded.** "900c Â· REP 0 Â· 0 in stash" rendered on every hub frame. The bytes were C3 82 C2 B7, a double encoded middle dot, in three places. Repaired at byte level to a single U+00B7. This was flagged in the v0.84 art plan and not acted on then; seeing it on screen is what made it real.
  - **The game did not fit the window.** `#root` was a fixed `height:720px` while his Chrome viewport was 551, so the health bar, the meters and the entire bottom button row sat below the fold behind a scrollbar. It is now `100vh` with a 520 floor, and the page's own default margin, which was leaving 18px of overflow and putting the scrollbar back, is zeroed. Verified fitting exactly with no scroll.
  - **Process failure, mine.** He was playing while I was working, and I reloaded his tab twice to pick up fixes. That killed a raid mid beacon countdown and he reasonably reported it as a beacon bug. His profile confirmed the cause: zero runs logged and credits untouched, so the raid was cut off rather than completed. The beacon itself was then verified independently in a separate copy: four extractions, each waiting 25.0 to 25.1 seconds against a 25 second setting, all ending correctly. **Standing rule from this: never navigate or reload a tab he is playing in. Read it with script if state is needed, and let him refresh when he chooses.**
- **v0.90 (first real playtest data, and it says the raid had no tension in it at all):** His v0.89 run: extracted in 314s with 4345c and 30 items, 18 containers, 7 shots fired, one crawler killed, no downs, no heals, **first enemy contact: NONE**, zero seconds crouched, nine seconds sprinting, and all four AI raiders extracted. Tagged "Loot boring" and "Extract too easy". He never met a single enemy in a five minute raid, which is why nothing was tense. That is the direct consequence of my own earlier work: he asked for sparser enemies on a bigger map and got 26 bodies spread over 20.8 million square units, so crossing paths with one became unlikely.
  - **Batch, one line each.** Enemy counts 9/10/3 to 13/15/4 sentries, crawlers, snitches, because he made zero contact in a full raid. Chase now routes around cover instead of clipping corners, because he approved letting them hunt and it is the difference between an enemy that finds you and one that loses you at the first wall. Backpack 40/60/80 to 55/80/105, because he chose bigger. The dropship keeps flying while you are down and takes you if you are in the ring, because he chose hauled aboard, and it also fixes the countdown freezing mid air. Config version bumped to 4 so his saved settings cannot silently pin the old enemy counts over the new defaults.
  - **Also shipped: camera zoom**, which he asked for. Mouse wheel, or plus and minus, or 0 to reset, from 65 to 200 percent, stored on the profile so it persists. The hard part was not the scale: the light and fog layers are separate offscreen canvases that were converting world positions to screen by hand, so they needed the same transform or the lighting would slide off the ground as you zoomed. Verified at 70, 100 and 180 percent that the lit pool still lands exactly on the player and that cone, fog, sprites and nameplates all stay locked together.
  - Measured after: enemy contact in 5 of 6 sim raids against effectively none before, 36 enemies per raid, no pathing hangs, frame script 2.8ms of a 16.7ms budget.
  - **Not addressed yet: "Loot boring."** That is the same complaint as "maps feel samey" and it needs content rather than tuning: landmarks, themed districts, real interiors. Next.
- **v0.91 (dropping and autoloot, the two features he asked for by name):** Both were specced two builds ago and neither had been built. Delivered together because they are the same system.
  - **Manual drop.** The inventory now has a selection: up and down move a highlight, Z drops the selected item. The arrows double as movement keys, so while the bag is open they select instead and WASD still walks, which means sorting does not root you in place with hunting enemies about. A dropped item lands as a fast-to-search pile at your feet rather than being destroyed, so it is a decision you can walk back. The list scrolls to keep the highlight visible, which matters because a full bag is longer than the panel.
  - **Autoloot.** Toggled with C, off by default, stored on the profile. When the bag is full it sheds the worst thing rather than refusing you. Worst means lowest value per unit of weight, not lowest price, so a heavy cheap thing goes before a light cheap thing. It never sheds rare or elite, so it cannot throw away the run; a bag of nothing but rares still refuses, which is his stated guard working.
  - **Verified against his spec, three cases.** Grossly overloaded: 100 weight down to 54 against a cap of 55, 35 items shed, every one recoverable on the ground, no rare or elite lost. Barely over: sheds exactly 3 and stops. Bag of nothing but rares: sheds 0 and refuses, as specified.
  - **The carry limit turned out to be softer than it looks**, which is worth recording: it gates STARTING a search, not the pickup itself, so a single container can push you well past capacity. That is why his 30-item run was possible. Autoloot hooks exactly that gate, which is the right place.
  - One layout fault found by looking, twice: the new control hint printed over the last rows of the item list. A fixed reserve of 22 pixels was still not enough, so the hint is now positioned from the measured end of the list rather than from the panel height.
  - Sim unchanged at 6/6 with no hangs, frame script 2.7ms of a 16.7ms budget.
- **v0.92 (sound, his named biggest gap):** He said the main thing stopping the game being frightening is sound, and approved building it even though I cannot hear a note of it. There WAS sound already, six one-shots for gunfire, hits, pickups and alarms, which is why "there is almost none" needed unpacking: everything arrived dead centre, so a shot in the dark told you it had happened but not where, and there was no floor of noise for anything to cut through.
  - **Everything is placed now.** A shared bus with a stereo panner, and a helper that turns a world position into distance and pan. Every existing sound was moved onto it: enemy gunfire, explosions, ricochets, alarms, thrown gear. Your own weapon deliberately stays centred, because it is in your hands. In a game built on not being able to see, direction is the largest single thing sound can give back.
  - **Footsteps for things you cannot see.** The nearest moving body within earshot emits a placed footstep, machines lower and slower than bodies, faster when hunting. This is the point of the whole pass: the fog stops being an absence and becomes something you listen to.
  - **An ambient bed** of two detuned low oscillators and filtered noise, running continuously and only ever changed by gain, so it costs nothing per frame. Its filter opens and its pitch lifts as something hunting gets closer, so the room tightens before you can see why. A heartbeat comes in under 45 integrity and speeds up as it falls, and again while downed.
  - **What I verified, since I cannot hear it.** The graph builds and stereo is supported. The ambience creates ZERO new audio nodes across 300 frames, so it is genuine steady state rather than a per-frame leak, which is the failure mode that would kill the tab. Panning reads -0.77 left, +0.77 right, 0.00 dead ahead. A moving enemy 200 units away produces about five footsteps in three seconds; the same enemy 3000 units away produces exactly zero nodes, so distance culling works. Audio costs under 0.005ms a frame and total script time is unchanged at 2.8ms of a 16.7ms budget. Sim unaffected and silent, as it must be for a 30 raid batch.
  - **What I cannot verify: whether any of it sounds good.** Levels, pitch, whether the heartbeat is tense or annoying, whether the footsteps read as menace or as noise. That is entirely his call and the loop is slow: he listens, he tells me, I adjust blind.
- **v0.93 (landmarks, against his top complaint that maps feel samey):** The answer to samey is not more procedural variation, it is somewhere you RECOGNISE. Five hand authored places, three per raid, each taking a whole district cell so it reads as a location rather than one more box: COLLAPSED TOWER (a broken ring with its north face fallen in, rubble inside, thin but valuable loot), CARGO YARD (parallel container rows forming straight corridors, geometry nothing else in the game produces, stocked heavily), CHECKPOINT (a barricade line with a single gap and flanking blocks, a pure cover fight, ammunition), RELIEF STATION (a real interior with two doors and internal partitions with staggered openings, so it is rooms rather than a box, medical loot), FLOODED PLAZA (deliberately open with pillars and guaranteed water, so crossing it is loud and there is nothing to hide behind).
  - **Naming is most of the point.** Each is boxed and labelled in gold on the sector map, and the game names it as you walk in. Distinctive geometry you never learn the name of is just terrain; a name is what turns it into somewhere you can plan around and go back to.
  - **They are worth visiting**, or they would be scenery: each stocks containers matching what its name promises, at its own density, so going somewhere specific beats searching the nearest box.
  - **Verified across 10 generated maps:** exactly 3 landmarks each, all five kinds appearing across the sample, zero overlaps with ordinary buildings, and all 30 interiors had a reachable walkable spot, which matters because a landmark you cannot enter is a wall. Sim: contact in 5 of 6 raids, no pathing hangs, 263 containers, frame script 2.5ms of a 16.7ms budget.
  - Still open from the same complaint: themed districts per raid, deeper interiors, and weather. Landmarks were the largest single piece and the one that gives the map a memory.
- **v0.94 (weather, the other half of "maps feel samey"):** Landmarks stopped the map being anonymous; weather stops the same ground playing the same way twice. Five conditions rolled once per raid, and every one of them is a tactical condition rather than a filter over the top, because each changes how far you see and how far you are heard.
  - **Measured effects, straight out of the build.** Against a base of 620 sight and a 300 unit noise ping: CLEAR 620 sight, 300 noise, lamps full. RAIN 540 sight, 180 noise, lamps full. FOG BANK 360 sight, 300 noise, lamps at 85 percent. BLACKOUT 620 sight, 300 noise, every lamp dead. STORM 480 sight, 144 noise, lamps at 55 percent, plus lightning.
  - **Rain is the interesting one** because it cuts noise BOTH ways: it hides your footsteps and it hides theirs, which is a genuine trade rather than a straight buff. Fog is the opposite, a straight loss of information for both sides. Blackout leaves your sight intact and takes away every landmark of light you were navigating by. Lightning in a storm briefly lights the whole street, which shows you the map and shows you to anything looking.
  - Every vision query was moved onto two helpers so sight moves as one thing; the previous arrangement had five separate reads of `CFG.viewFar` and any of them could have quietly ignored the weather.
  - Announced in the opening line of the raid instead of the controls reminder, which was identical every single time, and named on the sector map since it changes how far you can see.
  - **Verified:** 400 rolls give 34/22/21/12/11 percent against an intended 34/22/18/13/13, so the weighting works and clear stays commonest. Storm is the heaviest frame, with rain, lightning and dimmed lamps at once: 3.1ms of a 16.7ms budget, 95th percentile render 2.0ms. Rain is a fixed 170 screen space strokes regardless of zoom or map size. Sim unaffected, 6/6 with contact in all six and no hangs.
- **v0.95 (the extraction siege, against his playtest tag "Extract too easy"):** Extraction was the one moment in the raid with no risk in it. He pressed a key, stood in a circle for 25 quiet seconds with a full bag, and left. That is the exact opposite of what the ending of a greed run should feel like, and it was quietly undercutting the whole risk versus greed pillar: if getting out is free, then filling the bag costs nothing.
  - **Calling the dropship is now the loudest thing you can do.** The beacon fires a 700 unit ping and hard alerts every enemy within 1500 units, sending each one to a scattered point on the ring. It is not a trickle: measured on a passive player, interest went from 0 enemies before the call to between 3 and 13 after it, with a peak of 4 to 10 bodies inside 420 units of the ring.
  - **It keeps pulling.** A 900 unit re-ping every 2 seconds during the wait drags back anything that loses the scent, so the back half of the countdown is not a lull. Raiders already leaving with 5 or more items are skipped, because a rival hauling a full bag has somewhere better to be and chasing your beacon would read as scripted rather than greedy.
  - **The HUD says the number out loud.** Under the countdown bar: "N converging on the ring", amber, red above four. The opening line changed to "Every one of them heard that. Hold the ring." You are told the cost before the timer starts.
  - **This is where v0.90 dropship haul finally pays.** Going down inside the ring is no longer the end of the run, so the siege is survivable in a way that makes holding worth attempting rather than simply lethal.
  - **Verified against the risk it was meant to add, not against my intent.** Passive player: 3 of 5 died. The bot, which fights back, across three separate batches: 5/6, 5/6, 5/6 extracted, one death each, and the killers were spread across crawler, raider and sentry rather than one dominant threat. Before this change deaths at extraction were effectively zero. Frame cost 2.7ms of a 16.7ms budget with 36 enemies converging in a storm.
- **v0.96 (themed districts, and the actual reason maps felt samey):** His top complaint was that maps feel samey, and I had been treating that as a content shortage. It was not. Measuring the generator: every building rolled `ri(0,3)` for its district independently, so a building's nearest neighbour shared its district 26 percent of the time against 25 percent for pure chance, and every single map came out a 25/25/25/25 mix of all four palettes. There were no districts. There was district coloured noise. Four distinct palettes sprayed evenly over everything average to the same confetti, so no map could look like anywhere in particular. **The variety was cancelling itself out.**
  - **Zones instead of noise.** Each raid places 2 or 3 zone seeds, each claiming a different district, and every grid cell takes the district of its nearest seed with a small border jitter so the seams are organic rather than clean Voronoi edges. Landmarks and scatter props ask the same `districtAt` question instead of rolling their own, so a crate in the greenbelt is a greenbelt crate.
  - **Measured before and after:** nearest neighbour district match 26 percent to **88 percent**. District kinds per map 4.0 to **2.38**. Dominant district share 31 percent to **56 percent**. Sixteen maps produced **8 distinct zone combinations**, so raids now differ from each other and not just from nothing.
  - **Named, because a colour you cannot name is not a place.** Crossing a border says "Crossing into the greenbelt", on a 6 second cooldown since a cell border is a line you can stand on and wiggle across: measured 899 raw flips in 15 seconds of frame perfect wiggling, capped to exactly 3 callouts. A normal full diagonal walk crosses 1.5 borders on average, so the callout stays an event. The sector map labels each zone at the centroid of the cells it actually won, not at its seed, which was pushing names to the map edge whenever a seed landed in a corner.
  - **Verified the generator still holds:** 20 maps, every zone wins cells, all centroids inside the grid, cell counts sum exactly to the grid, smallest zone still 17 percent so nothing degenerates into a token sliver. 10 maps: all 30 landmarks reachable, zero landmark/building overlaps, 80 of 80 cross map paths found, 271 containers per map. Sim 5/6 and 6/6 with contact in 12 of 12 and no hangs. Frame 2.9ms of a 16.7ms budget.
  - Also checked our build against the two portable complaints from the Zero Sievert research: enemies spawning inside walls (504 enemies over 14 maps, zero inside a collider at spawn or after 2 seconds) and a fullscreen inventory that hides the world (ours is a 270px side panel and the raid keeps running behind it). Neither applies here.
- **v0.97 (interiors, plus three things from his live playtest):** Landmarks, districts and weather all changed the map between buildings. This changes the buildings. Every one of them used to be the same object: a box, plus one central divider if it was wide enough, repeated a hundred times a map. That is the last piece of "maps feel samey" and the reason going inside was never worth doing.
  - **Six floor plans, chosen for what each does to sight lines**, since that is what an interior means in a game where being seen is the danger. OPEN warehouse floor. SPINE, a corridor you must commit to with rooms off both sides, long sight line down it and none across. CORE, a sealed strongroom with exactly one way in, the most valuable shape in the game because entering it is a choice you can be caught making. PINWHEEL, four spokes from the middle that stop short of the walls, killing every diagonal while staying fully walkable. CELLS, alcoves open on one side, each a place something can be standing. LSPLIT, two rooms in an L with staggered openings. Small footprints only draw the plans that leave room to walk.
  - **A sealed room is invisible in play and indistinguishable from solid wall**, so it would have shipped as "some buildings just have less inside them". I reasoned all six through by hand and measured anyway: **lsplit sealed a room in 9.8% of the buildings that used it, cells in 1.7%, spine in 1.6%**, because a partition doorway can be plugged by another partition meeting it end on. Rather than special case each plan and re-derive the argument every time a new one is added, `repairInteriors` floods the finished nav grid once, strips the interior partitions of any building that failed, and falls back to an open floor. Interior partitions are tagged with their building id so it removes exactly one building's insides and nothing else. **After: 0 sealed cells across 12 maps and 167,059 walkable interior cells, 22 buildings of 723 repaired.**
  - The repair had to run **before** the sight segment list is built, not at the return. `segs` is a snapshot of the walls, so repairing after it is built leaves sight blocked by geometry that is no longer there. Verified: segment count equals walls times four on every map.
  - **Wheel zoom, from his playtest "zooming with mouse wheel doesnt feel fluid".** Three separate faults wearing one coat. It snapped, with no motion between steps. The step was additive, so +0.12 was an 18% change at 0.65 and 6% at 2.0 and the same flick felt violent zoomed out and stuck zoomed in. And it wrote the whole profile to localStorage on **every single wheel event**, stringifying and hitting disk on the main thread many times a second, which stalled the actual frames while you zoomed. That last one is the jank he could feel. Now: eased target, geometric step, debounced save, and delta modes normalised so a trackpad and a wheel agree. Measured settle 0.267s at 60fps, 0.267s at 30fps, 0.271s at 144fps, so it is frame rate independent.
  - **Dodge roll, from his playtest "it rolls too far, and it should take a lot of stamina".** Both at once because they are the same point: the roll was a travel move that happened to grant invulnerability, so it beat sprinting outright and there was no reason not to spam it. Now 122 units instead of 167, only just ahead of a 256 sprint, so distance is no longer why you press it. Cost 25 to 45 stamina: two from full instead of four, 3 seconds of regen to earn one back, and it competes with sprinting for the same pool. The 0.30s invulnerability window is untouched, since that is the part he did not complain about and the part that makes it a defensive tool.
  - **"I still don't understand why there are gold circles everywhere, are they supposed to be lights?"** Yes, and the question is the bug report. The light pass painted a pool of the lamp's own colour on the ground and **nothing ever drew the lamp**. A light with no visible source does not read as light, it reads as an abstract marker. Lamps now draw as hung fixtures with a bracket, housing and lit element, y-sorted with everything else, and a dead lamp still hangs there during a blackout. Hung rather than floor standing because these sit on spots the player walks through, and a floor lamp you can walk straight through is a worse lie than no lamp.
  - **Verified:** 80 of 80 cross map paths, 24 of 24 landmarks reachable, 269 containers per map, sim 78% extract over 18 raids with no hangs. Frame 4.0ms of a 16.7ms budget median across 5 maps in a storm, up from 2.9ms, which is the added interior walls and is proportionate.
- **v0.98 (Xbox controller support, at his request):** Full pad support in the raid and the hub, alongside mouse and keyboard rather than instead of them.
  - **The decision that made the rest simple: the right stick drives a VIRTUAL CURSOR, not the aim angle.** Facing, throw targeting, the camera lean and the crosshair are all derived from the cursor already, so moving the cursor makes every one of them work untouched. Setting the angle directly would have fixed aiming and silently left throws and the camera pointing at wherever the mouse happened to be.
  - Every in-raid action was lifted out of the keydown listener into `raidKey(code,repeat,ev)`, so the pad raises real actions instead of faking DOM events.
  - **Mapping:** left stick move (analog, with a rescaled radial deadzone so the first millimetre past it is a small input and not a jump), right stick aim, RT fire, LT steady aim, A search and call beacon, B roll, X reload, Y swap, LB cycle throwable, RB throw, LS click sprint, RS click crouch, dpad up map, dpad down medical, dpad left drop, dpad right autoloot, View inventory, Menu pause. With the bag open the dpad browses it instead.
  - **Two bugs the tests caught that reading the code did not.** First, the game consumes actions two different ways: some are raised on the keydown edge, others are POLLED from key state every frame. Mapping search and reload as taps set the key and cleared it inside the same frame, so the poll never saw it: **reload silently did nothing and looting would have been impossible**, since searching a container and calling the dropship are both hold to act. Held and tapped are now separate tables. Second, the pad wrote `mouse.down` and the held keys unconditionally, so **merely having a controller plugged in overwrote them to false every frame and broke mouse firing and keyboard sprint** whether or not the pad was being touched. The pad now only clears what the pad itself set.
  - The control legend, the gear rules and the inventory hints all switch to pad names when a pad is connected, because a controller player reading key names has to translate every line, and half translated is worse than either.
  - **Verified with a synthetic pad driving the real `pollPad`, since there is no controller on this machine.** Movement full stick 77 units against half stick 27, a ratio of 0.36 which is exactly what a 0.22 rescaled deadzone predicts. Zero drift at rest. Aim correct in all four quadrants. Trigger at 0.2 does not fire, at 0.9 does. Every mapped button confirmed to perform its action: roll spends 45 stamina, reload starts, swap changes weapon, throwable cycles through all three, throw consumes one, bag browses and drops, medical heals 40 to 68, map and sprint and crouch hold and release. Mouse fire, mouse aim, RMB steady aim and keyboard sprint all confirmed to survive an idle connected pad. Polling costs below timer resolution; frame 3.2ms of a 16.7ms budget.
  - **What this cannot verify:** real hardware. Stick drift on a worn pad, whether the aim radius feels right in the hand, whether 0.22 is the correct deadzone for his controller, and whether the button layout is comfortable are all his call at the pad.
- **v0.99 (hotfix: v0.98 did not boot, and it was my mistake):** He reported a blank screen. `drawHubWorld` threw `Cannot read properties of null (reading 'lights')` on its very first frame, so nothing ever rendered.
  - **Cause.** The v0.97 lamp fixture code was inserted with a PowerShell `.Replace()`, which replaces **every** occurrence, and the anchor I chose (`DR.push({k:p.y,pl:1});` followed by the `DR.sort`) exists **twice**: once in `render2D` and once in `drawHubWorld`, which duplicates the raid renderer verbatim. The file's own comment warns that the hub duplicates that renderer. So the raid lamp loop, which reads `G.lights`, was injected into the hub, where `G` is null.
  - **Why my check missed it, which is the more important failure.** I verified the build by reading `verlabel`, which is set on the line BEFORE the async boot chain, and by checking the console for errors. The version label therefore said v0.98 on a completely dead build, and the exception happened inside a requestAnimationFrame callback that the hidden browser pane never ran, so no console error appeared either. **A boot check that does not draw a frame is not a boot check.** From now on: drive at least one hub frame and one raid frame through the fixture before shipping, and assert no throw.
  - Two other sites received the same accidental replacement, both in the movement block: `tryRoll` and `updateHubWorld`. Both were checked and both are correct and desirable rather than bugs, so they stay: the roll now takes its direction from the stick, and hub movement is analog.
  - **Verified:** hub draws 10 frames with no error and a fully painted canvas, raid draws 20 frames with 201 lights and no error, sector map overlay and the inventory panel with the pad legend both draw clean, and the real file boots to v0.99 with an empty error log under an injected error and unhandled-rejection trap.
- **v1.00 (Toybox Noon: his answers became the build):** The research workflow returned a named art direction, "Toybox Noon", with exact values, and his 50-question answers set the priorities. This build ships the foundation layer of both.
  - **Always daytime, and daytime you can actually see.** Day is the default and every save migrates to it. The day fog was 72 to 93 percent opaque, which is why daylight still felt like night; it is now 30 to 54 percent. Stealth is untouched because enemies are gated on `e.seen`, not on fog darkness. Measured: mean screen lightness 36 percent with 0 percent of the screen in the black decile, against a near-black baseline.
  - **The palette was the "samey" root cause.** Old floors sat at 12 to 18 percent lightness, where hue does no work, so four districts read as one dark smear. New floors sit at 43 to 47 percent with the research's four non-overlapping value bands: floor, wall face, wall top, actors. dcol() now darkens FROM the daylight palette at night instead of lightening toward it.
  - **ARC caches: the loot promise made structural.** "I SHOULD FIND TOP TIER LOOT EVERY RUN EVEN IF I MOVE STRAIGHT TO THE EXTRACT." Three caches are placed every raid: one near the extraction, two out at landmarks. Cache loot table contains no junk at all, only rare and elite. Five new elite items and two new rares, because the old top tier was ONE item at weight 2 in safes only, and a tier with a single member cannot feel like a jackpot. Caches are the biggest brightest container in the game, labelled in world, and marked on the sector map from the first second, looted state shown.
  - **All text bigger, and a setting.** He asked for both a flat lift and a user control. Every canvas font passes through FS(): a 1.55x flat lift, an 18px floor (the research calls every 8 to 11px string a bug, and they were most of the file), and a uiScale multiplier stored on the profile. Panel metrics scale with LH() so the legend and inventory grew with their text instead of overlapping.
  - **Backpack unlimited**, per his direct request. Carry weight was friction with nothing on the other side once junk is gone.
  - **The v0.98 audit workflow's confirmed bugs, fixed:** the hub pad branch overwrote keyboard WASD and E unconditionally, so a merely-connected controller made hub stations unusable from the keyboard (same class as the raid bug, found by 28-agent adversarial audit); nothing released pad-owned input on disconnect, so a pad dying mid-firefight left the gun firing until the reserve emptied, sprint latched forever (padRelease() now runs on every pollPad exit and the disconnect event).
  - **Verified:** hub frame and raid frame both draw with no throw (the v0.99 lesson, now mandatory), 3 caches on every test map, day cond confirmed on migrated profile, sim 5/6 extract with sentry the killer, servers restarted after both went down (which is what his "its not booting" link failure was this time).
- **v1.01 (the enemy answers, the Warden, and the font is the art now):** His AI answer set implemented, plus live fixes from the session.
  - **THE WARDEN.** One per raid. His spec verbatim: "YES BUT IT SHOULD MOVE SLOWLY SO YOU CAN CHOOSE NOT TO ENGAGE." Speed 36 against his 158 walk, measured escapable in a direct probe. 620 hp, heavy cannon, never gives up once it has seen you, announces itself, red slit eye when hunting, audible tread. Killing it is the only source of the Warden Core (3800, the most valuable item in the game) plus a cache-grade drop: caches are the free jackpot, the Warden is the elected fight.
  - **Raiders flank, flee, and fight machines.** Each raider commits to a side at first contact and approaches an offset point rather than your centre; sides alternate deterministically because two raiders rolling the same side re-formed the queue (measured 7 degrees of separation, now opposite sides at 34 and widening). Cover and peek approximated as sidestep-while-cycling, plant to fire. Under 30 percent hp they break for the dropship with what they have. While looting they engage machines within 280 at close range, gated to within 600 of the player where the LOS cache is valid.
  - **Snitch marks now summon.** Machines within 900 get your marked position and come looking. Raiders ignore the call.
  - **Fonts embedded and chosen as art direction**, from his "text still looks like shit, font needs to be considered in art style": Titan One (display) and Rubik variable (body) as base64 data URIs, so the game is style-complete offline. All Oxanium and Roboto Mono references replaced. File grew 63KB.
  - **Text scale bug he caught: "key is too big, text is on top of each other."** Root cause was mine: a 1.55 flat lift multiplied by a 1.35 default user scale gave 2.09x text on unscaled layouts. Now one TEXTLIFT constant (1.3) shared by fonts and layout steps, floor 13px, user scale defaults 1.0. Nameplate boxes follow their measured font. HUD right-column rows scale with LH(). Legend heading column widened after Titan One glyphs outgrew it. Bag header no longer prints the fake 99999 cap.
  - **"The text file is back. why?"** The telemetry collector had died with the other servers, so the recorder fell back to browser downloads. Restarted, POST verified 200, probe file cleaned. Downloads stop.
  - **Verified:** hub and raid frames draw clean (mandatory gate), fonts decode and check true in the shipped build, profile intact, no console errors. Behaviour probes: warden max speed exactly 36, raider flees at 20 percent hp, snitch summons 3 of 3 staged machines, flanks split sides. Sim: 4/6 extract, killers warden and sentry, no hangs. The warden pulls the 70 percent rate toward the healthy band; one batch is noise, watching across ticks.
- **v1.02 (encampments, the in-game roadmap, and every prior build playable):**
  - **ENCAMPMENTS.** His spec: "encampments with a bunch of high tier loot and surrounded by enemies", distinct from caches. Two per raid: four safes in a tight cluster, guarded by four machines whose patrol is tethered to the post (measured max drift 209 against a 240 leash over 30 sim seconds), placed at least 900 from your drop and 500 from the extraction. Marked in red on the sector map with the name said out loud, because advertised danger is a choice and ambush danger is a mugging. Caches stay the free jackpot; encampments are the paid one.
  - **Roadmap in the terminal**, at his request, in his words "IN THE GAME": a NOW / NEXT / LATER list I edit every build, so what is coming is visible while he plays.
  - **Play an older build.** All 93 shipped versions extracted from history into `builds/` with an index, served next to the game, listed newest first in a picker in the terminal. Opens in a new tab so the current game is not disturbed. Accepted risk, stated: old builds share the save, and an old build writing settings can pin old tuning values until the modern build's migration re-drops them; credits, stash and the recorder are safe throughout. The archive is not committed to git, it is generated from git.
  - **Sim across two batches: 6/12 extract, 50 percent, killers sentry 4, crawler 2, no hangs.** First time inside the 35 to 60 healthy band since the v0.90 rework. The bot blunders into camps it cannot evaluate; a human sees the red diamonds and chooses, so live rate should sit a little higher.
  - Verified: hub and raid frames clean, map overlay clean, 2 camps with 4 safes and 4 tethered guards each on every probe map, roadmap renders 7 rows, picker lists 93 builds, no console errors, profile intact.
- **v1.03 (his first v1.01 recorder data: one batch of tuning, and armour against the bug he hit):** Three real runs. Tags: Extract too easy x2, Too easy x2, Loot boring, AI too dumb, Ran out of ammo. Notes: "looting feels so uninspired", "character not rendering" (run #3, abandoned), "every block is the same length, map has no atmosphere, needs verticality, hills, woods, town centers, big buildings".
  - **Tuning batch, one line each:**
    - eDmg 1 to 1.2: three runs, zero damage taken, zero downs, zero heals.
    - nSentry 13 to 15, nCrawler 15 to 17: firstContact was 183s in one run and never in another; the machines simply never met him.
    - Beacon siege radius 1500 to 2200 and re-ping 900 to 1200: Extract too easy twice more, so the call now reaches most of the map.
    - cfgv 4 to 5: his save pins tuning values, so without the migration none of the above would reach him. Sliders reset to the new defaults; credits, stash, armoury and recorder untouched.
  - **"Character not rendering" could not be reproduced** (warden draws both facings, player probe visible), which is the signature of a state dependent throw inside the y-sorted draw: one bad entity kills everything after it in the list, player included. The loop is now armoured: a throwing entity loses that entity for that frame instead of the player, the first failure is named on screen and recorded per run, and the recorder line carries DRAWERR so his next export tells me exactly what broke. Verified with a poisoned entity: frame survives, error logged as "crawler: poison-probe", player still visibly painted.
  - His map atmosphere note is the next major feature (big multi-cell buildings, woods, a town center); the roadmap NOW slot points at it.
  - **Sim with new tuning: 5/12 extract, 42 percent, killers sentry 5, crawler 2, no hangs.** In band, and he demonstrably outplays the bot.
- **v1.04 (map atmosphere, from his in-run note):** "every block is the same length, map has no atmosphere, needs verticality, hills, woods, town centers, big buildings." Everything in that list that fits a flat 2.5D sim is in this build; real verticality and hills are not, said plainly, because elevation would break the layer split between the flat simulation and the renderer.
  - **TOWN SQUARE, guaranteed on every map**: a stepped monument you can circle but not cross, six market stalls busy at the rim and open in the middle, two benches, heavy bulk loot. A town has a centre or it reads as a warehouse district; the other landmarks still rotate around it.
  - **WOODS, 2 to 3 groves per raid**: cells that carry 14 to 20 trees instead of a building. Trunk colliders block movement and sight exactly where the trunk stands; layered swaying canopies above; baked turf with organic blotches. Thin broken sight lines, which nothing else on the map produces.
  - **TWO-BLOCK BUILDINGS, 2 per raid**: single structures claiming a pair of adjacent cells, with the interior floor plans scaling up inside them.
  - **Roads segmented**: drawn per cell edge and suppressed through groves and under a big building's spine, so some blocks are twice the length of others and some streets end at a treeline. That is the direct answer to "every block is the same length".
  - Scatter slabs skip groves; probe found 0 concrete blocks inside woods after the fix.
  - **Verified across 8 maps**: town square on 8 of 8, 22 groves, 364 trees, 16 big buildings, 64 of 64 cross map paths, 0 sealed interior cells including the big buildings, hub and raid frames clean, no console errors. **Sim 3/6 this batch, killers crawler 2 sentry 1, no hangs**, consistent with the 42 percent band from v1.03.
- **v1.05 (runs #4 and #5: the extraction flow he actually asked for):** Two more real runs, both deaths at the ring. Tags and notes: "Extract too tense", "once i call the beacon and it arrivs i should have 30 seconds t get back into the circle", "player should be able to use the beacon and extract while downed", and at 190s "not enough enemies, boring".
  - **The ship holds 30 seconds after landing.** It used to leave the instant it touched down unless you were already standing in the ring, which turned a two second detour into a full re-call under siege and killed him twice in one raid (3 calls, 2 missed). Stepping into the ring at any moment of the hold extracts immediately; the siege re-ping keeps running through the hold, so it is a window, not a mercy. HUD switches to SHIP HOLDING with a red draining bar.
  - **A downed operator can call the ship.** The downed branch passed no call flag, so E while bleeding out did nothing: you could ride a beacon already inbound but never start one. Now the call passes through, and the existing crew-drag covers the landing. Bleeding out inside the ring is a decision point instead of a death sentence.
  - **Machines trickle back in.** One reinforcement every 40 to 70 seconds after the three minute mark, only while the machine count is below the raid's starting strength, landing at least 800 from the player. The back half of the clock now has as much in it as the front.
  - **Probed end to end**: call, land with the player outside, hold starts at 29s and counts, walking in mid hold extracts; letting it expire records exactly one miss and a recall works; a downed call inside the ring ends with the crew hauling him aboard; a raid culled by 10 machines replenishes to 32 within 150s. Hub and raid frames clean, no console errors.
  - **Sim: 6/12 across two batches, 50 percent, killers sentry 5 crawler 1, zero beacon misses for the bot now, no hangs.** In band.
  - His runs were on v1.01, so he has not yet felt the v1.03 tuning (eDmg 1.2, more patrols) or v1.04 maps; the "not enough enemies" complaint is half answered by those already, and the trickle finishes it.
- **v1.06 (run #6, on the new tuning, and he still cruised):** 75 percent accuracy, 13 kills, one calm beacon call, tags "Extract too easy" for the third time and "not enough enemies on map". One batch:
  - nSentry 17, nCrawler 20, nRaider 6: third consecutive "not enough enemies", now with the v1.03 counts demonstrably insufficient.
  - The beacon summons ARRIVALS, not just attention: one machine drops at the map edge every 8 seconds while the beacon runs or the ship holds, capped at six per call, aimed at the ring. The pull alone is not pressure for a player who shoots 75 percent, and this is what makes the 30 second hold a decision rather than a wider door.
  - Trickle reinforcements start at 120s and land every 30 to 50 seconds.
  - cfgv 6, so his pinned save receives all of it.
  - **Stated plainly: the bot is now below the band, 3/12 extract, 25 percent, sentries the killer.** That is deliberate. The band was calibrated when he found the game too easy, and he outplays the bot by a wide margin (his last run would have been a bot death several times over). If his next runs tag "Too hard", the counts come back down; feel is his call.
  - Probes: 6 siege arrivals per call confirmed, config reaches the profile as cfgv 6, hub and raid frames clean, no console errors.
- **v1.07 (faces):** The character redesign from his answers: visible faces, further toward big headed Toriyama.
  - **The operator and every raider have a face now**: whites, pupils, a specular glint, a small mouth that pulls into a grimace when hurt. The pupils track the aim direction, so the figure looks where you look, which makes it feel inhabited at zero animation cost. Head grew from 12x10 to 15x13, about 38 percent of the figure, and the anonymous visor strip is gone. Raiders share the same construction, so the rival crews are people too.
  - **Crawlers got an eye cluster**: three unblinking points on the head that all face you, dim amber on patrol, pulsing red on the rush. Scary is specificity, not a colour swap.
  - Nameplates lifted to clear the taller heads.
  - Verified: hub and raid frames clean, staged lineup screenshot confirms both faces read at zoom and the pupils track, no console errors. Sim 1/4 quick batch, killers sentry and raider, consistent with the deliberately hard v1.06 band. What a face FEELS like at his zoom level in motion is his call at the screen.
- **v1.08 (guns are the loot now):** His answer on finding a better gun versus valuables: "not even close". Two systems:
  - **Condition rolls on every field gun.** Worn 33 / Field 42 / Tuned 18 / Pristine 7 percent, measured 32/43/18/7 over 3000 rolls. Pristine is +24 percent damage, 30 percent tighter spread, +25 percent magazine, and the roll happens at pickup so every gun on the ground is a slot machine. A same-tier find in better condition auto-equips with a damage comparison said out loud. Banking stores the bare model, deliberately: a Pristine roll is a reason to fight with it THIS raid, which is the greed half of risk versus greed.
  - **Three new families with genuinely different fire patterns**: Burst Carbine (three rounds per trigger pull, echoed at 70ms so the burst finishes even if you release), Riot Scattergun (six pellets, tighter than the starter Hullcracker), Support MG (60 round box, brutal 3.4s reload). Seeded through lockers, safes and caches.
  - Burst echoes ride the throwables list with three guards so grenade code and the throw renderer skip them; verified 1 immediate round, 2 echoes queued, 3 bullets total, zero leftovers.
  - Verified: base weapon table unmutated after rolls, distribution correct, hub and raid frames clean, no console errors. Sim 2/5, killers warden and sentries, in line with the hard band.
- **v1.09 (hub shrunk):** His answers: "WAY TOO BIG", stations "right next to each other". The Undercroft went from 1180x760 to 700x470. All five stations sit in a ring around the spawn, the farthest 252 units away, about two seconds of walking, and everything is on one screen at once. Interior piers, counters and lights retightened to the new footprint.
  - Verified: every station acquires interaction from adjacent standing position (5 of 5), no station clips a wall, hub and raid frames clean, screenshot confirms the one-screen read, no console errors. Sim 1/4 quick check, no hangs, raid untouched by the change.
- **v1.10 (the ground remembers):** His yes to footprints, casings and litter that persists.
  - **Casings persist for the whole raid.** Brass used to vanish 3 seconds after it landed; settled shells now stop simulating entirely and stay, capped at 300, so a firefight is legible on the floor when you walk back through it. Settled shells cost nothing per frame.
  - **Footprints.** A boot mark every 0.34s of walking (0.22 sprinting), alternating sides, oriented along travel. Wet boots after water leave a dark trail for 6 seconds, which makes crossing water a tracking decision as well as a noise one. Faint scuffs otherwise.
  - **Search litter.** Two or three bits of discarded packing hit the ground beside every container you rifle, and they stay: a looted district looks looted, which is information as well as texture.
  - Decal pool unified at 420 with boot, junk and blood drawn as distinct shapes.
  - Verified: 8 prints in 3 seconds of walking (matches the interval), 12 casings persisted, 2 junk pieces per search, container opens normally, hub and raid frames clean, ~6.4ms average frame with 300 settled shells on the ground, no console errors. The shell settle flag runs in the rAF effects block the fixture cannot drive, so settling itself is verified by construction rather than probe; the pane suspends rAF and his browser does not.
- **v1.11 (sound pass two, built deaf as approved):** Three layers on top of the v0.92 foundation.
  - **Weapon voices.** One generator, one table: every family has its own length, brightness, decay and weight, so a distant fight tells you WHAT is firing before you see it. Pistols crack bright and short, SMGs chatter, the DMR and both shotguns carry a sub-thump layer, the LMG thuds flat. Machines keep the old rifle crack as their default voice. Raider and machine fire arrives panned and distance-faded as before, now with identity.
  - **Weather in the bed.** A bandpassed noise voice above the room-tone lowpass whose gain follows the rain amount, so rain sounds like rain rather than more rumble, and a storm is louder than a drizzle. Fades over about a second when weather is meaningless (dead, extracted).
  - **The dread layer.** A 36Hz sine that rises as the Warden closes, audible from about 700 out, well before its tread. Horror is a frequency you feel before you place it. Driven from the same loop that computes threat.
  - Verified structurally, since I cannot hear: all 11 weapon voices and the default build without throwing on a running AudioContext, the weather and dread nodes exist in the bed, frames clean, no console errors, sim 3/4 with no hangs. Whether it sounds GOOD is his verdict at the speakers, and I have said so every time sound ships.
- **v1.12 (the two HUD answers still outstanding):**
  - **Meters at combat size.** His answers, verbatim: "HUD BIGGER" and the health bar "NEEDS TO BE LARGER". Health went 150x10 to 280x18 with the number inside the bar where the eye already is; armour 280x11 above it, stamina 280x8 below.
  - **Dropped items say their name.** His #23. A single item crate you dropped yourself shows its item name in rarity colour when you stand near it, so re-collecting is not a memory test. Unsearched world containers stay mystery boxes on purpose: his own answer was that you must search to find.
  - Verified: drop flagged and named at the crate, meters render at the new sizes in a staged shot (HP 62 readable inside the bar), hub and raid frames clean, no console errors, profile intact.
- **v1.13 (time of day):** His answer: "MAKE IT VARY BASED ON TIME OF DAY". Five times rolled once per raid like weather: DAWN (violet pink, lamps still fighting the light), MORNING (cool green), NOON, GOLDEN HOUR (strong amber, everything glows), DUSK (muted violet, lamps fully on). Every one is DAYLIGHT: measured mean lightness runs 33 to 41 percent across all five, so the variance is colour temperature and lamp behaviour, never visibility, because the last thing he asked of darkness was to remove it.
  - The first cut measured near invisible (dawn and golden differed by 6 RGB points, drowned by per map palette variance), so the casts were tripled and re-measured: golden now reads strongly warm at 128/100/76 against morning's cool 100/104/75.
  - Lamps scale with the hour in all three light passes, dusk announces itself when the weather is clear, and the sector map shows the hour beside the weather.
  - Verified: all five times roll and render, lightness bounded, hub and raid frames clean, sector map clean, sim 3/4 with no hangs, no console errors.
- **v1.14 (the text size setting existed but had no door):** He answered BOTH to "flat lift or a setting", and the setting shipped at v1.00 as a profile field with a five-step table and NO way to change it. Found while auditing my own recent work. A "Text size" button in the terminal now cycles 100 to 200 percent, saved to the profile, applied live: every canvas string follows on the next frame because the font cache is keyed by scale. Verified: cycles correctly, raid and inventory render clean at 150 percent, resets, no console errors. A wider adversarial audit of v1.00 to v1.13 is running and lands next build.
- **v1.15 (the audit landed: 2 breaking, 7 major, 8 minor confirmed by 22 agents; the worst are fixed):**
  - **BREAKING, gun provenance.** Holding the issued sidearm while finding a better gun minted a sellable phantom pistol AND silently deleted the armoury pistol; and abandoning after any gun pickup permanently deleted the swapped-out armoury gun because the splice was never restored. Fixed with provenance flags on both weapon slots (armoury versus field versus issued, carried through the X swap) plus a G.spliced ledger the abandon branch restores from. A field-found gun being swapped out no longer deletes the armoury twin that never left base (the third confirmed gun bug, same fix).
  - **MAJOR, the sim was poisoned.** The bot called the beacon whenever it STRAYED into the ring mid-loot, summoning sieges it then walked away from. Every balance number since v0.95 carried that noise. The bot now calls only when its extract branch decides to leave: verified 6 raids, 5 deliberate calls, zero missed beacons, against routine accidental misses before.
  - **MAJOR, burst ammo.** Carbine echoes fired free rounds; a burst now consumes a round per echo and stops dry mid burst. Verified: 2 rounds in the magazine yields exactly 2 fired.
  - **MAJOR, the clinic sealed its own rooms in 59 percent of raids**: the horizontal divider landed inside the vertical divider's only gap, exactly the lsplit plug from v0.97 in hand-authored form. Restaggered so they cannot intersect: 0 sealed of 5 clinic maps after, and degenerate wall segments are dropped at emit.
  - **MAJOR, UI at scale**: the legend clamped straight over the enlarged meters, and inventory rows printed on top of each other at 150 percent text because the list pitch was still hard 16px. Both scale now.
  - **MAJOR, autoloot churn**: a full bag shed its worst item into its own pickup range and re-ate it forever. Auto-shed crates are ignored by the chooser for 8 seconds; your own discards also no longer advance contracts or reroll gun quality (two farm exploits closed).
  - **Minors**: the hold no longer promises 30 seconds the raid clock does not have (says the real number, bar scales), camp safes are collision-tested instead of embedded in walls (0 of 806 after), and the last two raw-px strings joined the text scaling.
  - Deferred, stated: the sim bot freezing beacons while downed (sim nuance), and the Voronoi jitter no-op (cosmetic seams). Both logged, neither player-facing.
  - Servers died again mid-tick and serve.ps1 had been replaced on disk with a hardcoded port 8791 copy, likely Daniel's; all four servers restored including his 8791, from a new serve2.ps1 so his file stays as he made it.
- **v1.16 (the gut punch):** His pillar answer, previously unbuilt: "losing a raid should be A REAL GUT PUNCH". Death was an instant cut to a stats div.
  - **The death beat.** A second and a half of quarter-speed world with a closing red field and YOU DIED, before any screen. You watch the thing that killed you keep moving. The sim skips it entirely, so balance numbers are untouched.
  - **The ledger.** The outcome screen lists what you were carrying item by item, in rarity colour, each marked GONE with its value, most valuable first, then the count and the safe pocket. Reading the list one line at a time is the punch; a count never was.
  - **The killer has a name.** Damage carries the shooter's identity, so the screen says KILLED BY SENTRY K-41, 2938M FROM EXTRACTION rather than "killed by sentry". Timer deaths stay anonymous, correctly.
  - Verified: beat starts on death and defers the end, ledger itemizes with the safe pocket correctly taking the two most valuable items first, killer line renders with name and distance, beat frame draws clean, sim 3/5 with no hangs and no beat interference, no console errors. Whether the beat FEELS right at the screen is his call, as all feel is.
- **v1.17 (the recorder learns the new systems):** Every feature since v1.00 was invisible to the flight recorder, which means his next feedback cycle would have carried zero signal on caches, encampments, the Warden, gun quality, the hold, weather or time of day. Data before changes is the first rule of this project, and I was about to be blind on everything new.
  - Each run now records and exports: weather and hour (`wx:fog/morning`), caches opened, encampment safes cracked, whether the Warden was met, guns equipped and the best condition found (PRISTINE called out), whether the extraction used the 30 second hold, and whether death came during a called beacon.
  - **Telemetry protocol section applies**: these ride the existing per-run line, omitted when zero, so old lines stay parseable.
  - Verified end to end with a staged run: cache plus camp safe plus hold extraction produced `wx:fog/morning caches:1 campSafes:1 gunsEq:1 viaHold:1` in the actual export text. The Warden tap lives inside the rAF loop the fixture cannot drive; it shares the dread computation that is already exercised live, stated plainly. Frames clean, sim 4/5, no hangs, no console errors.
- **v1.18 (telegraphed fire):** Sentries and the Warden used to hit with zero warning, which reads as unfair rather than frightening; horror needs the half second where you KNOW it is coming. Both now charge visibly and audibly before every shot: a red gathering glow at the lens or muzzle plus a rising whine, 0.4s on sentries, 0.7s on the Warden.
  - **The charge time is subtracted from the old cooldowns, so DPS is unchanged**: this adds legibility, not mercy. Measured: sentry cycle 0.60s against the old ~0.55 average (within roll noise), Warden cycle exactly the old 2.4s. First shots land after the full charge, so the glow is always a real warning you can act on: break the sightline during the charge and the shot never comes.
  - Verified with isolated clear-LOS duels for both units (an earlier zero-shot probe was my own staging putting a wall between them, stated for the record), glow frame draws clean, sim 4/5 with no hangs, no console errors. Also consumed one export from the queue that was my own v1.17 verification artefact (0s duration, 0 movement), not his play.
- **v1.19 to v1.20 (the spec arrives, and its first fixes):** Daniel delivered `DARK_RAIDERS_SPEC.md`, a full design specification that supersedes this document and every prior instruction. It is now the governing document; this file is history and measurement record. It carries an autonomy mandate: do not block, do not keep an open-questions list, decide and move.
  - **Spec defect 1, done: the shadowy circles are gone.** 520 dark ellipses per map were standing in for hills; they were never verticality and only muddied the floor. Deleted, replaced with a quarter as many honest small grime marks. Real elevation (multi level interiors, ramps, readable platform edges) is the replacement and is queued.
  - **Spec 6.5: the safe pocket is ONE item**, down from two.
  - **Spec 8.1 and 8.2: crawlers take 3 hits instead of 2, sentries 7 instead of 4** with a plain Auto Rifle. Config version 7 so his save receives it.
  - **Spec 5.1: the clock now warns** at five minutes, every minute after, and at thirty seconds, each with an alarm, because timer expiry is death and full loss.
  - **Spec defect 3 verified, not broken:** the dodge roll stamina cost is applying, measured 45 of 100 per roll.
  - **v1.19 furniture, and its correction.** Interior furniture (tables and shelving as real cover) shipped alongside, but measured 26 sealed sliver cells across 10 maps: the repair pass tolerated pockets of 3 cells or fewer, and furniture makes exactly that size of pocket. The repair is now LAYERED and its threshold is zero: any sealed cell strips that building's furniture first and re-floods, and only a building still sealed after that loses its authored floor plan. Result across 12 maps: **0 sealed cells with 1036 furniture pieces placed, and only 2 percent of buildings fall back to open**, so the plans survive. Also corrected the district border jitter, which the audit proved was a mathematical no-op, and the sim bot's downed branch, which froze the beacon.
  - **Sim 1/5 with the tankier enemies**, killers crawler and sentry. That is the spec's intent rather than a regression, and his runs decide the final numbers.
  - Servers died twice more this tick and were restarted; his link is live.
- **v1.21 (procedural generation is off; DAM BATTLEGROUNDS is a real place):** Spec 4.1 and defect 7. Maps are now fixed, hand designed and stable so the player can learn them.
  - **The authored map.** A dam wall runs the width of the north with two gate gaps and the POWERHOUSE straddling it; a reservoir is held above, a spillway channel cuts south through the middle into a tailrace pool. Six named zones with deliberately different character: THE CREST along the dam, TURBINE YARD open with big sheds, SPILLWAY a committed crossing, SUBSTATION a grid of small blocks that plays as a maze, WORKERS ROW close interiors on a real street, TAILRACE WOODS broken cover. Each building carries an authored floor plan rather than a rolled one. Built entirely from my own design knowledge: nothing sourced, datamined or imported.
  - **Spec 4.5: manholes.** Six fixed spawn points, one chosen at random per run, every one of them drawn into the baked floor as a closed manhole and marked on the sector map whether or not it was used today.
  - Extraction points are authored too, all open at run start; spec 5.3 closure and the two stage pull are the next build.
  - **A real defect the bigger map exposed**: the A star node cap was a fixed 60,000 against a 81,250 cell grid, so long cross map routes failed on budget alone, measured 2 of 40. The cap is now sized from the grid. After: **40 of 40 routes found, corner to corner in 5.6ms**.
  - Zone naming keys on the authored ZONE, not the district, because several zones share a district and the crossing callout would otherwise name the wrong place. Verified all six resolve correctly.
  - **Verified:** layout byte identical across raids (fixed, not rolled), one single connected walkable region, 0 sealed interior cells, 0 unreachable spawns or extracts, 176 containers and 3 caches placed, frame 2.4ms of a 16.7ms budget, sim 1/5 with no hangs, no console errors. The procedural buildMap is left in the file unreferenced and will be deleted once the second authored map lands.
- **v1.22 (the extraction sequence the spec describes):** Spec 5.2 and 5.3, replacing the single global beacon.
  - **Four stages, and the second pull is the point.** Walk up and pull (about 1.6 seconds of standing there), 30 seconds inbound, then a **30 second boarding window during which you must pull AGAIN to leave**. Verified end to end: standing in a landed ship without pulling does nothing, which is the whole change.
  - **Every point runs its own clock**, so a call is a place rather than a global state. That is what makes spec 5.2's shared window possible: anyone at that point during the window can board, so riding out on someone else's call is intended play rather than a bug.
  - **Spec 5.3 closure.** Points close progressively on the raid clock, announced two minutes ahead, and **a point already pulled completes its full sequence past its own cutoff**. Verified: 3 open at 10:00, 2 at 6:00, 1 at 4:00, and a point pulled three seconds before its cutoff was still live and counting fourteen seconds later. Which point draws which closure time is shuffled per run, so the map stays fixed while the pressure pattern does not.
  - The siege, the arrivals and the hold all moved onto the per-point clock with them.
  - Verified: full sequence, closure timeline, lock-in past cutoff, frames and sector map clean, sim 3/5 with 4 calls and 0 missed beacons, no hangs, no console errors.
- **v1.23 (the unified hotbar):** Spec 6.1 and defect 9. The two guns plus a throwable button plus a heal key are gone; guns, throwables, medical and the crowbar now occupy seven equal slots.
  - **1 to 7 selects, G uses what is selected.** Only one thing is in hand at a time, which is the deliberate feel change: choosing what to hold becomes a decision under pressure rather than three always available buttons.
  - **Slots are computed from live state every frame** rather than stored, so a pickup or a spend shows immediately and there is no second copy of the truth to drift out of sync.
  - **Drawn icons, not text**, per the spec's readability requirement: gun silhouette, throwable with a pin, medical cross, crowbar, each with its count and slot number, centred at the bottom of the screen. Selecting a gun slot still routes through the existing X swap so the old muscle memory keeps working.
  - Key legend, gear rules and the pad legend all rewritten to the hotbar model, and the old duplicate throwable readout removed from the corner.
  - **Verified:** all seven slots select, selecting a throwable slot syncs the throw selection, G spends a throwable (2 to 1) and heals through the same key (50 to 78 hp, one item consumed), frames and sector map clean, no console errors.
  - **Sim 2/10 across two batches, every death a sentry.** I checked whether the new two stage pull was the cause rather than assuming: on an empty map the bot completes both pulls and extracts in 60 seconds, so the sequence is sound and the deaths are the spec's much tankier sentries (150hp against the old 80) doing exactly what the spec asked. His runs decide whether that lands.
- **v1.24 (BURIED CITY, a map picker, and the procedural generator is deleted):** Spec 4.3 and the completion of 4.1.
  - **Map 2 is built.** Desert ruins whose entire identity is one contrast: a 2000 by 2000 open courtyard with long sightlines and five half buried walls as the only cover, ringed by garage rows and terraces that are tight close quarters clearing. It plays nothing like the dam, which has verticality and water as its constraints; here the tension is exposure and the relief is a doorway.
  - **A map picker in the terminal** cycles the two maps, stored on the profile, so both are reachable.
  - **The procedural generator is gone**: 12,335 characters of zone seeding, landmark reservation, woods and big building placement and scatter deleted outright. Nothing generates terrain at runtime any more. Git history holds it.
  - **A real defect found by probing rather than by eye.** Five authored spawn points sat INSIDE buildings, where the randomly placed furniture could block them: one was blocked in 8 runs of 10. Wrong twice over, since a manhole belongs in the street. All twelve spawns across both maps are now outdoors and verified never blocked across ten rebuilds each. A guard also nudges any blocked spawn to the nearest free point, so an authoring slip can never ship as a raid that starts stuck.
  - Two of my own mistakes, both caught and fixed inside the tick: the deletion left the fixture referencing the removed function, and a stale fixture build reported a syntax error the real file did not have. Verified the shipped file separately rather than trusting the fixture.
  - **Verified across both maps:** one connected walkable region each, 0 sealed interior cells, 0 unreachable spawns or extracts, 20 of 20 paths on each, frames and sector maps clean, sim 1/5 on each with no hangs, no console errors.
- **v1.25 (the snitch alarm, and ten raiders who remember you):** Spec 8.3, 8.4 and 8.5.
  - **The snitch is a timer you can beat.** Spotting you starts a 3 to 4 second audible windup rather than an instant mark, and killing it inside that window means nothing is called at all. If it finishes, reinforcements converge on **where you were when the alarm started**, so moving immediately is the second counterplay. It flees while alarming at 92 percent of its speed, fast enough to be a problem and slow enough to catch. Measured: window 3.25 seconds, and killing it mid windup prevented the call outright. Visually distinctive at range per the spec: an expanding red ring, a filling countdown arc and an ALARM label, so you can see one calling from across the map and read how long you have. Raiders now hear it too and come looking for a distracted target.
  - **Ten persistent named identities** with absurd tags, drawn distinct each raid so you never meet two of the same name. Gear rolls fresh each run, so an old rival can turn up dangerous or harmless.
  - **They remember, permanently.** Killing one records a grudge on the profile and it is shoot on sight from then on. Verified end to end: killed an identity, then found the same one hostile with the grudge flag set in a later raid.
  - **Varying hostility with a visible indicator.** Roughly half start passive; a passive raider watches you rather than opening fire, and turns only if you crowd it or shoot it. Measured: zero shots fired at 320 units over four seconds, flipped hostile at 160. Nameplates read the relationship at a glance: red for a grudge, green for passive, dim otherwise.
  - Verified: alarm timings and cancellation, identity uniqueness and grudge persistence, both hostility triggers, alarm visuals draw clean, sim 2/5 with no hangs, no console errors.
- **v1.26 (looting is a commitment you can break):** Spec 7.4.
  - **Progress persists on the container, not on you.** Start a cache, hear something, walk away and deal with it, come back and resume exactly where you left off. Measured: 2.3 seconds banked on a 4.6 second cache, kept intact across walking 900 units away and four seconds of doing something else, then finished in 2.33 more. That is what turns hearing footsteps into a real decision instead of a wasted commitment.
  - **The crowbar is in your hands while you work**, contextually rather than as a hotbar chore, and it is DRAWN: the gun leaves your hands and a pry bar replaces it. The cost of looting has to be visible or it is not a cost, and it means you can be caught holding it.
  - **Opened containers stay visibly opened for the rest of the run**: hollow interior, lid tipped back against the far side. An emptied container is evidence a raider has been here, which is information the map keeps for you.
  - **Partial progress is drawn on the container itself** in its rarity colour, so a half opened crate you abandoned is legible from across the room and worth walking back to.
  - Verified: resume timing, crowbar in hand during work, all three container states drawing together in one staged frame, sim 2/5 with 12 containers opened per raid and no hangs, no console errors.
- **v1.27 (real elevation):** Spec 4.6, the last big structural item. Genuine raised ground the player walks up onto, replacing the deleted shadow blobs.
  - **The design decision that makes it safe.** A platform's PERIMETER is emitted as ordinary walls with gaps cut where its ramps meet it. Collision, line of sight and pathfinding all keep working with no concept of height whatsoever; height is purely a render property, a lift applied to the sprite and to its y-sort key. That is the Sea of Stars trick the spec asks for: layered legible ground rather than a third axis in the simulation. It means verticality cannot introduce a class of movement bug, which matters more than the effect itself.
  - **Dam Battlegrounds gets elevated catwalks** over the turbine yard, spec 4.2's ask: a long sightline across the yard with only one way up. **Buried City gets a high terrace and a south wall** overlooking the courtyard crossing, which is the one commanding view of the map's most dangerous ground and therefore the one place everyone learns to check.
  - Decks bake into the floor with a hard cast shadow below and a bright near lip, and ramps get tread stripes, because height only reads in a three quarter view if the shadow sells it.
  - **Four real defects found by probing, all mine, all fixed inside the tick.** The lift lookup was called in the hub renderer where G is null, which is the same duplicate-renderer trap that killed v0.98; ramps were authored abutting platforms rather than overlapping them so no gap was ever cut and decks were 0 percent reachable; platform to platform junctions sealed an L shaped catwalk at its own corner; and a catwalk crossing a shed cut that interior in half, measured 407 sealed cells.
  - **Verified across 5 rebuilds of each map: 0 platform/building overlaps, 0 sealed interior cells, 0 blocked spawns, every deck routable from the ground, 20 of 20 map paths, frames and sector maps clean, sim 1/5 with no hangs, no console errors.**
- **v1.28 (the sound visualizer learns to speak):** Spec 10.2 and 10.3.
  - **A real colour language: source picks the hue, type picks the shade.** Red family is robots, orange family is third party raiders, white is you, yellow is environmental; light for movement and looting, dark for gunfire. Every ping site in the game was tagged at source, so a mark on screen now tells you WHO made the noise and WHAT they were doing, not merely that something happened.
  - **Spec 10.2 occlusion: walls muffle sound.** An occluded ping is measured at 0.42 of its strength and draws dimmer and smaller. Hiding behind concrete genuinely works and the visualizer tells you it worked.
  - **Spec 10.3 range cutoff: beyond earshot a sound does not appear at all**, verified with a raider stepping 4000 units away producing nothing. The visualizer mirrors what you would actually hear and nothing more. Distance also scales brightness and line weight, so a faint small mark reads as far and a bright heavy one as immediate.
  - **Opening a container is audible** and appears on the visualizer every half second of work, which is what makes an emptied crate a warning to whoever is listening.
  - **The language is stated in the legend** as six labelled colour swatches, because a colour code nobody can read is decoration. The old one line SOUND rule it replaces was removed.
  - Verified: far sound suppressed, near sound correctly tagged raider/move, through-wall muffling at 0.42, player gunfire tagged player/fire, legend renders inside its panel on both maps, sim 2/5 with no hangs, 4.15ms frame with 120 live pings on screen, no console errors.
- **v1.29 (the Undercroft has people in it):** Spec 3, and defect 8's "empty box".
  - **Vendors are named and they talk.** REQUISITION and WORKSHOP became HOLT, QUARTERMASTER and MERRIT, FITTER, each with rotating lines spoken over the floor when you walk up, so the hub reads as somewhere staffed rather than a row of interaction prompts on crates.
  - **VESH, THE GAMBLER**, spec 3.3, on the Diablo/Gheed model: unidentified goods at a **flat 450 credits whatever comes out**, unlimited pulls, money the only constraint. Verified the price does not scale with anything: 8 pulls cost exactly 3600, and it still charged 450 with a million credits in the bank. The pool runs from scrap to a Bloom Sample at long odds, 8 distinct results in 8 pulls, everything banked straight to the stash with a running list of what came out. The button disables and refuses to spend when he cannot afford it.
  - **The DEV CRATE**, spec 3.4: a full test kit opted in or out **per run**, so testing gear never leaks into a raid he did not ask for. Verified both ways: with it on, the raid starts with a Pristine Marksman Rifle, 60 armour, 96 reserve and two of each throwable; with it off, a bare Marksman Rifle and nothing.
  - A real defect found and fixed inside the tick: the vendor speech decayed its timer inside the hub DRAW pass, which has no dt. Moved to the update pass where dt exists.
  - Verified: all seven stations reachable from adjacent standing, gambler pricing and refusal, dev kit both states, hub and raid frames clean, sim 3/5 with no hangs, no console errors.
- **v1.30 (keys, locked rooms, and the two progression tracks):** Spec 7.6 and 17.
  - **Locked rooms**, two per map, sealed by construction with a single door segment that is REMOVED when the matching key is spent. That is the whole mechanism: no key means no route, and the nav grid and sight segments rebuild the moment it opens, so the route becomes real for everything on the map and not just for you. Each holds three cache grade containers, which is the reason to spend a key rather than sell it.
  - **Keys are single use and name their own door**, so there is no hunting. They drop in safes and caches, appear in Vesh's pool at long odds, are sellable if you will never use one, and can be extracted, stashed and brought back for a targeted raid. Which keys exist depends on the loaded map, so the loot tables carry a placeholder resolved at draw time.
  - **Locked rooms display on the in run map** per spec 11.1, marked LOCKED or OPEN, so the route can be planned before you commit.
  - **Spec 17: two tracks, neither of which makes the character stronger.** Experience counts time invested. Extraction Proficiency weighs value you actually get OUT, so dying loaded costs you 60 percent of what you were carrying. Verified: extracting with 6700 credits of loot took proficiency to 6; dying with more took it back to 0 while experience still rose. Both show on the post run summary and the hub header.
  - **Verified the whole key mechanic end to end:** the room is genuinely sealed before the key, immune to having no key and to holding the WRONG key, opens and consumes exactly one key with the right one, and the interior becomes reachable only afterwards. Keys reach the world at 27 across 6 raids, and the gambler produced 36 keys in 2000 pulls against a 2.26 percent expectation with no placeholder leaking. An earlier 0 in 200 was variance, checked rather than assumed.
- **v1.31 (the Mercenary, and a testing leak I had been causing):** Spec 3.5.
  - **THE HIRING BENCH.** One of the ten identities, hired for a single run, paid up front at 2600 credits. He drops in beside you, fights, and **loots for himself**, so he is competing with you for the good stuff. Walk out together and you take **ten percent of what he carried**. If he dies you owe a **3400 credit death benefit** to his family, and it is not optional: a bad mercenary run can put you in debt, which was the point of the spec's wording.
  - **The relationship system pays off here.** Good standing discounts the hire up to 40 percent; an identity you have KILLED refuses to work for you at any price. Extracting with him alive raises his standing, which makes him cheaper next time.
  - **Verified the whole contract:** hire charges exactly 2600, he spawns 60 units from the drop, he never turns hostile even when crowded, extracting paid a 330 cut on a 3300 haul, his death charged 3400 and took the balance negative with the debt called out on the summary, and a rival I had killed showed as refusing to work.
  - **A defect of mine, found by probing:** the mercenary was spawning up to 4764 units away, because the placement asked a whole-map random sampler to land within 320 of the drop and simply gave up. Replaced with a ring search around the spawn.
  - **And a workflow leak worth naming.** Two exports arrived this tick that looked like his runs and were mine: the test fixture was posting completed probe runs into `exports/` with 0 duration and 0 movement, exactly the artefact class the tick rules warn about, and it had been quietly corrupting his profile statistics for several ticks. Fixed at source by pointing the fixture's telemetry endpoint at a dead port. My first attempt stubbed the export FUNCTION, which failed because it is declared after the injection point and its own declaration overwrote the stub; redirecting the endpoint constant works because it is declared before. Verified: three forced fixture run completions now produce zero files in his recorder.
  - Frames clean on both maps with a mercenary alive, sim 1/5 with no hangs, no console errors.
- **v1.32 (the Peddler, and a duplicated block that had been sitting in the spawn code):**
  - **NEUTRAL CHARACTERS, which was his own answer to what the world was missing.** The Peddler is the first. One per raid, standing at whichever landmark sits about 1700 out from the drop, behind a folding table with three crates of stock on it and a lit lantern beside him. He does not fight. He does not move. He is marked TRADER on the sector map, because a trade you never found is not a decision, it is a secret.
  - **He is the pillar stated plainly: risk versus greed.** He buys your bag at 55 percent and he pays INSTANTLY. The credits are banked the moment the deal closes, so they are yours even if you are killed thirty seconds later. The bag on your back is worth full price and can be taken from you; his offer is worth half and cannot. That is the entire design, and it is a real choice at every point in a run: sell now and walk out light, or carry it and gamble.
  - He will not buy a key. Selling him the way into the vault you are standing next to is not a trade, it is a mistake with a confirmation button.
  - **He sells too.** Three offers per raid, at 1.9x. If the map has a locked room, there is a 60 percent chance one of the three is the key to it, which is the offer worth crossing the sector for.
  - **NOTORIETY.** Shooting the unarmed man is the greediest move available and it should cost something money cannot fix quickly. Killing him drops his stock and adds a permanent point. At two points every stall in the game closes to you, and each point adds 15 percent to what a mercenary charges for standing next to you. It decays by one per four clean extractions, so it fades from working, never from waiting.
  - **Verified:** hub frame and raid frame both clean, one Peddler at 907 and 1936 units on two different drops, zero movement and zero shots fired across 20 sim seconds standing in his face, sale paid exactly 784 on a 1425 bag (55 percent to the credit) with the key retained, purchase charged exactly, credits written to the profile the same instant, walking away closes the stall, the money survived a death and was called out on the summary, notoriety refused the stall at 2 and decayed to 0 after four extractions, and he never appears in the bot sim so the balance baseline is untouched. Sector map, nameplate and stall panel all render.
  - **A real defect found while patching, and it was mine.** A duplicate of the entire locked-door block was sitting inside `buildRaid`, pasted into the branch that repairs a blocked authored spawn. It parses, so it shipped silently, but `G` is still null there and there is no player object: the one raid that ever landed on a blocked spawn would have thrown and failed to launch. Almost certainly a `.Replace()` of mine that matched twice, which is the exact trap this file has caught me with before. Removed. The lesson stands: after any replace in this file, count the occurrences.
  - Sim 20 raids: 45 percent extract, 0 hangs, average haul 4977 on an extraction, killers sentry 6 / raider 3 / crawler 2. Inside the 35 to 60 band. Not a claim about the Peddler, who is not in the sim; it is the check that nothing broke.
  - Browser parse substituted for `node --check` as usual, since there is no JS runtime here. What it cannot cover: how the stall FEELS to walk up to under pressure, and whether 55 percent is the right number. Both are his call, and the 55 is the one to watch.
- **v1.33 (the room you are in, and a flooded vault nobody meant to author):** He named SOUND as the biggest gap in the game, and separately said the maps feel SAMEY. Those turn out to be the same complaint. A shed, a treeline and an open street are three different acoustics, and a player hears the difference long before they can name it.
  - **A reverb whose size is the room you are standing in.** No impulse files: four parallel comb delays with their own feedback and damping, a small Schroeder reverb, with send level, feedback and damping all driven per frame from where the operator is. Five spaces, all authored: the VAULT is cavernous and dark, INSIDE a building is boxy and close, WOODS are dead and damped, WATER is bright, OPEN is a thin slap back. Walking through a doorway audibly closes the room around you. The Undercroft has its own long low acoustic, so it is the first thing he hears.
  - **YOUR OWN FOOTSTEPS.** You could hear every machine on the map walking and could not hear yourself, which is backwards. Five surfaces, one generator: gravel, boards, plate steel, leaf litter and standing water, each with its own length, brightness and resonance. Water and leaves are the loud ones on purpose: they are the two surfaces that should make you think twice about crossing. Crouching is quieter and slower, sprinting is faster and full volume, so the stealth control finally has a sound to go with it.
  - **A stinger the moment something acquires you.** A low swell you feel in the chest under a thin descending shiver, placed at the thing that saw you, once every five seconds at most so a room turning on you at once is one shock rather than a wall of them. He asked for TENSE AND FRIGHTENING and this is the cheapest honest way to get it.
  - **The heartbeat now keys on danger, not just damage.** It used to run off health alone, so being hunted at full health was silent while bleeding out in an empty street was loud. Either condition drives it now, and whichever is worse sets the rate.
  - **A real authoring bug, found by the surface probe.** The dam's POWERHOUSE is authored at 2180,300 and the reservoir rectangle spans 120,120 by 4960 x 520, so the powerhouse sits entirely inside the water. That silently made the map's single highest value locked room, the TURBINE ROOM vault, half speed and crouch defeating, and painted its interior reservoir blue: you spend a key to get into the one place on the map you cannot move or hide in, with nothing anywhere saying so. It was never a decision, it was two rectangles overlapping. **A building has a floor.** Fixed mechanically in `inWaterMap` and visually in the ground bake, and verified: the powerhouse interior now bakes the same colour family as every other dry foundry building and is clearly distinct from the open reservoir beside it.
  - **Verified:** hub frame and raid frame clean on both maps, 60 frames with the full audio tick running and no exceptions, all five acoustics and all five surfaces reachable across 4000 sampled points, and the reverb automation measured converging to its authored targets in real time (open send 0.152 damp 4520, inside 0.44 damp 2100 feedback 0.80, woods 0.071 damp 824). Step cadence measured over 6.4 seconds: 14 walking, 10 crouched, 20 sprinting, 0 standing still. Stinger fires once on acquisition and a second acquisition inside the window correctly does not refire.
  - Sim 24 raids: 38 percent extract, 0 hangs, average haul 3525 on an extraction, killers crawler 7 / sentry 5 / raider 3. Inside the 35 to 60 band, and within the known swing of this sim; not a claim of change.
  - Browser parse substituted for `node --check`. **What I cannot verify: whether any of it sounds good.** I have no ears here. The numbers say the graph builds, the automation moves and nothing throws; whether the reverb is too wet indoors, whether the stinger is a shock or an annoyance, and whether the water footstep is too loud are all his to judge on one playthrough. The stinger is the one to listen for first.
- **v1.34 (COLD STORAGE, a third map, and a population bug it exposed):** His top complaint, in his own words, is that the maps feel SAMEY, and with two of them he was right by arithmetic before anything else.
  - **The third map is authored AGAINST the other two rather than beside them.** DAM BATTLEGROUNDS is wide horizontal bands split by one long barrier. BURIED CITY is a symmetrical ring around one enormous open courtyard. COLD STORAGE has no open ground at all: a packing plant, 4200 by 3400, about a third smaller than either, where every element exists to cut sight lines. Fourteen rows of racking with the aisle gap offset every row, so a straight run through the floor does not exist and standing in one aisle tells you nothing about the next. Nine freezer units in a three by three grid with eighty unit alleys. Container rows on the scrap line. A fenced dock strip with three gates, so leaving the docks is a decision.
  - **The claim is measured, not asserted.** Mean sight line, sampled 3360 rays per map from random walkable points: dam 638, buried 546, **cold 414**. Rays running further than 700: dam 39.3 percent, buried 29.8, **cold 21**. It is a genuinely different place to fight in.
  - **A real bug the new map exposed.** The enemy counts in CFG are flat numbers, which means they were really "this many bodies per map" rather than per acre. Nobody noticed while both maps were the same size. COLD STORAGE is 31 percent smaller and therefore came out **46 percent denser purely by accident**, and it sim tested at **6 percent extract against the dam's 38**. That was never a design decision, it was a config that never anticipated a second map size. Population now scales with ground, with the dam as the reference: the two existing maps are arithmetically unchanged (verified, 57 entities each, identical kind counts) and any future map inherits the dam's density. The difference between maps stays what it should be, which is their SHAPE.
  - After the fix COLD STORAGE runs **21 percent extract over 19 raids**, still the hardest of the three and now hard for the authored reason rather than an accidental one. Saying the number plainly: 21 is below the 35 to 60 band. It is one map of three, the bot handles tight geometry worse than a person does, and his own playtest tagged "Extract too easy", so I am shipping it as the hard map and leaving the call to him. Mean first contact 70 seconds. Killers sentry 11 of 15.
  - **Verified:** all three maps boot and draw, 99.42 percent of Cold Storage's walkable cells reachable from the drop (dam 98.72, buried 99.71), all six authored spawns and all three extraction points clear of geometry, all three extraction rings reachable, both catwalks 100 percent reachable, both locked rooms sealed before the key and reachable through the door after it, both new keys exist and open the right door, and the Peddler stocks them (17 freezer keys and 8 office keys across 40 raids). All five acoustics and all five footstep surfaces present on the new ground.
  - Two loose ends measured and deliberately left: the dam's TURBINE ROOM probe first read as unreachable, which was my probe point landing in the powerhouse wall's nav padding and not a fault; opening the door and re-flooding reaches all four corners. And two of BURIED CITY's three extraction markers sit with their centre inside geometry. Both rings are reachable so both work, and moving beacons on a map he has already learned is not worth a cosmetic tidy.
  - Browser parse substituted for `node --check`. Not verified: whether Cold Storage is FUN to move through. The numbers say it is tighter, denser and harder; whether that reads as tense or as claustrophobic in a bad way is a playtest question.
- **v1.35 (the season, and a stale roadmap he could see):** He named SEASONS OR TIERS as the structure he wants, and the game had no spine at all: every raid was worth exactly what the last one was and nothing accumulated except a credit balance.
  - **THE SEASON BOARD**, a new station in the Undercroft. Ten tiers, one long track, fed by every raid you finish. The rewards are things you can feel rather than a number going up: credits at four tiers, 400 reputation which opens the Quartermaster faster, the Burst Carbine, the Riot Scattergun and the Marksman Rifle straight into the armoury, a kit of medkits and plates, and one tier that raises your standing with all ten identities at once, which makes mercenaries cheaper and raiders more likely to leave you alone.
  - **Every raid feeds it, and a raid you died on still pays half.** 90 for walking out, 35 per thousand credits hauled, 3 a container, 6 a sentry up to 60 for a Warden, 40 for a door you spent a key on. Dying halves it and backing out quarters it. Losing already costs you your gun and your bag; it should not also erase the fact that the run happened. Measured over 7 sim raids at the bot's rate: deaths paid 63 to 149 and extractions paid 328 to 547, which is the difference reading clearly without the loss being nothing.
  - **Finishing the track moves the WORLD, not a badge.** Season 1 becomes Season 2, the track resets, and the world tier goes up: loot is worth 8 percent more and everything out there has 6 percent more health, per tier, to a cap of five. That is what makes it a tier ladder rather than a battle pass. It sits on top of his tuning sliders as a multiplier rather than rewriting them, so the Tuning Console still reads back what he set.
  - **Pacing:** the first tier lands after about one and a half raids so the board is not just a promise, and the full track is roughly 38 raids at the bot's 29 percent extract rate, which will be shorter for him because he extracts more often and hauls more.
  - **A collision worth naming.** The game ALREADY had a roadmap panel, built some builds ago and then not maintained: it still listed the sound pass as LATER after I shipped it in v1.33, and three NEXT items that had been done for weeks. I nearly shipped a second `var ROADMAP` beside it, which is the kind of duplicate-name collision that ships looking fine and then silently picks a winner. Merged into the one that exists, rewrote it to the truth, and the Season Board now shows the live list with the DONE items filtered out, because a board about what is coming should not be a receipt.
  - **Verified:** hub and raid frames clean on all three maps with the HUD and sector map drawn, the board opens and lists ten tiers and eight live roadmap rows, nothing is claimable at zero progress, a claimed tier cannot be claimed twice, and the whole track claimed end to end grants exactly what it says (three weapons into the armoury, four stash items, 400 rep, 20,500 credits, standing plus two on every identity) and then rolls the season over with progress and claims reset. The world tier then measurably moves loot to x1.08 and a sentry from 150 to 159 health. The progress line on the run summary matches what is actually awarded, checked on both an extraction and a death, so the number he reads is the number he gets.
  - Sim 15 raids on the dam: 40 percent extract, 0 hangs, average haul 4480, killers sentry 7 / raider 1 / warden 1. Unchanged band.
  - Browser parse substituted for `node --check`. Not verified: whether ten tiers is the right length, and whether the world tier climb is exciting or just inflation. Both need him to actually finish a season.
- **v1.36 (concealment, which the in-game roadmap said was next):** The game had no way to be hidden that was not also a wall. Cover stops a bullet; concealment only stops a look, and without it breaking contact in the open was impossible: once something saw you, the only answers were a wall or a kill.
  - **Bushes do not block movement, bullets, or anyone else's line of sight.** The only thing they do is make a body standing in one harder to notice. That is the entire mechanic and it is deliberately one rule.
  - **The numbers, and they are readable on purpose.** Crouching already hid you past 170 units anywhere, so the point of a bush is the two things crouch cannot do: hide you while STANDING, and hide you while MOVING. Standing still in one cuts the range you can be seen at to 40 percent, walking to 62, crouching to 10, and **sprinting to 100 percent with a noise ping**, because crashing through undergrowth is not stealth. Verified against a live sentry with a 340 unit range: exposed at 250 acquires, standing still in a bush at 250 does not, walking at 250 does not but at 180 does, sprinting at 250 acquires, and crouched at 60 does not. Every row matches the rule.
  - **And raiders use them against you.** A raider standing still in a bush at 300 units is genuinely invisible to you; the moment it moves it is not. That turns a treeline from scenery into somewhere an ambush comes from, which is the frightening half. Machines do not hide, because a Sentry creeping through a hedge is not the game this is, and the Peddler does not either, because he wants to be found.
  - **A HUD readout**, because a hiding mechanic you cannot tell is working is just an inconsistent enemy. It reads HIDDEN, WELL HIDDEN, CONCEALED, PARTLY HIDDEN or CRASHING THROUGH, coloured, above the health bar.
  - **Two defects found by measuring my own work.** First, both generation passes originally ran BEFORE the tree colliders, platform perimeters and locked room shells were pushed, so they were testing against an unfinished wall list: measured 10 bushes sitting on walls on Cold Storage and 5 inside buildings on Buried City. Moved to a single pass that runs last, and both counts are now 0 on all three maps. Second, a capture showed the operator vanishing completely inside a dense grove, which is unreadable rather than tense, so the bush YOU are standing in now draws at 52 percent while everyone else's stays solid.
  - **Density, tuned by measurement rather than feel.** The first pass put 2.6 percent of walkable ground under cover, which is not "find a bush", it is "get lucky". Now about 5 percent, with the median distance to the nearest cover at roughly 120 units, which is under a second of running. Findable under pressure, not everywhere. 214 bushes on the dam, 181 on Buried City, 136 on Cold Storage, none on a wall, none indoors.
  - Sim 16 raids on the dam: **56 percent extract**, 0 hangs, average haul 5421, mean first contact 67 seconds. That is up from 40 last build and at the top of the healthy band. Stating it plainly: the bot never crouches and never seeks cover deliberately, it only benefits when it happens to stop in a bush, and on 16 raids this is inside the known swing of this sim. I cannot separate the mechanic from variance at this sample size, and his own playtest tagged extraction as TOO EASY, so this is the number to watch next build rather than something I will quietly retune now.
  - Browser parse substituted for `node --check`. Not verified: whether hiding in a bush while something hunts you actually feels tense or just feels like the enemy got stupid. That is the whole question and it needs him.
- **v1.37 (parley, and a measurement that refused to give me the answer I expected):** Every human in this world was a target. Ten named identities, a standing ledger, a hostility model that already allowed a raider to be passive, and no way at all to USE any of it: you could shoot someone or you could walk away. Emotes are the missing verb.
  - **V opens a signal bar. Four emotes, picked with the number row.** HAIL is the one that matters; STAND DOWN, POINT and THANKS are expression. It is a strip and not a wheel on purpose, because a wheel wants the mouse you are already aiming with and this has to be usable while something walks toward you.
  - **You cannot talk to someone down a barrel.** A hail only counts if you are not aiming and have not fired for two and a half seconds. Otherwise it is just noise, and the bar tells you which of the two it currently is.
  - **A PASSIVE raider hailed twice becomes friendly for the rest of the raid.** He waves back, he hands you something out of his own bag, and his standing goes up permanently. Crucially he then stays friendly even if you crowd him, which the old rule flipped at 180 units: verified by standing on top of one for three sim seconds. That is the whole payoff of having talked to him.
  - **A HOSTILE raider can be talked down.** Two hails if he has not shot at you recently and you are not closing inside 190. Notoriety makes him slower to believe you: verified, at notoriety 2 it takes four hails instead of two. Good standing makes him quicker.
  - **A raider you have KILLED never listens.** He gets a refusal mark over his head and nothing else, which is what the grudge ledger was always for.
  - **And shooting a man who waved at you ends it permanently:** friendly off, hostile on, grudge set, standing down three. Verified, it left him at minus two.
  - Emote bubbles over every head that sent one, and the nameplate now reads FRIENDLY or LISTENING, because a parley you cannot see happening is a dice roll.
  - **A NEW TUNING DIAL, and the honest story behind it.** The sim's extract rate has climbed 40, then 56, then 64 percent across the builds since bushes landed, and his own playtest already said extraction was TOO EASY, so I added `concealPow` (a 0 to 1 scale over the whole concealment benefit, on the Tuning Console) specifically so the question could be measured instead of argued. Then I ran it: **concealment off, 44 percent over 16 raids. Full, 69 percent over 16.** That looked conclusive. So I ran the midpoint as a check, and 0.6 came out at **25 percent**, which is LOWER than switching the mechanic off entirely and is not physically possible for a partial buff.
  - **That contradiction is the finding.** It means 16 raids cannot rank these settings at all, and the 44 against 69 gap I was about to act on is inside this sim's noise. So I have changed nothing: concealment ships exactly as authored at 1. The dial stays, because it is the instrument this needs, and the next honest answer requires a run several times this size or his own playtest. I would rather ship the null result than a tuning change I talked myself into.
  - **Verified:** hub and raid frames clean with the bar open and bubbles live, all four emotes, both parley paths, both refusal paths, the aiming and recently-fired gates, the crowding test, the retaliation path, and the notoriety scaling. Sim 14 raids at the shipped setting: 64 percent extract, 0 hangs.
  - Browser parse substituted for `node --check`. Not verified: whether talking a hostile raider down feels like a real negotiation or like a button that switches an enemy off. That is the design question and it needs him.
- **v1.38 (contracts that pay in gear, and the concealment question finally answered):** Spec 16. A board that handed out money and nothing else was a slower way of selling loot, which is why contracts were something you completed by accident rather than something you went out to do.
  - **Every contract now names a physical payout before you commit to it.** That is the whole change: choosing between three contracts is now choosing between three pieces of kit. Medkits, plates, smoke, decoys and ammo at the bottom; frag charges, a field kit, a key to a sealed room, and the Burst Carbine, Riot Scattergun or Auto Rifle in the middle; the Marksman Rifle, the Support MG, a crate of rare salvage, a Bloom Sample or an ARC Reactor Core at the top.
  - **Three tiers, gated by a contract standing ledger of its own.** STANDARD always; HARD unlocks at 3; ELITE at 8. Standard work pays 1 standing, hard 2, elite 3. The board tells you where you stand and what is next. Targets and credits scale with the tier: measured, median reward goes 540 at standing 0, to 966 at 3, to a 3,200 credit elite job with a Bloom Sample attached.
  - **A payout you cannot use is not a reward,** so a weapon already in your armoury is never offered. Verified over 400 rolls: zero.
  - Two of my own picks were wrong and the probe caught them. The Stitcher and the Hullcracker are two of the four guns the Undercroft ISSUES you free after a bad run, so offering them as HARD contract pay is offering nothing; replaced with the Auto Rifle and the Riot Scattergun. And I had put the Compact SMG in the ELITE pool, which is an early gun sitting in the top tier; replaced with the Bloom Sample.
  - **Verified:** every one of the sixteen gear entries resolves to a real label and actually delivers weapons or stash items when paid, the board renders all three tiers with their badges and gear lines, and claiming three completed contracts through the real buttons paid 5,680 credits, six stash items and six contract standing, then refilled the board with three fresh contracts that all carry gear.
  - **THE CONCEALMENT QUESTION, ANSWERED.** Last build I ran an A and B on the new concealment dial, got 44 percent against 69, then got 25 percent at the midpoint, which is impossible for a partial buff, and concluded the sample could not rank the settings. So I ran it again this build at a larger size and, more importantly, as an independent replication. **This run: concealment on 45 percent over 22 raids, off 27 percent over 22.** Pooled with the previous run that is **76 raids: on 55 percent, off 34 percent.**
  - **Both independent runs agree in direction and roughly in size: bushes are worth about twenty points of extract rate to a bot that does not even use them deliberately.** The 25 percent midpoint reading was a small sample outlier, exactly as suspected. That is a real effect and I am recording it as one.
  - **I am still not retuning it, and here is the reason rather than a shrug.** The shipped setting lands at 55 percent pooled, which is inside the game's own healthy 35 to 60 band, just at the top of it. Concealment is supposed to be strong; that is the point of it. His playtest tag said extraction was TOO EASY, and if his own play agrees then `concealPow` at about 0.7 is where I would go first. That is a feel judgement and it is his. The measurement's job was to tell him the number, and the number is twenty points.
  - Sim at the shipped setting: 0 hangs across 44 raids. Browser parse substituted for `node --check`. Not verified: whether a named gear payout actually changes which contract he chases, which is the entire premise of the change.
- **v1.39 (armour in three tiers, and a sim that was measuring a game nobody plays):** Spec 9.7. One flat armour pool topped up by plates was a health bar with a different name. A rig is a decision you make in the Undercroft and then live with for a whole raid.
  - **Three rigs, and every point of protection is paid for.** SCAV RIG: 35 armour, no cost at all. PLATED VEST: 70 armour, 6 percent slower, 16 percent louder. BREACHER PLATE: 120 armour, 14 percent slower, 34 percent louder, and it soaks a bigger share of every hit. All measured on the shipped build: distance walked in two seconds went 316, 316, 297, 272, and the noise a footstep carries went up by exactly 1.02, 1.16 and 1.34 times with the weather held constant. A 40 damage hit costs 48 health bare, and 24, 20 or 16 with a rig on.
  - **You lose it when you die.** Same rule the guns already live under, and it is the whole reason the Breacher Plate is a bet rather than an obvious upgrade: 7,800 credits of protection that you only keep by walking out. Verified, and the summary names it: "Breacher Plate is gone. Falling back to the Plated Vest."
  - **READABLE ON THE SILHOUETTE, which is the half he actually asked for.** Armour draws in a cool steel ramp rather than in the coat colour, so it reads on all six raider coats and on the operator, and each tier is a different SHAPE rather than a different shade: a chest plate, then pauldrons, then a collar and a hard ridge. Measured against a frozen bare frame of the same figure: the silhouette gains 634, 882 and 1,091 pixels and widens from a 13 pixel torso to 19, 27 and 30. It sits between 10 and 24 pixels above the boots, so it is on the chest and not floating.
  - **And raiders wear them too**, weighted so most of what you meet has something on: 56 percent light, 15 medium, 5 heavy. Their armour absorbs exactly as yours does. That is the point of drawing it in steel: you can now decide whether to shoot the man in the road by looking at him.
  - **A defect of mine, caught by the sim and worth naming.** Raiders got armour and the sim's player did not, so the bot was fighting armoured opponents in a shirt. Extract rate fell from 64 percent to 20 in one build, which I nearly read as "raider armour is too strong". It was not: the sim had stopped modelling the game. It now wears a FIXED Scav Rig, which is both representative and constant across builds, and the rate came back to **60 percent over 15 raids, 0 hangs, average haul 4,819**. The lesson is the general one: when a measurement moves that far in one build, suspect the instrument before the design.
  - Bought, worn and switched through the real shop buttons: three rigs for 11,900 credits total, Wear and Worn states correct, no double purchase, and switching rigs takes effect on the next deploy.
  - Browser parse substituted for `node --check`. **Not verified: how the heavy rig FEELS.** The numbers say 14 percent slower and a third louder; whether that reads as weighty and deliberate or just sluggish is a playtest question, and it is the one to watch.
- **v1.40 (weak points, and the only way to use one is to be behind the thing):** Spec 8.7. A Sentry was 150 health and a Warden was 620, and the only tactic either asked for was "have enough bullets". A weak point turns a health bar into a place you have to GET TO.
  - **The vent is on its back.** That is the entire design. The only way to use the best opening on the machine is to be behind one that is hunting you, which is the exact opposite of what your nerve is telling you to do. The angles are offsets from the machine's own facing, so the openings turn as it turns: watching a Sentry sweep is watching the shot open and close.
  - **VENT, x3.4 and it overheats.** Verified end to end on the shipped build: a 20 damage round into the flank deals 20, into the optic deals 40, into the vent deals **68**. And overheating is not a debuff, it is a window: measured, a Sentry venting fired **0 rounds over four seconds against 6** from the same Sentry not venting. It cannot move, cannot turn and cannot shoot while it cools, so the vent stays exactly where you put it.
  - **OPTIC, x2 and it goes half blind.** Its acquisition range drops to about a third: verified, a sighted Sentry acquires at 200 and 300 units, a blinded one fails at 200 and only finds you at 100 and 60. It still comes; it just cannot pick you out.
  - **You cannot shoot the vent through the machine.** Found while testing: with the Sentry facing me, a round aimed at the far-side vent landed on the near-side optic instead, because the nearest opening on the path wins. That is correct and it is the load-bearing rule. Flanking is mandatory, not optional.
  - **A weak point is checked BEFORE armour**, because it is the gap in the armour. Nothing soaks a round through the vent.
  - **They are drawn, pulsing, in their own colours:** hot orange for the vent, cold blue for the optic, and the vent burns bright while it is venting so the window is visible from across the street. An opening you cannot see is a secret, and a secret is not a tactic. Crawlers and raiders have none: they are small and fast and their answer is already "shoot them".
  - Sim 15 raids: 53 percent extract, 0 hangs, average haul 3,417, killers sentry 5 and raider 2. In line with the last several builds; the bot does not aim at weak points, so this measures that nothing broke rather than the feature.
  - Browser parse substituted for `node --check`. **Not verified: whether going for the vent is a thrill or a chore.** The measurement says the window is real and the reward is large; whether a player will take the risk of walking behind a hunting machine to get it is the design question, and it is his.
- **v1.41 (scopes that see further, not just hit harder):** Spec 9.4. In a game built on not being able to see, range on a weapon card was nearly meaningless. The Marksman Rifle could reach 760 units and the operator could only SEE 620, so most of what you were paying for was theoretical: you owned a rifle that could hit things you would never know were there.
  - **Scoping now pushes your sight down the lane you are aiming along.** Marksman Rifle 1.9x, Auto Rifle 1.25x, Support MG 1.15x. Everything else has no glass and aiming does exactly what it did before. Measured on the shipped build: hip view 620, scoped 1,178 with the Marksman Rifle, 775 with the Auto Rifle, 713 with the Support MG, and unchanged on the pistol, SMG and carbine.
  - **The payoff, measured against a real body rather than a number:** with a clear lane, hip aim spots a Sentry at 500 units and misses it at 700 and 900. Scoped spots it at 500, 700 AND 900. That is the whole feature: the glass finds you targets, it does not merely help you hit ones you had already found.
  - **And it costs exactly what it should.** The lane narrows as it lengthens and your peripheral awareness collapses: the vision cone goes from 130 degrees to 73.7, and the awareness radius that catches things at your shoulder drops from 144 to 79. A scope is a straw you look down, which is why scoping in a corridor with something behind you is a bad idea. You are also already slowed to 62 percent and cannot sprint while aiming.
  - **It looks like what it is.** A vignette closes in as the magnification rises and a thin ranging ring sits at the cursor, so the narrowed cone and the lost periphery are visible rather than merely true, and the weapon line reads "1.9x SCOPE" instead of "[ADS]".
  - **Cost measured, not assumed.** The visibility polygon is built to the new radius, so scoping does more work per frame: 1.24 ms hip against 1.76 ms scoped over 40 frames at 1180 by 720. Real, and small enough not to matter.
  - Sim 15 raids: 40 percent extract, 0 hangs, average haul 2,866, killers sentry 5 / crawler 3 / raider 1. The bot deploys with the issued sidearm and no glass, so this is a check that nothing broke rather than a measurement of the feature.
  - Browser parse substituted for `node --check`. **Not verified: whether 1.9x is too much.** Seeing nearly twice as far down one lane is a large advantage, and the Marksman Rifle is already the best gun in the game. If the DMR starts feeling like the only correct answer, the number to move is its optic.
- **v1.42 (the Stray, and the first way to un-ruin your reputation):** The second neutral character. The Peddler is a business; the Stray is a person.
  - **He is hurt, he is hiding, and he wants one specific thing.** A medkit, a bandage, an armour plate or a box of ammo. He is placed INSIDE a building, at least 900 units from the drop and 700 from the Peddler, and he is **not on your map until you find him**. That is the difference between the two neutrals: the Peddler is an errand you can plan, the Stray is something you stumble into. Verified on all three maps: one per raid, always indoors, and always well clear of both the drop and the stall.
  - **What he pays with is the point.** Not much money: **he tells you where an ARC CACHE is**, and it goes on your sector map, named and drawn. Caches are pure high tier, so this answers "I JUST FIND JUNK" from an angle loot tables cannot: the reward for being decent to a stranger is a reason to walk somewhere you were not going. He deliberately names the cache FURTHEST from you.
  - **And helping him takes a point of NOTORIETY off you.** Until now the only way to clear notoriety was to wait out four clean extractions. Shooting traders makes you a problem; pulling someone out of a hole makes you less of one. Verified: notoriety went 2 to 1 on a single handover.
  - **He also pays a few hundred credits, banked the moment you hand it over**, the same rule the Peddler pays under, and the run summary names it whether you live or not.
  - **Shooting him costs a point of notoriety**, drops what little he had, and does not count as a kill on the recorder. Verified: he never moves, never fires, never damages you across 15 sim seconds of standing on top of him, so nothing about him is a threat you can claim you misread.
  - **Verified end to end:** approaching without the item asks and does nothing, handing it over consumes exactly that item and pays, a second handover is refused, the cache appears on the sector map, the summary line reads back the exact amount banked, and every frame, HUD and map pass is clean on all three maps.
  - Sim 12 raids: 50 percent extract, 0 hangs, average haul 3,434, killers crawler 3 / sentry 2 / raider 1. The bot has no idea he exists, so this only checks that nothing broke.
  - Browser parse substituted for `node --check`. **Not verified: whether he is findable often enough to matter.** He is hidden on purpose and he is randomly placed above a 900 unit floor, so on a big map you may go several raids without meeting one. If he turns out to be a thing you hear about but never see, the floor is the number to move.
- **v1.43 (your body is still out there):** He asked for losing a raid to be A REAL GUT PUNCH. It already cost the bag, the guns and the rig, but a loss that is only subtraction is a number going down: you read the list, you sigh, you deploy again.
  - **Everything you were carrying now stays exactly where you fell**, on that map, and you can go and get it. That turns the worst moment in the game into the setup for the most tense run you will play, because the spot you died in is by definition somewhere that kills people. It is marked on your sector map from the moment you deploy and it glows in the world, because the point is that you can plan a route to it.
  - **Three rules stop it being a free refund.**
    - **ONE body at a time.** Die again and the old one is gone, with a line on the summary saying so. Recovery is a commitment, not something you get to later.
    - **IT ROTS.** Three raids, and scavengers take a quarter of what is left every raid you leave it out there, highest value first. Measured: 8 items became 6, then 4, then nothing.
    - **The clock only runs while you are raiding**, so it cannot rot away while you sit in the Undercroft, and it only appears on the map it happened on.
  - **The rig comes back too.** Recovering the body re-equips the armour you died in and puts it back in your inventory, which matters now that a Breacher Plate is 7,800 credits.
  - **A defect of my own design, found by probing.** Dying while carrying nothing was silently destroying a body that held a Reactor Core, with nothing on the summary saying it had happened. The one-body rule is meant to make recovery urgent, not to punish a bad deploy twice. A death with nothing worth leaving now keeps the old body and says so.
  - **Verified end to end:** the body records at the exact death coordinates on the correct map, does not appear on other maps, ages and rots on schedule, draws in the world and on the sector map, and recovering it returns the items through the normal container path with the usual capacity rules plus the rig re-equipped and the record cleared. The Undercroft carries a standing line telling you where it is and how long it has left.
  - Sim 14 raids: 50 percent extract, 0 hangs, average haul 3,690. The sim never leaves a body, and it was checked that it cannot: the profile was clean after every batch.
  - Browser parse substituted for `node --check`. **Not verified: whether three raids is the right window**, and whether losing a quarter a raid is cruel or about right. This is the mechanic most likely to need a number moved after one real playthrough, and the honest answer is that it needs him to actually lose something he cared about.
- **v1.44 (THE LISTENER, and the discovery that footsteps were silent):** A fourth machine, and the brief was FRIGHTENING rather than tough. More health is not frightening, it is arithmetic. What is frightening is a thing you cannot see coming, cannot fight on equal terms, and brought on yourself.
  - **The Listener is BLIND.** No vision cone at all. It never patrols and it never looks. It stands dormant and nearly black, hunched, easily read as a bit of standing scrap, until it HEARS something. Then it screams, straightens up, and comes at the noise, fast, hitting for 34. Verified: it stood 400 units away in plain sight for ten seconds with the operator motionless and never moved, never noticed, never touched him.
  - **Go quiet and it loses you.** It runs to where the sound was, mills there for seven seconds, and settles back into dormancy. Verified. Any new noise inside that window puts it straight back on you.
  - **A DEFECT THIS FEATURE EXPOSED, and it is the biggest one in a while.** The Listener hunts noise, so I tested walking past one, and nothing happened. **The player's footsteps were producing audio and nothing else.** No noise event existed in the world at all: since v1.33 you could hear your own boots, and crouching sounded quieter, and none of it was mechanically real. The entire stealth layer was decoration. Footsteps now emit a real noise event scaled by stance and surface, with water 55 percent louder, metal 30 and leaf litter 20.
  - **Sent deliberately as a noise ordinary patrols ignore**, exactly as they always ignored footsteps, so no existing balance moves. Verified: a Sentry 200 units away still does not react to walking. The Listener hears it anyway, because it is checked before that gate. That is what makes it the only thing on the map that punishes moving badly.
  - **And the numbers make every stealth choice in the game load bearing at last.** Walking wakes one at 200 units and not at 300. **Crouching is safe at 120 and at 200.** Sprinting wakes it at 400. And in the Breacher Plate, walking wakes it at 300 where bare was safe, **and crouching wakes it at 120 where bare was safe**. The 34 percent noise penalty on heavy armour has a consequence now: the rig that keeps you alive against everything else gets you killed by this.
  - Two per map at the reference size, always dormant at spawn, always at least 1,000 units from the drop. Killing one is possible and it drops a small cache; the intended answer is silence.
  - **Guarded against my own design:** the wake scream is itself a noise, and noise wakes Listeners, so the ear routine is re-entrancy locked. With two per map the chain was finite anyway, but it is the kind of thing that stops being finite the moment somebody raises the count. Also gave the kill counter a slot for the new kind, without which the first one you killed would have turned the whole tally into NaN.
  - Sim 14 raids: 43 percent extract, 0 hangs, average haul 4,424, killers sentry 7 and raider 1. No sim death was caused by a Listener, which fits: the bot walks a lot but not near them.
  - Browser parse substituted for `node --check`. **Not verified: whether it is actually frightening.** Everything measurable says the trap works. Whether hearing something scream in the dark and knowing it is coming for a noise you made lands as dread or as an annoyance is exactly the question I cannot answer from here.
- **v1.45 (loot that can spike, and the odds are set by how greedy you are being):** "ITS BORING. I JUST FIND JUNK" and "I SHOULD FIND TOP TIER LOOT EVERY RUN". Raising the drop rates would only move the floor: within three raids the new good stuff is the new junk, because a constant is not exciting however large it is.
  - **WINDFALLS.** Any ordinary container can produce a second item on top of what it was already going to give you, drawn from the top of the table, announced loudly. The odds are not flat, and that is the whole design: **they are set by how far you are from a way out, how long you have been on the surface, and whether something that can kill you is standing within 340 units.**
  - **Measured on the dam, and greed pays six to one.** Standing next to an extraction point in the first minutes: 4.1 percent. At the deepest point on the map, 3,462 units from any way out: 20 percent. Nine minutes out and still deep: **25.7 percent**. Nine minutes out but back beside the beacon: 9.8. A run of 160 real container opens at the deep late position returned 36 windfalls, 22.5 percent, matching the model.
  - It is rolled at the MOMENT OF OPENING rather than when the map is built, because half of its inputs are facts about you: how long you have been out here and what is standing near you right now.
  - **THE ARC STRONGBOX.** One per raid, the discrete version of the same idea. It is placed in the worst place the map has, which in practice means inside a locked room every time on all three maps, so it costs a key before it costs anything else. It takes **nine seconds** to cut, and it **screams the entire time**: a 560 unit noise every half second, which reaches most of a district and every Listener on the map. Three elite items, all different, worth 6,700 to 8,800 credits.
  - Two of my own picks were wrong and the probe caught both. The Strongbox originally drew from the same pool as windfalls and rolled a Coil and a Payroll Ledger, which are rare rather than elite: nine seconds pinned and screaming is not worth three rare items. And with the pool fixed it rolled **three Sealed Codices**, which reads as a stack, not a haul. It now draws three distinct elite items from an elite-only pool.
  - Both are on the sector map from the start, because a dare you cannot see is not a dare. The Strongbox is drawn as a crosshair ring and named.
  - Windfalls and Strongbox opens are both in the flight recorder now, so the next tuning pass on this has data instead of my guess.
  - Sim 14 raids: 50 percent extract, 0 hangs, average haul 3,076. The bot loots whatever is nearest and leaves early, so it collects the 4 percent end of this curve almost exclusively, which is exactly why the sim haul did not move.
  - Browser parse substituted for `node --check`. **Not verified: whether the floor is high enough.** 4 percent beside the beacon is deliberately meagre, so a cautious raid still finds junk. That is the intent, but if his complaint is that EVERY run feels poor rather than that safe runs feel poor, the base rate is the number to raise.
- **v1.46 (weather that turns while you are still out there):** The conditions were rolled once at the drop and then they were a fact about the raid, which made weather a difficulty modifier you read on the loading line and forgot. A raid where the sky changes is a raid where the plan you made stops being the plan you are in, and that does more for how the place feels than a sixth weather type would.
  - **It crosses rather than snaps.** Every vision, noise and lighting query in the game reads the weather live, so a hard cut would be a jump cut. A turn takes fourteen seconds and everything moves together across it. Measured on a FOG to STORM turn: view went 0.60 to 0.80, noise 1.0 to 0.48, lamps 0.85 to 0.55, and the operator's actual sight distance travelled from 388 units to 496 continuously, one frame at a time.
  - **Announced when it starts, not when it finishes**, so the line arrives while there is still time to do something about it. The sector map shows the crossing and its percentage, so you can see how long you have before the fog is fully in.
  - Most raids get one turn, about three in ten get two, and it never turns into the weather it already is: verified over 300 forced turns, zero same-state transitions and all twenty possible pairs seen.
  - **A defect found by measuring rather than by playing.** The first cut booked the turn between 110 and 330 seconds, median 236. The median sim raid ends at 174. Three raids in four therefore never saw the sky move at all, which makes it a feature that exists mainly in the changelog. Pulled forward to between 86 and 208, median 145, keeping a floor so the conditions you deployed into are still the conditions you get to plan with. Re-measured: the sky now turns in **4 of 6** sim raids instead of 1 of 6.
  - The sim runs under the same sky, so its numbers keep meaning what they meant, and whether a turn happened is in the flight recorder.
  - Sim 14 raids: 36 percent extract, 0 hangs, average haul 3,236, killers sentry 8 and crawler 1. Inside the band and inside this sim's noise.
  - Browser parse substituted for `node --check`. **Not verified: whether a fog bank rolling in mid raid reads as dramatic or as the game getting harder for no reason.** The announcement and the map percentage are there to make it read as an event rather than a nerf, but that is a feel question.
- **v1.47 (machine voices, so you can tell what is out there without looking):** Sound is the gap he named, and the specific hole was that every machine on the map sounded identical. In a game whose whole premise is limited sight, being able to tell WHAT is nearby by ear is not decoration, it is the primary information channel. A servo sweep two rooms away and a skitter two rooms away are completely different decisions, and until this build they were the same noise.
  - **Five voices, one per kind.** The SENTRY sweeps: a filtered tone sliding across with a mechanical tick at the end of its travel. The CRAWLER skitters, a burst of short irregular clicks. The SNITCH is a thin detuned two tone whine. The WARDEN is hydraulic, a hiss with a sub-bass thump under it, audible at 900 units so it announces itself through two walls. The LISTENER creaks.
  - **And the voice changes the moment it notices you.** Hunting, the Sentry sweeps faster and higher, the Crawler's burst doubles in length and speed, the Snitch adds a beacon blip, and the Listener's dry creak becomes the same mechanism at speed, which is a shriek. Being noticed is now audible without looking at anything. Measured: an idle Sentry at 200 units voiced three times in ten seconds, the same Sentry hunting voiced **six**.
  - **A dormant Listener is almost silent, and the "almost" is the point.** Its hearing range is cut to a third when dormant, so it is inaudible at 320 units and audible at 260, 200 and 120. Blunder past one and you get nothing; move carefully and close and the creak is the only warning the game will give you.
  - **Occlusion is applied harder to voices than to gunfire**, because a machine behind a wall has to SOUND like it is behind a wall or the ear cannot place it.
  - **A hard ceiling, because a wall of noise carries no information.** Voices are budgeted at roughly seven a second across the whole map however many things are shouting. Measured: thirty machines all hunting inside 200 units produced about seven voices a second, not thirty. Without that the feature would defeat its own purpose in exactly the situations it matters most.
  - Verified: all five voices build their audio graphs without throwing in both idle and hunting forms, the scheduler runs twenty seconds of ticks clean, nothing in earshot produces exactly zero, and frames and HUD are clean.
  - Sim 14 raids: 50 percent extract, 0 hangs, average haul 3,677. Audio does not run in the sim, so this only confirms nothing broke.
  - Browser parse substituted for `node --check`. **What I cannot verify remains the whole point: I have no ears.** Everything measurable says the right voice fires at the right time, at the right rate, from the right place, and stops when it should. Whether a Sentry actually SOUNDS like a Sentry, and whether five machines in a street read as five distinguishable things or as mush, is entirely his to judge. If any one of them is annoying rather than informative, name it and I will rebuild that voice alone.
- **v1.48 (THE TERMS, so he can turn the difficulty up himself and get paid for it):** He tagged extraction as TOO EASY. The honest response to that is not for me to quietly raise the numbers, it is to hand him the dial and pay him for using it. It is also the cleanest possible statement of the pillar: a straight trade of safety for money, made BEFORE you know how the raid is going to go.
  - **A new station in the Undercroft.** Six terms, sign as many as you like, and the hazard pay adds up to +175 percent at full stack.
    - **BLACKOUT PROTOCOL +25%:** every lamp on the map stays dark. Not dimmer, gone: verified, 149 lamps to 0.
    - **HEAVY PATROLS +30%:** verified, 60 bodies on the map to 80.
    - **SHORT WINDOW +25%:** verified, the raid clock drops from 600 seconds to 396.
    - **NO SAFE POCKET +35%:** nothing is saved when you die. Verified, the "Safe pocket held" line disappears entirely.
    - **THEY KNOW YOU +30%:** every raider hostile and already looking. Verified. This one removes a whole tool from your hands, because there is no parley with someone who has already decided.
    - **SILENT RUNNING +30%:** an extra Listener, and every Listener hears half again as far.
  - **The bonus is paid only if you walk out.** Signing for worse conditions and then dying under them is simply a worse day, and the summary says so: "You signed for 55 percent and did not come back for it." Verified both ways: a 4,000 credit haul under +55 percent paid exactly 2,200 on the extraction and nothing at all on the death.
  - Season progress rides the same multiplier, because the work genuinely was harder.
  - **What you signed is on screen for the whole raid**, top right, because a handicap you have forgotten about does not read as a handicap, it reads as the game being broken.
  - **A layout defect caught by probing rather than by looking.** Adding the station pushed the Tuning Console to y=470 in a hub that is 470 tall, sinking half of it into the back wall where it may not have been reachable at all. Every station is now checked for bounds and for overlap: zero of each.
  - Sim 13 raids at standard terms: 38 percent extract, 0 hangs, average haul 2,838. The sim never signs anything, and it was checked that no term can leak into it.
  - Browser parse substituted for `node --check`. **Not verified: whether the prices are right.** +35 percent for losing the safe pocket is a guess, and so is the rest of the sheet. The one number I would watch is HEAVY PATROLS, because a third more machines may be worth much more than 30 percent, and if one term is obviously the best buy then the sheet is doing nothing.
- **v1.49 (machines that work together, and a difficulty spike I had to walk back):** The roadmap's next item was co-op, which is a networking architecture and not a fifteen minute job; pretending otherwise would have meant shipping half of it. Took the item after it instead, and said so.
  - **The problem: every machine fought its own private battle.** Six of them noticing you produced six identical charges along six copies of the same line, which is not six enemies, it is one enemy with six health bars. Worse, a crowd was LESS frightening than a pair, because a queue is legible and a queue dies in a doorway.
  - **A contact call now gives the group a shape.** The first machine to see you shouts, and everyone who answers takes a ROLE rather than a heading.
    - **PIN** holds at its own effective range and keeps shooting. It does not close, so backing off no longer resets the fight.
    - **FLANK** routes a quarter turn around you and comes in from the side, which is the thing that stops a doorway working.
    - **RUSH** goes straight in. Crawlers always take this: they are the timer on the engagement, and the shape only reads if something is forcing you to move.
  - **Measured, from an identical start, over six seconds:** a RUSH sentry closed 300 to 244 and walked 56 units. A PIN sentry **stayed at exactly 300 and walked 0**. A FLANK sentry closed to 146 but **walked 441 units and shifted its bearing 121 degrees to do it**. Three genuinely different behaviours, not three labels.
  - **Losing you scatters the search.** Six machines walking to one point is a queue again, so each takes its own slice of a ring around the last sighting: mean separation went from 0 to 206 units, every point distinct, and calling it twice does not walk them off the map.
  - **AND THEN THE SIM FELL OUT OF THE BAND, AND I WALKED IT BACK.** The first cut let every machine within 900 units answer, uncapped. Extract rate went from 38 percent to **14** in one build, which is not tense, it is an execution: six coordinated machines with a pin and a flank do not lose. Cut the shout to 620 units and capped it at four answering. Verified: eight machines in earshot, **four answer**. Re-measured at **50 percent extract over 12 raids**, back in line with the last several builds.
  - Both numbers are on the Tuning Console as **Contact call radius** and **Machines that answer a call**, because I have now been wrong about this once and he should not need me to be right about it.
  - Sim 12 raids: 50 percent extract, 0 hangs, average haul 4,008.
  - Browser parse substituted for `node --check`. **Not verified: whether the shape READS.** The numbers say a pinning machine holds and a flanker walks the long way round. Whether that feels like being outmanoeuvred or just like the enemies being slightly odd is the question, and the specific thing to watch for is whether you ever notice something deliberately coming at you from the side.
- **v1.50 (THE SEAL, a job too big for one raid):** Nothing in this game ever gave a reason to go back to a particular map except that it was that map's turn. Every raid started the same way and ended the same way, and the ground you were on was a backdrop rather than a place with a history.
  - **One heavy door per map, in the same place every time, that takes far longer to cut than a single raid allows.** Progress is per map and it persists: the dam remembers how far through it you got, and the only way to make progress is to come back to the dam.
  - **Two rules make it a decision rather than a chore.** Cutting is LOUD, the same howl the Strongbox makes, for as long as you stand there: every Listener on the map and most of a district knows exactly where you are and that you are not moving. And **progress only banks if you walk out**. Verified both ways: fifteen seconds of cutting followed by a death recorded exactly nothing and the summary said so, and fifteen seconds followed by an extraction banked and read back on the board.
  - **Finishing it resets it harder**, so the reason to return never runs out and each map keeps a ladder of its own. Verified end to end: tier 1 needs 40 seconds and paid a Bloom Sample, a Warden Core and a Sealed Codex worth 9,100 credits, then resealed at tier 2 needing 65.
  - It is drawn as a slab with the cut creeping up it, marked on the sector map with a progress ring, and the Undercroft carries a standing line per map so planning the trip back happens before you deploy rather than after you arrive.
  - **A defect worth naming, because the fix is the interesting part.** The first cut chose the door's position by testing candidate points against the built wall list, which looked right and was wrong: furniture and interior partitions are rolled fresh every raid, so a spot that was clear last time can be blocked this time and the door WALKS. Measured on COLD STORAGE, where it moved across four consecutive raids, which would have made the whole feature incoherent. The position now derives from the map DEFINITION only, which never changes. Verified: identical coordinates across six raids on all three maps, walkable and reachable from the drop on every one.
  - Also caught before it shipped: the placement helper was reading a variable that only exists inside the map builder, which would have been a dead build on the first deploy.
  - Sim 13 raids: 31 percent extract, 0 hangs, average haul 3,859, and the sim provably never touches a seal.
  - Browser parse substituted for `node --check`. **Not verified: whether 40 seconds is the right first bite.** It is about two thirds of a minute standing still and screaming in the most dangerous corner of the map, which sounds correct on paper. Whether it is a tense commitment or simply too long to hold is the thing to feel, and the tier curve after it is a guess on top of a guess.
- **v1.51 (guns wear out, and a favourite one becomes a running cost):** Guns already rolled a CONDITION when you found one in the field, and then it was frozen for that gun's life. Nothing you owned ever changed by being used, so the Marksman Rifle in the armoury was a permanently solved problem: you bought it once and stopped thinking about guns.
  - **Every round through a gun you OWN is counted, on the profile.** Four steps: CLEAN, then WORN at 420 rounds, FOULED at 950, FAILING at 1600. Measured on the Auto Rifle: spread widens from 0.070 to 0.078 to 0.091 to 0.105, reload stretches from 2,050ms to 2,870, and a fouled gun starts to JAM.
  - **A jam is the felt consequence.** The trigger does nothing, the round is gone, the gun needs cycling, and you find out mid fight. Rolled per trigger pull: measured over 600 pulls on a FAILING rifle, 35 jams against 565 rounds out, a 5.8 percent rate against the authored 6. **A CLEAN gun jammed 0 times in 400 pulls**, so a maintained weapon never does this.
  - **The equipped gun is a COPY with its wear baked in**, which matters more than it sounds: mutating the shared weapon table would have made every Auto Rifle in the game worse, including the ones raiders carry and the ones lying in crates. Verified, the base table is untouched after a Failing rifle deploys.
  - **Loaners and field pickups do not wear your armoury.** Issued kit is somebody else's problem and a field gun already rolled its own condition when you found it. Verified: 200 trigger pulls on an issued Ferro left the wear ledger byte identical.
  - **Merrit services them.** The workshop now leads with a REPAIRS section listing only guns that have wear on them, worst first, priced by how good the gun is and how far gone it is, and needing a part as well as money: a Component Kit up to FOULED, a Servo Actuator beyond it, two of them at FAILING. A 1,200 round Auto Rifle costs 2,214 credits and a Servo. Verified through the real buttons: serviced to zero, spent exactly what it said, and refuses correctly with the right reason when you are short of either money or parts.
  - Readable in three places: the armoury lists each gun's state and round count, the raid HUD carries the wear word above the weapon name, and a jam prints JAMMED where the ammo count goes.
  - Sim 13 raids: 62 percent extract, 0 hangs, average haul 2,604, and the sim provably adds no wear to his ledger.
  - Browser parse substituted for `node --check`. **Not verified: whether 420 rounds is the right first step.** That is roughly two or three busy raids with an automatic weapon and considerably longer with the Marksman Rifle, which feels right for "your favourite gun needs looking after" and could easily be too fast if he plays aggressively. The jam rate is the other one to watch: 6 percent at FAILING is one in seventeen trigger pulls, which is meant to be alarming rather than unusable.
- **v1.52 (DAM BATTLEGROUNDS rebuilt, and a landmark test that caught three old faults):** His note was that the dam should be redone. He is right that it was the weak map, and the measurement says so plainly: **only 10.4 percent of its walkable ground sat inside a named place**, against 47.6 on BURIED CITY and 39.9 on COLD STORAGE. It had the longest sight lines in the game at a mean of 675 with 41.8 percent of views running past 700 units, and the least interior of the three. It was three widely spaced things with a field between them.
  - **He asked for it to mimic another game's map and I have not done that**, because the spec he wrote for this project says map designs are to come from my own judgement and forbids sourcing or importing another game's geometry. So this is a rebuild, not a copy, worked from what a dam actually is as a place to fight in.
  - **The shape: a hard vertical stack of three worlds that only meet at a few points.** The RESERVOIR on top with a DROWNED VILLAGE standing in it, THE CREST across the middle, and everything below the wall. Nine named zones against six, and seven landmarks against three: POWERHOUSE, TURBINE HALL, SWITCHYARD, CONTRACTOR CAMP, DROWNED VILLAGE, THE TAILRACE and THE CREST.
  - **The crest is the one deliberately exposed place.** Parapets on both sides make it a corridor rather than a field, and the gaps through them are STAGGERED, so getting from the reservoir side to the downstream side means walking it in the open for a while. Two gate towers overlook the crossings. The POWERHOUSE spans a break in both parapets, which makes walking through the building the only sheltered way over the dam.
  - Everything else is built to contrast with that: the TURBINE HALL is four connected halls with four different interiors, the SWITCHYARD is a transformer maze with no straight run through it, the SPILLWAY is a concrete canyon that splits the lower map with one crossing on each side, the OUTFLOW YARD is parallel walled lanes you commit to, and the CONTRACTOR CAMP is a tight prefab cluster.
  - **The result, measured against the map it replaced:** named ground **10.4 to 35.4 percent**, mean sight line **675 to 492** which is now the second tightest in the game, and long views past 700 units **41.8 to 25.8 percent**. Interior coverage is unchanged at 12.5 percent and is still the lowest of the three, which is the one target I did not hit.
  - **Three defects of my own, all found by probing rather than by looking.** The gate towers and the powerhouse each sat exactly in a parapet gap, so every opening onto the reservoir was corked and **the entire top of the map was sealed**, 1,560 unreachable cells. The catwalk overlapped both turbine hall rows and cut their interiors, which is the identical fault the dam catwalk had at v1.0x and which its own comment warns about; measured as pockets of 504 and 506 cells appearing and vanishing with the furniture roll. And one spawn stood on a parapet with two extraction markers inside geometry. Reachability is now **99.5 percent worst case over six runs**, both decks fully reachable, and all six spawns and all three extractions clear on every run.
  - **A new check that earned its keep immediately.** Testing landmark rectangles for overlap flagged two on the rebuilt dam and then **two old faults on BURIED CITY** that I had noted at v1.34 and left alone: its courtyard landmark ran 240 units into the south garages, and two of its three extraction markers sat inside geometry. The rings were reachable so both worked, which is why I let them stand; a beacon drawn inside a wall is still a defect and now I have the test that proves it. Fixed. All three maps report zero landmark overlaps and three of three clear extractions.
  - Sim 11 raids on the rebuilt dam: 36 percent extract, 0 hangs, average haul 6,648, mean first contact 60 seconds.
  - Browser parse substituted for `node --check`. **Not verified: whether it plays better.** Every number says it is denser, tighter and more named than what it replaced. Whether the crest reads as a place you dread crossing, and whether the turbine hall is worth going into, are the two things to feel.



















- **v1.53 (the world stopped looking empty, and the beacon says what it means):** Two notes from him, 2026-08-22. The first was a bug: **"pushing the thing to start extraction process isn't working"**. The second was a look: **birds, deer, broken down cars, furniture and countertops and kitchens, and buildings that are completely destroyed and cannot be entered.**
  - **The beacon bug was FOUR bugs, and the biggest one was that the game never told him anything.** Calling extraction takes **1.6 seconds of HELD E**, and nothing on screen said so: no prompt, no bar, no sound. A crate gets a labelled `[E] SEARCH` prompt and a filling progress bar; the way out of the raid had neither, so a tap on E was indistinguishable from a dead button. **It now has the same prompt and the same bar**, in the extraction colour, and it reads `[E] CALL EXTRACTION`, then `INBOUND 25s`, then `[E] BOARD - 30s`, or `EXTRACTION CLOSED` in red.
  - **Second: a crate underfoot silently ate the keypress.** E is overloaded, and a container within 46 units won the press outright, so the beacon call never ran at all. **Measured: 3 containers sat inside extraction rings on the dam and 2 on Cold Storage, every single raid.** Standing on those points, E could never call, ever. Two fixes, because either alone leaves a hole: standing inside a ring the BEACON now owns E, and nothing is allowed to lie on a pad in the first place. A sweep runs after every placement path, so buildings, landmarks, open ground, caches, the strongbox and body drops are all covered by one rule, and loot is pushed clear rather than deleted. **Now 0 of 240 on the dam, 0 of 183 on the city, 0 of 155 on Cold Storage, over four builds each.**
  - **Third: a CLOSED point was completely silent.** No message, no sound, no refusal. It now says `This point is CLOSED. The open one is 2560m away, marked on your map.` with the real distance, and clanks.
  - **Fourth: all three places that draw a zone coloured it by `G.active`**, which is the last zone you walked into, not by whether it is open. A closed point painted itself teal and captioned itself EXTRACTION: it looked exactly like a working one. Every ring, label and map dot is now keyed on the zone's own `open` flag and reads OPEN or CLOSED. Also, an abandoned pull now decays instead of banking, so walking off at 1.5 seconds and returning a minute later no longer calls the ship instantly.
  - **Furniture went from 2 kinds to 7.** Tables and shelving were all there ever was. Now: counters and kitchen units that HUG an interior wall the way real ones do, with a stove ring drawn on the units, plus beds, sofas and locker banks. Three to six pieces per building instead of two, so a room reads as a room somebody left.
  - **Wrecked vehicles, roughly 120 on the dam and 82 on Cold Storage.** Rusted, dented, one wheel always flat, a different body colour and a different missing panel on each. They are real walls, so a car is cover you can actually use in the open, which is where breaking contact was hardest.
  - **Ruins: whole buildings that fell in.** Solid blocks with no shell, no door and no interior, because that is what makes them read as destroyed rather than as a building the generator forgot to open. Broken silhouette, standing wall stubs with blown out windows, rubble spilling across the footprint, exposed rebar along the break line. Fourteen to thirty five per map. Walking around one is a real detour.
  - **Birds and deer.** Flocks peck, herds graze, and both of them run: birds go up at 190 units and deer bolt at 300, from you, from raiders, or from a round going past within 260. They are non hostile, they are not counted as kills, and they never enter the sim. They also carry information, which is the part worth watching for: **a flock going up two hundred metres away means something over there moved.** A deer at the edge of the fog looks enough like a person to make you stop.
  - **A prop connectivity guard, because litter can seal a map.** A car 50 units wide dropped in a 70 unit doorway is a wall. Measured before the guard: the dam lost 1,297 cells behind the switchyard, and it moved every raid because the props roll every raid. The build now floods the finished grid and pulls out any wreck or ruin touching ground you cannot reach; authored geometry is never cut. **Verified over 8 dam builds that props now contribute exactly ZERO unreachable cells, with and without them stripped.**
  - **Four authored faults the new tests found, all older than this build.** Every SWITCHYARD control house sat in a 10 to 15 unit gap against a transformer row, walling off slivers of ground you could see and never walk on. The OUTFLOW shed sat flush against the substation's south wall so the two buildings' doors opened into each other and BOTH interiors were sealed, 641 cells. And one shed hugged the east map edge, so its east door opened onto a strip one nav cell wide. Fixed by moving geometry, not by cutting it.
  - **Reachability now: BURIED CITY and COLD STORAGE 100.00 percent over four builds each, a first for both.** The dam is 99.32 percent worst case over six, and the residual is **provably not mine**: eight dam builds measured with and without every prop stripped returned identical loss both ways, 48 to 516 cells of authored interior. That is the one number that did not reach where I wanted it.
  - Frame cost with all of it on screen: 1.55ms on the dam at 580 walls, 71 animals and 60 raiders.
  - Browser parse and a drawn frame substituted for `node --check`. **Not verified: whether it is too much.** 120 cars and 16 ruins on one map is a lot of stuff, and the risk is that the open ground stops reading as open. Watch whether the dam crest and the outflow lanes still feel exposed.

- **v1.54 (THE QUARRY, and elevation that finally means something):** The roadmap item that had been sitting at NOW since v1.52 was a fourth map built around verticality. The reason it sat there is that the elevation system could not express one: every platform in the game was a catwalk, every catwalk was at the same height, and two engine faults meant nothing else was possible.
  - **Fault one: a height difference between two touching decks was not a cliff.** The rule that opens the shared edge between adjacent platforms was written when every deck was the same height, and it opened that edge regardless. Two terraces 33 units apart had no wall between them and you walked off the drop with a visual pop. Same height still opens, because that genuinely is one surface.
  - **Fault two: a ramp interpolated from ZERO to the height of the one deck it found**, so a ramp BETWEEN two terraces dived to the ground and climbed back out. It now spans the two heights it actually connects and works out which end is which from where the decks sit along its long axis.
  - **And a third fault I introduced fixing the second one, caught by measuring rather than looking.** The three older maps author their ramps ABUTTING a platform rather than overlapping it, and the wall-cutting pass has always used a 24 unit tolerance for exactly that reason. My new lift code used a strict test, found nothing, and returned flat ground: **every catwalk ramp on BURIED CITY and COLD STORAGE went 0 to 0** and you stepped onto a deck with a 26 unit pop instead of walking up. Now padded to match. Verified across all four maps: dam 0>26, 26>0, 1>48, 47>1; city 24>0, 24>0; storage 0>26, 26>0.
  - **THE QUARRY: a stepped open pit, five terraces, 132 units from the rim to the pit floor.** The benches are the only ground there is and the only way between them is eight haul ramps cut into the cliff faces, two per drop, staggered from one drop to the next so getting down means crossing each bench end to end in the open. Measured lift ladder: **132, 99, 66, 33, 0**, with every ramp sloping cleanly between its two decks.
  - **The deal the map makes is the point of it.** The crusher pays best and it is at the bottom of the hole; two of the three ways out are at the top. Nine named zones, eight landmarks, a conveyor gallery that is the longest enclosed corridor in the game, and a sump you have to wade.
  - **One hard rule runs through every coordinate: nothing comes within 90 units of anything else.** A building's doors are rolled onto one or two of its four walls, so a shed with 46 units of clearance on its north side seals itself the moment the roll puts its only door there. The first draft did not have this rule and the screening plant took 145 cells of its own interior with it: the conveyor bench came in at **84 percent reachable**. With the rule: **100 percent on three of four benches, 99 on the fourth**, and all four decks fully reachable.
  - The magazine's locked room was the same fault one level down: 220 units tall inside a 258 unit interior, leaving 10 above and 28 below, both sealed. Shortened and made flush with the building's own north face so there is one gap to keep clear instead of two.
  - Reachability: **BURIED CITY and COLD STORAGE 100.00 percent**, THE QUARRY 99.22 worst case over four builds, DAM BATTLEGROUNDS 99.15. All spawns and all extractions clear on every map, every build.
  - Browser parse and a drawn frame on all four maps substituted for `node --check`. **Not verified: whether the descent reads as a descent.** The lift ladder is right in the numbers, but whether standing on the rim and looking down four terraces actually feels like looking into a pit is the thing to judge in the chair. Watch also whether the benches feel like corridors rather than fields, because that is what they are meant to be.

- **v1.55 (a crash in his own runs, and eight things he asked for):** His flight recorder came back with `DRAWERR:crawler` in two separate runs and a list of complaints, and one of those complaints turned out to be a bug I had shipped rather than a matter of taste.
  - **THE CRASH, and it was worse than it looked.** A dangling `else` in the entity draw: the raider draw was written as the else of the weak point test, so every kind WITHOUT weak points fell into it. Crawler, snitch, listener, peddler and stray all ran the raider path and threw on `e2.bag.length`, because only a raider carries a bag. The missing nameplate was the small half. The throw also skipped the `wc.restore()` that pairs with the deck lift, so **on any map with platforms every entity drawn after the first crawler slid upward by that deck's height for the rest of the frame**, and on THE QUARRY, where the top terrace lifts 132, that is the whole world jumping. Reproduced on the first frame; now zero faults across four maps with every entity kind crowded on camera for 60 frames each. The armoured loop also puts the transform back after any future fault, so it can never slide the world again.
  - **"changing weapons is all messed up, especially the first 2."** Reproduced from the code exactly, and it was a genuinely broken state machine. Slot two was implemented by firing the X swap, which trades the two guns, so the gun you asked for landed in slot ONE while the highlight sat on slot TWO: the label named one gun and your hands held the other. Pressing 2 again hit an "already selected" early return and did nothing at all, and pressing 1 hit an **empty branch** that also did nothing, so once you touched slot two **you could not get your primary back for the rest of the raid**. The slots are fixed now: slot one is always the gun you deployed with, slot two is always the other one, and the highlight follows the gun even when you use X. Verified through the real key handler: 1, 2, 2, 1, X, 1 all land on the right gun with the right slot lit.
  - **"Text still looks like absolute shit, some of it wayy too bold, some way too skinny."** He is right and the cause was a bug, not taste. The canvas mixed THREE families and FOURTEEN authored sizes, but the font helper clamps anything under 13px up to exactly 13px, so **8, 8.5, 9, 9.5, 10, 11 and 12px all rendered at the same size**. The hierarchy was entirely gone and the only thing left distinguishing one label from another was a randomly applied bold and a randomly chosen family. One family now (Rubik, with the display face kept only for the game's own logo), five sizes, two weights, and all **85 canvas font calls swept onto named roles**. The smallest size is set so it lands on exactly 13 rendered pixels, which is precisely where the old small text already sat, so nothing overflows.
  - **"i can see animals through fog of war and shouldn't be able to."** Correct, and worse than cosmetic: a deer bolting behind a building told you something had moved there, which is the exact tell the animals exist to give you only when you can SEE them. Gated on the same line of sight test the machines use. **The same fault applied to sentry scan cones**, which walked the full entity list rather than the seen list, so every machine on the map painted its cone through solid walls: free intelligence, every raid.
  - **"there are still random lights in the sky w no fixtures OUTSIDE."** Second time he has raised this. The generator dropped 28 glows per unit area at any free spot with nothing making the light. At v1.53 I drew a HUNG lamp over each, which fixed the indoor ones and made the outdoor ones worse, because a lamp hanging from nothing in a field is stranger than an unexplained glow. Outdoor lights are **lamp posts** now: fewer, standing on a real pole, and placed only within 150 units of a wall so there is something to bolt a bracket to. And **the lamps are off at morning and noon**, because he is right that a street lamp burning at midday is not atmosphere.
  - **"Buildings are built OVERTOP a road."** The road grid is inherited from the procedural generator, where buildings were placed INTO the cells the grid defined so a road could never run under one. The maps are hand authored now and nothing ever told the roads. Roads are laid in short runs and any run meeting a building, a cliff face or a collapsed block is not laid, so a road stops at a wall and picks up on the far side.
  - **"when you are out of ammo, the mouse cursour should indicate same."** The reticle never changed for anything: empty, reloading and jammed all drew the same white cross. It now turns amber and reads EMPTY - R, or red for NO AMMO and JAMMED, and a reload draws as a ring closing on the cursor. Your eyes are on the cursor in a firefight, not on the ammo counter.
  - **"too many animals, and deer are stuck in a small area which makes them spastic."** Counts roughly halved, 65 animals on the dam down to 29. The spastic deer were three faults in one block: it REVERSED velocity on a wall hit, which sends the animal back at whatever frightened it; it nudged the body by one frame of that velocity, not enough to clear a wall it was already inside, so it re-collided and re-reversed every frame; and a panicking animal never gave up, so the loop had no exit. It now separates out along the shallower axis, slides along the face, gives up after three hits, and a deer that has run somewhere else now LIVES there instead of walking straight back past the thing it fled.
  - Sim 16 raids: 75 percent extract, 0 hangs, average haul 4,241, median first contact 71 seconds.
  - **His five most recent runs are not usable as balance data.** Every one of them carries the crawler DRAWERR, which means the deck lift transform was leaking on every raid he played: four of the five died inside 90 seconds having barely moved, and the renderer was corrupt while it happened. Those numbers measure the bug, not the difficulty.
  - Browser parse and drawn frames on all four maps substituted for `node --check`. **Not verified: whether the new type scale reads better in the chair.** The measurements say the hierarchy exists now where it did not before, but bold versus regular at 13 rendered pixels is a judgement he has to make on screen.
- **v1.56 (the raids are seeded now, so two builds can finally be compared honestly):** No new content in this one. It buys the thing every future tuning decision depends on, fixes a bug that had quietly switched off half of THE TERMS, and closes two ways the browser could break the game with nothing in the console.
  - **Every gameplay roll is seeded.** 31 call sites moved off `Math.random()` onto a mulberry32 stream seeded once per raid in `buildRaid`. A raid is now a pure function of its seed: `srand(s)` sets it, `G.seed` records it, and the seed is written into both the sim result and the flight-recorder run line, so any run in the data can be rebuilt exactly. Verified by running seed 12345 twice, 777 twice and 424242 twice and requiring byte-identical results down to the per-kind kill counts. They matched, and different seeds produced different raids.
  - **What is deliberately NOT seeded, and why.** Audio buffer noise is generated once at audio init and never runs headless. Two cosmetic rolls, the crawler dust puff and the lightning flash, are render-layer and already fenced off from the sim. A draw that the played game takes and the sim never does would put the two out of step for the same seed, so the rule is that the seeded stream is exactly what the sim runs, and nothing else.
  - **Why this was the top open item, in numbers.** Extract rate is a binomial proportion and the sim is noisier than nearly any change worth making. Two IDENTICAL builds run 30 raids against 30 show a five point gap 68.5 percent of the time and a ten point gap 49.8 percent of the time. Every unpaired sim comparison this project has ever made was close to a coin flip, and at least one was acted on. Running the SAME seeds through both builds and taking the sign of the paired difference is right about 79 percent of the time at 30 seeds, 95 percent at 100 and 99 percent at 200. That is a fifth of the raids for a better answer. `__simSeeds(seedList)` returns one row per seed, so a flip can be named and gone and looked at rather than just counted.
  - **THE TERMS never paid its multiplier on season progress.** `var tPay=termsPay()` sat about thirty lines BELOW the season block that consumes it, so `tPay` was hoisted-undefined at the point of use and `spForRun` took `termPay:undefined` and fell through to `||0`. Signing for a 35 percent hazard load has therefore always paid the credit bonus and exactly nothing on the long track. The declaration moved above its first use. Worth flagging because it is invisible: nothing errors, nothing looks wrong, the number is just quietly smaller than it should be.
  - **Survival by value carried, and the confound that nearly made it lie.** A low extract rate is three different problems wearing one number: difficulty (deaths spread evenly across every loot value), legibility (deaths clustered on a route or a piece of geometry) and economy (deaths clustered on the runs that were actually worth something). Splitting outcome by value carried separates difficulty from economy directly, and the value was already recorded on death, it just had nobody reading it. Both the bot sim and the flight recorder now print the split. **The first run of it read INVERTED, and that was my metric being wrong, not the game.** Value carried and time survived are not independent: you accumulate loot BY surviving, so a run that ended at 40 seconds is empty because it was short, not short because it was empty. Read naively the low bands fill with early deaths and the curve comes out backwards even where greed IS being punished. The analysis now controls for it by comparing only runs that lasted 150 seconds, where what you are carrying is a choice you made, and it prints the uncontrolled slope alongside with a note saying not to read it. Validated against a synthetic set built so the two disagree: uncontrolled +21 points, controlled +71, and the controlled figure is the true one by construction.
  - **Two silent browser failures closed.** There was no `visibilitychange` handler, so returning to the tab after two minutes away simulated a full clamped 50ms frame of machines moving and the raid clock running while nobody was looking. `lastTs` is restamped on return and on focus, so the first frame back is worth about one frame. There was also no canvas context-loss handler: a GPU memory event, a driver reset or a laptop waking from sleep blanks the canvas permanently with nothing in the console. The frame is now skipped entirely while the context is gone, so the raid clock does not run down behind a blank screen, and on restore the two baked ground layers are dropped and rebuilt. `hubGround` rebuilds lazily on next use; `G.ground` is drawn unguarded, so it is rebuilt rather than nulled, which would have traded a blank canvas for a throw.
  - **Sim, 60 seeds on the four maps: 55 percent extract (33 out, 27 died), average haul 4,018c on extraction and 3,243c carried at death, average raid 135 seconds, deaths 14 sentry / 10 crawler / 3 raider, no timer expiries and no hangs.** Only 16 of 60 runs reached 150 seconds, which is itself the finding worth watching: the bot is dying in the first half of the raid, so most of these runs never get to the part where greed is a decision. This is the new baseline and it is a seeded one, so v1.57 can be run against these exact 60 seeds rather than against 60 fresh ones.
  - **Harness note that cost forty minutes.** A long batch has to be chunked, and chaining the chunks with `setTimeout` is throttled to roughly one callback per minute in a hidden pane: 36 raids took twelve minutes that way, then 24 more took under three after switching to `MessageChannel`, which Chrome does not throttle. Fronting the tab is not a reliable fix. The pattern is written into `tools/mkfixture.ps1` next to the hook that needs it.
  - Browser parse, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames, substituted for `node --check`, which cannot run here. The recorder was driven with an empty log and a populated one to prove the new block does not throw. **Not verified: anything about feel.** Nothing in this build is supposed to change how a raid plays, and the seeded stream is a different sequence of numbers from the old one, so if a raid feels different from v1.55 that is the seed change and worth telling me about. Also unverifiable here: the context-loss recovery, which needs a real GPU reset, and the tab-return fix, which needs a human alt-tabbing mid-raid.

- **v1.57 (the machines cost 17 times what they should, and his oldest complaint was a performance bug):** His standing note is **"not enough enemies, boring, looting"**, and it had never been acted on because raising the counts was assumed to be expensive. Nobody had measured it. Measured at 60 entities on the dam: the entire renderer cost 1.15ms a frame and the HUD 0.26ms, while the simulation cost 6.62ms, of which `updateEnts` alone was 6.34ms. The thing standing between him and more machines was never the drawing.
  - **Correction to the v1.56 entry.** It reports "60 seeds on the four maps". That is wrong: it was 60 seeds on THE QUARRY alone, because the four-map render check that ran before it left the profile pointing at map 3. The correct comparison is that THE QUARRY extracts at 55 percent and DAM BATTLEGROUNDS at 43 percent on the same 60 seeds, which is a real and useful difference and not something I should have reported as an average.
  - **First find: rays were 99.6 percent waste.** `rayHit` was a linear scan over every wall segment on the map, and the dam has 2,464. Measured how many can actually block a given ray: **a 500 unit sight line needs 11 of the 2,464, and a 200 unit one, which is most of what the AI asks for, needs 1.** A uniform grid at 160 units fixes it, and segments never move, so each is filed once into every cell its bounding box touches at map build. Result: `losClear` went from 10.75us to 0.58us at 500 units, **18.7x**, and from 10.52us to 0.23us at 200 units, **46.8x**.
  - **And it barely moved the frame, which is how the real fault was found.** `updateEnts` went 6.34ms to 6.06ms. Four percent. So line of sight was not the cost, and the honest thing was to keep measuring rather than ship the number that looked good. Bisecting `updateEnts` by entity kind gave sentry 116us, crawler 119us, snitch 111us, raider 108us, warden 100us: near identical costs for five completely different behaviours. That can only be shared per body code.
  - **Second find, and the actual answer: `collide`.** It tested all 606 walls on the dam for every body every frame, at 37.8us a call, and a body of radius 11 had **zero** walls within 40 units of it. The same grid treatment applies because walls do not move either. `collide` went from 38.3us to 0.5us, **85x**. `updateEnts` went from 6.34ms to **0.37ms**, and the whole simulation step from 6.62ms to **0.44ms**, a 15x cut. Total frame at 60 entities went from 8.03ms to 2.12ms, and for the first time the renderer is the largest single item in it.
  - **What that buys, which is the point of the whole exercise.** Scaling the entity count on the dam and measuring: 60 entities 1.61ms, 120 entities 2.23ms, 180 entities 2.41ms, 240 entities 2.55ms. **Four times the machines now costs less than a third of what sixty cost this morning.** Whatever "not enough enemies" turns out to want, the frame is no longer the thing saying no. The counts are deliberately NOT raised in this build: that is a balance change and it gets its own paired test rather than riding along with an infrastructure one.
  - **Why the wall index needed more care than the segment index.** `collide` MUTATES the body as it iterates, so a later wall sees the position after an earlier push and the resolution order matters. The query therefore sorts its result back into original wall order. It also means the query box has to cover where the body might END UP, not just where it started; a push places a body exactly r from a surface, so the pad is 96 units against a body radius of 11, several times the worst case. That is an argument rather than a proof, which is why the empirical check below exists.
  - **Proof of equivalence, which is what v1.56 was built to make possible.** The same 60 seeds were run through the committed v1.56 and through this build, comparing outcome, haul, duration, killer, containers and per-kind kill counts for every seed. **All 60 matched exactly, identical MD5 over the whole result set.** Both indexes return a SUPERSET of what the linear scan would have tested, so nothing that could change an answer is ever excluded, and the seeded harness turns that from a claim into a measurement. Two arms of 60 raids each is the first genuine A/B this project has run; it would have been meaningless a build ago.
  - **Second thing the harness proved.** Seeds are order independent: running seeds [A,B] and then [B,A] gives each seed the same raid either way, and a whole pass repeats exactly. So nothing leaks between raids in the sim, and a seed list can be run in any order or in any chunk size.
  - Browser parse, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames, substituted for `node --check`, which cannot run here. Both grids build on all four maps. **Not verified: feel, and it should be identical.** This build is proven to produce the same raids from the same seeds, so nothing about difficulty or behaviour changed. What a human might notice is smoothness, on a machine where the old 8ms frame was close to the limit. Also unverified: the hub, which keeps its own wall list and is deliberately left on the linear path, so it is unchanged rather than tested.

- **v1.58 (three things he asked for, and the risk pillar turns out not to be implemented):** His recorder arrived with 14 real runs on it. Most of the notes in it had already been answered in v1.53 to v1.55, and I checked each against the current code rather than assuming: the enemy scan cones already respect line of sight, the thirty second boarding window already exists, reinforcements already trickle in. Three were genuinely still live, and two of those come from run #14, which is his most recent.
  - **"raiders should drop better loot".** He is right and it was indefensible. A raider is the most dangerous thing on the map, he tagged the one fight he had as **"raider battle felt really good"**, and the reward was one to three rolls on `LOOT.crate`: the junk table, 32 percent scrap and 22 percent wire, the same table a wooden box in a corridor rolls on. Killing a person was worth less than opening a crate, because a crate at least rolls more times. A raider is an operator who has been out here looting exactly like you have, so the bag now reads like a player bag, and their RIG scales it, because the rig is the tell you can already see before you commit. Two to four rolls plus one per armour tier, on body and locker tier for most of them and on safe tier for the ones in medium or heavy plate. Taking on the one in heavy armour is now a decision with a visible upside instead of a worse version of the same fight.
  - **"lockers should only be up against the walls."** `spotIn` returns any legal spot inside a room, uniformly distributed, so most containers floated in open floor in the middle of rooms. Nobody puts a locker in the middle of a room. It also made searching mechanical: you swept the middle and never had a reason to look along an edge. `spotWall` keeps the identical legality test, so nothing can land inside geometry, and simply samples more and keeps the legal candidate closest to a wall. Measured after: median distance from a container to the nearest wall is 30 units on all four maps, and 70 to 84 percent of containers sit within 45 units of one. The second half of that note, "where is the furniture?", is not done and is not forgotten.
  - **"snitch too easy to kill".** It was, and the reason was not that it was fragile. It fled in a dead straight line at constant speed, and a target like that is trivially led at any range: you do not aim at it, you aim where it obviously will be. Making it a bullet sponge would have been the wrong fix, because a drone that soaks damage is not frightening, it is just slow. It now weaves, on a sine seeded per drone so a pair of them do not fly in formation, and it is genuinely hard to hit at range while staying killable up close where the weave is small in screen terms. Health went 26 to 38, deliberately a small change, only so that one lucky burst at range is not a guaranteed kill.
  - **Measured, 150 raids per arm on the dam, v1.57 against v1.58.** Extract rate **37 percent in both**, 56 of 150 each. Average haul on extraction **3,566c to 4,058c, up 14 percent**. Average haul carried at death unchanged at about 3,020c. Average raid length 134s to 148s, and runs reaching 150 seconds went from 48 to 67. So the reward went up by a seventh and the difficulty did not move, which is what this build was supposed to do.
  - **A limit of the paired harness, worth stating plainly.** v1.56 bought paired seeds, and they were decisive for v1.57 because that build was a pure refactor: same draws, same order, so the same seed produced the same raid. This build CHANGES how many numbers each raid draws, so from the first raider onward the two arms diverge completely and pairing buys nothing. That is why these are 150 unpaired raids per arm rather than 60 paired ones. **Pairing works for changes that do not alter the draw sequence, and for content changes it does not.** A future option, if this becomes a nuisance, is a separate stream for loot rolls so the main sequence stays stable.
  - **The finding neither of us was looking for: the risk pillar is not implemented.** The survival by value carried split, added in v1.56, now has enough runs to speak. Among the 67 raids that lasted past 150 seconds, where what you are carrying is a choice you made: **carrying 500 to 1500c gets out 33 percent of the time, 1500 to 3000c gets out 39 percent, and carrying over 3000c gets out 56 percent.** It goes the WRONG WAY, and it still goes the wrong way after controlling for how long the raid lasted, which was the confound built in to catch exactly this. Carrying a fortune is not more dangerous than carrying nothing. It is safer, because the runs where you accumulate a fortune are the runs that were going well. Pillar 1 of the design is risk versus greed, and mechanically there is currently no risk attached to greed at all. That is the likeliest single explanation for **"Extract too easy" x3** and it is the next thing worth designing rather than tuning.
  - **New: `tools/parsecheck.html`, and it caught this build being dead.** There is no JavaScript runtime on this machine, so `node --check` has never been runnable and the workflow has always gone straight to the fixture. My first attempt at this build had a duplicated `function spotIn` declaration, because an anchored insert included its own anchor line and left the original behind, which orphaned one opening brace. The parser blamed the last line of the 11,511 line file, which is the closing `})();` of the IIFE and points at nothing. The new page fetches a build, asks the browser's own parser to compile it WITHOUT running it, and independently reports brace, paren and bracket balance plus every duplicated top level function. Balance localises a fault that the parser message cannot. This is now the first check of every build, before the fixture.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames. **Not verified: whether the snitch is now annoying rather than tense.** The weave is tuned by eye and a drone that cannot be hit at all is worse than one that dies too fast, so that one is his call in the chair. Also not verified: whether containers against walls actually read better, as against simply being somewhere else.

- **v1.59 (greed costs something again, and the sim admits it cannot measure it):** v1.58 established that carrying a fortune was safer than carrying nothing. This build finds out why, fixes it, and then fails to prove the fix works, which is reported here rather than dressed up.
  - **The cause, and it was my own side effect.** His note on 2026-08-22 was **"make it where the backpack is unlimited and you can just take it all"**, so `PACKCAP` went to 99999. That was the right call and the cap is staying gone. But the only cost of weight anywhere in the file was computed as a FRACTION of that cap: `load=clamp(1-bagWeight()/(cap*1.15),.55,1)`. With the cap at infinity that expression is pinned at 1.0 forever. Removing the wall silently removed the cost as well, and pillar 1 of the design quietly stopped existing. Nothing announced it and nothing errored.
  - **The fix keeps his instruction exactly.** Nothing is refused, no pickup is blocked, there is no wall. Weight just COSTS, continuously and increasingly: the first 20wt is free because that is the kit you deploy with, and after that a bag makes you slower, louder and quicker to run out of breath. Measured off the real function: 30wt is 7 percent slower and 17 percent louder, 52wt is 21 and 53, 70wt is 33 and 83, and it floors at 38 percent slower with a bag over 100wt that is more than twice as loud as walking empty. Calibrated against the armour rigs, which are the game's existing scale for a whole-raid commitment: heavy plate costs 14 percent speed and 34 percent noise, and a serious haul should cost more than that because it is the same kind of bet made later with better information.
  - **A cost you cannot see is just the game feeling wrong.** The weight readout now says what the weight is DOING, in plain terms: `31 ITEMS 52wt 21% SLOWER 53% LOUDER`, in amber once it bites and rust once it is dangerous. The moment to think about leaving is on the HUD instead of being something you work out after dying with a full bag.
  - **The sim bot has never played the way he plays, and that is its own finding.** `simGreed` was 26, meaning the bot turned for the exit at 26wt. His own runs come home with 19 to 30 items. So every balance number this project has ever produced described a far more cautious player than the one holding the mouse, and any change to the cost of carrying would have been invisible in it by construction. Default raised to 52 and the slider ceiling from 60 to 140. `cfgv` bumped to 8 so a saved profile actually receives it, the same migration the v0.68 and v1.03 tuning batches used. Credits, stash, armoury and the recorder are untouched.
  - **What the greedy bot proved, 150 raids per arm on the dam.** At greed 26 it extracted 37 percent of the time with an average haul of 4,058c. At greed 52, on the identical v1.58 build, it extracted **35 percent** with an average haul of **7,179c**. Doubling your haul cost two points of survival. That is the pillar being absent, stated as a measurement rather than as an argument.
  - **And then the fix did not move it.** With the carry cost in: 35 percent. With the carry cost DOUBLED after that result: 35 percent again. **Fifty two of 150 in all three arms.** The bot's extract rate is completely insensitive to how loaded it is. The reason is visible in the rest of the numbers: raids average 228 to 239 seconds against a 600 second clock, so there is enormous slack and being a fifth slower never runs the bot out of time, exactly one raid in 150 ended on the timer. The bot also has no judgement to change: its exit rule is a fixed weight threshold, so it cannot decide that the trip out has become too dangerous. **A sim bot with no greed decision cannot measure a greed mechanic.** Reporting the doubled cost as a success because the design argument is sound would have been the easy thing and it would have been false.
  - **So this ships as a mechanism, not as a proven balance change, and the strength is his to set.** New `loadPen` slider on the tuning panel, 0 to 2. At 0 it is provably neutral, restoring v1.58 behaviour exactly. At 1, the shipped default, a 52wt bag is 21 percent slower. At 2, a 60wt bag is 38 percent slower. If a loaded run feels like wading, that is the one number to turn down, and it needs no help from me.
  - **Bands rewidened.** The old top band was 3000c and up, which swallowed 128 of 150 runs once the bot looted properly, so the split had no resolution left where the decisions are. Now five bands to 12,000c and above. On the doubled arm they read 3,000 to 6,000c at 46 percent out, 6,000 to 12,000c at 42, and over 12,000c at 42: much flatter than before, and still not a risk curve.
  - **What would actually implement the pillar, for the next tick.** Speed and noise are indirect: they make you easier to find, and the sim says finding you is not what kills you. The direct versions are that the trip out should scale with what you are holding, not with where you are: extraction announcing itself louder the richer you are, machines that prefer a loaded target, or the beacon siege scaling with bag value the way it already scales with time. That is a design job with a measurable hypothesis, and it is the top item.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames. The load curve and the `loadPen` slider are read off the real function through a new `__load` hook rather than off my arithmetic. **Not verified, and this is the one that matters: whether a heavy bag now feels like a decision or like a punishment.** The sim is structurally unable to answer it, I have said why, and it is entirely his call in the chair. If it is wrong, `loadPen` is the dial and 0 puts it back.

- **v1.60 (the extraction siege scales with the bag, and then a measurement explains why none of this worked):** v1.59 ended by naming the next step: speed and noise are indirect, so make the trip out scale directly with what you are holding. This build does that, measures it, finds it does almost nothing, and then finally measures the right thing.
  - **The mechanism, and it is good design regardless of what the numbers say.** Calling the dropship is the one moment in a raid you choose deliberately, knowing exactly what is in your bag, which makes it the honest place to charge for greed. The siege now scales with bag VALUE, read once at the moment of the call so it is a decision with a known price rather than a moving target, and so that dumping loot mid siege cannot quietly call the machines off. Walk to the ring with 500c and it is close to what it always was: six arrivals, one every eight seconds. Call it holding 12,000c and it is a siege: fourteen arrivals, one every 3.4 seconds. The call ping and the recurring convergence ping scale with the same number, so the noise and the arrivals tell one story, and the game says so out loud before the wait starts: **"They heard THAT. You are carrying too much to be quiet about it."** A price you only discover afterwards is an ambush, not a decision.
  - **Measured, 150 raids: 34 percent extract against 35.** One point. That is now THREE mechanisms in a row aimed at the trip out, across roughly 600 simulated raids, that have moved the extract rate by a point or less: carry weight on speed, carry weight on noise, and now the siege scaling with value.
  - **So I stopped guessing and measured where raids actually end.** 100 raids, 60 deaths: **33 of them, fifty five percent, happened before the beacon was ever called.** Only 22 died during the siege. Deaths spread right across the clock, peaking at 120 to 300 seconds, which is the deep looting window. More than half of all deaths happen before the player has reached the decision to leave at all. Every mechanism I built makes the last third of deaths scale with greed, and every one of them is invisible in a number dominated by the first half. All three failures have one explanation and I should have looked for it two builds ago instead of building the second and third fix.
  - **It also condemns the metric I added in v1.56 and have been steering by since.** Extract rate against value carried CANNOT show a risk curve while most deaths are "died while still looting", because the light bands fill with runs that never got rich rather than runs that chose to stay light. It reported INVERTED for four builds and that reading was actively misleading: it pointed me at three fixes in a row that could not possibly have worked. The v1.56 entry describes controlling for survival TIME, which was a real confound and a real fix, but it was not the only one and I treated it as if it were.
  - **The analysis now leads with the phase split and refuses to draw a curve it cannot support.** Both the bot sim and his flight recorder now print where deaths land: before ever calling the dropship, after calling but not in the ring, and during the siege. If 45 percent or more land in the first bucket it says so in as many words and stops, rather than printing a slope that means nothing. `diedInSiege`, `callGreed` and `timeOfDeath` are in the sim result now so this is checkable rather than asserted.
  - **What this actually means for the design, and it is not what I expected.** The game is not failing to punish greed. It is punishing TIME SPENT, which is a real and defensible expression of the pillar: deaths peak in the deep looting window, so pushing further into a raid is what kills you, not walking out heavy. The question that is now open, and it is a design question for him rather than a tuning one, is whether that is the game he wants. Punishing time makes the decision "how long do I stay". Punishing value makes it "how much do I take". Those are different games and the current one is the former while the documents describe the latter.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames. The new analysis was validated against a synthetic set built to the real 33 / 5 / 22 shape, and correctly refuses the curve. **Not verified: whether a rich extraction now feels like the raid turning against you.** Fourteen machines converging on a ring you have to stand in for 25 seconds is a big change in the chair and the sim cannot tell me whether it is thrilling or simply unsurvivable. If it is too much, it scales entirely off bag value, so a lighter run is a quieter one by construction.

- **v1.61 (a container is a decision now, not a hold):** His oldest and least-answered note, from run #1: **"looting feels so uninspired, how can we make it more interesting???"** It went unanswered for a long time because it reads as a request for more content, and it is not. It is a request for a decision. There was none: you walked to a box, held a key for between one and nine seconds, and received a lump of items. That happened about twenty one times a raid and every one of them was identical.
  - **Items now come out one at a time as the bar fills, worst first, best last.** Breaking off early keeps everything you have already pulled and leaves the rest in the box. Progress already persisted as of v1.53, so you can come back for it. Measured on a locker holding 60c, 70c and 310c: at 40 percent of the bar you have the 60, at 80 percent you have 130c of it, and the 310c only arrives if you stay to the end. Walking away at 80 percent is now a real decision with a real price rather than a wasted commitment.
  - **Why this is the change that mattered, and it comes straight out of the v1.60 measurement.** 55 percent of deaths happen before the dropship is ever called. I had spent three builds putting the greed decision at the extraction ring, which is where 37 percent of deaths are. This puts the same decision in the looting phase, where the majority of them are, and it fires twenty one times a raid instead of once. It is the same pillar at a much smaller scale and in the place the data actually points at.
  - **One misordered container per map, caught by the check and worth the catch.** The sort went into `mkContainer`, which covers everything built with rolled loot. It does not cover anything whose contents are assigned afterwards, and that set turns out to be the interesting half: the ARC strongbox, the seal cache, the warden drop, a raider corpse, your own dropped items. The offender in the audit was the strongbox, which is a nine second cut that howls the whole way through and is the one moment in a raid meant to feel like opening a vault. Handing over the best of its three elites in the first three seconds would have gutted it. The sort moved into `setLoot`, which every one of those paths goes through. Re-audited: **zero misordered containers out of 494 across all four maps.**
  - `openContainer` now takes an optional subset of keys and grants only those without finishing the container, with the whole granting body split out into `grantLoot`. Called with no subset it behaves exactly as it always did, so every existing caller, and there are twelve, is untouched.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames. The staged pull was driven directly through a new `__open` hook and verified item by item rather than inferred. **Not verified: whether this makes looting interesting, which is the entire point of it.** The sim bot always searches containers to completion, so it cannot express the new decision and its numbers say nothing about this change either way. What he should watch for is whether breaking off a search early ever feels like the right call, because if it never does then the bar is too short or the last item is not tempting enough, and both are one number.

- **v1.62 ("and where is the furniture?", which turned out to be a gate, not a missing feature):** The second half of his run #14 note, explicitly left undone at v1.61. Furniture was not missing. Seven pieces exist and have since v1.53, drawn properly with tables, shelving, counter runs, a stove, a bed. The problem was that most rooms never qualified for any.
  - **The measurement that found it.** The gate asked for an interior over 180 by 150. On DAM BATTLEGROUNDS, which is the map he plays most, that meant **61 pieces spread across 14 of its 35 buildings: twenty one buildings were completely bare**. Walk in most doors on that map and the room is an empty floor, which is exactly what he described. BURIED CITY read at 79 percent furnished on the identical code, purely because it is built from bigger rooms. So the feature was fine and the eligibility rule was doing all the damage.
  - **Two mistakes on the way, both caught by measuring rather than by looking.** First attempt scaled the piece count by floor area at 1.15 per hundred square units, which pushed a big hall from 3 to 6 pieces up to 9. That SEALED rooms, and the sealed-room repair pass strips every piece of furniture from any building it finds sealed, so the result was more furniture and an emptier map: pieces on the dam went up 61 to 80 while furnished buildings went DOWN from 14 to 9. Density is now 0.35 per hundred, which leaves a big hall about where it always was, and the entire change is that a small room gets two pieces instead of none.
  - **Second: in a small room the piece is now shoved against a wall, because a piece touching a wall cannot split a room in two and therefore cannot seal it.** At a 10 unit offset that made things worse in a way that would never show on screen: a 10 unit gap behind a table is narrower than a body, so it minted slivers of floor you can see and never stand on, and the dam fell from 99.07 to 98.42 percent reachable. Flush against the wall leaves no gap to be trapped in, and it is what furniture against a wall looks like anyway.
  - **Result, all four maps, against v1.61.** DAM 40 to **54 percent** of buildings furnished, 61 to 91 pieces. THE QUARRY 55 to **69 percent**, 68 to 98 pieces. COLD STORAGE holds at 75 percent with 71 to 85 pieces. BURIED CITY holds at 75 to 79 with 101 to 126 pieces. Reachability is at or above its previous figure on every map, and the dam actually improved, from a 99.15 percent baseline to **99.53**.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null. Reachability was re-flooded from the player's own spawn over the real nav grid on every map rather than assumed. **Not verified: whether the rooms now read as places people lived in.** That is the entire point of the note and it is a look, so it is his call. What I can say is that on the dam roughly half the buildings you walk into had nothing in them at all before this and now do.

- **v1.63 (more machines, each less lethal, and a crash I shipped in v1.58):** His note **"not enough enemies, boring"** is the last live item from the recorder, and it was blocked on frame budget until v1.57 removed that. This build spends the headroom, and finds a crash on the way.
  - **The crash first, because it is the important part.** v1.58 gave raiders in medium and heavy rigs rolls on `LOOT.safe`. That table contains a `KEY` placeholder rather than a real item, because which keys exist depends on which map is loaded, and only `mkContainer` ever resolved it. So the literal string `KEY` went into a raider's bag, and on death the bag became a corpse container through `setLoot`, where `bestRarity` looked up `ITEMS['KEY']`, found undefined, and threw **inside the death handler**. Killing an armoured raider could take the raid down. Found by scanning every loot key across 45 raids after the sim died on it; it appeared once in about 8,300 keys, which is roughly one raid in twenty and would have looked random in the chair. There is now one `rollLoot` that rolls a table AND resolves the placeholder, and `bestRarity` skips an unknown key rather than throwing, because a bad table entry should never be able to black-screen a raid. Re-scanned: **27,567 loot keys across 60 raids, zero unresolved.**
  - **Then the density, measured properly: three arms, 120 seeds each, same build, only the numbers changing.**
    - 17 sentries / 20 crawlers / 6 raiders / 4 snitches, crawler at 20 damage: **26 percent extract, 12.1 kills a raid**
    - 20 / 34 / 8 / 5, crawler at 20 damage: **18 percent extract, 15.0 kills a raid**
    - 20 / 34 / 8 / 5, crawler at 13 damage: **24 percent extract, 16.4 kills a raid**
  - **The first attempt at "more enemies" just made the game eight points more lethal, which is not what he asked for.** He asked for a busier world, not a harsher one. Softening the crawler buys the density back: **a third more fighting per raid at the same survival rate as before any of it**, 24 against 26, which is inside the noise band at this sample size. The crawler is the right thing to soften because it is the melee rusher, so it is the one whose count you actually notice, and it killed 48 of the 98 deaths in the dense arm. A sentry is a ranged threat you are meant to respect and it is untouched.
  - **Frame cost, which is the whole reason this was possible.** 57 to 81 entities on the four maps at 2.4 to 3.4ms a frame. v1.56 was 8.03ms at 60 entities. So the map now holds a third more machines at under half the cost it used to pay for fewer.
  - **A caveat on the absolute number, stated plainly.** 24 to 26 percent sits below the 35 to 60 band this document has always quoted, and that band was written when the sim bot turned for the exit at 26wt. Since v1.59 it loots to 52wt, which is roughly how he actually plays, and a maximally greedy player dying more is correct rather than broken. His own 14 real runs came in at 5 extractions from 13 completed raids, which is 38 percent. The comparison that matters in this entry is arm against arm, not arm against the old band.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames. **Not verified: whether a third more fighting is the busier world he wanted or simply more noise.** It is more encounters at the same lethality, which is what the note asks for read literally, but "boring" is a feel word and the sim cannot read it. Every one of these is a slider on the tuning panel if the mix is wrong.

- **v1.64 (the cars stop being suitcases, and this one I could actually check):** His standing note is that wrecked cars read as suitcases from directly overhead. This has sat on the open list for a long time because "does it look like a car" is exactly the class of thing the sim cannot answer. It turns out the capture sink on port 8779 can: render a frame, POST it as base64, look at the PNG. So for once a look complaint got verified rather than guessed at.
  - **He was right, and it was not close.** The captured before frame is a warm brown rounded rectangle with a smaller rounded rectangle centred on top and two dark stubs on the near edge. That is a suitcase with a handle and two clasps. Three things were causing it. The roof was CENTRED on the body, which is exactly where a handle goes. The wheels were two stubs on one edge only, which read as latches. And every wreck on every map was long in x with identical proportions, so a group of them lined up like luggage on a carousel.
  - **The fix leans on the one silhouette nothing else in this world has: four wheels straddling the body.** They are drawn before the shell and share its lift, so a sliver of each shows past both long edges and the body covers their middles. A suitcase does not have four dark studs poking out of its sides. The shell then steps nose, cabin, tail along its long axis so there is a front and a back, the cabin is offset toward the tail the way a saloon sits rather than centred, and the glass is two separate panels with roof between them instead of one bar across the middle. Dead headlights at the nose say which way it was pointing, and one wheel is always flat so it reads as dead rather than parked.
  - **Orientation and palette.** Wrecks are now 42 percent vertical, so a street reads as traffic that died where it stood rather than as a car park. Measured after: 53 vertical against 67 horizontal on the dam, 44 against 78 on BURIED CITY, 25 against 57 on COLD STORAGE, 47 against 49 on THE QUARRY. The palette also moved off warm mid browns, which are the exact tones that read as luggage leather at this size, onto faded automotive paint: oxide red, washed navy, gunmetal, olive.
  - **A mistake caught by capturing rather than by reading the code.** The first attempt drew the wheels at lift 3 against a body at lift 14, so the far pair was hidden underneath the shell entirely and the near pair floated eleven pixels clear of the bodywork. On screen that was two detached black blocks under a box, which is arguably worse than what it replaced. Wheels now share the body lift. I would not have found that by inspection; the frame showed it immediately.
  - **Also fixed on the way: a Cyrillic character in an identifier.** A variable I introduced in this build was named with a Cyrillic o rather than an ASCII one. It would have parsed and run fine, which is what makes it nasty, but it is the kind of thing that breaks a later search-and-replace in a way nobody can see. Swept the whole file: the only remaining non-ASCII characters are the intentional middle dots in the hub HUD.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames. Both orientations were captured and inspected as images rather than asserted. **Not verified: whether they read as cars at normal play zoom and in motion.** These captures are at 3.4x zoom and standing still, which is the most flattering possible test. At 1x with fog over them and a crawler coming, the read may be weaker, and if so the lever is the wheel protrusion, which is one number.

- **v1.65 ("every block is the same length", and he was describing something exactly measurable):** His in-run note at 25 seconds on run #3 was **"every block is the same length, map has no atmosphere, needs verticality, hills, woods, town centers, big buildings, etc"**. The first clause is the one that can be counted, so I counted it before touching anything: **BURIED CITY had 28 buildings and FOUR distinct footprints. Fifteen of them were 420x380, exactly**, laid out in two rows on a fixed 520 pitch at a single shared y. COLD STORAGE had 20 buildings and five footprints. That is not a city, it is a texture, and it is the most literal confirmation of a playtest note anywhere in this project.
  - **BURIED CITY re-authored: 4 distinct footprints to 21.** Every garage in both rows is now its own size, between 300 and 720 wide and 300 to 460 deep, and each row is staggered in depth so the eye cannot lock onto a repeating unit. The design intent is untouched: tight units ringing an exposed courtyard with the doors facing in. Every gap is at least 100 units against the 90 the reachability guarantee needs, and the tightest measured pair came back at exactly 100.
  - **COLD STORAGE: 5 to 10, and only the dock.** Its six loading bays were identical 520x420 boxes on a 600 pitch, and the giveaway is that the original comment reads "six bays along the top, every one a different interior". The variety was always meant to be INSIDE; the outside had none. Now all six differ and the row is staggered.
  - **CHILL ROW is deliberately left alone, and there is now a comment saying so.** Its nine identical units on eighty unit alleys look like exactly the same fault, but its own comment says it is the tightest ground in the game and that learning your way around it is supposed to pay. Uniformity there is a decision. An 80 unit gap also trips the 90 unit clearance heuristic, which is why the note matters: a later pass reading only the numbers would "fix" a block that is working as designed.
  - **Woods, which is the other half of his note.** BURIED CITY had 19 trees on a 4600 by 4600 map, which is not a wood, it is a hedge. Two more copses on the east side, where the map is already authored as "greener, overgrown ruin" so it stays a desert rather than becoming a forest, plus one in the west terraces. **Trees on that map: 19 to 60.**
  - **Reachability re-flooded from the player spawn on every map and unchanged: BURIED CITY 99.66 percent, COLD STORAGE 99.38, DAM 99.63, THE QUARRY 99.57.** Moving twenty eight building footprints is exactly the change that can silently strand a room, so this was measured rather than assumed.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames. **Not verified: whether the map now has the atmosphere he was asking for.** Footprint variety is the countable part of that note and it is fixed; verticality, hills and town centres are not, and the three of them are a map authoring job rather than a tuning one. Also unverified is whether the new BURIED CITY layout still plays as the map it was designed to be, because the courtyard crossing is the whole point of it and I have changed what rings the courtyard.

- **v1.66 (the destroyed buildings he asked for were being silently thrown away):** His map note asked for **"buildings that are completely destroyed and cannot be entered"**. That feature exists and has since v1.53: ruins, emitted as one solid block so nothing about them is enterable. It was barely reaching the map. Counted before touching anything: **DAM wanted 36 ruins and placed 15. BURIED CITY wanted 37 and placed 28. COLD STORAGE wanted 25 and placed 8. THE QUARRY wanted 29 and placed TWO.** Over the same four maps wrecked vehicles placed 120 of 120, 122 of 122, 82 of 82 and 96 of 96, so this was specific to ruins rather than to scatter placement in general.
  - **It was never broken, it was over constrained.** A ruin is 150 to 320 units wide and needs 70 units of clearance from every wall, so the largest needs a clear area of 460 by 400. By the time ruins are placed the wall list already holds every building wall, interior partition, piece of furniture, platform perimeter and racking run on the map. On THE QUARRY, which is five terraces, essentially nowhere is that clear, so 1,158 of 1,160 attempts failed and the map shipped with no destroyed buildings in it at all. The attempt budget was never the problem and raising it would have done nothing.
  - **The fix is to stop treating "a ruin" as one size.** Each attempt now tries a large footprint, then a medium, then a small one at the same spot, so a gap that cannot take a collapsed warehouse can still take a collapsed shed. Ruin to ruin spacing scales with the ruin as well, 140 for the largest down to 84 for the smallest, because the old flat 140 was sized for the biggest footprint and was pricing small rubble out of gaps it fits in. **The clearance rule against walls and buildings is unchanged at 70**, because that is the reachability guarantee and it was not what was wrong.
  - **Result: DAM 15 to 36 of 36. BURIED CITY 28 to 37 of 37. COLD STORAGE 8 to 22 of 25. THE QUARRY 2 to 6 of 29.**
  - **A regression I caused and then fixed in the same build.** The first version dropped THE QUARRY from 99.57 percent reachable to 98.39, about 1.2 percent of the map turned into floor you can see and never stand on. The cause is worth recording: there is already a prop connectivity guard that floods the finished grid and pulls out any wreck or ruin touching unreachable ground, and it works, but it ran a maximum of four passes and then gave up **silently**. Placing far more ruins stopped it converging inside that budget. Raised to ten, and since the loop breaks the moment a pass cuts nothing, the extra budget costs nothing on maps that already converged. THE QUARRY is back to 99.57 percent, exactly its previous figure.
  - **Sampled rather than measured once.** Reachability on the dam over eight seeds runs 99.22 to 99.63 with a median of 99.52, against a historical baseline of 99.15, and 36 of 36 ruins landed on every one of the eight. Props roll fresh every raid, so a single reading of this number means very little, which is a trap I walked into earlier in the session with a timing measurement.
  - **An honest limit worth writing down.** THE QUARRY still only takes 6 of the 29 ruins it asks for, and that is correct rather than a remaining bug: the map is five stacked terraces and it genuinely has very little open ground. The real fault is that `wantR` scales with raw world area, which is the wrong denominator for a map that is mostly platform. Scaling it by measured open ground instead would ask for a sensible number on every map. That is a small change and it is not in this build because I would want to re-baseline all four maps against it.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames. **Not verified: whether more rubble makes the maps read better or just busier.** Ruins are solid blocks that break sight lines, so this is a change to how the ground plays as well as how it looks, and 21 more of them on the dam is not a small change. If it makes the map feel cluttered the lever is the 9 in `wantR` and it is one number.

- **v1.67 (my tests were playing gunfire out loud on his PC, and a change I tried and threw away):** Two things, and the first is an apology.
  - **The verification fixture is now permanently silent.** Verification drives real frames, and real frames fire real gunshots, alarms, machine voices and ambience through WebAudio. He was working while a forty raid batch played all of it aloud, and asked me to cut it off. He should never have been able to hear my tests at all. Every emitter is stubbed at the injection point rather than trusting a master gain of zero, because a later build could add a node that misses the bus, and as belt and braces the `AudioContext` constructor itself is replaced with one that throws. Verified after: the constructor throws, the game holds no audio context at all after eighty driven frames, and the frames still run with `drawErr` null. **The mute lives only in the injected fixture, never in `dark_raiders.html`.** Checked explicitly: the game file contains no mute lines and still defines its own `sfx` and `blip`, so what he plays is unchanged.
  - **Tried and reverted: scaling the ruin count by measured open ground.** v1.66 noted that `wantR` scales with raw world area, which is the wrong denominator for THE QUARRY, and proposed measuring the actual free ground instead. I built it and it was worse. Measured over the four maps it cut the dam from 36 ruins to 33 and COLD STORAGE from 22 to 16, both of which demonstrably had the room, while THE QUARRY stayed at 5 either way. The reason is that the quarry is not short of open ground, it has about as much as COLD STORAGE at 1.86 against 1.90; its open ground is in long narrow terrace strips rather than in clear pockets, and no area based number of any kind can see the difference. So the ask stays generous, the size tier fallback and the connectivity guard decide what actually lands, and a map placing 5 of 29 is a log line rather than a fault. The reasoning is left in the file next to the constant so the next pass does not rediscover it.
  - **A scan that found nothing, reported because it found nothing.** Two of the worst bugs in this project were a variable used before its `var` assignment ran: the hazard pay multiplier that silently read as zero, and the `tPay` case behind it. I wrote a scanner for that whole class over all 267 top level functions. It produced 31 candidates and **every one is a false positive**, split between comment text, parameters shadowing an outer name, and multi declarator statements like `var a=1,b=2` where my regex only captured the first name. Spot checked the two that looked like real code, `bestD` in `buildRaid` and `row` in `renderHub`, and both are declared separately in each of several scopes. There is no live hoisting bug of that shape in the file.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames, and ruins still landing 36, 37, 18 and 7. **Not verified: nothing in this build changes what he plays**, so there is nothing for him to watch for. The silence fix is in the test harness and the ruin change was reverted before shipping.

- **v1.68 (ammunition comes back off the things that made you spend it):** His run #2 tag was **"Ran out of ammo"**, and it turns out to be the most measurable complaint in the recorder. Measured over 40 raids on v1.67: the player fires **202 rounds a raid**, and **40 percent of raids run completely dry**, spending an average of **98 seconds unable to shoot at all**, first hitting empty at a median of 270 seconds.
  - **It is not a scarcity problem, which is why more ammo in the tables would have been the wrong fix.** There are **1,760 rounds lying on the dam across 44 boxes**, against the 202 a raid actually uses. Eight times more ammunition exists than anyone needs. The problem is distribution: **only 44 of 236 containers hold any**, so finding it is luck, and when you are empty there is nothing you can DO about it. Ninety eight seconds of being hunted with no ability to fight back is not tension, it is dead time.
  - **So the fix is counterplay rather than abundance.** A destroyed machine now reliably returns some of what it cost to destroy it. Sentries are the ranged threat that drains a magazine, so a sentry always yields ammunition alongside its salvage; crawlers keep their existing roll. The answer to running low becomes FIGHT, which is the tense answer, rather than search two hundred boxes hoping, which is the boring one. Before this a sentry gave an expected 8.8 rounds: it dropped a container only 55 percent of the time and then had a 2 in 5 chance the single item was ammunition.
  - **Measured, 120 seeds per arm, same build, only the dial moving.** Raids that run dry **48 percent to 39 percent**. Time spent dry when it happens **99 seconds to 74**. Ammunition still in hand at the end 72 to 92 rounds. Shots fired a raid essentially unchanged at 224 against 230, so this is not the bot simply shooting more.
  - **Honest reading: this helps, it does not solve.** Two raids in five still run dry. The remaining cause is the 270 to 300 second mark, which is where the bot is deep in the map and furthest from anything it has already cleared. Going further would mean either raising the drop again, which starts to feel like the machines are vending machines, or putting ammunition somewhere you can seek out deliberately, which is a design question about whether this game wants a known resupply point. That is worth his opinion rather than my guess.
  - **New dial on the tuning panel: "Ammo back from a killed sentry", 0 to 1.** At 0 it reproduces v1.67 exactly, which is also how both arms above were run in a single build.
  - **The project moved to `C:\claudecode\dark raiders` this build**, at his request, out of the Desktop. Nothing was lost: the git history, the working changes, the exports and the tools all came across, and the play link serves the new location on the same port 8802, which matters because his saved progress is keyed to that origin and would have been orphaned by a port change. All five tool scripts hardcoded the old path and were repointed. The empty Desktop folder is still there because a shell is holding it open, and it can be deleted by hand.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames, and the fixture confirmed silent by asserting the `AudioContext` constructor throws. **Not verified: whether a sentry that reliably drops ammunition reads as a fair loop or as a vending machine.** The sim says the number moved; it cannot say whether killing a sentry to refill now feels like a decision or like a chore, and that is the thing to watch.

- **v1.69 (three ways to strand his save, found by attacking the hub instead of the raid):** Every audit so far has driven raids. The hub had never been attacked, and it is the higher stakes surface: a raid that throws costs you a raid, but a hub that throws costs you the game, because there is no way back in. That is not hypothetical, it is the v0.48 finding, where one retired item key in a stash took the whole hub down and stranded a real save.
  - **The method: drive the four hub renderers against twenty hostile but reachable profile states.** Empty stash and armoury, negative credits, which is genuinely reachable because a mercenary death benefit can put you in debt, five hundred stash items, unknown item keys, unknown gun ids, a missing rig, an unknown rig, a fully claimed season, negative season progress, null contracts, a null contract entry, null rivals, every Term switched on, an unknown Term id, an empty log, a pack tier out of range, a map index out of range.
  - **Three of them threw, all in `renderHub`.** An unknown key in the stash threw on `ITEMS[b].val` inside the sort. An unknown gun in the armoury threw on `wp.name`. Null contracts threw on `forEach`.
  - **Why the existing protection was not enough, which is the interesting part.** `loadProfile` has filtered unknown stash and armoury keys since v0.48, and that is the correct place to repair a save. It only runs at LOAD. A key with no `ITEMS` entry that enters the stash **mid session** reaches the hub straight away, and v1.63 proved that class is reachable: an unresolved `KEY` placeholder got into a raider's bag and crashed the death handler. A load time filter repairs the save you already broke; it cannot stop you breaking it. The hub now skips what it does not recognise instead of dying on it, which is the same principle as the `bestRarity` guard added in v1.63.
  - **Re-audited after: twenty hostile states, zero failures**, including two new cases added because the fix suggested them, a contracts array containing a null entry and a profile where every stash item and every gun is unknown.
  - **Confirmed while here, and worth stating because it found nothing:** negative credits render fine, five hundred stash items render fine, and an out of range pack tier or map index does not throw. Only the three above were real.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames. **Not verified: nothing here changes what a raid plays like.** This is pure robustness and it should be invisible. The one thing it changes visibly is that an item this build does not recognise now silently vanishes from the stash list rather than crashing the hub, so if he ever sees his stash count disagree with the number of rows in it, that is this guard doing its job and it is worth telling me.

- **v1.70 (the ammunition tell, which is the pillar-correct half of the v1.68 fix):** v1.68 made sentries return ammunition and measured the honest result: dry raids fell from 48 percent to 39, and the time a dry raid spends unable to shoot fell from 99 seconds to 74. It helped and it did not solve. Two raids in five still run empty.
  - **The remaining cause is not scarcity and never was.** There are **1,760 rounds lying on the dam across 44 boxes** against the **202 a raid actually uses**. Eight times more ammunition exists than anyone needs. But **only 44 of 236 containers hold any**, and nothing whatsoever tells you which. So being empty is a problem you cannot act on: every crate looks identical and each one costs 1.4 seconds to find out.
  - **Adding more ammunition would have been the lazy fix and it would have flattened the tension.** This is the pillar-correct one instead. Pillar 2 of this design is INFORMATION IS THE GAME, and this is an information problem wearing a scarcity costume. When you are genuinely low, a box you can SEE that holds ammunition now says so, with a small amber magazine mark above it.
  - **Three deliberate limits stop it being a cheat.** It only appears below a real threshold, 45 rounds by default, which is a bit over one rifle magazine and the point where a fight stops being a decision and becomes arithmetic; a stocked player never sees it at all. It is drawn in the WORLD pass, under the fog, so it cannot reveal anything through a wall or across ground you have not explored: you still have to go and look. And it says only that ammunition is in there, never how much or what else is with it, so committing to the search is still a commitment.
  - **Verified by driving the predicate rather than by reading it.** On a dam raid with 230 containers of which 39 hold ammunition: **stocked shows 0 tells, low shows exactly 39, the dial at 0 shows 0, and an opened container shows 0.** Captured a frame at the threshold as well, and the mark reads as distinct from the rarity pip below it rather than merging with it.
  - **New dial: "Show ammo boxes below this reserve", 0 to 200.** At 0 the feature does not exist, which is also how the off case above was tested.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null with the player forced empty so the tell was actually drawing on every map, plus hub frames. **Not verified: whether this makes running low feel survivable or simply removes the fear.** The sim cannot answer it, because the bot navigates to the nearest container by distance and does not look at pips at all, so its dry rate is completely unmoved by this change and I have not quoted one. This is his call in the chair, and the honest risk is that it is too generous: if being low stops being frightening, the threshold is the dial and 45 is a guess.

- **v1.71 (servicing a gun cost more than replacing it, at every tier):** Audited the transaction paths this tick, because a bug there costs him money or gear permanently rather than costing him a raid. Started with the shop and found nothing: **every consumable sells back for less than it costs**, so there is no money printer, and guns cannot be bought and resold because a purchase goes to the armoury rather than the stash. Repair logic itself is also correct, verified across six checks: no credits does not deduct, no parts does not deduct credits, success spends exactly the listed credits and exactly the listed parts, unrelated stash items are untouched, wear is zeroed, and a pristine gun cannot be charged for.
  - **Then the economics turned out to be inverted.** Wear is counted in ROUNDS FIRED, with steps at 420 WORN, 950 FOULED and 1600 FAILING, and the repair bill scaled with rounds and gun tier with **no ceiling of any kind**. Measured on v1.70 against the shop price of the same gun:
    - **pistol, buy 600:** repair at FOULED **1,154**, at FAILING **1,944**, at 2,400 rounds **2,916**
    - **SMG, buy 2,200:** repair at FAILING **2,448**
    - **rifle, buy 3,800:** repair at 2,400 rounds **4,428**
    - **DMR, buy 4,500:** repair at 2,400 rounds **5,184**
  - So servicing a gun was **always** the wrong move. Throwing it away and buying another was cheaper at every tier past WORN, which makes the Workshop a trap purchase and quietly deletes the entire point of v1.51, where a favourite gun was supposed to become a running cost you CHOOSE to pay. A raid fires about 202 rounds, so a rifle reaches FAILING in roughly eight raids and the bill arrives fast.
  - **Capped at 60 percent of replacement.** Replacement is the shop price where the shop stocks the gun, and the item value scaled by 2.4 where it does not, which is the ratio the shop itself uses across every gun it sells, consistently 2.0 to 2.5. Verified after: **repair never costs more than buying for any gun at any wear level**, and the cap holds at absurd wear, 99,999 rounds costs the same as 2,400.
  - **An honest consequence.** A cheap gun now hits its ceiling immediately: the pistol costs 432 to service at any wear at all, because its raw bill already exceeded the cap at WORN. So the escalating curve survives only on the expensive guns, rifle 775 to 1,753 to 2,160 and DMR 907 to 2,052 to 2,880. That is the right way round, since a pistol is nearly disposable anyway, but it does mean wear is a meaningful running cost mainly on the guns worth keeping.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames and all four hub screens including the Workshop. **Not verified: whether 60 percent is the right number.** It guarantees repair is always the cheaper option, which was the bug, but whether servicing a rifle for 2,160 feels like a fair bill or still like a mugging is a judgement from the chair. It is one constant if it is wrong.

- **v1.72 (two trap recipes, and the rule every recipe has to satisfy):** Continued the transaction audit into crafting and the season track. **The season track is completely clean** across every check I could think of: you cannot claim below the threshold, you can claim at exactly the threshold, you cannot claim the same tier twice, every tier grants exactly what its label promises in credits, reputation, stash items and weapons, a weapon tier cannot duplicate a gun you already own, the final tier correctly pays out and then rolls the season over with progress and claims reset and the world tier advanced, and a negative or out of range index is refused rather than throwing. Nothing to fix there.
  - **Crafting had no money printer either**, which is what I was hunting. Every recipe loses value even when priced RECURSIVELY through the Component Kit, which is an ingredient in six of the seven.
  - **But two recipes were traps.** Materials and credits are fully fungible in this game, because everything in the stash sells, so a recipe can be priced honestly against the shop. Smoke cost 255 in materials against **150 to simply buy one**. Decoy cost 227 against **100**. Both were strictly dominated: there was never a reason to craft either. That is the same shape as the Compact SMG trap already recorded in section 13, a thing the game offers you that is never the right choice.
  - **Fixed by raising the YIELD rather than cutting the cost**, so nothing he already owns or has already crafted gets worse, which is the principle the SMG write up recommends. Smoke now yields two, and decoy two. Frag is deliberately left alone: it prices out level with the shop at 309 against 280, and its real value is that crafting reaches it before the 600 reputation gate does, which is a reason to craft that has nothing to do with cost.
  - **I introduced a money printer doing it and caught it in the same build.** My first attempt made the decoy 3x for a component and a wire: 228 in materials selling for 258, a clean 30 credit profit loop, which is the exact thing this audit set out to rule out. Re-measured, found it, fixed it.
  - **The rule, now written into the file next to the recipes, because I learned it by breaking it.** Inputs must be worth MORE than the output sells for, or crafting prints money, and LESS than buying the same output outright, or the recipe is a trap. That window is precisely the shop's markup. For the decoy it is 160 to 200 for a pair, and one Component Kit at 179 is the only clean way to land inside it.
  - **Verified after: zero printers and zero traps other than the deliberate Frag.**
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames and all four hub screens. **Not verified: whether crafting is now worth doing at all.** The numbers say it is no longer strictly wrong, with the plate at 520 against 620 to buy and smoke at 255 against 300, but a 15 to 20 percent saving on things you can already afford may still not be worth the trip to the Workshop. Whether crafting deserves a bigger edge than that is a design call rather than a correctness one.

- **v1.73 (AI raiders were playing an easier game than the player, and the fix did not move the number):** Measured the AI raiders against the player for the first time, prompted by his own recorder, which shows `aiExtracted:4` to `6` on nearly every run while he got out once in thirteen. **Eight raiders spawn per raid and seven of them get out. A 90 percent extract rate, against the player's high thirties.**
  - **They were not better at the game, they were playing a different one.** The player calls a beacon, waits twenty five seconds, survives a siege that since v1.60 scales with the value in the bag, then boards. A raider walked into the ring and stood there for **five seconds**. Pillar 4 says raiders behave like players and run for the same extract you want, and at five seconds that was simply not true. Three consequences, all bad: it is thematically false, it drains the world because seven full bags leave every raid, and it deletes a fight, because a raider you cannot reach is never a decision.
  - **The dwell is now fourteen seconds and being shot interrupts it**, losing three seconds of progress for every second under fire. The intent is that a raider holding the ring with a full bag, which since v1.58 is a genuinely valuable bag, becomes the best target on the map and crossing open ground to contest it becomes a real choice.
  - **The mechanism is verified and the outcome is not.** Driving a raider into the ring directly: **14.1 seconds to extract uninterrupted, and never in sixty seconds while under sustained fire.** So the change does exactly what it says. But over 120 seeds per arm with only the dial moving, **the raider extract rate is 90 percent in both arms, unchanged**, and I am not going to dress that up.
  - **The reason is the finding worth keeping.** Nothing in this game ever threatens a raider at the extraction ring. Machines do not converge on it, the beacon siege is triggered by and aimed at the PLAYER, and the sim bot contests a raider extraction about half a time per raid. A longer window is only a window if something can come through it. Lengthening the dwell creates the opportunity; it cannot take it. **If raiders are ever meant to actually lose a bag, the change is that the extraction ring should be dangerous for them too, not that they should stand in it longer.** That is a larger design question and it is his, not mine to decide quietly.
  - **New dial: "Seconds a raider must hold the ring", 3 to 30.** At 5 it reproduces v1.72 exactly, which is how both arms above were run in a single build.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames and all four hub screens. **Not verified: whether contesting a raider extraction is fun, or even practical, for a human.** The sim bot cannot express the decision at all, so the fourteen seconds is a guess at what is long enough to cross ground and short enough not to be a chore. If a raider now feels like a sitting duck, or still feels uncatchable, the dial is one number and both failure modes are his to spot.

- **v1.74 (a contract that could never be finished, on the map he plays):** Audited the contract system, which had never been checked against what the maps actually contain. Started by generating fifteen hundred contracts and cross referencing every demand against real map supply. **Four of the five contract types are comfortably achievable**: the worst kill contract asks for six sentries against eighteen to twenty four on the map, the worst search asks for five crates against seventy one to a hundred and twenty seven, the worst extract-carrying asks for two of an item against dozens, and the biggest haul target is 1,600c against 90,000 to 139,000c of loot lying around. Nothing to fix in any of those.
  - **The fifth type was broken.** A district contract picked a district index from 0 to 3 at random and **never checked whether the map you are about to play contains one**. Measured over six seeds per map, worst case containers in each district:
    - DAM BATTLEGROUNDS **53 / 36 / 26 / 30**
    - BURIED CITY **13 / 0 / 10 / 78**
    - COLD STORAGE **27 / 9 / 2 / 38**
    - THE QUARRY **33 / 61 / 23 / 20**
  - **BURIED CITY has no buildings tagged district 1 at all.** Containers are only ever placed inside buildings and landmarks, so that district contains nothing, and "search four containers in it" was literally impossible. One district contract in four rolled it. COLD STORAGE is the softer version of the same fault: two containers in district 2 against a contract that asks for up to four.
  - **The reason it matters more than the numbers suggest is that nothing tells you.** There is no way to see that a contract cannot be finished. It sits in the slot paying nothing, and the only way out is to notice and reroll, which costs you the slot anyway. That is the worst kind of bug in a progression system: silent, and it looks like your own failure.
  - **Fixed by reading the map definition.** The district is now drawn only from the ones the current map's buildings actually use, and the ask is clamped to two where a district has fewer than three buildings in it. It reads the FIXED_MAPS definition rather than a live raid, because contracts are generated in the hub before any raid exists.
  - **Verified after: zero impossible contracts.** BURIED CITY now never names district 1 at all, offering only 0, 2 and 3. COLD STORAGE clamps its thin district 2 to an ask of two against a supply of two, and district 1 to two against nine. Every district's maximum ask is now at or below its worst case supply on every map.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames and all four hub screens. **Not verified: whether he ever hit this.** It needs a district contract to roll the empty district on BURIED CITY, so it is roughly one contract in twelve on that map, and his recorder does not record which contracts he was offered. If he has ever rerolled a search contract because it seemed to be doing nothing, this was probably why.

- **v1.75 (locked doors with no key on the map, seven raids in ten on COLD STORAGE):** Same question as v1.74, asked of a different system: does the map actually supply what it visibly promises? Every map has two locked rooms, each with a drawn door that says it is locked. Keys arrived only as a rare roll on the safe and cache loot tables, and `resolveKey` then picked ONE of the map's locked rooms at random, so even a key that did spawn was a coin flip on which door it opened.
  - **Measured over ten seeds per map, the fraction of raids where BOTH locked rooms had a key somewhere on the map:** DAM BATTLEGROUNDS **7/10**, BURIED CITY **8/10**, THE QUARRY **8/10**, **COLD STORAGE 3/10.** So on COLD STORAGE, seven raids in ten contained a visibly locked door that nothing on the map could open, and two raids in ten did on the map he plays most.
  - **This is the same silent shape as the impossible contract.** The room is drawn, it has a door, the door says LOCKED, and the key is simply not in the world. Nothing tells you, so it reads as a failure to search properly rather than as an absent object.
  - **The promise is now made structurally, exactly as the three ARC caches already are.** Each locked room is guaranteed one key in an ordinary container somewhere on the map. Rarity is untouched: it is still a search rather than a handout, it is never placed in a cache or a strongbox so it cannot ride in on the jackpot you already wanted, and extra keys from the loot tables still roll on top.
  - **A hole in my own first version, caught by measuring rather than by reading it back.** The guard asked whether a key existed anywhere, which counted a key that had randomly rolled INSIDE the room it opens. That key is useless, and the guard would see it, decide the promise was kept, and leave the door sealed. Measured: a key lands inside its own room 3 to 9 times per twelve seeds depending on the map, so it is not a rare corner. The check now only counts keys OUTSIDE the door they open, and so does the placement.
  - **Verified after, twelve seeds per map: every locked room has a key on all four maps, 12 of 12, and specifically a key outside the room it opens, also 12 of 12.** COLD STORAGE went from 3 in 10 to 12 in 12.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames and all four hub screens, with container counts unchanged at 150 to 239. **Not verified: whether guaranteeing a key makes the locked rooms feel routine.** There is a real argument that a door you sometimes cannot open is good tension and a reason to come back. I have taken the other side, that a promise the map cannot keep is a bug rather than a mystery, but if he wants locked rooms to be a lottery again the guarantee is one block and it is clearly marked.

- **v1.76 (half the landmark themes were the same theme, and none of them stocked what their sign said):** Third build running the same question at a different system: does the map supply what it promises? Landmarks are the named places, and each carries a loot theme. The mapping read `{rare:'safe', medical:'body', ammo:'body', bulk:'crate'}` and then the container type was chosen as `tt==='body' ? 'locker'`. Two faults fell out of that one line.
  - **`medical` and `ammo` both mapped to `'body'`, so they were byte for byte identical.** A RELIEF STATION and a CHECKPOINT stocked exactly the same loot. Half the landmark themes in the game were the same theme wearing two names, on every map: the dam's SWITCHYARD and THE CREST were indistinguishable from its CONTRACTOR CAMP, and BURIED CITY's NORTH GARAGES from its SOUTH GARAGES.
  - **And because `'body'` was then turned into a locker, `LOOT.body` was never used by a landmark at all.** That is the actually medical-weighted table, 18 percent bandages and 10 percent medkits. So the medical landmark did not stock medical supplies either. It stocked lockers, same as everything else.
  - **Each theme now has a table that matches its sign.** A relief station carries dressings, medkits and the plates you would expect where people were patched up. A checkpoint or a switchyard carries ammunition, 44 percent of its table. `rare` and `bulk` were already correct through the safe and crate tables and are untouched.
  - **This also answers, in the right currency, the question left open at v1.70.** v1.68 and v1.70 established that ammunition is not scarce but unfindable, and I flagged "a resupply point you can deliberately go to" as a design question rather than build one. It turns out the game already had the answer written on the map and was not honouring it. A CHECKPOINT is now a place you can choose to walk to when you are running dry. That is a decision on the ground rather than a number in a config, and it is justified by the landmark's own name rather than invented for balance.
  - **Measured after, aggregating every container inside a landmark across four maps and five seeds each:** ammo themed landmarks run **19 percent ammunition against 9 percent** in medical ones, and medical themed run **18 percent healing against 8 percent** in ammo ones. Rare landmarks average **690c an item against 274 to 282** everywhere else, so the valuable place is still clearly the valuable place. The figures are diluted because that count includes containers placed inside a landmark's footprint by the ordinary building and open-ground passes, which have no theme; the landmark-stocked containers themselves are drawn wholly from the new tables.
  - **Also confirmed clean, and worth stating because it found nothing:** every special character and set piece spawns on every raid. Sentry, crawler, snitch, listener, raider, warden, peddler and stray, plus encampments and THE SEAL, all **16 of 16 seeds on all four maps**. Nothing he has been promised is failing to turn up.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames and all four hub screens, with **zero unknown loot keys** across every container on every map, which is the check that would catch a bad entry in the two new tables. **Not verified: whether a CHECKPOINT now reads as somewhere worth a detour.** The sim bot walks to the nearest container and does not know what a landmark is, so it cannot tell me whether going out of your way for ammunition is a decision worth making. That is his to feel.

### THE SEAL audited end to end (2026-08-24 tick, no code change)
The only cross-raid promise in the game, and the most fragile kind of state there is: progress lives in the profile between raids. Driven end to end for the first time rather than read.
- **Abandoning a raid loses the cutting.** Fifteen seconds cut, zero banked.
- **Extracting banks exactly what you cut.** Fifteen seconds cut, fifteen banked.
- **Cutting the remaining twenty five completes it**, and a reward cache appears at the door in the same instant, container count 224 to 225.
- **The tier advances**, 0 to 1, **the cut resets to zero**, and **the reseal is genuinely harder**, 40 seconds to 65.
- **Progress is per map and not global.** Breaking the dam's seal leaves BURIED CITY still at tier 0, which is what makes it a reason to return to a specific place.
Eight checks, zero failures. Nothing to fix.

**Two traps in my own harness, found on the way, both now recorded next to the hooks that need them.** Both looked exactly like the game being broken.
- `showScreen` does `keys={}`, which REPLACES the object rather than clearing it. A reference captured once at the top of a test is stale the moment a raid ends, so every later keypress lands in an orphan object and the action silently stops happening. This is what made raids two and three of the first seal test read as a total failure to accumulate: the game was fine and my keyboard had been disconnected.
- Standing still in a live raid to hold a key gets you shot. The first cut read 10.1 seconds against 15 asked for, purely because a crawler reached the tester mid test. When the point is the mechanic rather than the fight, pin health and clear the downed flag every step.

- **v1.77 (you could never recover your own body intact, and the code said so itself):** Audited body recovery, the second of the two cross-raid promises in this game and the same fragile shape as THE SEAL: state that has to survive between raids. The mechanic passed every structural check first time. A death leaves a body on that map and only that map, it does not follow you to another one, it appears as a searchable container on your next raid there, and it ages out after three raids. Nothing wrong with any of that.
  - **Then the numbers on the way through did not add up.** Died carrying eight items worth **2,280c**. On the very first raid back, **before touching anything**, the body held six items worth **768c**. A Titan Plate and a Data Core, **1,512c of the 2,280**, were already gone before the raid had started.
  - **The bug is an off by one, and the code's own comment is the evidence.** The scavenger cut says it happens *"every raid you do not come back for it"*, which is the right rule. But it runs from `buildRaid`, which includes the raid where you **do** come back. So the cut was always taken before you had any opportunity to reach the body, and because the good stuff goes first by design, it was the expensive half that went. Recovering your body intact was not possible at all, on any raid, ever. The feature says one thing and did another.
  - **The first raid after a death now spends a flag instead of a quarter of your kit.** Every raid after that costs the quarter exactly as before, so the urgency the feature exists for is untouched: you still have to go back soon, you just are not robbed in transit.
  - **Verified after, same eight item death worth 3,360c:** first raid back holds **all eight, 3,360c intact**. Second raid back holds six, **1,006c**, so the scavengers still take their cut and still take the good things first. It still ages out on schedule.
  - **Worth flagging for his own save:** this has been live for every death he has ever had, so every body he has gone back for was already stripped of its two best items before he arrived. If recovering a body has ever felt underwhelming, that is why.
  - Parse check PASS, four maps built, stepped, drawn and HUD-drawn with `drawErr` null, plus hub frames and all four hub screens. **Not verified: whether three raids is now too generous.** Making the first trip intact is strictly more valuable than before, so the window may want to be shorter to compensate; `BODY_RAIDS` is one constant. I have deliberately not touched it in the same build as the fix, because changing the rule and the number together would make the next measurement unreadable.

### v1.78: the danger bonus fired on two thirds of the map, most of it through a wall

Third audit in the "does the map supply what it visibly promises" run, and this
time the promise is a comment. WINDFALLS carry a claim right above the function:
the odds "rise the further you are from a way out, the longer you have been on
the surface, and the closer you are to something that can kill you." Three
claims, all numeric, all checkable. I built a probe that reports windfallOdds
broken into its three terms at every container on a raid and ran it over 40
raids across all four maps, about 7,800 containers.

The distance term is fine. Nearest way out averages 1,243 units and reaches
3,449, so the gradient is real and reaches about half its ceiling on average.
That one does what it says.

The danger term does not. It fired on 65 percent of every container on all four
maps: 64.3, 64.7, 64.2, 66.5. A bonus that pays on two thirds of the map is not
a spike, it is a baseline wearing a costume, and a baseline is exactly the thing
the comment three lines above says windfalls exist to avoid. Worse: of the ones
that did fire, only 38 percent had line of sight to the container. The other 62
percent were a crawler standing on the far side of a wall, which the raid
correctly treats as no threat at all everywhere else in the codebase. The test
was a proximity test wearing the name danger. It measured population density.

Line of sight is now required, and because that cuts the trigger rate from 65
percent to 31.4 percent, the payout goes from 0.06 to 0.10 so the term still
means something when it lands.

The average is deliberately almost unchanged: 0.1368 before, 0.1303 after. What
changed is the shape, which is the entire point. Before, 78 percent of all
containers sat in two adjacent odds bands, 0.10 and 0.15, and only 3.1 percent
ever reached 0.20. Nothing reached the top band, so the 0.28 cap had never once
been approached. After: the middle two bands hold 49 percent, 13.3 percent reach
0.20 or better, and the top band is populated. Same money, distributed by what
you actually did rather than by where the map happened to put a sentry.

Second finding, from the same read. The windfall roll was skipped under G.sim,
so the bot sim has never once modelled windfalls. Every haul number this project
has produced was measured on a version of the game with the system switched off.
The subtler half is worse: the real game draws one random number per container
that the sim did not, so a seeded raid in the sim was never the same raid as
that seed played live. Seeds were only ever comparable sim to sim. The sim now
rolls it and skips only the presentation.

Measured, 120 seeds, THE QUARRY pinned, simGreed 52. The 1.77 arm reported zero
windfalls on all 120 raids, which is the proof rather than the inference. The
1.78 arm reports 198 across 120 raids: 1.65 a raid, 9.9 percent of containers
opened, 91 raids with at least one and 29 with none, tail out to six. Average
haul goes 4,478 to 7,734. That lift of 3,256 reconciles against the item table
independently: the nine windfall keys average 2,070 credits, and 1.65 times
2,070 is 3,415, within five percent of observed.

The important reading of that number is that it is NOT an economy change. The
real game has always rolled windfalls. What moved is the measurement: every
balance conclusion this project has drawn from the sim was drawn against an
average haul 42 percent below what the game actually pays. Nothing in the
player's economy changed today; the instrument stopped lying about it.

One honest limit on this comparison. Drawing one more random number per
container shifts the stream, so the same seed is no longer the same raid across
the two builds. This stopped being a paired test the moment the fix landed, and
the aggregate is all that survives. Extract rate read 20 percent against 15
percent, which at 120 a side is a z of about 1.0 and therefore nothing; I am not
reporting it as an effect, and the per seed flips are meaningless here for the
same reason. Paired comparisons resume from 1.78 forward.

Not verified: whether 31 percent is the right trigger rate, or whether the
danger term should scale with how many things can see you rather than firing
once on the first one found. It breaks on the first hit, so a container watched
by four sentries in the open pays exactly what one behind a low crate pays. That
is a design question about how loud the greed pillar should be and I have not
decided it. Also not verified by play: whether the widened spread reads as
"windfalls feel earned now" or just as "windfalls got rarer in the safe half of
the map", which is the same change described from the other side.
### v1.79: the greed dial was pinned at maximum for most of the calls it graded

Direct follow on from v1.78. Turning windfalls on in the sim moved average haul
up 73 percent, and anything keyed to bag value had been calibrated against the
low number. The obvious place to look is greedOf, which divides bag value by a
hardcoded 12,000 and clamps, and which the extraction siege scales off entirely:
the arrival interval is 8 minus 4.6 times greed, the arrival cap is 6 plus 8
times greed, and the ring noise is 1,200 times one plus 0.7 times greed.

I expected the top of the scale to be unreachable. It is the opposite. Over 120
seeded raids on THE QUARRY at simGreed 52, of the 31 raids that called a beacon,
the median call carried 12,118 and 17 of 31, 55 percent, were at or above 12,000.
Average greed came out at 0.934 of maximum. The highest call was 19,954, which
is 66 percent past a ceiling it cannot express.

So greedOf clamped to 1 for the majority of the calls it was asked to grade. A
player calling with 12,000 and a player calling with 19,954 bought exactly the
same siege: same 13 to 14 arrivals, same 3.4 second interval, same noise. The
dial that exists specifically to make greed cost something in proportion had
stopped being proportional and become a constant, which is the same failure the
danger term had in v1.78, arrived at from the other end.

The divisor is now a CFG dial, greedFull, so both arms run in one build, and it
defaults to 20,000 to span the range that actually occurs. Because the dial is
read at beacon call and nothing before it changes, callGreed per seed is
identical across arms, so this is a genuinely paired comparison rather than the
aggregate-only situation v1.78 was stuck with.

Separately, one real bug found by reading the spawner. The arrival counter
incremented before the placement could fail:

    G.siegeSpawned++;
    do{ ss2=freeSpot(G.map,30); st2++; }while(dist(ss2,p)<700&&st2<40);
    if(dist(ss2,p)>=700){ ...spawn... }

A siege that could not find a spot at least 700 units from the player burned one
of its capped arrivals anyway and quietly came up short. The cap is a promise
about how bad the ring gets and a failed dice roll must not pay it off. The
counter now increments only on a successful placement, and two new counters,
siegeArrivals and siegeNoSpot, report how often each happens so the failure rate
is visible instead of inferred.

And then the measurement embarrassed that fix, which is worth recording rather
than quietly dropping. Across 240 raids, 120 a side, siegeNoSpot came back ZERO
in both arms. The bug is real as written and the cap could genuinely be paid off
by a failed roll, but it never once fired under these conditions. I fixed a
defect with a measured incidence of nothing. It stays fixed because it is wrong
either way, but I am not claiming it changed anything, because it did not.

The paired A/B, 120 seeds, THE QUARRY, simGreed 52, greedFull 12,000 against
20,000. The pairing held: 119 of 120 seeds produced an identical callGreed and
the same 31 raids called a beacon in both arms, so this compares the same
decisions rather than merely the same seeds. The single mismatch is the one seed
whose outcome diverged.

Arrivals per call go 6.03 to 4.90, down 19 percent, and the sign is consistent
rather than noisy: 24 seeds down, 6 unchanged, 1 up. That is the gradient coming
back. Under the old divisor the majority of calls were clamped to the same
maximum siege; now what you carry actually selects the intensity.

Survival did not move and I am not going to pretend it did. Extract rate went
15.0 to 15.8 percent, one seed flipped to extract, none flipped to dead, and
deaths in the siege went 12 to 11. On 120 seeds that is nothing. This is the
fourth mechanism aimed at the extraction trip that has failed to move the
outcome, and the reason is the same one measured before and reconfirmed here: 89
of these 120 raids died before ever calling a beacon. Only 31 raids reach the
siege at all, so no amount of tuning it can move the headline number. The siege
is a texture change for the quarter of raids that get there, and that is the
honest description of what this build does.

I also checked the thing I most expected to be broken and it was fine, so I am
saying so plainly: the siege runs during both the inbound wait and the boarding
hold, up to 55 seconds, which makes the caps of 6 and 14 both exactly reachable.
The comment above it is accurate. That check found nothing.

Not verified: whether 20,000 is the right ceiling or merely a better one. It is
fitted to one map at one bot greed setting, and the bot fills its bag by weight
rather than by value, so a real player who leaves heavy cheap items behind will
carry more value per unit weight than this measures and will sit higher on the
scale than these numbers suggest. Also not verified: whether lowering average
siege intensity for the median call is the right trade at all. Restoring the
gradient necessarily makes the typical extraction easier than it was yesterday,
and whether the greed pillar should be a gradient or should simply be loud is a
design question I have not decided for him.
### v1.80: the sim could not measure the half of the game that decides the outcome

v1.79 left a loose thread I could not pull with the tools I had. Of 120 seeded
raids, 89 died before ever calling a beacon, which is why four consecutive
builds aimed at the extraction trip all failed to move the extract rate. So the
question became: what separates the 31 raids that got out from the 89 that did
not?

Almost nothing, is the honest answer, except one thing. Shots fired per raid:
109 dead against 115 survived. Hit rate: 66.8 against 71.1. Kills per minute:
4.46 against 4.49, which is identical. Containers per minute: the dead actually
loot slightly FASTER, 6.09 against 5.66. The survivors are not better shots,
they do not fight more efficiently, and they are not more careful about looting.

The one number that moves is first contact: 67 seconds for the dead against 114
for the survivors. But that number cannot be taken at face value, because it is
censored: a raid that ends at 150 seconds is structurally incapable of recording
a first contact at 200. Longer raids get more chances to have a late contact, so
the correlation is partly an artifact of the thing it claims to explain.

So I ran a landmark analysis instead. Take only raids that survived to time T,
which means every one of them had a full opportunity to be contacted before T,
and split on whether they actually were. That removes the censoring.

    alive at 60s   contacted before: 14.6% extract   not yet: 23.1%
    alive at 90s   contacted before: 17.0%           not yet: 28.9%
    alive at 120s  contacted before: 22.0%           not yet: 30.3%
    alive at 180s  contacted before: 23.8%           not yet: 45.0%

Same direction at all four landmarks, widening as the raid goes on. No single
landmark is significant on its own at these sample sizes; the consistency across
four nested cuts is the signal, not any one row.

And here is the problem, which the code has been stating plainly in a comment
for eighty builds: "The bot never crouches, so this measures exactly the
standing half of the mechanic." Crouch costs 48 percent of movement speed and
buys step noise down from a radius of 170 to 72, removes the periodic footstep
ping almost entirely, and improves the concealment roll from 0.62 to 0.22 while
moving. It is the primary tool a player has for controlling the exact variable
that the landmark analysis says decides the raid. The sim had no access to it.

Every balance conclusion this project has drawn about survivability was drawn
from a bot that walks everywhere upright.

simCrouch is a dial. 0 is the old standing-only behaviour and remains the
default so every historical number stays reproducible. 1 crouches while looting
when a machine is within 700 units. 2 crouches whenever not fleeing; the bot
never crouches while running from something, because that is not what the tool
is for.

Two mistakes of mine, both caught and both worth recording because the second
one is a trap that will recur.

First, mkfixture read the source with Get-Content -Raw, which in Windows
PowerShell 5.1 decodes using the ANSI codepage rather than UTF-8, then wrote it
back with -Encoding utf8. That double encoded every non-ASCII character, so four
hub labels shipped into every fixture with a stray A-circumflex. The game file
itself was never touched and is clean in git; only the test artifact was
corrupt. Both ends now use explicit UTF-8.

Second, and more instructive: I reported that the simCrouch 0 dial was not
neutral, and it is. Two builds served from the same origin share one
localStorage profile, but each tab boots its own copy of it into memory and then
mutates it as raids run. The two tabs had run different numbers of raids, so
their in-memory profiles had drifted apart, and I was comparing two builds
across two different player states while believing I had controlled for it.
Resetting mapIx, body and runs was not enough. Rebuilt as a loop that boots each
build into a fresh iframe from an identical profile, all four bisect variants
including the untouched build then reproduced v1.79 exactly. THE DIAL IS
NEUTRAL. The harness was wrong, not the code.

Then the measurement partly refuted the finding that motivated the whole build,
which is the most useful thing that happened today. 120 seeds per arm, THE
QUARRY, simGreed 52, greedFull 20,000.

                    simCrouch 0     1        2
    first contact     78s          122s     131s
    raid duration    170s          237s     279s
    containers       16.7          16.7     16.7
    extract rate     17.5%         21.7%    14.2%

Crouch does exactly what it promises to the variable the landmark analysis
identified: first contact moves from 78 seconds to 131, a 68 percent delay. That
part is unambiguous and large.

The outcome does not follow. Selective crouching gains 4.2 points and crouching
always LOSES 3.3, which is not even monotone. At 120 a side those are z of about
0.8 and 0.7, so the honest statement is that extract rate is FLAT across all
three arms and neither difference is real.

The mechanism is visible in the other two rows. Containers opened is 16.7 in
every arm, because the bot loots to a goal count rather than to a clock, so
crouching costs no loot at all. What it costs is time: 170 seconds becomes 279.
Crouch buys 53 seconds of not being seen and spends 109 seconds of being on the
surface to buy it. The two cancel.

This is the difference between a correlation and an intervention, and it is why
the landmark analysis was not enough on its own. Controlling for censoring does
not control for confounding: raids where contact comes late may be late-contact
because the spawn was favourable, not because anything the player did caused it.
Crouch is the actual intervention, and the causal effect of delaying detection
turns out to be roughly zero once its price is paid.

That makes five mechanisms now that have failed to move the extract rate, but
this is the first one that failed for a reason I can name rather than shrug at.
It is also direct evidence for the design question already on his desk: the game
punishes time spent rather than value carried, and that time punishment is
currently strong enough to cancel out the primary stealth tool in the game. A
player who uses cover and patience correctly is not rewarded for it. I am not
deciding that; it is his call, and it is now a measured argument rather than an
opinion.

Not verified: any of this for a HUMAN player. The bot loots to a goal count, so
crouching costs it nothing but time; a person who crouches is usually also
choosing to skip containers, take better angles and reposition, none of which
the bot does. The result above says the time cost cancels the stealth benefit
FOR A PLAYER WHO CHANGES NOTHING ELSE, which is not the same claim as crouching
being worthless. Also not verified on the other three maps, and not verified at
any other value of simGreed; the bot's bag threshold interacts directly with
raid length and this whole result is about raid length.
### v1.81: the shop was selling 1,750 credits of nothing

Chased from the v1.80 confound. Containers opened came out at 16.7 in all three
crouch arms, which is only possible if the bot stops looting on something other
than a clock. It stops on bag WEIGHT, at simGreed. That sent me to the weight
system, and the weight system has a hole in it that is not the bot's fault.

PACKCAP is [99999,99999,99999]. That is correct and deliberate: his note on
2026-08-22 was "make it where the backpack is unlimited and you can just take it
all", v1.59 honoured it, and moved the cost of weight onto loadOf so that taking
everything is allowed but expensive. None of that is in question and none of it
changed today.

What nobody went back and checked is that the SHOP still sells backpacks.
Backpack Tier 2 at 450 credits, Backpack Tier 3 at 1,300, gated behind 1,500
rep, rendered in the store as "Backpack Tier 2 (99999wt)". All three tiers are
the same number. The upgrade path costs 1,750 credits and does nothing at all,
and the label is technically honest in a way that reads as a bug report.

A better pack cannot hold more when the old one already held everything, so it
carries the same load more comfortably instead. PACKPEN is [1, 0.80, 0.62] and
multiplies the loadOf penalty. His rule is untouched to the letter: nothing is
ever refused, no pickup is blocked, there is still no wall. Tier 3 does not let
you carry more, it makes 60wt feel like 40. The greed pillar gets the counterplay
it never had, and the progression purchase starts existing.

Two smaller things from the same read. The operator sprite's loaded pose was fed
clamp(bagWeight()/PACKCAP[P.pack],0,1), which after the cap went to infinity is
pinned at about 0.0006, so the character has never once visibly carried anything
regardless of load. It now reads the real speed penalty. And both the shop label
and the loadout line now state the discount instead of printing 99999wt.

Two checks that found nothing, said plainly because a check that finds nothing
is still a result. The HUD weight readout is correct and always has been: it
shows item count, weight, and the live percentage slower and louder straight
from loadOf. And the autoCull and "Bag full" machinery is unreachable dead code
at cap 99999, but that is a direct consequence of his instruction rather than a
defect, so it stays exactly where it is.

Verified neutral: at pack tier 0, PACKPEN[0] is 1 and the build reproduces v1.80
exactly across six seeds, checked with the fresh-iframe harness that v1.80
established rather than the two-tab method that gave a false answer last time.
Anyone who has not bought a pack sees no change whatsoever.

Measured, 120 seeds per tier, THE QUARRY, simGreed 52, greedFull 20,000,
simCrouch 0.

                    T1        T2        T3
    extract rate    15.8%     16.7%     19.2%
    avg haul        7,729     7,992     8,015
    containers      16.7      17.3      17.0
    first contact   78s       79s       80s
    duration        169s      176s      171s

Both extract rate and haul are monotone in tier, which is the shape a working
upgrade should have, and first contact is flat at 78, 79, 80 exactly as it
should be since a pack has nothing to do with being seen.

The effect is NOT statistically established and I am not going to claim it is.
Paired T1 against T3: 110 of 120 seeds have the same outcome, 7 flip to extract
and 3 flip to dead. Ten discordant pairs splitting 7 to 3 is a two-sided p of
about 0.34, which is nothing. The aggregate 3.4 point gap is the same ten seeds
described differently, not independent evidence.

What IS established is the thing that actually mattered: the purchase does
something now. Before this build the effect size was not small, it was exactly
zero by construction, because the number the upgrade changed was the same number
at every tier. Going from provably nothing to probably-slightly-positive is the
result; the magnitude is unresolved.

Not verified: the size of the effect, and it would take far more than 120 seeds
to resolve it, because the limiting quantity is the ten discordant pairs rather
than the sample. A cleaner test would widen PACKPEN and check the direction
holds before trying to pin the number. Also not verified: whether 450 and 1,300
credits are the right prices for a 20 and 38 percent carry discount, which is a
value judgement about his economy that I have deliberately not made, and whether
the discount should scale the noise penalty as heavily as the speed penalty,
since loadOf currently returns both from the same multiplier and a real backpack
plausibly helps you carry weight without doing anything at all about the rattle.
### v1.82: what I called crouch stealth in v1.80 was arithmetic, and the real thing was switched off

Two measurements disagreed and both were mine. v1.59 measured that a heavy bag
makes you 53 percent louder and did not move the extract rate one point across
450 raids. v1.80 measured that crouching moves first contact from 78 seconds to
131 and I reported that as crouch delaying detection. Both cannot be telling the
truth about noise, so crouchParts splits crouch into its three separate effects
and runs them apart: bit 1 the speed cost, bit 2 the step-noise discount, bit 4
the concealment improvement.

    arm                             first contact   duration
    upright                              78s          169s
    full crouch (1+2+4)                 130s          275s
    speed + noise, no conceal (1+2)     132s          279s
    speed + conceal, no noise (1+4)     126s          260s
    noise + conceal, NO speed cost (6)   78s          169s

Every arm that pays the speed cost lands between 126 and 132 seconds. The arm
carrying both stealth benefits with no speed cost is indistinguishable from
walking upright: 78 seconds and 169 seconds duration, matching the baseline to
the second.

So the entire first-contact delay I attributed to stealth in v1.80 is the SPEED
PENALTY. Moving at 52 percent means covering less ground per second and
therefore meeting fewer things per second. It is arithmetic, not concealment.
The concealment multiplier and the step-noise discount together contribute zero
measurable delay. That is a correction to v1.80 and it is the more interesting
result.

Then the reason turned up, and it is not that concealment is worthless. pcon is
genuinely live: it multiplies enemy sight range and the ambient threshold in the
detection call. What the sim never had is this line:

    if(sees&&!G.sim&&(keys['ControlLeft']||keys['ControlRight'])&&dist(e,p)>170)
      sees=false;

Crouching makes you flatly invisible to anything more than 170 units away,
regardless of cones, ranges and concealment values. It is by far the strongest
stealth effect in the game. It was fenced off with !G.sim, and it reads the
player's crouch state off the keys object, which the bot has never touched. So
the sim was structurally incapable of measuring crouch stealth, and everything
it COULD see about crouching was the residue: a concealment multiplier and a
footstep radius, which do nothing on their own.

This is the third time in five builds that the sim has been blind to a shipped
mechanic: windfalls in v1.78, crouch itself in v1.80, and now the rule that
makes crouch worth using. The pattern is always the same shape, an early
performance or determinism guard that quietly became a correctness hole.

v1.82 publishes one G.pCrouch flag from both updatePlayer and updateBot so the
rule has a single source of truth instead of reading the keyboard, and puts sim
access behind crouchParts bit 8. Default remains 7, so the bit is off and every
historical number stays reproducible. The real game is untouched and always had
the rule.

With bit 8 available, the decomposition finishes, 120 seeds an arm, THE QUARRY,
simGreed 52, greedFull 20,000, pack T1.

    arm                        parts   extract   1st contact   never seen
    upright                        -    15.8%        78s            5
    hard rule ALONE                8    42.5%       121s           22
    hard rule + speed cost       1+8    40.0%       193s           35
    hard rule + noise + conceal 2+4+8   45.8%       126s           26
    real crouch, everything       15    41.7%       209s           29

The hard rule on its own takes the extract rate from 15.8 to 42.5 percent. Every
other arm sits within a few points of that, between 40.0 and 45.8, which is the
width of the noise at this sample size. The speed cost is worth about minus 2.5
points and the concealment multiplier plus the step-noise discount together are
worth about plus 3.3. Neither is distinguishable from zero. Crouch IS the hard
rule; the rest is garnish on top of it.

Paired upright against real crouch: 39 seeds flip to extract, 8 flip to dead, 73
unchanged. Forty-seven discordant pairs splitting 39 to 8 is not a close call.
For scale, the five builds before this one moved the extract rate by less than a
point each, and modelling one line that was already shipped moved it 26 points.

One instrumentation bug of mine, caught by the numbers refusing to make sense. I
wrote G.pCrouch=!!CCON, which conflates "the bot is crouching" with "the
concealment bit is enabled", so the first attempt at a hard-rule-only arm
silently never had the hard rule at all and read 10 percent. Corrected to
!!botCrouch and the two affected arms re-run; the numbers above are the
corrected ones. The default path was never affected, because bit 4 is set in the
default 7 and the two expressions agree there.

What this does NOT settle, and it is the whole design question: crouch is
currently a near-invisible dominant strategy. It costs 48 percent of movement
speed and roughly triples survival, and nothing in the game says so. Whether the
answer is to weaken it, to price it higher, to teach it, or to leave it alone as
a skill reward is his call and I have not made it. I have only established that
the sim can finally see it.

Not verified: any of this on the other three maps, or at other values of
simGreed, and in particular whether 170 units is the right threshold. The rule is
binary and total, so the entire mechanic sits on that one constant and nothing
has ever measured it. Also not verified: whether the bot's crouch policy
resembles a human's. It crouches whenever a machine is within 700 units, which
is a far more disciplined player than most, so 42.5 percent is closer to a
ceiling for the strategy than a description of typical play.

Verified neutral against v1.81 across six seeds using the fresh-iframe harness,
identical outcome, haul and duration on every one. Parse PASS at 1.82, all four
maps draw with drawErr null, hub renders.
### v1.83: measuring the one constant the strongest mechanic in the game rests on

v1.82 established that a single line IS the crouch mechanic. Invisibility to
anything further than 170 units while crouched is worth 15.8 to 42.5 percent
extract rate on its own, and every other component of crouch, the speed cost,
the concealment multiplier, the step-noise discount, lands within the noise band
of that figure. So the entire strongest mechanic in the game sits on one integer
that nothing has ever measured.

For scale on why it dominates: default viewFar is 620. A threshold of 170 means
crouching defeats roughly three quarters of the sighting range outright,
regardless of cones, alert state or concealment. It is not a modifier, it is a
switch.

crouchHide is now a dial defaulting to 170, with 0 disabling the rule entirely,
and the sweep runs 0, 90, 170, 300 and 620 at 120 seeds an arm with the real
crouch mechanic active, THE QUARRY, simGreed 52, greedFull 20,000, pack T1.

The sweep, 120 seeds an arm.

    crouchHide   extract   1st contact   never seen   duration   haul
      0 (off)     15.8%       130s            5         275s    7,043
      90          47.5%       249s           45         356s    9,486
      170         41.7%       209s           29         340s    9,092
      300         19.2%       134s            6         291s    7,848
      620         15.8%       130s            5         275s    7,043

Monotone decreasing in the threshold, which is the right direction: the rule
hides you from everything BEYOND the number, so a smaller number hides you from
more of the map.

The useful shape is how violently it turns over between 170 and 300. Going from
170 to 300 costs 22.5 points of extract rate, from 41.7 down to 19.2, and at 300
the mechanic is only 3.4 points better than switched off. Almost the entire
value of crouch lives in the band from about 90 to 200. The shipped 170 is
sitting on the steep face of that curve, not on a plateau, which means the
strongest mechanic in the game is highly sensitive to a constant that was
presumably picked by feel.

A consistency check fell out of this for free and it is worth recording. The 620
arm reproduces the 0 arm EXACTLY: same extract rate, same first contact, same
duration, same haul, same container count, to the digit. That is correct rather
than suspicious. Enemy sight range is about 620, so requiring a target to be
further than 620 away before hiding it can never fire, and a vacuous condition
and a disabled rule are the same thing. Two different code paths agreeing to the
digit is good evidence that this rule really is the only thing the dial changes.

Not verified: the shape of the curve between 90 and 170, which is exactly where
the decision lives and where I have only two points. Nor anything below 90, and
a very low threshold presumably inverts into uselessness at some point since a
machine standing on top of you still sees you. Not verified on the other three
maps, whose viewFar differs by preset, and the 620 equivalence in particular is
a property of THIS preset's sight range rather than a general law. And not
verified against a human: the bot crouches whenever a machine is within 700
units, which is more disciplined than most players, so every number in that
table is closer to a ceiling for the strategy than a description of real play.

Verified neutral: at the default 170 the build reproduces v1.82 exactly across
six seeds, and the check was run at crouchParts 15 so it actually exercises the
edited line rather than a branch that never fires. Durations of 422, 445 and 505
seconds in that sample confirm these were crouched raids and not the upright
baseline wearing a different label.
### v1.84: half of crouch is stealth and the other half is a get-out-of-jail button

Found by reading, not by measuring. The hard crouch rule that v1.82 identified as
the entire crouch mechanic has no awareness condition of any kind:

    if(sees&&G.pCrouch&&dist(e,p)>170) sees=false;

No check on e.alert, none on e.state. A sentry that is actively chasing you from
200 units away loses you the instant you crouch. So crouch is not only a stealth
tool, it is a combat disengage available at any moment at range, and that is a
different mechanic wearing the same button.

crouchBreaksChase separates the two jobs. 1 is the shipped behaviour and remains
the default. 0 makes anything already in 'chase' immune, so crouch still hides
you from things that have not found you and no longer erases a pursuit that has.
120 seeds an arm, THE QUARRY, simGreed 52, greedFull 20,000, pack T1, crouchHide
170, real crouch active.

                        extract   1st contact   duration   haul    downs
    shipped (breaks)     41.7%       209s         340s     9,092   0.61
    chase immune         29.2%       183s         327s     9,106   0.68

Twelve and a half points, and it splits the mechanic almost exactly in half.
Against the v1.82 upright baseline of 15.8 percent: not being found in the first
place is worth 13.4 points, and shaking a pursuer that already found you is
worth 12.5 more. Crouch has been doing two jobs of roughly equal size and only
one of them looks like stealth.

Paired: 32 seeds flip to dead when pursuit can no longer be shaken, 17 flip to
extract, 71 unchanged. Forty-nine discordant pairs splitting 32 to 17 gives a z
of about 2.1 and a two-sided p near 0.03, so this one clears the bar, unlike
most of the effects measured this week. Containers are identical at 19.5 in both
arms and haul is within 14 credits, which is the expected shape: the change does
not alter what the bot collects, only whether it survives to keep it.

Nothing is decided here and the default is unchanged. Whether erasing a chase at
range is a fair reward for accepting 48 percent less speed, or whether it should
cost something, or be limited to enemies that have lost line of sight, is a
design question about what crouch is FOR, and it is his.

Not verified: this is one map at one bot policy, and the bot crouches whenever a
machine is within 700 units, which means it is effectively always holding the
disengage button down. A player who crouches reactively rather than permanently
would see a smaller number. Also not verified: 'chase' may not be the right
predicate. It is the state used when a machine is actively coming for you, but
'hunt' and 'investigate' also describe something that has some idea where you
are, and a stricter or looser choice would move this number.

Verified neutral at the shipped default against v1.83 across six seeds using the
fresh-iframe harness, at crouchParts 15 so the edited line actually fires. Parse
PASS at 1.84, all four maps draw with drawErr null, hub renders.
### v1.85: the four maps are not the same difficulty and nothing had ever measured it

Two things this build. The small one first.

WATER. The noise block says "wading defeats crouch entirely: splashing is loud
whatever you do", and inside the noise system that is true: the footstep interval
drops to 0.30 and the radius goes to 290. But "entirely" is not what happens,
because the rule that actually hides you has never had a wading check. v1.82
measured the noise half of crouch at roughly nothing and the invisibility half at
26 points, so what water currently defeats is the part that does not matter and
what it leaves intact is the part that does. You can crouch-wade across open
water, splashing loudly enough to be heard at 290 units, and stay invisible to
anything past 170. waterDefeatsCrouch is a dial and DEFAULTS TO THE SHIPPED
BEHAVIOUR, because making water genuinely dangerous is a balance change rather
than a typo fix and the comment is ambiguous about whether "entirely" was ever
meant globally. His call, dial ready either way.

A check that found nothing, recorded because it looked alarming: the fixture
profile reads equipped 'fists' with an empty weapons array, which would mean
every combat number this week came from an unarmed bot. It does not. The guard
in buildRaid rolls one of the four issued starters whenever the equipped weapon
is fists or is missing from the armoury, so the bot always deploys armed.

Now the real finding. Crouch had only ever been measured on THE QUARRY, so I ran
upright against crouch on all four maps, 120 seeds an arm, simGreed 52,
greedFull 20,000, pack T1, crouchHide 170, crouchBreaksChase 1. Eight arms.

    map   upright   crouch   gain    flips up/down   1st contact upright
     0     30.8%    45.0%   +14.2      37 / 20             95s
     1     15.8%    41.7%   +25.8      39 /  8             78s
     2     17.5%    45.0%   +27.5      41 /  8             88s
     3     42.5%    54.2%   +11.7      30 / 16             85s

All four gains are significant on their own: z of 2.25, 4.52, 4.71 and 2.06.

The headline is not the crouch column. It is the upright one. At identical
settings the four maps run from 15.8 to 42.5 percent extract rate, a 27 point
spread, and map 3 is close to three times easier than map 1. Nothing in this
project has ever measured that, every balance number I have produced this week
came from map 1, and map 1 turns out to be the hardest of the four. Every
absolute figure in the last eight changelog entries is therefore a
worst-case-map figure rather than a typical one. The A/B comparisons are all
still sound, because both arms always shared a map, but the levels are not
representative and I have been quoting them as though they were.

The second finding is that crouch is a difficulty equaliser. It pays most where
the map is hardest, plus 25.8 and 27.5 on the two worst maps against plus 14.2
and 11.7 on the two easiest, and the result is that the spread collapses from 27
points to 12.5. With crouch the four maps all land between 41.7 and 54.2, which
is another way of saying that a player who crouches is barely playing four
different maps at all.

First contact upright is nearly identical everywhere, 78 to 95 seconds, so the
maps are not differing in how fast you get found. They differ in what happens
next.

Not verified: WHY the maps differ. Enemy counts, layout openness, extract
placement and container density are all plausible and I have measured none of
them; this build establishes the gap exists, not what causes it. Not verified
whether the spread is intentional, since four maps of equal difficulty would be
a strange design goal and 27 points may simply be more than intended. And not
verified for a human: the bot crouches whenever a machine is within 700 units,
so the crouch column is closer to a ceiling for the strategy than a description
of ordinary play.

Verified neutral: waterDefeatsCrouch 0 reproduces v1.84 exactly across six seeds
via the fresh-iframe harness at crouchParts 15 so the edited line fires. Parse
PASS at 1.85, all four maps draw with drawErr null, hub renders.
### v1.86: a clean correlation, a failed intervention, and the spread is still there

v1.85 found that the four maps run from 15.8 to 42.5 percent extract rate at
identical settings and left the cause open. This build went after the cause,
found a very clean-looking answer, tested it, and the test refused to confirm it.
Recording the whole arc because the negative half is the useful half.

MACHINE DENSITY IS NOT THE ANSWER. Per million square units of the span the
containers actually occupy, the four maps carry 3.18, 3.16, 3.38 and 3.31
machines. That is flat. The maps are not guarded differently, and raw enemy
count is actively anti-correlated with difficulty: map 0 fields the most
machines of any map, 62, and is the second easiest, while map 2 fields the
fewest, 45, and is the second hardest.

LOOT DENSITY LOOKED LIKE THE ANSWER. Containers per million: 13.42, 12.16,
10.98, 9.56 for maps 3, 0, 2, 1, against extract rates of 42.5, 30.8, 17.5 and
15.8. Perfect rank agreement across all four. Machines per container tells the
same story inverted: 0.247, 0.261, 0.308, 0.331. The mechanism was easy to
state and sounded right: the bot fills its bag by weight, so a sparse map means
walking further for the same haul, and walking further past a constant density
of machines means more encounters. Difficulty as loot SPACING rather than guard
count.

So I built the test. MAPCONT multipliers behind a lootNorm flag, default 0,
pulling each map toward about 12 containers per million. The dial does what it
claims: density spread narrows from 3.98 to 1.18, at 12.17, 11.98, 11.41 and
12.59, while machine density stays put at 3.18, 3.17, 3.37 and 3.31. Only the
intended quantity moved.

AND THE SPREAD DID NOT COLLAPSE.

    map   shipped   loot-normalised   delta   density change
     0     30.8%        26.7%         -4.1    12.16 -> 12.17
     1     15.8%        25.8%         +10.0    9.56 -> 11.98
     2     17.5%        10.8%         -6.7    10.94 -> 11.41
     3     42.5%        38.3%         -4.2    13.54 -> 12.59

    spread shipped 26.7 points, normalised 27.5 points

Map 1 moved 10 points in the predicted direction on the largest density change,
which is the one encouraging row. Map 3 lost 4.2 on a density cut, also
directionally right. But map 2 GAINED density and LOST 6.7 points, which is
backwards, and map 0's density did not move at all, 12.16 to 12.17, yet its rate
still fell 4.1 points.

That last row is the important one, because it is a direct read of the noise
floor: a 4.1 point swing with no change to the variable under test. At 120 seeds
the standard error on a rate near 30 percent is about 4.2 points and on a
difference of two such rates about 5.9. So map 0 and map 3 are noise, map 2 is
about one standard error, and map 1's plus 10 is about 1.7. Not one of these
clears the bar on its own.

The comparison is also unpaired in the way that matters. lootNorm changes map
generation, so a given seed no longer produces the same raid across arms, which
is the same limitation v1.78 ran into and it removes the per-seed pairing that
made earlier results sharp.

WHAT I ACTUALLY KNOW NOW. The correlation is real and striking, but it rests on
four data points, and a perfect rank agreement among four items happens by
chance one time in twenty-four. The intervention did not reproduce it. The
honest position is that loot density MAY be a contributor, most plausibly on map
1, and that the cause of the 27 point spread is still unknown. I am not going to
write it up as solved because the picture was pretty.

The dial stays in at default 0, changing nothing, because it is the apparatus
for the better version of this experiment rather than a balance change.

Not verified: the whole causal claim, which is the point of this entry. Also not
verified: whether 120 seeds is remotely enough. To resolve a 5 point effect
against a 5.9 point standard error needs several hundred seeds an arm, and the
right next experiment is one map at four or five deliberately spaced densities
rather than four maps at one, since that gives a dose-response curve on a single
geometry instead of one point each on four confounded ones. Not verified on
anything but the upright bot, and crouch compresses the map spread on its own,
so the entire question may matter less for a player who crouches.

### v1.87: the peddler pays more than extracting does, on every map, by the numbers

The peddler had never been audited. He buys anything in your bag at PEDDLER_BUY
and pays instantly, banked the moment the deal closes, so it is yours even if you
die thirty seconds later. The comment above him states the design exactly: "The
bag on your back is worth full price and can be taken from you. His offer is
worth half and cannot."

PEDDLER_BUY is 0.55.

The decision he presents is per item, and it is a straight expected-value
comparison: sell for 0.55 of value with certainty, or carry to the ring for 1.0
of value with probability p. Selling wins whenever p is below 0.55. So the
question is simply whether the survival rate is above or below 55 percent.

    upright bot        map0 30.8   map1 15.8   map2 17.5   map3 42.5
    disciplined crouch map0 45.0   map1 41.7   map2 45.0   map3 54.2

Eight measurements, every one under the break-even. Even the best case in the
project, the easiest of the four maps played by a bot that crouches whenever a
machine is within 700 units, lands at 54.2 against a break-even of 55. And the
entity census says there is exactly one peddler on every raid on every map, so
the option is always available. Emptying your bag to him is the mathematically
correct play in every situation this project has ever measured.

That inverts the premise the whole genre rests on, which is carry it out or lose
it. The risky option is supposed to pay more in expectation than the safe one,
and here it does not.

The honest caveats, because the raw comparison flatters the finding. Extraction
also banks your weapon and your rig, which dying costs you and the peddler does
not replace, and it is the only thing that advances exItem and haul contracts.
Selling is also not exclusive with extracting: you can sell what you are holding
when you meet him and keep looting afterwards, so in practice he is a partial
hedge rather than an alternative ending. The real margin is therefore narrower
than 55 against 15.8 makes it sound. But the per-item bag decision, which is the
one he actually puts in front of you, is not close on any map.

pedBuy is a dial and THE DEFAULT IS UNCHANGED at 0.55, because where the
break-even should sit relative to the survival rate is a question about what the
peddler is for and it is his. Roughly: 0.30 makes him a bad-day escape hatch,
0.55 makes him the optimal line, and anything above about 0.45 still beats the
current rate on three maps out of four.

Verified the dial: a fixed bag of two Data Cores, a Servo, an Optic and a
Circuit Board sells for 562, 1,027 and 1,496 credits at rates 0.30, 0.55 and
0.80. The ratios are 0.547 and 1.457 against the expected 0.545 and 1.454, so it
scales exactly. Note the absolute figure is above face value times rate, because
ival applies its own modifiers on top of the raw table value, but that cancels
out of the break-even entirely since both sides of the comparison use ival.

THREE CONTRACT AUDITS THAT FOUND NOTHING, recorded because a clean audit is a
result and I have been finding defects at a rate that makes silence look like
absence of checking.

First, exItem contracts ask you to extract carrying board, optic, servo or core.
All four are plain loot with no use field, so they land in the bag rather than
being consumed on pickup the way ammo and armour are. Satisfiable.

Second, the open contract asks for N safes, lockers or crates, and it picks the
type without consulting the map, which is the exact shape of the v1.74 district
bug. It is fine here. Worst case across ten seeds a map: safes 31, 19, 14 and
29, lockers 42, 32, 22 and 39, crates 108, 76, 63 and 91, against asks that top
out around six. Nothing close to impossible.

Third, contractExtract has no G.sim guard while contractKill and contractOpen
both have one, which looked like sim raids farming the profile's contracts. They
do not. endRaid returns inside its sim block well before contractExtract is
reached. The other two need their own guards because they fire mid-raid. The
asymmetry is correct.

Not verified: the peddler's actual availability in play. There is one on every
map, but I have not measured how often a real player encounters him, how far off
a natural looting route he sits, or whether he is reachable before the bag is
already full, and all three change the practical size of this. Not verified
either whether the bot ever uses him: the sim's peddler behaviour is not modelled
at all, so none of the extract rates quoted above include selling, which means
they are the rates for players who ignore him. Working out what the rate becomes
when the bot does sell is the obvious next measurement and it needs the bot
taught to trade first.

### v1.88: five notes from him in one sitting, and the cursor one was the real bug

He sent five things while I was mid-measurement. All five are in. Taking them in
order of how badly they were broken rather than the order they arrived.

THE CURSOR. "my mouse grahpic disappeared". This is a genuine trap and not a
cosmetic one. The canvas is styled cursor:none, so the in-game reticle IS the
pointer, and the reticle is drawn only under !keys['KeyM'], because holding M
raises the map. keyup is bound at the window, so any key still down when the
window loses focus never receives its keyup and stays true forever. Alt-tab with
M held, or click into another app mid-press, and the pointer is gone for the rest
of the session with no visible cause and no obvious way back. The same latch is
what leaves sprint or crouch stuck on, which this file has been bitten by before.
releaseAllKeys now runs on blur, on focus, and on the page becoming hidden, and
it clears the key map, the mouse button and the sprint flag together.

THE ZOOM. "zooming with the mouse is janky". The easing was already smooth,
already geometric, already debounced against localStorage, all fixed in an
earlier pass, so the remaining fault was somewhere else: the CAMERA and the ZOOM
were easing at different rates against coupled targets. The camera target was
tx = p.x + lean - VW/2 and VW is W/Z, so every frame the zoom eased it moved the
camera target by a large amount and the camera then chased it at its own slower
rate. At rest the algebra cancels and the player sits at a fixed screen position
regardless of zoom, which is exactly why it looked correct once it settled; it is
only during the ease that the two rates disagree, so the world slides under you
and then settles back. The fix separates what is being smoothed: a world-space
anchor eases toward the player, the cursor lean eases in SCREEN pixels where it
is already zoom-invariant, and the camera is then derived exactly from the
current eased zoom. Nothing chases a target that zoom is moving.

TAB INVENTORY OVER THE WEAPON NAME. It was the only offset in the entire
right-hand stack written in raw pixels while its five siblings all use LH(),
which scales with the UI setting. At 1.0 scale the raw 68 happens to clear the
sidearm line at LH(52) and looks fine. This file supports scales up to 2.09,
where LH(34) is 71, and the weapon name climbs straight through it. Scaled, and
moved clear of the tallest line in the stack.

CONCEALED UNDER THE LEGEND. It was drawn bottom LEFT at x=14, which is precisely
the column the legend panel occupies, and the legend bottoms out at
H - max(LH(52),96) while the label sat at by - LH(62). The legend is on by
default, so that overlap was the normal state of the screen rather than an edge
case. Moved to the right column, stacked above the inventory cue, where nothing
else draws.

WATER. "water should be deeper, go up to character's waist, make character much
slower". Wading was a speed multiplier and a splash radius with nothing on screen
saying so, which makes the cost feel arbitrary rather than earned. The operator
is now clipped at the waterline and the part below it is simply not drawn, with a
dark entry ellipse, a bright meniscus on top of it, and a wake that only appears
while you are moving, so standing still in water is visibly quieter than walking
through it. Clipping rather than compositing a second sprite keeps all of this
inside the existing 2.5D pass: no new layer, no second draw, no renderer change.
Speed goes from 0.55 to 0.34 and is now the wadeSpd dial so the feel is his to
set without going back into the movement code.

One mistake of mine in that last one, caught by measuring instead of eyeballing.
I set the waterline at 17 world pixels on the assumption the operator stands
about 34 tall. Sampling a pixel column straight through the player put the top of
the head 44 screen pixels above the feet at 2x zoom, so the sprite is 22 world
pixels, and 17 was 77 percent up the body: chest height, not waist. WADE_DEPTH is
11, which is half of 22, and the corrected placement was re-measured the same way.

Verified: parse PASS at 1.88, all four maps draw with drawErr null, hub renders,
and a wading raid driven through a zoom sweep from 1.9 down to 0.8 draws clean
with nothing thrown, which exercises the clip path and the new camera derivation
together.

Not verified: any of the four feel changes actually FEEL right, because the
browser pane does not composite while hidden so I cannot screenshot it, and feel
is the whole point of every one of them. The waterline height and the wake are
measured to be geometrically correct and drawn where intended, which is not the
same as looking good. The zoom fix is verified as not throwing and as
mathematically decoupled, not as smooth to a hand on a wheel. He should click the
play link and tell me which of the five still feels wrong.

### v1.89: his 17 real runs land, and two of his complaints were half right in opposite directions

First real telemetry in a long while: 17 runs on v1.87, authenticated by durations
from 25 to 600 seconds, real movement, real shots and real killers. Three exports,
all consumed. The recorder's own verdict is worth quoting because it agrees with
the sim to within a point: 73 percent of his deaths happened before the dropship
was ever called, against 74 percent measured over 120 seeded raids, and its advice
was "fix the looting phase first."

One number in his data that I did not expect and should have: crouch:0s in ALL
SEVENTEEN RUNS. He never crouches. v1.82 through v1.85 measured crouch at roughly
plus 26 points of extract rate, the single strongest mechanic in the game, and he
is playing 5 of 17 without it. That is not a balance problem, it is a teaching
problem, and it is the clearest possible confirmation of the "near-invisible
dominant strategy" note left at v1.82.

LOCKERS. His note: "lockers should onbly be up against the walls". I measured 0
percent of lockers within 26 units of a wall and very nearly reported v1.58 as
regressed. It has not. The control run is what saved it: distance to the nearest
wall averages 28 for lockers against 57 for crates, 39 for safes, 45 for caches
and 85 for bodies, so the wall-hugging pass is working and lockers are by a wide
margin the closest thing to a wall on the map. My threshold was the bug. spotWall
rejects any candidate within pad of a wall and then picks the closest survivor, so
pad is a floor NOTHING can be below, and I had set my test to exactly that floor.

But his perception is still correct, and the pad is the reason: 26 units of clear
floor between a locker and the wall reads as near the wall rather than against it.
A locker sprite is about 13 across, so the pad is now 18, which still cannot
overlap the wall and closes most of the visible gap. Measured after: average
distance to nearest wall 23, down from 28, with the closest now at 9 rather than
26. The corner cases sit closer than the pad because the pad test inflates an
axis-aligned box while the distance is euclidean, which is exactly the behaviour
wanted at a corner.

FURNITURE, AND A DEFAULT I GOT WRONG. His note: "where is the furniteure?". It is
there: 81, 121, 91 and 85 pieces on the four maps. Against 35, 28, 20 and 29
buildings that is three to four per building, which is what the cap of 6 produces
and is too sparse to READ as furnished from inside a room. The obvious fix is more
furniture, so I put density behind furnDens and set it to 1.6.

That was wrong, and measuring the right quantity caught it. v1.62's failure was
never about piece count: pieces went UP 61 to 80 while FURNISHED BUILDINGS went
DOWN 14 of 35 to 9 of 35, because dense rooms sealed themselves and the repair
pass then stripped every piece out of them. So I counted furnished buildings, not
pieces, across 112 buildings on all four maps:

    furnDens 1.0   376 pieces   72 of 112 furnished   64.3%
    furnDens 1.6   442 pieces   57 of 112 furnished   50.9%
    furnDens 2.2   473 pieces   48 of 112 furnished   42.9%

The same failure, reproduced exactly. My 1.6 default would have shipped a map with
14 percent FEWER furnished buildings than today, which is the precise thing he was
complaining about. Reverted to 1.0. Density is not the lever here; the sealing is,
and until placement stops sealing rooms, adding furniture subtracts furnished
buildings. The dial stays so the next attempt starts from measured ground rather
than from a guess.

Also fixed this build, from his five earlier notes, all verified in v1.88: the
latched-key cursor loss, the zoom camera coupling, TAB INVENTORY drawn in raw
pixels among LH-scaled siblings, CONCEALED drawn in the legend's own column, and
water depth plus a wadeSpd dial at 0.34.

Not verified: the crawler DRAWERR, which is the most important thing in his
telemetry and is still open. It fired in 7 of 17 runs, consecutively, runs 7
through 13, and then stopped. A reproduction attempt across 96 raids on all four
maps with 45 drawn frames each produced ZERO instances, so it depends on state a
plain drive does not reach. Weather is the strongest lead, since every failing run
carried a weather tag and the six runs with no tag never failed, but it is not
proven: one fog/noon run failed and another did not. Three suspects have been
cleared by inspection, liftAt, weakOf and drawCrawlerS, and a fourth, the raider
else-branch that caused an identical error before, is still correctly guarded. A
four-angle search with adversarial verification is running against the real file.

Not verified either: whether the locker gap now LOOKS right, or whether 64 percent
furnished reads as furnished. The browser pane does not composite while hidden so
I cannot screenshot, and both of those are perception questions that only he can
close.

### v1.90: the crash in his telemetry was fixed thirty-five builds ago and the recorder never said so

The headline finding from his 17 runs was DRAWERR:crawler in seven of them, and I
treated it as the top-priority live bug. It is not a live bug. It was fixed in
v1.55. The recorder simply reprints it forever.

The mechanism is worth stating plainly because it will keep happening otherwise.
P.log keeps the last 60 runs and lives in the saved profile. The exporter walks
the WHOLE log on every export. So a fault recorded once appears in every report
from then on, with nothing on the line to say which build produced it, and a fresh
export of an old failure is indistinguishable from a new one.

What it cost: I read the seven failures as current, drove 96 raids across all four
maps with 45 drawn frames each looking for a reproduction and got zero, cleared
liftAt, weakOf and drawCrawlerS by inspection, confirmed the raider else-branch
was still correctly guarded, and then had to fan out a four-angle static search
before the actual boundary surfaced. Every one of those steps was sound and none
of them could have found anything, because there was nothing there.

THE BOUNDARY. Cumulative DRAWERR count across his exports, by the build each run
was played on: runs #7 and #8 under v1.53, runs #9 to #13 under v1.54, and then
zero new ones. Run #14 under v1.57, runs #15 to #18 under v1.87, all clean. The
dividing line is the commit titled "v1.55: the crawler crash in his own runs",
which introduced the "else if(e2.kind==='raider')" guard. Seven failures, all of
them before the fix, none after.

THE WEATHER LEAD WAS THE SAME ARTIFACT. I noted that every failing run carried a
weather tag while the six clean early runs carried none, and flagged it as the
strongest lead. It was a version marker, not a cause: wx was only added in v1.17,
so the oldest runs have no tag at all. The direct controls kill it outright, and I
should have run them sooner: #13 fog/noon failed and #14 fog/noon did not, #7
clear/golden failed and #18 clear/golden did not, #11 and #12 blackout failed and
#16 blackout did not, #9 rain failed and #17 rain did not.

THE FIX IS THE RECORDER, not the renderer. Every run record now carries ver:VER,
stamped at the moment the run ends, and the export prints it first on the line:

    #7 v1.54 DEAD [B] wep:Stitcher dur:54s ...

Anything recorded before this build prints "v?", which is itself the signal that
the run predates the stamp. Verified: the export path renders "#1 v? DEAD [B]
wep:Scav Pistol ..." for existing history.

This is exactly the failure the standing instructions warn about, which is that
several of his complaints have already been fixed in later builds and re-fixing
them wastes a session. The instruction says to check each note against the current
code first. I did check the current code, twice, and the code was fine both times;
what I could not do was tell that his DATA was old, because the data did not say.
Now it does.

Not verified: whether any of the other faults in his log are also historical. The
same reasoning applies to every line in every export he has ever sent, and I have
no way to re-date the existing entries because the stamp only starts from here.
The practical consequence is that the "character not rendering" note on run #3 and
anything else from the low-numbered runs should be treated as undated rather than
current until he reproduces them on a v1.90 or later run.

AND THE V1.03 ENTRY IN THIS VERY FILE SETTLES IT. The v1.03 section above records
"his first v1.01 recorder data" with these notes: "looting feels so uninspired",
"character not rendering (run #3, abandoned)", and "every block is the same
length, map has no atmosphere, needs verticality". Those are verbatim the notes on
runs #1 and #3 of the export he sent today. His first three runs are from the
v1.01 era, were read and acted on at v1.03, and have been reprinted in every
export for eighty-seven builds since. There is no better demonstration of why the
stamp was needed.

Addendum, from an adversarial pass that tried to refute the crawler conclusion and
could not. Three pieces of evidence turn the boundary from strong inference into
proof, recorded because the next person to see DRAWERR in an export will want them.

First, .kind is never assigned anywhere in the file. A word-boundary search for an
assignment rather than a comparison returns ZERO hits across all 12,498 lines;
every occurrence is ===. An entity cannot change kind at runtime, so a draw item
holding a crawler can never reach the raider branch by any path.

Second, both guards landed in the same commit. git show of 0f43a6b, "v1.55: the
crawler crash in his own runs", removes the bare clamp(e2.bag.length/7,0,1) and
adds BOTH the else if(e2.kind==='raider') kind test AND the inline
(e2.bag?e2.bag.length:0) fallback. Two independent fixes for one fault, which is
why nothing has recurred in 35 builds.

Third, the weather red herring is datable. git log -S on the wx export field
bottoms out at f1789b6, "v1.17: the recorder learns the new systems". The apparent
weather correlation is nothing but the overlap window between v1.17, when the tag
started printing, and v1.55, when the crash stopped happening.

Also recorded so it is not rediscovered as new: line 7215 reads e.bag.length with
no inline guard, in the death and drop path. It is gated on kind==='raider' so it
is safe by the same argument, and it is not in the y-sorted draw loop, so it could
never produce a DRAWERR label at all.

### v1.91: you choose the two guns now, and most of his list turned out to be ghosts

His note: "'better guns autoequip' -- no. you should be able to carry all the guns
you want but you only have 2 equipped, then we need a way for you to change the 2
you have equipped."

Two of those three already existed. There have been two slots since early on,
p.wep and p.sec, swapped with X, and the bag has been uncapped since 2026-08-22.
What was missing was the CHOICE: a better gun equipped itself the instant you
picked it up, so the loadout was decided by pickup order rather than by you.

autoEquip is a dial and defaults to 0, off. A found gun now goes into the bag like
any other item. Inside the inventory, 1 puts the selected gun in your hands and 2
puts it on your back, and whatever was in that slot goes back into the bag, so the
exchange never destroys anything.

The one exception is issued kit, and it is deliberate rather than an oversight.
The four starter rifles and the Scav Pistol are loaners, and the pickup path has
refused to bank them since an old audit found that banking one silently ended the
fresh starter roll forever, because owning a copy made it your permanent equipped
gun from then on. equipFromBag keeps that rule: displace an issued gun and it is
left behind with a line saying so; displace a found one and it returns to the bag.

Verified as a chain rather than as three separate assertions, because the property
that matters is that nothing is ever lost:

    start                     Stitcher in hands, issued, bag [carbine, smg]
    1 on carbine              primary Burst Carbine, Stitcher LEFT BEHIND (issued)
    1 on smg                  primary Compact SMG, carbine RETURNED to bag
    2 on carbine              secondary Burst Carbine, Scav Pistol left behind (issued)

A key conflict came with it and is fixed. The hotbar handler took every digit and
ran before the inventory, so with the bag open one press of 1 would have both
moved the hotbar selection and equipped a gun. It is now gated on the bag being
closed. Verified both directions: with the bag open, Digit1 equips and the hotbar
does NOT move; with the bag closed, Digit2 moves the hotbar as it always did.

THE REST OF HIS LIST, DATED. The v1.90 version stamp paid for itself immediately.
Running git log -S against each complaint puts almost all of them before the fix
that answered them:

  "random lights floating in the air"        run #7, v1.53   fixed in v1.55
  "deer stuck in a small area, spastic"      run #7, v1.53   fixed in v1.55
  "too many animals"                         run #7, v1.53   touched in v1.53
  "looting feels so uninspired"              run #1, v1.01   logged at v1.03
  "character not rendering"                  run #3, v1.01   logged at v1.03
  "needs verticality, hills, woods"          run #3, v1.01   logged at v1.03, still his call
  "snitch too easy to kill"                  run #14, v1.57  possibly still live
  "lockers / where is the furniture"         run #14, v1.57  live, handled at v1.89

Both the lamp posts and the deer home range were fixed in the same commit as the
crawler crash, 0f43a6b, whose title is "v1.55: the crawler crash in his own runs,
and eight things he asked for". Run #7 is the run where he asked for them. His
export has been reprinting the request every session since the session that
granted it.

So of everything in the seventeen-run export, only the snitch note is plausibly
still open. Everything genuinely outstanding is what he typed directly today, and
those are dated by definition.

Not verified: whether 1 and 2 are the right keys. They are the digits the hotbar
already owns, and the guard makes them mean different things depending on whether
a panel is open, which is the kind of overload that reads fine in a changelog and
badly under the hand. If it feels wrong, the alternative is a dedicated key that
cycles the slot, at the cost of not being able to name the slot directly. Also not
verified by play: whether losing auto-equip makes the early game worse, since the
upgrade-on-pickup rule was load bearing for a long time and a player who never
opens the inventory will now carry a starter for the whole raid.

### v1.92: the animals were bulletproof

His note: "you should be able to kill animals". They were not merely tough, they
were untouchable. G.wild had no hp field and no bullet in the file ever tested
against it, so a round fired point blank at a deer standing in the open grass
passed straight through it and carried on. The only thing wildlife has ever done
is flinch when something frightened it.

Deer take 34, birds take 8, both roughly two rifle rounds and one respectively.

The hit test is placed AFTER the machine loop and behind a !hit guard, which is
the part that matters and the part that could have gone wrong. A bird drifting
between you and a sentry must never eat the round you aimed at the sentry.
Verified adversarially rather than assumed: with a bird parked directly in front
of a machine, the shot took 12 off the machine and the bird lived; with no
machine anywhere near, the same shot killed the bird. Set dressing cannot
intercept a shot that matters.

Shooting one panics everything within 420 units, which is the cost of hunting.
A herd breaking is visible a long way further than the animal you actually hit,
so taking the shot tells anything watching that direction where you are, on top
of the gunshot itself.

A dead deer leaves a carcass container holding Field Dressed Meat, 45c for 2wt.
That is deliberately poor. It is worse per unit of weight than nearly anything
else you can pick up, because hunting should be texture and a mercy on a bad run
rather than an income, and the shot that got it has already cost you more in
noise than the meat is worth.

Dead animals stop ticking entirely, no wander, no flee, no wall test, no home
range, but they still sort and draw, because the carcass lying in the grass is
the whole visible reward. It draws as a flat dark shape with the ground stain
under it and, on a deer, two stiff legs out to one side.

Verified end to end on a real raid: three rounds of 12 against 34 hp killed a
deer at minus 2, the carcass container spawned at its position holding meat, the
one other animal inside the panic radius was set fleeing, telemetry counted
wildKilled 1, and fifteen drawn frames afterwards came back with drawErr null.
Six carcasses forced onto the ground on a separate raid also drew clean, as did
all four maps and the four hub screens.

One thing that slowed this down and is worth recording for next time: __sim does
NOT advance bullets. It calls refreshVseg, updatePlayer, updateEnts and
updateThrowables, and __rawStep is simStep, the bot path. Neither moves a round.
The hook that does is __bullets(dt). My first attempt fired twelve rounds into a
deer and reported it unkillable, when in fact no bullet had moved at all.

Not verified: whether killing animals is worth doing, which is a feel question
and the meat value is a guess. 45c is set low on purpose but I have no play data
on whether that reads as a fair trade for the noise or as pointless. Also not
verified: whether birds at 8hp are too easy to hit with a shotgun, since the
pellet loop fires one bullet per pellet and every one of them now tests against
wildlife.

### v1.93: furniture against the walls, and every other note in his export was already fixed

Two things. The audit first, because it is the larger result.

EVERY NOTE IN HIS SEVENTEEN RUN EXPORT HAS ALREADY BEEN ANSWERED. Dating each one
against the build it was played on, using the v1.90 stamp and git log -S:

  looting feels so uninspired          run #1   v1.01   logged at v1.03
  character not rendering              run #3   v1.01   draw loop armoured, v1.03
  needs verticality, hills, woods      run #3   v1.01   logged, gated on him
  30 seconds to get back in the ring   run #4   early   already the rule, hold is min(30,...)
  not enough enemies                   run #4   early   counts raised v1.53
  extract while downed                 run #5   early   already in, cites run #5 by number
  random lights floating in the air    run #7   v1.53   fixed v1.55
  deer stuck in a small area, spastic  run #7   v1.53   fixed v1.55
  too many animals                     run #7   v1.53   fixed v1.53
  raiders should drop better loot      run #8   v1.53   fixed v1.58
  attack cones visible through walls   run #8   v1.53   fixed v1.55
  snitch too easy to kill              run #14  v1.57   fixed v1.58
  lockers should be against the walls  run #14  v1.57   fixed v1.58
  where is the furniture               run #14  v1.57   LIVE, this build

Two commits did nearly all of it: 0f43a6b "v1.55: the crawler crash in his own
runs, and eight things he asked for" and 9734e68 "v1.58: raiders stop dropping
junk, lockers move to the walls, the snitch weaves". Both of those titles name
his complaints directly. Several of the fixes carry his run number in a comment,
which is how the snitch and the downed-extract ones were caught: the code says
"his note on run #14" and "per his run #5 note" in so many words.

His export reprints all sixty stored runs every time, so a request keeps arriving
long after the session that granted it. That is what v1.90's version stamp was
for and it has now paid for itself twice over in one day.

THE ONE LIVE ITEM. "where is the furniteure?" measured true at v1.87 and this
build is its fix. v1.89 established that density is not the lever, by reproducing
the v1.62 failure exactly: raise it and pieces go UP while FURNISHED BUILDINGS go
DOWN, because extra pieces land free-standing in big rooms, seal them, and the
repair pass strips every piece from the whole building.

The cause turned out to be a gate. There was already a wall-hug, added after
v1.62, but it ran only on SMALL rooms, on the reasoning that a table in the
middle of a hall is the point. That reasoning is correct for one table and wrong
for five. A big room now keeps its centrepiece and every piece after the first
goes against a wall, where it cannot split the room and so cannot seal it.

Measured over 112 buildings on all four maps, eight seeds each:

    hug  dens   pieces   furnished   pct
     0   1.0     366        69      61.6      <- what he played on v1.87
     0   1.6     434        57      50.9
     0   2.2     475        47      42.0
     1   1.0     423        81      72.3
     1   1.6     611        78      69.6      <- new default
     1   2.2     710        69      61.6

At equal density hugging is a strict win on both axes at once, 366 to 423 pieces
AND 69 to 81 furnished buildings. And it transforms the scaling: at 2.2 the old
rule gave 475 pieces in 47 buildings, the new one gives 710 in 69, which is
nearly double the furniture for the same furnished count as the old baseline.

MY PREDICTION WAS HALF WRONG AND I AM NOT GOING TO ROUND IT UP. I predicted that
with hugging, density would start RAISING furnished buildings. It does not. The
count still falls, 81 to 78 to 69. The fall is much gentler, minus 12 across the
range against minus 22 before, but it is still negative. Hugging reduces the
sealing; it does not eliminate it. Something else is still closing rooms at high
density and I have not found it.

The default goes to 1.6 because that is a strict improvement on every axis
against what he actually played: 611 pieces against 366, 78 furnished buildings
against 69, and 7.8 pieces per furnished room against 5.3. This time the number
is measured. At v1.89 I set the same 1.6 blind, without hugging, and it was flatly
wrong: it would have shipped 14 percent FEWER furnished buildings.

Reachability checked before shipping, because that is the metric v1.62 actually
broke, 99.07 to 98.42 by minting slivers of floor behind furniture. At body scale,
12 unit cells, 12 raids per configuration: 99.50 percent on what he plays now,
99.40 at hug with density 1.0, 99.53 at the new default, 99.29 at 2.2. The new
default is the highest of the four and nothing is close to the v1.62 failure.

Two harness mistakes of mine getting to that number, both caught by the output
being absurd rather than by care. The first flood fill tested every cell against
every wall, roughly eight million checks a raid, and would never have finished. The
rewrite rasterised walls into the grid but used 40 unit cells with 8 units of
padding, so a 10 unit wall blocked a 40 unit cell, 600 walls chopped the map into
islands, and it reported 8 to 21 percent reachable. A number that far from the
known 99 is a broken instrument, not a discovery. Third attempt at body scale
matches the historical figures.

Not verified: whether 7.8 pieces in a room reads as furnished to him, which is
the entire point and is a perception question I cannot answer from a fixture. Also
not verified: what is still sealing rooms at high density. The gentler slope says
the remaining cause is smaller than the free-standing one, not that it is gone,
and until it is found the density dial has a ceiling somewhere below 2.2.

### v1.94: one unreachable cell was costing a building all of its furniture

v1.93 left a loose thread I made myself. I predicted that once furniture hugged
the walls, raising density would start RAISING furnished buildings, and it did not:
81, 78, 69 as density went up. Gentler than the minus 22 before it, but still
falling, and I said at the time that something else was still closing rooms.

This is that something, and it is not a sealing bug at all. It is the penalty.

    if(sealed>0){ bad[bi]=1; any=true; }
    ...
    if(walls[wi].furn&&walls[wi].ib!==undefined&&bad[walls[wi].ib]) walls.splice(wi,1);

The building is marked bad on a SINGLE unreachable cell, and then every piece of
furniture in it is removed. One table making one 1-cell pocket in the corner of a
hall costs that hall all six of its pieces. The threshold was deliberately set to
zero at some point, on the correct reasoning that even a 1-cell pocket is floor a
player can see and never stand on, but the RESPONSE to crossing it was never
scaled to match. Zero tolerance plus total punishment.

That also explains the exact shape v1.93 produced. Hugging stopped pieces from
splitting rooms, which is why the slope got much gentler, but every additional
piece is still one more chance to mint a pocket somewhere in the building, and one
pocket still took everything. So the count kept falling.

Now the repair removes only the pieces adjacent to the unreachable floor. The
blanket strip is kept directly underneath as the fallback for a building still
sealed after that, and the partition strip behind it, so the safety net is exactly
as strong as it was and only the collateral damage is gone.

Measured, 112 buildings over four maps, eight seeds each, hugging on in both arms:

    repair  dens   pieces   furnished   pct     reachable
      0     1.0     424        81      72.2       99.43
      0     1.6     582        74      66.1       99.49
      0     2.2     722        71      63.2       99.51
      1     1.0     449        91      80.8       99.32
      1     1.6     669        90      80.0       99.47     <- new default
      1     2.2     776        87      77.9       99.37

At every density targeted repair wins on both axes at once, ten to sixteen more
furnished buildings AND more pieces surviving.

The slope is now essentially flat: 91, 90, 87. A fall of four across a 2.2x
density range, against twelve at v1.93 and twenty-two before any of this. I
predicted it would start rising and it does not; what it does is stop falling,
which is the outcome that actually matters and is close enough to the prediction
that I will call the diagnosis confirmed rather than press the point.

Against what he actually played on v1.87: 366 pieces in 69 furnished buildings at
5.3 pieces a room, now 669 pieces in 90 furnished buildings at 7.4 a room. Eighty
three percent more furniture, twenty one more furnished buildings, forty percent
more in each room you walk into. Reachability 99.47 against 99.50, unchanged
within noise, and every cell in the matrix sits between 99.32 and 99.51 so nothing
here is near the 98.42 that v1.62 caused.

Not verified: whether any of this reads as furnished to him, which is the whole
point and cannot be answered from a fixture. Also not verified: the remaining four
building fall from 1.0 to 2.2. It is small enough to be noise at eight seeds a
cell and I have not chased it, so the density dial still has an unmeasured ceiling
somewhere above 2.2 rather than a proven one.

### v1.95: the bot can trade, and the harness I have been measuring on was leaking

v1.87 established that the peddler's 0.55 beats every survival rate on every map,
and closed by saying the sim could not model using him, so every rate quoted was
the rate for a player who ignores him. This build fixes that, and finding out how
badly took three attempts and turned up something worse than the original
question.

FOURTH GUARD, SAME SHAPE. The peddler was gated out of the sim entirely:

    // decision is live. Never in the sim. The bot has no trade logic, so a
    // neutral body in the crowd would only muddy the balance numbers.
    if(!sim){ ... mkPeddler ... }

True when written, and now the exact thing standing in the way. That is windfalls
at v1.78, crouch at v1.80, the hard crouch rule at v1.82, and now this. Every
performance or determinism guard in this file eventually becomes a correctness
hole, and the tell is always the same: a comment explaining why the sim does not
need to model something the player relies on.

pedSellAll is sim safe now. A headless batch must never credit P.credits or call
saveProfile, or it pays him for raids he never played and writes the profile
hundreds of times a batch. Verified: profile untouched across both arms.

THREE ATTEMPTS, AND THE FIRST TWO WERE MY OWN FAULT.

Attempt one: the policy diverted the moment the bag was worth 1,500, and the
peddler sits about 1,700 from the drop, so the bot abandoned looting immediately
and marched across open ground. Containers 15.2 to 6.9, duration 175s to 102s,
extract 20 to 5.8 percent, and only 11 of 120 raids ever arrived. That is a
measurement of a bad player, not of the peddler, and reported as-is it would have
condemned his price for reasons that have nothing to do with the price. Fixed with
a proximity gate: sell when the stall is on your way, within 700, which is what a
person does.

Attempt two: spawning the peddler was gated on simSell, so the selling arm drew
random numbers at map build that the ignoring arm did not, and the same seed
produced a different raid. It reported extract rate moving 20 to 10.8 percent on
the strength of 5 raids out of 120 that actually sold, which is arithmetically
impossible. Exactly the v1.78 trap. simPed and simSell are now separate: he is on
the map in both arms, and only whether the bot walks over differs.

AND THEN THE HARNESS ITSELF. Chasing attempt two I checked determinism properly
and found this:

  one seed replayed three times, resetting body and runs:  IDENTICAL
  six seed batch run twice, resetting the usual four:      DIVERGES
  six seed batch run twice, restoring the WHOLE profile:   IDENTICAL
  fields of P observably changed by a batch:               NONE

The last two contradict each other and I do not yet know why. Restoring P
wholesale fixes it while nothing in P appears to change, which means either the
JSON diff is blind to something, a removed key or an identity rather than a value,
or the leaking state is not in P at all and the restore is fixing it by side
effect. A once-per-session cache that consumes randomness the first time it is
built would fit every observation including that the later seeds in a batch
converge while the first few differ. A four angle search with adversarial
verification is running against the file.

The practical consequence is stated plainly because it touches my own past work:
every multi-arm batch this session started arm two from whatever arm one left
behind. The large effects are far too big to be leakage, crouch at plus 26 points
and targeted furniture repair at plus 16 buildings among them, but the small ones
deserve less confidence than I gave them and I will say which once the cause is
known. From here the standard is a full profile snapshot restored before every
arm, which is proven stable.

THE RESULT, on the stable harness, peddler present in both arms, 120 seeds:

                    ignore    sell
    extract rate     12.5%    10.8%
    containers        15.4     14.7
    duration          173s     176s
    raids that sold      0        5
    avg realised      1501     1376

Paired: 84 of 120 seeds byte identical, which is the correctness check, since a
seed where the bot never meets him must produce the same raid in both arms. 107
of 120 realise the same credits. Eight better selling, five worse.

The number that matters is the five seeds where he actually sold. On every one of
them the bot DIED IN BOTH ARMS. Ignoring him realised zero. Selling realised 4,866
each. That is the peddler doing exactly what the comment above him claims: the bag
on your back is worth full price and can be taken from you, his offer is worth
half and cannot. On a raid you were going to lose, half of something beats all of
nothing, and this is the first direct measurement of it rather than an argument
from the break-even.

Not verified: whether the aggregate is positive, because the policy diverts on
roughly thirty percent of seeds and closes a sale on four. The extract difference,
12.5 against 10.8, is fifteen extractions against thirteen and is noise at this
sample. Also not verified, and still deliberately his: whether 0.55 is the right
number. This build measures what the rate does, it does not choose it.

### v1.96: I raised a false alarm about the harness, and found a real bug underneath it

RETRACTION FIRST. At v1.95 I reported that two identical sim batches diverge when
only the usual four profile fields are reset, and told him that every multi-arm
batch this session had been leaking state between arms and that the crouch, greed,
pack and furniture numbers deserved less confidence. That was wrong.

Two independent attempts to reproduce it both come back clean:

  eight seed batch run twice, seeds recorded per raid, four field reset:
    all eight identical, all seeds matching, first divergence index -1
  four runs interleaved, peddler off twice then on twice:
    pedOffStable true, pedOnStable true

I cannot reproduce my own finding and I do not know what was wrong with the test
that produced it. What I can say is that the reset works, that I should have
isolated before raising the alarm rather than after, and that the measurements
stand as originally reported. The full-profile-restore harness costs nothing and
removes the question, so it stays as the standard, but it is now a belt rather
than a fix for a hole.

Twenty candidate explanations were generated and every one was refuted under
adversarial verification, which is the correct outcome when the phenomenon does
not exist. The sweep was not wasted though, because one of the refutations
contained a real defect that nothing else would have found.

THE REAL BUG. G is assigned in exactly four places in the file: 5302, 8244, 8529
and 12729. buildRaid spans 4680 to 5300. So G is not assigned until AFTER
buildRaid returns, and every (G&&G.sim) test evaluated during map construction is
reading the PREVIOUS raid's object.

mkRaider is called from buildRaid at line 5051 and line 4363 read:

    var rec=(G&&G.sim)?{kills:0,deaths:0,met:0,standing:0}:idRec(ident.id);

That guard has never once seen the raid it is building. In real play G held the
previous raid, whose sim flag was false, so the idRec branch was taken and it
looked correct by accident. In the headless batch G is null between seeds, so
(G&&G.sim) is falsy there too, and SIM RAIDERS HAVE ALWAYS READ THE LIVE GRUDGE
RECORDS the guard exists to shield them from. Every balance number involving
raiders was measured against whatever grudges his profile happened to be carrying.

Fixed by passing the sim flag down as a parameter instead of inferring it from a
global that is not set yet.

Verified positively rather than by absence. Eight real identities, read back from
a live raid, loaded with kills 5, deaths 2, met 9, standing 6, then a four seed
batch run against a neutral roster and against the grudged one:

    neutral   dead:3649:190 | dead:152:85 | dead:9184:315 | dead:3247:144
    grudged   dead:3649:190 | dead:152:85 | dead:9184:315 | dead:3247:144
    new grudge records created by the sim: 0

Zero records created is the decisive half. The sim now takes the neutral literal
branch and never calls idRec at all, so it cannot read or create a record. Before
the fix it called idRec on every raider it spawned.

Second, smaller fix in the harness. __simSeedsFull relied on G being null, which
held only because the loop nulls it at the end of each iteration. A played raid, a
__newRaid, or an exception thrown mid loop would leave G non-null and the next
batch's first seed would be built against it. G is now nulled immediately before
each build, so that is a guarantee instead of a side effect.

Not verified: how much the grudge leak actually moved past numbers. Raiders are 5
to 8 of roughly 60 entities on a map and grudge only changes their opening
disposition, so the effect is probably small, but "probably small" is a guess and
I have not measured it. Anyone re-deriving a raider-specific number from before
v1.96 should re-run it. Also not verified: what was wrong with the v1.95 test that
started all this. It is not reproducible and I have stopped chasing it rather than
keep spending on a phenomenon I cannot demonstrate.

### v1.97: the grudge leak measured, and crouch finally has a tell

TWO THINGS OWED FROM v1.96, both closed.

FIRST, A CHECK THAT FOUND NOTHING, recorded because it could easily have found
something. The dead guard fixed at v1.96 read G during map construction, when G
still holds the previous raid. If mkRaider did that, its siblings might too. They
do not. mkSentry, mkCrawler, mkSnitch, mkPeddler, mkWarden, mkListener,
mkContainer, setLoot, rollLoot and mkStrongbox contain no reference to G at all.
The other G.sim reads I traced, in wxTick, listenersHearInner, strayGive and
wildTick, all run at raid time when G is properly assigned. mkRaider was the only
one.

SECOND, THE SIZE OF THE LEAK, which v1.96 left as an explicit guess. I wrote that
the effect was "probably small" and flagged it unverified. Measured now, v1.95
against v1.96, 120 seeds each, run twice per build with a neutral grudge roster
and with a realistically loaded one:

                        seeds changed by grudges   extract   haul
    v1.95, leaking            116 of 120            20.8%   8,136 -> 8,341
    v1.96, fixed                0 of 120            20.8%   8,136 -> 8,136

Both halves of my guess were wrong, in opposite directions. Ninety seven percent
of individual raids changed depending on what grudges the profile happened to
carry, which is far more pervasive than "probably small". But the aggregate was
UNBIASED: extract rate identical to the decimal, haul moved 2.5 percent, inside
the noise band this project works in.

And the reason no past conclusion is affected is structural rather than lucky.
Every write to the grudge table is correctly guarded by !G.sim at a point where G
IS assigned, so a sim batch reads the table but never mutates it. Both arms of
every A/B ever run therefore saw the SAME grudges. Constant contamination across
arms is exactly the condition under which a paired comparison survives, which is
why the v1.95 numbers hold. The zero in the v1.96 row is the other half of the
proof: the fix does what it claims, grudges can no longer reach a sim raid.

CROUCH HAS A TELL NOW. v1.82 measured the hard crouch rule at 15.8 to 42.5 percent
extract rate on its own, the largest single effect in this file by a wide margin,
and v1.84 split it roughly evenly between not being found and shaking a pursuer
that already found you. His own seventeen run export reads crouch:0s in EVERY
RUN. He has never once used it.

Nothing on screen has ever suggested he should. The only concealment readout in
the game fires when you are standing in a bush, so the strongest mechanic
available has been completely silent. That is a teaching problem and not a
balance one, so this changes no number: it reuses the readout that already exists
and reports the state you are actually in.

    CROUCHED  UNSEEN      nothing inside the hide radius, so nothing beyond it
                          can see you at all
    CROUCHED  TOO CLOSE   something is inside it and the rule does not apply
    bush wording          unchanged when standing

Verified in all three states with drawErr null, and verified as draw-only rather
than asserted: v1.96 and v1.97 produce byte identical results across 60 seeds,
which is what it means for a change to touch the HUD and nothing else.

Not verified: whether the wording teaches him anything. "CROUCHED TOO CLOSE" is
trying to say two things at once, that you are crouched and that it is not helping
here, and it may read as a warning to back off rather than as an explanation of a
threshold. Also not verified: whether a readout is enough at all, since he has to
be crouching already to see it, and the thing he never does is press the key. A
first-raid prompt would reach him and a HUD label may not.

### v1.98: the looting decision does not exist on most containers, and my fix for it did not earn its place

His recorder's own verdict was "fix the looting phase first" and his note was
"looting feels so uninspired, how can we make it more interesting???". This build
is the measurement behind that, plus an attempted fix that I built, measured and
then defaulted back off.

WHAT LOOTING ACTUALLY PAYS. Every container on all four maps, six seeds each,
priced through ival so rarity and market modifiers are included:

    type     avg     per second   under 150c   single item   median gain
    crate    101c      72/s         81.8%        49.3%           0
    body     242c     242/s         38.5%        50.7%           0
    locker   357c     162/s         26.3%        32.4%          48
    safe   1,614c     475/s          0%           0%           508
    cache  4,399c     956/s          0%           0%         1,102

The first three columns are defensible tiering: the common thing pays less than
the rare thing. The last two are not.

v1.61 sorts container loot worst first and describes that one line as "what turns
a search from a hold-to-collect into a decision... every container asks the same
question the raid asks: is one more thing worth the time it costs." Measured, that
question is only ever asked by safes and caches. Half of all CRATES hold a single
item, so there is no second thing to stay for, and the median gain from finishing
the bar on a crate is exactly zero. Crates are about 48 percent of every container
in the game and bodies another 10, so on roughly 58 percent of what you open the
decision the design is built around cannot fire at all.

THE FIX I TRIED. A crate always holds two. Cheapest possible change: it touches no
loot table and no item value, it converts an existing one-or-two roll into two.

It did exactly what it was designed to do:

    single-item crates       51.4%  ->  0%
    crates with no gain      62.5%  ->  19.2%
    average crate value        99c  ->  134c

AND IT IS STILL NOT WORTH SHIPPING. The decision it creates is not worth making.
The second item averages 35 credits against a first item of 56, so the question
becomes "is another 35c worth 0.7 more seconds", which is the same non-decision
wearing a second coat. Giving him two worthless things instead of one worthless
thing is not an answer to "uninspired".

And it costs. Over 120 seeds an arm:

                  extract    haul      containers   duration
    crateMin 1     20.8%    8,136        16.1        178s
    crateMin 2     16.7%    7,764        16.0        183s

Haul fell 4.6 percent, which surprised me and has a clean mechanism: the bot fills
its bag by WEIGHT, so an extra near-worthless item displaces better loot it would
otherwise have carried out. Adding volume to a weight-capped bag makes the bag
worse. The extract difference is 25 extractions against 20 at 120 seeds and sits
inside the noise, so I am not claiming it.

So the default goes back to 1 and the dial stays. This is a negative result and
the honest version of it is that I fixed the letter of the v1.61 mechanic and not
its spirit.

WHERE THE REAL PROBLEM IS. Not the count, the contents. 81.8 percent of crates pay
under 150c and they are half the containers in the game, so the modal looting
experience in Dark Raiders is opening something worth 76 credits. The fix has to
change what a crate can CONTAIN, or widen its variance so that a few are genuinely
worth stopping for, which is what v1.78 already argued when it said the thing that
makes loot exciting is variance you caused. Both of those are balance decisions
about how the economy should feel, and they are his, not mine.

Verified: parse PASS at 1.98, four maps draw with drawErr null, hub renders, and
the default really is restored, 46.2 percent of 630 sampled crates hold a single
item again.

Not verified: whether widening crate variance would actually feel better, because
I have not built it. Also not verified: whether the 4.6 percent haul drop would
persist if the second item were valuable rather than junk. The weight-displacement
mechanism predicts it would not, since a heavy valuable item earns its place in
the bag, but that is reasoning rather than measurement and the moment I test it I
am choosing an economy, which is the part I am leaving to him.

### v1.99: I broke the Warden's promise at v1.88 and did not notice for eleven builds

The Warden carries one of the most specific promises in the file, written into its
own movement code: "Never faster than a walk, never gives up. The threat is a
tide, not a sprinter, so avoiding it is always a live option." That is a claim
about two numbers, and the numbers live about 2,000 lines apart.

Warden speed is 36. Player base is 158, so walking away is trivially possible and
the promise looks safe. It is not, because every slow effect on the player
MULTIPLIES:

    walking, empty                158.0    4.39x the Warden
    walking, 120wt                 98.0    2.72x
    wading, empty                  53.7    1.49x
    wading, 120wt                  33.3    0.92x   <- Warden is faster
    wading + crouch, 120wt         17.3    0.48x
    wading + crouch + ADS, 120wt   10.7    0.30x

Below 36 the Warden simply walks you down. There is no counterplay: it never
gives up, so a heavily loaded player caught in water is dead, and a crouched one
is dead twice over.

I CAUSED THIS AT v1.88. He asked for water to be "much slower" and I took wadeSpd
from 0.55 to 0.34. That request was reasonable and the change is right on its own
terms: at 0.55 the loaded wade was 53.9 and safely clear, at 0.34 it is 33.3 and
is not. What I failed to do was check the new multiplier against the costs that
already existed. Eleven builds ago, and nothing caught it in between, because
every check I ran was about the thing I had just changed rather than about what it
now interacted with.

The fix makes the promise structural rather than a coincidence. WARDEN_SPD is
named where the Warden is built, SPEED_FLOOR is named next to it at 46, which is
1.28 times the Warden, and the player's speed is floored after every multiplier
has been applied. Verified in the built fixture that the floor sits at line 6679,
after load, crouch, sprint, wading and ADS at 6661 to 6666, so nothing can be
applied afterwards and slip underneath it.

    walking, empty                158.0   untouched
    walking, 120wt                 98.0   untouched
    wading, empty                  53.7   untouched
    wading, 120wt          33.3 ->  46.0   floored
    wading + crouch        17.3 ->  46.0   floored
    wading + crouch + ADS  10.7 ->  46.0   floored

Three of the six cases are not touched at all, including wading empty at 53.7, so
the "much slower" water he asked for is entirely intact. The floor binds only on
combinations that would otherwise drop below a walk.

A harness mistake on the way, the third of its kind this session and caught the
same way, by the output being obviously wrong. I tried to verify by teleporting
the player into water and measuring displacement over half a second. It reported
wading as FASTER than walking, 194.6 against 71.5, with crouch and ADS having no
effect at all. That is collision ejection being counted as locomotion: dropping
the player inside geometry and measuring how far the solver pushed them out. A
number that contradicts the formula that obviously constrains it is a broken
instrument, so I discarded it and verified the arithmetic through the same
computation that found the bug, plus a direct read of the built fixture to confirm
the floor's position in the chain.

Not verified: whether 46 is the right floor. It is set at 1.28 times the Warden
because that is enough to walk away without making encumbrance feel weightless,
but I have no play data on whether being floored FEELS like a rescue or like the
controls going numb. Also not verified: whether other slow sources exist that I
have not enumerated. I checked load, crouch, sprint, wading, ADS and armour
because those are the multipliers in updatePlayer, but a status effect applied
elsewhere would sit outside the floor and reopen exactly this hole.

### v2.00: the bot has been walking on water, and it tilted the map comparison

v1.99 closed with an open question of my own: whether other slow sources sit
outside the new speed floor. Chasing that found something larger. updatePlayer
pays 0.34 speed and a 2.6x step-noise radius for wading. updateBot has never
referenced inWater at all. The sim has been crossing water as open ground for the
entire life of the project.

The reason this matters more than a uniform error is that water is not uniform:

    map 0   20.5% of the world is water   44 of 249 containers stand in it
    map 1    0%                            none, no water at all
    map 2    2.2%                          none
    map 3    7.0%                          17 of 205

So the error is concentrated on two maps. It did not add noise to the four-map
comparison at v1.85, it TILTED it, and in the direction that flatters the map it
most affects: map 0 measured second easiest while its bot crossed a fifth of that
map for free.

Fifth divergence of this family, after windfalls at v1.78, crouch at v1.80, the
hard crouch rule at v1.82 and the peddler at v1.95. Every one is a guard or an
omission that was correct when written and became a correctness hole as the game
grew past it. Defaults ON, following the windfall precedent, because a sim that
ignores a movement rule the player cannot ignore is measuring a different game.
simWade 0 restores the old behaviour. The bot also gets the SPEED_FLOOR the player
received at v1.99, so the Warden promise now holds for both.

Measured, 120 seeds an arm, eight arms, four maps against water cost off and on:

    map   water    extract free -> pays    duration free -> pays   seeds changed
     0    20.5%      13.3% -> 9.2%   -4.1     212s -> 247s  +35        57 of 120
     1     0%        20.8% -> 20.8%   0.0     178s -> 178s   +0         0 of 120
     2     2.2%       9.2% -> 6.7%   -2.5     186s -> 188s   +2        14 of 120
     3     7.0%      26.7% -> 27.5%  +0.8     189s -> 196s   +7        20 of 120

THE CONTROL IS THE RESULT. Map 1 has no water anywhere, and it came back with
ZERO seeds changed and zero delta on every single metric. That is what makes the
rest of the table trustworthy: the change provably touches water and nothing else.
Had map 1 moved at all, the diagnosis would have been wrong and the other three
columns would mean nothing.

Duration is the cleanest signal because it is the direct mechanical consequence,
and it scales with water almost perfectly: plus 35 seconds on map 0, plus 7 on map
3, plus 2 on map 2, zero on map 1. Seeds changed scales the same way, 57, 20, 14,
0.

The extract rates are the headline but the weakest column. Minus 4.1, minus 2.5
and plus 0.8 at 120 seeds a side are all inside a standard error of roughly 4 to 5
points, so no single one clears significance on its own. What is solid is that
map 0 gets harder and slower, which is the tilt predicted before the run.

Note that the absolute rates here do not match v1.85's 30.8, 15.8, 17.5 and 42.5.
Fifteen builds separate them, including the v1.96 grudge fix, the v1.99 speed
floor and a different crateMin, so the levels have moved. The comparison that
matters is within this table, arm against arm on the same build.

Not verified: whether the bot should also pay the wading NOISE in a way that
changes its behaviour rather than just its audibility. CNOISE is multiplied by
2.64 when wet, which makes the bot louder, but the bot has no concept of choosing
a quieter route, so the noise cost is currently a consequence it suffers rather
than a decision it makes. A player routes around water partly to stay quiet; the
bot cannot, so map 0 is probably still measured as easier than a human would find
it even after this fix.

### v2.01: v2.00 fixed how loud the bot is in water and missed how often

v2.00 gave the bot the player's wading noise by scaling CNOISE, the loudness. That
is half the rule. The player's footstep INTERVAL changes with state too, and by
more than the radius does:

    state      player interval    bot interval, before
    walking       0.72s               0.6s
    wading        0.30s               0.6s
    crouched      99s                 0.6s

Both errors point the same way, and the crouch one is far worse than the wading
one that prompted the look. An interval of 99 in a 600 second raid means a
crouching player emits essentially NO periodic footstep at all; the bot kept
pinging every 0.6 seconds at 0.42 radius. So the sim has been measuring crouch
with most of its noise benefit removed, and crouch is the strongest mechanic in
the game, which means the arm this project leans on hardest was the one most
understated.

Fixed by taking the ratios from the player's own constants rather than inventing
them: wet is 0.6 scaled by 0.30/0.72, crouched is effectively never, walking is
unchanged at 0.6.

Measured, 120 seeds an arm, bot crouching in BOTH arms, isolated with crouchParts
bit 2 so only the footstep rate differs:

                     extract   haul    containers   first contact
    old flat rate     33.3%    9,353     19.1          195s
    new player rate   38.3%    9,811     18.7          194s

Plus 5.0 points and plus 4.9 percent haul, and 16 seeds flip to extract against 10
to dead with 94 unchanged. THAT IS NOT SIGNIFICANT. Twenty six discordant pairs
splitting 16 to 10 is a z of about 1.2, so the direction is consistent but the
sample cannot carry the claim, and I am not going to present a fidelity fix as a
balance win.

The interesting null is first contact: 195 against 194, unmoved. I expected silent
footsteps to delay being found, and they do not, because the hard crouch rule
already dominates detection. Anything beyond 170 units cannot see a crouched
player at all, so footstep noise has almost nothing left to do for FIRST contact.
Where it should matter is after contact, in whether something reacquires you,
which is not what this measurement was pointed at.

The justification is fidelity rather than effect size. The sim was measurably
wrong about a rule the player lives under, in a direction that understated the
mechanic the project has spent the most builds studying. It is worth fixing at
zero measured cost even if the outcome number is noise.

Not verified: whether the crouched interval should be literally infinite for the
bot. I used 1e9, which mirrors the player's 99 in effect, but the player still
makes noise from firing, dodging and searching, so "crouched is silent" is only
true of the periodic footstep. If some other emitter is missing from the bot the
same way, this fix moves the sim closer to the player without arriving.
Not verified either: whether the +5 points survives a larger sample. The right
test is several hundred seeds a side, which is a long batch, and I have not run it.

### v2.02: the bot looted in silence, which was real and turned out not to matter

Rather than trip over a sixth sim divergence the way the previous five were found,
I swept the whole class. There are 97 sim guards in the file, 65 of which skip
work. Partitioned into five non-overlapping regions, every guard classified, and
anything claimed as a hole put through adversarial verification.

    86  cosmetic or correct by design
    13  candidates raised
     2  survived verification

Eighty six being correct is the result that matters most: the sim has no screen
and no speakers, so skipping audio, particles, HUD text and DOM work is right, and
the overwhelming majority of these guards are doing exactly that. This class is
now closed rather than being picked off one bug at a time.

THE BOT LOOTED IN TOTAL SILENCE. updatePlayer emits a search ping every 0.5s of
progress at radius 180, 560 for a strongbox, and AI raiders pay it too at 80.
updateBot emitted nothing at all: standing at a container means `moved` is false
so the movement ping is skipped, and grantLoot's completion ping is fenced under
!G.sim. A bot opening 11 to 15 containers a raid made not one looting sound.

And that is not cosmetic on its face. ping() sets e.alert to at least 1, flips
every entity in radius from patrol or loot into investigate with its target on the
container, and calls listenersHear unconditionally, which is the Listener's ONLY
input since that machine never calls canSee.

SO I PREDICTED FIRST CONTACT WOULD COME EARLIER AND THE EXTRACT RATE WOULD FALL.
It does not. 120 seeds an arm:

                     extract   first contact   haul    containers   listener kills
    silent loot       20.8%        85s         8,136      16.1            1
    audible loot      20.8%        82s         7,899      15.9            2

Zero change in extract rate. Three seconds on first contact. Paired, 116 of 120
seeds are unchanged with 2 flipping each way, which is as close to no effect as a
measurement gets.

The mechanism is almost certainly redundancy. The bot already emits a movement
ping of 140 times the load factor while walking between containers, which is the
same order as the 180 search ping, and it walks far more than it searches. Any
machine close enough to hear a search was already close enough to hear the
approach. The silence was real, and it was covered.

The fix stays because it is correct: the sim was missing a rule the player lives
under, the code now matches, and it costs nothing measurable. But I called it "the
largest sim divergence found so far" when I found it, and the number says it is
the smallest of the six. Being right that the code was wrong is not the same as
being right about what it was worth.

AND A CORRECTION TO v2.01, WHICH I SHIPPED AN HOUR EARLIER. I set the crouched
bot's footstep interval to 1e9 because updatePlayer uses 99 seconds. That is only
true of one of the player's two noise channels: tickPlayerSteps still emits a step
ping at radius 72 when crouched against 170 walking. A crouched player is quiet,
not silent. My version handed crouch a benefit the real game does not give it, in
the same direction as the error I was fixing. The crouched bot now pings on the
step channel's cadence at its radius ratio, 72 over 140.

Caught one more of my own on the way: I wrote the measurement referencing a
CFG.simLootNoise dial I had never added, so both arms would have been identical
and the null result would have been an artifact of my harness rather than a fact
about the game. Added the dial before running. That is the fourth harness mistake
this session and the second caught before it produced a wrong number rather than
after.

Not verified: whether the loot ping matters on a map where the bot walks less. THE
QUARRY has the lowest container density of the four, so the walk-to-search ratio
is at its highest there and the redundancy argument is at its strongest. On map 0
or map 3, where containers are denser and the bot walks less between them, the
search ping might not be covered by movement noise. I measured one map.
Also not verified: the second confirmed hole. The bot never swaps to its sidearm,
so when the universal reserve empties it abandons the raid while holding a full
Scav Pistol magazine, which corrupts the ammo-economy measurement v1.68 rests on.
That is a real finding and it is still open.

### v2.03: the bot walked off raids holding a loaded pistol

Second of the two holes the v2.02 guard sweep confirmed, and the last one it
found. Every deploy hands the player a Scav Pistol with a full magazine as p.sec
and p.secAmmo. swapGuns has NO sim guard, so it works headlessly. updateBot simply
never called it, and its dry test read only p.ammo+p.reserve. The reserve is one
universal pool, so when it emptied the bot ended its raid with a second gun still
loaded in the other hand.

That is not bookkeeping, because the dry clause is one of the FOUR conditions that
end the looting phase:

    bagWeight()>=CFG.simGreed || bagWeight()>=cap ||
    G.timeLeft<CFG.extractWait+120 || (p.ammo+p.reserve)<=0

A raid a player would have fought out with a sidearm was recorded as ending early.
That is the measurement the v1.68 ammo economy note rests on, 40 percent of raids
running completely dry with the first empty at a median of 270 seconds, and those
numbers counted a gun still in hand.

Both halves fixed: the bot swaps when the primary is dry and the sidearm has
rounds, and the dry test counts the sidearm so it cannot bail while still armed.

Measured, 120 seeds an arm:

                     extract   duration   shots   containers   haul
    no sidearm        20.8%      177s     121.3     15.9       7,899
    draws sidearm     22.5%      182s     123.7     16.3       8,078

Directionally exactly as predicted, and small. Plus 1.7 points, plus 5 seconds,
plus 2.4 shots. The paired view is the useful one: 100 of 120 seeds come back BYTE
IDENTICAL, 118 have the same outcome, 2 flip to extract, and ZERO flip to dead.

Zero flips to dead is the part worth having. The change is strictly non-harmful:
there is no seed where drawing the pistol made things worse, which is what you
want from a fix that gives the bot a capability it should always have had.

The reason the aggregate is small is that the dry clause rarely binds. Only 20 of
120 seeds differ at all, so on roughly 83 percent of raids the bot dies or fills
its bag before ammo ever becomes the deciding condition. The defect was real and
its blast radius is one raid in six.

That also puts a caveat on v1.68 rather than overturning it. I cannot say from
here whether "40 percent run completely dry" was inflated by this bug, because
that figure was measured on a build many versions back with a different bot, a
different economy and a different set of sim divergences. What I can say is that
the condition it counted was being evaluated with one gun missing.

Not verified: whether the bot should also swap the OTHER way, back to a reloaded
primary once reserve ammo is found. It swaps to the pistol and stays there, so a
bot that picks up an ammo box after going dry keeps fighting with the sidearm
while its rifle sits holstered with a full reserve behind it. That is now the
asymmetry, and it is smaller than the one it replaced but it is the same shape.
Also not verified on the other three maps; container density changes how often the
bag threshold beats the ammo threshold, so the one-in-six figure is specific to
THE QUARRY.

### v2.04: the pistol goes back in the holster, and the vein is exhausted

v2.03 taught the bot to draw its sidearm when the primary ran dry, and I flagged
the asymmetry it created in the same entry: it drew the pistol and stayed on it
forever, so a bot that later picked up an ammo box kept fighting with a Scav
Pistol while its rifle sat holstered behind a full reserve. Smaller than the hole
it replaced, same shape. This closes it.

Both rules are guarded against chasing each other. It swaps back only when the gun
in hand is EMPTY, so it never interrupts a burst, and only when the holstered gun
is a higher tier, so the two conditions cannot alternate.

The oscillation risk was the thing most likely to be wrong, so it was tested
before anything else, by forcing the scenario rather than hoping to meet it:

    start            Kettle, 28 in the magazine, 56 reserve
    forced dry       PISTOL, 12 rounds, 0 reserve
    ammo found       KETTLE again, reloading, 60 reserve
    400 more steps   Kettle, 11 rounds, zero further swaps

MY FIRST THRASH TEST WAS WORTHLESS AND I CAUGHT IT. Six full raids produced zero
weapon changes, so "no thrash" was vacuous: the dry condition never fired in any
of them, which is consistent with v2.03 measuring that it binds on about one raid
in six. A test that cannot observe the thing it is testing proves nothing, and it
looked like a pass.

Measured, 120 seeds an arm:

                  extract   duration   shots   haul
    one way        22.5%      182s     123.7   8,078
    both ways      23.3%      181s     124.6   8,097

118 of 120 seeds come back BYTE IDENTICAL. Two are touched, one flips to extract,
none flip to dead. It is the smallest effect of the whole series, and it should
be: swapping back requires going fully dry, THEN finding ammo, THEN surviving long
enough for the better gun to matter, which is a rare compound condition.

Correct, non-harmful, and nearly inert. All three are worth saying.

AND THE VEIN IS EXHAUSTED. Six sim divergences have now been found and fixed, and
their measured impact is a clean descending sequence:

    crouch, v1.80 and v1.82        +26 points of extract rate
    water, v2.00                   -4.1 on the map it affects, and a real tilt
    footstep rate, v2.01           +5.0, not significant
    sidearm, v2.03                 +1.7, one raid in six
    swap back, v2.04               +0.8, two raids in 120
    loot noise, v2.02               0.0, nothing at all

The guard sweep at v2.02 already established there is nothing structural left: 86
of 97 guards verified correct by design. The remaining finds are real defects with
no measurable consequence, which is the signal to stop mining here. Fidelity work
on the sim has stopped paying, and the open questions worth money now are the ones
I keep handing back to him: crate contents, the peddler rate, and verticality.

Not verified: whether the swap-back tier test is the right predicate. It compares
WTIER, so a bot holding a Pristine pistol and a Worn rifle of higher tier will
holster the better-conditioned gun for the better-tiered one. Quality is tracked
separately in qRank and is not consulted here, which is the same class of omission
this entry is fixing, just one level down. It affects nobody at 118 of 120 seeds
identical, but it is wrong in the same way.

### v2.05: the Listener cannot hear, and making it hear does not help

The Listener kills one or two raids in a hundred and twenty, in every batch I have
run all session, and hearing is its entire reason to exist. So I went looking.

ITS RANGE IS A CAP, NOT A RANGE. LISTEN_R is 760, but the test is
d <= min(s*1.35, 760), so a sound only carries s*1.35 and reaching 760 needs a
sound of strength 563 or more. Every emitter in the file, against a sentry's 340
sight range:

    bot walking          140  ->  heard at 189
    player walking step  170  ->  heard at 230
    player searching     180  ->  heard at 243
    player wading        290  ->  heard at 392
    player sprinting     300  ->  heard at 405
    strongbox cut        560  ->  heard at 756
    snitch alarm         620  ->  capped at 760
    beacon call          700  ->  capped at 760
    siege ring          1200  ->  capped at 760

Only four sounds in the whole game ever reach its advertised range, and three of
them are ALREADY ALARMS: the snitch has marked you, the beacon is called, the
siege is running. Everything else on the map knows by then. So the Listener's full
reach is almost never the thing that finds you first. The strongbox at 560 is the
one case where the design works exactly as written.

This also explains a null I could not account for at v2.02. I taught the bot to
make looting noise expecting Listeners to wake, and measured nothing at all. A
180-strength search ping is audible at 243 units. It was never going to hear it.

SO I ADDED THE DIAL AND SWEPT IT, AND IT DID NOT WORK.

    listenGain   extract   first contact   listener kills   seeds touched
      1.35        23.3%        82s               2               -
      2.5         27.5%        84s               1              41
      3.6         25.0%        86s               0              51

Making the Listener hear nearly three times further made the player do BETTER, not
worse. Extract rate went up and then down, non-monotone and within about one
standard error, first contact got two to four seconds LATER, and listener kills
went DOWN to zero. Forty one and fifty one seeds were touched, so the dial is
doing something; it just is not making that enemy dangerous.

THE REASON IS THAT IT CANNOT SEE. Listener sight range is 26 with a cone of ZERO,
against a sentry's 340, a raider's 302 and the Warden's 430. It is 7.6 percent of
a sentry. So the loop is: hear a noise, sprint to that spot at 196, arrive, and
have no way whatsoever to find you now that you have moved. Hearing better only
makes it sprint to more stale positions, and a machine committed to running at
stale positions is a machine that is reliably somewhere you are not. That is why
turning the volume up made it LESS lethal.

The fix is therefore not the falloff and I have not made it. It is either giving
the Listener enough sight to reacquire on arrival, or making it re-listen while
hunting so it can correct course, or accepting that it is a herding tool rather
than a killer and tuning it as one. Those are three different enemies and picking
between them is a design decision about what that machine is FOR, which is his.

listenGain defaults to the shipped 1.35 and changes nothing. It stays because the
next attempt should start from a measured baseline rather than a guess, and
because the sweep above is the evidence that the falloff is the wrong lever.

Not verified: whether a Listener with real sight would be fun or simply unfair. It
does 34 damage against a sentry's 14 and moves at 196 against the player's 158, so
it is already the fastest and hardest-hitting thing on the field; the only reason
it is survivable is that it is blind. Giving it eyes is not a small change and
should be measured before it is believed. Also not verified: whether the
non-monotone extract result is real signal or noise. 23.3, 27.5, 25.0 at 120 seeds
a side is inside a standard error, so the honest reading is that the dial moved
raids around without moving outcomes.

### v2.06: the Listener never meets you, and that is why nothing else about it matters

v2.05 established that the Listener hears a walking player at 230 units and that
turning that up made the player do BETTER, not worse. I guessed the reason was its
blindness: sight 26 with a cone of zero, so it arrives where the sound was and
cannot find you. That guess was incomplete. Tracking every Listener across twelve
full raids gives the actual shape:

    median closest approach to the player   985 units
    damage range                             26 units
    raids where it got within damage range    1 of 12
    raids where it never woke at all          7 of 12

Seven of twelve raids it never activates. Not "fails to kill you", never wakes:
zero hunt seconds, zero wakes. On a map about 4,500 units across, with two of them
at random free spots at least 1,000 from the drop, and a hearing radius of 230 for
a walking player, the player simply never passes close enough to one.

And when it does wake it does not converge. Seed 1079193 woke thirty six times,
gave up twenty eight times, hunted for seventy two seconds, and never got closer
than 1,454 units. Seed 1015841 woke twenty one times and hunted for 353 seconds
with a closest approach of 1,529. That is not a pursuit, it is an oscillation:
hear something at the edge of range, run at it, mill for seven seconds, sleep,
hear again.

So there are two independent failures stacked, and the one I found second is the
bigger one. Blindness explains why it cannot finish. Rarity explains why it never
starts. Raising listenGain at v2.05 addressed the second a little and made the
first worse, which is exactly why it produced more hunting and fewer kills.

The design comment above it says the noise system becomes load bearing "the moment
one of these wakes up". Measured: that moment arrives in five raids out of twelve,
and pays off in one.

WHAT I FIXED, both narrow and neither a balance decision.

N_LISTEN was the only enemy count in the file that was not a dial. nSentry,
nCrawler, nSnitch and nRaider are all CFG; this was a bare 2. The machine whose
entire purpose is to make noise matter could not be tuned without editing code.
nListen now exists and defaults to the same 2.

And the silence term was applying by halves. termsOn reads P.terms with no sim
guard, and listenersHearInner already used hasTerm('silence') unguarded to widen
the reach by fifty percent, but the extra machine that term grants was fenced
behind !sim. So a sim raid with that term got the hearing bonus and not the body.
Seventh instance of the family the v2.02 sweep closed, and the narrowest, since it
only bites when that term is on. Verified: default is 2, the dial moves it to 5,
and with the term active a sim raid now spawns 3 as the real game always did.
Profile terms were empty throughout, so this never touched any earlier number.

WHAT I DID NOT FIX, deliberately. Every remaining option changes what this enemy
IS. More of them, a bigger radius, placement near loot rather than at random, or
sight to reacquire on arrival: those are four different machines. The Listener as
written is a rare ambush that punishes noise in a specific place; the alternatives
turn it into a patrolling threat, a map-wide pressure, or a hunter. Picking is his,
and I have now spent two builds circling it, which is the point to stop and hand
over a complete diagnosis rather than keep making unilateral changes to an enemy
whose purpose is undecided.

Not verified: whether placement is the cheapest lever. Listeners use
far(freeSpot(map,26),1000), pure random at least 1,000 from the drop, while the
peddler is deliberately parked at a landmark about 1,700 out. Placement intent
already exists elsewhere in this file, so putting a Listener where looting happens
is a small change with a potentially large effect, and it is the first thing I
would test if he wants that machine to matter. I have not tested it because
choosing where it stands is choosing what it is for.

### v2.07: the wear, jam and repair economy is fully built and the game never routes you into it

Audited weapon wear, which has never been checked. It is an entire subsystem: four
condition tiers, per-tier spread and reload penalties, a jam probability, a repair
shop that wants credits and parts, and a cost curve tuned at v1.57. All of it
works. Almost none of it is reachable.

THREE PROVENANCES, AND ONLY ONE OF THEM PARTICIPATES.

  issued   a loaner starter, from wep=WEAPONS[pick(STARTERS)]. It has no jam
           field at all, so the jam test p.wep.jam>0 is undefined>0, false, and it
           can never jam. wearable() also excludes it, so it never accrues wear.
  field    a pickup. rollFieldGun copies the base weapon and overwrites dmg,
           spread, mag and name from its GUNQ roll. It never sets jam either, so
           a Worn Auto Rifle has worse spread and still cannot jam.
  owned    from the armoury, via wc2.jam=WS.jam. The ONLY provenance that accrues
           wear and the only one that can jam.

So the jam mechanic exists solely for guns you bought and equipped in the hub.

AND THE STATE THAT DECIDES IT IS STUCK. The fixture profile owns six guns, smg,
lmg, pistol, dmr, shotgun and rifle, and P.equipped is 'fists'. The deploy guard
reads:

    if(!wep||wep.id==='fists'||!P.weapons||P.weapons.indexOf(P.equipped)<0){
      wep=WEAPONS[pick(STARTERS)]; wepIssued=true; }

It DETECTS the inconsistency and silently works around it by issuing a loaner. It
does not repair P.equipped. endRaid does repair it, at line 8606, but only on the
death path. So once that field goes stale while you own guns, every deploy hands
you a loaner and nothing fixes it until you die or equip manually in the hub.
Measured: six of six raids came back 'issued'.

MEANWHILE THE ARMOURY HAS RUN AWAY. Every one of the six owned guns is past
FAILING, which is 1,600 rounds and a 6 percent jam per shot:

    lmg 44,330    rifle 9,627    smg 8,312
    shotgun 3,230    dmr 2,883    pistol 2,490

The LMG is twenty seven times past the threshold. Repair is priced sensibly and is
affordable, 467 to 3,110 credits plus two servos each, 12,287 for the lot against
13,085 credits in the bank. The economy is solvent and idle.

HIS OWN TELEMETRY AGREES, which is what makes this more than a fixture artifact.
Every weapon named across his seventeen runs is a starter, the Scav Pistol, or a
field pickup carrying a GUNQ prefix: Auto Rifle, Compact SMG, Scav Pistol,
Stitcher, Hullcracker, Kettle, Worn Auto Rifle, Tuned Riot Scattergun. Not one
armoury gun. He has never engaged the wear system, so he has never seen a jam, and
the repair shop has never had a reason to exist for him.

WHAT I SHIPPED IS THE INSTRUMENT, NOT THE FIX. Every run now records where its gun
came from, and the export line prints it as wep:Name(issued|field|owned). The next
set of runs will say plainly whether the repair shop is a system or an ornament,
and the same field is on simResult so batch measurement can see it too. Verified:
six of six read issued with fists equipped, and equipping an owned gun flips it to
owned.

I did not change the deploy guard, and that restraint is the point. Repairing
P.equipped there would hand him one of six FAILING guns at 6 percent a shot in
place of a clean loaner, which is a downgrade dressed as a bugfix. Whether owning
a gun should mean carrying it, whether wear should cap, and whether a field pickup
should be able to jam are three separate design questions about what that economy
is for, and they are his.

Also checked and clean, recorded because it would have been serious: addWear is
properly guarded with if(!G.sim&&!wep._echo), so the thousands of sim raids this
session did NOT write wear into the saved profile. Those six FAILING guns are his
real play, not my contamination.

Not verified: whether P.equipped going stale is reachable in normal play or is an
artifact of this fixture profile's history. Buying a weapon sets it, and dying
repairs it, so the window is narrow, but the deploy path treating the
inconsistency as normal rather than fixing it is what makes the state persistent
once entered. Also not verified: whether the wear thresholds are reachable at all
in a single session. FOULED needs 950 rounds and his heaviest run fired 111, so on
that pace it is roughly nine raids on one owned gun before the first jam is even
possible.

### v2.08: banking a gun never told the armoury you were holding it

v2.07 ended on an open question, whether P.equipped going stale is reachable in
normal play or is an artifact of this profile's history. It is reachable, and this
is the site.

Every place that adds to P.weapons maintains the invariant except one. Buying a
gun sets P.equipped. endRaid repairs it on the death path. bankItem, which is how
a recovered field gun enters the armoury, did neither. So the sequence is:

    own nothing                    equipped is 'fists'
    extract carrying a field gun   armoury fills, equipped still 'fists'
    every deploy after that        indexOf(P.equipped)<0, loaner issued, no repair

The deploy guard DETECTS the inconsistency and works around it rather than fixing
it, so the state is self-perpetuating until you die or equip by hand. It is
exactly the state the profile is in, six guns owned with fists equipped, and it is
why six of six raids came back 'issued' at v2.07. It is also why the wear, jam and
repair economy is unreachable, since wearable() and the jam field only exist for a
gun you own AND carry.

MY FIRST FIX WAS FENCED IN THE WRONG BRANCH AND WOULD NOT HAVE HELPED HIM. I put
the repair inside if(indexOf(it.gk)<0), the new-gun branch. But a save that owns
six guns recovers a DUPLICATE almost every time, and a duplicate falls straight
through to the stash as loot. The repair would never have fired for the exact save
that needed it. It now runs for any banked gun, and a duplicate still goes to the
stash exactly as before.

Verified as a matrix rather than a rate, because this is a correctness change:

    armoury      equipped   banked      result
    empty        fists      new gun     equips it, no stash
    owns it      fists      DUPLICATE   equips it, still stashed as loot
    owns other   stale id   new gun     equips it, no stash
    two guns     owned gun  new gun     LEFT ALONE, added to armoury
    two guns     owned gun  DUPLICATE   LEFT ALONE, still stashed
    one gun      owned gun  a servo     untouched

It repairs a broken state and never overrides a deliberate one.

AND THE PAYOFF, ON HIS ACTUAL PROFILE. Three deploys in the stuck state came back
issued, carrying hullcracker, hullcracker and ferro, all with no jam field at all.
One duplicate recovery, and the next three deploys came back owned, carrying the
SMG, with jam 0.06. That is the wear economy switching on: 6 percent per shot,
because that gun is 8,312 rounds past FAILING and has never been repaired. The
repair shop finally has a reason to exist, and 12,287 credits of repair bills sit
against 13,085 in the bank.

I am stating the downside plainly rather than selling this. He will now carry a
FAILING gun where he used to carry a clean loaner, and that is a real change in
his moment to moment experience. It is still correct: he owns those guns, he chose
to buy them, and a game that quietly hands you a loaner forever because of a stale
string is not protecting you, it is hiding a subsystem from you.

FOUND AND NOT FIXED, DELIBERATELY: THE BOT CANNOT JAM. The jam roll lives at 6788
inside if(mouse.down&&...), the player's fire path. The bot fires at 7113 and
neither rolls a jam nor checks p.jam before shooting. So the consequence this
build just switched on does not exist in the sim at all. That is the seventh
divergence of the family the v2.02 sweep catalogued, and unlike the last few it
is not inert: it is now load bearing, because v2.08 is what routes a player onto
the guns where jam is live. It is its own change with its own measurement and it
gets its own build rather than being smuggled into this one.

Not verified: what this does to extract rate, and I want to be exact about why
rather than call it small. I cannot measure it. An A/B would put an owned gun with
better base stats against a loaner in a sim that never jams, so it would report
the owned gun as strictly better and that number would be a lie by construction.
The honest sequence is to fix the bot jam first and measure afterwards, which is
the next build. Also not verified: whether a 6 percent jam is survivable in real
play rather than merely correct. FAILING is a tier the game has never actually
delivered to anybody, so nothing in this project's history says what it feels
like, and he is about to be the first to find out.

### v2.09: the bot could not jam, and once it can, v2.08 looks like a mistake

The jam roll lived inside the player's mouse.down fire path. simStep calls
updateBot and never updatePlayer, so no sim raid in this project's history has
ever jammed, ever ticked a jam clock down, or ever been blocked by one. The bot
fired at 7113 with no roll and no p.jam test at all.

Seventh divergence of the family the v2.02 sweep catalogued, and the first one
that is not inert. The previous six ran from +26 points down to 0.0 and I wrote at
v2.04 that the vein was exhausted. It was, for the game as it stood. v2.08 changed
the game: it routes players onto owned guns, and owned guns are the only ones that
can jam. A guard that was harmless for eighty builds became load bearing the
moment the build before it landed.

Fixed in three places. The bot rolls a jam on the trigger pull, is blocked while
jammed, and ticks the clock down whether or not it has a target. The T.jams
counter moved out of the !G.sim presentation guard, where it sat with the say and
the blip, because a counter is a fact and not a presentation detail. And simResult
now carries jams, which it never did.

MY FIRST MEASUREMENT WAS INVALID AND THE HARNESS TOLD ME SO. I put the rr() inside
the dial test, so simJam 0 skipped a draw that simJam 1 took. From the first shot
onward the two arms ran different raids, 120 of 120 seeds diverged, and the flip
counts I was about to quote meant nothing. The draw now happens whenever the gun
CAN jam, before the dial is consulted, so both arms share one stream. Guns with
jam 0, every loaner and every field pickup, never draw, so the back catalogue
stays reproducible. After the fix exactly ONE seed of 120 came back byte identical
and it was the one seed where the gun never jammed once, which is the internal
consistency check I wanted.

Fires at the designed rate: 1,091 jams in 17,586 trigger pulls, 0.062 against a
nominal 0.060.

THREE ARMS, 120 SEEDS EACH, BURIED CITY, simGreed 20000, everything else pinned:

                              extract   dur   shots   hits   jams   haul
  loaner, jam live             10.8%    264   144.0   95.1   0.00   11,479
  owned FAILING, jam OFF       11.7%    292   175.4   92.0   0.00   13,275
  owned FAILING, jam LIVE       2.5%    258   137.5   75.4   9.09   11,478

A FAILING gun costs 9.2 points of extract rate, 11.7 down to 2.5, a 79 percent
relative collapse. Nine jams a raid, 38 fewer shots, 17 fewer hits.

AND THAT IS THE REAL RESULT OF THIS BUILD, WHICH IS THAT v2.08 MADE HIS GAME
WORSE. Loaner against owned FAILING, both with the jam live, is 10.8 against 2.5.
Twelve seeds where the loaner survives and the owned gun dies, two the other way.
v2.08 is the build that moves him from the first row to the third.

I flagged this exact risk at v2.07 and then walked into it. The v2.07 entry says
repairing P.equipped "would hand him one of six FAILING guns at 6 percent a shot
in place of a clean loaner, which is a downgrade dressed as a bugfix", and I
declined to touch the deploy guard for that reason. One build later I fixed the
same invariant at a different site and argued it was correct, which it is, without
rechecking the reasoning I had written down the day before. Correct and harmful
are not exclusive, and I had already worked that out once.

I am NOT reverting v2.08. The invariant bug is real, and hiding six wrecked guns
behind a loaner is what made the wear economy unreachable in the first place. The
missing piece is not the repair, it is that the game never tells him. Nothing in
the hub says a gun is FAILING, nothing at deploy says the gun in his hands jams
one shot in sixteen, and the repair shop that would fix all six for 12,287 against
13,085 in the bank has never once been pointed at. A 6 percent jam he can see and
choose to fix is a system. The same 6 percent unannounced is a tax. That is v2.10
and it starts now.

Not verified: whether 0.06 is correctly tuned, and this build cannot tell you.
Every number above is one gun, 8,312 rounds deep, at the worst of four tiers, on
one map. FOULED at 0.022 is the tier a player actually reaches first and it is
unmeasured here. Also not verified: the loaner row is not paired with the other
two. A loaner has jam 0 so it never draws, which puts it on a different stream by
construction, so 10.8 against 2.5 is an aggregate difference of 120 raids against
120 raids and not a per-seed comparison. The 12 and 2 seed flips against the
loaner should be read as a rough direction, not as attribution.

### v2.10: one body with nowhere to go took the whole map's pathfinding budget

Found sideways. I was trying to measure the wear curve and one seed would not
finish: 600260 on BURIED CITY ran 1,344 sim steps in fourteen seconds while its
neighbours ran 4,000 in two. It was not a hang. It was uniformly 10.8ms a step
against 0.5, and no single step was slow, which is the shape of a fixed cost paid
every frame rather than a stall.

It was not the population and it was not the map. The two seeds are almost
identical on both: 71 against 70 entities with the same kinds and states, 704
against 698 walls, 2,816 against 2,792 segments.

WHAT IT ACTUALLY IS. Route searches are rationed to one per frame for the entire
map, set in refreshVseg, which the live loop and the sim step both call exactly
once a frame. navSeek decides whether to spend it:

    var stale=!e.path||e.pathT<=0||!e.pathGoal||dist(...)>140;

and the comment directly under it says a failing search "makes it wait its turn
like everyone else", pointing at the pathT cooldown set a few lines later. It does
not. A FAILED search leaves e.path null, so !e.path is true again on the very next
frame and pathT is never reached. The cooldown covers the case that does not need
it, a successful path, and misses the only case it was written for.

So a single body whose goal has no route re-requests every frame, forever. It pays
the most expensive query there is, and because the ration is one per frame for the
whole map, it also STARVES every other body of pathing. Two harms, and the second
is the one I did not expect.

Measured, BURIED CITY, 400 steps, exactly one body with an unreachable goal:

                              old      fixed
    steps that ran a search   89.3%    23.8%
    cost per step             12.82ms   1.71ms
    bodies stuck on pathFail   1         0

A normal seed is untouched: 20.3 percent of steps either way, 0.79 against 0.71ms,
which is noise. The fix only ever fires where the bug was.

WHY THIS IS A PLAYER PROBLEM AND NOT A SIM PROBLEM. The ration lives in the call
both loops share, so the live game pays the same 10ms every frame. Live frame cost,
sim plus render plus HUD, 180 frames after 120 warm frames:

                     median   p95     worst
    old, seed 1       3.10    14.40   23.00
    fixed, seed 1     1.80     2.60    5.70
    old, seed 2       2.50     4.70   23.80
    fixed, seed 2     2.50     4.20   10.10

Median barely moves. The tail does, and a tail is exactly what a stutter is: worst
case went from over the 16.7ms budget on both seeds to comfortably inside it. This
is the sort of thing that reads as "the game went choppy in that raid" and never
gets reported as a bug because it is intermittent and looks like the machine.

OUTCOMES ARE A WASH, WHICH IS THE RIGHT ANSWER. 120 seeds an arm, everything
pinned, CLEAN gun:

                    extract   dur   shots   containers   haul     worst raid
    old (0)          21.7%    355   207.4     32.1      17,280    47,525ms
    fixed (1)        20.0%    343   204.6     31.6      16,897     2,589ms

63 of 120 seeds byte identical, 108 of 120 same outcome, 5 flip to extract and 7 to
dead. At n=120 and p around 0.21 one standard error is 3.7 points, so 1.7 down is
well inside it and the flips are near symmetric. I am not claiming this made the
game harder or easier. It made it cost less: total compute for the batch fell from
297 seconds to 195, and the worst single raid went from 47.5 seconds to 2.6.

That 47.5 seconds is the same defect measured from the other end. A raid the
player would sit through at a degraded frame rate is a raid the sim takes
eighteen times longer to run.

navBackoff 1 is the fix and 0 restores the old behaviour, so both run in one build.

A WRONG TURN WORTH RECORDING, because I nearly reported it. Chasing this I probed
reachability using g.map.w and g.map.h, which do not exist on that object. Every
target came out NaN, every query failed, and it told me 100 percent of the map was
unreachable and that the dead centre could not be pathed to. Both false. The world
size lives on the __world() hook; with real coordinates it is 141 of 144 sampled
points reachable, 2.1 percent not, average query 0.89ms. The 2.1 percent is the
real story here, since those are the goals that trigger the bug, but the reading
that made me look was garbage and I would have shipped a false alarm about a
broken nav grid.

Not verified: how often a real player hits this. I found one pathological seed in
the first eight I ran and one more in 120, so the honest range is somewhere around
one raid in sixty to one in eight, and those two numbers are far enough apart that
I do not trust either. What triggers it is a body picking a goal in the 2.1 percent
of the map with no route, and I have not measured how goals are distributed against
that, only that both exist. Also not verified: whether the 2.1 percent SHOULD be
unreachable. Some of it will be sealed interiors, which is legitimate map making,
and some may be the doorway quantisation that has produced false positives in this
project twice before. This build makes an unreachable goal cheap; it does not ask
whether the goal should have been unreachable.

### v2.11: the wear curve is not a ramp, it is a trapdoor at FOULED

No game logic changed in this build. v2.09 measured one wear tier and I wrote in
its own Not verified line that a single point on a four point curve cannot say
whether 0.06 is tuned correctly, and that FOULED at 0.022 is the tier a player
actually reaches first and was unmeasured. This measures all four. It is the whole
build, and it exists because v2.09 shipped a claim I could not support.

120 seeds per tier, BURIED CITY, one gun, everything else pinned identically,
navBackoff 1 and simJam 1:

    tier      rounds   jam     extract   dur   shots   hit%   jams   haul
    CLEAN          0   0.000    20.0%    343   204.6   66.1   0.00   16,897
    WORN         420   0.000    16.7%    310   191.9   62.7   0.00   14,453
    FOULED       950   0.022     5.8%    278   163.2   57.7   3.58   12,275
    FAILING     1600   0.060     3.3%    241   130.1   54.4   8.33   10,513

READ THE GAPS, NOT THE ROWS:

    CLEAN  -> WORN      -3.3 points    stat penalty only, no jam
    WORN   -> FOULED   -10.9 points    the first frame jam exists
    FOULED -> FAILING   -2.5 points    jam nearly TRIPLES, 0.022 to 0.06

Almost the entire cost of neglecting a weapon is paid at the moment jam stops
being zero. Tripling the jam rate afterwards costs a quarter of what switching it
on cost. That is a trapdoor, not a ramp, and it is the opposite of what a wear
curve with four named tiers and a cost that grows with rounds fired looks like it
promises.

The paired view says the same thing. Against CLEAN on the same seeds: WORN flips
15 seeds to dead and 11 back to extract, which is close to a coin toss and
consistent with a small stat penalty. FOULED flips 21 to dead and only 4 to
extract. FAILING flips 23 to dead and 3 to extract. FOULED has already done
essentially all of the damage that FAILING does.

WHY THIS MATTERS FOR HIM SPECIFICALLY. FOULED is 950 rounds. His heaviest recorded
run fired 111. So it is roughly nine raids on one owned gun, which is a normal
amount of play, and it is the first tier he will ever meet. The tier he will meet
first is the one that takes his extract rate from 16.7 to 5.8.

WHAT I AM NOT DOING. I am not retuning it. Whether the cliff is wrong depends on
what wear is FOR, and there are at least three coherent answers: a soft tax that
nudges you toward the shop, a hard deadline that makes servicing mandatory, or a
resource sink that punishes hoarding guns you do not maintain. The current numbers
implement the second one whether or not that was the intent. Moving 0.022 down, or
inserting a tier between WORN and FOULED, or making the first jam of a raid free,
are three different games and picking is his.

What I can say with numbers, which is what he was missing: the lever that matters
is the FOULED jam rate, not the FAILING one. Tuning 0.06 changes almost nothing.

Not verified: any of this on the other three maps. Container density decides how
often the bag threshold beats the ammo threshold, and shots per raid is the
quantity jam scales against, so a map where the bot fires less should show a
shallower cliff. This is BURIED CITY only. Also not verified: the same curve for
the player rather than the bot. The bot fires 204.6 shots on a CLEAN gun; his
heaviest run fired 111, so he shoots roughly half as much and would meet the cliff
proportionally more slowly within a raid, though he reaches the tier itself just
as fast. And one honest limitation of the whole series: every tier here is the
Compact SMG, which v1.57 already flagged as a trap purchase, so the absolute rates
belong to that gun and only the SHAPE of the curve should be read as general.

### v2.12: the map was showing you ten containers you could never open, and almost every alarm on the way here was false

v2.10 closed with an open question I wrote myself: 2.1 percent of sampled points
had no route, and I did not know whether they SHOULD. This answers it. The answer
is mostly yes, and the honest part of this entry is how many wrong turns it took
to get there.

WHAT WAS ACTUALLY WRONG, and it is small. Placement asks freeSpot whether a point
is clear of walls. That is not the same question as whether a body can GET there,
and nothing anywhere asked the second one. Across 20 maps and 3,810 containers
that are not deliberately sealed:

    sealed by navPath                      59
      of which inside a locked room        49   keyed, by design
      of which in a camp                    0
      GENUINELY STRANDED                   10   0.26 percent

Ten containers across twenty maps, about one every second raid. Each one renders,
carries loot, and shows its rarity pip, so it is loot the game draws on the map
and never lets you have. Now zero: one flood fill over the nav grid the map
already builds, from the drop, cached, then a single sweep that relocates anything
stranded. cacheReach 0 restores the old behaviour.

FOUR FALSE ALARMS, IN ORDER, BECAUSE THE PATTERN IS THE POINT.

  1. I measured 4.1 to 5.7 percent of containers unreachable on every map and
     nearly reported a general placement failure. Most of it was locked rooms.
  2. I found 70.5 percent of CACHES sealed, which looked damning, and it is
     because caches are the container type that locked rooms are stocked with.
     120 of 120 locked room caches read sealed, correctly, because the door is
     shut. v1.75 already guarantees every locked door gets a key.
  3. Stripping those out left 26.3 percent of ARC caches sealed, the ones with a
     comment above them reading "a jackpot you never find is the same as no
     jackpot". So I fixed placeCache. IT FIXED NOTHING. Broken down by tag,
     placeCache's own caches are 0 of 60 sealed and were never the problem: every
     single sealed one was the ARC STRONGBOX, 20 of 20, which is placed inside a
     locked room ON PURPOSE as its first choice. I shipped a guard on a site with
     a zero percent failure rate and had to take it back out.
  4. Before all of that, my collide-based flood fill reported the entire map
     walkable, 211,600 cells of 211,600. collide is an EJECTOR: it mutates the
     point and returns nothing, so my boolean test was always false. Same family
     as measuring collision ejection as locomotion earlier in this series.

Only after the fourth correction did two independent instruments agree: navPath
and a body scale flood fill returned the same 8 containers on the test seed, with
zero disagreement in either direction, against 75.3 percent of the map walkable
and 25.3 percent blocked. That agreement is the only reason I trust the ten.

WHAT THE SWEEP DELIBERATELY DOES NOT TOUCH. My first version moved everything it
found, including 49 ordinary crates and lockers that had spawned inside a locked
room. They are unreachable for exactly as long as the door is, which is the point
of the door, and relocating them would have quietly deleted part of the reward for
spending a key. The sweep now skips anything inside a locked room rectangle, the
flagged locked room caches, and the strongbox. Verified: 49 still inside, 120
locked room caches untouched, strongbox still 20 of 20 sealed.

Cost is nothing. Build 377.0ms per map before, 362.6 after, which is noise around
a fill of 81,250 cells. Container count is identical at 3,810 and no container
lost its loot or its pip.

Outcomes, 120 seeds an arm, BURIED CITY, everything pinned:

              extract   dur   shots   containers   haul
    off         7.5%    252   142.4     22.9      11,646
    on          9.2%    253   140.5     22.7      11,233

107 of 120 byte identical, 118 same outcome, 2 flip to extract and ZERO to dead.
The 1.7 points is noise at this n and I am not claiming it. Zero flips to dead is
the part worth having: a placement fix should never cost a raid, and it does not.

Not verified: whether the ten stranded containers were reachable by the PLAYER
rather than by a body. Both instruments model a body of radius 11 pathing on foot,
and the player is that body, but the player can also be pushed by an explosion,
which no instrument here accounts for. Also not verified: whether relocating is
better than deleting. A stranded crate becomes an ordinary crate somewhere else,
which very slightly raises open ground loot density, and at ten containers across
twenty maps I cannot measure the difference between that and simply removing them.
And one thing I did NOT investigate: the ARC STRONGBOX being behind a locked door
every single raid on every map. That is what the code asks for and it may well be
intended, but it means the vault moment the design talks about is gated on finding
a key first, and nothing in the design notes says that out loud.

### v2.13: the wear cliff is real on all four maps and nothing like the same size, and I had the map name wrong for four builds

No game logic changed. Two things here: a correction, and the measurement v2.11
said it was missing.

THE CORRECTION FIRST, BECAUSE IT AFFECTS EVERY NUMBER SINCE v2.09. I have been
pinning mapIx 1 and calling it THE QUARRY. mapIx 1 is BURIED CITY. FIXED_MAPS is
dam, buried, cold, quarry, so THE QUARRY is mapIx 3 and I never touched it until
this build. Every arm in v2.09, v2.10, v2.11 and v2.12 ran on BURIED CITY. The
numbers are all still valid, they were correctly pinned and correctly paired, they
were simply attributed to the wrong map, and I have corrected those four entries
in place. The commit messages for those builds still say THE QUARRY and cannot be
changed. Earlier entries in this file also say THE QUARRY and I have NOT touched
them, because I do not know whether the map order was the same when they were
written and guessing would make the record worse rather than better.

NOW THE MEASUREMENT. CLEAN against FOULED, 120 seeds per arm, one gun, everything
else pinned identically, on all four maps:

    map                  CLEAN   FOULED   cliff   jams/raid   CLEAN haul
    DAM BATTLEGROUNDS     8.3%    5.8%     2.5      3.88       15,536
    BURIED CITY          20.0%    5.8%    14.2      3.58       16,897
    COLD STORAGE          6.7%    4.2%     2.5      3.67       16,286
    THE QUARRY           21.7%   11.7%    10.0      4.28       20,357

THE PENALTY IS UNIFORM AND THE DAMAGE IS NOT. Jams per raid sit between 3.58 and
4.28 on every map, so FOULED is doing the same thing everywhere. What differs is
how much there was to lose. The cliff tracks the CLEAN baseline almost exactly:
the two maps where a healthy gun extracts one raid in five lose 10 and 14 points,
and the two where it extracts one in twelve to one in fifteen lose 2.5.

So v2.11's headline needs qualifying. "The wear curve is a trapdoor" was measured
on one map and it is a trapdoor on that map. Averaged over four it is 7.3 points,
and on half the maps it is a nuisance rather than a cliff. The DIRECTION holds
everywhere, the MAGNITUDE was specific to the map I happened to pin. The v2.11
conclusion I still stand behind is the one about the lever: FOULED at 0.022 does
nearly all the work and FAILING at 0.060 adds little, and nothing here contradicts
that.

AND THE BIGGER FINDING IS NOT ABOUT WEAR AT ALL. Look at the CLEAN column. With an
identical gun, an identical bot and identical settings, extract rate runs 6.7, 8.3,
20.0 and 21.7 percent. The maps are not close to each other: THE QUARRY is 3.2
times easier to walk out of than COLD STORAGE. That sits directly against the
standing complaint that "maps feel samey", and it suggests the problem was never
that they play the same. They play very differently and nothing tells him which is
which. There is no difficulty shown anywhere in the hub, and contract pay does not
scale with it either, which means the sensible play is to farm the easy map and
the game never says so.

That is a design question, not a defect, so it goes to him rather than into a
build: whether map choice should be a stated risk-and-reward decision with pay to
match, or whether the three hard maps should come up toward the easy one.

Not verified: whether the difficulty spread survives a real player. Every number
here is the bot, and the bot's weaknesses are not evenly distributed across maps.
COLD STORAGE is the smallest world at 4200x3400 with the fewest containers, 136
against THE QUARRY's 208, so its low rate may partly be the bag filling slower
rather than the map being more lethal, and I did not separate those. Also not
verified: WORN and FAILING on the three maps I added. This is CLEAN against FOULED
only, chosen because v2.11 established that is where the whole effect lives, so
the shape of the middle of the curve on those maps is assumed rather than measured.

### v2.14: the map spread is lethality, not pace, and it is the sentry

No game logic changed. v2.13 ended on a confound I raised against my own finding:
COLD STORAGE is the smallest world with the fewest containers, so its low extract
rate might be the bag filling slowly rather than the map being more dangerous.
This settles it, and two sentry audits that follow from the answer both come back
clean, which is worth as much as a fix.

FIRST, CREDIT WHERE IT IS DUE AND I DID NOT GIVE IT. I wrote up the map spread at
v2.13 as though it were new. It is not: v1.85 found it, and v1.86 went after the
cause, tested loot density as the explanation with the MAPCONT dial, and honestly
reported that the intervention did not reproduce the correlation. The spread has
been a known open question for thirty builds. What is new here is the decomposition
of HOW raids end, which nobody has run.

120 seeds a map, CLEAN gun, everything pinned identically:

    map                 extract   died to enemy   ran out clock   1st contact
    DAM BATTLEGROUNDS     8.3%        79.2%          12.5%          152s
    BURIED CITY          22.5%        74.2%           3.3%          107s
    COLD STORAGE          6.7%        87.5%           5.8%          131s
    THE QUARRY           21.7%        69.2%           9.2%          127s

MY CONFOUND IS DEAD. If COLD STORAGE were hard because looting is slow, its raids
would end on the clock. They do not: 5.8 percent, the second LOWEST of the four,
and it opens 27.6 containers, identical to DAM. It is the most lethal map by a
clear margin, 87.5 percent of raids ending in something killing you. Pace is not
the story anywhere; between 69 and 88 percent of raids on every map end with a
machine standing over you, and the clock accounts for 3 to 13.

AND ONE MACHINE DOES MOST OF IT. Sentry kills per 120 raids: 60 on the dam, 58 on
COLD STORAGE, 56 on BURIED CITY, 46 on THE QUARRY. Against total deaths of 83 to
105, that is roughly two of every three deaths in this game, on every map, caused
by the same enemy. Crawlers are a distant second at 19 to 29 and everything else
is noise. Contact itself is not the differentiator either: 98 to 99 percent of
raids meet something on all four maps.

So the honest statement of the open question changes shape. It is not "why are
some maps harder", it is "why is the sentry more effective on some maps", and
that is a question about sight lines and geometry rather than about loot.

TWO SENTRY AUDITS, BOTH CLEAN, RECORDED BECAUSE A NEGATIVE RESULT STOPS THE NEXT
PASS REPEATING THEM.

  1. The telegraphed fire at v1.18 claims in its own comment that the 0.4s charge
     is subtracted from the old cooldown so DPS is unchanged. Checked against the
     diff that introduced it: the old roll was rnd(0.35,0.75) and the new cycle is
     0.4+rnd(0,0.35), which is rnd(0.40,0.75). Mean 0.55 against 0.575, about four
     percent slower and inside rounding. The Warden's is exact, 2.4 against
     0.7+1.7. The claim is true.
  2. Leaving the chase state does not clear e.windup, so in principle a sentry
     that loses you mid charge could reacquire and fire with no telegraph at all,
     which would be exactly the unfairness v1.18 set out to remove. Measured over
     14 raids, 409 chase entries and 366 chase exits: ZERO exits carried a pending
     charge. The window cannot open, because a 0.4s windup always resolves long
     before `alert` decays far enough to drop the state. Real hole, unreachable,
     and I am not adding dead code to close it.

Not verified: whether the sentry's dominance is geometry or simply arithmetic. It
fires every 0.40 to 0.75 seconds for 14, which is 19 to 35 damage a second against
100 health, so anything that keeps one in line of sight for four seconds is fatal
regardless of the map, and I have not measured how long sight lines actually stay
open on each map. That is the measurement I would run next and it is the one that
would separate "COLD STORAGE has longer firing lanes" from "COLD STORAGE crowds
you into them". Also not verified: any of this for a player rather than the bot.
The bot does not use cover deliberately, it crouches only when a dial says so and
this arm had simCrouch 0, so a sentry gets a cleaner shot at it than at a person
who is actively breaking line of sight. The RANKING should survive that; the
absolute rates should not be read as difficulty for him.

### v2.15: the camp guards never scaled with the ground, and four more hypotheses died on the way

v2.14 narrowed the thirty-build-old map spread question from "why are some maps
harder" to "why is the sentry more effective on some maps". This build eliminates
four candidate answers with numbers and finds one real defect underneath them.

FOUR HYPOTHESES, ALL DEAD, ALL RECORDED SO NOBODY RUNS THEM AGAIN.

  1. ENEMY DENSITY. Already normalised: den=clamp(AREA/4.0,0.45,1.6) exists
     precisely because COLD STORAGE was accidentally denser, and it works. Total
     bodies per million square units come out 3.85, 3.83, 3.99 and 3.99. Flat.
  2. SIGHT LINE LENGTH. 900 rays a map from random open ground, marched to first
     wall. Mean open line: THE QUARRY 174, COLD STORAGE 213, DAM 224, BURIED CITY
     263. The ranking is not difficulty's ranking and is not even close: the map
     with the SHORTEST lines and the map with the LONGEST are the two EASIEST.
     Percent of rays reaching a sentry's 340 range says the same, 13.1 to 25.1.
  3. DISTANCE FROM DROP TO A WAY OUT. 40 seeds a map: BURIED CITY 1583, THE
     QUARRY 1457, COLD STORAGE 1284, DAM 1168. Backwards. The two EASY maps make
     you walk furthest. A single-seed probe had said COLD STORAGE was 1856 and I
     nearly reported that; forty seeds put it at 1284 and killed it.
  4. WATER. DAM BATTLEGROUNDS is 21.9 percent wet by walkable ground, against THE
     QUARRY 8.3, COLD STORAGE 2.1 and BURIED CITY 0. That is a real and large
     difference and it plausibly explains the DAM, where a quarter of the ground
     cuts you to a third speed and raises your noise. It cannot explain COLD
     STORAGE, which is almost dry and is the hardest map in the game.

Also discarded before it reached a report: a concealment probe that returned
"100 percent of walkable ground concealed" on all four maps, which is nonsense
and means I called the wrong function. Not reported as a finding.

WHAT WAS ACTUALLY WRONG. Every map spawns exactly four sentries and four crawlers
MORE than config times den. Raiders and snitches match their predictions exactly.
A constant offset, not a scaling error, and it is the camps: two per raid, each
running two iterations that push one sentry and one crawler, flat, regardless of
how big the map is.

That is the identical bug v1.85 fixed everywhere else, in its own words: "the
counts in CFG are flat, so they were really this many bodies per map rather than
per acre". The patrol spawn was fixed. The guard detail was missed.

    sentries per million square units, with the flat detail included
      DAM 1.154   BURIED CITY 1.134   COLD STORAGE 1.261   THE QUARRY 1.208

The smallest map carries 11 percent more sentries per acre than the largest,
entirely because of a constant, and it is the map with the lowest extract rate in
the game.

Scaling the detail by den changes exactly ONE map at the current four sizes,
because the other three round back to 2. COLD STORAGE goes from 2 guards a camp
to 1, its sentries from 18 to 16, and its density from 1.261 to 1.120, which makes
it the LEAST dense map rather than the most. Both camps survive with all four
safes and their tether, so an encampment is still a defended position. Verified:
DAM, BURIED CITY and THE QUARRY are byte identical across the dial.

Measured on COLD STORAGE, 120 seeds an arm, everything else pinned:

                     extract   died to enemy   clock   containers   haul
    flat detail       6.7%        87.5%         5.8%     27.6      16,286
    scaled detail    11.7%        87.5%         0.8%     28.8      17,161

Plus 5.0 points, 12 seeds flip to extract against 6 to dead. campNorm 0 restores
the flat detail.

AND I AM NOT CALLING THAT SIGNIFICANT. Eighteen discordant pairs split 12 to 6 is
a McNemar z of about 1.41, which is p around 0.16. It is the right direction, it
is the size you would predict from an 11 percent density cut, and it does not
clear the bar on its own. The pairing is also weak here for the same reason
v1.86's lootNorm was: removing two bodies changes the number of random draws, so
zero of 120 seeds come back identical and these are not the same raids. The
correctness argument is what carries this change, not the five points.

Not verified: whether COLD STORAGE is still an outlier once the constant is gone.
Its density is now the lowest of the four and its extract rate is still 11.7
against 21.7 and 22.5 on the two easy maps, so most of the gap survives and the
original question is only partly answered. Also not verified: whether two camps
per raid should itself scale. I left the camp COUNT flat because "two per raid" is
stated design and the safes are the point of them, but the same argument that
makes the guards population makes the camps population, and I did not want to
change the number of set pieces on a map without him saying so.

### v2.16: wearing nothing was better than the rig you paid for

Audited armour, because v2.14 established that two of every three deaths in this
game are a sentry and armour is the only thing that answers a sentry. Two defects,
one of them a single character.

THE FALSY ZERO. damagePlayer read:

    var soak=armorById(p.rig).absorb||0.55;

No Rig has absorb 0.00. In JavaScript 0 is falsy, so `0.00||0.55` is 0.55, and a
player wearing nothing absorbed 55 percent of every hit. That is MORE than the
Scav Rig at 0.50 and nearly the Plated Vest at 0.58.

THE CEILING THAT IGNORED THE RIG. The comment above ARMOR_MAX states the intent
plainly: "the old flat ceiling is now whatever rig you walked in wearing, so the
HUD bar scales to the rig instead of to a constant that no longer means anything".
The code then wrote Math.max(ARMOR_MAX, rig.cap), which puts the constant straight
back for any rig under 60, and that is the bottom two of four:

    rig             table cap    actual ceiling
    No Rig               0            60
    Scav Rig            35            60
    Plated Vest         70            70
    Breacher Plate     120           120

TOGETHER THEY INVERT THE LADDER. Old behaviour, side by side:

    No Rig     ceiling 60   absorb 0.55   noise 1.00   costs nothing
    Scav Rig   ceiling 60   absorb 0.50   noise 1.02   costs credits

Same ceiling, worse absorption, worse noise, and you pay for it. The Scav Rig was
a strictly dominated purchase and the correct play was to wear nothing and pick up
plates. Fixed, the ladder is 0, 35, 70, 120 instead of 60, 60, 70, 120.

Four more falsy zeros in the same family were fixed with it: the plate pickup
guards all read `g.player.armorCap||ARMOR_MAX`, which would have turned a real
ceiling of 0 back into 60 at every one of them. Now an explicit undefined test.

Verified by hitting the player for 100 with each rig, both dial positions:
No Rig now absorbs 0 of it where it used to eat 55; Scav Rig caps at 35 absorbed
where it used to reach 60; Plated and Breacher are unchanged in both, which is the
control that says I only moved what I meant to.

Measured, BURIED CITY, 118 paired seeds, everything else pinned. The sim wears a
fixed Scav Rig, so this arm isolates the CEILING alone:

                        extract   died to enemy   downs   haul
    ceiling 60, old      22.9%       73.7%        0.78   16,905
    ceiling 35, new      17.8%       78.0%        0.81   16,348

Minus 5.1 points, 10 seeds flip to dead against 4 to extract, 40 of 118 identical.
McNemar z is about 1.60, p near 0.11, so not significant on its own, but the
direction and size are exactly what removing 25 points of armour buffer predicts.

THIS MAKES THE GAME HARDER AND I AM NOT HIDING THAT. He has said more than once
that he dies too fast. This build takes armour away from the two cheapest rigs.
The defence is that the ladder was inverted, not merely mistuned: an upgrade path
where the free option beats the first paid option is not a difficulty setting, it
is a broken shop. rigCap 0 restores the old ceiling if he disagrees; the absorb
fix is not dialled, because a falsy zero is a bug rather than a balance choice.

AND IT LANDS ON HIS SAVE HARDEST, which he needs to know before he plays. His
profile is rig 'none'. Under the old numbers that quietly gave him a 60 point
ceiling at 0.55 absorption, the best deal in the game. He now has 0 and 0.00,
literally no armour system at all, which is what "No Rig" always claimed. He is
carrying 13,085 credits and the shop sells rigs. Buying one is now strictly worth
doing, which was the whole point.

Not verified: the effect on the two upper rigs, and it could go either way. The
sim wears a fixed Scav Rig by design so every number above is the light tier, and
Plated and Breacher did not move a single value in the audit, but I have not run a
raid arm on them and their relative value against the cheaper rigs has changed
even though their own numbers have not. Also not verified: whether 35 is the right
cap now that it binds. It has never actually bound before, so the figure has never
been playtested as a ceiling, only ever written down as one.

### v2.17: the Armor Plate could never reach a raid, and the loadout ranked it first

Went to audit rig prices after v2.16 changed the ladder. The prices are fine. What
is not fine is the item sitting next to them in the shop.

THE DEPLOY LOADOUT RANKS ARMOUR FIRST AND HAS NEVER ONCE TAKEN ANY. Its own
comment states the priority and the reason: "in the order that actually keeps you
alive: armour, then ammo, then medical. Armour and ammo are spent the moment you
land". The guard immediately under it reads:

    if(use==='armor'&&g.player.armor>=armorCap) return false;

and the player is created with armor:myRig().cap. You always land FULL. So the
test is true on every deploy, for every rig, and the highest priority category in
the loadout was refused every single time.

Measured before the fix, two plates in the stash, deploying with each rig:

    No Rig    plates taken 0 of 2      Scav Rig  plates taken 0 of 2
    Plated    plates taken 0 of 2      Breacher  plates taken 0 of 2

The Armor Plate is in the shop at 620 credits behind 800 reputation. It is also in
the peddler's stock and on the crafting table. Nothing you bought could ever be
carried into a raid, and the only value it had was selling it back for 340, which
is a guaranteed 280 credit loss on a deliberate purchase. Same shape as the
impossible contract at v1.74 and the keyless door at v1.75: the game sells you
something that cannot work.

A plate FOUND in a raid was always fine, and I checked that before assuming: with
armour full or no rig it falls through to the bag as salvage worth 340, and with
armour missing it applies. So this is specifically the bought and stashed plate.

TWO HALVES TO THE FIX, BECAUSE THE FIRST ALONE WOULD HAVE DONE NOTHING.

Carrying it was the obvious fix and I nearly shipped only that. Then I checked the
hotbar and there was no armour verb at all: gun, gun, three throwables, medical,
crowbar. A carried plate would have sat in the bag exactly as unusable as it was
in the stash, and I would have called it fixed. So:

  1. The loadout now CARRIES a plate when armour is already full instead of
     refusing it, and still refuses outright when the rig ceiling is 0, because
     with No Rig there is genuinely nothing to slot it into.
  2. The hotbar gains an armour slot, and only when you are actually carrying one,
     so the slot order does not move for anyone who is not.

Verified end to end, deploy with two plates in stash, take a hit, slot one:

    rig        carried   slot appears   armour after 80 damage   after slotting
    No Rig        0          no                 0                    0
    Scav Rig      1         yes                 0                   35
    Breacher      1         yes                57                  112

It consumes exactly one plate, refuses when armour is full without consuming, and
says why with No Rig rather than silently eating it. Slot count is 7 without a
plate and 8 with, on every map.

NO BALANCE MEASUREMENT, AND THE REASON IS THE POINT RATHER THAN AN EXCUSE. The
stash loadout is the else branch of a test on `sim`; a sim raid takes the other
branch and is handed two bandages. Verified rather than asserted: a sim raid run
with three plates in the stash leaves all three there and the stash the same
length. The sim cannot see any of this, so a 120 seed arm would compare a build
against itself and report a difference of exactly zero, which would be a number
that looks like evidence and is not.

Not verified: whether one carried plate is the right amount. It takes one of the
three kit slots, so it now competes with ammo and medical for the first time ever,
and that trade has never existed before this build. Also not verified: the
peddler still sells plates mid raid, and buying one there with No Rig is the same
dead purchase the shop had, since he has no rig check either. I did not touch him
because his stock is a random draw rather than a menu, and gating it needs a
decision about whether he should refuse a sale or just warn.

### v2.18: the peddler sold the plate the shop had stopped selling, and v2.17 is reachable after all

Two small things: the site v2.17 named and left open, and a check on v2.17 itself
that I should have run before shipping it.

THE SITE I LEFT OPEN. v2.17 closed the Armor Plate defect in the hub and wrote in
its own Not verified line that the peddler still sells plates mid raid with no rig
check. He does, or did. He stocks plates at PED_STOCK, prices them at ival times
1.9, which is about 646 credits, and with No Rig the ceiling is 0, so it can never
be slotted and sells back for 340. The same guaranteed loss the shop had, at the
one counter I had not closed.

Refused now, with the reason said out loud, and the panel row greys the item and
prints "no rig" where the price goes so the refusal is never a surprise. The
backstop is in pedBuy rather than only in the drawing, which is the lesson the hub
shop already learned and wrote down: a sale should stand on its own conditions
rather than on the state of a row drawn earlier.

Verified, peddler stocked with a plate and a medkit, 20,000 credits:

    rig         plate        credits spent   medkit
    No Rig      REFUSED          0           sells normally, 700
    Scav Rig    sells            646         sells normally, 700

Stock is not marked sold on the refusal either, so he still has it if you come
back wearing something.

AND THE CHECK I OWED v2.17. That build added an armour slot to the hotbar and I
verified it by calling useArmor directly, which proves the function works and
proves nothing about whether a player can reach it. If no key selected that slot
the whole fix would have been dead on arrival, and I would have reported it as
shipped. Digits 1 to 9 call setHot(dn-1) and KeyG calls useHot, so with eight
slots the armour slot is index 6 and the key is 7. Driven through that path rather
than through the function: armour 0 after an 80 damage hit, press 7, press G,
armour 35 and the plate gone from the bag. It is reachable.

The peddler panel also draws with a plate in stock and no rig, which is the case
the new row branch introduces, and every map and the hub still draw clean.

NO BALANCE ARM, same reason as v2.17 and verified the same way rather than
asserted: the peddler is built inside the non-sim branch and simPed defaults to 0,
so the bot does not trade at all in the arms this project quotes. Nothing here can
move a sim number, and running 120 seeds would produce a difference of zero that
looked like evidence.

Not verified: whether refusing is better than warning. He is a trader, not a
tutorial, and there is a reading where he takes your money for a plate you cannot
use and that is exactly the kind of hard world this game is going for. I chose
refusal because the shop already refuses and two counters selling the same item on
different rules is worse than either rule. Also not verified: the crafting table
still makes plates from two comp and one board with no rig check, but that costs
materials rather than credits and produces a real item you can sell or use later,
so it is not the same trap and I have left it alone.

### v2.19: swept the falsy zero, and four systems audited clean

v2.16 found a defect that turned on one character: `absorb||0.55` where the value
was legitimately 0.00. That is a bug CLASS, not an incident, so this build sweeps
the whole file for it, the way v2.02 swept the sim guards. Most of the tick is
negative results, which is the honest shape of a sweep.

THE SWEEP. Every `X || N` in the file where N is non-zero, 24 sites, classified by
whether 0 is a legal value for X:

  REAL, and fixed:
    found.qRank||1     GUNQ ranks 'worn' at 0. Every Worn gun found was recorded
                       as Field in T.bestQ. Worn is weight 33 of 100, so this
                       misread a THIRD of all gun finds.
  LEGAL BUT UNREACHABLE, left alone and recorded:
    WTIER[id]||1       fists are tier 0, but repairCost returns null on w<=0
                       first and wearable() excludes fists explicitly, so a
                       fists tier is never computed.
    lift||24, 4 sites  a platform at ground level would be legal and would read
                       as lifted 24. No authored platform on any of the four maps
                       has lift 0; the only 0 is on a synthetic ramp object that
                       these four sites never see.
    CT.face||1         face 0 is a legal heading. Measured on 28 critters: 22 have
                       no face property at all and 6 are non-zero, none is 0.
  CORRECT BY DESIGN, 17 sites:
    0 is the "unset" sentinel rather than a value. Directions that are plus or
    minus 1, xpLevel, devicePixelRatio, pellets, zoom, radius, shipHoldMax.
    A default is the right answer for all of these.
  Also checked: spotFree's pad||22, where pad 0 is legal. No call site passes 0.

THE ONE FIX IS A WRONG NUMBER, NOT A WRONG OUTCOME, and I want that stated
plainly rather than dressed up. The export prints only tuned and PRISTINE, so
bestQ 0 and bestQ 1 render identically and no player has ever seen the
difference. It is fixed because the next thing to read bestQ would have inherited
the error silently, which is exactly how the armour defect survived.

FOUR AUDITS ON THE WAY, ALL CLEAN. Recorded so the next pass does not repeat them.

  1. CRAFTING INGREDIENTS. Every recipe needs one of six materials. Sampled 4,755
     containers over 24 raids on all four maps: scrap 1,229, wire 1,007, bandage
     698, cell 663, board 605, comp 258. Nothing is starved and no recipe is dead.
     v1.72 already priced the recipes against the shop, so I did not redo that.
  2. THE SIEGE. simResult has carried a siegeNoSpot failure counter that nobody
     had read. 119 seeds: 31 raids ran a siege, 214 arrivals, and ZERO no-spot
     failures. The counter has never fired.
  3. THE SNITCH. It flees while alarming and its alarm aborts after 3 seconds of
     lost sight against a 3 to 4 second windup, which looked self-defeating.
     Measured over 12 driven raids: 20 alarms started, 19 completed, 1 aborted.
     95 percent. The counterplay is kill it or move, and it works.
  4. UNGUARDED PRESENTATION IN THE SNITCH. Its say and sfx calls have no !G.sim
     guard while the sentry windup right above them does, which looked like the
     family v2.09 fixed. Both functions guard internally, so the call sites are
     harmless.

AND A MISTAKE I MADE AND CAUGHT BEFORE REPORTING IT. I measured 1.67 snitch alarms
a raid against 0.28 beaconCalls a raid and spent a while treating that 6x gap as a
defect. It is not: beaconCalls is the player's extraction dropship and a snitch
alarm calls reinforcements to a marked position. Two different mechanics with
similar names, and I had conflated them.

Not verified: whether the sweep is complete. It matches `X || N` with a numeric
literal, so it cannot see `a||b` where b is a variable or a call, and it cannot see
the same class expressed as `x ? x : d`. Both would hide the identical bug. Also
not verified: the four lift||24 sites will become live the moment any map authors
a platform at lift 0, and nothing in the file stops that or warns about it. I left
them because changing provably-safe code adds risk for no measured gain, but they
are a trap laid for whoever adds the next map.

### v2.20: canSee guards one argument correctly and two wrongly, on the same line

v2.19 closed with the sweep's own limitation written down: the regex matched
`X || <number>` and therefore could not see the same bug written as `x ? x : d`
or with a variable or call on the right. This build sweeps those two forms, and
they come back clean, which is worth saying plainly.

THE SELF-TEST TERNARY, `X ? X : d`. Eleven sites. Every one is either a clamp
(botSpd returns v<SPEED_FLOOR?SPEED_FLOOR:v, which is a floor and not a default),
a string fallback, or a null-object guard. None of them is a numeric default where
0 is legal. Nothing to fix.

THE IDENTIFIER DEFAULT, `X || <name>`. Thirty-odd sites, and almost all are plain
boolean logic rather than defaults: G.sim||G.over, p.moving||p.downed, !rig||
rig==='none'. The genuine defaults are table lookups falling back to another table
entry, which cannot be 0. caller.roleT||rnd(...) does treat 0 as unset, and that is
correct: roleT 0 means the role has expired and a fresh duration is exactly what
should be rolled.

ONE SITE IS DIFFERENT, AND IT IS THE WORST POSSIBLE PLACE FOR IT.

    function canSee(px,py,face,tx,ty,segs,far,cone,amb){
      var chh=cone===undefined?CH():cone;
      var lim=...<=chh?(far||VF()):(amb||AMBR());

The same expression guards `cone` with an explicit undefined test and `far` and
`amb` with ||. So a caller asking for a sight range of ZERO, which is the natural
way to say blind, gets the full default instead. That is the exact inversion you
least want in the function every enemy's eyes run through, and v2.14 measured that
two of every three deaths in this game are a sentry.

IT IS NOT REACHABLE TODAY AND I CHECKED RATHER THAN ASSUMED. The enemy call site
passes e.rng*mult*pcon*wkSight and CFG.eAmbient*pcon*wkSight. eAmbient's slider is
bounded 40 to 200. wkSight is 0.32 or 1. pcon is concealAt, which returns
1-(1-raw)*clamp(pw,0,1) with raw floored at 0.10 for a crouched stationary player
in a bush. Minimum 0.10, never 0.

So the safety of the most load-bearing sight test in the game rests entirely on a
constant in an unrelated function, and the obvious future tuning move, making full
concealment actually full, would hand every machine on the map its default vision
back. That is a landmine rather than a bug, and it is one line to defuse.

PROVED INERT RATHER THAN ASSERTED INERT. seeStrict 0 keeps the ||, so both live in
one build, and 120 seeds an arm on BURIED CITY comparing outcome, duration, shots,
hits, haul, containers, killer, first contact and jams as one joined string:

    120 paired seeds, 120 BYTE IDENTICAL, 0 differing

And proved not to be a no-op, by calling canSee directly with a target 30 units in
front and a range of zero:

                        far 0      far 340   far undefined
    seeStrict 0 (old)   SEES       sees      sees
    seeStrict 1 (new)   blind      sees      sees

The old code sees a target through a sight range of zero. The new code does not,
and both agree everywhere else, which is the whole claim.

Not verified: whether any FUTURE caller wants far=0 to mean "use the default". I
have assumed zero means zero, which is the only reading that makes the argument
useful, but the old behaviour was ten builds of history and something could have
been written to lean on it. Nothing in the file does today, which is what the 120
identical seeds demonstrate, and it would only matter if a call site were added
that passes a computed 0 and expects full vision, which would be a strange thing to
write on purpose. Also not verified: the sweep still cannot see this class when the
default is supplied by a caller further up, for example a function that takes an
options object and spreads defaults into it. This file does not use that pattern,
so I did not build a probe for it.

### v2.21: the hub now says what you are walking out in, and three more audits came back clean

v2.16 fixed an inverted armour ladder and the honest consequence, which that entry
states in full, was that No Rig became literally no armour. His save is rig 'none'.
So the build I shipped five ticks ago quietly took sixty points of protection off
his character and nothing anywhere on the screen mentions it. That is the gap worth
closing, and it is legibility rather than balance.

THE READINESS LINE. One line above DEPLOY, which is the last screen between the
stash and the surface. It states the number rather than nagging, because the rig's
cap IS the armour you land with, so "0 armour" is the whole warning:

    no rig, can afford   NO RIG. You deploy with 0 armour, and a plate has nothing
                         to slot into. The cheapest rig you can wear is 900c in
                         REQUISITION.
    no rig, broke        NO RIG. You deploy with 0 armour, and a plate has nothing
                         to slot into.
    Scav Rig             Scav Rig, 35 armour on the drop, absorbing 50% of every
                         hit until it is gone.
    Breacher Plate       Breacher Plate, 120 armour on the drop, absorbing 66% of
                         every hit until it is gone.

The price only appears when he can actually cover it and has not already bought
that rig, because telling someone to buy a thing they cannot afford is noise. It
reads the shop rather than hardcoding 900, so it stays true if the prices move.

No balance arm. This is DOM in renderHub, the sim never renders the hub, and a sim
raid still runs and extracts after the change. Verified rather than asserted, same
as v2.17 and v2.18.

THREE AUDITS ON THE WAY, ALL CLEAN.

  1. CONCEALMENT, which is the item I named at the end of v2.20 and suspected of
     being a coincidence. It is not. concealAt returns 1-(1-raw)*clamp(pw,0,1),
     the slider is bounded 0 to 1, and at 1 pConceal equals raw exactly. Measured
     live by binary searching the distance a sentry acquires the player, in a real
     bush with real geometry:

         crouched still   pConceal 0.10   seen from  34
         crouched moving           0.22              75
         standing still            0.40             136
         standing moving           0.62             211
         sprinting                 1.00             340

     Exactly 340 times pConceal at every step. The 0.10 floor is authored, not an
     accident of the canSee landmine, and the HUD's five labels line up with the
     five real values.
  2. THE HARD CROUCH RULE. HARDC is CFG.crouchParts&8 and crouchParts defaults to
     7, so bit 8 is off and the rule is sim-off by default. That looked like a
     divergence and is not: it is the decomposition dial v1.82 built, and simCrouch
     defaults to 0 so the bot never crouches in the quoted arms anyway.
  3. THE WARDEN'S PROMISE, which v1.99 made structural and v2.16 had a chance to
     break by touching rigs. It holds. SPEED_FLOOR is applied at the END of the
     multiplier chain, after load, rig, crouch, wade and ADS, so it catches every
     combination, and 46 is still above WARDEN_SPD 36.

Not verified: whether a line above DEPLOY is where he will actually look. It is the
screen he presses a button on, which is the best argument available, but the same
reasoning was used for the CONCEALED label that turned out to be sitting under the
key legend, and I only learned that because he told me. This is a guess about
attention dressed as a placement decision. Also not verified: the line says nothing
about the OTHER two things you deploy with, the gun and the three kit slots. Armour
is called out alone because it is the one v2.16 changed under him, and a readiness
panel that lists everything is a different and larger piece of work.

### v2.22: tried to fix a regression I had not caused, and reverted it

v2.17 ended on a worry about its own change: a carried plate takes one of the
three kit slots, so "it now competes with ammo and medical for the first time
ever, and that trade has never existed before this build". This build went to
settle that. The worry was wrong, the fix I wrote for it was a no-op, and both
of those are the result.

WHAT I THOUGHT I HAD FOUND. Deploying with a full stash takes plate, ammobox and
bandage. Deploying with no plates available takes ammobox, medkit and medkit. Put
side by side that reads as the plate pushing out a medkit: 35 effective HP on a
Scav Rig, weighing 3, in place of 65 HP of healing weighing 2. Strictly worse, and
shipped by me five ticks ago.

So I moved armour to the end of the priority chain, behind a kitOrder dial, on the
reasoning that v2.17 changed a plate from APPLIED to CARRIED and left it sitting at
the front of a list whose stated justification, "armour and ammo are spent the
moment you land", no longer described it.

THE DIAL CHANGED NOTHING. Four rig and stash combinations, both settings, byte for
byte identical takes. The reason is obvious once measured and I should have seen it
before writing code: the explicit chain calls takeBest once per category, and there
are exactly three slots and three categories, so with a stocked stash every order
takes one of each. Order cannot change a set that is one-of-everything.

WHAT ACTUALLY DISPLACES THE SECOND HEAL is the fill loop, which only runs when a
category came back empty, and that is true under any ordering. So the comparison I
built the fix on was not order versus order at all, it was has-plates versus
has-no-plates.

AND MEASURED PROPERLY, THE TRADE IS GOOD. Same stash minus the plates, light and
heavy rigs:

                        heal items   heal HP   reserve   plates
    plates in stash          2          56       100        1
    no plates in stash       2          56       100        0

Identical healing, identical ammo. The plate is free at the point of use, because
ISSUED_HEALS tops the bag back up to two heals whenever the stash take falls short:
you carry one bandage from the stash instead of two, and the Undercroft hands you
the second one. The whole cost is ONE stash bandage, worth 65 credits, in exchange
for carrying 35 to 55 effective HP that would otherwise sit at home.

So v2.17 is fine and better than I feared, and the dial is out of the file rather
than left in as apparatus, because apparatus for a question that turned out not to
exist is just dead code with a confident comment on it. Verified by line count:
13,284 before the attempt and 13,284 after the revert.

THE PROCESS FAILURE IS THE USEFUL PART. I had the measurement that disproves this
in the FIRST probe of the tick, sitting in a field called healHPCarried that read
56 in every single row including the ones I was calling worse. I read the take
lists, formed the story, and did not look at the column that contradicted it until
after the fix failed. Third time this session that a number I had already collected
would have stopped me earlier.

Not verified: what happens when the stash has plates and nothing else. The chain
takes armour, ammo and heal, the fill loop then retries all three, and with only
plates present a player would deploy carrying up to three of them and two issued
bandages. That is probably correct, since there is nothing better to bring, but the
armour hotbar slot shows a single count and I have not checked how three reads
there. Also not verified: any of this for a stash large enough that the SMALLEST
heal rule starts mattering, since two bandages and two medkits is a tidy case and a
real stash of forty mixed items may not behave as neatly.

### v2.23: dying to your own charge blamed whichever machine had last grazed you

Four things audited clean this tick and one real defect found in the fifth, on the
screen that ends every failed raid.

THE DEFECT. The death screen picks its wording like this:

    var kn=(T.lastHitName&&T.deathKiller!=='timer')?T.lastHitName:...

and damagePlayer wrote the name like this:

    if(srcName) G.tel.lastHitName=srcName;

Only ever written, never cleared. Every damagePlayer call in the file passes a
source name except ONE: the frag blast at explodeFrag, which passes 'other' and
nothing else. So a raid where anything named ever touched you, and which then
ended in a blast, printed the wrong killer by name.

That is not a corner. v0.58 measured it: a charge thrown into cover you are
standing against lands inside its own blast for a median 85 damage out of 100 to
the thrower, and that entry exists precisely because being killed unfairly by your
own throwable felt like an ambush. It then left the screen telling you a sentry did
it. Nothing on this map throws anything back, per the same entry, so a frag blast
is always yours and the attribution is always wrong.

Two lines. The blast now names itself, and lastHitName is assigned
unconditionally so an unnamed source clears the previous one rather than
inheriting it.

Verified by reproducing the exact sequence through the real code path rather than
by calling the formatter: get grazed by a named machine, then drop a live frag at
your feet and let updateThrowables run it.

    before the blast   lastHitName  CRAWLER N-12
    after the blast    lastHitName  YOUR OWN CHARGE
    death screen       KILLED BY YOUR OWN CHARGE   (was: KILLED BY CRAWLER N-12)
    damage taken       79 of 100, which is v0.58's median 85 within noise

An unnamed source with no replacement name now falls through to the killer kind,
so it reads KILLED BY OTHER rather than a stale machine, and named killers are
untouched: a sentry hit still prints SENTRY K-9.

FOUR AUDITS, ALL CLEAN, recorded so nobody repeats them.

  1. THE PLATES-ONLY STASH, which v2.22 left unverified. Deploying with four
     plates and nothing else takes three, the hotbar armour slot reads count 3,
     and the Undercroft still issues two bandages. With No Rig it takes none and
     leaves all four in the stash. Correct.
  2. A MESSY STASH of forty mixed items, which v2.22 also flagged, since two
     bandages and two medkits is a tidy case. Forty in, thirty-two left: three kit
     slots and five throwables. Heal 56, reserve 100, armour 35, same as the tidy
     case.
  3. DEPLOY WEIGHT. Three plates plus two bandages is 11, and LOAD_FREE is 20, so
     the auto-loadout cannot silently hand you a movement penalty at the drop.
  4. THE BACKPACK CAP. PACKCAP is [99999,99999,99999], which looked like a bug and
     is not: the comment two lines above it records that he asked for unlimited
     carry on 2026-08-22. Both derivations behave correctly under it, and the
     bot's bagWeight()>=cap looting condition simply never fires, which is what
     unlimited means.

Not verified: whether YOUR OWN CHARGE is the right wording when the frag was not
yours. It always is today because nothing else throws, but the AI raiders share a
lot of the player's kit and the moment one of them gets a frag this line becomes a
lie in the other direction. The name is hardcoded at the blast rather than derived
from a thrower, because throwables carry no owner field, and adding one to fix a
case that cannot happen yet is the kind of speculative work that has cost me two
builds this session already. Also not verified: the stale name could reach anything
OTHER than the death screen. lastHitName has one reader, and I checked, but it is
the sort of field that acquires readers.

### v2.24: the defect v1.96 fixed is still written down in the line that fixed it

v2.23 ended on an assumption I had made load-bearing without checking it: that
nothing but the player throws, which is what makes "YOUR OWN CHARGE" true. Checked
first, and it holds. doThrow is the only thing that pushes a frag, smoke or decoy,
and its single call site is useHot, which is the player's hotbar. Nothing else in
the file throws anything.

That led into the raider code, and into a bug class worth sweeping.

THE CLASS. v1.96 records it exactly: buildRaid spans hundreds of lines and G is not
assigned until AFTER it returns, so every (G&&G.sim) test evaluated during a map
build reads the PREVIOUS raid. It found one instance, in mkRaider, and fixed it by
threading the sim flag down as a parameter.

SWEPT, AND v1.96 WAS COMPLETE. buildRaid's own body contains exactly one mention of
G and it is inside a comment. Of the 72 functions it calls directly, exactly one
reads G, and that one is mkRaider. Going a level deeper, ping and wx read G and
would be genuinely dangerous at build time, since ping opens with if(!G) return and
a stale non-null G defeats that guard completely; neither is called during a build,
directly or through any callee. Nothing else to fix.

BUT THE FIX LEFT THE DEFECT IN THE FILE:

    var rec=(simBuild||(G&&G.sim))?{blank}:idRec(ident.id);

The stale read survives as an OR. It is unreachable today, and I checked rather
than assumed: runSim does G=null after every seed and the headless batch does the
same, verified live, so G is null or a live raid whenever this runs with simBuild
false. But it means the exact defect v1.96 diagnosed is still sitting in the line
that fixed it, one careless G assignment away from being live again, and what it
does when live is silent: every raider gets a blank grudge record and the whole
identity ledger switches off with no symptom.

Removed. Inert by logic rather than by measurement, which is stronger here: in a
sim build simBuild is true, and (true||X) is true for every X, so the sim cannot
tell the difference no matter what G holds. Confirmed in both directions anyway,
because a logical argument about the wrong expression is worth nothing:

    sim raid,  raider standing    0     blank record, correct
    live raid, raider standing  -76     real ledger read, correct
    G after a headless batch    null    which is why the fallback was unreachable

FIVE AUDITS, ALL CLEAN, so nobody runs them again.

  1. Only the player throws, confirmed above.
  2. The stale-G sweep across buildRaid and two levels of callees, above.
  3. CONTRACT PROGRESS. An ELITE kill contract multiplies by 2.4, so it can ask for
     5 snitches, and COLD STORAGE spawns 3 while THE QUARRY spawns 4. That looked
     like the impossible contract of v1.74 all over again. It is not: contracts
     live on P.contracts, which is the saved profile, and prog accumulates. Nothing
     resets it between raids. A five-snitch contract is a multi-raid job, not an
     impossible one.
  4. runSim's cleanup, which is what makes point 2 safe. G=null after every seed.
  5. The frag blast rename from v2.23 still holds with the raider kit confirmed,
     since raiders carry guns and grudges and no throwables.

Not verified: whether a blank grudge record is even distinguishable from a real one
at standing 0. A fresh identity he has never met also has standing 0, so if this
had gone live the symptom would have been invisible until a raider he had killed
twice greeted him like a stranger. That is an argument for having removed it rather
than a gap in the check, but it does mean I cannot write a regression test that
would have caught the original. Also not verified: the sweep covers functions
DEFINED with "function name(" at column zero. Anything assigned as a var or nested
inside another function would not appear in my call list, and this file has a
handful of inner helpers like that in buildRaid itself.

### v2.25: one Stray in six asked for the one thing you cannot hand over

v2.24 ended naming its own blind spot: the sweep only saw functions declared as
"function name(" at column zero, so nested helpers and var-assigned functions were
invisible, and buildRaid has several. Closed first, and it is clean.

THE BLIND SPOT, SWEPT. 36 nested function declarations and 2 var-assigned ones.
Of buildRaid's five inner helpers, clearOfPads, placeCache, far, nOf and takeBest,
NONE reads G. Of all 36 nested helpers only two mention G: botSpd, which does not
once you read the line rather than the window around it, and `one`, which is
runSim's own driver and ASSIGNS G rather than reading a stale one. Both
var-assigned functions, `outside` inside buildRaid and `done` in the config copier,
are clean. So v1.96 plus the v2.24 removal covers the whole class, including the
part I could not see when I said so.

THEN THE STRAY, WHICH HAS NEVER BEEN AUDITED. He asks for one item and pays for
it: a marked cache, 260 to 540 credits, and a point of notoriety cleared, which the
comment above him says is the only way to clear it other than waiting.

    var ix=G.bag.indexOf(e.want);
    if(ix<0){ say('He needs a '+ITEMS[e.want].name.toLowerCase()+'. You have none.'); return; }

It looks in the bag, and STRAY_WANTS is medkit, bandage, plate, ammobox, medkit,
bandage. An Ammo Box CANNOT BE IN THE BAG. The deploy loadout does reserve+=amt and
grantLoot does reserve+=amt, so a box dissolves into the ammunition pool at both
ends. Measured both paths on a live raid:

    at deploy            bag [plate, medkit, bandage], reserve 100, no ammobox
    picking one up       reserve 100 -> 140, bag grew by ZERO

So a sixth of all Strays asked for the single thing you can never be carrying, and
told you "You have none" no matter how many boxes were in your reserve. Same shape
as the impossible district contract at v1.74 and the keyless door at v1.75: the
game offers a trade it has made impossible, and it reads as your own failure to
find something.

There is exactly one exception and it is a coincidence, not a route: the Peddler
pushes his stock into G.bag, so a box BOUGHT from him is in the bag and would have
worked.

FIXED BY TAKING THE AMMUNITION FROM WHERE IT ACTUALLY LIVES. The bag is still
checked first, so a bought box is spent before your reserve is. Otherwise 40 rounds
come out of the pool, and if you cannot spare 40 he says so instead of pretending
you have nothing. It costs a real 40 rounds, which is the point: a gift should be
something you feel, and this is a game where running dry ends four raids in ten.

Verified, five cases on live raids:

    want      state                     result
    ammobox   100 reserve               helped, reserve 100->60, paid 291
    ammobox   20 reserve                refused, nothing spent, no payout
    ammobox   one bought, in the bag    helped, bag consumed it, reserve untouched
    medkit    in the bag                helped, unchanged behaviour, paid 268
    plate     none carried              refused, correctly

No balance arm and it is not possible to have one: strayGive opens with
if(!G||G.sim||...) return, and the sim build does not even place a Stray, which I
confirmed rather than assumed while trying to write the guard test. A 120 seed run
would compare the build against itself.

Not verified: whether 40 rounds is the right price. It is one Ammo Box exactly,
which is the honest reading of "he wants an ammo box", but the reserve is a single
universal pool shared by both guns, so 40 rounds off a Marksman Rifle player is
five magazines and off an LMG player it is barely one. The item is flat and the
weapons are not. Also not verified: whether he should want a plate at all now.
v2.16 made No Rig a real zero, so a player with no rig cannot carry a plate either,
and that is a second want he cannot satisfy, though unlike the ammo box it is a
consequence of a choice he made rather than of the plumbing.

### v2.26: the Stray's reward pointed at a locked door two times in five

v2.25 ended worrying that a no-rig player could not satisfy a plate request either.
Checked first, and the worry was wrong: with No Rig the ceiling is 0 so a plate
cannot be APPLIED, but grantLoot still puts a found one in the bag as salvage, and
the bag is what strayGive reads. Verified on a live raid with rig 'none': found
plate lands in the bag, Stray helped, 347 credits paid. Every want in the table is
now satisfiable by anyone.

His notoriety promise is also real, which the same read confirmed. The comment says
helping him is "the only way to clear it other than waiting", and strayGive does
decrement P.notoriety. Clean.

THE REWARD ITSELF IS WHERE THE DEFECT WAS. He pays in three things and the headline
one is a marked cache: "He tells you where a cache is. It is on your map."
strayReveal picked the farthest unopened container with c.cache set, deliberately,
because the comment says the far one is a reason to go somewhere you were not
going. The problem is what c.cache is true of. Three different things:

    3 ARC caches       placed in the open, the ones drawn on the sector map
    3 per locked room  and there are two locked rooms, so SIX
    the ARC STRONGBOX  which v2.12 established is placed inside a locked room
                       as its first preference

Gated caches outnumber open ones two to one, and being deep inside buildings they
are usually the farthest, so the far-one rule kept choosing them. Measured across
32 raids on all four maps:

    reveals pointing somewhere with no route without a key   13 of 32, 40.6%

v1.75 guarantees a key exists somewhere on the map, so it was never impossible.
But it turns a thank-you into a second errand, and the line he says does not
mention the door. That is the same shape as the impossible contract and the keyless
room, one step softer: the game keeps its promise in a way you cannot use yet.

Fixed by applying the far-one rule to the caches you can actually walk to, and
falling back to a gated one only when there is genuinely nothing else left. Same 32
raids, same seeds:

                                        before   after
    reveals behind a locked door          13       0
    fell back to a gated cache             -       0
    average distance from the player       -    3,110

Every reveal is now a named landmark, POWERHOUSE, RIM OFFICES, THE LONG DOCK, CHILL
ROW, and the far-one character survives at 3,110 units. The fallback was tested
directly rather than assumed: mark all three open caches revealed and it still
returns a gated one; mark everything and it returns null, which is the branch that
prints "he has nothing left to tell you, so he gives you what he has".

No balance arm and none is possible. strayGive opens with if(!G||G.sim) return and
the sim build does not place a Stray at all, which I confirmed at v2.25 while
trying to write the guard test.

Not verified: whether pointing at the strongbox was actually bad. It is the single
richest container in the game, three elite items, and a player who knows where it
is has something worth planning around even if the key hunt comes first. I have
treated "cannot walk there today" as the thing to fix because that is what the
sentence promises, but there is a reading where revealing the vault is the better
reward and the fix should have been to the WORDING instead. Also not verified: what
happens on a map with no locked rooms at all, since all four authored maps have
exactly two, and the fallback branch has therefore only ever been exercised by me
forcing it.

### v2.27: two extraction calls shared one siege, so the second one was free

Audited the extraction beacon, which is the system every other reward in the game
has to survive in order to pay out.

THE TELL WAS DEAD STATE. tryExtractTick sets five things when a beacon is called:

    z.beaconT=CFG.extractWait; z.hold=null; z.siegeSpawned=0; z.siegeSpawnT=0; z.siegeGreed=null;

Four of those are read again later. z.siegeSpawned and z.siegeSpawnT are never read
by anything. The tick that consumes them uses G.siegeSpawned and G.siegeSpawnT
instead, which is a global sitting inside a loop that runs PER ZONE, three lines
under z.siegeGreed being read per zone so the price of a call is fixed per call.

A SECOND BEACON IS REACHABLE, and I checked rather than assumed, because nothing
except the player calls one. The design comment says an AI raider can call a ring
across the map; the code has exactly one assignment to z.beaconT and it is the
player's. So this needs him to do it deliberately: call a ring, run to another and
call that too. Measured on BURIED CITY, three open rings 2,560 apart against a 25
second inbound wait and a 158 per second sprint. There is time.

WITH BOTH RUNNING, BOTH ZONES TICKED THE SAME COUNTER:

    siegeSpawnT after 10 seconds of sim     old 4.0     new 2.0 per zone
    per-zone clocks                         old 0, 0    new 2.0, 2.0

and the cap, which is the part that actually mattered. Greed pinned at 0.2 so the
interval is about 7.1 seconds and the cap is 8 per call, run to exhaustion:

                        arrivals   zone A   zone B
    one beacon, old         8         -        -
    one beacon, new         8         8        -
    two beacons, old        8         -        -
    two beacons, new       16         8        8

One beacon is unchanged, which is the control that matters. Two beacons under the
old code produced EIGHT arrivals total, because both calls drew on one budget. So
calling a decoy ring cost nothing: you doubled your chances to board and the ring
did not get any worse for it. The comment above the code promises "one machine
every 8 seconds while the beacon runs or the ship holds, capped at six per call".
Per call is now what it is, and a second call costs a second siege.

The globals are kept in step with the ring you are standing at, so anything reading
G for display keeps working, verified on a live beacon driven through real frames:
zone counter 1, global mirror 1, drawErr null.

PROVED INERT FOR THE SIM. The bot calls one beacon, so this should change nothing
headless, and 120 seeds an arm comparing outcome, duration, shots, haul,
containers, killer, siege arrivals and beacon calls as one joined string came back
120 of 120 BYTE IDENTICAL. siegePerZone 0 restores the shared global.

Also checked and clean on the way: the Stray's plate want is satisfiable by a
no-rig player after all, since grantLoot puts a found plate in the bag even at
ceiling 0, and his notoriety promise is real, P.notoriety is decremented.

Not verified: whether a second call SHOULD cost a second siege, or whether the
right fix was the opposite one, making a second call impossible while a beacon is
already inbound. I fixed the code to match the comment above it, which is the
conservative reading, but "capped at six per call" was written when there was only
ever one call and it may simply not have contemplated two. Making a decoy ring
genuinely expensive is a real difficulty increase for a tactic he may never have
used, and if he was using it deliberately this removes it. Also not verified: the
shared-cap behaviour on the ship HOLD phase specifically, since my measurement
pinned beaconT to a huge number to reach the cap and never exercised the handover
into z.hold.

### v2.28: I fixed one of the two clocks last build

v2.27 moved the siege SPAWN counter off the global and onto the zone, because it
was a global being ticked inside a loop that runs per zone. It stopped there. Two
lines below the code it changed, in the same loop, sits the re-ping clock:

    G.siege=(G.siege||0)+dt;
    if(G.siege>=2){ G.siege=0; ping(z.x,z.y,1200*(1+0.7*GR),...); }

Same defect, same loop, same build failed to see it. Measured with two beacons
running, 20 seconds of sim, counting how many times the clock fired:

    one beacon    10 of an expected 10      correct
    two beacons   20 of an expected 10      exactly double

It is not a small thing to double. That ping is 1200 strength, the loudest event in
the game, half again past the 760 the Listener's falloff caps at, and every one of
them drags everything within 1500 units into investigate. Two calls turned the
whole map over twice as often as one, on top of the spawn rate v2.27 already found.

Fixed the same way, so both clocks now live on the zone that owns them and the
globals mirror the ring you are standing at:

                          before   after
    one beacon              10       10     the control, unchanged
    two beacons             20       10

AND THE HOLD PHASE, WHICH IS THE PART v2.27 SAID IT HAD NOT TESTED. That entry
admitted its measurement pinned beaconT to a huge number to reach the cap and never
exercised the handover into z.hold. Tested here, with the beacon expiring into the
boarding window: 10 re-pings of an expected 10 with one beacon and with two, and
the hold counting down correctly from 30. The comment promises arrivals continue
"while the beacon runs or the ship holds", and both halves now behave.

The whole cycle also driven end to end through real frames rather than by pinning
state: beacon, into hold, ship leaves without you, beaconMissed incremented once,
drawErr null.

PROVED INERT FOR THE SIM, which calls one beacon. 120 seeds an arm comparing
outcome, duration, shots, haul, containers, killer, siege arrivals, beacon calls
and beacons missed as one joined string: 120 of 120 BYTE IDENTICAL. siegePerZone 0
restores both globals together, since they are one defect.

Not verified: whether anything else in that loop is still global. I checked the
three counters this file names siege-something and they are now all per zone or
correctly global, but the loop is fifty lines long and I found this one only
because v2.27 had walked past it, which is not a search strategy. The honest state
is that I have fixed the two I found rather than proved there is not a third. Also
not verified: whether two simultaneous beacons should re-ping the same ring twice
when both are within 1500 units of it, which they can be, since the ping is
positional and two nearby rings would each alert the same machines. That is a
double-alert rather than a double-clock and this build does not address it.

### v2.29: walk away from the ring you called and the HUD lies for the rest of the raid

v2.28 ended admitting that finding the same defect twice by walking past it is not
a search strategy. So this build read the whole 142 line loop rather than the two
lines next to the last bug, and enumerated every piece of state it touches.

THE SWEEP ITSELF CAME BACK CLEAN, and that part is worth saying. Fifteen G fields
and ten z fields appear in tickExtractPoints. Two of the G ones, G.siegePerZone and
G.raidSec, are not fields at all: my pattern matched the tail of CFG.siegePerZone
and CFG.raidSec, which is a reminder that a regex over source is not a reader. Of
the rest, every write to a global inside the per-zone loop is either guarded by
z===G.active or sits in the else branch that restores the old behaviour. No third
global clock. The two v2.27 and v2.28 found were the two there were.

BUT THE GUARD ITSELF IS THE BUG. G.beaconT, G.shipHold and G.shipHoldMax exist so
the HUD and the telemetry can read one value without knowing which ring owns it.
Every write to them is guarded by z===G.active, and the loop skips any zone with no
beacon. So the moment you walk from the ring you called to a different ring, the
mirror stops being updated AND stops being cleared.

Measured, calling a ring at 6 seconds and then standing in another:

                                    old        new
    ring ticks down to               4          4
    G.beaconT mirror reads           6          4     frozen, then tracking
    after the ship leaves            6        null    never cleared, then cleared
    HUD prints            BEACON INBOUND 6s   nothing
    diedInSiege would fire          yes         no

Two things read that value. drawHUD prints "BEACON INBOUND 6s" with a progress bar,
permanently, for the remainder of the raid. And killPlayer sets diedInSiege from
G.beaconT!==null, so every later death in that raid is filed as a siege death, in
the same telemetry this project has been quoting siege numbers out of.

Fixed by recomputing the mirrors once, after every zone has ticked, from the zones
themselves. The ring you are standing in wins so the number matches the circle you
are in; otherwise any live beacon does, which is what you want when you called one
and walked off; and when none is live the mirrors clear. Standing in your own ring
is unchanged, verified: zone 7, mirror 7, exact match.

Driven through real frames across all three phases with the HUD drawing each one:
inbound at 1.9, holding at 29.9, gone at null, drawErr null throughout.

PROVED INERT FOR THE SIM. diedInSiege is in simResult so this could have moved
numbers, which is why it went behind a dial rather than straight in. 120 seeds an
arm comparing outcome, duration, shots, haul, killer, diedInSiege, beacon calls,
beacons missed and siege arrivals: 120 of 120 BYTE IDENTICAL. The bot calls its
ring and stands in it, so it never meets this. beaconMirror 0 restores the guarded
writes alone.

Not verified: how far back the diedInSiege figures are wrong. The stale mirror only
persists if you leave a called ring, which the bot never does, so every batch number
this project has published is unaffected. His own runs are another matter, and the
17 run export he sent carried diedInSiege values I have never gone back and
recomputed. I am not going to pretend those are trustworthy now. Also not verified:
whether preferring the ring you stand in is right when two are live and neither is
yours, which cannot happen today because nothing but the player calls one, and
would need a rule the moment anything else does.

### v2.30: section 13 was still asking him a question he answered thirty builds ago

v2.29 ended saying his 17 run export carried diedInSiege values I had just made
suspect and had not recomputed. So this build went back to the export. The column
is fine, and the trip found something worse than a bad number.

THE COLUMN IS CLEAN. Exactly one run in the eighteen carries diedInSiege:1, run
#12, and that run reads beacon:1called/0missed with closestExt:2. He was two units
from the middle of the ring when he died. The stale mirror v2.29 fixed only
persists if you LEAVE a called ring, and he had not left it. Nothing in that export
needs recomputing, which is the answer I wanted rather than the one I expected.

THEN I CHECKED HIS NOTES AGAINST CURRENT CODE, which is the standing rule and the
reason it exists. Run #4, "once i call the beacon and it arrivs i should have 30
seconds t get back into the circle": built, z.hold is Math.min(30, ...). Run #5,
"player should be able to use the beacon and extract while downed": built, and the
comment in updatePlayer cites that note by number.

AND SECTION 13 STILL ASKS IT AS AN OPEN QUESTION. The entry, dated v0.82, reads:
"What should the dropship do if you are bleeding out inside the ring when it lands?
Right now the inbound countdown freezes the moment you go down... Measured: the
beacon ticks 0.00 seconds in 4.8 while downed... Two options, both a change of
feel... One line either way."

Every part of that is out of date. He answered the question in run #5, the answer
was implemented, and the measurement it quotes is no longer true. Re-measured on
the current build rather than trusted:

    beacon while downed        10.0 -> 7.0 across three seconds, not 0.00 in 4.8
    downed operator calling    reaches 22.6 with E held, so yes
    boarding, all four cases   standing+E EXTRACT   standing, no E  no
                               DOWNED+E   EXTRACT   downed, no E    no

So a downed player boards by pulling, exactly like anyone else, which is the right
rule and matches "pull again to board" everywhere else in the file.

That entry has sat in "What is waiting on Daniel" for thirty builds describing a
question that was answered and a behaviour that was changed. I have read section 13
at the start of a tick more than once this session looking for the highest value
open item, and this was in it. It is retired with the measurements above rather
than deleted, so the next reader can see it was closed by him and when.

ALSO CORRECTED, ONE LINE OF MINE. The comment above that code said the crew "drags
you aboard", which reads as automatic. It is not: E passes through while you are
down, and you still pull. The mechanic is right and only the description was
overselling it. Reworded rather than reimplemented, because the four-way
measurement says the behaviour is correct.

No balance arm. The only executable change is a comment, and the section 13 edit is
documentation; a sim raid still runs and the four boarding cases behave identically
after the edit, which is the check that the comment change touched nothing.

Not verified: the rest of section 13. There are five more entries in it and two
gated items, and I have only re-measured the one I happened to trip over. On this
evidence the list should be assumed stale until each entry is checked the way this
one was, and I have not done that. Also not verified: whether run #12's
diedInSiege:1 is right for the right reason. He was in the ring, so the flag is
plausible, but a beacon he had called and a siege that had actually begun are two
different conditions and the flag only tests the first.

### v2.31: he chose "hauled aboard" at v0.90 and it was never built

v2.30 retired one stale section 13 entry and said the rest of the list should be
assumed stale until checked. Checking the next one found something worse than
staleness.

FIRST, THE ONE I WENT LOOKING FOR. Section 13 asks "Should machines be able to walk
around cover to reach you?" and says route finding is wired into looting,
investigating and extraction "but deliberately not into combat chasing". That is
false. The chase branch calls navSeek at the player in five places. Measured over
ten raids: 4,961 chase ticks observed, 1,920 of them carrying a routed path, 38.7
percent, with routes up to seven waypoints.

It is not a regression, and the history says who decided it. v0.90's own note:
"Chase now routes around cover instead of clipping corners, BECAUSE HE APPROVED
LETTING THEM HUNT". So that question was answered by him and built forty builds
ago, and section 13 has been asking it ever since.

AND THE SAME NOTE CONTAINS A PROMISE THAT WAS NEVER KEPT. The next clause reads:
"The dropship keeps flying while you are down and TAKES YOU IF YOU ARE IN THE RING,
because he chose hauled aboard."

The first half shipped. The second half did not, and the diff proves it: v0.90's
downed branch called tryExtractTick(dt) with no wantCall argument, so a downed
operator could not board at all. Later, answering his run #5, the E key was passed
through, which lets a downed player board BY PULLING. Automatic pickup, the thing
he actually chose, has never existed in this game.

v2.30 IS MINE TO OWN. Last build I found the comment saying his crew "drags you
aboard", measured that you still have to pull, and reworded the comment to match
the code. I called the pull requirement "the right rule". It matches the code and
it contradicts his decision, and I checked the code against itself instead of
against what he asked for. That is the same failure the standing rule about
re-checking his notes exists to prevent, one level up.

BUILT. A downed operator inside the ring with the ship down is taken. Reaching that
branch already means standing in the circle with the ship landed, so the only new
condition is being unable to stand up.

Verified, all four combinations plus the boundary:

    state                        pull-only (old)   hauled (new)
    downed, in ring, no E             no extract      EXTRACT
    downed, in ring, E held           extract         extract
    downed, OUTSIDE the ring          -               no extract
    standing, in ring, no E           -               no extract

That last row needed a second pass and is worth recording. It first came back as an
extract, which looked like my guard firing for an upright player. It was not: the
siege had downed him while he stood there, so the pickup was correct. Re-run with
hard invulnerability so he cannot go down, a standing player with no E does not
leave, hold sitting at 10.2 with the ship still on the ground. The guard is right
and my first reading of my own test was wrong.

PROVED INERT FOR THE SIM. 120 seeds an arm on outcome, duration, haul, killer,
downs, holdExtract and beacon calls: 120 of 120 identical. The bot never goes down
inside a holding ring, so it cannot reach this. hauledAboard 0 restores pull-only.

Not verified: whether he still wants it. He chose this at v0.90, which is forty
builds and a great deal of tuning ago, and the argument against it is real: being
taken automatically removes the last decision in the tensest moment of a raid, and
a player who wanted to crawl out and try again no longer can. I have built what he
asked for rather than what I would pick, and the dial is there because the gap
between those two is exactly where I should not be guessing. Also not verified: the
remaining three section 13 entries, two of which I can already see are stale. The
shop one says the dearest item is the Marksman Rifle at 4,500 when the Breacher
Plate is 7,800, and the backpack one describes a carry limit that PACKCAP made
unlimited on 2026-08-22 at his request.

### v2.32: the last two stale entries in section 13, re-measured

No game logic changed. v2.30 and v2.31 each found a section 13 entry asking a
question he had already answered. The two remaining measured entries were quoting
v0.80 figures, so this re-measures both. Neither turns out to be an answered
question; both turn out to have the wrong numbers, and one has the wrong mechanism.

THE SHOP ENTRY. It said a full bag is worth 4,400 to 5,000 credits and the dearest
item is the Marksman Rifle at 4,500. Current, 120 seeds on BURIED CITY at the
DEFAULT simGreed of 52 rather than the 20,000 my recent arms have been pinning:

    all 120 raids       mean 9,028   median 9,632   range 76 to 23,703
    extracted only      mean 11,338  median 10,885  never below 5,687   25 of 120
    extract rate        20.8 percent

And the shop has moved further than the haul did. The dearest item is the Breacher
Plate at 7,800, which did not exist when this was written; the DMR at 4,500 is
second. Everything in the shop together is 26,570, and the highest reputation gate
is 5,000.

So the entry's CONCLUSION survives and is stronger than when written: one extracted
raid banks a mean 11,338 against a dearest item of 7,800. His own eighteen recorded
runs are the honest counterweight, because the bot is not him: five extracted, mean
6,300, best 11,500, so one good raid of his does not quite cover the Breacher and
two do. Either way his profile settles it. He is carrying 13,085 credits, has
bought nothing, and is still wearing No Rig. Credits are not his constraint.

THE BACKPACK ENTRY, WHERE THE MECHANISM IS NOW WRONG. It said a bot looting to its
carry limit fills up and leaves after about two and a half minutes, so the last
seven of the ten he asked for are spare. The shape holds:

    duration, 120 raids   mean 195s   median 201s   against a 600s clock
    ran the full clock    1 of 120
    finished under 150s   37 of 120

One raid in a hundred and twenty uses the ten minutes. But the cause named in the
entry no longer exists. PACKCAP has been [99999,99999,99999] since 2026-08-22, at
his own request for unlimited carry, so there is no carry limit to fill. What ends
a bot raid is simGreed, a bag weight threshold of 52 that exists ONLY in the sim.
The entry was describing a measurement dial as though it were the game.

The consequence is worth stating plainly because it is not what the entry implies:
A HUMAN PLAYER IS NEVER PUSHED OUT BY HIS BAG AT ALL. Nothing makes a raid a ten
minute commitment, and carry weight is no longer available as the lever, because he
already spent it on unlimited carry. The question stays open, with its answer space
smaller than the entry claims.

Both entries are updated in place with the measurements and the stale figures kept
visible, rather than retired, because unlike the two before them these are still
genuine open questions.

Not verified: the haul numbers on the other three maps. Everything above is BURIED
CITY, which v2.13 measured as one of the two EASY maps at 22.5 percent, so the 20.8
percent extract rate and the 11,338 extracted haul are close to a best case. COLD
STORAGE at 6.7 percent would bank far less per raid simply by extracting less
often, and I have not run it. Also not verified: whether simGreed 52 is a fair
stand-in for how he actually loots. It is the shipped default and therefore the
right number to quote, but his five extracted runs averaged 6,300 against the sim's
11,338, which is a gap wide enough that the two are not measuring the same player.

### v2.33: the sim banks twice what he does because it opens three times the containers

v2.32 ended on a worry with teeth: the sim reports 11,338 credits for an extracted
raid and his own five extracted runs averaged 6,300, and if the bot is looting a
different game from the one he plays then every balance number this session quoted
inherits the error. Decomposed, and the answer is reassuring in a way I did not
expect.

    extracted raids     containers   items   haul     per container
    the sim, 120 seeds     21.2       32.8   11,338        534
    him, 5 real runs        7.0       13.4    6,300        900

THE BOT OPENS THREE TIMES AS MANY CONTAINERS AND GETS 40 PERCENT LESS OUT OF EACH
ONE. He loots selectively and well; the bot loots exhaustively and badly. Across
all eighteen of his runs he averages 5.6 containers, so this is his style and not
one lucky raid.

That matters for what it does NOT invalidate. Every arm this session has been a
paired A/B inside one build, so a difference in how thoroughly the bot loots
appears in both arms and cancels out of the comparison. The extract rates stand.
What does not stand is any ABSOLUTE haul figure quoted from the sim as though it
were his: the sim's 11,338 is a thorough looter's number and he banks 6,300.

It also puts a number on something the project already suspected. The bot's 534 a
container against his 900 is the crate problem measured from the other end: the
containers he skips are the ones dragging the average down, which is the same
finding as "81.8 percent of crates pay under 150c" arriving by a different route.

TWO AUDITS ON THE WAY, BOTH CLEAN.

The haul figure is honest. haul is the sum of ival() over the bag, extracted items
go to the stash, and the stash sells at the same ival. Driven end to end with a
known bag: reported 1,750, six items banked, stash sell value 1,750, exact match,
and no credits move during the raid. The number on the screen is the number you get.

And the export renders correctly for a real log row, no undefined fields.

SHIPPED, SO NOBODY HAS TO DERIVE IT AGAIN. The run line now carries perCont, the
haul divided by containers opened. It is the single number that separates a
thorough looter from a selective one, it took a hand decomposition to get at this
tick, and the next export will simply state it. Verified against his own data:
run #1 was haul 7,115 over 16 containers and the line now reads perCont:445c, which
is 444.7 rounded. Omitted entirely when a run opened nothing, so a death at 40
seconds does not print a division by zero.

Not verified: whether his 900 a container is skill or version. His eighteen runs
are a v1.87 recorder and the loot tables have moved since, including v2.12 relocating
stranded containers and the crate work before it, so part of the per-container gap
could be the game rather than the player. The only clean way to separate those is a
fresh export from him on the current build, which is also the only thing that would
tell me whether any of this session's twenty-odd builds improved his experience at
all. Also not verified: the bot's 534 is BURIED CITY only, and container mix varies
by map, so the crate reading above is one map's worth of evidence.

### v2.34: the bot cannot read the pip, and the player is expected to

v2.33 measured that the bot opens 21.2 containers at 534 credits each while his own
extracted runs opened 7.0 at 900, and ended saying the bot spends its raid on
containers he would walk past. This is why.

    p.goal=null; var bd=1e9;
    for(i=0;i<G.containers.length;i++){
      var ct=G.containers[i]; if(ct.opened||ct.skip) continue;
      var dd=dist(p,ct); if(dd<bd){ bd=dd; p.goal=ct; }
    }

Pure nearest-first. Value never enters it. Meanwhile every unlooted container
carries c.best, the best rarity inside it, and the comment where that is set says
precisely what it is for: "what you read across a room to decide whether the trip
is worth it". The game hands the player a value signal and gives the bot no way to
see it, so the sim has been modelling a player who loots whatever he trips over.
That is the same family as crouch, water, the sidearm and the jam: a mechanic the
player uses and the bot cannot.

simPip weighs the pip against the walk. A rare container is worth going twice as
far for, an elite more than three times, blended by the dial's strength so it is a
weighting rather than a switch. Measured, 120 seeds an arm on BURIED CITY, with his
own five extracted runs in the last row for scale:

                   containers   haul     per container   extract   duration
    nearest-first     21.2      11,338        534         20.8%      195s
    reads the pip     18.0      13,352        743         23.3%      178s
    HIM                7.0       6,300        900           -          -

Every axis moves toward him. Fewer containers, more out of each, more banked, out
sooner, and out more often. That is four independent measures agreeing, which is
the strongest evidence yet that the pip is the thing he is actually using and the
bot's 534 was never his number.

The extract rate moves 2.5 points, which at 120 seeds is inside one standard error
and is not a claim. The per-container figure is the claim: 534 to 743, a 39 percent
improvement in what a container is worth, from nothing but choosing better ones.

IT DEFAULTS TO OFF, AND THE EVIDENCE ARGUES THE OTHER WAY. simSell, simPed and
simCrouch all default 0 for one reason: they change what the bot IS rather than
fixing something broken, and every number in this file's back catalogue was
measured without them. simPip is the same kind of change and gets the same
treatment. But I want the disagreement on the record rather than buried: four
measures say the pip arm is closer to the real player, so the honest reading is
that simPip 1 is the better model and simPip 0 is the more comparable one. That is
a decision with numbers attached rather than a shrug, and it is his to make.

Verified: all four maps and the hub draw clean, a container with its pip deleted
still gets chosen without throwing, and the shipped default reproduces the
nearest-first behaviour.

MY OWN CONTAMINATION, CAUGHT AND CLEARED. The verification pass reported the
default as 1. It was not: the source has simPip:0 and the saved profile had 0. My
measurement loop had left CFG.simPip at 1 in the live fixture session and I read it
back before resetting. Nothing persisted, and the dial is back at 0, but I nearly
reported my own test state as a shipped default.

Not verified: whether the weights are right. common 1, uncommon 0.75, rare 0.5,
elite 0.3 are the first numbers I tried and they were not tuned, only measured. A
sweep would tell you whether the bot should go three times as far for an elite or
ten, and there is a real risk that a strong weighting sends it across the map past
easy money. Also not verified: the pip tells you the BEST rarity in a container,
not the total, so a crate with one rare and nothing else outranks a safe with four
uncommons. That is what the player sees too, so the bot is now wrong in the same
way he is, which is the point, but it means neither of you is optimising value.

### v2.35: the pip weight swept, and it does not buy survival

No game logic changed. v2.34 shipped simPip with the first weights I tried and said
so in its own Not verified line. This sweeps them. The dial was already written as
a STRENGTH rather than a switch, so the sweep needed no code at all: five arms, 120
seeds each on BURIED CITY, everything else pinned.

    simPip   containers   value per container   extract   duration
      0         17.9             503             20.8%      195s
      0.25      16.8             510             20.8%      182s
      0.50      16.7             537             20.0%      190s
      0.75      15.5             580             27.5%      184s
      1.00      14.5             665             23.3%      178s

WHAT THE DIAL CONTROLS, IT CONTROLS CLEANLY. Containers fall monotonically from
17.9 to 14.5. Value per container rises monotonically from 503 to 665, a 32 percent
improvement. Duration falls from 195 seconds to 178. Three series, all monotone,
all in the direction the mechanism predicts: the bot walks past more junk, gets more
out of what it does open, and finishes sooner.

WHAT IT DOES NOT CONTROL IS WHETHER THE BOT LIVES. Extract rate reads 20.8, 20.8,
20.0, 27.5, 23.3. That is not a curve, it is noise around 22 with one high reading.
At 120 seeds and a rate near 0.22 one standard error is 3.8 points, so the 27.5 at
0.75 is 1.75 standard errors above the baseline and the arm ABOVE it falls back to
23.3. A real effect does not disappear when you turn the dial further up. I am
calling that spike noise, and if I had swept three values instead of five I would
have reported a peak at 0.75 and been wrong.

SO THE WEIGHTS DO NOT NEED RETUNING. common 1, uncommon 0.75, rare 0.5, elite 0.3
were the first numbers I tried and the sweep says the response is smooth and
monotone across the whole blend range, which is what you want from a weighting: no
threshold, no cliff, no value at which the bot starts sprinting across the map past
easy money. The strongest setting is also the best match to his behaviour, so if
the dial is ever turned on, 1 is the value.

AND THE SWEEP ANSWERS THE DEFAULT QUESTION MORE PRECISELY THAN v2.34 COULD. That
build kept simPip at 0 on the general principle that it changes what the bot IS.
The sweep sharpens it: the dial moves haul and container figures a great deal and
does not move extract rate at all. So turning it on would invalidate every HAUL
number in this file's back catalogue and would leave every EXTRACT RATE comparison
intact. That is a much narrower cost than I assumed, and it is worth him knowing
that the fidelity gain is available for the price of one column rather than all of
them. It stays 0 until he says otherwise.

Not verified: any of this on the other three maps. BURIED CITY has 187 containers
at the density measured in v2.15 and COLD STORAGE has 136, so a map with fewer
containers offers fewer chances to be choosy and the same dial should do less there.
The monotonicity is the claim I would defend across maps; the magnitudes are one
map's. Also not verified: whether a bot that skips junk should also skip it when the
bag is nearly full, which is the point where a common crate two steps away beats an
elite across the street. The dial has no notion of how much room is left.

### v2.36: every number I have published was measured at world tier 1 and never said so

v2.35 ended naming a blind spot in simPip: it weighs rarity against distance but
never against how much room is left in the bag. Checked first, and it is mostly not
a blind spot, which is worth saying before anything else.

RARITY ALREADY PROXIES THE THING THE LOAD PENALTY CHARGES FOR. Carry is unlimited
since 2026-08-22, so weight costs you speed and noise rather than space, which means
the quantity that matters is value per unit weight. Across the whole item table:

    rarity      mean value/weight   median   min    max
    common             63             60      23     110
    uncommon          186            155     105     275
    rare              352            317     260   1,400
    elite             765            760     425   1,550

Medians of 60, 155, 317, 760, roughly two and a half times a tier, cleanly
separated. A bot choosing by pip is already choosing approximately by value per
weight. The blind spot I named is real only at the edges where the ranges overlap,
and I am recording that rather than building a fix for it.

THEN THE THING I ACTUALLY FOUND, WHICH IS ABOUT MY OWN NUMBERS. ival multiplies
every item value by seasonLoot(), and every machine's health is multiplied by
seasonHp(). Both read P.worldTier and neither has a sim guard, so the headless
batch inherits whatever tier the profile is on.

The fixture profile is on TIER 1. So loot has been scaled by 1.08 and enemy health
by 1.06 for every measurement this session, roughly twenty builds of arms, and not
one of them recorded it. The tier advances only when a season reward is claimed,
which also zeroes the season points, so tier 1 with sp 0 is consistent and not a
defect; the defect is that nothing anywhere wrote the number down.

It does not make the comparisons wrong. Every arm was paired inside a single tier,
so the multiplier appears on both sides and cancels, which is the same argument that
saved the haul figures at v2.33. What it does is make them NON-TRANSFERABLE. A
profile on tier 0 sees 8 percent less loot and 6 percent weaker machines than every
figure in this file, a profile on tier 5 sees 40 and 30 percent more, and nobody
reading the export could have told which they were looking at.

Fixed by making it impossible to miss. simResult now carries tier, lootMul and hpMul
on every row, so a batch cannot be compared across tiers by accident. And the export
header states it in words:

    World tier 1 (season 2): loot x1.08, enemy health x1.06
      [every haul and credit figure below is scaled by this]

with a [neutral] marker instead when the tier is 0, verified by flipping the profile
to 0 and back.

Not verified: what tier HIS profile is on. The fixture is a copy and has been through
a season claim; his live save on 8802 may be on 0, 1 or something else, and if it is
not 1 then the absolute figures I have been quoting to him are off by up to 8 percent
on loot in whichever direction. The next export he sends will now say so on its first
screen, which is the point of the change, but until then I cannot correct the record.
Also not verified: whether the sim SHOULD inherit his tier at all. Modelling his
actual world is a defensible reason to, and shielding the measurement from a moving
profile is a defensible reason not to; the v1.96 grudge-record fix chose shielding
for a similar case, and I have chosen visibility here rather than quietly picking a
side on his behalf.

### v2.37: the sim inherited his world tier, and it was worth eight points of extract rate

v2.36 made the world tier visible and left the question open: should the sim inherit
it at all. The file had already answered, three lines into the same player object:

    armor:(sim?armorById('light').cap:myRig().cap)

with the comment "a constant baseline also keeps the numbers comparable across
builds, which is the whole point of having a sim at all". The rig is pinned because
it varies with his progression. The world tier varies with his progression and was
not pinned. So this is consistency with a decision already made rather than a new
policy, and the sim now runs at tier 0 regardless of the profile.

I EXPECTED THIS TO BE AN EIGHT PERCENT ADJUSTMENT TO HAUL. It is not. 120 seeds an
arm, everything else pinned:

                        tier   extract   haul    extracted haul   containers   dur
    inherits profile      1     20.8%    9,028      11,338          17.9       195s
    pinned neutral        0     29.2%    8,897      10,859          18.3       197s

EXTRACT RATE MOVES 8.4 POINTS. 17 seeds flip to extract, 7 flip to dead, 96 keep
their outcome. McNemar on 24 discordant pairs is z 2.04, p about 0.04, which is the
first result this session to clear the bar on its own rather than being reported as
suggestive.

A six percent change in machine health buys eight points of survival. That is a
much steeper response than the multiplier suggests, and it says the game sits at an
operating point where small changes to enemy durability matter a lot. Worth knowing
independently of this build.

AND IT MEANS MY PUBLISHED EXTRACT RATES WERE TIER 1 FIGURES. Everything this session
has quoted, the 20.8, the 22.5 on BURIED CITY, the four-map spread at v2.13, was
measured on a profile carrying loot x1.08 and machines at x1.06. A neutral profile
sees roughly eight points more. The COMPARISONS still hold, because every arm was
paired inside one tier and the multiplier appears on both sides, which is the same
argument that saved the haul figures at v2.33. The ABSOLUTE rates were eight points
pessimistic and I did not know it.

Haul barely moves, 9,028 to 8,897, because the eight percent cut to item values is
nearly cancelled by more raids surviving to bank anything.

IMPLEMENTED WITHOUT REOPENING A TRAP. worldTier is read from ival, which runs during
buildRaid before G is assigned, so testing G.sim inside it would have reintroduced
exactly the stale-G defect v1.96 diagnosed and v2.24 finished removing. The flag is
set from buildRaid's own sim parameter instead. Verified that the live game is
untouched: a live raid built immediately after a sim batch still spawns sentries at
159 health, which is 150 times 1.06, his real tier, on all four maps. A sim sentry
is 150. The export header still reports HIS tier, not the pinned one, because that
header describes his game and not my instrument.

simPinTier 0 restores inheritance.

Not verified: the pairing here is weak and I am not going to dress it up. Changing
enemy health changes combat, which changes the whole raid, so the two arms are not
the same 120 raids and the 96 matching outcomes are matching outcomes rather than
matching raids. The McNemar figure treats the seeds as paired, which flatters it. A
cleaner design would hold health fixed and vary only the loot multiplier to separate
the two halves of the tier, and I have not run that. Also not verified: whether the
8.4 points is specific to the step from tier 1 to 0. Tier 5 is health x1.30, five
times the step measured here, and there is no reason to assume the response stays
linear that far out.

### v2.38: enemy health is the steepest dial in the game, and loot value does not touch survival at all

No game logic changed. v2.37 measured 8.4 points of extract rate from pinning the
sim's world tier and admitted the arm confounded two things: tier 1 raises machine
health by six percent AND item values by eight. This separates them, and it needed
no code, because eHp and lootMult are already sliders and the sim now runs at
neutral so each one isolates cleanly. A two by two with the fourth cell already
measured last build, 120 seeds an arm:

    arm            eHp    lootMult   extract   haul    duration
    A neutral      1.00     1.00      29.2%    8,897     197s
    B health only  1.06     1.00      18.3%    8,331     195s
    C loot only    1.00     1.08      29.2%    9,518     196s

HEALTH IS THE WHOLE EFFECT. Six percent more machine health costs 10.9 points of
extract rate, 29.2 down to 18.3. That is the steepest response this project has
measured from any single number: roughly 1.8 points of survival per one percent of
enemy health, over the step tested.

LOOT VALUE MOVES SURVIVAL BY EXACTLY ZERO. 29.2 against 29.2, the same 35 raids of
120. It moves haul by 7.0 percent, which is the multiplier arriving where it should
and nowhere else.

AND THAT NULL IS STRONGER THAN IT LOOKS, because I checked whether arm C was really
a pure economy change and it was not. greedOf() is bagValue()/greedFull and
bagValue() sums ival(), so an eight percent loot multiplier raises PERCEIVED GREED
by eight percent, and greed drives the siege: the arrival interval is 8-4.6*GR and
the cap is 6+8*GR. Arm C was carrying a slightly angrier siege the whole way and
still landed on the same extract rate to the decimal.

WHAT THIS IS WORTH TO HIM. He has said the game is too hard more than once, and
eHp is a slider already on his Tuning Console. This is the exchange rate: about
1.8 points of extract rate for every percent of enemy health, in the region around
1.0. Turning eHp down to 0.94 should buy roughly the same eleven points that tier 1
was taking away. I am not touching it, because difficulty is his and a dial he
already owns needs a number rather than a decision from me.

It also re-frames three builds of my own work. v2.05 and v2.06 went after the
Listener, v2.15 after camp guard density, v2.27 and v2.28 after the siege clocks,
and the largest effect any of them produced was a couple of points. A six percent
change to one stat is worth five times that. If the question is ever "make the game
easier", the answer is not the machines' behaviour, it is their health.

Not verified: linearity, and I want to be exact about how little I know here. Two
health points were tested, 1.00 and 1.06. Quoting 1.8 points per percent is a
straight line drawn through two dots, and there is no reason the response stays
straight at 0.9 or at 1.3. Tier 5 is health x1.30, five times the step measured,
and extrapolating this slope there would predict an extract rate below zero, which
is obviously wrong and shows exactly how far the linear reading can be trusted.
Also not verified: whether the same steepness holds on the other three maps, since
COLD STORAGE already sits at 6.7 percent and has much less room to fall.

### v2.39: enemy health is a threshold, not a slope, and my v2.38 exchange rate was wrong

No game logic changed. v2.38 quoted "roughly 1.8 points of survival per one percent
of enemy health" and flagged in its own Not verified line that this was a straight
line drawn through two dots. This sweeps the dial and the line is not there. 120
seeds an arm, BURIED CITY, simGreed 52, simPinTier 1, lootMult 1, everything else
pinned:

    eHp     sentry HP   SMG shots to kill   extract   haul    duration
    0.85       128             11            30.0%    9,227     206s
    0.94       141             12            27.5%    8,612     189s
    1.00       150             13            29.2%    8,897     197s
    1.06       159             14            18.3%    8,331     195s
    1.10       165             14            20.3%    8,419     196s

MY v2.38 NUMBER IS WRONG AND SO WAS THE ADVICE THAT CAME WITH IT. There is no
constant exchange rate. The first three arms are flat, 30.0 / 27.5 / 29.2, all
inside one standard error of each other, and that covers a 15 percent range of
enemy health. Then it drops and stays down. Worse, v2.38 told him that turning
eHp down to 0.94 would buy back about eleven points. It buys back nothing: 0.94
measures 27.5 percent, which is LOWER than leaving the dial at 1.00. I gave him a
number to type into his own Tuning Console and it would have made his game very
slightly worse while he believed it was making it much better.

WHAT IS ACTUALLY THERE IS ONE THRESHOLD. Everything at or below 13 SMG shots to
kill a sentry sits near 29 percent. Everything at 14 sits near 20. The break is
between 13 and 14, and there is no step at 11 to 12 or 12 to 13, so this is a
single threshold rather than a staircase with a step per round.

AND IT TRACKS THE SHOT COUNT, NOT THE HEALTH. That prediction was made before the
test was run, which is the only reason it is worth anything. Sentry health was
pinned at 150 and the SMG was weakened from 12 damage to 11, which moves shots to
kill from 13 to 14 while leaving every enemy's health exactly where it was. Same
120 seeds:

    arm                              sentry HP   shots   extract
    eHp 1.00, SMG dmg 12                150       13      29.2%
    eHp 1.00, SMG dmg 11                150       14      21.7%
    eHp 1.06, SMG dmg 12                159       14      18.3%
    eHp 1.10, SMG dmg 12                165       14      20.3%

The damage-side arm landed with the 14-shot group, not with the health that
produced it. Pooling the three arms each side, grouped by shots to kill: 104 of
360 extract at 13 or fewer, 72 of 360 at 14. That is 28.9 percent against 20.0,
a gap of 8.9 points, standard error 3.2, z 2.8, p about 0.005.

THE OBVIOUS MECHANISM IS NOT THE MECHANISM. The magazine was the first thing I
checked and it is ruled out: the SMG holds 30, and at 11, 12, 13, 14 and 15 shots
to kill you get exactly 2 sentries per magazine every time, so no reload boundary
is crossed anywhere in the tested range. Whatever puts the break at 14
specifically, it is not running dry.

WHAT HE SHOULD ACTUALLY DO WITH THE DIAL. If the game is too hard, eHp needs to
be at or below 1.00, and there is no gain from going further down than that. The
useful setting is 1.00, not 0.94 and not 0.85, and the thing that made tier 1 hurt
was that x1.06 pushed the sentry across a threshold rather than that it added six
percent of anything.

Not verified: why 14. The magazine is excluded and I have not found what replaces
it. The untested hypothesis is time on target, since 14 shots at 88ms is 1.232
seconds of sustained fire against 1.144 at 13, and if a machine's return-fire or
repositioning window sits between those two numbers that would do it; I am
recording that as a guess and not as a finding. Also not verified: this is one
weapon against one enemy type on one map. Sentries are not the only thing shooting
back and the SMG is not the only gun, so "13 shots" is the coordinate of a break in
this configuration rather than a general rule. Also not verified: the single
damage-side arm on its own is 1.34 standard errors from the 13-shot arm, which
does not clear the bar by itself; the 2.8 comes from pooling three arms a side,
and the pooling groups by the very variable being tested.

### v2.40: the threshold is one sentry duel, and it is decided by a single round

No game logic changed. v2.39 found the break between 13 and 14 SMG shots and ended
saying I had excluded the magazine and had not found what replaced it. This finds
it, and the answer needed no new mechanism, only reading the killer column.

Both arms hold sentry health fixed at 150 and change only the SMG, so nothing about
the machines differs between them. 120 seeds, BURIED CITY, everything else pinned:

    arm                        extract   shots   hits   duration
    A  SMG dmg 12, 13 shots     29.2%    155.4   100.3    197s
    B  SMG dmg 11, 14 shots     21.7%    154.6   101.8    201s

    what killed the bot        A     B
    nothing, extracted         35    26
    sentry                     44    58
    crawler                    29    25
    raider                      8     9
    warden                      3     0
    listener                    0     1
    timer                       1     1

THE WHOLE SWING IS SENTRIES. Deaths to sentries go 44 to 58, up fourteen, and the
nine extractions lost are inside that. Nothing else moves further than noise.

IT IS NOT THE AMMO ECONOMY, WHICH WAS MY FIRST GUESS AND IS WRONG. If every kill
cost an extra round the bot should fire more, and it does not: 155.4 shots against
154.6, and 100.3 hits against 101.8. Both arms fire the same raid's worth of
ammunition. The extra round is not being spent, because the bot that needs it is
dead before it gets there.

AND THE ARM CONTAINS ITS OWN CONTROL, WHICH IS THE PART I WOULD DEFEND. Dropping
SMG damage from 12 to 11 does not move every breakpoint. A crawler has 55 health
and takes 5 shots at both values, unchanged. A sentry has 150 and goes from 13 to
14. So inside a single arm, one common enemy's breakpoint moved and one did not,
and the deaths follow the breakpoint exactly: sentries up fourteen, crawlers not up
at all. That is a within-arm comparison rather than a pooled cross-arm one, and it
does not depend on the grouping I flagged as weak in v2.39.

WHY THE SENTRY DUEL IS THIS TIGHT. A sentry has range 340 and the bot only
registers a threat at 300, so the bot walks into forty units of being shot at
before it may shoot back. The sentry hits for 14, and through the light rig the sim
pins, that is 10 hits to put the bot down. The bot needs 13 rounds at 88ms, about
1.14 seconds of held trigger, to put the sentry down first. Those two clocks are
close enough that the fight is roughly even, which is why one more round on the
bot's side of it is worth fourteen raids in a hundred and twenty.

WHAT THIS MEANS FOR THE DIAL, AND IT IS THE SAME ADVICE AS v2.39 WITH A REASON
UNDER IT. eHp x1.06 takes the sentry from 150 to 159 and 159 needs 14 rounds. That
is the entire cost of world tier 1: not six percent of anything, one extra round in
one duel. eHp 1.00 is the setting, and below 1.00 buys nothing because 141 and 128
still lose the same duel the same way.

I AM NOT RETUNING ANYTHING. The obvious move is to widen the gap, by giving the bot
its threat range at 340 to match the sentry, or by moving sentry health off the
breakpoint. Both are difficulty changes and difficulty is his, and the 300 against
340 asymmetry may well be deliberate: a machine that outranges you is a machine you
are supposed to avoid rather than duel. That is a design question and it goes to him
with numbers attached instead of being quietly decided here.

Not verified: whether the bot's 300 unit threat range is intentional. I found it in
updateBot's threat scan and it is a bare literal with no comment, so I cannot tell
from the file whether it was chosen to sit under the sentry's 340 or simply never
compared against it. Also not verified: any of this on the other three maps, or
against any weapon but the Compact SMG. Sentry counts differ per map, so a map with
fewer sentries should show a smaller break, and I have not measured that. Also not
verified: the crawler control is clean but it is one control; I did not construct an
arm where the sentry breakpoint stays put while another enemy's moves, which is the
mirror test and would be stronger than what I ran.

### v2.41: the mirror test says it really is the sentry, and also that I overstated v2.40

No game logic changed. v2.40 ended naming the missing control: I had shown one
enemy's breakpoint moving while another's held, and had not run the mirror, an arm
where the SENTRY holds and something else moves. This is that arm, and it changes
my confidence in both directions.

BUILDING IT NEEDED FRACTIONAL DAMAGE AND A CORRECTION. Enemy health in the sim is
sentry 150, crawler 52, raider 78. v2.40's arithmetic used 55 and 83, which are the
TIER 1 values I read off a live raid by mistake; the sim pins tier 0, so the bases
are 52 and 78. The conclusion is unaffected, since the sentry numbers were right,
but the crawler and raider figures in that entry are one tier high. Verified that
SMG damage takes a fractional value with no rounding anywhere in the path, so the
breakpoints can be steered independently: at 10.2 damage a sentry takes 15 rounds,
a raider 8, a crawler 6; at 10.6 the sentry still takes 15 and the raider still 8,
and only the crawler drops, to 5.

    120 seeds, BURIED CITY, sentry and raider breakpoints HELD, crawler moved

    arm                          extract   shots   hits   duration
    A  dmg 10.2, crawler 6         25.0%   145.7   94.7    195s
    B  dmg 10.6, crawler 5         23.3%   147.2   97.1    188s

    what killed the bot            A     B
    nothing, extracted            30    28
    sentry                        46    54
    crawler                       25    23
    raider                        11    12
    warden                         3     1
    listener                       2     1
    timer                          3     1

THE MIRROR PASSES. Making the crawler a full round cheaper to kill moves the
extract rate by 1.7 points, standard error 5.5, which is a third of one standard
error and is nothing. Crawler deaths move 25 to 23, which is also nothing. Compare
the same manipulation applied to the sentry in v2.40: 7.5 points and fourteen
deaths. Same kind of change, same size of change, different machine, and the effect
disappears. That is the control v2.40 was missing and it points the same way.

AND NOW THE PART THAT WEAKENS MY OWN LAST BUILD. Sentry deaths in this pair went 46
to 54, a swing of eight, in an arm where the sentry breakpoint did not move at all.
So eight deaths of drift is inside the noise of this measure at 120 seeds. v2.40
reported fourteen and treated it as decisive. Fourteen against a noise floor of
eight is about 1.75 times noise, which is suggestive and is not proof, and I
presented it more firmly than that. The extract-rate contrasts are the same story:
v2.40's 7.5 points is 1.34 standard errors and this build's 1.7 is 0.31, so neither
arm clears the bar alone. What carries the claim is the three together, v2.39's
pooled 2.8 standard errors plus a breakpoint that moves the outcome and a breakpoint
that does not, and not any single number I have quoted.

WHAT I NOW BELIEVE, STATED AT THE STRENGTH THE EVIDENCE SUPPORTS. The sentry duel
is very likely the thing that world tier 1 breaks, the mechanism is one extra round
in a fight that is close to even, and eHp 1.00 is still the setting to use. I would
defend that as the best reading of five arms. I would not defend any particular
number of points as the size of it.

Not verified: why sentry deaths carry eight of drift when nothing about the sentry
changed. The two arms differ in continuous time-to-kill even where the integer holds,
10.2 against 10.6 is four percent faster, so some of it is real and some is seed
noise, and I did not separate them. Also not verified, still: the other three maps
and any weapon other than the Compact SMG. Also not verified: whether a same-damage
pair, one arm run twice on the same seeds, would show the same eight-death spread,
which is the measurement that would actually pin the noise floor instead of
inferring it from one pair.

### v2.42: I measured the noise floor and it swallows most of what I reported this session

No game logic changed; the fixture gains a paired-test helper. v2.41 ended saying I
had never measured what a null arm looks like and had twice quoted death-count
swings without one. This measures it, and the answer is worse for my own back
catalogue than I expected.

FOUR BLOCKS OF 120 SEEDS, NOTHING CHANGED BETWEEN THEM. Same shipped defaults, same
map, same greed, same pinned tier. The only difference is which seeds.

    block   extract   sentry deaths   crawler deaths
      1      29.2%         49              26
      2      20.0%         52              35
      3      24.2%         58              27
      4      23.3%         43              28
    range     9.2          15               9
    sd        3.8          6.2             4.1

THE UNCHANGED GAME SPANS 9.2 POINTS OF EXTRACT RATE. And 15 sentry deaths. Set that
against what I reported: v2.40's headline was a 7.5 point extract gap and fourteen
extra sentry deaths. Both are smaller than the spread the game produces when
absolutely nothing is changed.

BUT I HAVE TO BE CAREFUL NOT TO OVERCORRECT, BECAUSE THESE MEASURE DIFFERENT THINGS.
The four blocks use DIFFERENT seed sets. Every arm in v2.39 through v2.41 used the
SAME seed list, so between-seed-set variation is common to both arms and largely
cancels. The 9.2 points is the error bar on an ABSOLUTE rate, not on a paired
difference. What it kills is the decimal: quoting "29.2 percent" as the extract rate
of this game is false precision, and it should have been "about 24, give or take 4".
Everything absolute this session inherits that.

SO I RAN THE TEST I SHOULD HAVE RUN ORIGINALLY. Both arms on each seed before moving
to the next, which makes the pairing exact, then McNemar on the discordant pairs.
119 pairs, sentry at 13 rounds against 14, health identical:

                        dmg 11 extract   dmg 11 dead
    dmg 12 extract            17              18
    dmg 12 dead                9              75

    rate 29.4% against 21.8%, discordant 27, chi 2.37, z 1.54, exact p = 0.122

IT DOES NOT CLEAR THE BAR. Eighteen seeds flip toward the 13-round arm and nine flip
the other way. The direction is the one I predicted and the p is 0.12. That is
suggestive and it is not a finding, and v2.40 reported it as though it were.

WHY THE WHOLE SESSION KEPT LANDING "INSIDE ONE STANDARD ERROR". The convention of
120 seeds an arm is simply too small for the effects being chased. At this
discordance rate, 0.227, and this split, detecting it at the five percent level with
eighty percent power needs about 71 discordant pairs, which is about 313 seeds an
arm. My standing convention is roughly 2.6 times too small. That is not a fact about
this build, it is a fact about every A and B in this file, and it explains a long run
of results that came out directionally right and statistically mute.

THE TOOLING NOW MAKES THE RIGHT TEST THE EASY ONE. __simPaired(seeds,dialsA,dialsB)
runs both arms on each seed in turn, returns McNemar's table with an exact two-sided
p, and puts every dial it touched back. Verified two ways: a null pair with identical
dials returns zero discordant pairs and identical rates, which it must since the sim
is deterministic, and an extreme pair returns five of six discordant all in one
direction. Both left CFG.eHp back at 1.

WHERE THE SENTRY THREAD ACTUALLY STANDS. Six arms, and every arm needing 14 or more
rounds has a lower extract rate than every arm needing 13 or fewer. The direction has
never once come out backwards, the crawler mirror at v2.41 correctly showed nothing,
and the pooled contrast at v2.39 was 2.8 standard errors. That is a good working
hypothesis. It is not established, no single paired test reaches significance, and I
should have said so three builds ago instead of at the end.

MY ADVICE ABOUT THE DIAL SURVIVES ANYWAY, FOR A REASON THAT IS NOT STATISTICAL. eHp
1.00 was already the neutral setting and going below it has never measured better
than leaving it. So "leave it at 1.00" costs him nothing whether or not the sentry
mechanism is real, which is the only reason I am not withdrawing that too.

Not verified: the noise floor for a PAIRED difference, which is the number I actually
need and still do not have. Four null blocks give the spread across seed sets; the
equivalent for paired arms would need repeated pairs under a dial that genuinely does
nothing, and there is no such dial to hand. Also not verified: whether 313 seeds is
achievable in a session, since 120 seeds takes about two minutes of wall clock in the
fixture and 313 an arm is roughly ten minutes for one comparison. Also not verified:
any of the four blocks on a map other than BURIED CITY, so the 9.2 point spread is one
map's noise floor and the quieter maps may well be tighter or worse.

### v2.43: the sentry threshold is real at n=320, and the bot was shooting past its own barrel

Two things, one measured and one fixed.

THE MEASUREMENT FIRST, BECAUSE IT SETTLES FOUR BUILDS. v2.42 worked out that 120
seeds an arm is about 2.6 times too small for these effects and put the required
number at roughly 313. So this ran 320, set in advance, and ran to 320 rather than
stopping when it crossed. Both arms on each seed in turn, sentry health identical
in both, only the SMG changed so shots to kill a sentry moves 13 to 14:

                          14 shots extract   14 shots dead
    13 shots extract            41                51
    13 shots dead               28               200

    28.8% against 21.6%, discordant 79, z 2.48, exact two-sided p = 0.0128

IT CLEARS THE BAR. The sentry threshold is real. That is the result v2.40 claimed
on 1.34 standard errors, v2.41 walked back, and v2.42 said needed 313 seeds before
anybody should believe it. It needed 320 and it survived them. The direction never
changed across six arms; only the evidence for it did.

Worth being exact about what is established: one extra round to kill a sentry costs
about 7 points of extract rate on BURIED CITY with the Compact SMG. eHp x1.06 is
what pushes 150 health to 159 and 159 needs the fourteenth round, so that remains
the whole cost of world tier 1, and eHp 1.00 remains the setting.

THE FIX, WHICH IS UNRELATED AND WAS FOUND WHILE READING THAT CODE. The bot's threat
scan used a bare literal 300 with no relation to the gun in its hands, and that one
number was answering two different questions: what may I shoot at, and how close
does something have to be before I stop looting and deal with it. Splitting them is
the whole change.

    simReach, DEFAULT ON, the correctness half. fireWeapon sets a bullet's life to
    rng/1180, so a round fired beyond the weapon's range cannot arrive. The Riot
    Scattergun dies at 260 and the Hullcracker at 210, so a bot holding either was
    firing at threats out to 300 and throwing those rounds away. Running dry is one
    of the four conditions that end the looting phase, so wasted rounds are not
    cosmetic. The bot now holds fire outside its own range.

    simEngage, DEFAULT OFF, the behaviour half. Nine of the twelve weapons out-range
    300, the Marksman Rifle by 460, so a bot with a long gun refuses fights it would
    win. That is tempting and it is NOT a correctness fix, because of the branch
    order: any threat inside the radius stops the bot looting entirely, so raising
    the radius to 760 gives you a bot that stands and trades all raid instead of
    filling its bag. It changes what the bot IS, so it follows simSell, simPed,
    simCrouch and simPip and stays off.

THE MACHINES ALREADY DID THIS RIGHT, which is what made it a defect rather than a
convention. Every machine fire path checks its own range before pulling: dw<e.rng*1.2
on the sentry's windup, d<e.rng*1.15 on the raider's, d<e.rng on the pinning branch.
The bot's was the only one that did not.

Verified: parsecheck PASS, all four maps and the hub draw clean with 10 of 10 entities
moving on every map, and the shipped defaults read simReach 1, simEngage 0.

Not verified: what simReach is worth in extract rate, and I want that stated plainly
rather than buried. It is a correctness fix with an argument behind it, not a measured
one, and the A/B has not been run. It should be, at 320 seeds, and the honest guess is
that it is small, because the guns that waste rounds are the two shortest and the sim
deploys an SMG. Also not verified: with simReach on and simEngage off there is a band
between the weapon's range and 300 where a shotgun bot stops looting and cannot shoot,
so it idles. It idled before too, just noisily, and I have not measured whether that
band costs anything. Also not verified: the p=0.0128 result is BURIED CITY and the
Compact SMG only, as every arm in this thread has been.

### v2.44: the health bar is twice the bar it was, and a hit now leaves a mark you can read

His three notes, 2026-08-25, all about the same thirty pixels: "health bar needs to
be bigger/more prominent", "taking damage needs better/clearer indicators", "show
damage as red on the health bar momentarily so player can see what damage they just
took".

WHY THE OLD BAR TOLD HIM NOTHING. It was 280 by 18, drawn in the bottom left in the
same column and at the same width as armour and stamina. Three bars, one size, so
the one that kills you looked like the one that makes you jog. And it snapped
straight to the new value on a hit, which means a graze that took 8 and a sentry
burst that took 34 produced the identical event: the bar is shorter now, work out
the rest yourself.

WHAT IT IS NOW. 360 by 26 with the number set in the title face, and armour and
stamina left narrow underneath so the hierarchy reads without being read.

THE RED BLOCK IS THE HIT, AT ITS ACTUAL SIZE. hpGhost holds the health you had
before the round landed. It sits still for 0.55 seconds, so the block is legible
rather than a flicker, then drains toward the true value at a rate proportional to
its own size, so a big hit visibly takes longer to bleed off than a small one. The
width of the red IS the damage. A second hit while the red is still up EXTENDS the
same block rather than restarting from the lower value, or a burst of three would
read as one small hit, which is exactly backwards from what he asked for.

The number comes with it: the amount taken floats to the right of the bar and fades
over about a second, so there is a figure as well as a shape.

AND THE FLASH AND THE SHAKE NOW SCALE WITH THE HIT. Both were constants, .28 flash
and 5 shake, whatever hit you. They now ride a severity term clamped to 0.35 to 1.9,
so a graze and a burst stop feeling the same. That is the "clearer indicators" half
and it costs nothing: no new state, no PRNG draw.

NOTHING HERE REACHES THE SIM. hpGhost, dmgHold, lastDmg and dmgPopT are read only
by drawHUD. No decision consults them, no random number is drawn, so every arm in
this file remains comparable across this build. Worth stating because presentation
changes have leaked into measurement here before.

Verified by driving it rather than by reading it: a 24 point hit through eDmg 1.2
lands as 29, health goes 100 to 71 with the ghost held at 100 and lastDmg 29; after
40 frames the hold has expired and the ghost has drained to 90.8; after 240 it has
reconciled at the true value. Parsecheck PASS, all four maps and the hub draw clean
with the block on screen.

Not verified: how it actually looks. The fixture proves the numbers move correctly
and that drawing them throws nothing; it cannot tell me whether 360 by 26 is the
right size on his monitor or whether 0.55 seconds is the right hold. Those are
judgements he makes by playing it, and the two constants are one line each if he
wants them different. Also not verified: the damage number is drawn to the RIGHT of
the bar, at x 390, and I have not checked that against every HUD element that lives
along that edge at small window widths, so it may collide with something on a narrow
window.

### v2.45: the trigger uses what you are holding, which is what a quickbar is for

His note, 2026-08-25: "when i switch to nades or bandaids or whatever, i should just
pull the shoot button to use it, not hit g -- makes no sense. Needs to be more like
minecraft in this regard -- loaded quickbar item always activates with shoot button".

HE IS RIGHT AND THE OLD SPLIT WAS INDEFENSIBLE. The number keys picked a slot, the
slot was drawn highlighted along the bottom of the screen, and then the selection
did nothing at all until you found a SECOND key. The hotbar showed you what was in
your hand and the trigger ignored it. G was the only way to act, and G is not where
anybody's hand is during a fight.

The selected slot now drives the trigger. Guns shoot, throwables throw, medical
heals, a plate goes on. G still works, because there was no reason to take it away,
but the legend now reads FIRE rather than G.

ONE ACTION PER CLICK for anything that is not an automatic weapon. p.fired already
tracked exactly that for semi-automatics, so the throwable and medical paths reuse
it; without that a grenade slot would throw the entire pouch in a fifth of a second.

AN EMPTY SLOT FALLS THROUGH TO THE GUN, AND THAT IS A SAFETY RULE. Throw your last
grenade and the slot stays selected. If an empty slot swallowed the trigger you would
be standing in a firefight clicking at nothing, wondering why your gun had stopped,
until you remembered to press 1. An empty slot is not a held item, so the trigger
goes back to the gun.

AND THE CROWBAR NEARLY SHIPPED AS A DEAD TRIGGER, which is mine to own. The hotbar
has a seventh slot, kind 'tool', count null, and useHot has no branch for it: the
crowbar is contextual, it comes up by itself while you work a container or cut a
seal, and there is no standalone crowbar action anywhere in the file. My first
version tested for an empty slot with count === 0, which null is not, so selecting
the Crowbar routed the trigger into a function that did nothing and the fire button
died until you pressed another number. Caught by enumerating the slots in the fixture
rather than by reading. Tools now fall through with the empties, and the count test
is "not greater than zero" so null, undefined and 0 are all handled the same way.

Verified by driving the real mouse through every slot the hotbar produces rather than
by inspection. Compact SMG: ammo down one. Smoke Canister with three in the pouch:
pouch down one, one throwable in flight. Bandage at 60 health: one heal consumed, 28
health back. Empty Smoke and the Crowbar with the cooldown cleared: ammo down one and
nothing thrown, so the fall-through fires the gun. Parsecheck PASS, four maps and the
hub draw clean.

Not verified: nothing here changes the bot, which never reads mouse state, so the sim
is untouched by construction rather than by measurement. Also not verified: whether
falling through to the gun is what he wants when a slot empties, as against the slot
auto-advancing back to slot 1. Falling through is the smaller change and keeps the
selection where he put it, but it does mean the highlighted slot and the thing that
fires can disagree while a slot sits empty. Also not verified: the armour plate path,
because the fixture profile carries no plate, so that branch of useHot was exercised
by neither of these tests.

### v2.46: healing takes time now, and the bot does it the same way

His note, 2026-08-25: "medkit shouldn't be instant, it should heal you up slowly".

WHY THE OLD ONE WAS A NON-DECISION. A Medkit returned 65 health in the frame the key
went down. There was never a moment where you had committed to healing and were still
hurt, so pressing F cost you nothing but the item: no window, no risk, nothing to
interrupt. Healing was a transaction rather than an action.

The item is now spent immediately and the health arrives over ITEMS[k].hot seconds.
Bandage 28 over 2.6s, Medkit 65 over 6.0s. That is 10.8 a second for both on purpose,
so the bigger item is not FASTER, it is LONGER, and choosing the Medkit means
choosing to be busy for six seconds. He named the Medkit; the Bandage moves with it,
because one instant heal and one gradual heal sitting in the same slot is the
confusing version of this change.

Stacking is never a downgrade: a second item while one is running adds its health to
the queue and takes the faster of the two rates.

ONE HEAL PATH FOR THE PLAYER AND THE BOT, WHICH IS THE PART THAT MATTERS BEYOND THIS
BUILD. The bot healed on its own line inside updateBot and the player healed on
another inside updatePlayer, both spelled out longhand. That is the exact shape of
every fidelity hole this file has had to find the hard way: wading at v2.00, the
sidearm at v2.03, the jam at v2.09, the pip at v2.34. Each was a rule the player
lived under and the bot did not, and each was found builds or months later. Leaving
two heal lines in place would have queued up the next one. Both now call applyHeal
and both tick tickHeal, so they cannot drift apart again.

Verified by driving both sides rather than by reading. PLAYER: health 30, one Medkit,
F pressed. The item leaves the bag on the first frame and the health does not: 30.0 at
0.0s with 65 queued, 40.8 at 1.0s, 62.5 at 3.0s, 95.0 at 6.0s with the queue empty.
That is 10.8 a second, arriving on schedule, and 30 plus 65 is 95. BOT: same setup,
stepped through updateBot rather than updatePlayer, 30.0 to 30.2 on the first step
with 64.8 queued and 40.8 after a second, which is the player's curve. healOverTime 0
returns both to instant, verified at 95 health in one step, and the dial is back at 1.

THE BAR SHOWS IT, because it had to. v2.44 put a red block on the health bar for
damage taken; an incoming heal is the same problem mirrored, and without it using a
Medkit looks like nothing happened for six seconds. Pending health draws as a pulsing
green segment from where you are to where you are going.

Not verified: what this does to survival, and it is the first change in a while that
should genuinely move it. The bot now spends six seconds at low health where it used
to spend none, and it heals at hp below 45, which is exactly when something is usually
shooting at it. I have not run the A and B. healOverTime is a dial precisely so that
can be measured properly at 320 seeds, and on v2.42's arithmetic anything smaller than
that will not answer it. Also not verified: whether taking damage should interrupt a
heal in progress. It does not today, which is the generous reading; the harsh reading
is that a heal interrupted by a hit is wasted, and that is a design call rather than
a bug, so it goes to him. Also not verified: selfRevive is untouched and still sets
health to 40 instantly, on the reasoning that getting off the floor is a different
act from patching a wound.

### v2.47: the cursor was being left outside the canvas, and BACKSPACE brings it back

His note, 2026-08-25: "mouse graphic is still disappearing, can we maybe add a key
command to refresh it". Still is the important word, because v0.98 already fixed a
version of this and shipped a comment saying so.

WHAT v0.98 FIXED WAS A DIFFERENT FAULT. It blamed a latched M: the reticle is drawn
only when M is not held, and keyup fires at the window, so alt-tabbing with M down
latched it forever. That was real and the blur handler that came out of it is
correct. It is not what is biting him now, and the file could have told me so: a
latched M also draws the entire map overlay. He would have seen a map, not a missing
cursor.

THE ONE THAT HIDES SILENTLY IS THE RESIZE. The canvas sets cursor:none, so the
reticle IS the cursor, and it is drawn at mouse.x, mouse.y. Those are only written by
a mousemove OVER the canvas. resize() centres them exactly once, guarded by
mouse.init, which is already true after the first resize. So shrink the window, drag
it to a smaller monitor, or open a dock that reflows the page, and the last known
position is now outside the canvas: the reticle draws off-screen, there is no OS
cursor because cursor:none is still in force, and the game otherwise looks perfectly
normal. Nothing recovers it but moving the mouse back over the canvas, and if the
pointer is already parked somewhere else that is not obvious either. mouse.x and
mouse.y are now clamped into the canvas on every resize.

AND THE BLUR PATH HAD THE SAME GAP ONE LEVEL UP. releaseAllKeys cleared held keys and
the mouse button, but the reticle also hides for an open bag, and G.bagOpen is not a
key. Alt-tab with the inventory open and it stayed latched. Cleared now, along with a
clamp on the way back in, since returning from another monitor is exactly when the
cursor can be out of bounds.

BACKSPACE IS THE KEY HE ASKED FOR. One press releases every held key, closes the bag,
and puts the reticle in the middle of the screen. It deliberately does not require a
live raid, so it rescues the hub screen too, and it is in the legend as BKSP.

Verified by driving it. The reticle parked at 99999,99999 comes back to 486,274 on
BACKSPACE. With bagOpen true, KeyM held, Shift held and the mouse button latched
down, one press clears all four and the HUD draws clean afterwards. The resize clamp
was verified by parking the reticle at 100000,100000 and firing a resize: it is
pulled back to the canvas bounds.

A NOTE ON MY OWN TEST, because it briefly reported a failure that was not one.
releaseAllKeys does keys={}, which REBINDS the variable rather than emptying the
object, so the handle my first probe was holding went stale and still showed KeyM
true. The game is fine, because every reader inside the file references the variable
and not a captured object. The probe was wrong, not the code, and I only found that
by re-fetching the reference.

Not verified: an actual window shrink in his browser. The fixture pane does not
shrink its canvas with the viewport, it reported 978 wide at a 400 wide viewport, so
I drove the resize handler directly instead. That proves the clamp fires and does the
right thing; it does not prove his particular way of resizing reaches that handler.
If the cursor still goes missing after this, the next thing to suspect is a path that
changes the canvas size without firing a resize event. Also not verified: whether
BACKSPACE is a key he likes. It was free, nothing else is bound to it, and it reads
as "undo", but it is one line to move.

### v2.48: the best moment in the loop was the quietest one

His note, 2026-08-25: "there should be a better loot noise for finding rare items or
guns".

EVERY CONTAINER IN THE GAME PLAYED THE SAME SOUND. One 'pick' blip, a single sine
sweeping 660 to 1180 in 120 milliseconds, whether the box held four pieces of scrap
or a Black Box. That is worse than it sounds, because the pip on the lid already
tells you what a container is WORTH before you open it: the game builds anticipation
correctly and then pays it off with nothing. His run #1 note was "looting feels so
uninspired, how can we make it more interesting???" and this is one of the reasons
why. The reward for the best find in a raid was identical to the reward for junk.

FOUR VOICES NOW, PITCHED AS A LADDER.
  pick        unchanged, common and uncommon
  pickRare    two notes, a rising fifth at 784 and 1175, soft tail. Above 'pick'
              without being a fanfare, because rare is common enough to hear often.
  pickElite   three ascending notes at 784, 1046 and 1568 with a high shimmer over
              the top. Allowed to be a fanfare: six items in the entire table are
              elite.
  pickGun     metal rather than music. A bandpassed noise scrape sweeping 1500 down
              to 760 over a low sine thunk, so it reads as a weapon being lifted.

A GUN OUTRANKS THE RARITY LADDER, which is a judgement rather than a rule. An Auto
Rifle and a Cell Bank are both tagged 'rare' and only one of them changes how the
rest of the raid goes. A gun is a different KIND of find, not a more valuable one, so
it gets its own voice rather than a place in the queue.

The chooser takes the BEST thing in the container, because that is the thing you will
remember finding, and it uses an explicit numeric test rather than a falsy fallback:
common is rank 0 and 0 is falsy, which is the same trap that handed a player wearing
no rig 0.55 absorption at v2.16.

Verified against the real item table rather than against my assumptions. Nine cases,
all correct: an empty container, a null argument and an unknown item key all fall back
to 'pick'; common alone and uncommon alone stay 'pick'; rare gives pickRare; elite
gives pickElite; and a gun returns pickGun whether it is sitting next to an elite or
next to scrap. Then twenty five real containers opened on a LIVE raid, which is the
only way the new path actually runs, with no errors: 18 plain, 4 rare, 2 elite, 1 gun.
So a bit over a quarter of containers now sound like something, which is about the
right frequency for it to stay meaningful.

AND THE FIXTURE STAYED SILENT, which I checked rather than assumed, because driving
frames once played gunfire aloud on his machine while he was working. AudioContext is
blocked in the fixture and reports "fixture is silent"; all four voices were called
directly and none threw.

Not verified: how any of it actually SOUNDS. I can prove the right voice is chosen for
the right contents and that nothing throws; I cannot hear the fixture, and the
frequencies, gains and note spacings are chosen on reasoning rather than by ear. If
the elite fanfare is annoying on the twentieth hearing, or the gun scrape reads as a
bug rather than as metal, those are numbers in one block and they need his ears. Also
not verified: these fire on opening a CONTAINER. Picking an item up off the ground,
looting a body and buying from the peddler all still use the old single blip, and I
have not touched them.

### v2.49: raiders belong to crews now, and rival crews shoot each other

His request, 2026-08-25: "other raiders should fight each other sometimes, they
should all have friendly/unfriendly status mechanism that we already made, but
towards one another".

THE MECHANISM HE MEANT WAS ALREADY THERE, POINTED AT HIM. mkRaider decides how each
raider feels about the PLAYER: a grudge if you have killed him before, passive if
your standing is good, otherwise a coin weighted to 0.55. This is the same idea
turned sideways. Every raider now carries a CREW, and two raiders from different
crews are enemies the same way a hostile raider is your enemy.

CREWS RATHER THAN A PER-PAIR ROLL, because hostility between people has to be
transitive to be readable. A man who shoots the raider beside him and ignores an
identical one ten metres away looks broken; a man who shoots everyone not wearing
his colours does not. Two crews by default, so about half of all pairs are hostile.

THREE THINGS HAD TO CHANGE, AND THE SECOND ONE WOULD HAVE MADE IT SILENTLY DO
NOTHING.
  1. The target scan skipped raiders outright, which is what kept them from ever
     picking each other. A rival crew is a valid target now; your own crew is not.
  2. Bullets were immune between entities of the same KIND. A raider's round passed
     straight through another raider even with the gun pointed at him. The exception
     is deliberately narrow, feuding raiders only, so machines still never shoot
     each other.
  3. Being hit set state to 'chase', and for a raider 'chase' means chase THE
     PLAYER. Shot by a rival, half the map would have turned on the one person who
     did not fire. A feud hit now leaves him in his own state, where the scan
     retaliates against whoever is nearest, which is the man who just shot him.

AND THEN THE MEASUREMENT SAID I HAD BUILT SOMETHING THAT NEVER HAPPENS. The rival
check went into the looting branch, which was the obvious place and was wrong:
raiders are in 'loot' for 18 percent of their time and in 'extract' for 82. Four
driven raids produced exactly ZERO engagements while rival pairs came within 280
units of each other between 85 and 122 times. It worked when I forced two raiders
together by hand and never once on its own. Extracting raiders fight now too, which
is also the better version thematically: a man running for the ring with a full bag
is exactly who has something worth taking, and the ring is where the player is
heading anyway, so it is the most likely place he will ever watch one.

THE 600 UNIT WINDOW AROUND THE PLAYER STAYS AND IS NOT NEGOTIABLE. G.vseg only
caches walls near the player, so losClear is only ANSWERABLE there; beyond it
raiders would trade shots through buildings. The existing raiders-fight-machines
feature has lived under the same limit since his note #39. It also means feuds
happen where they can be seen.

MEASURED BY ATTRIBUTION RATHER THAN BY EYE. Eight seeds, each run twice with the
same player path, once with raiderFeud 0 and once with 1. With the dial off, raiders
lost ZERO health in all eight. With it on, 188 points across three of the eight, 74
and 57 and 57. So the feud is the sole cause, and it fires in about 38 percent of
raids: "sometimes", which is the word he used.

Verified: parsecheck PASS, four maps and the hub draw clean with 10 of 10 entities
moving, and two crews present on every map. The guards all hold: a raider is not his
own enemy, two sentries are not enemies, a raider and a sentry do not count as a
feud, a null argument is safe, and a hired mercenary is exempt so a man you paid for
never wanders off to settle something of his own. raiderFeud 0 restores the old
behaviour exactly.
THE CREW ROLL IS DRAWN UNCONDITIONALLY, the same discipline as the jam roll at v2.09.
Putting rr() inside the dial test would make raiderFeud 0 skip a draw that raiderFeud
1 takes, shifting the PRNG stream from the first raider onward and turning the two
arms into different raids. Verified: with the dial off the same seed produces the
same raider count, the same first raider position and the same crew assignments.

Not verified: what this does to the player's extract rate. Raiders killing each other
means fewer raiders alive to kill him, and it also means a fight he can walk into or
around, so it could move survival in either direction. I have not run it at 320 seeds
and on v2.42's arithmetic nothing smaller will answer it. Also not verified: two
crews is a guess. raiderCrews is a dial and 3 would make roughly two thirds of pairs
hostile, which may be too much; I have measured 2 and nothing else. Also not verified:
whether a crew should be VISIBLE. Coats already vary per identity but they vary by
identity, not by crew, so right now there is no way to look at two raiders and know
whether they are about to fight. That is a real gap for a feature whose whole value is
being watched, and it is a design call rather than a bug.

### v2.50: you can pick things up out of the bag and put them on the bar

His request, 2026-08-25: "I want the inventory to be physical like minecraft so you
can drag icons down to the quick bars".

TWO THINGS WERE IN THE WAY AND ONLY ONE OF THEM WAS THE INVENTORY. The bag was a text
list, which is the obvious half. The other half is that the quickbar was DERIVED: it
is rebuilt from scratch every frame out of whatever you happen to be carrying, so
there was no such thing as a slot you had put something in. Dragging needs a slot to
be a place, not a readout.

WHAT IT DOES NOW. Rows in the bag carry a colour swatch and light up under the
cursor. Press on one and you are carrying it: the item follows the cursor with its
name under it, and any quickbar cell you pass over outlines in green. Let go on a
cell and that slot is yours. Let go anywhere else and the drag is abandoned, which is
what every inventory that works does.

ASSIGNMENTS ARE AN OVERRIDE, NOT A REPLACEMENT, and that was the design decision that
kept this build small. The derived bar is untouched and still produced exactly as
before; a map of slot index to item key is applied on top of it. So nothing that
already worked can regress, and an assignment that stops making sense simply falls
away rather than having to be cleaned up.

FOUR RULES, ALL OF THEM MEASURED RATHER THAN ASSUMED.
  An assignment is live only while you still carry the thing. Spend your last Medkit
  and the slot goes back to whatever it was instead of sitting there as a lie.
  Verified: slot 3 reads Medkit, is used, and reverts to Decoy Beacon.
  One item, one slot. Dropping something that already lives elsewhere on the bar
  MOVES it. Verified: dropped on slot 2 then slot 4, the map ends as {4: medkit}.
  An assigned slot uses THAT item. The generic heal path calls findHeal, which
  deliberately reaches for the SMALLEST heal you carry; if he has dragged a Medkit
  onto a slot he means the Medkit. Verified: with a Medkit and a Bandage in the bag,
  using the assigned slot consumed the Medkit and queued 65 health.
  A valuable on a slot must not swallow the trigger. Scrap Metal is not usable, so
  the slot falls through to the gun exactly as an empty slot does since v2.45.
  Verified: with Scrap on the selected slot, firing still cost a round. This is the
  same trap the Crowbar sprang in v2.45 and it would have been the same bug again.

THE RECTANGLES ARE RECORDED AS THEY ARE DRAWN, for both the bag rows and the bar
cells, rather than recomputed by the mouse code. Two copies of that arithmetic would
drift apart the first time the slot count or the UI scale changed and the drop target
would stop matching the thing on the screen.

A drag does not survive losing focus, for the same reason the keys do not.

Verified: parsecheck PASS, four maps and the hub draw clean, and the whole gesture
driven with real MouseEvents from a bag row to a bar cell and back out again.

MY TEST WAS WRONG BEFORE THE CODE WAS. The first drag probe reported no grab at all.
The listener is on cv, the world canvas, while __ctxCanvas() returns hcv, the HUD
canvas, so I had been dispatching every event at the wrong element. The game was
fine.

Not verified: how it FEELS, which for a drag is most of it. I can prove the item is
picked up, follows the cursor, highlights the right cell and lands where it was
dropped; I cannot tell whether the grab threshold, the ghost size or the drop
tolerance are comfortable, and those are judgements from using it. Also not verified:
assignments live on G and therefore last one raid. Whether a bar he arranged should
persist across deploys is a real question and it touches the profile, so it is his
call rather than mine. Also not verified: this is mouse only. The gamepad path has a
virtual cursor and could in principle drive the same gesture, and I have not wired or
tested it, so on a controller the bar is still the derived one.

### v2.51: buildings have windows, and the whole feature is one omission in the segment builder

His note, 2026-08-25: "buildings need windows that you can see and shoot out of but
not walk through".

THE ARCHITECTURE MADE THIS ALMOST FREE, WHICH IS WORTH RECORDING. A wall blocks
three different things through two different systems: movement reads map.walls, and
sight and bullets BOTH read map.segs, the segment list built from those walls. So a
window is a wall that is simply never told to the ray caster: skip it in the segment
builder and it stops blocking sight and stops stopping rounds, while collide still
refuses to let a body through. No new subsystem, no special case in the shooting
code, no per-frame cost. The bullet spawn check gets one line, so a round fired from
inside a window strip does not die there, and the nav grid is untouched because a
window cell is correctly not walkable.

CARVING. Building walls get a strip of 52 to 84 units cut out, roughly 45 percent of
eligible walls, at least 48 units clear of each end. Terrain, trees, ledges, the
locked-room shells and the world border are never candidates. All three rolls are
drawn for every candidate whether or not CFG.windows is on, the same discipline as
the jam roll at v2.09 and the crew roll at v2.49, so windows 0 and 1 run the same
PRNG stream and every seeded comparison in this file survives the feature.

DRAWN AS A WINDOW, because a hole that looks like a doorway gets walked into. Low
sill in the wall's own colours, pale glass band above it, a mullion on wide panes so
they do not read as a serving hatch.

THREE ROUNDS OF MY OWN VALIDATION FAILING, EACH ONE REAL AND EACH ONE MEASURED,
because carving a hole is easy and proving the hole is open is the actual work.
  ROUND ONE: 5 of 30 sampled windows on BURIED CITY were solid to sight. Not
  geometry behind them: a COINCIDENT wall, because makeBuilding lays overlapping
  runs, so carving one left its twin standing in the hole. A reconcile pass cuts the
  same span out of any wall crossing a window.
  ROUND TWO: the reconcile used rectangle overlap, and a wall that merely TOUCHES
  the sight line occludes without overlapping. 60 of 76 open on DAM. Replaced the
  guess with the game's own rayHit fired through every window at map build, demoting
  any window that is not genuinely open; demotion adds an occluder and can close a
  neighbour, so it iterates to a fixed point.
  ROUND THREE: one window in 214 still failed, and the cause was ORDER. Locked-room
  shells and other walls are pushed after the buildings, and a window carved before
  they exist can be sealed by one. The carve now runs once every wall on the map is
  present, immediately before the segments are built, and the validation probe is
  deliberately longer than anything the game later checks.

FINAL STATE, MEASURED TWICE ON DIFFERENT SEED SETS: 205 to 212 windows across the
four maps, every single one see-through at 26 units and every single one ejecting a
body stood in it, a real bullet flown through a window and surviving on all four
maps, the window draw branch exercised with the player stood at a window, and the
hub clean. Solid walls of window-like shape still block sight, 30 of 30.

Not verified: what windows do to BALANCE, and this one is not small. Every machine
and raider LOS check reads the same segments, so a window is a firing line in both
directions: sentries can now see and shoot the player through walls that used to be
cover, the Listener's hearing is unaffected but its sight is not, and the visibility
fan the player sees pours through window gaps. Extract rate, first-contact time and
camp behaviour could all move, the dial to measure it is CFG.windows, and at v2.42's
arithmetic the A/B needs 320 seeds which I have not run. Also not verified: the LOOK,
same as v2.48's sounds. The sill and glass colours are reasoned, not seen; if a
window reads as a doorway on his monitor the mullion and sill constants are the place
to push. Also not verified: crouching below a sill. A window blocks nothing at any
height, so there is no hiding under it, and whether there SHOULD be is a design
question that belongs to him.

### v2.52: going down interrupts the heal, and windows are balance-neutral at n=320

TWO SMALL FIXES AND ONE MEASUREMENT.

THE FIRST FIX. v2.46 made healing take time and left one seam open: nothing cleared
the queue when the player went down. The queued remainder of a Medkit kept trickling
into a body on the floor, so health crept up from zero while downed, which nothing
else in the game expects, and part of a heal survived a catastrophe it should not
have. Going down now zeroes the queue and the rate, verified by queuing 65 points
and taking a 500 damage hit: downed true, queue 0. v2.46's open question, whether
ORDINARY damage should interrupt a heal, stays open and stays his; being shot to the
floor is not ordinary damage.

THE SECOND FIX IS ONE STRING. The caption under the hotbar still read "[G] use"
after v2.45 moved the action onto the trigger; it reads "[FIRE] use" now, matching
the legend.

THE MEASUREMENT, WHICH IS THE REAL CONTENT OF THIS BUILD. v2.51 cut roughly two
hundred windows into the four maps and changed every line-of-sight answer in the
game in both directions, and shipped honestly labelled as unmeasured. Measured now
at the size v2.42 says these arms need: 320 seeds, BURIED CITY, both arms of every
seed run back to back, windows 0 against windows 1, everything else pinned.

                        windows on extract   windows on dead
    windows off extract        21                  39
    windows off dead           40                 220

    18.8% without windows against 19.1% with, discordant 79, exact p = 1.0

WINDOWS ARE BALANCE-NEUTRAL AND RAID-SCRAMBLING AT THE SAME TIME, and both halves
matter. The rate does not move: 0.3 points, z of zero, as null as a null gets. But
79 of 320 raids CHANGED OUTCOME, 39 flipping one way and 40 the other, which is a
quarter of all raids. For comparison, the sentry-round change at v2.43 flipped the
same count, 79, but 51 against 28. So windows redraw individual fights about as
strongly as the strongest balance lever measured this cycle, and do it symmetrically:
every firing line a window opens INTO the bot's cover it also opens OUT of it. That
is the best outcome the feature could have had. It changes raids without changing
the game's difficulty, which is what a texture feature should do and almost never
does.

Worth a note for the record: the base rate in this batch reads 18.8 to 19.1 against
the 24 give or take 4 the null blocks measured at v2.42. This batch runs with
raiderFeud, healOverTime and simReach all on, which v2.42's blocks did not have, and
each is plausibly worth a point or two of extract rate in the harsh direction. Their
individual costs are unmeasured, and I am flagging that rather than pretending the
gap is noise.

Verified: parsecheck PASS at v2.52, all four maps and the hub drive and draw clean
with 10 of 10 entities moving, and the down-interrupt exercised directly.

Not verified: the windows null is BURIED CITY only, and window density differs per
map, so a map with more exterior wall could still tilt. Also not verified: the
combined cost of the three new-default dials named above; if his next runs feel
harder than the file's back catalogue promised, that stack of defaults is the first
suspect, and each has a dial to switch off.

### v2.53: the medkit change costs 7.5 points of extract rate, and it is the whole of the drop

No game logic changed; this is the measurement build that turns v2.52's suspicion
into numbers. That build flagged the three new default-on dials, raiderFeud,
healOverTime and simReach, as the suspects for the base rate sitting near 19 against
the historical 24 give or take 4. Two batches of 320 seeds each, BURIED CITY, both
arms of every seed back to back, windows on throughout.

BATCH ONE, THE WHOLE STACK. Old defaults (feud off, instant heals, flat 300 reach)
against today's:

    25.9% against 19.1%, discordant 32 to 10, z 3.24, exact p = 0.0009

The stack costs 6.8 points and it is not noise. It also reconciles the ledger:
25.9 minus 6.8 is 19.1, which is exactly where the windows null read.

BATCH TWO, THE ISOLATION, AND IT IS TOTAL. Same 320 seeds, feud and reach held OLD
in both arms, only the heal changing:

    instant heals 25.9% against heal-over-time 18.4%
    discordant 31 to 7, z 3.73, exact p = 0.00012

HEAL-OVER-TIME IS THE ENTIRE EFFECT. Its lone cost, 7.5 points, matches the whole
stack's 6.8 within noise, which means feud and simReach are jointly about neutral,
mildly helpful if anything, and every point of the drop walks through the medkit.
That also confirms the v2.53 mechanism guess: the bot heals when health falls under
45, which is precisely when something is shooting at it, and it now spends six
seconds at low health in the open where it used to spend none. A bot that dies
during its own heal.

TWO READINGS, BOTH TRUE, AND THE DIFFERENCE MATTERS TO WHAT HE DOES NEXT.
  First reading: the game genuinely got about seven points harder, because he asked
  for a real change, medkits that cost time, and time in a firefight is life. That
  is the feature WORKING. If the new difficulty is unwelcome the price tag now has
  one name on it, and healOverTime 0 is one dial.
  Second reading: the seven points may OVERSTATE what he will feel, because the bot
  heals like a machine and he does not. The bot pops its medkit at 45 health
  wherever it happens to be standing, mid-fight included. A person retreats first.
  Teaching the bot to break contact before healing is a behaviour-capability
  change, exactly the family of simCrouch and simPip, and by this file's own
  convention it would default OFF, which would leave the measured rate where it
  is. So the honest statement is: seven points for a bot that heals badly, an
  unknown smaller number for a player who heals well.

Verified: parsecheck PASS at v2.53, all four maps and the hub drive and draw clean.
The build itself is VER and DESIGN.md only.

Not verified: the second reading, which is an argument and not a measurement. The
sim cannot currently retreat-then-heal, so the gap between "bot cost" and "player
cost" has no number and will not get one until that behaviour exists behind a dial.
Also not verified: whether feud and simReach are individually neutral or cancelling
each other out; the isolation says their SUM is near zero and nothing about the
parts. Also, as with every arm this cycle: BURIED CITY, Compact SMG, simGreed 52.

### v2.54: a bot that retreats to heal buys back a third of the medkit cost, suggestively

v2.53 ended with an argument that needed a number: the 7.5 point cost of
heal-over-time was measured on a bot that pops its medkit at 45 health wherever it
happens to be standing, and a person retreats first, so the player's true cost is
somewhere below the bot's. This build gives the argument its instrument and its
first reading.

simRetreatHeal, DEFAULT OFF. With the dial on, a bot below the heal threshold holds
its medkit while any live hostile has it in a sightline inside 420 units, and spends
those frames moving away from the nearest one; the moment it breaks contact, it
heals. A floor at 22 health: below that, waiting is a worse gamble than healing in
the open, two sentry hits from dead, so it heals regardless, or a bot pinned in a
long fight would hold a medkit all the way to zero. Behaviour-capability change, so
it defaults off like simSell, simPed, simCrouch and simPip, and the back catalogue
stays reproducible.

Driven before measuring, all four behaviours: with a sentry staring at it from 200
units and health at 35, the bot holds the heal, the bag still has its medkit, and
one step later it is further away, 200 to 218. Threat removed, next step it heals.
Health forced to 20 under the same sentry, it heals under fire, which is the floor
working. Dial back at 0 after every probe.

THE MEASUREMENT. 320 seeds, heal-over-time ON in both arms, only the retreat
changing:

    stand and heal 19.1% against retreat first 21.9%
    discordant 25 to 16, z 1.25, exact two-sided p = 0.211

RETREATING BUYS BACK 2.8 OF THE 7.5 POINTS, AND THE EVIDENCE IS SUGGESTIVE RATHER
THAN ESTABLISHED. The direction is the predicted one and it does not clear the bar;
by v2.42's own arithmetic a 2.8 point true effect at these rates needs more seeds
than 320 to show cleanly, so this is reported at the strength it has.

WHAT THE PAIR OF NUMBERS SAYS TOGETHER, taking both at face value. Standing still,
the medkit costs 7.5. Retreating first, about 4.7. So LESS THAN HALF the cost of
his medkit change is the bot healing in stupid places; the majority is the time
itself, six seconds of not shooting and not looting in a game that punishes both,
and no amount of healing technique gets that back. For him the practical bracket
is: the change made the game somewhere between about 5 and 7.5 points harder
depending on how well he heals, and healOverTime 0 remains the one-dial exit.

Verified: parsecheck PASS at v2.54, all four maps and the hub drive and draw clean
with 10 of 10 entities moving, the four retreat behaviours driven directly, and the
shipped default confirmed at 0. One defect caught before it shipped: the first cut
read LD.spd for the retreat speed, and LD is declared further down updateBot, so it
was hoisted and undefined and the retreat threw the moment a foe was found. The
load penalty is computed inline there now.

Not verified: the 2.8 at significance, which would take roughly 900 seeds at this
discordance rate and is queued behind better uses of that wall clock. Also not
verified: whether 420 units and the 22 floor are the right constants; both were
reasoned, neither swept. Also unchanged and still open: feud and simReach
individually, known only to sum to about zero.

### v2.55: the four-map picture at current rules, and COLD STORAGE has a raider problem

No game logic changed. Every measurement this cycle has been BURIED CITY, and the
last four-map survey predates windows, feuds, timed heals, the reach fix and the
sentry findings, so the map spread the file quotes was measured on a different
game. Re-measured: 120 seeds per map, current defaults, same seed list everywhere.

    map            extract   haul    duration   median first contact
    QUARRY          19.2%    9,405     205s            78s
    BURIED CITY     16.7%    8,058     221s            43s
    DAM             10.8%    8,882     243s            95s
    COLD STORAGE     7.5%    8,683     219s           113s

THE SPREAD SURVIVED EVERYTHING THIS CYCLE SHIPPED. Easiest to hardest still runs
QUARRY, BURIED, DAM, COLD, and COLD at 7.5 percent against QUARRY at 19.2 is a
factor of 2.6, roughly the same shape the file has carried since v2.13. Twenty
builds of mechanics, windows cut into every building, raiders at war with each
other, and the ordering of the maps did not move. Whatever makes COLD hard is
structural, not incidental.

THE SENTRY IS THE APEX KILLER ON ALL FOUR MAPS, 47 to 56 deaths of 120 everywhere,
which is consistent with the v2.40 through v2.43 thread: the sentry duel is the
fight that decides raids, on every map, at every density.

AND ONE GENUINE ANOMALY: RAIDERS KILL THE BOT 21 TIMES ON COLD, against 8 or 9 on
the other three. COLD is the map with the FEWEST raiders, five against eight, so
per raider it is roughly four times as lethal there. COLD is also the smallest,
tightest map with the fewest containers, so bot and raiders work the same shelves
sooner; the first-contact medians say the bot goes unseen longest on COLD, 113
seconds, so the raid's violence is compressed into its second half where bags are
full and health is spent. That reading is an argument, not a measurement, and it is
flagged rather than trusted.

FIRST CONTACT SPANS 43 TO 113 SECONDS ACROSS MAPS, nearly a factor of three, which
is the most texture the four maps have shown in one number: BURIED starts fights in
the first minute, COLD lets you work in silence and then kills you. Against his
standing complaint that maps feel samey, the numbers say the maps PLAY differently;
whether they FEEL different is his call, since feel lives in art and audio, not in
extract rates.

Verified: parsecheck PASS at v2.55, all four maps and the hub drive and draw clean.
Measurement build, VER and DESIGN.md only.

Not verified: everything at 120 seeds a map, so one SE is about 3 points and only
the COLD against QUARRY gap clears two SEs on its own; the ORDERING matches the
historical one, which is worth more than any single pairwise gap. Also not verified:
the COLD raider mechanism named above. Also: BURIED reads 16.7 here against 19.1 in
the 320-seed batches, which is inside one SE of both and a reminder that a 120-seed
number is a bearing, not a coordinate.

### v2.56: the COLD raider anomaly is an early-game fact, and my first explanation was wrong

No game logic changed. v2.55 flagged that raiders kill the bot 21 times on COLD
STORAGE against 8 or 9 on other maps despite COLD fielding the fewest raiders, and
offered a reading: COLD's late first contact compresses the raid's violence into
its second half, so raider deaths pile up late. That reading was checked before
being trusted, and it is wrong.

THE TEST. 120 seeds on BURIED and COLD with time of death recorded per kill:

                              BURIED      COLD
    raider kills                 7          21
    median raider kill time     46s         49s
    median machine kill time   217s        226s
    raider kills after 150s      1           2
    alive at 150s               84          85

THE CENSORING STORY IS DEAD ON EVERY AXIS. Raider kills are EARLY deaths on both
maps, median under fifty seconds, while machine kills cluster past 200. Survival to
150 seconds is identical, 84 against 85, so COLD does not keep the bot alive longer
for raiders to farm. Nineteen of COLD's twenty-one raider kills land in the first
150 seconds. The compressed-second-half mechanism I proposed predicts the exact
opposite of all of this, and it is withdrawn.

WHAT IS ACTUALLY TRUE: COLD's raiders kill three times as often in the OPENING of
the raid, 21 against 7, which at these counts is roughly p 0.01 as a two-sided
binomial. Per fielded raider, five against eight, it is nearly five to one. The
spawn-time facts do not obviously explain it: raider density per square unit is
about the same on both maps, the nearest raider spawns no closer, and the weapon
mix is the same table. What differs is the map itself: COLD is the smallest floor
at 4200 by 3400 with the tightest interior, so the bot's opening loot route and the
raiders' opening loot routes share corridors sooner. That is a plausible mechanism
and it remains UNPROVEN; distinguishing it from, say, a sightline effect through
COLD's shelving would need positional tracing that this build does not do.

Why this entry exists at all: v2.55 shipped a mechanism-shaped guess with a flag on
it, and the check took twenty minutes and killed it. The file has a long record of
plausible readings that died on contact with a measurement, v2.22's regression hunt,
v2.38's exchange rate, v2.41's overstated deaths, and the cheapest time to kill one
is before anyone builds on it.

Verified: parsecheck PASS at v2.56, all four maps and the hub drive and draw clean.
VER and DESIGN.md only.

Not verified: the corridor-sharing mechanism, which is the surviving candidate and
has no direct evidence yet. Also not verified: whether the early raider deaths are
FIGHTS or ambushes; the telemetry records who killed the bot but not whether the
bot fired back, and shots-fired-at-death would separate a duel from an execution.

### v2.57: crews wear their colours, closing the gap v2.49 shipped with

One small change, finishing a feature rather than adding one. v2.49 gave every
raider a crew and set rival crews shooting each other, and its own Not verified
line named the hole: nothing on screen said who was with whom, so a feud read as
two identical men inexplicably trading fire. A feature whose whole value is being
watched shipped illegible.

Every raider's nameplate now carries a crew block: a small coloured bar ahead of
the name, one colour per crew, red for crew one, blue for crew two, with two more
colours banked in case raiderCrews is ever raised past two. The block draws only
while the feud is live: mercenaries never show one, since they are exempt from
feuding and their loyalty is to the wallet, and raiderFeud 0 removes the colours
along with the behaviour, so the plate never advertises a war that is not
happening.

The nameplate was the right place rather than the coat. Coats already vary per
IDENTITY, they are how you recognise a man you have met before, and repainting
them by crew would have destroyed that to say something the plate can say in five
pixels. The existing plate colour keeps its old meaning, grudge red, passive
green, running teal, so the two systems stack: the bar says whose side he is on,
the name colour says how he feels about YOU.

Verified: parsecheck PASS at v2.57, all four maps and the hub drive and draw
clean. Two rival raiders parked beside the player and a frame drawn with both
plates on screen, no throw; the dial flipped off and drawn again, no throw. The
crew indices confirmed different on the two test raiders, 1 and 0.

Not verified: legibility, which is the entire point and cannot be read from a
fixture. Five pixels of bar at nameplate distance may be too subtle on his
monitor, and if it is, the width is one number. Also not verified: whether the
bar should also appear on the corpse of a feud casualty, which would let him
read a firefight he arrived too late to see; bodies currently carry no plate at
all and that is a larger change than this one.

### v2.58: the default-stack ledger closes, and the feud almost never decides a raid

No game logic changed. Third and last batch in the attribution thread: raiderFeud
isolated on the same 320 seeds, modern defaults in both arms, only the feud
toggling.

    no feud 18.4% against feud 19.1%
    discordant 6 of 320: 2 seeds extract only without the feud, 4 only with it

THE LEDGER NOW CLOSES TO WITHIN NOISE.
    whole stack (v2.53 batch one)        -6.8 points
    healOverTime alone (v2.53 batch two) -7.5 points
    raiderFeud alone (this batch)        +0.7 points
    simReach, by subtraction             about 0.0

Every point of the difficulty drop this cycle walks through the medkit and nothing
else. simReach, the correctness fix, is free, which is what a correctness fix
should be. And the feud is worth a fraction of a point IN THE BOT'S FAVOUR, which
was the v2.53 prediction, raiders shooting raiders means fewer guns pointed at the
bot, delivered at about a tenth the size anyone would have guessed.

THE FEUD FACT WORTH KEEPING: 314 OF 320 RAIDS END IDENTICALLY WITH THE WAR ON OR
OFF. v2.49 measured feuds FIRING in roughly 38 percent of raids, real bullets and
real raider corpses, and this batch says all of that violence changes the bot's own
outcome in under 2 percent of raids. The feud changes the WORLD without changing
the bot's fate, which for a texture feature is close to ideal: drama that costs the
player nothing measurable, exactly like windows at v2.52. The pattern across this
cycle is now sharp enough to state: TEXTURE IS FREE, TIME IS EXPENSIVE. Windows,
feuds and crew colours moved nothing; six seconds of medkit moved seven and a half
points.

Verified: parsecheck PASS at v2.58, all four maps and the hub drive and draw clean.
VER and DESIGN.md only.

Not verified: the simReach zero is inferred by subtraction across batches rather
than isolated directly, and the arithmetic assumes the three effects add, which
interactions could break; a direct simReach isolation would settle it and is not
worth 25 minutes against a predicted zero. Also not verified: the feud's +0.7 at
6 discordant pairs is statistically nothing and is reported as the direction of a
whisper, not a finding.

### v2.59: the v2.48 loot sounds never played, because I wired them to a path his game does not take

A defect in my own recent work, found by reading the call graph and owned in full.

v2.48 added pickRare, pickElite and pickGun and verified them green: nine chooser
cases correct, twenty-five real containers opened, voices selected properly. All of
that was true and none of it mattered, because the verification called
openContainer's FULL path directly, and live play has not used that path for
whole containers since v1.61. His containers open through STAGED PULLS: items come
out one at a time as the search bar fills, each granted through grantLoot with an
early return that bypasses the announcement entirely, and the full open then runs
at the very end with an EMPTY list. So the special-find sounds shipped, tested
clean, and never once played in his game; every staged find got a silent text
label and the container's closing got the same old generic blip. The tell was
right there in the flow: the finish was announcing "Found: " with nothing after
it.

THE FIX PUTS THE VOICE WHERE THE MOMENT IS. A rare, elite or field gun now sounds
the instant it comes OUT of the box mid-search, which is better than the v2.48
design as well as an actual repair of it: the payoff lands on the pull, not on the
container closing seconds later. Commons stay silent during staging, so a
three-item crate does not chirp three times; the plain pick blip still marks the
container finishing, and a finish with items left, which happens when a container
is opened in one lump by any other caller, keeps the full v2.48 announcement.

THE LESSON, BLUNTLY, FOR MY OWN VERIFICATION PRACTICE. I verified the function and
not the game. openContainer(ct) was the obvious thing to call and it is not what
play calls. The fixture drive that would have caught this, hold E at a real
container and watch the staged path, existed all along and was used for the FIX in
under a minute: a planted rare and a gun both came out through the staged pulls,
two items granted, container opened, nothing thrown. That is the drive v2.48
should have run.

Verified: parsecheck PASS at v2.59, all four maps and the hub drive and draw
clean, and a full staged search driven on a live raid with a rare and a gun in the
box, both pulled through the repaired path, bag up two, no throw. The fixture is
silent by construction, so no sound played during any of it, which is the point of
the fixture.

Not verified: the sound itself in his ears, unchanged from v2.48's caveat, and now
actually reachable for him to judge. Also not verified: whether the elite fanfare
overlapping a firefight is legible or lost; the voices were tuned for the quiet of
looting and a strongbox cut under siege is not quiet.

### v2.60: the paired batch becomes a fixture tool instead of a ritual

Fixture only, no game logic changed. Five 320-seed comparisons ran this cycle, the
stack, the heal isolation, the retreat dial, the windows null and the feud
isolation, and every one was the same MessageChannel loop hand-typed into the
console with the same mistakes on offer each time: setTimeout throttling in a
hidden tab, dials left dirty after the batch, and the standing temptation to stop
early the moment the split looks good.

__pairedBg(seeds, dialsA, dialsB) is that loop, once. It runs both arms of every
seed back to back so the pairing is exact, chunks with MessageChannel so a hidden
tab cannot throttle it, restores every dial it touched when it finishes, and
leaves progress on a window counter. __pairedPoll() reads progress while it runs
and the full McNemar result when it is done: rates, the concordance table,
discordant count, chi with continuity correction, and the exact two-sided p.

Verified both directions on the live fixture: a null pair with identical dials
returns zero discordant of four, which the deterministic sim guarantees, and an
extreme pair, eHp 0.45 against 1.9, returns three of six discordant all in one
direction with rates 50 against 0. CFG.eHp read 1 after both batches, so the
restore works. Parsecheck PASS at v2.60 and all four maps and the hub drive and
draw clean.

Not verified: a full 320-seed batch through the new runner, since that is 25
minutes to re-prove arithmetic already proven at small n and hand-proven five
times at full n this cycle. The next real comparison will be its first full-scale
run, and its numbers can be sanity-checked against the hand-rolled ones if the
question overlaps. Also not stored: per-seed rows, which the hand-rolled loops
also dropped; if a future question needs per-seed haul or killer under both arms,
the runner needs a rows option it does not have.

### v2.61: the COLD raider problem is twice as many of the same fight, and two more theories are dead

No game logic changed. Third pass at the v2.55 anomaly, raiders killing the bot 21
times per 120 raids on COLD against 8 or 9 elsewhere, and this one lands on a
mechanism by killing two more candidates first.

THEORY TWO, FEUD CROSSFIRE, IS DEAD. The feud fires within 600 units of the bot by
construction, COLD is the tightest map, and a stray feud round that hits the player
is booked as killer:raider, so the arithmetic was tempting. Measured: 120 COLD
seeds, feud off against feud on, killer distributions kept. Raider kills 19 without
the feud, 21 with it. The anomaly predates the feud entirely, and as a bonus the
feud's outcome-neutrality now holds on the hardest map too, 6.7 against 7.5 percent
extract.

WHAT THE DAMAGE PROBE SAYS. Forty COLD raids driven with the moment of FIRST raider
damage recorded, distance and time: twelve raids take raider fire, first hit at a
median of 35 seconds and 251 units, and all twelve shooters were in the chase
state. Not corridor collisions, only two events under 150 units. Not window snipes
either, nothing beyond 310. A raider SEES the bot inside the first minute, turns
hostile, closes, and opens fire at rifle range.

THE BURIED CONTRAST CLOSES IT. Same probe, same seeds, same forty raids: six events
against COLD's twelve, at the same character, median 27 seconds and 213 units,
chase state again. So COLD does not host a different KIND of raider encounter, it
hosts the SAME encounter at TWICE the rate, and the doubled kill count follows
directly. The question collapses from "why are COLD's raiders lethal" to "why does
a raider spot the bot twice as often in COLD's first minute", and the honest
candidates are the map's tight sightlines and the shared early loot routes of the
smallest container pool. That remains unproven, but it is now a question about
sighting geometry rather than about combat, feuds, timing or censoring, which is
four wrong doors closed.

WORTH SAYING ABOUT THE METHOD: every theory so far died to a probe that needed no
new code. The sim's telemetry, dmg by source, killer, time of death, plus driven
raids with __rawStep, has answered censoring, feuds, and now the encounter
character, each in under half an hour. The instrument this project actually
needed was built across v1.5 through v2.4, and this cycle is the payoff.

Verified: parsecheck PASS at v2.61, all four maps and the hub drive and draw
clean. VER and DESIGN.md only.

Not verified: the sighting-geometry mechanism, which would need a probe that
samples raider-to-bot line of sight through the first minute rather than waiting
for damage; it is the natural next probe if the anomaly ever matters enough to
act on. Also not verified: whether 12 of 40 against 6 of 40 is itself
significant, roughly p 0.10 two-sided at these counts, so the DIRECTION agrees
with the 120-seed kill counts but this probe alone would not carry the claim; the
21-against-8 kill figures at 120 seeds remain the load-bearing evidence.

### v2.62: COLD's raiders kill because its aisles do not blink, and the thread closes

No game logic changed. Fifth and final pass at the COLD raider anomaly, and the
mechanism is now measured rather than argued.

TWO PROBES, SAME FORTY RAIDS EACH, TWENTY PER MAP, FIRST MINUTES OF THE RAID.

SIGHTING PRESSURE IS IDENTICAL, which killed the tight-sightlines theory as
stated: sampling once a second, some hostile raider had line of sight to the bot
in 8.0 percent of COLD samples against 8.5 on BURIED, and was inside its own
weapon range in 6.2 against 5.7. Raiders SEE the bot equally often on both maps.
Theory five, dead like the previous four, but this one died into the answer.

SIGHTING LENGTH IS NOT. Tracking each raider's CONTINUOUS line-of-sight spell:

                          COLD      BURIED
    spells recorded         49         54
    median spell          1.35s      0.75s
    75th percentile       5.7s       1.35s
    90th percentile      21.8s       5.4s
    spells over 2s       38.8%      14.8%

SAME NUMBER OF GLIMPSES, THREE TIMES THE HOLD. On BURIED a raider catches sight of
the bot and the city's clutter cuts the line inside a second, so most sightings
die as glimpses and the chase fizzles. On COLD, once a raider has the bot, the
warehouse's long aisles keep the line open for five, ten, twenty seconds, which is
time to turn hostile, close to rifle range and land the eleven rounds a kill
needs. Every number upstream of this now follows: equal sightings, double the
damage events at 200 to 300 units in chase state, double the kills, all in the
first minute, feud-independent, censoring-independent.

SO THE ANOMALY IS THE MAP DOING EXACTLY WHAT A WAREHOUSE SHOULD DO, and the
question this thread opened with, mechanism or bug, resolves as mechanism, and a
GOOD one: COLD's identity is long dangerous lanes, and its raiders are the thing
that identity arms best. Nothing gets fixed, because nothing is broken. If its
7.5 percent extract rate is ever judged too cruel, the honest lever is anything
that breaks aisle sightlines, more shelving clutter, not raider counts, and that
is map authorship, which is his.

Verified: parsecheck PASS at v2.62, all four maps and the hub drive and draw
clean. VER and DESIGN.md only.

Not verified: the spell-length gap at formal significance, 49 and 54 spells with
heavy right tails resist the tests this file has been using, and I am not going
to dress a distributional eyeball up as a p-value; the 2.6x median ratio and the
tripled over-2s share across a hundred spells is reported as strong and unformal.
Also not verified: whether the same aisle effect shows on the QUARRY's terraces,
which the four-map killer table hints at, sentries there hold the same top spot
at a higher extract rate, and nobody has asked the question of that map yet.

### v2.63: every sim row now says which game it was measured on

One small change, same trap class as the tier stamp at v2.36. That build found that
every published number had been silently scaled by the profile's world tier and
fixed it by stamping tier, lootMul and hpMul on every sim row, so a batch could
not be compared across tiers by accident. This cycle recreated the identical trap
one layer up: three behaviour defaults changed, healOverTime, raiderFeud and
simReach, and one of them alone moves the extract rate 7.5 points, so a batch
recorded at v2.43 and a batch recorded at v2.58 quote rates for DIFFERENT GAMES
with nothing on either row saying so. The next session that lines two old batches
up side by side walks straight into it.

Every simResult now carries a dial fingerprint, one compact string rather than an
object so a hundred rows do not carry a hundred copies:

    dials: "hot1 feud1 reach1 win1 rheal0 eng0 pip0 greed52"

covering the heal, the feud, the weapon-range reach, windows, retreat-heal, the
engage radius, the pip and the greed threshold, which is every dial that has
shipped default-on or been A/B'd this cycle. A mismatch between two batches is now
visible in the first row of each instead of discoverable only by whoever remembers
which build changed which default.

Verified: parsecheck PASS at v2.63, all four maps and the hub drive and draw
clean. The stamp itself exercised: a row at shipped defaults reads hot1 feud1
reach1 win1 rheal0 eng0 pip0 greed52, the same seed with healOverTime 0 reads hot0
with all else identical, and the dial was back at 1 afterwards.

Not verified: completeness. The fingerprint covers the dials this cycle touched
plus greed; older behaviour dials, simCrouch, simSell, simPed, simWade and the
rest, are not stamped, on the argument that they have been stable at their
defaults since their own build notes and stamping all thirty would make the string
unreadable. If one of them is ever flipped in an arm, it joins the stamp then, and
until it does the fingerprint can claim two rows match when an unstamped dial
differs.

### v2.64: the paired runner keeps rows now, because every question this cycle ended in a killer table

Fixture only, no game logic changed. v2.60 shipped the backgrounded paired runner
and named its own gap: no per-seed rows. That gap then cost three hand-rolled
batches in a single day, the COLD feud test, the COLD against BURIED death-time
comparison and the four-map survey, each rebuilt from scratch because the question
was ATTRIBUTIONAL, which killer, at what time, with what haul, and the runner only
kept the McNemar counts.

__pairedBg takes a fourth argument, keepRows. Off by default, because three
hundred and twenty full rows is memory nobody reads unless the question needs it.
On, every seed stores outcome, killer, haul and time of death for BOTH arms, and
__pairedPoll's finished result carries the rows plus a killer table per arm
computed in the poll, so the console never has to fold three hundred rows by hand
again.

Verified: parsecheck PASS at v2.64, all four maps and the hub drive and draw
clean. The option exercised on a five-seed extreme pair: five rows present, each
carrying both arms' outcome, killer, haul and time of death, killer tables
computed per arm, and CFG.eHp back at 1 afterwards. Default off confirmed by the
earlier v2.60-style call still returning no rows field.

Not verified: memory behaviour at full scale with rows on, 320 rows of two small
objects each, which arithmetic says is trivial and which the first real
attributional batch will confirm in passing. Also noted while testing: two smoke
runs of the same extreme pair gave different arm rates because smoke tests do not
pin the full dial set, which is exactly the class of ambiguity the v2.63
fingerprint now makes visible on the rows themselves; a smoke test is a mechanism
check, not a measurement, and its rates mean nothing.

### v2.65: the windows look like windows, verified in pixels rather than in prose

No game logic changed. v2.51 shipped windows with an honest hole in its
verification: "Not verified: the LOOK. The sill and glass colours are reasoned,
not seen; if a window reads as a doorway on his monitor the mullion and sill
constants are the place to push." The fixture can prove geometry and cannot see.
The capture sink on 8779 can, and it is the same instrument that settled the
cars-as-suitcases complaint at v1.64, so a look question got the look tool.

The player was stood two steps south of an 80 by 16 window on BURIED CITY, the
world frame rendered and posted as a PNG, and the PNG read back. What the pixels
show: the window is a pale blue-grey band set into the wall run, visibly glass
against the solid masonry either side of it, split into two panes by the mullion,
with the sill line along its base. It does not read as a doorway, because a
doorway in this game is an absence and the glass band is emphatically a presence.
And the payoff of the whole feature is in the same frame: the player's vision fan
pours THROUGH the pane and lights the floor of the room beyond, while the wall
either side of it still casts shadow, which is see-through-but-not-walk-through
drawn as one picture.

So v2.51's remaining caveat narrows from "the look is unverified" to "one window
on one map at one size has been seen and looks right". The colours were chosen
blind at v2.51 and happen to sit well against BURIED's purple palette; the other
three maps use other palettes and their windows have been proven open to rays but
not yet looked at.

Verified: parsecheck PASS at v2.65, all four maps and the hub drive and draw
clean, and the captured frame itself, tools/shots/window_v264.png, 310KB posted
through the sink and inspected.

Not verified: the other three maps' palettes under the same glass colours, night
and weather variants, and a vertical window, since the captured one is
horizontal; each is one more capture if doubt ever arises. Also unchanged from
v2.51: no crouching below sills, which is a design question and his.

### v2.66: DAM raids run long because some of them are half swum, and a broken probe owned

Fixture hooks only, no game logic changed. Three loose ends closed, one of them
mine.

THE BROKEN PROBE FIRST. The first pass at DAM's 243-second raids reported zero
wading on the wettest map in the game, and the zero was my instrument: inWater
lives inside the IIFE, the probe ran in page scope, typeof read undefined and the
sampler silently counted nothing. The same probe also drove LIVE raids with
__startRaid and compared their durations against sim-raid figures, which is not a
comparison at all. Both faults are now structural rather than repeatable: the
fixture exposes __water.at, and __simRaidBegin / __simRaidStep / __simRaidEnd give
diagnostics a steppable SIM raid with real sim semantics, which is the thing four
probes this week hand-rolled against live raids by mistake.

THE ANSWER, MEASURED WITH THE FIXED INSTRUMENT. Twelve sim raids per map on the
duration extremes, sampling water membership each second:

    DAM     mean 14.7 percent of raid time in water, extremes 0 to 59.5
    QUARRY  mean  2.1 percent

AND THE SHAPE MATTERS MORE THAN THE MEAN. DAM's per-raid figures are bimodal:
five raids of twelve never touch water, five spend a quarter to a third of the
raid in it, one spends SIX MINUTES OF TEN swimming. The seed decides whether the
loot route crosses the flood, and a bot that routes wet pays 0.34 speed on
every wet step. That is where DAM's long tail of slow raids comes from, and it is
the map working as authored, the flood is DAM's identity the way the aisles are
COLD's.

THE WINDOW PALETTE ADDENDUM, closing v2.65's remaining caveat: the same capture
pass was run on the other three maps. DAM's grey-blue, COLD's mixed block and
QUARRY's rain-washed yard all show the glass band reading as a window against
their own palettes, and the DAM and QUARRY frames both catch the vision fan
exiting through a pane onto the ground beyond, which is the feature drawn as one
picture. tools/shots/window_dam.png, window_cold.png, window_quarry.png.

Verified: parsecheck PASS at v2.66, all four maps and the hub drive and draw
clean, __water.at returns true over DAM flood tiles by construction of the
measurement itself, and the steppable sim raid produces sim-typical durations,
205 and 194 second means, where the live-raid mistake had produced 447.

Not verified: the wading share against the survey's full 120-seed duration gap,
since twelve instrumented raids are a bearing rather than a coordinate; the
bimodal shape is the finding and it is visible at this n. Also not verified:
whether a 59.5 percent swum raid is fun, which is his kind of question, and the
map's wet routes are his authorship.

### v2.67: one call pins the measurement baseline, ending the hand-typed dial ritual

Fixture only, no game logic changed. The last recurring hazard in the measurement
workflow, closed the same way v2.60 closed the batch loop.

Every batch this cycle opened with the same twenty hand-typed dial assignments,
simGreed 52, simCrouch 0, the eleven correctness dials, the tier pin and the rest,
and the ritual failed twice in one day: two smoke tests ran with whatever dials
the previous batch had left behind, produced arm rates that meant nothing, and one
of them briefly read as a real discrepancy before the cause was traced. The v2.63
fingerprint makes such a mismatch VISIBLE after the fact; this makes it not happen.

__pinDefaults(mapIx) sets every dial a measurement arm depends on to the canonical
measurement posture in one call, pins the map, the loadout and the gun wear, and
returns a ledger of exactly what it changed so a probe can see what the previous
occupant left dirty. Arms then override only the dial under test. The dial list
lives in ONE place now, so when a future build adds a dial to the posture it is
added once rather than remembered in every batch.

Verified: parsecheck PASS at v2.67, all four maps and the hub drive and draw
clean. The pin itself exercised: eHp forced to 1.5, simGreed to 99, healOverTime
to 0 and the map to QUARRY, one call returned a change ledger naming exactly
those three dials with their old and new values, the CFG read back at canon, a
sim row stamped the canonical fingerprint hot1 feud1 reach1 win1 rheal0 eng0
pip0 greed52, and the mapIx argument overrode the default.

Not verified: adoption, which is a discipline rather than a mechanism; the
function only helps the session that remembers to call it first, and the memory
note for the 320-seed standard now needs one line pointing at it, which is
written alongside this entry. Also deliberately out of scope: __pinDefaults does
not restore dials afterwards, that remains the batch runner's job, because a pin
and a restore are different promises and conflating them is how dials got dirty
in the first place.

### v2.68: the exit dial I kept promising him is now actually on the console

His-facing fix, small code, embarrassing cause. Three changelog entries this
cycle, v2.53, v2.54 and v2.58, told him "healOverTime 0 is one dial in the
console" as the escape hatch from the medkit change and its measured 7.5 points
of difficulty. Checked today: the Tuning Console had never heard of it. Thirty
sliders, none of them the three dials this cycle shipped, so the exit I kept
pointing at was reachable only through devtools, which for him means it did not
exist. The claim was written three times and verified zero times, which is the
same failure as the v2.48 loot sounds wearing a different coat.

The console now carries all three of the cycle's gameplay dials, as 0/1 toggles:

    Heals take time (0 instant)     live
    Raider crews feud (0 truce)     live
    Buildings have windows          NEXT RAID

Heals and feuds read their dial at use time, so those flip mid-raid; windows are
cut when the map is built, so that row carries the console's existing NEXT RAID
tag. All three participate in the preset system the same way every other slider
does: touching one marks the config custom and saves, and applying a preset
resets them to defaults alongside everything else.

Verified through the console's own machinery rather than by reading it: the
fixture gained a __tune hook, the modal was opened by its real toggle, the list
built 33 rows, all three labels present, the NEXT RAID tag on windows and only on
windows, and the Heals slider driven through its own oninput handler set
CFG.healOverTime to 0, marked the preset custom, and set it back. Parsecheck PASS
at v2.68, all four maps and the hub drive and draw clean.

Not verified: the row labels' fit at his font scale, since the console renders
labels at whatever TYPE scale he runs and "Heals take time (0 instant)" is longer
than most rows; if it wraps badly the label is one string. Also not verified: 
whether simRetreatHeal belongs on the console too. It stays off it deliberately,
it is a sim-behaviour dial rather than a game dial, and the console has kept that
distinction since simGreed was allowed on only because the sim card reads it.

### v2.69: the live page boots clean, and three small caveats close

No code changed anywhere; this is a verification build that closes open caveats
from the last three entries, and the version bump exists so the record of what
was checked has an address.

THE LIVE PAGE, CHECKED FOR THE FIRST TIME IN TWENTY-FIVE BUILDS. Parsecheck and
the fixture share the game's script but not its boot context, and v0.98 shipped a
build that parsed clean and died during boot, which is why "verify must draw a
frame" is a standing rule. The play page on 8802 was loaded read-only: boot
completed with ZERO console errors, both canvases constructed at full size, the
tuning modal present in the DOM, and v2.68 in the page text. The one thing that
could not be verified is an actually-drawn frame, because the browser pane was
hidden and a hidden pane suspends requestAnimationFrame, which stalls the game
loop by design; that limitation is documented in the session memory and is the
pane's, not the game's. The boot-throw failure class v0.98 belonged to is
excluded; a drawn frame on his monitor is not, and his next real session settles
it by existing.

A NOTE SO NOBODY PANICS AT A NUMBER: the profile visible from the pane on 8802
reads zero runs and starter credits. That is the browser PANE'S own localStorage
partition, which had never visited 8802 before. His real save lives in his own
Chrome and was not touched.

CONSOLE LABEL FIT, closing v2.68's caveat by measurement rather than pixels: the
three new rows render their labels at the same 12 pixel height as every existing
row, no horizontal overflow, no wrapping, and the NEXT RAID chip sits inline on
the windows row only.

CONSOLE PROMISES OLDER THAN THIS CYCLE, checked and clean: concealPow, packR,
packMax and eHp, each described somewhere in this file as "on the Tuning
Console", are all genuinely in the SLIDERS list. The v2.68 failure was this
cycle's alone. That check found nothing, and it is recorded because a clean sweep
is information too.

Verified: parsecheck PASS at v2.69, all four maps and the hub drive and draw
clean in the fixture.

Not verified: a composited frame on the live page, as above, which needs either
his eyes or a displayed pane; everything short of that is green.

### v2.70: nine hundred seeds say retreating to heal is worth less than I said

No game logic changed. v2.54 measured simRetreatHeal at plus 2.8 points on 320
seeds, called it suggestive at p 0.21, and estimated roughly 900 seeds to settle
it. The 900 have now been run, the first full-scale batch through the v2.67 pin
and the v2.60 background runner, and the answer cuts against my own earlier
number:

    stand and heal 20.0% against retreat first 21.9%
    discordant 99 of 900: 58 flip toward retreating, 41 against
    z 1.61, exact two-sided p = 0.107

THE EFFECT SHRANK AS THE SAMPLE GREW, 2.8 points at 320 down to 1.9 at 900, which
is what regression to the mean looks like when an early estimate rode its noise.
And it STILL does not clear the bar. So the honest statement of record: teaching
the bot to break contact before healing is worth somewhere around two points,
probably, and even nine hundred paired raids cannot promise the sign.

WHAT THIS SETTLES ABOUT THE MEDKIT, AND IT IS THE STRONGER FORM OF v2.54's
CONCLUSION. The heal-over-time cost is 7.5 points, established at p 0.00012.
Healing technique recovers at most a quarter of it, unprovably. The rest is the
six seconds themselves, not shooting and not looting in a game that punishes
both, and no behaviour buys that back. For him the bracket tightens: the medkit
change made the game about 5.5 to 7.5 points harder almost regardless of how
well he heals, and healOverTime on the console, there since v2.68, remains the
only real exit.

TOOLING NOTE, since this was the first full-scale run of the new pipeline:
__pinDefaults reported a clean baseline before the batch, __pairedBg carried 900
seeds without a stall across roughly eighty minutes of hidden-tab wall clock, and
the dial came back restored. The pipeline is no longer new.

Verified: parsecheck PASS at v2.70, all four maps and the hub drive and draw
clean. VER and DESIGN.md only.

Not verified: the 1.9 points itself, which at p 0.107 remains a direction rather
than a finding, and this file is done spending wall clock on it; the dial is off
by default, its value is bounded above by small, and the question only matters if
he ever turns it on. Also not verified: whether the shrink from 2.8 to 1.9 will
continue at larger n; the honest prior after watching it shrink once is that the
true effect sits below 1.9, not above.

### v2.71: a raider's corpse says whose it was, and the check that led here found nothing wrong

Two things this tick: an audit that came back clean, and the small feature the
audit pointed at.

THE AUDIT FIRST, RECORDED BECAUSE A CLEAN SWEEP IS INFORMATION. The worry was
v2.49's bullet path setting byPlayer false on feud kills: if raider loot drops
were gated on that flag, a feud casualty would vanish without a lootable body and
the aftermath of the feature's own fights would be empty. Checked: the drop runs
on e.bag.length alone, whoever fired the shot, and byPlayer gates only kill
credit, contract progress and the grudge ledger, which is exactly where it
belongs. Feud casualties drop everything they carried, gun included, since every
raider spawns with one in the bag. Nothing to fix.

THE GAP NEXT DOOR, WHICH v2.57's OWN NOT VERIFIED LINE NAMED. A dead raider
became an anonymous 'body' container, so the aftermath of a feud, two corpses in
a doorway, read as furniture. The living man wears his name on a plate and his
crew's colours beside it since v2.57; dead, he lost both.

The body container now carries the fallen man's name and crew. The search prompt
spends them: standing over a raider's corpse reads SEARCH SIGMAGRINDSETTOM rather
than SEARCH BODY, with the same crew block the living man wore, in the same
colours, drawn beside the prompt. Two named bodies from different crews in one
doorway now tell the story of the fight by themselves, which is the last piece of
making the feud something he can read off the world. Mercenaries keep their name
and show no crew block, because they were exempt from the war alive and stay
exempt dead; the crew block also disappears entirely when raiderFeud is off, so
the prompt never advertises a war that is not running.

Verified by killing rather than by reading: a raider shot down with byPlayer
FALSE dropped a body carrying his exact name, his crew index and all six items of
his bag; the prompt path drew clean with the player stood on the corpse; a
mercenary killed the same way dropped a named body with NO crew tag. Parsecheck
PASS at v2.71, all four maps and the hub drive and draw clean with 10 of 10
entities moving.

Not verified: the LOOK of the crew block beside the prompt, which is four pixels
of colour positioned from a measureText width; if it crowds the text at his font
scale it is two constants. Also not verified: bodies that already existed on the
map at spawn, the sweep-placed 'body' furniture containers, correctly carry no
fallen name and still read SEARCH BODY, which was confirmed in passing by the
prompt fallback but not exercised as its own case.

### v2.72: a bought gun sounds like a gun, finishing the sound ladder's loose ends

Two one-line changes, closing the last corners v2.48 left open and v2.59
re-opened for inspection.

The Peddler's counter was the remaining place a find crossed into the bag on the
old generic chirp: buying an Auto Rifle from him clicked exactly like picking up
scrap, while pulling the identical rifle from a crate has rung like metal since
v2.59. The purchase now routes through lootVoice, so a bought gun scrapes, a
bought elite gets its fanfare, and a bought bandage stays a click, decided by the
same table that prices the find everywhere else.

Second, the auto-equip path: with autoEquip on, a field gun good enough to swap
to announced itself with the generic blip. It is a GUN arriving in your hands,
the single most consequential pickup in the game, and it now uses pickGun. The
dial defaults off, so most raids never hear this line, but the one that does
should not be told it found scrap.

Deliberately left on the plain blip, after reading every call site rather than
sweeping blind: the drag pickup, the slot assignment, the slot select, manual gun
equipping from the inventory, the armour slot, the stray hand-off and the body
recovery. Those are ACTIONS the player chose, not finds the world dealt, and a
rarity fanfare on a deliberate act would teach the ladder to mean nothing.

Verified: parsecheck PASS at v2.72, all four maps and the hub drive and draw
clean with 10 of 10 entities moving. The purchase exercised for real: a
gun_rifle planted in a live Peddler's stock, bought through the actual pedBuy
path, arrived in the bag, marked sold, threw nothing, and the voice chosen for it
is pickGun. Silent in the fixture by construction, as always.

Not verified: the sell-to-peddler direction, which still plays the plain blip and
is left that way on purpose, selling is a decision and the money line already
carries the payoff; if he wants a register sound for it, that is a taste call.
Also not verified, unchanged from v2.48: every voice's actual sound in his ears.

### v2.73: the corpse prompt seen in pixels, and one more stale G in the legend

One string fixed and one caveat closed, both found by the same capture.

THE STALE STRING. The long help block's HOTBAR line still read "1-7 selects, G
uses it." v2.45 moved the hotbar's action onto the trigger and updated the GEAR
key list and the under-bar caption, and this third copy of the same fact was
missed, sitting eight lines below the GEAR section that contradicted it. It reads
"1-7 selects, FIRE uses it" now. Three copies of one fact is the disease; this
build only treats the symptom, and the honest note is that any future control
change has THREE legend surfaces to visit: the key list, the under-bar caption,
and the tips block.

THE CAPTURE, closing v2.71's look caveat. First shot caught the corpse prompt
buried under the kill announcement, which is correct behaviour, the label
outlives the kill by two seconds and the prompt by design sits at the same spot.
Second shot, taken after the label faded: the prompt reads [E] SEARCH
LOOTGOBLIN_PRIME in the standard prompt yellow with the fallen man's red crew
block sitting clear of the text on its left, legible at capture scale, no
crowding, no wrap. The feud aftermath is now readable in-world exactly as
intended, and it has been SEEN rather than reasoned about.
tools/shots/corpse_prompt2.png is the frame.

Verified: parsecheck PASS at v2.73, all four maps and the hub drive and draw
clean. The capture itself exercised the full kill-drop-approach-prompt chain on
a live raid.

Not verified: the two seconds of overlap between the kill label and the search
prompt when the player is already standing on the body as it drops, visible in
the first capture. It resolves itself as the label fades and both pieces of text
are saying the same name, so it is recorded as observed and acceptable rather
than as a defect; if he ever reports the flicker of doubled text, the fix is to
suppress the prompt while a label is live at that spot, and it is small.

### v2.74: the corpse stops saying its name twice

One conditional, closing the overlap v2.73 captured and called acceptable. It was
acceptable; it was also the single most common way he will ever meet the named
corpse, because the usual reason to be standing over a raider's body the moment
it drops is having just made it, at close range, and for the kill label's two
seconds the world said LOOTGOBLIN_PRIME twice in two fonts a few pixels apart.

The body now stamps the raid clock at the moment it falls, and the search prompt
defers the NAME until 2.3 seconds have passed, a hair past the label's life.
During the overlap the prompt reads the plain SEARCH BODY, so the interaction cue
never disappears, which matters more than the name does; hiding the whole prompt
to avoid a stutter would have hidden the fact that the body can be searched at
all. Bodies found cold, the ordinary case for a feud aftermath, show their name
immediately, since their label is long gone.

A probe correction worth a line: the first verification aged the body with __sim
and reported the defer never expiring, which briefly read as a bug. __sim
deliberately does not advance the raid clock, a fact this file established at
v2.39 and I re-forgot; __rawStep does, and under it the sequence is exactly as
designed, generic at the drop, named at 3.15 seconds, both draw states clean.

Verified: parsecheck PASS at v2.74, all four maps and the hub drive and draw
clean with 10 of 10 entities moving, the fellAt stamp present on a dropped body,
the fresh state showing generic and the aged state showing the name on the raid
clock, neither state throwing.

Not verified: the exact 2.3 against the label's real fade curve, which was read
from the label code's lifetime rather than measured against its alpha; if a
frame or two of faint overlap survives at the boundary it is invisible against
the fade and not worth a capture. Also not verified: a body dropped by a feud
while the player watches from distance, where the label and prompt never
coexist; the defer costs that case 2.3 seconds of name for no benefit, which is
judged cheaper than a per-label liveness query.

### v2.75: QUARRY breaks my aisle theory, which its own caveat predicted

No game logic changed. v2.62 closed the COLD raider thread on "long aisle holds
convert sightings into kills" and its Not verified line named the check that
could break it: the same probe on QUARRY's terraces. Run now, with DAM alongside,
completing the four-map table:

    map       spells   median   p75     p90     over 2s
    DAM         37     0.30s    0.45s    9.6s    16.2%
    BURIED      54     0.75s    1.35s    5.4s    14.8%
    COLD        49     1.35s    5.7s    21.8s    38.8%
    QUARRY      34     1.65s    4.35s    7.35s   47.1%

AND THE THEORY AS STATED IS DEAD, killed by the map I said to check. QUARRY holds
line of sight LONGEST, the highest median and nearly half of all spells past two
seconds, and QUARRY's raiders kill the bot LEAST, eight or nine per 120 raids
against COLD's twenty-one. If hold length alone converted sightings into kills,
QUARRY would be the raider abattoir of the four. It is the easiest map in the
game.

WHAT SURVIVES, STATED AT ITS REAL STRENGTH. COLD still has the kills, still has
them early, still at rifle range from chasing raiders, and still has long holds;
none of that moved. What died is the claim that the holds ALONE are the
mechanism. The discriminating difference between COLD and QUARRY is what the
held line runs THROUGH: COLD's holds live in shelving lanes where breaking
sideways is a wall, QUARRY's live over open ground where both parties can
manoeuvre and shoot, and open ground is a fight the bot's own weapon can join.
So the surviving hypothesis is holds PLUS confinement, a lane you cannot leave
laterally, and that is one more unproven mechanism rather than a conclusion; the
difference this time is that it is the last one standing after five others died
on measurement, not the first one that sounded right.

The p90 column carries a second small fact: DAM's holds are glimpses at the
median, 0.30 seconds, city-like, but its 90th percentile is 9.6 seconds, longer
than BURIED's, which will be the dam crest and the open water margins, the same
both-ways-open geometry as QUARRY at smaller scale.

Verified: parsecheck PASS at v2.75, all four maps and the hub drive and draw
clean. Measurement build, VER and DESIGN.md only, run under __pinDefaults.

Not verified: the confinement clause, which would need a lateral-escape metric,
roughly the free width perpendicular to the held sightline, and nothing measures
that today. Also the standing caveat on all spell counts: 34 to 54 spells per
map resists formal testing, and every number above is a distribution eyeballed
honestly rather than a p-value.

### v2.76: the game tells him what changed, once, on the hub

His last recorded runs were v2.43 and thirty-three builds have landed since:
the trigger drives the hotbar now, heals cost six seconds, buildings grew
windows, the raiders went to war in colours, the inventory drags, and three new
toggles sit on his console. Nothing in the game said any of it, and the way he
was going to find out that heals take time was by dying inside one.

A one-time card on the hub now says so. UPDATED TO v2.76 over a short authored
list, seven lines, each one a change he will FEEL and none of them a fix or a
measurement; the list is a hand-maintained constant next to VER with its own
comment saying exactly what belongs on it. The card is dismissed by WALKING,
because the first thing anyone does on the hub is walk and a card needing its
own close key is a card that gets stuck; the stamp is written on dismissal
rather than display, so closing the tab mid-card shows it again. Seen state
lives in a NEW profile field, lastSeenVer, no storage key changes, and an old
profile without the field simply sees the card once, which is the intended
behaviour for exactly that profile.

The fixture gained __hubFrame, because __frame draws raids and the card lives in
the hub renderer, a distinction the first capture attempt demonstrated by
producing a raid HUD. With the real hub frame: the card renders centred over the
Undercroft, amber header, all seven lines legible, stations readable around it,
walk-to-dismiss footer in place. tools/shots/whatsnew_card2.png is the frame.

Verified: parsecheck PASS at v2.76, all four maps drive and draw clean with 10
of 10 entities moving, hub steps clean; the card shows on a profile with no
lastSeenVer, ten frames of held W stamp it to 2.76 and save, and the layout was
seen in pixels rather than reasoned about.

Not verified: the card against his real profile, which has no lastSeenVer and
will show it on his next hub visit, exactly once, which is the feature working
but has not been watched happening on his save. Also a maintenance obligation
rather than a caveat: the WHATSNEW list only stays true if future player-facing
builds update it, and a stale list is worse than none; the comment above it says
so, and this entry says it twice.

### v2.77: the whats-new card stops nagging, one build after it was born

A design flaw in v2.76, caught the next morning and owned. The card keyed its
seen-state to VER, and VER bumps on EVERY build, including measurement-only ones
that change nothing he can feel. Under that rule the identical seven lines would
have re-shown at every session that followed any build at all, and a card that
nags with unchanged content is a card that gets walked through unread, which
defeats the one job it has.

The card now keys to WHATSNEW_VER, a version stamped on the LIST rather than on
the build, sitting directly above the list with the comment that says when to
move it: only when the list itself changes. The header still names the current
build, so he always sees the real version number; the seen-state just stops
caring about builds that did not touch him.

Verified: parsecheck PASS at v2.77, all four maps drive and draw clean with 10
of 10 entities moving, hub steps clean. The two states exercised directly: a
profile stamped 2.76 stays card-free on this 2.77 build, and an unseen profile
shows the card and stamps to the LIST version 2.76, not to the build version,
after ten frames of walking.

Not verified: the failure mode this creates, which is the mirror of the one it
fixes: if a future build adds a player-facing change and updates WHATSNEW but
forgets to bump WHATSNEW_VER, the new line is silently never shown to anyone who
saw the old card. The two constants sit four lines apart with a comment binding
them, which is the strongest guard a convention can be; a check that the list
content hash matches the version would be stronger and is not worth its weight
in a game with one developer and one player.

### v2.78: web-hardened for tonight's itch upload

He asked how to put the game online for friends and is uploading to itch.io
tonight, so this build makes the single file behave itself on an origin that is
not this machine.

THE ONE WART, FOUND BY GREPPING FOR EVERYTHING THE FILE REACHES FOR. The game is
self-contained by charter, no CDNs, no libraries, and the sweep found exactly one
network reference: the telemetry DROP to http://localhost:8799. On an https itch
origin that fetch is mixed content, blocked before the network, rejected into the
download fallback, and a red console error on every single run for people who
never had a collector to reach. DROP is now null anywhere but localhost, and
autoExport goes straight to the fallback when it is null, so friends get a clean
console and their run report lands in Downloads.

CHECKED RATHER THAN ASSUMED, because iframes eat downloads: the fallback download
is triggered inside autoExport, which runs inside the outcome button's click
handler, so it carries user activation, which is what itch's sandbox requires for
a download. The chain was read end to end before relying on it. Friends' reports
save as dark_raiders_runN.txt; if he forwards them into exports/ they get mined
exactly like his own, which quietly turns tonight's upload into a playtest
pipeline.

THE INSTRUCTIONS HE ASKED TO KEEP live in tools/PUBLISH.md: the five itch steps,
the re-upload flow for updates, the friend-facing notes on saves and reports, the
zip rebuild commands, and the Netlify fallback. The upload artifact,
tools/publish/dark_raiders_web.zip with index.html inside, is rebuilt at v2.78,
and tools/publish/ is gitignored because a build artifact in the history is how a
stale zip gets shipped.

Verified: parsecheck PASS at v2.78, all four maps drive and draw clean with 10 of
10 entities moving, hub clean through the hub frame hook, and the drop gate
confirmed present in the served build with hostname localhost keeping the drop
alive HERE, so his own collector flow is untouched.

Not verified: the off-localhost branch on a real https origin, which cannot be
tested from this machine; the expression is a hostname equality and the fallback
path it selects is the same one exercised every time the local drop is down,
which is well-trodden. Also not verified: itch's iframe on his actual account
settings tonight; if the download prompt does not appear for friends, the first
thing to check is their browser's automatic-download permission for the itch
domain, and P.autoExport stays the off switch.

### v2.79: the whats-new card greets returning players, not arriving ones

One conditional, and the second first-impression fix in two builds, both found by
walking the cold-start path a friend will take tonight.

A fresh profile has no lastSeenVer, so under v2.77's rule a friend clicking the
itch link would have had, as the LITERAL FIRST SCREEN of the game, a card headed
UPDATED TO v2.79 listing changes to controls they have never used: "your FIRE
button NOW uses the selected slot" is a sentence addressed to somebody's memory,
and they do not have one. The card was written for the returning player and now
checks that it has one: a profile with zero runs stamps itself current silently
and goes straight to the clean hub; a profile that has played shows the card
exactly as before.

His own profile has runs, so HE still gets the card on his next session, which is
the point of the thing existing.

Verified all three states through the real hub frame: a no-runs no-stamp profile
comes out stamped 2.76 with no card shown; a five-run unstamped profile keeps the
card up while standing still; ten frames of held W stamp it and save. Parsecheck
PASS at v2.79, all four maps drive and draw clean with 10 of 10 entities moving.
The itch zip is rebuilt at v2.79, so tonight's upload carries this.

Not verified: whether a fresh player should get a different card, a welcome
rather than a changelog, which is a real idea and a design call; the legend list
already carries the controls and the hub prompts carry the flow, so the cold
start is not unaided, and a welcome card is his to want. Also not verified: the
zero-runs test reads P.runs, which counts finished raids; a friend who opens the
game, walks the hub and closes without raiding stays a "fresh" profile and would
see no card even after future updates until they actually play, which is judged
correct rather than a hole.

### v2.80: a fresh player gets a rolled starter instead of two identical pistols

Third cold-start find in three builds, and the deepest, surfaced by driving the
first raid a friend will play tonight from a genuinely wiped profile.

The fresh-profile literal shipped equipped:'pistol', and the deploy grants every
operator a Scav Pistol sidearm unconditionally. So a brand-new player's first
kit was their owned Scav Pistol as primary AND the issued Scav Pistol as
sidearm: two identical guns, an X swap that swaps nothing, and wear quietly
accruing on their only owned weapon from the first shot of their first raid,
toward a jam mechanic and a repair shop they have never heard of. Worse, the
four rolled starters, Ferro, Kettle, Stitcher, Hullcracker, exist for exactly
one stated reason, giving a first raid some character after bare-hands deploys
proved a death spiral, and the profile default meant that system NEVER FIRED for
the only players it was built for. His own recorded runs are full of starters
because his profile reads equipped 'fists'; fresh friends were getting a blander
first raid than the developer ever saw.

The fix is the one field: a new profile is born with equipped:'fists', which
routes the deploy to the rolled-starter branch exactly as that code's own
comment promises. The owned pistol stays in the armoury for whenever they choose
it deliberately, wear-free until then. Existing profiles are untouched, this is
only the literal a new profile is created from, and the loadProfile guard
already handles 'fists' as an equipped value.

Verified from a wiped profile through the REAL flow: fresh boot, hub, walk onto
the DEPLOY LIFT, press E through the actual hub step, and the raid opens with an
ISSUED starter, Ferro plus the Scav Pistol sidearm, wepIssued true, three
deploys from three. The full cold path also drove clean end to end earlier in
the same probe set: no card for a fresh profile, DAM first map, two bandages, no
rig, 120 frames of raid without a throw. Parsecheck PASS at v2.80, all four maps
and the hub drive and draw clean. The itch zip is rebuilt at v2.80.

Not verified: starter VARIETY across fresh deploys, since the three probe
deploys re-entered from near-identical PRNG state and all rolled Ferro; the
pick(STARTERS) mechanism is untouched by this change and its variety has been in
live service since v1.0x, so this is noted rather than chased. Also not
verified: whether a fresh player should ALSO start without the armoury pistol
entirely; owning one unused gun is harmless and gives the armoury screen
something to show, so it stays.

### v2.81: the Undercroft is five stations, exactly the five he named

His note, 2026-08-25: "there are too many characters to choose from in the
undercroft -- it needs to be like a stash, a single trader/quest giver, the
gambler, the cheat menu/dev box, and the deploy lift." Ten stations stood in a
700 by 470 room; his list is five, and five is what stands there now, his five:

    DEPLOY LIFT        to the surface
    HOLT, THE TRADER   [E] shop  [R] workshop  [F] hire  [T] the terms
    VESH, THE GAMBLER  unmarked goods, flat price
    THE STASH          [E] terminal  [R] season
    DEV BOX            [E] dev crate  [R] tuning

NOTHING WAS DELETED, ONLY THE CROWD. Every modal, the shop, the workshop, the
hiring bench, the Terms, the season board, the dev crate, the tuning console,
survives byte for byte; what changed is how many bodies offer them. A merged
station maps several KEYS, its sub line is BUILT from that map so the keys on
screen can never drift from the keys that work, and E always fires the first
listed function, so walk-up-and-press-E still does the most common thing
everywhere. Holt absorbs all four trade-and-work functions, which makes him the
single trader and quest-giver the note asked for; the Terminal becomes THE STASH
and carries the season board; the crate and the console share the dev box.

Verified through the real hub input rather than by calling the modals: the
player teleported to each station and each mapped key pressed through the actual
hub step, nine routes, nine correct modals, shop workshop merc terms gamble
terminal season crate tuning, each confirmed open by its DOM class and closed
before the next. Five stations counted in the live hub state. The new layout
seen in pixels, tools/shots/undercroft5.png: five islands with room around them,
against ten before. Parsecheck PASS at v2.81, all four maps drive and draw clean
with 10 of 10 entities moving, hub steps and draws clean. WHATSNEW updated with
the change and WHATSNEW_VER bumped, so returning players get told; the itch zip
is rebuilt at v2.81.

Not verified: the gamepad, which maps its A button to KeyE only, so pad players
reach each station's FIRST function and not the merged extras; that is four
functions out of reach on pad, it predates this build only in shape, and wiring
pad buttons to the extra keys is straightforward if he plays on pad. Also not
verified: the empty floor where five stations used to stand, which the capture
shows as pleasantly roomy but which may read as bare to him; furniture is
authorship and his. Also not verified: whether the Terms belongs under Holt
thematically, since signing for worse odds is more a gambler's trade; it is one
line to move to Vesh if he prefers.

### v2.82: dying no longer undoes the starter fix, and the whole first-session loop is walked

The cold-start walk reached its last stretch, death, the outcome screen, and the
second deploy, and the stretch paid for itself twice over.

FIRST, THE WALK ITSELF, driven through the REAL machinery for the first time: the
main loop is now steppable from the fixture with synthetic timestamps (__loop),
because deathBeat and the whole live-raid frame path exist only inside loop() and
a hidden pane never fires its rAF. With it, the full sequence ran end to end: no
medical, downed, dying, the 1.5 second death beat, KILLED IN ACTION with the
killer named and the distance from extraction, a feeling tag clicked through the
real button, a note typed into the real field, the confirm button pressed, the
run landing in P.log with outcome dead, the tag, the note and ver 2.81 stamped,
the raid state cleared, and a second deploy from the lift working immediately.
The earlier attempt at this walk failed because the bot logic self-revived with
the probe's own bandages, which was the probe's error and is noted as such.

SECOND, THE BUG THE WALK CAUGHT: v2.80 SURVIVED EXACTLY ONE DEATH. The death
ledger has a fallback, "if the gun you had equipped was lost with your body, fall
back to another owned gun", and it tested P.weapons.indexOf(P.equipped). But
'fists' is deliberately never in P.weapons, it is the value that MEANS "no
deliberate equip, roll me a starter", so every death flipped equipped to the
armoury pistol and brought the two-identical-pistols kit back from the second
raid onward. A fresh player dies in their first raid more often than not, so
v2.80's fix was, for most of its audience, one raid long. 'fists' is now exempt
from the fallback.

Verified from a wiped profile: first deploy rolls an issued Kettle, death with
the full outcome flow, equipped reads fists after the ledger, second deploy rolls
an issued Ferro. And the v2.80 variety caveat closes in passing: three distinct
starters, Ferro, Hullcracker and Kettle, have now been rolled across the walks.
Parsecheck PASS at v2.82, all four maps drive and draw clean with 10 of 10
entities moving, hub clean. The itch zip is rebuilt at v2.82.

Not verified: the extraction side of the same ledger, which re-equips the first
carried gun on a successful extract; that is deliberate behaviour with its own
comment, banking a field find and making it yours, and it correctly never sees
'fists' because it only fires when a real gun was carried out. Also not
verified: autoExport stayed disabled through the probe to keep fixture runs out
of exports/, so the outcome flow's export leg ran only to its P.log write; the
export itself is the most exercised path in the project and was not re-proven
here.

### v2.83: the world breaks

His note, 2026-08-25: "environment should be destructible -- walls, cars, etc --
everything should have HP and get destroyed if it takes enough damage." Also this
build: the extract ending of the first-session walk closed green, items banked to
the stash, the log stamped, the hub returned, so the whole friend-facing loop was
walked before the world learned to break.

THE ARCHITECTURE MADE IT THE DOOR-UNLOCK OPERATION, GENERALISED. Movement reads
map.walls, sight and bullets read map.segs, routing reads the nav grid; the keyed
door already removed a wall mid-raid and rebuilt what derives from it. So a wall
with zero HP dies the way an opened door does: out of the array, geometry
rebuilt, debris on the floor. HP is stamped lazily on first damage and scales by
material: glass 25, furniture 60, a tree 120, a wreck or ruin 150, a building
wall 320, authored terrain 700. Bullets damage the wall they die on, WHOEVER
fired them, machines included, which is half of what makes cover a resource now.
A frag charge deals 200 at its centre falling to 40 at the edge, so one charge
breaks glass, furniture, wrecks and trees outright and leaves a building wall
more than half gone; two charges open a building, which is what "takes enough
damage" means for masonry. Never destructible: the world border, locked-room
shells, keyed doors, ledges. CFG.destruct is the dial, default on because this
is his design request, and it joins the v2.63 fingerprint as 'des'.

GLASS NEEDED ITS OWN PHYSICS, found when the first probe could not shoot a
window out: a window has no segments by design since v2.51, so rounds pass
through and the wall-impact branch can never touch it. Glass was briefly the one
material bullets could not break. A round crossing a pane now damages it in
transit and KEEPS FLYING, once per pane per round, so the third SMG round breaks
the window and the hole becomes a doorway.

THE SHARED REBUILD FIXED TWO LATENT DOOR BUGS IN PASSING. The keyed door's
inline rebuild forgot the window skip, so opening any locked door RE-SEALED
every window on the map into a solid; and it never rebuilt the ray or wall
grids, so bullets kept dying on the ghost of the removed door. Both paths now
run rebuildGeometry(), one function, one truth.

Verified with real bullets on live raids: furniture dead in six rounds with the
wall count down one and the telemetry counting it; line of sight OPEN through
the hole; the border surviving forty rounds of 50; a locked-room shell likewise;
a 320-HP building wall down in seven rounds of 50; destruct 0 refusing all of
it; a window dead in exactly three SMG rounds with its hole walkable; and after
all the carnage, 120 frames of raid driving and drawing clean. Parsecheck PASS
at v2.83, all four maps and the hub drive and draw clean, WHATSNEW updated with
its version bumped, the itch zip rebuilt at v2.83.

Not verified: balance, and this one is LARGE. Destruction changes cover, which
v2.43 proved is where raids are decided; the 320-seed A/B on destruct exists as
one __pairedBg call and has not been run, and until it has, the extract-rate
consequences of a breakable world are unknown. Also not verified: nav rebuild
cost under sustained demolition, one buildNav per destroyed wall, fine for
gunfire cadence and untested against a player who chains charges. Also: one
probed window's hole still ejected a body because a coincident twin wall run
stood behind the pane, which is correct behaviour where real geometry remains,
and cosmetically a destroyed wall's baked contact shadow may linger on the
ground until the next raid.

### v2.84: the breakable world is balance-neutral, measured before anyone had to wonder

No game logic changed. v2.83 shipped destruction with its balance consequences
named as the largest open question, cover decides raids per the v2.43 thread and
destruction changes cover, so the 320-seed paired A/B ran immediately rather
than someday. destruct 0 against destruct 1, BURIED CITY, pinned via
__pinDefaults, rows kept:

    intact world 17.5% against breakable world 17.8%
    discordant 33 of 320: 16 flip toward intact, 17 toward breakable
    z 0, exact two-sided p = 1.0

    killers      intact   breakable
    sentry         145       136
    crawler         86        91
    raider          20        18
    warden           7        10
    extracted       56        57

AS NULL AS A NULL GETS, and the killer table says why in one line: nothing about
WHO kills the bot changes, because the bot does not demolish on purpose. It has
no charge-against-wall behaviour and no reason to shoot masonry, so the world
breaks only incidentally under stray fire, and incidental breakage at these HP
values is not enough to move outcomes. Ten percent of raids still flip, the
by-now-familiar signature of a texture feature: the raid is DIFFERENT, walls
fall and holes open and fights reroute, and the aggregate does not care.

THE PATTERN THIS CYCLE IS NOW FOUR FOR FOUR. Windows, feuds, crew colours and a
destructible world all measured at or within noise of zero balance cost, while
the one change that touched TIME, the six-second medkit, moved 7.5 points.
Texture is free; time is expensive. That is now the closest thing this project
has to a law.

WORTH SAYING FOR THE PLAYER'S SIDE, because the null is the BOT'S null: he and
his friends have grenades and intent. A player who charges a wall to flank a
camp is doing something the sim never models, so the FEELING of destruction is
entirely unmeasured here, only its passive cost, and the passive cost is zero,
which is exactly what a feature like this wants: all upside surface, no hidden
tax.

Verified: parsecheck PASS at v2.84, all four maps and the hub drive and draw
clean. Measurement build, VER and DESIGN.md only.

Not verified: BURIED CITY only, as every arm this cycle; a map with more
furniture in fire lanes could in principle differ. Also not verified: the
player-intent side named above, which no sim arm can reach and his next raids
will answer by feel.

### v2.85: the shadow tower over every named machine was a font weight

His report: "there's a glitch where each enemy has a large shadow rectangle
above it." Reproduced on the first capture: a name-plate-wide column of panel
dark rising from every named machine past the top of the screen.

FOUND BY INSTRUMENTING THE CANVAS, not by reading. fillRect and fill were
monkey-patched for one frame to log every call whose rectangle covered a pixel
inside the column, with stack traces. One call matched: a fillRect 93 wide and
810 TALL in rgba(6,9,13,.62), the standard text backplate colour, from the
nameplate painter.

THE BUG IS ONE parseFloat. The plate height was computed as
parseFloat(wc.font)*1.35, written when font strings began with their size. Every
TYPE face now leads with a WEIGHT, "600 10px Rubik", so parseFloat returned 600,
the weight, and the backplate drew ceil(600*1.35)=810 pixels tall behind every
plate. The height now comes from the actual px token, and the one other
candidate site was grepped for: this was the only parseFloat(font) in the file.

Verified three ways: the instrumented frame after the fix shows the tallest
backplate at 18 pixels; the same staged scene that showed the towers, sentry and
crawler and raider pulled around the player, now shows compact plates and
nothing above them, tools/shots/glitch_fixed.png against glitch_shadow.png; and
parsecheck PASS at v2.85 with all four maps and the hub driving and drawing
clean, 10 of 10 entities moving. The itch zip is rebuilt at v2.85.

Not verified: when the weights were added to TYPE and therefore how long this
was live; the typography rework predates this session's captures, and none of
the session's own screenshots framed a named machine with headroom above it
until today's, which is why a bug this visible could hide from a capture
workflow that photographs what it stages. His eyes found it in normal play
within a day of playing, which is the argument for his eyes.

### v2.86: the world stops contradicting itself, and the trees-on-roads bug was roads all along

His notes, three in a row: "bushes should only spawn on grass", "same for trees",
"look for other logical inconsistencies like this in the map and resolve them."
An audit hook was built first, __placeAudit, and it put numbers on the mess
before anything was fixed:

    culled, per raid on the audit seeds
                     DAM   BURIED   COLD   QUARRY
    bushes in water   68      0       2      13
    bushes on roads   12     27      16      16
    trees in water     6      0       0       0
    wrecks in water   34      0       5      14
    lamps in water    15      0       0       9

A THIRD OF DAM'S CARS WERE PARKED IN THE RESERVOIR, sixty-eight bushes grew in
it, and fifteen electric lamp posts stood lit in open water. Wrecks had no water
test at all; the bush scatter tested walls and buildings but never water or
tarmac.

THE TREES-ON-ROADS BUG WAS ROADS-UNDER-TREES. Trees only ever spawn inside
authored grove rects, and the bake's road layer was SUPPOSED to skip groves, but
it skipped them by grid cell and authored maps push woods with r:-1,c:-1, so the
skip never fired once on any live map and tarmac ran straight through every
wood. The road runs are now computed once in makeMap with grove rects in the
blocklist, so roads DETOUR woods, stored on the map, and the bake draws that
stored list: one list, so the picture and the logic cannot disagree. The
tree-on-road cull that was written alongside has caught zero trees since,
because the cause is gone.

EVERYTHING ELSE IS A CULL, NOT A RETRY, and that is stream discipline: filters
run after every placement roll has been drawn, so they consume no rr() and every
seeded comparison in the back catalogue is untouched. Bushes in water or on
tarmac go, trees in water go, wrecks in water go, and lamps in water go at raid
build with the same pattern. The building-floor exemption holds throughout: a
lamp inside the dry powerhouse that the reservoir rect overlaps stays lit, which
the audit initially flagged until the audit was taught the game's own inWaterMap
definition of wet.

KEPT, DELIBERATELY: containers in water, 31 on DAM and 12 on QUARRY on the audit
seeds. The flooded shelf is DAM's authored identity, v2.66 measured the wading
economy built on it, and a suitcase in a flood reads as flotsam in a way a lit
lamp post never can.

Verified: parsecheck PASS at v2.86, all four maps and the hub drive and draw
clean with 10 of 10 entities moving; the audit reads zero in every culled
category on all four maps; and the reservoir seen in pixels,
tools/shots/dam_reservoir.png, water with buildings and flotsam and nothing
absurd in it. The itch zip is rebuilt at v2.86.

Not verified: balance. DAM lost 80 bushes and 34 wrecks, real concealment and
real cover, most of it in water where the wading routes ran; the 320-seed
destruct-style paired run on this build against v2.85 has not been run, and DAM
is the map to run it on if the extract rate looks different in his hands. Also
not verified: the road detours change where tarmac lies on all four maps, which
is pure bake visuals with no collision or sight consequence, but the LOOK of the
new detours has only been sampled around one reservoir and one grove.

### v2.87: every item has a face, and the inventory is a grid of them

His notes, three in one afternoon: items should have "good images/graphics...
so that it is visually compelling" wherever the player meets them, and the
inventory "should move to like a placement/backpack system like arc raiders or
diablo... or minecraft, but the backpack should be unlimited". One build,
because the second note is what the first one is FOR.

THE ICON SYSTEM. The charter forbids asset files, so the pictures are drawn:
one procedural renderer, drawItemIcon, that every surface calls, so a Frag
Charge in the bag, on the hotbar and later in a shop row is recognisably one
object. Every item family has its own painter: scrap is torn plate, wire is a
coil, a cell is a battery with terminals and charge bars, a board is a PCB with
traces and pins, an optic is a lens with a highlight, a core is a radial glow in
a frame, a titan is an ingot, ledgers and codices are books, the blackbox has
its orange stripe, medical is a roll and a crossed case, the plate is a bolted
slab, the throwables are a canister with a wisp, a beacon with signal arcs and
a levered sphere with a crosshatch, keys are keys, meat is a drumstick, and
anything unknown falls back to a tinted tile so a future item is never
invisible. Guns get their own renderer, gunIcon: twelve side profiles built
from each weapon's OWN stats, barrel length from range, a drum for the LMG, a
long stick magazine for the SMG family, a pump for the scatterguns, a scope
block with a glass glint for the optics, so the icon set stays honest as the
table changes.

THE GRID. TAB now opens tiles, not a list: five columns, unlimited depth with a
window that follows the selection, identical items stacking with a count badge,
rarity as the tile's border colour, the kept-on-death diamond on protected
stacks, and the selected stack spelled out underneath with its per-unit value.
The equipped weapon header draws its portrait beside its stats. Every verb
moved with it: arrows walk the grid in two dimensions, Z drops ONE item from
the selected stack, 1 and 2 equip a selected gun to hand or back, and dragging
a tile to the hotbar works exactly as v2.50 built it, with the dragged icon
under the cursor instead of a coloured square.

THE HOTBAR shows portraits too: the actual gun in each gun slot, the actual
throwable, the best heal you are carrying, the plate, the crowbar. The old
four-glyph set survives only as a fallback for a slot with no icon key.

Verified in pixels and by verb. The staged bag with one of everything,
tools/shots/inv_grid.png, shows thirty-one items as four windowed rows of
distinct, readable tiles. Functionally, driven through the real input paths:
Z on a three-scrap stack leaves two; ArrowRight moves one stack and ArrowDown
moves five; a medkit tile dragged onto hotbar slot five assigns it with its
icon riding the slot; Digit1 on the rifle stack puts the Auto Rifle in hand.
Parsecheck PASS at v2.87, all four maps and the hub drive and draw clean with
10 of 10 entities moving. WHATSNEW updated and bumped; the itch zip is rebuilt
at v2.87.

Not verified: the shops, the stash, the armoury and the peddler still show
text, which is the second half of his first note; the icon system was built to
serve them (a dataURL cache over drawItemIcon drops into the DOM renderers) and
that is the next build. Also not verified: icon legibility at his font scale
and monitor, same caveat as every visual; the tile and icon sizes ride LH() so
they scale with his text setting, but eyes beat arithmetic. Also: gamepad bag
navigation still speaks list, DPAD up/down only; the grid needs left/right
wired for pad, one line each, queued with the shop pass.

### v2.88: the shops got faces too, finishing the item-graphics note

The second half of "any time the player is interacting with inventory, gun
selection, shops, etc." v2.87 built the renderer and the inventory; this build
carries the same pictures into every remaining surface.

THE BRIDGE TO THE DOM IS A CACHE. The shop, workshop, stash, armoury, gambler
and dev crate are HTML modals, not canvas, so itemIconURL renders each icon once
to an offscreen canvas, caches the dataURL by key and size, and iconImg drops it
into a row as an ordinary img. The cache is a few dozen 26 pixel sprites,
computed lazily, never invalidated, because the painters are pure functions of
the item table.

WHERE THE FACES NOW ARE. Holt's shop: every row, with two pseudo-keys invented
for the goods that are not ITEMS, rigs draw as a vest that thickens with its
tier and the backpack draws as a pack. The workshop: repairs lead with the
worn gun's own silhouette, recipes lead with the face of what they MAKE, so
"Armor Plate from 2 comp and a board" reads at a glance as a plate. The stash:
the three-pixel colour swatch is retired for the item's portrait. The armoury:
each owned gun's silhouette beside its name, the same picture the hotbar shows
when you carry it. Vesh's log and the dev crate list: inline icons in their
string rows. And the Peddler's canvas panel, met mid-raid: his stock now shows
the key, the box and the plate beside their prices.

Verified through the real stations rather than by calling renderers: the trader,
stash, gambler and dev box were each walked to and opened with their actual
keys, and the DOM counted 16 icon images in the shop, 7 in the workshop, 10 in
the crate and 5 in the stash; the gambler read zero on an empty log, which is
correct, and 3 once the log had entries. The Peddler's panel was captured in
pixels, tools/shots/peddler_icons.png, key and ammo box and plate all present.
Parsecheck PASS at v2.88, all four maps and the hub drive and draw clean with
10 of 10 entities moving. The whatsnew line now says icons are everywhere, and
the itch zip is rebuilt at v2.88.

Not verified: the merc bench, which still shows text, deliberately: mercenaries
are PEOPLE, and a person deserves a portrait system rather than an item icon,
which is authorship worth its own decision. Also not verified: DOM icon
appearance at his zoom and text scale; the imgs are sized in CSS pixels and do
not ride LH(), which is fine at 100 percent zoom and untested elsewhere. Also
the standing caveat: legibility is judged by his eyes, not my geometry.

### v2.89: the placement culls get a dial, so their cost can be measured

No behaviour changed at the shipped defaults. v2.86 removed a great deal of the
world: on DAM alone, 54 bushes and 35 wrecks and 15 lamp posts that were standing
in the reservoir, plus 20 bushes on tarmac. Its own Not verified line named the
risk plainly, that bushes are concealment and wrecks are cover and v2.43
established cover is where raids are decided, and that the paired run had not
been done. This build makes that run possible.

placeCull is the dial. It gates the makeMap culls and the raid-time lamp cull,
and it is exactly the kind of dial this project prefers: the filters consume no
rr(), so gating them cannot shift a single PRNG stream, which means placeCull 0
reproduces the pre-v2.86 world on the SAME seed, misplaced props and all. Both
arms therefore run in one build against identical raids, which is the standard
this file has held since v2.42.

Verified on one DAM seed, 9800, driven both ways: with the dial off the map
carries 240 bushes of which 54 stand in water and 35 wrecks stand in water, and
the cull log is empty; with it on the log records 54 bushes and 6 trees and 35
wrecks and 20 road bushes removed, and 166 bushes remain, none of them wet and
none on tarmac. Parsecheck PASS at v2.89, all four maps and the hub drive and
draw clean with 10 of 10 entities moving. The dial joins the v2.63 fingerprint
as 'cull' and the v2.67 pin baseline, so no future batch can run it dirty by
accident.

Not verified: the answer. The 320-seed paired run on DAM, placeCull 0 against 1,
is in flight as this entry is written and its result belongs to the next build.
DAM is the right map for it because DAM lost the most, and if the extract rate
moves anywhere it moves there. Also not verified: the other three maps, which
lost far less and are not worth 320 seeds each unless DAM shows something.

### v2.90: the hiring bench gets faces, and a note of his turns out to be already fixed

Two things, plus a mistake of mine.

THE CHECK THAT FOUND NOTHING, recorded because a clean sweep is information. His
run #8 note reads "i should not be able to see the red attack views of enemies
unless i am looking at them via line of sight, e.g. fog of war should block it."
Checked against the current code before touching anything: the sentry cone loop
carries `if(!sc.seen) continue;` with his note quoted above it, so it was fixed
in a later build and re-fixing it would have been the exact waste the watchdog
warns about. Nothing to do.

THE BENCH. v2.88 finished his item-graphics note and left one surface text-only
on purpose, saying a mercenary is a PERSON and deserves a portrait system rather
than an item icon. This is that system. Every identity now has a bust drawn from
its own coat colour, with features chosen by a stable hash of its id so the man
you hired last week looks the same today: a visor, a cap, a hood or a cropped
head with a scar, over one of five skin tones, with a collar and a strap so the
coat reads as kit. Ten identities, ten genuinely distinct faces, seen in
tools/shots/merc_portraits.png.

The row says more than a price now. Underneath each tag sits your history with
that man, "you killed him 2x", "owes you one", "died on your job", or "no
history", because the rivalry ledger is what decides whether he will work for
you at all and the bench used to render that as an unexplained "will not work
for you".

MY MISTAKE, OWNED: the 320-seed DAM cull measurement was running in the fixture
page when I navigated that same tab to parsecheck, which destroyed it at 152 of
320. Background batches and page navigation cannot share a tab; the batch is
restarted after this build's verification rather than before it, which is the
ordering this session should have been using all along.

Verified: parsecheck PASS at v2.90, all four maps and the hub drive and draw
clean with 10 of 10 entities moving, and the bench opened through its real
station key at Holt, ten rows, ten portrait images, ten DISTINCT image sources,
which is the check that the hash actually varies rather than drawing one face
ten times. The itch zip is rebuilt at v2.90.

Not verified: whether the faces read at 30 pixels on his monitor, the standing
caveat on everything visual. Also not verified: the portraits are bench-only;
the raider you meet in the FIELD still draws as the generic operator sprite in
his coat colour, so hiring a man and then seeing him is not yet a recognition
moment. That is a bigger piece of work and worth its own decision.

### v2.91: healing was latching the F key, and the inventory had no cursor to drag with

Three of his notes in one build, two of them my own defects.

THE HEAL, WHICH HE CALLED GLITCHY AND THEN PINNED PRECISELY: "bandage glitch
happens when i try to use 2 in a row". Two faults sat behind that sentence.

  ONE, THE LATCH, and this is the one that earns the word. The hotbar's heal
  slot called raidKey('KeyF'), and raidKey's FIRST LINE is keys[code]=true.
  Nothing releases it, because a keyup only ever arrives from a real key. So
  healing from the hotbar latched KeyF on permanently; the live handler reads
  `if(keys['KeyF']&&!p.healLock)` and clears healLock only on `!keys['KeyF']`,
  so healLock latched too and THE F KEY WAS DEAD for the rest of the raid. Same
  family as the latched map key v0.98 fixed, reintroduced by v2.45 wiring the
  trigger to the hotbar and reaching for a synthesised keypress to do it.

  TWO, THE GUARD, which is v2.46's debt. The check was p.hp<p.maxhp, correct
  before heal-over-time and wrong after it: health now arrives over seconds, so
  a second press tested health that had not risen yet and could burn an item
  into a queue with no room for it. The guard counts what is already inbound.

Both are gone, and no path synthesises a keypress any more: the key and the slot
and the assigned slot all call one useMedical verb.

THE CURSOR, his note: "when i pull up my inventory, the mouse should come up so i
can use it to view inventory items and drag them down onto the hotbar." My gap
from v2.50. The canvas sets cursor:none because the reticle IS the cursor, and
the reticle is deliberately hidden while the bag is open, so the drag system
shipped with nothing on screen to drag with. The OS arrow is restored for
exactly that window, which is also the right instrument, a crosshair aims and an
arrow points, and the hub always carries one now too. Written only on change,
driven from the render, so every path that closes the bag puts it back.

THE LOOT, his standing complaint since run #1: "looting feels so uninspired, how
can we make it more interesting???", which the recorder's own reading of his
deaths ends by seconding, "Fix the looting phase first." The payoff for opening a
container was a line of text. Every found item now rises out of the crate with
its own portrait beside its name, using the icon set v2.87 built, plate widened
to hold it. tools/shots/loot_labels.png shows a five-item find.

Verified by driving his exact case. Two bandages at 40 health: first press
queues 28 with one left in the bag, second press queues 56 with none left, and
it settles at 96 with an empty queue, so both were used and nothing was wasted.
The latch: healing from the hotbar slot leaves keys.KeyF false and healLock
false, and the F key still works afterwards, consuming the second bandage.
Cursor: none in a raid, default with the bag open, none again on close, none
while downed, default in the hub. Loot labels carry their item key and draw
clean. Parsecheck PASS at v2.91, all four maps and the hub drive and draw clean.
The itch zip is rebuilt at v2.91.

Not verified: whether two bandages SHOULD both be spendable when the second
partly overflows. The guard refuses only when the inbound total already fills
you, so topping up stays possible and stacking past full does not; a stricter
rule would refuse any partial overflow and would annoy anyone trying to top off
before a fight. Also not verified: the loot label plate widens by a fixed 15
pixels for its icon, which is right at the current text scale and untested at
his largest.

### Which settings touch enemies, settled (v0.69 tick, no code change)
The v0.68 mistake was assuming a setting was the player's when it was shared. Rather than fix the one case and move on, every tunable was traced to where it is actually read, so the class is closed.

- **Player only, verified by measurement not by reading:** `coneDeg` and `viewFar`. The same three machines were profiled while both were swung from their floor to their ceiling, and machine detection did not move a unit: sentry reach 340, crawler 26, raider 302 in all three states. They are read only by the player's visibility polygon, the fog gradient, and as the default in `canSee` that only player calls fall through to. Also player only by inspection: `ambient` now, `pSpeed`, `eDmg` (damage he takes), `regenDelay`, `regenSec`, `downTime`, `safeSlots`.
- **Enemy only:** `eHp`, and `eAmbient` as of v0.69.
- **Genuinely shared, and correctly so:** `noiseMult`. It scales every noise radius in `ping`, his own footsteps as well as every machine's. That is coherent as a "how loud is the world" control and no claim has ever been made otherwise, but it is the one remaining setting where changing it for one side changes it for both.

So the v0.69 correction was complete: awareness was the only leak. One process note, since the same trap caught me twice in this tick: creating an enemy to measure it gives a **randomly armed** raider each time, so any before-and-after comparison must build the subject once and re-measure that same object.






























### v2.92: the gun kept firing while the hand was full of something else

Two of his notes, one root. "gun is shooting while i'm trying to heal" and "lower
right corner still shows gun name and ammo info even when i switch to throwables,
heals etc" are the same fault seen from two sides: the hotbar selection was
authoritative for what you USED and advisory for everything else, so the gun code
and the HUD both went on reading p.wep regardless.

FIRING. v2.45 added a fall-through so an empty consumable slot would not swallow
the trigger. The condition was !hotGun || !(HSC.count>0), which reads "fire the
gun if the held thing is a gun OR the held stack is empty". The moment a stack hit
zero mid-hold, which is exactly what the last bandage in a stack does, the held
item became empty and an auto weapon opened up on the spot he was standing in. The
fall-through is gone. When the last of a stack is consumed the selection now falls
back to slot 0 explicitly, which is the behaviour the fall-through was groping for
without firing a magazine on the way.

READOUT. The bottom right block printed p.wep.name, the magazine and the jam and
melee states unconditionally, because it predates the hotbar entirely. It now asks
the hotbar what is in hand: a gun or tool prints the weapon block as before, and
anything else prints that item's name and how many of it you are holding. Nothing
about the gun is shown while the gun is not in your hands, which is the whole of
his complaint.

THE DEV CRATE, his note "i don't understand how to move stuff from the dev box to
my inventory". It was a single list of buttons that added an item and said nothing
back. It is now two panels side by side, the kit on the left and your stash on the
right, with HTML5 drag and drop between them and Take and Bin buttons as the
fallback, because a drag that fails silently is worse than a button.

Verified: parsecheck PASS at v2.92, all four maps and the hub drive and draw with
drawErr null. Driven test: holding fire with a two-bandage stack selected spends 0
rounds across the whole heal, ends with an empty bag and the selection back on slot
0, and the gun never fires. Crate panel renders 12 kit rows, 12 take buttons, 12
draggable rows, and a take moves the row into the stash panel.
Not verified: the actual mouse-drag gesture in the crate, which cannot be
synthesised in the fixture; the Take and Bin buttons are the tested path and the
drag shares their handlers.

### v2.93: a fleeing raider announced it once a frame, and no shop said what you were holding

THE FLEEING ANNOUNCEMENT, his note "when i fought a raider and when they started
running it said they were running MANY times". Three separate code paths were
fighting over one raider's state. Dropping below 30 percent health set the extract
state and printed IS RUNNING, with no latch, so the label reprinted on every frame
the condition still held. Worse, both bullet-hit handlers and the sight check
unconditionally forced the chase state, so a man who was running was dragged back
into the fight by the very shots chasing him, then dropped below the threshold
again and re-announced. Four sites fixed: the announcement latches on e.fled, and a
raider already extracting takes alertness from hits and from being seen but is
never put back into chase. A raider who has decided to leave now actually leaves.

WALLET LINES, his notes "requisition -- it doesn't show how much money i have so
that's annoying" and "same problem for vesh". Four surfaces took his money without
ever printing the balance: the gamble table, the workshop, the merc bench and the
requisition shop. One walletLine helper now writes "You hold Nc" into all of them,
and the shop's existing rep line carries the credits alongside it.

Verified: parsecheck PASS at v2.93, all four maps and the hub drive and draw with
drawErr null. Driven test: eight consecutive bullet hits on a fleeing raider leave
it extracting all eight times and print IS RUNNING exactly once. All four wallet
lines read the live credit total.
Not verified: nothing outstanding on this one.

### v2.94: the legend was eating the screen, the digits were locked out, and a keyed door looked like a wall

Four of his notes, all the same shape: the game knew something and was not saying
it.

THE LEGEND, "update the key legend, make it smaller if possible". It was a 480px
tall panel down the left edge, on by default, listing 18 bindings plus ten gear
rules plus the six-colour sound key. H now cycles three states instead of two.
COMPACT is the new default: two columns, twelve bindings, micro type, roughly a
fifth of the area. One more press gives the full reference exactly as it was, one
more turns it off. Nothing was deleted, it is just no longer always on screen.

THE MESSAGES, "i see that the game is giving me messages in the upper left corner
but I can't really read them bc it is blocked by the key legend". They were drawn
at 16,26. The legend panel starts at 14. Every message the game has ever written
was printed underneath it. The message line moved to top centre on its own plate,
below the compass, which is the one column that is empty in every frame and where
the eye already is because the raid timer lives there.

THE DIGITS, "player should be able to switch which item is equipped by using 1-9
keys even if inventory is open". The handler was explicitly guarded with a
not-bagOpen test, and the guard was correct at the time: v1.91 had given 1 and 2 a
second meaning inside the bag, equipping the selected gun to hand or back, and this
handler runs first and swallows every digit. Two meanings for one key is the actual
bug, so the second meaning moved. ENTER equips the selected bag gun to hand,
SHIFT+ENTER to the back, and 1 through 9 now mean exactly one thing everywhere in
the game.

KEYED DOORS, "if a door needs a key, the game should give a clear indication of
same". A locked room is five shell walls plus one wall carrying a door id, drawn in
the same colours as the shell, so a locked room was a featureless box and the only
tell was a prompt that appears once you are already standing on it. The door is now
its own object: a frame, two recessed panels and a lock plate, with a padlock tag
floating on the approach side. Both are GREEN when the matching key is in your bag
and AMBER when it is not, so "can I open that yet" is answered from across the map.
The near-door prompt also names the key now, so a Sealed Cellar Key found in a
footlocker an hour later is recognisable as the answer to a door you walked away
from.

WINDOWS, "need clearer indication of windows". Glass was one 30 percent wash of
blue-grey over the wall colour with a single mullion, which at raid distance is a
slightly lighter patch of wall. A window is a tactical fact here, it is the one
hole you can shoot through but not walk through, so it now carries a dark frame on
all four sides, brighter glass, a light streak, a cross of muntins and a lit sill.

His question "are destructible environments doable?" needed no build: they shipped
at v2.83 and are on by default. Walls, wrecks, trees, furniture and glass all carry
HP scaled by material, the rect is removed and rebuildGeometry re-derives segments,
nav and both grids. The world border, locked-room shells, keyed doors and ledges
are deliberately exempt, the middle two because the gate is the point. v2.84
measured it balance-neutral, p=1.0 at n=320.

Verified: parsecheck PASS at v2.94, all four maps and the hub drive and draw with
drawErr null in all three legend states. Driven test: with the bag OPEN, Digit3
selects slot 2 and Digit1 selects slot 0; with it closed Digit5 selects slot 4;
ENTER moves a bag gun into the hand and out of the bag while Digit2 moves only the
selection and leaves bag and weapon untouched; H cycles 1 to 2 to 0. Pixel captures
at 1280x718 confirm the compact panel, the centred message plate, the door slab
with a green plate while carrying its key, and framed window panes on a building
face. Door and window counts per map: 2 doors and 54 to 69 windows on each of the
four.
Not verified: no balance measurement was run. Nothing in this build touches a
random draw, an entity decision or a timing constant; it is HUD layout, one input
guard and two draw routines, so the seeded stream is unchanged by construction
rather than by measurement.

### v2.95: four maps were built and he has been playing one of them for 25 runs

His note: "if thre are multiple maps, i think i always play the same one, and i
don't know how to switch them -- gotta let me choose somehow -- maybe we need
another thing in the undercroft called settings?"

He is right, and checking it against the current code makes it worse rather than
better. The switch was not missing. It has existed for a long time as a 9.5px
button called "Map: DAM BATTLEGROUNDS", parked in the dev half of the Operator
Terminal between the sim progress line and the roadmap, and clicking it cycled
blind to the next index. So the feature was there, it was simply hidden behind the
one panel he has separately told me has "way too much sthit going on", and it named
no sector until after you had already committed to changing to it. His flight
recorder confirms the outcome: 25 runs, every one of them on index 0.

THE FIX IS PLACEMENT, NOT FUNCTIONALITY. The choice now rides on the DEPLOY LIFT,
which is the one station in the Undercroft that every raid passes through. E still
deploys, with no extra step and no new friction, and R opens the sector board. The
lift's own prompt line states the destination: "[E] deploy [R] sector > COLD
STORAGE". That line is generated from a FUNCTION rather than a string, because the
hub geometry is built once and the sector can change while you are standing in it,
which a baked string would not survive.

THE BOARD SAYS WHAT THE SECTORS ARE. A picker that lists four names is barely
better than a blind cycle, because "there are four maps" was never the missing
information; a reason to prefer one was. Each sector carries a character line
written from the measurements rather than from flavour, plus its size, its named
zone count, its keyed room count, and its container density as a percentage against
the average, drawn live from MAPCONT. Seal progress appears when you have cut any,
and a sector holding your body says so, because that is the single most likely
reason to deliberately pick a map you would otherwise skip. The current sector is
marked DEPLOYING HERE, so the state is never ambiguous.

SETTINGS, as he asked, but not as a sixth station. He asked at v2.81 for FEWER
bodies in the Undercroft and was right, so adding one back to hold two switches
would be undoing his own note. The dev box already carries the things that are
switches rather than content, so settings is its third key: T. It holds text size
and auto-export, which were the other two buttons buried beside the map button, and
states the two controls that are easy to lose, H for the legend and BACKSPACE for
the cursor. The Operator Terminal buttons still work and still sync; this is a
second door onto the same flags, not a move.

The old map button is not deleted either, it just stops cycling blind and opens the
same board.

Verified: parsecheck PASS at v2.95, all four maps and the hub drive and draw with
drawErr null. Driven through the DOM, which is the path a player takes: the button
opens the board, the board renders 4 rows named DAM BATTLEGROUNDS, BURIED CITY,
COLD STORAGE and THE QUARRY, exactly one carries DEPLOYING HERE, clicking row 2
moves the mark, sets mapIx to 2, updates the terminal button to "Map: COLD STORAGE"
and persists 2 into salvagerun:profile under the unchanged key. Facts row for COLD
STORAGE reads "42 by 34 hectares, 5 named zones, 2 keyed rooms, +9% loot". The lift
sub line reads "[E] deploy [R] sector > COLD STORAGE" and its acts are KeyE and
KeyR; the dev box reads "[E] dev crate [R] tuning [T] settings". Both settings
toggles move and write back, text size 100 to 125 percent and auto-export OFF to
ON. Hub frame captured at 1280x718 with the lift line legible.
Not verified: no balance measurement, and none is meaningful here. Nothing in this
build touches a random draw, an entity decision or a timing constant. One caveat
worth stating plainly: this build makes it easy for him to leave DAM BATTLEGROUNDS
for the first time, so the next flight recorder may show an extract rate that moved
for reasons of map character rather than of balance. The per-map spread has never
been measured against his own play, only against the bot, so treat the first
cross-sector runs as uncontrolled.


### v2.96: the fake terrain goes, raiders arrive already hurt, and the peddler stops eating the search key

Three of his notes. Two are removals and one is the first balance change in several
builds, so it carries a measurement.

THE GROUND NOISE, "ranbdom circles and squiggles on the map -- i guess they are
supposed to suggest altitude changes or shadows or something -- but they look like
shit, get rid of em". Two passes in bakeGround, both deleted. The first drew 180
random four segment polylines per unit area, every vertex jittered up to 32 units
in any direction, stroked black at up to 26 percent alpha. There is no charitable
reading of that: they are random squiggles. The second drew 60 dark ellipses per
unit area at up to 50 percent black, and those are the "circles" he means. Worse,
they are the fake hills that the SPEC 4.6 comment forty lines above them says were
DELETED. So the comment has been describing a deletion that did not hold, which is
the stale-comment defect this file keeps producing: the note stayed and the code
came back, and nobody reading the note would ever look.

Nothing replaces them and nothing needs to. The floor still carries surface grime,
gravel speckle, grass tufts, road dashes, water ripple, woods turf and a baked
contact shadow at the foot of every wall. Every one of those is information about a
real object in the world. The two that went were noise dressed up as terrain, which
is why they read as altitude that turned out not to be there.

RAIDERS ARRIVE WORN, "other raiders shouldn't always be at full health, right?"
Right, and the game already agreed with him on the other half of this exact idea
without ever finishing the thought: mkRaider has always set r.armor to 70 percent
of the rig cap, on the reasoning that a man you meet deep in a raid has been shot
at. His HEALTH was the one number still issued at a flat 100 percent to every
raider on every map. A third of them stay fresh, on the fiction that they dropped
in around when you did; the rest carry between 8 and 50 percent damage.

The floor is deliberate and it is not cosmetic. v2.93 makes a raider run once he
drops below 30 percent, so a spawn roll allowed to cross that line would put men on
the map who flee from their first sight of you, which reads as broken rather than
as wounded. Measured at n=640 raiders: with the dial off, 100 percent of raiders
spawn at exactly full. With it on, health runs 50 to 100 percent, mean 81, 34
percent still fresh, and zero below 50, so nothing spawns anywhere near the flee
line. Both rolls are drawn UNCONDITIONALLY, the v2.09 jam rule repeated for crews
at v2.49 and windows at v2.83, so the two arms are the same raid with and without
wear rather than two different raids.

THE PEDDLER WAS EATING THE SEARCH KEY, "i cant search a casher right next to the
peddler". He is right, and it was unconditional rather than intermittent. The stall
claims E across a 74 unit radius and opens on the press, and the line immediately
after it returns out of the entire interaction tick, so the container scan forty
lines below never ran while you stood anywhere near him. Any crate, cache or body
inside that radius was unsearchable for the whole raid. The peddler is deliberately
placed near loot, so this is not a corner case, it is the common case.

The crate takes the key when you are standing on one: 46 units is ON a container
while 74 is merely NEAR the stall. The resolution is self-clearing, which is why it
is the right way round rather than the other. Search the crate, it is marked opened
and skipped from then on, and the next press opens the stall. The reverse rule
would have no exit at all. While a crate is blocking it the stall's own label stops
advertising a key it is not going to get and says "search the crate first" instead.

Verified: parsecheck PASS at v2.96, all four maps and the hub drive and draw with
drawErr null. Driven test for the peddler, through the real main loop rather than
the raw stepper because the interaction tick only runs there: standing 8 units from
an unopened container and 51 units from the peddler, pedBlocked is 1, holding E
starts the container search and leaves the stall closed, the search completes and
marks the container opened, pedBlocked drops to 0 and the next press opens the
stall. Raider wear measured at n=640 spawns per arm as above.

BALANCE: raider wear is neutral, measured. 320 seeds paired on DAM BATTLEGROUNDS index
0, simGreed pinned at 52 in both arms, dial off against dial on in the same build.
Extract rate 14.7 percent with wear off (47 of 320) against 15.9 with it on (51 of
320). Discordant pairs 3 against 7, McNemar exact two sided p=0.34. Mean haul
across all runs 8757 against 8819. The killer table barely moves: sentry 156 to
152, crawler 99 to 100, warden 8 to 8, raider 2 to 1.

AND THE CAVEAT THAT MATTERS MORE THAN THE NUMBER. Look at that killer table again.
Across 640 simulated raids the bot died to a RAIDER three times. Its deaths are
sentries and crawlers, almost entirely. So the sim is a weak instrument for this
particular change: I have measured that making raiders weaker does not move an
outcome that raiders were barely deciding. His own flight recorder says the
opposite about him, with killer:raider on three of his last six deaths, so wear
will be more visible to him than to the bot. The honest reading is "no evidence of
harm at n=320", not "no effect". The dial is CFG.raiderWear if it needs to come
back out.

Not verified: the ground passes were removed on his say-so and on my own reading,
not measured, because there is nothing to measure. bakeGround is skipped entirely
in the sim (ground:sim?null:bakeGround(map)) so removing draws from it cannot move
any simulated number; it does re-roll what a real raid looks like after that point
on a given seed, which is a reshuffle rather than a bias, and no seeded comparison
against an older build survives it.


### v2.97: every name lifted from ARC Raiders is gone, and it was more than the word ARC

His note: "we need to remove all references to ARC raiders -- we shouldn't be
calling anything by the same name, etc. -- guns, enemies, no references to 'ARC'".

He was right to widen it past the string, because the string was the smaller half.
I audited every player-visible name in the file against the shipped vocabulary of
ARC Raiders, cross-checked against published weapon, enemy and map lists rather
than against my own recall, and the collisions were worse than the faction name.

WHAT WAS ACTUALLY LIFTED

Four guns. Ferro, Kettle, Stitcher and Hullcracker are all four real ARC Raiders
weapons, and they sit in ONE contiguous block in WEAPONS, introduced together as
the issued starters. Four verbatim names in four consecutive lines is not
convergent invention, it is a batch import, and it is the single most damaging
thing in the file because these are the guns a new player is handed on their first
deploy. Renamed to TACKER, SPUTTER, CHATTER and SCUTTLE, with the fire behaviour,
stats and sound profiles untouched: a semi-auto sidearm, a short spray gun, a loud
automatic and a close-range breacher, which is what they always were.

Two maps. DAM BATTLEGROUNDS and BURIED CITY are both shipped ARC Raiders map names,
verbatim. Now GREYWATER DAM and SUNKEN QUARTER. The map ids are internal and never
touch a save, so nothing migrates; P.mapIx is an index and P.seals is keyed by that
index, both unaffected.

One enemy. Our SNITCH and their Snitch are the same word for the same idea: a small
machine that spots you and calls in everything else. Ours is now the CRIER, which
is the same job described in our own words. The nameplate, the contract text, the
warning line and the two feeling tags all move with it.

The faction. ARC is the name of the hostile machine faction in ARC Raiders, and it
was ours too, on the caches, the strongbox, three elite items, the seal payoff line,
the Terms and two roadmap entries. It is MERIDIAN now.

One partial. Their Dam Battlegrounds has a POI called Central Spillway and our dam
had a zone called THE SPILLWAY. A spillway is a part of a dam and neither of us
invented the word, but it costs nothing to stop sharing it, so ours is THE OVERFLOW
and its landmark is OVERFLOW BRIDGE.

WHAT I DELIBERATELY DID NOT RENAME, and why, because a rename that goes too far
strips the game of its own identity as surely as one that stops too short:

SENTRY, CRAWLER, WARDEN, LISTENER, STRAY and the PEDDLER are not in their roster.
Their nearest machines are Sentinel and Turret, which are different words, and
sentry is plain English used in hundreds of games. The dam's own vocabulary stays
too. A reservoir, a crest, a turbine hall, a switchyard, a tailrace and a
powerhouse are what a hydroelectric dam physically HAS, none of them appear in
their published POI list, and renaming them would be renaming the English language
rather than removing a lift. Scav Pistol, Compact SMG, Auto Rifle, Marksman Rifle,
Burst Carbine, Riot Scattergun and Support MG are generic descriptors and stay.

One thing I am flagging rather than deciding: their game is ARC Raiders, its
players are called Raiders, and this game is DARK RAIDERS with raider enemies. He
did not ask me to rename the game and I have not. It is his call, and it is worth
one deliberate thought rather than a silent edit.

THE SAVE MIGRATION, which is the only risky part of this build. The gun KEYS were
renamed along with the display names, because leaving ferro and hullcracker in the
source would keep a private record of the lift. Those keys are in his profile:
P.weapons holds owned gun ids, P.equipped holds one, and P.wear is a ledger keyed
by gun id. loadProfile already filters P.weapons down to keys the build recognises,
which means WITHOUT a migration a returning save would have had its owned starters
and their accumulated wear silently deleted, with no error and nothing on screen to
say so. The migration maps all four old keys across all three fields and runs
BEFORE that filter, which is the entire reason it exists.

Verified: parsecheck PASS at v2.97, all four maps and the hub drive and
draw with drawErr null. Zero case-insensitive matches for "arc raiders" remain in
the file and zero genuine ARC tokens; the only survivors of a bare ARC substring
search are the word SEARCH, the canvas arc() call, carcass, hierarchy, archive and
a base64 font blob, which is exactly why this was done with anchored replacements
and never a blanket one. WEAPONS now exposes tacker=Tacker, sputter=Sputter,
chatter=Chatter, scuttle=Scuttle and none of the four old keys resolve. The sector
board lists GREYWATER DAM, SUNKEN QUARTER, COLD STORAGE and THE QUARRY. Nameplates
read CRIER E-97, CRIER N-23, CRIER E-86. Items read Meridian Black Box, Meridian
Reactor Core, Meridian Payroll Ledger. Pixel capture at 1280x718 shows the
MERIDIAN CACHE world label and a held "Fouled Tacker" in the weapon readout.

THE MIGRATION WAS TESTED AGAINST A PLANTED SAVE, not reasoned about. A pre-v2.97
profile was written into storage carrying weapons ["ferro","kettle","pistol"],
equipped "ferro", wear {ferro:1200, hullcracker:340, pistol:50}, 1926 credits, 28
runs, a two item stash and a contract reading "Destroy 2 snitches". After a reload
it came back as weapons ["tacker","sputter","pistol"], equipped "tacker", wear
{pistol:50, tacker:1200, scuttle:340} and "Destroy 2 criers". Note the third wear
entry: hullcracker wear carried to scuttle even though that gun was never in the
owned list, and pistol was left alone. Credits, runs, stash and the unrelated
part-completed sentry contract are untouched.
Not verified: no balance measurement, and none applies. Not one number, roll,
timing constant or decision changed in this build; it is strings and four object
keys. The one risk here was never balance, it was the save migration, and that is
tested above rather than argued for.

Two judgement calls he may want to overturn. First, the internal enemy kind is
still the string 'snitch', wired through some thirty code sites plus CFG.nSnitch
which lives in his SAVED config, so renaming it would have meant a second
migration for zero player-visible gain; what he reads says CRIER everywhere.
Second, the game is called DARK RAIDERS and its human enemies are raiders, while
their game is ARC Raiders and its players are Raiders. He did not ask me to rename
his game and I have not touched it. Both of those are his to decide, and they are
written down here rather than quietly settled.


### v2.98: the stash screen stops being two thirds developer furniture

His note, outstanding since before the sector work: "way too much sthit going on in
the stash, needs to simplify".

He is describing the Operator Terminal, which is the panel he opens more than any
other screen in the game, because it is where his stash and his loadout live. Its
third column was carrying, in one scrolling stack: the flight recorder, four
summary stats, Export for Claude, Run bot sim, an auto-export toggle, a text size
toggle, a map switcher, a sim progress line, the entire roadmap, and a dropdown for
loading older builds of the game. Nine of those thirteen things are instrumentation
I built for myself. He opens that screen to look at loot.

WHAT MOVED. Everything that is instrumentation rather than gameplay now lives
behind one button, "Dev tools and roadmap", in its own panel: the export, the bot
sim and its progress line, the map switcher, the roadmap and the old-build loader.
What stays on the terminal is the flight recorder and the four stats, because those
are him reading his own results, which is the game talking back to him rather than
me talking to myself.

WHAT WAS DELETED OUTRIGHT. The auto-export and text size toggles are gone from the
terminal entirely rather than moved, because v2.95 already gave both of them a home
in Settings under T at the dev box. They were a second set of buttons for the same
two flags, which is worse than clutter: two controls for one state is how the two
drift apart.

HOW IT WAS DONE, and this is the part that kept it safe. Every element KEPT ITS ID
and changed parent. Nothing was recreated, so every existing handler, every
syncAutoEx and syncTextSize and syncMapBtn, and every renderHub write still finds
exactly the node it has always found. The only code change is the two handlers for
the new panel, plus a null guard on the two buttons that no longer exist: those
were assigned at load with a bare getElementById, which throws on null, and a throw
at that point in the file would have taken down every handler declared after it.
That is the failure the guards exist for, not a theoretical one.

Counted before and after: the terminal now presents 9 interactive controls where it
presented 14, and its third panel is a list plus four numbers plus one button.

One thing I did not touch and am flagging instead. The terminal's bottom row still
carries DEPLOY, REQUISITION, WORKSHOP, CONDITIONS and TUNING, which duplicate what
the Undercroft stations already do: Holt carries the shop, the workshop and the
Terms, the lift carries deploy, the dev box carries tuning. That is arguably the
same complaint again. I left it because it is a navigation bar he may well use as a
shortcut rather than content in his way, and quietly removing someone's shortcuts
is a different thing from decluttering a panel. Say the word and it goes.

Verified: parsecheck PASS at v2.98, all four maps and the hub drive and draw with
drawErr null. Driven through the DOM: the Dev tools button opens the panel and the
Close button shuts it; all seven moved elements (exportbtn, simbtn, mapbtn,
roadmap, buildsel, buildgo, simprog) resolve inside #devmodal and NONE of them
resolve inside #hub any more; no id is duplicated anywhere in the file. The
terminal still renders its stash count, log count and all four stat fields without
throwing.
Not verified: no balance measurement, and none applies. This build moves DOM nodes
between parents and adds two click handlers. Nothing in it touches a random draw,
an entity decision, a timing constant or anything the sim can see.


### v2.99: the greed decision finally gets its number, and a one-sided clamp turns up underneath it

Two of the open items I was carrying turned out to be already done, which is worth
saying before the thing that was not. Wrecked cars reading as suitcases from
overhead was rebuilt at v1.64 into a four-wheels-at-the-corners silhouette with a
stepped hood, cabin and boot, and "looting feels so uninspired" was answered at
v1.61 with staged pulls and refined at v2.59. Both were still sitting on the open
list. Checking his notes against the CURRENT code before acting keeps paying for
itself; this is the third and fourth time this cycle.

WHAT WAS ACTUALLY MISSING was the other half of the v1.61 design. Staged pulls
exist so that leaving early is a real choice: items come out worst first, progress
persists on the container, so "one more thing or get out" is the whole raid played
in six seconds. But the information needed to make that choice was never on the
thing you look at while making it. The container's own glow carries best-remaining
as a colour, which is a good ambient cue from across a room and useless when your
eye is pinned to a six pixel progress bar, and that bar was hardcoded amber no
matter what was still in the box.

The bar now takes the colour of the best item still inside and carries a plate
saying how many are left and what the best of them is. It walks down live, because
near.best is already recomputed after every pull. Driven with a planted container
holding two commons, a rare and an elite, the plate reads ELITE at four left, at
three, at two and at one, and only stops when the elite is in your bag. That is
correct rather than a bug: worst-first sorting means the good thing is always last,
so the plate is telling you precisely how much is riding on the next second and a
half of standing still. "1 left ELITE" is the strongest argument the game can make
for staying, and until now it could not make it.

AND THE THING I FOUND UNDERNEATH IT. Driving that test I crashed render2D with
"The radius provided (-83.8152) is negative". The trigger was mine: I fed the
fixture a synthetic timestamp LOWER than the previous one. But the crash exposed
two real defects.

First, the frame clamp was one sided. `Math.min((ts-lastTs)/1000,.05)` bounds dt
from above, so a backgrounded tab returning does not teleport the world, and it
never bounded dt from below at all. A negative dt runs the entire game backwards
for one frame: the raid clock counts up, particles and pings age in reverse, and
anything deriving a radius or an alpha from elapsed-over-lifetime goes negative
with it. requestAnimationFrame is monotonic in real play so this is not something
he can hit today, but it is one Math.max to make a whole class of undebuggable
frame unreachable, and it means the harness cannot manufacture one either.

Second, and this one is not hypothetical: the noise-ping ring computed its radius
straight from pn.t over pn.life and handed it to arc() unchecked. A negative
radius THROWS, and that call sits inside render2D's draw list, so the exception
takes out every single thing queued to be drawn after it. That is the same failure
mode as the y-sort throw this file has already been bitten by once. The radius is
floored now rather than trusted.

Verified: parsecheck PASS at v2.99, all four maps and the hub drive and draw with
drawErr null. Staged-pull test driven through the real main loop against a planted
four-item container: pulls step 4 to 3 to 2 to 1 to done, the bag gains each item,
best-remaining reads elite throughout and drawErr stays null on every sampled
frame. Pixel capture at 1280x718 shows "2 left ELITE" on its plate in elite purple
with the progress bar tinted to match. The dt clamp is verified by the failure that
found it: driving __loop with a timestamp 50 seconds in the past now throws nothing
and leaves drawErr null, where before the fix that exact call crashed the render.
Not verified: no balance measurement, and none applies. This build adds a HUD
readout, floors one radius and clamps one delta. It changes no roll, no entity
decision and no timing constant, and the sim does not draw a HUD at all.


### v3.00: I audited my own sector board and two of its four claims were false

v2.95 put a sector board on the deploy lift and gave each of the four maps a
confident sentence about what it is like to play. I wrote those sentences five
builds ago. This build measured them, and the honest result is that I should not
have written them the way I did.

640 bot raids, 160 per sector, identical seed list on all four, mapIx pinned,
simGreed 52. Against the claims:

  GREYWATER DAM    extract 15.0%   first contact 105s   16.2 cont   median haul 8,035c
  SUNKEN QUARTER   extract 18.8%   first contact  53s   16.7 cont   median haul 7,250c
  COLD STORAGE     extract  4.4%   first contact  85s   14.8 cont   median haul 8,620c
  THE QUARRY       extract 23.1%   first contact  69s   16.9 cont   median haul 8,965c

WHAT HELD UP. The dam is slow: it has the latest first contact in the game by a
wide margin, 105 seconds against 53 on the Sunken Quarter, and the longest raids.
The Sunken Quarter is loud and early exactly as advertised, contact arriving in
about half the time the dam takes. Cold Storage is quiet then lethal and it is not
close: 4.4 percent extract against 15 to 23 everywhere else, with sentries
accounting for 96 of its 153 deaths. The Quarry is open and forgiving, 23.1
percent, the best odds of the four.

WHAT WAS FALSE. Both loot claims. I told him THE QUARRY has "the thinnest loot of
the four" and it actually carries the most containers, the most items and the
highest median haul in the game. I told him the SUNKEN QUARTER has "the most loot
per container" and it returns the least of any sector. One of those is wrong and
the other is exactly backwards, which is worse: he would have picked against his
own interest on both counts.

THE CAUSE, and it is the failure mode this file keeps producing. I derived both
claims from MAPCONT, a per-map container multiplier reading 0.99, 1.26, 1.09, 0.89.
I never checked whether the game uses it. It does not. mapContMul() returns MAPCONT
only when CFG.lootNorm is on, lootNorm defaults to 0, and so that constant has
never once affected a shipped raid. I read a number out of the source, wrote
player-facing copy from it, and shipped. It is the same class as the SPEC 4.6
comment describing a deletion that had been reverted, and as the v2.48 loot voices
that tested green through a path live play never takes: the file says a thing, the
game does another, and nobody looks.

WHAT SHIPS. The four character lines are rewritten to say only what 640 measured
raids support, including the two that now say the opposite of what they said
yesterday. The fabricated "+9% loot" chip is gone from the facts row and is
replaced with the real measurements: bot extract rate, median time to first
contact, containers per raid and median haul. Those are LABELLED as bot numbers on
the board itself and in the comment, because the bot is not him. It dies to
machines far more than he does, so these describe the shape of a sector rather
than his own odds, and saying so on the board is the difference between data and
another confident sentence.

MAPCONT is left in place and left inert. Turning lootNorm on would be a real
balance change across all four maps and it needs its own paired measurement, not a
drive-by while fixing some copy. Flagging it rather than doing it.

Verified: parsecheck PASS at v3.00, all four maps and the hub drive and draw with
drawErr null. The board is read back through the DOM after the change and returns
the four facts rows verbatim, e.g. THE QUARRY "46 by 36 hectares, 9 named zones, 2
keyed rooms, bot walks out 23.1%, first contact ~69s, 16.9 containers a raid,
median haul 8,965c". The measurement itself is 640 sims run through
__simSeedsFull with __pinDefaults per map.
Not verified: no A/B, because nothing in this build changes behaviour. It changes
four strings and one facts row. The numbers ON the board are bot-sim medians and
are not claimed to be his; his own recorder has him dying to raiders far more
often than the bot does, which is stated on the board rather than buried here.


### v3.01: the throw was aiming with the wrong copy of the maths, and two of my own changes came back

Four of his notes.

THE THROWABLE, "when I use a throwable, it should travel in the direction that I am
looking, similar to firing the gun. Right now it seems to always go in another
direction." He is exactly right, and the cause is the defect class this file
produces more than any other: duplicated arithmetic that drifted apart.

There were two copies of screen-to-world. The aiming copy divides the mouse
position by the zoom and carries a comment saying it must, "or aiming drifts
further from the cursor the further you zoom in and the gun stops pointing where
you are pointing". The throwing copy predates that fix and never received it, so it
read the cursor as though the zoom were always 1. At any zoom other than 1 the gun
and the throw disagree, and the error grows the further the cursor sits from screen
centre. That is precisely "it always goes in another direction".

There is one mouseWorld() now and both callers use it, so the two cannot drift
again. Measured across zooms 0.7, 1.0, 1.3 and 1.6 at five cursor positions: the
throw heading now matches the aim heading to within 0.3 degrees everywhere.

AUTO-RELOAD, "game should auto-reload if you try to fire a gun that is empty clip
but has reserve ammo". Pulling the trigger on an empty magazine is an unambiguous
statement that you want to shoot, and making you press a second key to say so again
is a chore rather than a decision. The dry pull starts the reload now. The reload
still takes its full time and is still interruptible, so the cost of running dry is
unchanged; only the extra keystroke is gone. With no reserve at all nothing starts,
because then there is genuinely nothing to do about it.

THE CARS ON HILLS, "why are all the cars on top of little hills? looks dumb, revert
it". This one is mine and the chain is worth writing down. A wreck was drawing its
own soft ellipse underneath itself, 59 units wide and 12 tall on a car 55 wide, at
34 percent black. It had always been there. What changed is v2.96, where I deleted
the 60-dark-ellipses-per-unit-area pass of fake terrain he asked me to remove. Until
then one more dark oval under a car was lost in a floor covered in dark ovals. I
cleaned the ground, and every surviving ellipse started reading as a mound with a
car parked on it. He is right to call it and right that it is a revert.

The ellipse is also redundant, which is why removing it is the correct fix rather
than the expedient one. A wreck is a wall, and bakeGround already lays a contact
shadow at the foot of every wall, so the car stays grounded exactly the way a
building is.

THE LOOT TELL, "the loot boxes shouldn't tell you the value of loot BEFORE you open
them lol that kills the gamble". Correct, and it was doing exactly that: the pulse
over every unopened container was tinted RCOL[ct.best], the rarity of the best item
inside, so an elite box glowed purple from across a room and a common one glowed
white. Choosing which box is worth six seconds IS the gamble, and the box was
answering that question before you touched it. The pulse is neutral amber now. It
still says UNLOOTED, which is navigation rather than gambling, and says nothing
about the contents.

A cache keeps its colour and that is deliberately not the same thing. A cache is a
public landmark, named on its world label and marked on the sector map, because
v1.75 established that a guaranteed jackpot you can never find is the worst of both
worlds. You know a cache is rich the way you know a bank is rich; you still do not
know what is in any particular drawer.

ONE THING I HAVE LEFT AND WANT HIM TO RULE ON. v2.99 put "3 left, ELITE" on the
progress bar WHILE you are searching a box. That is the same information one step
later, and I have kept it on the reasoning that it lands after you have committed,
where it powers the "one more pull or get out" decision rather than the "which box"
decision. If he meant that one too, it is one line to remove and I will.

Verified: parsecheck PASS at v3.01, all four maps and the hub drive and draw with
drawErr null. Throw direction measured against aim heading at five cursor positions
across four zoom levels, maximum disagreement 0.3 degrees. Auto-reload driven
through the real main loop in three cases: empty magazine with 60 reserve starts a
full-length reload; empty magazine with zero reserve starts nothing; five rounds in
the magazine fires normally and spends one, starting no reload. Wreck captured at
4x with the camera settled, which is how the ellipse was identified in the first
place.
Not verified: the two on-screen strings on the auto-reload path, "Reloading..." and
"Out of ammo.". The reload state changes correctly every time but G.msg did not
change in the fixture and I could not establish why inside a reasonable budget, so
I am flagging the text as unconfirmed rather than claiming it. The behaviour is
verified; the words may not appear. No balance measurement: nothing here touches a
roll, an entity decision or a timing constant.


### v3.02: the compass pointed at a fixed ring, and now it points at the way out you are actually near

His note: "what is the beacon indicator at the top of the screen -- can you make it
point to the NEAREST extraction instead, and make it switch any time the player
finds a nearer extraction -- also, player should be able to mark a waypoint on
their map using the mouse (add cursor when map is up), and then the beacon
indicator should change to like 'Marked Waypoint' and point to that instead".

WHAT IT WAS DOING. The arrow read G.active, the single ring the raid nominates at
build time, and it never changed as he moved. Every map has three open extracts, so
on any given run the arrow could confidently point at the second or third nearest
one. A compass that points away from the nearest way out is worse than no compass,
because he trusts it. His own recorder has runs ending with closestExt over 2,000
metres, which is exactly what walking toward the wrong ring looks like.

WHAT IT DOES NOW, in priority order, and the order is the design:

  1. If the beacon is actually inbound, it locks to THAT ring no matter what. At
     that point there is one way out that matters and pointing anywhere else would
     get him killed.
  2. Otherwise, if a waypoint is set, it points there and says WAYPOINT in amber.
     A waypoint is an explicit instruction and outranks a default.
  3. Otherwise it points at the NEAREST open extract, recomputed every frame, and
     says EXTRACT. Walk past a closer ring and the arrow swings to it by itself.

THE WAYPOINT. Hold M, click anywhere on the map, and it drops a marked point;
right-click clears it. The cursor now appears while the map is up, which was part
of his note and without which he would be aiming the click blind. A click outside
the map rectangle is ignored so a stray click on the surround cannot drop a
waypoint in a corner of the world, and the click returns before it can reach the
trigger, so marking a waypoint never also fires the gun.

The map draw used to compute its own scale and origin as locals, which meant a
click had no way to ask where it had landed. That projection is a shared function
now and both the draw and the click use it. This is the same lesson as the
throwable bug one build ago: two copies of a coordinate transform is precisely how
a cursor and the thing it points at end up disagreeing, so there is one copy.

Verified: parsecheck PASS at v3.02, all four maps and the hub drive and draw with
drawErr null, and the map overlay draws clean both with and without a waypoint set.
Compass retargeting driven from three standpoints on GREYWATER DAM, each 300 units
off a different ring: the nearest zone comes back as index 0, then 1, then 2, so it
does switch rather than sticking. Click round trip verified by dispatching real
mousedown events at three screen positions with the map up, and the resulting world
coordinates match the projection arithmetic exactly: screen (700,500) becomes world
(3022,2976) against a hand-computed (3022,2976). Pixel capture at 1280x718 shows
the waypoint ring and crosshair on the map, the "CLICK set waypoint, RIGHT-CLICK
clear" hint, and "WAYPOINT 2412m" on the compass.
Not verified: no balance measurement, and none applies. This is HUD targeting, one
click handler and a cursor rule; it changes no roll, no entity decision and no
timing constant. Worth noting for later: the same capture shows zone and landmark
labels overprinting each other on the sector map, which is his separate "names of
areas make no sense" note and is the next build rather than this one.


### v3.03: the map was printing half its names twice, and my own four-map check was one map four times

His note: "your names of areas on the maps make no sense".

I captured the sector map and he is right, though the cause is not the names. On
GREYWATER DAM, CONTRACTOR CAMP, TURBINE HALL, SWITCHYARD, THE TAILRACE and THE
CREST each appeared TWICE, one on top of the other, once large and faint and once
small and amber. Zone captions and landmark labels are both drawn at the centre of
their own rectangle, and a landmark that fills most of its zone shares that centre,
so the same words printed over themselves at two sizes. It does not read as two
labels. It reads as garbled text, which is exactly "makes no sense".

Counted across all four sectors: 5 of 7 landmark labels duplicate their zone name
on GREYWATER DAM, 3 of 3 on SUNKEN QUARTER, 3 of 3 on COLD STORAGE and 4 of 8 on
THE QUARRY. On two of the four maps EVERY landmark label was printing twice.

Three changes. A landmark whose name is simply its zone's name now draws its box
and keeps quiet, because it adds no information and costs legibility; the region is
already captioned. The zone caption moved off the centre line to near the top of
its region, the way a printed map letters a district across the top of it rather
than through the middle of it. And marker labels, CACHE, LOCKED, OPEN, ENCAMPMENT,
go through one placer that keeps what it has already drawn and walks a new label
clear of it.

The first version of that placer was worse than the overlap it replaced. Three
caches near each other each pushed up off the one below and produced a ladder of
the word CACHE, which is more ink saying less. A repeat of the same word in a
cluster carries nothing, because every one of those markers already draws its own
ring, so a duplicate is dropped outright and the cluster gets one label. Only
labels that genuinely differ are worth separating.

AND THE THING THIS UNCOVERED, which matters more than the labels.

Chasing why all four maps reported identical duplicate counts, I found that the
fixture's __startRaid took NO ARGUMENTS. Every __startRaid({mapIx:m,seed:s}) in
every verification run this session silently ignored both. So "all four maps drive
and draw with drawErr null", which I have written at the bottom of six changelog
entries, was in truth ONE map, whichever P.mapIx happened to hold, rendered four
times with an unpinned seed. It was not a lie about the result but it was a much
weaker check than the words claimed, and the words are what he reads.

The hook now sets P.mapIx and pendSeed before calling startRaid, which is the same
route __simSeedsFull uses and the reason the per-map sim numbers in v3.00 were
sound, that path was never affected. Re-run properly, the four maps now come back
genuinely different, world sizes 5200x4000, 4600x4600, 4200x3400 and 4600x3600,
zone counts 9, 5, 5 and 9, and all four still draw clean in both the raid view and
the map overlay. The earlier builds are not retroactively verified by this; they
are verified from v3.03 onward, and anything from v2.94 to v3.02 rests on a
one-map check plus parsecheck.

Verified: parsecheck PASS at v3.03. All four maps, now actually four different
maps, drive and draw with drawErr null in the raid view AND with the map overlay
up, plus hub frames. Duplicate-suppression counts measured per map as above. Pixel
captures at 1280x718 before and after: the doubled region names are gone, the CACHE
ladder produced by the first placer is gone, and each cluster carries one label.
Not verified: no balance measurement, and none applies. This build changes label
placement on an overlay and a fixture hook; it touches no roll, no entity decision
and no timing constant. Two minor crowdings remain where LOCKED, STRONGBOX and
CACHE markers sit close together in the SWITCHYARD, legible but tight, and I have
left them rather than push labels far enough from their markers to become
ambiguous about which marker they belong to.


### v3.04: the breakable world had HP and never once showed it

His note: "all destructible environment pieces should have HP that shows up once
they start taking damage from players, enemies, raiders, etc".

The HP has existed since v2.83 and was completely invisible. hpLeft is stamped on
first damage and counted down in silence, so shooting a wreck looked identical
whether it was one shot from breaking or thirty. That makes the whole destructible
system a guess: you cannot tell whether you are wasting ammunition on a wall or one
burst from opening a route, and both are common enough to matter.

Anything breakable that has been hit now wears a bar until it dies. It appears on
the FIRST point of damage and never before, which is his condition and also the
thing that keeps the world from turning into a field of health bars: an untouched
wreck shows nothing.

Three details that are deliberate rather than incidental.

It is fed by a list. damageWall pushes a piece onto G.dmgWalls the first time it
stamps hpLeft and splices it off when the piece breaks, so the draw pass walks the
handful of things that have been damaged rather than the six to eight hundred walls
on the map, every frame, forever.

The bar fades. Five seconds after the last hit it starts dissolving and is gone
three seconds later, so a wall you shot once on the way past does not advertise
itself for the rest of the raid. Hit it again and it comes straight back.

It is placed above the LIFT, not above the ground rect. Every solid draws its top
face raised by 14 or 26 units depending on size, and the first version put the bar
10 units off the ground y, which measured on a wreck put it straight across the
bodywork. 28 clears the tallest lift in the game.

Colour is the usual three-step, green above half, amber above a quarter, red below,
so the question the bar exists to answer, is one more burst worth it, is answerable
at a glance rather than by reading a number.

Verified: parsecheck PASS at v3.04, all four maps and the hub drive and draw with
drawErr null, in the raid view and with the map overlay up, and with a damaged
piece on screen in every one of them. Damage driven directly through damageWall via
a new scalar-only fixture hook: a wreck reports 150 max and steps 110, then 70,
then dies on the third hit, at which point it leaves both G.map.walls and the
damaged list, and the very next frame draws clean. A window reports 25 max and
chips to 15. A keyed door absorbs 999 damage, reports null HP and stays in the
wall list, so the gated content stays gated exactly as v2.83 intended. Pixel
capture at 4x shows the bar over a wreck at 55 of 150.
Not verified: no balance measurement, and none applies. This build adds a HUD
overlay and a bookkeeping list. It changes no roll, no entity decision, no timing
constant and no damage number; the sim does not draw and is unaffected.
One note on process: the first attempt at this test returned the wall object
itself and serialised the entire geometry graph, blowing the result budget. The
hook returns only scalars now, which is the general rule for anything in this
fixture that touches map geometry.


### Correction to v3.01, and a fixture that was lying about messages

The v3.01 entry ends with a "Not verified" line saying the two auto-reload strings,
"Reloading..." and "Out of ammo.", could not be confirmed because G.msg did not
change in the fixture and I could not establish why. That framing was wrong and the
implication, that something in the game might be off, was wrong with it.

The game was fine. The HARNESS was lying. tools/mkfixture.ps1 stubbed say() to a
no-op, grouped in with the audio emitters:

    try{ say=function(){}; }catch(e){}

say() is not an audio emitter. Its entire body is
`if(G&&!G.sim){G.msg=m;G.msgT=3.2;}`, a state write with no sound anywhere in it.
Stubbing it bought no silence at all and quietly broke every assertion any test
could ever make about on-screen messages, because G.msg simply never changed in the
fixture. I chased it through the wrong suspects for a while: a shadowed
definition, a stale G handle, a latched KeyR, T being undefined inside
updatePlayer. It was none of those. Settled it by adding a probe that calls say()
from INSIDE the module and reports what the module itself sees, which came back
with the message unchanged, G live and G.sim false, and that could only mean say
itself was not the function I thought it was.

The stub now does the real thing and records the last line:

    try{ say=function(m){ window.__lastSay=m; if(G&&!G.sim){ G.msg=m; G.msgT=3.2; } }; }catch(e){}

The fixture stays exactly as silent as it was, because say never made a sound, and
tests can now read what the game said. Both v3.01 strings are verified with it:
a dry trigger with 60 reserve gives msg "Reloading..." with the reload started at
1300ms, and with zero reserve gives msg "Out of ammo." with no reload.

I audited the other five stubs for the same fault and found none. sfx, blip,
tickAmbience, tickEnemyAudio, tickPlayerSteps and tickMachineVoices are all
genuinely audio-only, and every one of them already begins with its own
`if(G.sim) return`, so they are inert in a sim regardless. Importantly ping(), which
is what actually drives enemy hearing, was never stubbed, so no measurement has
been affected by this. tickPlayerSteps calls blip('foot') for the sound; the AI
facing noise comes from ping elsewhere.

One real consequence beyond the correction: because messages now land in the
fixture, the message plate added at v2.94 is exercised for the first time in the
four-map draw check, and all four maps plus the hub draw clean with a message up.

No game version bump. Not one byte of dark_raiders.html changed in this tick; the
fix is entirely in tools/mkfixture.ps1. Putting a new VER on an identical game to
satisfy a process step would make the version label lie, which is the same class of
problem as the thing being fixed.
Not verified: nothing outstanding. The correction itself is verified by the probe
described above, and the claim that no measurement was affected rests on ping()
never having been stubbed, which is checked rather than assumed.

### v3.05: the search bar stops pricing the box, and the roadmap stops advertising finished work

TWO HALVES OF ONE NUMBER. At v2.99 I put "3 left, ELITE" on the search bar so the
"one more pull or get out" decision had something behind it. At v3.01 he said loot
boxes should not tell you the value of what is inside before you open them, because
it kills the gamble. I neutralised the pre-open glow and kept this one, arguing it
lands after you have committed rather than while you are choosing which box.

That distinction is thinner than his principle. Knowing the last item is ELITE is
knowing the value before you have it, which is the thing he objected to, and the
fact that it arrives four seconds later does not change what it tells you.

So the number is split along the line his principle actually draws. COUNT STAYS:
how many pulls are left is a question about TIME, and time is what you are visibly
spending and what the bar is already measuring. RARITY GOES: that is value, and
whether the time is worth the value is precisely the gamble. The bar also drops
back to neutral amber instead of glowing with whatever is still in the box. The
label now reads "2 items left" and nothing else.

THE ROADMAP WAS ADVERTISING FINISHED WORK. Its NOW item read "Deployment
briefings: choose the map knowing what is on it", and that shipped across v2.95
and v3.00: the lift names its destination, and the sector board describes all four
sectors with measured extract rates, contact times, container counts and median
hauls. Leaving it under NOW is the same stale-claim fault as the SPEC 4.6 comment
describing a deletion that had been reverted, and as the MAPCONT copy built on an
inert constant. It is DONE now, and NOW states the thing that is genuinely open and
waiting on him: COLD STORAGE walking out at 4.4 percent against 15 to 23 everywhere
else.

I also swept for more of the duplicated-transform defect that produced the
throwable bug at v3.01 and the map-click problem at v3.02, and FOUND NOTHING
FURTHER. There is exactly one world-to-screen function, w2s, with nine callers and
no hand-rolled copies anywhere in the file, and screen-to-world is now the single
mouseWorld plus the map projection, each with one definition. The gamepad path
computes the inverse deliberately to synthesise a cursor position and is not a
duplicate. Saying so plainly because a check that finds nothing is still a result.

Verified: parsecheck PASS at v3.05, all four maps and the hub drive and draw with
drawErr null, in the raid view and with the map overlay up. Search label driven
through the real main loop against a planted container holding two commons and an
elite: the label reads "2 items left" with two still inside and the best of them
elite, and the elite is not named or coloured anywhere on screen. Pixel capture at
4x confirms neutral amber text and bar.
Not verified: no balance measurement, and none applies. This build changes one HUD
string, one bar colour and one roadmap entry; it touches no roll, no entity
decision and no timing constant. The judgement call itself is his to overturn: if
he wanted the rarity kept and only the pre-open glow gone, it is one line back.

### v3.06: COLD STORAGE had two of its three exits 503 units apart, and that was most of its lethality

Two of his notes, and they turned out to be one finding twice.

THE CARS, AGAIN. "cars are still up on little platforms and it looks dumb", which
is the second time he has raised it, so my v3.01 fix was wrong. It removed the
wreck's own soft ellipse and I called that done. The real cause was elsewhere
entirely, and removing the ellipse MADE IT WORSE.

bakeGround lays a hard-edged contact shadow under the footprint of EVERY wall, a
full width rectangle up to 15 units deep. That is right for a building, which is a
volume rising out of the ground, and wrong for a car, which is an object sitting on
it. The wreck sprite is also drawn lifted 14 to 15 units, so the slab sat in a
visible gap BELOW the car, and the two together read exactly as a vehicle parked on
a plinth. The soft ellipse had been covering that gap. I captured it at 6x this
time instead of guessing, which is what I should have done at v3.01. Wrecks are
skipped in that pass now and draw a shadow that hugs the wheels at the body's own
lift, so the car and its shadow touch.

THE EXTRACTS. "extractions should be spaced out -- on this map they are nearly
right next to each other". Measured across all four sectors, and he is precisely
right about one of them. Closest pair of extraction rings:

  GREYWATER DAM    1,955 units   29.8 percent of the map diagonal
  SUNKEN QUARTER   2,560         39.4
  THE QUARRY       1,841         31.5
  COLD STORAGE       503          9.3

The extraction ring is 78 units. Two of COLD STORAGE's three rings sat effectively
on top of each other, both in the south-west, so the sector advertised three ways
out and delivered two. THE LONG DOCK, the entire 4,200 wide northern strip, had no
exit anywhere in it. The redundant ring moves into the dock at 1,700, 400. New
closest pair is 2,284, or 42.3 percent, which makes COLD STORAGE the best spaced of
the four rather than the worst by a factor of four.

AND IT WAS MOST OF THE 4.4 PERCENT. This is the sector I flagged to him two builds
ago as an outlier needing his ruling, on the reasoning that its lethality was
interior geometry and would need real map surgery. It was not. It was two exits in
the same place. Re-measured on the IDENTICAL 160 seed list used for the v3.00
board, mapIx pinned, simGreed unchanged, one variable moved:

  extract rate    4.4 percent (7 of 160)  ->  15.0 percent (24 of 160)
  two proportion z = 3.21, p about 0.0013
  median first contact 85s -> 77s
  containers 14.8 -> 16.3, median haul 8,620c -> 7,775c
  sentry deaths 96 -> 66, crawler 48 -> 62

COLD STORAGE now sits level with GREYWATER DAM at 15.0 and below SUNKEN QUARTER at
18.8 and THE QUARRY at 23.1. The outlier is gone, and it did not need a redesign,
it needed one coordinate moved. Worth saying plainly: I told him the cause was
probably confinement and long sight lines. I was wrong about the cause while being
right that something was wrong, and his one-line note found it faster than my
measurement did.

The sector board moves with it. It carried "bot walks out 4.4%" for exactly one
build, and leaving a stale number there would have recreated the precise fault that
v3.00 existed to fix. It reads 15 percent now, first contact about 77s, 16.3
containers, median haul 7,775c, and the character line no longer calls this the
deadliest sector, because it is not one any more.

Telemetry consumed this tick: run #32 on v3.05, COLD STORAGE, dead at 113s to a
sentry with closestExt 12, which is reaching a ring and dying at it. No written
note attached. It predates this build and is exactly the failure the extract move
addresses.

Verified: parsecheck PASS at v3.06, all four maps and the hub drive and draw with
drawErr null in the raid view and with the map overlay up. Extract spacing
re-measured on all four sectors after the change, and no extraction ring on any map
sits inside a wall, checked against the full wall list rather than assumed. The 4.4
to 15.0 result is 160 seeds against the same 160 seeds. Wreck captured at 6x before
and after: the slab is gone and the shadow meets the wheels.
Not verified: the extract move is measured against the BOT, not against him. The
bot dies to machines far more than he does, so the size of the gain may differ for
him even though the direction will not. I have also not re-measured the other three
sectors, because nothing in this build touches them: the edit is one coordinate
inside the COLD STORAGE record plus a skip in a shadow pass keyed on the wreck
flag.


### v3.07: rounds punch through the thin things, and stop dead on the walls that matter

His note: "bullets should pass through thin walls, slow down, and do reduced
damages -- like in COD black ops 2".

SCOPED ON PURPOSE, and this is the whole design decision. This game states, in the
throwable comment and in the entire sight model, that every wall stops sight and
gunfire outright, and that is the one rule the cover system is built on. Making
building walls porous would not be a feature, it would be deleting cover from the
game. So THIN means thin: the soft furnishings, the car bodies and the trees, the
things you instinctively expect a rifle round to go through and a brick wall not
to. Building walls at 320 HP and terrain at 700 stay solid. Glass already passed
through untouched, because a window carries no segments at all by the v2.51 design.

Per material, measured on a driven round:

  furniture   damage x0.55   speed x0.80   (40 -> 22 dmg, 600 -> 480)
  tree        damage x0.50   speed x0.78   (40 -> 20 dmg, 600 -> 468)
  wreck/ruin  damage x0.45   speed x0.75   (40 -> 18 dmg, 900 -> 675)

A round is capped at two pieces so nothing tunnels the length of a room, and it
stops rather than penetrating once its damage would fall under 4, which is what
prevents a spent round chipping through scenery forever. Whatever it passes
through still takes the full damage it would have taken by stopping there, so
shooting through a car door eventually opens the car door. It cuts both ways:
machines and raiders punch through the same materials you do.

TWO BUGS OF MINE ON THE WAY, both found by driving it rather than reading it.

The first: I left hit=false after penetrating, and the tail of updateBullets does
`if(!hit){ b.x=sx+ux*trav; }`. That overwrote the exit point I had just computed
with the full free-flight travel, sometimes putting the round back INSIDE the rect,
where the next frame's inside-geometry test killed it. The tell was a 25 unit deep
wreck reporting TWO penetrations for one crossing. There is a `punched` flag now
and the tail respects it.

The second is subtler and is the v2.09 jam rule wearing a disguise. The
non-penetrating branch calls `decal(b.x,b.y,'#0d0f13',rnd(3,6))`. decal() early
returns on G.sim, so I would normally not think about it, but the rnd is an
ARGUMENT and JavaScript evaluates it before the call. So the pen-off arm consumed
one rr() that the pen-on arm did not, which shifts the entire stream from the first
bullet impact onward and makes the two arms different raids rather than the same
raid with and without penetration. The roll is drawn unconditionally into a local
now, before the branch. Had I not caught it the measurement below would have been
noise dressed as a result.

BALANCE: costs about two points, not significant. 320 seeds paired on GREYWATER
DAM, mapIx pinned, simGreed 52 in both arms, dial off against dial on in one build.

  extract rate   13.8 percent off (44 of 320)   11.6 percent on (37 of 320)
  discordant     16 favouring off, 9 favouring on
  McNemar exact two sided p = 0.23
  mean haul across all runs 8,418c off, 8,579c on
  killers barely move: sentry 155 to 157, crawler 99 to 104, warden 7 to 7

p=0.23 is not significance and I am not claiming harm. What I will say is that the
lean was negative and CONSISTENT: arm A led from seed 17 onward and never gave the
lead back across 320 pairs, which is not the shape of a coin landing badly. The
mechanism is obvious once stated, since penetration is symmetric and the bot spends
its life behind exactly the furniture and wrecks this makes porous. It ships ON
because he asked for it and the cost is inside the noise floor, and it is on
CFG.penetrate if either of us wants it back out.

Verified: parsecheck PASS at v3.07, all four maps and the hub drive and draw with
drawErr null. Penetration driven per material with a hand-placed round: furniture,
tree and wreck each cross with exactly one penetration recorded and the damage and
speed multipliers land on their stated values; with the dial off none of the three
cross and the round dies on the face; a building wall stops a round dead with the
dial ON, which is the cover pillar holding. Materials still take their damage in
both cases.
Not verified: I have not measured penetration separately per map, only on
GREYWATER DAM. The material mix differs between sectors, so a map thick with
furniture would feel this more than the dam does. Also unmeasured: what this does
to HIS play rather than the bot's. He fights raiders far more than the bot does and
raiders take cover behind the same soft things, so the symmetric cost may not land
symmetrically for him.


### v3.08: early deaths are not ambushes, and the check that proved it found no bug

THE INVESTIGATION FIRST, BECAUSE IT CAME BACK NEGATIVE. His flight recorder keeps
saying the same thing at the bottom of every export: 83 percent of his deaths
happen before the decision to leave exists. Several of his short runs looked like
ambushes, and one in particular, run #29, died at 65 seconds having moved 461 units
and fired ZERO shots. That reads as being killed with no warning, which if true
would be a real defect in how threats are telegraphed.

400 simulated raids across all four sectors, 345 deaths, split at 90 seconds:

                        died under 90s      died at 90s or later
  count                 60 (17% of deaths)  285
  median duration       65s                 214s
  median first contact  34s                 94s
  contact to death      28s                 82s
  never fired a shot    1 (2%)              4 (1%)
  containers opened     5                   18
  killers               sentry 41, crawler 14, raider 3    sentry 154, crawler 110

THE AMBUSH THEORY IS DEAD. Two percent of early deaths involved never firing a
shot, which is the same rate as late deaths, and the median early death came 28
SECONDS after first contact. That is a fight that was lost, not a jump scare. The
one thing that actually separates a short run from a long one is WHEN contact
happened: 34 seconds against 94. Early death is early contact, and the player is
getting a normal amount of warning and then losing.

So there is no defect here to fix, and I am saying so rather than inventing one.
His run #29 with zero shots is real but it is the two percent case, and a handful
of his runs is a small sample against 345.

WHAT SHIPS OFF THE BACK OF IT. The measurement does say what number is worth
showing him, and it is not the one the death screen was showing. "KILLED BY SENTRY,
812M FROM EXTRACTION" tells him what he just watched happen. It now also reads
"IN CONTACT 88S, FIRST SEEN AT 42S", or "NEVER SPOTTED" when nothing ever found
him. Those two numbers are the ones that distinguish a run that was going to end
early from one that was not, and putting them at the moment of death is the
difference between an epitaph and feedback. It costs nothing: both values were
already in the telemetry and already in the exported run line, they were simply
never shown to him at the point where he would care.

Verified: parsecheck PASS at v3.08, all four maps and the hub drive and draw with
drawErr null in the raid view and with the map overlay up. Death screen driven in
both branches: with firstContact 42 and a death at t=130 it reads "KILLED BY
SENTRY, 2353M FROM EXTRACTION, IN CONTACT 88S, FIRST SEEN AT 42S", and with
firstContact null it reads "KILLED BY TIMER, 1538M FROM EXTRACTION, NEVER
SPOTTED". The arithmetic is checked against the inputs rather than eyeballed.
Not verified: no balance measurement, and none applies. This build adds text to a
screen that appears after the raid is already over; it changes no roll, no entity
decision and no timing constant, and the sim never builds that screen. The
investigation itself is measured against the BOT, which fights differently from
him: it dies to machines far more than he does, so if his early deaths really do
have a different shape, this sample would not show it. What I can say is that the
engine is not denying warning, because the bot gets 28 seconds of it.


### Penetration measured on a second sector: the dam's negative lean was noise

At v3.07 I shipped bullet penetration with a caveat I was not comfortable with.
The dam measurement came back 13.8 percent off against 11.6 on, p=0.23, and I wrote
that the lean was "negative and CONSISTENT: arm A led from seed 17 onward and never
gave the lead back across 320 pairs, which is not the shape of a coin landing
badly." I also flagged that I had only measured one sector, and that the material
mix differs between them.

Both halves of that deserved checking, and the second one settles the first.

SUNKEN QUARTER, 320 paired seeds, same protocol, mapIx pinned, simGreed 52 in both
arms, dial off against dial on in one build:

  extract rate   16.3 percent off (52 of 320)   16.9 percent on (54 of 320)
  discordant     15 favouring off, 17 favouring on
  McNemar exact two sided p = 0.86

Dead neutral, and leaning the OPPOSITE way. This is the densest interior in the
game and the sector with the most furniture, which is where penetration should bite
hardest if it bites at all, and it does not.

POOLED ACROSS BOTH SECTORS, 640 paired seeds:

  discordant 57 pairs, 31 favouring off, 26 favouring on
  McNemar exact two sided p = 0.60

So penetration is balance neutral, and my "not the shape of a coin landing badly"
was exactly the shape of a coin landing badly. A run of one arm leading for 300
pairs feels like signal and is not; that is precisely what the 9.2 point noise
floor across 120 seed blocks has been telling me since v2.42, and I talked myself
past it because I had a plausible mechanism ready. Having a good story for why an
effect should exist makes it easier, not harder, to misread the noise.

The v3.07 entry stands except for that sentence, and this is the correction to it.
Penetration ships on, now on two sectors' evidence instead of one.

No version bump: not one byte of dark_raiders.html changed in this tick, it is a
measurement and a correction. Putting a new VER on an identical game would make the
version label lie.
Verified: parsecheck PASS at v3.08, all four maps and the hub drive and draw with
drawErr null in the raid view and with the map overlay up, and CFG.penetrate reads
1 at the shipped defaults.
Not verified: COLD STORAGE and THE QUARRY are still unmeasured for this dial. The
two sectors measured are the two extremes of interior density, which is the axis
penetration should act on, so I am treating the pooled result as sufficient rather
than running two more 320 seed batches for a dial that has now failed to move
anything twice. Also still unmeasured against HIS play rather than the bot's, for
the reason given at v3.07: he fights raiders far more than the bot does.


### v3.09: "punishes time spent, not value carried" stops being a slogan and becomes a measurement

I have been repeating that phrase to him for weeks as a design concern, flagged as
his call, without ever measuring it. This tick measured it. It is true, and the
size of the effect is larger than I expected.

THE HAZARD CURVE. 440 simulated raids across all four sectors. For each 60 second
window: of everyone still ALIVE at the start of it, what fraction did not survive
it. This has no selection problem, because every run is at risk in every window it
reaches.

  minute 1   4.8%   (21 of 440)
  minute 2  16.7%   (70 of 419)
  minute 3  18.9%   (65 of 344)
  minute 4  30.0%   (79 of 263)
  minute 5  31.6%   (54 of 171)
  minute 6  45.1%   (46 of 102)
  minute 7  27.9%   (12 of 43)
  minute 8  46.4%   (13 of 28)

Monotonic apart from minute 7, where n has fallen to 43 and the noise takes over.
A raid's ninth minute is roughly NINE TIMES deadlier than its first. The clock is
the antagonist.

AND THE VALUE BANDS ARE SELECTION, CONFIRMED. The same 440 runs reproduce the exact
shape his own recorder shows:

  0-1k    2.6% out   average duration  84s
  1-3k    0.0% out                    167s
  3-6k    6.5% out                    209s
  6-12k  18.6% out                    250s
  12k+   23.8% out                    233s

Read the duration column and the whole table dissolves. A run carrying under 1,000c
is not a cautious run, it is a run that died at 84 seconds before it could get
rich. The bands sort runs by how long they lasted and then report that as though it
were about weight. Carrying more does not kill you; it is evidence you survived
long enough to pick things up.

The recorder already half knew this. haulBandLines carries a paragraph explaining
why the bands must not be read as a risk curve, and it prints that paragraph
whenever most deaths happen before the extraction decision, which for him is 83
percent of them. A number that needs a paragraph telling you not to read it is a
number worth replacing.

WHAT SHIPS. The export now leads with SURVIVAL BY TIME IN RAID, computed the same
way, from his own log. The value bands stay underneath, because they are still the
right answer to a different question and the comparison between the two is the
lesson. The new table states plainly what it is: every run is at risk in every
minute it reaches, so if these numbers climb, the clock is what is killing him and
not the weight of the bag.

WHAT THIS DOES NOT DO is change the game. I am not touching the raid clock, the
siege, or enemy escalation on the back of one measurement, because which of those
should carry the pressure is a design decision and it is his. What it does is
replace a misleading instrument with an honest one, so the next time either of us
argues about greed and risk we are arguing from the right number.

Verified: parsecheck PASS at v3.09, all four maps and the hub drive and draw with
drawErr null in the raid view and with the map overlay up. The hazard arithmetic is
checked against a PLANTED log with a known shape rather than eyeballed: 10 runs,
two dying at 30 and 45 seconds, three at 70, 80 and 110, two extracting at 220 and
230, three dying at 240, 250 and 260. It reports minute 1 as 2 of 10, minute 2 as 3
of 8, minute 3 as 0 of 5, minute 4 as 1 of 5, which is correct on every count
including that the two extractions are at risk but are not deaths.
Not verified: the hazard curve is the BOT's, not his. His own table will be thin
for a while, since it needs runs spread across the minutes and he has 32 logged,
and the per-minute counts will be small enough to be noisy until that grows. I have
deliberately not tried to explain WHY hazard rises: alert accumulation, the siege,
ammunition running down and the timer forcing the endgame are all candidates and I
have measured none of them, so attributing it would be exactly the kind of
plausible story that made me misread the penetration lean one tick ago.


### The chase-give-up "fix": wrong premise, measured harmful, reverted

This tick I built a feature for a defect that does not exist, measured it, found it
made the game significantly worse, and then found the defect was never there. All
three of those are worth writing down, because the order they happened in is the
lesson.

WHAT I WENT LOOKING FOR. v3.09 established that hazard rises ninefold across a
raid. A follow-up probe stepping 48 sim raids and sampling every 30 seconds
established that the cause is not the player wearing down: ammunition RISES from 65
to 206 rounds over a raid, dry runs are 0 to 3 percent, health holds near 85, armour
falls only modestly from 35 to about 20. What climbs is machines in a hunting
state, 0 to 8.6.

WHAT I CONCLUDED, WRONGLY. I grepped for `state='patrol'` and found three
assignments: one from investigate, two inside the crier's alarm. The chase block had
none. I read that as "nothing ever gives up", noted that the warden's comment calls
out "never gives up" as its special trait, and built a lost-sight timer behind a
CFG.chaseGiveUp dial.

WHAT THE MEASUREMENT SAID. 320 paired seeds on GREYWATER DAM, mapIx pinned,
simGreed 52 both arms:

  extract rate  15.0 percent off  ->  11.6 percent on
  discordant    15 favouring off, 4 favouring on
  McNemar exact two sided p = 0.019

Significant, and in the wrong direction. My "fix" cost 3.4 points.

WHAT WAS ACTUALLY THERE. Chasing machines already give up, at line 9417:

    if(!sees&&e.alert<=0){ e.state=(raider?'loot':'investigate'); ... }

Sight sets alert to 2.4 and it decays at 0.5 a second, so a pursuer that loses
sight drops to investigate after 4.8 seconds and to patrol when it reaches the last
known point. Driven and confirmed: chase to investigate at exactly 4.80s. My grep
missed it because the exit routes through investigate and never mentions patrol,
and I searched for the destination instead of the departure.

So what I shipped was not a missing transition restored. It was a SECOND and faster
give-up path stacked on the existing one, and it made pursuit worse for the bot
rather than better. The whole thing is reverted: dark_raiders.html is byte for byte
back at v3.09, with no chaseGiveUp dial and no CHASE_LOSE constant left behind.

THE PROCESS FAILURE, because it is the reusable part. Two ticks ago I misread a
consistent lean as signal because I had a plausible mechanism ready. This time I
misread an absence of a string as an absence of behaviour, again because I had a
plausible mechanism ready. Both times the story came first and the evidence was
fitted to it. Grepping for a state name is not reading a state machine, and the
correct check would have taken one driven probe: put a machine in chase, remove line
of sight, watch what it does. That probe is four lines and it is what finally
settled it.

The v3.09 hazard finding still stands and is untouched: alerted machines do climb
across a raid. What is now UNEXPLAINED is why, given that de-escalation works. Fresh
contacts arriving faster than the 4.8 second decay clears them is the obvious
candidate, and I am explicitly not asserting it, because that is exactly the kind of
ready-made story that has cost me two ticks already.

ONE THING KEPT. tools/mkfixture.ps1's __pinDefaults did not pin destruct,
raiderWear or penetrate, all added after that list was written, so a value left
dirty by an aborted probe survived every later pin. That is how a timed-out probe
left a dial at 1 and the next pinned run still read 1. Those three are pinned now.
__pairedBg was never affected because it sets and restores its own dials, but
nothing else was protected.

No version bump: the game is unchanged from v3.09. The only surviving edit is in the
fixture.
Verified: parsecheck PASS at v3.09 after the revert, all four maps and the hub drive
and draw with drawErr null in the raid view and with the map overlay up,
CFG.chaseGiveUp is undefined so no dead dial remains, __pinDefaults reports pinned,
and the EXISTING de-escalation is driven and confirmed at 4.80 seconds.
Not verified: why alerted count rises across a raid, which is now an open question
rather than an answered one. I have measured that it is not ammunition, not health
and not armour, and that de-escalation functions; I have not measured contact
arrival rate against decay rate, which is the next thing to actually measure rather
than guess.


### v3.10: it was never pursuit piling up, it was the map waking one machine at a time

This closes the question the reverted chase experiment opened, and it corrects my
own v3.09 wording in the process.

At v3.09 I wrote that hazard rises ninefold across a raid because machines
accumulate in "a hunting state". A churn probe over 40 stepped raids, sampling every
6 seconds and counting state TRANSITIONS rather than just states, says that
description was wrong in the way that matters:

  window     in CHASE   in INVESTIGATE   distinct ever alerted   entries per machine
  0-30s        0.08          0.21                 0.1                  1.00
  60-90s       0.39          3.61                 1.9                  1.04
  150-180s     1.04          6.75                 5.0                  1.06
  240-270s     0.84          8.23                 7.0                  1.12
  300-330s     0.38         15.85                 6.8                  1.06

Three readings, and each one kills a theory I had:

PURSUIT DOES NOT ACCUMULATE. Machines in chase sit near one for the entire raid and
never climb. The thing I "fixed" last tick was not broken, and this is the second
piece of evidence for that after finding the de-escalation at line 9417.

THEY ARE NOT RE-FINDING YOU. Entries per alerted machine stay at 1.0 to 1.15, so
almost every machine that ever hunts you does it once. There is no churn, no
sticky leash, nothing circling back.

WHAT GROWS IS INVESTIGATE, from 0.2 to 15.9. Your own noise converts the map from
patrol into investigate, one machine at a time, and they walk toward where you have
been. Distinct machines ever alerted climbs steadily with it. The rising hazard is
not a pack that never gives up; it is the map progressively waking up, and every
gunshot and opened container pays into it.

That is a good system. It was also completely invisible. The '?' and '!' markers
draw only on entities you can SEE, so fifteen machines converging on your last
firefight from off screen are represented by nothing at all until they walk into
view. The one number that best predicts your death was the one number the game
never showed you.

WHAT SHIPS. Two lines top right, and only when non-zero: N HUNTING in red for
anything in chase or alarm, N SEARCHING in amber for anything investigating, with
the amber brightening past eight. They are COUNTS and deliberately not positions:
it tells you how much of the map you have woken, which is the thing that kills you,
without handing over a map of where everything is. Hunting and searching are split
because they demand different answers, one is a fight and the other is a reason to
leave the area.

Verified: parsecheck PASS at v3.10, all four maps and the hub drive and draw with
drawErr null in the raid view and with the map overlay up. Zero state draws nothing
and does not throw, checked by forcing every entity to patrol. Both lines verified
in a driven raid: a bot-driven raid to 210 seconds reports 0 hunting and 3
searching and renders "3 SEARCHING"; a forced state of 2 chase and 9 investigate
renders "2 HUNTING" above "9 SEARCHING", captured at 3x and read back from the
pixels.
Not verified: no balance measurement, and none applies. This adds two strings to
the HUD and counts a state array that already exists; it changes no roll, no entity
decision and no timing constant, and the sim does not draw a HUD. What I have NOT
measured is whether showing this changes how he plays, which is the only question
that really matters about it and the only one the bot cannot answer.

