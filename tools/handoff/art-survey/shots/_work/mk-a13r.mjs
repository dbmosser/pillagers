import fs from 'node:fs';
import { mkgame, mkrec, shoot, rmgame, WORK } from './lib.mjs';
const keys = process.argv.slice(2).length ? process.argv.slice(2) : ['A', 'B', 'D'];
const WASH = process.env.WASH ? +process.env.WASH : 0.19;   // option A: today's fill alpha at the top of its pulse
// P1 at hp 18, P2 at full health. The scene wipes the HUD, so the wash and the edge pulse are laid on the HUD canvas here, with the game's own numbers.
const js = `
const A=window.__art, gx=__gx;
const note=await A.scene('duo',{});
const s=__state(), p=s.player; p.hp=18;
const opt=window.__OPT;
window.__noHud0=window.__noHud;
window.__noHud2=function(){
  window.__noHud0();
  var c=gx('ctx'), W=gx('W'), H=gx('H'), g;
  if(!(gx('G.player.hp')<32)) return;
  var ph=0.4;   // the edge pulse frozen a little above its middle, same as option C
  if(opt==='A'){ c.fillStyle='rgba(200,30,20,'+window.__WASH+')'; c.fillRect(0,0,W,H); }
  if(opt==='C'||opt==='D'){ g=c.createRadialGradient(W/2,H/2,H*0.55,W/2,H/2,H*0.9); g.addColorStop(0,'rgba(200,30,20,0)'); g.addColorStop(1,'rgba(200,30,20,.45)');
    c.save(); c.globalAlpha=0.6+0.4*(0.5+0.5*ph); c.fillStyle=g; c.fillRect(0,0,W,H); c.restore(); }
};
gx('drawHUD=window.__noHud2');
A.draw(3);
return note;`;
mkrec(WORK + '/rec-a13.json', [{ name: 'a13', screen: 'P1 at 18 health beside P2', before: 'staged by a13 recipe', query: '', expect: '!!window.__art&&__state().player.hp===18&&!__state().drawErr', js }]);
const SPLAT = `shadowE(x+6,y+2.5,6.5,2.5,.18);
  if(window.__LOWB&&st&&st.hero&&st.own&&st.own.hp<32&&st.own.hp>0){   // low health: light blood on the ground, a trail behind the off hand
    (function(){
      var S=[[11.8,1.9,2.0],[18,4.4,1.45],[6.4,5.8,1.2],[24,0.8,1.0],[-3.5,7.4,0.95],[14.5,7.6,0.8],[29,3.6,0.7]], i, d, sx, sy, r;
      wc.save();
      for(i=0;i<S.length;i++){
        d=S[i]; sx=x-fl*d[0]; sy=y+d[1]; r=d[2];
        wc.fillStyle='#5e0d0a'; wc.beginPath(); wc.ellipse(sx+0.5,sy+0.5,r*1.3,r*0.8,0,0,6.2832); wc.fill();
        wc.fillStyle='#bd2a1e'; wc.beginPath(); wc.ellipse(sx,sy,r*1.18,r*0.7,0,0,6.2832); wc.fill();
        wc.fillStyle='#e8675a'; wc.fillRect(sx-r*0.6,sy-r*0.32,Math.max(0.8,r*0.5),0.7);
      }
      wc.restore();
    })();
  }`;
const SLUMP = `if(_LSX!==1) wc.restore();   // v23.xx (spr16): end of the Broad legs
  var _lowHp=!!(window.__LOWB&&st&&st.hero&&st.own&&st.own.hp<32&&st.own.hp>0);
  if(_lowHp){ wc.save(); wc.translate(0,2.6); wc.translate(x,ty-10); wc.rotate(fl*0.055); wc.translate(-x,-(ty-10)); }   // shoulders slump, the body folds forward`;
const STAIN = `  if(_lowHp){   // the chest stain, drawn on the torso before the head and the held gun, so the arm covers it where it really would
    (function(){
      var cx=x+leanX, sd=-fl;
      function blob(px,py,rx,ry,rot,fill){ wc.fillStyle=fill; wc.beginPath(); wc.ellipse(px,py,rx,ry,rot,0,6.2832); wc.fill(); }
      blob(cx+sd*3.4+0.5,ty-16.9+0.5,5.6,4.8,0.3,'#2a0504');
      blob(cx+sd*1.3+0.4,ty-14.0+0.4,3.8,3.2,0,'#5a0b09');
      blob(cx+sd*5.8+0.4,ty-19.8+0.4,3.0,2.4,0,'#5a0b09');
      blob(cx+sd*3.4,ty-17.0,5.0,4.2,0.3,'#7d1410');
      blob(cx+sd*1.3,ty-14.1,3.2,2.7,0,'#7d1410');
      blob(cx+sd*5.8,ty-19.9,2.5,2.0,0,'#7d1410');
      blob(cx+sd*4.4,ty-18.3,2.1,1.2,0.3,'#d0402f');
      wc.fillStyle='#5a0b09'; wc.fillRect(cx+sd*2.6-0.9,ty-13.6,1.8,5.6);
      wc.fillStyle='#7d1410'; wc.fillRect(cx+sd*2.6-0.55,ty-13.6,1.1,5.2);
      wc.fillStyle='#e0584a'; wc.fillRect(cx+sd*2.6-0.55,ty-13.2,0.5,1.4);
    })();
    wc.save(); wc.translate(0,1.4); wc.translate(x+leanX,ty-22); wc.rotate(fl*0.09); wc.translate(-(x+leanX),-(ty-22));   // the head hangs lower and forward
  }
  var hx2=x+leanX;`;
const HEADEND = `  if(_lowHp) wc.restore();
  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks`;
const TAIL = `    wc.globalAlpha=1;
  }
  if(_lowHp){
    wc.restore();
    // two light red drops falling from the off hand, one still hanging on the glove
    (function(){
      var hx=x-fl*11.4, gy=y+1.9;
      function tear(px,py,r,a){
        wc.globalAlpha=a;
        wc.beginPath(); wc.moveTo(px,py-r*2.4); wc.quadraticCurveTo(px+r*1.15,py-r*0.7,px+r,py); wc.arc(px,py,r,0,3.1416); wc.quadraticCurveTo(px-r*1.15,py-r*0.7,px,py-r*2.4); wc.closePath();
        wc.lineJoin='round'; wc.lineWidth=1.0; wc.strokeStyle='#5a0b09'; wc.stroke();
        wc.fillStyle='#c9301f'; wc.fill();
        wc.fillStyle='#f08a7c'; wc.fillRect(px-r*0.55,py-r*0.4,0.8,0.8);
        wc.globalAlpha=1;
      }
      tear(hx,ty-8.4,1.0,1);
      tear(hx+0.1,ty-3.4,1.45,1);
      wc.fillStyle='rgba(120,16,12,.55)'; wc.beginPath(); wc.ellipse(hx,gy,3.2,1.4,0,0,6.2832); wc.fill();
    })();
  }
}
// Every machine sprite is drawn from a scale derived off its collision radius,`;
const tailFrom = '    wc.globalAlpha=1;\n  }\n}\n// Every machine sprite is drawn from a scale derived off its collision radius,';
const bodyReps = [
  { from: 'shadowE(x+6,y+2.5,6.5,2.5,.18);', to: SPLAT },
  { from: 'if(_LSX!==1) wc.restore();   // v23.xx (spr16): end of the Broad legs', to: SLUMP },
  { from: '  var hx2=x+leanX;', to: STAIN },
  { from: "  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks", to: HEADEND },
  { from: tailFrom, to: TAIL }
];
for (const K of keys) {
  const name = 'a13-' + K.toLowerCase();
  const reps = (K === 'B' || K === 'D') ? bodyReps : [];
  mkgame(name, reps, { __OPT: K, __LOWB: (K === 'B' || K === 'D'), __WASH: WASH });
  const r = shoot('a13', K, WORK + '/rec-a13.json', 'a13');
  console.log(name, r.pic, r.lines.join(' | '));
  rmgame(name);
}
