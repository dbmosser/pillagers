// redo/a31.mjs : game/a31-B.html (day fog sheet at .12, so the ground outside the cone shows its shapes) and game/a31-C.html
// (fog sheet near black at .88 and the cone cut-out held at full strength to its rim, so the cone edge is a clean line).
import fs from 'node:fs';
import { buildCopy } from './lib.mjs';
const FOGA = "fx2.fillStyle=isDay()?('rgba(58,46,38,'+clamp(.46-(BR-1)*.06-_lift,.22,.54)+')')";
const fogB = process.argv[2] || '.12', fogC = process.argv[3] || '.88';
buildCopy('a31-B', [[FOGA, "fx2.fillStyle=isDay()?('rgba(58,46,38," + fogB + ")')"]]);
buildCopy('a31-C', [
  [FOGA, "fx2.fillStyle=isDay()?('rgba(14,12,10," + fogC + ")')"],
  ["vg2.addColorStop(0,'rgba(0,0,0,.97)'); vg2.addColorStop(1,'rgba(0,0,0,0)');", "vg2.addColorStop(0,'rgba(0,0,0,.97)'); vg2.addColorStop(1,'rgba(0,0,0,.97)');"],
  ["vg.addColorStop(0,'rgba(0,0,0,.80)'); vg.addColorStop(1,'rgba(0,0,0,0)');", "vg.addColorStop(0,'rgba(0,0,0,.80)'); vg.addColorStop(1,'rgba(0,0,0,.80)');"],
]);
fs.writeFileSync(new URL('screens-a31.json', import.meta.url), JSON.stringify({ 'a31-B': { from: 'a31-B' }, 'a31-C': { from: 'a31-C' } }, null, 1));
console.log('built a31-B fog ' + fogB + ', a31-C fog ' + fogC);
