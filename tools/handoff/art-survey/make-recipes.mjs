// make-recipes.mjs : writes recipes.json (the staging recipes for tools/uishots.ps1) from scene-lib.js.
//   node tools/handoff/art-survey/make-recipes.mjs
// recipes.json = the "about" and "prelude" of tools/handoff/shots/ui-screens-js.json, with scene-lib.js glued on the end of the prelude,
// then ten screens: duo, fight, lineup, loot, dark and the plate of each (same frame, players and enemies hidden).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(here, '..', '..', '..');
const base = JSON.parse(fs.readFileSync(path.join(root, 'tools', 'handoff', 'shots', 'ui-screens-js.json'), 'utf8'));
const lib = fs.readFileSync(path.join(here, 'scene-lib.js'), 'utf8');

const common = "!!window.__art&&!!__state().player&&!__state().over&&!__state().drawErr&&document.getElementById('topright').style.display==='none'";
const mate = "!!__gx('NET.up[1]')";
const scenes = {
  duo:    { screen: 'P1 and the co-op mate, standing close on open grass at midday, nobody else, no HUD',
            expect: common + '&&' + mate + "&&__state().ents.length===0&&__P().cond==='day'" },
  fight:  { screen: 'the duo against two pillagers and two machines a few metres away, shots in the air, no HUD',
            expect: common + '&&' + mate + "&&__state().ents.filter(e=>e.kind==='raider').length===2&&__state().ents.filter(e=>e.kind!=='raider').length===2&&__state().ents.every(e=>e.seen)&&__state().bullets.length>=8" },
  lineup: { screen: 'P1, seven pillagers (five roles, an elite, a golden one) and nine machines in two rows, no HUD',
            expect: common + "&&__state().ents.length===16&&__state().ents.every(e=>e.seen)&&__state().ents.filter(e=>e.kind==='raider').length===7" },
  loot:   { screen: 'P1 beside five opened boxes, four loot piles with rarity beams and two machine wrecks, no HUD',
            expect: common + "&&__state().containers.filter(c=>c.opened).length===5&&__state().containers.filter(c=>c.dropped).length===4&&__state().ents.length===0" },
  dark:   { screen: 'the duo at night in a blackout (every lamp dead), no HUD',
            expect: common + '&&' + mate + "&&__state().ents.length===0&&__P().cond==='night'" },
};
const screens = [];
for (const [name, s] of Object.entries(scenes)) {
  screens.push({ name, screen: s.screen, before: 'staged by window.__art.scene (tools/handoff/art-survey/scene-lib.js)', query: '', expect: s.expect,
    js: "return await window.__art.scene('" + name + "',{});" });
}
for (const [name, s] of Object.entries(scenes)) {
  screens.push({ name: name + '-plate', screen: 'the same frame as ' + name + ' with every player and enemy hidden', before: 'staged by window.__art.scene (tools/handoff/art-survey/scene-lib.js)', query: '',
    expect: common + "&&window.__only==='none'&&__state().ents.length===0&&!__state().bullets.length" + (name === 'loot' ? "&&__state().containers.filter(c=>c.opened).length===5" : ''),
    js: "return await window.__art.scene('" + name + "',{plate:true});" });
}
const about = base.about + ' ART SURVEY (2026-10-18): the prelude ends with scene-lib.js (window.__art), so a screen is one line, ' +
  "return await window.__art.scene('duo',{}) or ...scene('duo',{plate:true}); the returned note is a JSON line with the screen position of every character.";
const out = { about, prelude: base.prelude + '\n' + lib, screens };
fs.writeFileSync(path.join(here, 'recipes.json'), JSON.stringify(out, null, 1));
console.log('recipes.json: ' + screens.length + ' screens, prelude ' + out.prelude.length + ' chars');
