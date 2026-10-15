// Cloud tool: makes a real save from an old build kept in tools/ (a fixture or a bare game) and prints it.
//   node tools/cloud/oldsave.mjs FILE [RAIDS]   FILE inside tools/. Plays RAIDS career raids (default 2) through __deploy when the
//   build has it, each ended by extraction, then prints localStorage['salvagerun:profile'] (one JSON line).
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
const [file, raidsA = '2'] = process.argv.slice(2);
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const page = await (await browser.newContext({ viewport: { width: 1920, height: 1080 } })).newPage();
page.on('pageerror', e => console.error('pageerror: ' + e.message));
await page.goto(base + file, { waitUntil: 'load', timeout: 180000 });
await page.evaluate(() => { try { localStorage.clear(); } catch (e) {} });
await page.goto(base + file, { waitUntil: 'load', timeout: 180000 });
await page.waitForTimeout(6000);
const r = await page.evaluate(async (n) => {
  const log = [];
  try { if (window.__runPrep) __runPrep(); } catch (e) { log.push('prep ' + e); }
  for (let i = 0; i < n; i++) {
    try {
      if (!window.__deploy) { log.push('no __deploy'); break; }
      __deploy({ kit: ['bandage', 'medkit'], mapIx: 0, seed: 100 + i });
      const g = __state(); const t = performance.now();
      for (let f = 0; f < 600; f++) { try { __loop(t + f * 50); } catch (e) {} if (!__state() || __state().over) break; }
      const g2 = __state();
      if (g2 && !g2.over) {
        // carry something out: give the backpack a few items when the build has the bag, then extract
        try { if (Array.isArray(g2.bag) && g2.bag.length < 3) g2.bag.push({ id: 'scrap', n: 2 }); } catch (e) {}
        __endRaid(i % 2 ? 'death' : 'extract');
      }
      for (let f = 0; f < 60; f++) { try { __loop(performance.now() + f * 50); } catch (e) {} }
      try { const oc = document.getElementById('outcome'); if (oc) oc.classList.remove('on'); } catch (e) {}
      log.push('raid ' + i + ' ok');
    } catch (e) { log.push('raid ' + i + ' threw ' + e); }
  }
  await new Promise(ok => setTimeout(ok, 1500));
  return { log, ver: (typeof VER !== 'undefined' ? VER : (window.__gx ? window.__gx('VER') : '?')), save: localStorage.getItem('salvagerun:profile') };
}, +raidsA);
console.error(JSON.stringify({ ver: r.ver, log: r.log, len: r.save ? r.save.length : 0 }));
console.log(r.save || '');
await browser.close(); srv.close(); process.exit(0);
