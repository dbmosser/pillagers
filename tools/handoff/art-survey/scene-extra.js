// scene-extra.js : three more scenes for the art survey (2026-10-18), glued after scene-lib.js by build/make-recipes-x.mjs into recipes-x.json.
// They are the standard duo staged the same way (same site, light, camera, zoom), with one thing changed for the question that needs it.
//   duoaim    the duo, but P1 aims up and to the right (you see the back of his head) and P2 aims right (a side view)   (a03)
//   trio      P1 lean, a hired pillager with the broad build, P2 curved: all three in Standard Issue with the same hair and no hat   (a04)
//   duodown   the duo, but P2 is down on the ground with 16 s to go (the far-or-down case of a10)
//   duoparty  the duo with the party on, so the seat rings and badges the game draws in a two player match show   (a06)
(function(){
var A=window.__art, U=window.__uis;
function gx(s){ return __gx(s); }
function g(){ return __state(); }

A.scenes.duoaim=async function(o){
  var st=await A.stage(o), p=st.p, X=A.base().x, Y=A.base().y;
  p.x=X-36; p.y=Y; p.face=-1.05;
  A.mate(X+36,Y+4,0.3);
  A.cam(X,Y-10,5.0);
  return {zoom:5.0,chars:[{id:'p1',kind:'player',ref:'p1'},{id:'mate',kind:'player',ref:'mate'}]};
};

A.scenes.duodown=async function(o){
  var st=await A.stage(o), p=st.p, X=A.base().x, Y=A.base().y;
  p.x=X-36; p.y=Y; p.face=1.15;
  var u=A.mate(X+36,Y+4,1.95); u.dn=1; u.dt=16;
  A.cam(X,Y-10,5.0);
  return {zoom:5.0,chars:[{id:'p1',kind:'player',ref:'p1'},{id:'mate',kind:'player',ref:'mate'}]};
};

A.scenes.duoparty=async function(o){
  var st=await A.stage(o), p=st.p, X=A.base().x, Y=A.base().y;
  p.x=X-36; p.y=Y; p.face=1.15;
  A.mate(X+36,Y+4,1.95);
  gx("NET.peers=[window.__peer];");
  A.cam(X,Y-10,5.0);
  return {zoom:5.0,chars:[{id:'p1',kind:'player',ref:'p1'},{id:'mate',kind:'player',ref:'mate'}]};
};

A.scenes.trio=async function(o){
  var base={scheme:'schstd',fit:'slate',hat:'none',cut:'crop',hair:'dark',beard:'clean',vest:'vestplate',pads:'padsnone',pack:'packbrown',patch:'patchnone',
    boots:'bootblack',gloves:'gloveblack',face:'faceplain',skin:'tan',eyes:'eyeblue',tattoo:'tatnone',outfit:'outnone'};
  var l1=A.look1, l2=A.look2;
  A.look1=Object.assign({},l1,base,{build:'lean'}); A.look2=Object.assign({},l2,base,{build:'curved'});
  var st=await A.stage(o), p=st.p, s=st.s, X=A.base().x, Y=A.base().y;
  p.x=X-70; p.y=Y; p.face=1.4;
  A.mate(X+70,Y+4,1.75);
  var m=A.pillager(X,Y+2,{id:'beef',gun:'carbine',rig:'none',face:1.57,state:'patrol'});
  m.merc=1; m.hostile=false; m.friendly=1; m.build='broad'; m.coat='#59626f'; m.hair='dark'; m.cut='crop'; m.hat='none'; m.skin='tan'; m.beard='clean'; m.eyes='eyeblue';
  m.faceMark=null; m.boots='bootblack'; m.gloves='gloveblack'; m.pack='packbrown'; m.patch='patchnone'; m.tattoo='tatnone'; m.bag=[]; m.prole=null;
  A.look1=l1; A.look2=l2;
  A.cam(X,Y-10,5.0);
  return {zoom:5.0,chars:[{id:'p1',kind:'player',ref:'p1'},{id:'merc',kind:'pillager',ref:m},{id:'mate',kind:'player',ref:'mate'}]};
};
})();

// ---- a look-around scene for finding a busy floor (window.__look = {x,y,z,px,py}): the camera at (x,y), the player at (px,py) when given
(function(){
var A=window.__art;
A.scenes.look=async function(o){
  var st=await A.stage(o), p=st.p, L=window.__look||{x:A.base().x,y:A.base().y,z:3};
  if(L.px!==undefined){ p.x=L.px; p.y=L.py; }
  A.cam(L.x,L.y,L.z);
  return {zoom:L.z,chars:[{id:'p1',kind:'player',ref:'p1'}]};
};
})();

// ---- more scenes for the second pass (2026-10-18 evening)
(function(){
var A=window.__art;
function gx(s){ return __gx(s); }
function g(){ return __state(); }
// trio2 (a04): the three builds in a row, the same clothes, the same pose, each aiming SIDEWAYS so the gun does not cover the middle of the body.
//   window.__t2={f1,fm,f2} the three facings (default all 0 = the gun points to the right); P1 lean, the hired pillager broad, P2 curved.
A.scenes.trio2=async function(o){
  var t2=window.__t2||{f1:-0.6,fm:-0.6,f2:-0.6,cy:26}, Z=(t2.z||5.0);
  var base={scheme:'schstd',fit:'slate',hat:'none',cut:'crop',hair:'dark',beard:'clean',vest:'vestplate',pads:'padsnone',pack:'packbrown',patch:'patchnone',
    boots:'bootblack',gloves:'gloveblack',face:'faceplain',skin:'tan',eyes:'eyeblue',tattoo:'tatnone',outfit:'outnone'};
  var l1=A.look1, l2=A.look2;
  A.look1=Object.assign({},l1,base,{build:'lean'}); A.look2=Object.assign({},l2,base,{build:'curved'});
  var st=await A.stage(o), p=st.p, X=A.base().x, Y=A.base().y, sp=(t2.sp||78);
  p.x=X-sp; p.y=Y; p.face=t2.f1;
  A.mate(X+sp,Y,t2.f2);
  var m=A.pillager(X,Y,{id:'beef',gun:'carbine',rig:'none',face:t2.fm,state:'patrol'});
  m.merc=1; m.hostile=false; m.friendly=1; m.build='broad'; m.coat='#59626f'; m.hair='dark'; m.cut='crop'; m.hat='none'; m.skin='tan'; m.beard='clean'; m.eyes='eyeblue';
  m.faceMark=null; m.boots='bootblack'; m.gloves='gloveblack'; m.pack='packbrown'; m.patch='patchnone'; m.tattoo='tatnone'; m.bag=[]; m.prole=null;
  A.look1=l1; A.look2=l2;
  A.cam(X,Y-(t2.cy===undefined?4:t2.cy),Z);
  return {zoom:Z,chars:[{id:'p1',kind:'player',ref:'p1'},{id:'merc',kind:'pillager',ref:m},{id:'mate',kind:'player',ref:'mate'}]};
};

// duofar (a10): P1 on the left, the mate far to the right (about 330 world units), the camera pulled back so both fit
A.scenes.duofar=async function(o){
  var st=await A.stage(o), p=st.p, X=A.base().x, Y=A.base().y, Z=(window.__far&&window.__far.z)||2.7, D=(window.__far&&window.__far.d)||170;
  p.x=X-D; p.y=Y+4; p.face=0.1;
  A.mate(X+D,Y-4,3.0);
  A.cam(X,Y-6,Z);
  return {zoom:Z,chars:[{id:'p1',kind:'player',ref:'p1'},{id:'mate',kind:'player',ref:'mate'}]};
};

// busy (a07): the loot scene on a floor that is cluttered. The ground gets the game's own ruin paint (the burnt floor, the dust, the rubble blocks, the scorch;
// the same drawing as bakeGround's destroyed building, copied), dark crates and wrecks stand right behind P1, barrels and boxes round him.
A.scenes.busy=async function(o){
  var st=await A.stage(o), p=st.p, s=st.s, X=A.base().x, Y=A.base().y, Z=3.4, i, c, objs=[];
  var gc=s.ground.getContext('2d');
  function H(a,b){ var h=(Math.imul(a|0,374761393)^Math.imul(b|0,668265263))>>>0; h^=h>>>15; h=Math.imul(h,2246822519)>>>0; h^=h>>>13; return (h>>>8)/16777216; }
  var wallTop=gx('DISTRICTS[3].wallTop');
  function hexA(h,a){ return 'rgba('+parseInt(h.slice(1,3),16)+','+parseInt(h.slice(3,5),16)+','+parseInt(h.slice(5,7),16)+','+a+')'; }
  var cx=X+30, cy=Y-4, k;
  // 1. the burn: soft dark patches, thick under and round him (not one hard rectangle)
  for(k=0;k<14;k++){
    var bx=cx+(H(k*7,3)-0.5)*560, by=cy+(H(k*11,5)-0.5)*250, br=60+90*H(k*13,9);
    var gr=gc.createRadialGradient(bx,by,6,bx,by,br); gr.addColorStop(0,'rgba(22,19,17,0.62)'); gr.addColorStop(1,'rgba(22,19,17,0)');
    gc.fillStyle=gr; gc.beginPath(); gc.arc(bx,by,br,0,6.2832); gc.fill();
  }
  // 2. dust spilled over it
  gc.fillStyle='rgba(150,140,126,0.15)';
  for(k=0;k<40;k++){ var dx=cx+(H(k*13,7)-0.5)*600, dy=cy+(H(k*29,1)-0.5)*290, ds=10+26*H(k*23,11); gc.fillRect(dx-ds/2,dy-ds/3,ds,ds*0.66); }
  // 3. the rubble blocks (smaller, many, dark and light), a shadow and a face each, thick near him
  for(k=0;k<420;k++){
    var u1=H(k*31,17), u2=H(k*19,37), rr=Math.pow(H(k*5,23),0.8), an=u1*6.2832;
    var px=cx+Math.cos(an)*rr*330, py=cy+Math.sin(an)*rr*150+ (u2-0.5)*14, ps=4+13*H(k*43,5), tone=H(k*3,29);
    gc.fillStyle='rgba(14,12,11,0.5)'; gc.fillRect(px-ps/2+1.6,py-ps/3+1.6,ps,ps*0.62);
    gc.fillStyle=tone<0.45?'rgba(46,40,36,0.92)':(tone<0.75?'rgba(88,80,74,0.88)':hexA(wallTop,0.66));
    gc.fillRect(px-ps/2,py-ps/3,ps,ps*0.62);
  }
  // 4. the scorch under him
  var sg=gc.createRadialGradient(X,Y+4,4,X,Y+4,80); sg.addColorStop(0,'rgba(10,9,8,0.6)'); sg.addColorStop(1,'rgba(10,9,8,0)');
  gc.fillStyle=sg; gc.beginPath(); gc.arc(X,Y+4,80,0,6.2832); gc.fill();
  p.x=X; p.y=Y+6; p.face=0.5;
  // opened boxes to his left (staggered), piles to his right, as in the loot scene, but closer to him
  var opened=[["crate",-64,24],["locker",-96,-26],["safe",-128,24],["cache",-160,-26],["jackpot",-196,24]];
  for(i=0;i<opened.length;i++){ c=A.box(opened[i][0],X+opened[i][1],Y+opened[i][2],{opened:true}); objs.push({id:"open-"+opened[i][0],kind:"container",ref:c}); }
  var piles=[["medkit",52,24,"uncommon"],["core",100,2,"rare"],["blackbox",150,24,"elite"],["gun_sniper",198,2,"gold"]];
  for(i=0;i<piles.length;i++){ c=A.box("crate",X+piles[i][1],Y+piles[i][2],{loot:[piles[i][0]],drop:1}); objs.push({id:"pile-"+piles[i][3],kind:"pile",ref:c}); }
  // dark closed boxes right behind him, so the back of his outline sits against them, and two wrecks
  c=A.box("locker",X-20,Y-44,{loot:["board"]}); objs.push({id:"closed-locker",kind:"container",ref:c});
  c=A.box("safe",X+30,Y-46,{loot:["comp"]}); objs.push({id:"closed-safe",kind:"container",ref:c});
  c=A.box("botwreck",X-70,Y-62,{loot:["board"]}); c.bot="sentry"; objs.push({id:"wreck-sentry",kind:"wreck",ref:c});
  c=A.box("botwreck",X+84,Y-58,{loot:["comp"]}); c.bot="crawler"; objs.push({id:"wreck-crawler",kind:"wreck",ref:c});
  // barrels round the edge
  var bk=['red','acid'], bp=[[-236,-24],[236,32]];
  for(i=0;i<bp.length;i++) s.brl.push({id:s.brl.length,x:X+bp[i][0],y:Y+bp[i][1],hp:gx('BRL_HP'),fuse:-1,by:-1,gone:0,k:bk[i]});
  A.settleFx();
  A.cam(X+8,Y-6,Z);
  return {zoom:Z,chars:[{id:"p1",kind:"player",ref:"p1"}],objs:objs};
};
})();
