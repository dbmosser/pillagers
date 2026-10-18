// node build/m2-run.mjs [--keep] a24-D a25-B ...  : builds the patched copy of each option, shoots it, leaves shots/NAME/<screen>-1080.jpg and -4k.jpg, deletes the copy
import fs from 'node:fs';
import path from 'node:path';
import { buildCopy, shoot, AS } from './m2-lib.mjs';
const { P } = await import('./m2-patches.mjs');
const keep = process.argv.includes('--keep');
const names = process.argv.slice(2).filter(a => !a.startsWith('--'));
for (const n of names) {
  const p = P[n];
  if (!p) { console.log(n + ' NO PATCH'); continue; }
  try {
    const gp = buildCopy(n, p.edits);
    let r = shoot(n, p.screen); for (let k = 0; k < 2 && !r.ok; k++) r = shoot(n, p.screen);
    if (!keep) fs.rmSync(gp, { force: true });
    console.log(n + ' ' + (r.ok ? 'shot' : 'FAILED ' + r.err) + ' | ' + r.note);
  } catch (e) { console.log(n + ' ERROR ' + e.message); }
}
