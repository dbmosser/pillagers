// extract-pos.mjs : writes scene/NAME-pos.json for the five scenes from scene/report.json (the note of each camera run is a JSON line).
//   node tools/handoff/art-survey/extract-pos.mjs
// x,y = middle of the character's drawn body in the 1920x1080 picture, w,h = its size, fx,fy = where it stands (feet). Objects (boxes, piles, wrecks) carry fx,fy only.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
const dir = path.join(here, 'scene');
const rep = JSON.parse(fs.readFileSync(path.join(dir, 'report.json'), 'utf8'));
for (const s of rep.screens) {
  if (/-plate$/.test(s.name)) continue;
  const e = s['1080'];
  if (!e || !e.staged) { console.log(s.name + ': NOT STAGED ' + (e && e.note)); continue; }
  const j = JSON.parse(e.note);
  const out = { scene: j.scene, picture: '1920x1080', zoom: j.zoom, plate: s.name + '-plate-1080.jpg', characters: j.chars, objects: j.objects || [] };
  fs.writeFileSync(path.join(dir, s.name + '-pos.json'), JSON.stringify(out, null, 1));
  console.log(s.name + '-pos.json: ' + j.chars.length + ' characters, ' + out.objects.length + ' objects');
}
