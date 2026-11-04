// One-off, no game file changed. Times each check of slices [A,B) in a private hidden browser opened the way a full run opens one (tools/cdp.ps1, a fresh browser per slice, the same
// page), on its own port and profile. Meanwhile the live robot's 2-window raids alternate between no cap and the game's own 30 fps cap, in memory, so each raid line can be compared
// under the same load. Stops at once for a gate job, a pause or a full run, then puts the robot back to 0, closes its browser and deletes its profile.
import fs from 'node:fs';
import os from 'node:os';
import { execFileSync } from 'node:child_process';
const A0 = +(process.argv[2] ?? 0), B0 = +(process.argv[3] ?? 720), STEP = 120, PORT = 9345, CAP = 30;
const here = new URL('./', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1'), OUT = here + 'timing/';
fs.mkdirSync(OUT, { recursive: true });
const REPO = 'C:/claudecode/dark raiders', ST = 'C:/PillagersSpare/state.txt', LOG = 'C:/PillagersSpare/runner.log', FZ = 'C:/PillagersSpare/out/fuzz/fuzz.log';
const PROFILE = process.env.TEMP + '\\pillagers-cdp' + PORT;
const log0 = fs.readFileSync(LOG, 'utf8').split(/\r?\n/).length, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const note = (f, o) => fs.appendFileSync(OUT + f, JSON.stringify({ t: new Date().toTimeString().slice(0, 8), ...o }) + '\n');
const busy = () => {
  const s = fs.readFileSync(ST, 'utf8');
  if (/^gate_id=./m.test(s)) return 'gate job';
  if (/^pause_why=./m.test(s)) return 'pause';
  const n = fs.readFileSync(LOG, 'utf8').split(/\r?\n/).slice(log0).join('\n');
  return /full test run started|gate job \S+ started|paused:/.test(n) ? 'runner event' : '';
};
const cdp = (...a) => { try { return execFileSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', 'tools/cdp.ps1', '-Port', String(PORT), ...a], { cwd: REPO, encoding: 'utf8', timeout: 60000, windowsHide: true }); } catch (e) { return String(e.message).slice(0, 200); } };
const list = async (port) => { try { return await (await fetch(`http://127.0.0.1:${port}/json/list`, { signal: AbortSignal.timeout(4000) })).json(); } catch { return []; } };
const ev = (p, expr, ms = 4000) => new Promise((res) => {
  let w; try { w = new WebSocket(p.webSocketDebuggerUrl); } catch { return res(null); }
  const t = setTimeout(() => { try { w.close(); } catch {} res(null); }, ms);
  w.onopen = () => w.send(JSON.stringify({ id: 1, method: 'Runtime.evaluate', params: { expression: expr, returnByValue: true } }));
  w.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id === 1) { clearTimeout(t); try { w.close(); } catch {} res(m.result?.result?.value ?? null); } };
  w.onerror = () => { clearTimeout(t); res(null); };
});
// the robot: 0 until the first 2-window raid under load has ended, then CAP and 0 in turn, one 2-window raid each
let arm = 0, flips = 0, fzPos = fs.statSync(FZ).size, prev = os.cpus(), ticking = false;
const robotPages = async () => (await list(9331)).filter((x) => x.type === 'page' && /fixture-soak/.test(x.url));
const setCap = async (c) => { for (const p of await robotPages()) await ev(p, `(function(){ try{ return window.__gx('CFG.fpsCap=${c}'); }catch(e){ return null; } })()`); };
const tick = async () => {
  if (ticking) return; ticking = true;
  try {
    const sz = fs.statSync(FZ).size; if (sz < fzPos) fzPos = 0;
    if (sz > fzPos) {
      const fd = fs.openSync(FZ, 'r'), b = Buffer.alloc(sz - fzPos); fs.readSync(fd, b, 0, b.length, fzPos); fs.closeSync(fd); fzPos = sz;
      for (const l of b.toString('utf8').split(/\r?\n/)) {
        const m = / raid (\d+) (\w+) .* sec=(\d+) end=(\S+) problems=(\d+) .*events=(\d+)/.exec(l); if (!m) { if (/FUZZ (START|END|ABORT)/.test(l)) note('raids.jsonl', { line: l.slice(0, 120) }); continue; }
        note('raids.jsonl', { arm, flips, mode: m[2], sec: +m[3], end: m[4], problems: +m[5], events: +m[6], gfx: (/ gfx=(\S+)/.exec(l) || [])[1], gfx2: (/ gfx2=(\S+)/.exec(l) || [])[1] });
        if (m[2] === 'demo2p') { flips++; arm = arm ? 0 : CAP; }
      }
    }
    await setCap(arm);
    const c = os.cpus(); let idle = 0, all = 0; c.forEach((x, i) => { const a = x.times, z = prev[i].times, s = (o) => o.user + o.nice + o.sys + o.idle + o.irq; idle += a.idle - z.idle; all += s(a) - s(z); }); prev = c;
    note('busy.jsonl', { arm, busy: all ? Math.round(1000 * (1 - idle / all)) / 10 : null });
  } finally { ticking = false; }
};
const timer = setInterval(tick, 5000);
const closeAll = () => {
  clearInterval(timer); cdp('-Close');
  try { execFileSync('powershell', ['-NoProfile', '-Command', `Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object { $_.CommandLine -match 'remote-debugging-port=${PORT}(\\s|$)' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }; Start-Sleep -Seconds 2; Remove-Item -LiteralPath '${PROFILE}' -Recurse -Force -ErrorAction SilentlyContinue`], { timeout: 60000, windowsHide: true }); } catch {}
};
const finish = async (why) => { closeAll(); await setCap(0); console.log(why); process.exit(0); };
const b0 = busy(); if (b0) { clearInterval(timer); console.log('not started:', b0); process.exit(0); }
const wrap = (a, b) => `(function(){ window.__T=[]; for(var i=${a};i<Math.min(${b},__REGRESS.length);i++){ (function(t,i){ var r=t.run; t.run=function(){ var s=performance.now(); try{ return r.apply(this,arguments); }finally{ window.__T.push([i,Math.round(performance.now()-s),String(t.v),String(t.what).slice(0,90)]); } }; })(__REGRESS[i],i); } return __regressBg(${a},${b}); })()`;
const end = Date.now() + 4 * 3600e3;
for (let a = A0; a < B0; a += STEP) {
  const b = Math.min(a + STEP, B0), t0 = Date.now(), tag = `slice${a}=1`;
  if (a > A0) cdp('-Close');
  cdp('-Start', '-Profile', PROFILE);
  await fetch(`http://127.0.0.1:${PORT}/json/new?${encodeURI(`http://localhost:8806/fxcorpus.html?${tag}`)}`, { method: 'PUT', signal: AbortSignal.timeout(10000) }).catch(() => {});
  for (let i = 0; i < 25; i++) { await sleep(1000); const w = busy(); if (w) await finish(`stopped before slice ${a}: ${w}`); }
  const page = async () => (await list(PORT)).find((x) => x.type === 'page' && x.url.includes(tag));
  let p = await page();
  const started = p ? await ev(p, wrap(a, b), 30000) : null;
  if (!started) await finish(`slice ${a} did not start`);
  let last = -1, tMoved = Date.now(), done = false;
  while (!done) {
    await sleep(5000);
    const w = busy(); if (w) await finish(`stopped in slice ${a}: ${w}`);
    if (Date.now() > end) await finish(`time limit in slice ${a}`);
    p = await page();
    const v = p ? await ev(p, `(function(){ var P=window.__PROG; return P?JSON.stringify({d:P.done,f:!!P.finished}):null; })()`, 150000) : null;
    if (v) { const o = JSON.parse(v); if (o.f) done = true; if (o.d !== last) { last = o.d; tMoved = Date.now(); } }
    if (Date.now() - tMoved > 960000) await finish(`slice ${a} made no progress for 16 minutes at ${last}`);
  }
  const r = await ev(p, `JSON.stringify({s:__PROG.res.summary,f:__PROG.res.fail.map(function(x){ return String(x).slice(0,160); }),sk:__PROG.res.skipped.length,T:window.__T})`, 150000);
  const o = r ? JSON.parse(r) : {};
  fs.appendFileSync(OUT + 'slices.jsonl', JSON.stringify({ a, b, sec: Math.round((Date.now() - t0) / 1000), summary: o.s, fail: o.f, skipped: o.sk, T: o.T }) + '\n');
  note('progress.jsonl', { a, sec: Math.round((Date.now() - t0) / 1000), summary: o.s });
}
await finish(`finished [${A0},${B0})`);
