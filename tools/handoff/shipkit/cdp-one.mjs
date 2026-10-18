// node cdp-one.mjs PORT URL FILE [TIMEOUT_S=60] : open URL in a new front tab, wait for __REGRESS, evaluate the expression in FILE;
// if it does not answer in time, pause and print where the JavaScript is (5 samples). Closes its tab at the end.
import fs from 'fs';
const [port, url, file, toArg] = process.argv.slice(2);
const TO = +(toArg || 60) * 1000, base = `http://127.0.0.1:${port}`, expr = fs.readFileSync(file, 'utf8');
const tab = await (await fetch(`${base}/json/new?${url}`, { method: 'PUT' })).json();
await fetch(`${base}/json/activate/${tab.id}`);
const ws = new WebSocket(tab.webSocketDebuggerUrl);
let id = 0, samples = 0; const wait = {};
const send = (method, params = {}) => new Promise(res => { const i = ++id; wait[i] = res; ws.send(JSON.stringify({ id: i, method, params })); });
const finish = async code => { try { await fetch(`${base}/json/close/${tab.id}`); } catch {} process.exit(code); };
ws.onmessage = ev => { const m = JSON.parse(ev.data);
  if (m.id && wait[m.id]) { wait[m.id](m); delete wait[m.id]; }
  if (m.method === 'Debugger.paused') { samples++; console.log('SAMPLE ' + samples);
    for (const f of m.params.callFrames.slice(0, 10)) console.log('  ' + (f.functionName || '(anon)') + '  line ' + (f.location.lineNumber + 1) + ' col ' + f.location.columnNumber);
    send('Debugger.resume'); if (samples >= 5) finish(3); else setTimeout(() => send('Debugger.pause'), 3000); } };
await new Promise(r => ws.onopen = r);
await send('Runtime.enable'); await send('Debugger.enable');
for (let i = 0; i < 120; i++) { const r = await send('Runtime.evaluate', { expression: "String(typeof __REGRESS!=='undefined')", returnByValue: true });
  if (r.result && r.result.result && r.result.result.value === 'true') break; await new Promise(z => setTimeout(z, 500)); }
const t0 = Date.now();
const timer = setTimeout(() => { console.log(`NO ANSWER after ${TO / 1000} s; pausing`); send('Debugger.pause'); setTimeout(() => { console.log('NO PAUSE'); finish(4); }, 20000); }, TO);
const r = await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true });
clearTimeout(timer);
console.log(`DONE in ${Date.now() - t0} ms: ` + JSON.stringify(r.result && (r.result.result.value ?? r.result.exceptionDetails ?? r.result.result)).slice(0, 600));
finish(0);
