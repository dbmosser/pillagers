// node redo/shootmany.mjs <urlOrGameName|fixture> screen1 screen2 ...   shoots screens of recipes-redo.json from one page (default the real fixture), picture to shots/_work/redo-NAME.jpg
import fs from 'node:fs'; import path from 'node:path';
import { shoot, AS } from './lib.mjs';
const [page, ...names] = process.argv.slice(2);
for (const n of names) {
  const r = shoot('_redo-' + n, n, undefined, page === 'fixture' ? 'http://localhost:8808/fixture.html' : page);
  if (r.ok) { fs.copyFileSync(r.jpg, path.join(AS, 'shots', '_work', 'redo-' + n + '.jpg')); }
  console.log(n + ' ' + (r.ok ? 'shot' : 'FAILED ' + r.err) + ' | ' + r.note.slice(0, 200));
}
