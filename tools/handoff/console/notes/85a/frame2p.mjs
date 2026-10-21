// 85a frame2p: the REAL cross-site frame test of couch mode (cw-p2bridge v33.59, cw-p2marks v33.61), from coord-06's c6drive.mjs t4 and top2.html.
// A throwaway node server on 127.0.0.1:8871 serves ONLY the top page (itch's allow list, no sandbox) and closes at exit; the frame is
// the game on localhost, which is cross-site to 127.0.0.1 the way itch.io is to itch.zone. Talks to one test Chrome only.
// usage: node frame2p.mjs framed|control      env: C6_CDP (chrome debug port, lane a = 9361), C6_GAME_BASE (default http://localhost:8809/),
//        C6_GAME (page, default fixture.html)
// framed: a REAL CDP mouse click on 2 PLAYER CO-OP inside the frame; waits for both rosters = 2 (5 s goal, 20 s limit); a sound split
//        change in one window must show in the other; closing player 2 must leave a not-linked or p2 pad lost line.
// control: the same page at top level (BroadcastChannel path, the one the party uses): must still link.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import http from 'node:http';
const DIR = path.dirname(fileURLToPath(import.meta.url));
const PORT = +(process.env.C6_CDP || 9361);
const BASE = process.env.C6_GAME_BASE || 'http://localhost:8809/';
const GAME = process.env.C6_GAME || 'fixture.html';
const mode = process.argv[2] || 'framed';
const ALLOW = 'autoplay; fullscreen *; geolocation; microphone; camera; midi; monetization; xr-spatial-tracking; gamepad; gyroscope; accelerometer; xr; cross-origin-isolated; web-share';
const TOPHTML = `<!doctype html><meta charset=utf-8><title>85a top</title><style>html,body{margin:0;background:#fff}iframe{position:absolute;left:0;top:0;width:1888px;height:977px;border:0}</style><body><script>
var q=new URLSearchParams(location.search); var f=document.createElement('iframe'); f.id='game_drop'; f.setAttribute('allow',${JSON.stringify(ALLOW)}); f.src=q.get('src'); document.body.appendChild(f);</script>`;
const sleep = ms => new Promise(r => setTimeout(r, ms));
const ver = await (await fetch(`http://127.0.0.1:${PORT}/json/version`)).json();
const ws = new WebSocket(ver.webSocketDebuggerUrl);
await new Promise((r, j) => { ws.onopen = r; ws.onerror = j; });
let nid = 0; const pend = new Map();
ws.onmessage = e => { const m = JSON.parse(e.data); if (m.id && pend.has(m.id)) { const p = pend.get(m.id); pend.delete(m.id); m.error ? p.rej(new Error(JSON.stringify(m.error))) : p.res(m.result); } };
const send = (method, params = {}, sessionId) => new Promise((res, rej) => { const id = ++nid; pend.set(id, { res, rej }); const o = { id, method, params }; if (sessionId) o.sessionId = sessionId; ws.send(JSON.stringify(o)); });
const attach = async targetId => (await send('Target.attachToTarget', { targetId, flatten: true })).sessionId;
async function ev(sess, expr) { const r = await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true, userGesture: true }, sess); return r.exceptionDetails ? { __exception: (r.exceptionDetails.exception && r.exceptionDetails.exception.description) || r.exceptionDetails.text } : r.result.value; }
const targets = async () => (await send('Target.getTargets')).targetInfos;
async function waitTarget(pred, ms) { const t0 = Date.now(); while (Date.now() - t0 < ms) { const t = (await targets()).filter(pred); if (t.length) return t; await sleep(150); } return []; }
async function click(sess, x, y) { for (const type of ['mouseMoved', 'mousePressed', 'mouseReleased']) await send('Input.dispatchMouseEvent', { type, x, y, button: 'left', clickCount: 1 }, sess); }
let srv = null;
const serveTop = () => new Promise(r => { srv = http.createServer((req, res) => { if (req.url.startsWith('/top.html')) { res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8', 'Cache-Control': 'no-store' }); res.end(TOPHTML); } else { res.writeHead(404); res.end(); } }); srv.listen(8871, '127.0.0.1', r); });
const out = { test: 'frame2p', mode, at: new Date().toISOString(), chrome: ver.Browser, port: PORT };
const pair = 'f2' + mode.slice(0, 3) + Date.now().toString(36).slice(-6);
const gameUrl = BASE + GAME + '?netslot=A&pair=' + pair;
let topId = null;
async function run() {
  let H, T = null;
  if (mode === 'framed') {
    await serveTop();
    topId = (await send('Target.createTarget', { url: 'http://127.0.0.1:8871/top.html?src=' + encodeURIComponent(gameUrl) })).targetId;
    T = await attach(topId);
    const ft = await waitTarget(t => t.type === 'iframe' && t.url.includes('pair=' + pair), 15000);
    out.frameFound = ft.length; if (!ft.length) return;
    H = await attach(ft[0].targetId);
  } else { topId = (await send('Target.createTarget', { url: gameUrl })).targetId; H = await attach(topId); }
  const booted = async (S, ms) => { const t0 = Date.now(); while (Date.now() - t0 < ms) { try { if (await ev(S, "!!(window.__net&&window.__gx&&__gx('PLOADED'))") === true) return Date.now() - t0; } catch (e) { } await sleep(250); } return false; };
  out.hostBootMs = await booted(H, 60000);
  out.hostIsTop = await ev(H, 'window.top===window');
  out.ver = await ev(H, "typeof VER!=='undefined'?VER:__gx('VER')");
  await ev(H, "localStorage.removeItem('salvagerun:p2raid');localStorage.removeItem('salvagerun:p2live');1");
  await ev(H, `__gx("NET.pair='${pair}'")`);
  // a REAL mouse click on 2 PLAYER CO-OP, at the button's centre (the frame sits at 0,0 of the top page)
  await ev(H, "(function(){var b=document.getElementById('modecoop'); if(b&&b.scrollIntoView) b.scrollIntoView({block:'center'}); return 1;})()");
  const r = await ev(H, "(function(){var b=document.getElementById('modecoop'); if(!b) return null; var r=b.getBoundingClientRect(); return {x:r.left+r.width/2,y:r.top+r.height/2,disabled:!!b.disabled,shown:r.width>0};})()");
  out.btn = r;
  if (!r || !r.shown) { out.error = 'no 2 PLAYER CO-OP button on screen'; return; }
  const t0 = Date.now();
  await click(T || H, r.x, r.y);
  const gt = await waitTarget(t => t.type === 'page' && t.url.includes('p2=1') && t.url.includes('pair=' + pair), 8000);
  out.p2WindowFound = gt.length;
  let G = null; if (gt.length) { G = await attach(gt[0].targetId); out.p2Url = gt[0].url; }
  out.p2BootMs = G ? await booted(G, 20000) : false;
  out.p2HasOpener = G ? await ev(G, 'window.opener!==null') : null;
  let linked = false; const samples = [];
  while (Date.now() - t0 < 20000) {
    const h = await ev(H, 'JSON.stringify(__net.state())'), g = G ? await ev(G, "window.__net?JSON.stringify(__net.state()):'no __net'") : null;
    let hr = 0, gr = 0; try { hr = JSON.parse(h).roster.length; } catch (e) { } try { gr = JSON.parse(g).roster.length; } catch (e) { }
    samples.push({ ms: Date.now() - t0, hostRoster: hr, p2Roster: gr });
    if (hr === 2 && gr === 2) { linked = true; break; }
    await sleep(500);
  }
  out.linked = linked; out.linkMs = linked ? samples[samples.length - 1].ms : null; out.linkedUnder5s = linked && out.linkMs <= 5000; out.samples = samples;
  if (!linked) { out.hostStatus = await ev(H, 'NET.status'); out.hostMsg = await ev(H, "(document.getElementById('modemsg')||{}).textContent"); }
  if (linked && G) {
    // a raid: both ascend (the fixture's own helper, same as the gate drives)
    out.hostAscend = await ev(H, "typeof __net.ascend==='function'?(__net.ascend(),1):'no __net.ascend'");
    await sleep(6000);
    out.hostInRaid = await ev(H, "!!(window.G&&!G.over&&!G.sim)"); out.p2InRaid = await ev(G, "!!(window.G&&!G.over&&!G.sim)");
    // a shared sound setting changed in one window must show in the other (the bridge compares once a second)
    const k = "salvagerun:samesound:split";
    const was = await ev(G, `localStorage.getItem('${k}')`);
    await ev(H, `localStorage.setItem('${k}', ${JSON.stringify(was === '0' ? '1' : '0')});1`);
    await sleep(3500);
    out.splitSeenByP2 = (await ev(G, `localStorage.getItem('${k}')`)) === (was === '0' ? '1' : '0');
    // closing player 2: the host must say so
    await send('Target.closeTarget', { targetId: gt[0].targetId }); G = null;
    await sleep(20000);
    out.afterCloseStatus = await ev(H, 'NET.status'); out.afterCloseMsg = await ev(H, "(document.getElementById('modemsg')||{}).textContent");
    out.afterCloseRoster = await ev(H, 'JSON.stringify(__net.state().roster.length)');
  }
  try { await ev(H, "__gx('netSameStop()');1"); } catch (e) { }
}
try { await run(); } catch (e) { out.error = String(e && e.stack || e); }
try { for (const t of await targets()) if (t.type === 'page' && (t.url.includes(pair) || t.targetId === topId)) await send('Target.closeTarget', { targetId: t.targetId }); } catch (e) { }
fs.writeFileSync(path.join(DIR, `raw-frame2p-${mode}.json`), JSON.stringify(out, null, 1));
console.log(JSON.stringify({ mode, linked: out.linked, linkMs: out.linkMs, under5: out.linkedUnder5s, raid: [out.hostInRaid, out.p2InRaid], split: out.splitSeenByP2, after: out.afterCloseStatus, error: out.error }));
if (srv) srv.close(); ws.close(); setTimeout(() => process.exit(0), 300);
