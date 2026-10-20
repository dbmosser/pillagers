// 47-check-demo-link-offline: times the 2 player arcade demo link. usage: node 47-offline-test.mjs offline|control
import http from 'node:http'; import fs from 'node:fs'; import { spawn } from 'node:child_process';
const mode = process.argv[2] || 'offline', HP = 8871, CP = 9351;
const GAME = 'C:/claudecode/dark raiders/dark_raiders.html';
const srv = http.createServer((q, r) => { r.setHeader('content-type', 'text/html'); r.end(fs.readFileSync(GAME)); }).listen(HP, '127.0.0.1');
const args = ['--headless=new', '--window-size=1920,1080', '--remote-debugging-port=' + CP, '--user-data-dir=' + process.env.TEMP + '\\p47-' + mode,
  '--no-first-run', '--disable-background-timer-throttling', '--disable-renderer-backgrounding', '--disable-backgrounding-occluded-windows', '--autoplay-policy=no-user-gesture-required'];
if (mode === 'offline') args.push('--host-resolver-rules=MAP * ~NOTFOUND , EXCLUDE localhost , EXCLUDE 127.0.0.1');
args.push('about:blank');
const ch = spawn('C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe', args, { stdio: 'ignore' });
const sleep = ms => new Promise(r => setTimeout(r, ms));
const J = async p => (await fetch('http://127.0.0.1:' + CP + p, { method: p.includes('/new') ? 'PUT' : 'GET' })).json();
async function conn(t) {
  const ws = new WebSocket(t.webSocketDebuggerUrl); await new Promise(r => ws.onopen = r);
  let id = 0; const pend = {};
  ws.onmessage = e => { const m = JSON.parse(e.data); if (m.id && pend[m.id]) { pend[m.id](m); delete pend[m.id]; } };
  return { ev: (expr, gesture) => new Promise(res => { const i = ++id; pend[i] = m => res(m.result && m.result.result ? m.result.result.value : m); ws.send(JSON.stringify({ id: i, method: 'Runtime.evaluate', params: { expression: expr, returnByValue: true, awaitPromise: true, userGesture: !!gesture } })); }), ws };
}
try {
  for (let i = 0; i < 40; i++) { try { await J('/json/version'); break; } catch { await sleep(250); } }
  const url = 'http://localhost:' + HP + '/dark_raiders.html';
  await J('/json/new?' + url); await sleep(6000);
  let tabs = await J('/json'); const t1 = tabs.find(t => t.type === 'page' && t.url.includes(HP));
  const a = await conn(t1);
  console.log('mode', mode, 'ver', await a.ev('VER'), 'ice', await a.ev('JSON.stringify(NET_ICE)'));
  const t0 = Date.now();
  console.log('pick', await a.ev('arcadePick()', true));
  let linked = -1, last = '';
  for (let i = 0; i < 400; i++) {
    const s = await a.ev('JSON.stringify({n:netInCount(),st:NET.status,err:NET.err,arc:(typeof ARCADE==="object"&&ARCADE)?ARCADE.on:null})');
    if (s !== last) { console.log(((Date.now() - t0) / 1000).toFixed(1) + 's', s); last = s; }
    if (JSON.parse(s).n >= 1) { linked = (Date.now() - t0) / 1000; break; }
    await sleep(250);
  }
  console.log('LINKED_SECONDS', linked);
  tabs = await J('/json'); console.log('tabs', tabs.filter(t => t.type === 'page').map(t => t.url.slice(0, 90)));
  if (process.argv[3] === 'raid' && linked > 0) {
    await sleep(8000);
    console.log('state', await a.ev('JSON.stringify({g:typeof G==="object"&&G?{act:G.active,raid:!!G.raid}:null,arc:ARCADE&&ARCADE.on,n:netInCount()})'));
  }
} catch (e) { console.log('ERR', e.message); }
finally { try { ch.kill(); } catch {} srv.close(); setTimeout(() => process.exit(0), 500); }
