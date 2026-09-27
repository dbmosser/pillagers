// 4K frame profile: node tools/cloud/prof.mjs FILE [W H] -> frame ms stats and the top self-time functions over 6 s of a raid.
import http from 'node:http'; import fs from 'node:fs'; import path from 'node:path';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
let pw; try { pw = require('playwright'); } catch (e) { pw = require('/opt/node22/lib/node_modules/playwright'); }
const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..', '..');
const srv = http.createServer((q, r) => { const p = path.join(ROOT, decodeURIComponent(q.url.split('?')[0])); if (!p.startsWith(ROOT) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) { r.writeHead(404); r.end(); return; } r.writeHead(200, { 'content-type': p.endsWith('.html') ? 'text/html; charset=utf-8' : 'application/octet-stream' }); fs.createReadStream(p).pipe(r); });
await new Promise(ok => srv.listen(0, '127.0.0.1', ok));
const [file, w, h] = process.argv.slice(2);
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: (process.env.PROF_ARGS||'--enable-gpu-rasterization --ignore-gpu-blocklist').split(' ') });
const page = await (await browser.newContext({ viewport: { width: +(w || 3840), height: +(h || 2160) } })).newPage();
page.on('pageerror', e => console.log('pageerror: ' + e.message));
const url = 'http://127.0.0.1:' + srv.address().port + '/tools/' + file;
await page.goto(url, { waitUntil: 'load' }); await page.evaluate(() => localStorage.clear()); await page.goto(url, { waitUntil: 'load' });
await page.waitForFunction(() => typeof window.__deploy === 'function', null, { timeout: 120000 });
await page.evaluate(() => { try { __runPrep(); } catch (e) {} __deploy({ kit: [], safe: null, mapIx: 0, seed: 4242 }); });
await page.waitForTimeout(2500);
const cdp = await page.context().newCDPSession(page);
await cdp.send('Profiler.enable'); await cdp.send('Profiler.setSamplingInterval', { interval: 500 });
await page.evaluate(() => { window.__ft = []; let last = performance.now(); (function f(t) { window.__ft.push(t - last); last = t; if (window.__ft.length < 100000) requestAnimationFrame(f); })(performance.now()); });
await cdp.send('Profiler.start');
await page.waitForTimeout(6000);
const { profile } = await cdp.send('Profiler.stop');
const ft = await page.evaluate(() => window.__ft.slice(2));
ft.sort((a, b) => a - b);
const avg = ft.reduce((a, b) => a + b, 0) / ft.length;
console.log('frames ' + ft.length + ' in 6 s; avg ' + avg.toFixed(1) + ' ms; p50 ' + ft[Math.floor(ft.length * .5)].toFixed(1) + '; p95 ' + ft[Math.floor(ft.length * .95)].toFixed(1));
const self = {}, byId = {}; let total = 0;
for (const n of profile.nodes) byId[n.id] = n;
const dt = profile.timeDeltas; const cnt = {};
for (let i = 0; i < profile.samples.length; i++) { cnt[profile.samples[i]] = (cnt[profile.samples[i]] || 0) + (dt[i] || 0); }
for (const id in cnt) { const n = byId[id]; const k = n.callFrame.functionName || '(anon)'; const key = k + ':' + n.callFrame.lineNumber; self[key] = (self[key] || 0) + cnt[id]; total += cnt[id]; }
const parent = {}; for (const n of profile.nodes) for (const c of (n.children || [])) parent[c] = n.id;
const byJs = {};
for (const id in cnt) { let n = byId[id], nat = n.callFrame.lineNumber < 0 ? n.callFrame.functionName : null; let q = n; while (q && q.callFrame.lineNumber < 0 && parent[q.id]) q = byId[parent[q.id]]; if (!nat) continue; const k = nat + ' <- ' + (q.callFrame.functionName || '(anon)') + ':' + q.callFrame.lineNumber; byJs[k] = (byJs[k] || 0) + cnt[id]; }
console.log('--- canvas time by caller');
for (const [k, v] of Object.entries(byJs).sort((a, b) => b[1] - a[1]).slice(0, 25)) console.log((v / total * 100).toFixed(1).padStart(5) + '%  ' + k);
console.log('--- self');
const top = Object.entries(self).sort((a, b) => b[1] - a[1]).slice(0, 30);
for (const [k, v] of top) console.log((v / total * 100).toFixed(1).padStart(5) + '%  ' + k);
await browser.close(); srv.close();
