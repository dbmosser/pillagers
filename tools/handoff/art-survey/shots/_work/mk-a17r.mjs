import { mkgame, mkrec, shoot, rmgame, WORK } from './lib.mjs';
const keys = process.argv.slice(2).length ? process.argv.slice(2) : ['D'];
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
// real leaf shapes (pointed, with a vein): two on each shoulder, one on each side of the pack, two on the helmet
const LEAF = [
  "    wc.globalAlpha=1;",
  "  }",
  "  if(window.__LEAF&&st&&st.hero&&G&&G.pBush&&G.pCrouch){",
  "    var _lfn=function(lx,ly,ang,len,hw,c1,c2){ wc.save(); wc.translate(x+leanX+lx,ty+ly); wc.rotate(ang);",
  "      wc.beginPath(); wc.moveTo(-len/2,0); wc.quadraticCurveTo(-len*0.12,-hw*2,len/2,0); wc.quadraticCurveTo(-len*0.12,hw*2,-len/2,0); wc.closePath();",
  "      wc.fillStyle=c1; wc.fill(); wc.lineJoin='round'; wc.lineWidth=0.8; wc.strokeStyle='#27481f'; wc.stroke();",
  "      wc.beginPath(); wc.moveTo(-len/2+0.5,0); wc.lineTo(len/2-1.0,0); wc.lineWidth=0.6; wc.strokeStyle=c2; wc.stroke(); wc.restore(); };",
  "    var _g1='#4d8a3e', _g2='#6fae52', _v1='#a6d58a', _v2='#2f5a27';",
  "    _lfn(-14.6,-22.4,-2.5,6.6,1.65,_g1,_v1); _lfn(-11.2,-23.8,-1.9,6.6,1.65,_g2,_v2);",
  "    _lfn(14.6,-22.4,-0.65,6.6,1.65,_g2,_v2); _lfn(11.2,-23.8,-1.25,6.6,1.65,_g1,_v1);",
  "    _lfn(-13.4,-13.6,2.8,6.4,1.6,_g1,_v1); _lfn(-10.2,-12.4,2.0,6.2,1.55,_g2,_v2);",
  "    _lfn(-5.8,-41.0,-2.6,6.4,1.6,_g2,_v2); _lfn(-2.8,-42.6,-2.0,6.4,1.6,_g1,_v1);",
  "  }",
  "}",
  "// Every machine sprite is drawn from a scale derived off its collision radius,"
].join('\n');
const tail = '    wc.globalAlpha=1;\n  }\n}\n// Every machine sprite is drawn from a scale derived off its collision radius,';
for (const K of keys) {
  const name = 'a17-' + K.toLowerCase();
  mkgame(name, [{ from: tail, to: LEAF }], { __OPT: K, __LEAF: true });
  const r = shoot('a17', K, WORK + '/rec-a17.json', 'a17');
  console.log(name, r.pic, r.lines.join(' | ').slice(0, 300));
  rmgame(name);
}
