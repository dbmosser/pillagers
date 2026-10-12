## PILLAGERS: THE FORGE (gun upgrades and elemental damage), design document (read only, nothing edited)

**File:** `C:\claudecode\dark raiders\dark_raiders.html`, HEAD 75ffb63b (v23.96) plus fixture commit 7c0816f5. Line numbers are from today's read and will drift; every build re-reads current code.
**Authority:** his chat line of 2026-10-12, "a pack-a-punch mechanism to upgrade guns and add elemental damage would be cool", his follow-ups "in-raid only", "yeah that sounds great" and "if you extract with an upgraded gun you get to keep it", and the coordinator's decisions under "decide but tell me".

**What this design keeps from his standing rules**
- Gameplay identical in DEMO and CAREER: the same Forge, the same prices, the same stats, paid from the same thing (the raid score).
- Guns never wear or jam: the Forge adds no wear, and an upgrade never decays.
- 2.5D, not FPS: every piece of feedback sits at the aim point, on the body that was hit, or on the character. No screen-wide tint.
- AAA HUD voice: short caps callouts (GUN UPGRADED, NEED $2,500, MAX TIER), never explaining sentences.
- Keyboard and mouse first, pad supported, in both windows of same-machine co-op.
- Coming back empty: death loses the gun as usual; an abandon leaves the armoury as it was before the deploy, as usual.

**Five findings that shaped it**
1. **There is no CAREER raid score yet.** DEMO has one (`ARCADE.mine`, 45581, 46022). CAREER's `G.cs` is feat0h in the features design (features-design-2026-10-12.md lines 128-160) and is neither drafted nor shipped. The build that charges for an upgrade (forge9) must ship after feat0h. Everything before it is reachable only by the checks.
2. **A gun instance already survives the backpack.** `gunQPush` (17219) copies every field of the gun into `G.stowQ`, and `equipFromBag` (17311) takes the copy back. Tier and element fields ride along for free. Three places drop them:
   - a pile: `grantLoot` rebuilds a dropped gun from the base table (16964, the anti-reroll rule);
   - the burst echo: it copies five named fields only (14977);
   - the profile: `P.weapons` and `P.stash` hold model ids and key strings only.
3. **Player 2's rounds are damage requests.** The host runs every body (`updateEnts` returns early on a linked window, 20847). Player 2's window works out the damage and sends `netShotSend` (44495); the host applies it in `netShotTake` (44508). Elements therefore go to the host as a field on the shot word, and the host runs every status.
4. **An existing bug blocks MK II numbers for player 2.** `netShotTake` throws away any shot word over 600 (44521). The Longshot went to 170 at v21.66, and 170 x 3.6 (the Choir's DORSAL SPINE, 9205) is 612. So player 2's best shot in the game is already dropped today. A MK II Longshot (221 x 3.6 = 796) would be dropped every time. It is fixed first, on its own (forge1).
5. **No seeded draw is needed anywhere.** Every rule below is deterministic:
   - the Forge spot is authored and nudged by a fixed spiral;
   - the arc picks the nearest target;
   - burn, freeze and shred are timers and counters;
   - cosmetics use `fxn`/`fxr`.
   The seed 4242 fingerprint (ents 85/374, containers 165/593) cannot move: the station adds no ent and no container, and it is placed after every roll.

---

## PART 1. THE MODEL

### 1.1 The Forge on COLD STORAGE

**Where.** Add a field to the COLD STORAGE definition (`FIXED_MAPS[0]`, 6876):
`forge:{x:2420,y:1540,name:'THE FORGE'}`.

**Why this spot.**
- It is the 170 unit aisle between the PACKING FLOOR racking (whose rows end at x 2320) and the CHILL ROW units (which start at x 2520). It sits on the seam of the ammo zone and the medical zone, 330 units from the map centre (2100,1700).
- It is contested by geography. Every route between the west half and CHILL ROW crosses this aisle.
- Distances:
  - nearest extraction: (1700,400) at 1,349;
  - spawns: (2950,1000) at 757, (2180,2300) at 797 and (1600,1750) at 846.
  A fresh drop can reach it in about 5 s, and so can everybody else.
- It passes the `sealSpot` definition test (`defClear` inside `sealSpot`, 9531-9566):
  - the rack rows plus their 30 margin stop at 2350;
  - the CHILL ROW buildings minus their 30 margin start at 2490;
  - no water.
- THE COLD MILE is frozen (feat0b) and gets no Forge. A map with no `forge` field has none.

**Built.** `forgeSpot(map,def)` runs at raid build, after every seeded pass, beside the seal (11853-11856), but not inside a `sideStream`, because it draws nothing.
- It starts at the authored point.
- If any solid built wall (not `win`, not `ledge`) overlaps a 34 unit disc there, it walks the same 16-heading spiral `sealSpot` uses (40 unit steps, out to 400) against `G.map.walls` and takes the first clear disc on a walkable `map.navD` cell.
- Both windows of a pair build the same walls from the same seed, so they agree.
- The station is stored on the raid object beside the seal at 11931: `forge:(sim?null:forgeSpot(map,FIXED_MAPS[mapIx]))`. The sim and the bot never see it.

**What it is.**
- Not a wall and not an ent: it has no collider, like the seal slab.
- Drawn in the depth sort: `DR.push` beside the seal at 27171.
- An anvil-furnace block about 44 x 40, with a molten slot that pulses (cosmetic, `fxn`) and a ground glow ellipse. It registers itself as a bloom source with `gfxEmit` (36386) and casts a `flash` light at night.
- A label THE FORGE over it in the world-text style of `drawSealSlab` (27107-27133).
- A marker on the M map beside the seal ring (34135-34146): an amber anvil glyph and THE FORGE.

**It is loud.** A completed upgrade:
- calls `ping(forge.x,forge.y,700,false,false,'player','fire')`, the way the seal cut pings at 620 (19504-19507), so machines and pillagers in earshot investigate;
- throws a gold `spark` and `flash` burst.
Forging is a decision made in the open.

### 1.2 The interaction (keyboard and pad)

**Detection.** On the standing path of `updatePlayer`, beside the stall code (19660-19710):
- `G.nearForge = G.forge` when the player is within 70, `losClear`, not downed, not rolling, and the raid is not over.
- It is reset where the stall is reset on the downed branch (16008-16016).

**One prompt at a time.**
- `promptPick` (8185) gains `'forge'`, after `'deal'` and before `'ring'`.
- A crate or pile within 46 wins the key, by the stall's own rule (19683-19690), so a pile dropped on the Forge is still searchable.
- Pad: add `G.nearForge` to the X-is-E list at 13904. Pad X is then E, as everywhere.

**Prompt.** Drawn beside the seal prompt (31034-31042) with `hudPrompt` (8154), and a hold bar under its plate:

| Gun in hand | Prompt | Detail line |
|---|---|---|
| plain | `HOLD [E] UPGRADE · MK II` | `$2,500`, or `NEED $2,500` in danger red when short |
| MK II | `HOLD [E] UPGRADE · MK III` | `$6,000 · CHOOSE ELEMENT` |
| MK III | `MAX TIER` | no key |
| fists, or nothing | `NO GUN IN HAND` | no key |

**Hold.** `FORGE_HOLD=1.0` s of E, or pad X, fills the bar.
- Letting go resets it.
- Taking damage does not reset it: the search does not either.
- While held, the hands are busy (`G.handsT`), as with the seal.
- Fire is not blocked by the code, but E and the trigger are different hands of the player.

When the bar fills:
- **A plain gun becomes MK II at once.**
  - The score is charged.
  - The gun is rebuilt with `forgeApply`.
  - Callout `GUN UPGRADED`, detail `AUTO RIFLE MK II`, in the objective lane.
  - The pickup gun card (`G.gunCard`, 15393-15400) shows the new gun against the old one, with route tag `MK II  -$2,500`. The stat card that already exists does the before and after.
  - Sound `forge`, gold sparks, the ping.
- **A MK II gun opens THE WHEEL.** Nothing is charged until an element is picked.
- **Refusals** are said once per press (`G.forgeLock`, as `G.pedLock`): `NEED $2,500`, `MAX TIER`, `NO GUN IN HAND`.

**THE WHEEL** (`G.forgeWheel={t0,sel}`).
- The world keeps running. It is not a pause, exactly as the stall (`G.trade`) is not (19709-19722). `updatePlayer` takes its `tickRegen` and `tryExtractTick` and returns, and `mouse.down` is let go as the stall does (19706).
- It is drawn on the HUD canvas, centred on the Forge's screen point:
  - four sectors, each with its colour, its name and two words;
  - a centre disc reading `MK III  $6,000` and `CHOOSE ELEMENT`.
- Sectors:

  | Position | Element | Two words |
  |---|---|---|
  | top | FIRE | BURN · PANIC |
  | right | SHOCK | CHAIN · STUN |
  | bottom | CRYO | SLOW · FREEZE |
  | left | ACID | SHRED · ANTI-MACHINE |

- **Keyboard and mouse** (`raidKey`, 12388, beside the stall block at 12445-12470):
  - 1, 2, 3 or 4 picks and confirms;
  - the mouse picks the sector by its angle from the wheel centre (inside a dead disc of 20 percent of the radius nothing is picked);
  - LMB or E confirms the highlighted sector;
  - Esc, Tab or B closes with no charge.
- **Pad** (a branch shaped like the stall branch at 13794-13817; `padRelease` first, so nothing fires behind it):
  - the left stick past 0.5 picks by angle, and the D-pad up, right, down and left picks too;
  - A or X confirms;
  - B closes; Menu pauses, as at the stall.
- **Also closes it:** `backOut` (37398) and stepping more than 90 from the Forge.
- **Confirm:** charge $6,000, rebuild the gun with the element, then:
  - callout `GUN UPGRADED`, detail `AUTO RIFLE MK III · FIRE`;
  - the gun card with route tag `FIRE  -$6,000`;
  - sound `forge` plus the element's impact sound;
  - sparks in the element colour.

**Two players on one machine.** Each window has its own Forge and its own score, so there is no host message for the station. Both can forge the same raid. Player 2 on a controller uses pad X and the wheel's pad branch.

### 1.3 Costs: paid with RAID SCORE, the same in DEMO and CAREER

`FORGE_COST=[2500,6000]` (MK II, MK III). One wallet helper, so no caller ever asks which mode it is in:

```
function forgeScore(){ return (G&&G.arcade)?Math.max(0,ARCADE.mine|0):((G&&G.cs)?Math.max(0,G.cs.s|0):0); }
function forgeSpend(n){ if(forgeScore()<n) return false;
  if(G.arcade){ ARCADE.mine=(ARCADE.mine|0)-n; arcadeScSend(); } else G.cs.s-=n; return true; }
```

- In 2-player DEMO each window spends its own `ARCADE.mine`. The team score is the sum, and `arcadeScSend` (46037) tells the other window at once.
- In CAREER the score left is what extraction doubles into credits (feat0h `careerSettle`). So a MK II costs a CAREER player 5,000 extraction credits. That is the identical-rule consequence, and it makes the choice real.
- Decision (tell him): the DEMO high-score board and the CAREER personal-best board record what is left after a spend. A forge costs board score. That is the trade: power now against score.
- Scale. A pillager kill is 150 and a Sentry 100 (`ARCADE_KILLPTS`, 45729). An extraction bonus is 2,500 (`ARCADE_XBONUS`, 45661). Valuables score their credit value (arcade31). A MK II is about one good fight plus a box or two. A MK III is a committed run.

### 1.4 Stat changes per tier, through the WEAPONS data

`WEAPONS` (2170-2201) is never mutated. `forgeApply(w,fk,el)` returns a fresh shallow copy, the way `rollFieldGun` (2362) and `bakeWear` (10913) already do:

| Field | MK II (`fk:1`) | MK III (`fk:2`) |
|---|---|---|
| `dmg` | `round1(base.dmg*1.30)` (per pellet for pellet guns) | as MK II |
| `mag` | `max(ceil(mag*1.25), mag+1)` | as MK II |
| `reload` | `round(reload*0.80)` | as MK II |
| `name` | base name + ` MK II` | base name + ` MK III` |
| `tint` | `'#ffc94a'` (gold) | the element colour (tracer and muzzle) |
| `fk` | `1` | `2` |
| `el` | none | `'fire'`, `'shock'`, `'cryo'` or `'acid'` |

- `rof`, `spread`, `rng`, `noise`, `pellets`, `burst`, `optic` and `thru` are untouched. Fire rate never changes, which keeps sound and recoil feel.
- About +40 percent sustained damage: 30 percent a round, more rounds, quicker reloads.
- `forgeApply` is called on the gun as it is, and always starts from `WEAPONS[w.id]` for the multipliers, so forging twice never compounds. The rolled-quality fields (`q`, `qRank`) are kept.
- Examples at MK II:

  | Gun | Damage | Magazine | Reload (ms) |
  |---|---|---|---|
  | Auto Rifle | 23 to 29.9 | 25 to 32 | 2050 to 1640 |
  | Compact SMG | 12 to 15.6 | 30 to 38 | 1850 to 1480 |
  | Riot Scattergun | 16 to 20.8 a pellet | 7 to 9 | 2400 to 1920 |
  | Longshot | 170 to 221 | 5 to 7 | 3200 to 2560 |
  | Meridian Lance | 150 to 195 | 3 to 4 | 4000 to 3200 |
  | Scav Pistol | 23 to 29.9 | 12 to 15 | 1400 to 1120 |

- `ELEM` table, one place for every number and colour:

  | id | `c` (tracer, number, glow) | sound |
  |---|---|---|
  | `fire` | `#ff4f2a` | `elFire` |
  | `shock` | `#5aa8ff` | `elShock` |
  | `cryo` | `#c8f0ff` | `elCryo` |
  | `acid` | `#9cff4a` | `elAcid` |

- `gunTierOf(w)=(WTIER[w.id]||0)+(w.fk||0)`. A MK III Auto Rifle ranks 5, with the Longshot.
  - `gunStats` (2224) reads it, so the stat card verdict is honest (a MK III rifle against a plain LMG is not a DOWNGRADE).
  - `arcadeGunLoot` (45955) reads it for the stowed gun (`st`), so a DEMO find never pushes a MK III gun out of the stowed slot for a plain gun one rank up.
  - `carriedGuns` (23651) sorts by it on the extraction.
- Forging an ISSUED gun (a rolled starter, or the DEMO kit gun) makes it yours: `p.wepIssued=false`. You paid for it, and his rule "if you extract with an upgraded gun you get to keep it" covers it. The freebie-kit pistol rule (v15.58) still keeps it out of gun 1 at home.
- Loaded rounds are not topped up. Only the cap rises, so the Forge is never an ammo dispenser.

### 1.5 How an upgraded gun instance is stored

**In the hands.** `p.wep` or `p.sec` is the forged copy. `fireWeapon` (16184) reads `wep.dmg`, `wep.mag` and `wep.reload` as it always has, so the stats work with no other change.

**Gun keys.** The four gun keys (GUNKEYS, 1720; `gunKeysSettle` 17406) pin by model id (`'gun_'+id`). Forging keeps the id, so the gun keeps its key, its belt cell and its slot. The hand cells in `hotbarSlots` (17559) take `A.name` and `A.tint`, so the belt shows `AUTO RIFLE MK II` in gold with no change.

**In the backpack.** It already works:
- `bagHeldGun` (17236) calls `gunQPush(g)` (17220), a full shallow copy into `G.stowQ[id]`, first in first out per model;
- `equipFromBag` (17311) takes it back with `gunQTake` (17232);
- the DEMO stowed-gun push (`arcadeGunLoot` 45964) uses the same pair.
The forge3 check pins this with a regression assertion, but nothing changes there.

**In a pile (forge11).** The pile loses it today.
- `dropItem` (16386) splices the key out of the backpack. `gunQTrim` later drops the oldest copy, and `grantLoot` rebuilds a dropped gun at field grade (16964).
- Change: when the dropped key is a gun whose copy about to be trimmed (`q[0]` of `G.stowQ[gk]` once the count falls) carries `fk`, the pile records `c.fw={fk,el}`.
- `grantLoot` re-applies it: `ct.fw ? forgeApply(base,ct.fw.fk,ct.fw.el) : field`. Plain guns keep the anti-reroll rule exactly.
- On a linked window the pile is made by the host from the `pile` word (`netPileTake` 16373). The word gains `fk` and `el`, checked against `ELEM` and 1 to 2.
- So a teammate can pick up your MK III, and you can drop it and take it back.

**Burst echo (14977).** Add `el:BE.wep.el` to `ew`, so the second and third rounds of a Burst Carbine burst carry the element. Without it two thirds of a MK III carbine would be plain.

**On the profile, CAREER only (forge12).**
- **The record.** `P.forged={gk:{fk:1|2,el:''}}`, at most one per model, because the armoury (`P.weapons`) holds one of each model and a duplicate goes to `P.stash` as a plain key string (`bankItem`, 23620).
- **Extraction** (`endRaid`, the banking at 24051 and the hands at 24085-24092). After the existing banking, `forgeBank()` reads every forged gun the player carried out:
  - both hands, not issued;
  - the `G.stowQ` copies still matched to backpack keys (`gunQTrim` first).
  For each model, the highest `fk` wins, and on a tie the gun in the hands wins. If the model is in `P.weapons` after banking, `P.forged[gk]` is written.
- **Decision (tell him).** If he already owned a plain Auto Rifle and extracts a MK III rifle he found, his armoury Auto Rifle becomes the MK III. The extra plain copy goes to the stash as a sellable duplicate, as today. An extracted forge never downgrades the record: a MK II carried out over a MK III record keeps the MK III.
- **Deploy** (10925-10951). After `bakeWear`, the primary and the secondary each become `forgeApply(copy,P.forged[id].fk,P.forged[id].el)` when a record exists. `wepFromArmory` stays true, so the rules about losing it are unchanged.
- **Losing it.** `forgeSweep()` deletes any `P.forged[gk]` whose model is no longer in `P.weapons`. It runs:
  - at the end of `endRaid` (all three outcomes);
  - on profile load, beside the weapon filter at 3376, where it also drops any entry whose key is not in `WEAPONS`, whose `fk` is not 1 or 2, or whose `el` is not in `ELEM`;
  - after any Undercroft sale of an armoury gun.

  What that gives, with no special cases:

  | How the raid ends | Effect on the forge |
  |---|---|
  | dead | the carried armoury gun comes off `P.weapons` (24224-24226), so its forge goes with it |
  | abandon | the armoury is restored to its pre-deploy state (24286-24290), so an older forge survives and a forge bought this raid is never written |
  | extract | kept |

- **DEMO** has no stash. An arcade raid never reaches the settle (`endRaid` hands it to `arcadeExtracted`/`arcadeDied`, 23712), so nothing is written and the forge lasts the DEMO run. A 2-player DEMO respawn re-issues the kit and loses it, which is the DEMO's death rule.

### 1.6 Each element through the damage paths

**One host-side entry,** `elemHit(en,el,d,seat,sx,sy)`, where `d` is the damage the round actually dealt after the weak point, shield and armour, and `seat` is 0 for the host's own or solo player. It is called in two places only.

1. **Host and solo rounds,** `updateBullets` (22860). Right after `en.hp-=edmg` (22999), on the branch that is not a linked window:
   `if(b.el&&b.player) elemHit(en,b.el,edmg,0,b.owner.x,b.owner.y);`
   - The bullet gets `el:wep.el||''` where it is pushed in `fireWeapon` (16237-16241). Its `tint` is already `wep.tint`, so the tracer is the element colour.
   - ACID's two pre-damage effects are applied above the soak (1.6, ACID): the shred above the armour block at 22979-22983, and the machine bonus above line 22999.
   - The damage number colour at 23006: `WK ? orange : (b.el ? ELEM[b.el].c : (back shot ? gold : bone))`. The weak point stays orange because it is the more important fact.
2. **Player 2's rounds,** `netShotSend` (44495) and `netShotTake` (44508):
   - `netShotSend(en,edmg,ang,WK,_nar,b.el)` adds `m.el` (validated against `ELEM`);
   - `netShotTake` calls `elemHit(e,m.el,d,s,sx,sy)` after `e.hp-=d` (44525), with ACID's shred and machine bonus applied before it, as on the host;
   - the 600 cap becomes 1500 (forge1).
   The window that fired already draws its own coloured number (it chooses the colour), and `netFxDmg` (42713) carries the colour to the party.

**Not involved.**
- `damagePlayer` (15813) is untouched. In 2-player PVP a forged round does its MK damage to the other player and carries no status.
- Fists (the `mag===0` branch, 16207-16233) never have an element.
- Wildlife takes plain damage.
- Glass and destructible walls take `b.dmg`, which is already the MK damage.

**Kill credit for damage over time and arcs.** `elemCredit(en,seat)` mirrors the round rules:
- `if(en.hp<=0){ if(seat>0){ en.byPlayer=false; en.bySeat=seat; } else en.byPlayer=true; }`.
The death path (21087-21090) and `netEntGone` (44273) then pay contracts, the kill feed, DEMO score and the CAREER score, exactly as for a round. A burn that finishes a downed pillager is your kill, as a round would be (v15.45).

**Target rules shared by all four.**
- No status on: a merc (`en.merc`); a pillager who joined you (`friendlyPC`); a body with `finished`; a body with `hp<=0`.
- No arc to: the Peddler; the Survivor while not hostile; a peaceful pillager (`hostile===false`); a merc.
- The Overseer boss (`e.boss`) and the Warden and Choir take shortened control effects (below).

**FIRE: burn, and pillagers panic.**
- Each hit sets `e.burnT=3.0` and `e.burnDps=max(e.burnDps, min(18, 4+0.25*d))`, and remembers `e.burnBy=seat`.
- `elemTick` takes `burnDps*dt` off `hp` every frame while `burnT>0`. Armour does not stop fire.
- Examples: Auto Rifle MK III 11.5 a second (+34 over 3 s); SMG 7.9; Longshot capped at 18 (+54).
- **Panic** (pillagers only, `kind==='raider'`, not downed, not a merc):
  - the first burning hit with `panicCd<=0` sets `panicT=1.2`, `panicCd=5`, and the panic origin (`sx,sy`, the shooter);
  - while panicking he runs straight away from that point at `spd*1.1` through `moveToward` (20766), holds fire (`e.cd=max(e.cd,0.3)`), and does not roll;
  - then he resumes his AI, still hostile.
- Machines burn and keep fighting.

**SHOCK: chain, and stun machines.**
- Each hit arcs once to the nearest other valid body within 160 with `losClear` on `G.map.segs`.
  - The arc deals `0.5*d` (no weak point; the shield does not soak an arc; armour soaks it as a round).
  - It turns a pillager hostile the way a round does: the same lines as 23040-23060, through a small shared helper.
- Per-shooter arc cooldown 0.2 s (`G.arcCd[seat]`), so an SMG or a scattergun blast arcs about five times a second, not once a pellet.
- **Stun** (machines: sentry, crawler, listener, bulwark, howler, snitch, warden, choir):
  - `stunT=0.5` (Warden and Choir 0.25, the boss 0), refused while `stunImm>0`, then `stunImm=2.5`;
  - a stunned machine is rooted, cannot fire and cannot see (the same skip as overheat, below).
  - The immunity keeps an SMG from holding a Sentry forever, the v6.83 lesson on overheat (9242).

**CRYO: slow, and repeated hits freeze.**
- Each hit adds `chill+=clamp(d/25,0.35,3)` and sets `chillT=2.5`.
- While `chillT>0` the body moves at 60 percent: one multiply in `moveToward` (20781), beside the water rule, `if(e!==G.player&&e.chillT>0) spd*=0.6`. `navSeek` and `seekPoint` both reach `moveToward`, so every walker obeys it.
- At `chill>=6`, with `freezeImm<=0`: `frozenT=1.4` (Warden and Choir 0.7, boss 0.6), `chill=0`, `freezeImm=4`. A frozen body is rooted, silent and cannot fire. Pillagers freeze too.
- Hits to freeze from cold:

  | Gun (MK III) | Stacks a hit | Hits to freeze |
  |---|---|---|
  | Longshot | 3 | 2 |
  | Auto Rifle | 1.2 | 5 |
  | SMG | 0.62 | about 10 |
  | Scattergun | 0.83 a pellet | about one blast and a half |

**ACID: eats armour plates, extra damage to machines.**
- **Before the armour soak** (22979-22983 on the host; the `m.ar` branch at 44524 for player 2):
  - shred `min(en.armor, 0.6*d)` off `en.armor`;
  - set `corrT=4`, during which the rig's `absorb` counts half.
  - A Breacher Plate pillager (120 armour, absorb 0.66) goes from soaking two thirds of each round to bare in about seven MK III rifle hits instead of about twenty.
- **Machines** take `d*1.25` after any shield soak. On the host this is applied to `edmg` before line 22999. For player 2 it is applied by the shooter's window before sending, so the number it draws is the real one.
- No damage over time.

**Status timers and where they run.**
- `elemTick(dt)` is called once a frame from `updateEnts`, host or solo only (the linked window returns at 20847). Put it right after the frame counter at 20934. It:
  - decrements `burnT`, `panicT`, `panicCd`, `stunT`, `stunImm`, `chillT`, `frozenT`, `freezeImm` and `corrT`;
  - lets `chill` decay to 0 once `chillT` ends;
  - applies the burn with `elemCredit`.
- **The AI skip.** `elemHold(e,dt)` sits in the per-body loop (20972) right after the downed block (21259) and before the stray and Peddler branches (21264). It returns true, so the loop `continue`s, for:
  - a stunned or frozen body: `moving=false`; `cd=max(cd,0.35)`; `collide`;
  - a panicking pillager: the run, as above.
  The overheat branch (around 21520) is the precedent: no sight, no move, no shot.
- The sim and the bot never fire a forged gun, so none of this ever runs there. All of it is plain arithmetic with no draws.

**How the host mirrors statuses to player 2.**
- `netEntFlags` (44253) uses bits up to 2^22 (blind). Five new bits:

  | Flag | Bit | Value |
  |---|---|---|
  | burning | 2^23 | 8388608 |
  | stunned | 2^24 | 16777216 |
  | chilled | 2^25 | 33554432 |
  | frozen | 2^26 | 67108864 |
  | corroded | 2^27 | 134217728 |

  These are all below 2^31, so JS bitwise stays exact.
- `netEntFlagsApply` (44330) sets `e.burnT`/`e.stunT`/`e.chillT`/`e.frozenT`/`e.corrT` to a nominal 0.3 while the bit is on and 0 when it is off, the way the `overheat` and `shotT` bits are mirrored.
- Player 2 draws the same status effects from those fields. His window runs no status of its own (`updateEnts` returns early), so nothing is double-applied.
- The shock arc line is a cosmetic fx word: `netFx` kind `'a'` with `[x1,y1,x2,y2,col]`, broadcast by the host in `elemHit` and drawn by `netFxTake` (42786) into `G.arcs`.
- Player 2's tracers already carry the element colour, because `netFxShot` (42704) sends `b.tint`. A seventh entry, `1` for elemental, lets the receiving side draw the wider elemental tracer.

### 1.7 Visuals and sound per element (all cosmetic: `fxn`/`fxr`, `!G.sim`, never seeded)

| | Tracer (28158) | Impact | Body while affected | Number | Sound |
|---|---|---|---|---|---|
| MK II (no element) | gold, as `tint` | gold sparks | none | bone/weak/back as today | the gun's own |
| FIRE | `#ff4f2a`, width 3 | orange spark burst and an ember decal | 3 to 4 flame tongues licking up the body (additive), ember sparks, a `gfxEmit` warm glow; a panicking pillager gets a smoke trail | `#ff4f2a` | `elFire`: a short noise whoosh plus crackle |
| SHOCK | `#5aa8ff`, width 3 | blue-white sparks | a jagged arc line to the chained body (0.12 s); a stunned machine shows small crawling arcs over its hull and its eye dims | `#5aa8ff` | `elShock`: a sawtooth sweep from 1.2 kHz to 200 Hz, 0.12 s |
| CRYO | `#c8f0ff`, width 3 | ice shard sparks | chilled: pale blue rim and frost specks; frozen: a translucent ice block drawn over the body with a white edge, and a crack burst when it ends | `#c8f0ff` | `elCryo`: two glassy sines (2.2 and 3.3 kHz); `elFreeze`: a crack on freeze |
| ACID | `#9cff4a`, width 3 | green splash sparks | green drips falling off the body for `corrT`; an armour bar over a pillager flashes green as it is shredded | `#9cff4a` | `elAcid`: band-passed noise hiss at 3 kHz, 0.25 s |

- **Throttle.** One element impact sound per target every 0.15 s (`e.elSndT`) and one body effect pass per body per frame, so an SMG does not stack sound.
- **The sounds** go through `blip` (5005) into the mixer buses (v23.67), as `hit` and `clank` do. They are new `type` branches beside `pickGun` (around 5240).
- **The Forge's own sounds:**
  - `forge`: a low thump, a metallic 880 Hz ring decaying over 0.6 s, and a noise hiss;
  - a quiet furnace hum while standing within 70 (the `servo` voice at low volume).
- **Gun glow on the character.**
  - After the player's `drawOp` (27768, and the see-through copy at 27936), a small additive glow at the hands (x + cos(face) x 12, y - 10): gold for MK II, the element colour for MK III. It pulses at 1.5 Hz and registers a `gfxEmit`.
  - Player 2's body is drawn by `netUpDrawOne` (42595) from his state word. The word (42531-42533) gains `fk` and `el` when set, and the receiver (41403) stores `g.fk` and `g.el`, so each window sees the other's forged gun glow.
- **HUD.**
  - The gun card names the gun `AUTO RIFLE MK III` in gold (the name colour comes from `RCOL[gunRarity]` at 15375 and becomes gold when `fk`), with the element as a coloured tag line.
  - The belt hand cells show the name and tint automatically.
  - `gunIcon` (32536) prefers the rarity colour over `tint` (32538), so a forged gun passes an explicit gold or element override and gets a small element pip in the cell corner.
- Nothing is a full-screen overlay: the 2.5D rule.

### 1.8 Balance

**Value.**
- MK II is about +40 percent sustained damage for 2,500 score. In CAREER that is effectively 5,000 credits off the extraction pay.
- Elements add, roughly:

  | Element | Single target | Groups and control |
  |---|---|---|
  | FIRE | +25 to 40 percent over 3 s | panic breaks a pillager push |
  | SHOCK | none | +50 percent of every hit as splash in a pack (crawler swarms, waves); short machine stuns |
  | CRYO | none | control: kiting and freezing a Bulwark or a Warden for a flank |
  | ACID | strongest against armoured pillagers and every machine | +25 percent against machines |

**No element dominates every fight.**
- FIRE is the generalist.
- SHOCK suits DEMO waves.
- CRYO suits solo survival.
- ACID suits PvE machines and plated pillagers.

**Guards against breaking the game.**
- Immunity windows on stun (2.5 s) and freeze (4 s), as overheat has (`htImmune`, 9242).
- A cap on burn per second (18).
- The arc cooldown (0.2 s).
- Short control on Warden, Choir and the boss.
- Stats only scale existing numbers, so the 1500 shot cap holds the worst case: MK II Longshot 221 x 3.6 = 796, and the ACID machine bonus makes it 995.

**What cannot be measured.** The bot never forges, so the sim cannot measure the Forge (as it cannot measure pillager fights). Every number above is one row in `FORGE_COST`, `FORGE_MUL` or `ELEM`, so his playtest tunes it in one place. Balancing is allowed (his 2026-10-02 ruling); each change says why.

**Waves (DEMO and CAREER).** A forged gun makes later waves easier. If his playtest says DEMO gets trivial, the lever is the wave tier read from the score (feat0h), not the Forge.

---

## PART 2. EVERY CODE SITE (today's lines)

| Site | Line(s) | Change | Build |
|---|---|---|---|
| `netShotTake` 600 cap | 44517-44521 | to 1500 | forge1 |
| `WEAPONS` | 2170-2201 | untouched (read only) | - |
| `gunStats` / `gunCompare` | 2224-2242 | tier from `gunTierOf` | forge2 |
| new `FORGE_COST`, `FORGE_MUL`, `ELEM`, `forgeApply`, `gunTierOf`, `forgeName` | after `rollFieldGun` (2362-2381) | new, pure | forge2 |
| `arcadeGunLoot` stowed tier | 45960 (`st=`) | `gunTierOf(p.sec)` | forge2 |
| `fireWeapon` bullet push | 16237-16241 | `el:wep.el\|\|''` | forge3 |
| burst echo | 14977 | `el:BE.wep.el` | forge3 |
| `updateBullets` hit | 22935-23010 | `elemHit` after 22999; acid before 22979; number colour 23006 | forge3 to forge6 |
| `updateEnts` | 20934 / 21259 | `elemTick(dt)` / `elemHold(e,dt)` | forge3 |
| `moveToward` | 20781 | the chill multiplier | forge5 |
| `netShotSend` / `netShotTake` | 44495-44533 | `m.el`, host `elemHit` | forge7 |
| `netEntFlags` / `netEntFlagsApply` | 44253-44261 / 44330-44341 | five status bits | forge8 |
| `netFxTake` / new `netFxArc` | 42786 | kind `'a'` | forge8 |
| tracer draw | 28152-28165 | width 3 for elemental | forge8 |
| status body effects pass | after the depth sort, beside the damage bars (27943) | new `drawElemFx()` | forge8 |
| `blip` types | 5005 to 5600 | `forge`, `elFire`, `elShock`, `elCryo`, `elFreeze`, `elAcid` | forge8 (`forge` in forge9) |
| state word / receiver | 42531-42533 / 41403 | `fk`, `el` | forge8 |
| player glow | 27768, 27936; `netUpDrawOne` 42595 | glow | forge8 |
| `FIXED_MAPS` cold | 6876 | `forge:{x:2420,y:1540,name:'THE FORGE'}` | forge9 |
| raid object | 11931 (`seal:` beside it) and 11853 | `forge:` from `forgeSpot` | forge9 |
| `updatePlayer` standing path | 19660-19722 | `G.nearForge`, the hold, the MK II apply | forge9 |
| downed reset | 16008-16016 | `G.nearForge=null; G.forgeHold=0; G.forgeWheel=null` | forge9 |
| `promptPick` | 8185-8197 | `'forge'` | forge9 |
| pad X list | 13904 | `G.nearForge` | forge9 |
| prompt draw | beside 31034-31042 | `hudPrompt` and bar | forge9 |
| world draw | `DR.push` beside 27171 | `drawForge` | forge9 |
| M map | beside 34135-34146 | marker | forge9 |
| `G.gunCard` | 15393-15400 | the before and after on forging | forge9 |
| `raidKey` | 12388, beside 12445-12470 | wheel keys | forge10 |
| pad branch | beside 13794-13817 | wheel pad | forge10 |
| `backOut` | 37398 | closes the wheel | forge10 |
| HUD draw | beside `drawTrade` 31349 | `drawForgeWheel` | forge10 |
| `dropItem` / `netPileTake` / `grantLoot` | 16386 / 16373 / 16964 | `c.fw` | forge11 |
| `endRaid` extraction | 24051, 24085-24092 | `forgeBank()` | forge12 |
| `endRaid` end, profile load 3376, Undercroft gun sale | - | `forgeSweep()` | forge12 |
| deploy | 10925-10951 | `forgeApply` from `P.forged` | forge12 |
| `carriedGuns` | 23651-23658 | sort by `gunTierOf` | forge12 |
| `itemRows` | 31419 | MK and element rows for an owned forged model | forge13 |
| Undercroft gun names, armoury rows, belt plan cells, stat card | the `WEAPONS[gk].name` readers (3697, 23502-23537) | `forgeName(gk)` | forge13 |
| `WHATSNEW` | top of file | THE FORGE lines | forge14 |

**Existing bug found in passing (shipped as forge1).** Player 2's Longshot into a Choir's DORSAL SPINE (170 x 3.6 = 612) is thrown away by the host as `'bad'` today. The v22.24 comment still quotes the old 115 damage.

---

## PART 3. THE BUILDS (keys forge1 to forge14, in order, one behaviour each)

Every check returns null on a pass. Each fails on the previous build because the function, field or behaviour it reads is missing; that is the control. All use `__topClear`, `__runPrep`, `__resetCfg`, `__pinDefaults(0)`, `__deploy({kit:[],safe:null,mapIx:0,seed:4242})`, end the raid and restore P fields in `finally`, and restore the profile through the loader where `P` is touched. No check draws from the seeded stream. Ents are staged by moving an existing crawler, sentry or pillager to a fixed open spot near the player (the stray staging in older checks) and calling `elemHit`, `elemTick` and `updateBullets` directly, not by AI luck.

1. **forge1: PLAYER 2'S BEST SHOT LANDS.** `netShotTake` cap 600 to 1500.
   - Check: the host staging of the v22.24 (K35) check. Call `netShotTake` with `m.dmg=612` and `m.wk='DORSAL SPINE'` on a Choir. It must return `'shot'` and lower `hp` by 612 x 1. 1600 must still be `'bad'`.
   - Control: 612 returns `'bad'`.
2. **forge2: THE FORGE MODEL.** `FORGE_COST`, `FORGE_MUL`, `ELEM`, `forgeApply`, `forgeName`, `gunTierOf`; `gunStats` and `arcadeGunLoot` read the tier. No caller can make a forged gun yet.
   - Check:
     - `forgeApply(WEAPONS.rifle,1)` gives dmg 29.9, mag 32, reload 1640, name `Auto Rifle MK II`, fk 1, and `WEAPONS.rifle.dmg===23` afterwards;
     - fk 2 with `'cryo'` gives `el==='cryo'` and `tint===ELEM.cryo.c`;
     - forging the result again does not compound;
     - Lance mag 3 to 4;
     - `gunTierOf` is 4 for the MK II rifle;
     - `gunCompare(MK III rifle, plain lmg).verdict!=='DOWNGRADE'`.
3. **forge3: FIRE ROUNDS BURN AND PILLAGERS PANIC.** The bullet carries `el` (with the burst echo); `elemHit`, `elemTick`, `elemHold`, `elemCredit` for fire; the number colour.
   - Check:
     - `p.wep=forgeApply(WEAPONS.carbine,2,'fire')`, then `fireWeapon` gives the last bullet `el==='fire'`; tick `G.throws` 0.2 s and both echo bullets carry `fire`;
     - a crawler hit by a placed fire bullet (`updateBullets(0.001)`) has `burnT>0`; `elemTick(0.25)` x 12 takes about `burnDps*3` (plus or minus 1);
     - `hp=1` then `elemTick(0.5)` gives `byPlayer===true`;
     - a hostile pillager hit gets `panicT>0`, and over `__ents(0.1)` x 6 his distance from the shooter grows and `G.bullets` gains none of his;
     - the last `G.dmgN` colour is `ELEM.fire.c`;
     - regression: `gunQPush` then `gunQTake` of a fire gun keeps `fk` and `el`.
4. **forge4: SHOCK CHAINS AND STUNS MACHINES.**
   - Check:
     - two crawlers 100 apart in the open. `elemHit(a,'shock',40,0,...)` takes 20 off b, and gives `a.stunT>0` and `a.stunImm>0`;
     - `__ents(0.1)` x 3: a has not moved;
     - a second hit inside the immunity does not reset `stunT`;
     - a peaceful pillager or a merc as the only neighbour takes no arc;
     - a second shock call within 0.2 s (same seat) arcs nothing.
5. **forge5: CRYO SLOWS AND FREEZES.**
   - Check:
     - `moveToward(e,e.x+500,e.y,100,0.1)` moves 10 plain and 6 chilled;
     - five hits of `d=30` give `frozenT>0` and `chill===0`;
     - frozen over `__ents(0.2)` the body has not moved and has not fired;
     - a sixth hit inside `freezeImm` does not refreeze;
     - `chill` is 0 after `chillT` runs out.
6. **forge6: ACID SHREDS PLATES AND HURTS MACHINES.**
   - Check:
     - a pillager staged with `rig:'heavy'` and `armor:120` hit by an acid bullet of 30 has armour 120 - 18 - (soak with half absorb), and `corrT>0`;
     - two identical Sentries, one hit by a plain 30 round and one by an acid 30 round: the hp lost differs by 1.25x (within 0.5).
7. **forge7: PLAYER 2'S ELEMENTAL ROUNDS.**
   - Check:
     - stub `netSend` to capture: `netShotSend` from a fire round carries `m.el==='fire'`;
     - host staging: `netShotTake` with `m.el:'fire'` from seat 1 sets `burnT`; a burn kill marks `bySeat===1` and `byPlayer===false`;
     - `m.el:'acid'` on a plated pillager shreds before the soak;
     - `m.el:'bogus'` is ignored.
8. **forge8: ELEMENT EFFECTS, SOUNDS AND THE GUN GLOW, ON BOTH WINDOWS.** The status bits, the arc fx word, the tracers, `drawElemFx`, the six sounds, the glow, and `fk`/`el` in the state word.
   - Check:
     - `netEntFlags` of a burning, chilled body has bits 2^23 and 2^25, and `netEntFlagsApply` sets `burnT>0` and `chillT>0`;
     - a stubbed `blip` records `elFire` on a fire hit;
     - `__gfxCount` shows `drawElemFx` drawing for a burning body and not for a plain one;
     - the state word carries `fk:2,el:'fire'`;
     - `__shot4k` of four staged bodies (one per element) beside a MK III player, LOOKED at.
9. **forge9: THE FORGE UPGRADES YOUR GUN TO MK II.** The map field, `forgeSpot`, the station draw and M map marker, the prompt, the hold, `forgeScore`/`forgeSpend`, the gun card, the `forge` sound, and the ping. Needs feat0h (`G.cs`) in HEAD; if it is not there, park the chain here.
   - Check:
     - `G.forge` exists on COLD STORAGE, within 120 of (2420,1540), clear of every solid wall by 34 on seeds 4242, 7, 99 and 1234, and on a walkable `navD` cell;
     - the fingerprint is 85/165 at 4242;
     - stand the player on it with `keys.KeyE`: at `ARCADE.mine` or `G.cs.s`=3000 and `__sim(0.1)` x 12, `p.wep.fk===1`, the score is 500 and `p.wep.dmg` is 1.3x;
     - at 1000 nothing changes and `NEED` is said;
     - fists gives `NO GUN IN HAND`;
     - the same in DEMO (`ARCADE.mine`) and CAREER (`G.cs.s`);
     - `__shot4k` of the Forge, LOOKED at.
10. **forge10: THE WHEEL: MK III AND AN ELEMENT.**
    - Check:
      - a MK II gun and score 7000; the hold opens `G.forgeWheel`;
      - `raidKey('Digit3')` gives `el==='cryo'`, `fk===2` and score 1000;
      - reopen, then Escape: no charge, wheel closed;
      - stub `navigator.getGamepads` (D-pad right, then A) gives `shock`;
      - stepping 100 away closes it;
      - `__shot4k` of the open wheel, LOOKED at.
11. **forge11: A FORGED GUN DROPPED IS STILL FORGED.**
    - Check:
      - a MK III acid rifle bagged, then `dropItem`: the pile has `fw.fk===2`; `grantLoot` of the pile gives back a gun with `el==='acid'` and the MK name;
      - a plain dropped gun still comes back at field grade (the anti-reroll rule);
      - the `pile` word carries `fk` and `el`.
12. **forge12: EXTRACT IT AND YOU KEEP IT (CAREER).** `forgeBank`, `forgeSweep`, the deploy apply, the `carriedGuns` sort, profile load sanitising.
    - Check:
      - field rifle in hand forged MK III cryo, then `__endRaid('extract')`: `P.forged.rifle` is `{fk:2,el:'cryo'}`, and the next `__deploy` with `P.equipped='rifle'` gives `G.player.wep.el==='cryo'` and a MK III name;
      - a forged gun only in the backpack banks too;
      - the same carried from the armoury, then `__endRaid('dead')`: no `P.forged.rifle`;
      - abandon: the older record survives and this raid's forge is not written;
      - a bogus `P.forged` entry is dropped on load;
      - `P` restored through the loader.
13. **forge13: THE UNDERCROFT SHOWS IT.** Armoury rows, stash hover `itemRows`, belt plan cells and the stat card name and tint from `P.forged`.
    - Check: `P.forged.rifle` staged. `itemRows('gun_rifle')` has a `MK III` row and a `CRYO` row; the hub gun name helper returns `Auto Rifle MK III`; a gold or cryo override reaches `gunIcon`. `__shot4k` of the hub belt, LOOKED at.
14. **forge14: THE WHAT IS NEW CARD NAMES THE FORGE.** A WHATSNEW line under the alpha line (the card shows its first five lines), in plain prose for him.
    - Check: an assembled-needle source search for the line.

**Decisions to tell him (decide but tell me):**
- the Forge stands in the CHILL ROW west aisle;
- MK III costs 6,000;
- forging a loaner makes it yours;
- the board records the score left after a spend;
- an extracted forge goes onto the armoury model, and never downgrades it;
- elements do nothing to players in PvP;
- the wheel does not pause the world.
