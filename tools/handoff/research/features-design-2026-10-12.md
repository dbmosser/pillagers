# PILLAGERS: the next features, arcade first. A design (read only, nothing was edited)

**File:** `C:\claudecode\dark raiders\dark_raiders.html` (HEAD v23.58). All line numbers are at HEAD.
**Fixture:** `C:\claudecode\dark raiders\tools\mkfixture.ps1`. Note two things in it:
- `tickAmbience` is replaced with a no-op at line 1117, so no new sound logic may live inside `tickAmbience`.
- `__startRaid` (line 242) sets `P.mapIx` directly, so the mile fingerprint still builds after the map is hidden from the pickers.
- The fixture's `AudioContext` throws, so `ac()` returns null. The sound checks below install a fake context in `AC`.

The coordinator's mode design of 2026-10-12 is folded in. It replaces item 0 and changes how items 1 to 6 land.

---

## PART 0. The frame: his mode design, and the open questions

**DEMO** is the current arcade (1P and 2P), changed in three ways:
- Raids last 10 minutes.
- Extraction doubles the score and takes that player out of the raid.
- The run ends when nobody is left in the raid or the clock runs out.

Everything else stays: the sandbox (his save is never written), the party board, the attract loop, initials, idle return and the operator lock.

**CAREER** replaces the old extraction modes. It is the normal raid: from the Undercroft, with his real save, his stash and his kit. On top of that it adds:
- the arcade score layer (kill points, streaks, popups, a SCORE readout)
- a 10-minute clock
- the score doubled on extraction
- the score turned into credits at the settle

The Undercroft itself stays frozen. CAREER only adds lines to the outcome card.

**The bigger map is THE COLD MILE** (9000×7600, against COLD STORAGE at 4200×3400; `cols*cw` = `w`, line 7398). It is hidden from every picker but kept in code.

### Open questions for him (each has the default I recommend)

| # | Question | Recommended default |
|---|---|---|
| O1 | Does CAREER respawn you? | **No.** A death ends the raid as today: coming back empty, your kit is lost. |
| O2 | CAREER loadout | **His own packed kit**, as today. No random kit. |
| O3 | How the CAREER score becomes credits | **Credits = combat score × 2 on extraction, at a rate of 1.** Loot is still paid through the stash, as today, so nothing is paid twice. A death or an abandon converts **0**. |
| O4 | Does loot count in the CAREER score? | **Yes, at its found value, for the high score only.** It is not converted to credits (O3). |
| O5 | CAREER clock reaches 0 | **The burn, as today** (death unless you are boarding). |
| O6 | Arcade extras in CAREER (waves, spawn shield, half damage, quick heal) | **Off.** Waves draw the seeded stream mid-raid. Rings never close in either mode. |
| O7 | DEMO clock reaches 0 | **The run ends, TIME UP.** The score is kept at ×1 and there is no death. |
| O8 | DEMO 2P extraction | **Per player.** That player's own score ×2 and he is out. The run ends when both are out or at TIME. |
| O9 | DEMO death penalty on the score | **None.** He respawns as today; the clock is the cost. |
| O10 | PvP row | **Under CAREER, rules unchanged** (no score layer). |
| O11 | DEMO board rows from the endless era | **Dropped once with a new scale tag** `u:'t10'`, as arcade32 did. |
| O12 | Row words | **1 PLAYER DEMO, 2 PLAYER DEMO, 1 PLAYER CAREER, 2 PLAYER CAREER (SAME MACHINE), 2 PLAYER PVP (SAME MACHINE).** |
| O13 | Arcade stings (extract, streak, NEW HIGH SCORE, wave) | **Kept as cues of 1.2 s or less**, at most 4 notes, never looped, so they read as sound effects, not music. He should confirm they do not break his "no raid music" ruling. |

---

## PART 1. The features: model, code sites and risks

### Feature 0. The title (DEMO and CAREER), the clock and x2, CAREER, the hidden map

**0.1 The title** (HTML 1278-1290; CSS 728-735 and 114-119)

New row order inside `#modemenu`:
```
<div class="modehead" id="mhdemo">DEMO <span>PARTY · HIGH SCORE · 10 MIN</span></div>
  #modearcade1 "1 PLAYER DEMO"   (primary style: today's #titlestart look, padding 13px 46px, 15px)
  #modearcade  "2 PLAYER DEMO"   (ghost)
<div class="modehead" id="mhcareer">CAREER <span>YOUR SAVE · THE UNDERCROFT</span></div>
  #titlestart  "1 PLAYER CAREER" (ghost; data-mode solo; still runs go(), the Undercroft)
  #modecoop    "2 PLAYER CAREER (SAME MACHINE)"
  modelater #modecoopsrv (greyed), #modepvp, modelater #modepvpsrv (greyed)
```
- **Every id stays**, so `netTitleInit` (40785-40803) and `netTitleRows` (40805) still find every row.
- **New CSS:** `.modehead` (10.5px, letter-spacing .3em, amber, margin-top 10px). The max-height rule at line 118 moves from `#titlestart` to `#modearcade1`.
- **P2 window:** add `mhdemo` and `mhcareer` to the P2 hide list at line 40789. In that window only `#titlestart` ("ENTER THE UNDERCROFT", 40798) is left.
- **Default focus:** the padMenu title line (13089) becomes: focus `#modearcade1` when it is in the list, else `#titlestart` (the P2 window).
- **ENTER on the title:** `netTitleEnter` (40827) with no focused row clicks `#modearcade1` when it is shown, else `startFn`. A focused `#titlestart` still runs `startFn`.
- **Names:** `netModeName` (40502 area) returns `2 PLAYER DEMO` while `ARCADE.on`.
- **Fit:** `titleFit` (46436) re-measures on its own (ResizeObserver, 46457). The two labels add about 40 px.

**0.2 The DEMO 10-minute clock** (arcade section)
- Keep `ARCADE_CFG.raidSec:0` (44481) for the **build**. The build then stays exactly as today's arcade build (no ring schedule, `closeAt` undefined, line 44700).
- In `arcadePostBuild` (44699), replace `g.raidLen=0; g.timeLeft=0` with `g.raidLen=g.timeLeft=ARCADE_RAID_SEC (600)`. `raidClockOn()` (6259) is then true: the clock counts down (35628) and the warnings fire (`tickClockWarn`, 35632).
- Player 2 builds the same way. The host's clock reaches player 2 through `wd` `tl` (42891/42905) and the late word (41352/41383).
- **Clock at 0 in an arcade raid.** At 35641, before both burn branches, add:
  `if(G.arcade&&raidClockOn()&&G.timeLeft<=0&&!_boarding){ G.timeLeft=0; arcadeTimeUp(); }`
  - A pull that is boarding finishes as today.
- **`arcadeTimeUp()`:**
  - On the run authority (`arcadeBoardAuth`, 45874): `arcadeRunEnd('time')` (45721), which shows RUN OVER with a `TIME UP` header.
  - On player 2: freeze (`holdT`), show `TIME`, and wait for `arcend` (`arcadeEndTake`, 45762).
  - The site never burns in DEMO.
- **HUD:** `arcadeScoreHud` (45194, called at 29113) also draws the clock in m:ss under SCORE, red under 0:45, matching the 29107 rule.
- **Rebuild:** `arcadeRebuild` (45635) carries `G.timeLeft` into the rebuilt raid, so player 2 joining late never resets the clock.

**0.3 DEMO extraction ×2** (`arcadeExtracted`, 44824-44847)
- Replace `mine += ARCADE_XBONUS + pot` with `ARCADE.mine = (ARCADE.mine|0) * 2`.
- Remove the pot entirely: 44724, 45074 (`arcadeLoot` keeps only `mine += n`), the HAUL line at 45247, and the haul line in the HUD.
- The banner becomes `EXTRACTED!` / `SCORE x2` / `SCORE $N` (45244-45249).
- **No re-drop.** Remove `arcadeRedropSpot` and the kit call. Instead set `ARCADE.xOut=1`, `p.specOut=1` and freeze him.
- When the banner ends (3 s) and nobody is still in, the authority runs `arcadeRunEnd('extract')`.
- **2P:**
  - Player 2 extracting runs `arcadeP2Out('extract')` (45770), and its `arcleft` carries `x:1`.
  - The host extracting puts the host's attract up with `EXTRACTED · WAITING FOR PLAYER 2` (`arcadeAttStrip`, 45479).
  - `arcadeBenched()` (45609) must return **false** when `ARCADE.xOut`, so a press never un-benches an extracted player 1.
  - `arcadeIdleTick` (45697) and `arcleft` (45408) end the run when the host is out and the mate is gone.
- `arcadeScSend('x', …)` keeps telling the mate. The callout becomes `PLAYER 1 EXTRACTED x2`.
- **Board:** `arcadeBoardPut` (45876) tags rows `u:'t10'`, and `arcadeBoardLoad` (45835) drops the old tags once (O11).

**0.4 CAREER raids** (normal raids, his save)
- `CFG.career` (in DEF at 2073, default 1, so a dial can switch it off for A/B and for old checks).
- **Post-build hook** in `startRaid` right after 11759:
  `else if(G&&!G.sim&&CFG.career!==0&&!ARCADE.on) careerPostBuild(G);`
  It sets:
  - `G.career=1`
  - `G.raidLen=G.timeLeft=CAREER_SEC (600)`, done after the build so the ring schedule and the seeded draws do not move
  - `closeAt=undefined` on every zone (O6)
  - `G.cs={s:0,k:0,streak:null,loot:0,paid:0}`

  `runSim` (23885) calls `buildRaid(true)` directly, so the bots never become CAREER.
- **Scoring.** Split `arcadeKill` (45141) into a shared core `scoreKill(st,k,el,boss,x,y)` that holds the streak, popup and callout logic, with state passed in.
  - `arcadeKill` passes `ARCADE`; the new `careerKill` passes `G.cs`.
  - Call sites: 20431 (host credit) and 43834 (player 2 kill word): `else if(G.career) careerKill(...)`.
  - CAREER loot counts into `G.cs.loot` at its value in `grantLoot` (16475/16476). The items still go to the backpack (O4).
- **HUD:** at 29113, CAREER draws the normal clock and then a small `SCORE $N` line under it (`careerScoreHud`).
- **Clock at 0:** the burn, unchanged (O5).

**0.5 CAREER settle** (`endRaid`, beside hazard pay at 23293-23305)
- Add `if(G.career&&!G.sim) careerSettle(how,lines,haul);`:
  - **extract:** board score = (`cs.s` + `cs.loot`) × 2, and `P.credits += cs.s*2*CAREER_CR` (O3). Card line: `CAREER SCORE $N x2 · +$M CREDITS`.
  - **dead or abandon:** board score ×1, 0 credits. Card line: `CAREER SCORE $N · NO PAY`.
  - Keep `P.careerBest` and a top 10 `P.careerBoard` in his save. Add `NEW CAREER BEST` when it beats the best.
- The coming-back-empty rule stays the existing death settle, so the kit is still lost.
- In co-op, each window converts its own score into its own save. Both windows run `endRaid` on their own.

**0.6 Hide THE COLD MILE** (kept in code)
- `mapOffered` (6491) becomes `!m.frozen&&(!BETA_ONE_MAP||m.beta===1)`, with `frozen:1` on the mile entry (6637).
- **What hiding it reaches:**
  - the profile-load migration (3220) moves `P.mapIx` from 1 to 0 once
  - the lift (34093/34190)
  - the sector-card click (47055)
  - `offeredCount` (47224)
- **Code to add:**
  - `renderSector` (47004) skips maps that are not offered.
  - `sizeTag` (46919) measures offered maps only, so there is no tag.
  - The profile import at 38826 gets the same guard.
  - `arcadeEnter` (45353) sets `ARCADE.mapIx` to `firstOfferedMap()` when the saved index is not offered.
  - `arcadeDeploy` (44716) still honours an explicit `o.mapIx`, for the fixture.
- **What stays:** `netUpStart` (41303) follows the host word. Do **not** guard `buildRaid` (10496) or `startRaid`: the fixture's 374/593 mile fingerprint builds through `__startRaid`.

**Risks**
- Checks that will need new baselines:
  - the title default focus and ENTER = start checks (v14.26, v15.76)
  - checks matching the row texts `1 PLAYER`, `…ARCADE DEMO` (v23.24 arcade5, v23.54)
  - arcade2's `raidLen===0` / `!raidClockOn()`, and its tail check of `raidLen` 540 on a plain `__deploy`
  - arcade4's +2,500 and re-drop
  - sector-page checks that click the mile card (v15.86), and the sizeTag check (v7.54)
  - every check that asserts normal-raid settle credits. Those pin `CFG.career=0` in `__pinDefaults`.
- With a clock, AI that keys off `timeLeft` now runs in DEMO (for example the raider extraction timing). This is low risk; soak it.
- The migration rewrites his saved `P.mapIx` once, on load. That is the same mechanism BETA already uses.

### Feature 1. The tripwire mine

**The model**
- **Item:** `ITEMS.trip={name:'Tripwire Mine',val:160,wt:1,r:'uncommon',c:'#ff4a4a',use:'throw',tk:'trip'}`, appended after `frag` (2379). It is appended last, so the peddler's ITEMS walk (10083) and every other walk are unaffected.
- **Belt:**
  - `THROWKEYS=['smoke','decoy','frag','trip']` (2559).
  - `cycleThrow` uses `%THROWKEYS.length` instead of `%3` (13900).
  - `hotbarSlots` (16958) derives the trip cell **only while `G.pouch.trip>0`**, so a raid without one keeps today's belt.
  - If the derived list is already 9 long (a plate is carried), the trip takes the highest free gun key, 3 or 4, as an automatic pin (the v22.42 rule, 17011). This stops `out.length=HOTBAR_N` (16991) from cutting the plate off.
- **Placing it:**
  - Pad: LB/RB to the trip cell, then hold and release RT (the frag cook path, 18727). Keyboard: its digit key or Q, then a click or G.
  - Only a frag ever cooks off (18692/18730), so a held trip is safe.
  - `throwFrom` (14063) is unchanged: it lands at the aim point, stopped by walls.
  - `activateThrow` (14162) gets `else if(th.kind==='trip') tripArm(th)`.
- **`tripArm`:**
  - u = the throw direction, n = its perpendicular.
  - `a = rayHitG(tx,ty, n, 120)`, `b = rayHitG(tx,ty, -n, 120)`. Each end stops 4 short of a hit wall.
  - With no walls the wire is 80 each side. The total is clamped to 60-240, so a wire thrown into a doorway or corridor spans it.
  - The record `{id, ax,ay,bx,by, armT:0.6, life:TRIP_LIFE(240 s), seat, fx}` goes into `G.trips`.
  - At most 3 live per owner; the oldest goes.
  - Say `TRIPWIRE SET`.
- **Tick:** `tickTrips(dt)` is called at the end of `updateThrowables` (after 14430), gated `G.trips&&G.trips.length` (the sim never has any). It runs only where bodies are authoritative: solo, or the host (`!netEntsPeer()`, 41757).
  - **Who trips it:** a body trips it if its move this frame (`e.tpx,tpy` to `e.x,y`) crosses the wire segment, or it is within `0.6×e.r` while moving.
  - **Who counts:** `hp>0`, not `finished`, not `merc`, not friendly, not neutral peddler or stray, and **not a snitch** (it hovers).
  - **Never:** a player or a hire.
- **`tripBlast`** is a new function, kept separate so `explodeFrag` (14185) stays the same, byte for byte:
  - `sfx('boom')`; spark, flash and decal on the cosmetic stream; shake by distance; `ping(…,520,'env','fire')`.
  - Bodies within `TRIP_R` 150 with line of sight take `110×(1−d/R)+30`.
  - **No `damagePlayer` and no `netAreaHitPeers`**: no team damage and no self damage.
  - **Kill credit:** the host's own wire sets `e.byPlayer=true; bySeat=0` (plus `notoAggress`, as the frag does at 14252). A player 2 wire sets `byPlayer=false; bySeat=seat`, which reaches player 2 through the kill word (43345).
  - Survivors chase the blast point.
  - No wall damage.
- **Co-op:**
  - Player 2's `tripArm` sends `netThrSend('trip', x, y, {ax,ay,bx,by,id,s:seat})` (41824) and keeps a local copy (`fx:1`) to draw.
  - The host's `netThrTake` (41833; add `trip` and `tgo` to the whitelist at 41837) builds the real wire and passes the copy on.
  - On a blast or expiry the host sends `{k:'tgo',id}`, and every window drops its copy.
- **Drawing:** `tripDraw()`, hooked into **render2D** after the locked-door lamp block (27751, above the fog, so the owner and his teammate always see their own wires).
  - A faint red line (`rgba(255,60,60,.16+.08·pulse)`, 1.2 px in world space), dashed until armed, with two emitter nubs.
  - While a trip is held, a dashed preview of `tripPlan()` (the landing and span maths shared with `tripArm`).
  - The cook label (29702) reads `TRIPWIRE · RELEASE TO SET`.
  - `drawItemIcon` (32138) gets a `trip` branch.
- **Setup:** `pouch:{…,trip:0}` (11563); `tel.thr.trip:0` (11604). `grantLoot`'s `G.pouch[itm.tk]++` (16337) and the extraction stash loop (23434) are generic.
- **Where trips come from:**
  - **Arcade kit:** `arcadeKitApply` (44519) sets `g.pouch.trip=(Math.random()<ARCADE_TRIP_P 0.35)?1:0`.
  - **Arcade crates:** `arcadePostBuild` puts `'trip'` into `ARCADE_TRIP_BOX` (8) ordinary containers through `sideStream(g.seed,TAG_TRIP)` (5303). That is deterministic, both windows match, and the main stream does not move.
  - **Normal raids:** the mechanic works whenever one is carried. A cheap optional source (feat1f) is the same sideStream sprinkle (4 boxes) after 11759 for live non-arcade raids. It changes loot contents only, not counts or positions, so the fingerprint and the live-versus-sim parity hold. That is **OPEN**; my default is to ship it.

**Risks**
- The belt length (handled above).
- The `netThrTake` whitelist.
- render2D is shared with the graphics program (one hook line plus a new function).
- Undercroft: a trip carried home lands in the stash through the generic loop. Nothing new is built there.

### Feature 2. Gun stat cards

**The model**
- **`gunStats(w)`:**
  - `perPull = dmg×(pellets||1)×(burst||1)`
  - `rpm = round(60000/rof)`
  - `mag`
  - `rangeM = round(rng/10)`
  - `handling = round(100×(0.6×clamp(1−spread/0.2,0,1) + 0.4×clamp(1−(reload−1200)/3000,0,1)))`
  - `sustained = perPull×pulls / (pulls×rof/1000 + reload/1000)`, where `pulls = mag/(burst||1)` and melee counts as 0
- **`gunCompare(found, hand)`** returns `{rows:[DMG,RATE,MAG,RANGE,HANDLING] with value and delta, verdict}`.
  - The tier decides first (`WTIER`, 2159): higher is **UPGRADE**, lower is **DOWNGRADE**.
  - At equal tier, the sustained ratio decides: 1.08 or more is UPGRADE, 0.92 or less is DOWNGRADE, anything else is **SIDEGRADE**.
  - Against fists it is always UPGRADE.
  - The tier rule agrees with the routing in `arcadeGunLoot` and `grantLoot`.
- **The pickup card.** `grantLoot`'s gun branch (16338-16473) sets `G.gunCard={gk,name,cmp,tag,t0}`:
  - **Arcade:** only when `_agl.tag` is STOWED or KEY n (16379), never SCRAPPED.
  - **CAREER:** for every gun (to the stowed slot, the hand or the backpack, tags at 16414/16463/16472).
  - `drawGunCard()` is called in drawHUD right after `drawPickups()` (30632). It sits at the right edge just above the pickup stack (`drawPickups` returns its top y; the card is clamped at 0.30H or lower), lives 4 s, and hides with the backpack or the map.
  - Contents: the name in its rarity colour, a verdict chip (UPGRADE `#7fc4a0` / SIDEGRADE `#ffc04a` / DOWNGRADE `#ff5a4a`), `VS <HAND GUN>`, 5 rows with green or red deltas, and the route tag (`STOWED · LB/RB SWAP`, `KEY 3`).
  - Fonts go through `hudFS`, and every size is multiplied by `hudRes()` (about 2 at 4K), so it reads on a TV.
- **The backpack card.** In `drawBag` (32907-32933), when the selected stack is a gun, the right half of the hint area draws the same card against `p.wep`. `itemRows` stays on the left. The D-pad already moves `G.bagSel`.
- In "look at", the scope is the backpack plus the pickup. The frozen Undercroft stash is not touched.

**Risks:** small. Display only, and nothing is drawn under `G.sim`. The card can overlap the co-op kill feed for 4 s; it is capped at 0.30H or lower.

### Feature 3. The death recap

**The model**
- **The weapon on each hit.** `_logHit` (15266-15278) adds `w` (what hit him) and `k` (the source kind) to each `hitLog` entry. This is cosmetic: the entry is already written only when `!G.sim`.
  - `w` comes from `deathWeaponOf(src, srcName)`: for a raider, find the body named `srcName` in `G.ents` and use its `wep.name` in caps.
  - Otherwise use `MACH_ARMS`: `{crawler:'CLAWS', sentry:'AUTOCANNON', howler:'SHELLS', warden:'HEAVY CANNON', bulwark:'SHIELD GUN', choir:'PILLBOX', listener:'PULSE', yourself:'YOUR OWN CHARGE', lightning:'THE STORM'}` (the words are his to check).
  - **No signature change** to `damagePlayer` (15195), `netHitPlayer` (43281) or `netHitTake` (43553).
- **`deathRecap(log)`** returns `{killer, weapon, hits: the last 5 grouped rows, bySrc: the top 3 totals}`.
- **CAREER KIA card** (23772-23833):
  - The sub line (23792) becomes `KILLED BY X · WITH Y`.
  - A `DAMAGE TAKEN` block (per source: `-64 · 3 HITS`) is added after HOW IT WENT.
- **DEMO recap:**
  - `arcadeRespawn('dead')` (44752) snapshots `ARCADE.recap=deathRecap(G.tel.hitLog)` with `t0`, then clears `G.tel.hitLog=[]`. The arcade never settles, so nothing reads the log later.
  - `arcadeHud` (45230) draws `arcadeRecapHud()` while `ARCADE.holdT>0 && ARCADE.recap`. It is anchored right of centre (left edge at W×0.52, top at H×0.42), clear of the controls card at the left and of `DROPPING IN` at H×0.36.
  - Lines: `KILLED BY SENTRY` / `WITH AUTOCANNON` / up to 4 hit rows / `DAMAGE TAKEN` with the top 3.
  - Each window shows its own: the hits reach player 2 through its own `damagePlayer` (43559).

**Risks:** none to the sim. The recap must give way to the initials card (`arcadeIniRaid`, 46023) when that is up.

### Feature 4. More interiors (COLD STORAGE only, since the mile is hidden)

**What already exists**
- Every building has a forced interior plan: spine, core, cells, lsplit, pinwheel or open (`makeBuilding` 5677-5934, plans per building at 6551-6576). The partitions' doorways are kept in `map.idoors` (7401).
- Authored locked rooms (`def.locked`; built at 6757-6773 as 5 `lockWall` walls plus one `door` wall). They are opened by `lockedOpen` (42833) through `rebuildGeometry` (15448).
- A promised key per room (10839-10897), caches inside (10907-10916), the door prompt (29503-29527), the sector-map marks (33298-33310), the door lamp (27736-27751) and the net door word (`netDoorSend`/`netDoorTake`, 42840-42861).

Cheapest plan: reuse all of it. **The seeded build is not touched, so the fingerprint does not move.**

**feat4a. The keycard**
- `ITEMS.keycard={name:'Vault Keycard',val:250,r:'rare',c:'#7fe3d4',use:'key',door:'arc'}`, appended last. It is never in a map table and never in the peddler's `kcand`.
- One helper, `keyFits(it,door)`: `it.use==='key'&&(it.door===door.id||(it.door==='arc'&&(door.arc||(G&&G.arcade))))`. It replaces the 4 inline tests: `doorKeyIx` (7780), the door branch of `updatePlayer` (18826), the HUD prompt (29508) and the key name (29515, which reads "Needs the Vault Keycard" in the arcade).
- In the arcade a keycard opens **any** locked room. In CAREER it opens only arcade vaults, and there are none there, so normal raids are unchanged.

**feat4b. Arcade vaults**
- `arcadeVaults(g)`, run from `arcadePostBuild`, inside `sideStream(g.seed, TAG_VAULT)`.
- **Candidates:** buildings with plan `core` (COLD STORAGE has 4: 1912/230, 2980/900, 3440/1330, 2520/1760). For each:
  - the strongroom box = the bounding box of the walls with `ib===bi && !furn`; skip if there are fewer than 4
  - its single doorway = the `map.idoors` entry inside the box
  - skip it if any body is inside the box, or if it overlaps a locked room
- `ARCADE_VAULT_N` (2) are chosen with `ri` on the side stream. For each:
  - push the door wall `{x,y,w,h of that doorway, d:3, door:'arcvN', wid: the next index}`
  - push `{id:'arcvN', name:'VAULT A', x,y,w,h, doorX,doorY: the doorway centre, open:false, arc:1}` into `g.map.locked`
  - place 2 caches inside (`spotWall` + `mkContainer('cache',3)`, `inLocked`, one guaranteed tier-4 gun via `ri`)
  - put one keycard in an ordinary box outside every locked room (the 10848 rules)
- Then `rebuildGeometry()`, which rebuilds the nav, grids, reach and fog segments.
- Both windows run the same pass, so `netUpFp` agrees. Late joiners get the door state through the 41380 path (the door walls have `wid`).
- `shutRoomAt` (5989) then keeps waves out on its own. Also add `!shutRoomAt` to the teammate spot in `arcadeRespawn` (44764) and to the random pass in `arcadeRedropSpot` (44811).

**feat4c. Keycards from fights, and a vault bonus**
- `arcadeKeyDrop(e)` is called at the death site in `updateEnts` (after 20526), and only on the authority: `G.arcade`, not `netEntsPeer`.
- While a vault is shut and no keycard lies on the map, an elite or every 12th kill drops a pile `['keycard']`. It is built under `fxBorrow` (5309), so the main stream stays where it is. It reaches player 2 as a new container word (`netContNumber`, 44189).
- Opening an arcade vault pays `VAULT OPEN +$500` into `ARCADE.mine` (DEMO) and says `VAULT OPEN`.

**feat4d (OPTIONAL). Door frames**
- Cosmetic thresholds and frames at `map.doors` and `map.idoors` in arcade raids. This is render2D work in the wall pass; offer it to the graphics program.
- **Not recommended:** an extra partition pass. It risks sealed rooms (the v1.62 history at 5795-5818).

### Feature 5. Full controller navigation: audit and gaps

**Works today**
- **Attract:** any button drops in; player 2 joins with A (13327-13334, `arcadePadAtt` 45584).
- **Initials:** `arcadePadIni` (45989). It also covers the extraction card (13342).
- **Pause box:** a panel with focus. B and MENU resume (13152-13158). Settings and Abandon are hidden in arcade (13838-13855).
- **In the raid:** the backpack (VIEW, D-pad, A pick and place, B close, Y drop: 13586-13603), belt LB/RB (13568-13584), the map on D-UP, quick heal on D-DOWN (13585), and a disconnect pauses (13615).
- **Focus is visible:** `.padfocus` (CSS 663). Canvas lists use the gold ring.

**Gaps and their builds**

| Gap | Build |
|---|---|
| The title opens on `#titlestart`; ENTER starts the Undercroft | feat0a |
| Keyboard arrows cannot reach RETRY: `netTitleRows` takes `[data-mode]` only (40808) | feat5a: add `#moderetry` while it shows |
| END RUN is one press with no confirm (46589) | feat5b: the first A arms `END RUN? PRESS AGAIN` for 3 s; the feedback textarea `#pausenote` is hidden in the arcade box |
| A press on RUN OVER drops straight back in (`arcadeKeyAtt` 45580, `arcadePadAtt` 45588) | feat5c: a 1.5 s guard after `ARCADE.over.at` |
| No pad way to equip a gun from the backpack (keyboard ENTER at 12192) | feat5d: in arcade and CAREER with the backpack open, X sends `raidKey('Enter')` (13490-13507 branch) and holds nothing else |
| A roll (`raidKey` Space → `tryRoll`, 12142), a throw or the belt during the arcade drop hold drops the shield before he is in | feat5e: during `ARCADE.holdT>0`, `raidKey` ignores Space, G, Q and the digits, and the pad gives no taps |
| The death recap and the stat cards are display only, so no input is needed | none |
| The arcade allows no Settings (operator lock, arcade21) | by design |
| The operator chord is keyboard only | by design |

### Feature 6. The pro sound mix (cosmetic only)

**feat6a. Buses**
- In `bus()` (3894), keep BUS as the master: gain = master × fx (`volApply`, 3887), connected to `netSndOut`. Add:
  - **`SND.world`:** gain 1.15 → `DynamicsCompressor` (−16 dB, knee 10, ratio 3.5, attack 4 ms, release 220 ms) → limiter (−3 dB, ratio 20, attack 1 ms, release 80 ms) → BUS. **The reverb send moves from BUS to `SND.world`** (3902).
  - **Category gains into `SND.world`:** `gun` .95, `imp` .9, `mach` .85, `foley` .8, `amb` .9, `vox` 1, `world` .9.
  - **`ui` and `sting`:** straight into BUS. No compressor, no reverb, never ducked.
- **Routing:**
  - `blip` (4696) becomes `OUT=sndBus(SND_CAT[type]||'world')||bus()||a.destination`.
  - `SND_CAT`: shot, reload, reloadin and dry → gun; boom, hit and clank → imp; servo, skitter, drone, hydraul, dish, stepHeavy, seen and alarm → mach; foot and step → foley; flap → amb; the pick sounds, clockwarn and clocktick → ui; heart → vox; the ring sounds → world.
  - `ambience` (4477) → `amb`; `voxGrunt` and `voxBreath` (4450/4465) → `vox`.
- The music stays off BUS as it is (no raid music). **Split speakers are kept:** every bus ends in BUS → `sndG` → `sndP` (41104-41116, 41127).

**feat6b. Ducking**
- `sndDuck(cat,depth,hold)` and `sndMixTick(dt)` (setTargetAtTime). It is called in the raid loop beside `tickVerb` (35696), **not** in `tickAmbience`.
- `boom` closer than 700: amb 0.35, mach 0.6, foley 0.7, held 0.5 s, back over about 1.6 s.
- Player hit: amb 0.75. A sting: amb 0.6.
- **`ui` is never ducked.**

**feat6c. Distance and occlusion**
- `sfx` (4431) sets `SND_CTX=sndPlace(wx,wy)`: `{occ: !losClear(player→source) within 1500, lp: 900+600·(1−d/1500) if occluded else 18000, pan: clamp(pan×(d<150?1.4:d>700?0.7:1))}`.
- `blip` puts one lowpass in front of the panner and clears `SND_CTX` when it ends.
- `tickMachineVoices` already scales by occlusion (4671). It is left alone.

**feat6d. Gun layers**
- `gunLayers(d, space)` is a pure function returning `{crack, body, far, tail, tailKind}`:
  - closer than 250: a 4 kHz click
  - farther than 650: no crack, a lowpass at 800, plus a distant thump
  - **the tail by `spaceAt(SND_CTX)`** (4279): inside = `slap` (echoes at 45 and 90 ms), open = `roll` (0.9 s lowpass), woods = `soft`, vault = `ring`, water = `hiss`
- It is used in the shot branch (4737-4813). The player's own shot uses his own spot, with the tail at 0.5.

**feat6e. Machine state loops** (the off-screen warning)
- `tickMachLoops(dt)` keeps 3 persistent slots, reassigned every 0.25 s. They go to the machines with the highest score, where score = (fight 2, search 1) × (1−d/900), and only machines the player **cannot see** (`canSee`, 8611).
- **A sound per kind** (searching is slower and quieter, fighting is faster and louder; each fades in and out over 0.3 s):

| Kind | Sound |
|---|---|
| sentry | saw 140 Hz through a bandpass, LFO 3 / 7 Hz |
| crawler | gated noise, 9 / 16 Hz |
| warden | 48 Hz plus 96 Hz, LFO 0.6 / 1.4 |
| snitch | triangle 420 Hz, vibrato |
| listener | a sweep |
| howler | a low saw plus bursts |
| bulwark | square-wave treads |

- It is stopped in `ambienceOff` (4532) and `arcadeRaidStop`. It never runs under `G.sim`. It uses `fxr` and `Math.random` only.

**feat6f. Impacts by material**
- `matOf(wall)`: tree or furniture → wood, window → glass, wreck or lock wall → metal, otherwise concrete. `hitMat(e)`: raider → flesh, otherwise metal.
- Passed as the `wid` argument at 22556 and 22561 (`sfx("clank",b.x,b.y,matOf(_struck))`), 22415, 43608 and 22465 (flesh); `metal` at 22285 and 22304.
- The `clank` and `hit` branches (5265, 4821) pick their voice by material.
- The `rnd(3,6)` decal draw (22535) is unchanged, so the stream does not move.

**feat6g. Footsteps**
- `surfFine(x,y,base)` is cosmetic:
  - stone → wet (rain over 0.3) / grit (a yard landmark) / concrete
  - wood → tile (cells and core plans) / boards
  - metal → grate
- It is passed as a **6th** argument to `blip('foot',…)` (4343, 4596). `surfAt` and the step ping radius (4353-4357) are unchanged.
- Each surface gets 3 micro-variants (`Math.random`).

**feat6h. UI sounds**
- `sndUi(kind)` on the `ui` bus: move, ok, back, deny, open and close.
- **Where they fire:**
  - move: `padSetFocus` (13053), when the target changes
  - ok, or deny when disabled: a capture `click` listener on buttons inside `.modal`, `.pausebox`, `#title`, `#hub` and `.outcome`
  - back: padMenu B (13160)
  - open and close: `togglePauseBox`

**feat6i. Arcade stings**
- `arcSting(kind)` on the `sting` bus, called from:
  - `extract`: `arcadeExtracted`
  - `streak`: the streak call in `arcadeKill` (45150)
  - `hi`: `arcadeHiSay` (46068)
  - `wave`: `arcadeWaveTick` when a pack is made (44962)
  - `drop`: each integer of `arcadeDropHud` (45222)
  - `vault`: an arcade vault opening
- Each is 1.2 s or less (O13).

**Risks**
- Node count per sound grows by 1 or 2. That is the audio thread, not the frame time.
- Changing BUS→REV to WORLD→REV changes the reverb on the pickup chimes, which is intended.
- Checks that stub `blip` and compare arguments: the 4th argument is unchanged, and the material and the fine surface go in the 4th (wid) or 6th slot only.

---

## PART 2. Shippable builds, batches and what can run in parallel

**Wave 1** (4 agents in parallel; the regions do not overlap)
- **Batch A, title and map:** feat0a, feat0b (HTML 700-735, 114-119, 1278-1290; 13089; 40785-40832; 6491/6637; 46919; 47004; 3220; 38826).
- **Batch F, gun cards:** feat2a, feat2b, feat2c (a new section; 16338-16473; 30632 plus one call; 32907-32933).
- **Batch G1, the CAREER death card:** feat3a (15266-15278; 23772-23833).
- **Batch S1, sound core:** feat6a, feat6b, feat6c, feat6d, feat6f, feat6g (3860-5290; 4330-4362; 4565-4598; 22285/22304/22415/22465/22556/22561/43608; one line at 35696).

**Wave 2**
- **Batch M, modes (one agent, in order, because these share 29113, 23002 and arcadeKill):**
  - feat0c (DEMO clock): 44481-44708, 35641, 29113, 45194, 45635
  - feat0d (DEMO ×2): 44790-44847, 45072-45077, 45218-45251, 45408, 45479, 45609, 45697-45777, 45829-45884
  - feat0e (CAREER raid): 2073 DEF, 11759, 20431, 43834, 45141 refactor, 29113
  - feat0f (CAREER settle): 23293-23305
- **Batch D, the tripwire (parallel with M):**
  - feat1a: 2379, 2559, 11563, 11604, 13900, 14162-14184, 16958-16991
  - feat1b: after 14430, new `tickTrips` and `tripBlast`
  - feat1c: 41824-41854
  - feat1d: **render2D** after 27751, 29702, 32138

**Wave 3** (after M and D)
- **Batch E, interiors plus the arcade trip sources (one agent; they share `arcadePostBuild` and `arcadeKitApply`):**
  - feat1e: 44519, `arcadePostBuild`
  - feat4a: 7777-7781, 18815-18835, 29503-29518
  - feat4b: `arcadePostBuild`, 44764, 44811
  - feat4c: after 20526, `lockedOpen` caller at 18830
  - feat1f, OPTIONAL: 11759
  - feat4d, OPTIONAL, **render2D**
- **Batch G2:** feat3b (44752, 45230). Parallel with E only if E leaves `arcadeRespawn` alone, apart from 44764, which is a different line.
- **Batch H, controller:** feat5a (40805), feat5b (46589, 13838-13856), feat5c (45564-45589), feat5d (13490-13507 bag branch), feat5e (`raidKey` 12142 plus the pad tap loop 13544-13552). Parallel with E and G2.
- **Batch S2, last:** feat6e (new section plus the loop line), feat6h (13053, 13160, `togglePauseBox`, one listener), feat6i (calls inside arcade functions, so it goes after M, E and G2).

**Overlap with the graphics program** (render2D, drawOp and the entity draws)
- **render2D:** only feat1d (one hook line after 27751 plus `tripDraw`, a preview drawn in the same hook) and feat4d (optional, the wall pass).
- **Unchanged and reused by feat4b:** the locked-room lamp (27736-27751) and the map marks.
- **Not touched:** drawOp and the entity draw functions.
- **drawHUD and drawBag**, which they did not list, are touched by F, G, M and 1d (the cook label).
- **Hit pause:** if it freezes `G.t`, the 4 s cards and the recap simply wait. Ducking is independent of it.

---

## PART 3. A check for each build

Every check runs in game scope with `__topClear(); __runPrep();`. Each one restores what it changed in `finally` (`arcadeLeave()` when `ARCADE.on`, `__endRaid('abandon')`, `delete` on any ctx or navigator stub, and the `AC`/`BUS`/`REV`/`SND` stubs put back). Each check **fails on the previous build** because the function, field or behaviour it reads is new.

**feat0a**
- Title `on`, `PAD.focus=null`, `padMenu(function(){return false;})`. Then `PAD.focus.id==='modearcade1'`.
- `netTitleRows()` ids start `modearcade1, modearcade, titlestart, modecoop`. `#mhdemo` and `#mhcareer` read DEMO and CAREER.
- Stub `arcadeSoloPick` to record. `netTitleEnter(go)` with no focus records one call and `go` is not called.
- The 23.58 fit measure at menu zoom 2.4 is not over.
- On the old build: focus is on titlestart and the result is `'start'`.

**feat0b**
- The index of the largest `w*h` is 1. `mapOffered(FIXED_MAPS[1])===false`; `offeredCount()===1`.
- `renderSector()` gives no `.sectorpick[data-map="1"]`.
- `P.mapIx=1; arcadeEnter('host')` gives `ARCADE.mapIx===0` (then `arcadeLeave`).
- `__startRaid({mapIx:1,seed:4242})` still gives 374 bodies.

**feat0c**
- `arcadeDeploy({mapIx:0,seed:4242})`: `G.raidLen===600`, `raidClockOn()`, every zone `closeAt===undefined`.
- A fillText stub on hcv during drawHUD shows `SCORE` and a string matching `/^\d+:\d\d$/`.
- `arcadeShieldOff(); G.timeLeft=0.05;` then 30 `__loop` frames: G is null or stopped, `ARCADE.over.why==='time'`, never `nuking`, `P.runs` unchanged, `ARCADE.on` still set.

**feat0d**
- `arcadeDeploy; ARCADE.mine=1500; ARCADE.pot=300; __endRaid('extract')`.
- Then `ARCADE.mine===3000` and `ARCADE.banner.mul===2`. Run 220 frames.
- Solo: `ARCADE.over.why==='extract'`.
- With `ARCADE.xOut=1` and `specOut`, `arcadeBenched()===false`.
- On the old build: 4300.

**feat0e**
- `__deploy({kit:[],safe:null,mapIx:0,seed:4242})`: bodies 85, containers 165, `G.career===1`, `raidLen===600`.
- A crawler at +300 with `hp 0, byPlayer` after `__ents(0.016)` gives `G.cs.s===50`. The HUD trace shows `$50`.
- With `CFG.career=0` and a re-deploy: no `G.career`, `raidLen===540`.

**feat0f**
- `__deploy; G.cs.s=400; __endRaid('extract')`: `G.cs.paid===800`, `#oc_manifest` contains `CAREER SCORE` and `+$800`, `P.careerBest>=800`.
- Deploy again, `G.cs.s=400; __endRaid('dead')`: `paid===0`.

**feat1a**
- `__deploy`: with no trip there is no `throw:trip` cell.
- `G.pouch.trip=1`: the cell appears. `G.tsel=THROWKEYS.indexOf('trip')`, aim the mouse, `doThrow()`, 20 × `__sim(0.05)`.
- Then `G.trips.length===1`, the span is between 60 and 240, and `pouch.trip===0`.

**feat1b**
- `tripArm` at a clear spot 300 away. Run `tickTrips` past `armT`.
- A crawler on side A, a tick, then moved to side B, a tick: the crawler is hurt or dead and `G.trips` is empty.
- Player hp is unchanged (he stands 60 away).
- Walking `G.player` across a second wire leaves it standing.

**feat1c**
- A stand-in host with peer seat 1: `netThrTake(peer,{t:'thr',k:'trip',…,id:'s1-1',s:1})` gives a wire with seat 1. Tripping it kills with `bySeat===1` and `!byPlayer`.
- As the join role, `{k:'tgo',id}` removes the copy.
- On the old build: `'bad'`.

**feat1d**
- A wc `moveTo`/`lineTo`/`strokeStyle` stub over one render2D frame records a red stroke between the two ends of the wire.
- While a trip is held, the cook label trace has `RELEASE TO SET`.

**feat1e**
- Stub `Math.random` to 0, then `arcadeKitApply`: `pouch.trip===1`. Stub it to 0.99: 0.
- Two arcade deploys at seed 4242 give the same set of crates holding `trip`.
- Wrapping the sprinkle shows `RNGS` unchanged across it.

**feat2a**
- `gunCompare(WEAPONS.lmg,WEAPONS.rifle).verdict==='UPGRADE'`; `(pistol, rifle)` gives `'DOWNGRADE'`; `(rifle, rifle)` gives `'SIDEGRADE'` with all deltas 0. There are 5 rows.

**feat2b**
- Arcade, `p.wep=arcadeGun('chatter'), p.sec=arcadeGun('smg')`, then `grantLoot({x:p.x,y:p.y,loot:[]},['gun_lance'])`.
- `G.gunCard.gk==='lance'`, `cmp.verdict==='UPGRADE'`, `tag==='STOWED'`. The HUD trace shows `UPGRADE`.
- At `__forceSize(3840,2160)` the verdict font px is at least 1.8× the 1080p size.
- A scrapped gun leaves the card unchanged.

**feat2c**
- `__deploy; G.bag=['gun_dmr']; G.bagOpen=true; G.bagSel=0`. The drawHUD trace shows a verdict word and `HANDLING`.

**feat3a**
- `__deploy`. Push a raider R. `damagePlayer(25,'sentry','SENTRY',…)`, then `damagePlayer(30,'raider',R.name,…)`.
- The last `hitLog.w===R.wep.name.toUpperCase()`.
- `__endRaid('dead')`: `#oc_sub` contains `WITH`, `#oc_manifest` contains `DAMAGE TAKEN`.

**feat3b**
- `arcadeDeploy`, shield off, two SENTRY hits, `killPlayer('sentry')`, 120 frames.
- `ARCADE.recap.killer==='SENTRY'` and `G.tel.hitLog.length===0`.
- The HUD trace during the hold shows `KILLED BY` and `DAMAGE TAKEN`. After the hold it does not.

**feat4a**
- `arcadeDeploy`. Stand at the `cs_freezer` door, `G.bag.push('keycard')`, `keys.KeyE=true`, `__sim(0.02)`. The room is open and the keycard is spent.
- `__deploy` (CAREER): a keycard does nothing; `key_cs_freezer` still opens it.

**feat4b**
- Wrap `arcadeVaults` to compare `RNGS` before and after (equal).
- `arcadeDeploy` seed 4242: 2 rooms with `arc`, each with a `door` wall, `shutRoomAt` true at the centre, 2 or more caches inside.
- The `netUpFp(G).h` and vault rects of a second deploy are identical.
- A plain `__deploy`: no `arc` rooms, 85/165.

**feat4c**
- Boxes holding `keycard` number at least the vault count, and none lies inside a locked rect.
- Opening a vault with a keycard raises `ARCADE.mine` by 500.
- `ARCADE.kcN=11; arcadeKeyDrop(e)` makes a `['keycard']` pile, with `RNGS` unchanged.

**feat5a**
- `#moderetry` shown: it is in `netTitleRows()`.

**feat5b**
- `arcadeDeploy; togglePauseBox(true)`. The first `#arcendbtn` click leaves `G.arcade` and no `ARCADE.over`. The second click gives `over.why==='menu'`.
- `#pausenote` is hidden.

**feat5c**
- `arcadeRunEnd('menu')`. A synthetic keydown leaves `G` null.
- `ARCADE.over.at-=2000`, then a keydown gives `G.arcade===1`.

**feat5d**
- Stub `navigator.getGamepads` with an own property: a connected pad with 17 buttons.
- Arcade, backpack open, `G.bag=['gun_dmr']`. Press X and `pollPad()`: `p.wep.id==='dmr'`.

**feat5e**
- `arcadeDeploy; arcadeRespawn('dead'); raidKey('Space',false,null)`. Then `!(p.roll>0)` and `p.arcSh===1`.

**feat6a**
- **The fake context:** `AC` = a fake whose nodes record `connect`, with `createGain`, `createBiquadFilter`, `createStereoPanner`, `createDynamicsCompressor`, `createOscillator`, `createDelay`, `createBufferSource`, `createBuffer`, `destination`, `currentTime` and `sampleRate`. Set `BUS=REV=SND=null` first.
- After `bus()`: `sndBus('gun')` connects to `SND.world`; `SND.world` → comp → lim → BUS; `sndBus('ui')` → BUS; `REV.send` is fed by `SND.world`, not BUS.
- `blip('shot',100,0,'rifle')` reaches the gun bus.
- With `NET.same='host'` and split on, the `ui` path still reaches `NET.sndP` at pan −1.

**feat6b**
- Fake `AC`. `sfx('boom',p.x+100,p.y)`: the amb gain target is under 0.5 and ui is 1.
- `sndMixTick(2.5)`: amb is back at 0.95 or more.

**feat6c**
- `sndPlace` behind a building wall gives `occ` and `lp<=1200`. With a clear line, `lp>=16000`. Near widens the pan, far narrows it.

**feat6d**
- `gunLayers(100,'open').crack>0`; `gunLayers(800,'open')` gives `crack===0` and `tailKind==='roll'`; `'inside'` gives `'slap'`; `'vault'` gives `'ring'`.

**feat6e**
- Fake `AC`. Stage a chasing sentry behind a wall at 400 and a searching crawler unseen at 600. `tickMachLoops(0.3)`: the slot kinds include both, with states `fight` and `search`.
- `RNGS` unchanged. Under `G.sim` nothing is assigned.

**feat6f**
- `matOf({tree:1})==='wood'`, `matOf({win:1})==='glass'`, a building wall gives `'concrete'`.
- A bullet into a building wall with `sfx` stubbed records 4th argument `'concrete'`.

**feat6g**
- With `blip` and `ping` stubbed, `tickPlayerSteps`: the 4th `blip` argument is still in {stone, wood, metal, leaf, water}, a 6th argument is present, and the ping radius equals the old formula.

**feat6h**
- Fake `AC`. `padSetFocus(a); padSetFocus(b)`: `SND.uiLast==='move'`. A click on a title row gives `'ok'`.

**feat6i**
- Stub `arcSting` to record. `__endRaid('extract')` in arcade, a streak of 2, `arcadeHiSay`, and a wave tick that makes a pack: the recorder holds extract, streak, hi and wave.

---

### Critical Files for Implementation
- `C:\claudecode\dark raiders\dark_raiders.html`:
  - title HTML 1278-1290; CSS 114-119 and 728-735; `netTitleInit`/`Rows`/`Enter` 40785-40832; padMenu 13066-13171; pollPad 13234-13610
  - audio 3860-5290; throwables 13896-14431
  - `startRaid` 11724-11808; `endRaid` 22997, settle at 23293 and the KIA card at 23772-23833
  - `updateBullets` 22201-22569; drawHUD 28827-30641; `drawBag` 32742-32954
  - `FIXED_MAPS`/`mapOffered` 6477-6660; `renderSector` 47001
  - the arcade section 44414-46068
- `C:\claudecode\dark raiders\tools\mkfixture.ps1`: `__startRaid` 242, `__verify` fingerprint 1221-1243, `tickAmbience` stub 1117, `__topClear` 60795, `__deploy` 60922, the arcade check style at 5747-5895
- `C:\claudecode\dark raiders\tools\handoff\research\arcade-design-2026-10-11.md`: the shipped arcade model, sections 1, 3 and 6
---
## HIS ANSWERS OVERRIDE THE OPEN QUESTIONS ABOVE (2026-10-12, binding; memory pillagers-fifty-answers-2026-10-12)
- O1/O5: in BOTH DEMO and CAREER a player gets ONE self-revive, then death ends the raid. Exception: 2-player DEMO only, a dead player respawns but loses ALL their score (his words "should lose all score"). 1-player DEMO: death ends the run.
- O2: CAREER loadout = his own kit from the stash (as recommended).
- O3/O4: 1 score = 1 credit, banked ONLY on extraction (the score is doubled first). Extracted loot goes to the stash as ITEMS ONLY and does NOT count in the score.
- O6: CAREER waves are the SAME as DEMO; CAREER enemy damage is FULL. Rings never close (keep).
- O7: when the DEMO clock reaches 0 the site BURNS like a normal raid (not TIME UP).
- O8: extraction doubles the whole raid score and ENDS the run (DEMO: RUN OVER + initials).
- O9: see O1 (2P DEMO respawn loses all of that player's score).
- O12: the title highlights DEMO first. Rows under DEMO and CAREER as recommended.
- O13: stings are sound effects. Music plays ONLY on the title and the demo video, never in raids.
- Remove the Halloween dressing entirely (arcade20: pumpkins, orange lamps, haze, HAPPY HALLOWEEN). No Halloween target.
- KEYBOARD AND MOUSE first, then pad. No aim assist. The tripwire goes on the belt like a grenade.
- The death recap goes on the KIA / EXTRACTED card (also in DEMO), not on a 3-second respawn screen.
- Sound: punchy arcade, with short voice barks.
- In-game feedback in the ESC / TAB menu: a typed note plus a screenshot saved to exports.
- The player-facing version restarts at v0.0001; the internal VER stays for the tooling.
- The HUD is redone entirely by the UI program, so keep HUD edits minimal here.