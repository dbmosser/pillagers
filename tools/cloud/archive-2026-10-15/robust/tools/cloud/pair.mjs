// Cloud two-window soak: the host page picks 2 PLAYER ARCADE DEMO (arcadePick), the player 2 window it opens is a real popup
// page in the same browser, player 2 joins with A on a faked controller, and both play random input in real time.
//   node tools/cloud/pair.mjs FILE RUNS SECS SEED
// Prints one JSON line per run: page errors of each window, NaN on either player, whether player 2 got in and moved, and the
// census of listeners, intervals and DOM in each window after each run.
import http from 'node:http'; import fs from 'node:fs'; import path from 'node:path';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
let pw; try { pw = require('playwright'); } catch (e) { pw = require('/opt/node22/lib/node_modules/playwright'); }
const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..', '..');
const srv = http.createServer((q, r) => { const p = path.join(ROOT, decodeURIComponent(q.url.split('?')[0]));
  if (!p.startsWith(ROOT) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) { r.writeHead(404); r.end(); return; }
  r.writeHead(200, { 'content-type': p.endsWith('.html') ? 'text/html; charset=utf-8' : 'application/octet-stream' }); fs.createReadStream(p).pipe(r); });
await new Promise(ok => srv.listen(0, '127.0.0.1', ok));
const base = 'http://127.0.0.1:' + srv.address().port + '/tools/';
const [file = 'fixture.html', runsA = '3', secsA = '90', seedA = '1'] = process.argv.slice(2);
const RUNS = +runsA, SECS = +secsA; let rs = (+seedA) >>> 0; const rnd = () => { rs = (Math.imul(rs, 1664525) + 1013904223) >>> 0; return rs / 4294967296; };
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--autoplay-policy=no-user-gesture-required', '--js-flags=--expose-gc', '--disable-popup-blocking'] });
const ctx = await browser.newContext({ viewport: { width: 1920, height: 1080 } });
await ctx.addInitScript(() => {
  // two faked controllers seen by both windows, as on one PC: pad 0 idle (player 1 plays the keyboard), pad 1 driven by the test
  const mk = ix => ({ id: 'fake pad ' + ix, index: ix, connected: true, mapping: 'standard', timestamp: 0, axes: [0, 0, 0, 0], buttons: Array.from({ length: 17 }, () => ({ pressed: false, value: 0, touched: false })), vibrationActuator: null });
  window.__PADS = [mk(0), mk(1)];
  navigator.getGamepads = function () { return window.__PADS; };
  window.__padSet = function (ix, axes, btns) { const p = window.__PADS[ix]; p.timestamp = performance.now(); p.axes = axes; for (let i = 0; i < p.buttons.length; i++) { const v = btns.indexOf(i) >= 0; p.buttons[i] = { pressed: v, value: v ? 1 : 0, touched: v }; } };
  try { Object.defineProperty(document, 'hidden', { get: () => false }); Document.prototype.hasFocus = function () { return true; }; } catch (e) {}
});
const pages = {}; const errs = { A: [], C: [] };
const A = await ctx.newPage(); pages.A = A;
A.on('pageerror', e => errs.A.push((e.stack || e.message).split('\n').slice(0, 3).join(' / ')));
ctx.on('page', p => { if (p !== A) { pages.C = p; p.on('pageerror', e => errs.C.push((e.stack || e.message).split('\n').slice(0, 3).join(' / '))); p.on('dialog', d => d.dismiss().catch(() => {})); } });
A.on('dialog', d => d.dismiss().catch(() => {}));
await A.goto(base + file, { waitUntil: 'load', timeout: 180000 });
await A.evaluate(() => { try { localStorage.clear(); } catch (e) {} });
await A.goto(base + file, { waitUntil: 'load', timeout: 180000 });
await A.waitForFunction(() => typeof window.__gx === 'function', null, { timeout: 180000 });
await A.waitForTimeout(2000);
const gx = (p, js) => p.evaluate(s => window.__gx(s), js);
console.log('pick: ' + await gx(A, "(function(){ try{ var _bt=document.getElementById('title'); if(_bt) _bt.classList.remove('on'); return String(arcadePick()); }catch(e){ return 'ERR '+e; } })()"));
for (let i = 0; i < 60 && !pages.C; i++) await A.waitForTimeout(500);
if (!pages.C) { console.log('no player 2 window'); process.exit(1); }
const C = pages.C;
await C.waitForLoadState('load');
await C.waitForFunction(() => typeof window.__gx === 'function', null, { timeout: 180000 });
await C.waitForTimeout(3000);
console.log('C url: ' + C.url());
const CENSUS = `(function(){ var o={}; try{ o.st=state; o.arc=!!(G&&G.arcade); o.over=!!(G&&G.over); o.role=ARCADE.role; o.on=ARCADE.on; o.dom=document.getElementsByTagName('*').length; o.ents=(G&&G.ents)?G.ents.length:-1;
  if(G&&G.player){ o.px=Math.round(G.player.x); o.py=Math.round(G.player.y); o.hp=G.player.hp; }
  o.bad=[]; if(G&&G.player){ for(var k in G.player){ if(typeof G.player[k]==='number'&&!isFinite(G.player[k])) o.bad.push('p.'+k); } }
  if(G&&G.ents){ for(var i=0;i<G.ents.length&&o.bad.length<10;i++){ var e=G.ents[i]; if(e&&(typeof e.x==='number'&&!isFinite(e.x)||typeof e.y==='number'&&!isFinite(e.y))) o.bad.push('ent '+e.kind); } }
  o.mates=(NET.up?NET.up.length:0); o.crash=(P.crashes||[]).length; o.netOn=!!NET.on; o.same=NET.same; o.wantIn=ARCADE.wantIn;
  try{ o.heap=Math.round(performance.memory.usedJSHeapSize/1048576); }catch(e){} }catch(e){ o.err=String(e); } return JSON.stringify(o); })()`;
const census = async p => JSON.parse(await gx(p, CENSUS));
for (let run = 0; run < RUNS; run++) {
  const rec = { run };
  // host drops in with a key, player 2 presses A on its pad
  await gx(A, "(function(){ try{ return String(arcadePadAtt(true,false)); }catch(e){ return 'ERR '+e; } })()").then(v => rec.hostIn = v);
  await A.waitForTimeout(1500);
  for (let k = 0; k < 6; k++) { await C.evaluate(() => window.__padSet(1, [0, 0, 0, 0], [0])); await C.waitForTimeout(150); await C.evaluate(() => window.__padSet(1, [0, 0, 0, 0], [])); await C.waitForTimeout(600); }
  rec.c0 = await census(C); rec.a0 = await census(A);
  if (process.env.PROBE_C) {
    // a probe: JS run in player 2's window, then after 2 s JS run in the host window; prints both and stops
    rec.probeC = await gx(C, process.env.PROBE_C); await A.waitForTimeout(2000);
    rec.probeA = await gx(A, process.env.PROBE_A || '1'); if (process.env.PROBE_C2) { await A.waitForTimeout(2000); rec.probeC2 = await gx(C, process.env.PROBE_C2); } rec.errA = errs.A.splice(0); rec.errC = errs.C.splice(0);
    console.log(JSON.stringify({ probeC: rec.probeC, probeA: rec.probeA, probeC2: rec.probeC2, errA: rec.errA, errC: rec.errC })); break;
  }
  const t0 = Date.now(); let moved = 0, lastC = rec.c0;
  while (Date.now() - t0 < SECS * 1000) {
    // random keyboard on A, random stick and buttons on pad 1 (both windows see it, as on one PC)
    const ks = ['KeyW', 'KeyA', 'KeyS', 'KeyD'][Math.floor(rnd() * 4)];
    await A.keyboard.down(ks); await A.mouse.move(200 + rnd() * 1500, 150 + rnd() * 800);
    if (rnd() < 0.5) await A.mouse.down();
    const ax = [rnd() * 2 - 1, rnd() * 2 - 1, rnd() * 2 - 1, rnd() * 2 - 1], bt = [];
    if (rnd() < 0.4) bt.push(7); if (rnd() < 0.1) bt.push(0); if (rnd() < 0.08) bt.push(2); if (rnd() < 0.05) bt.push(4, 5); if (rnd() < 0.05) bt.push(1);
    await A.evaluate(([a, b]) => window.__padSet(1, a, b), [ax, bt]); await C.evaluate(([a, b]) => window.__padSet(1, a, b), [ax, bt]);
    await A.waitForTimeout(400 + rnd() * 600);
    await A.keyboard.up(ks); await A.mouse.up();
    if (rnd() < 0.05) { const t = ['KeyR', 'KeyE', 'KeyG', 'KeyQ', 'Space', 'KeyF'][Math.floor(rnd() * 6)]; await A.keyboard.press(t); }
    const c = await census(C); if (c.px !== undefined && lastC.px !== undefined && (Math.abs(c.px - lastC.px) + Math.abs(c.py - lastC.py) > 4)) moved++; lastC = c;
    if (c.bad && c.bad.length) rec.cbad = c.bad;
    // keep both alive in god mode so the run lasts
    await gx(A, "(function(){ try{ if(G&&G.player&&G.player.hp<35&&!G.player.downed) G.player.hp=G.player.maxhp||100; }catch(e){} return 1; })()");
    await gx(C, "(function(){ try{ if(G&&G.player&&G.player.hp<35&&!G.player.downed) G.player.hp=G.player.maxhp||100; }catch(e){} return 1; })()");
  }
  rec.moved = moved;
  if (process.env.LEAVE) {
    // the host window closes mid-raid: player 2 picks up the raid (his ruling). Read what player 2 holds before and after.
    const SNAP = "(function(){ try{ var o={st:state,over:!!(G&&G.over),t:Math.round(G.t||0),peer:(typeof flowPeer==='function')?flowPeer():null,was:!!G.netWasJoin}; var F=G.flow||{}; o.fires=(F.fires||[]).map(function(f){ return Math.round(f.x)+','+Math.round(f.y)+(fireLit(f)?'L':''); }); o.ev=((F.ev&&F.ev.live)||[]).map(function(e){ return e.id+':'+e.ph+':'+Math.round(e.t); }); o.evPlan=!!(F.ev&&F.ev.plan); o.sh=((F.sh&&F.sh.sites)||[]).map(function(s){ return 'open'+s.open+' clear'+s.clear+' def'+((s.def||[]).length)+'/'+((s.def2||[]).length); }); o.score=(G.arcade?ARCADE.mine:(G.cs&&G.cs.s))|0; o.gold=F.gold?{ref:!!F.gold.ref,dead:F.gold.dead}:null; o.goals=(F.goals&&F.goals.list||[]).map(function(g){ return g.id+':'+g.v+'/'+g.n; }); o.ents=G.ents.length; return JSON.stringify(o); }catch(e){ return JSON.stringify({err:String(e.stack||e)}); } })()";
    rec.before = JSON.parse(await gx(C, SNAP));
    await A.close();
    for (let k = 0; k < 8; k++) { await C.waitForTimeout(2500); rec['after' + k] = JSON.parse(await gx(C, SNAP)); }
    rec.errC = errs.C.splice(0); rec.crashC = await gx(C, "JSON.stringify((P.crashes||[]).slice(-3))");
    console.log(JSON.stringify(rec)); break;
  }
  // end the run from the host as the clock would
  rec.end = await gx(A, "(function(){ try{ if(G&&G.arcade&&!G.over&&raidClockOn()){ G.timeLeft=Math.min(G.timeLeft,2); return 'clock'; } return 'noclock st='+state; }catch(e){ return 'ERR '+e; } })()");
  await A.waitForTimeout(12000);
  rec.a1 = await census(A); rec.c1 = await census(C);
  rec.errA = errs.A.splice(0); rec.errC = errs.C.splice(0);
  rec.crashA = await gx(A, "JSON.stringify((P.crashes||[]).slice(-3))"); rec.crashC = await gx(C, "JSON.stringify((P.crashes||[]).slice(-3))");
  console.log(JSON.stringify(rec));
  // the RUN OVER card: press through it on the host so the attract comes back
  for (let k = 0; k < 4; k++) { await gx(A, "(function(){ try{ return String(arcadePadAtt(true,false)); }catch(e){ return 'ERR '+e; } })()"); await A.waitForTimeout(1200); }
  await gx(A, "(function(){ try{ if(G&&G.arcade&&!G.over){ if(!arcadeRunEnd('quit')) arcadeRaidStop('end'); } }catch(e){} return 1; })()");
  await A.waitForTimeout(4000);
}
await browser.close(); srv.close(); process.exit(0);
