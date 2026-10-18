// m2-lib.mjs : second pass on the machine questions (a24..a28), 2026-10-18. Copy tools/fixture.html, patch the COPY, shoot it with the game's camera.
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
export const AS = path.resolve(here, '..');                     // art-survey
export const ROOT = path.resolve(AS, '..', '..', '..');          // C:\claudecode\dark raiders
export const PORT = 9374;
let SRC = null;
export function src() { if (SRC === null) SRC = fs.readFileSync(path.join(ROOT, 'tools', 'fixture.html'), 'utf8'); return SRC; }
// edits: [[find, replace, count?]]; every find must be present exactly count (default 1) times, or it throws
export function apply(text, edits, tag) {
  for (const e of edits) {
    const [find, rep, cnt] = e; const want = cnt === undefined ? 1 : cnt;
    let n = 0, i = -1; while ((i = text.indexOf(find, i + 1)) !== -1) n++;
    if (n !== want) throw new Error(tag + ': anchor found ' + n + ' times (want ' + want + '): ' + find.slice(0, 90));
    text = text.split(find).join(rep);
  }
  return text;
}
export function buildCopy(name, edits) {
  const out = path.join(AS, 'game', name + '.html');
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, apply(src(), edits || [], name), 'utf8');
  return out;
}
// the one place every copy gets its hooks: functions renamed so a wrapper can stand in front of each machine draw; the hook code goes in before the first frame
export const WRAP = [['drawSentryS', 'sentry'], ['drawCrawlerS', 'crawler'], ['drawSnitchS', 'snitch'], ['drawListenerS', 'listener'], ['drawHowlerS', 'howler'], ['drawBulwarkS', 'bulwark'], ['drawChoirS', 'choir'], ['drawWardenAt', 'warden']];
export const wrapEdits = () => WRAP.map(([fn, kind]) => ['function ' + fn + '(e){', 'function ' + fn + '(e){ if(__MW) return __MW(\'' + kind + '\',' + fn + '0,e); return ' + fn + '0(e); }\nfunction ' + fn + '0(e){']);
export const INJECT_AT = '\nrequestAnimationFrame(function(ts){\n  lastTs=ts;';
export const inject = (code) => [INJECT_AT, '\n// ---- art-survey hooks (this copy only) ----\nvar __MW=null;\n' + code + '\n' + INJECT_AT];
export function shoot(name, screen, recipes) {
  const outDir = path.join(AS, 'shots', name);
  fs.rmSync(outDir, { recursive: true, force: true });
  const args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tools/uishots.ps1', '-Screens', screen, '-Recipes', path.join(AS, recipes || 'recipes-mach2.json'),
    '-Url', 'http://localhost:8808/handoff/art-survey/game/' + name + '.html', '-Out', outDir, '-Res', '1080,4k', '-Port', String(PORT), '-NoLint'];
  const r = spawnSync('powershell', args, { cwd: ROOT, encoding: 'utf8', timeout: 420000 });
  const j1 = path.join(outDir, screen + '-1080.jpg'), j4 = path.join(outDir, screen + '-4k.jpg');
  const ok = fs.existsSync(j1) && fs.existsSync(j4);
  const note = (r.stdout || '').split('\n').filter(l => /staged|NOT STAGED|error|Error/i.test(l)).join(' | ').slice(0, 300);
  return { ok, j1, j4, note, err: ok ? '' : ((r.stderr || '') + (r.stdout || '')).slice(-800) };
}
