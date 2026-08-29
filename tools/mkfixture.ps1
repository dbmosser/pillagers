param([string]$Root = 'C:\claudecode\dark raiders',[string]$Src='',[string]$Dst='')
# Builds tools\fixture.html: the game with a set of window.__* test hooks
# injected at the boot banner, so a headless check can drive the real code.
# Rebuild it after EVERY edit to dark_raiders.html, then verify against it.
# -Src and -Dst let a fixture be built from an OLD revision of the game, which is how
# a paired A/B is run: git show <rev>:dark_raiders.html to a file, build a second
# fixture from it, then put the same seed list through both and compare per seed.
$src = if($Src){ $Src } else { Join-Path $Root 'dark_raiders.html' }
$dst = if($Dst){ $Dst } else { Join-Path $Root 'tools\fixture.html' }
$needle = '// ================================================================ boot'
# Only names that exist in the 2.5D source. An object literal naming a missing
# function throws at definition time and silently kills every hook after it,
# which is exactly what castColumn/worldOf/rayRect/zbuf/VM/SPR did: those are
# first-person leftovers from another project and were never in this game.
$inject = @'
window.__frame=function(dt){ render2D(dt===undefined?0.016:dt); };
window.__state=function(){ return G; };
// The telemetry consent rule, exposed so its truth table can be driven. autoExport
// and downloadExport are stubbed below and must stay stubbed, so this is the only
// way to check where a report would have been allowed to go.
window.__telemetryDest=function(pub,loc,shared,proto){ return telemetryDest(pub,loc,shared,proto); };
// Reads the message system from INSIDE the module, so a test can tell "say did
// not run" apart from "say ran but I am holding a different G".
window.__say=function(m){ say(m); return {inside:(G?G.msg:null),sim:(G?!!G.sim:null),sameG:(G===window.__state())}; };
window.__msg=function(){ return G?{msg:G.msg,msgT:G.msgT,sim:!!G.sim}:null; };
window.__cam=function(){ return {x:camX,y:camY}; };
// v3.61: __cfg now accepts an optional patch. It silently ignored its argument
// for the whole project, so every probe that "set" a dial through it was a
// no-op that happened to coincide with __pinDefaults' pins. The v3.51 healing
// probe's two identical arms were this, not only the pin re-application.
window.__cfg=function(p){ if(p){ for(var k in p) CFG[k]=p[k]; } return CFG; };
window.__keys=function(){ return keys; };
window.__mouse=function(){ return mouse; };
window.__sim=function(dt){ refreshVseg(); updatePlayer(dt); updateEnts(dt); updateThrowables(dt); };
window.__tickFx=function(dt){
  var i;
  for(i=G.tracers.length-1;i>=0;i--){ G.tracers[i].t+=dt; if(G.tracers[i].t>G.tracers[i].life) G.tracers.splice(i,1); }
  for(i=G.flashes.length-1;i>=0;i--){ G.flashes[i].t+=dt; if(G.flashes[i].t>G.flashes[i].life) G.flashes.splice(i,1); }
  for(i=G.sparks.length-1;i>=0;i--){ var s=G.sparks[i]; s.t+=dt; if(s.t>s.life) G.sparks.splice(i,1); }
};
window.__nav={spotFree:spotFree,collide:collide,dist:dist,losClear:losClear,canSee:canSee,
  freeSpot:freeSpot,spotIn:spotIn,rayHit:rayHit,conePoly:conePoly,buildVisPoly:buildVisPoly};
window.__navPath=function(nav,sx,sy,tx,ty){ return navPath(nav,sx,sy,tx,ty); };
window.__rawStep=function(dt){ simStep(dt); };
window.__endRaid=function(how){ endRaid(how); };
window.__reportProbe=function(runs){
  // Make the quiet drop unreachable and count how many runs actually get saved.
  var saved=0, origFetch=window.fetch, origCreate=URL.createObjectURL;
  window.fetch=function(){ return Promise.reject(new Error('drop down')); };
  URL.createObjectURL=function(){ saved++; return 'blob:probe'; };
  var status=[];
  var chain=Promise.resolve();
  for(var i=0;i<runs;i++){
    chain=chain.then(function(){
      P.runs++;
      autoExport();
      return new Promise(function(r){ setTimeout(function(){ status.push(P.lastReport); r(); },0); });
    });
  }
  return chain.then(function(){
    window.fetch=origFetch; URL.createObjectURL=origCreate;
    return {runsPlayed:runs, filesSaved:saved, statusAfterEachRun:status};
  });
};
// The preview pane is 641x550, far narrower than a real play window, which
// distorts anything measured about what fits on screen. This forces the canvas
// to a stated size so readings are representative.
window.__forceSize=function(w,h){
  cv.style.width=w+'px'; cv.style.height=h+'px';
  hcv.style.width=w+'px'; hcv.style.height=h+'px';
  resize();
  return {W:W,H:H,dpr:DPR,cv:[cv.width,cv.height]};
};
window.__canvases=function(){ return {world:cv,overlay:hcv}; };
window.__movers={seekPoint:seekPoint,navSeek:navSeek,mkSentry:mkSentry,mkRaider:mkRaider,dist:dist,buildNav:buildNav};
window.__newRaid=function(){ G=buildRaid(true); return G; };
window.__hub=function(){ return HB; };
// showScreen('hub') is the ONLY thing that builds HB, so every hub probe before
// this hook existed had to reach for HB through a raid ending and got null.
window.__showScreen=function(s){ showScreen(s); };
// COSMETICS. Purely cosmetic, so nothing here can move a balance number, but the
// unlock rules still have to be driven: a locked hat must never end up worn.
window.__cos={list:function(){ return COSMETICS; },
              owned:function(c){ return cosOwned(typeof c==='string'?cosFind(c):c); },
              need:function(c){ return cosNeed(typeof c==='string'?cosFind(c):c); },
              worn:function(k){ return cosWorn(k); },
              render:function(){ return renderCosmetics(); }};
window.__hubStep=function(dt){ dt=(dt===undefined||!isFinite(dt))?0.016:dt; updateHubWorld(dt); drawHubWorld(dt); };
// __startRaid TOOK NO ARGUMENTS until 2026-08-26 and silently ignored everything
// passed to it, so every __startRaid({mapIx:m,seed:s}) in a verification run built
// whatever map P.mapIx already held, with an unpinned seed. Four-map render checks
// were one map four times and said nothing about the other three. buildRaid reads
// P.mapIx and pendSeed, so both are set here before the call, which is the same
// route __simSeedsFull uses and the reason its per-map numbers were sound.
window.__startRaid=function(o){
  o=o||{};
  if(o.mapIx!==undefined) P.mapIx=clamp(o.mapIx|0,0,FIXED_MAPS.length-1);
  if(o.seed!==undefined) pendSeed=o.seed>>>0;
  return startRaid();
};
window.__mapOverlay=function(){ drawMapOverlay(); return {w:W,h:H,dpr:DPR}; };
// Damage a breakable by index into G.map.walls and report ONLY scalars: handing
// back the wall object serialises the whole geometry graph and blows the result
// budget, which is how the first attempt at this test failed.
window.__hitWall=function(ix,amt){
  var w=G.map.walls[ix];
  if(!w) return {err:'no wall at '+ix};
  var dead=damageWall(w,amt,w.x+w.w/2,w.y+w.h/2);
  return {dead:!!dead,hpLeft:(w.hpLeft===undefined?null:Math.round(w.hpLeft)),
          hpMax:(w.hpMax===undefined?null:w.hpMax),
          onList:(G.dmgWalls?G.dmgWalls.length:-1),
          stillInWalls:G.map.walls.indexOf(w)>=0};
};
window.__wallIndex=function(pred){
  for(var i=0;i<G.map.walls.length;i++){ var w=G.map.walls[i];
    if(pred==='wreck'&&w.wreck) return i;
    if(pred==='furn'&&w.furn) return i;
    if(pred==='win'&&w.win) return i;
    if(pred==='door'&&w.door) return i; }
  return -1;
};
// Lets a measurement rebuild the map at the pre-v0.68 world size so before and
// after are read off the same code path instead of off my arithmetic.
// Samples one sim raid so a stall can be told apart from a decision never made.
window.__simTrace=function(){
  G=buildRaid(true);
  var samples=[],guard=0,cap=Math.round(CFG.raidSec/0.15)+200,next=0;
  while(!G.over&&guard<cap){
    simStep(.15); guard++;
    if(G.t>=next){
      next+=10;
      var p=G.player,z=G.active;
      samples.push({t:Math.round(G.t),left:Math.round(G.timeLeft),
        bag:+bagWeight().toFixed(1),cap:PACKCAP[P.pack],
        dz:Math.round(dist(p,z)),x:Math.round(p.x),y:Math.round(p.y),
        seeking:(bagWeight()>=CFG.simGreed||bagWeight()>=PACKCAP[P.pack]||G.timeLeft<CFG.extractWait+120||(p.ammo+p.reserve)<=0)?1:0});
    }
  }
  if(!G.over){ G.tel.deathKiller='timer'; endRaid('dead'); }
  var r=G.simResult; G=null;
  return {outcome:r.outcome,killer:r.killer,greed:CFG.simGreed,samples:samples};
};
window.__setWorld=function(w,h){ WORLD_W=w; WORLD_H=h; AREA=(WORLD_W*WORLD_H)/(2600*2000); return {WORLD_W:WORLD_W,WORLD_H:WORLD_H,AREA:AREA}; };
window.__ctxCanvas=function(){ return ctx.canvas; };
window.__hud=function(){ drawHUD(); };
window.__conceal={bushAt:inBush,at:concealAt,mapBush:bushAtMap};
window.__emote={do:doEmote,list:EMOTES,down:weaponDown,ids:function(){return IDENTITIES;},rec:idRec};
window.__con={gen:genContract,label:gearLabel,pay:payGear,tier:contractTier,tiers:CTIER,gear:CGEAR,stand:cstand,render:renderHub};
window.__arm={list:ARMORS,by:armorById,mine:myRig,cap:armorCap,ping:ping,hurt:damagePlayer,shop:renderShop,SHOP:SHOP};
window.__weak={pts:WEAKPTS,of:weakOf,pos:weakPos,hit:weakHit,apply:applyWeak};
window.__bullets=function(dt){ updateBullets(dt); };
window.__optic={mag:opticMag,CH:CH,VF:VF,AMBR:AMBR};
window.__stray={make:mkStray,give:strayGive,reveal:strayReveal,wants:STRAY_WANTS};
window.__body={here:bodyHere,age:bodyAge,line:bodyLine,recover:bodyRecover,RAIDS:BODY_RAIDS};
window.__listen={make:mkListener,hear:listenersHear,R:LISTEN_R};
window.__spike={odds:windfallOdds,box:mkStrongbox,pool:WINDFALL,open:openContainer};
window.__wxturn={tick:wxTick,mix:wxMix,list:WEATHER,TURN:WX_TURN,cur:wx};
window.__voice={tick:tickMachineVoices,map:VOICE,budget:function(){return VOICE_BUDGET;},blip:blip};
window.__terms={list:TERMS,on:termsOn,has:hasTerm,pay:termsPay,toggle:toggleTerm,render:renderTerms};
window.__pack={call:packCall,scatter:packScatter,R:packR,max:packMax};
window.__seal={rec:sealRec,need:sealNeed,here:sealHere,spot:sealSpot,pay:sealPayout,lines:sealLines};
window.__wear={steps:WEARSTEPS,of:wearOf,step:wearStep,add:addWear,able:wearable,cost:repairCost,repair:repairGun,work:renderWork};
// updateEnts alone, so a detection test can pin the player's stance instead of
// having updatePlayer recompute it from keys that are not held.
window.__ents=function(dt){ refreshVseg(); updateEnts(dt); };
window.__space={at:spaceAt,surf:surfAt,verb:verb,tick:tickVerb,rev:function(){return REV;},
  name:function(){return SPACE_N;},steps:tickPlayerSteps,pstep:function(){return PSTEP;}};
window.__ped={open:pedOpen,sell:pedSellAll,buy:pedBuy,make:mkPeddler,draw:drawTrade};
window.__raidKey=function(c){ raidKey(c,false,null); };
// The button driven bot sim hands control back through setTimeout, which the
// browser pane freezes whenever it is not being displayed. This runs the exact
// same inner loop synchronously so a batch completes inside one call.
window.__simBatch=function(n){
  var res=[],i,t0=performance.now();
  for(i=0;i<n;i++){
    G=buildRaid(true);
    var guard=0,cap=Math.round(CFG.raidSec/0.15)+200;
    while(!G.over&&guard<cap){ simStep(.15); guard++; }
    if(!G.over){ G.tel.deathKiller='timer'; endRaid('dead'); }
    res.push({r:G.simResult,guard:guard,cap:cap});
    G=null;
  }
  return {ms:performance.now()-t0,res:res};
};
// The recorder is the thing he actually sends back, so it has to be provable that
// it does not throw. Anything added to buildExport gets checked through this.
window.__export=function(){ return buildExport(); };
// The cost of a heavy bag, so the curve can be read off the real function rather than
// off my arithmetic, and so the loadPen slider can be proven to reach zero.
// TIMING: WARM FOR AT LEAST 100 FRAMES BEFORE MEASURING ANYTHING.
// A short warm gives readings that are pure JIT cold start and they look exactly like
// a catastrophic regression. This has now cost two investigations: COLD STORAGE read
// 11.33ms a frame at 40 warm frames and 2.41 at 120, and THE QUARRY read a 9.03ms sim
// step at 40 and 0.43 at 120. Both were nothing. Warm 120, then measure twice and
// distrust the first pass.
window.__load=function(w){ return loadOf(w); };
window.__tell=function(ct){ return ammoTell(ct); };
window.__season={tiers:SEASON_TIERS,claim:claimTier,claimed:seasonClaimed,ready:seasonReady,no:seasonNo,tier:worldTier,label:tierLabel,sp:spForRun};
window.__repair={cost:repairCost,replace:replaceCost,go:repairGun};
// Container opening, whole or by subset, so the staged pull can be driven and checked
// without needing a key held down for four seconds of real time.
window.__open=function(ct,keys){ return openContainer(ct,keys); };
// Item value and the item table, so a probe can price a container's contents.
// ival applies rarity and market modifiers on top of the raw table value, so
// reading ITEMS[k].val directly would understate everything.
window.__ival=function(k){ return ival(k); };
// Banking an extracted item, so the armoury invariant can be tested directly
// rather than by driving a whole raid to a successful extraction.
window.__bank=function(k){ return bankItem(k); };
// The hotbar and the carried-armour verb, so the slot list and the slotting
// rule can be driven headlessly instead of through a keypress.
window.__hotbar=function(){ return hotbarSlots(); };
window.__useArmor=function(){ return useArmor(); };
window.__useHot=function(){ return useHot(); };
window.__pedBuy=function(i){ return pedBuy(i); };
// The weapon table, so shots-to-kill can be varied from the WEAPON side
// instead of the health side and the two separated causally.
window.__weapons=function(){ return WEAPONS; };
// The pickup-voice chooser and the blip synth, so a rarity ladder can be checked
// without anything being audible. blip() returns early on a sim raid and the
// fixture blocks AudioContext, so calling it here stays silent by construction.
window.__lootVoice=function(keys){ return lootVoice(keys); };
window.__feudFoe=function(a,b){ return feudFoe(a,b); };
// Water membership, for diagnostics. A v2.66 probe silently measured zero wading
// on the wettest map because inWater lives inside the IIFE and typeof from page
// scope read undefined; a hook makes that failure impossible to repeat.
window.__water={at:inWater};
window.__tune={toggle:toggleTune,sliders:function(){return SLIDERS;}};
// Renders the hub scene INCLUDING its HUD and any card; __frame only draws raids.
window.__hubFrame=function(dt){ drawHubWorld(dt===undefined?0.016:dt); };
// The hub state itself, so a cold-start walk can visit stations for real.
window.__hb=function(){ return HB; };
// The MAIN LOOP, steppable with synthetic timestamps, because deathBeat and the
// whole live-raid frame path exist only inside loop() and a hidden pane never
// fires its rAF. Each call arms one more rAF, which is exactly the loop
// resuming normally if the pane ever becomes visible, so this is safe to drive.
window.__loop=function(ts){ loop(ts); };
// Placement sanity audit, v2.86: counts of props sitting on ground they should
// not, plus the culls makeMap already performed this raid.
window.__placeAudit=function(){
  var m=G&&G.map; if(!m) return null;
  // The game's own definition of wet, building-floor exemption included, or the
  // audit flags a lamp on a dry powerhouse floor as standing in the lake.
  function wet(x,y){ return inWaterMap(m,x,y); }
  function road(x,y){ for(var q=0;q<(m.roadRects||[]).length;q++){ var R3=m.roadRects[q];
    if(x>=R3.x&&x<=R3.x+R3.w&&y>=R3.y&&y<=R3.y+R3.h) return true; } return false; }
  var out={culledThisRaid:m.cullLog||null, live:{bushWater:0,bushRoad:0,treeWater:0,treeRoad:0,
    wreckWater:0,containerWater:0,lampWater:0,bushes:m.bushes.length,roadRuns:(m.roadRects||[]).length}};
  m.bushes.forEach(function(b){ if(wet(b.x,b.y))out.live.bushWater++; else if(road(b.x,b.y))out.live.bushRoad++; });
  m.walls.forEach(function(w){
    if(w.tree){ var cx=w.x+w.w/2,cy=w.y+w.h/2;
      if(wet(cx,cy))out.live.treeWater++; else if(road(cx,cy))out.live.treeRoad++; }
    else if(w.wreck){ if(wet(w.x+w.w/2,w.y+w.h/2))out.live.wreckWater++; }
  });
  (G.containers||[]).forEach(function(c){ if(wet(c.x,c.y))out.live.containerWater++; });
  (G.lights||[]).forEach(function(l){ if(wet(l.x,l.y))out.live.lampWater++; });
  return out;
};
// THE MEASUREMENT BASELINE, ONE CALL, v2.67. Every batch this cycle opened with
// the same twenty hand-typed dial assignments, and twice a smoke test that
// skipped them produced rates that meant nothing and briefly looked like
// findings. This is the canonical pin: every dial a measurement arm depends on,
// set to the shipped-default measurement posture, returning what it changed so a
// probe can log it. Arms then override ONLY the dial under test. mapIx and
// equipment are pinned too, since forgetting the map is the other classic.
window.__pinDefaults=function(mapIx){
  var C2=CFG, P2=P, changed={};
  // DANIEL POSTURE. The pin is simGreed 14. The v3.85 note here still said 23,
// "calibrated from his 47 real runs", long after the pin was deliberately
// recalibrated 23 -> 14 on 2026-08-27 against a 49-run fingerprint. The move was
// right and recorded; this comment was simply never updated with it, so it has
// been describing a posture the harness stopped using.
// Priced at v4.94 rather than silently corrected either way, 320 paired seeds on
// COLD STORAGE: greed 14 extracts 13.8 percent, greed 23 extracts 8.4 percent,
// 43 discordant, p = 0.0137. So the documented value is the WORSE match to him,
// not the better one, and moving the pin to 23 would widen the gap this comment
// exists to close. The pin stays at 14 and the comment is now true.
// THE GAP ITSELF, measured at v4.94 against his 29 logged COLD STORAGE runs:
//   he extracts 41.4 percent, the bot 13.8. He is three times better.
//   his median haul 3,260c, the bot 2,010c. He is richer AND safer at once,
//   which is why no single greed value can reconcile them: greed trades one for
//   the other and he is winning both.
//   what kills him: raider 5, crawler 4, sentry 2. What kills the bot: sentry
//   147, raider 68, crawler 27. The bot's real weakness is sentries, and that is
//   a fighting and route problem, not a looting dial.
// His order stands: the bot is the benchmark. It is currently a bad one for
// absolute numbers. Paired A/B on one map still prices a change honestly, which
// is what these batches are actually for.
var want={simGreed:14,simCrouch:0,simSell:0,simPed:0,simSidearm:1,simSwapBack:1,
    simWade:1,simLootNoise:1,simJam:1,navBackoff:1,cacheReach:1,campNorm:1,rigCap:1,
    seeStrict:1,siegePerZone:1,beaconMirror:1,hauledAboard:1,simPip:0,simPinTier:1,
    eHp:1,lootMult:1,windows:1,simEngage:0,raiderFeud:1,simReach:1,healOverTime:1,
    simRetreatHeal:0,placeCull:1,
    // Dials added after this list was written were NOT being pinned, so a value
    // left dirty by an aborted probe survived every later __pinDefaults and could
    // silently contaminate a measurement. Caught when a timed-out probe left
    // chaseGiveUp at 1 and the next pinned run still read 1. __pairedBg sets and
    // restores its own dials so the A/Bs were safe, but nothing else was.
    // Same defect again at v3.17: raiderDown shipped unpinned. Every new dial
    // must land here in the same build that introduces it.
    destruct:1,raiderWear:1,penetrate:1,raiderDown:1,siegePull:0.5,siegeVol:1,siegeEcho:1,decay:1,simRig:'light',smokeR:165,fragR:150,healSolo:1,healSlow:1.6,extOutside:1,raiderWaves:1,raiderWaveCap:8,raiderWaveMin:12,raiderWaveGap:60,raiderKit:1,spawnClear:1150,raiderHaul:7,healPow:0.70,healSlow:2.4,wardenHp:900,wardenDmg:46,wardenRng:620,downTime:17,healPrep:1.5,armorPrep:2,lodR:1100,raiderBeacon:1,eliteRate:0.08,eliteHp:2.2,eliteDmg:1.6,nHowler:2,nBulwark:1,bulwarkArc:1.15,bulwarkSoak:0.12,machVsRaider:0,howlerDmg:35,howlerAir:2.1,howlerR:90,simAim:52,simPick:1,simFlee:1,simCover:1,simHoldFire:0,simDodgeRing:1,
    // v3.41 gave the PLAYER plain-language control of eight of these dials and
    // persists his choice on the profile. The fixture loads that profile, so a
    // saved "Raiders: Many" would silently run every A/B at nRaider 15 and every
    // number in this file would drift without anything looking wrong. Same
    // contamination v3.10 caught with chaseGiveUp, one layer up: a dial the
    // PLAYER can now move has to be pinned like any other.
    nRaider:10,nSentry:20,nCrawler:34,eDmg:1,raidSec:600};
  for(var k in want){ if(C2[k]!==want[k]){ changed[k]=[C2[k],want[k]]; C2[k]=want[k]; } }
  P2.mapIx=(mapIx===undefined)?1:mapIx;
  P2.body=null; P2.equipped='smg'; P2.wear=P2.wear||{}; P2.wear['smg']=0;
  return {pinned:true, mapIx:P2.mapIx, changed:changed};
};
// And a sim raid that can be STEPPED from outside, so a diagnostic can sample
// state mid-raid while keeping sim semantics. __simSeedsFull owns the batch case;
// this owns the instrumented-single-raid case that keeps getting hand-rolled
// wrongly against live raids.
window.__simRaidBegin=function(seed){ pendSeed=seed>>>0; G=null; G=buildRaid(true); return true; };
window.__simRaidStep=function(dt){ if(!G||G.over) return false; simStep(dt||0.15); return !G.over; };
window.__simRaidEnd=function(){
  if(!G) return null;
  if(!G.over){ G.tel.deathKiller='probe'; endRaid('dead'); }
  var r=G.simResult; G=null; return r;
};
// BACKGROUNDED PAIRED BATCH, v2.60. Every 320-seed comparison this cycle was run
// by hand-rolling the same MessageChannel loop into the console, five times, with
// the same mistakes available every time (setTimeout throttling, forgetting to
// restore dials, stopping early at a good-looking split). This is that loop, once,
// with the McNemar arithmetic attached. Start it, poll __pairedPoll(), read the
// result when done:true. MessageChannel and never setTimeout, because a hidden tab
// throttles setTimeout to one callback a minute and these batches run unattended.
window.__pairedBg=function(seeds,dialsA,dialsB,keepRows){
  // keepRows stores {seed, a:{outcome,killer,haul,tod}, b:{...}} per seed. Off by
  // default because 320 full rows is memory nobody reads unless the question is
  // attributional, which every killer-table question this cycle turned out to be.
  var st={a:0,b:0,c:0,d:0,done:0,n:seeds.length,fin:false,rows:keepRows?[]:null};
  window.__PBG=st;
  var save={},k;
  for(k in dialsA) save[k]=CFG[k];
  for(k in dialsB) if(!(k in save)) save[k]=CFG[k];
  function step(){
    var t0=Date.now();
    while(st.done<st.n && Date.now()-t0<20000){
      var s=seeds[st.done];
      for(k in dialsA) CFG[k]=dialsA[k];
      var ra=window.__simSeedsFull([s])[0];
      for(k in dialsB) CFG[k]=dialsB[k];
      var rb=window.__simSeedsFull([s])[0];
      var xa=(ra.outcome==='extract')?1:0, xb=(rb.outcome==='extract')?1:0;
      if(xa&&xb)st.a++; else if(xa&&!xb)st.b++; else if(!xa&&xb)st.c++; else st.d++;
      if(st.rows) st.rows.push({seed:s,
        a:{outcome:ra.outcome,killer:ra.killer||null,haul:ra.haul,tod:ra.timeOfDeath},
        b:{outcome:rb.outcome,killer:rb.killer||null,haul:rb.haul,tod:rb.timeOfDeath}});
      st.done++;
    }
    if(st.done>=st.n){
      for(k in save) CFG[k]=save[k];
      st.fin=true;
      return;
    }
    mc.port2.postMessage(0);
  }
  var mc=new MessageChannel();
  mc.port1.onmessage=step;
  mc.port2.postMessage(0);
  return {started:true, n:st.n};
};
window.__pairedPoll=function(){
  var st=window.__PBG;
  if(!st) return {err:'no batch started'};
  if(!st.fin) return {done:st.done, of:st.n, onlyA:st.b, onlyB:st.c, finished:false};
  var n=st.n, b=st.b, c=st.c, disc=b+c;
  var chi=disc>0?Math.pow(Math.abs(b-c)-1,2)/disc:0;
  function lch(nn,kk){var s2=0;for(var i=0;i<kk;i++)s2+=Math.log(nn-i)-Math.log(i+1);return s2;}
  var p=0,mn=Math.min(b,c);
  if(disc>0){ for(var kk=0;kk<=mn;kk++) p+=Math.exp(lch(disc,kk)-disc*Math.log(2)); p=Math.min(1,2*p); }
  else p=1;
  var out={finished:true, n:n,
    rateA:+(100*(st.a+b)/n).toFixed(1), rateB:+(100*(st.a+c)/n).toFixed(1),
    table:{both:st.a,onlyA:b,onlyB:c,neither:st.d},
    discordant:disc, z:+Math.sqrt(chi).toFixed(2), exactTwoSidedP:+p.toFixed(5)};
  if(st.rows){
    // The killer tables per arm, computed here so the console never has to.
    var ka={},kb={};
    st.rows.forEach(function(r){
      var k1=r.a.killer||'(extract)'; ka[k1]=(ka[k1]||0)+1;
      var k2=r.b.killer||'(extract)'; kb[k2]=(kb[k2]||0)+1;
    });
    out.killersA=ka; out.killersB=kb; out.rows=st.rows;
  }
  return out;
};
window.__blip=function(t){ return blip(t); };
// PAIRED ARMS AND THE TEST THAT GOES WITH THEM, v2.42. Two arms run over one seed
// list are PAIRED, and comparing their extract rates as if they were independent
// samples throws the pairing away and reads far more into a gap than is there.
// v2.42 measured the cost: four 120-seed blocks of the UNCHANGED game span 9.2
// points of extract rate, so a single arm's rate is worth about plus or minus 4.
// This runs both arms on each seed before moving to the next, which keeps the
// pairing exact, and returns McNemar's table so the right test is the easy one.
// dialsA and dialsB are merged into CFG for their own arm only; every other dial
// must already be pinned by the caller.
window.__simPaired=function(seeds,dialsA,dialsB){
  var rows=[],a=0,b=0,c=0,d=0,k;
  var save={}; for(k in dialsA) save[k]=CFG[k]; for(k in dialsB) save[k]=CFG[k];
  for(var i=0;i<seeds.length;i++){
    var ra,rb;
    for(k in dialsA) CFG[k]=dialsA[k];
    ra=window.__simSeedsFull([seeds[i]])[0];
    for(k in dialsB) CFG[k]=dialsB[k];
    rb=window.__simSeedsFull([seeds[i]])[0];
    var xa=(ra.outcome==='extract')?1:0, xb=(rb.outcome==='extract')?1:0;
    if(xa&&xb)a++; else if(xa&&!xb)b++; else if(!xa&&xb)c++; else d++;
    rows.push({seed:seeds[i],a:ra,b:rb});
  }
  for(k in save) CFG[k]=save[k];
  var n=seeds.length, disc=b+c;
  var chi=disc>0?Math.pow(Math.abs(b-c)-1,2)/disc:0;
  function lch(nn,kk){var s=0;for(var i2=0;i2<kk;i2++)s+=Math.log(nn-i2)-Math.log(i2+1);return s;}
  var p=0,mn=Math.min(b,c);
  if(disc>0){ for(var kk=0;kk<=mn;kk++) p+=Math.exp(lch(disc,kk)-disc*Math.log(2)); p=Math.min(1,2*p); }
  else p=1;
  return {n:n, rateA:+(100*(a+b)/n).toFixed(1), rateB:+(100*(a+c)/n).toFixed(1),
    table:{bothExtract:a,onlyA:b,onlyB:c,neither:d}, discordant:disc,
    mcnemarChi:+chi.toFixed(2), z:+Math.sqrt(chi).toFixed(2),
    exactTwoSidedP:+p.toFixed(4), rows:rows};
};
window.__setHot=function(i){ return setHot(i); };
window.__items=function(){ return ITEMS; };
window.__loot=function(){ return LOOT; };
// v3.26: the auto-equip preference resolver and the settings renderer, so the
// precedence rule (bot obeys the dial, player obeys his setting) can be driven
// rather than asserted, and so the settings rows can be read back as strings.
window.__autoEquip={on:function(){ return autoEquipOn(); },settings:function(){ renderSettings(); },
  grant:function(ct,keys){ return grantLoot(ct,keys); }};
window.__bestRarity=function(a){ return bestRarity(a); };
window.__simSeedsFull=function(seeds){
  var out=[],i;
  for(i=0;i<seeds.length;i++){
    pendSeed=seeds[i]>>>0;
    // NULL IT FIRST. buildRaid reads G during construction in several places and
    // does not assign it until after it returns, so a leftover G from a played
    // raid, a __newRaid, or an exception thrown mid loop would be read as the
    // current raid and poison this batch's first seed. The loop already nulls G
    // at the end of every iteration, which is why batches are stable in practice;
    // this makes that a guarantee rather than a side effect.
    G=null;
    G=buildRaid(true);
    var guard=0,cap=Math.round(CFG.raidSec/0.15)+200;
    while(!G.over&&guard<cap){ simStep(.15); guard++; }
    if(!G.over){ G.tel.deathKiller='timer'; endRaid('dead'); }
    var r=G.simResult;
    r.seed=seeds[i]>>>0; r.beaconT=(G.beaconT!==null&&G.beaconT!==undefined)?1:0;
    out.push(r); G=null;
  }
  return out;
};
window.__world=function(){ return {w:WORLD_W,h:WORLD_H}; };
// WINDFALL PROBE. Reports windfallOdds broken into its three terms at every
// container on the current raid, so the promise ("odds rise with distance from a
// way out, time on the surface, and danger") can be checked against real geometry
// rather than against the comment that describes it.
window.__wf=function(atSec){
  if(!G) return null;
  var save=G.timeLeft;
  if(atSec!==undefined&&atSec!==null) G.timeLeft=CFG.raidSec-atSec;
  var rows=[];
  for(var i=0;i<G.containers.length;i++){
    var c=G.containers[i];
    var near=1e9;
    for(var z=0;z<G.zones.length;z++){ var d=dist(c,G.zones[z]); if(d<near) near=d; }
    var danger=0,dLos=0,dAware=0,dAlive=0;
    for(var e=0;e<G.ents.length;e++){
      var E=G.ents[e];
      if(E.kind==='raider'||E.kind==='peddler'||E.kind==='stray') continue;
      if(dist(c,E)<340&&losClear(c.x,c.y,E.x,E.y,G.vseg||G.map.segs)){ danger=1; if(!E.dead) dAlive=1; if(losClear(c.x,c.y,E.x,E.y,G.vseg||G.map.segs)) dLos=1; if(E.alert||E.state==='chase'||E.state==='hunt'||E.state==='search') dAware=1; break; }
    }
    var out=CFG.raidSec-G.timeLeft;
    rows.push({kind:c.kind,near:Math.round(near),
      tDist:+(clamp(near/2600,0,1)*0.10).toFixed(4),
      tTime:+(clamp((out-240)/420,0,1)*0.08).toFixed(4),
      tDang:danger?0.10:0,dLos:dLos,dAware:dAware,dAlive:dAlive,
      odds:+windfallOdds(c.x,c.y).toFixed(4)});
  }
  G.timeLeft=save;
  return {raidSec:CFG.raidSec,zones:G.zones.length,cons:rows.length,rows:rows};
};
// Paired A/B. Runs an explicit list of seeds so the SAME raids can be put through
// two builds and compared pairwise. Unpaired 30v30 comparisons are close to a coin
// flip; the sign of a paired difference is right about 95 percent of the time at 100
// seeds. Returns one row per seed so flips can be named, not just counted.
// HOW TO DRIVE A LONG BATCH FROM A HIDDEN PANE. A batch of 60 raids is about ten
// minutes of blocking main thread, far past the 30s eval limit, so it has to be
// chunked. Do NOT chain the chunks with setTimeout: a hidden tab throttles timers
// to roughly one per minute and the batch crawls. Measured on 2026-08-23: 36 raids
// in 12 minutes on setTimeout, then 10 raids in 90 seconds after switching to
// MessageChannel, which Chrome does not throttle. Pattern:
//   var mc=new MessageChannel();
//   mc.port1.onmessage=function(){ ...run 3 seeds...; if(more) mc.port2.postMessage(0); };
//   mc.port2.postMessage(0);
// Then poll a global from a separate eval. Fronting the tab is not a reliable fix.
window.__simSeeds=function(seeds){
  var out=[],i,t0=performance.now();
  for(i=0;i<seeds.length;i++){
    pendSeed=seeds[i]>>>0;
    // NULL IT FIRST. buildRaid reads G during construction in several places and
    // does not assign it until after it returns, so a leftover G from a played
    // raid, a __newRaid, or an exception thrown mid loop would be read as the
    // current raid and poison this batch's first seed. The loop already nulls G
    // at the end of every iteration, which is why batches are stable in practice;
    // this makes that a guarantee rather than a side effect.
    G=null;
    G=buildRaid(true);
    var guard=0,cap=Math.round(CFG.raidSec/0.15)+200;
    while(!G.over&&guard<cap){ simStep(.15); guard++; }
    if(!G.over){ G.tel.deathKiller='timer'; endRaid('dead'); }
    var r=G.simResult;
    out.push({seed:seeds[i]>>>0,o:r.outcome,haul:r.haul,dur:r.dur,killer:r.killer,cont:r.containers,kills:r.kills});
    G=null;
  }
  return {ms:performance.now()-t0,rows:out};
};
// Proves the seeding actually works before any conclusion is drawn from it. Runs the
// same seed twice and reports whether the two raids agree on every recorded field.
window.__seedCheck=function(seed,reps){
  var runs=[],i;
  for(i=0;i<(reps||3);i++) runs.push(__simSeeds([seed]).rows[0]);
  var a=JSON.stringify(runs[0]),same=1;
  for(i=1;i<runs.length;i++) if(JSON.stringify(runs[i])!==a) same=0;
  return {deterministic:!!same,runs:runs};
};
window.__seed={set:function(s){ pendSeed=(s>>>0); },cur:function(){ return RSEED; },srand:srand,rr:rr};
window.__bands=function(rows){ return haulBandLines(rows,'bands'); };
window.__setZoom=function(z){ setZoom(z,true); return ZOOM(); };
window.__zoom={set:setZoom,tick:tickZoom,cur:ZOOM,target:zoomTarget,
  min:function(){return ZMIN;},max:function(){return ZMAX;}};
window.__roll={try:tryRoll,spd:function(){return ROLLSPD;},stam:function(){return ROLLSTAM;}};
window.__getZoom=function(){ return ZOOM(); };
window.__prof=function(){ return P; };
// v4.18: the board only refills at boot, so a new contract kind could crash card
// creation and no sweep would ever roll it. This calls the real generator directly.
window.__genContract=function(){ return genContract(); };
// v4.77: the run-report status line, so a failure notice can be driven.
window.__syncReport=function(){ syncAutoEx(); return document.getElementById('reportline'); };
// v3.37: the REAL profile loader, so "does progression survive a session" can be
// driven rather than read. __load is loadOf(), a loadout helper, and calling it
// for this proved nothing at all.
window.__loadProfile=function(){ return loadProfile(); };
window.__primer={open:function(){ openPrimer(); },maybe:function(){ maybePrimer(); },list:function(){ return PRIMER; }};
window.__status={player:function(){ return playerStatus(); },raider:function(e){ return raiderStatus(e); },col:STATCOL};
window.__board=function(){ renderSeason(); return ROADMAP; };
// THE MUSIC, dry. Swaps the voice for a recorder and runs the sequencer over the
// whole theme without a speaker, so the harmony and the melody can be READ. I
// cannot hear the game; this is how a tune gets verified.
window.__musDry=function(steps){
  var out=[], real=musVoice;
  musVoice=function(aa,t,midi,type,vol,dur,atk,det){
    out.push({step:aa,midi:midi,type:type,vol:+(vol||0).toFixed(3),dur:dur,detune:det||1});
  };
  try{ for(var i=0;i<steps;i++) musNote(i,0,i); } finally { musVoice=real; }
  return out;
};
window.__musTheme=function(){ return {theme:HUB_THEME,chords:HUB_CHORDS}; };
window.__musWanted=function(){ return musicWanted(); };
// The drop check: the last screen before a raid, so it can be driven like every
// other one instead of only through a click path.
window.__stage={ render:function(pf){ return renderStage(pf); },
                 live:function(){ return stageKitLive(); },
                 slots:function(){ return DEPLOY_SLOTS; } };
// The sector page and its pre-deploy kit line, so the last screen before a drop
// can be driven and read like every other one.
window.__sector=function(){ renderSector(); return document.getElementById('sectorkit'); };
window.__saveProfile=function(){ return saveProfile(); };
try{ var _osp=saveProfile; saveProfile=function(){ var t0=performance.now(); var r=_osp.apply(null,arguments); _PT.save=(_PT.save||0)+(performance.now()-t0); _PSAVE=(_PSAVE||0)+1; return r; }; var _PSAVE=0; }catch(e){}
// The fixture must never write into his flight recorder. Test runs were landing
// in exports/ as real-looking runs with 0 duration and 0 movement, which is
// exactly the artefact class the tick rules warn about. Killed at source.
window.__isFixture=1;
// THE FIXTURE IS SILENT. Verification drives real frames, and real frames fire real
// gunshots, alarms and machine voices through WebAudio. On 2026-08-24 a 40 raid batch
// played all of it out loud on Daniel's PC while he was trying to work. He should never
// be able to hear my tests. Every emitter is stubbed at the source rather than relying
// on a gain of zero, because a later build could add a new node that misses the bus.
try{ sfx=function(){}; }catch(e){}
try{ blip=function(){}; }catch(e){}
// say() WAS STUBBED TO A NO-OP HERE AND IT IS NOT AN AUDIO EMITTER. Its whole body
// is `if(G&&!G.sim){G.msg=m;G.msgT=3.2;}`, a state write with no sound anywhere in
// it, so silencing it bought nothing and quietly broke every assertion any test
// could make about on-screen messages: G.msg simply never changed in the fixture.
// That cost a v3.01 changelog line admitting I could not verify two strings, when
// the game was fine and the harness was lying. It now does the real thing AND
// records the last line, so the fixture stays as silent as it ever was and a test
// can finally read what the game said.
try{ say=function(m){ window.__lastSay=m; if(G&&!G.sim){ G.msg=m; G.msgT=3.2; } }; }catch(e){}
try{ tickAmbience=function(){}; }catch(e){}
try{ tickEnemyAudio=function(){}; }catch(e){}
try{ tickPlayerSteps=function(){}; }catch(e){}
try{ tickMachineVoices=function(){}; }catch(e){}
// tickMusic is DELIBERATELY not stubbed here, departing from stub-at-source:
// the __music hook has to observe the real gate to verify it, and the throwing
// AudioContext below makes ac() return null so tickMusic cannot emit anyway.
// And belt and braces: never let an AudioContext start at all.
try{ if(window.AudioContext) window.AudioContext=function(){ throw new Error('fixture is silent'); }; }catch(e){}
try{ if(window.webkitAudioContext) window.webkitAudioContext=window.AudioContext; }catch(e){}
// The fixture must never write into his recorder OR his Downloads. The v1.31
// fix redirected DROP to a dead port, which stopped the collector posts but
// sent every probe run down the fetch-failure fallback, which is
// downloadExport(): my tests dribbled dark_raiders_run*.txt into his Downloads
// folder for days. Ten of them surfaced on 2026-08-22 and looked like real
// runs until the zero durations and killer:null gave them away.
// Both functions are declared ABOVE this injection point now (the file grew),
// and function declarations are hoisted regardless, so direct stubs stick.
// DROP stays redirected as belt and braces.
try{ DROP='http://127.0.0.1:9/blackhole'; }catch(e){}
try{ autoExport=function(){ if(typeof P!=='undefined'&&P) P.lastReport='fixture-stub'; }; }catch(e){}
try{ downloadExport=function(){ if(typeof P!=='undefined'&&P) P.lastReport='fixture-dl-stub'; }; }catch(e){}
window.__gun={roll:rollFieldGun,fire:fireWeapon,quals:GUNQ,wtier:WTIER,weapons:WEAPONS,items:function(){return ITEMS;}};
window.__pad={poll:pollPad,state:function(){ return PAD; },tap:function(){ return PADTAP; },
  hold:function(){ return PADHOLD; },legend:function(){ return LEGEND_PAD; }};
window.__mouseState=function(){ return mouse; };
// TWO TRAPS WHEN DRIVING HELD-KEY ACTIONS ACROSS MORE THAN ONE RAID. Both cost a
// diagnosis on 2026-08-24 while testing THE SEAL, and both look exactly like the game
// being broken rather than the harness.
// 1. showScreen does keys={} , which REPLACES the object rather than clearing it. A
//    reference captured once at the top of a test is stale the moment a raid ends, so
//    every later keypress goes into an orphan object and the action silently stops
//    happening. Call __keysRef() fresh inside each step, never hoist it.
// 2. Standing still in a live raid to hold a key gets you shot. The seal cut read 10.1
//    seconds against 15 asked for, purely because a crawler reached the tester. Pin
//    hp, clear downed and set iv every step when the point of the test is the mechanic
//    rather than the fight.
window.__keysRef=function(){ return keys; };
window.__wx={list:function(){ return WEATHER; },cur:wx,VF:VF,AMBR:AMBR,ping:ping,pick:pickWeather};
window.__music=function(){ tickMusic(); return {mode:musicMode(),wanted:musicWanted(),started:!!MUS.g,step:MUS.step,intensity:musIntensity(),smoothed:MUS.i,trk:(MUS.trk===undefined?null:MUS.trk),trkName:(MUS.trk===undefined?null:MUS_TRACKS[MUS.trk].name)}; };
window.__hudBox=function(){ return HUDBOX; };
window.__ghost={parse:parseGhost,apply:applyGhost};
window.__w2s=function(x,y){ return w2s(x,0,y); };
try{ var _ocs=canSee; canSee=function(){ var t0=performance.now(); var r=_ocs.apply(null,arguments); _PT.see=(_PT.see||0)+(performance.now()-t0); return r; }; }catch(e){}try{ var _ocol=collide; collide=function(){ var t0=performance.now(); var r=_ocol.apply(null,arguments); _PT.col=(_PT.col||0)+(performance.now()-t0); return r; }; }catch(e){}
try{ var _oskp=seekPoint; seekPoint=function(){ var t0=performance.now(); var r=_oskp.apply(null,arguments); _PT.skp=(_PT.skp||0)+(performance.now()-t0); return r; }; }catch(e){}
try{ var _omt=moveToward; moveToward=function(){ var t0=performance.now(); var r=_omt.apply(null,arguments); _PT.mt=(_PT.mt||0)+(performance.now()-t0); return r; }; }catch(e){}try{ var _onsk=navSeek; navSeek=function(){ var t0=performance.now(); var r=_onsk.apply(null,arguments); _PT.nsk=(_PT.nsk||0)+(performance.now()-t0); return r; }; }catch(e){}
try{ var _okit=raiderUseKit; raiderUseKit=function(){ var t0=performance.now(); var r=_okit.apply(null,arguments); _PT.kit=(_PT.kit||0)+(performance.now()-t0); return r; }; }catch(e){}
try{ var _opc=packCall; packCall=function(){ var t0=performance.now(); var r=_opc.apply(null,arguments); _PT.pack=(_PT.pack||0)+(performance.now()-t0); return r; }; }catch(e){}
try{ var _olhi=listenersHearInner; listenersHearInner=function(){ var t0=performance.now(); var r=_olhi.apply(null,arguments); _PT.hear=(_PT.hear||0)+(performance.now()-t0); return r; }; }catch(e){}try{ var _twav=tickRaiderWaves; tickRaiderWaves=function(){ var t0=performance.now(); var r=_twav.apply(null,arguments); _PT.waves=(_PT.waves||0)+(performance.now()-t0); return r; }; }catch(e){}
// perf instrumentation, fixture-only: count the expensive calls per __sim
var _PNAV=0,_PLOS=0;
try{ var _onav=navPath; navPath=function(){ _PNAV++; return _onav.apply(null,arguments); }; }catch(e){}
try{ var _olos=losClear; losClear=function(){ _PLOS++; return _olos.apply(null,arguments); }; }catch(e){}
var _PSEG=0,_PFS=0,_PSPOT=0;
try{ var _oref=refreshVseg; refreshVseg=function(){ _PSEG++; return _oref.apply(null,arguments); }; }catch(e){}
try{ var _ofs=freeSpot; freeSpot=function(){ _PFS++; var t0=performance.now(); var r=_ofs.apply(null,arguments); _PT.fs=(_PT.fs||0)+(performance.now()-t0); return r; }; }catch(e){}
try{ var _osw=spotWall; spotWall=function(){ _PSPOT++; return _osw.apply(null,arguments); }; }catch(e){}
window.__perfCounters=function(reset){ var r={nav:_PNAV,los:_PLOS,vseg:_PSEG,freeSpot:_PFS,spotWall:_PSPOT}; if(reset){_PNAV=0;_PLOS=0;_PSEG=0;_PFS=0;_PSPOT=0;} return r; };
var _PT={vseg:0,ents:0,player:0,thr:0};
try{ var _tref=refreshVseg; refreshVseg=function(){ var t0=performance.now(); var r=_tref.apply(null,arguments); _PT.vseg+=performance.now()-t0; return r; }; }catch(e){}
try{ var _tent=updateEnts; updateEnts=function(){ var t0=performance.now(); var r=_tent.apply(null,arguments); _PT.ents+=performance.now()-t0; return r; }; }catch(e){}
try{ var _tpl=updatePlayer; updatePlayer=function(){ var t0=performance.now(); var r=_tpl.apply(null,arguments); _PT.player+=performance.now()-t0; return r; }; }catch(e){}
try{ var _tth=updateThrowables; updateThrowables=function(){ var t0=performance.now(); var r=_tth.apply(null,arguments); _PT.thr+=performance.now()-t0; return r; }; }catch(e){}
window.__perfTimes=function(reset){ var r={},k; for(k in _PT) r[k]=+(+_PT[k]).toFixed(2); if(reset) for(k in _PT) _PT[k]=0; return r; };
window.__audio={amb:tickAmbience,steps:tickEnemyAudio,sfx:sfx,blip:blip,ears:earsOf,
  bus:bus,ctx:ac,ambObj:function(){ return AMB; }};
window.__bag={weight:bagWeight,drop:dropItem,worst:worstBagIndex,cull:autoCull,
  cap:function(){ return PACKCAP[P.pack]; },ival:ival,items:function(){ return ITEMS; }};
// ================================================================ boot
'@
# Windows PowerShell 5.1 Get-Content -Raw decodes with the ANSI codepage, so UTF-8
# source came back as mojibake and Set-Content -Encoding utf8 then double encoded it.
# Four hub labels shipped into every fixture with a stray A-circumflex. Read explicit.
$text = [IO.File]::ReadAllText($src,[Text.Encoding]::UTF8)
$text = $text.Replace($needle, $inject)
[IO.File]::WriteAllText($dst,$text,(New-Object Text.UTF8Encoding $false))
"written: " + (Test-Path $dst)
