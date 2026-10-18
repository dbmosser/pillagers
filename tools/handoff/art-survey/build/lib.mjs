// art-survey build helpers (2026-10-18): make a patched copy of tools/fixture.html, shoot it with the game's camera.
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
export const AS = path.resolve(here, '..');                     // art-survey
export const ROOT = path.resolve(AS, '..', '..', '..');          // C:\claudecode\dark raiders
let SRC = null;
export function src() { if (SRC === null) SRC = fs.readFileSync(path.join(AS, 'game', 'base.html'), 'utf8'); return SRC; }
// edits: [[find, replace, count?]]; every find must be present exactly count (default 1) times, or it throws
export function apply(text, edits, tag) {
  for (const e of edits) {
    const [find, rep, cnt] = e; const want = cnt === undefined ? 1 : cnt;
    if (find instanceof RegExp) {
      const re = new RegExp(find.source, find.flags.includes('g') ? find.flags : find.flags + 'g');
      const n = (text.match(re) || []).length;
      if (n !== want) throw new Error(tag + ': pattern matched ' + n + ' times (want ' + want + '): ' + find.source.slice(0, 90));
      text = text.replace(re, () => rep);
      continue;
    }
    let n = 0, i = -1; while ((i = text.indexOf(find, i + 1)) !== -1) n++;
    if (n !== want) throw new Error(tag + ': anchor found ' + n + ' times (want ' + want + '): ' + find.slice(0, 90));
    text = text.split(find).join(rep);
  }
  return text;
}
export function buildCopy(name, edits) {
  const out = path.join(AS, 'game', name + '.html');
  fs.writeFileSync(out, apply(src(), edits || [], name), 'utf8');
  return out;
}
export function shoot(name, scene, recipes) {
  const outDir = path.join(AS, 'shots', name);
  fs.rmSync(outDir, { recursive: true, force: true });
  const args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tools/uishots.ps1', '-Screens', scene, '-Recipes', path.join(AS, recipes || 'recipes-x.json'),
    '-Url', 'http://localhost:8808/handoff/art-survey/game/' + name + '.html', '-Out', outDir, '-Res', '4k', '-Port', '9371', '-NoLint'];
  const r = spawnSync('powershell', args, { cwd: ROOT, encoding: 'utf8', timeout: 240000 });
  const jpg = path.join(outDir, scene + '-4k.jpg');
  const ok = fs.existsSync(jpg);
  const note = (r.stdout || '').split('\n').filter(l => /staged|NOT STAGED|error|Error/i.test(l)).join(' | ').slice(0, 300);
  return { ok, jpg, note, err: ok ? '' : ((r.stderr || '') + (r.stdout || '')).slice(-600) };
}
