# 2026-09-07 build specs from the audit backlog (workflow wf_80109af7-d74, 53 agents)

Each spec was written from the source and then attacked by a skeptic; only the ones the skeptic CONFIRMED are here. Anchors were reported as matching verbatim and exactly once at v12.28: RE-COUNT each one before drafting, the tree moves every twenty minutes. Draft these after his notes are done.

## 1. v12.31 - THE STALL IS NOT A PAUSE: the Peddler trade window stops every extraction clock while the raid clock and the machines run on  [key: trade-freeze]

- Still open: STILL OPEN at v12.27. The deciding line is unchanged in C:\claudecode\dark raiders\dark_raiders.html (now line 14934, one match in the file):

  if(G.trade){ tickRegen(dt); return; }

It sits inside updatePlayer (declared at 14292, ends at 15132), and it is ABOVE the only real-game call to the extraction tick, at 15129:

  tryExtractTick(dt,!!keys['KeyE']&&(!near||onPad));

WHAT STOPS. tryExtractTick is the only caller of tickExtractPoints (13568) and of tickRaiderWaves (13569); grep shows tickExtractPoints has exactly one call site in the file. So while G.trade is set, none of these advance:
- 13977  z.beaconT-=dt                       the inbound extraction countdown
- 14170  z.hold-=dt                          the 30 second boarding window
- 14027  z.siegeSpawnT / 14037 the arrivals   the siege the call bought
- 14065  z.siege / 14091 the 2 second re-ping
- 14205-14223 the G.beaconT / G.shipHold mirrors the HUD reads
- 14228-14243 the closing loop: the two-minute warning and cz.open=false
- 13569  tickRaiderWaves

WHAT DOES NOT STOP. Nothing in loop() gates on G.trade (28206-28350). In the same frames:
- 28279  G.t+=dt
- 28283  if(CFG.raidSec>0) G.timeLeft-=dt      the raid clock
- 28311  updateEnts(dt)                        the machines
- 28312  updateBullets(dt); updateThrowables(dt)
- 28288-28294 the THIRTY SECONDS / minutes-left warnings, which read the clock that is still falling.

WHAT THE PLAYER SEES. The ring label at 23781 prints 'EXTRACT '+extLetter(RZ)+' INBOUND '+Math.ceil(RZ.beaconT)+'s' straight off the frozen field, and 23794 prints the boarding seconds off z.hold. So the number over the extraction point sits still while the raid clock in the corner keeps falling and machines keep moving around him. Trade for sixty seconds and he has lost sixty seconds of raid and gained nothing on the extraction; equally, an extraction already on the ground never leaves while the panel is up.

THE PRECEDENT IS IN THE SAME FUNCTION. Both other early returns in updatePlayer carry the tick past themselves for exactly this reason: 14352 tryExtractTick(dt,!!keys['KeyE']) in the downed branch, with the comment at 14338 'The beacon countdown lives in here, so going down used to freeze the dropship in mid air'; and 14390 tryExtractTick(dt) in the roll branch. The trade return is the one that was never given the same treatment.

Nothing later fixes it: the only other G.trade sites are 9093/9113/9130/9134/9142 (buying and selling), 10615/10634/10641/10643 (keys), 12361, 14925/14926/14931, 24598/24602/24913 (drawing), 25526 (the panel). None of them tick a clock. The corpus has no check pairing G.trade with a beacon (grep of mkfixture.ps1: 'trade' hits are 9.40, 12.17, 12.28, 11.36, 11.68 only).
- Balance risk: DEFECT FIX, not a dial. No CFG value, no default, no table and no number in DEF is touched; the patch adds one call so a function that is supposed to run every frame of a raid runs during the one state that was skipping it. The two other early returns in the same function already do this, so the patch makes the trade branch agree with the downed branch and the roll branch rather than inventing a rule.

Honest statement of the in-raid effect, because it is not nil. Today the stall is a free pause on extraction pressure: the extraction waits, the siege stops arriving, the ring stops re-pinging, and the waves stop. After the patch those all run while he shops, so a trade during a called extraction is harder than it is today - but it is harder in exactly the way the code already promises everywhere else, and the audit's own read (tools\handoff\audit-0907-confirmed.md, finding 9) notes the freeze currently favours the player. This is restoring intended behaviour, not moving difficulty, so it is inside the no-balancing rule. If he disagrees, the smaller half of the fix (call tickExtractPoints alone and leave tickRaiderWaves frozen) is one word, but I do not recommend splitting it.

Scope note: the seal-cut branch at 14798 ('return;   // cutting owns the key and your attention') has the identical shape and freezes the same clocks. It is a separate finding with its own line in the audit and it is NOT in this build, per his one-thing-per-build rule.
- Control failure claimed: On v12.27, unpatched, the check goes red and prints all three arms (semicolon separated). The exact wording, with the ring letter and the numbers filled in from the run:

with the stall open the raid clock fell 1.04s and the inbound extraction fell 0.00s: the point still reads EXTRACT A INBOUND 18s and nothing is getting any closer; with the stall open a landed extraction held its 9.5s boarding window through 1.00s of raid clock, so it waits for as long as he shops; with the stall open extraction B is still marked open at <closeAt-0.6>s against a closing time of <closeAt>, so the map keeps offering a point that has gone

The two control lines stay silent on the unpatched build, which is the point: the raid clock DID fall (so the ruler works) and the same frames DO tick the beacon once the stall is shut (so the trade gate is the only difference). With the patch applied all three arms fall silent - the beacon falls by the same second the raid clock does, the boarding window spends itself, and the point closes - and the check returns null.

The third arm is skipped silently on a map and seed with no second open point carrying a closeAt; arms one, two and the two controls always run.
- Hooks used: Fixture hooks, each confirmed by grep in C:\claudecode\dark raiders\tools\mkfixture.ps1:
- window.__deploy       18965  (commits the kit and starts a non-sim raid, so state==='raid' and G.sim is false, which loop() requires at 28251)
- window.__state        84
- window.__endRaid      135    (finally; 'abandon' is one of the three real outcomes)
- window.__loop         530    (drives the real frame: this is what makes the raid clock fall and updatePlayer run)
- window.__keys         113    (returns the live keys object; mutated in place, never dispatched, so nothing fires twice)
- window.__runPrep      18856
- window.__topClear     18849
- window.__resetCfg     104
- window.__pinDefaults  580
- window.__cleanProfile 169
- window.__pinDPR       179
- window.__forceSize    158    (the loop draws, and a 0x0 pane is what a fresh session gives)

Closure functions and globals called from inside the check, each confirmed by grep in C:\claudecode\dark raiders\dark_raiders.html:
- mkPeddler         8966   (builds the stall entity, pushed into G.ents so the gate at 14808 finds it within 74 units)
- extLetter         5161   (the letter the map and the ring label use, so the message names the point the way the game does)
- dist              4456
- tryExtractTick    13543  (guard only, typeof)
- tickExtractPoints 13962  (guard only, typeof)
- CFG               1577 (DEF) / 1593 (applyCfg); CFG.superhot appears at 33206-33207 as a Settings row, and is zeroed here because loop() 28254-28261 sets dt=0 with no key held when it is on. Restored by __resetCfg in the finally.
- performance.now, the same driver pattern as check 10.75 at mkfixture.ps1:11651.

Everything the check writes is restored: keys cleared, every container it marked opened put back, G.trade nulled, p.iv zeroed, the raid ended, CFG reset, profile cleaned. The peddler pushed into G.ents and every field written on the zones die with G when the raid ends.
- Not verified: - It never presses the pull key while the panel is up, so it does not prove the patch withholds the player's own pull (tryExtractTick is called with no wantCall). If that ever regressed, the stall would become a place you can board from and this check would stay green.
- One second per arm is under both the siege interval (8s at zero greed, 14008) and close to the 2 second re-ping (14065), so the arrivals and the re-ping the patch also unfreezes are NOT measured. Nor are the raider waves (13569).
- It reads the fields the labels are built from - Z.beaconT, Z.hold, cz.open - not the drawn pixels. It does not trace the text at 23781 or 23794, so a build that froze the label some other way would pass.
- It does not cover the identical early return in the seal-cut branch at 14798, which freezes the same clocks while he cuts a seal. That is its own finding and its own build.
- G.trade exists only in the real game (9096: the bot path returns early), so the bot sim cannot see any of this and no extract-rate number will move.
- The staging line is the soft spot: if E beside the stall does not open the panel (an unexpected E claimant near the drop, or a container the 220-unit sweep missed), the check reports 'staging:' and then measures with G.trade set by hand. That still exercises the same gate, but it means a red staging line is about the fixture, not the fix.
- dt is clamped to 0.05 at 28223, so the first frame of every arm is 50ms and the drive is about 1.04s, not exactly 1.00s; every assertion is a ratio against the raid clock measured in the same frames, so this does not matter, but no arm should be rewritten to assert an absolute number of seconds.

### anchor 1 (reported match count 1): The one line that returns out of updatePlayer while the trade window is open, above the only real-game call to tryExtractTick at 15129. Verified verbatim with a whole-line grep on C:\claudecode\dark raiders\dark_raiders.html: exactly one match, at line 14934, two leading spaces, no trailing space. The near-neighbours 14382 and 15128 are bare tickRegen(dt); lines and do not match this pattern.
OLD:
```
  if(G.trade){ tickRegen(dt); return; }
```
NEW:
```
  if(G.trade){
    tickRegen(dt);
    // v12.31, from the 2026-09-07 read-only audit (trade-freeze): THE STALL IS NOT
    // A PAUSE. This return skips the whole tail of updatePlayer, and the only real
    // call to tryExtractTick lives down there, so every extraction clock stopped
    // dead for as long as the trade window was up: the inbound countdown, the 30
    // second boarding window, the siege arrivals, the 2 second re-ping, the mirrors
    // the HUD reads, the closing of a point whose time has come, and the raider
    // waves. Nothing else stopped. loop() gates on none of this: it keeps adding to
    // G.t, keeps taking dt off G.timeLeft, and runs updateEnts, updateBullets and
    // updateThrowables on the next three lines of the same frame. So the raid clock
    // and the machines ran on while the label over the ring held EXTRACT A INBOUND
    // at whatever second the panel opened, and a landed extraction never left while
    // he shopped. Same fault and same fix as the two branches above: the downed
    // branch and the roll branch both carry this call past their own early return,
    // and the downed one says why in as many words. No wantCall, exactly as in the
    // roll: E belongs to the panel while it is open, so the clocks run and no pull
    // of his own does.
    tryExtractTick(dt);
    return;
  }
```
### what the check says it measures
the Peddler stall is not a pause: with the trade window open the inbound extraction still counts down, a landed extraction still spends its boarding window, and an extraction point whose closing time passes while he shops still closes, measured against the raid clock, which never stopped (2026-09-07 read-only audit, trade-freeze)
### check body
```js
if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__loop&&window.__keys&&window.__runPrep&&window.__topClear&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__pinDPR&&window.__forceSize)) return 'SKIP: this fixture cannot deploy and drive the live loop';
if(typeof mkPeddler!=='function'||typeof tryExtractTick!=='function'||typeof tickExtractPoints!=='function'||typeof extLetter!=='function'||typeof dist!=='function') return 'SKIP: no stall or extraction tick in this build';
var bad=[], K=null, hid=[], i, f, base=performance.now()+50;
function drive(n){ for(f=0;f<n;f++){ base+=16.7; __loop(base); } }
try{
  __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile(); __pinDPR(1); __forceSize(1920,1080);
  CFG.superhot=0;                       // a Settings dial that would zero dt with no key held
  __deploy({kit:[],safe:null,mapIx:0,seed:4242});
  var g=__state(); if(!g||!g.zones||!g.zones.length) return 'SKIP: no raid with extraction points';
  var p=g.player, Z=null;
  for(i=0;i<g.zones.length&&!Z;i++) if(g.zones[i].open) Z=g.zones[i];
  if(!Z) return 'SKIP: no open extraction point';
  K=__keys(); for(var k0 in K) K[k0]=false;
  p.downed=false; p.hp=p.maxhp; p.iv=999;
  // The crates by his feet are marked searched so the stall wins E, which is the
  // resolution the game itself uses. Every one is put back in the finally.
  for(i=0;i<g.containers.length;i++){ var CU=g.containers[i]; if(!CU.opened&&dist(CU,p)<220){ CU.opened=true; hid.push(CU); } }
  var pd=mkPeddler(p.x+30,p.y,g.map); g.ents.push(pd);
  // OPEN THE STALL THE WAY HE DOES: one frame with E down, one with it up.
  K['KeyE']=true; drive(1); K['KeyE']=false; drive(1);
  if(g.trade!==pd){ bad.push('staging: E beside the stall did not open the trade window through the real loop, so the arms below ran with it set by hand'); g.trade=pd; }
  // ARM ONE, THE INBOUND EXTRACTION. 17.5 seconds out, 411 on the raid clock: two
  // numbers no default produces (extractWait is 25, raidSec is 540).
  g.raidLen=540; g.timeLeft=411;
  Z.beaconT=17.5; Z.hold=null; Z.holdMax=null; Z.pullT=null; Z.pinged=0; g.active=Z; g.beaconT=17.5;
  var tl0=g.timeLeft, b0=Z.beaconT;
  drive(60);
  var bNow=(Z.beaconT===null||Z.beaconT===undefined)?0:Z.beaconT;
  var tlD=tl0-g.timeLeft, bD=b0-bNow;
  if(g.trade!==pd) bad.push('control: the stall shut during the first arm, so nothing was measured');
  else if(tlD<0.2) bad.push('control: the raid clock did not run in the frames driven (it fell '+tlD.toFixed(2)+'s), so this ruler cannot see a frozen clock');
  else if(bD<tlD*0.5) bad.push('with the stall open the raid clock fell '+tlD.toFixed(2)+'s and the inbound extraction fell '+bD.toFixed(2)+'s: the point still reads EXTRACT '+extLetter(Z)+' INBOUND '+Math.ceil(bNow)+'s and nothing is getting any closer');
  // ARM TWO, THE LANDED EXTRACTION: on the ground with 9.5s of boarding window left.
  Z.beaconT=0; Z.hold=9.5; Z.holdMax=30; Z.pullT=null; g.active=Z; g.shipHold=9.5;
  var tl1=g.timeLeft, h0=Z.hold;
  drive(60);
  var hNow=(Z.hold===null||Z.hold===undefined)?0:Z.hold;
  var tlD1=tl1-g.timeLeft, hD=h0-hNow;
  if(g.trade===pd&&tlD1>=0.2&&hD<tlD1*0.5) bad.push('with the stall open a landed extraction held its '+h0+'s boarding window through '+tlD1.toFixed(2)+'s of raid clock, so it waits for as long as he shops');
  // ARM THREE, THE CLOSING POINT, which needs no call at all and is the commoner
  // case: a point whose closing time passes while he trades should shut.
  var CZ=null;
  for(i=0;i<g.zones.length&&!CZ;i++) if(g.zones[i]!==Z&&g.zones[i].open&&g.zones[i].closeAt!==undefined) CZ=g.zones[i];
  if(CZ){
    Z.beaconT=null; Z.hold=null; Z.pullT=null; g.beaconT=null; g.shipHold=null;
    CZ.warned=1; g.timeLeft=CZ.closeAt+0.4;
    drive(60);
    if(g.trade===pd&&g.timeLeft<=CZ.closeAt&&CZ.open) bad.push('with the stall open extraction '+extLetter(CZ)+' is still marked open at '+g.timeLeft.toFixed(1)+'s against a closing time of '+CZ.closeAt+', so the map keeps offering a point that has gone');
  }
  // THE CONTROL: shut the stall and the same frames move the same clock.
  g.trade=null;
  g.timeLeft=411; Z.beaconT=17.5; Z.hold=null; Z.holdMax=null; Z.pullT=null; g.active=Z; g.beaconT=17.5;
  var tl2=g.timeLeft, b2=Z.beaconT;
  drive(60);
  var b2Now=(Z.beaconT===null||Z.beaconT===undefined)?0:Z.beaconT;
  var tlD2=tl2-g.timeLeft, bD2=b2-b2Now;
  if(tlD2<0.2) bad.push('control: the raid clock did not run with the stall shut either, so the driver is broken and the arms above prove nothing');
  else if(bD2<tlD2*0.5) bad.push('control: with the stall SHUT the inbound extraction still did not move (raid clock '+tlD2.toFixed(2)+'s, extraction '+bD2.toFixed(2)+'s), so the arms above prove nothing');
}catch(err){ bad.push('threw: '+(err&&err.message||err)); }
finally{
  try{ if(K) for(var k1 in K) K[k1]=false; }catch(_k){}
  for(i=0;i<hid.length;i++) hid[i].opened=false;
  try{ var g2=__state(); if(g2){ g2.trade=null; if(!g2.over){ g2.player.downed=false; g2.player.iv=0; __endRaid('abandon'); } } }catch(_e){}
  try{ __resetCfg(); }catch(_c){}
  __topClear(); __cleanProfile();
}
return bad.length?bad.join('; '):null;
```

## 2. A hit on the corpse re-downs a dead man during the death beat  [key: corpse-redown]

- Still open: STILL OPEN. First, a correction to the stated tree state: the prompt says v12.27 with 1228 unapplied, but `C:\claudecode\dark raiders\dark_raiders.html` line 1361 reads `var VER='12.28';` and DEVNOW at line 28738 reads `now:'v12.28: his note of 2026-09-07 (Peddler purchases...'`, so build 1228 IS applied and the queue in tools\handoff now runs to 1232. I verified every line below against the file as it stands today, not against the v12.23 numbers.

The defect. killPlayer (line 12123) does NOT end the raid on a live run; it opens a 1.5 second beat and leaves the body in the world with the downed flag CLEARED:

  12128    p.hp=0; p.downed=false;
  12129    G.tel.deathKiller=p.pendKiller||src||'other';
  12133    if(G.sim){ endRaid('dead'); return; }
  12134    if(G.deathBeat===undefined||G.deathBeat===null){
  12135      G.deathBeat=1.5; p.dying=true;

loop() keeps running the world underneath that beat, bullets included (line 28269-28276):

  28269  if(!G.paused&&!G.over&&G.deathBeat!==undefined&&G.deathBeat!==null){
  28271    G.deathBeat-=dt;
  28272    var bdt=dt*0.25;
  28274    refreshVseg(); updateEnts(bdt); updateBullets(bdt); updateThrowables(bdt);
  28276    if(G.deathBeat<=0){ endRaid('dead'); }

and updateBullets has no dead/dying test on the player hit (line 17997):

  17997          if(dist(b,p)<p.r+3){ damagePlayer(b.dmg,b.owner.kind,b.owner.name,b.x-b.vx*0.05,b.y-b.vy*0.05); spark(b.x,b.y,'#ff5a4a',10,200); hit=true; }

damagePlayer (line 12139) opens with no dead guard at all. Its only early return is invulnerability, and killPlayer never sets iv:

  12139  function damagePlayer(amt,src,srcName,sx,sy){
  12150    var p=G.player;
  12151    if(p.iv>0) return;

So a round on the corpse walks straight past `if(p.downed)` (12191, false since killPlayer cleared it), takes hp negative, and lands in the down branch, which fires all three symptoms:

  12245  p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
  12271      G.tel.downs++;
  12276      say(p.revived?('DOWN. Your one self-revive is spent. Crawl for an extraction'...
  12277                   :'DOWN. '+keyLabel('KeyF','F')+' to get back up. You get one per raid.');

And the killer rename is a separate, earlier write in the same function, above even the iv test in effect (line 12169), which is exactly what the KILLED IN ACTION card prints:

  12169    G.tel.lastHitName=srcName||null;
  19019      var kn=(T.lastHitName&&T.deathKiller!=='timer')?T.lastHitName:String(T.deathKiller||'unknown').toUpperCase();
  19038      s.textContent='KILLED BY '+kn+(T.deathDistExtract?',  '+metres(T.deathDistExtract)+'M FROM EXTRACTION':'');

Note deathKiller itself is frozen correctly at 12129, so the card disagrees with the ledger row: killer:T.deathKiller (18490) names the real killer while the card names whoever last touched the corpse. Every other damage source funnels through the same function (lightning 5261, frag 11776, howler 11848, listener 16534/16544, crawler 17073), and the crawler is the only one with a `!p.downed` guard, which is false during the beat, so it hits the corpse too.

Nothing later fixes it: no build between v12.23 and v12.28 touched damagePlayer, killPlayer or the beat, and none of the four unapplied drafts p1229-p1232 mentions damagePlayer, killPlayer, deathBeat, pendKiller or lastHitName (grepped). The corpus has no check on the death beat at all: grep for deathBeat in tools\mkfixture.ps1 returns only the comment on the __loop hook at line 526.
- Balance risk: DEFECT FIX, not a dial. No in-raid difficulty moves, and the change is provably invisible to every measurement.

The outcome is already settled before the guard can act. killPlayer has set hp to 0, cleared downed and stamped deathKiller; the only exit from the beat is endRaid('dead') at 28276. The guard cannot save a player, cannot kill one, cannot alter the fight, and changes no PRNG draw on any path that decides anything (updateBullets still steps the round, still calls spark, still sets hit and splices it, so the bullet stream is untouched; the guard returns before decal(), whose rnd() calls sit inside damagePlayer and only ever ran on an already-dead man).

It is bit-identical under the sim. killPlayer line 12133, `if(G.sim){ endRaid('dead'); return; }`, means G.deathBeat and p.dying are never set in a sim raid, so the guard condition is never true in a batch. Every bot number, every 320-seed paired A/B and the extract rate are unchanged by construction, not by measurement.

What it does change is presentation and telemetry, all of it wrong today: a phantom DOWN toast over the death fade, G.tel.downs (printed on the run report and in the profile stats card at 30912), the killer name on the KILLED IN ACTION card, and G.tel.dmg credited to a machine that shot a corpse. Correcting a count of downs that never happened is a defect fix under his no-balancing rule; it moves no CFG dial and touches no difficulty constant.

One vocabulary note: nothing in the patch or the check writes player-facing copy, so pillager/tactical belt/Undercroft/extraction are not at stake.
- Control failure claimed: On today's build (v12.28, unpatched) the check returns a FAILURE string, all six clauses firing, joined by semicolons:

"a hit on the body during the death fade counts another DOWN: the report goes from 1 to 2 on a man who is already dead; a hit on the body during the death fade puts the dead man back into the downed state; a hit on the body during the death fade throws a toast over the death fade: DOWN. F to get back up. You get one per raid.; a hit on the body during the death fade renames the killer: it was DUSTMAN ALPHA NINE and is now CORPSE ROBBER SEVEN; the KILLED IN ACTION card reads "KILLED BY CORPSE ROBBER SEVEN", naming the machine that shot the corpse; the KILLED IN ACTION card reads "KILLED BY CORPSE ROBBER SEVEN", and does not name DUSTMAN ALPHA NINE, who actually killed him"

(the card line may carry a trailing ",  NNM FROM EXTRACTION" depending on where seed 4242 drops him; the assertions are indexOf tests, so that does not matter.)

With the patch applied the guard at the head of damagePlayer returns before any stamp, so downs stays 1, p.downed stays false, no new toast is said, lastHitName stays DUSTMAN ALPHA NINE, the card reads KILLED BY DUSTMAN ALPHA NINE, bad is empty and the check returns null.

Why the control is real, not a level. The two control clauses at the top (killer0 must be 'sentry', name0 must be KILLER) prove the check staged the death it thinks it staged before it measures anything, so it cannot pass by never reaching the beat. And every assertion measures a CHANGE across the corpse hit against a baseline taken one line after killPlayer fired, not a fixed value, so it cannot pass because some number happened to be zero. The bullet-consumed test (g.bullets.indexOf(cb)) behaves identically on both builds -- updateBullets sets hit=true and splices the round whether or not damagePlayer does anything with it -- so it is a genuine did-the-round-land signal and not a proxy for the fix.
- Hooks used: Fixture hooks, each confirmed by grepping "^window.<name>=" in C:\claudecode\dark raiders\tools\mkfixture.ps1 (1 match each):
- window.__deploy (line 18965) - stages the kit through commitKit and starts a LIVE raid (sim omitted, so sim:false); the only path that lands a real player.
- window.__state (84) - returns G, for tel, player, bullets, deathBeat.
- window.__loop (530) - loop(ts). The comment at line 526 says outright that deathBeat and the whole live-raid frame path exist only inside loop(), which is exactly why the corpse hit is driven through it.
- window.__endRaid (135) - endRaid(how). Outcomes used: 'dead' for the card, 'abandon' in the finally. Both real; there is no 'death' or 'timeout'.
- window.__P (191) - the profile, for snapshot and restore.
- window.__resetCfg (104) - CFG back to DEF before staging.
- window.__pinDefaults (580) - map 0 pin, so the raid is the standard one.
- window.__cleanProfile (169) - clears terms/hotAssign/uiScale/cond/cosOutfit that an earlier check may have left; note it itself calls saveProfile, which is why the finally restores terms, cond and cosOutfit and saves again.
- window.__pinDPR (179) and window.__forceSize (158) - the 1080p ruler, both optional and wrapped, so a 0x0 pane cannot turn this red for the pane instead of the build.
- window.__topClear (18849) - shuts the outcome card in the finally so the next check does not aim at the DOM through it.

Closure functions and closure variables called directly from inside the check (checks run inside the game IIFE), each confirmed in C:\claudecode\dark raiders\dark_raiders.html:
- updateBullets (defined line 17763, 1 match) - drives steps 1 and 2 deterministically, and is the same function the death beat calls at 28274.
- damagePlayer (12139, 1 match) - reached only through updateBullets, never called by hand.
- killPlayer (12123, 1 match) - reached only through the downed branch at 12197, never called by hand.
- endRaid (18464, 1 match) - through __endRaid.
- saveProfile (2426, 1 match) - in the finally.
- say - reassigned to a recorder and restored; the fixture itself sets say at mkfixture.ps1 line 1104 and checks at 6816, 7209 and 11647 already reassign it the same way.
- CFG - read and fully snapshot/restored; used directly by fixture code (mkfixture 279) and by checks (5943, 6092, 6989).
- lastTs - the module-level frame stamp declared at dark_raiders.html line 28051 (var state='hub',lastTs=0;). Snapshot and restored, so this check cannot leave a future timestamp that makes a later check's __loop see dt=0.

Everything the check touches and restores: say; CFG (every key); lastTs; P.stash, P.kit, P.weapons, P.equipped, P.equippedSec, P.safe, P.hotAssign, P.freeKit, P.kitChosen, P.dropKit, P.mapIx, P.terms, P.cond, P.cosOutfit, P.tuned, P.gameOpts, P.log, then saveProfile; the live raid (ended, and G.bullets emptied); the outcome card (__topClear). Nothing on the player or G.tel needs restoring because G and G.player are rebuilt by the next buildRaid. No prototype hook is installed.
- Not verified: What this check cannot see:

1. The picture. It never renders the death fade, so it does not prove the DOWN toast was actually drawn over the red field, only that say() was called with it. The toast text is read out of the say recorder, not off the canvas; a textTrace-based twin would be needed to prove the pixels.

2. The other things the guard now suppresses on a corpse: voxGrunt (12146), the screen shake (12161 and 12235), hitFlash, the blood decal at 12236, and the G.tel.hitLog row at 12186. The check asserts none of them. If suppressing the corpse decal turns out to read badly during the fade, this check will not notice.

3. G.tel.dmg. The guard also stops damage being credited to whoever shot the corpse (12182 is above the sim guard inside _logHit), which changes the damage-taken figure on the run report. That is the same defect, but the check does not assert it, so a future change that re-opens only that half would pass.

4. The non-bullet sources. The check drives the corpse hit through updateBullets only. Lightning (5261), the frag blast (11776), the howler shell (11848), the listener (16534, 16544) and the crawler bite (17073) all reach damagePlayer too and are all covered by the same top-of-function guard by inspection, not by measurement.

5. Whether other machines fire on the corpse in the two __loop frames. If they do, on the unpatched build the failure is simply louder; on the patched build the guard blocks them too, so the assertions hold either way. But the check does not distinguish its own staged round from theirs, so it cannot report which enemies were shooting a corpse in a real fight.

6. Volume. It proves the defect on one map (0), one seed (4242) and one staged death. It says nothing about how often a real raid actually lands a round inside the 1.5 second window, which is a question only his own runs or a live watch can answer, and the bot cannot: killPlayer ends a sim raid before the beat exists, so no batch has ever executed this code.

7. The build number. The comment in new_lines says v12.33 because the tree reads VER='12.28' and drafts 1229-1232 are queued unapplied. If this ships at a different number the comment must be renumbered; the anchor itself is unaffected, since none of those four drafts touches damagePlayer, killPlayer, deathBeat, pendKiller or lastHitName.

### anchor 1 (reported match count 1): One guard at the very top of damagePlayer closes all three symptoms at once (the toast, the downs count, the killer rename) and covers every damage source, because lightning, frags, the howler, the listener, the crawler and every bullet all funnel through this one function. It must sit above line 12169 (G.tel.lastHitName=srcName||null) and above the hitFrom/hurtAt stamps, since those run before the iv test and the rename is what reaches the card. Both halves of the condition are set only by killPlayer at line 12135 (G.deathBeat=1.5; p.dying=true) and both are per-raid, since G and G.player are rebuilt by buildRaid, so the guard cannot leak into a later raid. null is treated as not-dead to match killPlayer's own test at 12134. Verified verbatim with a multiline grep against the live file: exactly 1 match. Build number: I have numbered it v12.33 because the tree is at v12.28 and tools\handoff already holds unapplied drafts 1229-1232; none of those four touches damagePlayer, killPlayer, deathBeat, pendKiller or lastHitName, so this anchor matches whether it is applied at 1229 or at 1233 -- only the number inside the comment needs to follow wherever it lands. new_lines contains no quote character of any kind and no non-ASCII, so it drops into a single-quoted PowerShell here-string with nothing to escape.
OLD:
```
function damagePlayer(amt,src,srcName,sx,sy){
  // v4.28: the direction of the hit, stamped for the ring around the body.
  if(G&&sx!==undefined&&G.player) G.player.hitFrom={ang:Math.atan2(sy-G.player.y,sx-G.player.x),at:G.t};
```
NEW:
```
function damagePlayer(amt,src,srcName,sx,sy){
  // v12.33, 2026-09-07 read-only audit (corpse-redown): A DEAD MAN TAKES NO MORE
  // HITS. killPlayer does not end a live raid; it opens a 1.5 second beat and
  // leaves the body in the world with p.downed CLEARED and hp at 0, and the beat
  // in loop() keeps calling updateEnts, updateBullets and updateThrowables
  // underneath it. So a round, a blade or a blast that landed on the corpse fell
  // straight past the downed branch below, took hp negative, and re-downed a man
  // who was already dead: a second DOWN toast painted over the death fade,
  // another count on G.tel.downs that the run report and the stats card both
  // print, and lastHitName rewritten, which is the name the KILLED IN ACTION card
  // reads out while the ledger row beside it still names the real killer.
  // Whoever killed him killed him.
  // ABOVE EVERY STAMP IN THIS FUNCTION on purpose. hitFrom, hurtAt and
  // lastHitName are all written before the iv test, so a guard placed any lower
  // still lets the card be renamed by a shot at a corpse.
  // Costs nothing anywhere it can be measured: killPlayer ends a sim raid outright
  // rather than running a beat, so G.deathBeat is never set under G.sim and every
  // batch and paired A/B is unchanged. The round itself still sparks, still counts
  // as a hit and is still consumed in updateBullets, so the bullet stream is
  // untouched.
  if(G&&((G.deathBeat!==undefined&&G.deathBeat!==null)||(G.player&&G.player.dying))) return;
  // v4.28: the direction of the hit, stamped for the ring around the body.
  if(G&&sx!==undefined&&G.player) G.player.hitFrom={ang:Math.atan2(sy-G.player.y,sx-G.player.x),at:G.t};
```
### what the check says it measures
a round that lands on the body during the 1.5 second death fade does not re-down a dead man: no second DOWN toast, no extra down on the run report, and the KILLED IN ACTION card still names the machine that actually killed him
### check body
```js
var bad=[];
if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__loop&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile&&window.__topClear))
  return 'SKIP: this fixture cannot deploy and drive a live raid';
if(typeof updateBullets!=='function'||typeof damagePlayer!=='function'||typeof killPlayer!=='function')
  return 'SKIP: this build has no bullet or player damage path';
var sub=document.getElementById('oc_sub');
if(!sub) return 'SKIP: this build has no run report subtitle to read';
var realSay=(typeof say==='function')?say:null;
if(!realSay) return 'SKIP: no say to listen to';
var P2=__P(), ck;
var keepP={stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),weapons:(P2.weapons||[]).slice(),
           eq:P2.equipped,sec:P2.equippedSec,safe:P2.safe,hot:P2.hotAssign,free:P2.freeKit,
           chosen:P2.kitChosen,drop:(P2.dropKit||[]).slice(),mapIx:P2.mapIx,
           terms:(P2.terms||[]).slice(),cond:P2.cond,cos:P2.cosOutfit,
           tuned:P2.tuned,gopts:P2.gameOpts,log:(P2.log||[]).slice()};
var keepCfg={}; for(ck in CFG) keepCfg[ck]=CFG[ck];
var keepTs=lastTs;
var said=[];
// Two names no machine on any map is ever called, so nothing below can pass by
// agreeing with a real killer that happened to be standing there.
var KILLER='DUSTMAN ALPHA NINE', ROBBER='CORPSE ROBBER SEVEN';
try{
  __resetCfg(); __pinDefaults(0); __cleanProfile();
  try{ if(window.__pinDPR) __pinDPR(1); if(window.__forceSize) __forceSize(1920,1080); }catch(_fs){}
  P2.freeKit=0; P2.hotAssign={}; P2.safe=null;
  __deploy({kit:[],safe:null,mapIx:0,seed:4242});
  var g=__state();
  if(!g||!g.player) return 'SKIP: no live raid to kill anyone in';
  if(g.sim) return 'SKIP: the death beat never runs under the sim';
  var p=g.player;
  say=function(m){ said.push(String(m)); return realSay.apply(null,arguments); };
  // A real enemy round, on the real bullet path, sitting inside his own body so
  // the player-hit test at the head of updateBullets cannot miss it.
  var shoot=function(kind,name,dmg){
    var b={x:p.x-2,y:p.y,vx:60,vy:0,dmg:dmg,life:2,player:false,owner:{kind:kind,name:name}};
    g.bullets.push(b); return b;
  };
  // 1. HE GOES DOWN.
  p.iv=0; p.armor=0; p.hp=30; p.downed=false; p.downT=0; p.revived=false; p.cooking=0;
  shoot('sentry',KILLER,999); updateBullets(0.016);
  if(!p.downed) return 'SKIP: the staged round did not put him on the floor';
  // 2. AND THEN HE DIES, a second round while he is down, which is what opens the beat.
  p.downT=1;
  shoot('sentry',KILLER,9); updateBullets(0.016);
  if(!(g.deathBeat>0)) return 'SKIP: the second round did not open the death beat';
  var downs0=g.tel.downs, killer0=g.tel.deathKiller, name0=g.tel.lastHitName, said0=said.length;
  if(killer0!=='sentry') bad.push('control: the death is recorded against '+killer0+' rather than sentry, so this is not the death it staged');
  if(name0!==KILLER) bad.push('control: at the moment of death the last hit names '+name0+' rather than '+KILLER);
  // 3. A ROUND LANDS ON THE BODY, inside the beat, through the real frame. The
  // first __loop is a warm-up so lastTs is below the timestamps driven here and
  // dt cannot come out zero or negative from whatever the last check left.
  var t0=(lastTs||0)+1000;
  __loop(t0);
  var cb=shoot('howler',ROBBER,12);
  __loop(t0+16.7);
  if(g.bullets.indexOf(cb)>=0) return 'SKIP: the round aimed at the body never reached it';
  if(!(g.deathBeat>0)) return 'SKIP: the death beat ran out before the body was hit';
  // WHAT HE WOULD SEE.
  if(g.tel.downs!==downs0) bad.push('a hit on the body during the death fade counts another DOWN: the report goes from '+downs0+' to '+g.tel.downs+' on a man who is already dead');
  if(p.downed) bad.push('a hit on the body during the death fade puts the dead man back into the downed state');
  var newSaid=said.slice(said0).join(' | ');
  if(newSaid.indexOf('DOWN. ')>=0) bad.push('a hit on the body during the death fade throws a toast over the death fade: '+newSaid);
  if(g.tel.lastHitName!==name0) bad.push('a hit on the body during the death fade renames the killer: it was '+name0+' and is now '+g.tel.lastHitName);
  // 4. AND THE CARD ITSELF, which is where he actually reads the name.
  __endRaid('dead');
  var line=String(sub.textContent||'');
  if(line.indexOf(ROBBER)>=0) bad.push('the KILLED IN ACTION card reads "'+line+'", naming the machine that shot the corpse');
  if(line.indexOf(KILLER)<0) bad.push('the KILLED IN ACTION card reads "'+line+'", and does not name '+KILLER+', who actually killed him');
}
finally{
  try{ say=realSay; }catch(_s){}
  try{ var gg=__state(); if(gg&&gg.bullets) gg.bullets.length=0; }catch(_b){}
  try{ if(__state()&&!__state().over) __endRaid('abandon'); }catch(_e){}
  for(ck in keepCfg) CFG[ck]=keepCfg[ck];
  lastTs=keepTs;
  P2.stash=keepP.stash; P2.kit=keepP.kit; P2.weapons=keepP.weapons;
  P2.equipped=keepP.eq; P2.equippedSec=keepP.sec; P2.safe=keepP.safe;
  P2.hotAssign=keepP.hot; P2.freeKit=keepP.free; P2.kitChosen=keepP.chosen;
  P2.dropKit=keepP.drop; P2.mapIx=keepP.mapIx; P2.terms=keepP.terms;
  P2.cond=keepP.cond; P2.cosOutfit=keepP.cos;
  P2.tuned=keepP.tuned; P2.gameOpts=keepP.gopts; P2.log=keepP.log;
  try{ saveProfile(); }catch(_p){}
  try{ __topClear(); }catch(_t){}
}
return bad.length?bad.join('; '):null;
```

## 3. v12.31 - F already held when the hit lands must not spend the one self-revive (f-held-revive)  [key: f-held-revive]

- Still open: STILL OPEN. The tree actually stamps VER='12.28' (dark_raiders.html line 1361) and WHATSNEW_VER='12.28' (line 1372), i.e. build 1228 has landed since the task prompt was written; drafts 1229 (-> v12.29) and 1230 (-> v12.30) are still unapplied and neither touches this code (grepped p1229.ps1 and p1230.ps1 for healLock/downed/selfRevive/KeyF: no matches).

The deciding lines, all quoted verbatim from the current file:

1) The revive is an edge trigger whose latch is SET ONLY INSIDE THE DOWNED BRANCH (line 14336-14337, inside updatePlayer):
    if(keys['KeyF']&&!p.healLock){ p.healLock=true; selfRevive(); }
    if(!keys['KeyF']) p.healLock=false;

2) The only other line in the whole file that touches the latch is a CLEAR, never a set (line 14742, the standing path):
  if(!keys['KeyF']) p.healLock=false;
with its own comment at 14738-14741: "the held-F heal is gone. F is the melee strike (v10.64) ... healLock is still cleared here so the downed self-revive on F keeps its edge trigger."

A full-file grep for healLock returns exactly four hits: 12658 (a comment), 14336 (the set), 14337 and 14742 (the two clears). So while the player is STANDING with F held down, healLock is false and stays false.

3) Going down does not latch it. The whole down block (line 12244-12245, in damagePlayer) is:
    if(p.cooking) releaseCook();
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
It clears the cook, the heal queue, the pulls and prep, and never touches healLock.

4) F is the melee strike, so holding it is ordinary play, and the key is polled, not edge-read, by the downed branch: line 10666 "if(code==='KeyF'&&G&&!G.over&&!G.paused&&!repeat) meleeStrike();" fires on keydown, while raidKey line 10607 "keys[code]=true;" leaves keys['KeyF'] true for as long as the finger is down (cleared only by the keyup listener at line 10787).

Chain: hand on F (melee) -> hit lands -> damagePlayer sets p.downed=true with p.healLock still false -> the very next updatePlayer frame reaches line 14336, reads keys['KeyF'] true and healLock false, and calls selfRevive() (line 14279), which sets p.hp=40, p.downed=false, p.revived=true, bumps G.tel.revives and says 'Back on your feet. That was your one.' The one self-revive is spent on the first downed frame by a key that was already down before he went down. The player then sees, on his second down, the v12.10 line at 12276: 'DOWN. Your one self-revive is spent...' for a revive he never chose to spend.

The only other place the player is downed is the nuke ending at 24997 ("p.hp=0; p.downed=true; p.downT=0;"), where tickDowned (14246) kills on the same frame before line 14336 is reached, so that path is not affected.
- Balance risk: DEFECT FIX, not a balance change. Nothing in the patch moves a dial: CFG.downTime (17), CFG.eDmg, the 40 HP the revive grants (line 14285), the one-per-raid rule (line 14281), the 30 units/second crawl and the give-up hold are all untouched. The patch adds one assignment that latches the existing edge-trigger flag at the moment the operator goes down, so the self-revive is spent by a PRESS, which is exactly what the code already intends (line 14738-14741 says healLock is kept "so the downed self-revive on F keeps its edge trigger") and what the overlay asks for on screen (line 24398: "[F] SELF-REVIVE, one per raid").

The honest caveat: a player who used to lose the revive to a phantom press now keeps it, so his survival in that specific case improves. That is the removal of an input he never made, not a difficulty dial being moved, and it is the same class as v12.23 (a cook dropped on the down) which shipped under the same house rule. In-raid difficulty for a player who never had F held is bit-identical: with F not held, healLock is false either way and the first real press still revives (that is CONTROL ONE in the check). No sim/bot behaviour changes at all - the bot's downed branch (line 15208-15209, "if(!p.revived){ selfRevive(); }") does not read healLock, so every extract-rate number is unmoved.
- Control failure claimed: On today's build (VER 12.28 in the tree, and equally on v12.29/v12.30 once drafts 1229 and 1230 land, since neither touches this code) the check returns a FAILURE string from the finding arm and nothing else. It reads, with the numbers filled in:

"F already held when the hit landed spent the one self-revive with no press meant for it: on the first downed frame he is back on his feet on 40 health and revived true, the revive ledger went 0 to 1, and the toast reads \"Back on your feet. That was your one.\""

That is one hit landing while the melee key is held, followed by two ordinary __loop frames with no new key touched. Both controls still pass on the unpatched build - control one never holds a key, and control two revives at the down and so is trivially up - so the single line above is the whole red, and it names exactly the behaviour the patch removes. With the patch applied the finding arm sees p.downed true and p.revived false after those two frames, control one still revives on the real press with the ledger moving by one, control two still revives after the release and re-press, and the check returns null.
- Hooks used: Fixture hooks, each confirmed present in C:\claudecode\dark raiders\tools\mkfixture.ps1:
- window.__deploy - defined at mkfixture.ps1 line 18965.
- window.__state - line 84.
- window.__loop - line 530 ("window.__loop=function(ts){ loop(ts); };"), and loop() at game line 28206 is the only stepper that runs updatePlayer, which is where both halves of the bug live.
- window.__endRaid - line 135 (used in finally with 'extract', one of the three real outcomes).
- window.__topClear - line 18849.
- window.__runPrep - line 18856.
- window.__resetCfg - line 104.
- window.__pinDefaults - line 580 (takes mapIx).
- window.__cleanProfile - line 169.

Game closure functions and globals the check touches directly (checks run inside the closure, so these are callable by name):
- damagePlayer(amt,src,srcName,sx,sy) - game line 12139. Called to drive the real down path, the same way the shipped v12.23 and v11.94 checks do it (mkfixture.ps1 lines 5988 and 6832).
- keys - game line 10487 ("var keys={},mouse={...}"), read to prove the synthetic key landed and reassigned to {} in finally; the shipped v11.94 check does the same at mkfixture.ps1 lines 6839 and 6841.
- mouse - same declaration, line 10487; only mouse.down is restored.
- G.tel.melee / G.tel.revives - written at game lines 12371 and 14286.
- G.msg - written by the fixture's own say override (mkfixture.ps1 lines 1103-1107), which mirrors the shipped say and is what the player reads as the toast.
- updatePlayer (game line 14292) and selfRevive (game line 14279) are typeof-probed in the SKIP guard but never called by hand: the check reaches them only through __loop, so it drives the real play path rather than a hand-driven artefact.
- Key delivery is a synthetic KeyboardEvent dispatched on window ONLY (never window plus document), which reaches raidKey (game line 10606, "keys[code]=true;") for the press and the keyup listener at game line 10787 for the release.
- Not verified: - It never draws a frame. It does not check that the DOWN overlay, the bleed bar, or the "[F] SELF-REVIVE, one per raid" line (game line 24386-24398) are actually on screen while he is down; it asserts on p.downed, p.revived, p.hp, G.tel.revives and the toast text. A __textTrace/__frame arm could cover that and is deliberately left out to keep the check to one frame budget.
- It does not exercise the gamepad. PADMAP 13 maps D-pad down to 'KeyF' (game line 11179) and padHold writes the same keys slot (lines 11376 and 11316), so the fix covers a held D-pad by construction, but no pad input is simulated.
- It does not cover the nuke down at game line 24997 (p.downT=0, killed by tickDowned on the same frame), and it does not cover a real bullet: damagePlayer is called directly rather than through updateBullets.
- It cannot see the bot. The sim's downed branch (game line 15208-15209) auto-revives and never reads healLock, so nothing here says anything about extract rate, and per the standing note the bot never plays this state anyway.
- It does not test human hand timing: a real player might release F within the same frame the hit lands, which is indistinguishable here.
- The exact revive health is asserted as a band (above 0, at most 40) rather than exactly 40, so a stray enemy round landing inside the six control frames cannot turn the check red for the wrong reason; the exact 40 appears only in the failure text.
- NUMBERING CAVEAT, not verified by the source alone: the task brief says the tree is v12.27, but dark_raiders.html line 1361 reads var VER='12.28' and line 1372 var WHATSNEW_VER='12.28', and mkfixture.ps1 already carries a {v:'12.28'} entry at line 5735, so build 1228 has landed. With 1229 (-> v12.29) and 1230 (-> v12.30) queued ahead of this one, this spec is written as build 1231 / v12.31 and its corpus entry as {v:'12.31'}, inserted immediately before the {v:'12.30'} header that f1230 creates. If 1229 and 1230 are dropped or reordered, renumber the check version, both patch comments and the stamps to match - the anchors themselves are unaffected, since neither p1229.ps1 nor p1230.ps1 touches damagePlayer, updatePlayer, healLock or selfRevive.

### anchor 1 (reported match count 1): The down moment is the only place the latch can be set before the downed branch ever runs. Verified verbatim: line 12244 carries four leading spaces, line 12245 carries none (that odd indentation is in the shipped file and is preserved). Grep of the escaped line 12245 text returns exactly one hit (12245); grep of "if(p.cooking) releaseCook();" returns exactly one hit (12244), so the two-line block matches once. keys is in scope here (var keys={} at line 10487, same IIFE, and damagePlayer is a top-level function of that IIFE). !! is used because keys[code] is set to false, not deleted, by the keyup listener at 10787, and because the pad path (padHold('KeyF',...) at 11376 into line 11316) writes the same slot, so a held D-pad down is covered too. Assigning unconditionally (rather than only setting true) is deliberate: if F is not held at the down, the latch is cleared, so the first real press still revives.
OLD:
```
    if(p.cooking) releaseCook();
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
```
NEW:
```
    if(p.cooking) releaseCook();
    // v12.31, 2026-09-07 read-only audit (f-held-revive): A KEY ALREADY DOWN IS
    // NOT A PRESS. healLock is the edge latch for the self-revive and it is SET
    // in exactly one place, inside the downed branch of updatePlayer; the two
    // other lines that name it only CLEAR it. So a hand already resting on F
    // when the hit landed arrived on the floor with the latch clear, and the
    // first downed frame read that held key as a fresh press and spent the one
    // self-revive with no decision made. F is the melee strike since v10.64, so
    // holding it through a fight is ordinary play, and the man then paid for it
    // on his second down with the v12.10 line telling him a revive he never
    // chose was gone. Latched here, at the instant he goes down: the revive now
    // waits for a release and a real press, which is what the DOWN overlay asks
    // for, and the clear on the next frame still frees that press.
    p.healLock=!!keys['KeyF'];
p.hp=0; p.downed=true; p.downT=CFG.downTime; p.pendKiller=src; p.prep=null; p.prepA=null;
```
### anchor 2 (reported match count 1): Comment only, no behaviour change: it puts the reason at the site a future reader will find first. Verified: grep of the escaped line 14336 text returns exactly one hit (14336) and 14337 is the following line; the only other copy of the clear (line 14742) has two leading spaces, not four, and is not preceded by the set, so the pair is unique. Safe to drop this anchor if a later draft renumbers around it - the fix itself is anchor 1.
OLD:
```
    if(keys['KeyF']&&!p.healLock){ p.healLock=true; selfRevive(); }
    if(!keys['KeyF']) p.healLock=false;
```
NEW:
```
    // v12.31, audit (f-held-revive): THE OTHER HALF OF THE EDGE. The latch below
    // is set only in here, so this line used to read a key that was already down
    // before he went down as a press, and the one self-revive was spent on the
    // first downed frame. damagePlayer latches it at the moment he goes down now;
    // the clear on the line after still frees the real press that follows.
    if(keys['KeyF']&&!p.healLock){ p.healLock=true; selfRevive(); }
    if(!keys['KeyF']) p.healLock=false;
```
### what the check says it measures
F already held when the hit lands does not spend the one self-revive: put down with the strike key held he stays on the floor with the revive unspent, letting go and pressing F still stands him up, and a down with nothing held still revives on the first real press (2026-09-07 read-only audit)
### check body
```js
     if(!(window.__deploy&&window.__state&&window.__loop&&window.__endRaid)) return 'SKIP: this fixture cannot deploy and press keys in a raid';
     if(typeof damagePlayer!=='function'||typeof updatePlayer!=='function'||typeof selfRevive!=='function') return 'SKIP: no down or revive path in this build';
     var bad=[];
     function press(code,key){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true})); }
     function release(code,key){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:key,bubbles:true,cancelable:true})); }
     function frames(n){ var t0=performance.now(); for(var i=0;i<n;i++) __loop(t0+i*16.7); }
     // One staged down, distinctive on purpose: 88 health, no plate, the latch
     // explicitly CLEAR before the hit, so a pass can never come from a stale latch.
     function putDown(g,p){
       var en=null; for(var i=0;i<g.ents.length&&!en;i++) if(g.ents[i].kind==='crawler'&&!g.ents[i].downed) en=g.ents[i];
       p.hp=88; p.armor=0; p.iv=0; p.roll=0; p.downed=false; p.revived=false; p.healLock=false;
       p.cooking=0; p.cookT=0; p.cookKind=null; p.giveT=0;
       damagePlayer(240,en,en?en.kind:'crawler',p.x+20,p.y);
       return en;
     }
     try{
       // THE FINDING. F is the melee strike, so a hand on it when the hit lands is ordinary play.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       keys={}; p.hp=88; p.armor=0; p.iv=0; p.roll=0; p.downed=false; p.revived=false; p.healLock=false;
       var mel0=(g.tel&&g.tel.melee)||0, rev0=(g.tel&&g.tel.revives)||0;
       press('KeyF','f'); frames(3);
       // Without these two the whole check is a silent probe: a synthetic key that
       // never reached the game would make the finding arm pass for nothing.
       if(!keys['KeyF']) bad.push('setup: the held F never reached the game, so nothing below proves anything');
       if(!(((g.tel&&g.tel.melee)||0)>mel0)) bad.push('setup: the held F swung no strike (melee '+mel0+' to '+((g.tel&&g.tel.melee)||0)+'), so the key is not really down');
       if(p.downed) bad.push('setup: the strike put him on the floor by itself');
       putDown(g,p);
       if(!p.downed) bad.push('setup: a 240 hit on 88 health did not put him down (health '+Math.round(p.hp)+')');
       frames(2);
       if(!p.downed||p.revived)
         bad.push('F already held when the hit landed spent the one self-revive with no press meant for it: on the first downed frame he is '+(p.downed?'down but':'back on his feet on '+Math.round(p.hp)+' health and')+' revived '+p.revived+', the revive ledger went '+rev0+' to '+((g.tel&&g.tel.revives)||0)+', and the toast reads "'+(g.msg||'')+'"');
       release('KeyF','f'); frames(1);
       // CONTROL ONE: nothing held at all. He stays on the floor, and a REAL press
       // still stands him up on the revive health, so the fix has not killed F.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; keys={};
       var rev1=(g.tel&&g.tel.revives)||0;
       putDown(g,p);
       if(!p.downed) bad.push('control one: the hit did not put him down');
       frames(6);
       if(!p.downed||p.revived) bad.push('control one: he came off the floor with no key held at all (downed '+p.downed+', revived '+p.revived+')');
       press('KeyF','f'); frames(2); release('KeyF','f'); frames(1);
       if(p.downed||!p.revived||!(p.hp>0&&p.hp<=40)) bad.push('control one: a real press of F no longer revives (downed '+p.downed+', revived '+p.revived+', health '+Math.round(p.hp)+', wanted up on 40)');
       if(((g.tel&&g.tel.revives)||0)!==rev1+1) bad.push('control one: the revive ledger did not move on the real press ('+rev1+' to '+((g.tel&&g.tel.revives)||0)+')');
       // CONTROL TWO: held through the down, then let go and press again. The one
       // revive is still there, so the latch delays the press, it does not eat it.
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       g=__state(); p=g.player; keys={};
       press('KeyF','f'); frames(2);
       putDown(g,p); frames(2);
       release('KeyF','f'); frames(2);
       press('KeyF','f'); frames(2);
       if(p.downed||!p.revived) bad.push('control two: after the hand let go and pressed F again the revive did not fire (downed '+p.downed+', revived '+p.revived+', health '+Math.round(p.hp)+')');
       release('KeyF','f'); frames(1);
     }catch(err){ bad.push('threw: '+(err&&err.message||err)); }
     finally{
       try{ release('KeyF','f'); release('Space',' '); }catch(_k){}
       try{ keys={}; mouse.down=false; }catch(_k2){}
       try{ var g2=__state(); if(g2&&g2.player){ var p2=g2.player;
         p2.downed=false; p2.revived=false; p2.healLock=false; p2.hp=100; p2.armor=0;
         p2.downT=0; p2.giveT=0; p2.pendKiller=null; p2.iv=0;
         p2.cooking=0; p2.cookT=0; p2.cookKind=null;
         if(!g2.over) __endRaid('extract'); } }catch(_e){}
       __topClear(); __resetCfg(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null;
```

## 4. v12.31 gun-slot-reconcile: an extraction rewrites gun 1 from the tier sort and leaves gun 2 naming the same gun, so the next raid comes up with fists in slot 2  [key: gun-slot-reconcile]

- Still open: STILL OPEN. Read at the live tree (the file now reads var VER='12.28' at line 1361, so build 1228 has landed since the prompt was written; 1229 and 1230 are still queued and neither touches this region).

The rewrite, C:\claudecode\dark raiders\dark_raiders.html:18740-18746, inside endRaid's how==='extract' branch:
    var kept=carriedGuns(G.player);
    for(i=0;i<kept.length;i++){
      // v6.68, his note: no line about it. The gun is still kept, silently.
      if(P.weapons.indexOf(kept[i].id)<0) P.weapons.push(kept[i].id);
    }
    if(kept.length) P.equipped=kept[0].id;
    for(i=0;i<THROWKEYS.length;i++){
P.equippedSec is never touched here or anywhere else in endRaid.

The sort that reverses the slots, line 18452-18459:
function carriedGuns(p){
  var out=[];
  if(p.wep&&p.wep.id!=='fists'&&!p.wepIssued) out.push(p.wep);
  if(p.sec&&p.sec.id!=='fists'&&!p.secIssued) out.push(p.sec);
  if(out.length===2&&out[0].id===out[1].id) out.pop();
  out.sort(function(a,b){ return (WTIER[b.id]||0)-(WTIER[a.id]||0); });
  return out;
}
So a run where the better gun rode in slot 2 gives kept[0]===the slot-2 gun, and P.equipped is set to the id P.equippedSec already holds.

The consequence the player meets, line 9353-9362 (deploy):
  var sec=WEAPONS.fists, secIss=false;
  if(P.equippedSec&&P.equippedSec!=='fists'&&P.equippedSec!=='none'&&WEAPONS[P.equippedSec]&&
     (P.weapons||[]).indexOf(P.equippedSec)>=0&&P.equippedSec!==P.equipped){
The guard P.equippedSec!==P.equipped fails on the collided profile, so sec stays WEAPONS.fists: the next raid starts with one gun and an empty second slot the player never emptied.

And what the last screen before the lift prints, line 32766-32771:
    var g1=(P.equipped&&P.equipped!=='fists')?WEAPONS[P.equipped]:null;
    var g2=(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists')?WEAPONS[P.equippedSec]:null;
    ...
    bits.push(g1?escHtml(g1.name):...); bits.push(g2?escHtml(g2.name):...);
which prints the same gun name twice.

Nothing later reconciles: grep of equippedSec across the whole file returns 17 hits (9354, 9355, 9361, 29675, 29978, 29980, 29986, 29991, 30114, 30120, 30490, 30961, 31023, 32767, 32874, 33172, 33719) and none of them is in endRaid, in the load-time sanitiser (2601-2605, which repairs P.equipped only) or in renderHub. The only writer that DOES reconcile is the armoury menu itself, 29979-29988: "Put in gun 1" does `if((P.equippedSec||'none')===gk) P.equippedSec='none';` first, and "Put in gun 2" does `if((P.equipped||'fists')===gk) P.equipped='fists';`. endRaid is the one slot-1 writer that skips that rule.

First-evening reachable: WELCOME_PACK is `{guns:['smg','carbine'],...}` (33108) and the take button (33171-33172) puts smg in slot 1 and carbine in slot 2; WTIER (1657) ranks carbine 3 above smg 2, so the very first extraction of a new player who deploys with his own loadout sets P.equipped=P.equippedSec='carbine' and silently unslots the SMG he still owns.
- Balance risk: Defect fix, not a dial. No in-raid number moves: no damage, spawn, AI, loot or timer value is touched, and the patch runs after the raid is over, in the banking branch.

The fix is deliberately scoped to the collision alone - `if(kept.length&&(P.equippedSec||'none')===P.equipped)` - so a profile whose two slots already name two different guns comes out of the patch byte-identical to today. The only state that changes is state that is already wrong: two slots naming one gun.

Where it does change what the player deploys with, it changes it back towards what he had. Case A (both guns carried, better one in slot 2): today he loses the second gun entirely on the next deploy; after the patch he deploys with both, the same two guns he walked out with, just swapped so the better one is primary - which is the stated intent of the v6.68 comment above the line ("Both hands count"). That is a repair of a loadout the game took away, not a buff: it restores a gun he owned before the extraction, and one he can restore by hand today in the armoury menu in two clicks. Case B (only one gun carried and it collides): the slot honestly empties to 'none'; his in-raid loadout is unchanged (he was already deploying with fists in slot 2), only the ascent-check text stops lying.

Nothing hands out a gun that was not already in the player's hands: the id written into slot 2 is always kept[1], a gun carriedGuns has just banked into P.weapons. A player whose slot 2 is legitimately 'none' and who carries a field gun out is NOT auto-slotted - that case fails the collision test and is left alone, precisely so the patch cannot be read as a free upgrade.
- Control failure claimed: On today's build (v12.28, unpatched) the check returns three failures joined by '; ':

1. "after extracting with both guns, gun 1 and gun 2 both read sniper, so one gun is in two hands and the Scav Pistol he still owns has been unslotted by a run in which he lost nothing"
2. "the ascent check names the Longshot twice as his loadout (Longshot . Longshot . armour cap ... )"
3. "the next raid comes up with nothing in gun 2 after an extraction that lost no gun"

Every control line stays silent on the unpatched build, which is what makes those three the finding rather than a broken staging: the raid does start pistol-in-gun-1 / Longshot-in-gun-2 with neither flagged issued, both guns are still in P.weapons after the extraction, and P.equipped does read 'sniper' (the tier sort ran) - the failure is only that P.equippedSec was never reconciled with it.

With the patch, P.equippedSec becomes 'pistol' (kept[1].id), the summary reads "Longshot . Scav Pistol . ...", the redeploy hands him p.sec.id==='pistol', and the check returns null.

Two of the assertions exist to stop a lazy fix passing: "gun 2 reads X after the extraction, not the Scav Pistol he carried out" and the 'no second gun' line both fire if someone repairs the collision by simply clearing slot 2 to 'none' - that would end the same-gun-twice display but still throw away a gun he walked out with.
- Hooks used: Fixture hooks, each confirmed present in C:\claudecode\dark raiders\tools\mkfixture.ps1 by grep:
- window.__deploy - defined line 18965 (sets P.stash/P.kit/P.freeKit=0, calls commitKit then __startRaid with mapIx/seed).
- window.__state - line 84 (returns G).
- window.__endRaid - line 135 (calls endRaid(how) inside the closure).
- window.__P - line 191 (returns P).
- window.__topClear - line 18849 (drops the outcome card's 'on' class).
- window.__runPrep - line 18856 (pins DPR 1, dismisses the boot title, cleans the profile).
- window.__resetCfg - line 104.
- window.__pinDefaults - line 580.
- window.__cleanProfile - line 169.
- window.__renderStage - line 217 (returns renderStage(prefill); called with no argument, which per dark_raiders.html:32748 leaves P.kit alone). Used behind a feature test, exactly as check 10.12 (mkfixture.ps1:14425) does.

Closure functions and tables called directly from inside the check, each confirmed in C:\claudecode\dark raiders\dark_raiders.html by grep:
- carriedGuns - defined line 18452 (typeof test only, as a build guard).
- saveProfile - called at 18716 and elsewhere; the same call the existing checks at mkfixture.ps1:6546 and 6560 make.
- WEAPONS - table at line 1617; WEAPONS.pistol at 1620 ('Scav Pistol'), WEAPONS.sniper at 1629 ('Longshot').
- WTIER - table at line 1657: pistol 1, sniper 5, so the sort must reverse the staged slots.

DOM element read: #stagesum, declared at dark_raiders.html:1050 and written at 32758-32782. Only textContent is read, so no viewport layout is required and no __forceSize call is made (the pane is left alone).

Restore: the finally block ends any live raid through the real __endRaid, then writes back a snapshot of 22 profile fields taken before the staging - weapons, equipped, equippedSec, wear, stash, kit, kitChosen, dropKit, safe, safeUp, freeKit, kitBeforeFree, kitSaved, runs, ext, best, credits, kills, log, notExt, notoriety, mapIx - arrays by slice and objects by shallow copy, then saveProfile, __topClear and __cleanProfile. No CFG dial is set (only __resetCfg/__pinDefaults, the corpus standard), no global is reassigned, and no prototype is hooked.
- Not verified: 1. The death path. The identical class of defect sits at dark_raiders.html:18844, `if(P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';` - it repairs slot 1 after the ledger splices lost guns out of P.weapons and leaves P.equippedSec pointing at a gun that is no longer owned (finding 16 in tools\handoff\audit-0907-confirmed.md). This patch and this check do not touch it, deliberately: one thing per build. It needs its own build, its own anchor and its own check.

2. The armoury and hub rendering. The check reads the ascent-check summary only. It does not assert the armoury rack row at dark_raiders.html:30490 (`var inSlot=(P.equipped===gk)?1:((P.equippedSec===gk)?2:0);`), so it cannot see whether the "2" badge lands on the right cell after the repair.

3. Anything that needs a real frame. The check is synchronous and never calls __loop or __frame, so it says nothing about the in-raid belt cells, the gun-two swap on X (13087-13109), or how the second gun draws in the HUD.

4. Field-gun pickups. The staged run carries two armoury guns from deploy to extraction and never picks a gun up in the raid (12969 / 13187), so the interaction between a field gun landing in slot 2 and the reconcile is untested. By inspection that case fails the collision test and is left untouched, but the check does not prove it.

5. Anything a human eye would judge. Whether swapping the two slots (better gun to primary) is what he wants rather than leaving his chosen primary alone is a design question; the patch keeps the existing v6.68 promotion behaviour and only stops it eating slot 2.

6. Version stamps are not in these anchors. The tree currently reads var VER='12.28' (line 1361) and var WHATSNEW_VER='12.28' (line 1372), and drafts 1229 and 1230 are queued ahead of this one, so the stamp and DEVNOW anchors depend on which build is applied when this ships. As written this is build 1231 / v12.31; if it is renumbered, the build number in the code comment and the VER, WHATSNEW_VER and DEVNOW anchors of the p-script must all be rewritten from the tree at apply time, not copied. Both stamps must move together (WHATSNEW_VER is not gated by parsecheck).

7. The corpus was running in the Browser pane while this was written. Nothing here has been executed; every claim is from the source text of dark_raiders.html and mkfixture.ps1, and the check must still be dry-run on :8801 against the previous build before it ships.

### anchor 1 (reported match count 1): The two lines are 18745 and 18746 of C:\claudecode\dark raiders\dark_raiders.html, adjacent, inside endRaid's how==='extract' branch. Both verified with anchored regexes that pin the leading whitespace and the end of line: ^    if\(kept\.length\) P\.equipped=kept\[0\]\.id;$ -> 1 match, and ^    for\(i=0;i<THROWKEYS\.length;i\+\+\)\{$ -> 1 match. Each line carries exactly four leading spaces. The THROWKEYS line is carried in the anchor only to pin the insertion point below the equip rewrite; it is reproduced unchanged. New text is pure ASCII, ES5 (var-free, no arrow, no template string), contains no apostrophe and no line beginning with the here-string terminator, so it is safe inside a SubRx @'...'@ block. Neither queued draft collides: p1229 patches the crawler chase/alert sites and p1230 patches hotSel/setHot, and a grep of tools\handoff for kept[0], carriedGuns and equippedSec returns nothing in p1228/p1229/p1230.
OLD:
```
    if(kept.length) P.equipped=kept[0].id;
    for(i=0;i<THROWKEYS.length;i++){
```
NEW:
```
    if(kept.length) P.equipped=kept[0].id;
    // v12.31, audit gun-slot-reconcile: SLOT TWO IS RECONCILED WITH SLOT ONE.
    // The line above rewrites gun 1 from the tier sort, so a run where the
    // better gun rode in slot 2 leaves BOTH slots naming it. The ascent check
    // then prints the same gun name twice, and the deploy guard refuses a
    // sidearm equal to the primary, so the next raid comes up with fists in
    // gun 2 and a gun he still owns quietly unslotted, out of a run in which
    // he lost nothing. The welcome pack hands out smg then carbine, which is
    // exactly the losing order, so this is the first extraction of a new
    // player. Only the collision is repaired: the other gun he actually
    // carried takes slot 2, and where there is no other gun the slot is
    // honestly empty. Two distinct slots are left untouched. Same rule the
    // armoury menu applies when a gun is put into a slot it already sits in.
    if(kept.length&&(P.equippedSec||'none')===P.equipped)
      P.equippedSec=(kept.length>1&&kept[1].id!==P.equipped)?kept[1].id:'none';
    for(i=0;i<THROWKEYS.length;i++){
```
### what the check says it measures
extracting with a gun in each hand leaves a gun in each hand: banking the better one into gun 1 no longer leaves gun 2 naming the same gun, so the ascent check does not print it twice and the next raid still comes up with a second gun (2026-09-07 audit, gun-slot-reconcile)
### check body
```js
if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__topClear&&window.__runPrep&&window.__resetCfg&&window.__pinDefaults&&window.__cleanProfile)) return 'SKIP: this fixture cannot deploy and end a raid';
if(typeof carriedGuns!=='function'||typeof saveProfile!=='function') return 'SKIP: this build does not bank carried guns';
if(!(WEAPONS&&WEAPONS.pistol&&WEAPONS.sniper&&WTIER&&WTIER.sniper>WTIER.pistol)) return 'SKIP: the Longshot no longer outranks the Scav Pistol, so the tier sort cannot be staged';
var bad=[], P2=__P(), i;
var KEYS=['weapons','equipped','equippedSec','wear','stash','kit','kitChosen','dropKit','safe','safeUp','freeKit','kitBeforeFree','kitSaved','runs','ext','best','credits','kills','log','notExt','notoriety','mapIx'];
function snap(v){ var o,k; if(v&&v.slice) return v.slice(); if(v&&typeof v==='object'){ o={}; for(k in v) o[k]=v[k]; return o; } return v; }
var keep={}; for(i=0;i<KEYS.length;i++) keep[KEYS[i]]=snap(P2[KEYS[i]]);
try{
  __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
  // DISTINCTIVE ON PURPOSE: the weakest gun in the file in slot 1 and the
  // strongest in slot 2. No starter roll, no free kit and no fallback can
  // produce a Longshot, and the tier sort must reverse this exact pair.
  P2.weapons=['pistol','sniper']; P2.equipped='pistol'; P2.equippedSec='sniper';
  P2.wear={}; P2.freeKit=0; P2.kitSaved=null; P2.kitBeforeFree=null;
  saveProfile();
  __deploy({kit:[],safe:null,mapIx:0,seed:4242});
  var g=__state(), p=g.player;
  if(!p.wep||p.wep.id!=='pistol') bad.push('control: the raid did not start with the Scav Pistol in gun 1 (it holds '+(p.wep&&p.wep.id)+')');
  if(!p.sec||p.sec.id!=='sniper') bad.push('control: the raid did not start with the Longshot in gun 2 (it holds '+(p.sec&&p.sec.id)+')');
  if(p.wepIssued||p.secIssued) bad.push('control: a slot was filled with issued kit, so that gun would never be banked and the sort would not run');
  g.bag=[]; p.downed=false; p.hp=100;
  __endRaid('extract');
  if(P2.weapons.indexOf('pistol')<0||P2.weapons.indexOf('sniper')<0) bad.push('control: the extraction did not leave both guns in the armoury (it holds '+P2.weapons.join(',')+')');
  if(P2.equipped!=='sniper') bad.push('control: the extraction did not promote the Longshot into gun 1 (gun 1 reads '+P2.equipped+'), so the tier sort this check is about did not run');
  if(P2.equippedSec===P2.equipped) bad.push('after extracting with both guns, gun 1 and gun 2 both read '+P2.equipped+', so one gun is in two hands and the Scav Pistol he still owns has been unslotted by a run in which he lost nothing');
  else if(P2.equippedSec!=='pistol') bad.push('gun 2 reads '+P2.equippedSec+' after the extraction, not the Scav Pistol he carried out');
  // WHAT THE LAST SCREEN BEFORE THE LIFT PRINTS.
  if(window.__renderStage&&document.getElementById('stagesum')){
    __topClear();
    try{ __renderStage(); }catch(_rs){ bad.push('the ascent check threw: '+(_rs&&_rs.message||_rs)); }
    var sum=(document.getElementById('stagesum').textContent||'').replace(/\s+/g,' ');
    var nm=WEAPONS.sniper.name, none2='no second '+'gun';
    if(!sum) bad.push('control: the ascent check summary is empty, so what the last screen names cannot be read here');
    else{
      if(sum.split(nm).length-1>1) bad.push('the ascent check names the '+nm+' twice as his loadout ('+sum.slice(0,90)+')');
      if(sum.indexOf(WEAPONS.pistol.name)<0) bad.push('the ascent check does not name the Scav Pistol he carried out ('+sum.slice(0,90)+')');
      if(sum.indexOf(none2)>=0) bad.push('the ascent check says '+none2+' after a run in which he lost no gun ('+sum.slice(0,90)+')');
    }
  }
  // AND THE RAID HE ACTUALLY DEPLOYS INTO NEXT.
  __deploy({kit:[],safe:null,mapIx:0,seed:4242});
  var g2=__state(), p2=g2.player;
  if(!p2.sec||p2.sec.id==='fists') bad.push('the next raid comes up with nothing in gun 2 after an extraction that lost no gun');
  else if(p2.wep&&p2.sec.id===p2.wep.id) bad.push('the next raid comes up holding two copies of the '+p2.sec.id);
  else if(p2.sec.id!=='pistol') bad.push('the next raid comes up with '+p2.sec.id+' in gun 2, not the Scav Pistol he carried out');
}catch(e){ bad.push('threw: '+(e&&e.message||e)); }
finally{
  try{ var g3=__state(); if(g3&&!g3.over){ g3.player.downed=false; g3.bag=[]; __endRaid('extract'); } }catch(_e){}
  for(i=0;i<KEYS.length;i++) P2[KEYS[i]]=keep[KEYS[i]];
  try{ saveProfile(); }catch(_s){}
  __topClear(); __cleanProfile();
}
return bad.length?bad.join('; '):null;
```

## 5. v12.28, dead-slot2: a death that takes the sidearm leaves gun slot 2 naming a gun that is no longer in the armoury, and the ascent check sends him up with it  [key: dead-slot2]

- Still open: STILL OPEN at v12.27. Three places decide it, all read verbatim out of C:\claudecode\dark raiders\dark_raiders.html.

(1) The death branch splices the carried guns out of the armoury. endRaid is at line 18464, `} else if(how==='dead'){` at 18755, and inside it at 18808-18810:
    `      var wi=_egArm?P.weapons.indexOf(gone[j].id):-1;`
    `      if(wi>=0){ P.weapons.splice(wi,1);`
    `        lines.push('<span style="color:#cdd6dd">'+gone[j].name+'</span><span style="color:var(--rust)">  LOST</span>'); }`
carriedGuns (line 18452-18459) returns BOTH hands, `if(p.sec&&p.sec.id!=='fists'&&!p.secIssued) out.push(p.sec);`, so the sidearm is spliced exactly like the primary.

(2) One slot gets repaired and the other does not. Line 18844, the only repair in the branch:
    `    if(P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';`
A grep for `equippedSec` over the whole file returns 9354, 9355, 9361, 29675, 29978, 29980, 29986, 29991, 30114, 30120, 30490, 30961, 31023, 32767, 32874, 33172, 33719 - not one line inside endRaid (18464 to the end of the function). Nothing repairs gun slot 2 after a death.

(3) The deploy refuses the dead gun but the ascent check prints it. buildRaid, line 9354-9355:
    `  if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&WEAPONS[P.equippedSec]&&`
    `     (P.weapons||[]).indexOf(P.equippedSec)>=0&&P.equippedSec!==P.equipped){`
so the raid hands you an empty second slot. renderStage (line 32743) writes the summary line and at 32767 reads the field raw, with no armoury test at all:
    `    var g2=(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists')?WEAPONS[P.equippedSec]:null;`
    `    bits.push(g2?escHtml(g2.name):'<span style="color:var(--ash)">no second gun</span>');`
So on the last screen before the lift the game names a gun he lost with his body as gun 2, and then he lands with nothing in that hand.

Nothing between v12.23 and v12.27 touched either line: both anchors below match exactly once in the tree today, and drafts 1228 to 1232 in tools\handoff contain no edit to `P.equipped`, `equippedSec`, `var g2=` in renderStage, or `stagesum`.
- Balance risk: DEFECT FIX, no balance risk. Neither anchor changes what goes up in a raid, so in-raid difficulty is byte-identical.

buildRaid already refuses a slot-2 gun that is not in P.weapons (lines 9354-9355 quoted above), so on today's build the raid after such a death already starts with `sec=WEAPONS.fists`. Anchor A only writes the profile field down to the value the deploy has always behaved as if it held; anchor B only changes what one HTML line says. No CFG dial, no weapon stat, no count, no timer, no drop table is touched, and the fix cannot make a raid easier or harder in either direction. It is the same class of repair as the primary-slot line at 18844 that has sat one line above it since v2.82.

House-rule check: player-facing wording is untouched (the existing strings `no second gun` and the gun names stay exactly as they are); the patch adds no new player-facing copy at all; both anchors are pure ASCII with no doubled quotes; no DEVNOW string is involved.
- Control failure claimed: On the unpatched tree (v12.27) the check returns three failures joined by semicolons, and on the patched build it returns null.

What it prints today, verbatim in shape:

  after dying with it, gun slot 2 still names the Meridian Lance, which is no longer in the armoury; the ascent check sends him up with a Meridian Lance he lost with his body [Longshot no gun of your own, a loaner Meridian Lance armour cap 3 nothing packed no safe pocket]; the ascent check does not say no second gun after the sidearm was lost [ ... same line ... ]

(the bracketed text is whatever #stagesum actually reads at that moment, so the failure quotes the screen back rather than asserting a canned sentence; the leading fragment is the g1 half, which is separately correct because line 18844 already repairs the primary.)

Why each arm turns over with the patch:
- Anchor A writes P.equippedSec='none' inside the death branch, so the first assertion sees 'none' and stays quiet.
- With slot 2 at 'none', renderStage takes the else at 32771 and the summary reads `no second gun`, so the second and third assertions stay quiet. Anchor B holds the same result if the field were stale for any other reason.
- The control arm passes on BOTH builds: with 'lance' back in P.weapons and P.equipped='sniper', anchor B's added tests (WEAPONS[_s2], in P.weapons, not equal to slot 1) are all true, so the page still prints Meridian Lance. If anchor B were written too tightly the control would go red and say so, which is the point of running it.

Staging refusals return early as `staging: ...` strings rather than pretending to measure: if the Meridian Lance did not go up in slot 2, or was not flagged secFromArmory, or survived the death, the check names that instead of blaming the build.
- Hooks used: Fixture hooks, each grepped in C:\claudecode\dark raiders\tools\mkfixture.ps1 and confirmed present:
- window.__deploy        line 18965  `window.__deploy=function(o){` (sets P.stash/P.kit/P.freeKit=0, runs commitKit then __startRaid)
- window.__state         line 84     `window.__state=function(){ return G; };`
- window.__endRaid       line 135    `window.__endRaid=function(how){ endRaid(how); };`
- window.__P             line 191    `window.__P=function(){ return P; };`
- window.__renderStage   line 217    `window.__renderStage=function(prefill){ return renderStage(prefill); };`
- window.__runPrep       line 18856
- window.__topClear      line 18849
- window.__cleanProfile  line 169
- window.__resetCfg      line 104
- window.__pinDefaults   line 580  (note: it sets P.equipped='smg' and pushes 'smg' into P.weapons, which is why the check stages its own armoury strictly AFTER calling it)

Closure functions and globals called directly from inside the check, each grepped in C:\claudecode\dark raiders\dark_raiders.html:
- WEAPONS            line 1617  `var WEAPONS={` - and WEAPONS.sniper at 1629, WEAPONS.lance at 1650, names Longshot and Meridian Lance
- saveProfile()      line 2426  `function saveProfile(){`
- endRaid (via __endRaid)  line 18464  `function endRaid(how){`
- renderStage (via __renderStage) line 32743  `function renderStage(prefill){`

DOM ids read, each grepped in the game file:
- #stagemodal  line 1023, #stagehead line 1024, #stagesum line 1050, #stageplan (written by renderStage at 32792)

Player fields the check reads off the live raid, each grepped:
- p.sec / p.secFromArmory - written at line 10300 `wepIssued:wepIssued,secIssued:secIss,wepFromArmory:!wepIssued,secFromArmory:!secIss,`
- carriedGuns reads them at 18454-18455 and the death splice tests them at 18804.

No browser tool, no server and no localhost is used; the check is pure in-page JavaScript inside the game closure, as every other __REGRESS entry is.
- Not verified: What this check cannot see:

1. The kill itself. It calls __endRaid('dead') rather than letting a pillager or a sentry put him down, so it proves the payout path but not that every real death route reaches it. (endRaid is the game's own function, not a fixture copy, so the branch under test is the shipped one - but the callers are out of view.)

2. A death that loses only ONE of the two guns. The staging loses both, so P.weapons ends empty and P.equipped falls to 'fists'. The mixed case - slot 1 kept, slot 2 lost, or the reverse - is not exercised, and neither is the case where the primary repair at 18844 lands P.equipped on the same id P.equippedSec holds.

3. The extract branch. Line 18745 `if(kept.length) P.equipped=kept[0].id;` can make slot 1 and slot 2 name the same gun on a clean extraction; that is a separate finding in the same audit and this check never runs an extract. Anchor B silently makes the ASCENT CHECK honest about it, but nothing here asserts on it, so do not read a green run as that finding being closed.

4. The saved profile across a reload. The check restores through the live P and saveProfile; it never drives __applyLoaded, so it does not prove the 'none' survives a page load. (Line 31023 already validates e2 against the owned list on load, so the loader is not the risk - it is simply untested here.)

5. Anything drawn rather than written. It reads #stagesum textContent only: no pixels, no fonts, no colours, no layout, no overflow, so it cannot see the summary being clipped, hidden behind the outcome card, or painted off the panel. It also never opens the ascent modal, so nothing about that screen at 1920x1080 is measured.

6. The other screens that show gun 2. The Undercroft armoury row (line 30490, the amber 1/2 badge) and the in-raid HUD are not rendered or asserted; they iterate P.weapons and so were never wrong, but this check does not prove that.

7. Sound, the outcome card copy, the KIA ledger lines and the credits arithmetic. The bag is emptied before the death precisely so the ledger does no work, so nothing about what the death screen SAYS about the lost guns is under test.

8. The bot. Per the standing note, the sim never plays this path and no extract-rate number is touched or implied by either anchor.

### anchor 1 (reported match count 1): ANCHOR A, the root cause. Line 18844 of dark_raiders.html, inside the how==='dead' branch of endRaid (branch opens at 18755, closes into the abandon branch at 18855), immediately after the guns have been spliced out of P.weapons at 18809 and before the kitBeforeFree restore at 18867. Grepped as an anchored whole line: 1 occurrence in the file. The only other line in the file carrying the same tail is 2605, `          if(!WEAPONS[P.equipped]) P.equipped=P.weapons.length?P.weapons[0]:'fists';`, which is a different statement with ten leading spaces and does not collide. Placed after the primary repair rather than before it so the two read as the pair they are; deliberately membership-only, with no P.equippedSec===P.equipped clause, because the slot-1/slot-2 collision on the EXTRACT branch (line 18745, `if(kept.length) P.equipped=kept[0].id;`) is a separate finding with its own draft and must not be half-fixed here.
OLD:
```
    if(P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';
```
NEW:
```
    if(P.equipped!=='fists'&&P.weapons.indexOf(P.equipped)<0) P.equipped=P.weapons.length?P.weapons[0]:'fists';
    // v12.28, audit dead-slot2: AND GUN 2 GETS THE SAME REPAIR. The line above has
    // put the primary back on a gun you still own since v2.82, and nothing has ever
    // done it for the sidearm, so a death that took the second gun left P.equippedSec
    // naming a gun the splice thirty lines up had just removed from the armoury.
    // buildRaid refuses it - it tests P.weapons before it bakes a sidearm - and sends
    // you up with an empty second slot, but the ascent check reads the field raw and
    // told him the dead gun was going up in his hands. An empty gun 2 is the v5.37
    // default, so that is what the slot goes back to.
    if(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists'&&
       P.weapons.indexOf(P.equippedSec)<0) P.equippedSec='none';
```
### anchor 2 (reported match count 1): ANCHOR B, the display. Line 32767 of dark_raiders.html, inside the anonymous summary IIFE of renderStage (function opens 32743, IIFE opens 32757, writes #stagesum at 32782). Grepped as an anchored whole line: 1 occurrence in the file. _s2 is a new local: the IIFE already declares sw, _fkg, g1, g2, rg2, bits, kn, _sfk and _sfl and none of them is _s2. This is belt and braces on top of anchor A - with A alone the field is already clean after a death - but it also stops the ascent check lying for the other two routes to a stale slot 2 (a profile that arrives stale from anywhere, and a slot 2 that has come to equal slot 1), and it is the line the finding actually names.
OLD:
```
    var g2=(P.equippedSec&&P.equippedSec!=='none'&&P.equippedSec!=='fists')?WEAPONS[P.equippedSec]:null;
```
NEW:
```
    // v12.28, audit dead-slot2: THE SAME TEST buildRaid MAKES, so this page can
    // never name a gun that will not come up. It read the slot raw, so after a death
    // that took the sidearm it printed the lost gun as your second gun, and it would
    // do the same for a slot 2 that had come to name the gun already in slot 1. Both
    // are cases buildRaid throws away at 9354. This is the last screen before the
    // lift, so it is the one screen that has to agree with the deploy.
    var _s2=P.equippedSec;
    var g2=(_s2&&_s2!=='none'&&_s2!=='fists'&&WEAPONS[_s2]&&
            (P.weapons||[]).indexOf(_s2)>=0&&_s2!==P.equipped)?WEAPONS[_s2]:null;
```
### what the check says it measures
a death that takes the sidearm empties gun slot 2, and the ascent check stops naming a gun that is no longer in the armoury
### check body
```js
if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P&&window.__runPrep&&window.__topClear&&window.__cleanProfile&&window.__resetCfg&&window.__pinDefaults)) return 'SKIP: this fixture cannot deploy and end a raid';
     if(!window.__renderStage) return 'SKIP: this fixture cannot render the ascent check';
     if(!document.getElementById('stagemodal')||!document.getElementById('stagesum')) return 'SKIP: this build has no ascent check summary line';
     if(!(WEAPONS&&WEAPONS.sniper&&WEAPONS.lance)) return 'SKIP: this build has no Longshot and no Meridian Lance to stage';
     var bad=[], P2=__P();
     var keep={weapons:(P2.weapons||[]).slice(),eq:P2.equipped,eq2:P2.equippedSec,
       stash:(P2.stash||[]).slice(),kit:(P2.kit||[]).slice(),drop:(P2.dropKit||[]).slice(),
       hot:JSON.parse(JSON.stringify(P2.hotAssign||{})),wear:JSON.parse(JSON.stringify(P2.wear||{})),
       kills:JSON.parse(JSON.stringify(P2.kills||{})),chosen:P2.kitChosen,freeKit:P2.freeKit,
       kbf:P2.kitBeforeFree,kitSaved:P2.kitSaved,gunSlot:P2._gunSlot,safe:P2.safe,safeUp:P2.safeUp,
       merc:P2.merc,mapIx:P2.mapIx,runs:P2.runs,died:P2.died,ext:P2.ext,credits:P2.credits,
       xp:P2.xp,best:P2.best,notExt:P2.notExt};
     function sumText(){ var e=document.getElementById('stagesum'); return ((e&&e.textContent)||'').replace(/\s+/g,' '); }
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       try{ var g0=__state(); if(g0&&!g0.over){ g0.player.downed=false; __endRaid('abandon'); } }catch(_0){}
       P2=__P();
       // DISTINCTIVE: two guns no starter roll, no shop stock and no freebie kit can hand you.
       P2.weapons=['sniper','lance']; P2.equipped='sniper'; P2.equippedSec='lance';
       P2.wear={}; P2.merc=null; P2.safe=null; P2.safeUp=null;
       P2.kitBeforeFree=null; P2.kitSaved=null; P2._gunSlot=null;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(); if(!g) return 'staging: no raid to die in';
       var p=g.player;
       if(!p.sec||p.sec.id!=='lance') return 'staging: gun 2 went up as '+((p.sec&&p.sec.id)||'nothing')+' and not the Meridian Lance';
       if(!p.secFromArmory) return 'staging: gun 2 is not flagged as out of the armoury, so a death would not take it';
       g.bag.length=0; p.downed=false; g.over=false;
       __endRaid('dead');
       __topClear();
       P2=__P();
       var own=P2.weapons||[];
       if(own.indexOf('lance')>=0) return 'staging: the Meridian Lance survived the death, so there is nothing here to measure';
       if(P2.freeKit) return 'staging: the profile came out of the death on the freebie kit, which prints its own line';
       // THE FINDING, part one: the slot still points at the gun that died with him.
       var s2=P2.equippedSec;
       if(s2&&s2!=='none'&&s2!=='fists'&&own.indexOf(s2)<0)
         bad.push('after dying with it, gun slot 2 still names the '+((WEAPONS[s2]&&WEAPONS[s2].name)||s2)+', which is no longer in the armoury');
       // THE FINDING, part two: and the last screen before the lift tells him it is coming up.
       try{ __renderStage(); }catch(_r){ bad.push('the ascent check threw after the death: '+_r); }
       var txt=sumText();
       if(txt.indexOf('Meridian Lance')>=0)
         bad.push('the ascent check sends him up with a Meridian Lance he lost with his body ['+txt+']');
       if(txt.indexOf('no second gun')<0)
         bad.push('the ascent check does not say no second gun after the sidearm was lost ['+txt+']');
       // CONTROL: put the gun back in the armoury and the same page must name it again.
       P2.weapons=['sniper','lance']; P2.equipped='sniper'; P2.equippedSec='lance';
       try{ __renderStage(); }catch(_r2){ bad.push('control: the ascent check threw: '+_r2); }
       var ctl=sumText();
       if(ctl.indexOf('Meridian Lance')<0)
         bad.push('control: with the Meridian Lance back in the armoury the ascent check no longer names it as gun 2 ['+ctl+']');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ var gz=__state(); if(gz&&!gz.over){ gz.player.downed=false; __endRaid('abandon'); } }catch(_e){}
       try{ var sm=document.getElementById('stagemodal'); if(sm) sm.classList.remove('on');
            var sp=document.getElementById('stageplan'); if(sp) sp.innerHTML='';
            var sv=document.getElementById('stagesum'); if(sv) sv.innerHTML=''; }catch(_s){}
       try{ var Pz=__P();
         Pz.weapons=keep.weapons; Pz.equipped=keep.eq; Pz.equippedSec=keep.eq2;
         Pz.stash=keep.stash; Pz.kit=keep.kit; Pz.dropKit=keep.drop; Pz.hotAssign=keep.hot;
         Pz.wear=keep.wear; Pz.kills=keep.kills; Pz.kitChosen=keep.chosen; Pz.freeKit=keep.freeKit;
         Pz.kitBeforeFree=keep.kbf; Pz.kitSaved=keep.kitSaved; Pz._gunSlot=keep.gunSlot;
         Pz.safe=keep.safe; Pz.safeUp=keep.safeUp; Pz.merc=keep.merc; Pz.mapIx=keep.mapIx;
         Pz.runs=keep.runs; Pz.died=keep.died; Pz.ext=keep.ext; Pz.credits=keep.credits;
         Pz.xp=keep.xp; Pz.best=keep.best; Pz.notExt=keep.notExt;
         saveProfile(); }catch(_p){}
       __topClear(); __cleanProfile();
     }
     return bad.length?bad.join('; '):null;
```

## 6. v12.33 - THE MAN YOU HIRED PICKS UP THE MEN SHOOTING AT YOU (merc-loots-hostiles)  [key: merc-loots-hostiles]

- Still open: STILL OPEN. Note first: the tree has moved past the prompt. C:\claudecode\dark raiders\dark_raiders.html now reads `var VER='12.28';` (line 1361) and DEVNOW.now names v12.28, i.e. draft 1228 is applied; drafts 1229-1232 are queued (d1232.txt is "## v12.32"), and none of p1229/p1230/p1231/p1232 contain the strings RD===e, reviving, RD.crew or merc, so the anchor below is untouched at v12.32 and this build is v12.33.

THE DEFECT. Under the LOOT order the merc falls out of the three merc branches (mercEngage at 17249, the rescue at 17268, follow at 17291, hold at 17328 - none of which apply) and lands in the crew-revive branch, which decides who is worth picking up by CREW NUMBER ALONE. Lines 17344-17357 of dark_raiders.html, verbatim:

    else if((e.state==='loot'||e.state==='extract')&&e.kind==='raider'&&CFG.raiderDown!==0&&(function(){
      if(e.reviving&&(e.reviving.downed!==1||G.ents.indexOf(e.reviving)<0)) e.reviving=null;
      if(!e.reviving){
        var best=null,bd=(e.state==='extract')?260:760;
        for(var rv=0;rv<G.ents.length;rv++){
          var RD=G.ents[rv];
          if(RD===e||RD.kind!=='raider'||!RD.downed) continue;
          if(RD.crew!==e.crew) continue;

The two deciding lines are the last two: the only tests are "is a raider" and "same crew". There is no e.merc test and no hostility test anywhere in the branch or in its outer condition, so the merc is an eligible reviver and a downed HOSTILE pillager is an eligible target. The payoff at 17365-17369 stands the hostile back up: `TG.downed=0; TG.state='loot'; TG.hp=Math.round(TG.maxhp*0.4);` with the PICKED UP label.

WHY THEY SHARE A NUMBER. The merc is built by the ordinary constructor and given no crew: line 10097-10098, `var M2=mkRaider(msp.x,msp.y,mid,sim);` then `M2.merc=1; M2.hostile=false; M2.grudge=false; M2.friendly=1;`. mkRaider rolls it at line 8838: `crew:Math.floor(_crewRoll*Math.max(2,CFG.raiderCrews||2)),` and CFG.raiderCrews is 2 by default (DEF, line 1585), so your hire shares a crew number with about half the hostile pillagers on the map.

REACHABLE, not dead code. The merc keeps state 'loot' from mkRaider (line 8815) and can never be pushed into 'chase' by sight, because line 16910 excludes him from the whole seen-you section: `if(sees&&!(e.merc&&!e.downed&&(` ... `(p.downed&&CFG.raiderDown!==0)||true))){`. So with the LOOT order set, no live target for mercEngage and a downed same-crew hostile inside 760, the branch fires.

NOT ALREADY FIXED. AUDIT.md has no row for it: the merc rows are "merc ignored the LOOT order" (v8.45), "merc's cut paid from a number only a HUD draw updated" (v8.46), "YOUR PUNCH HIT YOUR OWN MERC" (v11.38), "A MERC WHO BOARDED AN EARLIER SHIP WAS NEVER PAID" (v11.62). Nothing about revives.
- Balance risk: DEFECT FIX, not a dial. Nothing in CFG, DEF or any numeric constant is touched; no difficulty setting moves; the branch keeps the same 760/260 radii, the same 3.2 second pickup and the same 40 percent stand-up. For every entity that is not the merc the code path is byte-identical, so ordinary crew revives, the sim and every historical benchmark number are unchanged (the bot never hires a merc, so no A/B arm can even see this line).

What does change in-raid: an enemy pillager who would have been put back on his feet by YOUR hire stays down. That is player-favouring, which is the direction the no-balancing rule cares least about, and it is the correction of a nonsense behaviour rather than a tuning judgement - the man you paid 30,000 credits for was working for the other side. The rate is small anyway: it needs the merc idle under LOOT, no live target inside mercEngage, and a downed hostile inside 760 who won the roughly one-in-two crew collision.

The one thing deliberately NOT changed, because it WOULD be a balance call: the mirror case, a hostile pillager of the same crew number walking over and picking your downed merc up. That is the same "a crew number is not a side" defect pointed the other way, but removing it takes something away from the player, so it is named in the design entry and left for him.
- Control failure claimed: On the unpatched build (today's tree, and the v12.32 fixture this ships against) arm A fires and the corpus prints one line:

  v12.33 a merc told to loot on his own does not pick up a downed HOSTILE pillager who happens to share his crew number; he still picks up one who has thrown in with you, and an ordinary crew still picks its own up -> the man you hired left your job and picked up a downed HOSTILE pillager because they share a crew number: he is on his feet with 311 health and shooting at you again

311 is the pickup's own arithmetic, Math.round(777*0.4), off the distinctive maxhp the stage gives him; no other path in the game writes that number onto that man, and his bag is emptied so nothing heals him afterwards. On the old build the pickup completes at about 3.3 seconds of the 5, so `up` is true rather than merely `latched`. Arms B and C pass on both builds - they exist to prove the room produces a pickup at all and that the fix is a side test rather than a blanket ban - so the whole red is arm A, and it goes green with the patch while B and C stay green.
- Hooks used: Every one confirmed by grep in C:\claudecode\dark raiders\tools\mkfixture.ps1 at the line given:

- window.__deploy - line 18965, `window.__deploy=function(o){` (commitKit then __startRaid with sim false, which is what makes the merc spawn at all).
- window.__state - line 84, `window.__state=function(){ return G; };`
- window.__ents - line 442, `window.__ents=function(dt){ refreshVseg(); updateEnts(dt); };` - this is the real AI step that owns the branch being patched (updateEnts, dark_raiders.html line 15980, branch at 17344).
- window.__P - line 191, `window.__P=function(){ return P; };`
- window.__identityIds - line 1020, `window.__identityIds=function(){ ... IDENTITIES[i].id ... };`
- window.__topClear - line 18849.
- window.__runPrep - line 18856.
- window.__resetCfg - line 104.
- window.__pinDefaults - line 580.
- window.__cleanProfile - line 169.

Closure values reached directly from inside the check: WORLD_W only (dark_raiders.html line 1243, `var WORLD_W=5200,WORLD_H=4000;`), used to decide which side of the merc to park the player on so the thousand units cannot fall off the map. No closure function is called, deliberately - the check asserts on entity fields the game itself wrote, not on helpers that could agree with a bug.

The hire is created through the game's own path (P.merc set to a real identity id, then __deploy runs the sideStream spawn at dark_raiders.html 10079-10103), exactly as shipped check 11.62 does at mkfixture.ps1:7773.
- Not verified: - THE MIRROR CASE, left in on purpose: a hostile pillager of the merc's crew number still walks over and picks YOUR downed merc up. Same "a crew number is not a side" defect, but closing it takes something away from the player, so it is his call and not a fix I make before alpha.
- HOW OFTEN IT HAPPENS in a real raid. The check proves the branch fires in a staged room; it measures no rate. The sim cannot supply one either - the bot never hires a merc, so no A/B arm has ever contained this entity.
- HIS EYE. Nothing is said or drawn when the hire declines; the only player-visible difference is that the PICKED UP label and the enemy standing up no longer happen. The check drives __ents, not __loop, so nothing about drawing, the label, sound or the HUD is exercised.
- THE OTHER TWO ORDERS. Under FOLLOW and HOLD the merc is owned by his own branches above this one and never reached the crew branch, so the check does not stage them and the patch cannot affect them.
- A PASSIVE STRANGER. The fix still lets the hire pick up a downed pillager whose hostile is false (good standing, never provoked) and who shares his number. That is the same test mercEngage uses for who is his business, but whether the man you paid should be kneeling over strangers at all is a judgement, not a defect.
- THE friendlyPC ARM asserts identical behaviour on both builds. It is a guard against over-fixing, not evidence that anything changed.
- ENTITY POSITIONS. The two pillagers the stage borrows are moved and stamped inside the raid this check itself deployed; the globals, the roster array, the order, the hold point, the revive counter, CFG and the profile are all restored, but the borrowed men are not put back where they stood. The next check deploys its own raid.

### anchor 1 (reported match count 1): The whole defect is these two tests: 'is a raider' and 'same crew', with nothing asking which side either man is on. The guard goes between them, so it reads as the side test that has to pass before the crew test is even asked. Both lines are unique in the file on their own (grep -c -F: 'if(RD===e||RD.kind!==...' = 1, 'if(RD.crew!==e.crew) continue;' = 1, and RD.crew appears exactly once, at line 17351), so the pair matches exactly once. Indentation is ten leading spaces on each line, verified with cat -A; the file is LF-only today (0 CR bytes), so a SubRx built with the standard \r?\n join matches either way.
OLD:
```
          if(RD===e||RD.kind!=='raider'||!RD.downed) continue;
          if(RD.crew!==e.crew) continue;
```
NEW:
```
          if(RD===e||RD.kind!=='raider'||!RD.downed) continue;
          // v12.33, audit merc-loots-hostiles: A CREW NUMBER IS NOT A SIDE. The man
          // you hired is built by mkRaider like every other pillager and rolls a
          // crew there (raiderCrews 2), so he shares a number with about half the
          // map. Told to loot on his own he reaches this branch, and a downed
          // HOSTILE inside 760 carrying that number read as one of his own: he
          // left your job, knelt over the man who had been shooting at you and put
          // him back on his feet on 40 percent health. The test below is the one
          // mercEngage already uses to decide who is his business, so the pillager
          // he would shoot is the pillager he will not pick up. A man who has
          // thrown in with you, or who is passive, is still picked up, and no
          // other reviver in the game has his crew rule changed.
          if(e.merc&&!RD.merc&&RD.hostile!==false&&!RD.friendlyPC) continue;
          if(RD.crew!==e.crew) continue;
```
### what the check says it measures
a merc told to loot on his own does not pick up a downed HOSTILE pillager who happens to share his crew number; he still picks up one who has thrown in with you, and an ordinary crew still picks its own up
### check body
```js
     if(!(window.__deploy&&window.__state&&window.__ents&&window.__P&&window.__identityIds))
       return 'SKIP: this fixture cannot hire a merc and step the pillagers';
     var P=window.__P(), ids=window.__identityIds(), bad=[];
     if(!ids.length) return 'SKIP: no identity to hire';
     var svMerc=P.merc, svCred=P.credits;
     // THE STAGE, three arms on one room. A reviver and a downed pillager twenty
     // units apart on the ground the hired man spawned on, both stamped crew 7 -
     // raiderCrews is 2, so 7 is a number no raid can roll and can only have come
     // from here. You are parked a thousand units away, which puts the stage
     // outside the crawl-for-cover branch (700) and outside engageNear (600), so
     // the downed man does not crawl out of reach and mercEngage never fires.
     // Nobody else is in G.ents. The order is LOOT, the order the finding names.
     // His bag is emptied because raiderUseKit heals a hurt pillager from his own
     // bag and would blur the 311 the pickup writes. Five seconds at 0.1 against
     // the 3.2 second pickup.
     function arm(mode){
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       P.merc=ids[0]; P.credits=1000;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player, i, e, M=null, pool=[];
       for(i=0;i<g.ents.length;i++){
         e=g.ents[i];
         if(e.kind!=='raider') continue;
         if(e.merc){ if(!M) M=e; }
         else if(!e.downed&&!e.finished) pool.push(e);
       }
       if(!M) return {skip:'the hired merc did not spawn'};
       if(pool.length<2) return {skip:'fewer than two ordinary pillagers on this map and seed'};
       var E=(mode==='crew')?pool[0]:M, D=pool[1];
       var keepEnts=g.ents, keepOrder=g.mercOrder, keepHold=g.mercHold,
           keepRev=(g.tel?(g.tel.crewRevives||0):null), out=null;
       try{
         g.mercOrder='loot'; g.mercHold=null;
         p.downed=false; p.hp=p.maxhp; p.iv=99;
         p.x=(M.x+1000<WORLD_W-60)?(M.x+1000):(M.x-1000); p.y=M.y;
         E.x=M.x; E.y=M.y; E.crew=7; E.state='loot'; E.downed=false; E.finished=false;
         E.reviving=null; E.revProg=0; E.hp=E.maxhp; E.hostile=E.merc?false:true; E.friendlyPC=0;
         D.x=M.x+20; D.y=M.y; D.crew=7; D.downed=1; D.downT=16; D.state='down';
         D.finished=false; D.reviveT=0; D.maxhp=777; D.hp=50; D.bag=[]; D.healQ=0;
         D.hostile=(mode==='side')?false:true; D.friendlyPC=(mode==='side')?1:0;
         g.ents=[E,D];
         for(var f=0;f<50;f++) __ents(0.1);
         out={up:(!D.downed&&!D.finished), hp:Math.round(D.hp),
              latched:(E.reviving===D), gone:!!D.finished};
       } finally {
         // The raid itself is this check's own deploy and the next check deploys
         // its own, but the roster array, the order, the hold point and the revive
         // counter are read by anything that runs after this one.
         g.ents=keepEnts; g.mercOrder=keepOrder; g.mercHold=keepHold;
         if(g.tel&&keepRev!==null) g.tel.crewRevives=keepRev;
       }
       return out;
     }
     try{
       // THE FINDING: your hire, told to loot on his own, and a downed HOSTILE
       // pillager who happens to carry his crew number.
       var A=arm('hostile');
       if(A.skip) return 'SKIP: '+A.skip;
       if(A.gone) bad.push('control: the downed man bled out inside the five seconds, so this arm never asked the question');
       else if(A.up) bad.push('the man you hired left your job and picked up a downed HOSTILE pillager because they share a crew number: he is on his feet with '+A.hp+' health and shooting at you again');
       else if(A.latched) bad.push('the man you hired broke off and knelt over a downed HOSTILE pillager of his crew number; the pickup was still running at five seconds');
       // CONTROL 1: AN ORDINARY CREW STILL PICKS ITS OWN UP, in this same room.
       // Without it, a fix that stopped every pickup everywhere would read green.
       var B=arm('crew');
       if(B.skip) return 'SKIP: '+B.skip;
       if(!B.up) bad.push('control: an ordinary pillager did not pick his own downed crewmate up in the same room (health '+B.hp+', bled out '+B.gone+'), so the stage produces no pickup at all and the merc arm proves nothing');
       else if(B.hp!==311) bad.push('control: the crewmate stood up on '+B.hp+' health, not the 311 the pickup writes (40 percent of the 777 this stage gave him), so something other than the pickup stood him up');
       // CONTROL 2: AND YOUR HIRE STILL PICKS UP A MAN ON YOUR SIDE who shares the
       // number, which is what separates a side test from a blanket ban on the man
       // you paid for helping anybody at all.
       var C=arm('side');
       if(C.skip) return 'SKIP: '+C.skip;
       if(!C.up) bad.push('control: the man you hired no longer picks up a downed pillager who has thrown in with you and shares his crew number (health '+C.hp+', bled out '+C.gone+'), so the fix bans him from helping anyone instead of telling the two sides apart');
     } finally {
       P.merc=svMerc; P.credits=svCred;
       __resetCfg(); __cleanProfile(); __topClear();
     }
     return bad.length?bad.join('; '):null;
```

## Rejected by the skeptic (do not build from these without reading the source again)
- bag-gun-mag (unsure): v12.33 - a gun keeps its magazine through the backpack (bag-gun-mag) -- The patch itself is sound and would work, but the spec's central evidence claim is provably incomplete, so I cannot pass it as written.

VERIFIED GOOD: (a) All five anchors exist verbatim and exactly once in dark_raiders.html (13083, 13091, 13182-13185, 13187-13188) â€” note the bare "  G.bag.splice(ix,1);" line occurs 4 times, not the 2 the spec states, but the 3-line preamble makes the anchor un...
- g-empty-throw (refuted): v12.31 g-empty-throw: the belt key on an empty throwable cell names what is missing instead of cycling the hidden selector and throwing a different grenade -- The underlying finding is real and anchor 1 is sound, but the spec as written must not ship. (1) Version collision: v12.31 and v12.32 are already claimed by existing queued drafts â€” f1231.ps1 line 24 inserts {v:'12.31'} (crafting hold-button) and f1232.ps1 line 24 inserts {v:'12.32'} (footprints), both live in tools\handoff and not in parked\. The spec enumerates the queue as 1228/1229/1230 only...
- howler-wall (refuted): v12.28 - howler-wall: a solid wall stops the Howler blast, the way it already stops a Frag Charge -- WHAT CHECKS OUT (do not re-verify): (a) Both anchors are verbatim and unique. dark_raiders.html:11846-11848 and 11853-11855 match the quoted text character for character including the 2/4-space indents; `var dp=dist(p,{x:SH.tx,y:SH.ty});` -> 1 hit (11846), `if(de<R+e.r){` -> 1 hit (11855), `if(_onRoof&&underSameRoof(_roof,e.x,e.y)) continue;` -> 1 hit (11853). (b) The defect IS still open: the los...
- howler-crater (refuted): v12.31: the Howler stops taking a bearing from its own shell burst (finding howler-crater) -- The FINDING is real and the ANCHORS are clean, but the CHECK's control failure is not guaranteed, so the build must not ship as specified.

WHAT VERIFIES (all confirmed by reading C:\claudecode\dark raiders\dark_raiders.html):
- Tree is at v12.28, as the spec itself corrects: line 1361 `var VER='12.28';`, line 1372 `var WHATSNEW_VER='12.28';`.
- The loop is real and still open. dark_raiders.html:1...
