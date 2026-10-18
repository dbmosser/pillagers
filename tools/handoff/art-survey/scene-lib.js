// scene-lib.js : the five standard scenes for the art survey (2026-10-18), readable copy.
// recipes.json carries this same text at the end of its "prelude" (tools/handoff/art-survey/make-recipes.mjs glues it on),
// so a screen is one line: return await window.__art.scene('duo');  or  ...scene('duo',{plate:true})
//
// What a scene is: the test build (fixture.html), one raid on seed 4242 / map 0, the loop frozen, the HUD wiped, the camera
// pinned, two players with different cosmetics, and whatever the scene adds. Same seed + same code = the same picture.
//   duo      P1 and the co-op mate, close, on open ground, midday, nobody else
//   fight    the duo, two pillagers and two machines a few metres away, shots in the air
//   lineup   P1 and every kind of enemy in two rows (5 pillager roles, an elite, a golden one; 9 machines)
//   loot     P1 beside open containers and loot piles with their rarity beams
//   dark     the duo at night in a blackout
//   NAME-plate is the same frame with both players and every enemy hidden (scene opts {plate:true})
// scene() returns a JSON string: {scene, plate, zoom, w, h, chars:[{id,kind,x,y,w,h,fx,fy}]} (screen pixels at 1920x1080).
window.__art=window.__art||(function(){
var A={}, U=window.__uis, G0=null;

// ---- the two looks (keys are the profile-free cosmetic names the game's own racks use) ----
A.look1={build:'broad',skin:'tan',cut:'crop',hair:'dark',beard:'stubble',eyes:'eyeblue',face:'facescar',scheme:'schcrimson',hat:'tachelm',vest:'vestband',pads:'padsround',pack:'packblack',boots:'bootblack',gloves:'gloveblack',patch:'patchskull',tattoo:'tatnone',outfit:'outnone'};
A.look2={hair:'red',hat:'boonie',skin:'umber',fit:'slate',cut:'long',beard:'clean',eyes:'eyegreen',face:'facefreckles',boots:'bootgaiter',gloves:'glovegrey',pack:'packframe',patch:'patchstar',tattoo:'tatnone',outfit:'outnone',build:'curved',scheme:'schverdant',vest:'vestharn',pads:'padsnone'};

var SITE={x:1560,y:2960};   // the woods meadow: the one open stretch of grass on the map, every scene is shot here so all plates share one floor
var BASE={x:SITE.x,y:SITE.y};   // P1 stands here
var CAM={w:1920,h:1080};

function gx(s){ return __gx(s); }
function g(){ return __state(); }

// ---- freeze: no animation frames, no hidden worker, a fixed random state ----
A.freeze=async function(){
  if(!window.__rafStub){ window.__rafStub=1; window.requestAnimationFrame=function(){ return 0; }; }
  gx('hidWant=function(){return false;}');
  await U.wait(200);
  gx('RNGS=0x1badf00d; FXS=0x2545F491;');
};

// ---- the HUD: wiped, only the dark edge of the screen stays (and the golden shine, without its word) ----
A.hud=function(){
  if(!window.__drawHUDReal) window.__drawHUDReal=gx('drawHUD');
  window.__noHud=function(){
    var c=gx('ctx'), W=gx('W'), H=gx('H');
    c.clearRect(0,0,W,H);
    var vg=c.createRadialGradient(W/2,H/2,H*.42,W/2,H/2,H*.85);
    vg.addColorStop(0,'rgba(0,0,0,0)'); vg.addColorStop(1,'rgba(0,0,0,.45)');
    c.fillStyle=vg; c.fillRect(0,0,W,H);
    if(window.__goldShine){
      var oh=gx('hudText'); gx('hudText=function(){}');
      try{ gx('goldDraw(ctx)'); }catch(e){} finally{ window.__oh=oh; gx('hudText=window.__oh'); }
    }
  };
  gx('drawHUD=window.__noHud');
  var tr=document.getElementById('topright'); if(tr) tr.style.display='none';
};

// ---- the camera: world point (x,y) at the middle of the picture, zoom z ----
A.cam=function(x,y,z){
  var s=g();
  if(z) __zoom.set(z);
  gx('mouse.x=W/2;mouse.y=H*0.54');
  s.anchX=x; s.anchY=y; s.leanSX=0; s.leanSY=0; s.shake=0;
};
A.draw=function(n){ for(var i=0;i<(n||1);i++) __frame(0); };

// ---- players: the mate is one fake peer in NET.up, drawn by the game's own netUpDrawOne ----
A.mate=function(x,y,face,o){
  o=o||{};
  var s=g();
  if(!window.__mateOn){
    window.__mateOn=1;
    gx("netSend=function(){return true;}; netSendFast=function(){return true;}; netRefresh=function(){};");
    gx("NET.on=true; NET.role='host'; NET.seat=0; NET.upSeed=G.seed>>>0; NET.peers=[]; NET.roster=[{seat:0,name:'p1',host:true},{seat:1,name:'p2'}]; NET.up=[]; NET.upOut=undefined; NET.specG=null;");
    gx("netUpTags=function(){return 0;};");
  }
  window.__peer={state:'in',seat:1};
  window.__mateWord={t:'st',k:'r',sd:s.seed>>>0,x:x,y:y,f:face,m:0,r:0,c:0,sp:0,dn:0,w:o.w||'rifle',pz:0,hp:100,mh:100,ar:0,ac:0,dt:0,sa:o.ads?1:0,lk:A.look2};
  gx("netOnState(window.__peer,window.__mateWord)");
  var u=gx('NET.up[1]'); u.age=0; u.x=x; u.y=y; u.tx=x; u.ty=y; u.f=face;
  return u;
};

// ---- hide / show the two players (the plate) ----
var realDrawOp=null;
A.only=function(spec){   // spec: null = everyone, 'none' = nobody, {x,y} = only the body drawn at that spot
  if(!realDrawOp){ realDrawOp=gx('drawOp'); window.__drawOpReal=realDrawOp;
    gx("drawOp=function(x,y){ var o=window.__only; if(o==='none') return; if(o&&(Math.abs(x-o.x)>3||Math.abs(y-o.y)>3)) return; return window.__drawOpReal.apply(this,arguments); };"); }
  window.__only=spec||null;
};

// ---- a clear stage: trees, bushes, crates, props, lamps and barrels inside the rectangle are taken out of the lists the picture draws
// (rect in world units; walls and buildings are never touched, the site is chosen so none stands there) ----
A.clearStage=function(x0,y0,x1,y1){
  var s=g(), m=s.map, i, j, n=0, w, b, gone=[];
  function inb(x,y,r){ return x+r>x0&&x-r<x1&&y+r>y0&&y-r<y1; }
  var alive=m.walls.filter(function(q){ return q.tree&&q.x>-1000; });
  for(i=m.walls.length-1;i>=0;i--){ w=m.walls[i];
    if(w.x<-1000) continue;
    if(!(w.tree||w.furn||w.wreck)) continue;
    var ext=w.tree?(w.canopy||30)+40:20;
    if(w.x+w.w+ext>x0&&w.x-ext<x1&&w.y+w.h+ext+30>y0&&w.y-ext-60<y1){ gone.push({x:w.x,y:w.y,w:w.w,h:w.h}); w.x=-9000; w.y=-9000; n++; } }   // moved off the map, not spliced: wall ids and the wall grid keep their places
  // what was taken out no longer casts a sight shadow (the fog wedges the picture would show behind it)
  var vs=s.vseg, k, q;
  for(k=vs.length-1;k>=0;k--){ q=vs[k]; for(j=0;j<gone.length;j++){ var t=gone[j];
    if(q.x1>=t.x-3&&q.x1<=t.x+t.w+3&&q.x2>=t.x-3&&q.x2<=t.x+t.w+3&&q.y1>=t.y-3&&q.y1<=t.y+t.h+3&&q.y2>=t.y-3&&q.y2<=t.y+t.h+3){ vs.splice(k,1); break; } } }
  for(i=m.bushes.length-1;i>=0;i--){ b=m.bushes[i]; if(inb(b.x,b.y,(b.r||20)+16)){ m.bushes.splice(i,1); n++; } }
  for(i=s.containers.length-1;i>=0;i--){ b=s.containers[i]; if(inb(b.x,b.y,34)){ s.containers.splice(i,1); n++; } }
  for(i=s.brl.length-1;i>=0;i--){ b=s.brl[i]; if(inb(b.x,b.y,34)){ s.brl.splice(i,1); n++; } }
  for(i=s.lights.length-1;i>=0;i--){ b=s.lights[i]; if(inb(b.x,b.y,40)){ s.lights.splice(i,1); n++; } }
  gx("G.grid=buildSegGrid(G.map.segs,WORLD_W,WORLD_H);");   // the sight lookup is rebuilt from what is left
  // the floor is baked again without them: no trunk marks, no leftover contact shadows (a fixed random stream keeps it the same every time)
  gx("RNGS=0x5eed1234; G.ground=bakeGround(G.map);");
  return n;
};

// ---- the common staging ----
A.stage=async function(o){
  o=o||{};
  window.__goldShine=0; window.__only=null;
  var P=__P(), K=gx('COSKEY'), k;
  P.cosAll=true;
  P.cond=o.night?'night':'day';
  P.wxPick=o.night?'blackout':'clear';
  for(k in A.look1) if(K[k]) P[K[k]]=A.look1[k];
  U.dep({kit:['gun_carbine','medkit','bandage','plate','frag','smoke'],seed:4242,mapIx:0});
  await A.freeze();
  var s=g(), p=s.player;
  if(!o.night){ s.tod=gx('TODS[2]'); s.wx=gx('WEATHER[0]'); s.wxNext=null; }
  __belt.set(3);                       // the carbine in his hands
  s.rise=null; s.ents.length=0; s.wild.length=0; s.bullets.length=0; s.flashes.length=0; s.sparks.length=0; s.shells.length=0;
  s.puffs.length=0; s.decals.length=0; s.throws.length=0; s.labels.length=0; s.dmgN.length=0; s.noiseRings.length=0; s.pings.length=0;
  s.t=40; s.shake=0; s.msg=''; s.msgT=0;
  if(!o.night) __cfg({ambient:1500,viewFar:1500,coneDeg:360});   // a clear day: nothing hidden by the fog of war
  BASE={x:o.x||SITE.x,y:o.y||SITE.y};
  A.clearStage(BASE.x-410,BASE.y-290,BASE.x+410,BASE.y+250);
  p.x=BASE.x; p.y=BASE.y; p.face=(o.face===undefined?1.25:o.face); p.iv=99; p.moving=false; p.recoil=0; p.muzzle=0;
  A.hud();
  A.only(null);
  return {s:s,p:p};
};

// ---- bodies for the enemies: the game's own makers, then placed, turned and frozen ----
function put(e,x,y,face,state){
  e.x=x; e.y=y; e.tx=x; e.ty=y; e.face=face; e.state=state||'patrol'; e.cd=3; e.alert=0; e.hitT=0; e.moving=false; e.step=0;
  if(e.lx!==undefined){ e.lx=Math.round(x); e.ly=Math.round(y); }
  return e;
}
A.pillager=function(x,y,o){
  o=o||{};
  window.__idn=gx('IDENTITIES').filter(function(i){ return i.id===(o.id||'beef'); })[0];
  var e=gx('mkRaider('+Math.round(x)+','+Math.round(y)+',window.__idn)');
  var wk=o.gun||'smg';
  e.wep=gx('WEAPONS["'+wk+'"]'); e.dmg=e.wep.dmg; e.rng=e.wep.rng*.72;
  e.rig=o.rig||'none';
  var ar=gx('armorById("'+e.rig+'")'); e.armor=ar.cap*0.7; e.armorCap=ar.cap; e.bulk=ar.bulk;
  e.hp=e.maxhp; e.hostile=true; e.elite=o.elite?1:0; e.golden=0; e.bag=e.bag||[];
  if(o.prole) e.prole=o.prole;
  if(o.elite){ e.r=Math.round(e.r*1.12); }
  put(e,x,y,o.face===undefined?1.5708:o.face,o.state||'patrol');
  g().ents.push(e);
  return e;
};
A.machine=function(kind,x,y,o){
  o=o||{};
  var mk={sentry:'mkSentry',crawler:'mkCrawler',snitch:'mkSnitch',bulwark:'mkBulwark',howler:'mkHowler',listener:'mkListener',choir:'mkChoir',warden:'mkWarden'}[kind];
  var e=gx(mk+'('+Math.round(x)+','+Math.round(y)+')');
  e.elite=0; e.affix=null; e.hp=e.maxhp;
  put(e,x,y,o.face===undefined?1.5708:o.face,o.state||'patrol');
  g().ents.push(e);
  return e;
};
A.overseer=function(x,y,face){
  var s=g(); s.bossDone=0;
  var e=gx('bossTick(true)');
  if(!e){ e=s.bossRef; }
  put(e,x,y,face===undefined?1.5708:face,'patrol');
  e.lairX=x; e.lairY=y;
  return e;
};

// ---- a shot in the air: from the muzzle of whoever fires toward (tx,ty), n rounds spaced like a burst ----
A.shoot=function(sh,wep,tx,ty,fromPlayer,rounds){
  window.__sh=sh; window.__wp=wep;
  var n0=g().bullets.length;
  gx('fireWeapon(window.__sh,window.__wp,'+tx+','+ty+','+(fromPlayer?'true':'false')+')');
  var s=g(), b=s.bullets[s.bullets.length-1];
  if(!b) return null;
  var a=Math.atan2(ty-sh.y,tx-sh.x), v=Math.hypot(b.vx,b.vy), i, c, extra=[];
  b.vx=Math.cos(a)*v; b.vy=Math.sin(a)*v;
  var muz=Math.hypot(b.x-b.sx,b.y-b.sy);
  var dists=rounds||[60,200];
  b.x=b.sx+Math.cos(a)*(muz+dists[0]); b.y=b.sy+Math.sin(a)*(muz+dists[0]);
  for(i=1;i<dists.length;i++){
    c={}; for(var k in b) c[k]=b[k];
    c.x=b.sx+Math.cos(a)*(muz+dists[i]); c.y=b.sy+Math.sin(a)*(muz+dists[i]);
    s.bullets.push(c);
  }
  return b;
};

// a frozen shot would show every muzzle light at its brightest frame as a hard pale disc (they live a twentieth of a second); the discs and the sound marks are dropped, the muzzle sprites, tracers and shells stay
A.settleFx=function(){ var s=g(), i; s.flashes.length=0; s.noiseRings.length=0; s.pings.length=0; s.shake=0; };

// ---- measuring: where each character lands in the 1920x1080 picture ----
function bbox(img0,img1,w,h){
  var x0=1e9,y0=1e9,x1=-1,y1=-1,i,n=w*h,d0=img0.data,d1=img1.data,dd;
  for(i=0;i<n;i++){
    dd=Math.abs(d0[i*4]-d1[i*4])+Math.abs(d0[i*4+1]-d1[i*4+1])+Math.abs(d0[i*4+2]-d1[i*4+2]);
    if(dd>36){ var x=i%w, y=(i/w)|0; if(x<x0)x0=x; if(x>x1)x1=x; if(y<y0)y0=y; if(y>y1)y1=y; }
  }
  return x1<0?null:[x0,y0,x1,y1];
}
// chars: [{id,kind,ref}] where ref is G.ents[i] (or 'p1' / 'mate'); everything else hidden for the one picture
A.measure=function(chars){
  var s=g(), p=s.player, cv=document.getElementById('cv'), c2=cv.getContext('2d',{willReadFrequently:true}), w=cv.width, h=cv.height;
  var allEnts=s.ents.slice(), bl=s.bullets.slice(), fl=s.flashes.slice(), sp=s.sparks.slice(), sh=s.shells.slice(), pf=s.puffs.slice(), nr=s.noiseRings.slice();
  var gm=gx('GFXMUZ').slice(), Z=__zoom.cur?gx('ZOOM()'):gx('ZOOM()'), out=[], i, img0, img1, bb, e, X, Y;
  var gl=window.__goldShine; window.__goldShine=0;
  s.bullets.length=0; s.flashes.length=0; s.sparks.length=0; s.shells.length=0; s.puffs.length=0; s.noiseRings.length=0; gx('GFXMUZ.length=0');
  s.ents.length=0; A.only('none'); A.draw(1); img0=c2.getImageData(0,0,w,h);
  for(i=0;i<chars.length;i++){
    e=chars[i].ref; s.ents.length=0;
    if(e==='p1'){ X=p.x; Y=p.y; }
    else if(e==='mate'){ var u=gx('NET.up[1]'); X=u.x; Y=u.y; }
    else { X=e.x; Y=e.y; s.ents.push(e); }
    A.only({x:X,y:Y}); A.draw(1); img1=c2.getImageData(0,0,w,h);
    bb=bbox(img0,img1,w,h);
    var q=gx('w2s('+X+',0,'+Y+')');
    out.push({id:chars[i].id,kind:chars[i].kind,x:bb?Math.round((bb[0]+bb[2])/2)+1:null,y:bb?Math.round((bb[1]+bb[3])/2)+1:null,
      w:bb?bb[2]-bb[0]+1:null,h:bb?bb[3]-bb[1]+1:null,fx:Math.round(q.x)+1,fy:Math.round(q.y)+1});
  }
  s.ents.length=0; for(i=0;i<allEnts.length;i++) s.ents.push(allEnts[i]);
  for(i=0;i<bl.length;i++) s.bullets.push(bl[i]); for(i=0;i<fl.length;i++) s.flashes.push(fl[i]); for(i=0;i<sp.length;i++) s.sparks.push(sp[i]);
  for(i=0;i<sh.length;i++) s.shells.push(sh[i]); for(i=0;i<pf.length;i++) s.puffs.push(pf[i]); for(i=0;i<nr.length;i++) s.noiseRings.push(nr[i]);
  gx('GFXMUZ.length=0'); for(i=0;i<gm.length;i++) gx('GFXMUZ').push(gm[i]);
  window.__goldShine=gl; A.only(null);
  return out;
};

// ---- the scenes: each returns {chars:[{id,kind,ref}], zoom} after placing everything and pointing the camera ----
A.scenes={};

A.scenes.duo=async function(o){
  var st=await A.stage(o), p=st.p, X=BASE.x, Y=BASE.y;
  p.x=X-36; p.y=Y; p.face=1.15;
  A.mate(X+36,Y+4,1.95);
  A.cam(X,Y-10,5.0);
  return {zoom:5.0,chars:[{id:'p1',kind:'player',ref:'p1'},{id:'mate',kind:'player',ref:'mate'}]};
};

A.scenes.fight=async function(o){
  var st=await A.stage(o), p=st.p, s=st.s, X=BASE.x, Y=BASE.y, Z=3.0;
  var pa, pb, sen, cra;
  p.x=X-176; p.y=Y+14; p.face=0.1;
  A.mate(X-248,Y-40,0.0,{ads:1});
  pa=A.pillager(X-30,Y-26,{id:'beef',gun:'shotgun',rig:'none',state:'chase',face:Math.PI-0.12});
  pb=A.pillager(X+14,Y+70,{id:'gamer',gun:'carbine',rig:'light',state:'chase',face:Math.PI-0.3});
  cra=A.machine('crawler',X+50,Y+34,{state:'chase',face:Math.PI});
  sen=A.machine('sentry',X+150,Y-6,{state:'chase',face:Math.PI-0.1});
  sen.rng=100;   // its sight cone stops well short of the pair
  // the shots: P1 at the near pillager, both pillagers back at the pair, the sentry at P1
  A.shoot(p,p.wep,pa.x,pa.y-8,true,[70,200,330]);
  A.shoot(pa,pa.wep,p.x,p.y-6,false,[55,150]);
  A.shoot(pb,pb.wep,p.x+10,p.y+10,false,[110,260]);
  A.shoot(sen,{dmg:sen.dmg,spread:.10,rng:sen.rng,noise:340,tint:'#ff9a6a'},p.x,p.y,false,[80,240]);
  A.settleFx();
  A.cam(X-40,Y+10,Z);
  return {zoom:Z,chars:[{id:'p1',kind:'player',ref:'p1'},{id:'mate',kind:'player',ref:'mate'},
    {id:'pillager-a',kind:'pillager',ref:pa},{id:'pillager-b',kind:'pillager',ref:pb},{id:'crawler',kind:'machine',ref:cra},{id:'sentry',kind:'machine',ref:sen}]};
};

A.scenes.lineup=async function(o){
  var st=await A.stage(o), p=st.p, s=st.s, X=BASE.x, Y=BASE.y, Z=2.7, i, e, chars=[], x;
  var FY=Y+58, BY=Y-62, face=1.5708;
  // front row: P1 then the pillagers (the five roles by gun and rig, an elite, a golden one)
  var rows=[
    {n:'pillager-rush',  id:'beef',  gun:'shotgun',rig:'none'},
    {n:'pillager-flank', id:'prone', gun:'carbine',rig:'light'},
    {n:'pillager-supp',  id:'gamer', gun:'lmg',    rig:'medium'},
    {n:'pillager-mark',  id:'noscp', gun:'magnum', rig:'none'},
    {n:'pillager-shield',id:'sigma', gun:'smg',    rig:'heavy'},
    {n:'pillager-elite', id:'crouch',gun:'rifle',  rig:'medium',elite:1},
    {n:'pillager-golden',id:'lag',   gun:'carbine',rig:'light', golden:1}];
  var sp=70, x0=X-3.5*sp-sp*0.5;
  p.x=x0; p.y=FY; p.face=face;
  chars.push({id:'p1',kind:'player',ref:'p1'});
  for(i=0;i<rows.length;i++){
    e=A.pillager(x0+sp*(i+1),FY,{id:rows[i].id,gun:rows[i].gun,rig:rows[i].rig,elite:rows[i].elite,face:face,state:'patrol'});
    chars.push({id:rows[i].n,kind:'pillager',ref:e});
    if(rows[i].golden){ window.__ge=e; gx('goldMake(window.__ge)'); s.flow=s.flow||{}; s.flow.gold={ref:e,hp0:e.maxhp,dead:0,tried:0}; window.__goldShine=1; }
  }
  // back row: every machine, left to right by size
  var ms=[['sentry','sentry'],['crawler','crawler'],['snitch','crier'],['bulwark','bulwark'],['howler','howler'],['listener','listener'],['choir','pillbox'],['warden','warden'],['overseer','overseer']];
  var gap=24, tot=0, ents=[], r;
  for(i=0;i<ms.length;i++){
    e=(ms[i][0]==='overseer')?A.overseer(X,BY,face):A.machine(ms[i][0],X,BY,{face:face});
    if(ms[i][0]==='sentry') e.rng=2;   // no sight cone on the ground in a line-up
    ents.push(e); tot+=e.r*2+(i?gap:0);
  }
  x=X-tot/2;
  for(i=0;i<ents.length;i++){
    r=ents[i].r; x+=r; ents[i].x=x; ents[i].tx=x; ents[i].y=BY; ents[i].ty=BY; x+=r+gap;
    chars.push({id:ms[i][1],kind:'machine',ref:ents[i]});
  }
  A.settleFx();
  A.cam(X,Y-6,Z);
  return {zoom:Z,chars:chars};
};

// the picture: scene (or its plate), measured, the last frame drawn, a JSON line back
A.scene=async function(name,o){
  o=o||{};
  var r=await A.scenes[name](o), s=g(), i;
  A.draw(2);
  var chars=null;
  if(!o.plate){ chars=A.measure(r.chars); }
  else { s.ents.length=0; s.bullets.length=0; s.flashes.length=0; s.sparks.length=0; s.shells.length=0; s.puffs.length=0; s.noiseRings.length=0; gx('GFXMUZ.length=0'); window.__goldShine=0; A.only('none'); }
  A.draw(2);
  return JSON.stringify({scene:name,plate:!!o.plate,zoom:gx('ZOOM()'),w:CAM.w,h:CAM.h,chars:chars});
};

A.P1=function(){ return g().player; };
A.state=function(){ return g(); };
A.base=function(){ return BASE; };

return A;
})();
