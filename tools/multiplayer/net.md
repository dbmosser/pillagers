# PILLAGERS netcode design (read-only review of dark_raiders.html v15.72, 36,713 lines)

## 1. Topology and authority: host-authoritative star over WebRTC. Not lockstep.

**What the code does now**
- Every gameplay roll uses one shared seeded stream, `function rr(){ RNGS=(RNGS+0x6D2B79F5)>>>0; ...}`, called from 68 places.
- The world is seeded once: `var seed=srand(pendSeed===null?((Math.random()*4294967296)>>>0):pendSeed);` in `buildRaid`.
- The frame step is variable: `var dt=clamp((ts-lastTs)/1000,0,.05);` in `loop`.

**Why lockstep fails here**
1. **Variable frame time.** A 144 Hz PC and a 60 Hz PC step different `dt` values. Lockstep would need a fixed step, which would change the single-player game.
2. **Floating-point maths.** The code has 350 `Math.sin/cos/atan2/exp/pow` calls. ECMAScript does not pin their results, so Chrome and Firefox can differ in the last bit.
3. **The stream is already fragile on one machine.** The file has to defend it by hand, for example: "THE DECAL ROLL IS DRAWN UNCONDITIONALLY ... `decal(x,y,c,rnd(3,6))` evaluates rnd BEFORE the call". The `if(!G.sim)` branches are another sign. With several players, any `rr()` draw that depends on who the local player is would desync the raid for good, with no recovery.
4. **One stalled tab stalls everyone.** A hidden tab has no rAF, so the whole party would freeze with it.

**Why host-authoritative fits**
- The seed only has to rebuild the static world once, at raid start. A client runs `buildRaid` itself using the host's seed and build inputs, and gets a mirror `G` that the existing renderer draws unchanged.
- After that, the host runs the only simulation. The host's `rr()` stream in multiplayer is free to differ from single player.
- Rules:
  - Net code never calls `rr/rnd/pick`. Net ids come from counters; client cosmetics use `fxr`/`Math.random`.
  - Single player never enters net code, so the seed 4242 fingerprint stays untouched.

**The core technique: seat context swap.** Player state is spread across `G` and closure globals. There are 221 `G.player` references, and `updateEnts` alone has 147 `p.` references after `var p=G.player,T=G.tel;`. Rather than rewrite those, the host swaps a "seat" into place, calls the unchanged function, then swaps back:

- **G fields in the swap set**, taken from what `updatePlayer`, `raidKey`, `damagePlayer`, `tryRoll`, `cycleThrow`, `useHot` and `tryExtractTick` write:
  - player, bag, pouch, tsel, hot, hotAssign
  - searching, searchT, nearContainer, nearPad, nearDoor, nearPed, nearSeal, nearStray, nearDown
  - sprinting, crouchTog, ctrlUndo, pBush, pCrouch, pConceal, sealNoise
  - handsT, punchT, rollSayT, revLock, strayLock, pedLock, pedBlocked, trade
  - bagOpen, bagSel, drag, emoteBar, mapOpen, legendOn
  - marked, waypoint, tel, seen, deathBeat
  - active, beaconT (the mirror), shipHold, extSay
  - carriedIn, carriedKit, pedCarry
- **Closure variables in the swap set:** `keys`, `mouse`, `PAD`, `pauseOpen`, `tuneOpen`, `P`, `DT_LAST`. The net section must live inside the same closure so it can reassign them.
- **One-line guarded hooks:**
  - `mouseWorld` returns `NET.seat.aim`.
  - `say`/`say2`/`sayWhenFree`/`blip` go to the seat's outbox.
  - `earsOf` uses the host's own listener.
  - `saveProfile`/`storeSet` throw if called while a seat is swapped in.
- **Enemy targeting:** in the `updateEnts` loop, when `NET.world` is set, each ent gets `p=netTarget(e)`. That is its sticky target seat, else the nearest living seat, with no `rr()` draw. That seat's pBush/pCrouch/pConceal are swapped in for the perception reads.
- **Damage call sites:** the 7 `damagePlayer(` calls (lines ~5547, 12602, 12713, 17982, 17992, 18532, 19532) go through `seatCall(seatOf(target),...)`.
- **Enemy bullets:** `updateBullets` starts with `var p=G.player;`. Enemy rounds must test every living seat instead.

## 2. Messages, channels and rates

**Channels:** one `RTCPeerConnection` per host-to-client pair, with two negotiated data channels.
- `rel` (id 0): ordered and reliable, JSON. Used for rare messages.
- `fast` (id 1): `ordered:false, maxRetransmits:0`, binary `DataView`. Payload cap 1,150 B so a message never fragments.

**Handshake (rel)**
- Client sends `{t:'hello',proto:1,ver:'15.72',pid:<8 hex from SHA-256 of P.iid>,name,look,mic:bool}`.
- Host replies with one of:
  - `{t:'welcome',you:seatIx,roster:[{ix,pid,name,look,ready}],hostMs}`
  - `{t:'reject',why:'version'|'full'|'inRaid'}`. VER must match exactly.
- Lobby:
  - Client ready: `{t:'ready',kit:{bag,hotAssign,equipped,equippedSec,rig,pack,autoloot,junk},pouch}`
  - Host to all: `{t:'roster',...}`
  - Host start: `{t:'start',seed,mapIx,cond,cfg:{only the CFG keys buildRaid reads: raidSec, contDens, nightDens, nSentry, nCrawler, nRaider, nSnitch, nListen, nHowler, nBulwark, houseFill, houseCap, crawlerPerHouse, spawnClear, placeCull, decks, campNorm, cacheReach, eHp, destruct},build:{equipped,equippedSec,weapons,merc,terms,rig,hotAssign},fp:{ents,conts,walls,rngs},seats:[{ix,x,y,wep,sec,ammo,reserve,armor,armorCap,rig}]}`
- **Why the host's build inputs are needed:** `buildRaid` rolls the kit (`wep=WEAPONS[pick(STARTERS)]`) before it places ents and containers. A client building with its own kit would place a different population.
- **Client build steps:**
  1. Swap `P`/`CFG` to the host's build inputs and set `pendSeed=seed`.
  2. Call `buildRaid(false)`.
  3. Restore its own `P`/`CFG` and re-run `fogLoad` for its own fog.
  4. Compare the fingerprint `{G.ents.length, G.containers.length, G.map.walls.length, RNGS}` and reply `{t:'built',ok,fp}`.
  5. A mismatch aborts that seat with a version message.

**Stable ids**
- Containers use their array index. There is no `containers.splice` anywhere; only pushes.
- Ents get `e.nid`: build index at start, then a host counter. `ents.splice` appears 4 times and `ents.push` 18 times, including `G.ents.push(rr()<.5?mkSentry(...):mkCrawler(...))` for reinforcements.
- Walls get `w.nid` set to the build index, because `damageWall` does `G.map.walls.splice(ix,1)`.

**Input packet (fast, client to host, 30 Hz)**
- Header, 4 B: `type u8`, `ackSnap u16`, `n u8`.
- Carries the last 4 unacked commands (4 Ã— 14 B). Each command covers one client frame capped at 60 per second; faster frames merge.
- Command layout, 14 B: `seq u16`, `dtMs u8`, `held u16`, `aimX u16`, `aimY u16` (world Ã— 8), `padMx i8`, `padMy i8`, `edge u8`, `edgeArg u8`, `viewLag u8` (ms/4).
- `held` bits: W, A, S, D, E, F, R, X, Shift, LMB, RMB, CapsLock, downed-Space.
- **Edge keys:** the host replays them through the existing `raidKey(code,false,null)` inside the seat swap. The whitelist is Space, KeyF, Digit1-9, KeyQ, KeyG, KeyC/Ctrl, KeyV plus digit, KeyZ, KeyI/B. UI-only keys stay local: M, H, zoom, Minus/Equal, Backspace, Esc/Tab/P.
- **In-raid inventory drags** go on rel as `{t:'inv',op:'drop'|'use'|'move'|'bind'|'equip',...}`. The host replies with the whole bag.

**Snapshot (fast, host to each client, 20 Hz, filtered to what that player is near)**
- Header, 16 B: `type`, `seq u16`, `hostMs u32`, `ackCmd u16`, `timeLeft u16` (Ã—10), `flags u8`, `nSeats u8`, `nEnts u8`, `nEv u8`, spare.
- Own seat, about 24 B: `x`, `y` (u16 Ã—8), hp, armor, stam, ammo, `reserve u16`, secAmmo, reloading, iv, `flags u16` (downed, dying, ads, crouchTog, sprinting, roll, bagOpen, autoJog, jam, stim), rollT, rollDir u8, downT, searchProg u8, cookT, tsel.
- Each other seat, 14 B: ix, x, y, face u8, flags u16, hp, wepId, rollPhase, heal, talking bit.
- Each ent, 11 B: `nid u16`, x, y, face u8, state u8, hp% u8, fx u8 (moving, muzzle, hitT, downed, finished, alert, windup, elite), aux u8 (legs, step, overheat per kind). These are the fields the draw code reads: `e.face/state/hitT/muzzle/legs/step/overheat/windup/downed/moving`.
  - Ents within 1,200 px go in every snapshot.
  - Ents further away rotate through at 2 Hz under a priority accumulator.
- Events, 5-9 B each and cosmetic only:
  - `shot{owner,x,y,ang u16,wep}` (client flies a local tracer at 1180 px/s until a wall or a `hit`)
  - `sfx{id,x,y}` (client calls its own `sfx`, which also marks its own noise ring)
  - `hit{nid,dmg,x,y}`
  - `boom{x,y,r}`
  - `throw{kind,x,y,vx,vy,fuse}`

**Gameplay events (rel, JSON)**
- `spawn`/`gone` for ents
- `cont{id,opened,prog,pulled,srchBy}` and `contNew`, used for drops and for the 170 s restock in `updateEnts`
- `wall{nid,hp}` and `wallDown{nid}`
- `ring{...}`, `wx{id}`, `strike{x,y}`, `nuke`
- `seat{ix,state}`, `bag{...}`, `say{text}`, `end{...}`

`wxTick` and `strikeTick` draw `rr()` and `strikeTick` does damage, so both run only on the host.

**Clock sync:** `ping`/`pong` every second on `fast`, smoothed offset.

**Bandwidth** (about 93 B per datagram of IP, UDP, DTLS-GCM and SCTP overhead):

| | Input | Snapshot (typical: 25 ents, 12 events, about 440 B payload) | Totals |
|---|---|---|---|
| Per client | about 150 B Ã— 30 Hz â‰ˆ 36 kbps up | about 530 B Ã— 20 Hz â‰ˆ 85 kbps down | |
| 2 players | | | Host up about 90 kbps, host down about 36 kbps |
| 4 players | | | Host up about 270 kbps, host down about 110 kbps; each client up 36, down 90 kbps |
| Voice | | | About 45 kbps per talking stream each way (Opus 24 kbps plus RTP overhead) |

Worst case for 4 players, everyone talking: host up about 400 kbps.

## 3. Prediction, interpolation, hits and loot

**Host stepping**
- The host's own seat keeps stepping exactly as now: `updatePlayer(dt)`, then `updateEnts`, `updateBullets`, `updateThrowables`.
- Each remote seat runs `updatePlayer(cmd.dt)` once per received command, inside the seat swap, before ents step.
- If a seat has no commands for more than 100 ms, the host repeats its last held keys (without edges) for that time and later discards the same amount of client time. This stops a lag switch from freezing `downT`.
- A seat may spend at most 1.05 s of command time per host second (speed-hack cap).
- **Multiplayer-only rule changes:**
  - Superhot is forced off. The loop's `if(!_shAct) dt=0;` would freeze everyone.
  - Pause is an overlay only; `G.paused` is never set.
  - The death beat is per seat. `var bdt=dt*0.25;` must not slow the shared world.

**Local player on the client**
- The client runs the same `updatePlayer` on its mirror in `NET.predict` mode. About 10 guarded branches skip in that mode: container search, `fireWeapon` (replaced by a local cosmetic tracer drawn with `fxn`), `tryExtractTick`, `tickRegen`/`tickHeal`/`tickReload`, cooking, trade and doors, give-up.
- This gives exact movement parity (sprint, stamina, crouch, weight, water, collision) with no refactor.
- **Reconciling:** on each snapshot, set x, y, roll, rollDir, rollCd, stam, stamLock, stamRelease, autoJog, crouchTog and iv from the host's own-seat block at `ackCmd`, then replay the unacked commands.
  - Errors under 64 px are smoothed out over 100 ms.
  - Larger errors snap.
- Predicted immediately: aim, facing, ADS, muzzle flash, recoil, tracer and sound, and the ammo count (host corrects it).
- Never predicted: hp, damage, loot, extraction outcome. The search bar and extraction bar may fill locally, but the host decides.

**Remote ents and seats:** interpolated 100 ms behind host time, shortest-arc facing, flags from the newer snapshot. If snapshots stop, extrapolate at most 100 ms, then freeze.

**Hits (host only)**
- A remote player's rounds come from `fireWeapon(seatPlayer,...)` at the host's copy of their position. Rounds already carry `owner:sh` and `player:!!fromPlayer`.
- Kill credit follows the round's owner seat: set `e.bySeat` beside `e.byPlayer` (14 sites) and add to that seat's `tel`.
- No friendly fire by construction: player rounds only test `G.ents`.
- **Lag compensation in v1:** fast-forward each new remote round by min(RTT/2, 150 ms) by temporarily setting `G.bullets=[new]; updateBullets(ff);`.
- **v1.1 if playtests call crawlers unhittable:** keep a 300 ms ring of ent positions and rewind by `viewLag` for the round's first sweep.

**Loot (host only)**
- The search branch, `if(near&&(keys['KeyX']||(keys['KeyE']&&!onPad)))` with `near.prog=(near.prog||0)+dt/buzzSlow();`, runs under the seat swap. Pulled items land in that seat's bag.
- A container is locked to one searcher (`ct.srchBy`). Otherwise two players would double the search speed, which is a balance change and numbers are frozen.
- The client receives the whole `bag` on rel after each change. Container contents are never sent until an item is pulled.

## 4. Mic chat

**Transport**
- On each connection, `addTransceiver('audio',{direction:'sendrecv'})` at creation. `replaceTrack(mic)` once the mic is granted, so no renegotiation is needed.
- Push-to-talk toggles `track.enabled`.
- `sender.setParameters` caps bitrate at `maxBitrate:24000`, mono.
- With 3 or 4 players, each client pair opens its own audio-only connection, with setup messages relayed over the host's `rel` channel. If that connection fails, the host forwards the received track with `addTrack`.

**Bound keys found**
- Keyboard:
  - Movement and stance: W/A/S/D and the arrows (also backpack navigation), Shift L/R, Ctrl L/R and C, Space, CapsLock (auto-jog).
  - Actions: E, X, R, F, G, Q, T (4th action at a station on the Undercroft floor), V (emotes), Z, O.
  - Screens and menus: M, H, I/B, P, Escape, Tab, Enter and NumpadEnter, Backspace, Backquote (Shift+` for tuning).
  - Numbers and zoom: Digit0-9, Numpad0/+/-, Minus/Equal.
  - Stash: J (junk tag while hovering an item) and 1-9 (hover-pack).
- Mouse: LMB, RMB, Ctrl+wheel.
- Controller: every button is used (0-5, 8-15), and triggers 6 and 7 are zoom.

**Push-to-talk choice**
- **Default key: hold Y (`KeyY`).** It has zero references in the file, and a WASD hand can reach it. T is taken on the floor. Alt pulls focus to the browser.
- Read it in its own capture listener: ignore it in INPUT/TEXTAREA, and release it on `blur`/`visibilitychange`.
- A controller has no free button, so controller players default to voice-activated open mic. Settings offer PTT, toggle or open mic.

**Proximity volume**
- Chain: `MediaStreamSource` â†’ Gain (distance) â†’ StereoPanner (`dx/520`, matching `earsOf`) â†’ lowpass (1,200 Hz when `!losClear`) â†’ a new VOICE bus â†’ `AC.destination`. It bypasses `BUS`, so it skips the game's reverb.
- Curve: full volume up to 120 px, -30 dB at 900 px, silent beyond 1,100 px (sight distance `viewFar` is 620). Behind walls Ã—0.5.
- Updated every 100 ms with `setTargetAtTime`.
- **Chromium quirks:**
  - A remote stream must also be attached to a muted `<audio>` element or Web Audio receives silence.
  - Chrome's echo cancellation does not cover audio played through Web Audio. Hence PTT by default and a headset hint.
  - An optional "speakers" mode drives `<audio>.volume` directly (no pan), which echo cancellation does cover.

**Mute list:** `P.netMute[pid]`, local only, with a per-player 0-150% slider. Also "mute my mic" and "mute all" in the Party panel and in the pause-menu roster.

**In the Undercroft lobby**
- Flat party voice, no proximity.
- Players already back in the Undercroft while others are still in the raid are heard as a flat, band-passed "lift radio". This is on by default with one toggle and is the owner's call.

**Mic permission:** request it only on the "Mic on" click in the Party panel, never at page load. If refused, emotes still work; send them as `{t:'emote'}` on rel.

## 5. Lobby flow in the Undercroft

**The lift station**
- The lift has E (`go up`), R (`quick ascent`) and T (`the terms`). F is free, so `KeyF:['party',...]` opens a PARTY modal with CLOSE and ESC: HOST A PARTY, JOIN A PARTY, Mic, roster.
- **Signalling (connection setup):**
  - **v1, no server:** copy-paste invite codes. Wait for full ICE gathering, compress with `CompressionStream('deflate-raw')`, then base64url.
  - **v2:** a 6-letter room code on a Cloudflare Worker with a Durable Object, next to the collector. Not KV: it is eventually consistent and can lag up to 60 s.
  - STUN only, e.g. `stun:stun.cloudflare.com:3478`. Without TURN, pairs behind CGNAT or symmetric NAT fail; detect this and say so.
- **On the floor:** remote players appear on the floor, drawn with `drawOp` from their `look`, at 10 Hz. Each player stocks their own kit at their own stash.
- **Ready:** a client pressing E at the lift runs its own ascent check, then `commitKit()` and sends `ready`.
  - In a party, clients' E and R mean ready. Quick ascent must never start a solo raid.
- **Host choices:** sector, day/night and terms. These change the world, so they are host-only. Clients see them in the roster.
- **Ascend together** unlocks when everyone is ready. Then `start`, then every client acks `built`, then the world starts. After a 10 s timeout the seat is dropped; that client never left and keeps its packed kit.
- **Per-player endings**
  - **Extract:** a seat completing the pull in a landed ring gets `{t:'end',how:'extract',player,bag,pouch,tel,carriedIn,carriedKit,pedCarry,...}`. The client writes that into its mirror `G` and runs its own `endRaid('extract')`.
  - **Death or abandon:** same route. So "coming back empty" happens on the client's own profile through the existing code.
  - No body is left behind. That is his v5.28 order.
  - A beacon call and its siege are shared by the world. The raid clock and the burning of the site end every seat left.
- **When the host's own seat ends**
  - `endRaid` sets `G.over`, and the loop has `if(state!=='raid'||!G||G.sim) return;`, so the world would stop.
  - Fix: in multiplayer the world lives in `NET.world`, and `netHostStep(dt)` runs ahead of the state check. The host can go back to the Undercroft while the others finish.
  - The world is torn down only when every seat has resolved.
- The party stays connected between raids. The roster shows IN RAID m:ss / EXTRACTED / DEAD.

**What each profile keeps:** everything, on its own PC: stash, credits, XP, contracts, cosmetics, fog, settings, free kit, mute list and voice settings.
- The host's world dials apply to the raid only; the client's own CFG is restored afterwards.
- The host never writes a client's profile, and the reverse is enforced by the `saveProfile` guard.
- Clients' hired mercs and intel are off in v1. The host's merc follows the host.

**Needs the owner's word:**
- What happens to clients when the host disconnects. The suggested default is abandon; the alternative is keeping what they carry.
- Teammate revive. It is new; today there is only self-revive.
- Scaling enemies for 4 players. That is balancing, which is frozen until after alpha.

## 6. Testing

**On one PC (automatable in the fixture)**
- **Separate profiles:** add a `?netslot=A|B` override that sets `SKEY='salvagerun:profile:net'+slot` and never writes `salvagerun:activeSlot`. Without it, two same-origin tabs share one profile, because `SKEY` is derived from the active slot.
- **Two tabs, or two iframes of one harness:**
  - Hidden tabs get no rAF, so use a harness in `tools/nettest.html` with two visible 960Ã—540 iframes.
  - Serve it on :8803, never on :8802.
  - Signalling goes over `BroadcastChannel('pillagers-net')`.
  - Real WebRTC connects over loopback, and the parent drives each iframe's `contentWindow` hooks.
- **Transports:** a `LoopTransport` (a BroadcastChannel with setTimeout latency, jitter and loss knobs) for deterministic logic checks, plus the real-RTC path.
- **Checks:**
  1. **Single player unchanged:** seed 4242 ents/containers/`RNGS` after build, and paired A/B against the previous build, with the net code present but off.
  2. **Build parity:** host has a gun, client has none, so the client build path would draw `pick(STARTERS)`. The fingerprints must match. The control run without the build-inputs swap must mismatch.
  3. **Movement:** hold W for 2 s; host seat position matches a single-player run with the same dt sequence. Prediction error under 2 px at 0 loss, under 8 px at 100 ms and 5% loss.
  4. **Search lock and loot:** item lands in the right bag; the second searcher's progress does not grow.
  5. **Kill credit** goes to the shooter's `tel`.
  6. **Deaths are per player:** after a client death, its profile has an empty loadout with the kit in its stash, and the host profile is byte-identical.
  7. **Staged extraction** of one seat, staging `G.active`.
  8. **Host ends first;** the world keeps running.
  9. **Version mismatch** is rejected.
  10. **Disconnect** is handled.
  11. **Voice:**
      - A synthetic mic (oscillator into `createMediaStreamDestination`).
      - PTT KeyY dispatched on window only.
      - Receiver analyser level rises only while held.
      - The gain node's scheduled value at 100/600/1,200 px.
      - Mute gives 0.

**Only on two real PCs**
- **Connection:** NAT traversal and TURN need; real Wi-Fi jitter and loss.
- **Mic and audio:**
  - Mic permission inside the itch iframe. The itch page did not show an iframe allow list when I fetched it, so check on the live page.
  - Mic is also blocked on a LAN IP over plain http, which is not a secure context; localhost and itch https work.
  - Echo with speakers; Windows "communications" ducking the game audio.
- **Browsers and hardware:**
  - Mixed Chrome/Firefox/Edge.
  - 60 vs 144 Hz host.
  - A host that is alt-tabbed or minimized, since rAF stops there. Keep the host tab audible or drive it from a Worker timer.
  - Host CPU with 4 seats; clock drift over a 540 s raid.

**Size of the change:** about 13 guarded hooks in existing code:
- `loop`, `updateEnts` per-ent `p`, the enemy-round seat test in `updateBullets`, the 7 `damagePlayer` sites
- `mouseWorld`, `say`/`sfx`/`earsOf`/`blip`, `saveProfile`
- pause, Superhot and death beat
- the host-seat split in `endRaid`, the `SKEY` override, the lift F action, drawing the other seats

Plus a new NET section of roughly 2,000 lines in the same file, using only browser APIs.