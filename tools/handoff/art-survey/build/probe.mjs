// node build/probe.mjs "<js that returns a string>"   runs the js in a staged raid (stage() already called) and prints what it returns
import fs from 'node:fs'; import path from 'node:path'; import { spawnSync } from 'node:child_process';
import { AS, ROOT } from './lib.mjs';
const js = process.argv[2];
const r = JSON.parse(fs.readFileSync(path.join(AS, 'recipes-x.json'), 'utf8'));
r.screens = [{ name: 'probe', screen: 'probe', before: '', query: '', expect: 'true', js: "var st=await window.__art.stage({}); " + js }];
const rp = path.join(AS, 'recipes-probe.json'); fs.writeFileSync(rp, JSON.stringify(r));
const out = path.join(AS, 'shots', '_probe');
fs.rmSync(out, { recursive: true, force: true });
const args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tools/uishots.ps1', '-Screens', 'probe', '-Recipes', rp, '-Url', 'http://localhost:8808/handoff/art-survey/game/base.html', '-Out', out, '-Res', '1080', '-Port', '9371', '-NoLint'];
const p = spawnSync('powershell', args, { cwd: ROOT, encoding: 'utf8', timeout: 240000 });
const rep = JSON.parse(fs.readFileSync(path.join(out, 'report.json'), 'utf8').replace(/^\uFEFF/, ''));
console.log(JSON.stringify(rep.screens[0]['1080'].note).slice(0, 6000));
