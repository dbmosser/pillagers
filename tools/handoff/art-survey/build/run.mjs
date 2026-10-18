// node build/run.mjs a01-B a01-C ...   builds the patched copy of each, shoots it, copies the picture to shots/NAME/pic.jpg
import fs from 'node:fs';
import path from 'node:path';
import { buildCopy, shoot, AS } from './lib.mjs';
const { P } = await import('./patches.mjs');
const keep = process.argv.includes('--keep');
const names = process.argv.slice(2).filter(a => !a.startsWith('--'));
for (const n of names) {
  if (process.argv.includes('--resume') && fs.existsSync(path.join(AS, 'shots', n, 'pic.jpg'))) { console.log(n + ' already shot'); continue; }
  const p = P[n];
  if (!p) { console.log(n + ' NO PATCH'); continue; }
  try {
    const gp = buildCopy(n, p.edits);
    let r = shoot(n, p.scene, p.recipes); for (let k = 0; k < 3 && !r.ok; k++) { r = shoot(n, p.scene, p.recipes); }
    if (r.ok) { fs.copyFileSync(r.jpg, path.join(AS, 'shots', n, 'pic.jpg')); }
    if (!keep) fs.rmSync(gp, { force: true });
    console.log(n + ' ' + (r.ok ? 'shot' : 'FAILED ' + r.err) + ' | ' + r.note);
  } catch (e) { console.log(n + ' ERROR ' + e.message); }
}
