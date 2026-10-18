// builds screens.json entries for the a37 prototypes (runtime hooks on the plain fixture; the final look is baked into game copies later)
import fs from 'node:fs';
const hud = (a, rgb, v0) => `window.__noHud=function(){ var c=gx('ctx'), W=gx('W'), H=gx('H'); c.clearRect(0,0,W,H); var vg=c.createRadialGradient(W/2,H/2,H*${v0},W/2,H/2,H*.85); vg.addColorStop(0,'rgba(${rgb},0)'); vg.addColorStop(1,'rgba(${rgb},${a})'); c.fillStyle=vg; c.fillRect(0,0,W,H); }; gx('drawHUD=window.__noHud');`;
const hook = (grade, grain) => `
window.__grade=${grade||'null'};
window.__grain=${grain||'null'};
gx('gfxPostFog=function(dt){ var on=gfxHook("postfog"); if(on&&window.__grade){ try{ window.__grade(wc,W,H,DPR); }catch(e){ window.__gerr=String(e); } } return on; }');
gx('gfxScreen=function(dt){ var on=gfxHook("screen"); if(on&&window.__grain){ try{ window.__grain(wc,W,H,DPR); }catch(e){ window.__gerr=String(e); } } return on; }');`;
const grainFn = (amp, px) => `function(c,W,H,DPR){ if(!window.__gtile){ var t=document.createElement('canvas'); t.width=t.height=256; var x=t.getContext('2d'), im=x.createImageData(256,256), i, v, s=1234567; for(i=0;i<65536;i++){ s=(s*1103515245+12345)&0x7fffffff; v=(s>>16)&1?255:0; im.data[i*4]=v; im.data[i*4+1]=v; im.data[i*4+2]=v; im.data[i*4+3]=Math.round(255*${amp}); } x.putImageData(im,0,0); window.__gtile=t; }
  c.save(); c.setTransform(1,0,0,1,0,0); c.imageSmoothingEnabled=false; c.globalCompositeOperation='source-over'; var pw=256*${px}*DPR; for(var yy=0;yy<c.canvas.height;yy+=pw) for(var xx=0;xx<c.canvas.width;xx+=pw) c.drawImage(window.__gtile,xx,yy,pw,pw); c.restore(); }`;
const mk = (grade, grain, vig) => `var r=await window.__art.scene('duo',{}); var gx=window.__gx; ${hud(vig[0], vig[1], vig[2])} ${hook(grade, grain)} window.__art.draw(2); return r;`;
const S = {};

const filt = (f) => ;
const gB3 = ;
const gB4 = ;
S.p37B3 = { js: mk(gB3, grainFn(0.045, 2), [0.68, '8,16,40', 0.36]) };
S.p37B4 = { js: mk(gB4, grainFn(0.045, 2), [0.74, '8,16,40', 0.34]) };
fs.writeFileSync(new URL('screens.json', import.meta.url), JSON.stringify(S, null, 1));
console.log(Object.keys(S).join(','));
