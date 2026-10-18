// m2-patches.mjs : the options of the machine questions a24..a28 that are drawn again (2026-10-18). One entry per option:
//   { screen, edits:[[find,replace,count?]] }  edits are applied to a COPY of tools/fixture.html (m2-lib.mjs adds the hooks); never written back.
import { wrapEdits, inject } from './m2-lib.mjs';
export const P = {};
const W = () => wrapEdits();

// ------------------------------------------------------------------ a24-D  toy bright: hulls painted red, yellow and blue, clean dark outlines
const TOY = `
var __TOYF={
  red:{deep:'#7d1a22',dark:'#b3262f',mid:'#e63946',light:'#ff6b6b',hi:'#ffb3a8',och:'#ffd23a',acc:'yellow'},
  yellow:{deep:'#8a6200',dark:'#c98f00',mid:'#ffc21a',light:'#ffd84d',hi:'#fff0a0',och:'#e63946',acc:'red'},
  blue:{deep:'#1c3f8c',dark:'#2563c9',mid:'#3b8bff',light:'#6db0ff',hi:'#b5dcff',och:'#ffd23a',acc:'yellow'}};
var __TOYK={sentry:'blue',crawler:'red',snitch:'yellow',bulwark:'red',howler:'blue',listener:'yellow',choir:'red',warden:'blue'};
var __TOYINK='#241f3d', __TOYB=false;
function __toyMap(v,fam){
  if(typeof v!=='string'||v.charAt(0)!=='#'||v.length!==7) return v;
  var k=v.toLowerCase(), F=__TOYF[fam], A=__TOYF[F.acc], r, g, b, mx, mn, l;
  var EX={'#4e2419':A.dark,'#7a3a2a':A.mid,'#9c5038':A.light,'#2a1610':A.deep,'#c8962e':F.och,'#c9a24a':F.och,'#e0bc62':F.och,'#8a6a2a':A.dark,'#120e0c':__TOYINK,'#0b0a09':__TOYINK};
  if(EX[k]) return EX[k];
  r=parseInt(k.substr(1,2),16); g=parseInt(k.substr(3,2),16); b=parseInt(k.substr(5,2),16);
  mx=Math.max(r,g,b); mn=Math.min(r,g,b);
  if(mx-mn>46) return v;
  l=(0.3*r+0.59*g+0.11*b)/255;
  if(__TOYB) l=Math.min(1,l*2.5);
  if(l>0.75) return v;
  if(l<0.14) return __TOYINK;
  if(l<0.225) return F.deep;
  if(l<0.31) return F.dark;
  if(l<0.44) return F.mid;
  if(l<0.57) return F.light;
  return F.hi;
}
function __toyOn(ctx,fam){
  var P=CanvasRenderingContext2D.prototype, df=Object.getOwnPropertyDescriptor(P,'fillStyle'), ds=Object.getOwnPropertyDescriptor(P,'strokeStyle');
  Object.defineProperty(ctx,'fillStyle',{configurable:true,enumerable:true,get:function(){ return df.get.call(ctx); },set:function(v){ df.set.call(ctx,__toyMap(v,fam)); }});
  Object.defineProperty(ctx,'strokeStyle',{configurable:true,enumerable:true,get:function(){ return ds.get.call(ctx); },set:function(v){ ds.set.call(ctx,__toyMap(v,fam)); }});
}
function __toyOff(ctx){ delete ctx.fillStyle; delete ctx.strokeStyle; }
__MW=function(kind,orig,e){
  var fam=e.boss?'yellow':__TOYK[kind], ctx=wc, ink0=INK, f0=ctx&&ctx.filter;
  if(!fam||!ctx||!ctx.getTransform) return orig(e);
  __toyOn(ctx,fam); INK=__TOYINK; __TOYB=!!e.boss;
  try{ ctx.filter='saturate(1.2) brightness(1.04)'; return orig(e); }
  finally{ ctx.filter=f0||'none'; INK=ink0; __TOYB=false; __toyOff(ctx); }
};
`;
P['a24-D'] = { screen: 'm-lineup', edits: [...W(), inject(TOY)] };

// ------------------------------------------------------------------ a25-B  a colour per machine: each kind has its own calm lens colour, bright and with a halo so it can be seen
const EYEB = `
var __EYEC={sentry:'#54e0ff',crawler:'#ffb23a',snitch:'#b6ff4a',listener:'#ff5ad2',bulwark:'#ff8a3c',howler:'#b07cff',warden:'#ffffff'};
window.__EYEB=1;
`;
P['a25-B'] = { screen: 'm-lineupmood', edits: [...W(),
  ['function sprEyeOf(e){', "function sprEyeOf(e){ var r=sprEyeOf0(e); if(window.__EYEB&&r.c==='#dfe9f0'&&r.h===0&&e&&__EYEC[e.kind]) return {c:__EYEC[e.kind],a:0.95,h:1.6}; return r; }\nfunction sprEyeOf0(e){"],
  ['function mbEye(e,T){', "function mbEye(e,T){ var r=mbEye0(e,T); if(window.__EYEB&&r[0]==='#dfe9f0'&&__EYEC[e.kind]) return [__EYEC[e.kind],.95,1]; return r; }\nfunction mbEye0(e,T){"],
  ["lg.addColorStop(0,'#ff5a4a');", "lg.addColorStop(0,(window.__EYEB&&!(e.seenYou||e.state==='chase'))?'#ff5ad2':'#ff5a4a');"],
  ["wc.fillStyle='#ff5a4a';\n    wc.fillRect(e.x-1.4+sway*1.2,hy-1.2,2.8,2.4);", "wc.fillStyle=(window.__EYEB&&!(e.seenYou||e.state==='chase'))?'#ff5ad2':'#ff5a4a';\n    wc.fillRect(e.x-1.4+sway*1.2,hy-1.2,2.8,2.4);"],
  inject(EYEB)] };

// ------------------------------------------------------------------ a26  machine size (the lineup with room): A as now, B every machine 1.25, C by threat, D every machine 1.5
const SCALE = (tbl, boss) => `
var __SC=${tbl};
__MW=function(kind,orig,e){
  var k=e.boss?${boss}:__SC[kind];
  if(!k||k===1||!wc) return orig(e);
  wc.save(); wc.translate(e.x,e.y); wc.scale(k,k); wc.translate(-e.x,-e.y);
  try{ return orig(e); } finally { wc.restore(); }
};
`;
P['a26-A'] = { screen: 'm-lineupbig', edits: [] };
P['a26-B'] = { screen: 'm-lineupbig', edits: [...W(), inject(SCALE("{sentry:1.25,crawler:1.25,snitch:1.25,listener:1.25,bulwark:1.25,howler:1.25,choir:1.25,warden:1.25}", '1.25'))] };
P['a26-C'] = { screen: 'm-lineupbig', edits: [...W(), inject(SCALE("{sentry:1,crawler:1,snitch:1,listener:1.1,bulwark:1.3,howler:1.3,choir:1.3,warden:1.5}", '1.25'))] };
P['a26-D'] = { screen: 'm-lineupbig', edits: [...W(), inject(SCALE("{sentry:1.5,crawler:1.5,snitch:1.5,listener:1.5,bulwark:1.5,howler:1.5,choir:1.5,warden:1.5}", '1.5'))] };

// ------------------------------------------------------------------ a27  warning before a shot (the fight, the sentry and the warden 60 percent through their windup)
const WINDHOOK = [
  ['function drawDeathAnims(){', 'function drawDeathAnims(){ if(window.__LATE) window.__LATE();'],
  ['function drawWindupGlow(e,gx,gy){', 'function drawWindupGlow(e,gx,gy){ if(window.__NOGLOW) return;'],
  ['function telegraphLane(e){', 'function telegraphLane(e){ if(window.__NOLANE) return null;'],
];
const MUZ = `
window.__NOGLOW=1; window.__NOLANE=1;
function __muz(e){
  var f, S;
  if(e.kind==='warden'){ f=Math.cos(e.face)>=0?1:-1; return {x:e.x+f*32.4,y:e.y-27}; }
  S=e.r/SENTRY_R0; return {x:e.x+Math.cos(e.face)*32*S,y:e.y-25*S+Math.sin(e.face)*32*S};
}
function __wf(e){ var tot=(e.kind==='warden')?0.7:0.4; return Math.max(0,Math.min(1,1-e.windup/tot)); }
`;
const RINGB = MUZ + `
function __ringB(e){
  var f=__wf(e), m=__muz(e), r=26-18*f, k, a, c, gr;
  wc.save();
  // the ring it started from, faint, and two ghosts of it on the way in
  wc.strokeStyle='rgba(255,59,48,.30)'; wc.lineWidth=1.6; wc.beginPath(); wc.arc(m.x,m.y,26,0,6.2832); wc.stroke();
  wc.strokeStyle='rgba(255,59,48,.13)'; wc.lineWidth=1.4;
  wc.beginPath(); wc.arc(m.x,m.y,r+11,0,6.2832); wc.stroke(); wc.beginPath(); wc.arc(m.x,m.y,r+5.5,0,6.2832); wc.stroke();
  // four marks between the rings, pointing in
  wc.strokeStyle='rgba(255,90,70,.75)'; wc.lineWidth=1.8; wc.lineCap='round';
  for(k=0;k<4;k++){ a=0.7854+k*1.5708; c=Math.cos(a); wc.beginPath(); wc.moveTo(m.x+c*(r+9.5),m.y+Math.sin(a)*(r+9.5)); wc.lineTo(m.x+c*(r+4.5),m.y+Math.sin(a)*(r+4.5)); wc.stroke(); }
  // the bright ring, closing on the gun
  wc.strokeStyle='rgba(255,59,48,'+(0.4+0.55*f).toFixed(3)+')'; wc.lineWidth=3.4; wc.beginPath(); wc.arc(m.x,m.y,r,0,6.2832); wc.stroke();
  wc.globalCompositeOperation='lighter'; wc.strokeStyle='rgba(255,59,48,.30)'; wc.lineWidth=6.5; wc.beginPath(); wc.arc(m.x,m.y,r,0,6.2832); wc.stroke();
  // the white flash at the barrel tip
  gr=wc.createRadialGradient(m.x,m.y,0.5,m.x,m.y,10); gr.addColorStop(0,'rgba(255,255,255,.95)'); gr.addColorStop(0.35,'rgba(255,235,225,.55)'); gr.addColorStop(1,'rgba(255,200,190,0)');
  wc.fillStyle=gr; wc.beginPath(); wc.arc(m.x,m.y,10,0,6.2832); wc.fill();
  wc.strokeStyle='rgba(255,255,255,.9)'; wc.lineWidth=1.5;
  wc.beginPath(); wc.moveTo(m.x-8,m.y); wc.lineTo(m.x+8,m.y); wc.moveTo(m.x,m.y-8); wc.lineTo(m.x,m.y+8); wc.stroke();
  wc.fillStyle='#ffffff'; wc.beginPath(); wc.arc(m.x,m.y,3,0,6.2832); wc.fill();
  wc.restore();
}
window.__LATE=function(){ var w=window.__wind, i; if(!w) return; for(i=0;i<w.length;i++) if(w[i]&&w[i].hp>0&&w[i].windup!==undefined&&w[i].windup!==null) __ringB(w[i]); };
`;
P['a27-B'] = { screen: 'm-fightwind', edits: [...WINDHOOK, inject(RINGB)] };

const LINEC = MUZ + `
function __lineC(e){
  var f=__wf(e), m=__muz(e), p=G.player, tx=p.x, ty=p.y-12, dx=tx-m.x, dy=ty-m.y, L=Math.hypot(dx,dy), ux=dx/L, uy=dy/L, hd=L*f, hx=m.x+ux*hd, hy=m.y+uy*hd, gr, k, a;
  wc.save(); wc.lineCap='round';
  // the whole way to the target, faint and dashed: where the shot will go
  wc.strokeStyle='rgba(255,59,48,.30)'; wc.lineWidth=1.3; wc.setLineDash([5,5]);
  wc.beginPath(); wc.moveTo(m.x,m.y); wc.lineTo(tx,ty); wc.stroke(); wc.setLineDash([]);
  // the line that has grown so far: thick, bright at the gun, fading toward its head
  gr=wc.createLinearGradient(m.x,m.y,hx,hy); gr.addColorStop(0,'rgba(255,59,48,.98)'); gr.addColorStop(1,'rgba(255,59,48,.55)');
  wc.globalCompositeOperation='lighter'; wc.strokeStyle='rgba(255,59,48,.22)'; wc.lineWidth=7; wc.beginPath(); wc.moveTo(m.x,m.y); wc.lineTo(hx,hy); wc.stroke();
  wc.globalCompositeOperation='source-over'; wc.strokeStyle=gr; wc.lineWidth=3; wc.beginPath(); wc.moveTo(m.x,m.y); wc.lineTo(hx,hy); wc.stroke();
  wc.strokeStyle='rgba(255,215,205,.85)'; wc.lineWidth=1; wc.beginPath(); wc.moveTo(m.x,m.y); wc.lineTo(hx,hy); wc.stroke();
  wc.fillStyle='#fff1ec'; wc.beginPath(); wc.arc(hx,hy,2.6,0,6.2832); wc.fill();
  // where it ends: a ring on the target
  wc.strokeStyle='rgba(255,59,48,.8)'; wc.lineWidth=1.8; wc.beginPath(); wc.arc(tx,ty,9,0,6.2832); wc.stroke();
  for(k=0;k<4;k++){ a=k*1.5708; wc.beginPath(); wc.moveTo(tx+Math.cos(a)*7,ty+Math.sin(a)*7); wc.lineTo(tx+Math.cos(a)*13,ty+Math.sin(a)*13); wc.stroke(); }
  wc.restore();
}
window.__LATE=function(){ var w=window.__wind, i; if(!w) return; for(i=0;i<w.length;i++) if(w[i]&&w[i].hp>0&&w[i].windup!==undefined&&w[i].windup!==null) __lineC(w[i]); };
`;
P['a27-C'] = { screen: 'm-fightwind', edits: [...WINDHOOK, inject(LINEC)] };

// ------------------------------------------------------------------ a28  destroying a machine (the fight, the sentry and the crawler 0.2 s after they were destroyed)
const DEADHOOK = [
  ['function drawDeathAnims(){', 'function drawDeathAnims(){ if(window.__DFDRAW){ window.__DFDRAW(); return 0; }'],
];
const HASH = `
function __h(n){ var x=Math.sin(n*127.1+311.7)*43758.5453; return x-Math.floor(x); }
function __rr(c,x,y,w,h,r){ wc.beginPath(); if(HAS_RR) wc.roundRect(x,y,w,h,r); else wc.rect(x,y,w,h); }
`;
const SPARKC = HASH + `
window.__DF={mode:'C'};
function __bolt(x0,y0,x1,y1,seed,amp){
  var n=7, i, px=x0, py=y0, t, nx, ny, L=Math.hypot(x1-x0,y1-y0)||1, ox=-(y1-y0)/L, oy=(x1-x0)/L, j;
  wc.beginPath(); wc.moveTo(x0,y0);
  for(i=1;i<=n;i++){ t=i/n; j=(i===n)?0:(__h(seed+i*3.1)-0.5)*2*amp; wc.lineTo(x0+(x1-x0)*t+ox*j,y0+(y1-y0)*t+oy*j); }
}
function __boltStroke(x0,y0,x1,y1,seed,amp,wd){
  wc.lineJoin='miter'; wc.lineCap='round';
  wc.strokeStyle='rgba(30,100,255,.40)'; wc.lineWidth=wd*3.2; __bolt(x0,y0,x1,y1,seed,amp); wc.stroke();
  wc.strokeStyle='#2f7bff'; wc.lineWidth=wd*1.5; __bolt(x0,y0,x1,y1,seed,amp); wc.stroke();
  wc.strokeStyle='#e2f0ff'; wc.lineWidth=wd*0.5; __bolt(x0,y0,x1,y1,seed,amp); wc.stroke();
}
function __sparkC(e,tau,seed){
  var N=26, i, a, v, d, px, py, L, c, big, k=e.r/22, ux, uy;
  for(i=0;i<N;i++){
    a=(__h(seed+i*1.7)*1.0-0.5)*5.0-1.5708+((i%3)?0:2.6); v=(150+__h(seed+i*2.3)*260)*(0.8+0.4*k); d=v*tau*0.8;
    ux=Math.cos(a); uy=Math.sin(a); px=e.x+ux*d; py=e.y-14*k+uy*d*0.8-8*Math.sin(Math.min(1,tau/0.5)*3.14);
    L=(5+__h(seed+i*4.1)*8)*(0.8+0.5*k); big=(i%5===0);
    c=(i%4===0)?'255,255,255':((i%4===1)?'150,215,255':((i%4===2)?'90,170,255':'200,235,255'));
    wc.strokeStyle='rgba('+c+',.95)'; wc.lineWidth=big?2.2:1.5; wc.lineCap='round';
    wc.beginPath(); wc.moveTo(px-ux*L,py-uy*L*0.8); wc.lineTo(px,py); wc.stroke();
    if(big){ wc.fillStyle='rgba(255,255,255,.95)'; wc.beginPath(); wc.arc(px,py,1.9,0,6.2832); wc.fill(); }
  }
}
function __hullC(e,tau){
  var f=Math.min(1,tau/0.25), sy=1-0.5*f, sx=1+0.14*f, kind=e.kind, ctx=wc, f0=ctx.filter, hp0=e.hp, mz=e.muzzle;
  ctx.save(); ctx.translate(e.x,e.y); ctx.scale(sx,sy); ctx.translate(-e.x,-e.y);
  e.hp=0; e.muzzle=0; e.hitT=0; e.windup=null;
  try{ ctx.filter='brightness(.74) saturate(.75)'; if(kind==='sentry') drawSentryS0(e); else drawCrawlerS0(e); }
  finally{ ctx.filter=f0||'none'; e.hp=hp0; e.muzzle=mz; ctx.restore(); }
}
window.__DFDRAW=function(){
  var d=window.__dead, tau=window.__DFT||0.2, i, e, k, gr, cy, seed, a0, b0;
  if(!d) return;
  for(i=0;i<d.length;i++){
    e=d[i]; k=e.r/22; cy=e.y-14*k*0.6; seed=(e.kind==='sentry')?11:57;
    wc.save();
    // the hull sags flat
    __hullC(e,tau);
    // a blue-white flash under everything else
    wc.globalCompositeOperation='lighter';
    gr=wc.createRadialGradient(e.x,cy,2,e.x,cy,e.r*2.1); gr.addColorStop(0,'rgba(170,215,255,.80)'); gr.addColorStop(0.45,'rgba(60,130,255,.35)'); gr.addColorStop(1,'rgba(30,80,255,0)');
    wc.fillStyle=gr; wc.beginPath(); wc.arc(e.x,cy,e.r*2.1,0,6.2832); wc.fill();
    wc.globalCompositeOperation='source-over';
    // bold blue arcs jumping across the hull
    __boltStroke(e.x-e.r*0.95,cy-e.r*0.55,e.x+e.r*0.2,cy+e.r*0.15,seed+1,e.r*0.32,2.0*(0.7+0.4*k));
    __boltStroke(e.x+e.r*0.1,cy-e.r*0.85,e.x+e.r*1.05,cy+e.r*0.25,seed+9,e.r*0.34,2.0*(0.7+0.4*k));
    __boltStroke(e.x-e.r*0.5,cy+e.r*0.35,e.x+e.r*0.7,cy-e.r*0.55,seed+17,e.r*0.30,1.7*(0.7+0.4*k));
    // the burst of sparks
    wc.globalCompositeOperation='lighter';
    __sparkC(e,tau,seed);
    wc.restore();
  }
};
`;
P['a28-C'] = { screen: 'm-fightdead', edits: [...W(), ...DEADHOOK, inject(SPARKC)] };

const CHUNKD = HASH + `
window.__DF={mode:'D'};
function __poly(p,fill,ink){
  var i; wc.beginPath(); wc.moveTo(p[0],p[1]); for(i=2;i<p.length;i+=2) wc.lineTo(p[i],p[i+1]); wc.closePath();
  wc.lineJoin='round'; wc.lineWidth=2.2; wc.strokeStyle=ink||INK; wc.stroke(); wc.fillStyle=fill; wc.fill();
}
// big pieces, each drawn around (0,0) at its own size; the machine's own greys, the hazard ochre, the oxide of the crawler shell
var __CH={
  sentry:[
   {deg:-38,sp:610,spin:3.2,s:1.25,fn:function(){ __poly([-11,-7,8,-7,12,-2,12,7,-11,7],'#59626b'); wc.fillStyle='#7c868f'; wc.fillRect(-10,-6,17,2.2); wc.fillStyle='#3e454c'; wc.fillRect(8,-2,3.5,8.5);
        wc.fillStyle='#c8962e'; __poly([-7,-1,-4.5,-1,-2,1.8,-4.5,4.6,-7,4.6,-4.5,1.8],'#c8962e'); __poly([-1.5,-1,1,-1,3.5,1.8,1,4.6,-1.5,4.6,1,1.8],'#c8962e'); }},
   {deg:-128,sp:560,spin:-4.1,s:1.3,fn:function(){ __poly([-7,-5,7,-5,9,-1,7,6,-7,6],'#59626b'); wc.fillStyle='#7c868f'; wc.fillRect(-6,-4,12,1.6); wc.fillStyle='#2a2f35'; wc.beginPath(); wc.arc(3,1,3.1,0,6.2832); wc.fill(); wc.fillStyle='#dfe9f0'; wc.beginPath(); wc.arc(3,1,1.6,0,6.2832); wc.fill(); wc.fillStyle='#3e454c'; wc.fillRect(-4,-9,2,4); }},
   {deg:34,sp:600,spin:2.6,s:1.2,fn:function(){ __poly([-12,-4,12,-4,12,4,-12,4],'#1b1f24'); wc.fillStyle='#363d45'; for(var q=-10;q<10;q+=5) wc.fillRect(q,-3,2.6,2); wc.fillStyle='#4a525b'; wc.beginPath(); wc.arc(-5,1,2.4,0,6.2832); wc.arc(4,1,2.4,0,6.2832); wc.fill(); }},
   {deg:-178,sp:540,spin:-2.2,s:1.25,fn:function(){ __poly([-13,-3.2,13,-3.2,13,3.2,-13,3.2],'#2a2f35'); wc.fillStyle='#4a525b'; wc.fillRect(-12,-2.4,24,1.6); wc.fillStyle='#8d98a3'; wc.fillRect(-12,-2.6,24,0.8); wc.fillStyle='#0e1114'; wc.fillRect(-6,-0.4,2,1.6); wc.fillRect(-1,-0.4,2,1.6); wc.fillRect(4,-0.4,2,1.6); }},
   {deg:92,sp:520,spin:5.0,s:1.15,fn:function(){ __poly([-6,-6,6,-6,7,6,-6,7],'#3e454c'); wc.fillStyle='#7c868f'; wc.beginPath(); wc.arc(0,0,3.4,0,6.2832); wc.fill(); wc.fillStyle='#2a2f35'; wc.beginPath(); wc.arc(0,0,1.4,0,6.2832); wc.fill(); }},
   {deg:-84,sp:640,spin:-3.4,s:1.1,fn:function(){ __poly([-6,-3,5,-5,8,2,-2,6],'#7c868f'); wc.fillStyle='#9aa4ad'; wc.fillRect(-4,-3,8,1.2); }}
  ],
  crawler:[
   {deg:-150,sp:600,spin:3.0,s:1.3,fn:function(){ __poly([-9,-3,-3,-6,6,-5,9,0,5,5,-6,5],'#7a3a2a'); wc.fillStyle='#9c5038'; wc.fillRect(-6,-4.2,11,1.8); wc.fillStyle='#4e2419'; wc.fillRect(4,0,3,4); }},
   {deg:-72,sp:560,spin:-3.6,s:1.3,fn:function(){ __poly([-8,-3,0,-6,8,-3,8,3,0,6,-8,3],'#7a3a2a'); wc.fillStyle='#9c5038'; wc.fillRect(-5,-3.6,9,1.6); wc.fillStyle='#4e2419'; wc.fillRect(-1,-5,1.4,10); }},
   {deg:-12,sp:640,spin:2.4,s:1.25,fn:function(){ __poly([-7,-4,7,-4,9,0,7,4,-7,4],'#7a3a2a'); wc.fillStyle='#9c5038'; wc.fillRect(-5,-3,10,1.4); }},
   {deg:44,sp:580,spin:-4.4,s:1.35,fn:function(){ __poly([-6,-4,5,-4,8,0,5,4,-6,4],'#3e454c'); wc.fillStyle='#59626b'; wc.fillRect(-5,-3,9,1.4); wc.fillStyle='#dfe9f0'; wc.fillRect(1,-1.6,1.8,1.8); wc.fillRect(4,-1.6,1.8,1.8);
        wc.strokeStyle=INK; wc.lineWidth=2.4; wc.beginPath(); wc.moveTo(6,-3); wc.lineTo(11,-6); wc.moveTo(6,3); wc.lineTo(11,6); wc.stroke(); wc.strokeStyle='#8d98a3'; wc.lineWidth=1; wc.stroke(); }},
   {deg:118,sp:560,spin:5.2,s:1.3,fn:function(){ wc.lineCap='round'; wc.lineJoin='round'; wc.strokeStyle=INK; wc.lineWidth=4.2; wc.beginPath(); wc.moveTo(-10,3); wc.lineTo(-2,-5); wc.lineTo(9,2); wc.stroke(); wc.strokeStyle='#59626b'; wc.lineWidth=2.2; wc.stroke(); wc.strokeStyle='#8d98a3'; wc.lineWidth=0.8; wc.stroke(); }},
   {deg:158,sp:520,spin:-5.6,s:1.25,fn:function(){ wc.lineCap='round'; wc.lineJoin='round'; wc.strokeStyle=INK; wc.lineWidth=4.2; wc.beginPath(); wc.moveTo(-9,-2); wc.lineTo(0,5); wc.lineTo(10,-3); wc.stroke(); wc.strokeStyle='#59626b'; wc.lineWidth=2.2; wc.stroke(); wc.strokeStyle='#8d98a3'; wc.lineWidth=0.8; wc.stroke(); }}
  ]
};
function __chunkD(e,c,tau,sh){
  var a=c.deg*Math.PI/180, ux=Math.cos(a), uy=Math.sin(a), d=c.sp*tau*0.82, lift=30*Math.sin(Math.min(1,tau/0.5)*3.14159), k=e.r/22, L, j, nx=-uy, ny=ux;
  var cx=e.x+ux*d, cy=e.y-12*(0.6+0.4*k)+uy*d*0.85, ang=c.spin*tau*3;
  // its shadow on the ground, then the short streaks behind it, then the piece itself
  wc.save();
  wc.fillStyle='rgba(0,0,0,.26)'; wc.beginPath(); wc.ellipse(cx,e.y+uy*d*0.85+3,8*c.s,3*c.s,0,0,6.2832); wc.fill();
  L=Math.min(34,d*0.4); wc.lineCap='round';
  for(j=-1;j<=1;j++){
    wc.strokeStyle='rgba(245,240,226,'+(j===0?0.7:0.38)+')'; wc.lineWidth=j===0?1.8:1.1;
    wc.beginPath(); wc.moveTo(cx-ux*5+nx*j*4.5,cy-lift-uy*5+ny*j*4.5); wc.lineTo(cx-ux*(5+L*(j===0?1:0.62))+nx*j*4.5,cy-lift-uy*(5+L*(j===0?1:0.62))+ny*j*4.5); wc.stroke();
  }
  wc.translate(cx,cy-lift); wc.rotate(ang); wc.scale(c.s,c.s); c.fn();
  wc.restore();
}
window.__DFDRAW=function(){
  var d=window.__dead, tau=window.__DFT||0.2, i, e, j, gr, list;
  if(!d) return;
  for(i=0;i<d.length;i++){
    e=d[i]; list=__CH[e.kind]; if(!list) continue;
    wc.save();
    // what is left where the body stood: a scorch on the ground and a fading flash
    wc.fillStyle='rgba(18,12,8,.40)'; wc.beginPath(); wc.ellipse(e.x,e.y+2,e.r*1.15,e.r*0.5,0,0,6.2832); wc.fill();
    wc.globalCompositeOperation='lighter';
    gr=wc.createRadialGradient(e.x,e.y-8,1,e.x,e.y-8,e.r*1.5); gr.addColorStop(0,'rgba(255,200,120,.45)'); gr.addColorStop(1,'rgba(255,120,40,0)');
    wc.fillStyle=gr; wc.beginPath(); wc.arc(e.x,e.y-8,e.r*1.5,0,6.2832); wc.fill();
    wc.globalCompositeOperation='source-over';
    wc.restore();
    for(j=0;j<list.length;j++) __chunkD(e,list[j],tau);
  }
};
`;
P['a28-D'] = { screen: 'm-fightdead', edits: [...DEADHOOK, inject(CHUNKD)] };
