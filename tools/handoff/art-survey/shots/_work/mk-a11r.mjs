import fs from 'node:fs';
import { AS } from './lib.mjs';
import { sheets, wrap, page } from './snip-common.mjs';
// a11 redo: only C (smaller steps now really shorter, a hard foot plant) and D (ghosts and streaks that show). A and B are not touched.
const CAPS = {
  C: ['heavy and grounded', 'short quick steps, a hard plant, dust'],
  D: ['speed streaks', 'sprint leaves ghosts and streaks']
};
const BOB = { C: [0.8, 0.8], D: [1.5, 1.5] };
const SHEET = { C: ['C-walk', 'C-sprint'], D: ['A-walk', 'A-sprint'] };
// the step lengths: A steps every 0.28 s walking and 0.20 s sprinting; C steps every 0.20 s and 0.14 s at the SAME ground speed, so each step is about 30 percent shorter
const SD = { C: [0.20, 0.14], D: [0.28, 0.20] };
const common = (K) => `
var SDW=${SD[K][0]}, SDS=${SD[K][1]};
function pose(t){
  var sp=t>=1.5, lt=sp?t-1.5:t, sd=sp?SDS:SDW, ph=Math.PI*lt/sd, idx=Math.round((ph%TWO)/TWO*24)%24;
  if(idx<0) idx+=24;
  return {sp:sp, lt:lt, sd:sd, ph:ph, idx:idx, u:((ph/Math.PI)%1+1)%1, bob:(sp?BOBS:BOBW)*Math.abs(Math.sin(ph))*U4};
}
function scroll(t){ return t<1.5?150*t:225+260*(t-1.5); }
function label(sp){
  var s=sp?'sprinting':'walking'; c.save(); c.font='600 15px Barlow,Segoe UI,sans-serif'; var w=c.measureText(s).width+18;
  c.fillStyle='rgba(11,12,13,.62)'; c.fillRect(10,10,w,24); c.fillStyle=sp?'#e4ff2e':'#f2efe6'; c.textBaseline='middle'; c.fillText(s,19,22.5); c.restore();
}
`;
function body(K) {
  let extra = '', mid = '', pre = '', post = '';
  if (K === 'C') {
    mid = `fx+=0.8*U4*Math.sin(p.ph);
      var tau=p.u*p.sd, hit=1-eo(tau/(p.sp?0.12:0.10)), sqz=(p.sp?0.065:0.05)*hit;
      o.sy=1-sqz; o.sx=1+sqz*0.4;`;
    pre = `shadowS(CXF,1+(p.sp?0.14:0.09)*(1-eo(p.u*p.sd/0.10)));`;
    post = 'dust(t);';
    extra = `
function shadowS(x,k){ var s=SH.shadow; c.save(); c.translate(Math.round(x),GY); c.scale(k,k); c.drawImage(s.img,Math.round(-s.ox),Math.round(-s.oy)); c.restore(); }
function dust(t){
  var k, tb, tau, kk, x, y, sp, dur, side;
  for(k=0;k<20;k++){
    if(k<8){ tb=k*SDW; sp=0; if(tb>=1.5) continue; } else { tb=1.5+(k-8)*SDS; sp=1; }
    if(tb>t) continue; tau=t-tb; dur=sp?0.28:0.22; if(tau>=dur) continue; kk=tau/dur; side=(k%2)?5:-4;
    x=CXF-22+side-(scroll(t)-scroll(tb)); y=GY-3-(sp?11:6)*kk;
    c.save(); c.globalAlpha=(sp?0.6:0.42)*(1-kk); c.fillStyle='#8a8478'; c.beginPath(); c.arc(x,y,((sp?2:1.5)+(sp?3.4:2.2)*kk)*U4,0,TWO); c.fill();
    c.globalAlpha=(sp?0.3:0.2)*(1-kk); c.fillStyle='#b8b2a0'; c.beginPath(); c.arc(x+3,y-3,((sp?1.2:0.9)+(sp?2.2:1.4)*kk)*U4,0,TWO); c.fill(); c.restore(); }
}`;
  } else if (K === 'D') {
    extra = `
function ghosts(t,sh){
  var g, q, d=[[2/60,7*U4,0.58],[4/60,14*U4,0.32]];
  for(g=1;g>=0;g--){ q=pose(t-d[g][0]); spr(sh,q.idx,CXF-d[g][1],GY-q.bob,{a:d[g][2]}); }
}
function streaks(t,bob){
  var i, y, g, ys=[9,13,17], ln=[130,170,108], x0=CXF-34, L, wob;
  for(i=0;i<3;i++){
    wob=0.88+0.12*Math.sin(t*46+i*2.1); L=ln[i]*wob; y=GY-bob-ys[i]*U4;
    g=c.createLinearGradient(x0,0,x0-L,0); g.addColorStop(0,'rgba(255,255,255,.95)'); g.addColorStop(0.45,'rgba(255,255,255,.6)'); g.addColorStop(1,'rgba(255,255,255,0)');
    c.save(); c.strokeStyle=g; c.lineWidth=4; c.lineCap='round'; c.beginPath(); c.moveTo(x0,y); c.lineTo(x0-L,y); c.stroke(); c.restore();
  }
}`;
    pre = 'if(p.sp){ ghosts(t,sh); streaks(t,p.bob); }';
  }
  const dr = `
      var p=pose(t), off=scroll(t), sh=p.sp?SH.sprint:SH.walk, o={}, fx=CXF;
      ground(off);
      ${K === 'C' ? '' : 'shadow(CXF);'}
      ${pre}
      ${K === 'C' ? '' : ''}
      ${mid}
      spr(sh,p.idx,fx,GY-p.bob,o);
      ${post}
      groundFront(off);
      label(p.sp);`;
  return { extra: common(K) + `var BOBW=${BOB[K][0]}, BOBS=${BOB[K][1]};` + extra, dr };
}
for (const K of ['C', 'D']) {
  const P = 'a11-' + K.toLowerCase();
  const b = body(K);
  const shj = sheets({ walk: SHEET[K][0], sprint: SHEET[K][1], shadow: 'shadow' });
  const script = wrap(P, shj, b.extra, b.dr, { loop: 3.0 });
  const html = page(P, CAPS[K][0], `<b>${CAPS[K][0]}</b><span>${CAPS[K][1]}</span>`, script);
  fs.mkdirSync(AS + '/snip', { recursive: true });
  fs.writeFileSync(AS + '/snip/' + P + '.html', html);
  console.log(P, html.length);
}
