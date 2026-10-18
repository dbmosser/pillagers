// redo/lib.mjs (2026-10-18, art-survey redo helper, camera port 9375): copy of tools/fixture.html patched for one option, shot with the game's camera.
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url));
export const AS = path.resolve(here, '..');
export const ROOT = path.resolve(AS, '..', '..', '..');
export const PORT = 9375;
export function readFixture() { return fs.readFileSync(path.join(ROOT, 'tools', 'fixture.html'), 'utf8'); }
// edits: [[find, replace, count?]]; every find must be present exactly count (default 1) times, or it throws
export function apply(text, edits, tag) {
  for (const e of edits) {
    const [find, rep, cnt] = e; const want = cnt === undefined ? 1 : cnt;
    let n = 0, i = -1; while ((i = text.indexOf(find, i + 1)) !== -1) n++;
    if (n !== want) throw new Error(tag + ': anchor found ' + n + ' times (want ' + want + '): ' + find.slice(0, 100));
    text = text.split(find).join(rep);
  }
  return text;
}
export function buildCopy(name, edits) {
  const out = path.join(AS, 'game', name + '.html');
  fs.writeFileSync(out, apply(readFixture(), edits || [], name), 'utf8');
  return out;
}
export function shoot(name, screen, recipes, urlName) {
  const outDir = path.join(AS, 'shots', name);
  fs.rmSync(outDir, { recursive: true, force: true });
  const args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tools/uishots.ps1', '-Screens', screen, '-Recipes', recipes || path.join(AS, 'recipes-redo.json'),
    '-Url', (urlName && urlName.startsWith('http')) ? urlName : 'http://localhost:8808/handoff/art-survey/game/' + (urlName || name) + '.html', '-Out', outDir, '-Res', '1080', '-Port', String(PORT), '-NoLint'];
  const r = spawnSync('powershell', args, { cwd: ROOT, encoding: 'utf8', timeout: 240000 });
  const jpg = path.join(outDir, screen + '-1080.jpg');
  const ok = fs.existsSync(jpg);
  const note = (r.stdout || '').split('\n').filter(l => /staged|NOT STAGED|error|Error|expect/i.test(l)).join(' | ').slice(0, 500);
  return { ok, jpg, note, err: ok ? '' : ((r.stderr || '') + (r.stdout || '')).slice(-800) };
}
