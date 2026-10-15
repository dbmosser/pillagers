# EXPERIMENTAL SETTINGS: THE IMPLEMENTATION MAP (2026-10-15)

His order (2026-10-14 night): "create an experimental settings menu inside settings where I can turn new features on and off".
He also said the gun feel builds "felt pretty good" and need no switch.

Read-only research. Nothing in dark_raiders.html or tools/ was changed. Line numbers are from commit c2d37e64 (v27.27).
HEAD moved to 0470f90f (v27.30) while this was written, so every anchor below is also a grep-able quote: grep the quote, not the number.

## 0. Bottom line

- 30 switches. 28 come from the list in the order (the five raid events counted one by one), and 2 more were found in git log:
  the GOLDEN CLUE HUNT (v26.94, its own yes to suggestion 3) and AIM LANES (v26.58, the attack telegraphs, suggestion 20).
  A 31st row, EVENT LOCKDOWN ALARM, exists only while EVENTS.lock is still in the file (it is being taken out; it was still there at v27.30).
- Every switch has one or two choke points. Almost all are "return early in the one function that starts the feature";
  the rest of the feature then never has data to draw, tick or send.
- No switch moves the seed 4242 build fingerprint (ents 85/374, containers 165/593), on or off. Nothing since v26.54 draws from the
  build stream: the new features use side streams (sideStream), the cosmetic stream (fxBorrow, fxr, fxn), hashes or Math.random,
  and everything they add to the world is added after buildRaid returns (barrels go in G.brl, not in ents or containers).
- Two player: the switches go in DEF, so the host's OFF values already ride in the raid word (netUpCfgDiff -> m.cfg -> netUpStart),
  and a snapshot taken at the top of startRaid (XF) holds them for the whole raid on both windows. The host rules with no new net word.
- DEMO and CAREER: no switch reads G.arcade or G.career. The same switch does the same thing in both modes.
- The three riskiest to switch off: AIR STRIKE, FUEL FIRES, RAID DIRECTOR (section 5).

## 1. The list, confirmed against git log b4c1b743..c2d37e64 and the code

| # | Row label | Flag | Scope | Builds | In the order's list |
|---|---|---|---|---|---|
| 1 | RAID DIRECTOR | xfDir | WORLD | v26.69 | yes |
| 2 | AIR STRIKE | xfAir | WORLD | v26.71, v26.74, v27.19, v27.25 | yes |
| 3 | RUN GOALS | xfGoals | WORLD | v26.73, v27.27 | yes |
| 4 | FUEL FIRES | xfFire | WORLD | v26.78, v27.04 | yes (fire hazards) |
| 5 | EVENT \u00b7 ORBITAL DEBRIS | xfEvDebris | WORLD | v26.80, v27.07 | yes |
| 6 | EVENT \u00b7 MACHINE CONVOY | xfEvConvoy | WORLD | v26.81, v27.07 | yes |
| 7 | EVENT \u00b7 BOUNTY PILLAGER | xfEvBounty | WORLD | v26.82, v27.07, v27.27 | yes |
| 8 | EVENT \u00b7 COOLANT RUPTURE | xfEvCool | WORLD | v26.83, v27.07 | yes (coolant fog) |
| 9 | EVENT \u00b7 OVERSEER RAMPAGE | xfEvRamp | WORLD | v26.86, v27.07 | yes |
| (9b) | EVENT \u00b7 LOCKDOWN ALARM | xfEvLock | WORLD | v26.85, v27.09 | being removed: row only while EVENTS.lock exists |
| 10 | STRONGHOLDS | xfHold | WORLD | v26.91, v27.12 | yes |
| 11 | GOLDEN ENEMY | xfGold | WORLD | v26.92, v27.18 | yes |
| 12 | GOLDEN CLUE HUNT | xfClue | WORLD | v26.94, v27.18 | ADDED |
| 13 | STYLE MEDALS | xfStyle | WORLD | v26.84, v26.98 | yes (style medals and the combo ring) |
| 14 | POWER-UPS | xfPwr | WORLD | v26.88, v26.89 | yes |
| 15 | TEAM COMBO | xfTeam | WORLD | v26.95, v26.98 | yes |
| 16 | PARTY SEED | xfSeed | LOCAL (host machine) | v26.93 | yes |
| 17 | PILLAGER ROLES | xfRoles | WORLD | v26.59 | yes |
| 18 | SUPPRESSION | xfSupp | WORLD | v26.62 | yes |
| 19 | MACHINES VS PILLAGERS | xfFeud | WORLD | v26.68 | yes |
| 20 | OVERSEER PHASES | xfOvPh | WORLD | v26.70 | yes |
| 21 | ELITE AFFIXES | xfAffix | WORLD | v26.72 | yes |
| 22 | SEARCH RINGS | xfSearch | WORLD | v26.76 | yes (search rings and cones) |
| 23 | MIMIC CRATES | xfMimic | WORLD | v26.77 | yes |
| 24 | WARDEN ARMOUR | xfWarden | WORLD | v26.79 | yes |
| 25 | EXPLOSIVE BARRELS | xfBarrel | WORLD | v27.05 | yes |
| 26 | WAVES GROW | xfRamp | WORLD | v27.11 | yes (waves ramp) |
| 27 | AIM LANES | xfTell | WORLD | v26.58 | ADDED |
| 28 | NEEDED-ITEM GLOW | xfNeed | LOCAL | v27.00 | yes |
| 29 | HAUL REVEAL | xfHaul | LOCAL | v27.08 | yes |
| 30 | SHOP RE-ROLL | xfShop | LOCAL | v27.03 | yes |

WORLD = read from the raid snapshot XF (set at the lift; the host rules in a party). LOCAL = read live from this window's CFG
(Undercroft or display only, each window its own; the party seed only ever runs on the machine that deploys).

Labels are written above with \u00b7 the way the file writes a middle dot; type the six characters backslash u 0 0 b 7 inside the JS string,
never the character itself (PowerShell 5.1 reads .ps1 as ANSI: memory "No non-ASCII in patch scripts").

### Considered and left without a switch

| Build | What | Why no switch |
|---|---|---|
| v26.55, 26.56, 26.57, 26.60, 26.63, 26.64, 26.65, 26.66, 26.67 | hit stop and lance kick, active reload, camera look ahead, LMG spin up, close call, finisher, grenade marker, ricochet, bloom ring | his words: gun feel "felt pretty good", no toggles |
| v27.06 | no back shot bonus on pillagers | his answer 31 ("no weakspots/headshots"), a ruling, not an experiment |
| v27.10 | guns in hand even bigger | his answer 42, cosmetic |
| v27.13 | damage numbers | already a DISPLAY row (dmgNumbers) |
| v27.14, v27.16, v27.17, v27.22, v27.24, v27.26, v27.29 | six pickup rows, heartbeat at 30 percent, gun card spot, ghost gun keys, persistent feed, controls list, prompts 60 percent | his answers and orders on the HUD; layout, not a feature to compare |
| v27.20, v27.23, v27.28 | kit on the map select, RANDOM KIT 2 guns 1 each, BEST KIT | his words on the kit flow |
| v26.96, v26.97, v27.01, v27.02, v27.21 | gun kill tally, armory codex, trophy case, stash sort/filter/lock, one row stash | Undercroft screens. If he asks later: hide the ARMORY and TROPHIES buttons (trophyOpen, codexScan) and the KILLS line (gunKillsOf); keep the counting running so ON again loses nothing |
| v26.90 | operator menu NEW PARTY | DEMO operator tool; its seed part is PARTY SEED |
| v26.74, v26.89, v26.98 | air strike plate at 4K, magnet/shield/screen clear, combo x clears the team ring | parts of AIR STRIKE, POWER-UPS, TEAM COMBO |
| v27.04, 27.07, 27.09, 27.12, 27.18, 27.19, 27.25, 27.27 | the player 2 builds of the raid flow | they follow the parent switch (the peer mirrors what the host sends) |
| v27.30 | elite machines get an outline | cosmetic on every elite; with ELITE AFFIXES off the elites are plain and keep the outline in the plain colour |
| v26.61, 26.75, 26.87, 26.99, 27.15 | what is new cards | text; the card will still name a feature that is off (acceptable) |

## 2. How Settings works today (c2d37e64)

- THE ROW TABLE. `var GAMEOPTS=[` (L59544). A row is `{k, label, sec, hint, opts:[{n, cfg}], def, show}`. `def` is the INDEX of the default option.
  `cfg` is written into CFG when the option is chosen. Example of the newest style, ON by default with ON first:
  `{k:'gfxPost', label:'POST FX', hint:'BLOOM AND COLOUR GRADE. OFF RUNS FASTER.', opts:[{n:'ON', cfg:{gfxPost:1}},{n:'OFF', cfg:{gfxPost:0}}], def:0}`.
  `show:function(){...}` hides a row that does not apply (rumbleK uses it): `if(typeof _gr.show==='function'&&!_gr.show()) continue;`.
- STORAGE. `P.gameOpts[k]` holds the chosen INDEX, saved by `saveProfile()` into the profile (storage key salvagerun:profile, untouched).
  `function gameOptIx(k)` (L59970) returns the saved index or `row.def`. `function gameOptLive(k)` (L59959) returns the option whose cfg
  matches CFG now (or -1 = CUSTOM). `function applyGameOpts()` (L59990) writes every row's chosen cfg into CFG (skipping keys the tuning console
  owns, `tunedKeys()`); it runs after the profile loads (L4093, L4105, L60982), after a preset (L41406) and on every row click.
- THE CLICK. `function cycleGameOpt(k)` (L60031) steps `P.gameOpts[k]` to the next option, releases console claims on the row's keys,
  `applyGameOpts(); saveProfile();`. Wired at L60320: `b.onclick=function(){ var _rs0=CFG.raidSec; cycleGameOpt(k); gameOptRaidNow(_rs0); renderSettings(); };`
  (gameOptRaidNow only rescales a live raid clock).
- THE PAGE. `function renderSettingsInner(host)` (L60145) loops GAMEOPTS, builds each row
  `'<div class="row"><div style="flex:1"><b>'+_gr.label+'</b><div class="hint">'+_gr.hint+...+'</div></div><button id="go_'+_gr.k+'" ...>'+(_gs?_gs.n:'CUSTOM')+'</button></div>'`
  into `_SEC[setSecOf(_gr)]`; a non-default pick is drawn amber (`(_dflt?'':';color:var(--amber)')`).
  `host.innerHTML=setSecsHtml(_SEC,{CONTROLS:keysRowHtml(),CONTROLLER:padRowHtml()})+kidHeadHtml()+...` .
- THE SECTIONS. `var SETSEC=['THE RAID','AUDIO','CONTROLS','CONTROLLER','DISPLAY','ACCESSIBILITY'];` (L60098). `function setSecsHtml(S,X)` (L60105)
  emits, in SETSEC order, a head (`setSecHead`) plus X[section] (rows that lead a section) plus S[section], and a jump bar chip per section that has
  rows; a section with no rows is not drawn. The kid menu, backup and tools come after, under SAVES AND TOOLS.
- CFG AND DEF. `var DEF={...}` is one long object (L2638 to L2646, ends `partDoor:1};`), `applyCfg(DEF,null)` at L2655 makes CFG from it.
  The tuning console uses its own explicit `var SLIDERS=[` list (L41304), so a new DEF key does NOT become a slider.
- THE TWO PLAYER PRECEDENT. Superhot is the one Settings row the host rules: `m.sh=CFG.superhot?1:0;` in `function netWorldSend()` (L51658),
  `netShTake(m.sh)` in netWorldTake, `function netShHost()` (L51219), `netShDrop()` in netReset, and cycleGameOpt refuses the row on a linked window.
  That pattern is LIVE (twice a second). The experimental switches do not need it: they are raid-start values (section 3.4).
- THE RAID WORD. `function netUpAnnounce(g)` sends `cfg:netUpCfgDiff()` = every DEF key whose CFG value differs from DEF (L49974).
  `function netUpStart(m)` (L50045) on the linked window saves its CFG, sets `CFG[k]=DEF[k]` for every DEF key, applies m.cfg for DEF keys,
  calls `startRaid()`, and in `finally` puts its own CFG back. A late join goes through the same netUpStart with the kept NET.upWord.
  `saveProfile()` does nothing while `NET.upHold` (L3730), so nothing of the host's leaks into player 2's save.

## 3. The proposal: an EXPERIMENTAL section

### 3.1 The switch table, the DEF keys and the snapshot (insert right after the DEF line, L2646, before `var PRESETS={`)

ES5, ASCII only, CRLF like the rest of the file.

```js
// v27.xx (exp1), HIS ORDER (2026-10-14 night): "create an experimental settings menu inside settings where I can turn new features on and off".
// One row per feature added since v26.54 (the gun feel builds excepted, his words). Every switch is ON by default, so a profile that never opens
// the section plays exactly as before. OFF plays that part of the game as v26.54 did. Each is a DEF key (1), so the host's OFF values ride in the
// raid word (netUpCfgDiff) and a linked window builds and plays the raid under them. WORLD switches are read from XF, a snapshot taken when the
// raid starts (startRaid), never from CFG during a raid: a change made mid raid starts with the next raid, and on a linked window XF holds the
// host's values while its own CFG is put back by netUpStart. LOCAL switches (Undercroft and display only) are read live from CFG.
// [key, label, hint, scope] scope 'w' WORLD, 'l' LOCAL. The order is the order of the rows.
var XF_ROWS=[
  ['xfDir','RAID DIRECTOR','THE WAVES EASE OFF AFTER A HARD HIT AND AMBUSH YOU AFTER A QUIET STRETCH.','w'],
  ['xfRamp','WAVES GROW','THE WAVES GROW THE LONGER YOU STAY.','w'],
  ['xfAir','AIR STRIKE','DAMAGE CHARGES AN AIR STRIKE. G, OR LB + RB, TO AIM IT.','w'],
  ['xfGoals','RUN GOALS','THREE SMALL GOALS A RAID. EACH PAYS A SCORE CHIP.','w'],
  ['xfFire','FUEL FIRES','TWO FUEL FIRES A RAID BURN AS WALLS OF FLAME.','w'],
  ['xfEvDebris','EVENT \u00b7 ORBITAL DEBRIS','DEBRIS FALLS IN A RING AND LEAVES BURNING WRECKS WITH LOOT.','w'],
  ['xfEvConvoy','EVENT \u00b7 MACHINE CONVOY','AN ARMOURED TRAIN CROSSES THE MAP. KILL THE CARRIER FOR ITS CRATE.','w'],
  ['xfEvBounty','EVENT \u00b7 BOUNTY PILLAGER','A MARKED BOSS HUNTS YOU. DOWN HIM FOR $1,500.','w'],
  ['xfEvCool','EVENT \u00b7 COOLANT RUPTURE','A DISTRICT FOGS OVER: SHORTER VIEW, DOUBLE CRYO, RICHER CRATES.','w'],
  ['xfEvRamp','EVENT \u00b7 OVERSEER RAMPAGE','THE OVERSEER LEAVES ITS LAIR AND SWEEPS THE MAP.','w'],
  ['xfEvLock','EVENT \u00b7 LOCKDOWN ALARM','A DISTRICT SEALS WITH BERSERK MACHINES AND A JACKPOT CACHE.','w'],   // drop this line when EVENTS.lock is gone
  ['xfHold','STRONGHOLDS','FENCED COMPOUNDS: BREACH THE GATE, BEAT TWO WAVES, TAKE THE PURPLE CACHE.','w'],
  ['xfGold','GOLDEN ENEMY','ONE TOUGH GOLDEN ENEMY A RAID DROPS A GOLDEN HOARD.','w'],
  ['xfClue','GOLDEN CLUE HUNT','THREE CLUES SHRINK A CIRCLE ON THE GOLDEN ENEMY. NEEDS GOLDEN ENEMY.','w'],
  ['xfBarrel','EXPLOSIVE BARRELS','RED BARRELS EXPLODE AND SET OFF THE BARRELS BESIDE THEM.','w'],
  ['xfMimic','MIMIC CRATES','ABOUT ONE CRATE IN FIFTY HIDES A CRAWLER.','w'],
  ['xfRoles','PILLAGER ROLES','PILLAGERS READ BY ROLE: COLOUR, SHAPE AND HOW THEY FIGHT.','w'],
  ['xfSupp','SUPPRESSION','HEAVY FIRE PINS A PILLAGER: HE DUCKS AND SHOOTS WILD.','w'],
  ['xfFeud','MACHINES VS PILLAGERS','MACHINES AND PILLAGERS FIGHT WHEN THEY MEET.','w'],
  ['xfSearch','SEARCH RINGS','AN ENEMY THAT LOSES YOU SEARCHES IN WIDER RINGS WITH A SCAN CONE.','w'],
  ['xfTell','AIM LANES','A MACHINE ABOUT TO SHOOT PAINTS ITS AIM ON THE GROUND.','w'],
  ['xfAffix','ELITE AFFIXES','ELITE MACHINES ARE SHIELDED, VOLATILE, FAST OR MENDERS.','w'],
  ['xfWarden','WARDEN ARMOUR','A WARDEN SHRUGS OFF FIRE FROM THE FRONT.','w'],
  ['xfOvPh','OVERSEER PHASES','THE OVERSEER CALLS CRAWLERS, THEN SWEEPS A LASER.','w'],
  ['xfStyle','STYLE MEDALS','STYLE BONUSES, MEDALS AND THE COMBO RING AT THE CURSOR.','w'],
  ['xfPwr','POWER-UPS','KILLS DROP TIMED POWER-UPS.','w'],
  ['xfTeam','TEAM COMBO','KILLS BY BOTH PLAYERS CLOSE TOGETHER BUILD A TEAM MULTIPLIER. 2 PLAYER DEMO.','w'],
  ['xfSeed','PARTY SEED','NEW PARTY LOCKS ONE SEED FOR THE NIGHT. DEMO.','l'],
  ['xfNeed','NEEDED-ITEM GLOW','A BOX THAT HOLDS AN ITEM YOUR CONTRACT NEEDS GLOWS GOLD.','l'],
  ['xfHaul','HAUL REVEAL','THE HAUL ON THE EXTRACTED CARD COMES UP ONE BY ONE.','l'],
  ['xfShop','SHOP RE-ROLL','TWO OF THE FOUR SHOP EXTRAS ARE IN STOCK EACH RAID. OFF: ALL FOUR.','l']
];
var XF_KEYS=[], XF_WORLD=[], XF={};
(function(){ var i; for(i=0;i<XF_ROWS.length;i++){ XF_KEYS.push(XF_ROWS[i][0]); DEF[XF_ROWS[i][0]]=1; if(XF_ROWS[i][3]==='w') XF_WORLD.push(XF_ROWS[i][0]); } })();
function xfSnap(){ var i, k; XF={}; for(i=0;i<XF_WORLD.length;i++){ k=XF_WORLD[i]; XF[k]=(CFG&&CFG[k]===0)?0:1; } return XF; }
function xf(k){ return XF[k]!==0; }                      // a WORLD switch, as this raid was started with it (all ON before any raid)
function xfL(k){ return !(CFG&&CFG[k]===0); }            // a LOCAL switch, this window, now
var XF_EV={debris:'xfEvDebris',convoy:'xfEvConvoy',bounty:'xfEvBounty',cool:'xfEvCool',lock:'xfEvLock',rampage:'xfEvRamp'};
```

Why DEF: (1) netUpCfgDiff carries any DEF key that differs, so the host's OFF switches reach player 2 with no new net code; (2) netUpStart resets
DEF keys to DEF before applying the host diff, so player 2's own OFF switches cannot leak into a party build; (3) the fixture's `__resetCfg`
(tools/mkfixture.ps1, L104) resets DEF keys, so a check that flips a switch is put back by the usual reset.

### 3.2 The snapshot point (startRaid, L14030)

Right after `if(netGuestHeld()) return false;` (L14031), before `G=buildRaid(false);`:

```js
  xfSnap();   // v27.xx (exp1): the experimental switches this raid is built and played with (on a linked window: the host's, netUpStart has them in CFG)
```

It must come BEFORE buildRaid: ELITE AFFIXES is decided inside buildRaid (blessElite), and the global G is still the previous raid there.
On the host it reads its own CFG. On a linked window startRaid runs inside netUpStart while CFG holds DEF plus the host diff, so XF = the host's,
and it stays the host's after the `finally` puts player 2's own CFG back. The late join path is the same netUpStart. The bot sim and the
fixture's direct buildRaid calls do not pass startRaid; they see the last snapshot (all ON unless a check changed it), see 3.7.

### 3.3 The rows, the section, the lead row (after `var GAMEOPTS=[...];` closes, L59955)

```js
// v27.xx (exp1): the EXPERIMENTAL rows, one per switch, ON first so a saved index means the same thing in every later build
(function(){
  var i, r, on, off, o;
  for(i=0;i<XF_ROWS.length;i++){
    r=XF_ROWS[i]; on={}; off={}; on[r[0]]=1; off[r[0]]=0;
    o={k:r[0],label:r[1],sec:'EXPERIMENTAL',hint:r[2],xf:r[3],opts:[{n:'ON',cfg:on},{n:'OFF',cfg:off}],def:0};
    if(r[0]==='xfEvLock') o.show=function(){ return !!EVENTS.lock; };
    GAMEOPTS.push(o);
  }
})();
```

- `var SETSEC=[...,'ACCESSIBILITY','EXPERIMENTAL'];` (L60098). The jump bar gets an EXPERIMENTAL chip by itself. It sits before SAVES AND TOOLS.
- A lead row with ALL ON, through the X argument (the way CONTROLS gets CHANGE KEYS):
  `setSecsHtml(_SEC,{CONTROLS:keysRowHtml(),CONTROLLER:padRowHtml(),EXPERIMENTAL:xfHeadRowHtml()})`

```js
function xfHeadRowHtml(){
  return '<div class="row"><div style="flex:1"><b>NEW SINCE V26.54</b><div class="hint">OFF PLAYS THAT PART THE OLD WAY. A CHANGE STARTS WITH THE NEXT RAID. IN A PARTY THE HOST DECIDES.</div></div>'+
    '<button id="xf_allon" style="padding:6px 12px;min-width:92px">ALL ON</button></div>';
}
function xfRowNote(r){
  var raid=(typeof G!=='undefined'&&G&&!G.over&&!G.sim), join=(typeof NET==='object'&&NET&&NET.on&&NET.role==='join');
  if(!r||r.xf!=='w') return '';
  if(join) return raid?(' THIS RAID: '+(xf(r.k)?'ON':'OFF')+', AS THE HOST SET IT.'):' IN A PARTY THE HOST DECIDES.';
  return raid?' FROM THE NEXT RAID.':'';
}
```

- In renderSettingsInner, add the note to the hint: after `'<div class="hint">'+_gr.hint+(_gs?'':' Set by hand in the tuning console; click to put a word back on it.')`
  append `+((_gr.sec==='EXPERIMENTAL')?xfRowNote(_gr):'')`.
- Wire ALL ON next to the GAMEOPTS click loop (after L60325):

```js
  var _xa=document.getElementById('xf_allon');
  if(_xa) _xa.onclick=function(){ var i; P.gameOpts=P.gameOpts||{}; for(i=0;i<XF_KEYS.length;i++) delete P.gameOpts[XF_KEYS[i]]; applyGameOpts(); saveProfile(); renderSettings(); };
```

- A row that is OFF is drawn amber already (non-default). Nothing else in the page changes: the same ids (go_xf...), the same pad walk, the same save.
- Optional: grey the CLUE row's hint when GOLDEN ENEMY is off (`xfL('xfGold')`), it cannot run without it.

### 3.4 Saving and the host rule in two player

- Saving: `P.gameOpts.xfDir=1` means OFF (index 1). ON stays index 0 forever; never reorder opts. No migration: a save without the keys gets def 0 = ON.
- Host rule: nothing new on the wire. The host's startRaid snapshots its switches; netUpAnnounce sends the OFF ones in m.cfg; player 2's netUpStart
  builds under them and its startRaid snapshots them into XF. For the whole raid both windows read the same XF. The same holds for a late joiner
  (NET.upWord keeps the cfg of the raid start, which is exactly the host's XF) and for a player 2 who takes the raid over when the host is gone.
- A change on either window mid raid only changes CFG and P.gameOpts; XF waits for the next startRaid. That is what keeps anything from being
  half on: no switch ever flips under a live raid.
- Player 2's own rows still cycle and save (they are his solo settings); the note says the host decides, and during a party raid it states the
  value in effect. Refusing the click like Superhot is not needed, because his value is never used in a party raid.
- Optional, not required: if he wants player 2's rows to show the host's values in the Undercroft too, add `m.xf` (a bit string of XF_WORLD) to
  netWorldSend beside `m.sh`. Not needed for correctness.
- LOCAL switches: PARTY SEED is read where the host deploys (arcadeDeploy), so it is the host's by nature. NEEDED-ITEM GLOW, HAUL REVEAL and SHOP
  RE-ROLL are each window's own display and own Undercroft, read live (xfL), so they can be flipped any time and take effect at once.
- A desync of switches would NOT be caught by the surface fingerprint (netUpFp counts bodies, containers and walls; no switch changes those),
  which is why the switches must travel in the raid word and be snapshotted, never read from player 2's own CFG during a raid.

### 3.5 DEMO and CAREER

Every guard below reads only XF or xfL. None reads G.arcade or G.career, and the features themselves already run the one code path in both modes
(flowTick gates on `G.arcade||G.career`, arcadeWaveTick serves both, arcadeKill and careerKill both call styleKill and pwrKill).
Mode-only by design, before any switch: TEAM COMBO (2 player DEMO only, `ARCADE.on&&!ARCADE.solo`), PARTY SEED (DEMO), and the CAREER-only
Undercroft displays (NEEDED-ITEM GLOW: `needItems` returns {} in an arcade raid; HAUL REVEAL: the DEMO shows no card; SHOP RE-ROLL: no shop in DEMO).

### 3.6 Fixture and checks (tool edits the PC agent makes; this research did not touch tools)

- `window.__resetCfg` in tools/mkfixture.ps1 resets DEF keys; add `try{ xfSnap(); }catch(e){}` at its end, or a check that changed a switch
  leaves XF stale for the next check.
- A check that flips a switch: set CFG.k=0, call `xfSnap()` (or go through startRaid), and put CFG and `P.gameOpts` back in `finally`
  (memory: "The loader replaces the profile", "Checks lean on the profile").
- Older settings checks (settings1, settingsfix) may count sections, chips or rows; expect to retarget them for a seventh section.
- One OFF probe check covers the fingerprint claim: for each WORLD key, set it 0, xfSnap, build seed 4242, read ents 85/374 and containers
  165/593, and call the choke function to see its v26.54 answer (e.g. `raiderApf(e)===.85` for a raider, `waveTier(0)===0` at minute 9,
  `shopStocked({k:'smoke'})===true`). Then all keys back to 1.

## 4. Feature by feature

Format: GUARD = the edit (the switch lives here). INERT = code that needs no edit because it has nothing to act on once the guard holds.
OFF = what v26.54 did. Every line number is c2d37e64.

### 1. RAID DIRECTOR (xfDir) v26.69
What: stress drives the wave clock: a breather after a hard hit, a faster clock in a quiet stretch, an AMBUSH BEHIND YOU pack after a long quiet.
GUARD:
- `function flowDir(dt){` L53992: right after `if(!D) D=S.dir={st:0,hp:hp,quiet:0,ph:'build',phT:0,waves:0,amb:0,lastAmb:-999,pace:1};`
  add `if(!xf('xfDir')){ D.ph='build'; D.pace=1; return D; }`.
- `function flowAmbushOk(D,q){` L54011: first line `if(!xf('xfDir')) return false;`.
- `function arcadeWaveOk(` L53862: `if(flowZoneNear(x,y,DIR.ring)) return false;` (L53866) came with the Director; for a strict v26.54 make it
  `if(xf('xfDir')&&flowZoneNear(x,y,DIR.ring)) return false;`.
INERT: in `function arcadeWaveTick(dt){` (L53932) `WS.waveT=(+WS.waveT||0)+((dt>0)?dt:0)*D.pace;` is the old line at pace 1; the breather clamp
`if(D.pace<=0){ WS.waveT=Math.min(WS.waveT,iv-0.5); return 0; }` never runs; `amb=flowAmbushOk(D,q)?1:0;` gives 0, so
`n=Math.min(amb?pack+2:pack,cap-live);` is the old pack and the WAVE callout has no AMBUSH sub.
KEEP: `flowDirFired(D,amb,made)` (L53966) must still run: it counts `D.waves`, which the run goal 3 WAVES reads
(`if(id==='wave3') return (S.dir&&S.dir.waves)|0;` in goalProg L54217). Never skip flowDir or flowDirFired outright.
OFF: v26.54 wave clock (fixed rate, packs anywhere the spot rules allow). Net: none, host or solo only (`netEntsPeer()` return at L53934).
Stream: Math.random only.

### 2. AIR STRIKE (xfAir) v26.71, v26.74, v27.19, v27.25
What: damage you deal fills a meter (AIR.need 1,500); G (or LB + RB) aims, fire calls six blasts.
GUARD:
- `function airKey(){` L54063: first line `if(!xf('xfAir')) return false;` (silent: G was free before v26.71).
- `function airScan(){` L54050: first line `if(!xf('xfAir')) return;` (the host and solo meter).
- `function airCharge(e,dmg){` L55699: first line `if(!xf('xfAir')) return 0;` (player 2's meter, charged from netShotSend: `try{ airCharge(e,dmg); }catch(_ach){}` L52358).
- the pad chord L15996, `if(_lbN&&_rbN&&(!PAD.prev[4]||!PAD.prev[5])&&!PAD.airChord&&...&&typeof flowOn==='function'&&flowOn()){`: add `&&xf('xfAir')`.
  Without it the chord still fires, sets `PAD.lbHeld=1; PAD.rbHeld=1;` and swallows the two bumpers' belt walk even though airKey refuses.
- `function flowNetWord(peer,m){` L55558, branch `if(m.k==='air'){` (L55571): first line inside `if(!xf('xfAir')) return 'off';`.
- `function goalsMake(S){` L54207: next to the vault line
  `if(!(G.map&&G.map.locked&&G.map.locked.length)){ ix=pool.indexOf('vault'); if(ix>=0) pool.splice(ix,1); }`
  add `if(!xf('xfAir')){ ix=pool.indexOf('air1'); if(ix>=0) pool.splice(ix,1); }`. Otherwise the AIR STRIKE goal can be drawn and never met.
INERT: airTick (no aim, no strikes), airCall, airBlast, airStrikeFx, flowNetAirSend; airDraw (L54117) draws the plate only
`if(A.m>0||A.aim||A.sk.length)`, so nothing shows. The 'KeyG' row in KEYS_ACTS stays on the key page (harmless).
OFF: no meter, no plate, G does nothing, bumpers walk the belt. Net: `{t:'fl',k:'air'}` word; P2 meter through netShotSend. Stream: Math.random (a0).

### 3. RUN GOALS (xfGoals) v26.73, v27.27
What: three small goals a raid, each pays a chip into the run score.
GUARD: `function goalsTick(dt){` L54239: after `if(flowPeer()) return;` add `if(!xf('xfGoals')) return;`.
INERT: S.goals is never made, so `goalsHud` (L54250, called `goalsHud(ctx)` at L36624) returns at `if(!S||!S.goals||...`, `goalsTiles` (L55753)
returns 0, `goalsNetOut` returns 0 and player 2's `if(fl.r) goalsNetTake(fl.r);` skips. flowKill keeps counting (harmless).
Pays: `flowChip(gl.chip,'GOAL DONE',gl.t)` never runs. Stream: side GOAL_TAG 61.

### 4. FUEL FIRES (xfFire) v26.78, v27.04
What: two planned fuel fires a raid, impassable discs that burn whoever stands at the edge.
GUARD: `function fireTick(dt){` L54334: the plan block `if(!peer){   // v27.04 (coop1): a linked player 2 window plans and lights nothing`
becomes `if(!peer&&xf('xfFire')){`. Nothing else.
DO NOT guard the top of fireTick: the same function ages, fences (fireKeep) and burns EVERY fire in G.flow.fires, including the burning wrecks
ORBITAL DEBRIS lights (`fireAdd(pt.x,pt.y,58,45,'debris',0);` L54582). A top return leaves those frozen at t=0: fireDraw draws their warm-up
dashed ring forever, they never light, never fence and never go away.
INERT: `fireAt` in arcadeWaveOk (L53867), fireMarks, fireNetTake (the host sends only the debris fires). Stream: side FIRE.tag 63; sparks cosmetic.

### 5 to 9 (and 9b). THE RAID EVENTS (xfEvDebris, xfEvConvoy, xfEvBounty, xfEvCool, xfEvRamp, xfEvLock) v26.80 to v26.86, v27.07, v27.09
What: one or two events a raid with a warning ring, a countdown and a map mark.
GUARD (one place for all six): `function evEligible(){` L54460, the loop line
`for(i=0;i<EV_IDS.length;i++){ d=EVENTS[EV_IDS[i]]; if(d&&(!d.ok||d.ok())) out.push(EV_IDS[i]); }`
becomes `...if(d&&(!d.ok||d.ok())&&xf(XF_EV[EV_IDS[i]])) out.push(EV_IDS[i]); }`.
An event that is off never enters evPlan's pool. The plan still holds 1 or 2 events (drawn from the ones left); with all off evPlan stops at
`if(!ids.length){ E.plan=plan; return plan; }` and no event happens.
INERT: an event's start, tick, end and draw run only for a launched event; `coolIn`, `flowVis`, `flowCryo` find no live 'cool' (VF and AMBR
multiply by 1; `elemHit` cold is x1); `lockSealed` and `lockKeep` find no live 'lock'; player 2's `evPeerTick` and `evNetTake` handle only what
the host sends (`evNetOut`). Stream: plan side EV.tag 62, each event on `evStream` of its number; an off event only shifts the side stream.
Per event:
- DEBRIS: impacts hurt everyone inside, light 58 wide fires through fireAdd (keep fireTick running, see 4), drop a DEBRIS WRECK (loot, side stream).
- CONVOY: a Bulwark carrier and four armoured crawlers made on side stream EV.tag+3; CONVOY CRATE on death of the carrier.
- BOUNTY: a pillager with 4x health hunts you; `flowChip(BOUNTY.pay,'BOUNTY CLAIMED','BOUNTY PILLAGER')` pays 1,500 (a party kill counts, v27.27).
- COOL: view x0.45 at the middle (`function VF(){ return CFG.viewFar*wx().view*opticMag()*flowVis(); }`), double cryo, one more item in the shut boxes inside.
- RAMPAGE: also gated by `ok:function(){ return CFG.boss!==0; },` (L54990); moves the Overseer's lair and speed, its end() puts them back.
- LOCK: is being removed. While `EVENTS.lock=` exists keep xfEvLock with `show:function(){ return !!EVENTS.lock; }`; once removed, drop its
  XF_ROWS line and its XF_EV entry; nothing else refers to it.

### 10. STRONGHOLDS (xfHold) v26.91, v27.12
What: one or two fenced compounds: breach the gate (3 s), two waves, a purple cache, the STRONGHOLD CHIP 1,000.
GUARD: `function shTick(dt){` L55148: first line `if(!xf('xfHold')) return;` (before the `if(flowPeer()){ shPeerTick(dt); return; }` line).
INERT: no sites, so `shAt` returns null (arcadeWaveOk L53868, clueLayout, the cache mark L55540), shKeep never runs, shDraw and shMarks draw
nothing, `shNetOut` returns [] (player 2 gets none), flowNetWord 'gate' answers 'gone'. Pays: `flowChip(SH.chip,'STRONGHOLD CLEARED','STRONGHOLD')` never.
Stream: side SH.tag 64 (+1 garrison and cache, +2 cache box, +3 wave two).

### 11. GOLDEN ENEMY (xfGold) v26.92, v27.18
What: one body a raid gilded (3x health, 1.1x size), drops a GOLDEN HOARD.
GUARD: `function goldTick(dt){` L55242: first line `if(!xf('xfGold')) return;`.
INERT: no S.ref, so goldDraw returns, `goldNetOut` returns 0, and the clue hunt never lays out (`if(!S||!S.ref||(G.t||0)<4) return;` in clueTick).
The GOLD HUNTER trophy cannot be earned in such a raid (fine). Stream: side GOLD.tag 65.

### 12. GOLDEN CLUE HUNT (xfClue) v26.94, v27.18 (ADDED)
What: three clue props shrink a search circle on the golden enemy.
GUARD: `function clueTick(dt){` L55307: first line `if(!xf('xfClue')) return;` (before the `if(flowPeer()){ cluePeerTick(dt); return; }` line).
INERT: no props, so clueMarks, clueDraw, `clueNetOut` (returns 0), cluePeerTick and flowNetWord 'clue' have nothing. Needs GOLDEN ENEMY ON to do
anything. Stream: side CLUE.tag 66 (+1 for the circle offsets).

### 13. STYLE MEDALS (xfStyle) v26.84, v26.98
What: LONG SHOT, MELEE KILL, GRENADE DOUBLE, MULTI-KILL, UNTOUCHED medals paid through scoreBonus, and the combo ring at the cursor.
GUARD:
- `function styleKill(k,el,boss,x,y,e){` L56105: first line `if(!xf('xfStyle')) return 0;`.
- `function styleTick(p,dt){` L56123: wrap the calm block `if(t>=S.calmAt){ ... }` in `if(xf('xfStyle')){ ... }`. Keep the pops cleanup line
  after it: TEAM COMBO uses the same plates (styMedal).
- `function styleDraw(c,p,rx,ry){` L56137: the ring block `if(s&&s.n>=2&&t>=s.t&&t-s.t<ARCADE_STREAK_GAP){` becomes
  `if(xf('xfStyle')&&s&&s.n>=2&&t>=s.t&&t-s.t<ARCADE_STREAK_GAP){`. The plates loop below stays (with style off it holds only team medals).
KEEP: the streak multiplier itself (scoreKill, ARCADE_STREAK_GAP) is older than v26.54 and stays. The blow marks (`e.blow='x'`, 'm', 'g') stay, harmless.
Callers: arcadeKill L56049 and careerKill L56032 (`try{ styleKill(k,el,boss,x,y,ke); }`), styleTick from updatePlayer L23466, styleDraw L36254.

### 14. POWER-UPS (xfPwr) v26.88, v26.89
What: kills drop timed pickups: BOTTOMLESS CLIP, DOUBLE DAMAGE, RAPID FIRE, MAGNET, SHIELD BUBBLE, SCREEN CLEAR.
GUARD: `function pwrKill(k,el,boss,x,y,e){` L56220: first line `if(!xf('xfPwr')) return 0;`.
INERT: no items and no timers, so `pwrOn` is false everywhere: `pwrMul('dmg',fromPlayer)` 1, `pwrRof()` 1, `pwrClip()` false (the ammo line
`if(!pwrClip()) p.ammo--;` is the old decrement), the damagePlayer shield check `pwrOn('shield')` false; pwrTick, pwrDraw, pwrDraw2 have nothing.
Stream: side PWR.tag 71 per kill number.

### 15. TEAM COMBO (xfTeam) v26.95, v26.98
What: 2 player DEMO: kills by both players within 2 s and 52 m build a TEAM multiplier.
GUARD: `function teamKill(x,y){` L56433 first line `if(!xf('xfTeam')) return 0;` (it then sends no arckill); `function arcadeTeamTake(m){`
L56449 first line `if(!xf('xfTeam')) return 'ignored';`; `function teamDraw(c,p,rx,ry){` L56458 first line `if(!xf('xfTeam')) return;`.
Net: the arcade word `{t:'arckill'}` on the pair channel (netSamePost). Pays: `styMedal('TEAM COMBO x'+n,TEAM.pts*n,x,y)`.

### 16. PARTY SEED (xfSeed, LOCAL) v26.93
What: NEW PARTY locks one seed and sector for the night, so every DEMO run plays the same raid.
GUARD: `function arcadePartySeed(){` L56932: first `if(!xfL('xfSeed')) return 0;`. Then arcadePartyMap is -1 and arcadePartyCode is '', so
arcadeDeploy uses `ARCADE.mapIx` and buildRaid's own Math.random seed (L53647, `var _ps=arcadePartySeed(); if(_ps) pendSeed=_ps;` L53651),
and the board line (L56803) and the operator card line (L56967) disappear by themselves.
FIX TWO TEXTS (else they read half): L57008 `ARCOP.note='CLEARS TONIGHT\u2019S BEST  \u00b7  NEW SEED  \u00b7  BEST EVER STAYS'` drops NEW SEED when off;
L57010 `'NEW PARTY  \u00b7  BOARD CLEARED  \u00b7  SEED '+arcadePartyCode()` becomes `...BOARD CLEARED'+(arcadePartyCode()?'  \u00b7  SEED '+arcadePartyCode():'')`.
`arcadeNewParty` may keep writing the seed into the record: ON again the same night resumes it. 2P: the seed reaches player 2 in the raid word.

### 17. PILLAGER ROLES (xfRoles) v26.59
What: RUSH, FLANK, SUPP, MARK, SHIELD from gun and rig: a coat tint, a shape, and how close each fights.
GUARD: `function raiderRole(e){` L20531: first line `if(!xf('xfRoles')) return null;`.
INERT: `raiderApf` .85, `raiderRtf` .30, `raiderFr` .55 (the v26.54 constants at L27009, L27030, L26998), `raiderCoat` returns e.coat (L33973),
`drawRoleMark` returns (L33980). 2P: player 2 works out roles itself from wep, rig and ident, so its XF must be the host's (it is).

### 18. SUPPRESSION (xfSupp) v26.62
What: rounds past a hostile pillager pin him: he ducks, holds, slips to cover and shoots 2.5x wild.
GUARD: `function suppHit(en){` L20591: first line `if(!xf('xfSupp')) return false;`.
INERT: pinT is never set, so `if(e.pinT>0){` (L27004), `*(e.pinT>0?2.5:1)` (L27069), the crouch pose and flag bit 268435456 never trigger.
Callers: updateBullets L27888 (`en.suppB=b; suppHit(en);`), netShotTake L52395. Stream: none; the shot jitter draws the same number of rnd().

### 19. MACHINES VS PILLAGERS (xfFeud) v26.68
What: pillagers running for the ring fight machines they meet; Wardens and Bulwarks hunt pillagers they see.
GUARD: `function machFoe(o){` L20604: `if(!xf('xfFeud')) return false;` before the return; `function machHuntRaider(e,dt){` L11620, line L11622
`if(e.kind!=='sentry'&&e.kind!=='crawler'&&e.kind!=='bulwark'&&!(e.kind==='warden'&&!e.boss)) return false;` becomes
`if(e.kind!=='sentry'&&e.kind!=='crawler'&&!(xf('xfFeud')&&(e.kind==='bulwark'||(e.kind==='warden'&&!e.boss)))) return false;`.
KEEP: the older fights (a looting pillager shoots a machine, CFG.machVsRaider sentries and crawlers) are pre v26.54 and stay. Host only.

### 20. OVERSEER PHASES (xfOvPh) v26.70
What: at 66 percent it calls crawlers, at 33 percent a sweeping laser, then its core is exposed (+50 percent damage) while it vents.
GUARD: `function overseerTick(e,p,sees,dt){` L20641: first line `if(!xf('xfOvPh')) return false;`; and in updateBullets L27960
`if(en.boss&&en.overheat>0) edmg*=1.5;` becomes `if(xf('xfOvPh')&&en.boss&&en.overheat>0) edmg*=1.5;`. That second guard matters: the line
also fires for the older seam-hit vent (overheat), which never paid a bonus in v26.54. It runs on player 2's window too (his rounds work out
their own number before netShotSend), so XF on player 2 must be the host's (it is).
INERT: `if(e.boss&&overseerTick(e,p,sees,dt)){ collide(e,G.map.walls); continue; }` (L26539) falls through to the old boss code; overseerSummon
(fxBorrow), the beam draw (L33061, swpT never above 0), flag bit 1073741824 and the 'phase' mark never fire.

### 21. ELITE AFFIXES (xfAffix) v26.72 (the v27.30 outline is cosmetic and stays)
What: an elite machine is SHIELDED, VOLATILE, FAST or a MENDER, in its own colour, and pays 3x.
GUARD: `function affixApply(e,ix){` L20708: first line `if(!xf('xfAffix')) return null;`.
Callers: blessElite L11687 `if(e.kind!=='raider') affixApply(e,Math.floor(roll/rate*4));` (BUILD TIME, inside buildRaid: this is why the
snapshot sits before buildRaid), arcadeWaveElite L53908 (waves, convoy crawlers, stronghold wave two).
INERT: no e.affix, so affixSoak passes the full round, affixBoom and affixMend never run, the draw takes the old purple ring
(`if(e2.elite&&e2.affix&&AFFIX[e2.affix]) drawAffixMark(e2); else if(e2.elite){`), the kill pays the old 2x (`(e.elite&&e.affix)?3:e.elite`),
`netEntNewWord` sends `af:''`. Stream: none (the affix came from the existing elite roll or a position hash). Fingerprint: unchanged (FAST only
changes e.spd; no body is added or moved).

### 22. SEARCH RINGS (xfSearch) v26.76
What: a searcher widens its search in three rings instead of giving up at the first point, and shows an amber scan cone.
GUARD (three edits):
- `function searchAdvance(e){` L20840: first line `if(!xf('xfSearch')) return false;`.
- the stuck rule, L27026 and L27027:
  `if(_sd>40&&_srch){ if(_sd<(e.srchBest===undefined?1e9:e.srchBest)-6){ e.srchBest=_sd; e.srchT=0; } else e.srchT=(e.srchT||0)+dt; }`
  `if(_sd>40&&!(_srch&&(e.srchT||0)>1.5)) navSeek(e,_shx,_shy,e.spd*.9,dt);`
  use `_srch&&xf('xfSearch')` in place of `_srch` in both. Without this, with rings off a searcher that cannot get nearer for 1.5 s drops the
  hunt (`else if(!(_srch&&searchAdvance(e))) e.alert=0;`), where v26.54 kept walking at the point.
- `function searchCone(e){` L20828: first line `if(!xf('xfSearch')) return null;` (cone draw L33076, `var _sk=searchCone(_sce); if(!_sk) continue;`).
INERT: searchSector's radius `(CFG.crewSearchR===undefined?130:CFG.crewSearchR)*(1+0.8*(e.searchLvl|0))` (L10068) stays x1 (searchLvl stays 0);
the machine ring line L27079 calls searchAdvance (false); flag bit -2147483648 is still sent (it is just "searching") but player 2's searchCone returns null.

### 23. MIMIC CRATES (xfMimic) v26.77
What: about one crate or locker in fifty hides a dormant crawler that bursts out 0.8 s after you start searching.
GUARD: `function isMimic(ct){` L20855: `if(!ct||typeof G==='undefined'||!G||CFG.mimic===0) return false;` becomes
`if(!ct||typeof G==='undefined'||!G||CFG.mimic===0||!xf('xfMimic')) return false;`. Keep the old hidden dial CFG.mimic (checks may use it).
INERT: mimicTick (`try{ mimicTick(dt); }catch(_mt){}` L25698, host only, after the peer return L25691) caches `ct.mim=0` per box and never wakes one.
Stream: hash; the crawler is made on the cosmetic stream.

### 24. WARDEN ARMOUR (xfWarden) v26.79
What: a plain Warden soaks 60 percent of a round from its front arc.
GUARD: updateBullets L27911 `} else if((en.kind==='bulwark'||(en.kind==='warden'&&!en.boss))&&(function(){` becomes
`} else if((en.kind==='bulwark'||(xf('xfWarden')&&en.kind==='warden'&&!en.boss))&&(function(){`. The WARDEN_ARC and WARDEN_SOAK ternaries inside
are then unreachable for a Warden. Runs on player 2's window for his own rounds, so XF matters there (it is the host's).

### 25. EXPLOSIVE BARRELS (xfBarrel) v27.05
What: clusters of red ! barrels that explode and chain.
GUARD: `function brlPlace(g){` L17109: after `g.brl=[];` add `if(!xf('xfBarrel')) return;`. (Called from startRaid after buildRaid:
`if(G&&!G.sim){ try{ brlPlace(G); }catch(_bpl){ G.brl=[]; } }` L14067, on both windows.)
INERT: `if(G.brl&&G.brl.length&&brlShot(b)){ hit=true; break; }` (L27849), brlNear in explodeFrag (L17248), brlTick (L17488), the draw loop.
Stream: side BRL_TAG 47 into G.brl, not ents or containers, so the fingerprint is the same on or off.
2P: there is no barrel net word; each window places its own from the side stream, so both MUST have the same switch (XF does it).

### 26. WAVES GROW (xfRamp) v27.11
What: the wave tier has a floor that rises one step every two minutes to 4.
GUARD: `function waveTier(score){` L53928, line L53929: `tt=Math.max(0,Math.min(4,Math.floor((+elapsed()||0)/120)))` becomes
`tt=xf('xfRamp')?Math.max(0,Math.min(4,Math.floor((+elapsed()||0)/120))):0`. OFF: the tier is the score alone (v26.54).

### 27. AIM LANES (xfTell) v26.58 (ADDED)
What: a Sentry or Warden winding up paints a red lane to where its round would stop; a Howler shell fills its landing circle.
GUARD: `function telegraphLane(e){` L31902: first line `if(!xf('xfTell')) return null;` (the lane loop L33047 `var _tn=telegraphLane(_tle); if(!_tn) continue;`).
And the four statements after the comment `// v26.xx (ai20): the landing circle FILLS` (L33159 to L33163, the fill and the faint full ring)
go inside `if(xf('xfTell')){ ... }`; keep the stroke after them (`wc.strokeStyle='rgba(255,90,60,'+(0.25+0.45*_sf).toFixed(3)+')';`), that one is v26.54.
Note: the Overseer phase 3 charge shows its lane through telegraphLane; with AIM LANES off the charge has its alarm sound only.

### 28. NEEDED-ITEM GLOW (xfNeed, LOCAL) v27.00
What: a box that holds an item an unfinished contract needs glows gold; the item gets a gold edge in the pickup stack and the backpack.
GUARD: `function needRefresh(){` L38001: after `if(!G||G.sim) return 0;` add `if(!xfL('xfNeed')){ G.need={}; G.needN=0; return 0; }`.
INERT: `needHolds` returns false (`!G.needN`), so the box glow (L32611), the pickup row edge (L17834) and the bag cell edge (L40543) do not draw.
Live: needRefresh runs once a second from careerTick (L38119), so a flip mid raid clears within a second. CAREER only by design.

### 29. HAUL REVEAL (xfHaul, LOCAL) v27.08
What: the EXTRACTED card's haul pictures come up one by one with a rarity flash and a HAUL total.
GUARD: `function haulRevealStart(){` L29629: after `HAUL_REV=null;` add `if(!xfL('xfHaul')) return 0;`.
INERT: haulRevealSkip returns false, so ESC, TAB, A, B and a click leave the card at once as before; the 40 ms interval ticks nothing; no HAUL
line is inserted. CAREER only (the DEMO shows no card).

### 30. SHOP RE-ROLL (xfShop, LOCAL) v27.03
What: two of the four shop extras (Smoke, Decoy, Frag, Stim) are in stock, re-rolled after every raid.
GUARD: `function shopStocked(o){ return !o||!!SHOP_CORE[o.k]||o.kind==='pack'||!!shopStockSet()[o.k]; }` (L47770) becomes
`function shopStocked(o){ return !xfL('xfShop')||!o||!!SHOP_CORE[o.k]||o.kind==='pack'||!!shopStockSet()[o.k]; }`.
INERT: SOLD OUT in renderShop (L47829), renderShopGrid (L47938, L47941) and the lift's offer (renderStage L59230). The switch is read before the
SHOP_MEMO cache, so no stale set. Stream: side SHOP_TAG 67 keyed on P.runs.

## 5. Risk ranking

The three riskiest to switch off:
1. AIR STRIKE. The most entry points across both windows and both inputs: the G key, the LB + RB chord (which swallows the bumpers unless the
   chord condition itself is guarded), player 2's meter inside netShotSend, the 'air' flow word, and the run goal pool (an AIR STRIKE goal that can
   never be met unless 'air1' leaves the pool on the host).
2. FUEL FIRES. fireTick is shared with ORBITAL DEBRIS: the natural top-of-function guard leaves debris fires frozen on screen as warm-up rings that
   never burn, fence or fade. Guard only the plan block.
3. RAID DIRECTOR. It lives inside the one wave clock DEMO and CAREER share, and its state object also counts the waves the 3 WAVES goal reads.
   Skipping flowDir or flowDirFired makes that goal unwinnable; the guard must keep D and neutralise pace and the ambush.

Next in line: OVERSEER PHASES (the +50 percent vent line also fires for the older seam-hit vent and runs on player 2's window), SEARCH RINGS
(the 1.5 s stuck rule must be guarded with the rings or searchers give up early), ELITE AFFIXES (decided at build time; the snapshot must exist
before buildRaid), PARTY SEED (two operator notes read "SEED " with nothing after unless fixed).
Low risk, one-line choke points: run goals, events, strongholds, golden enemy, clue hunt, power-ups, team combo, roles, suppression, feud, mimic,
warden armour, barrels, waves grow, aim lanes, needed glow, haul reveal, shop re-roll.

## 6. Suggested order of work (his rule: one thing per build)

1. The section itself: XF_ROWS, the DEF keys, xfSnap in startRaid, the GAMEOPTS rows, SETSEC, the lead row and ALL ON, the notes. Ship with the
   one-line choke guards (rows 3, 5 to 12, 14, 15, 17, 18, 19, 21, 23, 24, 25, 26) and their check. Rows whose guard is not in yet must not be
   listed (leave them out of XF_ROWS until their build), so no row ever does nothing.
2. The careful ones, one build each or two at most: AIR STRIKE, FUEL FIRES, RAID DIRECTOR, OVERSEER PHASES, SEARCH RINGS, STYLE MEDALS, AIM LANES.
3. The LOCAL rows: PARTY SEED (with its two texts), NEEDED-ITEM GLOW, HAUL REVEAL, SHOP RE-ROLL.
Each build: a check that drives the OFF arm on the play path and fails on the previous build (the row is missing there), plus the OFF probe of 3.6.
Two player: one same machine pair run with the host OFF and player 2 ON for a switch with a visible tell (barrels, strongholds, roles): both
windows must show the OFF world.
