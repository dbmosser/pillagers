// node build/compose.mjs a01-B a01-C ...   writes mock/NAME.html (frame full size + a 3x inset, top right) and renders img/NAME.jpg
// The picture is shots/NAME/pic.jpg (4K, the same framing as 1080 at 2x pixels, so the 3x inset stays sharp).
// An inset entry (build/insets.mjs) is one of:
//   { x, y, w, h, right, top }          one crop, centred on (x,y) of the 1080 picture, default 640x400, top right
//   { crops: [ {x,y,w,h}, ... ] }       crops stacked down the right side (one "3x" tag on the first)
//   { xs: [x1,x2,x3], y, w, h }         crops side by side along the top right (all at the same height y)
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { AS, ROOT } from './lib.mjs';
const { INSETS } = await import('./insets.mjs');
const names = process.argv.slice(2).filter(a => !a.startsWith('--'));
const K = 3, GAP = 8;
const BORDER = 'box-sizing:border-box;border:2px solid rgba(242,239,230,.9);border-radius:3px;box-shadow:0 0 0 1px rgba(0,0,0,.65),0 8px 28px rgba(0,0,0,.55)';
const FONT = '"Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif';
function layout(ins) {                                  // -> [{x,y,w,h,left,top}] with the pixel box of each crop in the 1920x1080 page
  const right = ins.right === undefined ? 20 : ins.right, top = ins.top === undefined ? 20 : ins.top;
  let list = [];
  if (ins.xs) {                                         // a row
    const W = ins.w || 480, H = ins.h || 380, total = ins.xs.length * W + (ins.xs.length - 1) * GAP;
    list = ins.xs.map((cx, i) => ({ x: cx, y: ins.y, w: W, h: H, left: 1920 - right - total + i * (W + GAP), top }));
  } else if (ins.crops) {                               // a column
    let t = top;
    list = ins.crops.map(c => { const w = c.w || 640, h = c.h || 400, o = { x: c.x, y: c.y, w, h, left: 1920 - right - w, top: t }; t += h + GAP; return o; });
  } else {
    const w = ins.w || 640, h = ins.h || 400;
    list = [{ x: ins.x, y: ins.y, w, h, left: 1920 - right - w, top }];
  }
  return list;
}
function page(name, ins) {
  const pic = '../shots/' + name + '/pic.jpg';
  const lay = layout(ins);
  const boxes = lay.map(c => {
    const bx = c.x * K - c.w / 2, by = c.y * K - c.h / 2;       // c.x, c.y: the centre of the region, in 1080 picture pixels
    return `<div style="position:absolute;left:${c.left}px;top:${c.top}px;width:${c.w}px;height:${c.h}px;${BORDER};background:url(${pic}) -${bx}px -${by}px/${1920 * K}px ${1080 * K}px no-repeat;image-rendering:auto"></div>`;
  }).join('');
  const first = lay[0], rm = lay.reduce((a, c) => (c.top === first.top && c.left + c.w > a.left + a.w) ? c : a, first);   // the tag sits in the top right corner of the right-most box of the first row
  const tr = 1920 - (rm.left + rm.w) + 10, tt = first.top + 8;
  return `<!doctype html><html><head><meta charset="utf-8"><title>${name}</title><style>
html,body{margin:0;padding:0;width:1920px;height:1080px;overflow:hidden;background:#000}
#f{position:absolute;left:0;top:0;width:1920px;height:1080px;background:url(${pic}) 0 0/1920px 1080px no-repeat}
#t{position:absolute;right:${tr}px;top:${tt}px;padding:2px 9px 3px;border-radius:3px;background:rgba(10,12,14,.72);color:#f2efe6;font:700 22px/1 ${FONT};letter-spacing:.04em}
</style></head><body><div id="f"></div>${boxes}<div id="t">3x</div></body></html>`;
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
