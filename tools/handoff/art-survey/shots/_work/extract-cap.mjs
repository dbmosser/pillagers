import fs from 'node:fs';
const rep = JSON.parse(fs.readFileSync('capmotion/report.json', 'utf8'));
const note = rep.screens[0]['1080'].note;
const o = JSON.parse(note);
fs.mkdirSync('sprites', { recursive: true });
let tot = 0;
for (const [n, sh] of Object.entries(o.sets)) {
  const png = Buffer.from(sh.png.split(',')[1], 'base64'), webp = Buffer.from(sh.webp.split(',')[1], 'base64');
  fs.writeFileSync('sprites/' + n + '.png', png); fs.writeFileSync('sprites/' + n + '.webp', webp);
  console.log(n.padEnd(10), sh.w + 'x' + sh.h, 'n=' + sh.n, 'png', png.length, 'webp', webp.length);
  tot += Math.min(png.length, webp.length);
}
fs.writeFileSync('sprites/meta.json', JSON.stringify({ S: o.S, box: o.box, fx: o.fx, fy: o.fy, coat: o.coat, coatP: o.coatP, sets: Object.fromEntries(Object.entries(o.sets).map(([n, s]) => [n, { w: s.w, h: s.h, n: s.n, ox: s.ox, oy: s.oy }])) }, null, 1));
console.log('total', tot, 'coat', o.coat, o.coatP, 'fx,fy', o.fx, o.fy);
