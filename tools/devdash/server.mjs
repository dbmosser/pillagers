// devdash/server.mjs : PILLAGERS DEV, a live dashboard of everything working on the game (2026-10-17, his "can you build like a
// separate windows app that shows everything that's happening at any given time related to developing the game?").
// Reads only status files, logs and git; never a key. Serves http://127.0.0.1:8820 (localhost only). Opened as its own window by
// the desktop shortcut (tools/devdash/open.vbs starts this server if it is not running, then opens Chrome in app mode).
import http from 'http';
import os from 'os';
import { readFileSync, statSync, existsSync, readdirSync } from 'fs';
import { execFileSync, execFile } from 'child_process';
const R = 'C:/claudecode/dark raiders', C = R + '/tools/handoff/console', N = R + '/tools/handoff/nightly';
const S = 'C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad';
const rd = (p, d = '') => { try { return readFileSync(p, 'utf8'); } catch { return d; } };
const tail = (p, n) => rd(p).replace(/\r/g, '').trimEnd().split('\n').filter(Boolean).slice(-n);
const ageS = p => { try { return Math.round((Date.now() - statSync(p).mtimeMs) / 1000); } catch { return null; } };
let verCache = { m: 0, v: '?' };
function ver() {
  try { const m = statSync(R + '/dark_raiders.html').mtimeMs; if (m !== verCache.m) {
    const t = readFileSync(R + '/dark_raiders.html', 'utf8'); const x = /\nvar VER='([0-9.]+)'/.exec(t); verCache = { m, v: x ? x[1] : '?' }; } } catch {}
  return verCache.v;
}
let cpuPrev = os.cpus(), cpu = 0;
setInterval(() => { const c = os.cpus(); let idle = 0, tot = 0;
  c.forEach((k, i) => { const p = cpuPrev[i].times, t = k.times; const d = (t.user + t.nice + t.sys + t.idle + t.irq) - (p.user + p.nice + p.sys + p.idle + p.irq); tot += d; idle += t.idle - p.idle; });
  cpu = tot ? Math.round(100 * (1 - idle / tot)) : 0; cpuPrev = c; }, 2000);
let procs = { chrome: 0, fuzz: [], workers: 0, review: 0, ollama: 0, t: 0 };
function pollProcs() {
  execFile('powershell', ['-NoProfile', '-Command', "Get-CimInstance Win32_Process | ForEach-Object { $_.Name + '|' + $_.CommandLine }"], { maxBuffer: 32e6, windowsHide: true }, (err, out) => {
    if (err) return; const L = out.split(/\r?\n/);
    procs = { chrome: L.filter(l => /^chrome\.exe\|/i.test(l)).length,
      fuzz: L.filter(l => /fuzz\.ps1/.test(l) && /^powershell/i.test(l)).map(l => (/-Port (\d+)/.exec(l) || [0, '9331'])[1]),
      workers: L.filter(l => /run-api\.mjs/.test(l) && /^node/i.test(l)).length,
      review: L.filter(l => /review-batch\.mjs/.test(l) && /^node/i.test(l)).length,
      ollama: L.filter(l => /^(ollama|llama)/i.test(l)).length, t: Date.now() };
  });
}
pollProcs(); setInterval(pollProcs, 15000);
function git(args) { try { return execFileSync('git', args, { cwd: R, encoding: 'utf8', windowsHide: true }).trim(); } catch { return ''; } }
function caps() { const o = {}; rd(C + '/caps.txt').split(/\r?\n/).forEach(l => { const m = /^(\w+)=(.*)$/.exec(l.trim()); if (m) o[m[1]] = m[2]; }); return o; }
function data() {
  const today = new Date().toLocaleDateString('en-CA'), cp = caps();
  const sp = rd(C + '/spend.txt').split(/\r?\n/).filter(Boolean).map(l => l.split(' '));
  const spentToday = sp.filter(x => x[0] === today).reduce((s, x) => s + (+x[1] || 0), 0);
  const spentAll = sp.reduce((s, x) => s + (+x[1] || 0), 0), before = sp.filter(x => x[0] < today).reduce((s, x) => s + (+x[1] || 0), 0);
  const total = +(cp.TOTAL_USD || 190), end = cp.END_DATE || '2026-10-31';
  const daysLeft = Math.max(1, Math.round((new Date(end) - new Date(today)) / 864e5) + 1), share = Math.max(0, (total - before) / daysLeft);
  const tasks = existsSync(C + '/tasks') ? readdirSync(C + '/tasks').filter(f => f.endsWith('.md')).sort() : [];
  const lane = f => /^[0-9]/.test(f) ? 'a' : f[0];
  const lanes = ['a', 'b', 'c'].map(l => ({ lane: l, status: rd(C + '/status-' + l + '.txt').trim(), busy: existsSync(C + '/lane-' + l + '.lock'),
    queue: tasks.filter(f => lane(f) === l).map(f => f.replace(/\.md$/, '')) }));
  const lockOwner = existsSync(S + '/shipq.lock') ? rd(S + '/shipq.owner').trim() : '';
  const commits = git(['log', '-14', '--format=%h|%ad|%s', '--date=format:%m-%d %H:%M']).split('\n').filter(Boolean).map(l => l.split('|'));
  const shipsToday = git(['log', '--since=midnight', '--format=%s']).split('\n').filter(s => /^v\d+\.\d+:/.test(s)).length;
  const hb = ageS(N + '/runner.heartbeat');
  return { now: new Date().toLocaleTimeString(), ver: ver(), shipsToday, cpu, ramFree: +(os.freemem() / 2 ** 30).toFixed(1), ramTot: Math.round(os.totalmem() / 2 ** 30),
    procs, runnerAgeS: hb, lockOwner, lanes, stopFile: existsSync(C + '/STOP'),
    spend: { today: +spentToday.toFixed(2), all: +spentAll.toFixed(2), total, share: +share.toFixed(2), daysLeft, end },
    done: existsSync(C + '/done') ? readdirSync(C + '/done').length : 0, failed: existsSync(C + '/failed') ? readdirSync(C + '/failed') : [],
    questions: tail(C + '/questions.md', 8), runs: tail(C + '/runs.log', 10), shipq: tail(S + '/shipq.log', 12),
    nightly: tail(N + '/nightly.log', 8), fuzz: tail(R + '/tools/handoff/fuzz/fuzz.log', 4), review: tail(C + '/review/review.log', 3), commits };
}
const PAGE = () => rd("C:/claudecode/dark raiders/tools/devdash/index.html");   // read per request, so edits show at once
http.createServer((q, s) => {
  if (q.url.startsWith('/api')) { s.writeHead(200, { 'content-type': 'application/json', 'cache-control': 'no-store' }); s.end(JSON.stringify(data())); return; }
  s.writeHead(200, { 'content-type': 'text/html; charset=utf-8' }); s.end(PAGE());
}).listen(8820, '127.0.0.1');
