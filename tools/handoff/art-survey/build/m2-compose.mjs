// node build/m2-compose.mjs a24-D ...  : writes mock/NAME.html (the frame at 1920x1080 plus 3x insets) and renders img/NAME.jpg with render.ps1
// SETS[name] = { screen, crops:[{x,y,w,h,l,t}] }: (x,y) the centre of the region in the 1080 frame, (w,h) the size of the box on the page (the region shown is w/3 by h/3),
// (l,t) where the box sits on the page. The frame is the 1080 picture; the box is cut from the 4k picture of the same shot, so the 3x stays sharp.
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { AS, ROOT } from './m2-lib.mjs';
const { SETS } = await import('./m2-insets.mjs');
const names = process.argv.slice(2).filter(a => !a.startsWith('--'));
const K = 3;
const BORDER = 'box-sizing:border-box;border:2px solid rgba(242,239,230,.92);border-radius:3px;box-shadow:0 0 0 1px rgba(0,0,0,.65),0 8px 28px rgba(0,0,0,.55)';
const FONT = '"Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif';
function page(name, set) {
  const f1 = '../shots/' + name + '/' + set.screen + '-1080.jpg', f4 = '../shots/' + name + '/' + set.screen + '-4k.jpg';
  const boxes = set.crops.map(c => {
    const bx = c.x * K - c.w / 2, by = c.y * K - c.h / 2;
    return `<div style="position:absolute;left:${c.l}px;top:${c.t}px;width:${c.w}px;height:${c.h}px;${BORDER};background:url(${f4}) -${bx}px -${by}px/${1920 * K}px ${1080 * K}px no-repeat;image-rendering:auto"><span class="t">3x</span></div>`;
  }).join('');
  return `<!doctype html><html><head><meta charset="utf-8"><title>${name}</title><style>
html,body{margin:0;padding:0;width:1920px;height:1080px;overflow:hidden;background:#000}
#f{position:absolute;left:0;top:0;width:1920px;height:1080px;background:url(${f1}) 0 0/1920px 1080px no-repeat}
.t{position:absolute;right:6px;top:5px;padding:2px 8px 3px;border-radius:3px;background:rgba(10,12,14,.72);color:#f2efe6;font:700 21px/1 ${FONT};letter-spacing:.04em}
</style></head><body><div id="f"></div>${boxes}</body></html>`;
}
const outs = [];
for (const n of names) {
  const set = SETS[n]; if (!set) { console.log(n + ' NO INSET'); continue; }
  const f = path.join(AS, 'mock', n + '.html');
  fs.writeFileSync(f, page(n, set), 'utf8'); outs.push(path.relative(ROOT, f).split(path.sep).join('/'));
}
if (outs.length) {
  const r = spawnSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tools/handoff/art-survey/render.ps1', '-Html', outs.join(',')], { cwd: ROOT, encoding: 'utf8', timeout: 400000 });
  console.log((r.stdout || '') + (r.stderr || ''));
}
