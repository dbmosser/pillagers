// coord-06 primitive test driver. Talks to the headless Chrome on debug port 9371 ONLY.
// usage: node c6drive.mjs t1 <mode>     (mode: plain|noopener|noopenerpopup|noreferrer|link|cut|cutnav|twice)
//        node c6drive.mjs t2 <case>     (case: none|esc|noesc|noopener|cut|cutport|cutnav)
// The top page of t2 is served at http://127.0.0.1:8871/ by CDP Fetch interception (nothing listens on 8871):
// the static servers on 8803-8810 answer 400 Invalid Hostname to Host 127.0.0.1.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
const DIR = path.dirname(fileURLToPath(import.meta.url));
const PORT = 9371;
const BASE = 'http://localhost:8809/handoff/console/notes/coord-06/';
const TOP = 'http://127.0.0.1:8871/top2.html';
const sleep = ms => new Promise(r => setTimeout(r, ms));
const ver = await (await fetch(`http://127.0.0.1:${PORT}/json/version`)).json();
const ws = new WebSocket(ver.webSocketDebuggerUrl);
await new Promise((r, j) => { ws.onopen = r; ws.onerror = j; });
let nid = 0; const pend = new Map(); const events = [];
ws.onmessage = e => {
  const m = JSON.parse(e.data);
  if (m.id && pend.has(m.id)) { const p = pend.get(m.id); pend.delete(m.id); m.error ? p.rej(new Error(JSON.stringify(m.error))) : p.res(m.result); }
  else events.forEach(f => f(m));
};
const send = (method, params = {}, sessionId) => new Promise((res, rej) => { const id = ++nid; pend.set(id, { res, rej }); const o = { id, method, params }; if (sessionId) o.sessionId = sessionId; ws.send(JSON.stringify(o)); });
async function attach(targetId) { const r = await send('Target.attachToTarget', { targetId, flatten: true }); return r.sessionId; }
async function ev(sess, expr, gesture) {
  const r = await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true, userGesture: !!gesture }, sess);
  if (r.exceptionDetails) return { __exception: r.exceptionDetails.exception ? r.exceptionDetails.exception.description : r.exceptionDetails.text };
  return r.result.value;
}
async function ready(sess, ms = 8000) { const t0 = Date.now(); while (Date.now() - t0 < ms) { try { const v = await ev(sess, "document.readyState==='complete'&&typeof st==='function'"); if (v === true) return true; } catch (e) { } await sleep(100); } return false; }
async function targets() { return (await send('Target.getTargets')).targetInfos; }
async function waitTarget(pred, ms = 6000) { const t0 = Date.now(); while (Date.now() - t0 < ms) { const t = (await targets()).filter(pred); if (t.length) return t; await sleep(100); } return []; }
async function procs() { const r = await send('SystemInfo.getProcessInfo'); return r.processInfo.filter(p => p.type === 'renderer').map(p => ({ id: p.id, cpu: p.cpuTime })); }
function delta(a, b) { const m = new Map(a.map(p => [p.id, p.cpu])); return b.map(p => ({ id: p.id, d: +(p.cpu - (m.get(p.id) || 0)).toFixed(3) })).sort((x, y) => y.d - x.d); }
async function click(sess, x, y) {
  for (const type of ['mouseMoved', 'mousePressed', 'mouseReleased']) await send('Input.dispatchMouseEvent', { type, x, y, button: 'left', clickCount: 1 }, sess);
}
async function closeAll(pred) { for (const t of await targets()) if (t.type === 'page' && pred(t)) { try { await send('Target.closeTarget', { targetId: t.targetId }); } catch (e) { } } }
const out = { test: process.argv[2], mode: process.argv[3], at: new Date().toISOString(), chrome: ver.Browser };

async function t1(mode) {
  const tag = mode + '_' + Date.now().toString(36);
  const p0 = await procs(); out.renderersBefore = p0.length;
  const { targetId: aId } = await send('Target.createTarget', { url: BASE + 'a.html?case=' + tag });
  const A = await attach(aId); out.aReady = await ready(A);
  out.aOpenReturnedNull = await ev(A, `openB(${JSON.stringify(mode === 'twice' ? 'noopener' : mode)},${JSON.stringify(tag)},${mode === 'twice' ? "'pillagers_p2_" + tag + "'" : 'undefined'})`, true);
  if (mode === 'twice') { await sleep(800); out.aSecondOpenReturnedNull = await ev(A, `openB('noopener',${JSON.stringify(tag)},'pillagers_p2_${tag}')`, true); await sleep(1200); out.bTargetsAfterTwoOpensSameName = (await targets()).filter(t => t.url.includes('b.html?tag=' + tag)).length; }
  const bt = await waitTarget(t => t.type === 'page' && t.url.includes('b.html?tag=' + tag));
  out.bFound = bt.length; if (!bt.length) return;
  const B = await attach(bt[0].targetId); out.bReady = await ready(B);
  if (mode === 'cut' || mode === 'cutnav') out.bCutOpenerStillThere = await ev(B, 'cut()');
  if (mode === 'cutnav') { await ev(B, "location.href='b.html?tag=" + tag + "&gen=2';1"); await sleep(1500); out.bReadyGen2 = await ready(B); out.bUrlAfterNav = await ev(B, 'location.href'); }
  await sleep(400);
  out.renderersWithAB = (await procs()).length;
  // baseline gap
  await ev(B, 'reset()'); await sleep(1000); out.bBaselineMaxGapMs = +(await ev(B, 'S.maxGap')).toFixed(1);
  await ev(A, `poke(${JSON.stringify(tag)})`); await sleep(400);
  const q0 = await procs();
  await ev(B, 'reset()');
  await ev(A, 'busy(2000)');
  await sleep(50);
  const bAfter = await ev(B, 'st()');
  const q1 = await procs();
  await ev(B, 'busy(1000)');
  const q2 = await procs();
  out.bMaxGapWhileABusy2000Ms = +bAfter.maxGap.toFixed(1);
  out.bTicksDuringWindow = bAfter.ticks;
  out.sharedThread = bAfter.maxGap > 1500;
  const dA = delta(q0, q1), dB = delta(q1, q2);
  out.cpuDeltaWhileABusy = dA.slice(0, 3); out.cpuDeltaWhileBBusy = dB.slice(0, 3);
  out.pidA = dA[0].id; out.pidB = dB[0].id; out.samePid = out.pidA === out.pidB;
  out.b = bAfter; out.a = await ev(A, 'st()');
  out.bSawABroadcast = (bAfter.bc || []).some(m => m.from === 'a');
  out.bSawStorageEvent = (bAfter.storageEv || []).length > 0;
  out.bReadsALocalStorage = !!bAfter.lsA;
  await closeAll(t => t.url.includes(tag));
}

async function t2(cs) {
  const run = cs + '_' + Date.now().toString(36);
  const qs = { run, sb: 'none', feat: 'plain', popmode: 'none' };
  if (cs === 'esc' || cs === 'noesc') qs.sb = cs;
  if (cs === 'noopener') qs.feat = 'noopener';
  if (cs === 'cut' || cs === 'cutport' || cs === 'cutnav') qs.popmode = cs;
  out.params = qs;
  const { targetId: tId } = await send('Target.createTarget', { url: 'about:blank' });
  const T = await attach(tId);
  const html = fs.readFileSync(path.join(DIR, 'top2.html'));
  events.push(async m => {
    if (m.method === 'Fetch.requestPaused' && m.sessionId === T) {
      await send('Fetch.fulfillRequest', { requestId: m.params.requestId, responseCode: 200, responseHeaders: [{ name: 'Content-Type', value: 'text/html; charset=utf-8' }], body: html.toString('base64') }, T);
    }
  });
  await send('Fetch.enable', { patterns: [{ urlPattern: 'http://127.0.0.1:8871/*' }] }, T);
  await send('Page.enable', {}, T);
  await send('Page.navigate', { url: TOP + '?' + new URLSearchParams(qs).toString() }, T);
  let s0 = null; const t0 = Date.now();
  while (Date.now() - t0 < 10000) { try { s0 = await ev(T, "typeof __ask==='function'?__ask('state'):null"); if (s0 && !s0.timeout) break; } catch (e) { } await sleep(200); }
  out.innerAtLoad = s0;
  out.topOrigin = await ev(T, 'location.origin');
  const p0 = await procs(); out.renderersTopAndFrame = p0.length;
  await click(T, 100, 30);
  const pt = await waitTarget(t => t.type === 'page' && t.url.includes('pop.html?run=' + run), 5000);
  out.popFound = pt.length;
  let P = null;
  if (pt.length) { P = await attach(pt[0].targetId); out.popReady = await ready(P); }
  await sleep(2600);
  if (cs === 'cutnav' && P) { out.popReadyGen2 = await ready(P); out.popUrl = await ev(P, 'location.href'); }
  out.renderersWithPop = (await procs()).length;
  await click(T, 100, 130); await sleep(1500);
  await ev(T, "__ask('write','w2')"); await sleep(400);
  if (P) { out.popPortPing = await ev(P, 'portPing()'); await sleep(400); }
  if (P) {
    await ev(T, "__ask('reset')");
    const q0 = await procs();
    await ev(P, 'busy(2000)');
    await sleep(50);
    const sIn = await ev(T, "__ask('state')");
    const q1 = await procs();
    await ev(T, "__ask('busy',1000)");
    const q2 = await procs();
    await ev(T, '__busy(700)');
    const q3 = await procs();
    out.innerMaxGapWhilePopBusy2000Ms = sIn.maxGap != null ? +sIn.maxGap.toFixed(1) : sIn;
    out.innerSharesPopThread = sIn.maxGap > 1500;
    const dP = delta(q0, q1), dI = delta(q1, q2), dT = delta(q2, q3);
    out.pidPop = dP[0].id; out.pidInner = dI[0].id; out.pidTop = dT[0].id;
    out.cpuDeltas = { popBusy: dP.slice(0, 3), innerBusy: dI.slice(0, 3), topBusy: dT.slice(0, 3) };
    out.pop = await ev(P, 'st()');
  }
  out.inner = await ev(T, "__ask('state')");
  // verdicts
  const il = (out.inner && out.inner.log) || [], pl = (out.pop && out.pop.log) || [];
  out.verdict = {
    bcPopToFrame: il.some(x => x.includes('bc:{"from":"pop"')),
    bcFrameToPop: pl.some(x => x.includes('bc:{"from":"inner"') && !x.includes('rsa')),
    lsFrameSeesPopKey: !!(out.inner && out.inner.lsPop),
    lsPopSeesFrameKey: !!(out.pop && (out.pop.lsInner || out.pop.lsInnerAtLoad)),
    storageEventInFrame: il.some(x => x.includes('storage:c6t2:pop')),
    storageEventInPop: pl.some(x => x.includes('storage:c6t2:inner')),
    popHasOpener: out.pop ? out.pop.openerAtLoad : null,
    openerPostPopToFrame: il.some(x => x.includes('"hello":1')),
    frameReplyViaW: pl.some(x => x.includes('"via":"W"')),
    frameReplyViaSource: pl.some(x => x.includes('"via":"source"')),
    lateWAfterCut: pl.some(x => x.includes('"via":"W-late"')),
    portFrameToPop: pl.some(x => x.includes('port:{"from":"inner"')),
    portPopToFrame: il.some(x => x.includes('port:{"from":"pop"')),
    rsa: out.inner && out.inner.rsa,
    rsaBcReachedPop: pl.some(x => x.includes('rsa-bc')),
    rsaLsWriteSeenByPop: !!(out.pop && out.pop.lsRsa),
    popOwnProcess: out.pidPop != null ? out.pidPop !== out.pidInner : null,
  };
  await closeAll(t => t.url.includes(run) || t.targetId === tId);
}

try {
  if (out.test === 't1') await t1(out.mode); else if (out.test === 't2') await t2(out.mode);
} catch (e) { out.error = String(e && e.stack || e); }
const f = path.join(DIR, `raw-${out.test.toUpperCase()}-${out.mode}.json`);
fs.writeFileSync(f, JSON.stringify(out, null, 1));
console.log(JSON.stringify(Object.assign({ file: path.basename(f) }, out.verdict || { sharedThread: out.sharedThread, samePid: out.samePid, aOpenReturnedNull: out.aOpenReturnedNull, bMaxGap: out.bMaxGapWhileABusy2000Ms, error: out.error })));
ws.close(); process.exit(0);
