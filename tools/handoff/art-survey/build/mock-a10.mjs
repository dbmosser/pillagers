// mock-a10.mjs : the survey pictures of a10 (the tag over your mate), drawn on the duo frame at the game's scale (zoom 5, so one world unit is 5 px).
//   node build/mock-a10.mjs         writes mock/a10-A..D.html, then render.ps1 turns them into img/a10-A..D.jpg
// The frame is the real duo picture (shots/a01-A/pic.jpg, 4K). The tag sits where the game draws it: centred on the mate, its top 62 units above her feet.
// The 3x inset is the same stage again, scaled 3 times inside a clipped box, so the text stays sharp.
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { AS, ROOT } from './lib.mjs';

const FX = 1141, FY = 651;                       // the mate's feet in the 1080 frame (scene/duo-pos.json)
const PIC = '../shots/a01-A/pic.jpg', DOWN = '../shots/base-duodown/pic.jpg', PLATE = '../scene/duo-plate-1080.jpg';
const FONT = `"Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow","Roboto Condensed",sans-serif`;
const CSS = `
html,body{margin:0;padding:0;width:1920px;height:1080px;overflow:hidden;background:#000;font-family:${FONT}}
.stage{position:absolute;left:0;top:0;width:1920px;height:1080px;--u:5px;overflow:hidden}
.bg{position:absolute;left:0;top:0;width:1920px;height:1080px;background:url(${PIC}) 0 0/1920px 1080px no-repeat}
.tag{position:absolute;white-space:nowrap}
.plate{transform:translateX(-50%);height:calc(13*var(--u));line-height:calc(13*var(--u));padding:0 calc(4*var(--u));background:rgba(6,9,13,.86);font-weight:600;font-size:calc(13*var(--u))}
.ally{color:#7fb8ff}
.chipname{transform:translateX(-50%);display:flex;align-items:center;gap:calc(3*var(--u));height:calc(14*var(--u))}
.chip{box-sizing:border-box;width:calc(14*var(--u));height:calc(10*var(--u));border-radius:calc(3*var(--u));background:#38d6ff;color:#10151b;font-weight:700;font-size:calc(8*var(--u));line-height:calc(10*var(--u));text-align:center}
.nm{color:#fff;font-weight:600;font-size:calc(11*var(--u));line-height:calc(11*var(--u));-webkit-text-stroke:calc(2*var(--u)) #000;paint-order:stroke fill}
.bar{transform:translateX(-50%);width:calc(36*var(--u));height:calc(3*var(--u));background:#14171a;box-shadow:0 0 0 var(--u) #000}
.bar i{display:block;height:100%;width:60%;background:#5fae6f}
.down{transform:translateX(-50%);height:calc(13*var(--u));line-height:calc(13*var(--u));padding:0 calc(4*var(--u));background:rgba(40,8,6,.86);color:#ff5a4a;font-weight:600;font-size:calc(13*var(--u))}
#in{position:absolute;right:20px;top:20px;width:640px;height:400px;box-sizing:border-box;border:2px solid rgba(242,239,230,.9);border-radius:3px;overflow:hidden;box-shadow:0 0 0 1px rgba(0,0,0,.65),0 8px 28px rgba(0,0,0,.55);background:#000}
#in .stage{transform-origin:0 0}
#t{position:absolute;right:30px;top:28px;padding:2px 9px 3px;border-radius:3px;background:rgba(10,12,14,.72);color:#f2efe6;font:700 22px/1 ${FONT};letter-spacing:.04em}
`;
const top = FY - 62 * 5;                         // the top of the plate: 62 units above the feet
const A = `<div class="tag plate ally" style="left:${FX}px;top:${top}px">mia</div>`;
const B = `<div class="tag chipname" style="left:${FX}px;top:${top - 2.5}px"><span class="chip">p2</span><span class="nm">mia</span></div>`;
const D = A + `<div class="tag bar" style="left:${FX}px;top:${top + 65 + 5}px"><i></i></div>`;

// the far case for C: three small copies of the mate at 2 px a unit (the picture is 5), her tag as in B with its alpha, and the red down tag
function farInset() {
  const s = 2, k = s / 5;                         // 1080-frame px -> inset px
  function mini(src, fx, fy, left, feetY, extra, w, h, x0, y0) {   // w,h,x0,y0: the crop of the picture around the figure (1080 px)
    return `<div style="position:absolute;left:${left - (fx - x0) * k}px;top:${feetY - (fy - y0) * k}px;width:${w * k}px;height:${h * k}px;background:url(${src}) -${x0 * k}px -${y0 * k}px/${1920 * k}px ${1080 * k}px no-repeat"></div>` + extra;
  }
  const chipname = (cx, ty, a) => `<div style="position:absolute;left:${cx}px;top:${ty}px;transform:translateX(-50%);opacity:${a};display:flex;align-items:center;gap:${3 * s}px;height:${14 * s}px">
    <span style="box-sizing:border-box;width:${14 * s}px;height:${10 * s}px;border-radius:${3 * s}px;background:#38d6ff;color:#10151b;font:700 ${8 * s}px/${10 * s}px ${FONT};text-align:center">p2</span>
    <span style="color:#fff;font:600 ${11 * s}px/${11 * s}px ${FONT};-webkit-text-stroke:${2 * s}px #000;paint-order:stroke fill">mia</span></div>`;
  const downtag = (cx, ty) => `<div style="position:absolute;left:${cx}px;top:${ty}px;transform:translateX(-50%);white-space:nowrap;height:${13 * s}px;padding:0 ${4 * s}px;background:rgba(40,8,6,.86);color:#ff5a4a;font:600 ${13 * s}px/${13 * s}px ${FONT}">down 16s</div>`;
  const feet = 196;
  let h = `<div style="position:absolute;left:0;top:0;width:100%;height:100%;background:url(${PLATE}) 0 0/420px 240px no-repeat;opacity:1"></div>`;
  h += mini(PIC, FX, FY, 92, feet, chipname(92, feet - 62 * s - 1, 0.4), 175, 330, 1050, 420);
  h += mini(PIC, FX, FY, 232, feet, chipname(232, feet - 62 * s - 1, 1), 175, 330, 1050, 420);
  h += mini(DOWN, FX, FY, 352, feet, chipname(352, feet - 62 * s - 1, 1) + downtag(352, feet - 77 * s - 1), 175, 330, 1050, 420);
  for (const [lab, cx] of [['far', 92], ['near', 232], ['down', 352]]) h += `<div style="position:absolute;left:${cx}px;bottom:7px;transform:translateX(-50%);color:#f2efe6;font:600 17px/1 ${FONT};text-shadow:0 1px 2px #000,0 0 6px #000">${lab}</div>`;
  return `<div id="far" style="position:absolute;left:1480px;top:790px;width:420px;height:240px;box-sizing:border-box;border:2px solid rgba(242,239,230,.9);border-radius:3px;overflow:hidden;box-shadow:0 0 0 1px rgba(0,0,0,.65),0 8px 28px rgba(0,0,0,.55);background:#000">${h}</div>`;
}

function page(name, tag, withFar) {
  const cx = FX, cy = 405, bx = cx * 3 - 320, by = cy * 3 - 200;
  return `<!doctype html><html><head><meta charset="utf-8"><title>${name}</title><style>${CSS}</style></head><body>
<div class="stage"><div class="bg"></div>${tag}</div>
<div id="in"><div class="stage" style="transform:translate(-${bx}px,-${by}px) scale(3)"><div class="bg"></div>${tag}</div></div><div id="t">3x</div>${withFar ? farInset() : ''}
</body></html>`;
}
const outs = [];
for (const [n, tag, far] of [['a10-A', A, 0], ['a10-B', B, 0], ['a10-C', '', 1], ['a10-D', D, 0]]) {
  const f = path.join(AS, 'mock', n + '.html');
  fs.writeFileSync(f, page(n, tag, far), 'utf8'); outs.push(path.relative(ROOT, f).split(path.sep).join('/'));
}
const only = process.argv.slice(2).filter(a => !a.startsWith('--'));
const todo = only.length ? outs.filter(o => only.some(n => o.includes(n))) : outs;
const r = spawnSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tools/handoff/art-survey/render.ps1', '-Html', todo.join(',')], { cwd: ROOT, encoding: 'utf8', timeout: 400000 });
console.log((r.stdout || '') + (r.stderr || ''));
