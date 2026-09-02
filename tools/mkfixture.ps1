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
// v6.15: put every dial back to its authored default, in memory, right now.
// localStorage.removeItem plus __loadProfile does NOT do this: with no saved
// profile applyCfg never runs, so whatever the last settings click wrote is still
// live and the next sim run reads it. Returns what it changed so a caller can see
// whether it was measuring a contaminated build.
window.__resetCfg=function(){
  var changed={};
  for(var k in DEF){
    if(CFG[k]!==DEF[k]) changed[k]=[CFG[k],DEF[k]];
    CFG[k]=DEF[k];
  }
  try{ if(P) P.tuned={}; }catch(e){}
  return changed;
};
window.__keys=function(){ return keys; };
window.__mouse=function(){ return mouse; };
window.__sim=function(dt){ refreshVseg(); updatePlayer(dt); updateEnts(dt); updateThrowables(dt); };
window.__tickFx=function(dt){
  var i;
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
window.__P=function(){ return P; };
window.__buzzFx=function(){ drawBuzzFx(); };
window.__buzzT=function(dt){ tickBuzz(dt===undefined?0.033:dt); };
// v6.19: fire a station's REAL act, the same function its key press calls.
// __station() with no arguments lists what is there. Without this, a probe can only
// call the modal openers directly, which skips the station wiring, and the
// quick-ascent bug at v6.18 lived in exactly that gap.
window.__station=function(id,key){
  if(!HB) HB=buildHub();
  var out=[];
  for(var i=0;i<HB.stations.length;i++){
    var st=HB.stations[i];
    if(id===undefined){ out.push({id:st.id,label:st.label,keys:Object.keys(st.acts||{})}); continue; }
    if(st.id!==id) continue;
    var k=key||'KeyE';
    if(!st.acts||!st.acts[k]) return {err:'no act '+k+' on '+id,keys:Object.keys(st.acts||{})};
    st.acts[k][1]();
    return {fired:id+'.'+k,name:st.acts[k][0]};
  }
  return id===undefined?out:{err:'no station '+id};
};
// showScreen('hub') is the ONLY thing that builds HB, so every hub probe before
// this hook existed had to reach for HB through a raid ending and got null.
window.__showScreen=function(s){ showScreen(s); };
// The ascent check, so the screen he actually loads his kit on can be driven
// rather than assumed. It shares the figure and the hotbar plan with the hub.
window.__renderStage=function(prefill){ return renderStage(prefill); };
window.__avatar=function(host,pick){ return renderAvatar(host,pick); };
// FOG. Persistence is the whole point of it, so the probe has to be able to
// read the packed profile string, not just the live grid.
window.__fog={frac:function(m){ return fogFrac(m); },
              save:function(){ return fogSave(); },
              packed:function(m){ return (P.mapSeen||{})[m]; },
              mark:function(){ return fogMark(); },
              grid:function(){ return G&&G.seen?G.seen:null; },
              seenAt:function(x,y){ var S=G&&G.seen; if(!S) return true; var gx=Math.floor(x/FOG_CELL),gy=Math.floor(y/FOG_CELL); if(gx<0||gy<0||gx>=S.w||gy>=S.h) return false; return S.g[gy*S.w+gx]===1; }};
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
  window.__tune2={
    open:function(){ toggleTune(true); },
    close:function(){ toggleTune(false); },
    // the authored table, so a label can be checked without rendering
    sliders:function(){ return SLIDERS.map(function(S){ return {key:S[0],label:S[1],min:S[2],max:S[3]}; }); },
    // which dials the friendly Settings words own, and which of them a slider
    // also offers: the v5.86 collision, computable rather than remembered
    owned:function(){ var o={}; GAMEOPTS.forEach(function(r){ r.opts.forEach(function(x){
                        for(var c in x.cfg) o[c]=1; }); }); return Object.keys(o); },
    collisions:function(){ var o={}; GAMEOPTS.forEach(function(r){ r.opts.forEach(function(x){
                        for(var c in x.cfg) o[c]=1; }); });
                        return SLIDERS.filter(function(S){ return o[S[0]]; }).map(function(S){ return S[0]; }); },
    overridden:function(){ return (P&&P.tuned)||{}; }
  };
  // v8.55: the two tests every container placement uses. Without these a probe
  // about placement has to guess, and __los.reach answers a different question -
  // it is a line-of-sight DISTANCE, not reachability, and using it as a boolean
  // reported every point on the map as fine.
  window.__nav={
    reachable:function(x,y){ return navReachable(G.map,x,y); },
    free:function(x,y,pad){ return spotFree(G.map,x,y,pad===undefined?20:pad); }
  };
  window.__los={
    // straight line between two points, the test the game uses for a shot
    clear:function(ax,ay,bx,by){ refreshVseg(); return losClear(ax,ay,bx,by,G.vseg); },
    // full sight test including facing and cone, what an enemy uses
    see:function(px,py,face,tx,ty,far,cone){ refreshVseg(); return canSee(px,py,face,tx,ty,G.vseg,far,cone); },
    // how far a clear shot reaches from a point along a heading, for arena setup
    reach:function(x,y,th,max){ refreshVseg(); var m=max||900;
      for(var d=20; d<=m; d+=20){ if(!losClear(x,y,x+Math.cos(th)*d,y+Math.sin(th)*d,G.vseg)) return d; }
      return m; }
  };
window.__emote={do:doEmote,list:EMOTES,down:weaponDown,ids:function(){return IDENTITIES;},rec:idRec};
// v9.11: Wirt's counter. The key function is exposed with its time argument so a
// check can walk the clock forward instead of waiting an hour to find out whether
// the lot rotates.
window.__wirt={key:function(t){ return wirtLotKey(t); },
               left:function(t){ return wirtLotLeft(t); },
               hour:function(t){ return wirtLotHour(t); },
               price:function(){ return WIRT_LOT_PRICE; },
               pool:function(){ return WIRT_LOT_POOL.slice(); },
               render:function(){ return renderGamble(); },
               val:function(k){ return (ITEMS[k]||{}).val||0; },
               rar:function(k){ return (ITEMS[k]||{}).r||null; }};
window.__con={gen:genContract,label:gearLabel,pay:payGear,tier:contractTier,tiers:CTIER,gear:CGEAR,stand:cstand,render:renderHub,
  // v9.06: the palette table and the zone list, so a check can prove a contract
  // names somewhere he is actually told about rather than a colour scheme.
  districts:function(){ return DISTRICTS; },
  place:function(d){ return districtPlaceName(d); },
  zones:function(mi){ return (FIXED_MAPS[mi].zones||[]).map(function(z){ return {name:z.name,d:(z.d===undefined?0:z.d)}; }); },
  reload:function(){ return loadProfile(); }};
window.__arm={list:ARMORS,by:armorById,mine:myRig,cap:armorCap,ping:ping,hurt:damagePlayer,shop:renderShop,SHOP:SHOP};
window.__weak={pts:WEAKPTS,of:weakOf,pos:weakPos,hit:weakHit,apply:applyWeak};
window.__bullets=function(dt){ updateBullets(dt); };
window.__optic={mag:opticMag,CH:CH,VF:VF,AMBR:AMBR};
window.__stray={make:mkStray,give:strayGive,reveal:strayReveal,wants:STRAY_WANTS};
window.__body={age:bodyAge,line:bodyLine,RAIDS:0};   // v8.53: here/recover deleted with the dead recovery scaffolding
window.__listen={make:mkListener,hear:listenersHear,R:LISTEN_R};
// v9.00: was {odds:windfallOdds, pool:WINDFALL, ...}. Both are gone with the
// windfall roll, so this keeps only the two halves that still exist.
window.__spike={box:mkStrongbox,open:openContainer};
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
window.__season={tiers:SEASON_TIERS,claim:claimTier,claimed:seasonClaimed,ready:seasonReady,label:tierLabel,sp:spForRun};
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
window.__equipBag=function(ix,slot){ return equipFromBag(ix,slot); };
window.__useHot=function(){ return useHot(); };
window.__pedBuy=function(i){ return pedBuy(i); };
// The weapon table, so shots-to-kill can be varied from the WEAPON side
// instead of the health side and the two separated causally.
window.__weapons=function(){ return WEAPONS; };
// THE BELT, v8.31. hotbarSlots is derived every frame and setHot/useHot carry
// all the consequences, so without these a test can only guess at the belt from
// side effects - and a trigger rig that silently does nothing then reads as a
// pass. __hotbar returns the live slot list, __setHot selects the way the
// number keys do, __useHot pulls the trigger on whatever is selected.
window.__hotbar=function(){ return hotbarSlots(); };
window.__setHot=function(i){ setHot(i); return G?G.hot:null; };
window.__useHot=function(){ return useHot(); };
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
// WHAT THE PIN IS ALLOWED TO DISAGREE WITH DEF ABOUT, v5.91: the bot's own
// behaviour. Everything else is the shipped game and must match it exactly, or a
// batch is measuring a configuration nobody plays. Anything not on this list
// showing up in __pinAudit is drift and should be fixed in the pin, not added
// here.
window.__PIN_BOT_ONLY={simGreed:1,simPick:1,simFlee:1,simCover:1,simDodgeRing:1};
window.__pinAudit=function(){
  var save={},k;
  for(k in CFG) save[k]=CFG[k];
  var shipped={};
  for(k in DEF) shipped[k]=DEF[k];
  window.__pinDefaults(0);
  var drift=[], botOnly=[];
  for(k in CFG){
    if(!(k in shipped)) continue;              // sim-only dials with no shipped default
    if(String(CFG[k])===String(shipped[k])) continue;
    (window.__PIN_BOT_ONLY[k]?botOnly:drift).push(k+': shipped '+shipped[k]+' pinned '+CFG[k]);
  }
  for(k in save) CFG[k]=save[k];               // put it back exactly as found
  return {ok:drift.length===0, drift:drift, botOnly:botOnly};
};
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
    seeStrict:1,siegePerZone:1,beaconMirror:1,hauledAboard:0,simPip:0,
    eHp:1,lootMult:1,windows:1,simEngage:0,raiderFeud:1,simReach:1,healOverTime:1,
    simRetreatHeal:0,placeCull:1,
    // Dials added after this list was written were NOT being pinned, so a value
    // left dirty by an aborted probe survived every later __pinDefaults and could
    // silently contaminate a measurement. Caught when a timed-out probe left
    // chaseGiveUp at 1 and the next pinned run still read 1. __pairedBg sets and
    // restores its own dials so the A/Bs were safe, but nothing else was.
    // Same defect again at v3.17: raiderDown shipped unpinned. Every new dial
    // must land here in the same build that introduces it.
    destruct:1,raiderWear:1,penetrate:1,raiderDown:1,siegePull:0.5,siegeVol:1,siegeEcho:1,decay:1,simRig:'std',smokeR:165,fragR:150,healSolo:1,extOutside:1,raiderWaves:1,raiderWaveCap:8,raiderWaveMin:12,raiderWaveGap:60,raiderKit:1,spawnClear:1500,raiderHaul:7,healPow:0.70,healSlow:2.4,wardenHp:900,wardenDmg:46,wardenRng:620,downTime:17,healPrep:1.5,armorPrep:2,lodR:1100,raiderBeacon:1,eliteRate:0.08,eliteHp:2.2,eliteDmg:1.6,nHowler:2,nBulwark:1,bulwarkArc:1.15,bulwarkSoak:0.12,machVsRaider:1,howlerDmg:35,howlerAir:2.1,howlerR:90,simAim:52,simPick:1,simFlee:1,simCover:1,simHoldFire:0,simDodgeRing:1,
    // v3.41 gave the PLAYER plain-language control of eight of these dials and
    // persists his choice on the profile. The fixture loads that profile, so a
    // saved "Raiders: Many" would silently run every A/B at nRaider 15 and every
    // number in this file would drift without anything looking wrong. Same
    // contamination v3.10 caught with chaseGiveUp, one layer up: a dial the
    // PLAYER can now move has to be pinned like any other.
    // v6.71 dials, pinned in the build after the one that introduced them, which is one
    // build later than this list's own rule allows. wadeInset is the shoreline inset the
    // player and the bot both wade by; raiderFloorN and raiderFloorGap are the floor
    // under the live pillager count and how fast it refills.
    wadeInset:11,raiderFloorN:4,raiderFloorGap:8,overheatLock:7,superhot:0,strikeFind:0.16,eliteGuns:1,
    nRaider:10,nSentry:20,nCrawler:34,eDmg:1,raidSec:540};
  for(var k in want){ if(C2[k]!==want[k]){ changed[k]=[C2[k],want[k]]; C2[k]=want[k]; } }
  P2.mapIx=(mapIx===undefined)?1:mapIx;
  P2.body=null; P2.equipped='smg'; P2.wear=P2.wear||{}; P2.wear['smg']=0;
  // v7.48, audit items 39-41: the pin was blind to three kinds of state.
  // Without owning the smg the equip silently degraded to a per-seed random
  // starter; buzz doses from a probe survived into measurements; and the
  // v7.18 HUD-size keys persist P.uiScale/P.menuZoom that no pin covered.
  P2.weapons=P2.weapons||[]; if(P2.weapons.indexOf('smg')<0) P2.weapons.push('smg');
  P2.buzz=[];
  delete P2.uiScale; P2.menuZoom=1.3;
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
// HAZARD, found 2026-08-30: pass BOTH arms' dials EXPLICITLY. With dialsA={}
// arm A of every pair after the first inherits arm B's dials from the previous
// pair (the loop writes dialsB last and dialsA={} writes nothing back), so a
// lone-dial B arm silently turns the whole batch into B-vs-B minus one raid.
// {} vs {} baselines are unaffected (nothing is ever written).
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
// v9.07: the noise rings, so a check can count them rather than only look for
// red pixels. list() is what is live right now; mark() drives the real entry
// point the game uses.
window.__noise={list:function(){ return (G&&G.noiseRings)?G.noiseRings.slice():[]; },
                clear:function(){ if(G) G.noiseRings=[]; },
                mark:function(t,x,y){ return noiseMark(t,x,y); },
                table:function(){ return NOISEMARK; }};
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
window.__loot=function(){ return LOOT; };
// v9.01: the wear system, readable. Asking the deploy path what a worn gun feels
// like does not work, because it issues a starter when the gun is not owned in
// the way it expects, so every answer came back Compact SMG. These are the two
// functions that decide, plus the table they read.
window.__wear={
  steps:function(){ return WEARSTEPS.map(function(w){
    return {at:w.at,name:w.name,spread:w.spread,reload:w.reload,jam:w.jam}; }); },
  wearable:function(id){ return !!wearable(id); },
  // what the gun BECOMES after this many rounds, which is what he holds
  at:function(id,rounds){
    P.wear=P.wear||{}; var keep=P.wear[id];
    P.wear[id]=rounds;
    var base=WEAPONS[id], st=wearStep(id);
    var out={band:st.name, spread:+(base.spread*st.spread).toFixed(4),
             reload:Math.round(base.reload*st.reload), jam:st.jam,
             baseSpread:base.spread, baseReload:base.reload};
    if(keep===undefined) delete P.wear[id]; else P.wear[id]=keep;
    return out;
  }
};
// v8.95: draw the real backpack panel against a substitute state, and hand back
// what it recorded. G is restored whatever happens, so a throw cannot leave the
// game pointed at a fake raid.
window.__drawBagWith=function(fake){
  var old=G, err=null, out=null;
  try{ G=fake; drawBag(); out={panel:G.bagPanel,cells:(G.bagCells||[]).length,cols:G.bagCols}; }
  catch(e){ err=''+e; }
  finally{ G=old; }
  return {threw:err, recorded:out};
};
window.__guns={
  tiers:function(){ var o={}; for(var k in WEAPONS) o[k]={name:WEAPONS[k].name,tier:WTIER[k]}; return o; },
  quality:function(){ return GUNQ.map(function(q){ return {q:q.q,rank:q.rank,weight:q.w,prefix:q.pre}; }); },
  // v9.02: the actual roll, so a check can ask what a found gun IS rather than
  // reading the table and doing the arithmetic itself.
  roll:function(gk){ var g=rollFieldGun(gk);
    return {name:g.name,q:g.q,qRank:g.qRank,dmg:g.dmg,spread:g.spread,mag:g.mag,
            rof:g.rof,reload:g.reload,tint:g.tint||null}; },
  base:function(gk){ var b=WEAPONS[gk]; if(!b) return null;
    return {name:b.name,dmg:b.dmg,spread:b.spread,mag:b.mag,rof:b.rof,reload:b.reload,
            tint:b.tint||null}; },
  rarityOf:function(gk){ return gunRarity(gk); },
  colourOf:function(r){ return RCOL[r]; },
  // the name the game builds for a gun of this key at this quality, and the
  // colour the belt and the bag give that same gun
  nameAt:function(gk,qk){
    var Q=null; for(var i=0;i<GUNQ.length;i++) if(GUNQ[i].q===qk) Q=GUNQ[i];
    if(!Q||!WEAPONS[gk]) return null;
    return {name:Q.pre+WEAPONS[gk].name, rarity:gunRarity(gk), colour:RCOL[gunRarity(gk)],
            qualityTint:Q.tint||null};
  }
};
// v8.83: STAND ON THE UNDERCROFT FLOOR. showScreen('hub') is the real entry the
// game uses, so this is the play path and not a rebuilt copy of it.
window.__hubEnter=function(){ showScreen('hub'); return !!HB; };
window.__hubP=function(){ return HB?HB.player:null; };
window.__hubStep=function(dt){
  if(!HB||!wc||!(W>0)) return false;
  tickBuzz(dt); updateHubWorld(dt); drawHubWorld(dt); drawBuzzFx();
  // v8.96: the same two lines the real hub frame runs. Without them this shim
  // steps a version of the Undercroft that stopped existing at v8.95.
  try{ ctx.clearRect(0,0,W,H); if(hubBagOpen) drawHubBag(); }catch(_hs){}
  return true;
};
window.__hubPanelOn=function(){ return document.getElementById('hub').classList.contains('on'); };
window.__hubBag=function(v){ if(v!==undefined) hubBagOpen=!!v; return hubBagOpen; };
window.__hubBagState=function(){ return hubBagState(); };
// v8.96: the LIVE Undercroft backpack state, the one the draw and the mouse both
// use. A probe that rebuilt it would be measuring its own copy and not the panel
// he can actually click on.
window.__hubBagLive=function(){ return hubBagG; };
// The operator drawing calls, recorded as they happen. The pose is an argument
// to drawOp, so this is the only way to see what the Undercroft actually asks
// for rather than what I believe it asks for.
window.__opCalls=null;
window.__spyOps=function(on){
  if(on){
    window.__opCalls=[];
    if(!drawOp.__spied){
      var _o=drawOp;
      drawOp=function(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
        if(window.__opCalls) window.__opCalls.push(
          {mode:mode,ph:+(ph||0).toFixed(2),hero:!!(st&&st.hero)});
        return _o.apply(null,arguments);
      };
      drawOp.__spied=_o;
    }
  } else if(drawOp.__spied){ drawOp=drawOp.__spied; }
  return window.__opCalls;
};
window.__hud=function(){
  var out={z:{},box:{}};
  for(var k in HUDZ) out.z[k]=HUDZ[k];
  for(var b in HUDBOX){ var r=HUDBOX[b]; if(!r) continue;
    out.box[b]={x:Math.round(r.x),y:Math.round(r.y),w:Math.round(r.w),h:Math.round(r.h),
                right:Math.round(r.x+r.w),bottom:Math.round(r.y+r.h)}; }
  var hc=(G&&G.hotCells)||[];
  if(hc.length) out.belt={cells:hc.length,cellW:Math.round(hc[0].w),
    x:Math.round(hc[0].x),right:Math.round(hc[hc.length-1].x+hc[hc.length-1].w),
    y:Math.round(hc[0].y),bottom:Math.round(hc[0].y+hc[0].h)};
  // v9.09: what the HUD thinks is under a point, and what a click there actually
  // started. A pointer that promises resize where the click drags is worse than
  // no pointer, so a check has to be able to compare the two.
  out.hitAt=function(x,y){ var h=hudHit(x,y); return h?h.part:null; };
  out.grip=hudGripS();
  out.dragging=function(){ return HUDDRAG?HUDDRAG.id:null; };
  out.resizing=function(){ return HUDRESIZE?HUDRESIZE.id:null; };
  return out;
};
// v8.79: the FULL open, the path that rolls a windfall. Named __openFull rather
// than __open so it cannot be confused with the staged pull, which is what live
// play actually uses and which grants one key at a time.
window.__openFull=function(ct){ return openContainer(ct); };
window.__grant=function(ct,keys,delay0){ return grantLoot(ct,keys,delay0); };
// The item table and its icon renderer, so "does every item draw" can be
// answered instead of assumed. A blank cell in his stash is a shipped bug.
window.__items=function(){ return ITEMS; };
window.__drawIcon=function(c,k,x,y,s){ return drawItemIcon(c,k,x,y,s); };
// Container stocking, so "a body should be worth more than a crate" can be
// MEASURED over thousands of rolls instead of eyeballed from the weight tables.
window.__mkContainer=function(t){ return mkContainer(0,0,t); };
window.__ival=function(k){ return ival(k); };
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
// v9.00: the WINDFALL PROBE is gone with the thing it measured. It broke
// windfallOdds into its distance, time and danger terms so the promise could be
// checked against real geometry. There are no windfalls to measure now.
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
window.__musTheme=function(){ return {theme:HUB_THEME,chords:HUB_CHORDS,themes:MUS_THEMES,live:musTrk(),pick:function(){ MUS.trk=null; return musTrk(); }}; };
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
try{ sfx=function(t,x,y){ try{ if(typeof noiseMark==='function') noiseMark(t,x,y); }catch(_ns){} }; }catch(e){}
try{ blip=function(){}; }catch(e){}
// v8.55: lets a probe watch which sound a call site actually asks for. The step
// chooser calls blip through this binding, so without a setter its output was
// unobservable and any test of it passed by default.
window.__setBlip=function(f){ blip=f; };
// say() WAS STUBBED TO A NO-OP HERE AND IT IS NOT AN AUDIO EMITTER. Its whole body
// is `if(G&&!G.sim){G.msg=m;G.msgT=3.2;}`, a state write with no sound anywhere in
// it, so silencing it bought nothing and quietly broke every assertion any test
// could make about on-screen messages: G.msg simply never changed in the fixture.
// That cost a v3.01 changelog line admitting I could not verify two strings, when
// the game was fine and the harness was lying. It now does the real thing AND
// records the last line, so the fixture stays as silent as it ever was and a test
// can finally read what the game said.
// v8.13: AND IT HAD FALLEN BEHIND AGAIN, in exactly the way the paragraph above
// describes. The shipped say() gained an Undercroft fallback - with no raid to
// write G.msg into, it hands the line to hubToast - and this override still
// dropped it on the floor. Two probes reported "the fallback does not fire"
// while the game did it correctly. An override of a real function has to mirror
// the real function, or it is a second implementation that tests itself.
try{ say=function(m){
  window.__lastSay=m;
  if(G&&!G.sim){ G.msg=m; G.msgT=3.2; return; }
  if(!G&&typeof hubToast==='function') hubToast(m);
}; }catch(e){}
try{ tickAmbience=function(){}; }catch(e){}
try{ tickEnemyAudio=function(){}; }catch(e){}
try{ window.__stepsReal=tickPlayerSteps; }catch(e){}
// v8.73: and a way to put the real one back, so his "too many footsteps when
// sprinting" can be measured on the REAL frame rather than by calling the tick by
// hand. blip is stubbed anyway, so nothing becomes audible.
try{ window.__setSteps=function(f){ tickPlayerSteps=f||function(){}; }; }catch(e){}
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
window.__music=function(){ tickMusic(); return {mode:musicMode(),wanted:musicWanted(),started:!!MUS.g,step:MUS.step,trkName:(MUS.trk?MUS.trk.name:null),themes:MUS_THEMES.length}; };
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
// v8.55: stepSound is the only member here that is NOT a stub. The four tick
// functions above are emptied at source and ac() is made to throw, so amb/steps/
// voices call empty functions and always pass - a probe cannot see through them.
// ======================================================= THE VERIFY CHAIN
// One call, one result. See the note in mkfixture.ps1 for why this is here
// rather than retyped per build. Every check returns what it MEASURED, not a
// bare pass, because a green boolean cannot be cross-examined later.
// Expected fingerprints are passed in, never hardcoded here: a harness that
// knows the right answer will eventually assert it against itself.
window.__verify=function(opt){
  opt=opt||{};
  var EXP=opt.ents||{0:58,1:276}, SEED=opt.seed||4242;
  var R={pass:true,fail:[],notes:[]};
  function bad(m){ R.pass=false; R.fail.push(m); }
  function fresh(mi){ __resetCfg(); __pinDefaults(mi); }
  try{ __forceSize(1920,1080); }catch(e){ bad('forceSize threw: '+e); }
  // --- 1. map fingerprints. The tripwire for an accidental seeded draw.
  R.ents={}; R.containers={};
  [0,1].forEach(function(mi){
    fresh(mi); __startRaid({mapIx:mi,seed:SEED});
    var g=__state();
    R.ents[mi]=g.ents.length; R.containers[mi]=g.containers.length;
    if(g.ents.length!==EXP[mi]) bad('mapIx '+mi+' ents '+g.ents.length+', expected '+EXP[mi]+' - the seeded stream MOVED');
  });
  // --- 2. live vs sim parity. Same seed must build the same world.
  function sig(mi,sim){
    fresh(mi); __startRaid({mapIx:mi,seed:SEED,sim:sim});
    var g=__state();
    return g.ents.map(function(x){return x.kind+':'+Math.round(x.x)+','+Math.round(x.y);}).join('|')
         + '#' + g.containers.map(function(x){return x.type+':'+Math.round(x.x)+','+Math.round(x.y);}).join('|');
  }
  R.parity={};
  [0,1].forEach(function(mi){
    var L=sig(mi,false), S=sig(mi,true);
    R.parity[mi]=(L===S)?'identical':'MISMATCH';
    if(L!==S){
      var i=0; while(i<L.length&&i<S.length&&L[i]===S[i]) i++;
      bad('mapIx '+mi+' live and sim differ, first at char '+i);
    }
  });
  // --- 3. LOOTING, on the real play path. This is the check that would have
  // caught v8.34, where a deleted var froze the frame on holding E and shipped
  // three times. Holding the key through __loop is the whole point: the bot
  // never touches this code.
  R.loot={};
  [0,1].forEach(function(mi){
    fresh(mi); __startRaid({mapIx:mi,seed:SEED});
    var g=__state(), p=g.player, best=null, bd=1e9;
    for(var i=0;i<g.containers.length;i++){
      var c=g.containers[i], d=Math.hypot(c.x-p.x,c.y-p.y);
      if(d<bd&&c.loot&&c.loot.length){ bd=d; best=c; }
    }
    if(!best){ bad('mapIx '+mi+' has no container with loot in it'); return; }
    p.x=best.x; p.y=best.y+4;
    var K=__keysRef(); for(var k in K) K[k]=false; K['KeyE']=true;
    var t0=g.t, err=null;
    try{ for(var f=0;f<420;f++) __loop(performance.now()+f*16.7); }
    catch(e){ err=String(e); }
    var g2=__state();
    K['KeyE']=false;
    R.loot[mi]={thrown:err,clock:(t0.toFixed(1)+'->'+(g2?g2.t.toFixed(1):'gone')),
                searched:g2?g2.tel.containers:null,items:g2?g2.tel.items:null};
    if(err) bad('mapIx '+mi+' looting threw: '+err);
    else if(!g2||g2.t<=t0) bad('mapIx '+mi+' raid clock STALLED while looting');
    else if(!g2.tel.containers) bad('mapIx '+mi+' held E for 420 frames and searched nothing');
  });
  // --- 4. the three endings. endRaid has exactly three outcomes; a crash in the
  // payout path ships green without this. The abandon needs a REAL run behind it
  // or it takes the empty-run discard path and never draws a card.
  R.endings={};
  [['extract','EXTRACTED'],['dead','KILLED IN ACTION'],['abandon','ABANDONED']].forEach(function(pair){
    var how=pair[0], want=pair[1];
    fresh(0); __startRaid({mapIx:0,seed:SEED});
    var g=__state(), p=g.player;
    if(how==='abandon'){
      var best=null,bd=1e9;
      for(var i=0;i<g.containers.length;i++){
        var c=g.containers[i], d=Math.hypot(c.x-p.x,c.y-p.y);
        if(d<bd&&c.loot&&c.loot.length){ bd=d; best=c; }
      }
      if(best){
        p.x=best.x; p.y=best.y+4;
        var K2=__keysRef(); for(var k2 in K2) K2[k2]=false; K2['KeyE']=true;
        // Caught, not thrown. Controlled by forcing __loop to throw: without this
        // the exception escaped __verify and the check crashed instead of failing.
        try{ for(var f2=0;f2<420;f2++) __loop(performance.now()+f2*16.7); }
        catch(_pe){ bad('abandon setup threw while looting: '+_pe); }
        K2['KeyE']=false;
      }
    }
    var err=null;
    try{ __endRaid(how); for(var f3=0;f3<30;f3++) __loop(performance.now()+f3*16.7); }
    catch(e){ err=String(e); }
    var oc=document.getElementById('outcome');
    var on=!!(oc&&oc.classList.contains('on'));
    var txt=(document.body.innerText.match(/EXTRACTED|KILLED IN ACTION|ABANDONED/)||['NONE'])[0];
    R.endings[how]={headline:txt,overlay:on,thrown:err};
    if(err) bad(how+' threw: '+err);
    if(txt!==want) bad(how+' showed "'+txt+'", expected "'+want+'"');
    if(!on) bad(how+' left the outcome overlay off');
  });
  // --- 5. the hub, entered the way a player enters it. showScreen('hub') alone
  // does NOT dismiss the title - only the button handler does - so a probe that
  // calls it directly renders the hub underneath the title and reports success.
  R.hub={};
  try{
    var ocx=document.getElementById('outcome'); if(ocx) ocx.classList.remove('on');
    var t=document.getElementById('title');
    var btn=t?[].slice.call(t.querySelectorAll('button')).filter(function(b){
      return /UNDERCROFT|ENTER/i.test(b.textContent); })[0]:null;
    if(btn&&t.classList.contains('on')) btn.click(); else __showScreen('hub');
    for(var f4=0;f4<30;f4++) __renderStage(performance.now()+f4*16.7);
    R.hub={titleOn:!!(t&&t.classList.contains('on')),thrown:null};
    if(t&&t.classList.contains('on')) bad('hub: the title screen is still up');
  }catch(e){ R.hub={thrown:String(e)}; bad('hub/renderStage threw: '+e); }
  R.summary=R.pass?'PASS':('FAIL x'+R.fail.length);
  return R;
};
// Every check above is wrapped so a throw inside one is a FAILED check rather
// than a dead harness. __verify is what a build is judged on; it must always
// come back with a verdict.
window.__verifySafe=function(opt){
  try{ return window.__verify(opt); }
  catch(e){ return {pass:false,summary:'FAIL - harness threw',fail:['__verify itself threw: '+e+' | '+((e&&e.stack)||'').split('\n').slice(0,3).join(' <- ')]}; }
};
// A place for per-fix regression asserts. Each shipped fix adds one entry here
// so an old bug cannot come back quietly - the frozen-loot bug shipped three
// times because nothing re-checked it after the build that fixed it.
window.__REGRESS=[
  {v:'8.37',what:'holding E must not throw (var cap deleted at v8.34)',
   run:function(){ return null; }},   // covered by the loot leg of __verify
  {v:'8.55',what:'the two armoured heavies walk heavy',
   run:function(){
     var bad=[];
     ['sentry','warden','bulwark'].forEach(function(k){ if(__audio.stepSound(k)!=='stepHeavy') bad.push(k+' is not heavy'); });
     ['crawler','raider','snitch','listener','howler','choir'].forEach(function(k){ if(__audio.stepSound(k)!=='step') bad.push(k+' went heavy'); });
     return bad.length?bad.join('; '):null; }},
  {v:'8.55',what:'roads never cross an authored wall',
   run:function(){
     var out=[];
     [0,1].forEach(function(mi){
       __resetCfg(); __pinDefaults(mi); __startRaid({mapIx:mi,seed:4242});
       var g=__state(), R=g.map.roadRects||[], W=g.map.walls||[], hit=0;
       for(var i=0;i<R.length;i++)for(var j=0;j<W.length;j++){
         var r=R[i],w=W[j];
         if(w.furn||w.wreck||w.ledge) continue;
         if(r.x<w.x+w.w&&r.x+r.w>w.x&&r.y<w.y+w.h&&r.y+r.h>w.y){ hit++; break; }
       }
       if(hit) out.push('mapIx '+mi+' has '+hit+' roads crossing a wall');
     });
     return out.length?out.join('; '):null; }},
  {v:'8.75',what:'BACKSPACE rescues a latched key on the Undercroft floor as well as in a raid',
   run:function(){
     function press(){
       document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'Backspace',key:'Backspace',bubbles:true,cancelable:true}));
       document.body.dispatchEvent(new KeyboardEvent('keyup',{code:'Backspace',key:'Backspace',bubbles:true,cancelable:true}));
     }
     __showScreen('hub');
     var K=__keysRef();
     for(var k in K) K[k]=false;
     K['KeyW']=true; K['ShiftLeft']=true;
     if(!Object.keys(__keysRef()).filter(function(x){return __keysRef()[x];}).length)
       return 'the probe could not latch a key, so it is testing nothing';
     press();
     var still=Object.keys(__keysRef()).filter(function(x){return __keysRef()[x];});
     if(still.length) return 'on the hub floor BACKSPACE left '+still.join(',')+' latched';
     // and it must not have stopped working inside a raid
     __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
     var K2=__keysRef(); K2['KeyA']=true;
     press();
     var still2=Object.keys(__keysRef()).filter(function(x){return __keysRef()[x];});
     if(still2.length) return 'in a raid BACKSPACE left '+still2.join(',')+' latched';
     return null; }},
  {v:'8.74',what:'the settings menu actually applies what it says',
   run:function(){
     var P=__P(), bad=[];
     var keepT=P.tuned, keepG=P.gameOpts;
     // 1. A row whose dial was touched in the tuning console must still work.
     P.tuned={eDmg:1}; P.gameOpts={}; __resetCfg();
     var b1=__cfg().eDmg;
     __opts.cycle('hits');
     if(__cfg().eDmg===b1) bad.push('a Settings row is dead once its slider has been touched in the console');
     if(__opts.tuned().eDmg!==undefined) bad.push('clicking the row did not release the console claim');
     // 2. Other pillagers = None must survive the rows applied after it.
     P.tuned={}; P.gameOpts={raiders:3}; __resetCfg(); __opts.apply();
     if(__cfg().nRaider!==0) bad.push('None left nRaider at '+__cfg().nRaider);
     if(__cfg().raiderWaves!==0) bad.push('None still reinforces: raiderWaves '+__cfg().raiderWaves);
     // 3. Light extraction heat must scale the ring, not empty the whole map.
     P.tuned={}; P.gameOpts={ext:2}; __resetCfg(); __opts.apply();
     if(__cfg().siegeVol!==0.6) bad.push('Light did not scale siegeVol');
     if(__cfg().raiderWaves!==1) bad.push('Light switched off whole-raid reinforcement');
     // 4. A preset must not silently throw away the Settings choices.
     P.tuned={}; P.gameOpts={hits:0}; __resetCfg(); __opts.apply();
     var brutal=__cfg().eDmg;
     if(brutal===1) bad.push('the Brutal option is not writing eDmg, so this check is testing nothing');
     __opts.preset('A');
     if(__cfg().eDmg!==brutal) bad.push('a preset discarded the Settings choice: eDmg '+brutal+' became '+__cfg().eDmg);
     P.tuned=keepT||{}; P.gameOpts=keepG||{}; __resetCfg();
     return bad.length?bad.join('; '):null; }},
  {v:'8.73',what:'holding sprint through exhaustion does not stutter it on and off',
   run:function(){
     function hold(secs,release){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       var g=__state(); if(!g) return null;
       var p=g.player; g.ents.length=0; p.iv=99; p.stam=100;
       var K=__keysRef(); for(var k in K) K[k]=false;
       K['KeyD']=true; K['ShiftLeft']=true;
       var flips=0, prev=null, everSprinted=false;
       for(var f=0;f<secs*60;f++){
         if(!__state()||__state().over) break;
         if(release&&f===300) K['ShiftLeft']=false;
         if(release&&f===420) K['ShiftLeft']=true;
         __loop(performance.now()+f*16.7);
         var sp=!!__state().sprinting;
         if(sp) everSprinted=true;
         if(prev!==null&&sp!==prev) flips++;
         prev=sp;
       }
       for(var k2 in K) K[k2]=false;
       return {flips:flips, everSprinted:everSprinted};
     }
     var a=hold(10,false);
     if(!a) return 'no raid';
     // The probe must actually have sprinted, or it is testing nothing.
     if(!a.everSprinted) return 'the probe never sprinted at all, so this check is testing nothing';
     if(a.flips>2) return 'sprint switched state '+a.flips+' times while the key was simply held';
     // And the latch must not disable sprint forever: letting go and pressing
     // again has to give another one.
     var b=hold(10,true);
     if(b.flips<2) return 'releasing and pressing sprint again did not give a second sprint';
     return null; }},
  {v:'8.72',what:'an item can be dragged OFF the Undercroft belt and back into the backpack',
   run:function(){
     // The drop end resolves its target with document.elementFromPoint, which
     // returns null for every point when the pane is collapsed to 0x0. That is
     // not a broken belt, it is a dead viewport, and it cost him a false bug
     // report at v8.88.
     if(!__vpAlive()) return 'SKIP: the pane has no layout ('+window.innerWidth+'x'+window.innerHeight+'), so no drag can land';
     __showScreen('hub');
     var H=__hub(); if(!H) return 'no hub';
     var st=null; for(var i=0;i<H.stations.length;i++) if(H.stations[i].id==='term') st=H.stations[i];
     if(!st) return 'no stash station';
     var P=__P();
     P.stash=['servo','scrap','wire','medkit']; P.kit=['servo']; P.hotAssign={0:'servo'}; P.kitChosen=0;
     H.player.x=st.x; H.player.y=st.y; H.near=null; H.eLock=false;
     var K=__keysRef(); for(var k in K) K[k]=false;
     for(var f=0;f<12;f++) __hubStep(1/60);
     K['KeyE']=true; for(var f2=0;f2<12;f2++) __hubStep(1/60); K['KeyE']=false;
     // The walk-and-hold above is the play path and is tried first. It does not
     // always take, and when it did not this check returned "testing nothing",
     // which the runner scores as a failure: it condemned two good builds that
     // way. Open the panel directly as a fallback so the DRAG is what is being
     // measured rather than whether a key press landed.
     if(!document.getElementById('hub').classList.contains('on')){
       try{ renderHub(); document.getElementById('hub').classList.add('on'); }catch(_oh){}
     }
     function visCell(ix){
       var all=[].slice.call(document.querySelectorAll('[data-plan="'+ix+'"]'));
       for(var j=0;j<all.length;j++){ var r=all[j].getBoundingClientRect(); if(r.width>0&&r.height>0) return all[j]; }
       return null;
     }
     var grid=document.getElementById('stashgrid');
     var cell=visCell(0);
     // If the panel is not actually laid out there is nothing to test, and a
     // check that silently passes on an invisible panel is worse than none.
     if(!grid||!cell) return 'the stash screen did not open, so this check is testing nothing';
     var gr=grid.getBoundingClientRect(), cr=cell.getBoundingClientRect();
     if(!(gr.width>0&&cr.width>0)) return 'the stash panel has no layout, so this check is testing nothing';
     cell.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true,clientX:cr.left+cr.width/2,clientY:cr.top+cr.height/2}));
     document.dispatchEvent(new MouseEvent('mousemove',{bubbles:true,clientX:gr.left+40,clientY:gr.top+40}));
     document.dispatchEvent(new MouseEvent('mouseup',{bubbles:true,clientX:gr.left+40,clientY:gr.top+40}));
     var P2=__P();
     if(P2.hotAssign&&P2.hotAssign[0]!==undefined) return 'the belt slot still holds the item after dragging it to the backpack';
     if((P2.kit||[]).indexOf('servo')>=0) return 'the item is still in the kit going up';
     if((P2.stash||[]).indexOf('servo')<0) return 'the item vanished from the stash entirely';
     return null; }},
  {v:'8.66',what:'dragging onto the belt assigns, refuses and moves correctly',
   run:function(){
     var P=__P(); P.weapons=['smg','rifle']; P.hotAssign={};
     __resetCfg(); __pinDefaults(0);
     var d=__deploy({kit:['bandage','medkit','plate','gun_rifle'],safe:null,mapIx:0,seed:4242});
     if(d.error) return d.error;
     var g=__state(); if(!g) return 'no raid';
     g.ents.length=0; g.player.iv=99;
     for(var f=0;f<8;f++) __loop(performance.now()+f*16.7);
     var st=__state();
     if(!st.hotCells||!st.hotCells.length) return 'the bar was never drawn, so there are no drop targets and this check is testing nothing';
     function cellFor(ix){ var s=__state(); for(var i=0;i<s.hotCells.length;i++) if(s.hotCells[i].i===ix) return s.hotCells[i]; return null; }
     function drop(payload,slotIx){
       var s=__state(), cell=cellFor(slotIx), M=__mouse();
       if(!cell) return null;
       M.x=cell.x+cell.w/2; M.y=cell.y+cell.h/2;
       s.drag=payload;
       window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true}));
       for(var f2=0;f2<6;f2++) __loop(performance.now()+f2*16.7);
       return JSON.parse(JSON.stringify(__state().hotAssign||{}));
     }
     var sl=__belt.slots();
     if(sl[0].kind!=='gun'||sl[5].kind!=='heal'||sl[7].kind!=='empty')
       return 'the bar is not the shape this check assumes (0 gun, 5 heal, 7 empty), so it is testing nothing';
     // A consumable onto an empty slot takes.
     var a=drop({key:'bandage',bagIx:__state().bag.indexOf('bandage')},7);
     if(a['7']!=='bandage') return 'a bandage dropped on an empty slot did not stick';
     // v8.67, his order: a gun goes on ANY slot, same as any other equippable.
     var b=drop({key:'gun_rifle',bagIx:__state().bag.indexOf('gun_rifle')},5);
     if(b['5']!=='gun_rifle') return 'a gun was refused from an ordinary belt slot';
     // A consumable on a GUN slot is still refused: 1 and 2 are the two in your hands.
     var c=drop({key:'medkit',bagIx:__state().bag.indexOf('medkit')},0);
     if(c['0']) return 'a consumable was accepted onto a gun slot';
     // Moving one already on the bar must MOVE it, not leave a copy behind.
     var e2=drop({key:'bandage',fromHot:7},8);
     if(e2['7']) return 'moving an item off slot 7 left a copy behind';
     if(e2['8']!=='bandage') return 'moving an item to slot 8 did not land it';
     // Dropping onto its own slot is a click and must change nothing.
     var f3=drop({key:'bandage',fromHot:8},8);
     if(f3['8']!=='bandage') return 'dropping an item back on its own slot lost it';
     return null; }},
  {v:'8.65',what:'the two gun slots swap weapons and never fire one',
   run:function(){
     var P=__P(); P.weapons=['smg','rifle']; P.hotAssign={};
     __resetCfg(); __pinDefaults(0);
     var d=__deploy({kit:['bandage'],safe:null,mapIx:0,seed:4242});
     if(d.error) return d.error;
     var g=__state(); if(!g) return 'no raid';
     g.ents.length=0; g.player.iv=99;
     var sl=__belt.slots();
     if(!(sl[0]&&sl[0].kind==='gun'&&sl[1]&&sl[1].kind==='gun'))
       return 'the first two slots are not both guns, so this check is testing nothing';
     var hand0=g.player.wep&&g.player.wep.id, sec0=g.player.sec&&g.player.sec.id;
     if(!sec0) return 'no second gun was stowed, so the swap cannot be tested';
     __belt.set(1);
     for(var f=0;f<6;f++) __loop(performance.now()+f*16.7);
     var s1=__state();
     if((s1.player.wep&&s1.player.wep.id)!==sec0) return 'picking the stowed gun did not bring it up';
     __belt.set(0);
     for(var f2=0;f2<6;f2++) __loop(performance.now()+f2*16.7);
     var s2=__state();
     if((s2.player.wep&&s2.player.wep.id)!==hand0) return 'picking the first gun back did not restore it';
     if(s2.tel.shots>0) return 'a belt key FIRED the gun; it must only change weapon';
     return null; }},
  {v:'8.65',what:'the heal and plate slots spend the right item',
   run:function(){
     var P=__P(); P.weapons=['smg']; P.hotAssign={};
     __resetCfg(); __pinDefaults(0);
     var d=__deploy({kit:['bandage','medkit','plate'],safe:null,mapIx:0,seed:4242});
     if(d.error) return d.error;
     var g=__state(); if(!g) return 'no raid';
     g.ents.length=0; g.player.iv=99; g.player.hp=40; g.player.armor=0;
     var sl=__belt.slots(), hi=-1, pi=-1;
     sl.forEach(function(x,i){ if(x.kind==='heal') hi=i; if(x.kind==='armor') pi=i; });
     if(hi<0||pi<0) return 'no heal or armour slot on the belt, so this check is testing nothing';
     // The heal slot names the SMALLEST heal carried, which is the bandage here.
     if(sl[hi].icon!=='bandage') return 'the heal slot named '+sl[hi].icon+' with a bandage in the bag';
     __belt.set(hi); __belt.use();
     for(var f=0;f<200;f++) __loop(performance.now()+f*16.7);
     var s1=__state();
     if(s1.player.hp<=40) return 'using the heal slot healed nothing';
     if(s1.bag.indexOf('bandage')>=0) return 'the bandage was not spent';
     var sl2=__belt.slots(), pi2=-1;
     sl2.forEach(function(x,i){ if(x.kind==='armor') pi2=i; });
     if(pi2<0) return 'the armour slot vanished after healing';
     __belt.set(pi2); __belt.use();
     for(var f2=0;f2<200;f2++) __loop(performance.now()+f2*16.7);
     var s2=__state();
     if(s2.player.armor<=0) return 'using the plate slot applied no armour';
     if(s2.bag.indexOf('plate')>=0) return 'the plate was not spent';
     return null; }},
  {v:'8.64',what:'a raid that takes your kit also lets go of the belt keys',
   run:function(){
     function go(how,seconds){
       var P=__P(); P.weapons=['smg']; P.hotAssign={};
       __resetCfg(); __pinDefaults(0);
       var d=__deploy({kit:['servo','scrap','wire'],safe:null,mapIx:0,seed:4242});
       if(d.error) return {err:d.error};
       var g=__state(); if(!g) return {err:'no raid'};
       __P().hotAssign={'1':'servo','2':'scrap'};
       g.ents.length=0;
       if(seconds>0){
         var K=__keysRef(); for(var k in K) K[k]=false; K['KeyD']=true;
         for(var f=0;f<Math.round(seconds*60);f++) __loop(performance.now()+f*16.7);
         K['KeyD']=false;
       }
       __endRaid(how);
       var P2=__P(), A=P2.hotAssign||{}, owns=(P2.stash||[]);
       var dead=[]; for(var kk in A) if(owns.indexOf(A[kk])<0) dead.push(kk+' -> '+A[kk]);
       return {dead:dead, kept:Object.keys(A).length, owns:owns};
     }
     // The three ways a raid can take your kit.
     var cases=[['dead',0],['abandon',0],['abandon',3]];
     for(var i=0;i<cases.length;i++){
       var r=go(cases[i][0],cases[i][1]);
       if(r.err) return r.err;
       if(r.dead.length) return cases[i][0]+(cases[i][1]?(' after '+cases[i][1]+'s'):' instant')+' left dead keys: '+r.dead.join(', ');
     }
     // And the control: extracting brings the kit home, so the keys must STAY.
     var ex=go('extract',0);
     if(ex.err) return ex.err;
     if(ex.owns.indexOf('servo')<0) return 'the probe never got the kit home, so it is testing nothing';
     if(ex.kept!==2) return 'extracting stripped keys for gear that came home ('+ex.kept+' of 2 left)';
     return null; }},
  {v:'8.63',what:'the safe pocket keeps exactly one named item through a death',
   run:function(){
     function die(safeItem){
       __resetCfg(); __pinDefaults(0);
       var d=__deploy({kit:['servo','scrap','wire'],safe:safeItem,mapIx:0,seed:4242});
       if(d.error) return {err:d.error};
       var g=__state(); if(!g) return {err:'no raid'};
       g.ents.length=0;
       var carried=g.bag.slice();
       __endRaid('dead');
       return {armed:d.safeUp,carried:carried,stash:(__P().stash||[]).slice()};
     }
     var a=die('servo');
     if(a.err) return a.err;
     // The probe must actually have carried the item up, or it tests nothing.
     if(a.carried.indexOf('servo')<0) return 'the kit never reached the bag, so this check is testing nothing';
     if(a.armed!=='servo') return 'the pocket did not arm at deploy (safeUp='+String(a.armed)+')';
     if(a.stash.indexOf('servo')<0) return 'the named item did NOT survive the death';
     if(a.stash.length!==1) return 'more than the one named item came home: '+a.stash.join(',');
     var b=die(null);
     if(b.err) return b.err;
     if(b.stash.length) return 'items came home with nothing named as safe: '+b.stash.join(',');
     return null; }},
  {v:'8.61',what:'the boarding hold cannot be done in instalments',
   run:function(){
     function pull(leave){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.ents.length=0;
       var z=null; for(var i=0;i<g.zones.length;i++) if(g.zones[i].open){ z=g.zones[i]; break; }
       if(!z) return null;
       z.beaconT=0; z.hold=25; z.callT=0;
       p.x=z.x; p.y=z.y; p.iv=99; p.downed=false;
       var K=__keysRef(); for(var k in K) K[k]=false; K['KeyE']=true;
       for(var f=0;f<50&&__state()&&!__state().over;f++) __loop(performance.now()+f*16.7);
       var got=z.pullT;
       if(leave){
         K['KeyE']=false; p.x=z.x+900; p.y=z.y+700;
         for(var f2=0;f2<120&&__state()&&!__state().over;f2++) __loop(performance.now()+f2*16.7);
       }
       var after=z.pullT;
       p.x=z.x; p.y=z.y; K['KeyE']=true;
       var fr=0; for(;fr<40&&__state()&&!__state().over;fr++) __loop(performance.now()+fr*16.7);
       K['KeyE']=false;
       return {got:got,after:after,extracted:(!__state()||!!__state().over),frames:fr};
     }
     var a=pull(true);
     if(!a) return 'no open ring to test with';
     // The probe must actually have started a pull, or it is testing nothing.
     if(!(a.got>0.5)) return 'the probe never got the hold going (reached '+a.got+'), so it is testing nothing';
     if(a.after!==null&&a.after!==undefined) return 'the hold survived leaving the ring, at '+a.after;
     if(a.extracted) return 'leaving and returning still completed the boarding in '+a.frames+' frames';
     var b=pull(false);
     if(!b.extracted) return 'boarding no longer works at all when you never leave - the fix broke extraction';
     return null; }},
  {v:'8.60',what:'a burst gun wears once per ROUND, not once per trigger pull',
   run:function(){
     function fire(burst){
       var P=__P();
       P.weapons=['carbine']; P.wear=P.wear||{}; P.wear.carbine=0;
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.ents.length=0;
       p.wep={id:'carbine',name:'Burst Carbine',dmg:17,burst:burst,rof:360,spread:.055,
              mag:24,reload:1900,rng:500,auto:false,noise:400,tint:'#ffd88a',qRank:1,q:'field'};
       p.ammo=24; p.reserve=600; p.wepIssued=false; p.wepFromArmory=false;
       p.iv=99; p.reloading=0; p.jam=0;
       var M=__mouse(); M.down=true;
       var a0=p.ammo+p.reserve;
       for(var f=0;f<240;f++){ var pp=__state().player; M.down=true; pp.ads=false; __loop(performance.now()+f*16.7); }
       M.down=false;
       var g2=__state(), p2=g2.player;
       return {fired:a0-(p2.ammo+p2.reserve), wear:__P().wear.carbine||0};
     }
     var b3=fire(3), b1=fire(1);
     if(!b3.fired||!b1.fired) return 'the probe fired nothing, so it is testing nothing';
     var r3=b3.wear/b3.fired, r1=b1.wear/b1.fired;
     if(Math.abs(r3-r1)>0.05) return 'burst wears '+r3.toFixed(2)+' per round against '+r1.toFixed(2)+' for a single shot';
     return null; }},
  {v:'8.60',what:'a machine playing dead can be killed while it does it',
   run:function(){
     function go(kill){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player, cr=null;
       for(var i=0;i<g.ents.length;i++) if(g.ents[i].kind==='crawler'){ cr=g.ents[i]; break; }
       if(!cr) return null;
       g.ents.length=0; g.ents.push(cr);
       cr.possum=1; cr.state='possum'; cr.dead=0;
       cr.x=p.x+1400; cr.y=p.y+900;
       if(kill) cr.hp=-5;
       for(var f=0;f<300;f++) __rawStep(1/60);
       var g2=__state();
       for(var j=0;j<g2.ents.length;j++) if(g2.ents[j].kind==='crawler'&&!g2.ents[j].dead) return g2.ents[j];
       return null;
     }
     var dead=go(true), alive=go(false);
     if(dead) return 'a possum crawler at hp '+dead.hp+' is still in the entity list and not dead';
     // and the ambush must still arm, or the fix has removed the mechanic
     if(!alive) return 'a healthy possum crawler vanished - the fix broke the ambush';
     if(alive.state!=='possum') return 'a healthy possum crawler stopped playing dead on its own';
     return null; }},
  {v:'8.59',what:'a roll does not freeze the heal you are applying',
   run:function(){
     function go(roll){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.ents.length=0;
       p.hp=40; p.armor=0; p.iv=99; p.combatT=99; p.healQ=30; p.prep=null;
       for(var f=0;f<180;f++){
         var pp=__state().player;
         if(roll){ pp.roll=0.5; pp.rollDir={x:1,y:0}; }
         __loop(performance.now()+f*16.7);
       }
       return __state().player.healQ||0;
     }
     var a=go(false), b=go(true);
     if(b>a+1) return 'rolling left '+b.toFixed(1)+' of the heal unapplied against '+a.toFixed(1)+' standing still';
     return null; }},
  {v:'8.59',what:'melee cannot swing through a wall',
   run:function(){
     __resetCfg(); __pinDefaults(1); __startRaid({mapIx:1,seed:4242});
     var g=__state();
     var solid=g.map.walls.filter(function(w){return !w.furn&&!w.wreck&&!w.ledge;});
     solid.sort(function(a,b){return Math.min(a.w,a.h)-Math.min(b.w,b.h);});
     var reach=0, allowed=0;
     for(var k=0;k<solid.length;k++){
       var w=solid[k], t=Math.min(w.w,w.h);
       if(t>20) break;
       var thin=(w.w<w.h), cx=w.x+w.w/2, cy=w.y+w.h/2;
       var d=t/2+11.5, d2=t/2+13.5;
       var px=thin?cx-d:cx, py=thin?cy:cy-d;
       var qx=thin?cx+d2:cx, qy=thin?cy:cy+d2;
       if(Math.hypot(qx-px,qy-py)-24>MELEE_REACH) continue;
       reach++;
       refreshVseg();
       if(losClear(px,py,qx,qy,G.vseg)) allowed++;
     }
     // The map must still HAVE such geometries, or this check is watching nothing.
     if(!reach) return 'no wall-separated geometry inside melee reach - this check has stopped testing anything';
     if(allowed) return allowed+' of '+reach+' wall-separated pairs would still allow a swing';
     return null; }},
  {v:'8.58',what:'closest-extract measures the nearest OPEN ring, not the targeted one',
   run:function(){
     var out=[];
     [0,1].forEach(function(mi){
       __resetCfg(); __pinDefaults(mi); __startRaid({mapIx:mi,seed:4242});
       var g=__state(), p=g.player, near=1e9, act=g.active?dist(p,g.active):null;
       for(var i=0;i<g.zones.length;i++){ var z=g.zones[i]; if(!z.open) continue;
         var d=dist(p,z); if(d<near) near=d; }
       if(near>=1e9) return;
       for(var f=0;f<6;f++) __loop(performance.now()+f*16.7);
       var c=__state().tel.closestExtract;
       if(Math.abs(c-near)>2) out.push('mapIx '+mi+' reported '+Math.round(c)+', nearest open ring is '+Math.round(near));
     });
     return out.length?out.join('; '):null; }},
  {v:'8.58',what:'the sector board reads in metres, not a tenfold hectare',
   run:function(){
     try{ __ui.sector(); }catch(e){ return 'renderSector threw: '+e; }
     var t=(document.getElementById('sectormodal').textContent||'').replace(/\s+/g,' ');
     if(/\d+ by \d+ hectares/.test(t)) return 'the board still prints a dimension in hectares';
     if(!/\d+ by \d+ metres/.test(t)) return 'no metre dimension on the board at all';
     return null; }},
  {v:'8.58',what:'no message promises something the game does not do',
   run:function(){
     var bad=[];
     // Built at runtime on purpose. Written as literals, these needles appear in
     // this very function, which is in the page, so the check matched its own
     // source and failed a build that was correct.
     var n1='self-revive'+' with '+'medical', n2='jams'+' more '+'often';
     var src=(document.documentElement&&document.documentElement.innerHTML)||'';
     var cut=src.split('__REGRESS')[0];       // the game, not this harness
     if(cut.indexOf(n1)>=0) bad.push('the down message still asks for medical');
     if(cut.indexOf(n2)>=0) bad.push('the workshop still promises jamming');
     // And the fact underneath the text: if a wear band ever gets a real jam
     // figure, this stops being a lie and the workshop line should say so again.
     var anyJam=false;
     try{ for(var i=0;i<WEARSTEPS.length;i++) if(WEARSTEPS[i].jam>0) anyJam=true; }catch(e){}
     if(anyJam) bad.push('a wear band now has a real jam figure - the workshop line should promise it again');
     return bad.length?bad.join('; '):null; }},
  {v:'8.56',what:'the game counts in English at n=1',
   run:function(){
     var bad=[];
     if(__cos&&__cos.need){
       if(__cos.need({how:'runs:1'})!=='1 raid run') bad.push('unlock: '+__cos.need({how:'runs:1'}));
       if(__cos.need({how:'extracts:1'})!=='1 extraction') bad.push('unlock: '+__cos.need({how:'extracts:1'}));
       if(__cos.need({how:'runs:5'})!=='5 raids run') bad.push('plural broke: '+__cos.need({how:'runs:5'}));
     }
     return bad.length?bad.join('; '):null; }},
  {v:'8.78',what:'an item is in the backpack OR on the belt, never in both',
   run:function(){
     function grid(bind){
       var P=__P(); P.weapons=['smg']; P.hotAssign={};
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:['medkit','medkit','medkit','plate','servo'],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0; g.player.iv=99; g.bagOpen=true;
       for(var f=0;f<8;f++) __loop(performance.now()+f*16.7);
       if(bind) __state().hotAssign=bind;
       for(var f2=0;f2<8;f2++) __loop(performance.now()+f2*16.7);
       return (__state().bagCells||[]).map(function(c){ return c.key; }).sort().join(',');
     }
     var bad=[];
     // The control comes first. Nothing bound, everything shows. If this line
     // ever fails the harness is broken, not the rule.
     if(grid(null)!=='medkit,plate,servo') bad.push('control: unbound kit does not draw, got '+grid(null));
     // The rule. One plate carried, one plate bound, so no plate in the backpack.
     if(grid({8:'plate'}).indexOf('plate')>=0) bad.push('a bound plate is still in the backpack');
     // And the counter-control, so a fix that hides the whole stack fails here:
     // one of three medkits bound leaves two, which still draw.
     if(grid({7:'medkit'}).indexOf('medkit')<0) bad.push('binding 1 of 3 medkits hid all three');
     if(grid({7:'medkit',6:'medkit',5:'medkit'}).indexOf('medkit')>=0) bad.push('all three bound and a medkit still draws');
     // The store itself is never touched by any of this.
     if((__state().bag||[]).length!==5) bad.push('the bag store lost items, it should only be the DRAW that changes');
     return bad.length?bad.join('; '):null; }},
  // v9.00: the v8.79 check is retired. It proved a windfall item landed clear of
  // the item the search bar was already delivering, and his answer 10 removed
  // windfalls entirely. The half of it worth keeping, that several items in one
  // grant are dealt out rather than dumped on one frame, is asserted by the
  // v9.00 check at the end of this list.
  {v:'8.80',what:'a crawler waits between swings instead of hitting every frame',
   run:function(){
     __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(),p=g.player,c=null;
     for(var i=0;i<g.ents.length;i++) if(g.ents[i].kind==='crawler'&&!g.ents[i].elite){ c=g.ents[i]; break; }
     if(!c) return 'no plain crawler on the map to test with';
     // ONE crawler and nothing else, or the gaps measure the crowd, not the rule.
     g.ents.length=0; g.ents.push(c);
     p.x=c.x+14; p.y=c.y; p.hp=100000; p.maxhp=100000; p.armor=0; p.iv=0;
     var K=__keysRef(); for(var kk in K) delete K[kk];
     var last=p.hp,times=[];
     for(var f=0;f<600;f++){ __loop(performance.now()+f*16.7); if(p.hp<last){ times.push(g.t); last=p.hp; } }
     var bad=[];
     // CONTROL: it must still be able to hit at all. A gate that stopped the
     // chase outright would give a perfect zero here and look like a pass.
     if(times.length<4) return 'control: the crawler barely attacked at all, '+times.length+' hits in 10s';
     var gaps=[];
     for(var h=1;h<times.length;h++) gaps.push(times[h]-times[h-1]);
     gaps.sort(function(a,b){ return a-b; });
     var med=gaps[Math.floor(gaps.length/2)];
     // The bug was a 1 frame gap, about 0.02s. 0.7 is what the melee line asks for.
     if(med<0.45) bad.push('a single crawler is swinging every '+med.toFixed(3)+'s, the melee cooldown is 0.7');
     if(med>1.2) bad.push('a single crawler has gone passive, '+med.toFixed(3)+'s between swings');
     return bad.length?bad.join('; '):null; }},
  {v:'8.81',what:'the HUD grows with the screen and the belt never sits on the health bar',
   run:function(){
     function at(w,h){
       __forceSize(w,h);
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:['medkit','plate'],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0; g.player.iv=99; g.player.armor=20;
       for(var f=0;f<8;f++) __loop(performance.now()+f*16.7);
       var H2=__hud();
       if(!H2.belt||!H2.box.body||!H2.box.gear) return null;
       return {cell:H2.belt.cellW,
               gapL:H2.belt.x-H2.box.body.right,
               gapR:H2.box.gear.x-H2.belt.right,
               vitals:H2.box.body.w};
     }
     var a=at(1920,1080),b=at(2560,1440),c=at(3840,2160);
     __forceSize(1920,1080);
     if(!a||!b||!c) return 'could not read the HUD boxes at one of the three sizes';
     var bad=[];
     // The belt used to be 90px at all three. It must be bigger than that now,
     // and it must actually follow the screen.
     if(a.cell<=90) bad.push('the belt did not grow at 1080p, cell '+a.cell);
     if(b.cell<=a.cell) bad.push('the belt does not follow the screen to 1440p, '+a.cell+' then '+b.cell);
     if(c.cell<=b.cell) bad.push('the belt does not follow the screen to 4K, '+b.cell+' then '+c.cell);
     if(b.vitals<=a.vitals) bad.push('the vitals block does not follow the screen, '+a.vitals+' then '+b.vitals);
     // THE CONTROL that caught my first attempt: sizing the belt to the room but
     // centring it on the SCREEN put it 76px on top of the health bar. Any
     // negative gap here means the belt is overlapping a corner block again.
     [['1080p',a],['1440p',b],['4K',c]].forEach(function(r){
       if(r[1].gapL<0) bad.push('at '+r[0]+' the belt overlaps the vitals by '+(-r[1].gapL)+'px');
       if(r[1].gapR<0) bad.push('at '+r[0]+' the belt overlaps the gear stack by '+(-r[1].gapR)+'px');
     });
     return bad.length?bad.join('; '):null; }},
  {v:'8.82',what:'neither sector starts you in the same place every raid, and never beside an extract',
   run:function(){
     function sample(mapIx,n){
       var seen={},nearest=1e9;
       for(var i=0;i<n;i++){
         __resetCfg(); __pinDefaults(mapIx);
         __startRaid({mapIx:mapIx,seed:1000+i*777});
         var g=__state(),m=g.map,p=g.player,d=1e9;
         for(var e=0;e<m.extracts.length;e++)
           d=Math.min(d,Math.hypot(m.extracts[e].x-p.x,m.extracts[e].y-p.y));
         if(d<nearest) nearest=d;
         seen[Math.round(p.x)+','+Math.round(p.y)]=1;
       }
       var counts=Object.keys(seen).map(function(k){ return seen[k]; });
       return {distinct:Object.keys(seen).length,nearest:Math.round(nearest),
               topShare:Math.max.apply(null,counts)/n};
     }
     var a=sample(0,16), b=sample(1,16);
     var bad=[];
     // COLD STORAGE gave exactly ONE spawn across every seed before v8.82,
     // because only one of its six cleared the 1500 bar.
     if(a.distinct<4) bad.push('COLD STORAGE offers only '+a.distinct+' start(s)');
     if(b.distinct<4) bad.push('THE COLD MILE offers only '+b.distinct+' start(s)');
     // v8.90: AND NO ONE START MAY DOMINATE. v8.82 satisfied the count above and
     // still opened him on the same corner 45 percent of the time, which is what
     // he reported as "still spawning at the same place". A count is not variety.
     if(a.topShare>0.5) bad.push('one COLD STORAGE start takes '+Math.round(a.topShare*100)+' percent of raids');
     if(b.topShare>0.5) bad.push('one THE COLD MILE start takes '+Math.round(b.topShare*100)+' percent of raids');
     // THE CONTROL. Widening the choice must not be achieved by dropping his
     // run #37 rule: "i just spawned right next to an extraction, that should
     // never happen." The two spawns this rule rejects on COLD STORAGE sit 290
     // and 286 out, so anything under 900 means the rule has been thrown away.
     if(a.nearest<900) bad.push('COLD STORAGE started a raid '+a.nearest+' from an extract');
     if(b.nearest<900) bad.push('THE COLD MILE started a raid '+b.nearest+' from an extract');
     return bad.length?bad.join('; '):null; }},
  {v:'8.83',what:'rolling in the Undercroft draws the ball, the same as it does upstairs',
   run:function(){
     if(!__hubEnter()) return 'could not reach the Undercroft floor';
     var hp=__hubP(); if(!hp) return 'no operator on the Undercroft floor';
     __spyOps(true);
     function poses(rolling){
       var out=[];
       if(rolling){ hp.rollDir={x:1,y:0}; hp.rollT=0.38; } else { hp.rollT=0; }
       for(var f=0;f<10;f++){
         window.__opCalls=[];
         __hubStep(1/60);
         var hero=(window.__opCalls||[]).filter(function(c){ return c.hero; });
         if(hero.length) out.push(hero[0].mode);
       }
       return out;
     }
     var rolling=poses(true), standing=poses(false);
     __spyOps(false);
     var bad=[];
     if(!rolling.length) return 'the Undercroft drew no operator at all';
     // v8.70 passed the roll PHASE and left the pose as the walk cycle, which is
     // what "player doesn't turn into a rolly ball" was describing. The pose is
     // the argument that matters.
     if(rolling.filter(function(m){ return m==='roll'; }).length<rolling.length)
       bad.push('a rolling operator is not drawn as a ball, poses '+JSON.stringify(rolling));
     // THE CONTROL: hardcoding the ball would pass the line above and be worse.
     if(standing.filter(function(m){ return m==='roll'; }).length)
       bad.push('a standing operator is being drawn as a ball');
     return bad.length?bad.join('; '):null; }},
  {v:'8.84',what:'I in the Undercroft opens neither the terminal nor the retired full screen panel',
   run:function(){
     if(!__hubEnter()) return 'could not reach the Undercroft floor';
     // Entering the Undercroft unpacks your kit, so it has to be staged AFTER.
     // My first probe staged it before and read an empty grid as a bug.
     var P=__P();
     P.kit=['medkit','medkit','medkit','plate','servo'];
     P.hotAssign={7:'medkit',8:'plate'};
     var K=__keysRef(); for(var kk in K) delete K[kk];
     var cm=document.getElementById('carrymodal');
     var hub=document.getElementById('hub');
     cm&&cm.classList.remove('on'); hub.classList.remove('on');
     __hubBag(false);
     document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyI',bubbles:true}));
     var bad=[];
     // v8.95 replaced the full screen panel this check was written for, on his
     // note "they should get this exact same menu, NOT a fullscreen one". The
     // intent it was protecting survives: ONE inventory, opened by I, and the
     // terminal left alone. Where that inventory is drawn is the v8.95 check.
     if(cm&&cm.classList.contains('on')) bad.push('the retired full screen panel still opens on I');
     if(hub.classList.contains('on')) bad.push('I opened the terminal as well');
     if(!__hubBag()) bad.push('I opened no backpack at all');
     document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyI',bubbles:true}));
     return bad.length?bad.join('; '):null; }},
  {v:'8.85',what:'a pillager footprint does not draw through a wall, and a visible one still does',
   run:function(){
     __zoom.set(1,true);   // a render check owns the camera; setZoom persists
     __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(),p=g.player;
     g.ents.length=0; p.iv=99;
     var cv=document.getElementById('cv'); if(!cv) return 'no canvas to read';
     var c2=cv.getContext('2d');
     // __frame(0) redraws WITHOUT advancing the clock. That matters: my first
     // probe stepped __loop between shots, so the diff was rain and lighting
     // moving, not footprints, and it reported a leak of 23,239 pixels that was
     // entirely noise. This null control is what proves the method works at all.
     function shot(){ __frame(0); return c2.getImageData(0,0,cv.width,cv.height).data; }
     function diff(a,b){ var d=0;
       for(var i=0;i<a.length;i+=4){
         if(Math.abs(a[i]-b[i])+Math.abs(a[i+1]-b[i+1])+Math.abs(a[i+2]-b[i+2])>8) d++; }
       return d; }
     g.decals.length=0;
     if(diff(shot(),shot())!==0) return 'the renderer is not deterministic at dt 0, this check cannot measure anything';
     function trial(x,y,mine){
       g.decals.length=0; var base=shot();
       for(var k=0;k<8;k++) g.decals.push({x:x+k*3,y:y+k*2,c:'#241a10',s:5,a:.55,a0:.55,
         rot:0.6,print:1,mine:mine?1:0,t:0,life:45});
       var withP=shot(); g.decals.length=0; return diff(base,withP);
     }
     // A spot that is walkable, out of line of sight, and where a print is
     // genuinely drawable. That last part matters: a point inside a wall draws
     // nothing either way and would pass this check while proving nothing.
     var hid=null;
     for(var r=60;r<500&&!hid;r+=25){
       for(var a=0;a<6.28&&!hid;a+=0.09){
         var qx=Math.round(p.x+Math.cos(a)*r), qy=Math.round(p.y+Math.sin(a)*r);
         if(!__nav.free(qx,qy,10)) continue;
         if(__los.clear(p.x,p.y,qx,qy)) continue;
         if(trial(qx,qy,true)>150) hid={x:qx,y:qy};   // mine bypasses the gate
       }
     }
     if(!hid) return 'could not find a hidden spot where a print is drawable at all';
     var vis=null;
     for(var r2=40;r2<220&&!vis;r2+=10){
       for(var a2=0;a2<6.28&&!vis;a2+=0.09){
         var vx=Math.round(p.x+Math.cos(a2)*r2), vy=Math.round(p.y+Math.sin(a2)*r2);
         if(!__nav.free(vx,vy,10)) continue;
         if(!__los.see(p.x,p.y,p.face,vx,vy)) continue;
         if(trial(vx,vy,false)>150) vis={x:vx,y:vy};
       }
     }
     var bad=[];
     // THE BUG: a pillager print behind a wall must draw nothing.
     var leak=trial(hid.x,hid.y,false);
     if(leak>0) bad.push('a pillager print behind a wall drew '+leak+' pixels');
     // CONTROL ONE: it must still draw where you can see it, or the fix is just
     // "delete footprints" and would pass the line above.
     if(!vis) bad.push('control: no visible spot where a pillager print draws at all');
     // CONTROL TWO: your own prints are exempt, which is what the mine flag is for.
     if(trial(hid.x,hid.y,true)<=0) bad.push('control: your own prints stopped drawing too');
     return bad.length?bad.join('; '):null; }},
  {v:'8.86',what:'a house is a gamble: most hold a crawler, some hold three, and some are still empty',
   run:function(){
     function survey(mapIx,seeds){
       var tot=0,inside=0,bTot=0,bWith=0,b3=0;
       for(var s=0;s<seeds;s++){
         __resetCfg(); __pinDefaults(mapIx);
         __startRaid({mapIx:mapIx,seed:2000+s*613});
         var g=__state(),B=(g.map.buildings||[]);
         var cnt=new Array(B.length); for(var q=0;q<B.length;q++) cnt[q]=0;
         for(var e=0;e<g.ents.length;e++){
           var E=g.ents[e]; if(E.kind!=='crawler') continue;
           tot++;
           for(var b=0;b<B.length;b++){ var Bb=B[b];
             if(E.x>Bb.x&&E.x<Bb.x+Bb.w&&E.y>Bb.y&&E.y<Bb.y+Bb.h){ inside++; cnt[b]++; break; } }
         }
         bTot+=B.length;
         for(var q2=0;q2<B.length;q2++){ if(cnt[q2]>0) bWith++; if(cnt[q2]>=3) b3++; }
       }
       return {pctIn:inside/tot*100, pctOcc:bWith/bTot*100, withThree:b3, buildings:bTot};
     }
     var a=survey(0,5), b=survey(1,5);
     var bad=[];
     // Before v8.86: 15.6 percent of buildings occupied on COLD STORAGE, 14 on
     // THE COLD MILE. Walking into a house was safe five times out of six.
     if(a.pctOcc<45) bad.push('COLD STORAGE houses only '+a.pctOcc.toFixed(1)+' percent occupied');
     if(b.pctOcc<45) bad.push('THE COLD MILE houses only '+b.pctOcc.toFixed(1)+' percent occupied');
     // "a crawler or 3": the threes have to actually happen.
     if(!a.withThree) bad.push('no COLD STORAGE house held three crawlers across five raids');
     // CONTROL ONE: some houses must still be EMPTY, or there is no gamble in it,
     // just a tax. This is the line that a fix of "put a crawler in every
     // building" would fail.
     if(a.pctOcc>90) bad.push('COLD STORAGE houses are '+a.pctOcc.toFixed(1)+' percent occupied, that is a tax and not a gamble');
     if(b.pctOcc>90) bad.push('THE COLD MILE houses are '+b.pctOcc.toFixed(1)+' percent occupied');
     // CONTROL TWO: the street cannot go quiet. Some crawlers stay outside, or
     // the change reads as "crawlers moved" rather than "houses got dangerous".
     if(a.pctIn>92) bad.push('COLD STORAGE moved '+a.pctIn.toFixed(1)+' percent of crawlers indoors, the street is empty');
     if(b.pctIn>92) bad.push('THE COLD MILE moved '+b.pctIn.toFixed(1)+' percent of crawlers indoors');
     return bad.length?bad.join('; '):null; }},
  {v:'8.87',what:'no gun is named after a rarity it is not drawn as',
   run:function(){
     var RAR=['common','uncommon','rare','elite','gold'];
     var T=__guns.tiers(), Q=__guns.quality(), bad=[];
     // The bug was one word living in two scales: gold was the top CONDITION
     // (prefix "Gold ") and also the top RARITY (colour #ffc72e), so 14 of the
     // 16 guns could be called Gold something and drawn blue, white or purple.
     // This is the general form, so a future condition cannot reopen it.
     for(var qi=0;qi<Q.length;qi++){
       var pre=(Q[qi].prefix||'').trim().toLowerCase();
       if(!pre) continue;
       if(RAR.indexOf(pre)>=0)
         bad.push('the "'+Q[qi].prefix.trim()+'" condition is named after the '+pre+' rarity');
     }
     // And the specific case, checked through the names the game builds.
     for(var k in T){
       var g=__guns.nameAt(k,'gold');
       if(!g) continue;
       var first=g.name.split(' ')[0].toLowerCase();
       if(RAR.indexOf(first)>=0&&first!==g.rarity)
         bad.push(g.name+' is drawn '+g.rarity+', not '+first);
     }
     // v9.02: the ladder itself is retired by his answer 18, so the old demand
     // for five rungs with a gold key is void. What this check was protecting is
     // the WORD collision, and that survives: no gun may be named after a rarity.
     if(Q.length!==1) bad.push('the condition ladder is back, it has '+Q.length+' rungs');
     if(Q[0]&&(Q[0].prefix||'')!=='') bad.push('the one remaining condition puts "'+Q[0].prefix+'" in front of a gun name');
     // CONTROL TWO: gold must still be a RARITY, or the fix was to delete the
     // colour rather than to stop the collision.
     if(__guns.colourOf('gold')!=='#ffc72e') bad.push('gold is no longer a rarity colour');
     return bad.length?bad.join('; '):null; }},
  {v:'8.88',what:'the title screen obeys the text size setting and follows the monitor',
   run:function(){
     var t=document.getElementById('title');
     if(!t) return 'no title screen in the page';
     var P=__P(), keepZ=P.menuZoom, keepW=W, keepH=H;
     function z(w,h,mz){ __forceSize(w,h); P.menuZoom=mz; applyMenuZoom(); return parseFloat(t.style.zoom); }
     var bad=[];
     // It used to carry no zoom at all: applyMenuZoom listed .modal, .pausebox,
     // .outcome and #hub, and the first screen anybody sees was in none of them.
     var a=z(1920,1080,1.3);
     if(!(a>0)) bad.push('the title screen carries no zoom at all');
     // The text size setting has to reach it.
     var b=z(1920,1080,2.0);
     if(!(b>a)) bad.push('raising the text size did not change the title screen, '+a+' then '+b);
     // And the monitor has to reach it: 1440p is a third bigger than 1080p.
     var c=z(2560,1440,1.3);
     if(!(c>a*1.2)) bad.push('the title screen does not follow the screen to 1440p, '+a+' then '+c);
     // CONTROL ONE: floored at 1, so a small window is never shrunk further.
     var d=z(1280,720,1.3);
     if(Math.abs(d-a)>0.001) bad.push('a small window shrank the title screen, '+d+' against '+a+' at 1080p');
     // CONTROL TWO: it must be able to scroll. It scales now, and .screen is
     // overflow:hidden, which is exactly how v8.75 pushed the map picker footer
     // off the bottom with no way to reach it. The saves list and CREATE A NEW
     // SAVE are the last things on this screen.
     var ov=getComputedStyle(t).overflowY;
     if(ov!=='auto'&&ov!=='scroll') bad.push('the title screen cannot scroll, overflowY is '+ov+', so a tall one clips its own footer');
     P.menuZoom=keepZ; __forceSize(keepW||1920,keepH||1080); applyMenuZoom();
     return bad.length?bad.join('; '):null; }},
  {v:'8.89',what:'a pillager wading out of sight draws no rings in the water',
   run:function(){
     __zoom.set(1,true);   // same reason as v8.85
     __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(),p=g.player;
     g.ents.length=0; p.iv=99;
     var cv=document.getElementById('cv'); if(!cv) return 'no canvas to read';
     var c2=cv.getContext('2d');
     function shot(){ __frame(0); return c2.getImageData(0,0,cv.width,cv.height).data; }
     function diff(a,b){ var d=0;
       for(var i=0;i<a.length;i+=4){
         if(Math.abs(a[i]-b[i])+Math.abs(a[i+1]-b[i+1])+Math.abs(a[i+2]-b[i+2])>8) d++; }
       return d; }
     g.decals.length=0;
     if(diff(shot(),shot())!==0) return 'the renderer is not deterministic at dt 0, this check cannot measure anything';
     function trial(x,y,mine){
       g.decals.length=0; var base=shot();
       for(var k=0;k<8;k++) g.decals.push({x:x+k*3,y:y+k*2,c:'#b4def0',s:7,a:.5,a0:.5,
         rot:0,ripple:1,mine:mine?1:0,t:0,life:45});
       var w=shot(); g.decals.length=0; return diff(base,w);
     }
     var hid=null;
     for(var r=60;r<500&&!hid;r+=25){
       for(var a=0;a<6.28&&!hid;a+=0.09){
         var qx=Math.round(p.x+Math.cos(a)*r), qy=Math.round(p.y+Math.sin(a)*r);
         if(!__nav.free(qx,qy,10)) continue;
         if(__los.clear(p.x,p.y,qx,qy)) continue;
         if(trial(qx,qy,true)>150) hid={x:qx,y:qy};   // mine bypasses the gate
       }
     }
     if(!hid) return 'could not find a hidden spot where a ripple is drawable at all';
     var bad=[];
     var leak=trial(hid.x,hid.y,false);
     if(leak>0) bad.push('a pillager ripple behind a wall drew '+leak+' pixels');
     // CONTROL: your own wake must still draw, or the fix was to delete ripples.
     if(trial(hid.x,hid.y,true)<=0) bad.push('control: your own ripples stopped drawing too');
     return bad.length?bad.join('; '):null; }},
  {v:'8.91',what:'the three in-raid panels are twice the size, at every resolution, and never touch',
   run:function(){
     // His answer 25 is "TWICE AS LARGE RELATIVE TO THE SCREEN" and 26 is that it
     // has to look right at 1080p, 1440p and 4K, so all three are checked.
     var SIZES=[[1920,1080],[2560,1440],[3840,2160]];
     // Sizes before v8.91, measured at 1920x1080. None of these three were ever
     // in HUDZ, so the two builds that grew the HUD both walked straight past
     // them. Every size below is expressed as a SHARE of the screen, because a
     // pixel count would pass on a 4K panel while looking half the size.
     var was={raiders:[334,176],legend:[311,131],cond:[257,203]};
     var bad=[];
     function ov(a,b){ return !!(a&&b)&&a.x<b.right&&a.right>b.x&&a.y<b.bottom&&a.bottom>b.y; }
     for(var si=0;si<SIZES.length;si++){
       var SW=SIZES[si][0], SH=SIZES[si][1], tag=SW+'x'+SH;
       __forceSize(SW,SH);
       // v8.93 added a per-panel user scale saved on the profile. This check is
       // about the DEFAULT, so clear it, or the previous check's grip drag picks
       // the answer.
       var _P=__P(); _P.hud={};
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:['medkit'],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.player.iv=99;
       for(var f=0;f<20;f++) __loop(performance.now()+f*16.7);
       var B=__hud().box;
       if(!B.raiders||!B.legend||!B.cond){ bad.push('at '+tag+' one of the three panels did not draw'); continue; }
       ['raiders','legend','cond'].forEach(function(k){
         var got=B[k];
         // the old share of a 1920x1080 screen, doubled, is the bar
         // 1.4, not 1.9: he asked at v8.93 for 75 percent of the v8.91 size once
         // he saw it at 4K, where the screen factor was multiplying it by 1.9.
         // The floor is the default with no user scale; the corner grip can take
         // it lower and that is his business, not this check's.
         // WIDTH ONLY, v9.02: a panel is as tall as it has content, so height
         // moves whenever the game has more or less to say and reports nothing
         // about whether the panel was scaled. Width is the scale.
         var wantW=(was[k][0]/1920)*SW*1.4;
         if(got.w<wantW)
           bad.push(k+' at '+tag+' is '+got.w+' wide, under 1.4x its old share of the screen');
       });
       // CONTROL ONE: doubling two panels that grow toward each other made them
       // overlap by 106px on my first attempt. Any touching pair fails.
       [['raiders','legend'],['raiders','cond'],['legend','cond'],
        ['legend','body'],['cond','gear'],['raiders','body']].forEach(function(pr){
         if(ov(B[pr[0]],B[pr[1]])) bad.push(pr[0]+' overlaps '+pr[1]+' at '+tag);
       });
       // CONTROL TWO: bigger must not mean partly off screen, which is the other
       // obvious way to satisfy the size bar and be worse than before.
       ['raiders','legend','cond'].forEach(function(k){
         var r=B[k];
         if(r.x<0||r.y<0||r.right>SW||r.bottom>SH)
           bad.push(k+' is off screen at '+tag+', '+r.x+','+r.y+' to '+r.right+','+r.bottom);
       });
     }
     __forceSize(1920,1080);
     return bad.length?bad.join('; '):null; }},
  {v:'8.92',what:'the wheel zooms three times closer than it used to, and both ends still hold',
   run:function(){
     var bad=[];
     // Every value is READ BACK. setZoom clamps silently, so a check that only
     // asks is measuring its own input, which is how I first "proved" the game
     // rendered at zoom 9 when it had quietly held at 3.
     [0,1].forEach(function(mi){
       __resetCfg(); __pinDefaults(mi);
       __deploy({kit:['medkit'],safe:null,mapIx:mi,seed:4242});
       var g=__state(); g.player.iv=99;
       // The close end he asked for: 2 to 3 times nearer than the old 3.0.
       try{
         __zoom.set(6);
         if(__zoom.get()<6) bad.push('map '+mi+' will not go to 6, it held at '+__zoom.get());
         for(var f=0;f<8;f++) __loop(performance.now()+f*16.7);
       }catch(e){ bad.push('map '+mi+' threw while drawing at zoom 6: '+e); }
       try{
         __zoom.set(9);
         if(__zoom.get()<9) bad.push('map '+mi+' will not go to 9, it held at '+__zoom.get());
         for(var f2=0;f2<8;f2++) __loop(performance.now()+f2*16.7);
       }catch(e2){ bad.push('map '+mi+' threw while drawing at zoom 9: '+e2); }
       // CONTROL ONE: there must still BE a ceiling. Removing the clamp would
       // satisfy every line above and let the wheel run away to nothing.
       __zoom.set(400);
       if(__zoom.get()>__zoom.max()) bad.push('map '+mi+' let the zoom past its own ceiling');
       // CONTROL TWO: the far end is untouched. He said at v8.79 that the wide
       // end was right, so widening it here would be an unasked change.
       __zoom.set(0.1);
       if(Math.abs(__zoom.get()-0.85)>0.001) bad.push('the wide end moved, it is now '+__zoom.get()+' and should be 0.85');
       for(var f3=0;f3<6;f3++) __loop(performance.now()+f3*16.7);
     });
     __zoom.set(1);
     return bad.length?bad.join('; '):null; }},
  {v:'8.93',what:'a HUD panel can be resized by its corner grip, and the default dropped to 75 percent',
   run:function(){
     // Real mouse events against real canvas coordinates, so a collapsed pane
     // with a zero sized canvas rect would measure nothing.
     if(!__vpAlive()) return 'SKIP: the pane has no layout, canvas rects are zero and no click can land';
     __forceSize(1920,1080);
     var P=__P(); P.hud={};
     __resetCfg(); __pinDefaults(0);
     __deploy({kit:['medkit'],safe:null,mapIx:0,seed:4242});
     var g=__state(); g.player.iv=99;
     // Leftover bagOpen from an earlier check blocks the whole HUD mouse path,
     // which is what made me read a working grip as broken the first time.
     g.bagOpen=false; g.mapOpen=false;
     for(var f=0;f<20;f++) __loop(performance.now()+f*16.7);
     var B=__hud().box.raiders;
     if(!B) return 'the pillager board did not draw';
     var bad=[];
     // v8.91 shipped these at 2.0 and he said too big at 4K; 1.5 is his 75 pct.
     if(Math.abs(B.w-501)>12||Math.abs(B.h-264)>12)
       bad.push('the default board is '+B.w+'x'+B.h+', it should be about 501x264');
     var cv=document.getElementById('cv'), r=cv.getBoundingClientRect();
     function ev(t,x,y,tgt){ (tgt||cv).dispatchEvent(new MouseEvent(t,
       {button:0,bubbles:true,clientX:r.left+x,clientY:r.top+y})); }
     function drag(fx,fy,tx,ty){
       ev('mousemove',fx,fy); ev('mousedown',fx,fy);
       ev('mousemove',tx,ty); ev('mouseup',tx,ty,window);
       for(var q=0;q<8;q++) __loop(performance.now()+q*16.7);
     }
     // THE GRIP: grab the bottom right corner and pull out.
     drag(B.right-6,B.bottom-6,B.right+200,B.bottom+105);
     var z1=(__P().hud.raiders||{}).z, B1=__hud().box.raiders;
     if(!(z1>1.05)) bad.push('dragging the corner did not scale the panel, z is '+z1);
     if(!(B1.w>B.w+40)) bad.push('the panel did not actually get bigger, '+B.w+' then '+B1.w);
     // AND IT IS REMEMBERED, which is the half that makes it worth having.
     if(!((__P().hud.raiders||{}).z>1.05)) bad.push('the new size was not saved on the profile');
     // CONTROL ONE: the middle of the panel must NOT resize it, or the grip is
     // not a grip and every drag of the panel would rescale it by accident.
     P.hud={};
     for(var f2=0;f2<12;f2++) __loop(performance.now()+f2*16.7);
     var B2=__hud().box.raiders;
     drag(B2.x+B2.w/2,B2.y+B2.h/2,B2.x+B2.w/2+160,B2.y+B2.h/2+90);
     if(((__P().hud.raiders||{}).z||1)!==1) bad.push('control: dragging the middle of the panel resized it');
     // CONTROL TWO: it is clamped, so the wheel of a big pull cannot make a
     // panel that swallows the screen or vanishes.
     P.hud={raiders:{z:99}};
     for(var f3=0;f3<12;f3++) __loop(performance.now()+f3*16.7);
     var B3=__hud().box.raiders;
     P.hud={raiders:{z:0.001}};
     for(var f4=0;f4<12;f4++) __loop(performance.now()+f4*16.7);
     var B4=__hud().box.raiders;
     if(B3.w>1920) bad.push('an absurd saved scale drew a panel wider than the screen, '+B3.w);
     if(B4.w<60) bad.push('a tiny saved scale collapsed the panel to '+B4.w+'px');
     P.hud={};
     return bad.length?bad.join('; '):null; }},
  {v:'8.94',what:'the backpack never sits on the belt, at any resolution, and is called the backpack',
   run:function(){
     var bad=[];
     // He plays at 4K. The old reserve was LH(70)+LH(14), which is 131px at
     // every resolution because LH follows the text size, while the belt has
     // sized itself to the screen since v8.81. Measured before the fix: clear by
     // 10 at 1080p, 28 into the belt at 1440p, 64 into it at 4K.
     [[1920,1080],[2560,1440],[3840,2160]].forEach(function(SZ){
       var W2=SZ[0],H2=SZ[1],tag=W2+'x'+H2;
       __forceSize(W2,H2);
       var P=__P(); P.hud={};
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:['medkit','plate','servo','scrap','bandage'],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0; g.player.iv=99; g.bagOpen=true;
       for(var f=0;f<12;f++) __loop(performance.now()+f*16.7);
       var st=__state(), hc=st.hotCells||[], bp=st.bagPanel;
       if(!bp){ bad.push('at '+tag+' the backpack panel recorded no rectangle'); return; }
       if(!hc.length){ bad.push('at '+tag+' the belt drew no cells to measure against'); return; }
       var gap=hc[0].y-(bp.y+bp.h);
       if(gap<0) bad.push('at '+tag+' the backpack covers the belt by '+Math.round(-gap)+'px');
       // The prompt line lives above the cells and was the other half of what it
       // was covering, so a gap of nearly nothing is not good enough.
       if(gap<12) bad.push('at '+tag+' the backpack leaves only '+Math.round(gap)+'px above the belt');
       // CONTROL ONE: it must still be a usable panel. Shrinking it to a sliver
       // would satisfy every line above and be a worse bug.
       if(bp.h<200||bp.w<400) bad.push('at '+tag+' the backpack shrank to '+Math.round(bp.w)+'x'+Math.round(bp.h));
       if(bp.y<0) bad.push('at '+tag+' the backpack top ran off the screen');
       // CONTROL TWO: it must still be DRAWING the things it holds.
       if(!(st.bagCells||[]).length) bad.push('at '+tag+' the backpack drew no item cells');
     });
     __forceSize(1920,1080);
     // His word for it. Inventory means the backpack plus the belt; this panel is
     // the backpack.
     var src=(document.documentElement&&document.documentElement.innerHTML)||'';
     var cut=src.split('__REGRESS')[0];
     var needle='fillText('+String.fromCharCode(39)+'INVENTORY'+String.fromCharCode(39);
     if(cut.indexOf(needle)>=0) bad.push('the panel is still headed INVENTORY');
     return bad.length?bad.join('; '):null; }},
  {v:'8.95',what:'I in the Undercroft opens the raid backpack itself, not a second one',
   run:function(){
     if(!__hubEnter()) return 'could not reach the Undercroft floor';
     var P=__P();
     // Distinctive: five packed, one of two medkits on the belt, so the drawn
     // grid can only be right if the v8.78 claim rule ran inside drawBag.
     P.kit=['medkit','medkit','plate','servo','scrap'];
     P.hotAssign={7:'medkit'};
     var bad=[];
     var cm=document.getElementById('carrymodal');
     if(cm) cm.classList.remove('on');
     document.getElementById('hub').classList.remove('on');
     __hubBag(false);
     var K=__keysRef(); for(var k in K) delete K[k];
     document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyI',bubbles:true}));
     if(!__hubBag()) bad.push('I did not open the Undercroft backpack');
     // The two things he did NOT want.
     if(cm&&cm.classList.contains('on')) bad.push('the v8.84 fullscreen panel opened as well');
     if(__hubPanelOn()) bad.push('the terminal opened as well');
     // It has to be the RAID panel, so it must record the same rectangle that
     // panel records, and it must be a panel rather than the whole screen.
     __hubStep(1/60);
     // The substitute state is swapped in and out around the draw, so the test
     // is that G comes back as the SAME object, not that it is empty: the corpus
     // leaves a finished raid in there and my first version read that as a leak.
     var gBefore=__state();
     var fake=__hubBagState();
     var r=__drawBagWith(fake);
     if(__state()!==gBefore) bad.push('the shared draw did not hand the raid state back unchanged');
     if(r.threw) bad.push('the shared backpack draw threw on Undercroft data: '+r.threw);
     else if(!r.recorded||!r.recorded.panel) bad.push('the shared draw recorded no panel');
     else {
       var pn=r.recorded.panel;
       // NOT fullscreen, which is the whole of his note.
       if(pn.w>=1900||pn.h>=1000) bad.push('the Undercroft backpack is fullscreen at '+Math.round(pn.w)+'x'+Math.round(pn.h));
       if(pn.w<400||pn.h<200) bad.push('the Undercroft backpack drew as a sliver');
       // CONTROL: the belt claim rule has to be running, or this is a different
       // grid wearing the same name. Five packed, one on the belt, so four.
       if(r.recorded.cells!==4) bad.push('the grid drew '+r.recorded.cells+' cells, five packed with one on the belt should be four');
     }
     // And the key closes it again.
     document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyI',bubbles:true}));
     if(__hubBag()) bad.push('I did not close the Undercroft backpack again');
     return bad.length?bad.join('; '):null; }},
  {v:'8.96',what:'the Undercroft backpack has a belt and you can drag items onto it and off it',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, canvas rects are zero and no drag can land';
     __forceSize(1920,1080);
     if(!__hubEnter()) return 'could not reach the Undercroft floor';
     var P=__P();
     P.kit=['medkit','plate','servo','scrap','bandage'];
     P.hotAssign={};
     var K=__keysRef(); for(var k in K) delete K[k];
     __hubBag(false);
     document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyI',bubbles:true}));
     __hubStep(1/60); __hubStep(1/60);
     var L=__hubBagLive();
     if(!L) return 'the Undercroft backpack kept no state to drag with';
     var bc=L.bagCells||[], hc=L.hotCells||[];
     var bad=[];
     // v8.95 drew the panel and nothing else. The belt is what a drag needs
     // somewhere to land on, and it is his answer 22 in its own right.
     if(hc.length!==9) bad.push('the Undercroft belt drew '+hc.length+' slots, it should be 9');
     if(bc.length!==5) bad.push('the Undercroft backpack drew '+bc.length+' cells for 5 packed items');
     if(!hc.length||!bc.length) return bad.join('; ');
     var cv=document.getElementById('cv'), r=cv.getBoundingClientRect();
     function ev(t,x,y,tgt){ (tgt||cv).dispatchEvent(new MouseEvent(t,
       {button:0,bubbles:true,clientX:r.left+x,clientY:r.top+y})); }
     function drag(a,b){
       ev('mousemove',a.x+a.w/2,a.y+a.h/2);
       ev('mousedown',a.x+a.w/2,a.y+a.h/2);
       ev('mousemove',b.x+b.w/2,b.y+b.h/2);
       ev('mouseup',b.x+b.w/2,b.y+b.h/2,window);
       __hubStep(1/60);
     }
     // ONTO the belt.
     var key=bc[0].key;
     drag(bc[0],hc[7]);
     var live=__hubBagLive();
     if(!live||(live.hotAssign||{})[7]!==key)
       bad.push('dragging '+key+' onto belt slot 8 did not bind it');
     if(((__P().hotAssign||{})[7])!==key)
       bad.push('the new binding was not written to the profile');
     // And it must have LEFT the backpack, which is the v8.78 rule holding here
     // too rather than being reimplemented for this screen.
     if((live.bagCells||[]).length!==4)
       bad.push('the backpack still draws '+(live.bagCells||[]).length+' cells after one went to the belt');
     // OFF the belt again, which is his v8.72 note.
     var hc2=live.hotCells||[], bc2=live.bagCells||[];
     if(hc2.length>7&&bc2.length){
       drag(hc2[7],bc2[0]);
       var live2=__hubBagLive();
       if((live2.hotAssign||{})[7]!==undefined) bad.push('dragging off the belt did not release the slot');
       if(((__P().hotAssign||{})[7])!==undefined) bad.push('the released slot was not written to the profile');
       if((live2.bagCells||[]).length!==5) bad.push('the item did not come back into the backpack');
     }
     // CONTROL: none of this may consume the kit. Moving a thing between two
     // places he owns must never destroy it, which is the obvious way to make
     // every line above pass and lose his gear.
     if((__P().kit||[]).length!==5) bad.push('the kit lost items during the drags, it holds '+(__P().kit||[]).length);
     document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyI',bubbles:true}));
     return bad.length?bad.join('; '):null; }},
  {v:'8.97',what:'the STANDING chip keeps real clearance above the bars at every text size',
   run:function(){
     var P=__P(), keep=P.uiScale, bad=[];
     var by=1080-34;
     // These are the two numbers drawHUD uses. Written here so the check fails
     // if either the chip offset or the bar positions move without the other.
     [1.0,1.2,1.5,1.75,2.0].forEach(function(sc){
       P.uiScale=sc;
       var LH=__type.lh;
       [0,20].forEach(function(armor){
         var up=(armor>0)?(46+LH(5)):(25+LH(5));
         var chipTop=by-up-LH(17), chipBot=chipTop+LH(14);
         var nextTop=(armor>0)?(by-46):(by-25);
         var gap=nextTop-chipBot;
         // Before v8.97 this was a REMAINDER of 1 to 6 pixels and he reported it
         // twice as a collision. A gap has to be stated, not left over.
         if(gap<8) bad.push('at text '+sc+' with armour '+armor+' the chip leaves '+Math.round(gap)+'px above the bar');
         // CONTROL: it must not have been fixed by shoving the chip off the top
         // of the block it belongs to. The box is the mouse target and the thing
         // the legend pins itself above.
         if(chipTop<1080-142) bad.push('at text '+sc+' with armour '+armor+' the chip sits above its own block by '+Math.round((1080-142)-chipTop)+'px');
       });
     });
     P.uiScale=keep;
     return bad.length?bad.join('; '):null; }},
  {v:'8.98',what:'nothing in the extraction readout is drawn on top of the belt',
   run:function(){
     var bad=[];
     // He plays at 4K. Every line of this readout was placed a fixed number of
     // pixels off the bottom of the screen while the belt has sized itself to
     // the screen since v8.81. Measured before: the arrow 16px inside the belt
     // at 1080p, the banner 55 and the arrow 90 inside it at 4K.
     [[1920,1080],[2560,1440],[3840,2160]].forEach(function(SZ){
       var W2=SZ[0],H2=SZ[1],tag=W2+'x'+H2;
       __forceSize(W2,H2);
       var P=__P(); P.hud={};
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:['medkit'],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0; g.player.iv=99;
       for(var f=0;f<12;f++) __loop(performance.now()+f*16.7);
       var hc=__state().hotCells||[];
       if(!hc.length){ bad.push('at '+tag+' the belt drew no cells to measure against'); return; }
       var bt=hc[0].y, LH=__type.lh;
       // The three rows the readout uses, in the order they stack upward.
       var row=bt-LH(26), ban=bt-LH(48), prompt=bt-LH(6);
       if(row>=bt) bad.push('at '+tag+' the distance row is drawn inside the belt');
       if(ban>=bt) bad.push('at '+tag+' the extraction banner is drawn inside the belt');
       // They must also not sit on the weapon prompt line, which is its own row
       // just above the cells and was the other half of what he photographed.
       if(row>=prompt) bad.push('at '+tag+' the distance row is on the weapon prompt line');
       if(ban>=row) bad.push('at '+tag+' the banner is on the distance row');
       // CONTROL: it must not have been fixed by shoving the readout to the top
       // of the screen, which would satisfy every line above and be useless.
       if(ban<H2*0.5) bad.push('at '+tag+' the banner has been pushed into the top half of the screen');
     });
     __forceSize(1920,1080);
     return bad.length?bad.join('; '):null; }},
  {v:'8.99',what:'an unopened container shows neither its rarity nor a second bar while you search it',
   run:function(){
     __forceSize(1920,1080);
     __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(); g.ents.length=0; g.player.iv=99;
     var ct=null;
     for(var i=0;i<g.containers.length;i++) if((g.containers[i].loot||[]).length>=3){ ct=g.containers[i]; break; }
     if(!ct) return 'no container with three items to test with';
     g.player.x=ct.x; g.player.y=ct.y+10;
     __zoom.set(6,true);
     ct.prog=ct.time*0.5; ct.opened=false;
     var cv=document.getElementById('cv'); if(!cv) return 'no canvas to read';
     var c2=cv.getContext('2d');
     // __frame(0) redraws without advancing the clock, so the ONLY thing that
     // differs between two shots is what the test changed.
     function shot(){ __frame(0); return c2.getImageData(0,0,cv.width,cv.height).data; }
     function diff(a,b){ var d=0;
       for(var q=0;q<a.length;q+=4){
         if(Math.abs(a[q]-b[q])+Math.abs(a[q+1]-b[q+1])+Math.abs(a[q+2]-b[q+2])>8) d++; }
       return d; }
     if(diff(shot(),shot())!==0) return 'the renderer is not deterministic at dt 0, this check cannot measure anything';
     var bad=[];
     g.searching=null;
     ct.best='common'; var A=shot();
     ct.best='elite';  var B=shot();
     ct.best='gold';   var C=shot();
     // HIS RULE, 2026-08-26: a box must not tell you what it is worth before you
     // open it. Measured before v8.99: 2,691 pixels moved between common and
     // elite, because the progress bar took RCOL[ct.best].
     var leak=diff(A,B)+diff(B,C);
     if(leak>0) bad.push('an unopened container changes '+leak+' pixels when only the hidden rarity changes');
     // HIS NOTE: one bar while looting, not two. The cursor already carries one
     // for the container under it.
     g.searching=ct; var D=shot();
     g.searching=null; var E=shot();
     var barPx=diff(D,E);
     if(barPx<=0) bad.push('the container bar is not drawn at all, even for one he walked away from');
     // CONTROL: it must still be there for a container he LEFT part way, which
     // is the whole reason that bar exists. Deleting it would satisfy the line
     // above about two bars and lose the thing SPEC 7.4 is for.
     ct.prog=0; var F=shot();
     ct.prog=ct.time*0.5; var Gs=shot();
     if(diff(F,Gs)<=0) bad.push('control: a half searched container shows no progress at all');
     // setZoom writes to the profile, so leaving it at 6 would hand every later
     // check a camera it did not ask for. That is exactly how this check broke
     // the two visibility checks above it the first time it ran.
     __zoom.set(1,true);
     return bad.length?bad.join('; '):null; }},
  {v:'9.00',what:'a container grants exactly what it was built holding, with no windfall on top',
   run:function(){
     __zoom.set(1,true);
     __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(); g.ents.length=0; g.player.iv=99; g.sim=0;
     var bad=[];
     // Open a lot of ordinary containers and compare what came out against what
     // each was holding. A windfall appended a tenth item to the list at the
     // moment of opening, so any surplus is one.
     var opened=0, surplus=0, deep=null;
     for(var i=0;i<g.containers.length&&opened<60;i++){
       var ct=g.containers[i];
       if(ct.strong||ct.dropped||ct.mine||ct.opened) continue;
       var held=(ct.loot||[]).length;
       if(!held) continue;
       // furthest from a way out is where the old odds paid best, so hold on to
       // one for the second half of this check
       if(!deep) deep=ct;
       __openFull(ct);
       opened++;
       // The hot zone pushes two items in at open time and says so with
       // hotPaid. That is a different system and not a windfall.
       if(ct.hotPaid) continue;
       var got=(ct.loot||[]).length;
       if(got>held) surplus+=(got-held);
     }
     if(opened<10) return 'only '+opened+' ordinary containers to open, that is too few to say anything';
     if(surplus>0) bad.push(opened+' containers granted '+surplus+' items more than they held');
     // His recorder has carried a windfalls count in every run he has exported.
     // It was always created lazily by the roll and written out as
     // (T.windfalls||0), so the question is what the EXPORT says, not whether
     // the field exists on the object.
     var T=g.tel;
     if((T.windfalls||0)!==0) bad.push('the recorder counted '+T.windfalls+' windfalls');
     // CONTROL: the containers must still be GIVING things, or a fix of "grant
     // nothing" would satisfy every line above.
     var bagN=(g.bag||[]).length;
     if(bagN<5) bad.push('control: '+opened+' containers put only '+bagN+' items in the bag');
     return bad.length?bad.join('; '):null; }},
  {v:'9.01',what:'a gun never wears out and never jams, however many rounds go through it',
   run:function(){
     var bad=[];
     var T=__guns.tiers();
     var worn=[];
     for(var k in T) if(__wear.wearable(k)) worn.push(k);
     // Before v9.01 the SMG at 1,600 rounds shot 0.1725 against a clean 0.115,
     // and reloaded in 2590ms against 1850. Two guns wore; nothing else did.
     for(var i=0;i<worn.length;i++){
       var id=worn[i];
       var a=__wear.at(id,0), b=__wear.at(id,4000);
       if(a.spread!==b.spread) bad.push(id+' spread changes with use, '+a.spread+' to '+b.spread);
       if(a.reload!==b.reload) bad.push(id+' reload changes with use, '+a.reload+' to '+b.reload);
       if(b.band!=='CLEAN') bad.push(id+' reaches band '+b.band+' after 4,000 rounds');
       if(b.jam) bad.push(id+' can jam, jam='+b.jam);
     }
     // The whole table, so a second row cannot creep back in without failing here.
     var steps=__wear.steps();
     if(steps.length!==1) bad.push('the wear table has '+steps.length+' bands, it should have one');
     steps.forEach(function(w){
       if(w.spread!==1) bad.push('band '+w.name+' still multiplies spread by '+w.spread);
       if(w.reload!==1) bad.push('band '+w.name+' still multiplies reload by '+w.reload);
       if(w.jam) bad.push('band '+w.name+' can jam');
     });
     // CONTROL: the gun must still HAVE its stats. Zeroing the table by making
     // every gun spreadless would satisfy every line above and be a worse game.
     if(worn.length){
       var c=__wear.at(worn[0],0);
       if(!(c.spread>0)) bad.push('control: the gun has no spread at all, '+c.spread);
       if(!(c.reload>0)) bad.push('control: the gun has no reload time at all, '+c.reload);
       if(c.spread!==c.baseSpread) bad.push('control: a clean gun no longer matches its own table entry');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'9.02',what:'a found gun is just the gun: no hidden condition roll changing its strength',
   run:function(){
     __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
     var bad=[];
     var T=__guns.tiers();
     // Before v9.02, 400 Auto Rifles came back as five weapons doing 20.2, 23.0,
     // 25.3, 28.5 and 33.4 damage under five names. One gun, five strengths.
     for(var k in T){
       var base=__guns.base(k); if(!base) continue;
       var dmgs={}, names={}, qs={};
       for(var i=0;i<120;i++){
         var g=__guns.roll(k);
         dmgs[g.dmg]=1; names[g.name]=1; qs[g.q]=1;
       }
       var nd=Object.keys(dmgs).length, nn=Object.keys(names).length;
       if(nd!==1) bad.push(base.name+' can be found at '+nd+' different damages: '+Object.keys(dmgs).join(', '));
       if(nn!==1) bad.push(base.name+' can be found under '+nn+' different names: '+Object.keys(names).join(', '));
       if(Object.keys(names)[0]!==base.name) bad.push(base.name+' is found as "'+Object.keys(names)[0]+'"');
       // and it must be the BASE weapon, not some other flat number
       var one=__guns.roll(k);
       if(one.dmg!==base.dmg) bad.push(base.name+' rolls '+one.dmg+' damage against a base of '+base.dmg);
       if(one.spread!==base.spread) bad.push(base.name+' rolls '+one.spread+' spread against a base of '+base.spread);
       if(one.mag!==base.mag) bad.push(base.name+' rolls a magazine of '+one.mag+' against '+base.mag);
       if((one.tint||null)!==(base.tint||null))
         bad.push(base.name+' rolls a paint its own table entry does not have: '+one.tint);
     }
     // CONTROL: guns must still DIFFER from each other, or removing the second
     // strength axis would have flattened the first one too, which is the whole
     // thing he said should decide how good a gun is.
     var dmgSet={};
     for(var k2 in T){ var b2=__guns.base(k2); if(b2) dmgSet[b2.dmg]=1; }
     if(Object.keys(dmgSet).length<4) bad.push('control: only '+Object.keys(dmgSet).length+' distinct gun damages left in the whole table');
     return bad.length?bad.join('; '):null; }},
  {v:'9.03',what:'spending the last of a belted item leaves the slot dark and empty, never a different item',
   run:function(){
     __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
     var bad=[], g=__state();
     // Distinctive on purpose: the derived bar would put a THROWABLE on these
     // slots, so if the fix is absent the slot does not read "empty", it reads
     // Frag Charge. Two different items so one lucky match cannot pass this.
     g.bag=["medkit","medkit","bandage","frag","frag","frag"];
     g.hotAssign={4:"medkit",5:"bandage"};
     g.hotAuto=null;
     var before=__belt.slots();
     if(!before[4]||before[4].itemKey!=="medkit") bad.push("setup: slot 5 did not take the medkit binding");
     if(!before[5]||before[5].itemKey!=="bandage") bad.push("setup: slot 6 did not take the bandage binding");
     var c4=before[4]&&before[4].count, c5=before[5]&&before[5].count;
     if(c4!==2) bad.push("setup: slot 5 counted "+c4+" medkits, not 2");
     // Now spend every one of both, which is the thing he described.
     g.bag=["frag","frag","frag"];
     var after=__belt.slots();
     var a4=after[4]||{}, a5=after[5]||{};
     // HIS ANSWER 16: still the item he put there, and it says none left.
     if(a4.itemKey!=="medkit") bad.push("slot 5 stopped being the medkit and became "+(a4.name||"nothing"));
     if(a5.itemKey!=="bandage") bad.push("slot 6 stopped being the bandage and became "+(a5.name||"nothing"));
     if(a4.count!==0) bad.push("an emptied slot 5 reads a count of "+a4.count+" rather than none");
     if(!a4.empty) bad.push("an emptied slot 5 is not flagged empty, so the belt will not grey it");
     if(a5.empty!==1) bad.push("an emptied slot 6 is not flagged empty");
     // and it comes back to life on its own when he picks another one up
     g.bag=["frag","medkit"];
     var back=__belt.slots()[4]||{};
     if(back.count!==1||back.empty) bad.push("picking a medkit back up left slot 5 reading "+back.count+" empty="+back.empty);
     // CONTROL 1, and it is the one that matters: a slot he never bound must
     // STILL derive normally. Without this, a fix of "never re-derive anything"
     // would pass every assertion above and break the whole bar.
     g.hotAssign={};
     var derived=__belt.slots();
     var live=0;
     for(var i=0;i<derived.length;i++) if(derived[i]&&derived[i].kind!=="empty") live++;
     if(live<1) bad.push("control: with nothing bound the bar derived "+live+" live slots, so the derived path is dead");
     // CONTROL 2: a gun binding for a gun he is NOT carrying must still fall
     // away, which is the one case that keeps the old behaviour on purpose.
     // He keeps his fists here: the derived bar reads p.wep every frame, so
     // emptying his hands throws instead of measuring anything.
     var held={};
     if(g.player.wep&&g.player.wep.id) held[g.player.wep.id]=1;
     if(g.player.sec&&g.player.sec.id) held[g.player.sec.id]=1;
     var absent=null, TT=__guns.tiers();
     for(var gk in TT) if(!held[gk]){ absent=gk; break; }
     if(!absent) bad.push("control: could not find a gun he is not carrying");
     else {
       g.bag=[]; g.hotAssign={}; g.hotAssign[3]=absent;
       var gone=__belt.slots()[3]||{};
       if(gone.itemKey===absent) bad.push("control: a "+absent+" he is not carrying held its belt slot");
     }
     return bad.length?bad.join("; "):null; }},
  {v:'9.03',what:'an emptied belt slot is actually drawn darker, not just marked empty',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, the HUD canvas has no pixels to read';
     __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __zoom.set(1,true);
     __deploy({kit:['medkit','medkit'],safe:null,mapIx:0,seed:4242});
     var g=__state(); g.ents.length=0; g.player.iv=99;
     g.hotAssign={4:'medkit'}; g.hotAuto=null;
     function run(n){ for(var f=0;f<6;f++) __loop(performance.now()+n+f*16.7); }
     g.bag=['medkit','medkit']; run(0);
     var b=__hud().belt;
     if(!b) return 'the belt did not draw, so there is nothing to measure';
     // The HUD draws to hcv. Sampling the world canvas returns the same number
     // whatever the belt does, which is a check that can never fail.
     var cv=document.getElementById('hcv');
     if(!cv) return 'no HUD canvas to read';
     function cell(ix){
       var bb=__hud().belt;
       var x=Math.round(bb.x+bb.cellW*ix)+4, y=Math.round(bb.y)+4, w=Math.max(4,Math.round(bb.cellW)-8);
       var d=cv.getContext('2d').getImageData(x,y,w,w).data, s=0;
       for(var i=0;i<d.length;i+=4) s+=(d[i]+d[i+1]+d[i+2])/3;
       return s/(d.length/4);
     }
     var stocked=cell(4);
     g.bag=[]; run(900);
     var emptied=cell(4);
     var bad=[];
     if(!(stocked>0)) bad.push('the stocked slot measured '+stocked.toFixed(1)+', so nothing is being drawn there');
     // The cell is drawn at 28 percent alpha when its count is zero. Anything
     // near 1.0 means it is not dimming at all, which was the state he described.
     else if(emptied/stocked>0.75) bad.push('an emptied slot is drawn at '+Math.round(emptied/stocked*100)+' percent of a stocked one, so it does not read as darker');
     // CONTROL: picking one back up must bring the brightness back. Without this
     // a belt that drew every slot dark would pass the assertion above.
     g.bag=['medkit']; run(1800);
     var back=cell(4);
     if(stocked>0&&back/stocked<0.75) bad.push('control: restocking left the slot at '+Math.round(back/stocked*100)+' percent, so the slot is dark whatever he carries');
     return bad.length?bad.join('; '):null; }},
  {v:'9.04',what:'criers keep to the street and are not found standing inside houses',
   run:function(){
     __resetCfg(); __pinDefaults(0);
     var bad=[];
     function inB(m,x,y){ var B=m.buildings||[];
       for(var i=0;i<B.length;i++){ var b=B[i]; if(x>=b.x&&x<=b.x+b.w&&y>=b.y&&y<=b.y+b.h) return true; }
       return false; }
     [0,1].forEach(function(mi){
       __startRaid({mapIx:mi,seed:4242});
       var g=__state(), m=g.map;
       var sn=[], cr=[];
       for(var i=0;i<g.ents.length;i++){
         if(g.ents[i].kind==='snitch') sn.push(g.ents[i]);
         else if(g.ents[i].kind==='crawler') cr.push(g.ents[i]);
       }
       if(!sn.length){ bad.push('map '+mi+' has no criers to measure'); return; }
       // Nobody is being chased: the player is parked off the map, so every
       // sample below is a crier on patrol with nothing to answer.
       var spawnIn=0;
       for(var s=0;s<sn.length;s++) if(inB(m,sn[s].x,sn[s].y)) spawnIn++;
       if(spawnIn) bad.push('map '+mi+': '+spawnIn+' criers spawned inside a house');
       g.player.x=-99999; g.player.y=-99999;
       var samp=0,ins=0,csamp=0,cins=0;
       for(var f=0;f<900;f++){ __rawStep(1/60);
         if(f%10) continue;
         for(var a=0;a<sn.length;a++) if(sn[a].state==='patrol'){ samp++; if(inB(m,sn[a].x,sn[a].y)) ins++; }
         for(var b2=0;b2<cr.length;b2++) if(cr[b2].state==='patrol'){ csamp++; if(inB(m,cr[b2].x,cr[b2].y)) cins++; }
       }
       var pct=ins/Math.max(1,samp)*100;
       // Measured before the fix: 46.3 percent on COLD STORAGE and 24.7 on THE
       // COLD MILE, with two criers indoors for the whole run.
       if(pct>6) bad.push('map '+mi+': a patrolling crier is inside a house '+pct.toFixed(1)+' percent of the time');
       // CONTROL, and it is the one that matters. His v8.86 rule is that every
       // house should be a gamble because there is likely a crawler in it. A fix
       // that emptied the houses, or that simply stopped every machine walking
       // indoors, would pass the line above and wreck the thing he asked for.
       if(cr.length){
         var cpct=cins/Math.max(1,csamp)*100;
         if(cpct<25) bad.push('control: map '+mi+' crawlers are only indoors '+cpct.toFixed(1)+' percent of the time, the houses have been emptied');
       }
     });
     return bad.length?bad.join('; '):null; }},
  {v:'9.05',what:'COLD STORAGE drops you in one of about ten places, not one of four',
   run:function(){
     __resetCfg(); __pinDefaults(0);
     var bad=[], counts={}, pool=0, relocated=0, N=30, D0=false;
     for(var i=0;i<N;i++){
       __startRaid({mapIx:0,seed:11000+i*97});
       var g=__state(), D=g.spawnDbg;
       // WHERE HE LANDS is the measurement, and it works on any build. The
       // diagnostic is used only for the two things it alone can see.
       var at=Math.round(g.player.x)+','+Math.round(g.player.y);
       if(D){
         D0=true; pool=D.pool;
         // Every authored start must be legal ground. If the guard had to
         // relocate one, the point was written down badly and he starts
         // somewhere nobody chose.
         if(at!==(D.pt.x+','+D.pt.y)) relocated++;
       }
       counts[at]=(counts[at]||0)+1;
     }
     var keys=Object.keys(counts), top=0;
     for(var k in counts) if(counts[k]>top) top=counts[k];
     // HIS ANSWER 44. Before this the pool was four and he said so three times.
     if(D0&&pool<8) bad.push('the eligible pool is '+pool+' starts, he asked for about ten');
     if(keys.length<7) bad.push('only '+keys.length+' different starts came up in '+N+' raids');
     if(top/N>0.35) bad.push('one start took '+Math.round(top/N*100)+' percent of '+N+' raids');
     if(relocated) bad.push(relocated+' of '+N+' starts had to be relocated, so an authored spawn is not on clear ground');
     // CONTROL 1: his run #37 rule. Spawns must not creep towards the exits.
     // Scattering starts anywhere would satisfy every line above and quietly
     // hand him a raid that begins next to the way out.
     var g2=__state(), m=g2.map, worst=1e9, worstAt=null;
     for(var s=0;s<m.spawns.length;s++){
       var q=m.spawns[s], d=1e9;
       for(var e=0;e<m.extracts.length;e++) d=Math.min(d,Math.hypot(m.extracts[e].x-q.x,m.extracts[e].y-q.y));
       // only the ones that can actually be chosen: two authored spawns sit
       // close to an exit on purpose and the pool has always excluded them.
       if(d>=900&&d<worst){ worst=d; worstAt=Math.round(q.x)+','+Math.round(q.y); }
     }
     if(worst<900) bad.push('control: an eligible start sits '+Math.round(worst)+' from an extract at '+worstAt);
     // CONTROL 2: the pool floor is shared, so the other map must be unmoved.
     __resetCfg(); __pinDefaults(1);
     __startRaid({mapIx:1,seed:4242});
     var D2=__state().spawnDbg;
     if(!D2||D2.pool<12) bad.push('control: THE COLD MILE pool is '+(D2?D2.pool:'unknown')+', it should still be all 12');
     return bad.length?bad.join('; '):null; }},
  {v:'9.06',what:'a contract names a place he is told about, never a colour scheme',
   run:function(){
     __resetCfg(); __pinDefaults(0);
     var bad=[];
     // The four words in DISTRICTS are PALETTES. They set what colour a building
     // is painted and are shown to him nowhere. "Greenbelt" is one of them, and
     // he asked what it was.
     var PAL={}, DL=__con.districts();
     for(var i=0;i<DL.length;i++) PAL[String(DL[i].name).toUpperCase()]=i;
     // THE CONTRACT TEXT FIRST, because that is what he reads and every build
     // writes it. Asking a helper that only the fixed build has would make this
     // check pass or throw rather than measure.
     __P().mapIx=0;
     var seen=0, badDesc=[];
     for(var t=0;t<60;t++){
       var c=__con.gen();
       if(!c||c.type!=='district'||!c.desc) continue;
       seen++;
       var m=/ in (.+)$/.exec(c.desc);
       if(!m){ badDesc.push('a district contract with no place: '+c.desc); continue; }
       var pl=m[1].toUpperCase().split(' OR ');
       for(var pq=0;pq<pl.length;pq++)
         if(PAL[pl[pq]]!==undefined) badDesc.push(c.desc);
     }
     if(!seen) bad.push('no district contract was generated in 60 rolls, so this proved nothing');
     if(badDesc.length) bad.push(badDesc.length+' of '+seen+' district contracts still name a palette, e.g. "'+badDesc[0]+'"');
     // CONTROL 1: it must still SAY a place. A fix that stripped the location
     // would pass every line above and leave him an errand with no destination,
     // which is exactly what v7.54 did and v8.38 had to undo.
     var withPlace=0;
     for(var t2=0;t2<60;t2++){
       var c2=__con.gen();
       if(c2&&c2.type==='district'&&c2.desc&&/ in \S/.test(c2.desc)) withPlace++;
     }
     if(!withPlace) bad.push('control: no district contract names a place at all any more');
     // CONTROL 2: the palette table must still exist and still have four entries.
     // The colours are not the problem and deleting them would be a large change
     // wearing this one's clothes.
     if(DL.length!==4) bad.push('control: the district palette table has '+DL.length+' entries, it should still have 4');
     // And, only where the build offers it, the same rule stated per district on
     // both maps: whatever a district is called must be one of that map's zones.
     if(__con.place&&__con.zones){
       [0,1].forEach(function(mi){
         __P().mapIx=mi;
         var Z=__con.zones(mi), names={};
         for(var z=0;z<Z.length;z++) names[String(Z[z].name).toUpperCase()]=1;
         for(var d=0;d<DL.length;d++){
           var got;
           try{ got=String(__con.place(d)).toUpperCase(); }catch(_e){ return; }
           var parts=got.split(' OR ');
           for(var q=0;q<parts.length;q++){
             var one=parts[q].replace(/^\s+|\s+$/g,'');
             if(!names[one])
               bad.push('map '+mi+' district '+d+' is described as "'+one+'", which is not a zone on that map');
           }
         }
       });
       __P().mapIx=0;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'9.07',what:'a noise you cannot see leaves a ring on the ground, and one you can see does not',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to compare';
     __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __zoom.set(1,true);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player; g.ents.length=0; p.iv=99;
     // PINNED, not inherited. Face north, so due south of him is outside the
     // cone and is heard rather than seen whatever an earlier check left behind.
     p.face=Math.PI/2;
     for(var f=0;f<6;f++) __loop(performance.now()+f*16.7);
     p.face=Math.PI/2;
     if(!__noise) return 'this build has no noise rings at all';
     var cv=document.getElementById('cv');
     if(!cv) return 'no world canvas to read';
     function snap(){ __frame(0); return cv.getContext('2d').getImageData(0,0,1920,1080).data; }
     function diff(a,b){ var n=0; for(var i=0;i<a.length;i+=4) if(a[i]!==b[i]||a[i+1]!==b[i+1]||a[i+2]!==b[i+2]) n++; return n; }
     var bad=[];
     __noise.clear();
     var base=snap(), ctrl=snap();
     // A renderer that is not still makes every number below meaningless, so it
     // is proved still first.
     if(diff(base,ctrl)!==0) return 'two identical redraws differ, so no pixel measurement here means anything';
     // He faces north out of __deploy, so a point south of him is outside the
     // cone: heard, not seen. Measured before v9.07: 0 pixels, always.
     var NX=p.x, NY=p.y-260;
     __audio.sfx('shot', NX, NY, 'rifle');
     var heard=__noise.list().length, heardPix=diff(base,snap());
     if(heard<1) bad.push('a gunshot he cannot see left no ring');
     // A ring drawn outside the camera changes no pixels for an honest reason,
     // and reading that as "not drawn" is how this check lied to me twice.
     var _cm=__cam?__cam():null;
     if(_cm&&(NX<_cm.x||NX>_cm.x+1920||NY<_cm.y||NY>_cm.y+1080))
       return 'SKIP: the noise landed outside the camera at '+Math.round(NX)+','+Math.round(NY)+', so pixels prove nothing';
     if(heardPix<20) bad.push('the ring changed only '+heardPix+' pixels, so nothing was actually drawn');
     // CONTROL 1, and it is the whole point of the feature: a noise he can SEE
     // must not draw anything. Without this, "always draw a ring" passes above
     // and litters the screen with circles on things standing in front of him.
     __noise.clear();
     var b2=snap();
     __audio.sfx('shot', p.x+8, p.y+40, 'rifle');
     var seen=__noise.list().length, seenPix=diff(b2,snap());
     if(seen!==0) bad.push('a gunshot in plain sight drew '+seen+' rings');
     if(seenPix!==0) bad.push('a gunshot in plain sight changed '+seenPix+' pixels');
     // CONTROL 2: it must expire. A marker that never dies is a permanent red
     // circle on the map and would still pass every line above.
     __noise.clear();
     __audio.sfx('boom', NX, NY);
     var t0=performance.now();
     for(var f2=0;f2<80;f2++) __loop(t0+f2*16.7);
     if(__noise.list().length!==0) bad.push('the ring never expired, '+__noise.list().length+' still live after 80 frames');
     // CONTROL 3: it must not be able to fill the screen.
     __noise.clear();
     for(var q=0;q<60;q++) __audio.sfx('shot', NX+q, NY, 'rifle');
     if(__noise.list().length>22) bad.push('the ring list is uncapped, '+__noise.list().length+' live after 60 noises');
     __noise.clear();
     return bad.length?bad.join('; '):null; }},
  {v:'9.08',what:'the downed screen does not flash at you and grows with the monitor',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to compare';
     var bad=[];
     var hc=document.getElementById('hcv');
     if(!hc) return 'no HUD canvas to read';
     // Puts him on the floor next to an open ring with a ship inbound, which is
     // the state that draws CRAWL TO THE RING.
     function setup(W2,H2,down){
       __forceSize(W2,H2); __resetCfg(); __pinDefaults(0); __zoom.set(1,true);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player; g.ents.length=0;
       p.downed=down?1:0; p.downT=12; p.revived=1; p.iv=99;
       var z=g.zones&&g.zones[0];
       if(!z) return null;
       g.active=z; z.open=true; p.x=z.x+z.r+120; p.y=z.y; g.beaconT=20;
       for(var f=0;f<4;f++) __loop(performance.now()+f*16.7);
       return g;
     }
     function boxMean(x,y,w,h){ __frame(0);
       var d=hc.getContext('2d').getImageData(x,y,w,h).data,s=0;
       for(var i=0;i<d.length;i+=4) s+=(d[i]+d[i+1]+d[i+2])/3*(d[i+3]/255);
       return s/(d.length/4); }
     // How much a box swings as ONLY the raid clock moves, which is what drives
     // the pulse. Measured on the message box and nothing else.
     // TIGHT ON THE MESSAGE. A generous box drowns the pulse in static pixels:
     // the first version of this used a 720x90 box and read a real 21 percent
     // swing as 2, so it passed the build it was written to catch.
     function swing(g,y0,h0){
       var t=g.timeLeft, vals=[];
       for(var k=0;k<12;k++){ g.timeLeft=t+k*0.15; vals.push(boxMean(700,y0,520,h0)); }
       g.timeLeft=t;
       var mn=Math.min.apply(null,vals), mx=Math.max.apply(null,vals);
       return {mn:mn,mx:mx,pct:mx>0.01?((mx-mn)/mx*100):0};
     }
     var gd=setup(1920,1080,true);
     if(!gd) return 'no extraction zone to stand next to';
     // The measurement is only worth anything if a fixed clock is stable.
     gd.beaconT=20;
     var s1=boxMean(700,570,520,60), s2=boxMean(700,570,520,60);
     if(Math.abs(s1-s2)>0.01) return 'the same clock draws two different boxes, so no brightness reading here means anything';
     // It has to actually be drawing the message, or a blank box passes as calm.
     if(s1<3) bad.push('the downed message box is nearly empty at '+s1.toFixed(2)+', nothing is being drawn there');
     var dn=swing(gd,570,60);
     // Measured before v9.08: 21.1 percent, cycling every 1.2 seconds, while he
     // is bleeding to death.
     if(dn.pct>3) bad.push('the downed message still pulses, '+dn.pct.toFixed(1)+' percent brightness swing');
     // CONTROL 1: STANDING, the pulse must survive. Deleting it everywhere would
     // pass the line above and quietly kill a prompt that exists because a static
     // line on a calm screen stops being read.
     var gs=setup(1920,1080,false);
     if(gs){
       var g2=__state(), p2=g2.player, z2=g2.active;
       p2.x=z2.x; p2.y=z2.y;                       // inside the ring: HOLD E TO EXTRACT
       for(var f2=0;f2<4;f2++) __loop(performance.now()+f2*16.7);
       // AFTER the frames, not before. __loop runs the beacon itself and puts
       // beaconT back, so setting it first drew no prompt at all and the control
       // reported "not drawing" against a build where it draws fine.
       g2.shipHold=8; g2.beaconT=0;
       var up=swing(g2,375,55);
       if(up.mx<3) bad.push('control: the standing prompt is not drawing at all, so its pulse cannot be judged');
       else if(up.pct<3) bad.push('control: the standing prompt stopped pulsing too, swing '+up.pct.toFixed(1)+' percent');
     }
     // AND THE SIZE. The bleed bar is the easiest thing to measure: scan the row
     // it sits on and count how wide the lit run is.
     function barWidth(W2,H2){
       var g3=setup(W2,H2,true); if(!g3) return 0;
       __frame(0);
       var sc=(W2>=3840?2:1);
       var y=Math.round(H2/2-18*sc);
       var d=hc.getContext('2d').getImageData(0,y,W2,1).data;
       var first=-1,last=-1;
       for(var x=0;x<W2;x++){ var i=x*4, lum=(d[i]+d[i+1]+d[i+2])/3*(d[i+3]/255);
         if(lum>28){ if(first<0) first=x; last=x; } }
       return first<0?0:(last-first+1);
     }
     var b1=barWidth(1920,1080), b4=barWidth(3840,2160);
     __forceSize(1920,1080);
     if(!b1) bad.push('the bleed-out bar did not draw at 1080p');
     else if(b4/b1<1.7) bad.push('the downed screen barely grows on a bigger monitor: bar '+b1+'px at 1080p and '+b4+'px at 4K');
     // CONTROL 2: and it must NOT have grown at 1080p, which is where he already
     // had a working layout. hudRes is 1 there, so the block is the size it was.
     if(b1>340) bad.push('control: the bleed bar is '+b1+'px at 1080p, the block has been inflated where it was already right');
     return bad.length?bad.join('; '):null; }},
  {v:'9.09',what:'the pointer says what a panel edge does: move, resize or minimise',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to compare';
     __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __zoom.set(1,true);
     __deploy({kit:['medkit','plate'],safe:null,mapIx:0,seed:4242});
     // OWN PRECONDITIONS. An earlier check can leave a panel collapsed or resized
     // on the profile, and a collapsed panel has no resize corner at all, which
     // reads exactly like the defect this is looking for.
     __P().hud={};
     var g=__state(); g.ents.length=0; g.player.iv=99;
     for(var f=0;f<6;f++) __loop(performance.now()+f*16.7);
     var hc=document.getElementById('hcv'); if(!hc) return 'no HUD canvas to read';
     var m=__mouse(), H=__hud(), B=H.box&&H.box.body;
     if(!B) return 'the vitals panel did not draw, so there is no panel to point at';
     var bad=[];
     // WHICH PIXELS THE POINTER ITSELF PUTS DOWN: the same region rendered with
     // the pointer parked far away, then with it here. Reading the drawn cursor
     // rather than the code that chose it.
     function sig(px,py){
       m.x=960; m.y=300; __frame(0);
       var far=hc.getContext('2d').getImageData(px-30,py-30,60,60).data;
       m.x=px; m.y=py; __frame(0);
       var here=hc.getContext('2d').getImageData(px-30,py-30,60,60).data;
       var stem=0,total=0,key=[];
       for(var y=0;y<60;y++) for(var x=0;x<60;x++){
         var i=(y*60+x)*4;
         if(far[i]!==here[i]||far[i+1]!==here[i+1]||far[i+2]!==here[i+2]||far[i+3]!==here[i+3]){
           total++;
           if(x>=26&&x<=34&&y>=4&&y<=24) stem++;   // the reticle's top arm
           if(key.length<400) key.push(x+':'+y);
         }
       }
       return {n:total, stem:stem, k:key.join(',')};
     }
     var world=sig(1400,400);
     var body =sig(Math.round(B.x+B.w/2), Math.round(B.y+B.h/2));
     var bar  =sig(Math.round(B.x+50),    Math.round(B.y+8));
     var glyph=sig(Math.round(B.right-12),Math.round(B.y+8));
     var grip =sig(Math.round(B.x+B.w-8), Math.round(B.y+B.h-8));
     if(!world.n) return 'nothing is drawn at the pointer at all, so this cannot be measured';
     // HIS ANSWER 38. Measured before v9.09: bar and glyph drew byte-identical
     // arrows, and the grip drew the aiming reticle.
     if(bar.k===glyph.k) bad.push('the drag bar and the minimise glyph still draw the same pointer');
     if(grip.n>=world.n*0.8) bad.push('the resize corner still draws the aiming reticle, footprint '+grip.n+' against '+world.n+' on open ground');
     if(grip.k===bar.k) bad.push('the resize corner and the drag bar draw the same pointer');
     if(grip.k===body.k) bad.push('the resize corner draws whatever the panel body draws');
     // CONTROL 1: the reticle must SURVIVE where it belongs. Replacing the
     // pointer everywhere would satisfy every line above and take his aiming
     // cross away in a firefight.
     if(!body.stem) bad.push('control: the panel body no longer draws the aiming reticle');
     if(!world.stem) bad.push('control: open ground no longer draws the aiming reticle');
     // Same SHAPE, not the same pixels: the reticle drawn over a lit panel
     // antialiases against a different background, so a strict pixel comparison
     // fails on every build including the fixed one.
     if(Math.abs(body.n-world.n)>world.n*0.25)
       bad.push('control: the pointer over a panel body is a different size from the one on open ground, '+body.n+' against '+world.n);
     // CONTROL 2, and it is the one that keeps this honest: the pointer must
     // agree with what a click there actually does. A resize pointer over a spot
     // that starts a DRAG is a worse lie than the reticle was.
     if(H.hitAt){
       var pg=H.hitAt(Math.round(B.x+B.w-8), Math.round(B.y+B.h-8));
       if(pg!=='grip') bad.push('control: the corner the resize pointer is drawn on hit-tests as "'+pg+'"');
       var pb=H.hitAt(Math.round(B.x+50), Math.round(B.y+8));
       if(pb!=='bar'&&pb!=='glyph') bad.push('control: the drag bar hit-tests as "'+pb+'"');
     }
     m.x=960; m.y=300;
     return bad.length?bad.join('; '):null; }},
  {v:'9.10',what:'picking a downed pillager up pays you out of his own kit, once',
   run:function(){
     var bad=[];
     // Puts a pillager on the floor at his feet and holds E, which is the play
     // path: the same key, the same lock, the same medical cost.
     function downOne(){
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:['medkit','medkit'],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player; p.iv=99;
       var rd=null;
       for(var i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].merc){ rd=g.ents[i]; break; }
       if(!rd) return null;
       rd.downed=1; rd.downT=30; rd.hp=1; rd.state='down'; rd.x=p.x+20; rd.y=p.y;
       return {g:g,p:p,rd:rd};
     }
     function bodyAfterKill(S){
       var K=__keysRef(); for(var k in K) delete K[k];
       S.rd.hp=0; S.rd.downed=0; S.rd.finished=1; S.rd.byPlayer=true;
       for(var f=0;f<6;f++) __loop(performance.now()+400+f*16.7);
       for(var c=S.g.containers.length-1;c>=0;c--)
         if(S.g.containers[c].type==='body') return (S.g.containers[c].loot||[]).slice();
       return null;
     }
     var A=downOne();
     if(!A) return 'no pillager on the map to put down';
     var hisBefore=(A.rd.bag||[]).slice(), yourBefore=A.g.bag.slice();
     var K=__keysRef(); for(var k in K) delete K[k];
     A.g.revLock=0; K['KeyE']=true;
     for(var f=0;f<10;f++) __loop(performance.now()+f*16.7);
     for(var k2 in K) delete K[k2];
     if(A.rd.downed) return 'the revive itself did not happen, so the payout cannot be judged';
     // HIS ANSWER 37. Measured before v9.10: your bag went medkit,medkit ->
     // medkit and his bag did not change at all.
     var gained=[], after=A.g.bag.slice(), tmp=yourBefore.slice();
     for(var q=0;q<after.length;q++){ var ix=tmp.indexOf(after[q]); if(ix<0) gained.push(after[q]); else tmp.splice(ix,1); }
     if(!gained.length) bad.push('reviving him paid nothing at all');
     else {
       var got=gained[0];
       // It has to be a gun or something worth carrying, which is his sentence.
       if(String(got).indexOf('gun_')!==0&&__con&&typeof ival==='undefined'){ /* value checked below */ }
       if(hisBefore.indexOf(got)<0&&String(got).indexOf('gun_')!==0)
         bad.push('he paid "'+got+'", which was never in his kit');
       // and it has to LEAVE him, or it is conjured rather than handed over
       var stillHas=((A.rd.bag||[]).indexOf(got)>=0);
       if(stillHas&&hisBefore.indexOf(got)>=0) bad.push('he handed over '+got+' and still has one');
     }
     // The cost must remain. A payout with no price is not the trade he described.
     var spent=false;
     for(var s=0;s<yourBefore.length;s++){
       if(yourBefore[s]==='medkit'){
         var cA=0,cB=0;
         for(var a1=0;a1<yourBefore.length;a1++) if(yourBefore[a1]==='medkit') cA++;
         for(var b1=0;b1<after.length;b1++) if(after[b1]==='medkit') cB++;
         spent=(cB<cA); break;
       }
     }
     if(!spent) bad.push('the revive no longer costs a medical item');
     // CONTROL 1: THE OBVIOUS FARM. Revive him for his gun, then shoot him, and
     // the body must not carry the same gun a second time.
     var loot1=bodyAfterKill(A);
     if(loot1===null) bad.push('control: killing him after the revive left no body to search');
     else {
       var dupe=0;
       for(var d=0;d<loot1.length;d++) if(String(loot1[d]).indexOf('gun_')===0) dupe++;
       if(dupe&&gained.length&&String(gained[0]).indexOf('gun_')===0&&loot1.indexOf(gained[0])>=0)
         bad.push('the body paid the same gun again: revive then kill is worth two weapons');
     }
     // CONTROL 2, and it is the one that stops a lazy fix: a pillager you did NOT
     // revive must STILL drop his gun. Stamping every body as paid would satisfy
     // control 1 and quietly delete the most common payout in the game.
     var B=downOne();
     if(!B) bad.push('control: could not stage a second pillager');
     else {
       var loot2=bodyAfterKill(B);
       if(loot2===null) bad.push('control: an unrevived pillager left no body at all');
       else {
         var hasGun=false;
         for(var d2=0;d2<loot2.length;d2++) if(String(loot2[d2]).indexOf('gun_')===0) hasGun=true;
         if(!hasGun) bad.push('control: a pillager nobody revived no longer drops his gun');
       }
     }
     return bad.length?bad.join('; '):null; }},
  {v:'9.11',what:'Wirt keeps one good thing on the counter at a flat 10,000 that changes every hour',
   run:function(){
     var bad=[], HR=3600000, base=Date.now();
     // HIS ANSWER 48, MEASURED THE WAY HE WOULD SEE IT FIRST: open the stall and
     // read the buttons. Before v9.11 there were exactly two, Gamble and Leave,
     // and the panel never mentioned an hour or a price other than the pull.
     if(__vpAlive()){
       __hubEnter();
       try{ if(window.__wirt&&__wirt.render) __wirt.render(); }catch(_r){}
       var _m=document.getElementById('gamblemodal');
       if(_m){
         var _txt=_m.textContent.replace(/\s+/g,' ');
         var _buys=0, _bl=_m.querySelectorAll('button');
         for(var _b=0;_b<_bl.length;_b++) if(/10,?000/.test(_bl[_b].textContent)) _buys++;
         if(!_buys) bad.push('Wirt has nothing on the counter: no 10,000 offer among his '+_bl.length+' buttons');
         if(!/hour/i.test(_txt)) bad.push('the stall never says the lot changes by the hour');
       }
     }
     // Everything below needs the build to actually have the counter behind it.
     var _live=false;
     try{ _live=(window.__wirt&&__wirt.price()>0); }catch(_e){ _live=false; }
     if(!_live) return bad.length?bad.join('; '):'this build has no counter at Wirt at all';
     if(__wirt.price()!==10000) bad.push('the lot costs '+__wirt.price()+', he said 10k');
     var pool=__wirt.pool();
     if(pool.length<4) bad.push('the counter draws from only '+pool.length+' things');
     // IT MUST BE WORTH WALKING DOWN FOR. A 10,000 counter stocked with scrap is
     // the letter of his answer and none of the point.
     for(var q=0;q<pool.length;q++){
       var r=__wirt.rar(pool[q]);
       if(r!=='elite'&&r!=='rare') bad.push('the counter can stock '+pool[q]+', which is '+r);
     }
     // IT CHANGES BY THE HOUR, walked forward rather than waited for.
     var seq=[]; for(var h=0;h<48;h++) seq.push(__wirt.key(base+h*HR));
     var seen={}; for(var i=0;i<seq.length;i++) seen[seq[i]]=1;
     var nSeen=0; for(var kk in seen) nSeen++;
     var changes=0; for(var c=1;c<seq.length;c++) if(seq[c]!==seq[c-1]) changes++;
     if(changes<20) bad.push('the lot changed only '+changes+' times across 48 hours');
     if(nSeen<4) bad.push('only '+nSeen+' different things came up across 48 hours');
     // AND IT HOLDS FOR THE WHOLE HOUR. A lot that rerolls while he is deciding,
     // or every time he walks back in, is a different and worse thing.
     var h0=Math.floor(base/HR)*HR;
     var a=__wirt.key(h0+1), b=__wirt.key(h0+900000), c2=__wirt.key(h0+1800000), d=__wirt.key(h0+3599000);
     if(!(a===b&&b===c2&&c2===d)) bad.push('the lot changes inside a single hour: '+a+', '+b+', '+c2+', '+d);
     // THE COUNTER ITSELF, drawn, with a real button on it.
     if(!__vpAlive()) return bad.length?bad.join('; '):'SKIP: the pane has no layout, the stall cannot be drawn';
     __hubEnter();
     var P=__P(), cred0=P.credits, stash0=(P.stash||[]).slice();
     P.credits=25000; P.stash=[];
     __wirt.render();
     var el=document.getElementById('wirtlot');
     if(!el||!el.textContent||el.textContent.length<8) bad.push('nothing is drawn on the counter');
     var btn=document.getElementById('wirtlotbtn');
     if(!btn) bad.push('the counter has no buy button');
     else {
       var want=__wirt.key();
       btn.click();
       if(P.credits!==15000) bad.push('buying the lot moved credits 25000 to '+P.credits+', it should cost exactly 10,000');
       if((P.stash||[]).indexOf(want)<0) bad.push('paid for '+want+' and it did not reach the stash');
       // CONTROL: he must not be able to buy it with money he does not have.
       P.credits=500; __wirt.render();
       var b2=document.getElementById('wirtlotbtn');
       if(b2){
         if(!b2.disabled) bad.push('control: the buy button is live at $500 against a $10,000 price');
         var st=(P.stash||[]).length; b2.click();
         if(P.credits!==500||(P.stash||[]).length!==st)
           bad.push('control: clicking it while broke still took '+(500-P.credits)+' credits');
       }
     }
     P.credits=cred0; P.stash=stash0;
     return bad.length?bad.join('; '):null; }},
  {v:'9.12',what:'a HUD panel cannot be dragged off the screen and lost',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, no drag can land';
     __forceSize(1920,1080); __resetCfg(); __pinDefaults(0); __zoom.set(1,true);
     __deploy({kit:['medkit','plate'],safe:null,mapIx:0,seed:4242});
     __P().hud={};
     var g=__state(); g.ents.length=0; g.player.iv=99;
     for(var f=0;f<6;f++) __loop(performance.now()+f*16.7);
     var bad=[], cv=document.getElementById('cv');
     if(!cv) return 'no canvas to drag on';
     var H=__hud(), B=H.box&&H.box.body;
     if(!B) return 'the vitals panel did not draw, so there is nothing to drag';
     function frames(t){ for(var q=0;q<6;q++) __loop(performance.now()+t+q*16.7); }
     function reachable(b){
       // Some of the panel has to be on screen AND the strip he drags it by has
       // to be hit-testable by a real pointer.
       if(!(b.right>0&&b.bottom>0&&b.x<1920&&b.y<1080)) return false;
       var hx=Math.max(6,Math.min(1914,Math.round(b.x+Math.min(b.w/2,40))));
       var hy=Math.max(4,Math.min(1076,Math.round(b.y+6)));
       var part=__hud().hitAt?__hud().hitAt(hx,hy):null;
       return part==='bar'||part==='glyph'||part==='grip'||part==='body';
     }
     // THE FLICK, through the real mouse path: down on the bar, one big move,
     // up. Measured before v9.12: x -886 with the right edge at -354, saved to
     // the profile, and no reset control anywhere in the game.
     var r=cv.getBoundingClientRect();
     function ev(t,x,y){ cv.dispatchEvent(new MouseEvent(t,{clientX:r.left+x,clientY:r.top+y,button:0,bubbles:true})); }
     var bx=Math.round(B.x+60), by=Math.round(B.y+6);
     ev('mousemove',bx,by); ev('mousedown',bx,by);
     ev('mousemove',bx-900,by-1000); ev('mouseup',bx-900,by-1000);
     frames(300);
     var A=__hud().box.body;
     if(!reachable(A)) bad.push('one flick put the vitals panel at x '+Math.round(A.x)+', right '+Math.round(A.right)+', with no way to grab it back');
     // AND IT REPAIRS a profile that is already broken, which a clamp living only
     // in the drag handler would not do.
     __P().hud={body:{dx:-3000,dy:-3000}};
     frames(900);
     var R2=__hud().box.body;
     if(!reachable(R2)) bad.push('a panel already saved off screen stayed off screen at x '+Math.round(R2.x));
     // CONTROL 1: it must still MOVE. A clamp that pinned every panel to its
     // default would pass both lines above and take away the thing he asked for.
     __P().hud={};
     frames(1500);
     var home=__hud().box.body;
     __P().hud={body:{dx:-140,dy:-220}};
     frames(2100);
     var moved=__hud().box.body;
     if(Math.round(moved.x)===Math.round(home.x)&&Math.round(moved.y)===Math.round(home.y))
       bad.push('control: a modest drag no longer moves the panel at all');
     if(Math.abs((moved.x-home.x)-(-140))>2||Math.abs((moved.y-home.y)-(-220))>2)
       bad.push('control: a modest drag was altered, moved by '+Math.round(moved.x-home.x)+','+Math.round(moved.y-home.y)+' instead of -140,-220');
     // CONTROL 2: a panel he never touched must be left exactly where it was, so
     // the clamp cannot quietly reposition the default layout.
     __P().hud={};
     frames(2700);
     var untouched=__hud().box.gear;
     __P().hud={body:{dx:-3000,dy:-3000}};
     frames(3300);
     var untouched2=__hud().box.gear;
     if(untouched&&untouched2&&(Math.round(untouched.x)!==Math.round(untouched2.x)||Math.round(untouched.y)!==Math.round(untouched2.y)))
       bad.push('control: rescuing one panel moved another that was never dragged');
     __P().hud={};
     return bad.length?bad.join('; '):null; }},
  {v:'9.13',what:'the backpack follows the monitor instead of staying its 1080p size',
   run:function(){
     var bad=[];
     function raidBag(W2,H2){
       __forceSize(W2,H2); __resetCfg(); __pinDefaults(0); __zoom.set(1,true);
       __deploy({kit:['medkit','plate','servo','scrap','core'],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0; g.player.iv=99; g.bagOpen=true;
       for(var f=0;f<6;f++) __loop(performance.now()+f*16.7);
       var bp=g.bagPanel, belt=(g.hotCells&&g.hotCells.length)?g.hotCells[0]:null;
       return {p:bp?{x:bp.x,y:bp.y,w:bp.w,h:bp.h}:null, cols:g.bagCols,
               gap:(bp&&belt)?(belt.y-(bp.y+bp.h)):null};
     }
     var a=raidBag(1920,1080), b=raidBag(3840,2160);
     __forceSize(1920,1080);
     if(!a.p||!b.p) return 'the backpack panel did not record itself, so there is nothing to measure';
     // HIS NOTE, twice: the menus are too small and he plays at 4K. Measured
     // before v9.13: 1194x435 at 1080p and 1295x435 at 4K, growth 1.08 and 1.00
     // against a screen with four times the area.
     var gw=b.p.w/a.p.w, gh=b.p.h/a.p.h;
     if(gw<1.7) bad.push('the backpack is only '+gw.toFixed(2)+'x wider on a 4K screen than at 1080p');
     if(gh<1.7) bad.push('the backpack is only '+gh.toFixed(2)+'x taller on a 4K screen than at 1080p');
     // SAME LAYOUT, BIGGER. Growing by adding columns is what it used to do and
     // is not what he asked for: he asked for the same menu, larger.
     if(a.cols!==b.cols) bad.push('the grid changed shape rather than size, '+a.cols+' columns at 1080p and '+b.cols+' at 4K');
     // CONTROL 1: 1080p must not have moved. He has a working layout there and
     // this was a 4K complaint.
     if(Math.abs(a.p.w-1194)>6||Math.abs(a.p.h-435)>6)
       bad.push('control: the 1080p panel changed to '+Math.round(a.p.w)+'x'+Math.round(a.p.h)+', it was 1194x435');
     // CONTROL 2: it must still clear the belt at BOTH sizes. Doubling a panel
     // that sits above the belt is exactly how it lands on the belt, which is a
     // thing he has already reported once.
     if(a.gap!==null&&a.gap<0) bad.push('control: at 1080p the backpack overlaps the belt by '+Math.round(-a.gap)+'px');
     if(b.gap!==null&&b.gap<0) bad.push('control: at 4K the backpack overlaps the belt by '+Math.round(-b.gap)+'px');
     // CONTROL 3: and it must still fit on the screen it is drawn on.
     if(b.p.x<0||b.p.x+b.p.w>3840) bad.push('control: at 4K the panel runs off the screen, x '+Math.round(b.p.x)+' width '+Math.round(b.p.w));
     if(b.p.y<0||b.p.y+b.p.h>2160) bad.push('control: at 4K the panel runs off the bottom, y '+Math.round(b.p.y)+' height '+Math.round(b.p.h));
     // AND THE UNDERCROFT DRAWS THE SAME PANEL, which is the whole point of
     // v8.95. If only the raid one scaled, his I key would open a small one.
     if(__vpAlive()&&__hubEnter&&__drawBagWith&&__hubBagState){
       function hubBag(W2,H2){
         __forceSize(W2,H2); __resetCfg(); __pinDefaults(0);
         __hubEnter();
         var P2=__P(); P2.kit=['medkit','plate','servo','scrap','core']; P2.hotAssign={};
         __hubBag(false);
         var r=__drawBagWith(__hubBagState());
         return (r&&r.recorded)?r.recorded.panel:null;
       }
       var ha=hubBag(1920,1080), hb=hubBag(3840,2160);
       __forceSize(1920,1080);
       if(ha&&hb){
         if(hb.w/ha.w<1.7) bad.push('the Undercroft backpack is only '+(hb.w/ha.w).toFixed(2)+'x wider at 4K');
       }
     }
     return bad.length?bad.join('; '):null; }}
];
// Is the page actually laid out? A collapsed pane reports a 0x0 viewport and
// document.elementFromPoint then returns null everywhere, which silently breaks
// every drag, click and hit test. Checks that need the DOM ask this first.
window.__vpAlive=function(){
  if(!window.innerWidth||!window.innerHeight) return false;
  return !!document.elementFromPoint(2,2);
};
window.__regress=function(){
  var res={pass:true,checked:0,fail:[],skipped:[]};
  for(var i=0;i<__REGRESS.length;i++){
    var t=__REGRESS[i], r=null;
    res.checked++;
    try{ r=t.run(); }catch(e){ r='threw: '+e; }
    // A check that cannot run says so instead of condemning the build. Before
    // this, the only way to report anything was to return a string and every
    // string was a failure, which is how a 0x0 viewport made me tell him the
    // belt drag was broken when it was not.
    if(r&&r.indexOf('SKIP: ')===0){ res.skipped.push('v'+t.v+' '+t.what+' -> '+r.slice(6)); continue; }
    if(r){ res.pass=false; res.fail.push('v'+t.v+' '+t.what+' -> '+r); }
  }
  var ran=res.checked-res.skipped.length;
  res.summary=res.pass?('PASS, '+ran+' regression checks'+(res.skipped.length?(' ('+res.skipped.length+' could not run)'):''))
                      :('FAIL x'+res.fail.length);
  return res;
};
// v8.58: the DOM panels that COMPUTE their contents, so a probe can read the
// real rendered text instead of redoing the arithmetic and grading itself.
window.__type={
  // the rendered px of a TYPE role at the current text size, not the source px
  px:function(role){ var m=/([\d.]+)px/.exec(FS(TYPE[role])); return m?+m[1]:null; },
  lh:function(n){ return LH(n); },
  scale:function(){ return uiScale(); },
  // how wide the widest line of a list of strings renders in a given role
  widest:function(role,arr,pre){
    var c=document.createElement('canvas').getContext('2d');
    c.font=FS(TYPE[role]); var m=0,who=-1;
    for(var i=0;i<arr.length;i++){
      var w=c.measureText((pre?((i+1)+'. '):'')+arr[i]).width;
      if(w>m){ m=w; who=i; }
    }
    return {px:Math.round(m),line:who+1,n:arr.length};
  },
  whatsnew:function(){ return WHATSNEW.slice(); },
  ver:function(){ return WHATSNEW_VER; }
};
window.__zoom={min:function(){ return ZMIN; },max:function(){ return ZMAX; },
               get:function(){ return zoomTarget(); },
               set:function(z){ setZoom(z,true); return zoomTarget(); },
               // how many map tiles fit across the screen at a given zoom
               tiles:function(z){ var g=__state(); if(!g||!g.map) return null;
                 return +( (cv.width/(window.devicePixelRatio||1)) /z/g.map.cw ).toFixed(1); }};
window.__ui={sector:function(){ return renderSector(); },
             hub:function(){ return renderHub(); },
             stats:function(){ return renderStatCards(); }};
// v8.63: deploy WITH A KIT, through the real staging path. Puts the named items
// in the stash, stages them, runs commitKit so P.dropKit and P.safeUp are armed
// exactly as the lift arms them, then starts the raid. Without this the drop kit
// and the safe pocket were untestable, because __startRaid lands with nothing.
window.__deploy=function(o){
  o=o||{};
  var kit=o.kit||[];
  P.stash=(o.stash||kit).slice();
  P.kit=kit.slice();
  P.kitChosen=0; P.dropKit=[]; P.freeKit=0;
  if(o.safe!==undefined) P.safe=o.safe;
  var ok=false;
  try{ ok=commitKit(); }catch(e){ return {error:'commitKit threw: '+e}; }
  __startRaid({mapIx:o.mapIx===undefined?0:o.mapIx,seed:o.seed===undefined?4242:o.seed,sim:!!o.sim});
  return {committed:ok,dropKit:(P.dropKit||[]).slice(),safeUp:P.safeUp===undefined?null:P.safeUp,
          stashLeft:(P.stash||[]).slice(),bag:G?G.bag.slice():null};
};
// v8.65: the belt, readable. slots() is what the hotbar actually holds, sel() is
// which one is live, set() and use() are the two verbs the keys drive. Without
// these a belt check has to infer the state from the HUD and usually infers it
// wrong.
window.__belt={slots:function(){ return hotbarSlots(); },
               sel:function(){ return hotSel(); },
               set:function(i){ return setHot(i); },
               use:function(){ return useHot(); },
               assign:function(){ return P.hotAssign||{}; }};
// v8.74: the settings menu, so "make sure all the modifiers work as intended"
// can be a check rather than a reading of the source. rows is the table the
// panel is built from, cycle is what a click does, apply is what a load does.
window.__opts={rows:function(){ return GAMEOPTS; },
               cycle:function(k){ return cycleGameOpt(k); },
               apply:function(){ return applyGameOpts(); },
               ix:function(k){ return gameOptIx(k); },
               tuned:function(){ return tunedKeys(); },
               preset:function(k){ return applyPreset(k); }};
window.__audio={amb:tickAmbience,steps:tickEnemyAudio,sfx:sfx,blip:blip,ears:earsOf,stepSound:stepSoundFor,
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
