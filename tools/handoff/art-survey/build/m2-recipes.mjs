// node build/m2-recipes.mjs : writes recipes-mach2.json = recipes-mach.json + build/m2-ext.js on the end of the prelude + the new screens
import fs from 'node:fs';
import path from 'node:path';
import { AS } from './m2-lib.mjs';
const base = JSON.parse(fs.readFileSync(path.join(AS, 'recipes-mach.json'), 'utf8'));
const ext = fs.readFileSync(path.join(AS, 'build', 'm2-ext.js'), 'utf8');
const lineup = base.screens.find(s => s.name === 'm-lineup');
const screens = base.screens.slice();
screens.push(Object.assign({}, lineup, { name: 'm-lineupbig', screen: 'lineupbig', js: "return await window.__art.scene('lineupbig',{});" }));
const out = { about: base.about + ' 2nd pass (m2-ext.js): lineupbig, fightdead without wrecks for C and D.', prelude: base.prelude + '\n' + ext, screens };
fs.writeFileSync(path.join(AS, 'recipes-mach2.json'), JSON.stringify(out, null, 1));
console.log('recipes-mach2.json: ' + screens.length + ' screens, prelude ' + out.prelude.length);
