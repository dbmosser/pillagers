// devdash/server.mjs : PILLAGERS DEV, a live dashboard of everything working on the game (2026-10-17, his "can you build like a
// separate windows app that shows everything that's happening at any given time related to developing the game?").
// Reads only status files, logs and git; never a key. Serves http://127.0.0.1:8820 (localhost only). Opened as its own window by
// the desktop shortcut (tools/devdash/open.vbs starts this server if it is not running, then opens Chrome in app mode).
import http from 'http';
import os from 'os';
import { readFileSync, statSync, existsSync, readdirSync, writeFileSync, appendFileSync } from 'fs';
import { execFileSync, execFile, spawn } from 'child_process';
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
  // 10-25: PLAN_LINE_END (his "as ready as possible by Friday night") ends the line early, the same rule tools/console-lane.sh paces by,
  // so the page shows the line the helpers actually use (it showed the even line to the reset).
  const start = reset - 7 * 864e5, le = Date.parse(caps.PLAN_LINE_END || ''), end = le > start && le < reset ? le : reset;
  // 10-27, his "Keep shipping. Pace for 90% use by Friday afternoon": PLAN_LINE_START/PLAN_LINE_FROM start the line at the week's use when
  // he said it, then it climbs to PLAN_LINE_TARGET% at PLAN_LINE_END (the same rule tools/console-lane.sh paces by).
  const ls = Date.parse(caps.PLAN_LINE_START || ''), anch = ls >= start && ls < end && end < reset, f0 = anch ? +(caps.PLAN_LINE_FROM || 0) : 0;
  const goal = anch ? +(caps.PLAN_LINE_TARGET || target) : target, s0 = anch ? ls : start, clamp = v => Math.min(1, Math.max(0, v));
  const line = f0 + clamp((Date.now() - s0) / (end - s0)) * (goal - f0);
  const hist = tail(PL, 3000).map(l => l.split(' ').map(Number)).filter(h => h[0] * 1000 >= start && !isNaN(h[2])).map(h => [h[0] * 1000, h[2]]);
  if (isNaN(wk)) return { wk: null };
  return { ses, wk, ageS, target: goal, sesMax, pace: String(caps.PLAN_PACE ?? '1').trim() !== '0', reset, start, lineStart: anch ? ls : null, lineFrom: f0, lineEnd: end, line: +line.toFixed(1),
    catchUp: wk > line ? s0 + clamp((wk - f0) / (goal - f0)) * (end - s0) : null,
    perDay: +((goal - wk) / Math.max(0.1, (Math.max(end, Date.now() + 864e5) - Date.now()) / 864e5)).toFixed(1), hist };
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
// 10-25 (his "what about updating the dashboard ... is it unduly expensive"): once a minute, not every 15 s. Each listing starts a
// PowerShell (measured 0.8 s), which every 15 s came to over an hour of processor time a day; a minute is still live for a page of counts.
pollProcs(); setInterval(pollProcs, 60000);
function git(args) { try { return execFileSync('git', args, { cwd: R, encoding: 'utf8', windowsHide: true }).trim(); } catch { return ''; } }
function caps() { const o = {}; rd(C + '/caps.txt').split(/\r?\n/).forEach(l => { const m = /^(\w+)=(.*)$/.exec(l.trim()); if (m) o[m[1]] = m[2]; }); return o; }
// 10-19, his "the dashboard should be a cmprehensive napshot of everything we are doing to develop the game": the other AI services.
// ChatGPT (the Codex helper, lane o), Google Antigravity (the bug checker, tools/ship-review.ps1 -Engine agy), the local AI (Ollama on
// his graphics card). Reads status files, logs and two local answers (Ollama's API, "codex login status"); never a key.
const SR = R + '/tools/handoff/ship-review', CX = R + '/tools/handoff/codex';
let aiLive = { ollamaUp: false, models: [], loaded: [], codexLogin: '', t: 0, lt: 0 };
function getJson(url) { return new Promise(res => { const rq = http.get(url, { timeout: 4000 }, r => { let b = ''; r.on('data', c => b += c); r.on('end', () => { try { res(JSON.parse(b)); } catch { res(null); } }); }); rq.on('error', () => res(null)); rq.on('timeout', () => { rq.destroy(); res(null); }); }); }
// 10-23: the bug checker in the VM uses the main PC's Ollama (PILLAGERS_OLLAMA_URL, the same rule as ship-review.ps1: only localhost or a
// private-network address), so the dashboard asks the same place; asking the VM's own port said "not running" while it ran.
let OLL = String(process.env.PILLAGERS_OLLAMA_URL || '').trim();
if (!OLL) try { OLL = (execFileSync('reg', ['query', 'HKCU\\Environment', '/v', 'PILLAGERS_OLLAMA_URL'], { encoding: 'utf8', windowsHide: true }).match(/REG_\w+\s+(\S+)/) || [])[1] || ''; } catch {}
OLL = /^https?:\/\/(localhost|127(\.\d{1,3}){3}|10(\.\d{1,3}){3}|192\.168(\.\d{1,3}){2}|172\.(1[6-9]|2\d|3[01])(\.\d{1,3}){2})(:\d{1,5})?\/*$/.test(OLL) ? OLL.replace(/\/+$/, '') : 'http://127.0.0.1:11434';
// 10-28: the VM's network moves on a restart (192.168.160.x, then 172.17.96.x, then 172.20.160.x), so when the set address is silent
// try the main PC at the VM's default gateway too, the same fallback hostctl.mjs uses
let GW = ''; try { GW = (execFileSync('ipconfig', { encoding: 'utf8', windowsHide: true }).match(/Default Gateway[ .]*:\s*(\d+\.\d+\.\d+\.\d+)/) || [])[1] || ''; } catch {}
async function aiPoll() {
  let tags = await getJson(OLL + '/api/tags');
  if (!tags && GW && !OLL.includes('//' + GW + ':')) { const alt = 'http://' + GW + ':11434'; tags = await getJson(alt + '/api/tags'); if (tags) OLL = alt; }
  const ps = tags ? await getJson(OLL + '/api/ps') : null;
  aiLive.ollamaUp = !!tags; aiLive.models = tags ? (tags.models || []).map(m => ({ name: m.name, gb: +(m.size / 2 ** 30).toFixed(1) })) : [];
  aiLive.loaded = ps ? (ps.models || []).map(m => m.name) : []; aiLive.t = Date.now();
  if (Date.now() - aiLive.lt > 30 * 60e3) { aiLive.lt = Date.now();   // 10-25: the Codex login check every 30 min (was 10); it starts Codex each time
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
    local: { off: kv(C + '/caps.txt').LOCAL_AI === '0', up: aiLive.ollamaUp, models: aiLive.models, loaded: aiLive.loaded, pull: pullState(), status: st('ollama'), running: procs.reviewers.includes('ollama'),
      night: tail(R + '/tools/handoff/llm-night/run.log', 1)[0] || '' },
    reviews: revs.slice(0, 6), reviewsToday: revs.filter(r => new Date(r.at).toLocaleDateString('en-CA') === day).length,
    findings: tail(SR + '/findings.txt', 6) };
}
// 10-21, his "spare pc should be reflected in the dev dashboard" (he also calls the spare PC the JTPC): what it is doing, from what
// tools/spare/spare-import.mjs brings in from the spare-results branch (live.txt, its status file, its robot log). Cached for a minute.
const SPD = R + '/tools/handoff/spare';
let spareCache = { t: 0, v: null };
function spareInfo() {
  if (spareCache.v && Date.now() - spareCache.t < 60e3) return spareCache.v;
  const live = kv(SPD + '/live.txt'), host = /^[\w-]+$/.test(live.host || '') ? live.host : '';
  const raw = host ? git(['cat-file', 'blob', 'refs/spare-import/spare-results:spare/' + host + '/status.txt']) : '';
  const st = Object.fromEntries([...raw.replace(/\r?\n/g, ' ').matchAll(/(?:^|\s)(\w+)=(.*?)(?=\s+\w+=|\s*$)/g)].map(m => [m[1], m[2].trim()]));
  const day = new Date().toLocaleDateString('en-CA'), L = host ? tail(SPD + '/' + host + '/fuzz.log', 600) : [];
  const raids = L.filter(l => l.startsWith(day) && / raid \d+ /.test(l));
  // 10-26: the status file's own epoch first (live.txt says epoch=0 while the spare PC is paused, so the VM takes the tests back)
  const v = { host, seenEpoch: +st.epoch || +live.epoch || 0, game: st.game || '', testRun: st.test_run || '', robots: +st.robots || 0, ramFree: st.ram_free_gb || '', pushOk: st.push_ok || '', mode: st.mode || '',
    raidsToday: raids.length, problemsToday: raids.reduce((s, l) => s + +((/ problems=(\d+)/.exec(l) || [0, 0])[1]), 0),
    lastRaids: raids.slice(-4), lastEnd: L.filter(l => /FUZZ END/.test(l)).slice(-1)[0] || '' };
  // 10-22: the main PC's idle runs (tools/spare/spare-runner.ps1 IDLE MODE on JUL26): tests only while he is away
  const mraw = git(['cat-file', 'blob', 'refs/spare-import/spare-results:spare/JUL26/status.txt']);
  if (mraw) {
    const ms = Object.fromEntries([...mraw.replace(/\r?\n/g, ' ').matchAll(/(?:^|\s)(\w+)=(.*?)(?=\s+\w+=|\s*$)/g)].map(m => [m[1], m[2].trim()]));
    const ML = tail(SPD + '/JUL26/fuzz.log', 600), mr = ML.filter(l => l.startsWith(day) && / raid \d+ /.test(l));
    // 10-26, his "why don't you show detailed info on each PC": memory, mode, whether it can see the spare PC, why its robots last stopped
    v.mainPc = { seenEpoch: +ms.epoch || 0, testRun: ms.test_run || '', robots: +ms.robots || 0, game: ms.game || '', raidsToday: mr.length,
      problemsToday: mr.reduce((s, l) => s + +((/ problems=(\d+)/.exec(l) || [0, 0])[1]), 0),
      ramFree: ms.ram_free_gb || '', mode: ms.mode || '', spareSeen: ms.spare_pc || '', lastEnd: ML.filter(l => /FUZZ END/.test(l)).slice(-1)[0] || '',
      // 10-27 his "make sure we are always getting game telemetry back from the main pc": the 8799 report receiver, up or down, and the newest report and note
      receiver: ms.receiver8799 || '' };
  }
  spareCache = { t: Date.now(), v }; return v;
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
  // 10-27 (Dashboard Correspondent): old marks a helper that is switched off (no news for 2 days, nothing running, nothing queued),
  // so the page folds D, E and F into one line instead of showing their 10-18 and 10-19 notes as news
  const lanes = ['a', 'b', 'c', 'd', 'e', 'f', 'o'].filter(l => l < 'd' || existsSync(C + '/status-' + l + '.txt')).map(l => ({ lane: l, status: rd(C + '/status-' + l + '.txt').trim(), busy: existsSync(C + '/lane-' + l + '.lock'),
    queue: tasks.filter(f => lane(f) === l).map(f => f.replace(/\.md$/, '')) })).map(x => ({ ...x, old: !x.busy && !x.queue.length && (ageS(C + '/status-' + x.lane + '.txt') ?? 1e9) > 2 * 86400 }));
  const lockOwner = existsSync(S + '/shipq.lock') ? rd(S + '/shipq.owner').trim() : '';
  // 10-27: format-local, so a commit made in a cloud chat shows his clock time (02:54 was 22:54 here)
  const commits = git(['log', '-14', '--format=%h|%ad|%s', '--date=format-local:%m-%d %H:%M']).split('\n').filter(Boolean).map(l => l.split('|'));
  const shipsToday = git(['log', '--since=midnight', '--format=%s']).split('\n').filter(s => /^v\d+\.\d+:/.test(s)).length;
  const hb = ageS(N + '/runner.heartbeat');
  const titles = {}; (tail(S + "/shipq.log", 12).join(" ") + " " + lockOwner).replace(/cw-[A-Za-z0-9_-]+/g, k => { if (!titles[k]) { try { titles[k] = JSON.parse(rd(R + "/tools/handoff/drafts/draft-" + k + ".json").replace(/^﻿/, "")).title || ""; } catch {} } return k; });
  const st = kv(R + '/tools/handoff/stable.txt');
  // 10-20: his notes from the main PC (tools/fetch-notes.mjs, coord-01) and the spare PC (tools/spare/spare-import.mjs)
  const notes = rd(R + '/tools/handoff/notes-fetch.txt').trim().slice(0, 240), spare = rd(R + '/tools/handoff/spare-status.txt').trim().slice(0, 300);
  // 10-27: the version his main PC serves on 8802 (tools/handoff/onhispc.sh), the version on itch (the runner's itch step), the feature
  // jobs parked until 11/1 (his 10-27 "no new features until Nov 1"), and whether this page's copy reaches his desktop (the bridge)
  const op = tail(C + '/onhispc.txt', 20).reverse().map(l => /^(\d\d-\d\d \d\d:\d\d) .*\(8802 serves ([\d.]+)\)/.exec(l)).find(Boolean);
  const after = existsSync(C + '/after-nov1') ? readdirSync(C + '/after-nov1').filter(f => f.endsWith('.md')).length : 0;
  return { now: new Date().toLocaleTimeString(), ver: ver(), shipsToday, cpu, notes, spare, spareInfo: spareInfo(),
    onPc: op ? { ver: op[2], at: op[1] } : null, itch: rd(N + '/itch-ver.txt').trim(), afterNov1: after,
    link: { ok: snapOkAt > snapFailAt, okAt: snapOkAt, failAt: snapFailAt },
    stable: { version: st.version || '', at: st.at || '', address: st.address || '', frozen: existsSync(R + '/tools/handoff/stable.freeze') }, report: latestReport(), ramFree: +(os.freemem() / 2 ** 30).toFixed(1), ramTot: Math.round(os.totalmem() / 2 ** 30), cpus: os.cpus().length,
    procs, runnerAgeS: hb, lockOwner, titles, lanes, stopFile: existsSync(C + '/STOP'),
    spend: { real: !!real, today: +(real ? real.today_usd : spentToday0).toFixed(2), all: +(real ? real.month_usd : spentAll0).toFixed(2), total, share: +share.toFixed(2), daysLeft, end },
    done: existsSync(C + '/done') ? readdirSync(C + '/done').length : 0, failed: existsSync(C + '/failed') ? readdirSync(C + '/failed') : [],
    blocked: existsSync(C + '/blocked') ? readdirSync(C + '/blocked').filter(f => f.endsWith('.md')).map(f => ({ job: f.slice(0, -3), on: rd(C + '/blocked/' + f.slice(0, -3) + '.on').trim() })) : [],
    questions: tail(C + '/for-you.md', 12), plan: plan(), runs: tail(C + '/runs.log', 10), shipq: tail(S + '/shipq.log', 12),
    // 10-27: only the runner's own time-stamped lines (butler's "Use the butler status" and raw bridge JSON leaked onto the page)
    ai: ai(), nightly: tail(N + '/nightly.log', 60).filter(l => /^(\d\d-\d\d )?\d\d:\d\d /.test(l)).slice(-8), fuzz: tail(R + '/tools/handoff/fuzz/fuzz.log', 4), review: tail(C + '/review/review.log', 3), commits };
}
const PAGE = () => rd("C:/claudecode/dark raiders/tools/devdash/index.html");   // read per request, so edits show at once
const srv = http.createServer((q, s) => {
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
let snapBusy = false, snapErrAt = 0, snapSig = '', snapSent = 0, snapOkAt = 0, snapFailAt = 0;
function snapshot(d) {
  d = d || data(); d.snapAt = Date.now();
  return PAGE()
    .replace("d=await (await fetch('/api',{cache:'no-store'})).json();", 'd=window.__SNAP;')
    .replace('tick(); setInterval(tick,5000);', SNAP_TAIL)
    .replace("(every 5 seconds)", "(sent from the VM every 30 seconds)")
    .replace('href="/report"', 'href="#"')
    .replace('<script>', '<script>window.__SNAP=' + JSON.stringify(d).replace(/</g, '\u003c') + ';</script><script>');
}
function pushSnap() { try { pushSnap0(); } catch (e) { snapBusy = false; } }   // 10-27: a bad status file must not end the server
function pushSnap0() {
  if (snapBusy) return;
  // 10-25: a copy goes only when something on the page changed, or 90 s after the last one (the page warns after 120 s of silence),
  // not every 30 s regardless: while the helpers rest most copies were the same page with a new clock.
  const d = data(), sig = JSON.stringify({ ...d, now: 0, cpu: 0, ramFree: 0, runnerAgeS: 0, procs: { ...d.procs, t: 0 }, link: d.link.ok, ai: { ...d.ai, local: { ...d.ai.local, loaded: 0 } },
    plan: d.plan && { ...d.plan, ageS: 0, line: 0, perDay: 0, catchUp: 0 }, spareInfo: { ...d.spareInfo, seenEpoch: 0, mainPc: d.spareInfo.mainPc && { ...d.spareInfo.mainPc, seenEpoch: 0 } } });
  if (sig === snapSig && Date.now() - snapSent < 90e3) return;
  snapBusy = true; snapSig = sig; snapSent = Date.now();
  try { writeFileSync(SNAP_TMP, snapshot(d)); } catch (e) { snapBusy = false; return; }
  execFile(process.execPath, [R + '/tools/bridge/hostctl.mjs', 'share-put', 'name=' + SNAP_NAME, '--file', SNAP_TMP], { timeout: 20000, windowsHide: true }, (err, out, errOut) => {
    snapBusy = false;
    const ok = !err && /"ok":\s*true/.test(String(out)); if (ok) snapOkAt = Date.now(); else snapFailAt = Date.now();
    if (!ok && Date.now() - snapErrAt > 600000) {
      snapErrAt = Date.now();
      try { appendFileSync(SNAP_LOG, new Date().toISOString() + ' push failed: ' + String((err && err.message) || out || errOut).replace(/\s+/g, ' ').slice(0, 300) + '\n'); } catch {}
    }
  });
}
setTimeout(pushSnap, 3000); setInterval(pushSnap, 30000);
// 10-24, his yes to "the VM gets the extra memory whenever you are away": the main PC's minute check (tools/migrate/host-night-memory.ps1,
// MemFollow) takes memory back only as fast as the VM has it free, so every 30 s the VM tells it the time and its free memory (os.freemem is
// the available physical memory, what Hyper-V can take back).
const MEM_NAME = 'vm-memory.txt', MEM_TMP = os.tmpdir() + '/pillagers-vm-memory.txt';
let memBusy = false;
function pushMem() {
  if (memBusy) return; memBusy = true;
  try { writeFileSync(MEM_TMP, 'epoch=' + Math.floor(Date.now() / 1000) + '\nfreeMB=' + Math.floor(os.freemem() / 1048576) + '\n'); } catch (e) { memBusy = false; return; }
  execFile(process.execPath, [R + '/tools/bridge/hostctl.mjs', 'share-put', 'name=' + MEM_NAME, '--file', MEM_TMP], { timeout: 20000, windowsHide: true }, () => { memBusy = false; });
}
setTimeout(pushMem, 5000); setInterval(pushMem, 30000);
// 10-27 (Dashboard Correspondent): a change to this file takes effect by itself. Every 30 s the server looks at its own file; when it
// changed and the new copy passes node --check, it lets go of 8820, starts the new copy and exits (a broken copy is left alone, so the
// page stays up on the old code). index.html needs none of this: it is read on every request.
const SELF = R + '/tools/devdash/server.mjs', selfM = (() => { try { return statSync(SELF).mtimeMs; } catch { return 0; } })();
let selfBusy = false;
setInterval(() => {
  let m = 0; try { m = statSync(SELF).mtimeMs; } catch { return; }
  if (selfBusy || !m || m === selfM || Date.now() - m < 5000) return; selfBusy = true;   // 5 s: let an editor finish writing
  execFile(process.execPath, ['--check', SELF], { timeout: 20000, windowsHide: true }, err => {
    if (err) { selfBusy = false; try { appendFileSync(os.tmpdir() + '/pillagers-dashboard-crash.log', new Date().toISOString() + ' new server.mjs fails node --check; staying on the old copy\n'); } catch {} return; }
    srv.close(); try { srv.closeAllConnections(); } catch {}   // the listening socket goes at once; open page connections are cut
    setTimeout(() => { spawn(process.execPath, ['server.mjs'], { cwd: R + '/tools/devdash', detached: true, stdio: 'ignore', windowsHide: true }).unref(); process.exit(0); }, 500);
  });
}, 30000);
// 10-27: found dead at 19:27 with no trace, and his desktop copy stood still for over an hour. The runner (tools/nightly.sh step 10) starts
// it again within 5 minutes; a crash now leaves its reason in pillagers-dashboard-crash.log (TEMP) first.
process.on('uncaughtException', (e) => {
  try { appendFileSync(os.tmpdir() + '/pillagers-dashboard-crash.log', new Date().toISOString() + ' ' + String((e && e.stack) || e).slice(0, 2000) + '\n'); } catch {}
  process.exit(1);
});
