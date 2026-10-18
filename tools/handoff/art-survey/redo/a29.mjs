// redo/a29.mjs : game/a29-A..D.html = the world's colour treatment, shot at a meadow with a wall (a building front, a road strip) beside the raiders.
// A is the unpatched game. B, C, D put a canvas colour filter on the WORLD only (the baked floor and every wall, bush, crate and lamp in the
// y-sorted list), never on the raiders, machines, light, fog or the HUD.
//   B muted   : saturate .6, a little darker
//   C cool    : hue turned toward teal, saturate .75, darker
//   D vivid   : saturate 1.55, a touch brighter
// node redo/a29.mjs [x] [y]
import fs from 'node:fs';
import { buildCopy } from './lib.mjs';
const X = process.argv[2] || '1191', Y = process.argv[3] || '3054';
const F = {
  B: 'saturate(.6) brightness(.95)',
  C: 'hue-rotate(32deg) saturate(.75) brightness(.88)',
  D: 'saturate(1.55) brightness(1.03)',
};
const edits = (f) => [
  ['function drawHUD(){', "var ART29={f:'" + f + "'};\nfunction drawHUD(){"],
  ['  if(gx1>gx0&&gy1>gy0) wc.drawImage(G.ground,gx0,gy0,gx1-gx0,gy1-gy0,gx0,gy0,gx1-gx0,gy1-gy0);', "  wc.filter=ART29.f;\n  if(gx1>gx0&&gy1>gy0) wc.drawImage(G.ground,gx0,gy0,gx1-gx0,gy1-gy0,gx0,gy0,gx1-gx0,gy1-gy0);"],
  ['  try{ gfxShadowPass(dt); }catch(_gsh){}   // v23.xx (gfx2): shadow hook, under the y-sorted bodies', "  wc.filter='none';\n  try{ gfxShadowPass(dt); }catch(_gsh){}   // v23.xx (gfx2): shadow hook, under the y-sorted bodies"],
  ['    var it=DR[i];\n    _svd=0;\n    try{\n    if(it.fn){ it.fn(); } else', "    var it=DR[i];\n    wc.filter=(it.w||it.b||it.c||it.lm||(it.fn&&!it.cr))?ART29.f:'none';\n    _svd=0;\n    try{\n    if(it.fn){ it.fn(); } else"],
  ['  // v9.27, HIS #45: YOU ARE NOT ALLOWED TO VANISH.', "  wc.filter='none';\n  // v9.27, HIS #45: YOU ARE NOT ALLOWED TO VANISH."],
];
buildCopy('a29-A', []);
const S = {};
const JS = "return await window.__art.scene('duo',{x:" + X + ",y:" + Y + "});";
const BASE = "!!window.__art&&!!__state().player&&!__state().over&&!__state().drawErr&&document.getElementById('topright').style.display==='none'&&__state().ents.length===0&&__P().cond==='day'";
S['a29-A'] = { js: JS, expect: BASE };
for (const k of ['B', 'C', 'D']) {
  buildCopy('a29-' + k, edits(F[k]));
  S['a29-' + k] = { js: JS, expect: BASE + "&&__gx('ART29.f').length>5" };
}
fs.writeFileSync(new URL('screens-a29.json', import.meta.url), JSON.stringify(S, null, 1));
console.log('built a29 A-D at ' + X + ',' + Y);
