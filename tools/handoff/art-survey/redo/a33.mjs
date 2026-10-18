// redo/a33.mjs : game/a33-C.html = long glow streaks, each in its own gun's or element's colour (a saturated glow under a pale core,
// drawn over the ground rather than added to it, so the colour reads). The scene gives each shooter's rounds the colour the Forge
// really gives them (ELEM[el].c with el set), so four different colours are in the air at once.
import fs from 'node:fs';
import { buildCopy } from './lib.mjs';

const FN = `
function trcRgb33(hex,pale){
  var h=String(hex||'#ffd48a'), r, g, b, mx, mn, l, s, d, hh, q, p2, f;
  if(h.length===4) h='#'+h.charAt(1)+h.charAt(1)+h.charAt(2)+h.charAt(2)+h.charAt(3)+h.charAt(3);
  r=parseInt(h.slice(1,3),16)/255; g=parseInt(h.slice(3,5),16)/255; b=parseInt(h.slice(5,7),16)/255;
  if(pale){ r=r+(1-r)*pale; g=g+(1-g)*pale; b=b+(1-b)*pale; return Math.round(r*255)+','+Math.round(g*255)+','+Math.round(b*255); }
  mx=Math.max(r,g,b); mn=Math.min(r,g,b); l=(mx+mn)/2; d=mx-mn;
  if(d<1e-4){ hh=0; s=0; } else { s=l>.5?d/(2-mx-mn):d/(mx+mn); hh=mx===r?((g-b)/d+(g<b?6:0)):(mx===g?(b-r)/d+2:(r-g)/d+4); hh/=6; }
  s=Math.max(s,.92); l=Math.min(.62,Math.max(.5,l));
  q=l<.5?l*(1+s):l+s-l*s; p2=2*l-q;
  f=function(t){ if(t<0)t+=1; if(t>1)t-=1; return t<1/6?p2+(q-p2)*6*t:(t<.5?q:(t<2/3?p2+(q-p2)*(2/3-t)*6:p2)); };
  return Math.round(f(hh+1/3)*255)+','+Math.round(f(hh)*255)+','+Math.round(f(hh-1/3)*255);
}
function trc33(b,bm){
  var hex=(b.el&&ELEM[b.el])?ELEM[b.el].c:b.tint, len=b.rkt?64:36, d, x1=b.x, y1=b.y-12, x0, y0, g, rgb, pale;
  if(b.mzd>0){ d=Math.hypot(b.x-b.sx,b.y-b.sy)-b.mzd; if(d<=3) return; len=Math.min(len,d); }
  x0=x1-b.vx/bm*len; y0=y1-b.vy/bm*len;
  rgb=trcRgb33(hex,0); pale=trcRgb33(hex,.62);
  wc.save(); wc.globalCompositeOperation='source-over'; wc.lineCap='round';
  g=wc.createLinearGradient(x0,y0,x1,y1); g.addColorStop(0,'rgba('+rgb+',0)'); g.addColorStop(1,'rgba('+rgb+',.62)');
  wc.strokeStyle=g; wc.lineWidth=8; wc.beginPath(); wc.moveTo(x0,y0); wc.lineTo(x1,y1); wc.stroke();
  g=wc.createLinearGradient(x0,y0,x1,y1); g.addColorStop(0,'rgba('+rgb+',0)'); g.addColorStop(.5,'rgba('+rgb+',.7)'); g.addColorStop(1,'rgba('+rgb+',1)');
  wc.strokeStyle=g; wc.lineWidth=4; wc.beginPath(); wc.moveTo(x0,y0); wc.lineTo(x1,y1); wc.stroke();
  g=wc.createLinearGradient(x0,y0,x1,y1); g.addColorStop(0,'rgba('+pale+',0)'); g.addColorStop(1,'rgba('+pale+',1)');
  wc.strokeStyle=g; wc.lineWidth=1.8; wc.beginPath(); wc.moveTo(x0,y0); wc.lineTo(x1,y1); wc.stroke();
  wc.restore();
}
`;
buildCopy('a33-C', [
  ['wc.beginPath(); wc.moveTo(b.x-b.vx/bm*_gtl,b.y-b.vy/bm*_gtl-12);', 'trc33(b,bm); wc.beginPath(); wc.moveTo(b.x,b.y-12);'],
  ['function drawHUD(){', FN + '\nfunction drawHUD(){'],
]);
const JS = `var r=await window.__art.scene('fight',{}); var A=window.__art, gx=window.__gx, s=A.state(), p=s.player, pa=s.ents[0], pb=s.ents[1], E=gx('ELEM'), i, b;
for(i=0;i<s.bullets.length;i++){ b=s.bullets[i]; if(b.owner===p){ b.el='shock'; b.tint=E.shock.c; } else if(b.owner===pa){ b.el='fire'; b.tint=E.fire.c; } else if(b.owner===pb){ b.el='acid'; b.tint=E.acid.c; } }
A.draw(2); return r;`;
const EXPECT = "!!window.__art&&!!__state().player&&!__state().over&&!__state().drawErr&&document.getElementById('topright').style.display==='none'&&__P().cond==='day'&&__state().bullets.length>=8&&__state().bullets.filter(b=>b.el).length>=6";
fs.writeFileSync(new URL('screens-a33.json', import.meta.url), JSON.stringify({ 'a33-C': { js: JS, expect: EXPECT } }, null, 1));
console.log('built a33-C');
