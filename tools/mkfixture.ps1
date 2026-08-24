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
window.__cam=function(){ return {x:camX,y:camY}; };
window.__cfg=function(){ return CFG; };
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
window.__hubStep=function(dt){ updateHubWorld(dt); drawHubWorld(dt); };
window.__startRaid=function(){ return startRaid(); };
window.__mapOverlay=function(){ drawMapOverlay(); return {w:W,h:H,dpr:DPR}; };
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
window.__bestRarity=function(a){ return bestRarity(a); };
window.__simSeedsFull=function(seeds){
  var out=[],i;
  for(i=0;i<seeds.length;i++){
    pendSeed=seeds[i]>>>0;
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
try{ say=function(){}; }catch(e){}
try{ tickAmbience=function(){}; }catch(e){}
try{ tickEnemyAudio=function(){}; }catch(e){}
try{ tickPlayerSteps=function(){}; }catch(e){}
try{ tickMachineVoices=function(){}; }catch(e){}
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
window.__keysRef=function(){ return keys; };
window.__wx={list:function(){ return WEATHER; },cur:wx,VF:VF,AMBR:AMBR,ping:ping,pick:pickWeather};
window.__audio={amb:tickAmbience,steps:tickEnemyAudio,sfx:sfx,blip:blip,ears:earsOf,
  bus:bus,ctx:ac,ambObj:function(){ return AMB; }};
window.__bag={weight:bagWeight,drop:dropItem,worst:worstBagIndex,cull:autoCull,
  cap:function(){ return PACKCAP[P.pack]; },ival:ival,items:function(){ return ITEMS; }};
// ================================================================ boot
'@
$text = Get-Content $src -Raw
$text = $text.Replace($needle, $inject)
Set-Content -Path $dst -Value $text -Encoding utf8
"written: " + (Test-Path $dst)
