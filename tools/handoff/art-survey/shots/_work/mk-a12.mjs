import fs from 'node:fs';
import { AS } from './lib.mjs';
import { sheets, wrap, page } from './snip-common.mjs';
const CAPS = {
  A: ['red chest glow', 'today: a glow on the chest, a small shove'],
  B: ['white flash, then red', 'one quick white flash, a small recoil'],
  C: ['squash flinch', 'squashes and springs back, head tilts away'],
  D: ['freeze and shake', 'a tiny pause, a shake, a red outline']
};
const common = `
var HX=CXF-34, HY=GY-17*U4;
function shot(t){
  var q=t-0.1, i, a, hd, g, k, r0, r1;
  if(t>=0.055&&t<0.1){ hd=lerp(-30,HX,(t-0.055)/0.045); g=c.createLinearGradient(hd-80,0,hd,0); g.addColorStop(0,'rgba(255,233,168,0)'); g.addColorStop(1,'rgba(255,244,200,.95)');
    c.strokeStyle=g; c.lineWidth=3; c.lineCap='round'; c.beginPath(); c.moveTo(hd-80,HY); c.lineTo(hd,HY); c.stroke(); }
  if(q>=0&&q<0.09){ k=q/0.09; c.strokeStyle='rgba(255,236,170,'+(1-k).toFixed(3)+')'; c.lineWidth=2.5; c.lineCap='round';
    for(i=0;i<6;i++){ a=Math.PI+(i-2.5)*0.5; r0=6+k*14; r1=12+k*30; c.beginPath(); c.moveTo(HX+Math.cos(a)*r0,HY+Math.sin(a)*r0); c.lineTo(HX+Math.cos(a)*r1,HY+Math.sin(a)*r1); c.stroke(); } }
}
`;
function body(K) {
  let extra = common, dr = '', t0 = `var tau=t-0.1;`;
  if (K === 'A') {
    dr = `${t0} var ox=0, sh=SH.stand, idx=0;
      if(tau>=0&&tau<0.16) ox=4*U4*Math.sin(Math.PI*tau/0.16);
      if(tau>=0&&tau<0.4){ sh=SH.hurtA; idx=Math.min(7,Math.floor(tau/0.05)); }
      ground(0); shadow(CXF+ox); spr(sh,idx,CXF+ox,GY); groundFront(0); shot(t);`;
  } else if (K === 'B') {
    dr = `${t0} var ox=0, k;
      if(tau>=0&&tau<0.08) ox=2.5*U4*eo(tau/0.08); else if(tau>=0.08&&tau<0.22) ox=2.5*U4*(1-sm((tau-0.08)/0.14));
      scratch(SH.stand,0);
      if(tau>=0&&tau<0.066) tint('rgba(255,255,255,.9)'); else if(tau>=0.066&&tau<0.3) tint('rgba(255,60,48,'+(0.55*(1-(tau-0.066)/0.234)).toFixed(3)+')');
      ground(0); shadow(CXF+ox); putScratch(CXF+ox,GY); groundFront(0); shot(t);`;
  } else if (K === 'C') {
    dr = `${t0} var sx=1, sy=1, fi=0, k;
      if(tau>=0&&tau<0.3){
        if(tau<0.08){ k=eo(tau/0.08); sx=lerp(1,1.08,k); sy=lerp(1,0.88,k); }
        else if(tau<0.2){ k=sm((tau-0.08)/0.12); sx=lerp(1.08,0.97,k); sy=lerp(0.88,1.04,k); }
        else { k=sm((tau-0.2)/0.1); sx=lerp(0.97,1,k); sy=lerp(1.04,1,k); }
      }
      var useHit=tau>=0&&tau<0.28; if(useHit) fi=Math.min(13,Math.floor(tau/0.02));
      ground(0); shadow(CXF); spr(useHit?SH.hitC:SH.stand,useHit?fi:0,CXF,GY,{sx:sx,sy:sy}); groundFront(0); shot(t);`;
  } else {
    extra += `
var tmp2=document.createElement('canvas'); tmp2.width=240; tmp2.height=210; var t2=tmp2.getContext('2d');
var sil=null;
function mkSil(){ var s=document.createElement('canvas'); s.width=240; s.height=210; var x=s.getContext('2d'); x.drawImage(SH.stand.img,0,0); var d=x.getImageData(0,0,240,210), i; for(i=3;i<d.data.length;i+=4) d.data[i]=d.data[i]>110?255:0; x.putImageData(d,0,0); return s; }
function outline(x,y,col,a){
  if(!sil) sil=mkSil();
  var m, d, k, dx, dy;
  for(m=0;m<2;m++){
    d=m?2:5; t2.setTransform(1,0,0,1,0,0); t2.globalCompositeOperation='source-over'; t2.clearRect(0,0,240,210);
    for(k=0;k<8;k++){ dx=Math.round(Math.cos(k*0.7854)*d); dy=Math.round(Math.sin(k*0.7854)*d); t2.drawImage(sil,0,0,224,196,6+dx,6+dy,224,196); }
    t2.globalCompositeOperation='source-in'; t2.fillStyle=col; t2.fillRect(0,0,240,210); t2.globalCompositeOperation='source-over';
    c.save(); c.globalAlpha=a*(m?1:0.32); c.drawImage(tmp2,0,0,240,210,Math.round(x)-FX-6,Math.round(y)-FY-6,240,210); c.restore();
  }
}`;
    dr = `${t0} var ox=0, k;
      if(tau>=0.07&&tau<0.17){ k=(tau-0.07)/0.1; ox=2.5*U4*Math.sin(TWO*4*k)*(1-k); }
      scratch(SH.stand,0);
      ground(0); shadow(CXF+ox);
      if(tau>=0&&tau<0.18) outline(CXF+ox,GY,'#ff3b30',1-tau/0.18);
      putScratch(CXF+ox,GY); groundFront(0); shot(t);`;
  }
  return { extra, dr };
}
for (const K of ['A', 'B', 'C', 'D']) {
  const P = 'a12-' + K.toLowerCase();
  const b = body(K);
  const map = { stand: 'stand', shadow: 'shadow' };
  if (K === 'A') map.hurtA = 'hurtA';
  if (K === 'C') map.hitC = 'hitC';
  const script = wrap(P, sheets(map), b.extra, b.dr, { loop: 1.2 });
  const html = page(P, CAPS[K][0], `<b>${CAPS[K][0]}</b><span>${CAPS[K][1]}</span>`, script);
  fs.writeFileSync(AS + '/snip/' + P + '.html', html);
  console.log(P, html.length);
}
