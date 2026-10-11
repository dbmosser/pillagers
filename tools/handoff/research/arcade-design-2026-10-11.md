# PILLAGERS: "2 PLAYER ARCADE DEMO", design (read-only, nothing edited)

File: `C:\claudecode\dark raiders\dark_raiders.html` (HEAD v23.19). Fixture helpers: `C:\claudecode\dark raiders\tools\mkfixture.ps1` (`__startRaid` 242, `__topClear` 58491, `__runPrep` 58502, `__deploy` 58615, fingerprint check 1231-1243).

Naming: the source already says "ARC" in many comments ("ARC Raiders", 3256, 14512…), so the state object is `ARCADE`, the raid flag is `G.arcade`, and the functions are `arcadeX()`.

All of his 2026-10-11 additions are folded in:
- no clock, no burn, rings never close
- the classic attract loop
- the arcade HUD
- no inventory chores, with the gun in hand never replaced
- both players on pads
- popups and streaks
- waves that come to the players
- Halloween dressing
- truly endless; the loadout is always random
- every new player-facing text in AAA caps voice

## 1. THE MODEL

### 1.0 One idea holds the design together
An arcade raid is a normal raid built through the real `startRaid()`. It then never ends.
- **No arcade change touches `buildRaid`.** Every change is a post-build hook in `startRaid`, gated on `ARCADE.on`, or a branch gated on `G.arcade`.
- **Death and extraction never reach `endRaid`'s settling code.** One guard at the top of `endRaid` sends them to arcade handlers inside the same `G`.
- **The profile is sandboxed for the whole arcade session**, in both windows.

### 1.1 Entering arcade mode
**Title MODE row.** Add `<button class="deploy ghost moderow" id="modearcade" data-mode="arcade">2 PLAYER ARCADE DEMO</button>` right after the CO-OP row (HTML 1279).
- `netTitleRows` (40717) picks it up automatically through `button[data-mode]`, so the arrows, ENTER and pad A work.
- `netTitleInit` (40701) wires `onclick → arcadePick()`. Add `modearcade` to its P2 hide list (40703).
- RETRY (40707) calls `arcadePick()` when `NET.arcPick` is set.

**`arcadePick()`.** Sets `NET.arcPick=1`, then calls `netSamePick('coop', function(){ NET.start&&NET.start(); arcadeEnter('host'); })` (40536).
- This opens the player 2 window exactly as co-op does, with BroadcastChannel pairing, `NET.role` host/join and the v15.74 handshake.
- `NET.mode` stays `'coop'`. The arcade flag travels separately, so the `coop|pvp` checks are untouched: `netModeOf` 39845, `netP2Url` 40522, `netSameOnMsg` 40676, `netSameBootP2` 40688.
- `netP2Url` (40519) appends `&arc=1`.
- A new `netArcOf(q)` is read in `netSameBootP2` (40686).
- `netModeName` (40502) returns `2 PLAYER ARCADE DEMO` while `ARCADE.on`.

**`arcadeEnter(role)`, on both windows:**
- calls `saveProfile()` once to flush, then installs the sandbox (1.12)
- installs the session CFG overlay `{raidSec:0, extractWait:15}`, keeping the old values to restore at leave
- sets `WNSEEN=1` (1722)
- sets `ARCADE.mapIx` = the real profile's `P.mapIx`, clamped (his last sector; 0 if unset)
- sets the in-memory pad picks (1.11)
- shows the arcade attract (1.9)

**The host tells player 2.** It posts `{t:'arcon'}` on entry, and again on every `'ready'` from the player 2 window (`netSameOnMsg` 40657). A rebooted player 2 window therefore always rejoins arcade.

**Player 2 on `arcon`.** It runs `arcadeEnter('p2')`. If it is mid-raid in a normal co-op raid, it replies `arcbusy` instead and the host shows `PLAYER 2 IS IN A RAID`. Because this is an in-page switch with no reload, there is no page-away risk (the 40541 / 40552 guards stay as they are).

**Arcade words.** They ride the pair BroadcastChannel (`netSamePost`, 40510). Add one line in `netSameOnMsg` after 40655: `if(m.t.indexOf('arc')===0) return arcadeOnMsg(m);`. The words are:
- `arcon` / `arcoff`
- `arcjoin`, `arcgo`, `arcnew`
- `arcsc`, `arcact`
- `arcend`
- `arcini`, `arcinis`
- `archi`, `arcleft`

Raid, entity and container traffic stays on the co-op data channel, unchanged.

**Leaving.** `arcadeLeave()` posts `arcoff`, stops any arcade raid (1.10), restores CFG and P, and puts the pad picks back (`netPadLoad` 40815). It is reached from the operator chord (Recommendation 1) or the title row path.

### 1.2 Instant drop-in from the demo video
**Host window.** Any key, click, touch or pad button drops straight into a raid via `arcadeDropIn()`. F1-F12 and the modifier keys are excluded, so F9 (record) and F11 (fullscreen) still work for the operator. There is no title, no character select and no kit question.
- **Keys.** The capture listener at 35112-35117 hands to `arcadeKeyAtt(e)` when `ARCADE.on`.
- **Pad.** The `ATT.on` branch of `pollPad` (13314-13321) reads only this window's own pad (`netPadTick`, 13232). In arcade it calls `arcadeDropIn()`, keeps its own `PAD.prev` latch and `padRelease`, and returns.
- **Mouse.** Mousemove and wheel never drop in. The mousemove listener at 35118 returns early in arcade.
- **`attTick`** (35103) starts with `if(ARCADE.on){ arcadeAttTick(); return; }`. Without this, its `!attTitleUp()` line would stop the overlay every 0.5 s. Its all-pads read would also let the other player's pad steal the window.

**Player 2 window.** Only A (button 0) on its own pad joins: `ARCADE.wantIn=1` and it posts `arcjoin`. In arcade its attract listener does not swallow keys, so `netKeyFwd` (40608) still hands them to player 1 as today.

**`arcadeDeploy(o)`.** It sets the sandbox `mapIx`/`cond`, sets `pendSeed=o.seed` when given (as `__startRaid` does), and calls `startRaid()`.

**New line in `startRaid` right after 11749:** `if(ARCADE.on&&G&&!G.sim) arcadePostBuild(G);`. It runs before `gunKeysSettle` (11751) and `netUpAnnounce` (11755), so the host fingerprint already includes it. Player 2 builds through the same `startRaid` inside `netUpStart`, so both windows apply the identical post-build. `arcadePostBuild` does this:
- sets `G.arcade=1`, keeps `raidLen`/`timeLeft` at 0, and sets `closeAt` undefined on every zone
- removes the peddler and strays from `G.ents` (deterministic, no draw)
- sets `legendOn=0` and `hotAssign=null`
- applies the random kit (1.6)
- sets the spawn shield
- adds the Halloween cosmetics (cosmetic stream only)

The rival callout (11792-11798) is skipped when `G.arcade`.

### 1.3 How both windows join a raid
**Player 2 presses A.** It posts `arcjoin`. The host's `arcadeOnMsg` then does one of three things:
- **No run is on.** The host runs `arcadeDeploy` with player 1 **benched**: `G.player.specOut=1`, frozen, and the overlay stays up saying `PLAYER 1: PRESS ANY BUTTON`. `specOut` already makes him nobody's target (`netTargetFor` 43141, `netNearDist` 43151, `netPlayersList` 43157), stops damage (15176) and credits him no kills (20369).
- **The host raid was built before the link was up** (no `NET.upWord`, because `netUpAnnounce` returns null when `!NET.on`, 41147). The host runs `arcadeRebuild()`: a fresh raid on the same map, with player 1 keeping his score and a `PLAYER 2 JOINING` banner. It posts `arcnew` first.
- **A run is on.** The host replies `{t:'arcgo',fresh:0}`.

**Player 2's side:**
- **`fresh:1`.** It waits for the raid word.
- **`fresh:0`.** It calls `netLateAsk()` (41299), retried every 1.5 s until `G.arcade`. The host answers with the existing `netLateReply` (41255), which sends the dead bodies, the fallen walls and any later bodies such as waves or the boss.
- **`netUpTake`, new block after 41321** for words with `m.arc` while `ARCADE.on`:
  - not `wantIn`: record `NET.hostSeed` and return `'arc:wait'`, staying on the attract
  - an older arcade raid in hand: `arcadeRaidStop('new')` first, so the rebuild word is never refused as "up top already" (41185)
- **`netUpStart`.** Skip `commitKit()` (41207) when `m.arc`, so the player 2 save's packed kit is never committed.
- **`netUpAnnounce`.** Add `if(g.arcade) m.arc=1;` at 41149. Only arcade words gain a field.
- **`netLateApply`** (41295) stands player 2 beside the host when the host is playing, else at a spawn. Player 2 arrives shielded.
- **Callout.** The host's `NAME IS JOINING` (41271) becomes `PLAYER 2 JOINED` in arcade.

### 1.4 Endless
- **No clock.** `raidSec:0` is in CFG during every arcade build. On the host it is the session overlay. On player 2, `netUpStart` builds from DEF plus the host's diff (41212-41213), and the diff carries `raidSec:0`. So `G.raidLen=0` (11522) and `raidClockOn()` (6251) is false. The clock, the clock warnings and the burn are all behind `raidClockOn()` (35553, 35565-35576), so none of them run. `gameOptRaidNow` (44777) needs `raidLen>0`, so no clock can be added mid-raid.
- **Rings never close.** With `_clockLen<=0`, `cl=null` gives every zone `closeAt` undefined (10650). The shuffle still makes its `ri` draws (10658-10661), so the stream count is unchanged. `tickExtractPoints` (18138) then skips every ring. A ring whose ship left is callable again (18081-18095). The map says `STAYS OPEN` (33466).
- **The world stays populated.** `tickRaiderWaves` (17755) keeps the urgent floor of pillagers. The arcade wave director (1.13) adds the action.

### 1.5 Spawn shield
- **State.** `p.arcSh=1` at every drop, respawn and re-drop.
- **Damage.** In `damagePlayer`, add `if(G&&G.player&&G.player.arcSh) return;` beside the `specOut` return at 15176. That is above the hit stamps, so there is no grunt, no hit ring and no log entry.
- **What counts as moving:**
  - movement input of magnitude above 0.25 (WASD, arrows or left stick, read at 18361-18373)
  - a dodge roll (`tryRoll` 13903)
  - a shot fired (`fireWeapon` 15520 with `fromPlayer`)
  - a throw
  - Aiming alone (mouse or right stick) and searching do not drop it, so a newcomer can wiggle the stick while reading the card.
- **How it shows:**
  - a pulsing teal bubble ring and the tag `SHIELD · MOVE TO START` under the player, drawn right after the own-player `drawOp` (26977 / 27144)
  - the controls card on the left while shielded (1.15)
  - `sh:1` added to the `st` word (41483-41485) only while shielded, filed as `g.sh` at 40395 and drawn as the same ring on the teammate in `netUpDrawOne` (41546)
  - hits on the shield spark teal

### 1.6 The random loadout (always random, never from a stash)
**What the sandbox gives `buildRaid`.** The sandbox owns exactly one gun, `weapons:['rifle'], equipped:'rifle', equippedSec:'none', kitChosen:1, dropKit:[], stash:[]`. Because of that:
- `buildRaid` never makes its player-dependent loaner draw (10522-10526)
- the build is identical in both windows
- no stash splice ever runs (11624-11630)

**`arcadeKitApply(p,g,why)` then overwrites everything, using `Math.random` only** (the `kitFill` pattern at 34353; never `rollFieldGun`, which draws `rr()` at 2276). It runs from `arcadePostBuild`, from respawn and from re-drop:
- **Guns.** In hand, one of `ARCADE_GUNS1=['rifle','carbine','smg','shotgun','lmg']`. Stowed, a different one of `ARCADE_GUNS2=['magnum','dmr','shotgun','chatter','smg','carbine']`. These are WTIER 2-4 (2153). There is never a pistol, Tacker or Bare Hands. Both are plain copies of `WEAPONS[id]` flagged as field guns (`wepIssued`, `wepFromArmory`, `secFromArmory` all false), so no armoury splice is ever possible.
- **Ammo.** A full magazine each, with `reserve = 6 × the primary magazine`.
- **Kit.** A backpack of 3 Bandages and 1 Medkit, and a pouch with 1 Frag and 1 Smoke.
- **Armour.** `armor = armorCap`, so it starts full.
- **Health.** `hp=maxhp`, with self-revive available again.
- **Belt.** `G.hotAssign={}, G.hotAuto={}`, then `gunKeysSettle({deploy:1})` (16732) and `G.hot=gunCell()`. Heals show on the derived Medical belt cell.

### 1.7 Death and respawn
**Unchanged.** Going down, bleeding out, give-up, self-revive and the teammate revive stay exactly as today. `killPlayer` (15127) still runs the 1.5 s death beat.

**New guard.** At the very top of `endRaid` (22937-22938, before `G.over` is set, so nothing settles, scores or goes out):
`if(G&&G.arcade&&!G.sim){ if(how==='dead') return arcadeRespawn('dead'); if(how==='extract') return arcadeExtracted(); if(how==='abandon') return arcadeRaidStop('quit'); }`
This one guard covers every path into `endRaid`:
- the death beat (35544)
- both extraction calls (17407, 17422)
- the timer calls (35568, 23814), which are unreachable with no clock
- the abandon confirm (44806)

**`arcadeRespawn('dead')`:**
- **Where.** Within 60-140 units of a teammate who is up and not downed. Otherwise, the map spawn (`G.map.spawns`) farthest from any live hostile, using `spotFree` (8340) and a `Math.random` tie-break. Never `freeSpot` (8346, seeded).
- **How long.** The 1.5 s death beat, then `ARCADE.holdT=3` with `DROPPING IN 3·2·1` in big text. During the hold, the loop runs `netPausedStep(dt)` (42617) instead of `updatePlayer`. Edit at 35579-35580: `if((G.paused&&netPauseLive())||(G.arcade&&ARCADE.holdT>0)) netPausedStep(dt); else updatePlayer(dt);`. That is exactly "he stands still while the world runs on". The shield lasts until he moves.
- **Kit.** A fresh random loadout (1.6).
- **What he carried.** It is gone: backpack, pouch, guns and armour are replaced. The haul pot (1.8) is lost with the callout `HAUL LOST`. The team score keeps everything.
- **Clean-up.** It also clears `deathBeat`, `dying`, `downed` and `pendKiller`, and sets the death count `ARCADE.deaths++`.

The kid rule for player 2 stays intact: `netUpEnd` and `lateBan` (41445) are never reached in arcade.

### 1.8 Combined score, extraction bonus and re-drop
**Per-window score.** Each window scores only its own player into `ARCADE.mine`, inside a run id the host owns.
- **Kill points**, from the host credit (20369-20370) and the player 2 kill word (`netKillTake` 43707):

  | Kind | Points |
  |---|---|
  | crawler | 50 |
  | snitch | 75 |
  | sentry | 100 |
  | raider | 150 |
  | listener | 200 |
  | howler | 200 |
  | bulwark | 300 |
  | warden | 400 |
  | choir (the Pillbox) | 500 |
  | the Overseer | 2000 |

  An elite counts ×2, then the streak multiplier applies (1.14).
- **Loot.** Every valuable grabbed scores its value ÷ 10 at once and also goes into `ARCADE.pot`.
- **Revive.** Reviving a teammate is +250.

**Extraction** (`arcadeExtracted`):
- **Points.** `EXTRACTION BONUS +2,500` plus `HAUL x2 +pot`; the pot is paid again. `ARCADE.ext++`.
- **Banner.** 3 s in the centre: `EXTRACTED!` with the two lines and the new `TEAM SCORE`.
- **Re-drop.** Fresh kit, a re-drop spot at least 900 from every ring, this player's pull and hold cleared from the ring, `holdT = 3 + 3`, shield on.
- **The world is not touched.** No rebuild, so the teammate's fight goes on. The teammate's window gets a small callout `PLAYER 1 EXTRACTED +3,340`.
- **Board checkpoint.** The run's board row is written now (1.10).

**Sync.** `arcsc {run,s,k,x,ev}` is posted on every change (at most 4 a second) both ways. Each window keeps `ARCADE.mate`; `team = mine + mate`. A word for another run id is ignored. A player 2 who joins mid-run starts at 0 under the host's run id.

**HUD:**
- **Top centre.** In arcade, the count-up clock (29038-29046) is replaced by a small `TEAM SCORE` label over the big number, with the streak badge `x3` beside it. Under it, small: `YOU 4,320 · P2 3,110`.
- **Extract arrow.** The existing nearest-open-ring arrow and distance (29059-29084) draw ×1.6 in arcade.
- **Haul pot.** Over the gear stack: `HAUL 640 · x2 ON EXTRACT`.

### 1.9 The attract loop
`arcadeAttTick()` reuses `ATT.el` and the overlay from `attEl` (35058). The clip source comes from `attStart` (35091): the in-browser F9 clip in IndexedDB `pillagers-attract`, else `attract.mp4` / `attract.webm`. Both windows share the IndexedDB because they are the same origin.

**It cycles:**
- **VIDEO**, 40 s
- **TONIGHT'S BEST**, 10 s: the top 10 with initials, a `BEST EVER` line, and this run's row highlighted
- **HOW TO PLAY**, 10 s: the big controls card for keyboard and pad (1.15)

With no clip, it cycles the board and HOW TO PLAY only.

**Always on screen:** the big pulsing `PRESS ANY BUTTON` (host) or `PLAYER 2: PRESS A` (player 2) in `.attpress`, plus the spooky `HAPPY HALLOWEEN` banner. While a run is live and this window is out, it adds `JOIN YOUR TEAM · TEAM SCORE 12,340`, and `LINKING…` until player 2's link is up.

### 1.10 Idle return to the demo, and the run end
**Activity tracking.**
- Each window stamps `ARCADE.ownAt` on its own keydown, mousedown, wheel, touch and mousemove over 12 px.
- Its own pad counts through `RUMBLE.usedAt`. `pollPad` already stamps that only for this window's pad (13237). It deliberately does not use `ATT.last`, which any pad pokes.
- Keys handed over from the player 2 window land on the host, so they count as player 1 activity, which is correct.
- Player 2 posts `arcact` every 2 s while active, and the host keeps `ARCADE.mateAt`.

**`arcadeIdleTick`** runs on the run authority: the host, or player 2 after a host takeover (`G.netWasJoin`, 44236). Idle is `now − max(ownAt, mateAt)`:
- **90 s:** `STILL PLAYING?` (warn lane) with the sub `PRESS ANY BUTTON`
- **120 s:** `RUN ENDS IN 30`, counting down
- **150 s** (2.5 min): the run ends

**Benching.** A player idle for 150 s while the other is playing is benched:
- **The host** gets `specOut` and the overlay with `PLAYER 1: PRESS ANY BUTTON`. Pressing un-benches him with a respawn beside player 2.
- **Player 2's raid stops:** `arcadeRaidStop('idle')` with `netUpEnd('abandon')`, which never sets `lateBan`. It posts `arcleft`, the host says `PLAYER 2 OUT` in place of the line at 41383, and player 2's attract returns.

**Run end** (`arcadeRunEnd`), from idle or END RUN:
1. The host posts `arcend` first, and player 2 tears down silently.
2. The host runs `arcadeRaidStop()`. This mirrors the instant-quit teardown (23021-23053) without any of its P writes: `togglePauseBox(false)`, `ambienceOff`, `recStop`, `netUpEnd('abandon')` when linked, `G=null`, `keys={}`, `showScreen('hub')`. There is no outcome card and no `endRaid` settling. `netHostGone` with no G is a no-op (44230).
3. The RUN OVER card shows: team score, a P1/P2 row each with score, kills, extractions and deaths in the `netScoreDraw` row style (41421), then initials if they qualify (1.11), then the attract board page.

**END RUN.** In arcade the pause box (HTML 862-874) hides `Settings` (`#pausesetbtn` 870) and `Abandon run` (`#abandonbtn` 874), and shows `END RUN`. The abandon confirm (44785) is guarded too: no XP fee (44794-44799).

### 1.11 Party scoreboard, initials and pads
**Storage.** Its own key, `localStorage['pillagers:arcade:board']` = `{v:1, rows:[{run,i,s,x,k,t}]}`, keeping 100 rows.
- **Single writer.** Only the run authority writes, so there are no races. Player 2 reads it on each board page.
- **Tonight** is rows from the last 12 hours, top 10. **BEST EVER** is the overall maximum.
- **Writes.** The live run's row is written at every extraction (same run id, updated in place) and finalised at run end. A host crash or reload therefore keeps the score.

**Initials.**
- **When.** At run end, if the run makes tonight's top 10 and has no initials yet.
- **Card.** Three letters.
  - **Pad:** D-pad or stick up/down changes the letter, right or A goes to the next, left or B goes back, MENU finishes.
  - **Keyboard:** letters, Backspace, Enter.
- **Timeout.** 20 s keeps what is there, or `???` if untouched.
- **Both windows.** The card shows on both. Player 2's pad sends `arcini {op}`, the host applies it and broadcasts `arcinis`. The arcade pad handler sits in `pollPad` before `padMenu` (13322).

**NEW HIGH SCORE.** Said once per run, on both windows (`archi`), when the team passes tonight's best.

**Pads.** "Controller 1 is player 1, controller 2 is player 2."
- `arcadeEnter` sets `NET.padIx=0` (host) or `1` (player 2) **in memory** and calls `netPadPost()` (40821).
- It deliberately skips `netPadSet` (40822), which writes `salvagerun:samepad:*`. `netPadLoad` puts his kept picks back at leave.
- `netPadFor` (40779) already honours picks, so player 1 plays fully on a pad and the keyboard and mouse still drive player 1.

### 1.12 Profile isolation: exactly what is skipped, and how
1. **`saveProfile`** (3040) returns at once while `ARCADE.on`, beside the `NET.upHold` test. This covers every in-raid P write reaching storage: the kit block's `saveProfile` (11648), `fogSave` (24255), kills and grudges (20380, 43712), notoriety (43719), wear, contracts, `raidSpliced` (16266), `noteCrash`, and the `netUpStart` saves (41231, 41242).
2. **`storeSet`** (2627) refuses while `ARCADE.on`. That catches the direct writers that bypass `saveProfile` (restore and UNDO at 46469 / 46483), and Settings is hidden besides. The `:prerestore` writes (46468, 46482, 47097) are only on Settings paths, which are unreachable in arcade.
3. **The P in memory is a sandbox.**
   - `arcadeSandboxIn`: `ARCADE.realJs = netUpSnapP()` (41190), then `netUpPutP(sandboxJs)` (41192) installs it in place, since every closure holds P.
   - The sandbox is a copy of his P with these overrides: the one-gun loadout above; `kit:[]`, `hotAssign:null`, `merc:null`, `mercOut:null`, `intel:0`, `terms:[]`, `contracts:[]`, `gunPiled:[]`, `raidSpliced:[]`, `notoriety:0`, `runs:0`; `autoloot:1`; `keymap:{}` (default keys for walk-ups); `pname` `PLAYER 1` or `PLAYER 2`; `mapIx`; `cond`; `crashes:[]`.
   - His HUD layout and the player 2 save's kid mode settings (`kidDmg`, `kidBack`) are kept.
   - `arcadeSandboxOut` restores CFG, runs `netUpPutP(ARCADE.realJs)`, clears `ARCADE.on`, merges any new sandbox crash entries into `P.crashes`, and calls `saveProfile()`.
   - Disk was never touched in between. A tab closed mid-arcade leaves the pre-arcade save.
4. **`endRaid`** never settles an arcade raid (guard in 1.7). So: no `P.runs++` (23056), no XP, credits, Mainframe pay or merc settling, no run log or `pendingRun`, no flight-recorder download (44808), no outcome card, no `netScoreSend` (22940) and no out word (22941).
5. **The abandon XP fee** (44794-44799) is skipped in arcade.
6. **No `commitKit`** in player 2's `netUpStart` (41207), and **no pad-pick writes** (1.11).
7. **The only new storage** is the board key. The player 2 window applies the same rules to its own player 2 save.

### 1.13 Action comes to you (waves)
`arcadeWaveTick(dt)` runs only on the host or solo. It is called in the raid branch after `updateEnts` (35582), never when `netEntsPeer()` (41636).
- **Tier.** `tier = min(8, floor(team/4000))`.
- **Timing and cap.** Every `max(10, 22 − 2·tier)` s, while the live hostiles within 1400 of the playing players number fewer than `min(24, 6 + 2·tier)`.
- **Pack size.** `min(6, 2 + floor(tier/2))`.
- **Placement.** At 750-1100 from a random playing player. The ring is sampled with `Math.random` and checked with `spotFree` (8340), `navReachable` (5988) and `!shutRoomAt` (5981).
- **Behaviour.** The pack is set `alert=3, state='investigate', tx/ty` at the player ±60, like the siege at 17936-17938, and flagged `arcWave=1`.
- **Mix.** Crawlers; sentries from tier 1; hostile raiders from tier 2; elites from tier 4.
- **Callout.** `WAVE n` in the warn lane.
- **Player 2.** The new bodies reach the player 2 window through `netEntsTick` (41490), like any body that arrives after the build.
- **Seeded draws.** The `mk*` constructors draw the seeded stream (`rnd` at 9426 / 9442), but only on the host and only inside arcade raids.

### 1.14 Popups and streaks
- **Popups.** Every score event puts `label(x,y,'+150',…)` (15055) at the body or item.
- **Streak.** Kills less than 4 s apart chain into a multiplier:

  | Chain | Multiplier | Callout (ext lane) |
  |---|---|---|
  | 2 | x2 | `DOUBLE KILL` |
  | 3-4 | x3 | `TRIPLE KILL`, `MULTI KILL` |
  | 5-7 | x4 | `RAMPAGE` |
  | 8+ | x5 | `UNSTOPPABLE` |

- **Badge.** The multiplier shows beside TEAM SCORE.
- **NEW HIGH SCORE** is covered in 1.11.

### 1.15 Newcomer settings, inventory and the controls card
**Softer enemies.** In `damagePlayer` after 15154: `if(G&&G.arcade) amt*=ARCADE_DMG;` with 0.5, on both windows. On player 2 it stacks with kid mode, and `KID_MIN` (42320) still floors it.

**More ammo and heals:**
- 6 magazines at every drop
- each kill refunds half a magazine
- every 3rd kill adds a Bandage, up to 5 heals carried
- full armour at every drop
- the session overlay sets `extractWait 15`

**Walk-over loot:**
- **Auto-search.** At 19127, `G.arcade && near && near.loot.length` searches with no key.
- **Fast.** Progress ×6 at 19152 and in the host's `netSrchTick` (44024), so a box held through the host is fast too.
- **Valuables** (items with no use) never enter the backpack. They become points plus pot, with a `+N` tag on their pickup row (`grantLoot` 16425 and the pickup row at 16448).
- **Usable items.** Ammo, heals (onto the belt via `autoBelt`), throws, plates and keys go where they go today.

**Gun upgrades.** In the `grantLoot` gun branch (16291-16423), when `G.arcade`:
- `p.wep` is never touched, and the `_handFree` branch (16368) is skipped.
- A gun with a higher tier than the stowed gun takes the stowed slot. The old stowed gun goes to the backpack on a free gun key. Tag `STOWED`.
- Otherwise, a gun better than the worst one carried goes to the backpack on key 3 or 4 via `gunKeysSettle({deploy:1})` (16751-16765). Tag `KEY 3`.
- Otherwise it is scrapped for points. Tag `SCRAPPED`.

**Hidden in arcade:**
- CONDITIONS (the block from 29146 / 29149 to about 29360)
- CURRENT PILLAGERS (30563-30569)
- the notoriety stamp (29748-29775)
- contracts (the sandbox has none)
- the `WANTS REVENGE` callouts (20381, 43713) and the rival callout (11795)
- the peddler and strays (removed at post-build)

**Controls card.** `arcadeCardRows()` gives KEYBOARD and CONTROLLER columns:

| Action | Keyboard | Controller |
|---|---|---|
| MOVE | WASD | L STICK |
| AIM | MOUSE | R STICK |
| FIRE | LEFT CLICK | RT |
| ROLL | SPACE | A |
| RELOAD | R | X |
| SWITCH GUN | 1-4 | LB / RB |
| HEAL | + ON THE BELT, THEN FIRE | + ON THE BELT, THEN FIRE |
| EXTRACT | HOLD E IN A TEAL RING | HOLD X IN A TEAL RING |

- The names come from `keyLabel` / `keysOf` (KEYS_ACTS 13620) and `LEGEND_PAD` (30709), with PlayStation names through `padB` (12921).
- It is drawn big at the left at every drop, while shielded and for 4 s after.
- The HOW TO PLAY attract page uses the same rows.

### 1.16 Halloween dressing
`arcadeHallow(g)` runs in `arcadePostBuild`. It is cosmetic only and uses only the `fxr` stream (5274):
- `G.lights[i].c` is set to orange tones with a little more intensity. These are the lamp passes at 26405, 27470 and 27558; the darkness cut is colourless, so the sight rules are unchanged.
- Pumpkins go into `G.arcPumps`, near lamps and doors, checked with `spotFree`, and are drawn after the decals (26141).
- A slow violet haze is drawn after the fog sheets, beside the weather fog draw (about 27786). Sight is not touched.
- The `HAPPY HALLOWEEN` banner appears on the attract.
- `P.cond` is set to `night` (tunable).

## 2. EVERY CODE SITE THAT CHANGES (line numbers at v23.19)

**Profile and storage**
- `storeSet` 2627; `saveProfile` 3040
- `WNSEEN` 1722 / gate 34894; `WHATSNEW` 1723: one ARCADE DEMO entry at the top

**Title and mode row**
- Title HTML 1276-1286: the new row
- `netModeOf` 39845; new `netArcOf`; `netModeName` 40502
- `netP2Url` 40519-40523; `netSamePick` 40536-40571 (called from `arcadePick`; RETRY 40707)
- `netSameOnMsg` 40638-40683 (arcade words after 40655; `arcon` on ready 40657)
- `netSameBootP2` 40686-40697
- `netTitleInit` 40701-40715
- `netKeyFwd` 40608-40626: unchanged, but relied on

**Attract and pad input**
- `attTick` 35103-35111; capture listeners 35112-35118; `attEl` / `attShow` 35058-35081
- `recDraw` title stop 35150 → arcade teardown calls `recStop`
- `pollPad` 13314-13321 (arcade attract and drop-in), plus the arcade card/initials pad handler before `padMenu` 13322
- `netPadPost` / `netPadLoad` 40815-40830: reused, not changed

**Raid start and the post-build hook**
- `startRaid` 11716-11799: hook after 11749; rival callout 11792-11798
- `buildRaid`: **no change** (relied on: 10515-10526, 10643-10661, 11522, 11621-11705)

**Main loop**
- 35507: `arcadeTick(dt)`, which runs `holdT`, banner, idle, scoring sync and waves (host)
- 35544: through the `endRaid` guard
- 35579-35580: `netPausedStep` during `holdT`
- 35582: `arcadeWaveTick` after `updateEnts`

**Death, damage and extraction**
- `endRaid` 22937-22938: the guard
- `confirmabandon` 44785-44807; pause HTML 862-874; `togglePauseBox` 13739
- `damagePlayer` 15154 (arcade multiplier), 15176 (shield)
- `tryRoll` 13903, `fireWeapon` 15520, the throw start, `updatePlayer` 18361-18373: shield off

**Loot and guns**
- Search 19127, 19152; `netSrchTick` 44024
- `grantLoot` 16291-16425, pickup tags 16448

**Kills and score**
- 20369-20383 (score, no REVENGE callout in arcade)
- `netKillTake` 43707-43713

**HUD**
- `drawHUD`: clock 29038-29046, compass 29075-29084, CONDITIONS 29146 to about 29360, notoriety 29748-29775, board 30563-30569, arcade layer before 30597 (score, countdown, banner, card)

**World drawing**
- `render2D`: 26141 (pumpkins), after 26977 / 27144 (shield ring), about 27786 (haze)

**Co-op and net**
- `st` word 41483-41485 (`sh`), `netOnState` 40395 (`g.sh`), `netUpDrawOne` 41546
- `netUpAnnounce` 41149 (`arc`)
- `netUpStart` 41207 (no `commitKit`)
- `netUpTake` after 41321 (arcade gating, stop the old raid)
- `netLateReply` 41271 (callout), `netLateApply` 41295 (spot)
- `netUpWord` 41383 (`PLAYER 2 OUT`)
- `netUpEnd` 41442 (reused for silent teardown)

**New code:** one arcade section placed after the net section (after about 44260). It holds `ARCADE`, `arcadePick`, `arcadeEnter` / `arcadeLeave`, `arcadeSandboxIn` / `arcadeSandboxOut`, `arcadeDeploy`, `arcadePostBuild`, `arcadeKitApply`, `arcadeRespawn`, `arcadeExtracted`, `arcadeRaidStop`, `arcadeRebuild`, `arcadeOnMsg`, `arcadeScore` / `arcadeKill`, `arcadeTick`, `arcadeIdleTick`, `arcadeWaveTick`, `arcadeAttTick`, `arcadeBoardPut` / `arcadeBoardTonight`, `arcadeIni*`, `arcadeCardRows`, `arcadeHallow` and `arcadeHud`.

**Fixture:** `__topClear` (mkfixture 58491) should call `arcadeLeave()` when `ARCADE.on`.

## 3. THE BUILDS, IN ORDER

Every check:
- runs in game scope after `__topClear(); __runPrep();`
- ends with `arcadeLeave()` in a `finally`
- fails on the previous build because the function or behaviour is missing

A two-player arcade raid is playable after **arcade6**.

1. **arcade1, SANDBOX.** `ARCADE`, `arcadeSandboxIn` / `Out`, and the `saveProfile` (3040) and `storeSet` (2627) gates. *Check:* note `localStorage.getItem(SKEY)`, `P.credits` and `P.stash`. Then `arcadeSandboxIn(); P.credits=987654; P.stash=['scrap']; saveProfile(); storeSet('{}');`. Storage must equal the noted copy. After `arcadeSandboxOut()`, `P.credits` and `P.stash` must equal the noted values.

2. **arcade2, ENDLESS ARCADE RAID (solo).** `arcadeDeploy`, the session CFG overlay, the `startRaid` hook after 11749, `arcadePostBuild` and `arcadeKitApply`. *Check:* `arcadeDeploy({mapIx:0,seed:4242})` gives:
   - `G.arcade===1`, `G.raidLen===0` and `!raidClockOn()`
   - every zone has `closeAt===undefined`
   - `wep.id` is in `ARCADE_GUNS1`, and `sec.id` is a different gun
   - no peddler
   - after 600 `__loop` frames, `!G.over && !G.nuking`

   Then `arcadeLeave(); __deploy({kit:[],safe:null,mapIx:0,seed:4242})` must still give 85 ents and `raidLen` 540.

3. **arcade3, DEATH RESPAWNS (and quit leaves cleanly).** The `endRaid` guard (22938), `arcadeRespawn`, `holdT` through `netPausedStep` (35579), `arcadeRaidStop` for abandon, and the 44785 fee skip. *Check:* `arcadeDeploy`; keep `g=__state()` and `runs0=P.runs`; `killPlayer('t')`; 150 `__loop` frames. Then: `__state()===g`, `!g.over`, `hp===maxhp`, `deathBeat==null`, `ARCADE.deaths===1`, `P.runs===runs0`, and `#outcome` is not on.

4. **arcade4, EXTRACTION BONUS, BANNER AND RE-DROP.** `arcadeExtracted` and the banner draw. *Check:* `arcadeDeploy; ARCADE.pot=300; __endRaid('extract');`. Then: `!G.over`, `ARCADE.mine>=2800`, `ARCADE.banner` is set, the player is at least 700 from every ring, and `P.runs` is unchanged.

5. **arcade5, THE MODE ROW AND BOTH WINDOWS IN ARCADE.** The row, `arcadePick`, `&arc=1`, `arcon`, `arcadeEnter('p2')`, the `attTick` / `pollPad` / listener branches, and host instant drop-in. *Check:*
   - Set up a stand-in channel: `NET.bc={postMessage:m=>out.push(m),close(){}}`, `NET.same='host'`, `NET.pair='tp'`.
   - `arcadeEnter('host')`, then `netSameOnMsg({t:'ready',pair:'tp'})`. `out` must contain an `arcon`.
   - With `NET.arcPick=1`, `netP2Url('coop','tp')` must contain `&arc=1`.
   - `#modearcade` must be in `netTitleRows()`.
   - A synthetic mousemove leaves `G` null. A synthetic keydown gives `G.arcade===1`.
   - Then `netSameStop()`.

6. **arcade6, PLAYER 2 DROPS IN WITH A.** `arcjoin` / `arcgo` / `arcnew`, the `netUpTake` gate, no `commitKit`, `m.arc`, `netLateApply` spot, host bench, `arcadeRebuild`. *Check:*
   - Host half: `arcadeDeploy({mapIx:0,seed:4242})`. Build the raid word by hand: `{t:'raid',seed:4242,mapIx:0,cond:P.cond,wx:G.wx.id,iss:G.issDraw?1:0,terms:[],merc:'',cfg:netUpCfgDiff(),fp:netUpFp(G),arc:1}`. Then `arcadeRaidStop()`.
   - Guest half: set `NET.role='join'`, a stand-in peer `{state:'in',seat:0}`, `ARCADE.role='p2'`.
   - With `wantIn=0`: `netUpTake(peer,m)==='arc:wait'` and `!G`.
   - With `wantIn=1`: it returns `'up'`, `G.arcade===1` and `netUpFpSame(netUpFp(G),m.fp)`.
   - Restore the NET fields.

7. **arcade7, BOTH PLAYERS ON PADS.** In-memory picks host 0 / player 2 1, and the arcade pad handlers. *Check:* note `localStorage.getItem(netPadKey('host'))`. With two connected stand-in pads after `arcadeEnter('host')`, `netPadFor('host',NET.padIx,1,gps,null)===0` and `netPadFor('p2',1,0,gps,null)===1`. The kept pick key is unchanged, and after `arcadeLeave` `NET.padIx` equals `netPadLoad()`.

8. **arcade8, COMBINED TEAM SCORE.** Kill and loot scoring (20369, 43707), `arcsc`, and the TEAM SCORE HUD in place of the clock. *Check:* `arcadeDeploy`; push a `mkCrawler` 300 away with `byPlayer=1, hp=0`; `__ents(0.016)` gives `ARCADE.mine===50`. Then `arcadeOnMsg({t:'arcsc',run:ARCADE.run.id,s:400})` gives `arcadeTeam()===450`. A `drawHUD` text trace shows `TEAM SCORE` and `450`.

9. **arcade9, SPAWN SHIELD.** `arcSh`, the `damagePlayer` return (15176), the clears, the ring and tag, and `sh` / `g.sh`. *Check:*
   - `arcadeDeploy`; `damagePlayer(40,'sentry','T')` leaves hp unchanged.
   - `keys.KeyD=true; __sim(0.1); keys.KeyD=false;` gives `arcSh===0`.
   - `damagePlayer(40,…)` now lowers hp.

10. **arcade10, EASIER FOR NEWCOMERS.** `ARCADE_DMG` (after 15154), kill refunds, heal every 3rd kill, full armour. *Check:*
    - `arcadeDeploy`, `arcadeShieldOff()`, `p.armor=0`; `damagePlayer(20,…)` takes exactly `20*CFG.eDmg*0.5`.
    - One credited kill raises `reserve` by `ceil(mag/2)`.

11. **arcade11, WALK-OVER LOOT.** Auto-search (19127), ×6 (19152, 44024), valuables to score and pot (16425). *Check:* `arcadeDeploy`, shield off, a `mkContainer` 20 units away with `loot ['scrap','bandage']`, 40 `__loop` frames with no keys. Then: `ct.opened`, no `scrap` in `G.bag`, one more `bandage` in `G.bag`, and `ARCADE.pot>0`.

12. **arcade12, AN UPGRADE NEVER REPLACES THE GUN IN HAND.** The `grantLoot` gun branch (16291-16423). *Check:* set `p.wep` to a `chatter` copy and `p.sec` to an `smg` copy; `grantLoot({x:p.x,y:p.y,loot:[]},['gun_lance'])`. Then: `p.wep.id==='chatter'`, `p.sec.id==='lance'`, `'gun_smg'` is in `G.bag`, and a `G.hotAssign` key 2 or 3 holds `'gun_smg'`.

13. **arcade13, ARCADE HUD.** Hide CONDITIONS, the board, notoriety and the REVENGE/RIVAL lines; bigger EXTRACT arrow; `DROPPING IN n`. *Check:* in a `drawHUD` text trace there is no `CONDITIONS`, no `CURRENT PILLAGERS`, and `EXTRACT` is present. With `ARCADE.holdT=2`, `DROPPING IN` is present.

14. **arcade14, ACTION COMES TO YOU.** `arcadeWaveTick`. *Check:* `arcadeDeploy; ARCADE.mine=8000; ARCADE.waveT=999; n0=G.ents.length; arcadeWaveTick(0.05)` adds at least 2 ents, each with `arcWave`, 700-1200 from the player, `state 'investigate'`. A plain `__deploy` plus 30 s of `__sim` has no `arcWave` ents.

15. **arcade15, POPUPS AND STREAKS.** `arcadeKill`, the multiplier, `label`, the callouts. *Check:* two crawler kills 0.5 s apart give `ARCADE.streak.n===2`, the second award is 100, `G.labels` has `'+100'`, and the alert lane holds `DOUBLE KILL`.

16. **arcade16, IDLE RETURN AND END RUN.** Activity stamps, `arcact`, 90 / 120 / 150 s, benching, `arcend`, `arcadeRaidStop`, the RUN OVER card, the pause box END RUN. *Check:* `arcadeDeploy; ARCADE.ownAt=Date.now()-151000; ARCADE.mateAt=0; arcadeIdleTick(Date.now());`. Then: `!G`, `ARCADE.on`, the attract overlay is shown, `P.runs` is unchanged and the outcome card is off.

17. **arcade17, THE ATTRACT LOOP.** VIDEO → BOARD → HOW TO PLAY, `PRESS ANY BUTTON` / `PLAYER 2: PRESS A`, live team strip. *Check:* `arcadeEnter('host'); arcadeAttStart();`. Stepping `ARCADE.att.t` past 40, then +10, then +10 walks the phases (with no clip: board, then howto, then board). `.attpress` reads `PRESS ANY BUTTON`. Mousemove starts no raid; keydown does.

18. **arcade18, PARTY SCOREBOARD AND INITIALS, NEW HIGH SCORE.** *Check:*
    - Clear the board key. Put three rows: `{run:'a',s:500}`, `{run:'b',s:900}`, `{run:'a',s:1200,i:'AAA'}`. `arcadeBoardTonight()` gives 2 rows, the first with `s 1200`.
    - `arcadeIniStart(); arcadeIniOp('up')` gives letter `B`; `next` / `done` write the initials.
    - `SKEY` storage is unchanged.
    - Restore the board key.

19. **arcade19, THE CONTROLS CARD.** `arcadeCardRows` on spawn and on the HOW TO PLAY page. *Check:* 8 rows, each with a keyboard and a pad label. A text trace shows `MOVE` while `arcSh`, and does not after shield off plus 5 s of frames.

20. **arcade20, HALLOWEEN DRESSING.** `arcadeHallow`. *Check:* after `arcadeDeploy({seed:4242})`, `r0=RNGS; arcadeHallow(G)` leaves `RNGS===r0`. `G.arcPumps.length>0` and every light colour is in the orange set. A plain `__deploy` has no `arcPumps` and its lights are unchanged.

## 4. RISKS AND HOW THE DESIGN AVOIDS THEM

- **The seeded sim and its fingerprint** (ents 85/374, containers 165/593 at seed 4242).
  - `buildRaid` is untouched. Every arcade change is either post-build behind `ARCADE.on` / `G.arcade`, or cosmetic on the `fxr` stream.
  - The kit uses `Math.random`, never `rollFieldGun` or `pick`.
  - `runSim` (23829) calls `buildRaid(true)` directly and can never reach the hook.
  - The CFG overlay exists only while arcade is on.
  - Builds 2 and 20 re-assert 85 ents on a plain deploy.
- **Normal raids must be byte-for-byte unchanged.**
  - New fields go on net words only in arcade (`m.arc` only when `g.arcade`; `sh` only while shielded).
  - Every new line in a shared function is an early `G.arcade` or `ARCADE.on` branch.
  - Remaining risk: the title gains one row and the pause box a hidden button. Any existing check that counts mode rows or pause buttons needs updating.
- **A check leaving arcade on would poison the corpus** (every later save gated). Each arcade check uses `arcadeLeave()` in `finally`, and `__topClear` force-leaves arcade.
- **Coming back empty, and issued kit.** These rules live in `endRaid`'s settling code, which arcade never runs. Arcade guns are field guns with `wepFromArmory` false, so no armoury splice is possible even in memory. Normal deaths are untouched.
- **Co-op rulings.**
  - No team damage: arcade adds no player-vs-player damage path.
  - The remaining player picks up the raid: `netHostGone` (44229) is untouched. Player 2 keeps `ARCADE` and becomes the idle and board authority.
  - Kid comeback: `lateBan` (41445) and `lateOut` (41384) are only set by dead/extract out words, which arcade never sends. The player 2 idle exit sends `'abandon'`.
- **Player 2 pulled up without pressing A.** `netUpTake` returns `arc:wait` unless `wantIn`.
- **A raid word refused because player 2 is "up top already"** (41185). Arcade stops the old arcade raid first.
- **A raid word refused because the fingerprint mismatched.** Both windows run the same post-build. A non-arcade player 2 fails safely through the existing mismatch path (41226-41237).
- **Teardown without `endRaid` leaving state behind.** `arcadeRaidStop` mirrors the instant-quit branch (ambience, pause box, `G=null`, `keys={}`, hub) plus `netUpEnd` and `recStop`.
- **An endless page running for hours** (containers from bodies, labels, decals). Decals and logs are capped already. Waves are capped. A soak is recommended (Recommendation 5).
- **The pad rule.** "One pad goes to player 1" in arcade differs from his v16.35 rule (player 2 takes the first pad). It applies only through in-memory picks while arcade is on.
- **Open choices for him:** the night setting, the score values, and `???` rows on idle-out.

## 5. RECOMMENDATIONS (OPTIONAL, not asked for)

1. OPTIONAL: OPERATOR LOCK. LEAVE ARCADE only from a keyboard chord (Ctrl+Shift+F10), so guests pressing MENU can only RESUME or END RUN.
2. OPTIONAL: Ask for initials on the first extraction banner once the run makes tonight's top 10, so teams that walk away still get their names on the board.
3. OPTIONAL: A one-button QUICK HEAL in arcade (D-DOWN while standing, G on keys) using `findHeal` (16161) and `startPrep` (15984). Belt-then-fire is the control newcomers will miss.
4. OPTIONAL: A screen wake lock (`navigator.wakeLock`) while arcade is on, so neither monitor sleeps during the attract loop.
5. OPTIONAL: A 3-hour fixture soak of an arcade raid (the `fixture-soak` pattern) that watches `G.containers`, `G.labels`, ents and the frame time before the party.

### Critical Files for Implementation
- C:\claudecode\dark raiders\dark_raiders.html (startRaid 11716, endRaid 22937, loop 35453-35620, net section 40485-44260, attract 35041-35119, drawHUD 28760-30598)
- C:\claudecode\dark raiders\tools\mkfixture.ps1 (__startRaid 242, __topClear 58491, __runPrep 58502, __deploy 58615, fingerprint check 1231)

## 6. HIS YES TO ALL FIVE RECOMMENDATIONS (2026-10-11): four more builds and a soak
21. **arcade21, OPERATOR LOCK.** LEAVE ARCADE is reached only from a keyboard chord (Ctrl+Shift+F10). In arcade the pause menu shows only RESUME and END RUN, so a guest pressing MENU or ESC cannot leave the mode or reach Settings, the stash or the Mainframe. *Check:* in arcade, a synthetic Escape plus a click on every visible pause button never clears ARCADE.on. The chord does clear it.
22. **arcade22, INITIALS AT THE FIRST QUALIFYING EXTRACTION.** When a run first makes tonight's top 10 at an extraction, the EXTRACTED banner offers the 3-initials card, on the pad or the keyboard. The run's board row then keeps those initials, so a team that walks away still gets its name on the board. *Check:* stage a board, extract over its 10th score, and see that arcadeIniStart ran. After arcadeIniOp ops the row carries the initials.
23. **arcade23, ONE-BUTTON QUICK HEAL in arcade.** D-pad DOWN on the pad and G on the keyboard use the best heal carried (findHeal and startPrep, with the same rules as useMedical, including the Bandage-to-85 cap of healCeil). It is shown on the controls card. *Check:* in arcade with a Bandage carried and hp 40, the quick-heal input starts the heal prep. Outside arcade, G does what it did before.
24. **arcade24, SCREEN WAKE LOCK.** navigator.wakeLock.request('screen') while ARCADE.on, on both windows, re-requested on visibilitychange and released at leave. Wrap it in try/catch, because the API is missing or refused in some contexts. *Check:* with a stubbed navigator.wakeLock, entering arcade requests it once and leaving releases it.
- **SOAK BEFORE THE PARTY:** a 3-hour arcade raid soak (the fixture-soak pattern) that watches G.containers, G.labels, the ents and the frame time, run after arcade20.
25. **arcade25, VALUABLES IGNORE A FULL BACKPACK** (a low finding of the arcade 7-13 review). Walk-over loot is refused with BACKPACK FULL even for valuables, which in arcade never enter the backpack (they turn into score and pot). In arcade the full test must count only items that actually go into the bag. *Check:* in arcade with a full G.bag, walking over a container that holds only valuables opens it, scores it and leaves no BACKPACK FULL line.
26. **arcade26, RUN END ALWAYS REACHES PLAYER 2** (low finding of the 14-25 review). Ending the run on the host can leave player 2 playing on alone, because of a timing race between the pair BroadcastChannel word (arcend) and the co-op data channel teardown (netUpEnd). Player 2 must stop its arcade raid on whichever word arrives first, and the host must repeat arcend until player 2 acknowledges it (arcendok) or 3 s pass. *Check:* stage player 2 in an arcade raid and deliver only the netUpEnd path, or only arcend: in both cases player 2 ends on its attract.
27. **arcade27, THE HOST INITIALS CARD STAYS ON THE HOST** (low). The host's in-raid initials card (arcade22) is mirrored to player 2's attract and takes over its A button, so player 2 cannot join while the host types. Mirror the card to player 2 only at RUN OVER (arcade18), never during a live raid. *Check:* host extraction initials do not post arcini to a player 2 that is on its attract, and player 2's A still sends arcjoin.
28. **arcade28, WAVES FOLLOW THE RAID OWNER** (low). After player 2 takes over a raid whose host left (G.netWasJoin), arcadeWaveTick never runs again, because it returns on the p2 role. The run authority, meaning the host or the player 2 that took over, runs the waves. *Check:* with ARCADE.role p2 and G.netWasJoin set and no live peer, a wave tick past its timer adds an arcWave pack.
