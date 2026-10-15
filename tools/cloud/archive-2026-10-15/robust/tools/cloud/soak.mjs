// Cloud long-play soak (Linux, headless Chromium 1920x1080). A TOOL: it never edits the game; it drives a fixture copy.
//   node tools/cloud/soak.mjs FILE MODES RAIDS SECS SEED
//     FILE   a name inside tools/ (fixture.html)
//     MODES  comma list of demo1,demo2,career (default demo1,career,demo2)
//     RAIDS  raids to run (default 6); SECS game seconds per raid before the clock is forced down (default 240)
//     SEED   master seed for raid seeds, maps and inputs (default 1)
// One page runs every raid back to back. The main loop is stepped in game scope with a pushed clock (50 ms a frame, the loop
// clamp) and HID.fromWorker set, so no extra rAF chain is armed. Input is real DOM events (keydown/up on window, mouse on the
// canvas) from a seeded LCG. After each raid it records: page errors, the game crash list, non-finite numbers on the player and
// on every entity, raids that never end, G array lengths, live listeners, live timers, heap. Prints one JSON line per raid.
import http from 'node:http'; import fs from 'node:fs'; import path from 'node:path';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
let pw; try { pw = require('playwright'); } catch (e) { pw = require('/opt/node22/lib/node_modules/playwright'); }
const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..', '..');
const srv = http.createServer((q, r) => {
  const p = path.join(ROOT, decodeURIComponent(q.url.split('?')[0]));
  if (!p.startsWith(ROOT) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) { r.writeHead(404); r.end(); return; }
  r.writeHead(200, { 'content-type': p.endsWith('.html') ? 'text/html; charset=utf-8' : 'application/octet-stream' }); fs.createReadStream(p).pipe(r);
});
await new Promise(ok => srv.listen(0, '127.0.0.1', ok));
const base = 'http://127.0.0.1:' + srv.address().port + '/tools/';
const [file = 'fixture.html', modesA = 'demo1,career,demo2', raidsA = '6', secsA = '240', seedA = '1'] = process.argv.slice(2);
const MODES = modesA.split(','), RAIDS = +raidsA, SECS = +secsA, SEED = +seedA;
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--autoplay-policy=no-user-gesture-required', '--js-flags=--expose-gc'] });
const page = await (await browser.newContext({ viewport: { width: 1920, height: 1080 } })).newPage();
const perrs = []; page.on('pageerror', e => perrs.push((e.stack || e.message || String(e)).slice(0, 600)));
page.on('dialog', d => d.dismiss().catch(() => {}));
// listener and timer ledger, installed before any game script runs
await page.addInitScript(() => {
  const L = window.__LED = { add: 0, rem: 0, live: new Map(), to: 0, iv: new Map(), raf: 0, els: [] };
  const ael = EventTarget.prototype.addEventListener, rel = EventTarget.prototype.removeEventListener;
  const key = (t, ty, f, c) => ty + '|' + (typeof c === 'object' ? !!(c && c.capture) : !!c);
  const W = new WeakMap();
  EventTarget.prototype.addEventListener = function (ty, f, c) {
    if (f) { let m = W.get(this); if (!m) { m = new Map(); W.set(this, m); } let s = m.get(key(this, ty, f, c)); if (!s) { s = new Set(); m.set(key(this, ty, f, c), s); }
      if (!s.has(f)) { s.add(f); L.add++; if (this.nodeType === 1) { if (!this.__lc) { this.__lc = 0; L.els.push(new WeakRef(this)); } this.__lc++; } const nm = (this === window ? 'window' : this === document ? 'document' : (this.nodeName || this.constructor.name)) + ':' + ty; L.live.set(nm, (L.live.get(nm) || 0) + 1); } }
    return ael.call(this, ty, f, c);
  };
  EventTarget.prototype.removeEventListener = function (ty, f, c) {
    const m = W.get(this), s = m && m.get(key(this, ty, f, c));
    if (s && s.has(f)) { s.delete(f); L.rem++; if (this.nodeType === 1 && this.__lc) this.__lc--; const nm = (this === window ? 'window' : this === document ? 'document' : (this.nodeName || this.constructor.name)) + ':' + ty; L.live.set(nm, (L.live.get(nm) || 0) - 1); }
    return rel.call(this, ty, f, c);
  };
  const si = window.setInterval, ci = window.clearInterval;
  window.setInterval = function (f, ms) { const id = si.apply(window, arguments); L.iv.set(id, String(f).slice(0, 80) + ' @' + ms); return id; };
  window.clearInterval = function (id) { L.iv.delete(id); return ci.call(window, id); };
});
let rs = SEED >>> 0; const rnd = () => { rs = (Math.imul(rs, 1664525) + 1013904223) >>> 0; return rs / 4294967296; };
await page.goto(base + file, { waitUntil: 'load', timeout: 180000 });
await page.evaluate(() => { try { localStorage.clear(); } catch (e) {} });
await page.goto(base + file, { waitUntil: 'load', timeout: 180000 });
await page.waitForFunction(() => typeof window.__gx === 'function' && typeof window.__deploy === 'function', null, { timeout: 180000 });
await page.waitForTimeout(1500);
await page.evaluate(src => window.__gx(src), fs.readFileSync(path.join(ROOT, 'tools/fuzz-hook.js'), 'utf8'));
await page.evaluate(() => window.__gx('__runPrep()'));
// render throttle: the world draw runs on 1 frame in RENDER_EVERY (env, default 15) so game time runs far ahead of real time
await page.evaluate(n => window.__gx("(function(){ if(window.__R2D) return; window.__R2D=render2D; var c=0; render2D=function(dt){ if((++c)%"+n+"===0) return window.__R2D(dt); }; })()"), +(process.env.RENDER_EVERY || 15));
const maps = JSON.parse(await page.evaluate(() => window.__gx("(function(){ var a=[],i; for(i=0;i<FIXED_MAPS.length;i++) a.push(i); return JSON.stringify(a); })()")));
// census: lengths of every array on G and a few globals, listeners, intervals, heap
const CENSUS = `(function(){ var o={g:{},glob:{}},k,v; try{ if(typeof G==='object'&&G){ for(k in G){ v=G[k]; if(Array.isArray(v)) o.g[k]=v.length; } } }catch(e){}
  try{ ['P'].forEach(function(n){ var x=eval(n); for(k in x){ v=x[k]; if(Array.isArray(v)) o.glob[n+'.'+k]=v.length; } }); }catch(e){}
  try{ for(k in ARCADE){ v=ARCADE[k]; if(Array.isArray(v)) o.glob['ARCADE.'+k]=v.length; } }catch(e){}
  try{ for(k in NET){ v=NET[k]; if(Array.isArray(v)) o.glob['NET.'+k]=v.length; } }catch(e){}
  var L=window.__LED; o.lis={}; L.live.forEach(function(n,k2){ o.lis[k2]=n; }); o.iv=L.iv.size; var ea=0,ed=0,ec={}; L.els=L.els.filter(function(w){ var e=w.deref(); if(!e) return false; if(e.__lc>0){ if(e.isConnected){ ea+=e.__lc; var nm=e.nodeName+(e.id?'#'+e.id:'')+(e.className&&typeof e.className==='string'?'.'+e.className.split(' ')[0]:''); ec[nm]=(ec[nm]||0)+e.__lc; } else ed+=e.__lc; } return true; }); o.glob['LIS.attached']=ea; o.glob['LIS.detached']=ed; o.ec=ec; o.ivl=Array.from(L.iv.values());
  o.dom=document.getElementsByTagName('*').length; o.cv=document.getElementsByTagName('canvas').length;
  try{ if(window.gc) window.gc(); o.heap=Math.round(performance.memory.usedJSHeapSize/1048576); }catch(e){}
  try{ o.sk=JSON.stringify(localStorage).length; }catch(e){}
  return JSON.stringify(o); })()`;
const startJS = (mode, mapIx, seed) => mode === 'demo1'
  ? `(function(){ try{ __topClear(); __runPrep(); CAREER_ON=0; arcadeSoloPick(); var ok=arcadeDeploy({mapIx:${mapIx},seed:${seed}}); return JSON.stringify({ok:!!(ok&&G&&G.arcade)}); }catch(e){ return JSON.stringify({ok:false,err:String(e&&e.stack||e).slice(0,300)}); } })()`
  : mode === 'demo2'
  ? `(function(){ try{ __topClear(); __runPrep(); CAREER_ON=0; var ok=arcadeDeploy({mapIx:${mapIx},seed:${seed}}); return JSON.stringify({ok:!!(ok&&G&&G.arcade)}); }catch(e){ return JSON.stringify({ok:false,err:String(e&&e.stack||e).slice(0,300)}); } })()`
  : `(function(){ try{ __topClear(); __runPrep(); CAREER_ON=1; var r=__deploy({kit:['bandage','medkit','plate','frag','gun_smg'],mapIx:${mapIx},seed:${seed}}); return JSON.stringify({ok:!!(G&&G.career&&!G.arcade),err:(r&&r.error)||null}); }catch(e){ return JSON.stringify({ok:false,err:String(e&&e.stack||e).slice(0,300)}); } })()`;
// N frames in game scope with random input; returns the poll after them
const STEP = `(function(n,seed,god){ var s=seed>>>0, r=function(){ s=(Math.imul(s,1664525)+1013904223)>>>0; return s/4294967296; };
  var KEYS=['KeyW','KeyA','KeyS','KeyD'], TAPS=['KeyR','KeyE','KeyX','KeyG','KeyQ','KeyF','KeyH','Digit1','Digit2','Digit3','Digit4','Digit5','Space','KeyC','KeyB','KeyM','Escape','Tab','ControlLeft'];
  function kev(t,c){ try{ window.dispatchEvent(new KeyboardEvent(t,{code:c,key:c.replace(/^Key|^Digit/,'').toLowerCase(),bubbles:true,cancelable:true})); }catch(e){} }
  function mev(t,x,y,b){ try{ cv.dispatchEvent(new MouseEvent(t,{clientX:x,clientY:y,button:b,buttons:t==='mouseup'?0:(b===2?2:1),bubbles:true,cancelable:true})); }catch(e){} }
  var H=window.__SH||(window.__SH={held:{},mx:960,my:540,md:0,ts:performance.now()}), i, k, fr=0, ended=0;
  for(i=0;i<n;i++){
    for(k in H.held){ if(--H.held[k]<=0){ delete H.held[k]; kev('keyup',k); } }
    if(r()<0.08){ k=KEYS[(r()*4)|0]; if(!H.held[k]){ H.held[k]=3+((r()*25)|0); kev('keydown',k); } }
    if(r()<0.02){ k=TAPS[(r()*TAPS.length)|0]; if(!H.held[k]){ H.held[k]=1+((r()*3)|0); kev('keydown',k); } }
    H.mx=Math.max(0,Math.min(1919,H.mx+(r()-0.5)*120)); H.my=Math.max(0,Math.min(1079,H.my+(r()-0.5)*90)); mev('mousemove',H.mx,H.my,0);
    if(!H.md&&r()<0.06){ H.md=2+((r()*20)|0); mev('mousedown',H.mx,H.my,0); } else if(H.md&&--H.md<=0){ H.md=0; mev('mouseup',H.mx,H.my,0); try{ window.dispatchEvent(new MouseEvent('mouseup',{clientX:H.mx,clientY:H.my,button:0})); }catch(e){} }
    if(god&&typeof G==='object'&&G&&G.player&&G.player.hp<35&&!G.player.downed) G.player.hp=G.player.maxhp||100;
    if((pauseOpen||(G&&(G.paused||G.mapOpen||G.bagOpen)))&&r()<0.05) kev('keydown','Escape'), kev('keyup','Escape');
    H.ts+=50; HID.fromWorker=1; try{ loop(H.ts); }catch(e){ (window.__fz.errs).push({k:'loop',m:String(e&&e.message||e),w:String(e&&e.stack||'').slice(0,400)}); } finally{ HID.fromWorker=0; }
    fr++; if(state!=='raid'||!G||G.over){ ended=1; break; }
  }
  var o=window.__fz.poll(); o.fr=fr; o.ended=ended; o.gt=(G&&G.t)||0; return JSON.stringify(o); })`;
const out = [];
const before = JSON.parse(await page.evaluate(c => window.__gx(c), CENSUS));
console.log(JSON.stringify({ start: true, maps, census: before }));
for (let n = 0; n < RAIDS; n++) {
  const mode = MODES[n % MODES.length], mapIx = maps[Math.floor(rnd() * maps.length)], seed = 1 + Math.floor(rnd() * 1e6), god = rnd() < 0.6;
  const t0 = Date.now(), rec = { n, mode, mapIx, seed, god: +god, errs: [], bad: [], gb: [] };
  const st = JSON.parse(await page.evaluate(js => window.__gx(js), startJS(mode, mapIx, seed)));
  if (!st.ok) { rec.end = 'nostart'; rec.err = st.err; console.log(JSON.stringify(rec)); continue; }
  let gsec = 0, last = null, forced = false, endAt = 0;
  while (true) {
    const o = JSON.parse(await page.evaluate(([s, n2, sd, g]) => window.__gx('(' + s + ')(' + n2 + ',' + sd + ',' + g + ')'), [STEP, 100, Math.floor(rnd() * 4e9), god ? 1 : 0]));
    gsec += o.fr * 0.05; last = o;
    (o.errs || []).forEach(e => { if (rec.errs.length < 8) rec.errs.push(e.k + ': ' + e.m + ' | ' + String(e.w).split('\n').slice(0, 3).join(' / ')); });
    (o.bad || []).forEach(b => { if (rec.bad.indexOf(b) < 0 && rec.bad.length < 10) rec.bad.push(b); });
    (o.gb || []).forEach(b => { if (rec.gb.indexOf(b) < 0 && rec.gb.length < 10) rec.gb.push(b); });
    if (o.ended || o.st !== 'raid' || o.over) { rec.end = 'ended st=' + o.st + ' over=' + o.over + ' ae=' + o.ae; break; }
    if (!forced && gsec >= SECS) {
      forced = true; endAt = gsec + 120;
      const r = await page.evaluate(() => window.__gx("(function(){ try{ if(G&&!G.over&&raidClockOn()){ G.timeLeft=Math.min(G.timeLeft,2); return 'clock'; } if(G&&G.arcade){ return 'arcade'; } return 'noclock'; }catch(e){ return 'err '+e; } })()"));
      rec.force = r;
      if (r !== 'clock') { // a run with no raid clock ends by abandon, as a player leaving
        await page.evaluate(() => window.__gx("(function(){ try{ if(G&&G.arcade){ if(!arcadeRunEnd('quit')) arcadeRaidStop('end'); } else endRaid('abandon'); }catch(e){ window.__fz.errs.push({k:'end',m:String(e),w:String(e&&e.stack)}); } })()"));
      }
    }
    if (forced && gsec >= endAt) { rec.end = 'NOEND tl=' + last.tl + ' menu=' + last.menu; break; }
    if (gsec > SECS + 600) { rec.end = 'NOEND-hard'; break; }
  }
  // let the end screens run 3 s of frames, then leave to the floor
  await page.evaluate(() => window.__gx("(function(){ var t=(window.__SH&&window.__SH.ts)||performance.now(); for(var i=0;i<60;i++){ t+=50; HID.fromWorker=1; try{ loop(t); }catch(e){ window.__fz.errs.push({k:'post',m:String(e&&e.message||e),w:String(e&&e.stack||'')}); } finally{ HID.fromWorker=0; } } if(window.__SH){ window.__SH.ts=t; for(var k in window.__SH.held){ try{ window.dispatchEvent(new KeyboardEvent('keyup',{code:k})); }catch(e){} } window.__SH.held={}; } return 1; })()"));
  const po = JSON.parse(await page.evaluate(() => JSON.stringify(window.__fz.poll())));
  (po.errs || []).forEach(e => { if (rec.errs.length < 8) rec.errs.push(e.k + ': ' + e.m + ' | ' + String(e.w).split('\n').slice(0, 3).join(' / ')); });
  rec.gsec = Math.round(gsec); rec.wall = Math.round((Date.now() - t0) / 1000);
  rec.pe = perrs.splice(0, perrs.length).slice(0, 5);
  const cz = JSON.parse(await page.evaluate(c => window.__gx(c), CENSUS));
  if (!globalThis.__c0) globalThis.__c0 = cz;
  const c0 = globalThis.__c0, d = {};
  for (const sec of ['glob']) for (const k in cz[sec]) if (cz[sec][k] !== c0[sec][k]) d[sec + ':' + k] = (c0[sec][k] || 0) + '>' + cz[sec][k];
  for (const k in cz.ec) if (cz.ec[k] !== (c0.ec[k] || 0)) d['el:' + k] = (c0.ec[k] || 0) + '>' + cz.ec[k];
  for (const k of ['iv', 'dom', 'cv', 'heap', 'sk']) if (cz[k] !== c0[k]) d[k] = c0[k] + '>' + cz[k];
  rec.cdiff = d; if (n === RAIDS - 1) rec.ivl = cz.ivl;
  console.log(JSON.stringify(rec));
}
await browser.close(); srv.close(); process.exit(0);
