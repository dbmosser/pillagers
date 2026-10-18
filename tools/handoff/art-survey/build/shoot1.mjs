// node build/shoot1.mjs <screen> [htmlcopy=base] [res=1080]   quick look: shoots one screen of recipes-x.json from game/<htmlcopy>.html into shots/_quick/<screen>/
import path from 'node:path'; import fs from 'node:fs'; import { spawnSync } from 'node:child_process'; import { AS, ROOT } from './lib.mjs';
const [scr, copy = 'base', res = '1080'] = process.argv.slice(2);
const out = path.join(AS, 'shots', '_quick', scr + '-' + copy);
fs.rmSync(out, { recursive: true, force: true });
const args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tools/uishots.ps1', '-Screens', scr, '-Recipes', path.join(AS, 'recipes-x.json'), '-Url', 'http://localhost:8808/handoff/art-survey/game/' + copy + '.html', '-Out', out, '-Res', res, '-Port', '9371', '-NoLint'];
const p = spawnSync('powershell', args, { cwd: ROOT, encoding: 'utf8', timeout: 240000 });
const f = path.join(out, scr + '-' + res + '.jpg');
console.log(fs.existsSync(f) ? f : 'FAILED ' + (p.stdout || '').slice(-500) + (p.stderr || '').slice(-300));
const rp = path.join(out, 'report.json'); if (fs.existsSync(rp)) { try { const j = JSON.parse(fs.readFileSync(rp, 'utf8').replace(/^\uFEFF/, '')); console.log(String(j.screens[0][res].note).slice(0, 900)); } catch (e) {} }
