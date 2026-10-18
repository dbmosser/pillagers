import fs from 'node:fs';
import { mkgame, mkrec, shoot, WORK } from './lib.mjs';
const keys = process.argv.slice(2).length ? process.argv.slice(2) : ['A', 'B', 'C', 'D'];
// the drawing hooks, written into the game's own scope (they use wc, INK, HUDF, FS, TYPE, drawItemIcon)
const DOWNU = [
  "window.__DOWNU=function(x,y,mode){",
  "  var o=window.__OPT, cx=x-1, cy=y-4, g;",
  "  if(o==='B'){",
  "    wc.save(); wc.translate(x-36,y); wc.rotate(0.1);",
  "    wc.fillStyle='rgba(0,0,0,.22)'; wc.beginPath(); wc.ellipse(1,4,15,3,0,0,6.2832); wc.fill();",
  "    try{ drawItemIcon(wc,'gun_carbine',0,-4,30); }catch(e){}",
  "    wc.restore();",
  "    wc.save(); wc.globalAlpha=0.75; wc.strokeStyle='#ff4a3a'; wc.lineWidth=2; wc.beginPath(); wc.ellipse(x,y-1,18,7,0,0,6.2832); wc.stroke(); wc.restore();",
  "  }",
  "  if(o==='C'){",
  "    wc.save(); wc.lineWidth=3; wc.strokeStyle='rgba(255,255,255,.3)'; wc.beginPath(); wc.ellipse(cx,cy,28,11,0,0,6.2832); wc.stroke();",
  "    wc.strokeStyle='#a6e83a'; wc.beginPath(); wc.ellipse(cx,cy,28,11,0,-1.5708,-1.5708+6.2832*0.4); wc.stroke(); wc.restore();",
  "  }",
  "  if(o==='D'){",
  "    wc.save(); wc.globalCompositeOperation='lighter';",
  "    g=wc.createLinearGradient(0,cy,0,cy-70); g.addColorStop(0,'rgba(255,74,58,.4)'); g.addColorStop(1,'rgba(255,74,58,0)');",
  "    wc.fillStyle=g; wc.beginPath(); wc.moveTo(cx-4,cy); wc.lineTo(cx+4,cy); wc.lineTo(cx+2,cy-70); wc.lineTo(cx-2,cy-70); wc.closePath(); wc.fill(); wc.restore();",
  "  }",
  "};"
].join('\n');
const TAGS = [
  "window.__tagsFn=function(){ window.__tagCalls=(window.__tagCalls||0)+1; try{ window.__tagBody(); }catch(e){ window.__tagErr=String(e&&e.message); } return 1; };",
  "window.__tagBody=function(){",
  "  var o=window.__OPT, p=G.player, x=p.x, y=p.y, cx=x-1, cy=y-4, dl, dw;",
  "  wc.save(); wc.textAlign='left';",
  "  if(o==='A'||o==='B'){",
  "    wc.font=FS(TYPE.micro); dl='down  '+String.fromCharCode(183)+'  16s'; dw=wc.measureText(dl).width;",
  "    wc.fillStyle='rgba(40,8,6,.86)'; wc.fillRect(x-dw/2-4,y-62,dw+8,13);",
  "    wc.fillStyle='#ff5a4a'; wc.fillText(dl,x-dw/2,y-52);",
  "  }",
  "  if(o==='C'){",
  "    wc.font='700 12px '+HUDF; wc.textAlign='center'; wc.lineJoin='round'; wc.lineWidth=3; wc.strokeStyle=INK; wc.strokeText('16',cx,cy+4); wc.fillStyle='#ffffff'; wc.fillText('16',cx,cy+4);",
  "  }",
  "  if(o==='D'){",
  "    var py=cy-70-10-1.5;",
  "    wc.fillStyle='#e0382c'; wc.beginPath(); wc.arc(cx,py,9,0,6.2832); wc.fill(); wc.lineWidth=1.6; wc.strokeStyle=INK; wc.stroke();",
  "    wc.fillStyle='#ffffff'; wc.fillRect(cx-6,py-1.5,12,3); wc.fillRect(cx-1.5,py-6,3,12);",
  "  }",
  "  wc.restore();",
  "  return 1;",
  "};"
].join('\n');
const js = [
  "const A=window.__art, gx=__gx;",
  "await A.scene('duo',{});",
  "const s=__state(), p=s.player, X=A.base().x, Y=A.base().y;",
  "p.x=X-14; p.y=Y; p.downed=true;",
  "const mf=1.8;",
  "A.mate(X+18,Y+4,mf);",
  "window.__mateWord.c=1; gx('netOnState(window.__peer,window.__mateWord)');",
  "const u=gx('NET.up[1]'); u.age=0; u.x=X+18; u.y=Y+4; u.tx=u.x; u.ty=u.y; u.f=mf;",
  "gx(" + JSON.stringify(DOWNU) + ");",
  "gx(" + JSON.stringify(TAGS) + ");",
  "gx('netUpTags=window.__tagsFn');",
  "gx('window.__noHud14=function(){ window.__noHud(); if(GFXWT) gfxWorldText(); };'); gx('drawHUD=window.__noHud14');",
  "A.cam(X,Y-10,5.0);",
  "A.draw(3);",
  "const ch=A.measure([{id:'p1',kind:'player',ref:'p1'},{id:'mate',kind:'player',ref:'mate'}]);",
  "A.draw(3);",
  "return JSON.stringify({scene:'a14',calls:window.__tagCalls,err:window.__tagErr,chars:ch});"
].join('\n');
mkrec(WORK + '/rec-a14.json', [{ name: 'a14', screen: 'P1 downed, P2 kneeling beside', before: 'staged by a14 recipe', query: '', expect: '!!window.__art&&__state().player.downed===true&&!__state().drawErr', js }]);
const reps = [
  { from: 'if(_SEAT>=0) drawSeatRing(x,y,_SEAT);', to: "if(window.__KNEEL&&st&&st.hero&&mode==='down') mode='crouchnone';\n  if(_SEAT>=0) drawSeatRing(x,y,_SEAT);\n  if(window.__DOWNU&&st&&st.hero) window.__DOWNU(x,y,mode);" },
  { from: '  var hx2=x+leanX;', to: '  var hx2=x+leanX; var _kneel14=!!(window.__KNEEL&&st.hero); if(_kneel14){ wc.save(); wc.translate(0,4); }' },
  { from: "  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks", to: "  if(_kneel14) wc.restore();\n  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks" }
];
for (const K of keys) {
  const name = 'a14-' + K.toLowerCase();
  mkgame(name, reps, { __OPT: K, __KNEEL: K === 'B' });
  const r = shoot('a14', K, WORK + '/rec-a14.json', 'a14');
  console.log(name, r.pic, r.lines.join(' | '));
}
