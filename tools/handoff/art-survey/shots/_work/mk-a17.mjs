import { mkgame, mkrec, shoot, WORK } from './lib.mjs';
const keys = process.argv.slice(2).length ? process.argv.slice(2) : ['A', 'B', 'C', 'D'];
const js = [
  "const A=window.__art, gx=__gx;",
  "await A.scene('duo',{});",
  "const s=__state(), p=s.player, X=A.base().x, Y=A.base().y;",
  "s.map.bushes.push({x:p.x+10,y:p.y-38,r:44,s:2.1});",
  "gx('G.crouchTog=true; G.pBush=inBush(G.player.x,G.player.y); G.pCrouch=true; G.pConceal=concealAt(G.player.x,G.player.y,false,false,true);');",
  "A.cam(X,Y-10,5.0);",
  "A.draw(3);",
  "const ch=A.measure([{id:'p1',kind:'player',ref:'p1'},{id:'mate',kind:'player',ref:'mate'}]);",
  "A.draw(3);",
  "return JSON.stringify({scene:'a17',bush:gx('!!G.pBush'),conceal:gx('G.pConceal'),crouch:gx('G.pCrouch'),chars:ch});"
].join('\n');
mkrec(WORK + '/rec-a17.json', [{ name: 'a17', screen: 'P1 crouched in a bush, P2 standing', before: 'staged by a17 recipe', query: '', expect: '!!window.__art&&__state().player&&!__state().drawErr&&!!__gx("G.pBush")', js }]);
const WRAP = [
  "function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){",
  "  if((window.__LAYER||window.__FILT)&&st&&st.hero&&!window.__inLay&&G&&G.pBush&&G.pCrouch&&mode!=='down'){",
  "    window.__inLay=1;",
  "    if(window.__FILT){ wc.save(); wc.filter='saturate(.65) brightness(.78)'; try{ drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st); }finally{ wc.filter='none'; wc.restore(); window.__inLay=0; } return; }",
  "    var _w0=wc, _oc=window.__ocv||(window.__ocv=document.createElement('canvas')), _cv=_w0.canvas;",
  "    if(_oc.width!==_cv.width||_oc.height!==_cv.height){ _oc.width=_cv.width; _oc.height=_cv.height; }",
  "    var _o2=_oc.getContext('2d'); _o2.setTransform(1,0,0,1,0,0); _o2.clearRect(0,0,_oc.width,_oc.height); _o2.imageSmoothingEnabled=_w0.imageSmoothingEnabled;",
  "    _o2.setTransform(_w0.getTransform()); _o2.translate(x,y); _o2.scale(0.92,0.92); _o2.translate(-x,-y);",
  "    wc=_o2; try{ drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st); }finally{ wc=_w0; window.__inLay=0; }",
  "    _w0.save(); _w0.setTransform(1,0,0,1,0,0); _w0.globalAlpha=0.68; _w0.drawImage(_oc,0,0); _w0.restore(); return;",
  "  }"
].join('\n');
const LEAF = [
  "    wc.globalAlpha=1;",
  "  }",
  "  if(window.__LEAF&&st&&st.hero&&G&&G.pBush&&G.pCrouch){",
  "    var _lv=[[-8.5,-17,-0.5,'#4d8a3e'],[8.5,-18,0.5,'#6fae52'],[9,-11,0.9,'#4d8a3e'],[1.5,-31,-0.3,'#6fae52']], _li;",
  "    for(_li=0;_li<_lv.length;_li++){ wc.save(); wc.translate(x+leanX+_lv[_li][0],ty+_lv[_li][1]); wc.rotate(_lv[_li][2]); wc.fillStyle=_lv[_li][3]; wc.beginPath(); wc.ellipse(0,0,2.5,1.5,0,0,6.2832); wc.fill(); wc.restore(); }",
  "  }",
  "}",
  "// Every machine sprite is drawn from a scale derived off its collision radius,"
].join('\n');
const tail = '    wc.globalAlpha=1;\n  }\n}\n// Every machine sprite is drawn from a scale derived off its collision radius,';
const repsFor = K => K === 'B' || K === 'C' ? [{ from: 'function drawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){', to: WRAP }]
  : K === 'D' ? [{ from: tail, to: LEAF }] : [];
for (const K of keys) {
  const name = 'a17-' + K.toLowerCase();
  mkgame(name, repsFor(K), { __OPT: K, __LAYER: K === 'B', __FILT: K === 'C', __LEAF: K === 'D' });
  const r = shoot('a17', K, WORK + '/rec-a17.json', 'a17');
  console.log(name, r.pic, r.lines.join(' | ').slice(0, 400));
}
