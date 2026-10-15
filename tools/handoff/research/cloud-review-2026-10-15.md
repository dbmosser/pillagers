# Cloud review 2026-10-15: everything since v26.54

Read-only static review of `dark_raiders.html`.

- **Range reviewed:** `b4c1b743` (v26.54) to `9502166a` (v27.24), about 4,000 added lines over 73 commits, read in full.
- **Later commits:** v27.25 to v27.30 (`0470f90f`) landed while I worked. I diffed them too, and each finding below is confirmed still present at `0470f90f` unless it says otherwise.
- **Testing:** none. No browser, no node.
- **Grep:** every "grep" quote below is a literal substring of the v27.30 file.

**Drafts already in flight that overlap these findings.** Check that each draft covers the item named before you close it:

- draft-feed3 covers finding 1.
- draft-firefit covers part of findings 2 and 3 (fire placement only).
- draft-nolockdown covers finding 33.
- draft-nocluehunt covers finding 34.
- Already shipped: v27.25 (air strike on a pad) closes half of finding 5, v27.27 (coop8) closes the player 2 goals and bounty gaps, and v27.28 (kit3) closes the BEST KIT label mismatch.

Findings are ranked by how much a player would notice them.

---

## Tier 1: a player sees these every raid

### 1. Every raid line is shown two or three times (v27.24 `9502166a`, feed1)

- **Where:** `say()` now calls `try{ feedSay(m,k,o); }catch(_fsy){}` before the old lanes. `label()` calls `try{ feedLabel(txt,col,ik); }catch(_flb){}`. `netFeedPush` writes `feedKillLine(...)` and also still pushes to `NET.feed`. The comment at `var FEED={show:10,keep:40` says "The old places (the message rows, the pickup stack, the kill feed, the loot labels) still show in this build".
- **What goes wrong:** a pickup appears in the pickup stack (now 6 rows, v27.14) and in the feed. An alert appears in the alert lane and in the feed. A co-op kill appears in the right-edge kill feed and in the feed. A medal appears as a plate over the cursor and in the feed. Two message systems are doing one job, and this is exactly the "different player messages come in at different places" complaint.
- **Fix:** land draft-feed3 (stop drawing the message rows, the pickup stack, `netFeedDraw` and the message labels). Then grep that `pickSay`, `netFeedDraw` and the label path no longer draw anything.

### 2. The stronghold fence is a perfect circle drawn over buildings, and it teleports bodies (v26.91 `3a37f04c` flow11, v27.12 `b638353f` coop4)

- **Where:** `shLayout` checks only the centre (`spotFree(G.map,x,y,50)`) and the gate. The fence is `shDraw` on the HUD canvas: `c.arc(sc.x,sc.y,R,s.ga+s.gw,s.ga+6.2832-s.gw)`. `shKeep` moves bodies with `if(spotFree(G.map,nx,ny,Math.max(6,rad*0.6))){ o.x=nx; o.y=ny; return true; }`.
- **What goes wrong:**
  - The 240-radius ring cuts through walls, rooms and roofs. It is drawn on top of roofs and fog because it is a HUD draw.
  - A body on the wrong side is snapped radially to the ring with no line-of-sight test, so it can be moved through a building wall.
  - Where the snap target is not free, `shKeep` returns false and the body simply crosses: the fence leaks wherever it meets geometry.
  - The player's side (`p.shS`) is kept for the whole raid. A DEMO respawn or redrop within 400 of a ring can therefore pull him to the inside edge.
- **Fix:**
  - Lay a site only where the whole ring band (r ± 40) is clear: sample about 48 points with `spotFree`, as draft-firefit does for fire discs.
  - Draw the fence in the world pass, sorted with the walls (like `drawSealSlab`), not on the HUD.
  - Before snapping a body, require `losClear(o.x,o.y,nx,ny,G.map.segs)`; if that fails, push it back along its own velocity instead.
  - Reset `p.shS` on respawn and redrop.

### 3. Invisible walls are not in the AI's navigation, and event placement ignores strongholds (flow4/flow5/flow6/flow7/flow10/flow11)

- **Where:** `fireKeep`, `shKeep` and `lockKeep` push bodies back every frame. `navSeek` and `moveToward` know nothing about any of them (`fireAt`/`shAt` are only read by `arcadeWaveOk`).
  - The bounty pick ends `flowZoneNear(x,y,350)) S={x:x,y:y};` with no `shAt`.
  - The convoy `ok()` has no `shAt`.
  - The rampage waypoints and the debris `pick`/`start` have no `shAt`.
- **What goes wrong:**
  - Pillagers and machines chasing you walk into a fire disc or fence and are snapped back each frame, which reads as visible jitter. Fire also burns them while they grind there.
  - A bounty hunter can spawn inside a stronghold and be fenced in while "HE HUNTS YOU".
  - A convoy whose route crosses a stronghold piles up on the fence and vanishes at 170 s.
  - The Overseer on rampage is fenced as well (`shKeep` runs for every body with hp > 0).
  - Debris pieces can land inside a compound.
- **Fix:**
  - Give these hazards one shared "flow obstacle" query (fires, fence, lockdown) and have `navSeek` treat a blocked next cell as a wall.
  - At minimum, retarget a body to the ring edge tangent instead of snapping it.
  - Add `!shAt(x,y,80)` to the bounty, convoy (start, destination and a straight-line sample), rampage waypoint and debris pickers.
  - draft-firefit fixes fire placement only, not the navigation.

### 4. Explosive barrels are not co-op aware at all (v27.05 `d2149d7b`)

- **Where:** `brlPlace(G)` runs in every window. `brlOk` rejects spots near the window's own player: `if(p&&Math.hypot(x-p.x,y-p.y)<460) return false;`. `brlBlast` contains `if(peer) return;   // a linked window: the host runs the bodies`. No net word mentions barrels.
- **What goes wrong:**
  - The two windows can lay different barrels, because the side-stream draws diverge when `brlOk` rejects different spots.
  - When player 2 shoots a barrel, it explodes only in his window and damages nobody but himself (the host never hears about it), and the host's copy stays standing.
  - When the host's barrel goes up, player 2 sees nothing and takes no damage.
  - A teammate frag copy (`fx:1`) never lights barrels in the other window.
- **Fix:**
  - Place barrels before the player is placed, or use the drop point rather than `g.player`, so both windows lay the same set.
  - Send a reliable `{t:'fl',k:'brl',id,by}` word when a barrel is lit. The host runs the blast on the bodies; every window plays the effects and applies damage to its own player.
  - A peer's shot should ask the host (the same path as `netShotSend`).

### 5. The finisher cannot be done on a controller (v26.64 `d716bf46` feel16)

- **Where:** `finisherTick` contains `||!keys['KeyV']){ G.finT=0;`. No pad button maps to `KeyV` (see `PADTAP`, `PADHOLD`, `PAD_ACTS`). The prompt is `'FINISH ['+keyLabel('KeyV','V')+']'`.
- **What goes wrong:** player 2 on a pad (his same-PC two-player setup) sees FINISH [V] over every downed pillager and has no way to press it. (The air strike half of this finding was fixed in v27.25 with the LB+RB chord.)
- **Fix:** map the finisher to the pad's X hold when `finTarget(p)` is set (X already picks E or R on the press; add a third mode), or to RS click. Give `KeyV` a `PADLABEL` entry so the prompt names the button.

### 6. The golden enemy shows through walls and fog, and so do other event markers (v26.92 `62f6f3c7` flow12, v27.18 coop5)

- **Where:** `goldDraw` draws the glow, the ground ellipse, the sparks and `hudText('GOLDEN',s.x,s.y-R*1.9-LH(6)*z)` on the HUD canvas whenever the body is on screen. There is no `e.seen` or `canSee` test.
  - The same applies to the bounty ring and `'BOUNTY  $'+BOUNTY.pay` (`evDraw` follows `def.mx`).
  - The convoy ring follows the carrier.
  - The coolant draw outlines every rich crate (`if(!cr||!cr.rich||cr.opened) continue;`) regardless of fog.
- **What goes wrong:** the game's core rule is line of sight. A golden machine behind a wall, or across dark ground at night, is lit up and named, which also undercuts the clue hunt and the search circle. The bounty hunter's exact position is broadcast while he "hunts you".
- **Fix:**
  - Gate `goldDraw` and the bounty label on `e.seen` (the same flag the body draw uses). Keep the map marks if the owner wants them advertised.
  - Clip the rich-crate glints to seen containers.

### 7. The power-up timer chips are drawn on top of the item-in-hand plate and the extraction banner (v26.88 `5c7c2a23` party2)

- **Where:** in `pwrDraw`, `miny-=40*z` then `y0=Math.round(miny-24*z)`, which puts the chips from belt−64 to belt−40. `drawHand` is at `y=Math.round(c0-bh-LH(26))`, from belt−72 to belt−26. The extraction lines are `_exBan=_exBelt-LH(48)*_exR` and `_exRow=_exBelt-LH(26)*_exR`. The air strike plate is at `y=Math.round(c0-U(112))`.
- **What goes wrong:** at 1080p, any power-up running while a grenade or heal is readying, or while an extraction is called, paints its chips across the hand plate or the HOLD E TO CALL banner. The four pieces also use three different scale systems (`LH`, `hudRes` as z, and `LH*z`), so they drift apart further at 4K.
- **Fix:** give the above-belt stack one layout function (hand plate, extraction rows, power-up chips, air strike plate) that places each piece above the previous one and records it in `HUDBOX`, all in one unit (`LH(v)*hudRes()`).

---

## Tier 2: noticed within a few raids

### 8. SCREEN CLEAR instantly kills the golden enemy, the convoy carrier and the stronghold defenders (v26.89 `200e155f` party3)

- **Where:** `pwrPulse` uses `K={crawler:1,snitch:1,sentry:1,listener:1,howler:1,bulwark:1}` and skips only `e.boss||e.elite||e.downed||e.finished||e.neutral`.
- **What goes wrong:**
  - A golden crawler, sentry or bulwark (3x health, not elite) dies to one pickup and drops the hoard, credited to nobody, so there is no GOLD HUNTER trophy.
  - The convoy CARRIER is a non-elite Bulwark, so the convoy is solved in one press.
  - Both stronghold waves, except the elite crawlers, die if they are on screen.
- **Fix:** also skip `e.golden||e.carrier||e.bounty||e.shi!==undefined||e.summoned`, or limit the pulse to plain wave bodies (`e.arcWave`).

### 9. MAGNET pulls the stronghold cache through the closed fence, and breaks co-op looting (v26.89 `200e155f` party3)

- **Where:** `pwrMagnet` uses `mt={body:1,botwreck:1,cache:1}` and checks only `spotFree` and `shutRoomAt`.
- **What goes wrong:**
  - The STRONGHOLD CACHE (`mkContainer(s.x,s.y,'cache')`, which exists from t=3) is within 520 of anyone standing at the fence. It slides out through the mesh before the gate is breached, and the CONVOY CRATE comes along too.
  - In co-op, each window moves its own copy of a container. The host's `netSrchTake` then answers `why:'far'` for a box that player 2 sees at his feet, and the host's own magnet pulls boxes that never move on player 2's screen.
- **Fix:**
  - Skip containers whose tag is in `EV_WRECK_TAGS`, plus any inside a closed `shAt()`.
  - On a peer, do not move containers. On the host, broadcast the moved position (the cont word) or disable the magnet for containers in co-op.

### 10. Convoy crew and bounty hunter are deleted from the world in plain view (v26.81 `aa38e6a1`, v26.82 `c6399821`)

- **Where:** `convoyLeave` does `G.ents.splice(k,1)` for the whole crew (on arrival, and at the 170 s `end`). The bounty `end` has `k=G.ents.indexOf(e); if(k>=0) G.ents.splice(k,1);`.
- **What goes wrong:** bodies that are mid-fight, chasing you or on screen simply pop out of existence. This is very visible jank.
- **Fix:** only remove a body that is off screen, not seen and not in chase. Otherwise drop its event tags and let it stay as an ordinary enemy, and say CONVOY AWAY or BOUNTY SLIPPED AWAY only once it is removed.

### 11. Suppression counts each round many times, and one shotgun blast pins (v26.62 `7c851684` ai22)

- **Where:** in `updateBullets`, `if(en.kind==='raider'&&en.suppB!==b&&dist(b,en)<en.r+SUPP_R){ en.suppB=b; suppHit(en); }`. `SUPP_N=4`. The shotgun fires 6 pellets.
- **What goes wrong:**
  - `suppB` remembers only the last round. With two rounds in flight near a man, they alternate, and each round is counted again every frame it stays within 70 units (about 8 frames). An SMG or LMG burst pins him almost at once.
  - A single Riot Scattergun shot that passes near him (6 pellets, 4 needed) pins him for 2.6 s.
  - The comment claims "once per round per man".
- **Fix:** mark the round instead: `b.supp=b.supp||{}; if(!b.supp[en.nid||en.id]){ b.supp[...]=1; suppHit(en); }`. Count a shotgun blast as one round (`b.pel` index 0 only).

### 12. The "6 CRATES" run goal counts boxes nobody in the party opened (v26.73 `855182e2` flow3)

- **Where:** in `goalProg`, `if(C[i]&&C[i].opened) n++;` over all `G.containers`.
- **What goes wrong:** pillagers looting (`e.goal.opened=true`) and hires (`e.mgoal.opened=true`) tick the goal, and so do looted bodies and wrecks. The goal can pay its chip while the player has not searched anything.
- **Fix:** count in `openContainer` for the local player (and in the host's `netSrchTake` completion for player 2): `S.crates++`.

### 13. G is now the air strike, but the belt still advertises G as throw, and the removed U, H and J keys (v26.71 `a30c64ea` flow2, against leftovers from wheel4)

- **Where:** the belt keycap code `if(S.icon===_gSel) _cc='KeyG'; else if((S.count|0)>0){ _cc='KeyU'; _cgr=true; }`, then KeyH and KeyJ for heals. The belt hover card `beltInfoCard` still lists `'THROW CHOSEN'`, `'HEAL CHOSEN'` and `'NEXT'` with G, H, U and J.
- **What goes wrong:** the chosen grenade cell shows a G cap. Pressing G opens the air strike aim, or says AIR STRIKE 23%, instead of throwing. U and J have had no handler since wheel4. H is dead too: `holdHTick` reads `keys['KeyH']` but nothing ever arms it (`HHOLD.arm=1` appears nowhere). Even so, `KEYS_ACTS` still offers `['KeyH','heal (tap), armour plate (hold)']` in CHANGE KEYS.
- **Fix:** drop the G, U, H and J caps and the hover-card key rows for throwables and heals. Show the digit (and Q WHEEL) only. Then either remove the H row from `KEYS_ACTS` or re-arm H on purpose.

### 14. The crowbar still does 1.5x from behind on pillagers (v27.06 `ce0ce24b` nohead was incomplete)

- **Where:** in the melee branch of `fireWeapon`, `if(Math.abs(Math.atan2(Math.sin(base-_me.face),Math.cos(base-_me.face)))<0.9) _mdm*=1.5;`.
- **What goes wrong:** his answer 31 says no weak spots and consistent damage in pillager fights. v27.06 removed the back-shot bonus for rounds only; the swing still pays half again into a pillager's back.
- **Fix:** `if(_me.kind!=='raider'&&...) _mdm*=1.5;`.

### 15. Mimic in co-op (v26.77 `46bbff3d` ai27)

- **Where:** `mimicTick` runs only on the host (inside `updateEnts`, after the peer return). The host's box `prog` rises when player 2 searches (netSrch). `mimicWake` aims the crawler with `c.tx=p?p.x:x; c.ty=p?p.y:y;`, using the host player. The tick tell (`foley('pinClick',...)`) and `say('MIMIC','warn')` play only in the host window.
- **What goes wrong:** when player 2 opens a mimic, the crawler bursts out heading for player 1, wherever he is. Player 2 gets no tell and no MIMIC callout.
- **Fix:** take the searcher from `ct.netBy` (seat) and target that player's body (`NET.up[seat]`). Send a mark word (`k:'mimic'`) so the peer plays the tell within 130 of the box and says MIMIC.

### 16. Hit-stop stun-locks enemies with power-ups (v26.55 `22168faa` feel10, with v26.88 party2)

- **Where:** `var HITSTOP_DMG=40, HITSTOP_T=0.06`. `hitStopOn(en,b.dmg)` uses the round's final damage, after DOUBLE DAMAGE, the active reload bonus and so on.
- **What goes wrong:** an Auto Rifle (23 damage, 132 ms between shots) does 46 under DOUBLE DAMAGE, so every hit stops the body for 60 ms. With RAPID FIRE as well (66 ms), any non-boss body, the golden enemy and wardens included, is frozen about 90 percent of the time.
- **Fix:** test the gun's base damage (`b.baseDmg`), or give each body a cooldown, for example `if(e.stopImm>0) return; e.stopImm=0.25`.

### 17. The bounty pays on a down and on deaths nobody caused (v26.82 `c6399821` flow7)

- **Where:** the bounty `tick` has `down=!(e.hp>0)||e.downed||e.finished||G.ents.indexOf(e)<0;` then `if(e.byPlayer!==false||(e.bySeat|0)>0)`.
- **What goes wrong:**
  - DOWNED counts as claimed and ends the event, but a pillager can get up once and carries on hunting with no ring.
  - A death to a fuel fire, debris or a barrel lit by no player leaves `byPlayer` undefined, which is `!==false`, so the bounty is paid. The design says nothing is paid in that case.
- **Fix:** claim on `e.hp<=0&&(e.byPlayer===true||e.bySeat>0)` only. Keep tracking a downed hunter.

### 18. Callout pile-ups and duplicate reward lines (two systems for one event)

- **Where:**
  - At raid start: `goalsTick` says `say('RUN GOALS','obj',...)` at 1.5 s, `shTick` says `say('STRONGHOLD','info',...)` at 3 s, and `clueTick` says `say('GOLDEN ENEMY','info',{sub:'SEARCH CIRCLE ON THE MAP'})` at 4 s, on top of the existing start lines.
  - `flowChip` does `say(head,...)` and also `label(p.x,p.y-44,'+'+arcadeCr(n),...)`. `feedLabel` turns that label into a second "+$200" feed line through `feedMoney`.
  - `teamKill` calls `styMedal('TEAM COMBO x'+n,...)` and also `say('TEAM COMBO','ext',...)`.
  - A three-kill burst fires the streak `say(c,'ext',{sub:'x'+mx})` (TRIPLE KILL) and the style medal MULTI-KILL.
- **What goes wrong:** the first seconds of every raid are a stack of alerts. Rewards print twice. The streak callouts and the style medals announce the same moment.
- **Fix:**
  - Fold the raid-start lines into one RAID BRIEFING line (goals, strongholds, events).
  - Have `flowChip` call `scoreBonus` (one path), or pass `ik` to its label.
  - Pick one of TEAM COMBO medal or say, and one of the streak or MULTI-KILL (let MULTI-KILL ride on the streak line).

---

## Tier 3: noticed occasionally, or only in co-op or CAREER

### 19. The What's New card says "Power-ups are shared", which is false (v27.15 `126acd46`)

- **Where:** `'TWO PLAYER FLOW. ... Power-ups are shared.'`. `pwrS()` state is per window, and nothing sends drops or pickups over the net ("each window drops for its own kills and the pickups are its own").
- **Fix:** either share drops (host owns `G.pwr.items` and sends them in the flow word) or reword the card.

### 20. A kept RANDOM KIT or BEST KIT pick quietly rewrites the player's loadout every raid (v27.20 `69d1d2b2` kit1, v27.23 kit2, v27.28 kit3)

- **Where:** `kitPlaceGuns` contains `for(j in P.hotAssign) if(ITEMS[P.hotAssign[j]]&&ITEMS[P.hotAssign[j]].use==='gun') delete P.hotAssign[j];`, sets `P.equipped` and `P.equippedSec`, and moves stash guns into `P.weapons`. `P.kit` is replaced. The lift quick ascent has `if(kitPickOf()!=='mine') kitApply(kitPickOf());`.
- **What goes wrong:** once RANDOM or BEST is the kept pick, every ascent (including R at the lift, which shows no page) overwrites his gun keys, his equipped guns and his packing list. Switching back to MY LOADOUT later gives him the last random kit, not his own.
- **Fix:** snapshot `{kit, hotAssign, equipped, equippedSec}` into `P.kitMine` the first time a non-mine kit is applied, and restore it in `kitApply('mine')`. Do the same as the freebie's `kitSaved`.

### 21. Air strike prompts hard-code the keyboard key (v26.71 flow2; still there after v27.25)

- **Where:** `airHint()` returns `'PRESS G'`, the meter cap is `hudKey(padOn()?padB('LB+RB'):'G',...`, and the aim prompt says `'G')+' CANCEL'`.
- **What goes wrong:** after a key remap (G is in `KEYS_ACTS`), the HUD names the wrong key.
- **Fix:** use `keyLabel('KeyG','G')` in all three places.

### 22. The Overseer is an endless crawler farm in DEMO (v26.70 `d6ce37a3` ai24)

- **Where:** `if(ph>=2&&e.seenYou){ e.sumT=(e.sumT||0)-dt; if(e.sumT<=0){ e.sumT=OV_SUMMON; overseerSummon(e); } }`. Summoned crawlers score, roll power-up drops and feed the streak like any kill.
- **What goes wrong:** you can sit near a phase-2 Overseer and harvest three crawlers every 20 s for score, medals and drops.
- **Fix:** summoned bodies pay no score or power-up roll (`if(e.summoned) return 0` in `scoreKill`/`pwrKill`), or cap total summons per Overseer (for example 12).

### 23. SCREEN CLEAR by player 2 credits every machine as his kill (v26.89 party3)

- **Where:** in `pwrPulse`, `if(net) netShotSend(e,9999,...)`. The solo branch sets `e.byPlayer=false` and pays a flat medal of at most 400.
- **What goes wrong:** on a linked window each pulsed machine is a full kill for player 2: kind score, streak multiplier, style medals, power-up rolls, and air strike charge (`airCharge` caps at hp). The same pickup is worth far more for player 2 than solo.
- **Fix:** send a dedicated "pulse kill" (credit nobody) and pay the flat medal locally, matching solo.

### 24. Player 2's gun kill tally and kill trophies never count (v26.96 `b8bdb101` career1, v27.01 `37bfa1e8` career4)

- **Where:** `gunKillNote(e)` and `trophyKill(e)` are called only inside the host's `if(e.byPlayer&&!(G.player&&G.player.specOut))` death branch. `netKillTake` (player 2's credit path) calls neither.
- **What goes wrong:** in co-op CAREER, player 2's guns never gain KILLS, and GOLD HUNTER, OVERSEER DOWN and CENTURION are unreachable for him.
- **Fix:**
  - In `netKillTake`, call `trophyKill(e)`.
  - Have the peer remember the gun id of its last round on each mirror (it already sets `en.blowG` in its own `updateBullets`) and call `gunKillNote` there.

### 25. Player 2 never sees the needed-item glow (v27.00 `128761e8` career3)

- **Where:** `needHolds` contains `if(!G||!G.need||!G.needN||!ct||ct.opened||ct.net) return false;`, and peer boxes carry no loot list until they are opened.
- **Fix:** the host adds a "needed" bit per container to the cont word, worked out from player 2's contract list (sent once at raid start), or accept this as host-only and say so.

### 26. The shield affix soaks player 2's blasts but not the host's (v26.72 `a555306e` ai25)

- **Where:** `netShotTake` does `e.hp-=affixSoak(e,d)` for every word, including player 2's frag, air strike, barrel and pulse damage. The host's own blasts subtract hp directly. The design says blasts go past the shield.
- **Fix:** send a flag on blast words (`m.bl=1` from `explodeFrag`, `airBlast`, `brlBlast` and `pwrPulse`) and skip `affixSoak` when it is set.

### 27. Player 2 cannot suppress with near misses (v26.62 ai22)

- **Where:** the near-miss count lives only in the host's `updateBullets` for host rounds. `netShotTake` calls `suppHit(e)` only for rounds that hit.
- **Fix:** the peer counts its own near misses (the same per-round mark as finding 11) and sends `{t:'fl',k:'supp',id}`. Low priority.

### 28. HUD draws and flow ticks are not exception-safe

- **Where:**
  - `goldDraw`, `fireDraw`, `evDraw`, `shDraw`, `airDraw`, `pwrDraw` and `pwrDraw2` each call `c.save()` without `try{...}finally{c.restore()}`, and several set `globalCompositeOperation='lighter'` before a `createRadialGradient` call.
  - All flow ticks share one catch: `if(!G.over){ try{ flowTick(dt); }catch(_flt){} updateEnts(dt); }`.
- **What goes wrong:** a single bad value, such as a non-finite radius in a gradient call, leaves the canvas state stack unbalanced every frame, with the rest of the HUD drawn in additive mode and the stack growing. Any throw in `goalsTick` silently stops fires, events, strongholds and the golden enemy for that frame, and every frame if it repeats.
- **Fix:** wrap each draw body in `try/finally`, the way `drawAffixMark` and `feedDraw` already are, and give each tick in `flowTick` its own try.

### 29. One HUD callout is a sentence (v26.79 `635f2697` ai28)

- **Where:** `say((en.kind==='warden')?'WARDEN ARMOUR':'BULWARK SHIELD','info',{sub:(en.kind==='warden')?'Hit its back.':'Flank it.'})`.
- **Fix:** use `'HIT THE BACK'` and `'FLANK IT'`, in caps with no full stop.

### 30. Per-frame performance traps (small, but they add up at 4K)

- **Where:**
  - The scan-cone pass builds `conePoly(...,segsNear(...),14)` for every seen searcher every frame.
  - `flowMarks()` allocates its list twice per frame (minimap and sector map).
  - `evTick` runs `G.containers.indexOf(E.wrecks[i])` (about 600 containers) for every wreck every frame.
  - `shAlive` runs `G.ents.indexOf` for every defender every frame.
  - The v27.30 elite outline (`rimOpen`/`rimClose`, after this review's range) does 16 or more `drawImage` calls plus `getTransform()` per elite per frame.
- **Fix:** cache the cone polygon per body for 3 frames. Keep a single `flowMarks` result per frame. Replace the `indexOf` liveness tests with `!e.finished&&e.hp>0` or a removed flag. Bake the elite outline per sprite frame, or limit it to the 4 nearest elites.

### 31. The mimic tell is the grenade pin-pull click (v26.77 ai27)

- **Where:** `foley('pinClick',ct.x,ct.y,{g:0.22,rate:1.5})`.
- **What goes wrong:** the player cannot tell "a mimic is near" from his own or a teammate's grenade.
- **Fix:** use a distinct chitter or tick sample.

### 32. RANDOM KIT moves stash guns into the armoury for good (v27.23 `8d6f8ef3` kit2)

- **Where:** in `kitPlaceGuns`, `P.stash.splice(ix,1); P.weapons.push(g);`.
- **What goes wrong:** a gun the player kept in the stash on purpose (for example to sell, or locked with career5) is moved for good. A locked item (`P.keep`) can be picked as well.
- **Fix:** skip guns that are `stashLocked`. Restore the moves on MY LOADOUT (see finding 20).

---

## Leftovers and removal status

### 33. The LOCKDOWN raid event is still live in v27.30 (draft-nolockdown pending)

- **Where (all still present):**
  - `var EV_IDS=['debris','convoy','bounty','cool','lock','rampage'];`
  - the `EVENTS.lock=` block (with `lockSealed`, `lockKeep`, `lockCache`, `LOCK.`, `lkSide`, `berserk`)
  - `'LOCKDOWN CACHE':1` in `EV_WRECK_TAGS`
  - `evNetX` / `evNetTakeX` / `evPeerStart` / `evNetTake` (`'LOCKDOWN OVER'`) / `evPeerTick` (`lockSealed(ev)&&p`)
  - the What's New line `'... coolant fog, a lockdown, an Overseer rampage.'`
- **Status:** the draft's ten anchors cover all ten sites I found.
- **After it lands:** grep `lockSealed|LOCK\.|lkSide|berserk|LOCKDOWN` should return only comments. Removing `'lock'` from `EV_IDS` shifts the net index of `'rampage'` from 5 to 4. That is fine because both windows run the same build, but older fixture checks that stage events by index need it.

### 34. The golden clue hunt is still live in v27.30 (draft-nocluehunt pending)

- **Where:** `clueTick` / `clueDraw` / `clueMarks` / `clueNetOut` / `clueNetTake` / `clueTaken` / `cluePeerTick`, plus the `'clue'` branch of `flowNetWord`. The draft's anchors cover these.
- **Note:** finding 6 (golden glow through walls) is separate and stays after the cut.

### 35. Checked and clean

- **3-2-1 GO:** only a comment remains.
- **Tacker, Sputter, Chatter, Scuttle:** comments only. No weapon rows, and `ARCADE_GUNS2` is clean.
- **Voices, announcer, taunts, emotes:** no new speech. `annCue` is the tonal chime ladder, and `styTone`/`PWR_SND` are tones.
- **Weak spots and headshots on pillagers or players:** none for rounds (`WEAKPTS` has machines only, and the back-shot bonus excludes raiders). The crowbar is the one exception, finding 14.
- **Listeners and timers:** the haul reveal adds one `addEventListener` and one `setInterval` at load. The codex and trophy close handlers are guarded (`b._cx`, `b._tr`).
- **Per-raid state:** all new state lives on `G` (`G.flow`, `G.fd`, `G.sty`, `G.pwr`, `G.gunK`, `G.brl`) and is reset by a new raid.
- **Gradient inputs:** the new `createRadialGradient` and `arc` inputs are guarded (net words validate `r>0` and finite x/y; `netEntMake` defaults `r`).
