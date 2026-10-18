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
