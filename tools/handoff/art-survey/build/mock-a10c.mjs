// mock-a10c.mjs : the survey picture of a10-C (name only when far), second pass. Real game frames, no pasted strip:
//   the whole picture is the real duo frame with the mate close and NO tag; the two boxes top right are 3x crops of two other real game frames
//   (shots/a10-far: the mate far away, shots/a10-down: the mate down), each with the tag drawn over the mate where the game puts it.
//   node build/mock-a10c.mjs      writes mock/a10-C.html and renders img/a10-C.jpg
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { AS, ROOT } from './lib.mjs';

const FONT = "'Barlow Condensed','Bahnschrift SemiCondensed','Arial Narrow','Roboto Condensed',sans-serif";
const K = 3;
// the 1080-frame numbers come from each shot's report (4k numbers / 2)
const FAR = { pic: '../shots/a10-far/pic.jpg', u: 3.397, fx: 1536, fy: 591.5, cy: 448, w: 640, h: 440, top: 20, label: 'far' };
const DOWN = { pic: '../shots/a10-down/pic.jpg', u: 3.397, fx: 1196, fy: 591.5, cy: 520, w: 640, h: 456, top: 468, label: 'down' };

function chipname(u, cx, top, alpha) {
  return `<div style="position:absolute;left:${cx}px;top:${top}px;transform:translateX(-50%);opacity:${alpha};white-space:nowrap;display:flex;align-items:center;gap:${3 * u}px;height:${14 * u}px">
    <span style="box-sizing:border-box;width:${14 * u}px;height:${10 * u}px;border-radius:${3 * u}px;background:#38d6ff;color:#10151b;font:700 ${8 * u}px/${10 * u}px ${FONT};text-align:center">p2</span>
    <span style="color:#fff;font:600 ${11 * u}px/${11 * u}px ${FONT};-webkit-text-stroke:${2 * u}px #000;paint-order:stroke fill">mia</span></div>`;
}
function downtag(u, cx, top) {
  return `<div style="position:absolute;left:${cx}px;top:${top}px;transform:translateX(-50%);white-space:nowrap;height:${13 * u}px;line-height:${13 * u}px;padding:0 ${4 * u}px;background:rgba(40,8,6,.86);color:#ff5a4a;font:600 ${13 * u}px/${13 * u}px ${FONT}">down 16s</div>`;
}
function box(c, tags, withTag) {
  const left = 1920 - 20 - c.w, bx = c.fx * K - c.w / 2, by = c.cy * K - c.h / 2;
  return `<div style="position:absolute;left:${left}px;top:${c.top}px;width:${c.w}px;height:${c.h}px;box-sizing:border-box;border:2px solid rgba(242,239,230,.9);border-radius:3px;overflow:hidden;box-shadow:0 0 0 1px rgba(0,0,0,.65),0 8px 28px rgba(0,0,0,.55);background:#000">
  <div style="position:absolute;left:0;top:0;width:1920px;height:1080px;transform-origin:0 0;transform:translate(${-bx}px,${-by}px) scale(${K});background:url(${c.pic}) 0 0/1920px 1080px no-repeat">${tags}</div>
  <div style="position:absolute;left:12px;bottom:10px;padding:2px 10px 3px;border-radius:3px;background:rgba(10,12,14,.72);color:#f2efe6;font:700 24px/1 ${FONT};letter-spacing:.04em">${c.label}</div>
  ${withTag ? `<div style="position:absolute;right:8px;top:8px;padding:2px 9px 3px;border-radius:3px;background:rgba(10,12,14,.72);color:#f2efe6;font:700 22px/1 ${FONT};letter-spacing:.04em">3x</div>` : ''}
</div>`;
}
// far: 340 world units away, so the tag is part way up its fade (0.4 at 300, full at 400): alpha about 0.64
const farTags = chipname(FAR.u, FAR.fx, FAR.fy - 62 * FAR.u - 2.5, 0.64);
// down: the tag stack sits low over the body, the red seconds tag above the name
const downTags = chipname(DOWN.u, DOWN.fx, DOWN.fy - 26 * DOWN.u, 1) + downtag(DOWN.u, DOWN.fx, DOWN.fy - 26 * DOWN.u - 15 * DOWN.u);
const html = `<!doctype html><html><head><meta charset="utf-8"><title>a10-C</title><style>
html,body{margin:0;padding:0;width:1920px;height:1080px;overflow:hidden;background:#000}
#f{position:absolute;left:0;top:0;width:1920px;height:1080px;background:url(../shots/a01-A/pic.jpg) 0 0/1920px 1080px no-repeat}
</style></head><body><div id="f"></div>${box(FAR, farTags, true)}${box(DOWN, downTags, false)}</body></html>`;
const f = path.join(AS, 'mock', 'a10-C.html');
fs.writeFileSync(f, html, 'utf8');
const r = spawnSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tools/handoff/art-survey/render.ps1', '-Html', path.relative(ROOT, f).split(path.sep).join('/')], { cwd: ROOT, encoding: 'utf8', timeout: 200000 });
console.log((r.stdout || '') + (r.stderr || ''));
