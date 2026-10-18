import {open} from './cdpi.mjs';
import fs from 'node:fs';
const f = process.argv[2];
const c = await open(9354,'8808');
const src = fs.readFileSync(f,'utf8');
const r = await c.ev('__gx('+JSON.stringify('('+src+')()')+')');
console.log('RESULT:', r);
c.close();
