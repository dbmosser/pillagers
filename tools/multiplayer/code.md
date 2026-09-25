# Pillagers: the single-player assumptions a multiplayer mode would have to replace

Checked against `C:\claudecode\dark raiders\dark_raiders.html` (36,713 lines, DEVNOW v15.72). I only read the file; nothing was edited. Line numbers are as of now.

## 1. How the player is represented

- There is one body, `G.player`, created as a literal inside `buildRaid` (L10667): `player:{x:start.x,y:start.y,r:11,hp:100,maxhp:100, ... downed:false,downT:0,revived:false,iv:0,jam:0,pendKiller:null, ... roll:0,rollCd:0,rollDir:{x:1,y:0},ads:false},`
- `G.player` appears 221 times on 163 lines, across 100 top-level functions. 71 functions copy it into a local variable first (55 of them as `p`, for example `var p=G.player,T=G.tel;` at L15600 and L17505).
- Counting those copies, there are about 1,530 references to the player's fields. By function:
  - `updatePlayer` 279
  - `updateBot` 184 (the bot sim only)
  - `updateEnts` 151
  - `drawHUD` 134
  - `render2D` 122
  - `damagePlayer` 52
  - `grantLoot` 44
  - `tickHeal` 36
  - `applyHeal` 30
  - `loop` 28
  - `hotbarSlots` 25
  - `tryRoll` 23
  - `endRaid` 16
- A second set of per-player state sits directly on `G`, not on `G.player`: about 950 references. The largest are `G.tel` 154, `G.bag` 114, `G.hotAssign` 59, `G.hotCells` 25, `G.bagOpen` and `G.bagSel` 23 each, `G.drag` 22, `G.hotAuto` 19, `G.sprinting` and `G.mapOpen` 18 each, `G.searching` 16, `G.pouch` 15, `G.pCrouch` 10 and `G.pConceal` 9. Smaller ones include `G.seen` (fog), `G.waypoint`, `G.near*`, `G.msg*`, `G.camX` and `G.anchX`, `G.trade`, `G.pedCarry`, `G.deathBeat`, `G.carriedIn` and `G.intel`.

The big consumers, by area:

- **Input.** `updatePlayer` reads the global `keys`, `mouse` and `PAD` directly (44 reads, for example `keys['KeyE']` Ã—12 and `mouse.down` Ã—8). `raidKey(code,â€¦)` at L11061 does `keys[code]=true`. Across the file there are 94 `keys[` reads and 142 `mouse.` reads.
- **Camera.** In `render2D` (L22635) the camera follows the one player: `G.anchX+=(p.x-G.anchX)*ke; ... camX=G.anchX-(W/2-G.leanSX)/Z;`
- **AI targeting.** `updateEnts` reads only a narrow set of player fields: `p.x`/`p.y` (57 each), `p.downed` 18, `p.r` 4, `p.face` 4, `p.moving` 3, `G.pCrouch`/`G.pConceal` 2 each, plus `hp`, `maxhp`, `iv` and `pendKiller`. The key lines are `var sees=canSee(e.x,e.y,e.face,p.x,p.y,G.vseg,_fSee,e.cone,_aSee);` (L18077) and `if(sees&&p.downed&&e.kind!=='raider') sees=false;`
- **Bullets.** Machine bullets test one target (L19532): `if(!_mOwn&&dist(b,p)<p.r+3){ damagePlayer(b.dmg,...`
- **Noise and sound.** `ping()` (L12843) pushes the UI ping relative to the one listener (`var pp=G.player; var d0=dist(pp,{x:x,y:y});`) and then alerts machines by position. `noiseMark` and `earsOf` are listener-relative: `var p=G.player, dx=wx-p.x`.
- **Loot and search.** `openContainer`, `grantLoot` (44 refs), `G.searching`/`searchT`, and `G.bag.splice` or push.
- **Doors.** Opening a locked door happens inline in `updatePlayer` (L16132): `doorNear.open=true; ... G.map.walls.splice(dw,1); rebuildGeometry();`
- **Extraction.** `standingRing()` and `tryExtractTick` (L14758) take `var p=G.player`. Ring hold state lives on the zone (`pullT`, `boardT`, `hold`), which assumes one person pulling.
- **Downed and death.** `damagePlayer` (L13031) and `killPlayer` (L13006) handle it. `G.deathBeat` in `loop` slows the whole world for the death beat: `var bdt=dt*0.25; ... updateEnts(bdt); updateBullets(bdt)`. Then `endRaid('dead')` runs.
- **Inventory and belt.** `G.bag`, `G.hotAssign`, `G.hotCells` and `G.pouch`, plus the drag UI on the HUD canvas.
- **Run report.** `endRaid(how)` (L20013) begins `if(G.over) return; G.over=how;`, then `fogSave()`, pays into `P`, runs `saveProfile()`, and on the return-to-hub path sets `G=null; keys={};`. One player ending the raid ends it for the world.
- **Also centred on the one player:**
  - `strikeTick` places lightning around `p` (`var sx=clamp(p.x+Math.cos(ang)*rad,...)`).
  - Restock (`dist(_rc,G.player)<700`).
  - The rival announcement, mercs (`mercOrder` and `mercHold`) and the peddler (`G.trade`).

## 2. Main loop, steppers, random numbers, map build

- **`loop(ts)` (L30214) runs on requestAnimationFrame with a variable step:** `var dt=clamp((ts-lastTs)/1000,0,.05);`. Three things change world time from one player's side:
  - Superhot sets `if(!_shAct) dt=0;`.
  - Pause: `G.paused=pauseOpen||tuneOpen` (L10891).
  - The death beat runs the world at a quarter of dt.
- **Live step order** is `refreshVseg(); updatePlayer(dt); updateEnts(dt); updateBullets(dt); updateThrowables(dt); tickHot`, then the audio ticks, then `wxTick(dt); strikeTick(dt);`. `wildTick(dt)` runs at L30464.
- **The sim step** is the clean model of a world step:
  ```
  function simStep(dt){ ... refreshVseg(); updateBot(dt); if(G.over) return; updateEnts(dt); ... updateBullets(dt); ... updateThrowables(dt); }
  ```
  It uses a fixed 0.15 s step and no rendering. `updateBot` already stands in for `updatePlayer`, so there is a precedent for driving the player from something other than the keyboard.
- **Random numbers.** There is one global seeded stream: `var RNGS=...; function srand(s){...} function rr(){ RNGS=(RNGS+0x6D2B79F5)>>>0; ...}`. `rnd`, `ri`, `pick` and `rollTable` all draw from it.
  - `sideStream(sd,tag,fn)` and `fxBorrow` save and restore `RNGS`. `fxr()` is a separate cosmetic stream.
- **Seeded draws during a raid, by function:**
  - `updateEnts` 62
  - `wildTick` 10
  - `strikeTick` 6
  - `tickExtractPoints` 5
  - `updateBullets` 4
  - `updateBot` 4
  - `wxTick` 4
  - `updatePlayer`, `damagePlayer`, `tickNuke`, `mercEngage` and `machHuntRaider` 3 each
  - `tryExtractTick`, `tickHot` and `raiderThrow` 2 each
  - The 170 s crate restock calls `mkContainer`, which also draws.

  The number of draws per second depends on frame count and dt. Two machines on the same seed would diverge within a few frames, so lockstep is not possible without a fixed-step rewrite, which would break the feel and the fingerprint. The design has to be host-authoritative.
- **`Math.random` during a raid** is cosmetic or audio only: `updateEnts` sparks and blips (L17460, L18802, L19008), `blip` Ã—31, the hub crowd, and the raid seed itself. Rendering stays off the seeded stream: shake uses `fxn`, per the v3.19 note at L22666.
- **Map build.** `buildRaid(sim)` (L9661) seeds with `var seed=srand(pendSeed===null?((Math.random()*4294967296)>>>0):pendSeed);`, then calls `buildFixedMap(FIXED_MAPS[mapIx])` (L6034).
  - The geometry depends only on the seed, the map definition, and CFG dials (`bldgRuin`, `navBody`, `partDoor`, `windows`, `gridJitter`, `lmCut`, `placeCull`, `bushRoadR`). It reads nothing from `P`.
  - After the geometry, the draws do depend on the player's profile:
    - `wep=WEAPONS[pick(STARTERS)]` (L9699) draws only when no gun is equipped.
    - `isDay()`, which is `P.cond==='day'`, changes counts through `_nightMul`.
    - `hasTerm('silence')` adds a Listener.
    - `P.merc` splices the identity pool.
  - **So a client cannot rebuild the entities or containers from the seed.** It can rebuild the geometry only, and only if it adopts the host's CFG.

## 3. What the host would send, with counts at seed 4242

Fixture figures: COLD STORAGE (mapIx 0, 4200Ã—3400) has 85 entities and 165 containers. THE COLD MILE (mapIx 1, 9000Ã—7600) has 374 entities, 593 containers and 84 buildings. None of the AI has distance culling; every entity updates every frame.

| Data | How to send it | Count |
|---|---|---|
| Players | Position, face, hp, downed, crouch/conceal, roll, ads, weapon id, firing flag | 2â€“4 |
| `G.ents` (machines and pillagers) | Per tick: x, y, face, hp, state, alert, downed/finished/moving flags, hitT/recoil. Raider look and gear once. About 12 bytes each in binary. | 85 / 374 |
| `G.containers` | Full list at join (x, y, type, best, opened, strong, inLocked), then events: opened, prog/pulled, loot taken, 170 s restock, dropped piles | 165 / 593 |
| `G.bullets` | Spawn events (origin, angle, speed, owner); clients fly them for looks, host resolves hits | about 0â€“40 alive |
| `G.throws`, `smokes`, `decoys`, `frags` | Events plus a small snapshot | 10 or fewer |
| `G.zones` and `G.active` | open, beaconT, hold, pullT, boardT, closeAt, siege fields; plus `G.beaconT`, `G.shipHold`, siege and `waveN`/`waveT` | 3 / 6 |
| Doors (`map.locked[].open`), `G.dmgWalls`, seal (`G.seal.gained`) | Events; clients run `rebuildGeometry()` | 2 / 8 locked rooms |
| Weather and lightning | `G.wx`, `wxNext`, `wxT`, `tod`, `lightning`, `strikes[]` | 1 |
| Timers | `G.t`, `timeLeft`, `raidLen`, `nuking`, `nukeT` | a few scalars |
| `G.wild` (birds, herds) | Snapshot, or drop it | about 20 / about 100 (estimated from `spawnWild` scale) |
| Not sent; each client derives them | `noiseRings` (cap 22, `noiseMark` is listener-relative), `pings` (cap 140), decals, shells, sparks, puffs, labels, dmgN, flashes | â€” |

- Sound and messages need events. One hook inside `sfx(type,wx,wy)` covers all 98 `sfx(` call sites, and each client then runs its own `noiseMark`/`earsOf`. `say(` has 183 call sites, which need sorting into world messages and personal ones.
- Bandwidth: a full entity snapshot on THE COLD MILE is about 4.5 KB in binary (JSON would be 5â€“8 times larger). Sending only entities within about 1,600 units of each player, and only what changed, at 20 Hz comes to about 20â€“40 KB/s per client.

## 4. The profile and stash

- `P` is one global literal (L2182). `saveProfile()` (L2580) begins `P.cfg=CFG; P.cfgv=18; storeSet(JSON.stringify(P));`
- Storage keys:
  - `'salvagerun:activeSlot'`
  - `SKEY` = `'salvagerun:profile'` or `'salvagerun:profile:'+slot`
  - `SKEY+':prerestore'` and `SKEY+':unreadable'`
  - `'salvagerun:precrash'`
  - `'salvagerun:fsWanted'`
- Everything in `P` stays local to each player: credits, xp, stash, weapons, equipped/equippedSec, wear, hotAssign, kit/dropKit/freeKit/kitChosen, contracts, terms, seals, mapSeen (fog, saved by `fogSave` under `P.mapIx`), notoriety, merc, intel, rivals, log, crashes, pname, cosmetics, cfg and cond.
- Three traps:
  1. **The host's dials can leak into a client's save.** A client has to adopt the host's CFG for the raid, but any `saveProfile()` during the raid writes `P.cfg=CFG`. `buildRaid` also splices the client's own `P.stash` and `P.dropKit`.
  2. **Fog can save under the wrong map.** `fogSave` and `resolveKey` key on `P.mapIx`, so a client must take the host's map index.
  3. **Seal progress** is stored per player per map in `P.seals`. If two players cut the same seal, whose record counts is a design question for you.

## 5. Where it can be split cleanly, and what is risky

Guiding split: the host owns the world, and each player's own machine owns that player's body and bag. Clients run their own `updatePlayer`, `drawHUD`, bag and heal logic locally, unchanged. Everything that touches the world goes to the host as a request, and hits come back as events that call the local `damagePlayer`. That leaves the 1,530 player references and 950 per-player fields alone.

### Seams, with rough size

| Area | Work | Lines |
|---|---|---|
| **A. Transport and lobby** | `NET` module on built-in browser peer-to-peer connections (WebRTC): one reliable channel and one unreliable channel (`maxRetransmits:0`), host at the centre. Joining is either by copy-paste offer codes (no server) or by a room on the existing Cloudflare Worker. Plus a lobby row on the Undercroft floor. | ~600â€“900 new, ~10 touched |
| **B. Mic chat** | Uses the browser's own microphone and peer-to-peer audio, no library. `getUserMedia` with echo cancellation, noise suppression and auto gain; one track per peer; GainNode plus StereoPanner fed by an `earsOf`-style distance calculation. It must go to `a.destination`, not `BUS` (`BUS` feeds the reverb). Push-to-talk on a free key: K, L, N, U or Y (J is taken via `.key==='j'`). Mute and device choice go in Settings. | ~200â€“300 new, ~5 touched |
| **C. Raid handshake** | Host sends `{seed, mapIx, cfg, cond, terms}`. Client sets `pendSeed`, swaps in the host CFG (restore it without saving), runs `buildRaid(false)` for geometry and its own kit, then replaces `ents`, `containers`, `zones`, `active` and `wx` with the host's join snapshot. | ~150â€“250 new, ~10 touched in `startRaid` |
| **D. Loop fork** | In `loop`'s raid branch: `if(NET.client) clientStep(dt); else { ...existing...; if(NET.host) hostSend(); }`. `clientStep` applies snapshots with interpolation, replays events, and runs local `updatePlayer`. | ~10 touched, ~300 new |
| **E. Client choke points** | About 15â€“25 places where the client's own actions change the world: `fireWeapon`, `ping`, `throwFrom`, `openContainer`/`grantLoot`, `dropItem`, `meleeStrike`, the door block in `updatePlayer`, `tryExtractTick`/beacon, `damageWall`, the seal cut, `pedBuy`/`pedSellAll`, `strayGive`, `doEmote`, merc orders. Plus the host-side handlers. | ~150â€“250 touched, ~300 new |
| **F. AI with several targets** | Riskiest. In `updateEnts`, replace the one `var p=G.player` with a per-entity `targetFor(e)`, which returns `G.player` when there are no peers. Also: the bullet hit loop in `updateBullets`, `strikeTick`, `wildTick`, `tickRaiderWaves` and the siege, mercs, restock, and rival. | ~100â€“150 touched |
| **G. Drawing the other players** | Reuse `drawOp(...)` the way raiders use it (~L23737), plus name tags and map dots. | ~100â€“150 new, ~10 touched |
| **H. Raid end** | Each player leaves on their own. The client runs its own `endRaid` payout unchanged. The host's own death or extraction becomes spectating; the host defers `G.over` and `G=null` until everyone is out or the clock ends. | ~100â€“200 touched |
| **I. World-time controls** | Gate superhot, pause (make it an overlay), the death-beat slow-down (make it local), and the backquote tuning console while a network raid is on. | ~20â€“40 touched |
| **J. Snapshot codec** | Fixed-schema binary for entities, zones and timers; events for everything else. | ~300â€“400 new |

Total: about 2,000â€“3,000 new lines and 450â€“800 touched, all behind `NET.on`.

### Riskiest parts

1. **Keeping single-player identical.** `updateEnts` is shared by the live game and the sim. Any extra seeded draw, or a changed order of draws, when there are no peers moves the seed 4242 fingerprint (85/165 and 374/593) and invalidates paired A/B runs. Check with `__verifySafe` and a paired run after every step.
2. **Everything that assumes one raid ends when one player ends.** That covers `G.over`, `endRaid` setting `G=null`, `G.deathBeat` slowing the world, and the host's pause.
3. **The host's tab.** requestAnimationFrame stops in a background tab, so the world freezes for everyone. The host needs a timer-driven step as a fallback. Also, the 0.05 s dt cap means a hitch on the host slows world time for all players.
4. **Extraction and siege state** (`pullT`, `boardT`, `hold`, `G.beaconT`, `shipHold`, raider waves) is built for one person pulling.
5. **Microphone permissions.**
   - Mic access needs a secure page. `https` (itch) and `http://localhost` work; `http://<LAN IP>` from the plain static server does not.
   - The itch iframe must allow `microphone`. I have not confirmed that it does, so test it first.
   - Chrome can play a remote voice stream through WebAudio silently unless the stream is also attached to a muted `<audio>` element.
   - Echo on laptop speakers needs a real test.
6. **Getting through home routers, and ownership decisions.** Direct peer-to-peer connections fail for some router pairs without a relay server. There is also nothing yet that says who owns a hit on another player or damage between teammates.
7. **Design questions for you, since numbers are frozen.** Two to four players against unscaled enemy counts is a balance change in practice. Friendly fire, reviving a teammate, whose seal progress counts, and whether one beacon call serves the whole team are also open.