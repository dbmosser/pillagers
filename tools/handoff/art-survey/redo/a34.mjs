// redo/a34.mjs : game/a34-C.html = a hit raider leaves two clear light-red stains of different sizes on the ground around him
// (the old drop was a 2-4 px dark red dot, half the time). Three hits in the scene (one raider twice, one once) = six stains.
import fs from 'node:fs';
import { buildCopy } from './lib.mjs';
const OLD = 'if(fxr()<0.55){ d=fxn(6,14); decal(x+Math.cos(a)*d,y+16+Math.sin(a)*d*0.5,BLOOD_DROP,fxn(2.2,4)*(0.7+0.5*k)); }';
const NEW = `var _j34, _a34, _dd34, _h34=(BLOOD_N34>>1);
  for(_j34=0;_j34<2;_j34++){ d=fxn(16,42); _a34=a+(_j34?2.5:-0.4)+1.1*_h34+fxn(-0.25,0.25); decal(x+Math.cos(_a34)*d,y+16+Math.sin(_a34)*d*0.5,BLOOD_STAIN,BLOOD_SZ34[BLOOD_N34++%BLOOD_SZ34.length]); _dd34=G.decals[G.decals.length-1]; _dd34.a=_dd34.a0=0.9; }`;
buildCopy('a34-C', [
  [OLD, NEW],
  ["var BLOOD_SPRAY='#b3241b', BLOOD_MIST='#7a1612', BLOOD_DROP='#5c1310';", "var BLOOD_SPRAY='#b3241b', BLOOD_MIST='#7a1612', BLOOD_DROP='#5c1310', BLOOD_STAIN='#e8635d', BLOOD_SZ34=[7,12,5,9.5,13.5,6], BLOOD_N34=0;"],
]);
const old = JSON.parse(fs.readFileSync(new URL('../shots/_recipes/all.json', import.meta.url), 'utf8')).screens.find(q => q.name === 'a34-C');
const EXPECT = "!!window.__art&&!!__state().player&&!__state().over&&!__state().drawErr&&document.getElementById('topright').style.display==='none'&&__P().cond==='day'&&__state().decals.filter(function(d){return d.c==='#e8635d';}).length>=4&&__state().decals.filter(function(d){return d.c==='#e8635d';}).length<=6";
fs.writeFileSync(new URL('screens-a34.json', import.meta.url), JSON.stringify({ 'a34-C': { js: old.js, expect: EXPECT } }, null, 1));
console.log('built a34-C');
