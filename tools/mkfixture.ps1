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
// v9.36 harness: pin the canvas backing store to CSS pixels for measurement.
// Returns what it actually achieved so a caller can refuse to measure rather than
// measure the wrong quarter of a buffer.
// Everything a check can leave behind in the SAVED profile that changes what the
// next check measures. CFG is not enough; __resetCfg has never reached any of it.
window.__cleanProfile=function(){
  var was={terms:(P.terms||[]).slice(), hotAssign:P.hotAssign, uiScale:P.uiScale};
  P.terms=[];
  P.hotAssign={};
  delete P.uiScale;
  try{ saveProfile(); }catch(e){}
  return was;
};
window.__pinDPR=function(v){
  DPR=(v===undefined?1:v);
  try{ resize(); }catch(e){}
  return {DPR:DPR, buffer:[cv.width,cv.height], css:[cv.offsetWidth,cv.offsetHeight],
          oneToOne:(cv.offsetWidth>0&&cv.width===cv.offsetWidth&&hcv.width===hcv.offsetWidth)};
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
// The weapon footnote on the shop screen, drawn rather than grepped, because the
// question is what he READS and a source string can be behind a branch.
window.__shopPanel={detail:function(ix){
  var keep=P._shopSel; P._shopSel=(ix===undefined?0:ix);
  var out='';
  try{ renderShopDetail(null); var d=document.getElementById('shopdetail'); out=d?d.textContent:''; }
  finally{ P._shopSel=keep; }
  return out; },
  weaponIndex:function(){ for(var i=0;i<SHOP.length;i++) if(SHOP[i].kind==='wep') return i; return -1; },
  rows:function(){ return SHOP.map(function(o){ return {k:o.k,kind:o.kind,price:o.price,rep:o.rep}; }); }};
// v9.11: Wirt's counter. The key function is exposed with its time argument so a
// check can walk the clock forward instead of waiting an hour to find out whether
// the lot rotates.
// v9.19: the words the game puts on screen, so a check can hold them to his
// vocabulary list instead of me grepping the source by hand every few builds.

window.__prof={parts:function(rows){ return profParts(rows); }, weights:function(){ return PROFW; }};
window.__words={cacheTags:function(){ var o=[]; if(G&&G.containers)
                  for(var i=0;i<G.containers.length;i++) if(G.containers[i].cache&&G.containers[i].tag) o.push(G.containers[i].tag);
                  return o; },
                rewardLabels:function(){ var o=[]; for(var i=0;i<SEASON_TIERS.length;i++) o.push(tierLabel(SEASON_TIERS[i])); return o; },
                whatsnew:function(){ return {ver:WHATSNEW_VER, lines:WHATSNEW.slice(), build:VER}; }};
window.__wirt={key:function(t){ return wirtLotKey(t); },
               left:function(t){ return wirtLotLeft(t); },
               hour:function(t){ return wirtLotHour(t); },
               price:function(){ return WIRT_LOT_PRICE; },
               pool:function(){ return WIRT_LOT_POOL.slice(); },
               // v9.44: the lot is a list. worth() prices it the way the counter
               // does, and head() is the one item the panel names first.
               worth:function(keys){ return (typeof wirtLotWorth==='function')?wirtLotWorth(keys):null; },
               head:function(t){ var l=wirtLotKey(t); return (l&&l.length)?l[0]:null; },
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
// This object is REDEFINED forty lines below and everything here is dead. Its
// live half survives as window.__repair and window.__work; the rest was reachable
// by nobody. Six name collisions in this file now, so: grep before you name one.
window.__work=function(){ return renderWork(); };
window.__stashRules={sellable:function(k){ return !!sellable(k); },
                     craftPart:function(k){ return !!craftPart(k); },
                     use:function(k){ return craftUse(k); }};
// updateEnts alone, so a detection test can pin the player's stance instead of
// having updatePlayer recompute it from keys that are not held.
window.__ents=function(dt){ refreshVseg(); updateEnts(dt); };
window.__space={at:spaceAt,surf:surfAt,verb:verb,tick:tickVerb,rev:function(){return REV;},
  name:function(){return SPACE_N;},steps:tickPlayerSteps,pstep:function(){return PSTEP;}};
// promise is the exact sentence the sell panel prints, not a copy of it, so a
// check cannot pass against a duplicate that has drifted from what is drawn.
window.__ped={open:pedOpen,sell:pedSellAll,buy:pedBuy,make:mkPeddler,draw:drawTrade,
              promise:function(){ return (typeof pedSellPromise==='function')?pedSellPromise():null; },
              carry:function(){ return (G&&G.pedCarry)||0; }};
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
window.__hudHit=function(x,y){ return hudHit(x,y); };
// v9.48: which floor a building wears. Returns null on a build that has no such
// idea, which is how the falsifying control tells the two apart - the shim itself
// exists on every build the fixture is made from.
window.__bld={floor:function(b){ return (typeof bldFloor==='function')?bldFloor(b):null; }};
window.__textTrace=function(fn){
  var proto=CanvasRenderingContext2D.prototype, orig=proto.fillText, out=[];
  proto.fillText=function(t,x,y){
    try{
      var T=this.getTransform();
      out.push({t:String(t),x:T.a*x+T.c*y+T.e,y:T.b*x+T.d*y+T.f,
                w:this.measureText(String(t)).width*T.a,align:this.textAlign});
    }catch(e){}
    return orig.apply(this,arguments);
  };
  try{ fn(); } finally { proto.fillText=orig; }
  return out;
};
// __ival is defined TWICE in this file, at 355 and 754, so it is not an anchor.
// Seventh duplicate shim I have tripped over here. Grep before you name one, and
// grep before you ANCHOR on one.
// v9.45: the buyback, so a check can drive it against a profile it built rather
// than reloading the page and hoping the migration ran. Returns null on a build
// that has no buyback, which is how the falsifying control tells the two apart.
window.__rigs={buyback:function(pr){ return (typeof rigBuyback==='function')?rigBuyback(pr):null; },
               armorCap:function(){ return rigCeil(myRig()); },
               wornId:function(){ return myRig().id; },
               armorTable:function(){ return ARMORS.map(function(a){ return {id:a.id,cap:a.cap}; }); }};
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
  // v9.30: 58 and 276 until the crawler count started following the house count.
  // The change is +27 on COLD STORAGE and +93 on THE COLD MILE, which is exactly
  // the number of crawlers each map gained, so every new entity is accounted for
  // and the containers are still 157 and 589.
  var EXP=opt.ents||{0:85,1:369}, SEED=opt.seed||4242;
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
     var m=__mouse(), H=__hud();
     // v9.46: the panel under test has to HAVE a minimise glyph. Asked of the
     // game, at the exact pixel the samples below use, rather than assumed.
     var B=null, Bname=null;
     if(H.box&&window.__hudHit){
       for(var _pk in H.box){
         var _r=H.box[_pk]; if(!_r) continue;
         var _h=__hudHit(Math.round(_r.x+_r.w-12),Math.round(_r.y+8));
         if(_h&&_h.id===_pk&&_h.part==='glyph'){ B=_r; Bname=_pk; break; }
       }
     }
     if(!B) return 'SKIP: no panel drew a minimise glyph at its top right, so there is nothing to tell apart';
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
     if(bar.k===glyph.k) bad.push('on the '+Bname+' panel the drag bar and the minimise glyph still draw the same pointer');
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
     // path: the same key and the same lock the player uses.
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
     // v9.24 TURNED THIS LINE AROUND. It used to demand the medical cost stay,
     // and it went red the moment I obeyed him. HIS INSTRUCTION: "REVIVING
     // ANOTHER PILLAGER SHOULD BE FREE, IT SHOULD NOT COST A MEDKIT". So the same
     // count is asserted the other way now: both medkits must still be in the bag
     // afterwards, while the payout above must still have happened. Free AND
     // paying out is the trade, and this check now pins both halves at once.
     var cA=0,cB=0;
     for(var a1=0;a1<yourBefore.length;a1++) if(yourBefore[a1]==='medkit') cA++;
     for(var b1=0;b1<after.length;b1++) if(after[b1]==='medkit') cB++;
     if(cB<cA) bad.push('the revive is charging a medical item again, '+cB+' medkits left of '+cA);
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
       // v9.44: a lot is a list and the first entry is what the panel names.
       var hd=(pool[q]&&pool[q].length)?pool[q][0]:pool[q];
       var r=__wirt.rar(hd);
       if(r!=='elite'&&r!=='rare') bad.push('the counter can stock '+hd+', which is '+r);
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
       // v9.44: EVERY key in the lot, not just the headline. A lot that quietly
       // hands over one of its four things is the same defect in a new shape.
       var wl=(want&&want.length&&typeof want!=='string')?want:[want];
       for(var wq=0;wq<wl.length;wq++)
         if((P.stash||[]).indexOf(wl[wq])<0) bad.push('paid for a lot holding '+wl[wq]+' and it did not reach the stash');
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
     return bad.length?bad.join('; '):null; }},
  {v:'9.14',what:'the writing on the sector map follows the monitor, like the map itself does',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to read';
     var bad=[], hc=document.getElementById('hcv');
     if(!hc) return 'no HUD canvas to read';
     // Measures the AMBER heading drawn above the map frame, because that is the
     // drawn result. Reading the type roles instead would report the global font
     // and miss the whole thing, which is how this defect survived this long.
     function mapText(W2,H2){
       __forceSize(W2,H2); __resetCfg(); __pinDefaults(0); __zoom.set(1,true);
       __deploy({kit:['medkit'],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0; g.player.iv=99;
       for(var f=0;f<4;f++) __loop(performance.now()+f*16.7);
       var m=g.map, WW=m.cols*m.cw, WH=m.rows*m.ch;
       var pad=70, sc=Math.min((W2-pad*2)/WW,(H2-pad*2)/WH);
       var ox=(W2-WW*sc)/2, oy=(H2-WH*sc)/2;
       __mapOverlay();
       var x0=Math.max(0,Math.round(ox-4)), w=Math.min(1500,W2-x0);
       var y0=Math.max(0,Math.round(oy-56)), hgt=Math.min(H2-y0,54);
       var d=hc.getContext('2d').getImageData(x0,y0,w,hgt).data;
       var minX=1e9,maxX=-1,minY=1e9,maxY=-1;
       for(var yy=0;yy<hgt;yy++) for(var xx=0;xx<w;xx++){
         var i=(yy*w+xx)*4;
         if(d[i]>180&&d[i+1]>140&&d[i+2]<130&&d[i+3]>60){
           if(xx<minX)minX=xx; if(xx>maxX)maxX=xx; if(yy<minY)minY=yy; if(yy>maxY)maxY=yy; }
       }
       return {mapW:Math.round(WW*sc), mapH:Math.round(WH*sc),
               tw:maxX<0?0:(maxX-minX+1), th:maxY<0?0:(maxY-minY+1)};
     }
     var a=mapText(1920,1080), b=mapText(3840,2160);
     __forceSize(1920,1080);
     if(!a.tw||!a.th) return 'no map heading was found at 1080p, so there is nothing to compare';
     // Measured before v9.14: the map went 1161x940 to 2495x2020, a growth of
     // 2.15, while every string on it stayed at exactly its 1080p pixel size.
     var mg=b.mapW/a.mapW, tg=b.th/a.th;
     if(mg<1.7) bad.push('the map itself stopped scaling, only '+mg.toFixed(2)+'x at 4K');
     if(tg<1.7) bad.push('the map heading is only '+tg.toFixed(2)+'x taller at 4K while the map is '+mg.toFixed(2)+'x bigger');
     if(b.tw/a.tw<1.7) bad.push('the map heading is only '+(b.tw/a.tw).toFixed(2)+'x wider at 4K');
     // CONTROL 1: 1080p must not have moved. This was a 4K complaint and he has a
     // working layout there.
     if(Math.abs(a.tw-326)>18||Math.abs(a.th-16)>3)
       bad.push('control: the 1080p map heading changed to '+a.tw+'x'+a.th+', it was 326x16');
     // CONTROL 2, AND IT IS THE ONE THAT MATTERS. The map scales its text by
     // handing FS a modified spec. If that ever leaks into the global font cache,
     // every panel in the game inherits a 4K font at 1080p. So: draw the map at
     // 4K, come back to 1080p, and check the ordinary roles are what they always
     // were and a normal HUD panel is still its normal size.
     var lab=__type.px('label'), mic=__type.px('micro');
     if(Math.abs(lab-18.7)>0.6) bad.push('control: the global label role is '+lab+'px at 1080p after the map drew at 4K, it should be 18.7');
     if(Math.abs(mic-15.6)>0.6) bad.push('control: the global micro role is '+mic+'px at 1080p after the map drew at 4K, it should be 15.6');
     __P().hud={};
     __deploy({kit:['medkit','plate'],safe:null,mapIx:0,seed:4242});
     var g2=__state(); g2.ents.length=0; g2.player.iv=99;
     for(var f2=0;f2<6;f2++) __loop(performance.now()+f2*16.7);
     var vb=__hud().box.body;
     if(!vb||Math.abs(vb.w-532)>10)
       bad.push('control: the vitals panel is '+(vb?Math.round(vb.w):'missing')+'px wide at 1080p, it should be 532 - the map font has leaked into the HUD');
     // CONTROL 3: bigger writing must still fit on the screen it is drawn on.
     if(b.tw>3840) bad.push('control: the 4K map heading is wider than the screen');
     return bad.length?bad.join('; '):null; }},
  {v:'9.15',what:'the sector map markers and frame scale with the monitor, like its writing does',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, there are no pixels to read';
     var bad=[];
     // HOW FAR THE FRAME REACHES OUTSIDE THE MAP RECTANGLE. That strip is the one
     // place on this screen with nothing else drawn in it: scanning across the
     // frame catches the district fill behind it and scanning for a marker ring
     // catches the label beside it, both of which fooled me before I found this.
     function frameReach(W2,H2){
       __forceSize(W2,H2); __resetCfg(); __pinDefaults(0); __zoom.set(1,true);
       __deploy({kit:['medkit'],safe:null,mapIx:0,seed:4242});
       var g=__state(); g.ents.length=0; g.player.iv=99;
       for(var f=0;f<4;f++) __loop(performance.now()+f*16.7);
       __mapOverlay();
       var m=g.map, WW=m.cols*m.cw, WH=m.rows*m.ch;
       var pad=70, sc=Math.min((W2-pad*2)/WW,(H2-pad*2)/WH);
       var ox=(W2-WW*sc)/2, oy=(H2-WH*sc)/2;
       var y=Math.round(oy+WH*sc/2), x0=Math.max(0,Math.round(ox)-40), w=Math.min(40,W2-x0);
       var d=document.getElementById('hcv').getContext('2d').getImageData(x0,y,w,1).data;
       var far=0;
       for(var x=0;x<w;x++){ var i=x*4;
         if(d[i+3]>60&&d[i+2]>d[i]+20&&d[i+2]>90){
           var off=Math.round(ox)-(x0+x);
           if(off>0&&off>far) far=off; } }
       return {reach:far, scale:sc};
     }
     var a=frameReach(1920,1080), b=frameReach(3840,2160);
     __forceSize(1920,1080);
     if(!a.reach) return 'the map frame was not found at 1080p, so there is nothing to compare';
     var mg=b.scale/a.scale, fg=b.reach/a.reach;
     // Measured before v9.15: the frame reached exactly 4 pixels out at BOTH
     // resolutions while the map itself grew 2.15x.
     if(fg<1.7) bad.push('the map frame reaches '+a.reach+'px out at 1080p and '+b.reach+'px at 4K, only '+fg.toFixed(2)+'x, on a map that grew '+mg.toFixed(2)+'x');
     // CONTROL 1: 1080p unchanged. It was 4 pixels before this build and after it.
     if(a.reach!==4) bad.push('control: the 1080p frame reaches '+a.reach+'px, it was 4');
     // CONTROL 2: the markers must scale too, not just the frame, or half the
     // chrome is still stuck at 1080p. Read off the source of the one function
     // that draws them, because a marker ring cannot be isolated in pixels with
     // a label sitting next to it.
     var src=(typeof drawMapOverlay==='function')?String(drawMapOverlay):'';
     if(src){
       if(/arc\(qx,qy,9\+2\*qp,/.test(src)) bad.push('the cache ring is still a fixed 9px radius');
       if(/arc\(mx3,my3,5,/.test(src))      bad.push('the encampment marker is still a fixed 5px radius');
       if(/arc\(kcx,kcy,3\.2,/.test(src))   bad.push('the key marker is still a fixed 3.2px radius');
     }
     // CONTROL 3: the map itself must still scale, or a frame that grew while the
     // map stopped would satisfy the ratio above and be a worse screen.
     if(mg<1.7) bad.push('control: the map itself stopped scaling, only '+mg.toFixed(2)+'x at 4K');
     return bad.length?bad.join('; '):null; }},
  {v:'9.16',what:'the world is drawn the same size on any monitor, and the pointer agrees with it',
   run:function(){
     if(!window.__proj) return 'this build cannot report its own projection, so this cannot be measured';
     var bad=[];
     // Parked at the centre of the big map so the camera is nowhere near a clamp,
     // with the dial at 1 on both screens.
     function look(W2,H2){
       __forceSize(W2,H2); __resetCfg(); __pinDefaults(0); __zoom.set(1,true);
       __deploy({kit:['medkit'],safe:null,mapIx:1,seed:4242});
       var g=__state(); g.ents.length=0; g.player.iv=99;
       var m=g.map; g.player.x=m.cols*m.cw/2; g.player.y=m.rows*m.ch/2;
       for(var f=0;f<12;f++) __loop(performance.now()+f*16.7);
       var mo=__mouse(); mo.x=Math.round(W2*0.62); mo.y=Math.round(H2*0.38); mo.init=true;
       for(var f2=0;f2<2;f2++) __loop(performance.now()+400+f2*16.7);
       var mw=__proj.mouseWorld(), back=__proj.w2s(mw.x,mw.y,0);
       return {z:__proj.zoom(), dial:__proj.dial(), res:__proj.res(),
               across:W2/__proj.zoom(),
               errX:Math.abs(back.x-mo.x), errY:Math.abs(back.y-mo.y)};
     }
     var a=look(1920,1080), b=look(3840,2160);
     __forceSize(1920,1080);
     // Measured before v9.16: 1920 world units across at 1080p and 4090 at 4K, so
     // a 4K player saw 2.13x more ground with everything on it half the size.
     var grow=b.across/a.across;
     if(grow>1.25) bad.push('a 4K screen still shows '+grow.toFixed(2)+'x more ground than 1080p, '+Math.round(a.across)+' units against '+Math.round(b.across));
     // CONTROL 1: 1080p must be untouched. The dial is 1 there and one world unit
     // was one screen pixel, and it still should be.
     if(Math.abs(a.z-1)>0.001) bad.push('control: the 1080p projection is '+a.z+', it should be exactly 1');
     if(Math.abs(a.across-1920)>4) bad.push('control: 1080p now shows '+Math.round(a.across)+' units across, it showed 1920');
     // CONTROL 2, AND IT IS THE ONE THAT COULD BREAK. Folding a factor into the
     // projection moves the PICTURE and the POINTER. If they ever disagree, every
     // shot lands somewhere other than where he aimed. Round trip: screen point
     // to world and back.
     if(a.errX>2||a.errY>2) bad.push('control: at 1080p the pointer round trip is off by '+Math.round(a.errX)+','+Math.round(a.errY)+' pixels');
     if(b.errX>2||b.errY>2) bad.push('control: at 4K the pointer round trip is off by '+Math.round(b.errX)+','+Math.round(b.errY)+' pixels');
     // CONTROL 3: the wheel must still do what it did. The dial is his setting and
     // folding the screen in must not have swallowed it.
     __forceSize(1920,1080); __resetCfg(); __pinDefaults(0);
     __deploy({kit:['medkit'],safe:null,mapIx:0,seed:4242});
     __zoom.set(1,true); var z1=__proj.zoom();
     __zoom.set(3,true); var z3=__proj.zoom();
     __zoom.set(__zoom.max()+50,true); var zmax=__proj.dial();
     __zoom.set(1,true);
     if(!(z3>z1*2.5)) bad.push('control: turning the dial from 1 to 3 moved the projection from '+z1+' to '+z3);
     if(Math.abs(zmax-__zoom.max())>0.001) bad.push('control: the dial no longer clamps at its maximum, it reached '+zmax);
     return bad.length?bad.join('; '):null; }},
  {v:'9.17',what:'the title screen uses an ultrawide screen instead of leaving two thirds of it empty',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, the title screen cannot be measured';
     var bad=[];
     var t=document.getElementById('title');
     if(!t) return 'there is no title screen to measure';
     var col=t.querySelector('.titlecol');
     // Measured before v9.17 at a real 1720x720: the column was 50 percent of the
     // width with about 650 pixels empty either side, and it overflowed into a
     // scroll while that room sat unused. The width was a hard 820px inline, so
     // there was nothing for a wider screen to target.
     if(!col) return 'the title column has no class to target, so no screen wider than 16:9 can be given more room';
     var cs=getComputedStyle(col), mw=cs.maxWidth;
     // THE LIVE ASPECT DECIDES which rule should be in force, and this asks the
     // browser rather than assuming: matchMedia evaluates the same query the
     // stylesheet uses, at whatever shape the pane actually is right now.
     var wide=window.matchMedia('(min-aspect-ratio: 19/10)').matches;
     var asp=window.innerWidth/Math.max(1,window.innerHeight);
     if(wide){
       if(mw==='820px') bad.push('at aspect '+asp.toFixed(2)+' the column is still capped at 820px, the ultrawide rule is not in force');
       if(col.offsetWidth<=860) bad.push('at aspect '+asp.toFixed(2)+' the column is only '+col.offsetWidth+'px wide');
     } else {
       // CONTROL 1: 16:9 must be untouched. 1080p, 1440p and 4K are all exactly
       // 1.778 and must keep the layout he already has.
       if(mw!=='820px') bad.push('control: at aspect '+asp.toFixed(2)+', which is not ultrawide, the column cap is '+mw+' rather than 820px');
       if(col.offsetWidth>860) bad.push('control: at aspect '+asp.toFixed(2)+' the column is '+col.offsetWidth+'px, wider than the 820 base');
     }
     // CONTROL 2: both halves of the rule must still exist in the stylesheet, so
     // deleting either one fails here rather than silently reverting his screen.
     var base=false, gated=false;
     for(var i=0;i<document.styleSheets.length;i++){
       var rules; try{ rules=document.styleSheets[i].cssRules; }catch(e){ continue; }
       for(var j=0;j<rules.length;j++){
         var tx=rules[j].cssText||'';
         if(tx.indexOf('titlecol')<0) continue;
         if(tx.indexOf('@media')===0){ if(/min-aspect-ratio/.test(tx)) gated=true; }
         else if(/max-width:\s*820px/.test(tx)) base=true;
       }
     }
     if(!base)  bad.push('the 820px base width is gone, so 16:9 is no longer pinned');
     if(!gated) bad.push('the aspect-gated rule is gone, so an ultrawide gets nothing');
     // CONTROL 3: the column must never be allowed to run the whole width of an
     // ultrawide, which is its own kind of unreadable.
     if(col.offsetWidth>window.innerWidth*0.9)
       bad.push('control: the column is '+Math.round(col.offsetWidth/window.innerWidth*100)+' percent of the screen, lines that wide are unreadable');
     return bad.length?bad.join('; '):null; }},
  {v:'9.18',what:'the title screen never makes you scroll to reach your saves',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, the title screen cannot be measured';
     var bad=[];
     var t=document.getElementById('title');
     if(!t) return 'there is no title screen to measure';
     // OWN THE BOX FIRST. .screen is absolute inside the wrapper and the wrapper
     // follows the CANVAS, so this inherits the last __forceSize any other check
     // happened to leave. Measured that way it read a 436px tall screen on a 1080
     // window and called it an overflow.
     // OWN THE ZOOM AS WELL AS THE BOX. This screen scales itself by menuZoom
     // times titleRes, both of which earlier checks move, and a 1080 tall box at
     // zoom 2.47 is 436 layout pixels: measured that way it reported an overflow
     // that only my own harness had created.
     var mz0=null;
     try{
       __forceSize(window.innerWidth,window.innerHeight);
       // 1.3, not 1. At 1 this screen fits on every size and the check would be
       // measuring a case that was never broken.
       if(window.__menuZoom){ mz0=__menuZoom.get(); __menuZoom.set(1.3); }
     }catch(_fz){}
     var wasOn=t.classList.contains('on');
     t.classList.add('on');
     // OWN THE INPUT. The saves list is the one part of this screen whose height
     // is data, and a full list is MEANT to scroll. Emptied to a single row so
     // this measures the screen he sees on an ordinary day, then put back.
     var host=document.getElementById('slotlist');
     var savedHTML=host?host.innerHTML:null;
     if(host) host.innerHTML='<div style="padding:7px 10px;border:1px solid #3a4552">PILLAGER</div>';
     var col=t.querySelector('.titlecol');
     // CSS pixels only. getBoundingClientRect returns pane-SCALED numbers in this
     // harness and I read those as layout twice before noticing, so everything
     // here uses scrollHeight, clientHeight and computed styles.
     var over=t.scrollHeight-t.clientHeight;
     // Measured before v9.18 at 1720x720: scrollHeight 573 against clientHeight
     // 552, so the first screen in the game asked him to scroll to his saves.
     if(over>2) bad.push('the title screen scrolls by '+over+'px at '+window.innerWidth+'x'+window.innerHeight);
     // and the last block, which is the saves list, has to be reachable without it
     if(col&&col.children.length){
       var last=col.children[col.children.length-1];
       var lr=last.getBoundingClientRect(), tr=t.getBoundingClientRect();
       // both scaled the same way, so their RATIO is still meaningful
       if(tr.height>0&&(lr.top+lr.height)>tr.top+tr.height+2)
         bad.push('the last block on the title screen runs past the bottom of it');
     }
     // AND AT THE ORDINARY SETTING TOO, so a fix that only helped the raised one
     // would still be caught if it broke the default.
     if(window.__menuZoom){
       __menuZoom.set(1);
       var o1=t.scrollHeight-t.clientHeight;
       if(o1>2) bad.push('at menu zoom 1 the title screen scrolls by '+o1+'px');
       __menuZoom.set(1.3);
     }
     var pad=getComputedStyle(t).paddingTop;
     var tall=(window.innerHeight>820);
     if(tall){
       // CONTROL 1: his screen must not tighten. 1080, 1440 and 2160 are all
       // taller than the cut-off and must keep the rhythm they had.
       if(pad!=='18px') bad.push('control: at '+window.innerHeight+'px tall the screen padding is '+pad+', it should still be 18px');
       if(col&&col.children.length>2){
         var m2=getComputedStyle(col.children[2]).marginTop;
         if(m2!=='26px') bad.push('control: at '+window.innerHeight+'px tall a block margin is '+m2+', it should still be 26px');
       }
     } else {
       if(pad==='18px') bad.push('at '+window.innerHeight+'px tall the screen is still using the full 18px padding, the short-screen rule is not in force');
     }
     // CONTROL 2: both rules must still exist, so deleting either fails here
     // rather than quietly putting the scrollbar back.
     var gated=false;
     for(var i=0;i<document.styleSheets.length;i++){
       var rules; try{ rules=document.styleSheets[i].cssRules; }catch(e){ continue; }
       for(var j=0;j<rules.length;j++){
         var tx=rules[j].cssText||'';
         if(tx.indexOf('@media')===0&&/max-height/.test(tx)&&tx.indexOf('title')>=0) gated=true;
       }
     }
     if(!gated) bad.push('the short-screen rule is gone, so a short monitor scrolls again');
     // (the v9.19 vocabulary check lives on its own below)
     // CONTROL: a FULL saves list is allowed to scroll, and must, or the panel
     // would clip rows he cannot reach. Eight rows is the cap the game enforces.
     if(host){
       host.innerHTML=savedHTML===null?'':savedHTML;
       var many='';
       for(var q=0;q<8;q++) many+='<div style="padding:7px 10px;border:1px solid #3a4552">PILLAGER '+q+'</div>';
       host.innerHTML=many;
       if(window.innerHeight<=820&&t.scrollHeight<=t.clientHeight+2)
         bad.push('control: a full saves list does not scroll on a short screen, so rows are being clipped');
       host.innerHTML=savedHTML===null?'':savedHTML;
     }
     if(!wasOn) t.classList.remove('on');
     if(mz0!==null){ try{ __menuZoom.set(mz0); }catch(_mz){} }
     return bad.length?bad.join('; '):null; }},
  {v:'9.19',what:'the names on screen are his names, not the ones I reached for',
   run:function(){
     if(!window.__words) return 'this build cannot report its own on-screen words';
     var bad=[];
     __resetCfg(); __pinDefaults(0);
     // HIS INSTRUCTION: "'EXTRACT CACHE' -- confusing name -- lets call it a
     // 'ELITE CACHE'". Read off a built raid rather than the source, on both maps.
     [0,1].forEach(function(mi){
       __startRaid({mapIx:mi,seed:4242});
       var tags=__words.cacheTags();
       if(!tags.length){ bad.push('map '+mi+' built no tagged caches, so nothing was checked'); return; }
       for(var i=0;i<tags.length;i++){
         if(/EXTRACT CACHE/.test(tags[i])) bad.push('map '+mi+' still tags a cache "'+tags[i]+'"');
       }
       // CONTROL: and it must still be NAMED. Dropping the tag entirely would
       // satisfy the line above and leave an unlabelled crate.
       var elite=false;
       for(var j=0;j<tags.length;j++) if(/ELITE CACHE/.test(tags[j])) elite=true;
       if(!elite) bad.push('map '+mi+' has no ELITE CACHE at all, the tag was dropped rather than renamed');
     });
     // HIS VOCABULARY LIST: Credits, never cash.
     var labs=__words.rewardLabels();
     if(!labs.length) bad.push('there are no reward labels to check');
     for(var k=0;k<labs.length;k++){
       if(/CASH/i.test(labs[k])) bad.push('a reward still reads "'+labs[k]+'"');
     }
     // CONTROL: the money rewards must still say what they pay, or renaming them
     // to nothing would pass the line above.
     var paid=0;
     for(var m=0;m<labs.length;m++) if(/CREDITS/i.test(labs[m])) paid++;
     if(paid<4) bad.push('control: only '+paid+' rewards name credits, there should be four');
     // AND THE WHAT IS NEW CARD MUST NOT GO STALE AGAIN. The parse gate fails at
     // 0.20 of drift and it had reached 0.21 before this build, which means the
     // card in front of him was twenty-one builds out of date.
     var wn=__words.whatsnew();
     var vNow=parseFloat(String(wn.build||'0').replace(/[^0-9.]/g,''))||0;
     var vCard=parseFloat(String(wn.ver||'0').replace(/[^0-9.]/g,''))||0;
     if(vNow&&vCard&&(vNow-vCard)>0.15)
       bad.push('the what-is-new card is at v'+wn.ver+' against a build at v'+wn.build);
     if(!wn.lines.length) bad.push('the what-is-new card has no lines');
     return bad.length?bad.join('; '):null; }},
  {v:'9.20',what:'the death screen table reports what the hit actually did, not what was thrown',
   run:function(){
     var bad=[];
     __resetCfg(); __pinDefaults(0);
     __deploy({kit:['plate'],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player; g.ents.length=0;
     function hit(hp0,armor0,amount,name){
       p.hp=hp0; p.maxhp=100; p.armor=armor0; p.iv=0; p.downed=0;
       g.tel.hitLog=[];
       __arm.hurt(amount,'crawler',name,p.x+20,p.y);
       var rows=g.tel.hitLog||[];
       return {row:rows[rows.length-1]||null, hpAfter:Math.max(0,Math.round(p.hp)),
               lost:Math.round(hp0-Math.max(0,p.hp)), downed:!!p.downed};
     }
     // THROUGH ARMOUR. Measured before v9.20: 100 health and 40 armour hit for 30
     // actually loses 15, and the table read DAMAGE 30, HEALTH 100.
     var a=hit(100,40,30,'CRAWLER');
     if(!a.row) return 'no row was written at all, so there is nothing to check';
     if(a.row.a!==a.lost) bad.push('with armour the table says '+a.row.a+' damage where he actually lost '+a.lost);
     if(a.row.hp!==a.hpAfter) bad.push('with armour the table says '+a.row.hp+' health where he actually has '+a.hpAfter);
     // THE KILLING BLOW. Its own note says this column shows the hit the run
     // stopped being winnable on, and it used to print the health he had BEFORE it.
     var b=hit(20,0,60,'PILLAGER');
     if(!b.downed) bad.push('the lethal hit did not put him down, so the killing row cannot be judged');
     else if(b.row.hp!==0) bad.push('the killing blow prints '+b.row.hp+' health, it should print nothing left');
     // CONTROL 1: it must still be LOGGING, with the name, or an empty table
     // satisfies every line above.
     if(!b.row.n) bad.push('control: the row carries no attacker name');
     if(b.row.a<=0) bad.push('control: the row carries no damage');
     // CONTROL 2, AND IT IS THE ONE THAT MATTERS: with NO armour the logged
     // damage must still equal the FULL incoming hit. A fix that simply always
     // reported a smaller number, or halved everything, would satisfy the armour
     // case above and be wrong here.
     var c=hit(100,0,24,'CRAWLER');
     if(c.row.a!==24) bad.push('control: with no armour a 24 hit is logged as '+c.row.a+', it should be the full 24');
     if(c.row.hp!==76) bad.push('control: with no armour a 24 hit leaves '+c.row.hp+' in the table, it should be 76');
     // CONTROL 3: a hit taken while already down must still appear. That branch
     // returns early and is the one the row was moved across.
     p.hp=0; p.armor=0; p.downed=true; p.downT=12; g.tel.hitLog=[];
     __arm.hurt(9,'crawler','CRAWLER',p.x+20,p.y);
     if(!(g.tel.hitLog||[]).length) bad.push('control: a hit taken while downed is missing from the table');
     else if(g.tel.hitLog[g.tel.hitLog.length-1].hp!==0)
       bad.push('control: a hit taken while downed reports health he does not have');
     return bad.length?bad.join('; '):null; }},
  {v:'9.21',what:'the run recorder counts the damage that actually reached him',
   run:function(){
     var bad=[];
     __resetCfg(); __pinDefaults(0);
     __deploy({kit:['plate'],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player; g.ents.length=0;
     function hit(hp0,armor0,amount,src,sim){
       p.hp=hp0; p.maxhp=100; p.armor=armor0; p.iv=0; p.downed=0;
       g.tel.dmg={}; g.tel.hitLog=[];
       var was=g.sim; if(sim) g.sim=1;
       __arm.hurt(amount,src,src.toUpperCase(),p.x+20,p.y);
       g.sim=was;
       var rows=g.tel.hitLog||[];
       return {recorder:g.tel.dmg[src]||0, table:rows.length?rows[rows.length-1].a:null,
               lost:Math.round(hp0-Math.max(0,p.hp))};
     }
     // THROUGH ARMOUR. Measured before v9.21: he loses 15, the table says 15 and
     // the recorder said 30, so every export overstated what reached him by
     // exactly what the plate absorbed.
     var a=hit(100,40,30,'crawler',false);
     if(a.recorder!==a.lost) bad.push('the recorder logs '+a.recorder+' where he actually lost '+a.lost);
     if(a.recorder!==a.table) bad.push('the recorder says '+a.recorder+' and the table on the same screen says '+a.table);
     // CONTROL 1: with no armour it must still be the FULL hit. A recorder that
     // simply reported a smaller number would satisfy the line above.
     var b=hit(100,0,24,'crawler',false);
     if(b.recorder!==24) bad.push('control: with no armour a 24 hit is recorded as '+b.recorder);
     // CONTROL 2, AND IT IS THE ONE THAT MATTERS. This counter exists for the
     // balance batches, which run under the bot. Moving it below a not-a-sim
     // guard would zero every batch and read exactly like a fix.
     var c=hit(100,0,20,'sentry',true);
     if(c.recorder!==20) bad.push('control: under the bot a 20 hit is recorded as '+c.recorder+', the batches would report no damage');
     // CONTROL 3: it must still be counted PER SOURCE, or one total tells me
     // nothing about what is actually killing him.
     p.hp=100; p.armor=0; p.iv=0; p.downed=0; g.tel.dmg={};
     __arm.hurt(10,'crawler','CRAWLER',p.x+20,p.y);
     p.iv=0; __arm.hurt(10,'sentry','SENTRY',p.x+20,p.y);
     var keys=0; for(var k in g.tel.dmg) keys++;
     if(keys<2) bad.push('control: two different attackers collapsed into '+keys+' entry in the recorder');
     return bad.length?bad.join('; '):null; }},
  {v:'9.22',what:'taking one thing out of a crate does not read out what is still inside',
   run:function(){
     var bad=[];
     __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player; g.ents.length=0; p.iv=99;
     function box(){ for(var i=0;i<g.containers.length;i++) if(g.containers[i].loot&&!g.containers[i].opened) return g.containers[i]; return null; }
     var ct=box();
     if(!ct) return 'no unopened container to pull from';
     // DISTINCTIVE ON PURPOSE: three elites nothing else would produce, so a
     // message naming the wrong ones cannot be mistaken for a coincidence.
     ct.loot=['blackbox','reactor','codex']; ct.opened=false;
     g.msg=''; g.bag=[];
     __grant(ct,['blackbox']);
     var said=String(g.msg||'');
     // Measured before v9.22: pulling the Black Box alone printed
     // "Found: Meridian Black Box, Meridian Reactor Core, Sealed Codex".
     if(/Reactor Core/.test(said)) bad.push('a single pull still names the Reactor Core left in the box: "'+said+'"');
     if(/Sealed Codex/.test(said))  bad.push('a single pull still names the Sealed Codex left in the box: "'+said+'"');
     // CONTROL 1: it must still say what he DID take, or going silent would pass
     // both lines above and take away the only feedback a pull has.
     if(!/Black Box/.test(said)) bad.push('control: the pull no longer names the thing he actually took: "'+said+'"');
     if(g.bag.indexOf('blackbox')<0) bad.push('control: the pull did not reach his bag at all');
     // CONTROL 2: THE FULL OPEN IS UNCHANGED. It hands the whole contents in as
     // the keys, so it must still read out every item. A fix that only ever named
     // one thing would satisfy everything above and gut the ordinary open.
     var ct2=box();
     if(ct2){
       ct2.loot=['servo','scrap']; ct2.opened=false;
       g.msg=''; g.bag=[];
       __grant(ct2,ct2.loot);
       var said2=String(g.msg||'');
       if(!/Servo/.test(said2)||!/Scrap/.test(said2))
         bad.push('control: a full open no longer lists everything it gave: "'+said2+'"');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'9.24',what:'picking a downed pillager up is free and costs no medical',
   run:function(){
     var bad=[];
     // The play path: a man on the floor at his feet and the key held down.
     function revive(bag){
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player; p.iv=99;
       g.bag=bag.slice();
       var rd=null;
       for(var i=0;i<g.ents.length;i++) if(g.ents[i].kind==='raider'&&!g.ents[i].merc){ rd=g.ents[i]; break; }
       if(!rd) return null;
       rd.downed=1; rd.downT=30; rd.hp=1; rd.state='down'; rd.x=p.x+20; rd.y=p.y;
       var K=__keysRef(); for(var k in K) delete K[k];
       g.revLock=0; g.msg=''; K['KeyE']=true;
       for(var f=0;f<10;f++) __loop(performance.now()+f*16.7);
       for(var k2 in K) delete K[k2];
       var meds=0; for(var b=0;b<g.bag.length;b++) if(g.bag[b]==='bandage'||g.bag[b]==='medkit') meds++;
       return {up:!rd.downed, said:String(g.msg||''), meds:meds, bag:g.bag.slice(),
               friendly:(rd.hostile===false), hpPct:Math.round(rd.hp/rd.maxhp*100), ent:rd, g:g};
     }
     // HIS INSTRUCTION. Measured before v9.24: an empty bag was refused outright
     // with "No medical to revive him with", and a bandage in the bag was spent.
     var empty=revive([]);
     if(!empty) return 'no pillager on the map to put down';
     if(!empty.up) bad.push('with an empty bag the man on the floor still cannot be helped: "'+empty.said+'"');
     if(/No medical/i.test(empty.said)) bad.push('the refusal is still there: "'+empty.said+'"');
     var withMed=revive(['bandage']);
     if(withMed.meds!==1) bad.push('reviving still spends a medical item, '+withMed.meds+' left of 1');
     // CONTROL 1: it must still WORK, not merely be free. A revive that quietly
     // stopped happening would satisfy both lines above.
     if(!withMed.up) bad.push('control: the revive did not happen at all');
     if(withMed.hpPct<30||withMed.hpPct>50) bad.push('control: he got up on '+withMed.hpPct+' percent health, it should be 40');
     if(!withMed.friendly) bad.push('control: he got up still hostile');
     // CONTROL 2: and it must still PAY, which is his answer 37 from v9.10. Free
     // to give and nothing in return would be a different change from the one he
     // asked for.
     var paid=false;
     for(var q=0;q<withMed.bag.length;q++) if(String(withMed.bag[q]).indexOf('gun_')===0) paid=true;
     if(!paid) bad.push('control: he no longer hands anything over for it');
     // CONTROL 3: his OWN self-revive is a separate thing and is still one a raid.
     // Making one free must not have made the other unlimited.
     var g2=withMed.g, p2=g2.player;
     p2.downed=1; p2.downT=10; p2.revived=false; g2.msg='';
     var K3=__keysRef(); for(var k3 in K3) delete K3[k3];
     K3['KeyF']=true; p2.healLock=false;
     for(var f3=0;f3<6;f3++) __loop(performance.now()+400+f3*16.7);
     var firstUse=!p2.downed;
     p2.downed=1; p2.downT=10; g2.msg='';
     p2.healLock=false;
     for(var f4=0;f4<6;f4++) __loop(performance.now()+800+f4*16.7);
     for(var k4 in K3) delete K3[k4];
     if(firstUse&&!p2.downed) bad.push('control: his own self-revive works twice in one raid now, it is meant to be one');
     return bad.length?bad.join('; '):null; }},
  {v:'9.25',what:'a pillager who was not fighting you fights back the moment you shoot him',
   run:function(){
     var bad=[];
     // ONE ROUND, THEN THE TRIGGER RELEASED. Automatic fire is deliberately not
     // used: the old behaviour woke him only by luck, when some later round
     // happened to land in a window where he was not rolling. One aimed shot and
     // then silence is the case he actually reported, and it is the case that
     // never woke him at all.
     function shoot(mode){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player, tgt=null;
       for(var i=0;i<g.ents.length;i++){ var e=g.ents[i];
         if(e.kind==='raider'&&e.hostile===false&&!e.merc&&!e.friendlyPC&&!e.downed){ tgt=e; break; } }
       if(!tgt) return null;
       if(mode==='ally') tgt.friendlyPC=true;
       g.ents=[tgt]; p.iv=99; p.hp=p.maxhp;
       var gun=__gun.roll('rifle');
       for(var kk in gun) p.wep[kk]=gun[kk];
       p.ammo=gun.mag; p.jam=0;
       // He must SURVIVE to be able to answer. A pillager on his own 78 health
       // dies inside the window and then the question cannot be asked at all.
       tgt.maxhp=100000; tgt.hp=100000;
       // A LINE TO HIM, not a compass direction. Due east was open on the map
       // this was written against and had a wall across it once v9.30 changed the
       // spawn counts, which silently turned this check into a skip.
       (function(){
         var R=400, ok=false;
         for(var a=0;a<24&&!ok;a++){
           var th=a/24*Math.PI*2, px=tgt.x+Math.cos(th)*R, py=tgt.y+Math.sin(th)*R;
           if(window.__los&&!__los.clear(px,py,tgt.x,tgt.y)) continue;
           p.x=px; p.y=py; ok=true;
         }
         if(!ok){ p.x=tgt.x+R; p.y=tgt.y; }
       })();
       var M=__mouse(); M.init=true;
       var K=__keysRef(); for(var k in K) delete K[k];
       var landed=0, hpPrev=tgt.hp, hitAt=-1, hostileAt=-1, backAt=-1, stopAt=-1;
       for(var f=0;f<520;f++){
         var s=__proj.w2s(tgt.x,tgt.y); M.x=s.x; M.y=s.y;
         if(landed<1){ M.down=true; } else { if(stopAt<0) stopAt=f; M.down=false; }
         if(p.ammo<=0) p.ammo=gun.mag;
         __loop(performance.now()+f*16.7);
         if(tgt.hp<hpPrev){ landed++; if(hitAt<0) hitAt=f; hpPrev=tgt.hp; }
         if(hostileAt<0&&tgt.hostile) hostileAt=f;
         if(backAt<0) for(var b=0;b<(g.bullets||[]).length;b++) if(g.bullets[b].owner===tgt) backAt=f;
       }
       M.down=false;
       return {landed:landed,hitAt:hitAt,hostileAt:hostileAt,backAt:backAt,stopAt:stopAt,
               watched:(stopAt>=0?520-stopAt:0),noto:(__P?(__P().notoriety||0):0),tgt:tgt};
     }
     var a=shoot('peaceful');
     if(!a) return 'no peaceful pillager on this map and seed';
     if(a.landed<1) return 'SKIP: could not land a round on him in 520 frames';
     if(a.hostileAt<0)
       bad.push('shot once from 400 units and watched '+a.watched+' frames: he never turned on you');
     else if(a.backAt<0)
       bad.push('he turned hostile but never fired back in '+a.watched+' frames');
     // CONTROL 1: the notoriety charge for shooting a man who was not fighting
     // you must survive. notoAggress only fires while he is still peaceful, so
     // setting the flag one line too early would delete the penalty in silence.
     if(a.noto<1) bad.push('control: shooting a peaceful pillager no longer costs notoriety');
     // CONTROL 2: a pillager fighting ALONGSIDE you must not be turned by a
     // stray round, or the fix reads as "any hit makes anyone an enemy".
     var b2=shoot('ally');
     if(b2&&b2.landed>=1&&b2.tgt.hostile)
       bad.push('control: a stray round turned a pillager who was fighting alongside you');
     return bad.length?bad.join('; '):null; }},
  {v:'9.26',what:'a round that goes past a pillager counts as shooting at him',
   run:function(){
     var bad=[];
     // THE MISS, not the hit. v9.25 already covers the round that connects.
     //
     // THE TARGET IS PINNED, and that is the whole reason this check holds still.
     // A peaceful pillager wanders while he loots, so an unpinned version of this
     // measured a different pass distance every run and said "he turned" and "he
     // did not turn" minutes apart. Pinning him makes the geometry exact: he
     // stands at TX,TY, the player stands 300 east, and the shot is aimed 30 south
     // of him, which puts the round through a corridor about 23 units off his
     // shoulder. That is wider than the 14 that would hit him and inside the 51
     // that counts as being shot at, every single time.
     function miss(mode, wake){
       __resetCfg(); __pinDefaults(0);
       // The setter takes an OBJECT. Passing a name and a value spreads the name
       // string into CFG one character at a time and changes nothing, which cost
       // me a control that reported a dial as stuck when it was never set.
       if(wake!==undefined){
         __cfg({missWake:wake});
         if(__cfg().missWake!==wake) return {dialStuck:__cfg().missWake};
       }
       __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player, tgt=null;
       for(var i=0;i<g.ents.length;i++){ var e=g.ents[i];
         if(e.kind==='raider'&&e.hostile===false&&!e.merc&&!e.friendlyPC&&!e.downed){ tgt=e; break; } }
       if(!tgt) return null;
       if(mode==='ally') tgt.friendlyPC=true;
       g.ents=[tgt]; p.iv=99; p.hp=p.maxhp;
       // Semi automatic on purpose, pulsed, so this is a handful of aimed shots
       // going past him rather than a wall of noise.
       var gun=__gun.roll('dmr');
       for(var kk in gun) p.wep[kk]=gun[kk];
       p.ammo=gun.mag; p.jam=0;
       // He must survive, so a round that does land can be reported rather than
       // silently measured on a corpse.
       tgt.maxhp=100000; tgt.hp=100000;
       var TX=tgt.x, TY=tgt.y;
       // A LINE TO HIM, chosen the same way and for the same reason as in the
       // v9.25 check. The player is pinned to this bearing every frame below.
       var _SA=0;
       for(var _ai=0;_ai<24;_ai++){
         var _th=_ai/24*Math.PI*2;
         var _px=TX+Math.cos(_th)*300, _py=TY+Math.sin(_th)*300;
         if(window.__los&&!__los.clear(_px,_py,TX,TY)) continue;
         _SA=_th; break;
       }
       var _SPX=TX+Math.cos(_SA)*300, _SPY=TY+Math.sin(_SA)*300;
       // Thirty units to the side of him, measured PERPENDICULAR to the firing
       // line rather than always southward, so the miss stays a near miss
       // whatever bearing the open ground turned out to be on.
       var _AX=TX-Math.sin(_SA)*30, _AY=TY+Math.cos(_SA)*30;
       // A CHANGE, NOT A LEVEL. Notoriety is saved in the profile and the corpus
       // shares one, so an absolute test would pass on an earlier check.
       var noto0=(__P?(__P().notoriety||0):0);
       var M=__mouse(); M.init=true;
       var K=__keysRef(); for(var k in K) delete K[k];
       var hpPrev=tgt.hp, landed=0, hostileAt=-1, fired=0, ammoPrev=p.ammo, closest=1e9;
       for(var f=0;f<420;f++){
         tgt.x=TX; tgt.y=TY; p.x=_SPX; p.y=_SPY;
         var s=__proj.w2s(_AX, _AY); M.x=s.x; M.y=s.y; M.down=((f%10)<2);
         if(p.ammo<ammoPrev) fired+=(ammoPrev-p.ammo);
         if(p.ammo<=0) p.ammo=gun.mag;
         ammoPrev=p.ammo;
         __loop(performance.now()+f*16.7);
         tgt.x=TX; tgt.y=TY;
         for(var b=0;b<(g.bullets||[]).length;b++){ var bu=g.bullets[b];
           if(bu.player){ var d=Math.hypot(bu.x-TX,bu.y-TY); if(d<closest) closest=d; } }
         if(tgt.hp<hpPrev){ landed++; hpPrev=tgt.hp; }
         if(hostileAt<0&&tgt.hostile) hostileAt=f;
       }
       M.down=false;
       return {fired:fired, landed:landed, closest:Math.round(closest), hostileAt:hostileAt,
               hostile:!!tgt.hostile, notoGained:((__P?(__P().notoriety||0):0)-noto0),
               alert:tgt.alert||0};
     }
     var a=miss('peaceful');
     if(!a) return 'no peaceful pillager on this map and seed';
     if(a.fired<5) return 'SKIP: the player never fired, nothing to judge';
     if(a.landed>0) return 'SKIP: a round landed, which is the v9.25 case, not this one';
     if(a.closest>50) return 'SKIP: the nearest round passed '+a.closest+' units away, too wide to be a near miss';
     // THE MEASUREMENT. Nothing touched him, and he turned anyway.
     if(a.hostileAt<0)
       bad.push(a.fired+' rounds went past him, nearest '+a.closest+' units off, and none landed: '+
                'he never turned, alert only reached '+(Math.round(a.alert*10)/10));
     // CONTROL 1: it must still cost you. Setting the flag one line above
     // notoAggress would delete the charge for starting on a man who was not
     // fighting you, and nothing else in the game would notice.
     if(a.notoGained<1) bad.push('control: shooting at a peaceful pillager and missing costs no notoriety');
     // CONTROL 2: a pillager fighting ALONGSIDE you must not be turned by rounds
     // going past him, or every firefight beside an ally ends with him on the
     // other side.
     var b3=miss('ally');
     if(b3&&b3.hostile) bad.push('control: rounds past a pillager fighting alongside you turned him');
     // CONTROL 3: THE DIAL MUST BE THE THING DOING IT. With missWake at zero the
     // old behaviour has to come back exactly, or this check is passing on some
     // other route into hostility rather than on the line this build added.
     var c=miss('peaceful',0);
     if(c&&c.dialStuck!==undefined) bad.push('control: missWake did not take, it read back '+c.dialStuck);
     else if(c&&c.hostile) bad.push('control: with missWake off a miss still turned him, so something else is doing it');
     __resetCfg();
     return bad.length?bad.join('; '):null; }},
  {v:'9.27',what:'standing behind a container roof draws you through it instead of swallowing you',
   run:function(){
     var bad=[];
     __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
     var g=__state(), W=g.map.walls;
     // HIS #45, the long container east of the COLD STORAGE starts. Found by
     // shape rather than by index so a map edit moves the check instead of
     // breaking it.
     var wl=null;
     for(var i=0;i<W.length;i++){ var w=W[i];
       if(w.furn||w.wreck||w.ledge||w.win) continue;
       if(w.w>=900&&w.h<=50&&w.x>2500){ wl=w; break; } }
     if(!wl) return 'SKIP: COLD STORAGE no longer has the long container this was measured on';
     var LIFT=wl.lift||((wl.w<=60&&wl.h<=60)?14:26);
     var cx0=wl.x+wl.w*0.5;
     var inBand=Math.round(wl.y-LIFT*0.5);      // inside the drawn roof, north of solid
     // THE DIAL IS THE ONLY THING THAT MOVES. Player, camera, wall and frame are
     // identical between the two reads, which is what makes this a measurement of
     // the ghost rather than of the scenery. Every other way I tried moved the
     // camera with the player and compared two different pictures.
     function ghostPct(py){
       __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242});
       var gg=__state(), pp=gg.player;
       gg.ents.length=0; pp.iv=99;
       pp.x=cx0; pp.y=py;
       var K=__keysRef(); for(var k in K) delete K[k];
       for(var f=0;f<4;f++) __loop(performance.now()+f*16.7);
       var moved=Math.round(Math.hypot(pp.x-cx0,pp.y-py));
       var s=__proj.w2s(pp.x,pp.y);
       var R=14, bx=Math.round(s.x-R), by=Math.round(s.y-R*1.9), bw=R*2, bh=Math.round(R*2.5);
       var cv=__canvases().world, cx=cv.getContext('2d');
       __cfg({seeThrough:1}); __frame(0);
       var A=cx.getImageData(bx,by,bw,bh).data;
       __cfg({seeThrough:0}); __frame(0);
       var B=cx.getImageData(bx,by,bw,bh).data;
       __cfg({seeThrough:1});
       var diff=0, n=A.length/4;
       for(var q=0;q<A.length;q+=4)
         if(Math.abs(A[q]-B[q])+Math.abs(A[q+1]-B[q+1])+Math.abs(A[q+2]-B[q+2])>24) diff++;
       return {pct:Math.round(diff/n*100), pushed:moved};
     }
     var band=ghostPct(inBand);
     // If a later build widens the colliders to match the art, this ground stops
     // being reachable and the whole question goes away. Say so rather than
     // failing, because that would be a fix too, just a much bigger one.
     if(band.pushed>6)
       return 'SKIP: the drawn roof is solid now, this ground is no longer reachable, so there is nothing to draw through';
     if(band.pct<15)
       bad.push('standing '+Math.round(LIFT*0.5)+' units inside the container roof, nothing is drawn through it: '+
                band.pct+' percent of the box responds to the dial');
     // CONTROL 1: IN FRONT OF IT, where he is plainly visible already, the ghost
     // must not fire. A version that simply drew a second operator every frame
     // would satisfy the line above and look wrong everywhere.
     var front=ghostPct(wl.y+wl.h+18);
     if(front.pct>4) bad.push('control: standing in front of the container, something is still drawn through it ('+front.pct+' percent)');
     // CONTROL 2: and well clear to the north, where the art never reaches.
     var clear=ghostPct(wl.y-LIFT-18);
     if(clear.pct>4) bad.push('control: standing clear of the container, something is still drawn through it ('+clear.pct+' percent)');
     __resetCfg();
     return bad.length?bad.join('; '):null; }},
  {v:'9.28',what:'a pillager who spots you calls his crew, and only his crew, and only in earshot',
   run:function(){
     var bad=[];
     // THE STAGE. One crew, nobody else on the map. The SPOTTER stands 300 units
     // from the player looking straight at him. The rest huddle 780 from the
     // player, which is past the 620 they can see, and 480 from the spotter,
     // which is well inside a shout. So the only thing that can involve them is
     // the call. Measured before this build: exactly one man came.
     function stage(mode,frames){
       __resetCfg(); __pinDefaults(0);
       if(mode==='off')   __cfg({crewCall:0});
       if(mode==='cap1')  __cfg({crewMax:1});
       __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player, byCrew={};
       for(var i=0;i<g.ents.length;i++){ var e=g.ents[i];
         if(e.kind==='raider'&&!e.merc){ (byCrew[e.crew]=byCrew[e.crew]||[]).push(e); } }
       var best=null;
       for(var k in byCrew) if(!best||byCrew[k].length>best.length) best=byCrew[k];
       if(!best||best.length<3) return null;
       g.ents=best.slice(); p.iv=99; p.hp=p.maxhp;
       var sp=g.ents[0];
       sp.x=p.x+300; sp.y=p.y; sp.hostile=true; sp.state='loot';
       sp.face=Math.atan2(p.y-sp.y,p.x-sp.x);
       for(var q=1;q<g.ents.length;q++){
         var m=g.ents[q];
         m.x=p.x+780+(q*14); m.y=p.y+(q%2?60:-60); m.state='loot';
         m.face=Math.atan2(-1,0);
         m.hostile=(mode==='peaceful')?false:true;
         if(mode==='othercrew') m.crew=sp.crew+7;
         if(mode==='faraway'){ m.x=p.x+3000; m.y=p.y+3000; }
       }
       var K=__keysRef(); for(var k2 in K) delete K[k2];
       for(var f=0;f<frames;f++) __loop(performance.now()+f*16.7);
       var chasing=0;
       for(var r=0;r<g.ents.length;r++) if(g.ents[r].state==='chase') chasing++;
       var out={crewSize:g.ents.length, chasing:chasing, called:(g.tel&&g.tel.crewCalls)||0};
       __resetCfg();
       return out;
     }
     var a=stage('normal',180);
     if(!a) return 'SKIP: no crew of three on this map and seed to stage the call with';
     // HIS 36. The shout has to actually carry.
     if(a.called<1)
       bad.push('a pillager shouted that he had found you and nobody came: '+a.chasing+' of '+a.crewSize+' in the fight');
     // CONTROL 1: THE DIAL MUST BE THE THING DOING IT, or this passes on some
     // other route into the fight rather than on the call.
     var off=stage('off',180);
     if(off&&off.called>0) bad.push('control: with crewCall off the shout still called '+off.called+' men');
     if(off&&off.chasing>1) bad.push('control: with crewCall off, '+off.chasing+' men are in the fight, so something else is pulling them');
     // CONTROL 2: THE CAP IS REAL. Without this the fix could be "the whole map
     // comes", which is a different game and not what he asked for.
     var cap=stage('cap1',180);
     if(cap&&cap.called>1) bad.push('control: crewMax 1 still called '+cap.called+' men');
     // CONTROL 3: HIS CREW, NOT EVERY PILLAGER. Crews are the whole point; a call
     // that pulls strangers would delete the distinction.
     var other=stage('othercrew',180);
     if(other&&other.called>0) bad.push('control: the shout pulled '+other.called+' men from a different crew');
     // CONTROL 4: A PEACEFUL MAN IS NOT IN YOUR FIGHT. Being conscripted by a
     // crewmate's shout would turn every sighting into a brawl with people who
     // had no quarrel with you, and would quietly undo v9.25 and v9.26.
     var peace=stage('peaceful',180);
     if(peace&&peace.called>0) bad.push('control: the shout conscripted '+peace.called+' pillagers who were not fighting you');
     // CONTROL 5: EARSHOT. A shout must not cross the map.
     var far=stage('faraway',180);
     if(far&&far.called>0) bad.push('control: the shout carried 3000 units and called '+far.called+' men');
     return bad.length?bad.join('; '):null; }},
  {v:'9.29',what:'a called crew comes at you from different sides instead of in single file',
   run:function(){
     var bad=[];
     // PAIRED, and that is the point of it. On a freshly loaded page this reads a
     // stable 146 degrees against 52 with the stations off, identical every run.
     // Run after seventy other checks it wandered between 57 and 165, which is the
     // same shape as the crate reach check I had to pull at v9.23: stable alone,
     // unstable in company. So the check never asks for an absolute. It measures
     // the same scene twice in the same session and asks only that the arm with
     // stations is wider. Whatever the corpus does to the world, it does to both.
     // The clock is fixed rather than wall time for the same reason.
     function sep(spread){
       __resetCfg(); __pinDefaults(0);
       __cfg({crewSpread:spread});
       if(__cfg().crewSpread!==spread) return {dialStuck:__cfg().crewSpread};
       __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player, byCrew={};
       for(var i=0;i<g.ents.length;i++){ var e=g.ents[i];
         if(e.kind==='raider'&&!e.merc){ (byCrew[e.crew]=byCrew[e.crew]||[]).push(e); } }
       var best=null;
       for(var k in byCrew) if(!best||byCrew[k].length>best.length) best=byCrew[k];
       if(!best||best.length<3) return null;
       g.ents=best.slice(); p.iv=99;
       // He must survive the whole engagement or the scene ends early and the
       // question of where they stood cannot be asked.
       p.maxhp=100000; p.hp=100000;
       var sp=g.ents[0];
       sp.x=p.x+300; sp.y=p.y; sp.hostile=true; sp.state='loot';
       sp.face=Math.atan2(p.y-sp.y,p.x-sp.x);
       for(var q=1;q<g.ents.length;q++){ var m=g.ents[q];
         m.x=p.x+780+(q*14); m.y=p.y+(q%2?60:-60); m.hostile=true; m.state='loot';
         m.face=Math.atan2(-1,0); }
       var PX=p.x, PY=p.y;
       var K=__keysRef(); for(var k2 in K) delete K[k2];
       // He is pinned. A player who backs away turns this into a measurement of
       // his own retreat rather than of their approach.
       for(var f=0;f<600;f++){ p.x=PX; p.y=PY; __loop(100000+f*16.7); }
       var spB=Math.atan2(sp.y-PY,sp.x-PX)*57.3, maxSep=0, n=0;
       for(var r=0;r<g.ents.length;r++){ var e2=g.ents[r];
         if(e2===sp||e2.state!=='chase') continue;
         n++;
         var b=Math.atan2(e2.y-PY,e2.x-PX)*57.3, dd=Math.abs(b-spB);
         if(dd>180) dd=360-dd; if(dd>maxSep) maxSep=dd; }
       __resetCfg();
       return {called:n, sep:Math.round(maxSep)};
     }
     var on=sep(1);
     if(!on) return 'SKIP: no crew of three on this map and seed to stage the call with';
     if(on.dialStuck!==undefined) return 'control: crewSpread did not take, it read back '+on.dialStuck;
     var off=sep(0);
     if(off&&off.dialStuck!==undefined) return 'control: crewSpread did not take, it read back '+off.dialStuck;
     // Both arms must actually have men in the fight, or there is nothing to
     // compare and a silent zero would read as a pass.
     if(on.called<1||!off||off.called<1)
       return 'SKIP: the shout called nobody in one of the arms, so there is no formation to measure';
     // HIS 36, the half about arriving as a crew rather than as a line. Measured
     // before the stations went in: three men on bearings 13, 10 and -1, with the
     // closest pair three degrees apart, walking to one point in single file.
     if((on.sep-off.sep)<40)
       bad.push('a called crew still arrives in single file: furthest man is '+on.sep+
                ' degrees off the spotter with stations on and '+off.sep+' with them off');
     return bad.length?bad.join('; '):null; }},
  {v:'9.30',what:'the crawler count follows the houses, the surplus is outside, and no house holds four',
   run:function(){
     var bad=[];
     // HIS ANSWERS 2, 3 AND 5 TOGETHER, because they only make sense together:
     //   "2 house occupancy about right; house = any indoor structure."
     //   "3 never more than 3 per house."
     //   "5 crawler count = houses x 2.5, keep some outside."
     // Leave the insides alone, put the difference on the street.
     function survey(mapIx,perHouse){
       __resetCfg(); __pinDefaults(mapIx);
       if(perHouse!==undefined){
         __cfg({crawlerPerHouse:perHouse});
         if(__cfg().crawlerPerHouse!==perHouse) return {dialStuck:__cfg().crawlerPerHouse};
       }
       __startRaid({mapIx:mapIx,seed:4242});
       var g=__state(), B=g.map.buildings||[], pool=[];
       for(var i=0;i<B.length;i++){ var b=B[i]; if(b.w>=80&&b.h>=80) pool.push(b); }
       if(!pool.length) return null;
       var craw=0, inside=0, per={};
       for(var j=0;j<g.ents.length;j++){ var e=g.ents[j];
         if(e.kind!=='crawler') continue;
         craw++;
         for(var k=0;k<pool.length;k++){ var bb=pool[k];
           if(e.x>bb.x&&e.x<bb.x+bb.w&&e.y>bb.y&&e.y<bb.y+bb.h){ inside++; per[k]=(per[k]||0)+1; break; } }
       }
       var occ=0, most=0;
       for(var q in per){ occ++; if(per[q]>most) most=per[q]; }
       __resetCfg();
       return {houses:pool.length, crawlers:craw, per:craw/pool.length,
               inside:inside, outside:craw-inside, pctOcc:Math.round(occ/pool.length*100), most:most};
     }
     var maps=[{ix:0,name:'COLD STORAGE'},{ix:1,name:'THE COLD MILE'}];
     for(var m=0;m<maps.length;m++){
       var a=survey(maps[m].ix);
       if(!a) return 'SKIP: '+maps[m].name+' has no buildings big enough to count as houses';
       if(a.dialStuck!==undefined) return 'control: crawlerPerHouse did not take, it read back '+a.dialStuck;
       // HIS 5, the count. 2.2 rather than 2.5 because the placer works in whole
       // crawlers against a house pool that excludes anything near the landing,
       // so the ratio measured against every big building lands a little under.
       if(a.per<2.2)
         bad.push(maps[m].name+' has '+a.crawlers+' crawlers for '+a.houses+' houses, '+
                  (Math.round(a.per*100)/100)+' each, and he asked for 2.5');
       // HIS 5 again, the other half: "keep some outside". Most of the extra ones
       // must be on the street, not stuffed into more houses.
       if(a.outside<a.inside)
         bad.push(maps[m].name+' put '+a.inside+' crawlers indoors and only '+a.outside+
                  ' outside, so the count went into the houses rather than the streets');
       // HIS 3. This is the one the higher count could break, and did on the first
       // cut: a house held four.
       if(a.most>3)
         bad.push(maps[m].name+' has a house holding '+a.most+' crawlers, and he said never more than 3');
       // HIS 2, and the line my own v8.86 check calls a tax rather than a gamble.
       // A building you clear and find nothing in is what makes the next one worth
       // being careful about.
       if(a.pctOcc>90)
         bad.push(maps[m].name+' is '+a.pctOcc+' percent occupied, so there are no empty houses left to find');
     }
     // CONTROL: THE DIAL MUST BE THE THING DOING IT. With crawlerPerHouse off the
     // count falls back to the old area figure, which proves this check is reading
     // the new rule and not some unrelated change to how many machines spawn.
     var off=survey(0,0);
     if(off&&off.per>2.0)
       bad.push('control: with crawlerPerHouse off the count is still '+
                (Math.round(off.per*100)/100)+' per house, so something else is setting it');
     return bad.length?bad.join('; '):null; }},
  {v:'9.31',what:'an item can be taken back off the belt during a raid, and a click on its own slot is not that',
   run:function(){
     var bad=[];
     // HIS 11, the half that only ever worked in the Undercroft. Driven with real
     // keyboard and mouse events rather than by calling into the drag state, so
     // this is the gesture and not a description of it.
     function drag(mode){
       __resetCfg(); __pinDefaults(0);
       // THE BELT PLAN IS SAVED IN THE PROFILE. Without clearing it each run
       // inherits the last one, and the second measurement is of the first. This
       // cost me a reading that said the unbind fired when it had not.
       try{ __P().hotAssign={}; }catch(_pe){}
       __deploy({kit:['bandage','medkit'],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player; p.iv=99;
       g.hotAssign={}; g.hotAuto={};
       var K=__keysRef(); for(var k in K) delete K[k];
       window.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyI',bubbles:true}));
       window.dispatchEvent(new KeyboardEvent('keyup',{code:'KeyI',bubbles:true}));
       for(var f=0;f<8;f++) __loop(performance.now()+f*16.7);
       __frame(0);
       if(!g.bagOpen) return {err:'the backpack did not open on I'};
       if(!(g.bagCells||[]).length||!(g.hotCells||[]).length) return {err:'no cells laid out'};
       var M=__mouse(), hcv=document.getElementById('hcv'), cv=document.getElementById('cv');
       function at(c){ M.x=c.x+c.w/2; M.y=c.y+c.h/2; }
       // The press is on a canvas and the release is on the window, which is how
       // the game binds them; sending the press to all three is simply belt and
       // braces against that changing.
       function down(){ [hcv,cv,window].forEach(function(t){ try{ t.dispatchEvent(new MouseEvent('mousedown',{button:0,bubbles:true})); }catch(_de){} }); }
       function up(){ window.dispatchEvent(new MouseEvent('mouseup',{button:0,bubbles:true})); }
       var bagCell=g.bagCells[0], slot=g.hotCells[4], other=g.hotCells[5], key=bagCell.key;
       at(bagCell); down(); at(slot); up(); __frame(0);
       var assigned=((g.hotAssign||{})[4]===key);
       if(mode==='sameSlot'){ at(slot); down(); at(slot); up(); }
       if(mode==='otherSlot'){ at(slot); down(); at(other); up(); }
       if(mode==='toBag'){ at(slot); down(); at(bagCell); up(); }
       __frame(0);
       var a=g.hotAssign||{};
       return {key:key, assigned:assigned, slot5:a[4], slot6:a[5], inBag:(g.bag.indexOf(key)>=0)};
     }
     var off=drag('toBag');
     if(off.err) return 'SKIP: '+off.err;
     // The other half has to work first, or nothing below means anything.
     if(!off.assigned) return 'the drag ONTO the belt stopped working, so the drag off cannot be judged';
     // HIS 11. Measured before this build: the slot still read the item.
     if(off.slot5!==undefined)
       bad.push('dragging '+off.key+' off the belt into the backpack left slot 5 still holding it');
     // CONTROL 1: it must come off the BELT, not out of existence. An unbind that
     // ate the item would satisfy the line above.
     if(!off.inBag) bad.push('control: the item vanished from the backpack instead of just leaving the belt');
     // CONTROL 2: PICKING IT UP AND PUTTING IT STRAIGHT BACK IS A CLICK. v8.14
     // established that and my own first cut of this build broke it, clearing the
     // slot on a gesture that is meant to select.
     var same=drag('sameSlot');
     if(!same.err&&same.slot5!==same.key)
       bad.push('control: dropping '+same.key+' back on its own slot cleared it, and that gesture is a click');
     // CONTROL 3: A MOVE IS STILL A MOVE. Dropping on a different slot must
     // relocate rather than unbind, or the fix has eaten rearranging the bar.
     var moved=drag('otherSlot');
     if(!moved.err&&(moved.slot6!==moved.key||moved.slot5!==undefined))
       bad.push('control: moving '+moved.key+' from slot 5 to slot 6 did not move it, slot5='+
                moved.slot5+' slot6='+moved.slot6);
     return bad.length?bad.join('; '):null; }},
  {v:'9.32',what:'you can see the item in your hand while you drag it round the Undercroft backpack',
   run:function(){
     if(!__vpAlive()) return 'SKIP: the pane has no layout, so nothing can be measured in pixels';
     __forceSize(1920,1080);
     if(!__hubEnter()) return 'could not reach the Undercroft floor';
     var P=__P();
     P.kit=['medkit','plate','servo','scrap','bandage']; P.hotAssign={};
     var K=__keysRef(); for(var k in K) delete K[k];
     __hubBag(false);
     document.body.dispatchEvent(new KeyboardEvent('keydown',{code:'KeyI',bubbles:true}));
     __hubStep(1/60); __hubStep(1/60);
     var L=__hubBagLive();
     if(!L) return 'the Undercroft backpack kept no state to drag with';
     var bc=L.bagCells||[], hc=L.hotCells||[];
     if(!bc.length||hc.length<5) return 'SKIP: the Undercroft backpack drew no cells to measure against';
     var M=__mouse(), cv=document.getElementById('hcv'), cx=cv.getContext('2d');
     function box(x,y,r){
       var d=cx.getImageData(Math.round(x-r),Math.round(y-r),r*2,r*2).data, s=0;
       for(var i=0;i<d.length;i+=4) s+=d[i]+d[i+1]+d[i+2];
       return s;
     }
     // THE HUB DRAWS ON ITS OWN STEP. __renderStage does not redraw this screen,
     // and measuring through it said the fix had not worked when it had. The
     // control below is what caught that and it stays in for good.
     function draw(){ __hubStep(1/60); }
     var bad=[];
     // CONTROL FIRST, deliberately: hovering a belt cell WITH something in hand
     // highlights it, and that has worked since v8.96. If this does not respond
     // the panel is not being redrawn and every reading below is meaningless.
     var hot=hc[4];
     M.x=hot.x+hot.w/2; M.y=hot.y+hot.h/2;
     L.drag=null; draw(); var h0=box(M.x,M.y,20);
     L.drag={key:'medkit',bagIx:0}; draw(); var h1=box(M.x,M.y,20);
     if(h0===h1){ L.drag=null; draw();
       return 'SKIP: the Undercroft backpack is not redrawing, so nothing here can be measured'; }
     // HIS 11, the other half. Measured on v9.31: identical pixels with and
     // without something in hand, so between picking an item up and putting it
     // down there was no sign you were holding anything.
     var cell=bc[0];
     M.x=cell.x+cell.w*0.5; M.y=cell.y-70;      // open floor above the panel
     L.drag=null; draw(); var g0=box(M.x,M.y,26);
     L.drag={key:'medkit',bagIx:0}; draw(); var g1=box(M.x,M.y,26);
     if(g0===g1) bad.push('nothing is drawn at the cursor while an item is in hand on the Undercroft floor');
     L.drag=null; draw();
     return bad.length?bad.join('; '):null; }},
  {v:'9.33',what:'proficiency is his five things mixed, and each one of them moves it',
   run:function(){
     var bad=[];
     // WHAT HE WOULD SEE, before anything else. The old build shows a card called
     // "Net carried out" and never uses the word proficiency anywhere.
     var _cardTxt='';
     try{
       __P().log=[{outcome:'extract',haul:9000,shots:50,hits:30,acc:60,downs:0,
                   dmg:{sentry:40,crawler:0,raider:0,snitch:0,other:0}}];
       // The cards are built when the hub is shown; there is no separate stats screen,
       // and asking for one returned an empty grid that silently skipped this test.
       if(typeof __showScreen==='function') __showScreen('hub');
       var _g=document.getElementById('statgrid');
       _cardTxt=_g?(_g.textContent||''):'';
     }catch(_ce){}
     if(_cardTxt&&!/proficiency/i.test(_cardTxt))
       bad.push('the stats screen still never says proficiency: it reads "'+
                _cardTxt.replace(/\s+/g,' ').slice(0,90)+'"');
     if(!window.__prof)
       return bad.length?bad.join('; '):'SKIP: the screen looks right but the fixture has no handle on the arithmetic';
     // DISTINCTIVE RUNS, not plausible ones. Every figure below is picked so that
     // a formula ignoring the part under test would give itself away: the good log
     // is good at everything and the probes are each bad at exactly one thing.
     function run(o){
       return {outcome:o.outcome||'extract', haul:(o.haul===undefined?12000:o.haul),
               shots:100, hits:(o.hits===undefined?100:o.hits),
               acc:(o.acc===undefined?100:o.acc),
               downs:(o.downs===undefined?0:o.downs),
               dmg:{sentry:(o.hurt===undefined?0:o.hurt),crawler:0,raider:0,snitch:0,other:0}};
     }
     function log(n,o){ var a=[]; for(var i=0;i<n;i++) a.push(run(o)); return a; }
     var perfect=null;
     try{ perfect=window.__prof.parts(log(10,{})); }catch(_pe){}
     if(!perfect) return bad.length?bad.join('; '):'the rating returned nothing for ten clean runs';
     if(perfect.score<95)
       bad.push('ten flawless runs score only '+perfect.score+' out of 100');
     // AND THE FLOOR. Without this, a formula that always returns 100 passes.
     var awful=window.__prof.parts(log(10,{outcome:'dead',haul:0,hits:0,acc:0,downs:3,hurt:900}));
     if(awful.score>8)
       bad.push('ten runs that failed at everything still score '+awful.score+' out of 100');
     // HIS FIVE, ONE AT A TIME. Each probe is perfect except for one ingredient,
     // so a part that is not wired in shows up as a score that did not move.
     var probes=[
       {k:'money extracted',   o:{haul:0},                    w:'money'},
       {k:'extract versus die',o:{outcome:'dead'},            w:'out'},
       {k:'times downed',      o:{downs:3},                   w:'up'},
       {k:'accuracy',          o:{hits:0,acc:0},              w:'aim'},
       {k:'damage per raid',   o:{hurt:900},                  w:'hurt'}
     ];
     for(var i=0;i<probes.length;i++){
       var pr=window.__prof.parts(log(10,probes[i].o));
       if(!pr){ bad.push('the rating returned nothing for the '+probes[i].k+' probe'); continue; }
       if(pr.score>=perfect.score)
         bad.push('being bad at '+probes[i].k+' did not lower the rating at all: '+
                  pr.score+' against '+perfect.score);
       if(pr.parts[probes[i].w]>0.35)
         bad.push('the '+probes[i].k+' part still reads '+Math.round(pr.parts[probes[i].w]*100)+
                  ' percent when that is the one thing the runs were bad at');
     }
     // CONTROL: ABANDONING IS NOT DYING. He can back out of a raid and that is a
     // decision, not a failure, so it must not be counted against the extract
     // ratio the way a death is.
     var quit=window.__prof.parts(log(10,{outcome:'abandon'}));
     var died=window.__prof.parts(log(10,{outcome:'dead'}));
     if(quit&&died&&quit.parts.out<=died.parts.out)
       bad.push('control: backing out of ten raids is scored no better than dying in ten');
     // CONTROL: the weights must still add up to something the score is divided
     // by, or the number stops being out of a hundred.
     var W=window.__prof.weights(), sum=0;
     for(var w in W) sum+=W[w];
     if(sum<=0) bad.push('control: the weights sum to '+sum+', so the score is not out of anything');
     return bad.length?bad.join('; '):null; }},
  {v:'9.34',what:'calling the ship names the siege, and the number it promises is the number that arrives',
   run:function(){
     var bad=[];
     // HIS 6: "he does not know what a siege is". He could not have: the line
     // explaining it was written and then overwritten in the same frame, because
     // say() replaces rather than queues. Measured before this build, an empty bag
     // and a bag worth 37,500 were told exactly the same two sentences.
     function call(rich,thenRun){
       __resetCfg(); __pinDefaults(0);
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player; p.iv=99; p.maxhp=100000; p.hp=100000;
       g.ents.length=0;
       // DISTINCTIVE, not plausible: the two most expensive guns in the game, ten
       // of them, against nothing at all. Anything that ignores the bag gives
       // itself away across a gap that wide.
       g.bag=rich?['gun_lance','gun_sniper','gun_lance','gun_sniper','gun_lance',
                   'gun_sniper','gun_lance','gun_sniper','gun_lance','gun_sniper']:[];
       var z=null,bd=1e9;
       for(var i=0;i<g.zones.length;i++){
         var d=Math.hypot(g.zones[i].x-p.x,g.zones[i].y-p.y);
         if(d<bd){ bd=d; z=g.zones[i]; } }
       if(!z) return null;
       p.x=z.x; p.y=z.y;
       var K=__keysRef(); for(var k in K) delete K[k];
       K['KeyE']=true;
       for(var f=0;f<200;f++){
         __loop(performance.now()+f*16.7);
         if(z.beaconT!==null&&z.beaconT!==undefined&&f>30) break; }
       var msg=String(g.msg||'');
       var out={called:(z.beaconT!==null&&z.beaconT!==undefined), msg:msg,
                greed:(g.tel&&g.tel.callGreed)||0,
                promised:((/about (\d+) machines/.exec(msg)||[])[1]||null)};
       if(out.promised) out.promised=+out.promised;
       if(thenRun){
         // Stand in the ring and let the whole siege run in.
         for(var f2=0;f2<2600;f2++){ p.x=z.x; p.y=z.y; __loop(performance.now()+4000+f2*16.7); }
         var m=0;
         for(var e=0;e<g.ents.length;e++){ var kk=g.ents[e].kind; if(kk!=='raider'&&kk!=='stray') m++; }
         out.arrived=m;
       }
       for(var k2 in K) delete K[k2];
       return out;
     }
     var heavy=call(true,true);
     if(!heavy) return 'SKIP: no extraction ring on this map and seed to call from';
     if(!heavy.called) return 'SKIP: holding E in the ring did not call the ship';
     // HIS 6, the word itself.
     if(!/siege/i.test(heavy.msg))
       bad.push('calling the ship still never uses the word siege: "'+heavy.msg.slice(0,80)+'"');
     // AND A NUMBER HE CAN COUNT.
     if(heavy.promised===null)
       bad.push('the call says nothing about how many are coming');
     // THE CONTROL THAT MATTERS MOST, and the one that caught my own first cut
     // promising exactly twice what turned up: the number in the warning has to be
     // the number he will see, or the warning teaches him to ignore warnings.
     else if(heavy.arrived!==undefined&&Math.abs(heavy.arrived-heavy.promised)>1)
       bad.push('the call promised '+heavy.promised+' machines and '+heavy.arrived+' arrived');
     // CONTROL: the bag has to change the number, or it is a decoration rather
     // than the price of what he is carrying.
     var light=call(false,false);
     if(light&&light.promised!==null&&heavy.promised!==null&&light.promised>=heavy.promised)
       bad.push('control: an empty bag is promised '+light.promised+' machines and a bag worth '+
                heavy.greed+' is promised '+heavy.promised+', so what he carries changes nothing');
     // CONTROL: and the two bags must not be told the same sentence, which is
     // exactly what the old build did.
     if(light&&light.msg===heavy.msg)
       bad.push('control: an empty bag and a full one are told word for word the same thing');
     return bad.length?bad.join('; '):null; }},
  {v:'9.35',what:'the raid clock has an off position, and still kills you when it is on',
   run:function(){
     var bad=[];
     // HIS 6, second half: "nothing should be meant to end the raid." The clock is
     // the one thing whose whole purpose is to end it, the code called expiry
     // "death and full loss", and the slider bottomed out at two minutes.
     function run(sec,frames){
       __resetCfg(); __pinDefaults(0);
       __cfg({raidSec:sec});
       if(__cfg().raidSec!==sec) return {dialStuck:__cfg().raidSec};
       __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       // He must not die of anything else, or the reading is about a crawler.
       p.iv=99; p.maxhp=100000; p.hp=100000;
       g.ents.length=0;
       var K=__keysRef(); for(var k in K) delete K[k];
       var ended=-1;
       for(var f=0;f<frames;f++){
         __loop(performance.now()+f*16.7);
         if(ended<0&&(g.over||g.nuking)) ended=f;
       }
       var closed=0;
       for(var z=0;z<g.zones.length;z++) if(g.zones[z].open===false) closed++;
       var out={endedAt:ended, over:!!g.over, nuking:!!g.nuking, gT:Math.round(g.t),
                killer:(g.tel&&g.tel.deathKiller)||null, ringsClosed:closed, zones:g.zones.length};
       __resetCfg();
       return out;
     }
     // OFF. Twenty seven seconds of raid, which is nearly twice the shortest clock
     // the slider used to allow, and nothing may end it.
     var off=run(0,1600);
     if(off.dialStuck!==undefined) return 'control: raidSec did not take, it read back '+off.dialStuck;
     if(off.endedAt>=0)
       bad.push('with the raid timer OFF the raid still ended at frame '+off.endedAt+
                (off.killer?(' with the killer recorded as '+off.killer):''));
     // AND THE RINGS MUST STAY OPEN. Their closing times are measured against the
     // clock, so a clock that does not move must not close them. Without this a
     // "fix" that only stopped the death would still squeeze him off the map.
     if(off.ringsClosed>0)
       bad.push('with the timer OFF, '+off.ringsClosed+' of '+off.zones+' extraction rings closed anyway');
     // AND THE RUN MUST STILL KNOW HOW LONG IT TOOK. Duration is read off the
     // clock everywhere else, so holding the clock still could have reported every
     // raid as instantaneous.
     if(off.gT<10)
       bad.push('with the timer OFF the raid recorded only '+off.gT+' seconds of elapsed time');
     // CONTROL: THE CLOCK MUST STILL WORK. This is the line that stops the fix
     // being "the timer is gone", which is not what he asked for. Fifteen seconds
     // of clock has to run out and it has to be fatal, exactly as before.
     var on=run(15,1600);
     if(on.dialStuck!==undefined) return 'control: raidSec did not take, it read back '+on.dialStuck;
     if(on.endedAt<0)
       bad.push('control: a 15 second raid timer never ran out across 1600 frames, so the clock is simply gone');
     else if(on.killer!=='timer')
       bad.push('control: the timer ran out and the killer was recorded as '+on.killer+' rather than the timer');
     return bad.length?bad.join('; '):null; }},
  {v:'9.36',what:'HEAVY PATROLS buys forty percent more crawlers, the same as it buys of everything else',
   run:function(){
     var bad=[];
     // A REGRESSION I SHIPPED AT v9.30. The term promises "forty percent more of
     // everything out there" and he pays thirty percent hazard pay for it. The
     // crawler floor added at v9.30 took the larger of the area figure and a
     // house-derived one, and the house one knew nothing about terms, so it
     // overwrote the term for the largest population on both maps.
     // Measured before the fix, plain against the term: sentries 16 to 23 and
     // pillagers 7 to 10 on COLD STORAGE, and crawlers 52 to 54.
     function count(mapIx,onTerm){
       __resetCfg(); __pinDefaults(mapIx);
       // NOT restored to what was there: restored to NOTHING. Handing back a
       // contaminated value is how this leaked in the first place.
       var P=__P();
       P.terms = onTerm?['patrols']:[];
       __startRaid({mapIx:mapIx,seed:4242});
       var g=__state(), c={};
       for(var i=0;i<g.ents.length;i++){ var k=g.ents[i].kind; c[k]=(c[k]||0)+1; }
       P.terms=[]; try{ saveProfile(); }catch(e){}
       __resetCfg();
       return c;
     }
     var maps=[{ix:0,name:'COLD STORAGE'},{ix:1,name:'THE COLD MILE'}];
     for(var m=0;m<maps.length;m++){
       var off=count(maps[m].ix,false), on=count(maps[m].ix,true);
       if(!off.crawler||!off.sentry){ bad.push(maps[m].name+' built no crawlers or no sentries to compare'); continue; }
       var cUp=(on.crawler-off.crawler)/off.crawler;
       var sUp=(on.sentry-off.sentry)/off.sentry;
       // CONTROL FIRST: the term has to be doing anything at all, or a broken
       // fixture would read as a broken game. Sentries were never affected by the
       // v9.30 floor, so they are the honest yardstick.
       if(sUp<0.25){
         bad.push('control: HEAVY PATROLS only raised sentries on '+maps[m].name+' by '+
                  Math.round(sUp*100)+' percent, so the term is not being applied and nothing below means anything');
         continue;
       }
       // THE FINDING. 25 percent rather than 40 because the counts are whole
       // machines against a house pool that shifts with the landing, but the
       // defect showed 4 percent and 2 percent, so there is no overlap.
       if(cUp<0.25)
         bad.push('on '+maps[m].name+' HEAVY PATROLS raised sentries by '+Math.round(sUp*100)+
                  ' percent and crawlers by only '+Math.round(cUp*100)+
                  ' percent, so the term is not buying the crawlers it charges for');
     }
     // CONTROL: and with the term OFF the crawler count must still follow the
     // houses, which is what v9.30 was for. Multiplying the floor must not have
     // quietly replaced it.
     var plain=count(0,false);
     var g2=null;
     __resetCfg(); __pinDefaults(0); __startRaid({mapIx:0,seed:4242}); g2=__state();
     var pool=0, B=g2.map.buildings||[];
     for(var b=0;b<B.length;b++) if(B[b].w>=80&&B[b].h>=80) pool++;
     __resetCfg();
     if(pool&&(plain.crawler/pool)<2.2)
       bad.push('control: with no term the crawler count fell back to '+
                (Math.round(plain.crawler/pool*100)/100)+' per house, and his figure is 2.5');
     return bad.length?bad.join('; '):null; }},
  {v:'9.37',what:'you cannot abandon a run while you are bleeding out, and you still can on your feet',
   run:function(){
     var bad=[];
     // FREE INSURANCE. Being downed does not set G.over, so for the whole
     // seventeen second bleed-out the pause box still offered Abandon run, and
     // abandoning runs a different branch from dying: the death branch strips both
     // carried weapons out of the armoury and the abandon branch does not. The
     // entire price of turning a death into a walk-away was the XP fee.
     function stage(down){
       __resetCfg(); __pinDefaults(0);
       var P=__P();
       P.weapons=['pistol'];
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.ents.length=0;
       if(down){ p.downed=true; p.downT=15; p.hp=0; }
       else { p.downed=false; p.hp=p.maxhp; p.iv=99; }
       try{ togglePauseBox(true); }catch(e){ return {err:'the pause box would not open: '+e}; }
       var ab=document.getElementById('abandonbtn');
       var ca=document.getElementById('confirmabandon');
       var bl=document.getElementById('pausebleed');
       // THE BUTTON IS A TOGGLE: armed once, the next press disarms. Without this
       // the second stage cancelled what the first stage had armed and reported
       // that backing out was broken on a build where it works.
       if(ca) ca.style.display='none';
       if(ab) ab.textContent='Abandon run';
       var shown=!!(ab&&ab.style.display!=='none');
       // Press it. Hiding a control is presentation; the handler is the rule, and
       // the box can already be open when you go down.
       if(ab) try{ ab.click(); }catch(e2){}
       var armed=!!(ca&&ca.style.display!=='none');
       var told=!!(bl&&bl.style.display!=='none');
       var over=!!g.over;
       try{ togglePauseBox(false); }catch(e3){}
       __resetCfg();
       return {abandonShown:shown, confirmArmed:armed, toldWhy:told, raidOver:over};
     }
     var downed=stage(true);
     if(downed.err) return 'SKIP: '+downed.err;
     // THE FINDING.
     if(downed.abandonShown)
       bad.push('the pause box still offers Abandon run while you are bleeding out');
     if(downed.confirmArmed)
       bad.push('pressing Abandon while bleeding out still arms the confirm, so the run can be walked away from on the floor');
     // A control that silently vanishes teaches nothing, so it has to say why.
     if(!downed.abandonShown&&!downed.toldWhy&&document.getElementById('pausebleed'))
       bad.push('the abandon controls are gone while downed but nothing on screen says why');
     // CONTROL: ON YOUR FEET IT MUST STILL WORK. Without this the fix could be
     // "abandoning is gone", which would be a different and much worse change.
     var up=stage(false);
     if(!up.err){
       if(!up.abandonShown)
         bad.push('control: Abandon run is missing even when you are on your feet and unhurt');
       if(!up.confirmArmed)
         bad.push('control: pressing Abandon on your feet no longer arms the confirm, so backing out is broken');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'9.38',what:'shooting a Listener does not switch it off',
   run:function(){
     var bad=[];
     // The Listener's whole behaviour lives behind state 'hunt'. Every other state
     // falls into an else that stops it moving, which is right for 'dormant' and
     // wrong for 'chase' - a state the bullet path and the frag path both write on
     // anything that is not a raider or a snitch. So one round used to freeze the
     // one enemy built around not being seen coming.
     function stand(putInChase){
       __resetCfg(); __pinDefaults(0);
       __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player, L=null;
       for(var i=0;i<g.ents.length;i++) if(g.ents[i].kind==='listener'){ L=g.ents[i]; break; }
       if(!L) return null;
       g.ents=[L];
       // He must be hittable and must survive, so the only thing the count can be
       // measuring is whether the Listener swings.
       p.iv=0; p.maxhp=100000; p.hp=100000;
       var PX=L.x-(L.r+11+2), PY=L.y;      // just inside its reach
       p.x=PX; p.y=PY;
       L.state='hunt'; L.wakeT=0; L.heardX=PX; L.heardY=PY;
       L.maxhp=100000; L.hp=100000; L.cd=0;
       var K=__keysRef(); for(var k in K) delete K[k];
       // This is exactly what a landed round does to it.
       if(putInChase){ L.state='chase'; L.tx=PX; L.ty=PY; }
       var hits=0, hpPrev=p.hp;
       for(var f=0;f<420;f++){
         // Pinned, or the measurement becomes about his retreat.
         p.x=PX; p.y=PY; p.iv=0;
         __loop(performance.now()+f*16.7);
         if(p.hp<hpPrev){ hits++; hpPrev=p.hp; }
       }
       return {hits:hits, state:L.state};
     }
     // CONTROL FIRST: a Listener left alone at this range must land blows, or the
     // staging is wrong and nothing below means anything.
     var alone=stand(false);
     if(!alone) return 'SKIP: no Listener on this map and seed to stand next to';
     if(alone.hits<1)
       return 'SKIP: a Listener that was never shot landed nothing either, so this scene is not measuring its attacks';
     // THE FINDING. Measured before the fix: 9 hits left alone, 0 after a round.
     var shot=stand(true);
     if(shot&&shot.hits<1)
       bad.push('a Listener put into the state a landed round gives it stopped attacking entirely: '+
                alone.hits+' hits when left alone, '+shot.hits+' after being shot');
     return bad.length?bad.join('; '):null; }},
  {v:'9.39',what:'the last-minute warnings name a way out that is actually open',
   run:function(){
     var bad=[];
     // The rings close on fractions of the clock REMAINING, two thirds and four
     // ninths, so on the default 540 second raid they shut with 360 and 240 left
     // while the warnings only speak at 180, 120, 60 and 30. Every warning lands
     // after both closures, so a shut ring is always a candidate and whether it
     // gets named depends only on where he is standing.
     function warn(closeTheNearOne){
       __resetCfg(); __pinDefaults(0);
       __startRaid({mapIx:0,seed:4242});
       var g=__state(), p=g.player;
       g.ents.length=0; p.iv=99; p.maxhp=100000; p.hp=100000;
       var near=null,nd=1e9;
       for(var i=0;i<g.zones.length;i++){
         var d=Math.hypot(g.zones[i].x-p.x,g.zones[i].y-p.y);
         if(d<nd){ nd=d; near=g.zones[i]; } }
       if(!near||g.zones.length<2) return null;
       for(var j=0;j<g.zones.length;j++) g.zones[j].open=true;
       if(closeTheNearOne) near.open=false;
       // The nearest OPEN ring, worked out here rather than asked of the game, so
       // the check is not grading the thing it is testing.
       var openD=1e9;
       for(var q=0;q<g.zones.length;q++) if(g.zones[q].open!==false)
         openD=Math.min(openD,Math.hypot(g.zones[q].x-p.x,g.zones[q].y-p.y));
       g.timeLeft=31; g.lastWarn=-1; g.msg='';
       var K=__keysRef(); for(var k in K) delete K[k];
       var said='';
       for(var f=0;f<140;f++){
         __loop(performance.now()+f*16.7);
         var m=String(g.msg||'');
         if(/THIRTY SECONDS/i.test(m)){ said=m; break; }
       }
       // AFTER, not before. The rings close on the clock, so anything forced open
       // at 31 seconds is shut again on the next frame.
       var openAfter=1e9, closedAfter=1e9, nOpen=0;
       for(var r2=0;r2<g.zones.length;r2++){
         var Z2=g.zones[r2], d2=Math.hypot(Z2.x-p.x,Z2.y-p.y);
         if(Z2.open===false) closedAfter=Math.min(closedAfter,d2);
         else { nOpen++; openAfter=Math.min(openAfter,d2); }
       }
       var told=(/([0-9]+)m/.exec(said)||[])[1];
       return {said:said, told:(told?+told*10:null),
               closedAt:(closedAfter<1e9?Math.round(closedAfter):null),
               openAt:(openAfter<1e9?Math.round(openAfter):null),
               openCount:nOpen};
     }
     var shut=warn(true);
     if(!shut) return 'SKIP: this map and seed does not have two extraction rings to choose between';
     // CONTROL FIRST: the warning has to fire, or nothing below is being measured.
     if(!shut.said) return 'SKIP: the thirty second warning never fired, so there is no hint to grade';
     if(shut.openAt===null||shut.closedAt===null)
       return 'SKIP: at thirty seconds this seed did not leave one ring open and one shut, so there is nothing to choose between';
     if(shut.told===null) bad.push('the thirty second warning names no distance at all: "'+shut.said+'"');
     else {
       // THE FINDING. Measured before the fix: closed ring 1,406 units away, nearest
       // open one 2,612, and it said 141m, which is the closed one, with thirty
       // seconds left and no time to correct the mistake.
       var toOpen=Math.abs(shut.told-shut.openAt), toClosed=Math.abs(shut.told-shut.closedAt);
       if(toClosed<toOpen)
         bad.push('with thirty seconds left it points at the CLOSED ring: it said '+
                  Math.round(shut.told/10)+'m, the shut ring is '+Math.round(shut.closedAt/10)+
                  'm away and the nearest open one is '+Math.round(shut.openAt/10)+'m');
     }
     // CONTROL: it must name the nearest OPEN ring, not merely any open one. A fix
     // of "always pick the furthest" would pass the line above and be no better.
     // Graded against the rings that were actually open when it spoke.
     if(shut.told!==null&&shut.openAt!==null&&Math.abs(shut.told-shut.openAt)>260)
       bad.push('control: it said '+Math.round(shut.told/10)+
                'm when the nearest OPEN ring was '+Math.round(shut.openAt/10)+'m');
     return bad.length?bad.join('; '):null; }},
  {v:'9.40',what:'the Peddler does not promise your money survives your death',
   run:function(){
     var bad=[];
     // MEASURE WHAT HAPPENS FIRST, then read what he was told. The other way round
     // grades a sentence against my opinion instead of against the game.
     __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(), p=g.player;
     g.ents.length=0; p.iv=99;
     var P=__P(), before=P.credits||0;
     // Stall money, exactly as a sale would leave it.
     g.pedCarry=5000;
     __endRaid('dead');
     var afterDeath=(__P().credits||0)-before;
     // And the other outcome, from a clean raid, so the comparison is real.
     __resetCfg(); __pinDefaults(0);
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g2=__state(); g2.ents.length=0; g2.player.iv=99;
     var before2=(__P().credits||0);
     g2.pedCarry=5000;
     __endRaid('extract');
     var afterExtract=(__P().credits||0)-before2;
     // CONTROL FIRST: extracting has to pay it, or this scene is not wired up and
     // the promise cannot be judged against anything.
     if(afterExtract<5000)
       return 'SKIP: walking out did not bank the stall money either, so this scene is not measuring the promise';
     var survivesDeath=(afterDeath>=5000);
     var promise=window.__ped?window.__ped.promise():null;
     // NOT A SKIP. A sell panel whose terms are written inline in the draw cannot
     // be checked against what the game actually does, and that is exactly how the
     // promise and the behaviour drifted apart in the first place. The terms
     // living in one readable place is part of the fix, so its absence is a
     // failure rather than an excuse.
     if(promise===null)
       bad.push('the sell terms are not in one place, so nothing can check them against what dying actually does');
     else {
     // THE FINDING. The panel used to say "Yours even if you die out there" while
     // the death screen said "Stall money lost where you fell".
     if(!survivesDeath&&/even if you die/i.test(promise))
       bad.push('the sell panel promises "'+promise+'" and dying loses every credit of it');
     // AND THE OTHER WAY ROUND, so a later change that makes the money genuinely
     // safe cannot leave the panel understating it.
     if(survivesDeath&&/walk it out|have to walk/i.test(promise))
       bad.push('the sell panel says you have to walk the money out, and dying kept it');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'9.48',what:'buildings do not all wear the identical floor',
   run:function(){
     var bad=[];
     __resetCfg(); __pinDefaults(0); __cleanProfile();

     // I TRIED TO READ THIS OFF THE BAKED PIXELS ALONE and it does not work: the
     // ground canvas carries interior walls, furniture, wrecks and stains as well
     // as the floor, so a scanline across a building crosses 22 dark features
     // where the grid has 12. On a build where EVERY floor was the same 46 pixel
     // grid my first signature reported 39 different treatments. It passed on the
     // OLD build, which is the only reason I caught it.
     // So: the mechanism for the distribution, and a real pixel diff between two
     // buildings of the SAME footprint for the part that has to be visual.
     function survey(mapIx){
       __deploy({kit:[],safe:null,mapIx:mapIx,seed:4242});
       var g=__state(), m=g.map, gr=g.ground, B=m.buildings||[], out=[];
       for(var i=0;i<B.length;i++){
         var b=B[i]; if(b.w<60||b.h<60) continue;
         out.push({i:i,wh:Math.round(b.w)+'x'+Math.round(b.h),f:__bld.floor(b),
                   x:b.x,y:b.y,w:b.w,h:b.h});
       }
       return {list:out,ground:gr};
     }
     var s0=survey(0), s1=survey(1);
     if(s0.list.length<8||s1.list.length<20)
       return 'SKIP: only '+s0.list.length+' and '+s1.list.length+' buildings big enough to read';
     if(!(window.__bld&&window.__bld.floor)||s1.list[0].f===null)
       return 'every building on both maps draws the identical floor: this build has no per-building floor at all';
     // THE FINDING. Measured on v9.47: all 104 buildings on both maps drew the
     // identical 46 pixel grid both ways and the identical hazard stripe, and 45
     // of the 84 on THE COLD MILE are the same 320x240 box as well.
     [{s:s0,name:'COLD STORAGE'},{s:s1,name:'THE COLD MILE'}].forEach(function(q){
       var c={}, kinds=0, top=0;
       for(var i=0;i<q.s.list.length;i++){ var k=q.s.list[i].f;
         if(c[k]===undefined){ c[k]=0; kinds++; } c[k]++; if(c[k]>top) top=c[k]; }
       var share=100*top/q.s.list.length;
       if(kinds<3) bad.push(q.name+' paints '+q.s.list.length+' buildings with '+kinds+' floor'+(kinds===1?'':'s'));
       if(share>55) bad.push(q.name+' gives '+share.toFixed(0)+' percent of its buildings the same floor');
     });
     // AND THE SAME EVERY RAID, or the map stops being learnable, which is the
     // whole reason the geography is fixed rather than generated.
     var again=survey(1), moved=0;
     for(var i=0;i<Math.min(again.list.length,s1.list.length);i++)
       if(again.list[i].f!==s1.list[i].f) moved++;
     if(moved) bad.push(moved+' buildings changed their floor between two raids on the same seed');
     // AND IT HAS TO BE VISIBLE. Two buildings of the SAME footprint with
     // DIFFERENT floors, diffed pixel for pixel in the canvas the game actually
     // bakes. Same size, so any difference is the floor and not the geometry.
     var byWh={}, pair=null;
     for(i=0;i<s1.list.length;i++){
       var b=s1.list[i];
       if(!byWh[b.wh]) byWh[b.wh]=[];
       byWh[b.wh].push(b);
     }
     for(var wh in byWh){
       var arr=byWh[wh];
       for(i=0;i<arr.length&&!pair;i++) for(var j=i+1;j<arr.length;j++)
         if(arr[i].f!==arr[j].f){ pair=[arr[i],arr[j]]; break; }
       if(pair) break;
     }
     // A PIXEL DIFF CANNOT ANSWER THIS and I tried. Two buildings of the same
     // footprint sit in different places, so the district gradient, the stains,
     // the interior walls and the furniture all differ too: they came back 100
     // percent different on a build where their floors were identical. What IS
     // worth asserting is that the variety is reachable at all, which is a
     // property of the hash and not of my opinion.
     if(!pair) bad.push('no two buildings of the same size wear different floors, so the variety is unreachable in practice');     return bad.length?bad.join('; '):null; }},
  {v:'9.47',what:'a crew that loses you searches as a crew, not as a queue',
   run:function(){
     var bad=[];
     __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:1,seed:4242});
     var g=__state(), m=g.map, WW=m.cols*m.cw, WH=m.rows*m.ch;
     // AN ARENA BUILT FROM THE MAP. An open stand with four clear bearings at 240
     // units, and a spot hidden from ALL FOUR posts, not merely from the stand.
     // My first cut only hid him from the stand and three men walked straight at
     // him because they could still see him from where they were standing.
     var A=null;
     for(var px=400; px<WW-400 && !A; px+=130){
      for(var py=400; py<WH-400 && !A; py+=130){
       if(!__nav.free(px,py,18)||!__nav.reachable(px,py)) continue;
       var open=[],a,th,ex,ey;
       for(a=0;a<16&&open.length<4;a++){
         th=a*Math.PI/8; ex=px+Math.cos(th)*240; ey=py+Math.sin(th)*240;
         if(ex<70||ey<70||ex>WW-70||ey>WH-70) continue;
         if(!__nav.free(ex,ey,16)||!__nav.reachable(ex,ey)) continue;
         if(!__los.clear(px,py,ex,ey)) continue;
         open.push({x:ex,y:ey});
       }
       if(open.length<4) continue;
       var hid=null;
       for(a=0;a<32&&!hid;a++){
         var t2=a*Math.PI/16;
         for(var r=300;r<=560;r+=30){
           var hx=px+Math.cos(t2)*r, hy=py+Math.sin(t2)*r;
           if(hx<70||hy<70||hx>WW-70||hy>WH-70) continue;
           if(!__nav.free(hx,hy,16)||!__nav.reachable(hx,hy)) continue;
           var blind=true;
           for(var q=0;q<open.length;q++) if(__los.clear(open[q].x,open[q].y,hx,hy)){ blind=false; break; }
           if(blind){ hid={x:hx,y:hy}; break; }
         }
       }
       if(hid) A={px:px,py:py,posts:open,hid:hid};
      }
     }
     if(!A) return 'SKIP: this map has no open stand with four clear bearings and a spot hidden from all of them';
     function run(dial){
       __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:1,seed:4242});
       if(dial!==null) __cfg({crewSearch:dial});
       var G2=__state(), pp=G2.player, crew=[], i;
       for(i=0;i<G2.ents.length&&crew.length<4;i++) if(G2.ents[i].kind==='raider') crew.push(G2.ents[i]);
       if(crew.length<4) return {skip:'only '+crew.length+' pillagers on this map'};
       G2.ents.length=0; for(i=0;i<crew.length;i++) G2.ents.push(crew[i]);
       pp.x=A.px; pp.y=A.py; pp.iv=9999; pp.downed=false; G2.pCrouch=false;
       for(i=0;i<crew.length;i++){
         var e=crew[i];
         e.x=A.posts[i].x; e.y=A.posts[i].y;
         e.hostile=true; e.merc=false; e.friendlyPC=0; e.downed=false; e.grudge=true;
         e.state='patrol'; e.alert=0; e.cd=0;
         if(e.crewArc!==undefined) delete e.crewArc;
         if(e.searchArc!==undefined) delete e.searchArc;
         e.face=Math.atan2(pp.y-e.y,pp.x-e.x);
       }
       for(var f=0;f<25;f++) __ents(1/60);
       var chasing=[];
       for(i=0;i<crew.length;i++) if(crew[i].state==='chase') chasing.push(crew[i]);
       if(chasing.length<3) return {skip:'only '+chasing.length+' of 4 entered chase from a clear 240 unit sighting'};
       pp.x=A.hid.x; pp.y=A.hid.y;
       var sighted=0;
       for(i=0;i<chasing.length;i++) if(__los.clear(chasing[i].x,chasing[i].y,pp.x,pp.y)) sighted++;
       if(sighted) return {skip:sighted+' of them can still see the hidden spot'};
       // A few frames so each man has decided where to look, then read the
       // DECISIONS. Positions cannot answer this: they start 184 units apart on
       // their posts and close on the sighting, so any spread measured from where
       // they stand is measuring my arena and not the game.
       for(var f2=0;f2<30;f2++) __ents(1/60);
       var tgts=[], np=0, pts={};
       for(i=0;i<chasing.length;i++){
         var e2=chasing[i];
         var tx2=(e2.searchX===undefined)?e2.tx:e2.searchX;
         var ty2=(e2.searchY===undefined)?e2.ty:e2.searchY;
         tgts.push({x:tx2,y:ty2});
         var key=Math.round(tx2/60)+':'+Math.round(ty2/60);
         if(!pts[key]){ pts[key]=1; np++; }
       }
       var closest=1e9;
       for(i=0;i<tgts.length;i++) for(var j=i+1;j<tgts.length;j++){
         var d=Math.hypot(tgts[i].x-tgts[j].x,tgts[i].y-tgts[j].y);
         if(d<closest) closest=d;
       }
       // And they have to actually GO there, or a decision nobody acts on is not a
       // behaviour. Distance closed on his own chosen point over 60 more frames.
       var before=[], after=[];
       for(i=0;i<chasing.length;i++) before.push(Math.hypot(chasing[i].x-tgts[i].x,chasing[i].y-tgts[i].y));
       for(var f3=0;f3<60;f3++) __ents(1/60);
       for(i=0;i<chasing.length;i++) after.push(Math.hypot(chasing[i].x-tgts[i].x,chasing[i].y-tgts[i].y));
       var closedOn=0;
       for(i=0;i<before.length;i++) if(after[i]<before[i]-20) closedOn++;
       return {n:chasing.length, closestPair:Math.round(closest), distinctSpots:np,
               walkedToIt:closedOn, readBack:(dial===null?null:__cfg().crewSearch)};
     }
     var on=run(1);
     if(on.skip) return 'SKIP: '+on.skip;
     var off=run(0);
     if(off.skip) return 'SKIP: '+off.skip;
     // CONTROL FIRST, AND IT IS THE ONE THAT MATTERS: the dial has to be live. If
     // both arms agree, suspect the setter before the design - it has cost a build
     // before. crewSearch 0 must reproduce the old queue exactly.
     if(off.readBack!==0||on.readBack!==1)
       bad.push('control: the dial did not read back, on='+on.readBack+' off='+off.readBack);
     if(off.closestPair>20)
       bad.push('control: with the fan switched off the crew chose points '+off.closestPair+
                ' units apart, and the old behaviour sends every man to the same one');
     // THE FINDING. Measured on v9.46: three men, all targeting one point to the
     // unit, finishing 22, 29 and 53 units apart.
     if(on.closestPair<=100)
       bad.push(on.n+' pillagers lost him and the two closest chose points '+on.closestPair+
                ' units apart, which is the queue slice 2 was written to remove');
     if(on.walkedToIt<2)
       bad.push('only '+on.walkedToIt+' of '+on.n+' actually walked toward the place they chose');
     if(on.distinctSpots<2)
       bad.push(on.n+' pillagers searched '+on.distinctSpots+' place between them');
     // CONTROL TWO: they must still GO somewhere. A fan that sends everyone home
     // is not a search, and standing still would satisfy the spread test.
     if(on.closestPair>700)
       bad.push('control: the crew chose points '+on.closestPair+' units apart, which is scattering rather than searching');
     return bad.length?bad.join('; '):null; }},
  {v:'9.46',what:'the controls legend can be clicked where it is drawn',
   run:function(){
     var bad=[];
     if(!__vpAlive()) return 'SKIP: the pane has no layout, nothing can be drawn or hit';
     if(!(window.__textTrace&&window.__hudHit&&window.__hudBox))
       return 'SKIP: this build cannot report where it drew or what it would hit';
     __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     __state().legendOn=1;
     // The panel anchors off LAST frame's measurement, so one frame proves
     // nothing. Ten, then measure the eleventh.
     for(var f=0;f<10;f++) __frame(0.016);
     var draws=__textTrace(function(){ __frame(0.016); });
     var cv=document.querySelector('canvas'), H=cv.height;
     // Found by the legend's OWN words, so the vitals text sitting directly
     // below it cannot contaminate the extent.
     var LBL=['move','sprint','crouch','roll','fire','aim','reload','swap gun',
              'hotbar','bag','search','map','H  full list'];
     var leg=[], i;
     for(i=0;i<draws.length;i++) if(LBL.indexOf(draws[i].t)>=0) leg.push(draws[i]);
     // CONTROL FIRST: if the legend did not draw, there is nothing to grade and
     // every assertion below would pass on an empty screen.
     if(leg.length<10) return 'SKIP: the legend drew only '+leg.length+' of its 13 rows';
     var top=leg[0].y, bot=leg[0].y;
     for(i=1;i<leg.length;i++){ if(leg[i].y<top) top=leg[i].y; if(leg[i].y>bot) bot=leg[i].y; }
     var box=__hudBox().legend;
     if(!box) return 'SKIP: this build records no hit box for the legend';
     function ask(x,y){ var h=__hudHit(x,y); return h?h.id:'nothing'; }
     var lx=Math.round(leg[0].x)+4;
     // THE FINDING. Measured on v9.45 at 3840x2160: painted 1898 to 2216,
     // recorded 1356 to 1749, clicking the visible legend answered body and
     // clicking empty air 400 pixels above it answered legend. At 1920x1080 the
     // same error is 8 pixels, which is why no check had ever caught it.
     if(bot>box.y+box.h+2)
       bad.push('the legend paints down to '+Math.round(bot)+' and its hit box ends at '+
                Math.round(box.y+box.h)+', so its last '+Math.round(bot-(box.y+box.h))+' pixels are not clickable');
     if(top<box.y-2)
       bad.push('the legend paints from '+Math.round(top)+' and its hit box starts at '+Math.round(box.y));
     // ASK THE GAME, not my copy of its rule.
     var atMid=ask(lx,Math.round((top+bot)/2)), atFoot=ask(lx,Math.round(bot)-2);
     if(atMid!=='legend') bad.push('clicking the middle of the drawn legend answers '+atMid);
     if(atFoot!=='legend') bad.push('clicking its last line answers '+atFoot);
     // AND IT HAS TO BE ON THE SCREEN AT ALL.
     if(bot>H) bad.push('the legend last line is drawn '+Math.round(bot-H)+' pixels below the bottom of the screen');
     if(box.y+box.h>H+2) bad.push('the legend hit box runs '+Math.round(box.y+box.h-H)+' pixels off the bottom');
     // CONTROL TWO: a hit box big enough to swallow the screen would satisfy
     // every line above and break every other panel.
     if(box.h>H*0.5) bad.push('control: the legend hit box is '+Math.round(box.h)+' tall on a '+H+' screen');
     // CONTROL THREE: the OTHER panels must still answer for themselves. If the
     // legend now covers them, this was fixed by breaking the rest of the HUD.
     var B=__hudBox(), k;
     for(k in B){
       if(k==='legend'||!B[k]) continue;
       var who=ask(Math.round(B[k].x+B[k].w/2),Math.round(B[k].y+B[k].h/2));
       if(who==='legend') bad.push('control: the middle of the '+k+' panel now answers legend');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'9.45',what:'rigs are out of the game, and what he already owned was paid for',
   run:function(){
     var bad=[];
     __resetCfg(); __pinDefaults(0); __cleanProfile();
     var RIGS=['rig_light','rig_medium','rig_heavy'];
     var I=__items();
     // THE ITEMS THEMSELVES.
     for(var r=0;r<RIGS.length;r++) if(I[RIGS[r]]) bad.push(RIGS[r]+' is still in the item table as '+I[RIGS[r]].name);
     // AND WHAT ACTUALLY DROPS, rolled through the real container maker rather
     // than read off the weight tables, because a table is not what stocks a raid.
     // Measured on v9.44: 96 rigs in 4,449 loot keys, 2.16 percent. Safes 3.65,
     // caches 4.59, bodies 1.30. Roughly one thing in 46 was armour he could not
     // put on.
     var kinds=['safe','body','cache','locker','crate'], rigs=0, keys=0, where=[];
     for(var t=0;t<kinds.length;t++){
       var kr=0,kk=0;
       for(var i=0;i<300;i++){
         var c=__mkContainer(kinds[t]), L=(c&&c.loot)||[];
         for(var j=0;j<L.length;j++){ kk++; if(String(L[j]).indexOf('rig_')===0) kr++; }
       }
       rigs+=kr; keys+=kk;
       if(kr) where.push(kinds[t]+' '+kr+' of '+kk);
     }
     if(rigs) bad.push(rigs+' rigs still dropped across '+keys+' loot keys: '+where.join(', '));
     // CONTROL ONE: the containers must still be putting things in themselves. An
     // empty loot table would satisfy every line above.
     if(keys<2000) bad.push('control: 1,500 containers produced only '+keys+' items, so nothing is being stocked');
     // CONTROL TWO, AND THE IMPORTANT ONE: ARMOUR IS NOT RIGS. The rig ITEMS are
     // out; the armour ceiling every operator wears is not, and deleting it would
     // take armour out of the game rather than rigs out of the loot.
     if(window.__rigs){
       if(__rigs.wornId()!=='std') bad.push('control: the operator is wearing '+__rigs.wornId()+' rather than the standard armour');
       if(!(__rigs.armorCap()>0)) bad.push('control: the armour ceiling is '+__rigs.armorCap()+', so armour is gone as well as rigs');
       var AT=__rigs.armorTable();
       if(AT.length<2) bad.push('control: the armour table has '+AT.length+' entries left');
     }
     // WHAT HE ALREADY OWNED. Distinctive amounts, so a fallback that pays a flat
     // rate or pays nothing cannot look like a pass: one of each, 360 + 1,280 +
     // 3,120 = 4,760, plus one thing that is not a rig and must survive untouched.
     if(window.__rigs&&__rigs.buyback){
       var fake={credits:77,stash:['relay','rig_light','gun_lance','rig_medium','rig_heavy','relay'],junk:{rig_heavy:1,relay:1}};
       var got=__rigs.buyback(fake);
       if(got===null) bad.push('this build has no buyback at all, so a saved stash keeps three keys with no row in the item table');
       else {
         if(got.n!==3) bad.push('the buyback took '+got.n+' rigs out of a stash holding 3');
         if(got.credits!==4760) bad.push('the buyback paid '+got.credits+' for one of each rig, which were worth 360, 1,280 and 3,120');
         if(fake.credits!==77+4760) bad.push('the credits went 77 to '+fake.credits+' and should have gone to '+(77+4760));
         for(var q=0;q<fake.stash.length;q++)
           if(String(fake.stash[q]).indexOf('rig_')===0) bad.push('a rig survived the buyback in the stash');
         // CONTROL THREE: it must take ONLY the rigs. A buyback that empties the
         // stash would satisfy every line above and rob him.
         var relays=0, lances=0;
         for(var q2=0;q2<fake.stash.length;q2++){
           if(fake.stash[q2]==='relay') relays++;
           if(fake.stash[q2]==='gun_lance') lances++;
         }
         if(relays!==2||lances!==1)
           bad.push('control: the buyback also took '+(2-relays)+' relays and '+(1-lances)+' guns out of the stash');
         if(fake.junk&&fake.junk.rig_heavy!==undefined) bad.push('the junk tag for a rig outlived the rig');
         if(!(fake.junk&&fake.junk.relay!==undefined)) bad.push('control: the buyback cleared a junk tag that was not a rig');
         // AND IT MUST NOT PAY TWICE. Running it again on the same profile is the
         // shape a missing stamp takes.
         var again=__rigs.buyback(fake);
         if(again&&(again.n||again.credits)) bad.push('running the buyback a second time paid another '+again.credits);
       }
     }
     return bad.length?bad.join('; '):null; }},
  {v:'9.44',what:'Wirt does not sell you a loss on his ten thousand credit counter',
   run:function(){
     var bad=[];
     __resetCfg(); __pinDefaults(0); __cleanProfile();
     if(!window.__wirt) return 'SKIP: this build has no counter at Wirt';
     var pool=__wirt.pool(), price=__wirt.price();
     // HIS ANSWER 48 IS THE FIXED POINT. The price is his and nothing here may
     // move it; only what stands behind it.
     if(price!==10000) bad.push('control: the lot costs '+price+' and his answer 48 said 10k');
     if(pool.length<4) bad.push('control: the counter draws from only '+pool.length+' lots');
     var P=__P();
     for(var i=0;i<pool.length;i++){
       // A lot was a bare string before v9.44. Normalised so this check reads an
       // older build honestly rather than grading the letters of a word.
       var lot=(typeof pool[i]==='string')?[pool[i]]:pool[i], head=lot[0], nm=[];
       for(var j=0;j<lot.length;j++) nm.push(lot[j]);
       // THE FINDING. Measured on v9.43: every one of the eight things on the
       // counter cost 10,000 and sold for between 1,700 and 4,600.
       var worth=__wirt.worth?__wirt.worth(lot):null;
       if(worth!==null&&worth<=price)
         bad.push('the lot '+nm.join(' + ')+' costs '+price+' and is worth '+worth+' across the counter');
       // AND IT MUST NOT BE A PRINTER THE OTHER WAY. A lot you can sell back for
       // more than you paid is free money every hour, forever.
       var back=0;
       for(var b=0;b<lot.length;b++) back+=__ival(lot[b]);
       if(back>=price)
         bad.push('the lot '+nm.join(' + ')+' sells straight back for '+back+' against a price of '+price);
       // PURE SALVAGE CANNOT BE SOLD TO A PLAYER AT ANY PRICE, which is why six
       // of the old eight were unfixable rather than mispriced. Every lot needs at
       // least one thing you would actually use.
       var usable=0;
       for(var u=0;u<lot.length;u++) if(__stashRules&&!__stashRules.sellable(lot[u])) usable++;
       if(!usable) bad.push('the lot '+nm.join(' + ')+' is nothing but salvage, so it can only be sold back');
     }
     // WHAT HE READS, drawn, not grepped. The shop's weapon footnote said the
     // Whisper and the Meridian Lance are "never sold, by anyone" on a screen
     // where Wirt has always sold the Lance.
     if(window.__shopPanel){
       var wi=__shopPanel.weaponIndex();
       if(wi>=0){
         var txt=(__shopPanel.detail(wi)||'').replace(/\s+/g,' ');
         var sellsLance=false, sellsWhisper=false;
         for(var s=0;s<pool.length;s++){
           var pl=(typeof pool[s]==='string')?[pool[s]]:pool[s];
           for(var s2=0;s2<pl.length;s2++){
             if(pl[s2]==='gun_lance') sellsLance=true;
             if(pl[s2]==='gun_whisper') sellsWhisper=true;
           }
         }
         if((sellsLance||sellsWhisper)&&/never sold,? by anyone/i.test(txt))
           bad.push('the shop footnote says those two are never sold by anyone, on a screen where Wirt sells them');
         // CONTROL: the footnote has to still BE there. Deleting it would satisfy
         // the line above and lose the one place the game explains its own stock.
         if(txt.length<40) bad.push('control: the weapon footnote is gone entirely, '+txt.length+' characters');
       }
     }
     // AND THE PANEL HAS TO SHOW THE LOT. A bundle he cannot see is a bundle he
     // will not buy, and the worth line is the only way he can check the deal.
     if(__vpAlive()){
       __hubEnter();
       var c0=P.credits; P.credits=25000;
       var multi=-1;
       for(var m=0;m<pool.length;m++) if(pool[m].length>1){ multi=m; break; }
       try{ __wirt.render(); }catch(e){ return 'SKIP: the counter would not draw, '+e; }
       var el=document.getElementById('wirtlot');
       var h=el?el.textContent.replace(/\s+/g,' '):'';
       var lk=__wirt.key();
       var live=(typeof lk==='string')?[lk]:lk;
       if(live&&live.length>1&&!/with /.test(h))
         bad.push('the counter is holding a lot of '+live.length+' things and names only one of them');
       var lw=__wirt.worth?__wirt.worth(live):null;
       if(!/Worth \$/.test(h)&&lw!==null&&lw>price)
         bad.push('the counter never says what the lot is worth, so the deal cannot be checked');
       P.credits=c0;
     }
     return bad.length?bad.join('; '):null; }},
  {v:'9.43',what:'the workshop does not charge for servicing a gun that cannot wear',
   run:function(){
     var bad=[];
     __resetCfg(); __pinDefaults(0); __cleanProfile();
     var P=__P(), T=__guns.tiers(), guns=[], k;
     for(k in T) if(k!=='fists') guns.push(k);
     if(!guns.length) return 'SKIP: no guns in the table';
     P.weapons=guns.slice();
     P.wear=P.wear||{};
     // MEASURE THE GUN FIRST, then read the bill. A gun that genuinely gets worse
     // with use has earned its repair, and this check has nothing to say about it.
     var anyMoves=false;
     for(var i=0;i<guns.length;i++){
       var a=__wear.at(guns[i],0), z=__wear.at(guns[i],4000);
       if(a.spread!==z.spread||a.reload!==z.reload||a.band!==z.band||z.jam) anyMoves=true;
     }
     if(anyMoves) return 'SKIP: some gun still changes with use, so servicing buys something';
     // THE FINDING. Measured on v9.42: every one of the fifteen guns billed, and
     // the Tacker asked 540 credits and two Servo Actuators against a replacement
     // cost of 900.
     var billed=[];
     for(var j=0;j<guns.length;j++){
       P.wear[guns[j]]=1600;
       var c=__repair.cost(guns[j]);
       P.wear[guns[j]]=0;
       if(c&&(c.credits>0||c.parts>0))
         billed.push(guns[j]+' '+c.credits+'c + '+c.parts+'x '+c.part+
                     ' against '+__repair.replace(guns[j])+' to replace it');
     }
     if(billed.length)
       bad.push(billed.length+' guns are billed for a service that changes nothing about them: '+
                billed.slice(0,3).join(', '));
     // AND THE BUTTON, not just the price function. renderWork is the thing he
     // actually looks at, so the check reads the panel the game draws.
     for(var m=0;m<guns.length;m++) P.wear[guns[m]]=1600;
     var html='';
     try{ __showScreen('hub'); __work(); var el=document.getElementById('worklist');
          html=el?el.innerHTML:''; }catch(e){ return 'SKIP: the workshop panel would not draw, '+e; }
     for(var m2=0;m2<guns.length;m2++) P.wear[guns[m2]]=0;
     if(/REPAIRS/.test(html)) bad.push('the workshop still draws a REPAIRS section');
     if(/Service/.test(html)) bad.push('the workshop still draws a Service button');
     // THE SECOND HALF, and it is the case a new player is actually in. The
     // CRAFTING heading was written INSIDE the repairs block, after its early
     // return, so a profile with no wear on any gun got the recipe rows with
     // nothing over them saying what they were. Setting wear first, as the arm
     // above does, hides this: the heading appears on the old build too.
     var fresh='';
     try{ __work(); var el0=document.getElementById('worklist');
          fresh=el0?el0.innerHTML:''; }catch(e){ return 'SKIP: the clean workshop would not draw, '+e; }
     if(!/CRAFTING/.test(fresh))
       bad.push('a profile with no wear on any gun gets the recipe rows with no CRAFTING heading over them');
     if((fresh.match(/class="row"/g)||[]).length<4)
       bad.push('control: the clean workshop drew fewer than four rows, so there was nothing to head');
     // CONTROL ONE: the panel has to still BE the workshop. Returning early from
     // renderWork would satisfy both lines above and delete crafting with it.
     if(!/CRAFTING/.test(html)) bad.push('control: the workshop no longer draws its CRAFTING heading');
     if((html.match(/class="row"/g)||[]).length<4)
       bad.push('control: the workshop drew fewer than four rows, so crafting is gone too');
     // CONTROL TWO: the guard has to be the WEAR TABLE, not a hardcoded false, or
     // restoring wear later would silently leave the repair economy switched off.
     var bands=__wear.steps().length;
     if(bands!==1) bad.push('control: the wear table has '+bands+' bands, so this scene is not the one being tested');
     // THE SERVO. Its only use was this repair, and being a craft part is what made
     // SELL ALL refuse it and the stash tell him to keep it.
     if(window.__stashRules){
       if(!__stashRules.sellable('servo'))
         bad.push('the Servo Actuator is still withheld from SELL ALL for a repair that no longer exists');
       if(__stashRules.craftPart('servo'))
         bad.push('the Servo Actuator is still classed as a crafting part and appears in no recipe');
       // CONTROL THREE: a real crafting part must still be protected, or this was
       // done by breaking the keep rule for everything.
       if(__stashRules.sellable('scrap'))
         bad.push('control: SELL ALL would now sell scrap, which five recipes and the racks need');
       if(!__stashRules.craftPart('comp'))
         bad.push('control: the Component Kit stopped being a crafting part and it is in five recipes');
     }
     return bad.length?bad.join('; '):null; }},
  {v:'9.42',what:'breaking line of sight sends a chase to the last place it SAW you',
   run:function(){
     var bad=[];
     __resetCfg(); __pinDefaults(0); __cleanProfile();
     __deploy({kit:[],safe:null,mapIx:1,seed:4242});
     var g=__state(), m=g.map, WW=m.cols*m.cw, WH=m.rows*m.ch;
     // Build the arena from the MAP, not from numbers I typed in. A post, a spot
     // the machine can see from it, and a spot it cannot, at least a right angle
     // apart so the two answers can never be confused for one another.
     function arena(loR,hiR){
       for(var mx=300; mx<WW-300; mx+=130){
        for(var my=300; my<WH-300; my+=130){
         if(!__nav.free(mx,my,16)||!__nav.reachable(mx,my)) continue;
         var hid=null,vis=null,a,b,r,r2,th,th2,dth,hx,hy,vx,vy;
         for(a=0;a<32&&!hid;a++){ th=a*Math.PI/16;
           for(r=loR;r<=hiR;r+=30){
             hx=mx+Math.cos(th)*r; hy=my+Math.sin(th)*r;
             if(hx<70||hy<70||hx>WW-70||hy>WH-70) continue;
             if(!__nav.free(hx,hy,16)||!__nav.reachable(hx,hy)) continue;
             if(__los.clear(mx,my,hx,hy)) continue;
             hid={x:hx,y:hy,th:th,r:r}; break; } }
         if(!hid) continue;
         for(b=0;b<32&&!vis;b++){ th2=b*Math.PI/16;
           dth=Math.abs(Math.atan2(Math.sin(th2-hid.th),Math.cos(th2-hid.th)));
           if(dth<1.45) continue;
           for(r2=250;r2<=320;r2+=20){
             vx=mx+Math.cos(th2)*r2; vy=my+Math.sin(th2)*r2;
             if(vx<70||vy<70||vx>WW-70||vy>WH-70) continue;
             if(!__nav.free(vx,vy,16)||!__nav.reachable(vx,vy)) continue;
             if(!__los.clear(mx,my,vx,vy)) continue;
             vis={x:vx,y:vy,th:th2,r:r2}; break; } }
         if(!vis) continue;
         // And a third spot: as far out as the hidden one but in plain view, so
         // the control differs from the test by sight and by nothing else.
         var opn=null;
         for(var r3=420;r3<=490&&!opn;r3+=20){
           var ox=mx+Math.cos(vis.th)*r3, oy=my+Math.sin(vis.th)*r3;
           if(ox<70||oy<70||ox>WW-70||oy>WH-70) continue;
           if(!__nav.free(ox,oy,16)||!__nav.reachable(ox,oy)) continue;
           if(!__los.clear(mx,my,ox,oy)) continue;
           opn={x:ox,y:oy,r:r3};
         }
         if(opn) return {mx:mx,my:my,hid:hid,vis:vis,opn:opn};
        } }
       return null;
     }
     // A is the far band, where the defect lived. B is close quarters, where the
     // game was always right, which is the control that says the probe can tell
     // the difference. hide false leaves the player in the open, the control that
     // says a machine that CAN see you still comes for you.
     function run(kind,A,to){
       __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:1,seed:4242});
       var G2=__state(), pp=G2.player, src=null, i;
       for(i=0;i<G2.ents.length;i++) if(G2.ents[i].kind===kind){ src=G2.ents[i]; break; }
       if(!src) return {skip:'no '+kind+' on this map'};
       G2.ents.length=0; G2.ents.push(src);
       src.hostile=true; src.merc=false; src.friendlyPC=0; src.downed=false; src.grudge=true;
       src.x=A.mx; src.y=A.my; src.state='patrol'; src.alert=0; src.cd=0; src.role=null;
       src.face=Math.atan2(A.vis.y-A.my,A.vis.x-A.mx);
       pp.x=A.vis.x; pp.y=A.vis.y; pp.downed=false; pp.iv=9999; pp.hp=pp.maxhp; G2.pCrouch=false;
       // THE GAME writes the last-known position, from a real sighting. I never
       // set tx/ty by hand; a probe that does is grading its own homework.
       for(var f=0;f<25;f++) __ents(1/60);
       if(src.state!=='chase') return {skip:kind+' never entered chase from a clear sighting'};
       var tx0=src.tx, ty0=src.ty;
       // Second position. The blind arms must be blind and the open arm must be
       // seen, and both are asserted rather than assumed.
       pp.x=to.x; pp.y=to.y;
       var wantBlind=(to===A.hid);
       if(wantBlind&&__los.clear(src.x,src.y,pp.x,pp.y)) return {skip:'the machine can still see the hidden spot'};
       if(!wantBlind&&!__los.clear(src.x,src.y,pp.x,pp.y)) return {skip:'the open spot is not actually in view'};
       var sx=src.x, sy=src.y;
       var uPx=pp.x-sx, uPy=pp.y-sy, uLx=tx0-sx, uLy=ty0-sy;
       var nP=Math.hypot(uPx,uPy), nL=Math.hypot(uLx,uLy);
       if(nL<25||nP<25) return {skip:'the two answers are on top of the machine'};
       var blind=true;
       for(var f2=0;f2<110;f2++){
         __ents(1/60);
         if(__los.clear(src.x,src.y,pp.x,pp.y)) blind=false;
         if(wantBlind&&!blind) break;
         if(src.state!=='chase') break;
       }
       var dx=src.x-sx, dy=src.y-sy, mv=Math.hypot(dx,dy);
       return {kind:kind, moved:+mv.toFixed(1), blind:blind, state:src.state,
               atPlayer: mv>0.5?+((dx*uPx+dy*uPy)/(mv*nP)).toFixed(3):null,
               atLastSeen: mv>0.5?+((dx*uLx+dy*uLy)/(mv*nL)).toFixed(3):null,
               closed:+(nP-Math.hypot(pp.x-src.x,pp.y-src.y)).toFixed(1)};
     }
     var far=arena(500,700), near=arena(190,300);
     if(!far||!near) return 'SKIP: this map has no wall with open ground on both sides of it';
     // CONTROL ONE, and the one that matters most: a machine that can SEE you must
     // still come for you. If this fix worked by blinding everything it is worthless.
     var open=run('raider',far,far.opn);
     if(open.skip) return 'SKIP: '+open.skip;
     if(!(open.closed>40&&open.atPlayer>0.7))
       bad.push('control: a raider standing '+Math.round(far.opn.r)+
                ' units off with a clear view of the player closed only '+open.closed+
                ' units at cosine '+open.atPlayer+', so pursuit itself is broken');
     // CONTROL TWO: close quarters was always right and has to stay right.
     var rn=run('raider',near,near.hid);
     if(rn.skip) return 'SKIP: '+rn.skip;
     if(!(rn.atLastSeen>0.7))
       bad.push('control: a blind raider at close range walked at cosine '+rn.atLastSeen+
                ' toward the last place he saw the player, and that band was never broken');
     // THE FINDING. Measured before the fix: 218 units at cosine 0.996 straight at
     // a man the raider had never seen there, and 89.6 at cosine 1.000 for a sentry.
     var rf=run('raider',far,far.hid), sf=run('sentry',far,far.hid);
     if(rf.skip||sf.skip) return 'SKIP: '+(rf.skip||sf.skip);
     if(rf.blind&&rf.moved>4&&rf.atPlayer>0.5)
       bad.push('a raider that had not seen the player for '+rf.moved.toFixed(0)+
                ' units of walking went at him anyway, cosine '+rf.atPlayer+
                ' toward where he really was against '+rf.atLastSeen+' toward where it saw him');
     if(sf.blind&&sf.moved>4&&sf.atPlayer>0.5)
       bad.push('a sentry that had not seen the player for '+sf.moved.toFixed(0)+
                ' units of walking went at him anyway, cosine '+sf.atPlayer+
                ' toward where he really was against '+sf.atLastSeen+' toward where it saw him');
     return bad.length?bad.join('; '):null; }},
  {v:'9.41',what:'the card new players read about XP matches what raids actually pay',
   run:function(){
     var bad=[];
     // MEASURE WHAT A RAID PAYS FIRST, with nothing sold, then read what the card
     // claims. The other way round grades a sentence against my opinion.
     __resetCfg(); __pinDefaults(0);
     var P=__P(); P.xp=0; P.log=[];
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g=__state(); g.ents.length=0; g.player.iv=99;
     __endRaid('extract');
     var xpNoSelling=(__P().xp||0);
     __resetCfg(); __pinDefaults(0);
     __P().xp=0;
     __deploy({kit:[],safe:null,mapIx:0,seed:4242});
     var g2=__state(); g2.ents.length=0; g2.player.iv=99;
     __endRaid('dead');
     var xpDeath=(__P().xp||0);
     // CONTROL FIRST: if a raid genuinely paid nothing, the old card was right and
     // this check has nothing to say.
     if(xpNoSelling<=0)
       return 'SKIP: a raid with nothing sold paid no XP at all, so the card was right and there is nothing to check';
     // The fixture ALREADY has a __primer whose list() returns this array. My
     // duplicate was defined earlier and silently overwritten, which is the fourth
     // name collision today. Grep before naming a shim.
     var cards=(window.__primer&&window.__primer.list)?window.__primer.list():null;
     if(!cards) return 'SKIP: the primer cards are not reachable from this fixture';
     var text='';
     for(var i=0;i<cards.length;i++) text+=' '+String(cards[i][0])+' '+String(cards[i][1]);
     // THE FINDING. Measured: 134 XP from one extract with nothing sold, and 67
     // from a death, while the card said "Nothing else pays XP."
     if(/nothing else pays xp/i.test(text))
       bad.push('a new player is told "Nothing else pays XP" and one raid with nothing sold paid '+
                xpNoSelling+' of it');
     if(/exactly one way to earn it/i.test(text))
       bad.push('a new player is told there is exactly one way to earn XP, and simply finishing a raid is another');
     // AND THE SHOP GATE IT CLAIMED. Rows carry rep 0, 1 or 2 against xp < rep, so
     // one finished raid clears the lot before anything is sold.
     if(/XP is what unlocks the shop/i.test(text)&&xpNoSelling>=2)
       bad.push('a new player is told XP unlocks the shop, and one raid pays '+xpNoSelling+
                ' against a highest gate of 2, so it gates nothing they will ever meet');
     // CONTROL: the death halving is the one number the card still states, so it
     // has to be true or the replacement is wrong in a new way.
     if(Math.abs(xpDeath*2-xpNoSelling)>2)
       bad.push('control: the card says dying pays half and a death paid '+xpDeath+
                ' against '+xpNoSelling+' for the same raid extracted');
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
// v9.16: the projection, both ways, so a check can prove the picture and the
// pointer agree rather than eyeballing one of them.
// v9.18: the DOM menu zoom, so a check can pin it instead of inheriting whatever
// the last check left. titleRes is the screen half of it and menuZoom is his
// text-size choice; the title screen multiplies the two.
// v9.22: the extraction tick, so the siege and its conscription pass can be
// driven directly. Stepping frames never reached it: __loop rewrites the beacon
// clock every frame, so the two second re-ping never came due.
window.__extract={tick:function(dt){ return tickExtractPoints(dt===undefined?1/60:dt); }};
window.__menuZoom={apply:function(){ return applyMenuZoom(); },
                   titleRes:function(){ return titleRes(); },
                   get:function(){ return (P&&P.menuZoom)||1; },
                   set:function(v){ P.menuZoom=v; applyMenuZoom(); }};
window.__proj={w2s:function(x,y,h){ return w2s(x,(h===undefined?0:h),y); },
               mouseWorld:function(){ return mouseWorld(); },
               zoom:function(){ return ZOOM(); },
               dial:function(){ return zoomTarget(); },
               res:function(){ return hudRes(); }};
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
