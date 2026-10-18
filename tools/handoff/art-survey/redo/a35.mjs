// redo/a35.mjs : game/a35-A|B|C|D.html = the explosion question, staged on a real cluster of three red barrels (each with its white !).
// The middle barrel goes off through the game's own brlBlast (its flash, fire, scorch, decal, puffs and boomFx), the other two stand
// beside it: one already lit (the chain's next), one still unlit. A is the unpatched game. B, C, D change the drawing code in the copy only.
//   B  bigger blast with scorch : boomFx 1.2 -> 1.92 (60 percent bigger), a much larger dark scorch on the floor under and around the fire
//   C  fireball and smoke column: a tall column of flame blobs (about 90 px) and a wide, dark smoke plume drifting up
//   D  chunky cartoon puff       : outlined white disc, orange-yellow blob ring with a black outline, outlined grey smoke, few chunks
// node redo/a35.mjs [age]     (age in seconds after the blast, default .15)
import fs from 'node:fs';
import { buildCopy } from './lib.mjs';
const AGE = process.argv[2] || '0.15';

const COMMON = `
function artDarkSpr35(){
  var c=window.__dsm35, x, gr;
  if(c) return c;
  c=document.createElement('canvas'); c.width=c.height=64; x=c.getContext('2d'); gr=x.createRadialGradient(30,28,0,32,32,32);
  gr.addColorStop(0,'rgba(66,60,55,.98)'); gr.addColorStop(0.5,'rgba(40,36,33,.93)'); gr.addColorStop(0.82,'rgba(26,23,21,.55)'); gr.addColorStop(1,'rgba(20,18,16,0)');
  x.fillStyle=gr; x.fillRect(0,0,64,64); window.__dsm35=c; return c;
}
`;

const COL_FN = `
function artCol35(b,t,m){
  var s=b.s, j, cf, ce, h, r, fa, wob, q, R, rise, ox, yy, al, ds=artDarkSpr35();
  if(t<1.0){
    cf=Math.min(1,t/0.30); ce=1-Math.pow(1-cf,2);
    fa=(t<0.5)?1:Math.max(0,1-(t-0.5)/0.45);
    wc.globalCompositeOperation='lighter';
    for(j=0;j<8;j++){
      h=(6+j*8.5)*ce*s; r=(24-j*2.2)*s*(0.55+0.45*ce); wob=Math.sin(t*26+j*1.9)*(1+j*0.8);
      wc.globalAlpha=fa*(0.95-j*0.07);
      wc.drawImage(m.fire,b.x+wob-r,b.y-16-h-r*0.85,r*2,r*1.7);
    }
    r=13*s*(0.5+0.5*ce); h=(6+7*8.5)*ce*s;
    wc.globalAlpha=fa; wc.drawImage(m.core,b.x+Math.sin(t*26+13)*5-r,b.y-18-h-r*0.5,r*2,r*1.1);
  }
  wc.globalCompositeOperation='source-over';
  for(j=0;j<12;j++){
    q=t-0.018*j; if(q<=0) continue;
    rise=1-Math.pow(1-Math.min(1,q/0.42),2);
    ox=Math.sin(j*2.3)*(9+j*2.4)*s+q*14;
    yy=-(14+j*9)*s*rise-q*10;
    R=(21+j*3.8)*s*(0.7+0.5*Math.min(1,q/0.8));
    al=0.96*Math.min(1,q*6)*Math.max(0,1-Math.max(0,q-2.4)/2.2);
    wc.globalAlpha=al; wc.drawImage(ds,b.x+ox-R,b.y-14+yy-R,R*2,R*2);
  }
  wc.globalAlpha=1;
}
`;

const TOON_FN = `
function artToon35(b,t){
  var s=b.s, x=b.x, y=b.y-14, j, a, d, k, e, r, q, sh, fa, INKC='#1a1210', cols=['#ff8f1f','#ffc933','#ff6a1a','#ffd84d','#ff9d2a'], n, sp;
  wc.save();
  try{
    wc.globalCompositeOperation='source-over'; wc.lineJoin='round'; wc.strokeStyle=INKC; wc.lineWidth=2;
    // smoke: a few light grey outlined puffs, rising and swelling
    for(j=0;j<5;j++){
      q=t-0.06-j*0.03; if(q<=0) continue;
      sp=1-Math.min(1,Math.max(0,(q-1.4)/0.9));
      if(sp<=0) continue;
      r=(9+j*2.5)*s*(0.7+0.5*Math.min(1,q/0.6))*sp;
      wc.globalAlpha=1; wc.fillStyle=(j&1)?'#d7d4cc':'#bfbcb4';
      wc.beginPath(); wc.arc(x+Math.sin(j*2.7)*(10+j*3)*s+q*8,y-(10+j*9)*s*(1-Math.pow(1-Math.min(1,q/0.7),2))-q*10,r,0,6.2832); wc.fill(); wc.stroke();
    }
    // the white flash disc, two frames
    if(t<0.034){
      wc.fillStyle='#fffbe8'; wc.beginPath(); wc.arc(x,y,30,0,6.2832); wc.fill(); wc.stroke();
    } else {
      k=Math.min(1,(t-0.034)/0.3); e=1-Math.pow(1-k,2);
      sh=(t<0.45)?1:Math.max(0,1-Math.pow((t-0.45)/0.35,2));
      if(sh>0){
        n=9;
        for(j=0;j<n;j++){
          a=j*6.2832/n+0.35; d=(12+36*e)*s; r=(9.5+9*e)*s*sh;
          wc.fillStyle=cols[j%cols.length];
          wc.beginPath(); wc.arc(x+Math.cos(a)*d,y+Math.sin(a)*d*0.74,r,0,6.2832); wc.fill(); wc.stroke();
        }
        for(j=0;j<4;j++){
          a=j*6.2832/4+0.9; d=(5+8*e)*s;
          wc.fillStyle=(j&1)?'#ffd84d':'#ffb52a';
          wc.beginPath(); wc.arc(x+Math.cos(a)*d,y+Math.sin(a)*d*0.74,(13+9*e)*s*sh,0,6.2832); wc.fill(); wc.stroke();
        }
        wc.fillStyle='#fff3b0'; wc.beginPath(); wc.arc(x,y,(9+6*e)*s*sh,0,6.2832); wc.fill(); wc.stroke();
      }
    }
    // a few chunky chunks
    for(j=0;j<Math.min(6,b.deb.length);j++){
      sp=b.deb[j]; q=Math.min(t,sp.tl); d=(t<sp.tl)?(sp.vz*t-260*t*t):0;
      wc.fillStyle=(t<0.5)?'#ff9a2e':'#6b625a';
      wc.fillRect(b.x+sp.ux*sp.sp*q-sp.r,b.y+sp.uy*sp.sp*q*0.62-d-sp.r,sp.r*2,sp.r*1.6); wc.strokeRect(b.x+sp.ux*sp.sp*q-sp.r,b.y+sp.uy*sp.sp*q*0.62-d-sp.r,sp.r*2,sp.r*1.6);
    }
  } finally { wc.restore(); }
}
`;

const DRAWHUD = 'function drawHUD(){';
const BOOM_ANCHOR = "      wc.globalCompositeOperation='source-over';\n      for(j=0;j<b.smoke.length;j++){";
const LOOP_ANCHOR = "    wc.save();\n    try{\n      wc.globalCompositeOperation='source-over';\n      for(j=0;j<b.deb.length;j++){";
const PUFF_ANCHOR = "wc.globalAlpha=a2*.55; wc.fillStyle=q.c;";
const BOOM12 = "try{ boomFx(x,y,1.2,'frag'); }catch(_bfx){}";
const SCAR1 = "try{ gfxBlastScar(x,y,1,false); }catch(_gbs){}\n  }\n  G.shake=Math.max(G.shake,sd<300?10:(sd<800?5:2));";

buildCopy('a35-A', []);
buildCopy('a35-B', [
  [DRAWHUD, "var ART35={k:'B'};\n" + DRAWHUD],
  [BOOM12, "try{ boomFx(x,y,1.92,'frag'); }catch(_bfx){}"],
  [SCAR1, "try{ gfxBlastScar(x,y,2.6,false); scarStamp('scorch',x,y,{r:104}); scarStamp('scorch',x,y,{r:84}); scarStamp('scorch',x,y,{r:60}); decal(x,y,'rgba(20,16,12,.55)',44); }catch(_gbs){}\n  }\n  G.shake=Math.max(G.shake,sd<300?10:(sd<800?5:2));"],
]);
buildCopy('a35-C', [
  [DRAWHUD, "var ART35={k:'C'};\n" + COMMON + COL_FN + DRAWHUD],
  [BOOM_ANCHOR, "      artCol35(b,t,m);\n" + BOOM_ANCHOR],
]);
buildCopy('a35-D', [
  [DRAWHUD, "var ART35={k:'D'};\n" + TOON_FN + DRAWHUD],
  [LOOP_ANCHOR, "    if(ART35.k==='D'){ artToon35(b,t); continue; }\n" + LOOP_ANCHOR],
  [PUFF_ANCHOR, "wc.globalAlpha=(ART35.k==='D')?0:a2*.55; wc.fillStyle=q.c;"],
]);

const JS = `
var A=window.__art, gx=window.__gx, s=A.state(), AGE=${AGE};
function age(sec){ var n=Math.round(sec*60), dt=1/60, k, i, sp, d; for(k=0;k<n;k++){
  for(i=s.sparks.length-1;i>=0;i--){ sp=s.sparks[i]; sp.t+=dt; sp.x+=sp.vx*dt; sp.y+=sp.vy*dt; d=Math.pow(.92,dt*60); sp.vx*=d; sp.vy*=d; if(sp.t>sp.life) s.sparks.splice(i,1); }
  for(i=s.puffs.length-1;i>=0;i--){ s.puffs[i].t+=dt; if(s.puffs[i].t>s.puffs[i].life) s.puffs.splice(i,1); } } }
var r=await A.scene('fight',{}); s=A.state();
s.bullets.length=0; s.shells.length=0; s.flashes.length=0; s.noiseRings.length=0; s.pings.length=0; gx('GFXMUZ.length=0'); s.sparks.length=0; s.puffs.length=0;
var b=A.base(), X=b.x+138, Y=b.y+96, i;
window.__bq={x:X,y:Y};
function mk(id,x,y){ return {id:id,x:x,y:y,hp:30,fuse:-1,by:-1,gone:0,k:'red'}; }
s.brl.length=0; var B0=mk(0,X,Y), B1=mk(1,X-80,Y+16), B2=mk(2,X+78,Y+24); s.brl.push(B0,B1,B2);
var ents=s.ents.splice(0,s.ents.length);
gx('FXS=0x2545F491');
gx('brlBlast(G.brl[0])');
for(i=0;i<ents.length;i++) s.ents.push(ents[i]);
B1.fuse=0.06; B2.fuse=-1; B2.chain=0;
s.puffs.length=0; s.flashes.length=0; gx('G.bfire.length=0');
s.noiseRings.length=0; s.pings.length=0; s.shake=0;
var bo=gx('BOOMS'); for(i=0;i<bo.length;i++){ bo[i].t0=s.t-AGE; }
age(AGE); A.draw(2); return r;`;
const BASE = "!!window.__art&&!!__state().player&&!__state().over&&!__state().drawErr&&document.getElementById('topright').style.display==='none'&&__P().cond==='day'&&__state().ents.length>=4&&__gx('BOOMS.length')===1&&__state().brl.filter(function(q){return q.gone;}).length===1&&__state().brl.filter(function(q){return !q.gone;}).length===2";
const S = {};
for (const k of ['A', 'B', 'C', 'D']) S['a35-' + k] = { js: JS, expect: BASE + (k === 'A' ? '' : "&&__gx('ART35.k')==='" + k + "'") };
fs.writeFileSync(new URL('screens-a35.json', import.meta.url), JSON.stringify(S, null, 1));
console.log('built a35 A-D at age ' + AGE);
