import fs from 'node:fs';
import { mkgame, mkrec, shoot, rmgame, WORK } from './lib.mjs';
const keys = process.argv.slice(2).length ? process.argv.slice(2) : ['A', 'B', 'C', 'D'];
// P1 at hp 18, P2 at full health. The HUD is wiped by the scene, so the wash and the edge pulse are laid on the HUD canvas here, with the game's own numbers.
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
  var ph=0.4;   // the pulse frozen a little above its middle: sin = 0.4
  if(opt==='A'){ c.fillStyle='rgba(200,30,20,'+(.10+.09*ph)+')'; c.fillRect(0,0,W,H); }
  if(opt==='C'||opt==='D'){ g=c.createRadialGradient(W/2,H/2,H*0.55,W/2,H/2,H*0.9); g.addColorStop(0,'rgba(200,30,20,0)'); g.addColorStop(1,'rgba(200,30,20,.45)');
    c.save(); c.globalAlpha=0.6+0.4*(0.5+0.5*ph); c.fillStyle=g; c.fillRect(0,0,W,H); c.restore(); }
};
gx('drawHUD=window.__noHud2');
A.draw(3);
return note;`;
mkrec(WORK + '/rec-a13.json', [{ name: 'a13', screen: 'P1 at 18 health beside P2', before: 'staged by a13 recipe', query: '', expect: '!!window.__art&&__state().player.hp===18&&!__state().drawErr', js }]);
// the body of option B and D: stains, shoulders down 1.5, two drops falling from the hands
const bodyReps = [
  { from: 'if(_LSX!==1) wc.restore();   // v23.xx (spr16): end of the Broad legs',
    to: "if(_LSX!==1) wc.restore();   // v23.xx (spr16): end of the Broad legs\n  var _lowHp=!!(window.__LOWB&&st.hero&&st.own&&st.own.hp<32&&st.own.hp>0); if(_lowHp){ wc.save(); wc.translate(0,1.5); }" },
  { from: '    wc.globalAlpha=1;\n  }\n}\n// Every machine sprite is drawn from a scale derived off its collision radius,',
    to: "    wc.globalAlpha=1;\n  }\n  if(_lowHp){\n    wc.restore();\n    // the body shows it: two dark red stains on the chest and the gun arm, two drops falling from the hands, one old drop on the floor\n    (function(){\n      var Dg=GUNDEF[(st.own.wep&&GUNDEF[st.own.wep.id])?st.own.wep.id:'rifle'], ang=face, ca=Math.cos(ang), sa=Math.sin(ang), gk=GUNK, ox=x+leanX, oy=ty-20, sg=(fl<0)?-1:1;\n      function hand(lx,ly){ ly*=sg; return [ox+(lx*ca-ly*sa)*gk, oy+(lx*sa+ly*ca)*gk]; }\n      var h1=hand(Dg.grip-1.2+1.7,2), h2=hand(Dg.fg-1.7+1.7,1.9), gnd=y+1;\n      wc.globalAlpha=0.8; wc.fillStyle='#8a1c14'; wc.fillRect(x+leanX-4.8,ty-17.5,3,3); wc.fillRect(x+leanX+3.6,ty-21.8,4,3); wc.globalAlpha=1;\n      wc.fillStyle='#b02a20'; wc.fillRect(h1[0]-1.5,h1[1]+(gnd-h1[1])*0.42,3,3);\n      wc.globalAlpha=0.7; wc.fillRect(h2[0]-1.5,h2[1]+(gnd-h2[1])*0.78,3,3);\n      wc.globalAlpha=0.4; wc.beginPath(); wc.ellipse(h2[0]+1,gnd,2.4,1.1,0,0,6.2832); wc.fill(); wc.globalAlpha=1;\n    })();\n  }\n}\n// Every machine sprite is drawn from a scale derived off its collision radius," }
];
for (const K of keys) {
  const name = 'a13-' + K.toLowerCase();
  const reps = (K === 'B' || K === 'D') ? bodyReps : [];
  mkgame(name, reps, { __OPT: K, __LOWB: (K === 'B' || K === 'D') });
  const r = shoot('a13', K, WORK + '/rec-a13.json', 'a13');
  console.log(name, r.pic, r.lines.join(' | '));
}
