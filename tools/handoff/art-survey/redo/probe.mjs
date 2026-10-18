// node redo/probe.mjs file.js [pageName]   runs the JS (async body, return a value) on the fixture page with the scene prelude; prints the note
import fs from 'node:fs'; import path from 'node:path'; import { spawnSync } from 'node:child_process'; import { fileURLToPath } from 'node:url';
const here = path.dirname(fileURLToPath(import.meta.url)), AS = path.resolve(here, '..'), ROOT = path.resolve(AS, '..', '..', '..');
const r = JSON.parse(fs.readFileSync(path.join(AS, 'recipes.json'), 'utf8'));
const js = fs.readFileSync(process.argv[2], 'utf8');
const page = process.argv[3] || 'fixture';
const rec = { about: 'probe', prelude: r.prelude, screens: [{ name: 'probe', screen: 'probe', before: '', query: '', expect: '', js }] };
const rp = path.join(AS, 'shots', '_work', 'probe-redo.json'); fs.mkdirSync(path.dirname(rp), { recursive: true }); fs.writeFileSync(rp, JSON.stringify(rec));
const out = path.join(AS, 'shots', '_work', 'probe-redo-out'); fs.rmSync(out, { recursive: true, force: true });
const url = page === 'fixture' ? 'http://localhost:8808/fixture.html' : 'http://localhost:8808/handoff/art-survey/game/' + page + '.html';
const x = spawnSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tools/uishots.ps1', '-Screens', 'probe', '-Recipes', rp, '-Url', url, '-Out', out, '-Res', '1080', '-Port', '9375', '-NoLint'], { cwd: ROOT, encoding: 'utf8', timeout: 240000 });
try { const rep = JSON.parse(fs.readFileSync(path.join(out, 'report.json'), 'utf8')); const e = rep.screens[0]['1080']; console.log('staged=' + e.staged + '\n' + e.note); }
catch (e) { console.log('NO REPORT\n' + (x.stdout || '') + (x.stderr || '')); }
