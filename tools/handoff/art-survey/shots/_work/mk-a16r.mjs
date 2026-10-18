import { mkgame, mkrec, shoot, rmgame, WORK } from './lib.mjs';
const keys = process.argv.slice(2).length ? process.argv.slice(2) : ['B', 'D'];
const HUD = [
  "window.__hud16=function(){",
  "  window.__noHud(); if(GFXWT) gfxWorldText();",
  "  var a=window.__A16, rz=hudRes(); ctx.save(); ctx.globalAlpha=1; ctx.strokeStyle=xhCol(true); ctx.lineWidth=1.6*rz;",
  "  xhArms(ctx,a.mx,a.my,3.5*rz*xhSize(),5*rz*xhSize()); xhDot(ctx,a.mx,a.my,false,'',rz); ctx.restore();",
  "};"
].join('\n');
const OVER = [
  "window.__tagsFn=function(){ try{ window.__tagBody(); }catch(e){ window.__tagErr=String(e&&e.message); } return 1; };",
  "window.__tagBody=function(){",
  "  var o=window.__OPT, a=window.__A16, p=G.player, f=p.face, c, s, cx, cy, i;",
  "  wc.save();",
  "  if(o==='C'){",
  "    wc.globalAlpha=0.55; wc.strokeStyle='#ff4a3a'; wc.lineWidth=1.5; wc.lineCap='butt';",
  "    wc.beginPath(); wc.moveTo(a.wx0,a.wy0); wc.lineTo(a.hitX,a.wy0); wc.stroke();",
  "    wc.globalAlpha=0.9; wc.fillStyle='#ff4a3a'; wc.beginPath(); wc.arc(a.hitX,a.wy0,1.5,0,6.2832); wc.fill();",
  "  }",
  "  if(o==='D'){",
  "    c=Math.cos(f); s=Math.sin(f); cx=a.wx0+c*9; cy=a.wy0+s*9;",
  "    wc.beginPath(); wc.moveTo(cx+c*4.5,cy+s*4.5); wc.lineTo(cx-c*4.5-s*3.5,cy-s*4.5+c*3.5); wc.lineTo(cx-c*4.5+s*3.5,cy-s*4.5-c*3.5); wc.closePath();",
  "    wc.fillStyle=SEATCOL[0]; wc.fill(); wc.lineWidth=1; wc.lineJoin='round'; wc.strokeStyle=INK; wc.stroke();",
  "  }",
  "  wc.restore();",
  "  return 1;",
  "};"
].join('\n');
const AIMU = [
  "window.__AIMU=function(x,y,mode){",
  "  if(window.__OPT!=='B') return;",
  "  var a=window.__A16, X;",
  "  wc.save();",
  "  for(X=a.wx0+9; X<=a.stopX; X+=9){ wc.fillStyle='rgba(20,34,18,.45)'; wc.beginPath(); wc.arc(X+0.3,a.wy0+0.4,1.9,0,6.2832); wc.fill(); wc.fillStyle='rgba(255,255,255,.92)'; wc.beginPath(); wc.arc(X,a.wy0,1.5,0,6.2832); wc.fill(); }",
  "  wc.restore();",
  "};"
].join('\n');
const js = [
  "const A=window.__art, gx=__gx;",
  "await A.scene('duo',{});",
  "const s=__state(), p=s.player, X=A.base().x, Y=A.base().y, Z=2.7;",
  "p.x=X-130; p.y=Y; p.face=0; p.ads=true; p.moving=false;",
  "A.mate(X-166,Y+24,0.3);",
  "A.cam(X,Y-10,Z);",
  "for(let i=0;i<70;i++) A.draw(1);",
  "const q=gx('ZOOM()'), d=360/q;",
  "const e=A.pillager(p.x+560/q,p.y+1,{id:'beef',gun:'shotgun',rig:'none',state:'patrol',face:0.35}); e.name='';",
  "A.cam(p.x+280/q,Y-10,Z);",
  "A.draw(2);",
  "const mz=gx('gunMuzzleAt(G.player,G.player.wep,0)');",
  "const sc=gx('w2s('+(p.x+d)+',0,'+mz.y+')');",
  "window.__A16={wx0:mz.x,wy0:mz.y,hitX:e.x-e.r,stopX:(p.x+d)-4.5,mx:sc.x,my:sc.y,d:d,q:q};",
  "gx('mouse.x='+sc.x+';mouse.y='+sc.y);",
  "gx(" + JSON.stringify(HUD) + ");",
  "gx(" + JSON.stringify(OVER) + ");",
  "gx(" + JSON.stringify(AIMU) + ");",
  "gx('netUpTags=window.__tagsFn');",
  "gx('drawHUD=window.__hud16');",
  "A.draw(3);",
  "const ch=A.measure([{id:'p1',kind:'player',ref:'p1'},{id:'mate',kind:'player',ref:'mate'},{id:'pillager',kind:'pillager',ref:e}]);",
  "A.draw(3);",
  "return JSON.stringify({scene:'a16',a:window.__A16,err:window.__tagErr,chars:ch});"
].join('\n');
mkrec(WORK + '/rec-a16.json', [{ name: 'a16', screen: 'P1 aims right with sights held', before: 'staged by a16 recipe', query: '', expect: '!!window.__art&&__state().player.ads===true&&!__state().drawErr', js }]);
const repsB = [
  { from: 'if(_SEAT>=0) drawSeatRing(x,y,_SEAT);', to: "if(_SEAT>=0) drawSeatRing(x,y,_SEAT);\n  if(window.__AIMU&&st&&st.hero) window.__AIMU(x,y,mode);" }
];
for (const K of keys) {
  const name = 'a16-' + K.toLowerCase();
  mkgame(name, K === 'B' ? repsB : [], { __OPT: K });
  const r = shoot('a16', K, WORK + '/rec-a16.json', 'a16');
  console.log(name, r.pic, r.lines.join(' | ').slice(0, 300));
  rmgame(name);
}
