;// m2-ext.js : scene changes for the second pass on the machine questions (2026-10-18), glued on the end of the prelude of recipes-mach.json by m2-recipes.mjs
//   lineupbig    a26: the lineup with room for the big settings: every machine in one row, spaced for the 1.5 times setting so no machine touches another, zoom 2.2
//   fightdead    a28: the same as before, but C and D show the machines' own effect and no wreck yet (a wreck comes after the effect, at 0.5 s)
(function(){
var A=window.__art, U=window.__uis;
function gx(s){ return __gx(s); }
function g(){ return __state(); }

// a26: P1 and the pillagers in the front row, the nine machines in one row behind them, centres spaced from the widths measured in the plain lineup
A.scenes.lineupbig=async function(o){
  var st=await A.stage(o), p=st.p, s=st.s, X=A.base().x, Y=A.base().y, Z=2.4, i, e, chars=[], x;
  var XC=X-33, FY=Y+132, BY=Y-12, face=1.5708;   // the meadow runs from 434 left to 368 right of the site centre (a building stands beyond each end): the row is centred in it
  var rows=[
    {n:'pillager-rush',  id:'beef',  gun:'shotgun',rig:'none'},
    {n:'pillager-flank', id:'prone', gun:'carbine',rig:'light'},
    {n:'pillager-supp',  id:'gamer', gun:'lmg',    rig:'medium'},
    {n:'pillager-mark',  id:'noscp', gun:'magnum', rig:'none'},
    {n:'pillager-shield',id:'sigma', gun:'smg',    rig:'heavy'},
    {n:'pillager-elite', id:'crouch',gun:'rifle',  rig:'medium',elite:1},
    {n:'pillager-golden',id:'lag',   gun:'carbine',rig:'light', golden:1}];
  var sp=70, x0=XC-3.5*sp;
  p.x=x0; p.y=FY; p.face=face;
  chars.push({id:'p1',kind:'player',ref:'p1'});
  for(i=0;i<rows.length;i++){
    e=A.pillager(x0+sp*(i+1),FY,{id:rows[i].id,gun:rows[i].gun,rig:rows[i].rig,elite:rows[i].elite,face:face,state:'patrol'});
    chars.push({id:rows[i].n,kind:'pillager',ref:e});
    if(rows[i].golden){ window.__ge=e; gx('goldMake(window.__ge)'); s.flow=s.flow||{}; s.flow.gold={ref:e,hp0:e.maxhp,dead:0,tried:0}; window.__goldShine=1; }
  }
  // the machines: the width each is drawn at today (units), times 1.5 for the widest setting, half of it each side of the centre, 18 units clear between neighbours
  var ms=[['sentry','sentry',40],['crawler','crawler',42],['snitch','crier',34],['bulwark','bulwark',48],['howler','howler',41],['listener','listener',26],['choir','pillbox',60],['warden','warden',59],['overseer','overseer',87]];
  var gap=12, tot=0, ents=[], hw=[];
  for(i=0;i<ms.length;i++){
    e=(ms[i][0]==='overseer')?A.overseer(XC,BY,face):A.machine(ms[i][0],XC,BY,{face:face});
    if(ms[i][0]==='sentry') e.rng=2;   // no sight cone on the ground in a line-up
    ents.push(e); hw.push(ms[i][2]*0.75); tot+=hw[i]*2+(i?gap:0);
  }
  x=XC-tot/2;
  for(i=0;i<ents.length;i++){
    x+=hw[i]; ents[i].x=x; ents[i].tx=x; ents[i].y=BY; ents[i].ty=BY; x+=hw[i]+gap;
    chars.push({id:ms[i][1],kind:'machine',ref:ents[i]});
  }
  A.settleFx();
  A.cam(XC,Y+6,Z);
  return {zoom:Z,chars:chars};
};

// a28: the fight, the sentry and the crawler destroyed through the game's own death path, then 0.2 s of what that made (same as fightdead in recipes-mach.json);
// the modes C and D draw their own effect, so the game's yellow sparks and puffs are dropped and no wreck stands yet
A.scenes.fightdead=async function(o){
  var r=await A.scenes.fight(o), s=g(), i, k, dt, sp, sen, cra, all, dm;
  for(i=0;i<r.chars.length;i++){ if(r.chars[i].id==='crawler') cra=r.chars[i].ref; if(r.chars[i].id==='sentry') sen=r.chars[i].ref; }
  window.__dead=[sen,cra];
  sen.muzzle=0; sen.hp=0; cra.hp=0; sen.byPlayer=true; cra.byPlayer=true;
  all=s.ents.slice(); s.ents.length=0; s.ents.push(sen,cra);
  gx('updateEnts(0.05)');
  s.ents.length=0; all.forEach(function(e){ if(e!==sen&&e!==cra) s.ents.push(e); });
  if(window.__DF&&window.__DF.mode!=='A'){
    s.sparks=s.sparks.filter(function(q){ return q.c!=='#ffc04a'; }); s.puffs=s.puffs.filter(function(q){ return q.c!=='#ffc04a'; });
    if(window.__DF.mode==='C'||window.__DF.mode==='D') s.containers=s.containers.filter(function(c){ return !(c.type==='botwreck'&&(c.bot==='sentry'||c.bot==='crawler')); });
  }
  r.chars=r.chars.filter(function(c){ return c.kind!=='machine'; });
  for(k=0;k<4;k++){
    dt=0.05;
    for(i=s.sparks.length-1;i>=0;i--){ sp=s.sparks[i]; sp.t+=dt; sp.x+=sp.vx*dt; sp.y+=sp.vy*dt; dm=Math.pow(.92,dt*60); sp.vx*=dm; sp.vy*=dm; if(sp.t>sp.life) s.sparks.splice(i,1); }
    for(i=s.puffs.length-1;i>=0;i--){ s.puffs[i].t+=dt; if(s.puffs[i].t>s.puffs[i].life) s.puffs.splice(i,1); }
    s.t+=dt;
  }
  window.__DFT=0.2;
  s.labels.length=0; s.dmgN.length=0; s.shake=0; s.msg=''; s.msgT=0; s.hitMark=null;
  return r;
};
})();
