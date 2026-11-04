// One-off, no game file changed. Does the live robot's frame rate change how long the slow checks take? Runs a fixed list of slow checks over and over in a private hidden browser
// (tools/cdp.ps1, as a full run opens one), while the robot's 2-window raids alternate between no cap and the game's own 30 fps cap, in memory. A check that spans a change of cap is
// marked mixed. The robot's 3-minute hourly restart gives a third reading with no robot at all. Stops at once for a gate job, a pause or a full run, then puts the robot back to 0,
// closes its browser and deletes its profile.
import fs from 'node:fs';
import { execFileSync } from 'node:child_process';
const MINUTES = +(process.argv[2] ?? 60), PORT = 9345, CAP = 30, LIST = [75, 23, 355, 65, 5, 66, 214, 69, 68, 448, 150];
const here = new URL('./', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1'), OUT = here + 'timing/ab/';
fs.mkdirSync(OUT, { recursive: true });
const REPO = 'C:/claudecode/dark raiders', ST = 'C:/PillagersSpare/state.txt', LOG = 'C:/PillagersSpare/runner.log', FZ = 'C:/PillagersSpare/out/fuzz/fuzz.log';
const PROFILE = process.env.TEMP + '\\pillagers-cdp' + PORT, end = Date.now() + MINUTES * 60e3;
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
// epoch counts every change of what the robot is doing, so a check that starts and ends on the same epoch saw one state throughout
let arm = 0, epoch = 0, robot = true, fzPos = fs.statSync(FZ).size, ticking = false, closing = false;
const robotPages = async () => (await list(9331)).filter((x) => x.type === 'page' && /fixture-soak/.test(x.url));
const setCap = async (c) => { for (const p of await robotPages()) await ev(p, `(function(){ try{ return window.__gx('CFG.fpsCap=${c}'); }catch(e){ return null; } })()`); };
const closeAll = () => {
  cdp('-Close');
  try { execFileSync('powershell', ['-NoProfile', '-Command', `Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" | Where-Object { $_.CommandLine -match 'remote-debugging-port=${PORT}(\\s|$)' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }`], { timeout: 60000, windowsHide: true }); } catch {}
};
const finish = async (why) => {
  if (closing) return; closing = true; clearInterval(timer); closeAll();
  try { execFileSync('powershell', ['-NoProfile', '-Command', `Start-Sleep -Seconds 2; Remove-Item -LiteralPath '${PROFILE}' -Recurse -Force -ErrorAction SilentlyContinue`], { timeout: 60000, windowsHide: true }); } catch {}
  await setCap(0); console.log(why); process.exit(0);
};
const tick = async () => {
  if (ticking || closing) return; ticking = true;
  try {
    const w = busy(); if (w) return await finish(`stopped: ${w}`);
    if (Date.now() > end) return await finish(`finished ${MINUTES} minutes`);
    const sz = fs.statSync(FZ).size; if (sz < fzPos) fzPos = 0;
    if (sz > fzPos) {
      const fd = fs.openSync(FZ, 'r'), b = Buffer.alloc(sz - fzPos); fs.readSync(fd, b, 0, b.length, fzPos); fs.closeSync(fd); fzPos = sz;
      for (const l of b.toString('utf8').split(/\r?\n/)) {
        if (/FUZZ END|FUZZ ABORT/.test(l)) { robot = false; epoch++; note('raids.jsonl', { line: l.slice(0, 120) }); continue; }
        if (/FUZZ START/.test(l)) { robot = true; epoch++; note('raids.jsonl', { line: l.slice(0, 120) }); continue; }
        const m = / raid (\d+) (\w+) .* sec=(\d+) end=(\S+) problems=(\d+) .*events=(\d+)/.exec(l); if (!m) continue;
        note('raids.jsonl', { arm, epoch, mode: m[2], sec: +m[3], end: m[4], problems: +m[5], events: +m[6], gfx: (/ gfx=(\S+)/.exec(l) || [])[1], gfx2: (/ gfx2=(\S+)/.exec(l) || [])[1] });
        if (m[2] === 'demo2p') { epoch++; arm = arm ? 0 : CAP; }
      }
    }
    await setCap(arm);
  } finally { ticking = false; }
};
const timer = setInterval(tick, 5000);
const b0 = busy(); if (b0) { clearInterval(timer); console.log('not started:', b0); process.exit(0); }
const run1 = (i) => `(function(){ var t=__REGRESS[${i}], s, r=null; __topClear(); __ctxHeal(); __pilLive(); s=performance.now(); try{ r=t.run(); }catch(e){ r='threw'; } return JSON.stringify({ms:Math.round(performance.now()-s),v:t.v,r:r?String(r).slice(0,60):''}); })()`;
for (let loop = 0; ; loop++) {
  if (loop) cdp('-Close');
  cdp('-Start', '-Profile', PROFILE);
  const tag = `slice${loop}=1`;
  await fetch(`http://127.0.0.1:${PORT}/json/new?${encodeURI(`http://localhost:8806/fxcorpus.html?${tag}`)}`, { method: 'PUT', signal: AbortSignal.timeout(10000) }).catch(() => {});
  await sleep(25000);
  const p = (await list(PORT)).find((x) => x.type === 'page' && x.url.includes(tag));
  if (!p || !(await ev(p, `(function(){ __runPrep(); return 'ok'; })()`, 60000))) { await finish(`loop ${loop} did not start`); break; }
  // a different starting point each loop, so no check is always the first after a fresh page
  for (let k = 0; k < LIST.length; k++) {
    const i = LIST[(k + loop) % LIST.length], e0 = epoch, a0 = arm, r0 = robot;
    const v = await ev(p, run1(i), 900000);
    if (!v) { await finish(`check ${i} gave no answer in 15 minutes`); break; }
    const o = JSON.parse(v);
    note('checks.jsonl', { loop, k, i, ms: o.ms, v: o.v, r: o.r, arm: r0 ? a0 : 'none', same: e0 === epoch && r0 === robot });
  }
}
