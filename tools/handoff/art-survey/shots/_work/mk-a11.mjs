import fs from 'node:fs';
import { AS } from './lib.mjs';
import { sheets, wrap, page } from './snip-common.mjs';
const CAPS = {
  A: ['as now', 'calm swing, small bob'],
  B: ['bouncy', 'bigger bob, a squash on every step'],
  C: ['heavy and grounded', 'small steps, a sway, dust on a sprint'],
  D: ['speed streaks', 'sprint leaves ghosts and streaks']
};
const BOB = { A: [1.5, 1.5], B: [2.6, 3.6], C: [0.8, 0.8], D: [1.5, 1.5] };
const SHEET = { A: ['A-walk', 'A-sprint'], B: ['B-walk', 'B-sprint'], C: ['C-walk', 'C-sprint'], D: ['A-walk', 'A-sprint'] };
const common = `
function pose(t){
  var sp=t>=1.5, lt=sp?t-1.5:t, sd=sp?0.20:0.28, ph=Math.PI*lt/sd, idx=Math.round((ph%TWO)/TWO*24)%24;
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
  let extra = '', mid = '';
  if (K === 'B') {
    mid = `var tau=p.u*p.sd, sq=tau<0.06?1-eo(tau/0.06):0, sw=Math.sin(Math.PI*p.u); o.sy=1+0.03*sw-0.06*sq; o.sx=1-0.02*sw+0.04*sq;`;
  } else if (K === 'C') {
    mid = `fx+=0.8*U4*Math.sin(p.ph);`;
    extra = `
function dust(t){
  var k, tb, tau, kk, xb, x, y;
  for(k=0;k<8;k++){ tb=1.5+k*0.20; tau=t-tb; if(tau<0||tau>=0.26) continue; kk=tau/0.26;
    x=CXF-24-(scroll(t)-scroll(tb)); y=GY-3-10*kk;
    c.save(); c.globalAlpha=0.35*(1-kk); c.fillStyle='#8a8478'; c.beginPath(); c.arc(x,y,(2+3*kk)*U4,0,TWO); c.fill(); c.restore(); }
}`;
  } else if (K === 'D') {
    extra = `
function ghosts(t,sh){
  var g, q, d=[[2/60,6*U4,0.22],[4/60,12*U4,0.10]];
  for(g=0;g<2;g++){ q=pose(t-d[g][0]); spr(sh,q.idx,CXF-d[g][1],GY-q.bob,{a:d[g][2]}); }
}
function streaks(bob){
  var i, y, g, ys=[10,13,16];
  for(i=0;i<3;i++){ y=GY-bob-ys[i]*U4; g=c.createLinearGradient(CXF-76,0,CXF-76-8*U4,0); g.addColorStop(0,'rgba(255,255,255,.25)'); g.addColorStop(1,'rgba(255,255,255,0)');
    c.strokeStyle=g; c.lineWidth=2.5; c.beginPath(); c.moveTo(CXF-76,y); c.lineTo(CXF-76-8*U4,y); c.stroke(); }
}`;
  }
  const dr = `
      var p=pose(t), off=scroll(t), sh=p.sp?SH.sprint:SH.walk, o={}, fx=CXF;
      ground(off);
      shadow(CXF);
      ${K === 'D' ? 'if(p.sp){ ghosts(t,sh); streaks(p.bob); }' : ''}
      ${mid}
      spr(sh,p.idx,fx,GY-p.bob,o);
      ${K === 'C' ? 'if(p.sp) dust(t);' : ''}
      groundFront(off);
      label(p.sp);`;
  return { extra: common + `var BOBW=${BOB[K][0]}, BOBS=${BOB[K][1]};` + extra, dr };
}
for (const K of ['A', 'B', 'C', 'D']) {
  const P = 'a11-' + K.toLowerCase();
  const b = body(K);
  const shj = sheets({ walk: SHEET[K][0], sprint: SHEET[K][1], shadow: 'shadow' });
  const script = wrap(P, shj, b.extra, b.dr, { loop: 3.0 });
  const html = page(P, CAPS[K][0], `<b>${CAPS[K][0]}</b><span>${CAPS[K][1]}</span>`, script);
  fs.mkdirSync(AS + '/snip', { recursive: true });
  fs.writeFileSync(AS + '/snip/' + P + '.html', html);
  console.log(P, html.length);
}
