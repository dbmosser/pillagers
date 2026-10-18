// make-recipes-x.mjs : recipes-x.json = recipes-s.json (the five scenes, no plates) + scene-extra.js + the three extra scenes (duoaim, trio, duoparty).
//   node tools/handoff/art-survey/make-recipes-x.mjs
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
const r = JSON.parse(fs.readFileSync(path.join(here, 'recipes.json'), 'utf8'));
r.screens = r.screens.filter(s => !/plate/.test(s.name));
const common = r.screens.find(s => s.name === 'duo').expect.split('&&').slice(0, 5).join('&&');   // the shared part of the duo's expect
const mate = "!!__gx('NET.up[1]')";
const duoExpect = r.screens.find(s => s.name === 'duo').expect;
const add = [
  { name: 'duoaim', screen: 'the duo, P1 aims up and right, P2 aims right', expect: duoExpect },
  { name: 'duodown', screen: 'the duo, P2 is down', expect: duoExpect },
  { name: 'duoparty', screen: 'the duo with the party on (seat rings)', expect: duoExpect + "&&NET.peers.length===1".replace('NET', "__gx('NET')") },
  { name: 'trio', screen: 'P1 lean, a hired pillager broad, P2 curved', expect: duoExpect.replace('__state().ents.length===0', '__state().ents.length===1') },
];
for (const a of add) r.screens.push({ name: a.name, screen: a.screen, before: 'staged by window.__art.scene (scene-extra.js)', query: '', expect: a.expect, js: "return await window.__art.scene('" + a.name + "',{});" });
r.prelude = r.prelude + '\n' + fs.readFileSync(path.join(here, 'scene-extra.js'), 'utf8');
fs.writeFileSync(path.join(here, 'recipes-x.json'), JSON.stringify(r, null, 1));
console.log('recipes-x.json: ' + r.screens.map(s => s.name).join(', '));
