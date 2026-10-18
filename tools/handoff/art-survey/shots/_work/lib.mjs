// lib.mjs : helpers for the art-survey picture job (a11 to a17). Never edits the game, only copies of the fixture.
import fs from 'node:fs';
import path from 'node:path';
export const ROOT = 'C:/claudecode/dark raiders';
export const AS = ROOT + '/tools/handoff/art-survey';
export const WORK = AS + '/shots/_work';
// copy tools/fixture.html to game/NAME.html, apply exact replacements (each must match exactly `n` times, default 1), and set window.__OPT
export function mkgame(name, reps, vars) {
  let s = fs.readFileSync(ROOT + '/tools/fixture.html', 'utf8');
  for (const r of reps || []) {
    const n = r.n || 1;
    const parts = s.split(r.from);
    const found = parts.length - 1;
    if (found !== n) throw new Error(name + ': replacement matched ' + found + ' times, wanted ' + n + ': ' + r.from.slice(0, 80));
    s = parts.join(r.to);
  }
  const inj = '<script>' + Object.entries(vars || {}).map(([k, v]) => 'window.' + k + '=' + JSON.stringify(v) + ';').join('') + '</script>';
  const m0 = '<meta charset="utf-8">';
  if (!s.startsWith(m0)) throw new Error('fixture does not start with the charset meta');
  s = m0 + inj + s.slice(m0.length);
  const out = AS + '/game/' + name + '.html';
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, s);
  return out;
}
// recipes: the prelude of recipes.json plus my own screens
export function mkrec(outfile, screens) {
  const base = JSON.parse(fs.readFileSync(AS + '/recipes.json', 'utf8'));
  const out = { about: base.about + ' (a11-a17 picture job)', prelude: base.prelude, screens };
  fs.writeFileSync(outfile, JSON.stringify(out, null, 1));
}
