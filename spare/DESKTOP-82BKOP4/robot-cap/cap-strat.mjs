// A second trial on the live robot while no full run is on, this time split by how many robot windows are open: the game's own frame cap at off, 60 and 30, in turns.
// It only sets CFG.fpsCap in the robot's open pages, in memory, and puts it back to 0 at the end. It stops, and puts it back, if a full run starts or someone is at the PC. It waits out a gate job.
import os from 'node:os';
import fs from 'node:fs';
const MIN = Number(process.argv[2] || 45), TURN = 60, SETTLE = 10, CAPS = [0, 60, 30];
const LOG = 'C:/PillagersSpare/runner.log', ST = 'C:/PillagersSpare/state.txt';
const lines0 = fs.readFileSync(LOG, 'utf8').split(/\r?\n/).length;
const stopWhy = () => {
  if (/^pause_why=./m.test(fs.readFileSync(ST, 'utf8'))) return 'pause';
  const fresh = fs.readFileSync(LOG, 'utf8').split(/\r?\n/).slice(lines0).join('\n');
  if (/full test run started/.test(fresh)) return 'a full run started';
  if (/paused:/.test(fresh)) return 'someone at the PC';
  return '';
};
const gate = () => /^gate_id=./m.test(fs.readFileSync(ST, 'utf8'));
const pages = async () => { try { const L = await (await fetch('http://127.0.0.1:9331/json/list', { signal: AbortSignal.timeout(4000) })).json(); return L.filter((x) => x.type === 'page' && /fixture-soak/.test(x.url)); } catch { return []; } };
const ev = (p, expr) => new Promise((res) => {
  let w; try { w = new WebSocket(p.webSocketDebuggerUrl); } catch { return res(null); }
  const t = setTimeout(() => { try { w.close(); } catch {} res(null); }, 4000);
  w.onopen = () => w.send(JSON.stringify({ id: 1, method: 'Runtime.evaluate', params: { expression: expr, returnByValue: true } }));
  w.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id === 1) { clearTimeout(t); try { w.close(); } catch {} res(m.result?.result?.value ?? null); } };
  w.onerror = () => { clearTimeout(t); res(null); };
});
const setCap = async (c) => {
  const P = await pages(); let n = 0, raid = false;
  for (const p of P) {
    const v = await ev(p, `(function(){ try{ return window.__gx('CFG.fpsCap=${c}; state'); }catch(e){ return null; } })()`);
    if (v) { n++; if (!/p2=1/.test(p.url) && v === 'raid') raid = true; }
  }
  return { n, raid };
};
const busyNow = () => { let idle = 0, tot = 0; for (const c of os.cpus()) { for (const k of Object.keys(c.times)) tot += c.times[k]; idle += c.times.idle; } return { idle, tot }; };
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const B = {}; const end = Date.now() + MIN * 60000; let why = '', turn = 0;
try {
  while (Date.now() < end && !why) {
    const cap = CAPS[turn++ % CAPS.length], t0 = Date.now();
    await setCap(cap);
    let a = busyNow();
    while (Date.now() - t0 < TURN * 1000) {
      await sleep(5000);
      why = stopWhy(); if (why) break;
      const s = await setCap(cap), b = busyNow(), busy = 100 * (1 - (b.idle - a.idle) / (b.tot - a.tot)); a = b;
      if (Date.now() - t0 < SETTLE * 1000 || gate() || !s.raid || !s.n) continue;
      const k = s.n + ' window' + (s.n > 1 ? 's' : '') + ', cap ' + (cap || 'off'); (B[k] ||= []).push(busy);
    }
  }
} finally { const back = await setCap(0); console.log('put back to 0 on', back.n, 'pages'); }
if (why) console.log('stopped early:', why);
const q = (a, p) => { a = [...a].sort((x, y) => x - y); return a[Math.floor(p * (a.length - 1))]; };
for (const k of Object.keys(B).sort()) { const a = B[k]; console.log(k.padEnd(22), 'readings', String(a.length).padStart(4), 'mean', (a.reduce((x, y) => x + y, 0) / a.length).toFixed(1).padStart(5), 'q1', q(a, .25).toFixed(1).padStart(5), 'median', q(a, .5).toFixed(1).padStart(5), 'q3', q(a, .75).toFixed(1).padStart(5)); }
