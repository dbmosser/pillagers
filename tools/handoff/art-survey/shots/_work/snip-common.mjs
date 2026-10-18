import fs from 'node:fs';
import { WORK, AS } from './lib.mjs';
const meta = JSON.parse(fs.readFileSync(WORK + '/sprites/meta.json', 'utf8'));
export { meta };
export function b64(name) { return 'data:image/png;base64,' + fs.readFileSync(WORK + '/sprites/' + name + '.png').toString('base64'); }
// the sheet table for the snippet: name -> {u,w,h,n}
export function sheets(map) {
  const o = {};
  for (const [as, file] of Object.entries(map)) { const m = meta.sets[file]; o[as] = { u: b64(file), w: m.w, h: m.h, n: m.n, ox: m.ox, oy: m.oy }; }
  return JSON.stringify(o);
}
export const CSS = (P) => `
.${P}{position:relative;width:560px;height:340px;overflow:hidden;background:#0b0c0d;border:1px solid #23282c;border-radius:6px;box-sizing:border-box;font-family:'Barlow','Segoe UI',sans-serif;color:#f2efe6;text-transform:lowercase}
.${P}-cv{position:absolute;left:39px;top:11px;width:480px;height:270px;display:block;border-radius:3px;background:#587050}
.${P}-cap{position:absolute;left:0;right:0;bottom:0;height:48px;padding:0 20px;display:flex;align-items:center;gap:12px;border-top:1px solid #1c2024;background:#0b0c0d;font-size:17px;color:#a9a79e}
.${P}-cap b{font-family:'Barlow Condensed','Arial Narrow',sans-serif;font-weight:700;font-size:21px;color:#e4ff2e;letter-spacing:.01em}
`;
// the shared engine text: ground, sprites, loop. `body` supplies pose/draw code. All numbers in game units are multiplied by 4 (the sprites are drawn at 4x).
export const ENGINE = `
var U4=4, W=480, H=270, GY=215, CXF=CXFX, FX=${meta.fx}, FY=${meta.fy}, TWO=Math.PI*2;
function cl(x,a,b){ return x<a?a:(x>b?b:x); }
function eo(k){ k=cl(k,0,1); return 1-(1-k)*(1-k); }
function ei(k){ k=cl(k,0,1); return k*k; }
function lerp(a,b,k){ return a+(b-a)*k; }
function sm(k){ k=cl(k,0,1); return k*k*(3-2*k); }
var feats=[], patches=[];
(function(){ var s=12345; function r(){ s=(s*1664525+1013904223)>>>0; return s/4294967296; }
  var i; for(i=0;i<46;i++) feats.push({x:r()*GTW, y:70+r()*190, k:(r()<.68?0:(r()<.6?1:2)), s:.8+r()*.6});
  for(i=0;i<10;i++) patches.push({x:r()*GTW, y:80+r()*180, rx:60+r()*90, ry:24+r()*32});
})();
function gx(x,off){ return ((x-off)%GTW+GTW)%GTW-60; }
function ground(off){
  var i, p, f, x, g=c.createRadialGradient(240,150,40,240,150,340); g.addColorStop(0,'#779168'); g.addColorStop(1,'#566e4e');
  c.fillStyle=g; c.fillRect(0,0,W,H);
  c.fillStyle='rgba(44,66,38,.15)';
  for(i=0;i<patches.length;i++){ p=patches[i]; x=gx(p.x,off); c.beginPath(); c.ellipse(x,p.y,p.rx,p.ry,0,0,TWO); c.fill(); }
  for(i=0;i<feats.length;i++){ f=feats[i]; if(f.y>GY+3) continue; tuft(gx(f.x,off),f.y,f); }
}
function groundFront(off){ var i, f; for(i=0;i<feats.length;i++){ f=feats[i]; if(f.y<=GY+3) continue; tuft(gx(f.x,off),f.y,f); } }
function tuft(x,y,f){
  var s=f.s;
  if(f.k===2){ c.fillStyle='#677a5d'; c.fillRect(x-5*s,y-3*s,10*s,5*s); c.fillStyle='#7c9171'; c.fillRect(x-5*s,y-3*s,10*s,2*s); return; }
  c.strokeStyle=f.k===1?'#9bb78a':'#475f3f'; c.lineWidth=2.4; c.lineCap='round'; c.beginPath();
  c.moveTo(x,y); c.lineTo(x-5*s,y-10*s); c.moveTo(x,y); c.lineTo(x+1*s,y-13*s); c.moveTo(x,y); c.lineTo(x+6*s,y-9*s); c.stroke();
}
function shadow(x,a){ var s=SH.shadow; c.save(); c.globalAlpha=a==null?1:a; c.drawImage(s.img,Math.round(x-s.ox),Math.round(GY-s.oy)); c.restore(); }
// one frame of a sheet with the feet on (x,y): o.sx, o.sy scale about the feet, o.a alpha, o.rot radians about the feet
function spr(sh,idx,x,y,o){
  o=o||{}; c.save(); c.globalAlpha=o.a==null?1:o.a; c.translate(Math.round(x),Math.round(y));
  if(o.rot) c.rotate(o.rot); if(o.sx||o.sy) c.scale(o.sx||1,o.sy||1);
  c.drawImage(sh.img,idx*sh.w,0,sh.w,sh.h,-FX,-FY,sh.w,sh.h); c.restore();
}
var tmp=document.createElement('canvas'); tmp.width=240; tmp.height=210; var tc=tmp.getContext('2d');
// the frame on a scratch canvas (feet at FX,FY), so a colour can be laid on the body only
function scratch(sh,idx){ tc.setTransform(1,0,0,1,0,0); tc.globalCompositeOperation='source-over'; tc.globalAlpha=1; tc.clearRect(0,0,240,210); tc.drawImage(sh.img,idx*sh.w,0,sh.w,sh.h,0,0,sh.w,sh.h); return tc; }
function tint(col){ tc.globalCompositeOperation='source-atop'; tc.fillStyle=col; tc.fillRect(0,0,240,210); tc.globalCompositeOperation='source-over'; }
function putScratch(x,y,o){
  o=o||{}; c.save(); c.globalAlpha=o.a==null?1:o.a; c.translate(Math.round(x),Math.round(y)); if(o.rot) c.rotate(o.rot); if(o.sx||o.sy) c.scale(o.sx||1,o.sy||1);
  c.drawImage(tmp,0,0,224,196,-FX,-FY,224,196); c.restore();
}
function loadAll(SH,go){
  var k, left=0; for(k in SH) left++;
  for(k in SH){ (function(s){ s.img=new Image(); s.img.onload=function(){ if(--left===0) go(); }; s.img.src=s.u; })(SH[k]); }
}
`;
// wraps a body: root loop, freeze for a preview (data-t on the root), stops when the node is removed
export function wrap(P, sheetsJson, extra, bodyFn, o) {
  const cxf = o.cxf == null ? 200 : o.cxf, gtw = o.gtw || 615, loop = o.loop;
  const eng = ENGINE.replace('CXFX', String(cxf));
  return `<script>
(function(){
  var P='${P}', GTW=${gtw}, LOOP=${loop};
  Array.prototype.forEach.call(document.querySelectorAll('.'+P),function(root){
    if(root.getAttribute('data-on')) return; root.setAttribute('data-on','1');
    var cv=root.querySelector('canvas'), c=cv.getContext('2d'), SH=${sheetsJson};
    ${eng}
    ${extra || ''}
    function draw(t){
      ${bodyFn}
    }
    var fz=root.getAttribute('data-t');
    loadAll(SH,function(){
      if(fz!==null){ draw(parseFloat(fz)); return; }
      var T0=null;
      function frame(now){
        if(!root.isConnected) return;
        if(T0===null) T0=now;
        draw(((now-T0)/1000)%LOOP);
        requestAnimationFrame(frame);
      }
      requestAnimationFrame(frame);
    });
  });
})();
</script>`;
}
export function page(P, title, cap, script) {
  return `<!-- ${P}: ${title} -->
<style>${CSS(P)}</style>
<div class="${P}"><canvas class="${P}-cv" width="480" height="270"></canvas><div class="${P}-cap">${cap}</div></div>
${script}
`;
}
