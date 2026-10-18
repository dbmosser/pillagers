// redo/mkrecipes.mjs : writes ../recipes-redo.json = the official prelude (recipes.json: base prelude + scene-lib.js) + redo/extra-scenes.js
// + one screen per name in redo/screens.json ({name:{js,expect}}).   node redo/mkrecipes.mjs
import fs from 'node:fs'; import path from 'node:path'; import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url)), AS = path.resolve(here, '..');
const r = JSON.parse(fs.readFileSync(path.join(AS, 'recipes.json'), 'utf8'));
const extra = fs.existsSync(path.join(here, 'extra-scenes.js')) ? fs.readFileSync(path.join(here, 'extra-scenes.js'), 'utf8') : '';
const scr = JSON.parse(fs.readFileSync(path.join(here, 'screens.json'), 'utf8'));
const out = { about: r.about + ' REDO (2026-10-18, port 9375).', prelude: r.prelude + '\n' + extra, screens: [] };
for (const [name, s] of Object.entries(scr)) out.screens.push({ name, screen: s.screen || name, before: 'redo', query: '', expect: s.expect || '', js: s.js });
fs.writeFileSync(path.join(AS, 'recipes-redo.json'), JSON.stringify(out, null, 1));
console.log('recipes-redo.json: ' + out.screens.map(s => s.name).join(', '));
