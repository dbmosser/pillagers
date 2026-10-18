import fs from 'node:fs';
import { mkgame, mkrec, shoot, rmgame, WORK } from './lib.mjs';
const keys = process.argv.slice(2).length ? process.argv.slice(2) : ['A', 'B', 'D'];
// the drawing hooks, written into the game's own scope (they use wc, INK, HUDF, FS, TYPE, drawItemIcon)
const DOWNU = [
  "window.__DOWNU=function(x,y,mode){",
  "  var o=window.__OPT, cx=x-1, cy=y-4, g;",
  "  if(o==='B'){",
  "    // the gun lies on the floor beside the kneeling raider",
  "    wc.save(); wc.translate(x-38,y+2); wc.rotate(0.1);",
  "    wc.fillStyle='rgba(0,0,0,.24)'; wc.beginPath(); wc.ellipse(1,4,16,3.2,0,0,6.2832); wc.fill();",
  "    try{ drawItemIcon(wc,'gun_carbine',0,-4,32); }catch(e){}",
  "    wc.restore();",
  "    // the red ring on the floor, pulsing: drawn near the top of its pulse",
  "    wc.save(); wc.globalAlpha=0.9; wc.strokeStyle='#ff4a3a'; wc.lineWidth=2.4; wc.beginPath(); wc.ellipse(x,y+0.5,19,7.5,0,0,6.2832); wc.stroke();",
  "    wc.restore();",
  "  }",
  "  if(o==='C'){",
  "    wc.save(); wc.lineWidth=3; wc.strokeStyle='rgba(255,255,255,.3)'; wc.beginPath(); wc.ellipse(cx,cy,28,11,0,0,6.2832); wc.stroke();",
  "    wc.strokeStyle='#a6e83a'; wc.beginPath(); wc.ellipse(cx,cy,28,11,0,-1.5708,-1.5708+6.2832*0.4); wc.stroke(); wc.restore();",
  "  }",
  "  if(o==='D'){",
  "    var H=80;",
  "    wc.save();",
  "    // a red pool of light on the ground where the beam starts",
  "    g=wc.createRadialGradient(cx,cy,1,cx,cy,22); g.addColorStop(0,'rgba(255,74,58,.55)'); g.addColorStop(1,'rgba(255,74,58,0)');",
  "    wc.fillStyle=g; wc.beginPath(); wc.ellipse(cx,cy,22,9,0,0,6.2832); wc.fill();",
  "    // the column: saturated red, wide at the foot, fading as it climbs",
  "    g=wc.createLinearGradient(0,cy,0,cy-H); g.addColorStop(0,'rgba(255,50,38,.92)'); g.addColorStop(0.55,'rgba(255,60,46,.6)'); g.addColorStop(1,'rgba(255,74,58,.06)');",
  "    wc.fillStyle=g; wc.beginPath(); wc.moveTo(cx-8,cy); wc.lineTo(cx+8,cy); wc.lineTo(cx+3,cy-H); wc.lineTo(cx-3,cy-H); wc.closePath(); wc.fill();",
  "    // a bright core down the middle",
  "    g=wc.createLinearGradient(0,cy,0,cy-H); g.addColorStop(0,'rgba(255,225,215,.9)'); g.addColorStop(1,'rgba(255,225,215,0)');",
  "    wc.fillStyle=g; wc.beginPath(); wc.moveTo(cx-2.6,cy); wc.lineTo(cx+2.6,cy); wc.lineTo(cx+1,cy-H); wc.lineTo(cx-1,cy-H); wc.closePath(); wc.fill();",
  "    wc.restore();",
  "  }",
  "};"
].join('\n');
const TAGS = [
  "window.__tagsFn=function(){ window.__tagCalls=(window.__tagCalls||0)+1; try{ window.__tagBody(); }catch(e){ window.__tagErr=String(e&&e.message); } return 1; };",
  "window.__tagBody=function(){",
  "  var o=window.__OPT, p=G.player, x=p.x, y=p.y, cx=x-1, cy=y-4, dl, dw;",
  "  wc.save(); wc.textAlign='left';",
  "  if(o==='A'){",
  "    wc.font=FS(TYPE.micro); dl='down  '+String.fromCharCode(183)+'  16s'; dw=wc.measureText(dl).width;",
  "    wc.fillStyle='rgba(40,8,6,.86)'; wc.fillRect(x-dw/2-4,y-62,dw+8,13);",
  "    wc.fillStyle='#ff5a4a'; wc.fillText(dl,x-dw/2,y-52);",
  "  }",
  "  if(o==='C'){",
  "    wc.font='700 12px '+HUDF; wc.textAlign='center'; wc.lineJoin='round'; wc.lineWidth=3; wc.strokeStyle=INK; wc.strokeText('16',cx,cy+4); wc.fillStyle='#ffffff'; wc.fillText('16',cx,cy+4);",
  "  }",
  "  if(o==='D'){",
  "    var py=cy-80-13-1.5, r=13;",
  "    wc.fillStyle='rgba(255,90,70,.2)'; wc.beginPath(); wc.arc(cx,py,r+4,0,6.2832); wc.fill();",
  "    wc.fillStyle='#e0382c'; wc.beginPath(); wc.arc(cx,py,r,0,6.2832); wc.fill(); wc.lineWidth=2; wc.strokeStyle=INK; wc.stroke();",
  "    wc.fillStyle='#ffffff'; wc.fillRect(cx-8,py-2.4,16,4.8); wc.fillRect(cx-2.4,py-8,4.8,16);",
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
// the kneeling pose: legs folded to half height, the upper body folded forward and down onto them, the head hanging lower and forward, empty hands
const SEATRIG = "if(_SEAT>=0) drawSeatRing(x,y,_SEAT);";
const reps = [
  { from: SEATRIG, to: "if(window.__KNEEL&&st&&st.hero&&mode==='down') mode='none';\n  " + SEATRIG + "\n  if(window.__DOWNU&&st&&st.hero) window.__DOWNU(x,y,mode);" },
  { from: '  var _LSX=(_BLD===\'broad\')?1.2:1;', to: "  var _kn=!!(window.__KNEEL&&st.hero); if(_kn){ wc.save(); wc.translate(0,ty); wc.scale(1,0.5); wc.translate(0,-ty); }\n  var _LSX=(_BLD==='broad')?1.2:1;" },
  { from: 'if(_LSX!==1) wc.restore();   // v23.xx (spr16): end of the Broad legs', to: "if(_LSX!==1) wc.restore();   // v23.xx (spr16): end of the Broad legs\n  if(_kn){ wc.restore(); wc.save(); wc.translate(0,5.6); wc.translate(x,ty-10); wc.rotate(fl*0.07); wc.translate(-x,-(ty-10)); }" },
  { from: '  var hx2=x+leanX;', to: "  if(_kn){ wc.save(); wc.translate(0,4.6); wc.translate(x+leanX,ty-22); wc.rotate(fl*0.1); wc.translate(-(x+leanX),-(ty-22)); }\n  var hx2=x+leanX;" },
  { from: "  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks", to: "  if(_kn) wc.restore();\n  // v10.54, his notes: THE SUIT'S OWN PAINT. Last, over everything the racks" },
  { from: '    wc.globalAlpha=1;\n  }\n}\n// Every machine sprite is drawn from a scale derived off its collision radius,', to: '    wc.globalAlpha=1;\n  }\n  if(_kn) wc.restore();\n}\n// Every machine sprite is drawn from a scale derived off its collision radius,' }
];
for (const K of keys) {
  const name = 'a14-' + K.toLowerCase();
  // the kneel hooks go in every copy (they only act when __KNEEL is set), so the other options stay byte-identical in what they draw
  mkgame(name, K === 'B' ? reps : [reps[0]], { __OPT: K, __KNEEL: K === 'B' });
  const r = shoot('a14', K, WORK + '/rec-a14.json', 'a14');
  console.log(name, r.pic, r.lines.join(' | ').slice(0, 300));
  rmgame(name);
}
