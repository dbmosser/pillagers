// node prof2.mjs FILE MAPIX SECS [W H] [TOPN] : pinned-quality raid profile -> frame stats, game pass timings, top self-time functions
import http from 'node:http'; import fs from 'node:fs'; import path from 'node:path';
import { createRequire } from 'node:module'; const require = createRequire(import.meta.url);
const pw = require('/opt/node22/lib/node_modules/playwright'); const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..', '..', '..');
const [file, mapIx = '1', secs = '12', W = '1920', H = '1080', TOPN = '25'] = process.argv.slice(2);
const srv = http.createServer((q, r) => { const p = path.join(ROOT, decodeURIComponent(q.url.split('?')[0])); if (!fs.existsSync(p) || fs.statSync(p).isDirectory()) { r.writeHead(404); r.end(); return; } r.writeHead(200, { 'content-type': p.endsWith('.html') ? 'text/html; charset=utf-8' : 'application/octet-stream' }); fs.createReadStream(p).pipe(r); });
await new Promise(ok => srv.listen(0, '127.0.0.1', ok)); const base = 'http://127.0.0.1:' + srv.address().port + '/tools/';
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const page = await (await browser.newContext({ viewport: { width: +W, height: +H } })).newPage();
await page.goto(base + file); await page.evaluate(() => localStorage.clear()); await page.goto(base + file);
await page.waitForFunction(() => typeof window.__gx === 'function', null, { timeout: 120000 }); await page.waitForTimeout(2500);
const info = await page.evaluate((m) => {
  var t=document.getElementById('title'); if(t) t.classList.remove('on'); [].slice.call(document.querySelectorAll('.modal.on')).forEach(function(x){ x.classList.remove('on'); });
  __gx("P.cond='day'; P.stash=['gun_carbine','medkit','bandage']; P.kit=P.stash.slice(); P.kitChosen=0; P.dropKit=[]; P.freeKit=0; try{ commitKit(); }catch(e){} try{ MAPFIRST.skip=1; }catch(e){} P.mapIx="+(+m)+"; pendSeed=4242; startRaid();");
  return __gx("(function(){ var o={}; try{ CFG.gfxAuto=0; CFG.gfxPost=1; CFG.gfxLight=2; CFG.fxInt=1; DRS.q=0; DRS.scale=1; gfxqApply(); o.pinned=1; }catch(e){ o.pinned='no: '+e.message; } o.ver=VER; o.ents=G.ents.length; o.map=G.map&&G.map.name; return JSON.stringify(o); })()"); }, mapIx);
// keep the player alive and still; one hp top-up a second, no input
await page.evaluate(() => { window.__keep = setInterval(() => { try { __gx('if(G&&G.player){ G.player.hp=G.player.maxHp||100; G.player.downed=0; }'); } catch (e) {} }, 1000); });
await page.waitForTimeout(3000);
const cdp = await page.context().newCDPSession(page);
await cdp.send('Profiler.enable'); await cdp.send('Profiler.setSamplingInterval', { interval: 200 });
await page.evaluate(() => { window.__ft = []; let last = performance.now(); (function f(t) { window.__ft.push(t - last); last = t; if (window.__ft.length < 100000) requestAnimationFrame(f); })(performance.now()); });
await cdp.send('Profiler.start');
await page.waitForTimeout(+secs * 1000);
const { profile } = await cdp.send('Profiler.stop');
const ft = await page.evaluate(() => window.__ft.slice(2));
const tel = await page.evaluate(() => __gx('JSON.stringify((G&&G.tel&&G.tel.gfx)||null)'));
const alive = await page.evaluate(() => __gx('JSON.stringify({over:!!G.over,hp:G.player.hp|0,scale:(typeof DRS!=="undefined"?DRS.scale:null)})'));
ft.sort((a, b) => a - b); const sum = ft.reduce((a, b) => a + b, 0);
const byId = {}; for (const n of profile.nodes) byId[n.id] = n;
const self = {}; let tot = 0, idle = 0, prog = 0, gc = 0;
profile.samples.forEach((id, i) => { const dt = (profile.timeDeltas[i] || 0) / 1000; const n = byId[id]; const cf = n.callFrame; const name = cf.functionName || '(anon)';
  tot += dt; if (name === '(idle)') { idle += dt; return; } if (name === '(program)') { prog += dt; return; } if (name === '(garbage collector)') { gc += dt; return; }
  const k = name + ' :' + (cf.lineNumber + 1) + (cf.url.includes('tools/') ? '' : ' [' + cf.url.split('/').pop() + ']'); self[k] = (self[k] || 0) + dt; });
const js = tot - idle - prog - gc; const frames = ft.length;
const top = Object.entries(self).sort((a, b) => b[1] - a[1]).slice(0, +TOPN);
console.log('BUILD ' + info + ' ' + W + 'x' + H + ' ' + secs + 's alive=' + alive);
console.log('frames ' + frames + ' avg ' + (sum / frames).toFixed(1) + ' ms p50 ' + ft[Math.floor(frames * .5)].toFixed(1) + ' p95 ' + ft[Math.floor(frames * .95)].toFixed(1) + ' | js ' + (js / frames).toFixed(2) + ' ms/frame, gc ' + (gc / frames).toFixed(2) + ', program ' + (prog / frames).toFixed(2) + ', idle ' + (idle / frames).toFixed(2));
console.log('game tel ' + tel);
for (const [k, v] of top) console.log((v / frames).toFixed(3).padStart(7) + ' ms/frame ' + (100 * v / js).toFixed(1).padStart(5) + '%  ' + k);
clearInterval; await browser.close(); srv.close(); process.exit(0);
