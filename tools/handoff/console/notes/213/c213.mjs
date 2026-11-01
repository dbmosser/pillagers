// c213.mjs PORT W H CHECKID : open a fixture tab in Chrome PORT, size the page to W x H (device metrics, dsf 1), run one check, close the tab.
const [port, W, H, V] = process.argv.slice(2);
const base = `http://127.0.0.1:${port}`;
const t = await (await fetch(`${base}/json/new?about:blank`, { method: 'PUT' })).json();
const ws = new WebSocket(t.webSocketDebuggerUrl);
let id = 0; const pend = {};
const call = (method, params = {}) => new Promise(r => { const i = ++id; pend[i] = r; ws.send(JSON.stringify({ id: i, method, params })); });
ws.onmessage = e => { const m = JSON.parse(e.data); if (m.id && pend[m.id]) { pend[m.id](m); delete pend[m.id]; } };
await new Promise(r => ws.onopen = r);
const sleep = ms => new Promise(r => setTimeout(r, ms));
try {
  if (+W > 0) await call('Emulation.setDeviceMetricsOverride', { width: +W, height: +H, deviceScaleFactor: 1, mobile: false, screenWidth: +W, screenHeight: +H });
  await call('Page.navigate', { url: 'http://localhost:8806/fixture.html?kz213=1' });
  await sleep(20000);
  const expr = `(function(){ var t=__REGRESS.find(function(x){return x.v==='${V}'}); if(!t) return 'NO CHECK'; var r; try{ __runPrep(); __topClear(); r=t.run(); }catch(e){ r='threw '+e; } return 'window '+innerWidth+'x'+innerHeight+' screen '+screen.width+'x'+screen.height+' dpr '+devicePixelRatio+' | ${V}: '+(r?String(r).slice(0,400):'PASS'); })()`;
  const res = await call('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true });
  console.log(res.result?.result?.value ?? JSON.stringify(res).slice(0, 400));
} finally {
  ws.close(); await fetch(`${base}/json/close/${t.id}`);
}
