// One-off, no game file changed. The slow-check test found the robot's frame rate barely changes the long simulation checks. This one asks the same of the short checks, most of which
// draw: whole slices run in a private hidden browser, each slice once with the robot uncapped and once at the game's own 30 fps cap, order swapped every round. Marks any slice that
// spans the robot's hourly restart. Stops at once for a gate job, a pause or a full run, then puts the robot back to 0, closes its browser and deletes its profile.
import fs from 'node:fs';
import { execFileSync } from 'node:child_process';
const MINUTES = +(process.argv[2] ?? 38), PORT = 9345, CAP = 30, SLICES = [600, 480, 360], STEP = 120;
const here = new URL('./', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1'), OUT = here + 'timing/abs/';
fs.mkdirSync(OUT, { recursive: true });
const REPO = 'C:/claudecode/dark raiders', ST = 'C:/PillagersSpare/state.txt', LOG = 'C:/PillagersSpare/runner.log', FZ = 'C:/PillagersSpare/out/fuzz/fuzz.log';
const PROFILE = process.env.TEMP + '\\pillagers-cdp' + PORT, end = Date.now() + MINUTES * 60e3;
const log0 = fs.readFileSync(LOG, 'utf8').split(/\r?\n/).length, sleep = (ms) => new Promise((r) => setTimeout(r, ms));
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
let arm = 0, restarts = 0, fzPos = fs.statSync(FZ).size, closing = false;
const robotPages = async () => (await list(9331)).filter((x) => x.type === 'page' && /fixture-soak/.test(x.url));
const setCap = async (c) => { for (const p of await robotPages()) await ev(p, `(function(){ try{ return window.__gx('CFG.fpsCap=${c}'); }catch(e){ return null; } })()`); };
const finish = async (why) => {
  if (closing) return; closing = true; clearInterval(timer); cdp('-Close');
  try { execFileSync('powershell', ['-NoProfile', '-Command', `Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object { $_.CommandLine -match 'remote-debugging-port=${PORT}(\\s|$)' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }; Start-Sleep -Seconds 2; Remove-Item -LiteralPath '${PROFILE}' -Recurse -Force -ErrorAction SilentlyContinue`], { timeout: 60000, windowsHide: true }); } catch {}
  await setCap(0); console.log(why); process.exit(0);
};
let ticking = false;
const timer = setInterval(async () => {
  if (ticking || closing) return; ticking = true;
  try {
    const w = busy(); if (w) return await finish(`stopped: ${w}`);
    const sz = fs.statSync(FZ).size; if (sz < fzPos) fzPos = 0;
    if (sz > fzPos) {
      const fd = fs.openSync(FZ, 'r'), b = Buffer.alloc(sz - fzPos); fs.readSync(fd, b, 0, b.length, fzPos); fs.closeSync(fd); fzPos = sz;
      const s = b.toString('utf8'); if (/FUZZ (END|START|ABORT)/.test(s)) restarts++;
      for (const l of s.split(/\r?\n/)) if (/ raid \d+ /.test(l)) fs.appendFileSync(OUT + 'raids.txt', l.slice(0, 260) + '\n');
    }
    await setCap(arm);
  } finally { ticking = false; }
}, 5000);
const b0 = busy(); if (b0) { clearInterval(timer); console.log('not started:', b0); process.exit(0); }
const wrap = (a, b) => `(function(){ window.__T=[]; for(var i=${a};i<Math.min(${b},__REGRESS.length);i++){ (function(t,i){ var r=t.run; t.run=function(){ var s=performance.now(); try{ return r.apply(this,arguments); }finally{ window.__T.push([i,Math.round(performance.now()-s),String(t.v),String(t.what).slice(0,70)]); } }; })(__REGRESS[i],i); } return __regressBg(${a},${b}); })()`;
const one = async (a, c, round) => {
  arm = c; await setCap(c); await sleep(10000);
  cdp('-Close'); cdp('-Start', '-Profile', PROFILE);
  const tag = `slice${a}=1`, t0 = Date.now(), r0 = restarts;
  await fetch(`http://127.0.0.1:${PORT}/json/new?${encodeURI(`http://localhost:8806/fxcorpus.html?${tag}`)}`, { method: 'PUT', signal: AbortSignal.timeout(10000) }).catch(() => {});
  await sleep(25000);
  const page = async () => (await list(PORT)).find((x) => x.type === 'page' && x.url.includes(tag));
  let p = await page();
  if (!p || !(await ev(p, wrap(a, a + STEP), 30000))) return finish(`slice ${a} did not start`);
  for (let i = 0; ; i++) {
    await sleep(5000);
    p = await page();
    const v = p ? await ev(p, `(function(){ var P=window.__PROG; return P&&P.finished?JSON.stringify({s:P.res.summary,T:window.__T}):''; })()`, 150000) : null;
    if (v) {
      const o = JSON.parse(v), inC = o.T.reduce((x, y) => x + y[1], 0);
      fs.appendFileSync(OUT + 'slices.jsonl', JSON.stringify({ t: new Date().toTimeString().slice(0, 8), round, a, arm: c, wall: Math.round((Date.now() - t0) / 1000), inChecks: Math.round(inC / 1000), summary: o.s, clean: r0 === restarts, T: o.T }) + '\n');
      return;
    }
    if (i > 200) return finish(`slice ${a} over 17 minutes`);
  }
};
for (let round = 0; Date.now() < end; round++) {
  for (const a of SLICES) {
    if (Date.now() >= end) break;
    for (const c of round % 2 ? [CAP, 0] : [0, CAP]) await one(a, c, round);
  }
}
await finish(`finished ${MINUTES} minutes`);
