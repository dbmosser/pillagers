// devdash/server.mjs : PILLAGERS DEV, a live dashboard of everything working on the game (2026-10-17, his "can you build like a
// separate windows app that shows everything that's happening at any given time related to developing the game?").
// Reads only status files, logs and git; never a key. Serves http://127.0.0.1:8820 (localhost only). Opened as its own window by
// the desktop shortcut (tools/devdash/open.vbs starts this server if it is not running, then opens Chrome in app mode).
import http from 'http';
import os from 'os';
import { readFileSync, statSync, existsSync, readdirSync, writeFileSync, appendFileSync } from 'fs';
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
// 10-18: the latest stable build (tools/stable.sh writes tools/handoff/stable.txt) and the latest morning/evening report (tools/report.mjs)
const REP = R + '/tools/handoff/reports';
function kv(p) { const o = {}; rd(p).split(/\r?\n/).forEach(l => { const m = /^(\w+)=(.*)$/.exec(l.trim()); if (m) o[m[1]] = m[2]; }); return o; }
function latestReport() {
  try { const f = readdirSync(REP).filter(n => /^\d{4}-\d\d-\d\d-(am|pm)\.html$/.test(n)).sort(); if (!f.length) return null;
    const n = f[f.length - 1]; return { name: n, at: Math.round(statSync(REP + '/' + n).mtimeMs) }; } catch { return null; }
}
// 10-19, his "add stuff to the dashboard that looks at pacing of my Claude plan weekly usage": the REAL weekly number (claude -p "/usage",
// free, the same reading the plan helpers pace by) against the even line to PLAN_TARGET% (85) at the weekly reset. Each new reading is
// kept in console/plan-usage-log.txt so the page can draw the week. Refreshed here every 10 minutes when no helper has done it.
const PU = C + '/plan-usage.txt', PL = C + '/plan-usage-log.txt';
const CLAUDE = existsSync(process.env.USERPROFILE + '/.local/bin/claude.exe') ? process.env.USERPROFILE + '/.local/bin/claude.exe' : 'claude';
let planBusy = false, planTried = 0, planLogged = (() => { const l = tail(PL, 1)[0]; return l ? +l.split(' ')[0] : 0; })();
function planRefresh() {
  if (planBusy || Date.now() - planTried < 10 * 60e3) return; planBusy = true; planTried = Date.now();
  const env = { ...process.env }; delete env.ANTHROPIC_API_KEY;
  execFile(CLAUDE, ['-p', '/usage', '--output-format', 'json'], { cwd: R, env, timeout: 90e3, windowsHide: true, maxBuffer: 4e6 }, (err, out) => {
    planBusy = false; const t = String(out || '');
    const a = /Current session: (\d+)% used/.exec(t), w = /Current week \(all models\): (\d+)% used/.exec(t);
    if (a && w) try { writeFileSync(PU, a[1] + ' ' + w[1] + ' ' + Math.round(Date.now() / 1000) + '\n'); } catch {} });
}
function plan() {
  const [ses, wk, at] = rd(PU).trim().split(/\s+/).map(Number);
  const ageS = at ? Math.round(Date.now() / 1000 - at) : null;
  if (ageS === null || ageS > 600) planRefresh();
  if (at && at !== planLogged) { try { appendFileSync(PL, at + ' ' + ses + ' ' + wk + '\n'); planLogged = at; } catch {} }
  const caps = kv(C + '/caps.txt'), target = +(caps.PLAN_TARGET || 85), sesMax = +(caps.PLAN_SESSION_MAX || 75);
  let reset = Date.parse(caps.WEEK_RESET || '2026-10-25T05:00:00Z'); while (Date.now() >= reset) reset += 7 * 864e5;
  const start = reset - 7 * 864e5, line = (Date.now() - start) / (7 * 864e5) * target;
  const hist = tail(PL, 3000).map(l => l.split(' ').map(Number)).filter(h => h[0] * 1000 >= start && !isNaN(h[2])).map(h => [h[0] * 1000, h[2]]);
  if (isNaN(wk)) return { wk: null };
  return { ses, wk, ageS, target, sesMax, pace: String(caps.PLAN_PACE ?? '1').trim() !== '0', reset, start, line: +line.toFixed(1), catchUp: wk > line ? start + (wk / target) * 7 * 864e5 : null,
    perDay: +((target - wk) / Math.max(0.1, (reset - Date.now()) / 864e5)).toFixed(1), hist };
}
let cpuPrev = os.cpus(), cpu = 0;
setInterval(() => { const c = os.cpus(); let idle = 0, tot = 0;
  c.forEach((k, i) => { const p = cpuPrev[i].times, t = k.times; const d = (t.user + t.nice + t.sys + t.idle + t.irq) - (p.user + p.nice + p.sys + p.idle + p.irq); tot += d; idle += t.idle - p.idle; });
  cpu = tot ? Math.round(100 * (1 - idle / tot)) : 0; cpuPrev = c; }, 2000);
let procs = { chrome: 0, fuzz: [], workers: 0, review: 0, ollama: 0, codex: 0, agy: 0, reviewers: [], t: 0 };
function pollProcs() {
  execFile('powershell', ['-NoProfile', '-Command', "Get-CimInstance Win32_Process | ForEach-Object { $_.Name + '|' + $_.CommandLine }"], { maxBuffer: 32e6, windowsHide: true }, (err, out) => {
    if (err) return; const L = out.split(/\r?\n/);
    procs = { chrome: L.filter(l => /^chrome\.exe\|/i.test(l)).length,
      fuzz: L.filter(l => /fuzz\.ps1/.test(l) && /^powershell/i.test(l)).map(l => (/-Port (\d+)/.exec(l) || [0, '9331'])[1]),
      workers: L.filter(l => /run-api\.mjs/.test(l) && /^node/i.test(l)).length,
      review: L.filter(l => /review-batch\.mjs/.test(l) && /^node/i.test(l)).length,
      ollama: L.filter(l => /^(ollama|llama)/i.test(l)).length,
      codex: L.filter(l => /^node/i.test(l) && /codex\.js/.test(l) && /\bexec\b/.test(l)).length,
      agy: L.filter(l => /^agy\.exe\|/i.test(l)).length,
      reviewers: L.filter(l => /^powershell/i.test(l) && /ship-review\.ps1/.test(l)).map(l => (/-Engine (\w+)/i.exec(l) || [0, 'ollama'])[1].toLowerCase()), t: Date.now() };
  });
}
pollProcs(); setInterval(pollProcs, 15000);
function git(args) { try { return execFileSync('git', args, { cwd: R, encoding: 'utf8', windowsHide: true }).trim(); } catch { return ''; } }
function caps() { const o = {}; rd(C + '/caps.txt').split(/\r?\n/).forEach(l => { const m = /^(\w+)=(.*)$/.exec(l.trim()); if (m) o[m[1]] = m[2]; }); return o; }
// 10-19, his "the dashboard should be a cmprehensive napshot of everything we are doing to develop the game": the other AI services.
// ChatGPT (the Codex helper, lane o), Google Antigravity (the bug checker, tools/ship-review.ps1 -Engine agy), the local AI (Ollama on
// his graphics card). Reads status files, logs and two local answers (Ollama's API, "codex login status"); never a key.
const SR = R + '/tools/handoff/ship-review', CX = R + '/tools/handoff/codex';
let aiLive = { ollamaUp: false, models: [], loaded: [], codexLogin: '', t: 0, lt: 0 };
function getJson(url) { return new Promise(res => { const rq = http.get(url, { timeout: 4000 }, r => { let b = ''; r.on('data', c => b += c); r.on('end', () => { try { res(JSON.parse(b)); } catch { res(null); } }); }); rq.on('error', () => res(null)); rq.on('timeout', () => { rq.destroy(); res(null); }); }); }
async function aiPoll() {
  const tags = await getJson('http://127.0.0.1:11434/api/tags'), ps = tags ? await getJson('http://127.0.0.1:11434/api/ps') : null;
  aiLive.ollamaUp = !!tags; aiLive.models = tags ? (tags.models || []).map(m => ({ name: m.name, gb: +(m.size / 2 ** 30).toFixed(1) })) : [];
  aiLive.loaded = ps ? (ps.models || []).map(m => m.name) : []; aiLive.t = Date.now();
  if (Date.now() - aiLive.lt > 10 * 60e3) { aiLive.lt = Date.now();
    const js = process.execPath.replace(/node\.exe$/i, '') + 'node_modules/@openai/codex/bin/codex.js', env = { ...process.env }; delete env.OPENAI_API_KEY; delete env.CODEX_API_KEY;
    execFile(process.execPath, [js, 'login', 'status'], { env, timeout: 30e3, windowsHide: true }, (e, o, er) => { aiLive.codexLogin = String(o || er || '').trim().split(/\r?\n/)[0] || ''; }); }
}
aiPoll(); setInterval(aiPoll, 30e3);
function revList() {
  try { return readdirSync(SR + '/reviews').filter(f => f.endsWith('.md')).map(f => ({ f, m: statSync(SR + '/reviews/' + f).mtimeMs })).sort((a, b) => b.m - a.m).map(x => {
    const t = rd(SR + '/reviews/' + x.f), n = (t.match(/^BUG\s*\d+/gm) || []).length, m = /^(v[\d.]+|[0-9a-f]{8})-(\w+)\.md$/.exec(x.f) || [0, x.f, '?'];
    return { ver: m[1], engine: m[2], bugs: n, at: Math.round(x.m) }; }); } catch { return []; }
}
function pullState() {   // the local model download (ollama pull, logged in the scratchpad)
  const t = rd(S + '/pull-qwen38.log').replace(/\x1b\[[0-9;?]*[A-Za-z]/g, ''); if (!t) return '';
  if (/success/.test(t.slice(-400))) return 'done'; if (/error/i.test(t.slice(-400))) return 'error';
  const m = [...t.matchAll(/pulling [0-9a-f]+:\s+(\d+)%[^\n\r]*?([\d.]+ [KMG]B)\/\s*([\d.]+ [KMG]B)/g)].pop(); return m ? m[1] + '% (' + m[2] + ' of ' + m[3] + ')' : 'starting';
}
function ai() {
  const day = new Date().toLocaleDateString('en-CA'), revs = revList(), st = e => rd(SR + '/status-' + e + '.txt').trim();
  return { codex: { login: aiLive.codexLogin, status: rd(C + '/status-o.txt').trim(), busy: existsSync(C + '/lane-o.lock'), task: rd(C + '/lane-o.lock/task').trim(),
      running: procs.codex || 0, runs: tail(CX + '/runs.txt', 8), stop: existsSync(CX + '/STOP'),
      done: tail(CX + '/runs.txt', 500).filter(l => /done/i.test(l)).length },
    google: { status: st('agy'), running: procs.reviewers.includes('agy'), busy: procs.agy || 0 },
    local: { up: aiLive.ollamaUp, models: aiLive.models, loaded: aiLive.loaded, pull: pullState(), status: st('ollama'), running: procs.reviewers.includes('ollama'),
      night: tail(R + '/tools/handoff/llm-night/run.log', 1)[0] || '' },
    reviews: revs.slice(0, 6), reviewsToday: revs.filter(r => new Date(r.at).toLocaleDateString('en-CA') === day).length,
    findings: tail(SR + '/findings.txt', 6) };
}
function data() {
  const today = new Date().toLocaleDateString('en-CA'), cp = caps();
  const sp = rd(C + '/spend.txt').split(/\r?\n/).filter(Boolean).map(l => l.split(' '));
  const spentToday0 = sp.filter(x => x[0] === today).reduce((s, x) => s + (+x[1] || 0), 0);
  // 10-18: the real Console spend (tools/console-sdk/balance.mjs) wins over the estimate when it is under 3 hours old
  let real = null; try { const r = JSON.parse(rd(C + '/real-spend.json')); if (r.month === today.slice(0, 7) && Date.now() - Date.parse(r.at) < 3 * 3600e3) real = r; } catch {}
  const spentAll0 = sp.reduce((s, x) => s + (+x[1] || 0), 0), before = sp.filter(x => x[0] < today).reduce((s, x) => s + (+x[1] || 0), 0);
  const total = +(cp.TOTAL_USD || 190), end = cp.END_DATE || '2026-10-31';
  const daysLeft = Math.max(1, Math.round((new Date(end) - new Date(today)) / 864e5) + 1), share = Math.max(0, (total - before) / daysLeft);
  const tasks = existsSync(C + '/tasks') ? readdirSync(C + '/tasks').filter(f => f.endsWith('.md')).sort() : [];
  const lane = f => /^[0-9]/.test(f) ? 'a' : f[0];
  const lanes = ['a', 'b', 'c', 'd', 'e', 'f', 'o'].filter(l => l < 'd' || existsSync(C + '/status-' + l + '.txt')).map(l => ({ lane: l, status: rd(C + '/status-' + l + '.txt').trim(), busy: existsSync(C + '/lane-' + l + '.lock'),
    queue: tasks.filter(f => lane(f) === l).map(f => f.replace(/\.md$/, '')) }));
  const lockOwner = existsSync(S + '/shipq.lock') ? rd(S + '/shipq.owner').trim() : '';
  const commits = git(['log', '-14', '--format=%h|%ad|%s', '--date=format:%m-%d %H:%M']).split('\n').filter(Boolean).map(l => l.split('|'));
  const shipsToday = git(['log', '--since=midnight', '--format=%s']).split('\n').filter(s => /^v\d+\.\d+:/.test(s)).length;
  const hb = ageS(N + '/runner.heartbeat');
  const titles = {}; (tail(S + "/shipq.log", 12).join(" ") + " " + lockOwner).replace(/cw-[A-Za-z0-9_-]+/g, k => { if (!titles[k]) { try { titles[k] = JSON.parse(rd(R + "/tools/handoff/drafts/draft-" + k + ".json").replace(/^﻿/, "")).title || ""; } catch {} } return k; });
  const st = kv(R + '/tools/handoff/stable.txt');
  // 10-20: his notes from the main PC (tools/fetch-notes.mjs, coord-01) and the spare PC (tools/spare/spare-import.mjs)
  const notes = rd(R + '/tools/handoff/notes-fetch.txt').trim().slice(0, 240), spare = rd(R + '/tools/handoff/spare-status.txt').trim().slice(0, 300);
  return { now: new Date().toLocaleTimeString(), ver: ver(), shipsToday, cpu, notes, spare,
    stable: { version: st.version || '', at: st.at || '', address: st.address || '', frozen: existsSync(R + '/tools/handoff/stable.freeze') }, report: latestReport(), ramFree: +(os.freemem() / 2 ** 30).toFixed(1), ramTot: Math.round(os.totalmem() / 2 ** 30),
    procs, runnerAgeS: hb, lockOwner, titles, lanes, stopFile: existsSync(C + '/STOP'),
    spend: { real: !!real, today: +(real ? real.today_usd : spentToday0).toFixed(2), all: +(real ? real.month_usd : spentAll0).toFixed(2), total, share: +share.toFixed(2), daysLeft, end },
    done: existsSync(C + '/done') ? readdirSync(C + '/done').length : 0, failed: existsSync(C + '/failed') ? readdirSync(C + '/failed') : [],
    blocked: existsSync(C + '/blocked') ? readdirSync(C + '/blocked').filter(f => f.endsWith('.md')).map(f => ({ job: f.slice(0, -3), on: rd(C + '/blocked/' + f.slice(0, -3) + '.on').trim() })) : [],
    questions: tail(C + '/for-you.md', 12), plan: plan(), runs: tail(C + '/runs.log', 10), shipq: tail(S + '/shipq.log', 12),
    ai: ai(), nightly: tail(N + '/nightly.log', 8), fuzz: tail(R + '/tools/handoff/fuzz/fuzz.log', 4), review: tail(C + '/review/review.log', 3), commits };
}
const PAGE = () => rd("C:/claudecode/dark raiders/tools/devdash/index.html");   // read per request, so edits show at once
http.createServer((q, s) => {
  if (q.url.startsWith('/api')) { s.writeHead(200, { 'content-type': 'application/json', 'cache-control': 'no-store' }); s.end(JSON.stringify(data())); return; }
  // 10-18: /report is the newest morning/evening report; /reports/NAME.html is a named one (names checked, nothing else is served)
  if (q.url === '/report' || q.url.startsWith('/reports/')) {
    let raw = ''; try { raw = decodeURIComponent(q.url.slice(9)).split('?')[0]; } catch {}
    const lr = latestReport(), name = q.url === '/report' ? (lr && lr.name) : raw;
    const body = name && /^\d{4}-\d\d-\d\d-(am|pm)\.html$/.test(name) ? rd(REP + '/' + name, null) : null;
    if (body === null) { s.writeHead(404, { 'content-type': 'text/plain; charset=utf-8' }); s.end('No report yet. tools/report.mjs writes one at 07:00 and 18:00.'); return; }
    s.writeHead(200, { 'content-type': 'text/html; charset=utf-8', 'cache-control': 'no-store' }); s.end(body); return;
  }
  s.writeHead(200, { 'content-type': 'text/html; charset=utf-8' }); s.end(PAGE());
}).listen(8820, '127.0.0.1');

// 10-19 night, his words: "i cant see what all the helpers ... are doing in real time unless i ask you, thats why i wanted the dashboard to
// update in real time". This server is localhost-only inside the VM and the main PC cannot reach it, so every 30 s a self-contained copy (the
// page above with its data inside, no server needed) goes to the main PC's bridge share folder as pillagers-dashboard.html, through the host
// bridge's existing share-put job (tools/bridge/hostctl.mjs). The copy reloads itself every 30 s and says so when the VM stops sending.
// Never a key in the page: data() reads only status files, logs and git.
const SNAP_NAME = 'pillagers-dashboard.html', SNAP_TMP = os.tmpdir() + '/pillagers-dashboard-snap.html', SNAP_LOG = os.tmpdir() + '/pillagers-dashboard-push.log';
const SNAP_TAIL = "tick();(function(){var age=Math.round((Date.now()-window.__SNAP.snapAt)/1000);" +
  "if(age>120)$('upd').innerHTML='<span class=\"warn\">No news from the VM for '+Math.round(age/60)+' min (it may be restarting); this page keeps trying</span>';" +
  "try{var y=sessionStorage.getItem('dashY');if(y)scrollTo(0,+y);}catch(e){}" +
  "setTimeout(function(){try{sessionStorage.setItem('dashY',String(scrollY));}catch(e){}location.reload();},30000);})();";
let snapBusy = false, snapErrAt = 0;
function snapshot() {
  const d = data(); d.snapAt = Date.now();
  return PAGE()
    .replace("d=await (await fetch('/api',{cache:'no-store'})).json();", 'd=window.__SNAP;')
    .replace('tick(); setInterval(tick,5000);', SNAP_TAIL)
    .replace("(every 5 seconds)", "(sent from the VM every 30 seconds)")
    .replace('href="/report"', 'href="#"')
    .replace('<script>', '<script>window.__SNAP=' + JSON.stringify(d).replace(/</g, '\u003c') + ';</script><script>');
}
function pushSnap() {
  if (snapBusy) return; snapBusy = true;
  try { writeFileSync(SNAP_TMP, snapshot()); } catch (e) { snapBusy = false; return; }
  execFile(process.execPath, [R + '/tools/bridge/hostctl.mjs', 'share-put', 'name=' + SNAP_NAME, '--file', SNAP_TMP], { timeout: 20000, windowsHide: true }, (err, out, errOut) => {
    snapBusy = false;
    if ((err || !/"ok":\s*true/.test(String(out))) && Date.now() - snapErrAt > 600000) {
      snapErrAt = Date.now();
      try { appendFileSync(SNAP_LOG, new Date().toISOString() + ' push failed: ' + String((err && err.message) || out || errOut).replace(/\s+/g, ' ').slice(0, 300) + '\n'); } catch {}
    }
  });
}
setTimeout(pushSnap, 3000); setInterval(pushSnap, 30000);
