// node build/compose.mjs a01-B a01-C ...   writes mock/NAME.html (frame full size + a 3x inset, top right) and renders img/NAME.jpg
// The picture is shots/NAME/pic.jpg (4K, the same framing as 1080 at 2x pixels, so the 3x inset stays sharp).
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { AS, ROOT } from './lib.mjs';
const { INSETS } = await import('./insets.mjs');
const names = process.argv.slice(2).filter(a => !a.startsWith('--'));
function page(name, ins) {
  const pic = '../shots/' + name + '/pic.jpg';
  const W = ins.w || 640, H = ins.h || 400, k = 3;
  const bx = ins.x * k - W / 2, by = ins.y * k - H / 2;     // ins.x, ins.y: the centre of the region, in 1080 picture pixels
  const right = ins.right === undefined ? 20 : ins.right, top = ins.top === undefined ? 20 : ins.top;
  return `<!doctype html><html><head><meta charset="utf-8"><title>${name}</title><style>
html,body{margin:0;padding:0;width:1920px;height:1080px;overflow:hidden;background:#000}
#f{position:absolute;left:0;top:0;width:1920px;height:1080px;background:url(${pic}) 0 0/1920px 1080px no-repeat}
#in{position:absolute;right:${right}px;top:${top}px;width:${W}px;height:${H}px;box-sizing:border-box;border:2px solid rgba(242,239,230,.9);border-radius:3px;
 box-shadow:0 0 0 1px rgba(0,0,0,.65),0 8px 28px rgba(0,0,0,.55);background:url(${pic}) -${bx}px -${by}px/${1920 * k}px ${1080 * k}px no-repeat;image-rendering:auto}
#t{position:absolute;right:${right + 10}px;top:${top + 8}px;padding:2px 9px 3px;border-radius:3px;background:rgba(10,12,14,.72);color:#f2efe6;font:700 22px/1 "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif;letter-spacing:.04em}
</style></head><body><div id="f"></div><div id="in"></div><div id="t">3x</div></body></html>`;
}
const outs = [];
for (const n of names) {
  const q = n.split('-')[0];
  const ins = Object.assign({}, INSETS[q] || { x: 960, y: 540 }, INSETS[n] || {});
  const f = path.join(AS, 'mock', n + '.html');
  fs.writeFileSync(f, page(n, ins), 'utf8'); outs.push(path.relative(ROOT, f).split(path.sep).join('/'));
}
if (outs.length) {
  const r = spawnSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tools/handoff/art-survey/render.ps1', '-Html', outs.join(',')], { cwd: ROOT, encoding: 'utf8', timeout: 400000 });
  console.log((r.stdout || '') + (r.stderr || ''));
}
