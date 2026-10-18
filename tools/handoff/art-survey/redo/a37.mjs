// redo/a37.mjs : builds the game copies game/a37-A|B|C.html (the real grade, grain and vignette hooks filled in the COPY only) and screens-a37.json.
// A = today's game, unpatched (vignette only, no grain, no grade). B = cinematic grade + light grain + navy edge. C = colour up a step + lighter vignette.
import fs from 'node:fs';
import { buildCopy } from './lib.mjs';

const GRADE_FN = `
var ART37={grade:'',grain:0,gpx:2,a:.45,rgb:'0,0,0',v0:.42};
function artGrade37(c,W,H,DPR){
  c.save();
  var s=window.__scr37||(window.__scr37=document.createElement('canvas')); s.width=c.canvas.width; s.height=c.canvas.height; s.getContext('2d').drawImage(c.canvas,0,0);
  c.setTransform(1,0,0,1,0,0);
  if(ART37.grade==='B'){
    c.filter='contrast(1.1) saturate(1.06)'; c.drawImage(s,0,0); c.filter='none';
    c.setTransform(DPR,0,0,DPR,0,0);
    c.globalCompositeOperation='screen'; c.fillStyle='rgb(6,12,34)'; c.fillRect(0,0,W,H);
    c.globalCompositeOperation='soft-light'; c.globalAlpha=.6; c.fillStyle='#ffb870'; c.fillRect(0,0,W,H);
  } else if(ART37.grade==='C'){
    c.filter='saturate(1.42) contrast(1.05)'; c.drawImage(s,0,0); c.filter='none';
  }
  c.restore();
}
function artGrain37(c,W,H,DPR){
  var amp=ART37.grain, px=ART37.gpx; if(!(amp>0)) return;
  if(!window.__gtile37){ var t=document.createElement('canvas'); t.width=t.height=256; var x=t.getContext('2d'), im=x.createImageData(256,256), i, v, sd=1234567;
    for(i=0;i<65536;i++){ sd=(sd*1103515245+12345)&0x7fffffff; v=(sd>>16)&1?255:0; im.data[i*4]=v; im.data[i*4+1]=v; im.data[i*4+2]=v; im.data[i*4+3]=Math.round(255*amp); }
    x.putImageData(im,0,0); window.__gtile37=t; }
  c.save(); c.setTransform(1,0,0,1,0,0); c.imageSmoothingEnabled=false; c.globalCompositeOperation='source-over';
  var pw=256*px*DPR; for(var yy=0;yy<c.canvas.height;yy+=pw) for(var xx=0;xx<c.canvas.width;xx+=pw) c.drawImage(window.__gtile37,xx,yy,pw,pw);
  c.restore();
}
`;
const hookEdits = (cfg) => [
  ["function gfxPostFog(dt){ return gfxHook('postfog'); }", "function gfxPostFog(dt){ var on=gfxHook('postfog'); if(on&&ART37.grade) artGrade37(wc,W,H,DPR); return on; }"],
  ["function gfxScreen(dt){ return gfxHook('screen'); }", "function gfxScreen(dt){ var on=gfxHook('screen'); if(on&&ART37.grain>0) artGrain37(wc,W,H,DPR); return on; }"],
  ['function drawHUD(){', GRADE_FN.replace("var ART37={grade:'',grain:0,gpx:2,a:.45,rgb:'0,0,0',v0:.42};", 'var ART37=' + JSON.stringify(cfg) + ';') + '\nfunction drawHUD(){'],
  ['var vg=ctx.createRadialGradient(W/2,H/2,H*.42,W/2,H/2,H*.85);', 'var vg=ctx.createRadialGradient(W/2,H/2,H*ART37.v0,W/2,H/2,H*.85);'],
  ["vg.addColorStop(0,'rgba(0,0,0,0)'); vg.addColorStop(1,'rgba(0,0,0,.45)');", "vg.addColorStop(0,'rgba('+ART37.rgb+',0)'); vg.addColorStop(1,'rgba('+ART37.rgb+','+ART37.a+')');"],
];
const CFG = {
  B: { grade: 'B', grain: 0.045, gpx: 2, a: 0.68, rgb: '8,16,40', v0: 0.36 },
  C: { grade: 'C', grain: 0, gpx: 2, a: 0.25, rgb: '0,0,0', v0: 0.42 },
};
// the vignette of the recipe's HUD (scene-lib's A.hud() wipes drawHUD with a fixed .45 vignette), read from the copy's ART37
const JS = (grade) => `var r=await window.__art.scene('duo',{}); var gx=window.__gx; window.__noHud=function(){ var c=gx('ctx'), W=gx('W'), H=gx('H'), V=gx('ART37'); c.clearRect(0,0,W,H); var vg=c.createRadialGradient(W/2,H/2,H*V.v0,W/2,H/2,H*.85); vg.addColorStop(0,'rgba('+V.rgb+',0)'); vg.addColorStop(1,'rgba('+V.rgb+','+V.a+')'); c.fillStyle=vg; c.fillRect(0,0,W,H); }; gx('drawHUD=window.__noHud'); window.__art.draw(2); return r;`;
const EXPECT = "!!window.__art&&!!__state().player&&!__state().over&&!__state().drawErr&&document.getElementById('topright').style.display==='none'&&__state().ents.length===0&&__P().cond==='day'&&__gx('ART37.grade')==='%G%'&&!window.__gerr";
const S = {};
S['a37-A'] = { from: 'a37-A' };
for (const k of ['B', 'C']) {
  buildCopy('a37-' + k, hookEdits(CFG[k]));
  S['a37-' + k] = { js: JS(k), expect: EXPECT.replace('%G%', k) };
}
buildCopy('a37-A', []);
fs.writeFileSync(new URL('screens-a37.json', import.meta.url), JSON.stringify(S, null, 1));
console.log('built a37-A,B,C');
