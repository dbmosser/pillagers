## PILLAGERS: DEMO and CAREER modes plus features 1 to 6, design document (read-only, nothing edited)

**File:** `C:\claudecode\dark raiders\dark_raiders.html`, HEAD v23.58. Line numbers are from today's read.
**Fixture:** `C:\claudecode\dark raiders\tools\mkfixture.ps1`.

**What this design follows:**
- His mode design of 2026-10-12.
- His binding answers.
- The binding rules in the brief. Where his new answers change a normal raid, it is because he ordered it (CAREER).

**Three findings that shaped it:**
1. **Interiors already exist.** Every building has a forced interior plan (`makeBuilding` 5677-5934). Map-authored locked rooms with keys and guaranteed key placement also exist (6757-6773, 10839-10916).
2. **The seed fingerprint is only the build.** It is the ents and containers counts after `__startRaid` (mkfixture 1231-1243). A post-build pass that adds no ents or containers cannot move it. A pass that adds containers on a normal raid would move the 165.
3. **The audio is one graph.** Every generator goes `blip` → (panner) → `BUS` → `netSndOut` (sndG → sndP pan ±1) → destination. Buses can therefore be inserted in front of BUS and the player 1 left / player 2 right split survives untouched (3894-3905, 41104-41116).

---

## PART 1. THE MODEL, CODE SITES AND RISKS PER FEATURE

### 0. MODES: DEMO and CAREER (replaces the old item 0), the map, the version, NO HALLOWEEN, FEEDBACK

#### 0.1 Title (DEMO highlighted first)

**New row order** in `#modemenu`. HTML 1278-1290 is replaced; every id is kept, so all wiring and every check that finds a row still works:
- small label `DEMO`, then:
  - `#modearcade1` "1 PLAYER DEMO". This is now the primary style (non-ghost, big padding, the old `#titlestart` look).
  - `#modearcade` "2 PLAYER DEMO".
- small label `CAREER`, then:
  - `#titlestart` "1 PLAYER CAREER" (data-mode solo, still runs `go`, so the Undercroft is entered).
  - `#modecoop` "2 PLAYER CAREER (SAME MACHINE)".
  - the greyed CO-OP (SERVER) row.
  - `#modepvp` "2 PLAYER PVP (SAME MACHINE)". This is the old PvP rules, untouched.
  - the greyed PVP (SERVER) row.

**Labels.** They are `<div class="modehead" id="mhdemo">` and `id="mhcareer"`, not buttons. So `netTitleRows` (40805), which takes only `button[data-mode]`, ignores them.

**CSS.**
- Add `.modehead`, small amber caps at .3em.
- The `max-height:820px` rule at 118 targets `#titlestart`. It also gets `#modearcade1`.

**Default focus and ENTER.**
- `padMenu` 13089 focuses `#modearcade1` when it is in the focusables list, else `#titlestart`. The player 2 window hides the arcade rows, so it keeps titlestart.
- `netTitleEnter` 40827-40832: with no row highlighted, it clicks `#modearcade1` if it is shown, else `startFn`. A highlighted titlestart still runs startFn.
- Keyboard handler at 49176: unchanged, because it calls `netTitleEnter`.

**Other wiring.**
- `netTitleInit` 40789: add `mhdemo` and `mhcareer` to the player 2 hide list.
- `netModeName` 40593: arcade becomes `2 PLAYER DEMO`; coop becomes `2 PLAYER CAREER (SAME MACHINE)`.
- `titleFit` (46436-46452, with observers at 46456-46457) refits the taller column by itself.

**Risks.** Checks that expect `#titlestart` to be the default focus (v14.26), that expect `netTitleEnter` to return `'start'` with no focus (v15.76), or that match the old row texts must be re-baselined (Part 4).

#### 0.2 THE COLD MILE disabled, kept in code

The bigger map is FIXED_MAPS[1]: 9000×7600 (cols×cw = w), against COLD STORAGE at 4200×3400.

**The switch.** Add a `frozen:1` flag to the mile at 6637. `mapOffered` (6491) becomes `return !m.frozen&&(!BETA_ONE_MAP||m.beta===1);`. Both maps carry beta:1 today, so the flag is needed.

**What the existing machinery then does by itself:**
- **Profile load** (3219-3222) moves `P.mapIx` 1 to 0, once. It is written to his save at the next `saveProfile`.
- **The lift** (34093) is corrected the same way.
- **`offeredCount`** (47224) becomes 1. Only `stageback` (47608) reads it, so Back returns to the floor.
  - The lift itself (34089-34096) still opens the sector page on every ascent (v9.97: it carries day/night). This is his "keep the current weather and time-of-day system": the page stays, only the mile card leaves it.

**New guards:**
- **`renderSector`** 47004: `if(!mapOffered(M)) continue;`.
- **`sizeTag`** 46917: measure offered maps only, so no "(SMALLER MAP)" tag remains.
- **`arcadeEnter`** 45353: use `firstOfferedMap()` when `!mapOffered`. **`arcadeDeploy`** 44716 keeps honouring an explicit `o.mapIx`, because checks use it; its default comes from `ARCADE.mapIx`.
- **Profile import** 38826: the same guard.
- **`netUpStart`** 41303 needs nothing: player 2 follows the host word, and the host cannot pick the mile.

**Bots.** `runSim` (23885) builds from `P.mapIx` after the load migration, so no change. The `SECTOR_MEAS` row stays.

**Do NOT put `mapOffered` inside `buildRaid` or `startRaid`.** `__startRaid({mapIx:1})` (mkfixture 242-247) must still build 374/593 for `__verify`.

**Risk.** Checks that expect two sector cards on the sector page must be re-baselined.

#### 0.3 Player-facing version restarts at v0.0001

- `VER` (1698) stays the internal ship number used by tooling, net handshakes (40274, 40329 comparisons) and crash records.
- New constants: `var PVER_RESET='23.59';` and `function verShown(v){ … }`. It returns `'v0.'+pad4(n)` with `n = maj*100+min − (23*100+59) + 1`. So 23.59 shows as v0.0001 and 23.60 as v0.0002, with no tooling change.
- Use `verShown(VER)` at:
  - the title `#titlever` (48989)
  - `#verlabel` (49185)
  - the player-facing version sentences at 40277 and 40329 (the comparison stays on VER)
  - the WHATSNEW header
- The flight recorder header (38927) prints both: `PILLAGERS v0.0001 (build 23.59)`.

#### 0.4 NO HALLOWEEN (removed entirely)

Delete:
- `ARCADE_HALLOW`, `arcadeHallow`, `arcadePumpDraw`, `arcadeHazeDraw` (44602-44677).
- The call in `arcadePostBuild` (44705).
- The render2D calls at **26238** (pumpkins) and **27900** (haze). These two lines are in render2D, so coordinate with the graphics program.
- The `HAPPY HALLOWEEN` banner (45500-45501), its CSS `.arcboo` (45439) and `'arcboo'` in `arcadeAttUndress` (45509).

Lamps keep their seeded colours, and weather and time of day are untouched (arcadeDeploy never forced night).

#### 0.5 DEMO rules (the sandboxed 1P/2P arcade with the party board)

**Clock.**
- `ARCADE_CFG` (44481) keeps `raidSec:0` for the build, so the rings get no `closeAt` and the arcade build stays as today.
- `arcadePostBuild` (44699) then sets `g.raidLen=g.timeLeft=ARCADE_RAID_SEC` (600). `raidClockOn()` turns true: the countdown (35628), the warnings (`tickClockWarn` 35632) and the HUD clock all run.
- **At 0 the site BURNS as in a normal raid.** That is the existing branch (35641-35651) and `tickNuke` (31006), unchanged.
- The player 2 clock follows the host through the `wd` word (42891 / 42905) and the late word (41352 / 41383).
- `arcadeRebuild` (45635-45647) must carry `timeLeft` into the rebuilt raid.

**Death.** One self-revive (the existing downed and self-revive rules), then death. The guard in `endRaid` (23002) becomes:
- **1 PLAYER DEMO** (`ARCADE.solo`): `arcadeRunEnd('dead')`. RUN OVER, the score kept at ×1, then initials if it qualifies.
- **2 PLAYER DEMO:** `arcadeRespawn('dead')` as today, plus `ARCADE.mine=0; ARCADE.kills=0;` ("should lose all score"). It says `SCORE LOST` in the warn lane and sends `arcsc` at once.
  - Exception: while `G.nuking` there is no respawn. That player is out (benched as `specOut` on the host; `arcadeP2Out('burn')` on player 2), and the run ends when nobody is left playing. Burn deaths keep the score (my reading; he can say otherwise).
- `arcadeRespawn` 44752-44783 also gets `!shutRoomAt(G.map,x,y)` on the spot beside a teammate, because of the vaults (4).

**Extraction ×2 ends the run.** `arcadeExtracted` (44824-44847) is rewritten:
- No `ARCADE_XBONUS` (44790), no pot, no re-drop (`arcadeRedropSpot` becomes dead code and goes).
- **Solo:** `ARCADE.mine*=2`, `ARCADE.ext=1`, then `arcadeRunEnd('extract')`.
- **2P host:** `mine*=2; mate*=2` (the host is the run authority), then `arcadeRunEnd('extract')`. `arcend` carries `x2:1` and the final rows, and player 2 doubles its own `mine` for display on `arcadeEndTake`.
- **2P player 2 extracting:** posts `{t:'arcx'}`. The host doubles and ends the run.
- RUN OVER, then initials (arcade18, 45898-45999) as today.

**Dead code after this.**
- The in-raid initials at extraction (arcade22: `arcadeIniExtract` 46027, `arcadeIniRaid` 46023, the hold-at-3 in the loop at 35654). Remove them, keeping `arcadeIniRaid()` returning false or deleting its callers.
- The `HAUL x2` banner line (45247) and `ARCADE.pot` writes in `arcadeLoot` (45074). Valuables still score their full value in DEMO (arcade31).

**Unchanged in DEMO:** the spawn shield, half damage (`ARCADE_DMG` 15198), waves, streaks, the cull, idle return, the attract, the board, the operator lock, quick heal, the wake lock.

#### 0.6 CAREER (his real save, the Undercroft, arcade scoring, 10-minute raids)

**What a CAREER raid is.** It is every non-arcade, non-sim raid started from the Undercroft. CAREER replaces the old extraction mode, gated by a dial `CFG.career` (DEF 1, so the corpus can pin 0).

**Hook.** In `startRaid` after 11759: `else if(G&&!G.sim&&CFG.career!==0) careerPostBuild(G);`. It runs before `netUpAnnounce` (11764), so a CAREER co-op partner builds the same raid. It:
- sets `G.career=1` and `G.raidLen=G.timeLeft=600`
- sets every zone `closeAt=undefined` (arcade rule: rings stay open, the clock and the burn are the pressure)
- sets `G.cs={s:0,k:0,streak:null}`
- draws nothing (no rr), so the fingerprint stays at 85/165.

**Scoring.**
- Refactor `arcadeKill` (45141-45155) into a shared `scoreKill(st,k,el,boss,x,y)` that holds the points table, the streak, the popup and the callout. `ARCADE` (DEMO) and `G.cs` (CAREER) each call it.
- Call sites: the host credit at **20431** gets `else if(G.career) careerKill(...)`; the player 2 kill word at **43834** gets the same.
- A revive of a teammate scores +250.
- **Loot never scores in CAREER.** Extracted loot goes to the stash as items only, through the existing settle.

**Waves as in DEMO.** `arcadeWaveTick` (44937) and the call at 35659 accept `G.career`.
- Run them only where `!netEntsPeer()` (host or solo), with the tier taken from the career score.
- At the grudge ledger (20437) add `&&!e.arcWave`, so synthetic wave identities never write `P` idents or REVENGE lines into his save.
- Wave kills do count toward contracts (my reading; he can say otherwise).

**Damage and kit.** Full enemy damage (no `ARCADE_DMG`) and no spawn shield. His own kit from the stash, as today. Coming back empty on death is unchanged.

**Settle.** In `endRaid`, beside hazard pay (23293-23305): `careerSettle(how,lines)`.
- `extract`: `final=G.cs.s*2`, `P.credits+=final`, `G.careerPaid=final`. It pushes onto the board `P.careerBoard` (top 10 `{s,k,t,cond}`, in his save) and `P.careerBest`. The card lines read `CAREER SCORE $N x2 · +$N CREDITS` and `NEW PERSONAL BEST` when it is one.
- `dead` / `abandon`: banks nothing (`SCORE LOST $N`), and the board is not touched (banked-only board).
- 2P CAREER: each window settles its own player into its own save, as co-op already does per player.

**HUD (minimal).**
- At 29113 the clock stays.
- One new `careerScoreHud()` draws `SCORE $N` (and `xN` while a streak lives) under the clock.
- DEMO: `arcadeScoreHud` draws `mm:ss` under the score.

**Risks.** These change every normal raid by his order:
- raidLen 600 against the 540 default
- rings never close
- waves
- credits at extract.

Corpus checks that assert raidLen 540, ring closing or exact settle credits must pin `CFG.career=0` or be re-baselined. Bots never pass through `startRaid`, so `SECTOR_MEAS` and the bot balance are untouched.

#### 0.7 FEEDBACK (ESC / TAB menu)

**Button.** A `FEEDBACK` button in `#pausebox` (HTML 867-877), shown in every pause box, the arcade box included. The operator lock is not weakened: nothing leaves the arcade. The old `#pausenote` textarea (866) and its floor-note save (13802-13810) are hidden; the old notes keep their place in the report.

**Click:**
1. Snapshot the frame first: `cv` plus `hcv` composited onto an offscreen canvas at native size, `toDataURL('image/png')`. The pause box is DOM, so the shot shows the game.
2. Open a small `#fbmodal`: a textarea, SAVE, CANCEL.

**SAVE runs `fbSave(note,png)`:**
- If `LOCAL_DROP` exists (46646-46647), POST JSON `{note,png,ver,pver,run,t}` to `http://localhost:8799/feedback`. `tools/collector.ps1` gets a `/feedback` route beside `/telemetry` (lines 21-35) that writes `exports/feedback-<stamp>.txt` and `.png`.
- Otherwise, or on failure, download both files with the `downloadExport` pattern (46721-46729) as `pillagers_feedback_<stamp>.txt/.png`, honouring `reportEmbedded()` (46707).
- It shows `FEEDBACK SAVED` (hubToast) and never writes `P`, so it is safe in the DEMO sandbox.

**Controls.**
- Keyboard: type; Ctrl+Enter saves; ESC cancels.
- Pad: A on SAVE, B cancels. A pad-only player can still send a screenshot with an empty note; there is no on-screen keyboard (open below).

---

### 1. TRIPWIRE MINE (his #6)

**Item and pouch.**
- `ITEMS.trip={name:'Tripwire Mine',val:160,wt:1,r:'uncommon',c:'#ff4a4a',use:'throw',tk:'trip'}`, appended after 2379.
- `THROWKEYS` (2559) becomes `['smoke','decoy','frag','trip']`.
- Pouch init (11563) adds `trip:0`; `tel.thr` (11604) adds `trip:0`.
- `cycleThrow` 13900: `%3` becomes `%THROWKEYS.length`.

**Belt.**
- `hotbarSlots` 16958-16962: skip the derived `throw:trip` cell while `!(G.pouch.trip>0)`. The belt of anyone not carrying one is identical to today (key 9 stays free).
- When it is carried, it is a throw cell "like a grenade". The automatic-pin yield (16998-17017) already handles a growing belt.

**Generic paths that need no change:**
- the belt selection (17302, 17345, 17398)
- the trigger cook (18727)
- grant (16337), refund (18970)
- stash on extract (23434-23437)
- kit packing (11651, 11667)

**Placement (keyboard and mouse first; pad unchanged).**
- Keyboard and mouse: the belt digit or Q, then LMB or G.
- Pad: LB/RB to the cell, then hold and release RT.
- Release throws through the existing `throwFrom` (14063): wall stop, ping, shield off.
- Only a frag cooks off (18692, 18730), so a trip is never "held too long".
- `activateThrow` (14162) gets `else if(th.kind==='trip') tripArm(th)`.

**`tripArm` geometry:**
- n is the perpendicular to the throw.
- Each half is cast with `rayHitG` up to 120, stopping 4 short of a wall.
- With no walls the wire is 80 + 80.
- Total length is clamped to 60-240, so it spans a doorway or corridor by itself.
- `G.trips.push({id,ax,ay,bx,by,arm:0.6,life:TRIP_LIFE 240s,seat})`, at most 3 live per owner (the oldest goes).
- It says `TRIPWIRE SET` (info).

**Trigger.** `tickTrips(dt)` is called at the end of `updateThrowables` (14431). It is cheap and does nothing with no trips, so the sim never pays.
- Only where bodies are authoritative: `!netEntsPeer()`.
- **Who trips it:**
  - every ent with hp>0 that is not merc, friendly, finished, peddler or stray
  - all machines except the hovering snitch
  - pillagers, neutral or hostile
- **Never players, never the hire.**
- **Detection.** Segment-segment intersection of the body's step (the previous `e.tpx,tpy` against now) with the wire, after a bounding-box cull. A body standing on the wire when it arms does not fire it until it moves.

**Blast: a new `tripBlast(m,x,y)`.** `explodeFrag` (14185-14274) stays byte-identical for normal frags.
- R 150. Damage `110*(1-d/R)+30` to ents with line of sight; no player damage path at all (no team damage, no self damage); no wall damage.
- Effects: `sfx('boom')`, spark, flash, shake by distance, `ping(…,520)`.
- **Credit:**
  - owner seat 0: `e.byPlayer=true`, then `notoAggress`
  - seat >0: `e.byPlayer=false; e.bySeat=seat` (the 43345 path sends the kill word)
- Survivors chase toward the blast point.

**Co-op.**
- `netThrTake` whitelist (41837) adds `'trip'` and `'tgo'`.
- Player 2: at landing, `netThrSend('trip',x,y,{ax,ay,bx,by,id,s:NET.seat})` and keep a local fx copy.
- The host creates the real one (seat s) and relays fx copies.
- When it fires or expires, the host broadcasts `{k:'tgo',id}` and every window removes it.

**Draw.**
- `tripDraw()` hooks into **render2D after 27751** (after the locked-room lamps, above fog), so the owner and teammates always see their wires:
  - a faint red line, alpha .14-.22 with a pulse
  - emitter nubs with an LED
  - dashed while arming
- While a trip is in hand, a dashed preview at the predicted spot (`tripPreview()` shares the `throwFrom` math).
- Cook label 29702: `TRIPWIRE · RELEASE TO SET`.
- `drawItemIcon` (32138): an icon branch.

**Sources.**
- **DEMO kit:** `arcadeKitApply` 44519 adds `g.pouch.trip=(Math.random()<ARCADE_TRIP_P 0.35)?1:0`.
- **DEMO loot:** `arcadePostBuild` adds a `sideStream(g.seed,TAG_TRIP)` sprinkle of `trip` into 8 ordinary non-cache boxes (sideStream 5303 restores RNGS).
- **CAREER and normal loot ("only if cheap"):** an optional build. The same sideStream sprinkle into 4 boxes from `careerPostBuild`. It changes loot contents only: no counts, no positions, so 85/165 and the live/sim parity hold.
  - Risk: checks that inspect specific box contents at seed 4242. My recommendation is to ship it.

**Risks.**
- The `%3` cycle bug if missed.
- `G.pouch.trip` undefined becoming NaN in old saves' kit paths: guarded with `!==undefined` as at 11651.
- The tripwire hook line is in render2D.

---

### 2. GUN STAT CARDS (his #17): on pickup and in the backpack

**Model (pure, `gunStats(w)` and `gunCompare(f,h)`):**
- Damage per pull: `dmg×(pellets||1)×(burst||1)`
- Rate: `60000/rof` rpm
- Magazine
- Range: `rng/10` m
- Handling: `round(100×(0.6×clamp(1−spread/0.2,0,1)+0.4×clamp(1−(reload−1200)/3000,0,1)))`
- Sustained damage per second: `perPull×pulls/(pulls×rof/1000+reload/1000)`, with `pulls=mag/(burst||1)`

**Verdict:**
1. The `WTIER` difference (2159) first: higher tier is UPGRADE, lower is DOWNGRADE. This agrees with the arcade routing in 45089-45117.
2. At equal tier, the sustained ratio: ≥1.08 is UPGRADE, ≤0.92 is DOWNGRADE, otherwise SIDEGRADE.
3. Against bare hands it is always UPGRADE.

Deltas are green when better, red when worse, dim when equal. All five stats are higher-is-better.

**Pickup.**
- In `grantLoot`'s gun branch (16338-16474), after the route is known, set `G.gunCard={gk,vs:snapshot of p.wep,route:tag,t0:G.t}`.
  - Arcade: only when `arcadeGunLoot` returns STOWED or `KEY n` (45084-45122).
  - CAREER: on every gun pickup (IN HAND / SLOT n / BACKPACK / KEY n).
- `gunCardHud()` is called once from drawHUD next to `drawPickups` (30632). It draws above the pickup stack at the right edge:
  - 4 s life, hidden with the backpack or map open
  - name in rarity colour, verdict chip, `VS <HAND GUN>`, five rows, route tag
- Fonts `hudFS`, sizes ×`hudRes()`, so at 4K it is about twice the 1080p size: readable on a TV.

**Backpack.** In `drawBag`'s selected-stack block (32907-32949), for `it.use==='gun'`, draw the compare card in the right half. `itemRows` stays on the left for everything else.
- The card follows the mouse hover first (keyboard and mouse first), else `G.bagSel`. The pad D-pad already moves `G.bagSel`.

**HUD-minimal note.** Both are one self-contained draw function each, fed by `gunCompare`, so the UI redesign can restyle them without touching the model.

---

### 3. DEATH RECAP (his #29): on the KIA / EXTRACTED card

**Data.**
- `_logHit` (15266-15278) adds `k:src` and `w:weaponOf(src,srcName)`.
  - It is cosmetic and only reached when `!G.sim` (the sim returns before the push).
  - `weaponOf` finds a living or dying raider named `srcName` in `G.ents` and uses `e.wep.name`. Otherwise a table: crawler CLAWS, sentry AUTOCANNON, howler SHELLS, warden HEAVY CANNON, bulwark SHIELD GUN, choir PILLBOX, listener PULSE, yourself YOUR OWN CHARGE, lightning THE STORM.
  - No signature changes. The player 2 window gets the same lookup on its own world copies.
- `deathRecap(T)` returns `{killer, weapon, hits:last 6 grouped as at 23806-23811, bySrc: totals sorted}`.

**CAREER (the outcome card).**
- KIA, 23772-23833: the sub line becomes `KILLED BY <N> · WITH <W>`. Add a `DAMAGE TAKEN` block (top 4 sources, `-N (x HITS)`) under `HOW IT WENT`.
- EXTRACTED, 23764-23771: the same `DAMAGE TAKEN` block when there were hits.

**DEMO.**
- The RUN OVER card (`arcadeOverSync` 45796-45811) gets the recap lines of this window's last life. A 1P death shows KILLED BY and WITH; an extraction shows `EXTRACTED x2`.
- 2P only, during the 3 s respawn hold: `arcadeRespawn` snapshots `ARCADE.recap` from `G.tel.hitLog`, then clears hitLog (the arcade never settles it). A minimal text block (`KILLED BY …`, 3 hits, top source) is drawn from `arcadeHud` (45230) while `holdT>0`.

Each window shows its own.

---

### 4. INTERIORS (his #32): COLD STORAGE, an arcade-only post-build pass

**Cheapest route.** Do not touch the build. COLD STORAGE already has four `'core'` buildings: strongrooms with exactly one interior door (5720-5734, recorded in `map.idoors` at 7401). Sealing that one doorway turns a strongroom into a keycard vault.

**4a Keycard.**
- `ITEMS.keycard={name:'Vault Keycard',val:250,r:'rare',c:'#7fe3d4',use:'key',door:'arc'}`.
- `keyFits(it,door)`: `it.use==='key'&&(it.door===door.id||(it.door==='arc'&&(door.arc||(G&&G.arcade))))`. It is used at:
  - `doorKeyIx` 7780
  - the door use at 18826
  - the HUD prompt at 29508 and 29515
- In DEMO a keycard opens any locked room, the authored `cs_freezer` and `cs_office` included.
- In a raid that is not DEMO it opens only arc vault doors (none exist unless 4d ships), so nothing changes there.
- The Peddler's ITEMS scan (10083) only matches map door ids, so the stream does not move.

**4b DEMO vaults: `arcadeVaults(g)` in `arcadePostBuild`, inside `sideStream(g.seed,TAG_VAULT)`.**
- **Candidates:** core buildings whose non-furniture interior walls (`ib===bi && !furn`, ≥4 of them) give a strongroom box, that have one `idoors` entry inside the box, that have no ent and no spawn inside, and that do not overlap a locked room.
- Pick `ARCADE_VAULTS=2` with `ri` on the side stream.
- **Per vault:**
  - push the door wall `{…door rect, d:3, door:'arcvN', wid:walls.length}` (unique `wid`s for the late-join wall list at 41380)
  - push `{id:'arcvN', name:'VAULT A/B', box, doorX, doorY, open:false, arc:1}` onto `g.map.locked`
  - two `'cache'` boxes inside via `spotWall` / `mkContainer` (side stream), one guaranteed tier-4 gun
- Then `rebuildGeometry()` (15448). It rebuilds segs, nav, navD, the free-spot grid and the reach flood.
- **What comes for free:**
  - the lamp at the door (27736-27751)
  - the map outline and label (33298-33310)
  - `shutRoomAt` for waves (44891)
  - the door word for co-op (42840-42861)
- **Both windows run the identical pass,** so the arcade `netUpFp` (41221-41229) matches.
- **No main-stream draw:** RNGS is the same before and after. A plain `__deploy` is unchanged (85/165).

**4c Keycards in the world.**
- **Post-build** (side stream): one keycard per vault in an ordinary box outside every locked room, mirroring the rules at 10848-10896.
- **On the run authority, at the death site** (beside 20431, after the drop branches): an elite, or every 12th kill while a vault is shut and no keycard lies on the map, drops a keycard pile built under `fxBorrow` (5309), so it uses no main stream. It reaches player 2 through `netContNumber` (44189-44207).
- **Opening a vault in DEMO** pays `VAULT OPEN +$500` to the opener's score.

**4d CAREER vaults (later, after 4b proves out).**
- Seal plus loot only: seal the door, and upgrade the loot of boxes already inside. No new containers, so the 165 holds.
- Keycards come only from kills in CAREER.

**Optional 4e.** Door frames and thresholds drawn at `map.doors` / `map.idoors`. This is render2D, so leave it to the graphics program.

**Risks.**
- **A sealed room with a body inside.** It is skipped at selection, and later spawns honour `shutRoomAt`.
- **Respawn or re-drop beside a vault wall.** Add `!shutRoomAt` in `arcadeRespawn` 44764.
- **The interior repair pass.** `repairInteriors` can strip a core interior: the "≥4 walls" test skips those buildings.
- **Changing the map build itself is not needed.** If it ever is, the 85/165 gate and `__verify` must be re-measured and the new numbers passed in `opt.ents`.

---

### 5. CONTROLLER AND KEYBOARD NAVIGATION (keyboard and mouse first; his 2026-09-27 pad layout kept; no aim assist exists and none is added)

#### Audit of what exists

| Screen | Keyboard and mouse | Pad |
|---|---|---|
| Title | arrows / W / S cycle the data-mode rows; ENTER / Space (49176) | `padMenu` focus, D-pad / stick, A, B ignored (13151) |
| Attract (DEMO) | any key drops in, F-keys and modifiers excluded (45564-45582) | any button (host), A only (player 2) (13327-13334) |
| Initials | letters, Backspace, Enter (45972) | the pad handler (45989-45999) |
| Pause (RESUME / END RUN in DEMO) | handled | `padMenu`; B / MENU resume (13152-13159) |
| Backpack | arrows, Enter equip (12192), drag | D-pad, A pick and place onto a gun cell = equip, Y drop, B close (13586-13603) |
| Belt | digits, Q | LB/RB taps (13568-13584) |
| Map | — | D-UP |
| Pad unplug | — | pause (13615-13626) |

#### Gaps found

1. **The title default is START** (fixed by 0.1).
2. **RETRY** (`#moderetry`) is not in `netTitleRows`, so the keyboard arrows cannot reach it.
3. **END RUN ends the run on one press** (46589), with no confirm. Pad focus starts on RESUME, so one D-pad step and A ends a party run.
4. **RUN OVER:** any key, click or button drops a new run in at once (`arcadeKeyAtt` / `arcadePadAtt`), so mashing at the end restarts the run.
5. **During the 2P respawn hold** (`holdT`), `raidKey('Space')` (12142) still calls `tryRoll`. That drops the shield while the player is frozen, and the pad A does the same.
6. **FEEDBACK modal navigation** (new in 0.7).
7. **No pad text entry.** OPEN, with the default "not built".

There is no pad gap in equipping from the backpack: A picks up and A on gun cell 1 or 2 places it. **No new pad bindings are added.**

---

### 6. PRO SOUND (his #45): punchy arcade style, all cosmetic

Sound uses Math.random or fxr only; nothing runs under `G.sim`.

**6a Buses and dynamics.**
- `SND={bus:{gun,imp,mach,foley,amb,vox,ui,sting,world},world,comp,lim}` is built in `bus()` (3894-3905):
  - every category gain → WORLD (gain 1.15) → DynamicsCompressor (−16 dB, knee 10, ratio 3.5, attack 4 ms, release 220 ms) → limiter (−3 dB, ratio 20, attack 1 ms) → BUS
  - **ui and sting go → BUS directly**, so they are not compressed, ducked or reverberated
- The reverb send moves from `BUS.connect(R.send)` (3902) to `WORLD.connect(R.send)`.
- **BUS stays the master:** `volApply` (3885) and `netSndRoute` (41137) are unchanged, so **player 1 left / player 2 right is kept**.
- `blip` 4696: `var OUT=sndBus(SND_CAT[type]||'world')||bus()||a.destination;` with:
  - gun: shot, reload, reloadin, dry
  - imp: boom, hit, clank
  - mach: servo, skitter, drone, hydraul, dish, stepHeavy, seen, alarm
  - foley: foot, step
  - ui: pick, pickRare, pickElite, pickGun, clockwarn, clocktick
  - vox: heart
  - amb: flap
  - world: the rest
- `ambience` 4477 → amb; `voxGrunt` / `voxBreath` 4450 / 4465 → vox.

**6b Ducking.**
- `sndDuck(cat,depth,hold)` and `sndMixTick(dt)` are called in the loop beside `tickVerb` (35696). They are NOT inside `tickAmbience`, which the fixture stubs (mkfixture 1117).
- A boom within 700 ducks amb to 0.35, mach to 0.6 and foley to 0.7 for 0.5 s, then recovers over 1.6 s.
- A player hit ducks amb to 0.7. Stings duck amb to 0.6.
- **UI and sting are never ducked.**

**6c Distance and occlusion.**
- `sfx` (4431) sets `SND_CTX={x,y,occ}` with `occ=!losClear(player→source)` (cached per frame per rounded spot).
- `blip` inserts a lowpass at 900-1500 Hz when occluded, and widens the pan ×1.4 under 150 / narrows it ×0.7 past 700.
- Own sounds (`blipMine` 4422) take the player's position.

**6d Punchy guns.** `gunLayers(d,space)` in the shot branch (4737-4813):
- **Near crack** (d<250): a 4 kHz high-passed click plus the existing crack and body.
- **Mid:** as now.
- **Far** (>650): crack lowpass 800 at ×0.6, a distant thump, and an environment tail from `spaceAt` (4279) at the source:
  - inside: slap (two 45/90 ms echoes)
  - open: roll (0.9 s lowpassed decay)
  - woods: soft
  - vault: ring
  - water: hiss
- Own shots get the tail at 0.5.
- **Feedback sounds:** a hit-marker tick on the ui bus when the player's round lands (22415 path), a kill confirm, an armour-break crack and a shield pop.

**6e Machine state loops (off-screen warning).** `tickMachLoops(dt)` sits beside `tickMachineVoices` (35695).
- Three pooled persistent voices are re-assigned every 0.25 s to the nearest searching or fighting machines within 900 that `canSee` says are not visible.
- Per-kind patches:
  - sentry: saw 140 Hz → bandpass 900, LFO 3 / 7 Hz
  - crawler: noise gated at 9 / 16 Hz
  - warden: 48 Hz plus saw 96, LFO 0.6 / 1.4
  - snitch: triangle 420 with vibrato
  - listener: sweep 700-1100
  - howler: low saw plus bursts
  - bulwark: square 55 treads
- Searching is slow and quiet; fighting is faster and louder.
- Occlusion lowpass; 0.3 s fades. `sndLoopsOff()` in `ambienceOff` (4532) and the arcade teardown.

**6f Impacts by material.** `matOf(wall)`:
- tree / furn → wood
- win → glass
- wreck / car → metal
- lockWall / door → metal
- else concrete

Ents: raider → flesh; bulwark / warden → armor; others → metal.

Pass the material as the 4th argument:
- `sfx("clank",x,y,mat)` at 22556 and 22561
- `sfx("hit",…,mat)` at 22415, 22465 and 43608
- the weak spot at 22285 and the bulwark at 22304

The clank and hit branches (5265, 4821) get one patch per material. **The `rnd(3,6)` decal draw at 22535 is untouched**, so the stream does not move.

**6g Footsteps.**
- `surfAt` (4310) is unchanged, so the ping radii in `tickPlayerSteps` (4353-4357) are unchanged.
- A new cosmetic `surfFine(x,y,base)`:
  - stone: wet (rain >0.3) / grit (yard landmarks) / concrete
  - wood: tile (cells and core rooms) / boards
  - metal: grate
  - leaf, water
- Passed as a **6th** argument (`blip('foot',d,pan,surf,stance,fine)`), so checks reading argument 4 still pass.
- Three micro-variants per surface (Math.random). Enemy steps (4595-4596) get the fine surface too.

**6h UI sounds.** `sndUi(kind)` on the ui bus:
- move (2.2 kHz tick)
- ok (660→990)
- back
- deny
- open / close

Hooks:
- `padSetFocus` 13053 (when the element changes)
- a document capture `click` on buttons, `.sectorpick`, `.cell` and `[data-slot]` (ok, or deny when disabled)
- `padMenu` B 13160
- `togglePauseBox` 13768
- backpack open and close
- initials letter changes

**6i Voice barks, word by word, through Web Audio** (so the split speakers are kept).
- Short clips rendered once at build time by Windows SAPI (System.Speech) and embedded as base64 WAV in a `VOX_BARKS` table. They are decoded once at the first `ac()`.
- Played through the vox bus with a radio band-pass and a light WaveShaper, which makes them punchy and hides the TTS flatness.
- Barks: RELOADING, FRAG OUT, TRIPWIRE SET, I'M DOWN, REVIVING, HEALING, OUT OF AMMO, EXTRACTING, SCORE LOST.
- Announcer on the sting bus: DOUBLE KILL, TRIPLE KILL, RAMPAGE, UNSTOPPABLE, NEW HIGH SCORE, EXTRACTED, TWO MINUTES, ONE MINUTE, WAVE INCOMING.
- One at a time, a 1.2 s gap, by priority.
- Fallback: `speechSynthesis` only when decode fails AND `!NET.same`, because it cannot be panned.

**6j Arcade stings.** `arcSting(kind)`, each ≤1.2 s and tonal: extract, streak, hi, wave, vault, and the drop ticks 3-2-1.

Called from:
- `arcadeExtracted`
- the streak callout in `scoreKill`
- `arcadeHiSay` 46068
- `arcadeWaveTick` 44962
- the 2P respawn countdown

These are cues, not music (his no-raid-music rule).

**6k Music only on the title and the DEMO attract, never in raids.**
- `musicWanted` (4136-4158): keep `if(G) return false`.
- Then `return titleOn()||(ARCADE.on&&ATT.on);`. The Undercroft goes silent, by his words. The attract video is muted (35152), so the music plays over it.
- The player 2 rule at 4157 and `netMusPan` (41082) still keep one song, and keep it off a player who is in a raid.

**Risks.**
- **The fixture has no AudioContext** (the comment at 3949), so every sound check must install a fake context (Part 3).
- **Node count per shot rises by about 2.** Fine on the audio thread at 60 fps and 4K.

---

## PART 2. SHIPPABLE BUILDS (one behaviour each), BATCHES, PARALLELISM

### Batch M1, the shell (one agent)

| Build | Behaviour | Main sites |
|---|---|---|
| feat0a | DEMO / CAREER title, DEMO focused first, ENTER / A gives 1 PLAYER DEMO | 1278-1290, CSS, 13089, 40789, 40593, 40827 |
| feat0b | THE COLD MILE frozen | 6491, 6637, 47004, 46917, 45353, 38826 |
| feat0c | player version v0.0001 | 1698, 48989, 49185, 40277, 40329, 38927 |
| feat0d | NO HALLOWEEN | 44602-44677, 44705, **render2D 26238 and 27900**, 45439, 45500, 45509 |

### Batch M2, DEMO rules (one agent, after M1)

| Build | Behaviour | Main sites |
|---|---|---|
| feat0e | 10-minute DEMO clock, burns at 0 | 44699, 35628-35651, 45635 |
| feat0f | DEMO death: one self-revive; 1P ends the run; 2P respawns with the score reset to 0; no respawn in the burn | 23002, 44752 |
| feat0g | extraction ×2 ends the run, then RUN OVER and initials; bonus, pot, re-drop and in-raid initials removed | 44790-44847, 45074, 45247, 46023-46051, 35654, 45177, 45721 |

### Batch M3, CAREER (one agent, after M2)

| Build | Behaviour | Main sites |
|---|---|---|
| feat0h | `careerPostBuild`, the `scoreKill` refactor, career kills, waves in CAREER, the minimal score line | 11759, 20431, 20437, 43834, 45141, 44937, 35659, 29113 |
| feat0i | `careerSettle`: ×2, 1 score = 1 credit on extract only, the personal-best board | 23293-23305, card lines |

### Batch FB, FEEDBACK

| Build | Behaviour | Main sites |
|---|---|---|
| feat0j | FEEDBACK button and modal, screenshot, collector `/feedback`, download fallback | 862-880, 13768-13864, 46588, `tools/collector.ps1` |

### Batch T, TRIPWIRE

| Build | Behaviour |
|---|---|
| feat1a | item, pouch, belt cell, throw and arm |
| feat1b | trip, blast, credit, never players |
| feat1c | co-op words (41824-41854) |
| feat1d | draw: **render2D hook after 27751**, preview, icon, cook label |
| feat1e | DEMO kit and loot (44519, sideStream sprinkle) |
| feat1f | CAREER loot sprinkle, cheap and optional |

### Batch S, STAT CARDS

| Build | Behaviour |
|---|---|
| feat2a | `gunStats` / `gunCompare` model |
| feat2b | pickup card (grantLoot 16338-16474, one drawHUD line beside 30632) |
| feat2c | backpack card (drawBag 32907-32949) |

### Batch R, RECAP (after M2 and M3)

| Build | Behaviour |
|---|---|
| feat3a | hitLog weapon, `deathRecap`, CAREER KIA / EXTRACTED card (15266-15278, 23764-23833) |
| feat3b | DEMO RUN OVER recap plus the 2P respawn-hold recap (45796-45811, 44752, 45230) |

### Batch I, INTERIORS (after M2)

| Build | Behaviour |
|---|---|
| feat4a | keycard plus `keyFits` (7777, 18826, 29508, 29515) |
| feat4b | DEMO vaults (`arcadePostBuild`, sideStream, rebuildGeometry) |
| feat4c | keycards in the world, kill drops (beside 20431), VAULT OPEN pay |
| feat4d | CAREER seal-only vaults, optional and later |

### Batch C, CONTROLS (after M1 and M2)

| Build | Behaviour |
|---|---|
| feat5a | RETRY in `netTitleRows` (40805) |
| feat5b | END RUN arms first: `END RUN?  PRESS AGAIN`, 3 s (46589, 13838) |
| feat5c | RUN OVER input guard, 1.5 s (45564, 45584) |
| feat5d | input guard during the DEMO respawn hold (raidKey 11993; `tryRoll` 13940) |

### Batch A1, SOUND CORE

| Build | Behaviour |
|---|---|
| feat6a | buses, compressor, limiter |
| feat6b | ducking |
| feat6c | distance and occlusion |
| feat6d | punchy guns, environment tails, hit / kill confirm |
| feat6f | impacts by material |
| feat6g | footsteps |

### Batch A2, SOUND FEATURES (after A1; stings after M2 and M3)

| Build | Behaviour |
|---|---|
| feat6e | machine state loops |
| feat6h | UI sounds |
| feat6i | voice barks |
| feat6j | stings |
| feat6k | music on the title and the attract only |

### Parallel waves

- **Wave 1, parallel:** M1, A1, S, and T (feat1a-1c). Regions: title / HTML / map tables / the arcade Halloween block, the audio section 3860-5290 plus the 6 sfx call sites, grantLoot / drawBag, and the throwables section plus the net thr block. They are disjoint.
- **Wave 2:** M2 first. Then M3, I and T (feat1d-1f) in parallel; FB alongside.
  - M3 and I both touch the kill site near 20431, on different lines: merge M3 first.
  - feat1e touches `arcadeKitApply` and `arcadePostBuild`, which I also touches: merge feat1e before feat4b.
- **Wave 3, parallel:** R, C and A2.
  - A2's stings and the 6h `padSetFocus` hook touch functions C may touch (`padMenu`); C first.

### Graphics and UI program overlap

- **render2D:**
  - feat0d removes the hooks at 26238 and 27900
  - feat1d adds one hook after 27751
  - feat4e (optional) would be in the wall pass
- **drawOp and the entity draws:** none.
- **drawHUD and drawBag** (the HUD the UI redesign will redo):
  - feat0h, the score line at 29113
  - feat2b, one call beside 30632
  - feat2c, inside drawBag
  - feat1d, the cook label at 29702
  - feat3b, inside `arcadeHud`

  Each is one self-contained draw function over a pure model, so the UI program can restyle or replace it.

---

## PART 3. ONE CHECK PER BUILD (game scope, the fixture style of mkfixture 5747-5895)

Each passes on the new build and fails on the previous one.

**Common rules:**
- Wrap every check in `try / finally`, with `arcadeLeave()` when `ARCADE.on`, `__endRaid('abandon')` when a raid is live, and `__topClear()`.
- Canvas stubs go on `hcv.getContext('2d')` as own properties and are deleted after.
- **Fake audio for the feat6 checks.** Save `AC, BUS, REV, AMB, SND`, set `AC=fake; BUS=REV=AMB=SND=null`, and restore all of them in `finally`.
  - `fake` = `{currentTime:1, sampleRate:48000, state:'running', destination:N('dest'), createGain, createBiquadFilter, createStereoPanner, createDynamicsCompressor, createOscillator, createDelay, createBufferSource, createWaveShaper` (each returning `N(kind)`), `createBuffer:(c,l)=>({getChannelData:()=>new Float32Array(l)}), decodeAudioData:()=>Promise.resolve({}), resume(){}}`.
  - `N(k)` = `{kind:k, outs:[], connect(t){this.outs.push(t);return t}, disconnect(){this.outs=[]}, start(){}, stop(){}}` plus AudioParams (`value` and `setValueAtTime` / `setTargetAtTime(v){this.value=v}` / ramps / `cancelScheduledValues`) for gain, frequency, Q, pan, threshold, knee, ratio, attack, release, delayTime, playbackRate.
- **Pad stubs.** `navigator.getGamepads=()=>[{connected:true,index:0,id:'x',buttons:Array(17).fill(0).map(()=>({pressed:false,value:0})),axes:[0,0,0,0]}]`, restored after.

### Modes (feat0)

**feat0a, the title.**
1. Show `#title`; `PAD.focus=null`; call `padMenu(()=>false)`. `PAD.focus.id==='modearcade1'`.
2. The `netTitleRows()` ids start with `modearcade1, modearcade, titlestart, modecoop, modepvp`.
3. `#mhdemo` and `#mhcareer` exist and read DEMO and CAREER.
4. Stub `arcadeSoloPick` (record); `netTitleEnter(go_stub)` with no focus calls it and not `go`.
5. At menu zoom 2.4 the title still fits (the 23.58 measure).

The previous build focuses titlestart and calls `go`.

**feat0b, the mile frozen.**
1. The largest map by `w*h` is index 1; `mapOffered(FIXED_MAPS[1])===false`; `offeredCount()===1`.
2. `renderSector()` leaves no `.sectorpick[data-map="1"]`.
3. With `P.mapIx=1`, `arcadeEnter('host')` gives `ARCADE.mapIx===0` (then `arcadeLeave`).
4. `__startRaid({mapIx:1,seed:4242})` still gives 374 ents.

The previous build offers both maps.

**feat0c, the version.**
1. `verShown('23.59')==='v0.0001'` and `verShown('23.60')==='v0.0002'`.
2. `#titlever` and `#verlabel` text equals `verShown(VER)`.
3. `buildExport()` contains `'v'+VER`.

The previous build shows `v23.58`.

**feat0d, no Halloween.**
1. `arcadeDeploy({mapIx:0,seed:4242})`: `G.arcPumps===undefined`, and every `G.lights[i].c` equals the light colour of a plain `__deploy` at the same seed.
2. `typeof arcadeHallow==='undefined'`.
3. `arcadeAttStart()`: the overlay text has no `HALLOWEEN`.

The previous build has pumpkins.

**feat0e, the DEMO clock.**
1. `arcadeDeploy`: `G.raidLen===600` and `raidClockOn()`.
2. Set `G.timeLeft=0.02`; 5 `__loop` frames. `G.nuking===1`, `__state()===g`, `P.runs` unchanged.

The previous build has `raidLen 0`.

**feat0f, DEMO death.**
1. Solo: `ARCADE.solo=1`, `arcadeShieldOff`, `killPlayer('sentry')`, 120 frames. `!G`, `ARCADE.over.why==='dead'`, `#outcome` not on, `P.runs` unchanged.
2. Two-player: `ARCADE.solo=0`, `ARCADE.mine=900`, `killPlayer`, 120 frames. `G.arcade`, `ARCADE.mine===0`, `ARCADE.holdT>0`.
3. With `G.nuking=1`, a death does not respawn: `specOut` is set.

The previous build respawns the solo player and keeps the score.

**feat0g, extraction.**
1. Solo: `ARCADE.mine=1500`; `__endRaid('extract')`. `ARCADE.over.team===3000`, `ARCADE.over.why==='extract'`, `!G`.
2. Two-player host with `ARCADE.mate=400` and a stubbed `netSamePost`: `team===3800`, and the `arcend` word has `x2`.
3. Stage a board where 3000 makes the top 10: `ARCADE.ini` is set (initials at RUN OVER).

The previous build gives `mine=4000` and a re-drop.

**feat0h, CAREER raids.**
1. `__deploy({kit:[],safe:null,mapIx:0,seed:4242})`: `G.career===1`, `G.raidLen===600`, `G.ents.length===85`, `G.containers.length===165`, every `closeAt===undefined`.
2. Push a crawler with `hp=0, byPlayer=1`; `__ents(.016)`. `G.cs.s===50`.
3. `p.armor=0`; `damagePlayer(20,…)` takes `20*CFG.eDmg` (full damage).
4. `G.cs.s=9000; ARCADE.waveT=999` (or the career wave clock); one wave tick adds `arcWave` bodies.
5. `CFG.career=0` with `__deploy` gives `!G.career` and `raidLen 540`.

The previous build has no `G.career`.

**feat0i, CAREER settle.**
1. `__deploy`; `G.cs.s=700`; `__endRaid('extract')`. `G.careerPaid===1400`, `#oc_manifest` contains `CAREER SCORE`, `P.careerBoard[0].s===1400`.
2. New deploy; `G.cs.s=700`; `__endRaid('dead')`. `G.careerPaid===0` and the board unchanged.
3. Restore the board and credits.

The previous build has no `G.careerPaid`.

**feat0j, FEEDBACK.**
1. Stub `fetch` (capture), `URL.createObjectURL` and the anchor `click`. `togglePauseBox(true)`: `#fbbtn` is visible, in the arcade box too (with `arcadeDeploy`).
2. Click it: `#fbmodal.on`. Type a note and click SAVE. The captured payload has the note and a PNG data URL (or two blobs, one `image/png`).
3. In arcade, `localStorage.getItem(SKEY)` is unchanged.

The previous build has no button.

### Tripwire (feat1)

**feat1a, throw and arm.**
1. `__deploy`. `hotbarSlots()` has no `throw:trip` cell and the same length as before.
2. Set `G.pouch.trip=1`. A `throw:trip` cell appears.
3. `G.tsel=THROWKEYS.indexOf('trip')`; put `mouse` 200 px right; `doThrow()`; `__sim(.05)` ×20. `G.trips.length===1`, length in 60-240, `G.pouch.trip===0`.
4. `cycleThrow` reaches `trip`.

The previous build has no `ITEMS.trip`.

**feat1b, the trip.**
1. `tripArm` at a clear spot 300 from the player, with arm 0.
2. A crawler on side A; `tickTrips(.016)`; move it to side B; `tickTrips`. The crawler is damaged, `G.trips` is empty and the player's hp is unchanged (the player stands 60 from the wire).
3. A second wire: walk `G.player` across it. It stays.

The previous build has no `tickTrips`.

**feat1c, co-op.**
1. `NET.role='host'` with a stand-in peer `{state:'in',seat:1}`. `netThrTake(peer,{t:'thr',k:'trip',x,y,ax,ay,bx,by,id:'s1-1',s:1})` returns `'thr:trip'` and the trip has seat 1.
2. A body tripping it ends with `bySeat===1` and `byPlayer===false`.
3. As `role='join'`, `k:'tgo'` removes the fx copy.

The previous build returns `'bad'`.

**feat1d, the draw.** Stub `wc.stroke` and `wc.lineTo` (own properties) and run one `render2D` frame with a trip. The calls include the wire endpoints with a red `strokeStyle`. The HUD trace while holding a trip has `RELEASE TO SET`.

**feat1e, DEMO sources.**
1. `Math.random` stubbed to 0: `arcadeKitApply` gives `pouch.trip===1`. Stubbed to .99: 0.
2. Two `arcadeDeploy({seed:4242})` give the same box ids holding `trip`, and RNGS is equal right before and right after the sprinkle.

**feat1f, CAREER sprinkle.** `__deploy`: 4 boxes hold `trip`, the counts are 85/165, and the `__verify` parity reads identical.

### Stat cards (feat2)

**feat2a, the model.**
- `gunCompare(WEAPONS.lmg,WEAPONS.rifle).verdict==='UPGRADE'`
- `gunCompare(WEAPONS.pistol,WEAPONS.rifle)` is DOWNGRADE
- `gunCompare(WEAPONS.rifle,WEAPONS.rifle)` is SIDEGRADE with all deltas 0
- `gunStats(WEAPONS.shotgun).dmg===96`

**feat2b, the pickup card.**
1. `arcadeDeploy`; `p.wep=arcadeGun('chatter')`, `p.sec=arcadeGun('smg')`; `grantLoot({x:p.x,y:p.y,loot:[]},['gun_lance'])`. `G.gunCard.gk==='lance'`.
2. An `hcv` fillText trace of `drawHUD` contains `UPGRADE` and `DMG`.
3. At `__forceSize(3840,2160)` the card font px is at least 1.8× the 1080p size.

**feat2c, the backpack card.** `__deploy`; `G.bag=['gun_dmr']`; `G.bagOpen=true`; `G.bagSel=0`. The `drawHUD` trace contains a verdict word and `HANDLING`.

### Recap (feat3)

**feat3a, the CAREER card.**
1. `__deploy`. `damagePlayer(30,'sentry','SENTRY',…)` twice, then a raider-sourced hit.
2. `G.tel.hitLog.at(-1).w` is set.
3. `__endRaid('dead')`: `#oc_sub` has `WITH`, and `#oc_manifest` has `DAMAGE TAKEN` and `SENTRY`.

The previous build has no `w` and no block.

**feat3b, the DEMO recap.**
1. Solo DEMO: hits, then death. The RUN OVER element text has `KILLED BY` and `SENTRY`.
2. Two-player: after the respawn, `ARCADE.recap.killer==='SENTRY'` and `G.tel.hitLog.length===0`; the HUD trace during `holdT` has `KILLED BY`, and after the hold it does not.

### Interiors (feat4)

**feat4a, the keycard.**
1. `arcadeDeploy`; `G.bag.push('keycard')`; stand at the `cs_freezer` door; `keys.KeyE=true`; `__sim(.05)`. The room is open and the keycard is spent.
2. A plain `__deploy`: the keycard at the same door does nothing, and `key_cs_freezer` still opens it.

**feat4b, the vaults.**
1. `arcadeDeploy` twice at seed 4242: two `arc` locked rooms with identical rectangles, identical `netUpFp(G).h` both times, and RNGS restored around `arcadeVaults`.
2. No ent sits inside a vault; each vault holds ≥2 caches; `shutRoomAt` is true inside.
3. A plain `__deploy` gives 85/165 and no `arc` rooms.

**feat4c, keycard sources.**
1. At least one box per vault holds a keycard, and none of them is inside a locked rect.
2. An elite crawler kill on the host leaves a new keycard container.
3. Opening a vault raises `ARCADE.mine` by 500.

### Controls (feat5)

**feat5a.** Show `#moderetry`. It is in `netTitleRows()`, and `netTitleMove` reaches it.

**feat5b.** `arcadeDeploy`; `togglePauseBox(true)`; one `#arcendbtn` click leaves `G.arcade` and `!ARCADE.over`, and the text reads `END RUN?`. A second click ends the run.

**feat5c.** `arcadeRunEnd('menu')`, then `arcadeKeyAtt(synthetic keydown)` right away: `!G`. With `ARCADE.over.at-=2000`, the same key drops in.

**feat5d.** Two-player DEMO respawn (`holdT=3`): `raidKey('Space')` leaves `p.roll===0` and `p.arcSh===1`. The pad A (stub pad, `pollPad()`) does the same.

### Sound (feat6)

**feat6a, buses.** Fake audio; `bus()`.
- `sndBus('gun').outs[0]===SND.world`; WORLD reaches comp, comp reaches lim, lim reaches BUS.
- `sndBus('ui').outs[0]===BUS`.
- `REV.send` is in `SND.world.outs` and not in `BUS.outs`.
- `blip('shot',100,0,'rifle')` creates nodes whose chain reaches `sndBus('gun')`.
- With `NET.same='host'` and split on, `BUS.outs` reaches `NET.sndP` with pan −1.

The previous build has no `sndBus`.

**feat6b, ducking.** `sfx('boom',p.x+100,p.y)`: `SND.bus.amb.gain.value≤0.4`. `sndMixTick(2.5)`: ≥0.95. `SND.bus.ui.gain.value===1` throughout.

**feat6c, occlusion.** `sndPlace(x,y)` for a point behind a building wall gives `occ:1` and `lp≤1500`; for a point in the open with a clear line, no lowpass.

**feat6d, guns.**
- `gunLayers(100,'open').crack>0`
- `gunLayers(800,'open')` has crack 0, a tail and `tailKind==='roll'`
- `gunLayers(800,'inside').tailKind==='slap'`

**feat6e, machine loops.** Fake audio; a sentry chasing 500 away behind a wall; `tickMachLoops(0.3)`. `SND.loops` has the sentry in `'fight'`. With it in sight, no slot. With `G.sim`, nothing. RNGS is unchanged.

**feat6f, impacts.**
- `matOf({tree:1})==='wood'`, `matOf({win:1})==='glass'`, a building wall gives `'concrete'`.
- Capture `sfx` while a staged player bullet hits a building wall: the 4th argument is `'concrete'`, and RNGS advanced by exactly the old amount (one decal `rnd`).

**feat6g, footsteps.** Stub `blip` (capture) and `ping` (capture); run `tickPlayerSteps` while moving. The 4th argument is in the legacy set, the 6th is set, and the ping radius equals the formula at 4353-4356.

**feat6h, UI sounds.** Fake audio. `padSetFocus(a); padSetFocus(b)` gives `SND.uiLast==='move'`. Clicking a title row gives `'ok'`.

**feat6i, barks.** Fake audio: `VOX_BARKS.RELOADING` exists. Stub `voxBark`; starting a reload calls `'RELOADING'`. Two barks within 1.2 s play only one.

**feat6j, stings.** Stub `arcSting`, then trigger each: an extract, a double kill, the high score and a wave. The recorded kinds are `['extract','streak','hi','wave']`.

**feat6k, music.**
- Title on: `musicWanted()` is true.
- With `G` set: false.
- On the floor (hub, no title): false.
- `ARCADE.on` with `ATT.on`: true.

The previous build returns true on the floor.

---

## PART 4. EXISTING CHECKS TO RE-BASELINE (they encode the old rules)

- **The arcade checks:**
  - v23.21 arcade2: `raidLen 0`, endless
  - v23.22 arcade3: solo death respawns
  - v23.23 arcade4: +2,500 and the re-drop
  - v23.24 arcade5: row texts
  - v23.40 arcade17: HAPPY HALLOWEEN
  - v23.43 arcade20: Halloween
  - v23.45 arcade22: in-raid initials
  - v23.54 arcade30: row text "1 PLAYER ARCADE DEMO"
  - v23.56: any banner text
- **The title checks:** v14.26 / v15.76 (titlestart focus, ENTER returns `'start'`) and v23.58 (rows).
- **The sector page checks** that expect two cards, and any check that sets `P.mapIx=1` through the pickers.
- **Normal-raid checks** that assert raidLen 540, rings closing, or exact credits after extraction: pin `CFG.career=0`.
- **Pause box button counts** (the FEEDBACK button) and the `#pausenote` floor-note checks.
- **`verlabel` / `titlever` text checks.**

---

## OPEN for him (my recommended default in brackets)

1. Burn deaths in 2-player DEMO keep the team score at ×1 [yes].
2. In 2-player DEMO, either player's extraction doubles the team score and ends the run for both [yes].
3. The CAREER board takes banked (extracted) runs only [yes].
4. CAREER rings never close during the 10 minutes, the arcade rule [yes; the alternative is the normal schedule stretched to 600].
5. The CAREER waves count toward contracts [yes]. Wave pillagers never enter his grudge ledger [never].
6. The FEEDBACK button also shows in the DEMO pause box [yes]. Pad text entry [not built].
7. The bark voice: the Windows SAPI voice and the word list [David, the list above].
8. CAREER vaults, seal-only [after the DEMO vaults ship].
9. The cheap tripwire sprinkle in CAREER loot [ship it].
10. The Undercroft goes silent because music plays only on the title and the attract [as he said].

### Critical Files for Implementation
- C:\claudecode\dark raiders\dark_raiders.html (title 1278-1290; audio 3860-5290; throwables 13895-14431; damagePlayer 15195; grantLoot 16293; startRaid 11724-11808; endRaid 22997-23850; loop 35600-35700; net thr 41824-41854; arcade section 44414-46068; drawBag 32742; render2D hooks 26238/27751/27900)
- C:\claudecode\dark raiders\tools\mkfixture.ps1 (__startRaid 242, __verify 1221-1260, the tickAmbience stub 1117, __topClear 60795, __deploy 60922, check style 5747-5895)
- C:\claudecode\dark raiders\tools\collector.ps1 (the new /feedback route beside /telemetry, lines 21-35)
- C:\claudecode\dark raiders\tools\handoff\research\arcade-design-2026-10-11.md (the arcade model this design amends)

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