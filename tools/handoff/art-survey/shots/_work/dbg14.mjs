import fs from 'node:fs';
import { mkgame, mkrec, shoot, WORK, AS } from './lib.mjs';
mkgame('a14-a', [], { __OPT: 'A' });
const f = AS + '/game/a14-a.html';
let lines = fs.readFileSync(f, 'utf8').split('\n');
const cps = [36723, 36726, 36738, 37441, 37442, 37475, 37510, 37523, 37526, 37528];
for (const n of cps) { console.log(n, lines[n - 1].slice(0, 60)); lines[n - 1] = '(window.__cp=window.__cp||{})[' + n + ']=1; ' + lines[n - 1]; }
fs.writeFileSync(f, lines.join('\n'));
const js = [
  "const A=window.__art, gx=__gx;",
  "await A.scene('duo',{});",
  "window.__cp={}; A.draw(1);",
  "return JSON.stringify(Object.keys(window.__cp));"
].join('\n');
mkrec(WORK + '/rec-dbg14.json', [{ name: 'dbg14', screen: 'dbg', before: 'x', query: '', expect: 'true', js }]);
const r = shoot('a14', 'a', WORK + '/rec-dbg14.json', 'dbg14');
console.log(r.lines.join('\n'));
