# PILLAGERS graphics upgrade: design (base v23.58, Canvas 2D, one file)

All line numbers are `C:\claudecode\dark raiders\dark_raiders.html` at HEAD 8abb8969 (v23.58, 49,190 lines) unless marked `mkfixture` (`tools\mkfixture.ps1`). I edited nothing and started no browser.

## 0. Bottom line and the map freeze

- **Which map is smaller.** Both fixed maps set `cols:8, rows:8, cw:WORLD_W/8, ch:WORLD_H/8` (7398), so cols×cw by rows×ch is just w×h:
  - COLD STORAGE (`id:'cold'`, mapIx 0, 6498) is 4200×3400.
  - THE COLD MILE (`id:'mile'`, mapIx 1, 6637) is 9000×7600.
  - All per-map work goes on COLD STORAGE: light placement, baked props, ground dressing, steam vents, puddle sites. Engine-wide work runs everywhere, including the Undercroft and mapIx 1 if it comes back: lighting layer, shadows, shake, hit pause, post pass, render scale, animation, effects. The seed 4242 fingerprint check still builds both maps (`__verify`, mkfixture 1221-1240: ents 85/374), so it must keep passing.
- **Screenshots** come from arcade raids on map 0: `arcadeDeploy({mapIx:0,seed:4242,cond})` at 44710, the call the arcade checks already use (mkfixture 5813 on).
- **Five of the 15 items partly exist already:**
  - Render scale: `CFG.gfxScale` and Auto resolution (24094-24128). But it scales the HUD canvas too, so text blurs.
  - Vignette: drawn on the HUD every frame, 28831-28833.
  - Baked walls, trees and shadows: v18.15, v18.16 and v18.36.
  - Persistent casings: 35789-35800.
  - Death animation and hit jolt: v17.47, 25278-25311.
  - The design upgrades these rather than duplicating them.
- **Loot glow conflicts with one of his rulings.** His 2026-08-26 note (25843-25851) bans rarity colour on an unopened box. Item 14 is therefore designed for dropped crates and opened containers only. Unopened boxes keep the neutral amber pulse. He should confirm.
- **Co-op shares one main thread.** Player 2 is opened with `window.open` and keeps its opener (40641), so both windows run on the same renderer main thread. In DEMO (2-player party) the CPU budget per window is roughly half. Budgets below are set for that.
- **What is not known yet.** Nobody has measured 4K frame time. The code says so itself: "this environment can time the script but not the drawing" (26150-26152). Build gfx1 adds in-game frame telemetry, so his own PC gives the real number.

---

## 1. The current render pipeline

### 1.1 Canvases

| Canvas | Context | What it holds | Size |
|---|---|---|---|
| `cv` | `wc` (24084) | The world | `W*DPR`. `DPR=min(dpr,2)*gfxScaleNow()` (24130, 24133-24134) |
| `hcv` | `ctx` | The HUD, on top (CSS 51) | Same `DPR` (24135-24136), so a lower render resolution softens the HUD text too |
| `litC` | `lx2` (24087) | Darkness and lamps sheet | `SOFTR` of the screen (24137-24139). `SOFTR`=0.5 when W*H>2.6e6, otherwise 0.67, times `gfxScaleNow`, never under 0.33 (v18.03). Also used by the Undercroft (34778-34795) |
| `fogC` | `fx2` (24086) | Fog of war sheet | Same `SOFTR` sizing |
| `G.ground` | - | Baked floor | `bakeGround` (8005). 1 px per world unit: 4200×3400 on COLD STORAGE. Built only when live (11530). Rebaked on context restore (35386) |

Other offscreen stores:
- `SHADSPR` (24234), `WALLSPR` (25937), `VEGSPR` (25943), `ICONSPR`.
- `BUZZTR` (28149, Blotter effect) and `REC.cv` (35240, recorder).
- On context restore every store is dropped (35382).

### 1.2 Frame order

**`loop(ts)`** (35528):
- Resize on a scale change (35535-35536), frame cap (35538).
- Frame gap feeds `perfNote` (35550, 25 ms threshold) and `drsTick` (35551).
- Undercroft path: `drawHubWorld` (35558-35580).
- Raid sim (35621-35663). `G.shake` decays at `dt*26` (35663).
- Effect lists age (35764-35800): pings, decals (life and fade), puffs, labels, flashes, sparks (moved and damped), shells (settle, cap 300).
- `render2D(dt)` (35818).

**`render2D(dt)`** (26069-27963):
1. Camera.
   - Scope-zoom ease (26076-26077), `Z=ZOOM()` (26078).
   - Anchor and lean (26094-26102).
   - Shake: `sk=G.shake*.7`, `ox/oy` jittered with `fxn` every frame (26114-26115).
   - `VX=ox; VY=oy` (26116), so `w2s` (24164) and every world-anchored HUD mark shake. Aim does not: `mouseWorld` reads the unshaken `G.camX` (13994-13999).
2. Visibility. `VIS` is rebuilt with `canSee` over all of `G.ents`, plus shared sight (26120-26141).
3. Ground layer, inside `wc.save/scale/translate` (26145):
   - Letterbox fill (26144), sub-rect of `G.ground` (26153-26155), water shimmer (26157-26168), story prop (26170-26177).
   - Footprints with `canSee` (26178-26204), decals (26205-26237, `canSee` for prints and ripples), arcade pumpkins (26238).
   - **Brass shells (26239-26246): all of them, no view cull, a save/rotate/fillRect/restore each.**
   - Extraction zones (26249-26260), sentry cones (26262-26291), pings in the old order (26294-26325), prep bars (26339-26350), marked ring (26352-26358), mortar shells (26361-26375).
4. Y-sorted list `DR` (26378-26491). Items: thrown objects, walls, containers, the seal, seen entities, bushes, lamps, wildlife, the player, party (`netUpDraw`). Sorted at 26491.
5. The `DR` loop (26504-27175), wrapped in fault armour (27155-27174):
   - Wildlife, lamp housings (26584-26616), bushes (26617-26636, `vegDraw`), trees (26637-26656).
   - **Ruins, wrecks and furniture painted live (26657-26900).**
   - Doors and windows live (26930-26988). Plain walls from `wallSprite` (27009-27011). The lift rule: `LIFT = ledge?0 : lift || (w<=60&&h<=60 ? 14 : 26)` (26916).
   - Containers `drawContS` (27013, 25704-25926). Party `netUpDrawOne` (41666).
   - Player `drawOp` (27016-27064).
   - Entities (27065-27154): deck lift, hit jolt `animHitShift` (27069), elite ring, the per-kind draw functions (27081-27127), weak-point glows using a radial gradient each (27134-27151).
6. See-through ghost of the player (27187-27216). Damage bars (27221-27245).
7. Air pass:
   - Additive tracers including `G.fxBullets` (27427-27440), sparks (27441-27445).
   - `drawDeathAnims` (27447), puffs (27448-27453), thrown objects (27475-27482), smoke grenades (27483-27493), extraction light shaft (27495-27505).
   - `wc.restore` and `setTransform(DPR)` (27506-27511).
8. **Darkness sheet** (27512-27592).
   - Clear, then fill `rgba(7,7,26, NIGHT_SHEET/BR)` by night or `rgba(22,28,54, DAY_SHEET/BR)` by day (27527-27529; `DAY_SHEET=.13`, `NIGHT_SHEET=.30`, 24593).
   - `destination-out` radial holes: lamps (27536-27550, one `createRadialGradient` per lamp per frame, flicker `fk`), player (27551-27555), mate (27556), flashes (27558-27567), hunting machines from `VIS` only (27571-27581), beacon (27583-27589).
   - Stretched over the frame (27592).
9. **Warm glows**, additive (27593-27665).
   - Blacks lift `#05030b` (27601-27603), time-of-day cast (27607-27613), dim (27614-27620).
   - Two flat discs per lamp in the lamp's colour (27624-27640). This is the only place a lamp's colour reaches the screen.
   - Flash bloom discs (27642-27649), machine eye glow (27651-27659), beacon (27660-27663).
10. **Fog of war** (27666-27735). Fill (27705-27717), `buildVisPoly` cut-out (27722-27729), ambient cut-out (27730-27733), mate fog (27734), composite (27735).
11. Drawn after the sheets:
   - Locked-door glows (27736-27751), pings (27761-27800), noise rings (27810-27824).
   - **World text** `_wtA` / `_wtB`, in the world transform on `wc` (27825-27827; defined 27253 and 27381).
12. Weather and overlays:
   - Rain: 110-290 screen-space hairlines in one path (27831-27872).
   - Fog weather: full-screen fill plus 7 radial gradients every frame (27879-27899).
   - Arcade haze (27900), nuke white-out (27903-27911), strike rings (27914-27943), lightning (27948-27960).
13. `drawHUD()` (27961, 28827).
   - `ctx.clearRect` (28830).
   - Vignette: one full-screen radial gradient every frame (28831-28833).
   - Then the message rows, boss (Overseer) bar `drawBossBar` (28798), use bar `drawUseBar` (28481), status icons `drawStatusIcons` (28643), belt and so on.
   - `drawBuzzFx` (27962).

### 1.3 Lamp data (`G.lights`)
- Built in `buildRaid` (10954-11021), live only (`!sim && !hasTerm('blackout')`, 10962), inside `fxBorrow` (10963) on the cosmetic stream.
  - Building lamps: 1-2 per building, `{x,y,r:130-210,c:D.light,i:.30-.52,f,fl}`.
  - Posts beside walls: `{...,post:1}`.
  - Lamps in water are removed (11019-11021).
- Readers outside drawing: only the `tLit` telemetry (18612). DESIGN 11554-11558: lamps never touch detection or AI.
- The arcade recolours lamps after build with `fxr` (`arcadeHallow`, 44606-44611). Any lamp cache must key on `c` and `i`.
- Undercroft lamps: `HB.lights` (34196-34199).

### 1.4 Effect lists and their writers
- `flash(x,y,r,col,life)` (15028-15032): returns in the sim, cap 60. Muzzle: `fireWeapon` sets `sh.muzzle=.06` and calls `flash` (15643-15646). Explosions call it at 14197, 14311, 14370 and 14426.
- `spark()` (15015-15025): returns in the sim, `fxn`, thinned by `fxLevel` 0.
- `decal()` (15161-15166): cap 420, `life:45`. So scorch, blood and junk fade after 45 s; nothing on the ground is permanent today, whatever the comment at 35765 says. Prints use `pushPrint` (15151).
- Brass: pushed with `fxn` (15663-15668), settles and persists (35789-35800).
- `p.recoil=1` is set (15650) and decays at `dt*7` (18295), but `drawOp` never reads it.
- Hit flags `e.hitT` (.16-.2) are set in sim code (22335, 22491 and others), decay 20319, mirrored to linked windows (43401-43402).

### 1.5 Entity drawing
- **`drawOp`** (24668-25263) draws the player, pillagers, the stray, teammates, the Undercroft crowd and `__opShot`.
  - Walk cycle: leg swing and lift, bob, sprint lean (24695-24704).
  - Builds: Lean, Broad and Curved (24596-24604, `drawBuildTorso` 24646-24667). Curved jiggle spring, fed by the bob only (24605-24636; v20.08 and v20.14 rules).
  - `'down'` pose is 4 fills (24674-24680).
  - Gun group rotated to the aim with a reload drop (25180-25253). Muzzle disc (25245-25251).
- **Machines:** `drawWardenAt/S` (25315-25362), `drawChoirS` (25363), `drawSentryS` (25437), `drawCrawlerS` (25484), `drawPeddlerS` (25528), `drawListenerS` (25563), `drawBulwarkS` (25609), `drawHowlerS` (25637), `drawSnitchS` (25653).
  - The 10 functions use `G.t` 19 times. `e.maxhp` exists (9432).
  - Hits draw as a red additive overlay, for example 25349-25354.
- **Death:** `deathAnimAdd` and `drawDeathAnims` (25291-25311) draw a coloured ellipse that turns and flattens over 0.8 s. It is also called from a linked window (43477).

### 1.6 Cosmetic streams (the only legal source of new randomness)
- `fxr/fxn/fxi/fxpick` (5281-5291). `fxBorrow` (5309-5314). `sideStream` (5303).
- `grit(x,y)` positional hash (7884).
- Deterministic functions of `G.t`, as rain and fog banks use (27864-27870, 27889-27898).
- Precedents to follow:
  - Shake moved off the raid stream (26103-26113).
  - Bullet impact keeps `rnd(3,6)` evaluated on both branches (22528-22535). Never add or remove a seeded draw there.
  - Brass (15664) and sparks (15018).

### 1.7 Frame-cost history and probes
- v1.56: `updateEnts` 6.34 ms against a 1.15 ms renderer, which led to the segment grid (8429-8442).
- `segsNear` measured 152 of 1,934 segments relevant (8560-8565).
- Sentry cones: 1.1 ms at 1600×900 before their view cull (26278-26283).
- v17.43 graphics rows (24094-24097). v17.87 `perfNote` (35496-35510). v18.01 Auto resolution (24099-24128).
- v18.03 soft sheets at half size (24088-24093; DESIGN 42805).
- v18.15 walls baked: 3,650-4,270 fillRect a frame became under 1,500 (25928-25936).
- v18.16 vegetation: about 250 arcs became under 120 (25938-25942).
- v18.36 shadow stamps: about 165 ellipses became under 70 (24230-24251).
- v18.48 sprites sharp at 4K (`wallSpriteScale` 25978).
- No `shadowBlur` on purpose (7723, 29111).
- Fixture: `__perfTimes` (save timing only), `__perfCounters` (nav, los, vseg), `__frame` = `render2D` (mkfixture 15).
- The checks that count draw calls patch `CanvasRenderingContext2D.prototype` (check v18.15 in `__REGRESS`, mkfixture 1348 on). New checks should use own-property stubs on the context instead, as asked.

### 1.8 Frame-cost hot spots (main thread)
1. All 300 settled casings redrawn every frame with no cull: 5 calls each (26239-26246).
2. One `createRadialGradient` per lamp per frame on `lx2` (27545), plus 2 disc arcs per lamp (27637-27639). Flashes: 2 each (27563, 27647).
3. Weather fog: a full-screen fill plus 7 gradients up to about 1,400 px square (27887-27898).
4. HUD vignette: a full-screen gradient every frame (28831).
5. `buildVisPoly` every frame: `segsNear` is a linear scan over all segments, then about 84 rays plus 3 per endpoint (8576-8595, called 27722). Again per mate (41641).
6. Live props:
   - `drawContS` uses `rrF`, with nested rotate for bodies and wrecks (25704-25926).
   - Ruins, wrecks and furniture: about 60 calls per branch (26657-26900).
   - Lamp housings (26584-26616).
7. Per-frame gradients: weak points (27140), strongbox and mine (25906, 25918), stray (27101), doors (27742).
8. `drawOp`: about 100 or more calls per body. Text: `measureText`/`fillText` on labels and nameplates.
9. Decals: up to 420 with save/restore, plus `canSee` on prints (26190, 26219). `VIS` runs `canSee` over all entities (26121).
10. Two windows on one main thread (40641).
11. Bake storm: `wallSpriteScale` depends on `DPR`, so an Auto resolution step can cross a scale and flush `WALLSPR`, then rebake every wall in one frame (26050-26052).

---

## 2. The 15 items

**Global targets**, measured per window at 3840×2160 on COLD STORAGE, warm frame, arcade raid, night storm:
- Main thread for `render2D` plus HUD: High at most Classic +1.5 ms after the bake savings.
- At most 4,000 canvas calls a frame.
- At most 14 full-screen passes. A pass is a fill or `drawImage` covering 90% or more of W×H.
- At most 10 `createRadialGradient` calls on `wc` a frame.
- Zero `getImageData` and zero `ctx.filter` per frame. Filters only at bake time.
- New sprite and canvas memory at most 60 MB per window.

**Measurement**, used throughout:
- M1: calls per frame via own-property stubs on `wc`, `ctx`, `lx2`, `fx2` and each new context, deleted afterwards.
- M2: `render2D` script time median over 60 frames, as a High/Classic ratio inside the same build (cancels out the machine).
- M3: `G.tel.gfx` frame-gap p50/p95 in his flight-recorder export (gfx1). The real GPU number from his PC.
- M4: `cdp.ps1 -Throttle 4` for a weak CPU or co-op.
- M5: two fixture iframes on one page, as `tools\nettest.html` does, for DEMO co-op cost.

**New Settings rows**, inserted after Effects (47908-47913):

| Row | Key | Options | Default |
|---|---|---|---|
| LIGHTING | `gfxLight` | HIGH (colour + shadows) / STANDARD (colour) / CLASSIC (v23.58) | HIGH |
| POST FX | `gfxPost` | ON / OFF | ON |
| EFFECT INTENSITY | `fxInt` | FULL / HALF / OFF (shake, hit pause, white flash, bloom, grain) | FULL |
| HUD SIZE | `hudTv` | STANDARD / LARGE FOR TV | STANDARD |

- Existing rows stay. Render resolution's hint changes to say the world only, text stays sharp. Effects (`fxLevel`) also thins the new particles.
- The existing rows are sentence case. New labels and words use short caps per his order.
- Following the existing convention (`wallBake`, `fxLevel`), undefined means default.
- CLASSIC plus POST OFF reproduces v23.58 exactly. That is the rollback and the A/B arm.

**1. Real lighting.**
- Approach: two new canvases sized like the soft sheets (start at `SOFTR`; the ladder can drop them to 0.33):
  - `LGC` (glow): cleared black. Lamps, flashes, beacon, open extraction rings (teal), hunting `VIS` machines, the player's lamp and lit pumpkins add in their colour with `'lighter'`.
  - `LMC` (light map): filled with an ambient colour, then `LGC` added.
  - The world takes `LMC` with `'multiply'`, then `LGC` with `'lighter'` at about 0.25. That replaces the discs at 27624-27640.
- Calibration (his hold-luminance rule, 27518-27526): ambient = 1 − sheet alpha. Blacks get `c·a` folded into the existing `#05030b` lift. Each lamp contributes `a·.85·L.i·gradient·colour/max(colour)`. Unlit ground and lamp centres keep today's luminance; only hue, falloff and shadows change.
- Hook: A wraps 27512-27665 as `if(gfxLightOn()) gfxLightPass(...) else {old code verbatim}`. The Undercroft path (34778-34804) also calls `gfxLightPass` with `HB.lights`, without shadows.
- Budget: +0.35 ms, +40 calls, +1 full-screen pass, 2 canvases at about 8 MB each at 4K.
- Setting: LIGHTING.
- Risks: brighter nights (his notes v4.35 and v5.54); leaking information under fog. Composite before the fog sheet; machine lights come from `VIS` only, as today.

**2. Shadows that follow light.**
- Approach: a baked cookie per lamp.
  - A visibility polygon from `G.map.segs` (walls, trees and wrecks; windows are see-through), queried through `segsBox(G.grid,...)` and copied, because it returns a shared scratch array (8461).
  - About 96 rays plus segment endpoints, as in `buildVisPoly`.
  - **Lift-aware:** a ray that hits a south face is pulled up by that wall's lift (26916 rule; the wall is found with `wallsNear`). The front face band, 26 above the collider, is lit and the floor behind is dark.
  - Plus 15% unshadowed bounce so roofs are not black.
  - Gradient filled into the polygon at 0.75 px per unit. Optional `blur(1.5px)` at bake time only.
  - Keyed `x,y,r,c,i` plus the identity of `G.map.segs`; `rebuildGeometry` (15448-15467) makes a new array when walls break or doors open.
  - LRU of 96. COLD STORAGE holds every lamp; prebaked over the first 60 frames of a raid, at most 2 bakes a frame.
  - Per frame: one `drawImage` per lamp, with flicker as alpha and scale (old parity).
- Flashes with r≥150 or life≥0.3 (frags, shells, the player's muzzle) get a lazy polygon on first draw.
- Bodies (`VIS`, the player, drawn teammates) get up to 2 directional stamps, the `SHADSPR` ellipse rotated away from the lights, drawn in `gfxShadowPass` under the `DR` list.
- Budget: +0.2 ms a frame, at most 0.6 ms on a frame that bakes, 25 MB.
- Setting: LIGHTING HIGH. STANDARD skips the polygons.
- Risks: the lift band; breakable walls; bake hitches. All three are covered above.

**3. Animation pass** (inside `drawOp` and the death functions).
- Idle stays byte-identical to v23.58, so existing pixel checks hold.
- Walk: arms counter-swing, shoulders and hips counter-rotate. Curved hips still ride the jiggle spring, which is still fed by the bob only.
- Run: stride 5.4, torso tilt about 0.07 rad, both feet off the ground for 12% of the cycle, gun lowered as today. Moving backwards reverses the phase (velocity against facing).
- Recoil: the gun group goes 2.2 units back and 0.12 rad up × k, the shoulder 0.6. k comes from `p.recoil` (player) or `e.muzzle/.06` (pillagers), or from a new tracer origin (teammates).
- Hit flinch: torso and head about 1.5 units away from the shot plus a head tilt for 0.15 s.
- Downed: a lying figure (head, torso, legs, reaching arm, breathing) in the body's build.
- Death: humans fall. `drawOp('down')` rotates to the ground over 0.35 s, then fades into the `'body'` container. Machines keep the silhouette and get item 13.
- Budget: +0.1 ms. Setting: none (animation always on).
- Risks: BUILD bodies and jiggle must stay for every viewer (`st.build` passes through for pillagers and teammates); existing `__opShot` and `__spyOps` checks.

**4. Visible damage on machines.**
- Approach: each kind gets a plate list. A plate is drawn while `hp/maxhp` is above its threshold (75, 50 or 25%).
  - Below a threshold the plate is shed: a render debris piece (`fxn` velocity, z arc) that lands as a ground stamp.
  - Below 50%: sparks every 0.3-0.9 s.
  - Below 25%: a smoke column (baked puff sprites), fire flicker and an emissive.
- The shed stage lives in a render-side `WeakMap` and is monotonic. Everything derives from mirrored `hp`, so the linked window shows it too, with no new net messages.
- Hook: inside the 10 machine functions plus `gfxBodyFx()` in the air pass.
- Budget: +0.1 ms, at most 40 smoke sprites per machine.
- Setting: Effects and EFFECT INTENSITY.
- Risks: draws never touch `rnd` or `e.*`; emission only from render `dt`.

**5. Trauma screen shake.**
- Approach: a render-side trauma value rises with each rise in `G.shake` (about 1/30 per unit) and decays about 1.4/s. Offset = 14 px × trauma² × fxInt × smooth noise (3 sines with phases from `fxr` per raid).
- `ox/oy` carry it for every world layer (ground, light, fog stay aligned). No rotation, which would misalign the stretched sheets.
- `VX/VY` = the rounded unshaken camera. `w2s`, world text and the HUD stay steady. Aim is already unshaken.
- The arcade respawn (44779, 44844) resets trauma too.
- Budget: 0. Setting: EFFECT INTENSITY.
- Risks: none to the sim. `G.shake` writes are untouched.

**6. Hit pause (render-only).**
- Approach: on a rising `hitT` edge (render-side `WeakMap` of the last value), freeze the victim's pose for 60 ms (90 on a kill or damage over 40) × fxInt.
  - `drawOp` gets the cached `ph/face/moving`.
  - Machines read `entT(e)` in place of `G.t` (the 19 uses).
  - Jiggle is not stepped.
- Never the local player, never `NET.up` teammates (`netUpDrawOne` is a separate path), never in the sim (render does not run there).
- The existing jolt (`animHitShift`) still plays.
- Budget: under 0.02 ms. Setting: EFFECT INTENSITY.
- Risks: a sim field touched by accident. Use a `WeakMap`, never write `e.*`.

**7. Shot detail.**
- Muzzle flash on the first frame: `fireWeapon` pushes a shot event (`gfxShot`, `!G.sim`, no RNG). The next rendered frame draws a baked star sprite per weapon family at full alpha at the barrel tip, however large `dt` was. Teammates get one from new `G.fxBullets` origins; today `netUpDrawOne` passes muzzle 0 (41675).
- White hit flash: on the rising-edge frame only, the victim is redrawn into a shared scratch canvas (the global `wc` swapped with `finally`, the `ctx` precedent at 36859; shadows suppressed), filled white with `'source-in'` and stamped at 0.85×fxInt.
- Casings: settled brass is stamped into the ground and leaves `G.shells`. In-flight brass is view-culled.
- Wall marks: `wallMark(_struck,...)` after the existing `rnd(3,6)` at 22557-22561. South faces only. A `WeakMap` per wall (24 per wall, 1,500 total) is painted into the `WALLSPR` sprite and repainted on rebake. Zero cost per frame.
- Budget: −0.3 ms net (casings).
- Risks: the bullet branch's stream (add no draws).

**8. Post pass.**
- Bloom: `gfxEmit` registrations (lamp heads, flashes, fireballs, fire, sparks, tracers, `VIS` eyes) drawn into a canvas at 1/8 size, downsampled once to 1/16, both upscaled `'lighter'`. Composited **before the fog sheet**, so nothing glows through fog.
- Grade: a table keyed by time of day and weather `{mul, sat, lift}`, blended by `wxT`, using only `'multiply'` and `'saturation'` (never brightens). Applied after the fog and before pings, rings and world text, so the v10.79 floors and the rings stay true.
- Vignette: baked once per W,H, one `drawImage`.
- Grain: a 256² `fxr` noise tile made once, a pattern fill at 0.035 with a per-frame offset.
- Budget: +0.4 ms, +4 full-screen passes, −1 gradient.
- Setting: POST FX, EFFECT INTENSITY.

**9. Atmosphere.**
- Dust in lamp beams: about 5 motes per visible lamp at night and dusk, positions a pure function of `G.t` and the lamp index (no RNG). More in fog.
- Rain: splash rings at hashed (cell, floor(G.t·rate)) sites in view; streaks get two depth layers and a slant.
- Embers over burning machines, explosion remains (3 s) and lit pumpkins.
- Steam: COLD STORAGE refrigeration vents (roof sites picked by `grit` on cold's buildings) and overheated machine vents (20871).
- Fog banks: the 7 gradients become one baked sprite.
- Budget: +0.25 ms, −7 gradients. Setting: Effects.

**10. Baking.**
- Already baked: walls (v18.15), canopies (v18.16), shadows (v18.36).
- New bakes:
  - `drawContS` keyed by type, opened, camp, and a `grit` angle bucket for bodies and wrecks.
  - Ruins, wrecks and furniture as wall sprites.
  - Lamp housings.
  - Glow sprites (weak point, strongbox, cache, stray, door, windup) as tinted pre-baked discs drawn with alpha.
- All through the global `wc` swap. One store registry (`GFXSTORES`) is dropped in `onCtxRestored` (35382).
- Budget: −1 ms or more (measured by calls).
- Risk: a bake storm on a scale change. Mitigation: a per-frame bake budget with the old-scale sprite drawn scaled.

**11. Render scale.**
- `DPRH=min(dpr,2)` for `hcv` and `ctx` always. `DPR=DPRH·gfxScaleNow()` for `cv` only (24130-24136). `hudPrompt` (7762) and icons (32530) read `DPRH`.
- World text moves to the HUD canvas: `drawHUD` calls `_wtA/_wtB` after its clear and vignette, with `ctx` in the world transform, `wc` swapped. So it is sharp at any scale and steady under shake, and now draws over the rain.
- Auto becomes a ladder (`GFXQ`), stepped by `drsTick`: bloom off, then light map 0.5→0.33, then shadows off, then world scale (old DRS). The reverse on smooth frames.
- A covered window (`HID.fromWorker`) draws CLASSIC light with no post pass.
- Budget: saves. Setting: Render resolution and Auto resolution.

**12. Richer ground.**
- `scarStamp(kind,x,y,o)` paints into `G.ground` (1 px per unit, zero cost per frame, no new memory) and logs to `G.scarLog` (cap 6,000). The log replays after a rebake (35386).
- Contents: scorch sprite; 4-7 crack polylines (`fxn`); debris and shed plates; casings. Nothing on roofs (`roofAt`).
- Wetness `WET` eases toward `wx().rain` (20 s up, 90 s down). The light pass raises glow ×(1+0.8·WET) and lowers the ground ambient 6%: the wet sheen.
- Puddles: sites from `grit` on a 200-unit grid near drains, doors and yards. Outdoors, `spotFree`, not water. Built once per raid, render-only.
  - Baked puddle sprites drawn at alpha WET.
  - A lamp-colour streak for each lamp within 260.
- COLD STORAGE dressing baked into `bakeGround` (live only, cold only, no RNG): aisle paint in the PACKING FLOOR racking, frost near freezer rooms, oil and tyre marks on the SCRAP LINE, drains.
- Budget: +0.1 ms.
- Risk: flat only. Hills and verticality are never added; nothing gets a collider.

**13. Bigger explosions.**
- `boomFx(x,y,size,kind)`, a render list capped at 6:
  - Fireball: 3 baked radial sprites, scaled over 0.35 s.
  - Shockwave: a stroked ellipse growing to 1.4R in 0.22 s.
  - Smoke column: 8-14 baked puffs rising with drift, 2.5-4 s.
  - Flying debris: 8-16 pieces with z arcs that land as stamps.
  - Plus an emissive, the existing `flash()` (now coloured and shadowed), scorch and cracks.
- Hooks: frag (14194, 14426), howler shell (14308, 14370), machine death via `gfxOnDeath` inside `deathAnimAdd`, which also runs on the linked window (43477). Size by kind: crawler 0.6, Warden 1.8 plus secondary pops.
- Budget: at most 0.3 ms peak. Setting: Effects.

**14. Loot glow.**
- Rarity colour (`RCOL`, 2384) only where the contents are known:
  - Dropped crates (`c.dropped`, 15797).
  - Opened containers with loot left: `c.loot` and `bestRarity`.
  - Caches, as today.
- A baked ground disc plus a lit lip, pulsing. Unopened boxes keep amber.
- Rare or better: an additive beam sprite (the 27495-27505 shaft style), 140 units, only when `canSee` from the player. Drawn before the fog.
- Budget: +0.05 ms.
- Risk: **his 2026-08-26 ruling.** The v8.99 2,691 px leak test becomes a check.

**15. TV readability.**
- At 4K: `FXK=1+0.25·clamp(hudRes()-1,0,1)` on tracer, ring and spark widths. A baked soft dark contrast halo behind every `VIS` actor and the player.
- LARGE FOR TV:
  - World text ×1.3.
  - `hudText` outline ×1.5 (7740).
  - Reticle ×1.25.
  - The user-scalable panels (`HUDZ` body, gear, raiders, legend, cond) +25% about their own anchors.
  - Status icons, heal ring, belt, use bar and Overseer bar: boxes unchanged.
- `hudRes` is untouched: it drives the world projection (24207).
- Budget: +0.05 ms.

---

## 3. Builds (45), in 6 batches

**Shared rules for every build.**
- One behaviour per build.
- Hooks in sim code are `if(!G.sim)` and use `fxn/fxr/grit` only. Never `rnd/rr/ri/pick`.
- After every edit: `node --check` on the extracted script, `mkfixture`, then `gate.ps1` (parse; the check passes twice on the dry build; FAILS, not SKIPs, on the control). `-Fix` runs `__verifySafe`: the seed 4242 fingerprint, ents 85/374, containers 165/593.

**Helpers added in gfx1 (fixture side, mkfixture):**
- `__gfxCount(ctxs,names,fn)`: own-property stubs, deleted in `finally`. Also counts full-screen passes and gradients.
- `__gfxStage(o)`: `__topClear(); __runPrep(); arcadeDeploy({mapIx:0,seed:4242,cond})`, or `__deploy` for a plain raid. Weather (`g.wx=WEATHER.find(...)`, `g.wxNext=null`), `g.tod`, size (`__forceSize`, `__pinDPR(1)`), placement (`g.player.x/y`, `G.anchX=undefined`), `arcSh=0`, N `__loop` frames.
- `__gfxProbe(o)`.
- `__shot4k(name)`: composites `cv`+`hcv` and POSTs to the capture sink on 8779.

**Parallel layout.**
- Wave 1: A, sequential.
- Wave 2: **B, C, D, E and F1 in parallel.** A pre-places every hook line, so each batch edits only its own function bodies and owned lines.
- Wave 3: F2.
- Each batch works in its own git worktree with its own shard port (8803-8810) and its own CDP port and profile.
- A creates marker blocks in `__REGRESS` (`// ==== GFX-B checks ====` and so on) and empty `// ===== GFX-x =====` sections above `render2D`.
- Batch checks use `v:'gfxN'`. The integrator merges B, C, D, E and F1 in order, assigns versions (v23.59 and up, after the map-freeze build) in the three version strings, renames `v`, writes the DESIGN entries and reruns the gates.

### Batch A: Foundations (wave 1, sequential)
Owns: `resize` (24129-24159), the camera block (26094-26116, hook only), `drawHUD` head (28827-28833), `loop` (35549-35551), `onCtxRestored` (35382), GAMEOPTS (47913), mkfixture helpers.

- **gfx1 Frame telemetry.**
  - Change: per-pass timers (`GFXP`, sampled 1 frame in 15). `G.tel.gfx {n,p50,p95,slow,q}` from the loop gap on real live frames, in the export.
  - Check: `__gfxStage({frames:90})` gives `g.tel.gfx.n>=60` with p50 between 10 and 30. A `__startRaid({sim:true})` raid has no `tel.gfx`. Old: undefined.
- **gfx2 Hook scaffold and store registry.**
  - Change: stub hooks in `render2D`. The lighting `if/else` wrap. Sim-side stubs: `gfxShot` (15646), `wallMark` (22560), `boomFx` (14194, 14308, 14370, 14426), `gfxOnDeath` in `deathAnimAdd` (which now stores `kind`), `scarStamp`, `gfxEmit`, `gfxWet`. Registry dropped on context restore.
  - Check: spy each hook, each called once per `__frame`. A frame's `wc` pixel hash is identical with `GFX.bypass=1`. A fake `onCtxRestored()` empties registered stores. Old: hooks missing.
- **gfx3 Settings rows.**
  - Change: the four rows above, `def` HIGH/ON/FULL/STANDARD.
  - Check: `__opts.rows()` has `gfxLight`, `gfxPost`, `fxInt`, `hudTv` with those defaults. `__opts.cycle('gfxLight')` gives 2→1→0→2. Old: rows absent.
- **gfx4 HUD canvas at native resolution.**
  - Check: `__pinDPR(1); __cfg({gfxScale:0.5}); resize()` gives `hcv.width===W` and `cv.width===round(W*.5)`. Old: `hcv.width===W*.5`.
- **gfx5 World text on the HUD canvas.**
  - Check: `label(p.x,p.y,'ZQX GFX5','#fff')`, then trace `fillText` on `wc` and `ctx` across a `__frame` plus `drawHUD`: the label is on `ctx` only, and its device font px at scale 0.5 equals the full-scale value. Old: drawn on `wc`.
- **gfx6 Quality ladder and bake budget.**
  - Check: drive `drsTick(40,t)` for 2.5 s simulated: `GFXQ.post===0` and `DRS.scale===1`. Three more slow periods and only then `DRS.scale<1`. Over 300 walls first-seen in one frame, at most 6 baked. Old: no `GFXQ`, scale drops first.

### Batch B: Light and shadow (wave 2)
Owns: 27512-27665 (else-branch untouched), 34778-34804, the lamp block 10962-11011 (cold only), GFX-B, `gfxShadowPass`.

- **gfx7 Coloured light map** (raid and Undercroft).
  - Check: night `__gfxStage`, `getImageData` on `cv`. At a point 400 or more units from any lamp, luminance HIGH vs CLASSIC within 4%. At an orange lamp centre, (R−B) under HIGH is at least 12 above CLASSIC. Old: the setting is ignored, difference 0.
- **gfx8 Lamp cookies with lift-aware shadows.**
  - Check: find a lamp, a wall and a floor point Q with the wall between within r·0.7. Q is at least 15% darker in HIGH than in STANDARD. A front-face point (W.y+W.h−10) is at least 0.8× STANDARD. `LCOOK.n<=96`. After `rebuildGeometry()` the key changes. Old: no `LCOOK`.
- **gfx9 Dynamic coloured lights** (flashes, beacon, rings, eyes, pumpkins).
  - Check: an open zone in view at night: the centre pixel has G−R ≥10 under HIGH and <5 under CLASSIC. Old: fails.
- **gfx10 Flash shadows.**
  - Check: a flash north of a wall. The gain at Q south of the wall is at most 25% of the gain at a mirrored open point. `rayHit` calls on frame 2 = 0 (cached `F.poly`). Old: fails.
- **gfx11 Body shadows from lights.**
  - Check: a raider 40 units east of a lamp. `drawImage` of a `SHADSPR` canvas centred at dx>4 from his feet. Removing the lamp removes it. Old: fails.
- **gfx12 COLD STORAGE light placement.**
  - Change: authored sets, no RNG, live only. Cold strip lights over the `cs_pack` aisles, flicker in `cs_sump`, floods on `cs_scrap`.
  - Check: map 0 live `G.lights` has lamps inside the `cs_pack` rect along aisles. Map 1 is unchanged. `__startRaid({sim:true})` keeps `G.lights` empty. Old: fails.

### Batch C: Bodies and machines (wave 2)
Owns: `drawOp` and builds (24596-25263), death animation (25278-25311), machines (25315-25703), entity dispatch (27065-27154, minus A's `gfxActorPre` line), the ghost (27201-27214), GFX-C.

- **gfx13 Walk and run cycle.**
  - Check: `__opShot` idle for lean, broad and curved has the same pixel hash as `CFG.gfxAnim=0` in the same build. A sprint at ph 0 vs π moves the support-hand x by at least 1.2. Old: the hand is static.
- **gfx14 Gun recoil.**
  - Check: `drawOp` with `st.recoil:1` vs 0. The barrel `fillRect` device x (through `getTransform`) moves back at least 1.5. Old: fails.
- **gfx15 Hit flinch.**
  - Check: `hurt:.16`, `hitDir` set. The head plate is offset at least 1 unit. Old: fails.
- **gfx16 Downed pose.**
  - Check: mode `'down'` issues 10 or more fills (old 4). Curved is wider at the hip row than lean.
- **gfx17 Human death fall.**
  - Check: `deathAnimAdd(raider)`, spy 3 frames. `drawOp` called with `'down'` with a `wc.rotate` between. Old: ellipse only.
- **gfx18 Hit pause.**
  - Check: two walking raiders, set `r1.hitT=.16`, 3 frames with `G.t+=.016`. r1's `ph` is identical across frames; r2's changes. A mocked `NET.up` teammate's `ph` changes. Paired sim: `__sim(.05)`×20 with fxInt 1 vs 0 gives identical `e.x/e.y/e.hp/G.t`. Old: r1 changes.
- **gfx19 White hit flash.**
  - Check: `drawImage` of the `HITSIL` scratch onto `wc`: 1 on the edge frame, 0 on the next. Old: fails.
- **gfx20 Armour plates and shedding.**
  - Check: a sentry at 100% vs 30% differs by the expected plate fills. 80%→70% creates exactly 1 debris piece. Old: fails.
- **gfx21 Damage sparks, smoke and fire.**
  - Check: a sentry at 20%, 60 frames: `RSMOKE` has 8 or more. At 90%: 0. Old: fails.

### Batch D: Shots and ground (wave 2)
Owns: the shells draw (26239-26247) and update (35789-35800), `wallSprite`/`wallPaint` (25979-26068), `bakeGround` (cold dressing), the bodies of `gfxShot`/`wallMark`/`scarStamp`/`gfxWet`, GFX-D.

- **gfx22 Ground stamps with replay.**
  - Check: `scarStamp('scorch',x,y,{r:20})` darkens the `G.ground` pixel by at least 20. After `G.ground=bakeGround(G.map); gfxScarReplay()` it is dark again. Old: fails.
- **gfx23 Casings pile up.**
  - Check: 60 shots then 2 s: no settled brass left in `G.shells`, 0 shell draws a frame, brass-hued ground pixels at the landing points. Old: 300 drawn every frame.
- **gfx24 Muzzle flash on the first frame** (including teammates).
  - Check: `fireWeapon(p,...)`, `__sim(.05)` twice (muzzle spent), then `__frame`: `MUZSPR` drawn once at alpha 0.9 or more. Old: fails.
- **gfx25 Wall bullet marks.**
  - Check: shoot a wall to the north. The sprite pixel at the mark is darker. Flush `WALLSPR` and rebake: still dark. Old: fails.
- **gfx26 Scorch, cracks and debris.**
  - Check: `explodeFrag` darkens a 12-unit radius. 500 decals later (cap churn) it is still dark. Old: fails.
- **gfx27 Wetness and wet sheen.**
  - Check: storm plus `__sim` 25 s gives `WET>0.6`. The glow composite alpha is higher than at `WET=0`. Clear weather decays. Old: fails.
- **gfx28 Puddles and lamp reflections.**
  - Check: `WET=1` gives more than 0 puddle draws and a streak for a puddle near a lamp. `WET=0` gives 0. Old: fails.
- **gfx29 COLD STORAGE ground dressing.**
  - Check: `bakeGround` on cold vs `CFG.gfxDress=0` differs by at least N px inside the `cs_pack` rect. Map 1 is identical. Old: fails.

### Batch E: Effects and atmosphere (wave 2)
Owns: the `drawContS` pulse (25858-25867, one line: dropped crates skip amber), weather (27831-27899), GFX-E, the bodies of `boomFx`/`gfxOnDeath`/`gfxContPost`/`gfxAir`.

- **gfx30 Explosion module.**
  - Check: `explodeFrag` gives `BOOMS.length===1` with 8 or more debris. The fireball sprite is drawn at +0.1 s and smoke at +1.5 s. Old: fails.
- **gfx31 Machine death blasts.**
  - Check: `deathAnimAdd(sentry)` adds one at size 1. `deathAnimAdd(raider)` adds 0. Old: fails.
- **gfx32 Loot glow for known contents.**
  - Check: drop an elite item and the elite sprite is drawn. An unopened container with `best` common vs elite gives identical pixels (the v8.99 test). Old: fails.
- **gfx33 Rare drop beam.**
  - Check: an elite drop in sight gets a beam draw. Behind a wall (`canSee` false): none. Old: fails.
- **gfx34 Dust in lamp beams.**
  - Check: night at a lamp gives 5 or more mote draws; noon gives 0. Old: fails.
- **gfx35 Rain splashes and streak layers.**
  - Check: storm gives more than 20 splash draws a frame; clear gives 0. Old: fails.
- **gfx36 Embers and steam** (cold vents).
  - Check: map 0 `GFXVENTS.length>0` with steam draws more than 0 in view. Map 1 has 0 vents. Old: fails.
- **gfx37 Fog banks baked.**
  - Check: a fog raid's warm frame has 0 `createRadialGradient` on `wc` from that pass (old: 7).

### Batch F1: Shake, vignette and grain, TV (wave 2, disjoint lines)
Owns: 26114-26116, 44779/44844, 28831-28833, `hudText` (7736-7744), FX widths at 27431-27444 and 27761-27824, GFX-F, `gfxActorPre`.

- **gfx38 Trauma shake, world only.**
  - Check: `G.shake=9`, 10 frames. `w2s(p.x,0,p.y)` stays constant. The ground `drawImage` destination offsets are nonzero, with frame-to-frame change at most 40% of the amplitude. A second hit raises trauma. Old: `w2s` moves.
- **gfx39 Baked vignette and film grain.**
  - Check: `ctx` gradients per frame = 0 (old: 1). POST ON gives a pattern fill on `wc`; OFF gives none.
- **gfx40 LARGE FOR TV preset.**
  - Check: trace the boxes of `drawStatusIcons`, `G.hotCells`, `drawUseBar` and `drawBossBar` (stage a Warden boss) with `hudTv` 0 and 1: identical. Nameplate font px ×1.25 or more. Old: no row.
- **gfx41 4K effect sizes and actor halos.**
  - Check: at 3840×2160 the tracer `lineWidth` is 2.5 or more (old 2). Halo draws = `VIS.length+1`.

### Batch F2: Bloom, grade, bakes (wave 3, after the merge)
- **gfx42 Emissive bloom.**
  - Check: night lamp: pixels 12 units outside the head are brighter with POST ON than OFF. Added calls at most 12 plus emitters.
- **gfx43 Colour grading.**
  - Check: same scene, storm vs clear: mean saturation drops 10% or more. CLASSIC plus POST OFF are unchanged. Fog-sheet luminance is not higher.
- **gfx44 Baked props** (containers, ruins, wrecks, furniture, lamp housings).
  - Check: a warm frame on the PACKING FLOOR has 40% or more fewer `roundRect`+`fillRect` calls than `wallBake 0`. Baked crate vs live paint pixel difference at most 2%.
- **gfx45 Glow sprites.**
  - Check: warm frame with a sentry in view: `wc` gradients at most 2 (old: 4 or more).

**Then a fixture-only commit: the 4K perf gate.**
- Scene: 3840×2160, arcade map 0 seed 4242, night storm, all HIGH.
- Limits: calls at most 1.25× CLASSIC + 300; full-screen passes at most 14; `wc` gradients at most 10; `getImageData`/filter 0; script ratio HIGH/CLASSIC at most 1.6.
- Also run as two iframes, the nettest pattern.

---

## 4. Screenshot plan (4K, arcade raids on COLD STORAGE)

**Tools:**
- `tools\start-servers.ps1`: 8800 fixture, 8779 capture sink (`capture.ps1` writes POSTed base64 to `tools\shots`, flattening names).
- `tools\cdp.ps1`:
  - `-Start`: headless Chrome 1920×1080 on port 9333 with its own profile.
  - `-Open URL`, then `-Match 8800/fixture -Expr "__gfxShot('S2','after')"`.
  - `-Shot path.jpg` saves only a 1920×1080 viewport JPEG at quality 70 (header lines 1-10 and 48-61). Use it for a quick look only.
- The 4K PNG comes from `__shot4k`: `__forceSize(3840,2160)`, `__pinDPR(1)`, compose `cv`+`hcv`, POST `gfx_<batch>_<scene>_<before|after>_<ver>.png`.
- "Before" uses the control fixture (`mkfixture -Src <previous rev> -Dst tools\fxctlNN.html`); "after" uses the dry fixture. Same staging, same frame counts.

**Scenes.** All `arcadeDeploy({mapIx:0,seed:4242,cond})`, `arcSh=0`, frames advanced with `__loop`:

| Scene | Content |
|---|---|
| S1 | Spawn, night, clear |
| S2 | PACKING FLOOR racking aisle, night (lamps, shadows, front faces) |
| S3 | S2 at noon and at 6pm (grade) |
| S4 | SCRAP LINE in a storm, 30 s after the turn (puddles, splashes, sheen) |
| S5 | THE SUMP, fog at dusk (motes, banks, steam vents) |
| S6 | Firefight with a sentry at 60%, then 20% (plates, smoke). Player firing: first-frame muzzle and recoil. Wall marks after 30 shots, casings after 60. Shake sequence of 6 frames |
| S7 | Frag at +0.05, +0.2, +0.6 and +2.0 s, then the ground after |
| S8 | Loot: dropped elite crate, opened locker with a rare left, unopened crate, cache |
| S9 | `__opShot` grid at zoom 9: lean, broad, curved × idle, walk, sprint, ADS+recoil, hurt, down. Raider death-fall frames |
| S10 | HUD STANDARD vs LARGE FOR TV with status icons, belt, use bar and Overseer bar (stage a Warden boss) |
| S11 | Render resolution Low: crop of a nameplate and the HUD for text sharpness |
| S12 | DEMO co-op: `arcadeDeploy` host plus `{role:'p2'}` in two fixture iframes, one shot from each |

**Per batch:**
- A: S1, S10, S11.
- B: S1, S2, S3, S5.
- C: S6, S9.
- D: S4, S6, S7.
- E: S4, S5, S7, S8.
- F1: S6 (shake sequence), S10, S11.
- F2: the full set, plus 1080p copies of S1 and S10 for parity.

---

## 5. Risks and how each is avoided

1. **Seeded world or sim drift.**
   - No new code calls `rnd/rr/ri/pick`. A lint check greps the GFX sections.
   - Sim-side hooks are `!G.sim` and only record. The bullet branch keeps its `rnd(3,6)`.
   - Lamp and cold dressing stay in the live-only, `fxBorrow`-or-no-RNG paths.
   - `__verifySafe` runs on every gate: 85/374 and containers 165/593, plus live-vs-sim parity.
2. **Information under the fog.**
   - Light, bloom, glow, beams and body shadows all composite before the fog sheet and use `VIS` / `canSee` gating, the v8.85 precedent.
   - A check renders a scene with and without an unseen pillager behind a wall: zero pixel difference.
   - Light never feeds the sim (DESIGN 11554).
3. **His night-brightness rulings.** Ambient is calibrated to the old sheet. The luminance-parity check (gfx7) runs at day and night. The grade only darkens or desaturates.
4. **Frame cost at 4K and shared-thread co-op.**
   - Budgets above, the M1/M2 checks, and the final perf gate.
   - `gfx1` telemetry from his own PC.
   - The quality ladder sheds post and light resolution before world resolution. A covered window draws cheap.
5. **Bake storms and memory.**
   - Per-frame bake budgets; LRU caps (cookies 96, wall marks 1,500, scar log 6,000).
   - Ground stamps reuse `G.ground` (57 MB on COLD STORAGE), no new big canvases.
   - Every store goes in the registry dropped on context restore (35382).
6. **The wall lift band and his ban on hills.** Lift-aware cookies; ground marks are flat; nothing new gets a collider. Vertical smoke and beams are effects, not terrain.
7. **BUILD bodies and jiggle seen by all.**
   - Idle stays byte-identical. The spring is fed by the bob only.
   - Pillagers and teammates keep `st.build`. The see-through ghost reuses the frame's pose (24607).
8. **HUD items that must stay put.** Status icons, heal ring, belt, use bar and Overseer bar are pinned by the gfx40 box check. Shake never touches `ctx`. `hudRes` is untouched.
9. **Hit pause touching the sim or the teammate.** A `WeakMap`, no `e.*` writes. Excludes the local player and `NET.up`. The paired-sim check.
10. **Existing frame-cost and pixel checks** (18.15, 18.16, 18.36, 18.03, the v10.79 floors, v8.99). New visuals are `drawImage` stamps, not fills or arcs. The grade sits before the rings and labels. `litC` stays for the Undercroft and the 18.03 sizes. The full corpus (`__regressBg` shards) runs per batch.
11. **Render-scale semantics.** All 11 uses of `DPR` audited (`hudPrompt` 7762, icons 32530, `REC` 35239). World text moves to `ctx` with the `wc` swap in `finally`. Mouse coordinates are CSS pixels, so aim is unaffected.
12. **Arcade and DEMO.**
    - Cookie keys include `c` and `i` (the `arcadeHallow` recolour).
    - Pumpkins become lights. Respawn resets trauma.
    - Effects derive from mirrored fields (`hitT` flags, `hp`, `deathAnimAdd` from the death word), so player 2 sees them with no new net messages.
13. **Parallel merge conflicts.** Wave A's hook scaffold, owned line ranges, marker blocks in `__REGRESS`, and version and DESIGN entries assigned only by the integrator.
14. **Loot ruling.** Unopened boxes never show rarity. The v8.99 pixel test is in gfx32. He confirms dropped and opened glow.
15. **Photosensitivity and comfort.** EFFECT INTENSITY scales shake, pause, white flash, bloom and grain. Lightning and the nuke stay as they are (gameplay).
16. **His standing rulings.** No raid music; no audio is touched. Guns never wear or jam, so there is no wear visual and no jam animation; recoil is cosmetic only. Hills and verticality are never added.

### Critical files for implementation
- `C:\claudecode\dark raiders\dark_raiders.html`: `render2D` 26069-27963, `drawOp` 24668-25263, machines 25315-25703, `resize`/DRS 24099-24159, `drawHUD` 28827, `loop` 35528-35818, GAMEOPTS 47868-48012.
- `C:\claudecode\dark raiders\tools\mkfixture.ps1`: `__REGRESS` from 1348, helpers (`__deploy` 60922, `__forceSize` 158, `__verify` 1221).
- `C:\claudecode\dark raiders\tools\gate.ps1`.
- `C:\claudecode\dark raiders\tools\cdp.ps1` and `C:\claudecode\dark raiders\tools\capture.ps1`.
- `C:\claudecode\dark raiders\DESIGN.md`: frame-cost entries v18.01-v18.48 around 42575-42820.