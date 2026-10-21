// coord-06 debug: load the t2 top page through Fetch interception and list targets and frame state (port 9371 only).
import fs from 'node:fs';
const sleep = ms => new Promise(r => setTimeout(r, ms));
const ver = await (await fetch('http://127.0.0.1:9371/json/version')).json();
const ws = new WebSocket(ver.webSocketDebuggerUrl);
await new Promise(r => ws.onopen = r);
let nid = 0; const pend = new Map(); const evs = [];
ws.onmessage = e => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { const p = pend.get(m.id); pend.delete(m.id); p(m); } else evs.forEach(f => f(m)); };
const send = (method, params = {}, sessionId) => new Promise(res => { const id = ++nid; pend.set(id, res); ws.send(JSON.stringify({ id, method, params, sessionId })); });
const html = fs.readFileSync(new URL('./top2.html', import.meta.url));
const { result: { targetId } } = await send('Target.createTarget', { url: 'about:blank' });
const { result: { sessionId: T } } = await send('Target.attachToTarget', { targetId, flatten: true });
const log = [];
evs.push(async m => { if (m.method === 'Fetch.requestPaused') { log.push('paused ' + m.params.request.url); await send('Fetch.fulfillRequest', { requestId: m.params.requestId, responseCode: 200, responseHeaders: [{ name: 'Content-Type', value: 'text/html; charset=utf-8' }], body: html.toString('base64') }, T); } else if (m.method === 'Runtime.consoleAPICalled' || m.method === 'Runtime.exceptionThrown' || m.method === 'Log.entryAdded') log.push(JSON.stringify(m.params).slice(0, 300)); });
await send('Runtime.enable', {}, T); await send('Log.enable', {}, T);
await send('Fetch.enable', { patterns: [{ urlPattern: 'http://127.0.0.1:8871/*' }] }, T);
console.log(JSON.stringify(await send('Page.navigate', { url: 'http://127.0.0.1:8871/top2.html?run=dbg&sb=none&feat=plain&popmode=none' }, T)));
await sleep(3000);
const r = await send('Runtime.evaluate', { expression: 'JSON.stringify({src:document.querySelector("iframe")&&document.querySelector("iframe").src, rs:document.readyState, body:document.body?document.body.innerHTML.slice(0,300):null})', returnByValue: true }, T);
console.log(JSON.stringify(r.result));
const tg = await send('Target.getTargets');
console.log(JSON.stringify(tg.result.targetInfos.map(t => [t.type, t.url.slice(0, 120)])));
const fr = tg.result.targetInfos.find(t => t.type === 'iframe');
if (fr) {
  const a = await send('Target.attachToTarget', { targetId: fr.targetId, flatten: true }); const F = a.result.sessionId;
  const e = await send('Runtime.evaluate', { expression: 'JSON.stringify({rs:document.readyState,S:typeof S!=="undefined"?S:null,html:document.body.innerText.slice(0,500)})', returnByValue: true }, F);
  console.log('FRAME', JSON.stringify(e.result || e.error));
  const e2 = await send('Runtime.evaluate', { expression: '__ask("state").then(JSON.stringify)', returnByValue: true, awaitPromise: true }, T);
  console.log('ASK', JSON.stringify(e2.result || e2.error));
}
console.log(log.join('\n'));
await send('Target.closeTarget', { targetId });
process.exit(0);
