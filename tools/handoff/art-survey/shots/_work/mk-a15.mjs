import fs from 'node:fs';
import { AS } from './lib.mjs';
import { sheets, wrap, page, meta } from './snip-common.mjs';
const CAPS = {
  A: ['squash and fade', 'today: a flat shape squashes and fades'],
  B: ['fall and turn to light', 'drops flat, breaks into rising light'],
  C: ['knocked away', 'thrown along the shot, a few drops of blood'],
  D: ['drops the kit', 'the gun and the pack clatter to the floor']
};
const COAT = meta.coatP;
const common = `
var HX=CXF-34, HY=GY-17*U4, D0=0.2;
function shot(t){
  var q=t-D0, i, a, hd, g, k, r0, r1;
  if(t>=D0-0.045&&t<D0){ hd=lerp(-30,HX,(t-(D0-0.045))/0.045); g=c.createLinearGradient(hd-80,0,hd,0); g.addColorStop(0,'rgba(255,233,168,0)'); g.addColorStop(1,'rgba(255,244,200,.95)');
    c.strokeStyle=g; c.lineWidth=3; c.lineCap='round'; c.beginPath(); c.moveTo(hd-80,HY); c.lineTo(hd,HY); c.stroke(); }
  if(q>=0&&q<0.09){ k=q/0.09; c.strokeStyle='rgba(255,236,170,'+(1-k).toFixed(3)+')'; c.lineWidth=2.5; c.lineCap='round';
    for(i=0;i<6;i++){ a=Math.PI+(i-2.5)*0.5; r0=6+k*14; r1=12+k*30; c.beginPath(); c.moveTo(HX+Math.cos(a)*r0,HY+Math.sin(a)*r0); c.lineTo(HX+Math.cos(a)*r1,HY+Math.sin(a)*r1); c.stroke(); } }
}
function fadeIn(t){ return cl(t/0.12,0,1); }
function px(x,y,w,col,a){ c.save(); c.globalAlpha=a; c.fillStyle=col; c.fillRect(Math.round(x-w/2),Math.round(y-w/2),w,w); c.restore(); }
`;
function body(K) {
  let extra = common, dr = '';
  const pre = `var d=t-D0, fi=fadeIn(t); ground(0);`;
  if (K === 'A') {
    dr = `${pre}
      if(d<0){ shadow(CXF); spr(SH.stand,0,CXF,GY,{a:fi}); }
      else if(d<0.8){ var k=1-d/0.8, sx=0.65+0.35*k, sy=0.55+0.45*k, rot=1.4*(d/0.8);
        c.save(); c.translate(CXF,GY-7*U4); c.rotate(rot); c.scale(sx,sy); c.globalAlpha=0.85*k;
        c.fillStyle='${COAT}'; c.strokeStyle='#14161b'; c.lineWidth=3/Math.max(sx,sy); c.beginPath(); c.ellipse(0,0,10*U4,8*U4,0,0,TWO); c.fill(); c.stroke(); c.restore(); }
      groundFront(0); shot(t);`;
  } else if (K === 'B') {
    extra += `
var LP=[]; (function(){ var s=777; function r(){ s=(s*1664525+1013904223)>>>0; return s/4294967296; } for(var i=0;i<14;i++) LP.push({x:(r()-0.5)*120,y:(r()-0.5)*34,ts:0.4+r()*0.2,dx:(r()-0.3)*24}); })();`;
    dr = `${pre}
      var al=1, fall=0;
      if(d>=0){ fall=ei(d/0.22); if(d>=0.4) al=cl(1-(d-0.4)/0.5,0,1); }
      if(d>=0.9) al=0;
      shadow(CXF,al);
      if(al>0){
        var th=fall*Math.PI/2, f=lerp(1,0.55,fall), px0=lerp(CXF,CXF-4,fall), py0=lerp(GY,GY-34+6*U4*fall*0,fall);
        c.save(); c.translate(Math.round(px0),Math.round(py0)); c.scale(1,f); c.rotate(th); c.globalAlpha=al*fi;
        c.drawImage(SH.stand.img,0,0,SH.stand.w,SH.stand.h,-FX,-FY,SH.stand.w,SH.stand.h); c.restore();
      }
      if(d>=0.4&&d<1.0){ var i, q, kk; for(i=0;i<LP.length;i++){ q=LP[i]; kk=(d-q.ts)/0.5; if(kk<0||kk>1) continue;
        px(CXF+70+q.x+q.dx*kk,GY-30+q.y-22*U4*kk,2*U4,'#ffb02e',1-kk); } }
      groundFront(0); shot(t);`;
  } else if (K === 'C') {
    extra += `
var DR=[[110,90],[85,120],[140,70],[70,140],[120,100]];`;
    dr = `${pre}
      if(d<0.75){
        var m=eo(d/0.35)*(d<0.35?1:0)+(d>=0.35?1:0), al=1; if(d>=0.2) al=cl(1-(d-0.2)/0.55,0,1); if(d<0){ m=0; al=1; }
        var ox=16*U4*m, th=(20*Math.PI/180)*m;
        shadow(CXF+ox,al);
        spr(SH.stand,0,CXF+ox,GY,{rot:th,a:al*fi});
      }
      if(d>=0.4){ c.save(); c.globalAlpha=0.7-0.1*cl((d-0.4)/6,0,1); c.fillStyle='#b02a20'; c.beginPath(); c.ellipse(CXF+6*U4,GY-1,3*U4,1.3*U4,0,0,TWO); c.fill(); c.restore(); }
      if(d>=0.05&&d<0.4){ var j, tt=d-0.05, kk=tt/0.35, v; for(j=0;j<DR.length;j++){ v=DR[j];
        c.save(); c.globalAlpha=1-0.6*kk; c.fillStyle='#b02a20'; c.beginPath(); c.arc(HX+v[0]*tt*U4,HY+(-v[1]*tt+0.5*600*tt*tt)*U4,1.5*U4,0,TWO); c.fill(); c.restore(); } }
      groundFront(0); shot(t);`;
  } else {
    extra += `
var GUN=SH.gun, PK=SH.pack;
var BG={x:CXF+GUN.w/2-GUN.ox, y:GY-20*U4+GUN.h/2-GUN.oy}, BP={x:CXF+PK.w/2-PK.ox, y:GY+PK.h/2-PK.oy}, GR=3600;
function gunPos(d){
  var yl=GY-8, y0=BG.y, T1=Math.sqrt(2*(yl-y0)/GR), h1=24, h2=8, T2=2*Math.sqrt(2*h1/GR), T3=2*Math.sqrt(2*h2/GR), tot=T1+T2+T3, y, p, u;
  if(d<0) return {x:BG.x,y:y0,rot:0};
  if(d<T1) y=y0+0.5*GR*d*d;
  else if(d<T1+T2){ u=d-T1; y=yl-(Math.sqrt(2*h1*GR)*u-0.5*GR*u*u); }
  else if(d<tot){ u=d-T1-T2; y=yl-(Math.sqrt(2*h2*GR)*u-0.5*GR*u*u); }
  else y=yl;
  p=cl(d/tot,0,1);
  return {x:BG.x+14*U4*eo(p),y:y,rot:(540*Math.PI/180)*eo(p)};
}
function packPos(d){
  var yl=GY-8, y0=BP.y, T=0.35, v0=(0.5*GR*T*T-(yl-y0))/T, tau=Math.min(d,T), y;
  if(d<0) return {x:BP.x,y:y0,rot:0};
  y=y0-v0*tau+0.5*GR*tau*tau; if(d>=T) y=yl;
  return {x:BP.x-10*U4*cl(d/T,0,1),y:y,rot:(150*Math.PI/180)*eo(d/T)};
}`;
    dr = `${pre}
      var fa=d<0?1:cl(1-d/0.3,0,1), ka=1; if(d>0.7) ka=cl(1-(d-0.7)/0.2,0,1);
      if(d<0.3){ shadow(CXF,fa); spr(SH.stand,0,CXF,GY,{a:fa*fi}); }
      if(ka>0){
        var gp=gunPos(d), pp=packPos(d);
        // the pack
        c.save(); c.globalAlpha=ka*fi; c.translate(pp.x,pp.y); c.rotate(pp.rot); c.drawImage(PK.img,-PK.w/2,-PK.h/2); c.restore();
        // the gun
        c.save(); c.globalAlpha=ka*fi; c.translate(gp.x,gp.y); c.rotate(gp.rot); c.drawImage(GUN.img,-GUN.w/2,-GUN.h/2); c.restore();
      }
      groundFront(0); shot(t);`;
  }
  return { extra, dr };
}
for (const K of ['A', 'B', 'C', 'D']) {
  const P = 'a15-' + K.toLowerCase();
  const b = body(K);
  const map = { stand: 'stand', shadow: 'shadow' };
  if (K === 'D') { map.gun = 'gun'; map.pack = 'pack'; }
  const script = wrap(P, sheets(map), b.extra, b.dr, { loop: 1.6 });
  const html = page(P, CAPS[K][0], `<b>${CAPS[K][0]}</b><span>${CAPS[K][1]}</span>`, script);
  fs.writeFileSync(AS + '/snip/' + P + '.html', html);
  console.log(P, html.length);
}
