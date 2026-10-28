// node multi.mjs FILE V1,V2,...  : load FILE (inside tools/) once, run each version's checks once, print one line each
import http from 'node:http'; import fs from 'node:fs'; import path from 'node:path';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const pw = require('/opt/node22/lib/node_modules/playwright');
const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..', '..', '..');
const srv = http.createServer((q, r) => { const p = path.join(ROOT, decodeURIComponent(q.url.split('?')[0]));
  if (!p.startsWith(ROOT) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) { r.writeHead(404); r.end(); return; }
  r.writeHead(200, { 'content-type': p.endsWith('.html') ? 'text/html; charset=utf-8' : 'application/octet-stream' }); fs.createReadStream(p).pipe(r); });
await new Promise(ok => srv.listen(0, '127.0.0.1', ok));
const base = 'http://127.0.0.1:' + srv.address().port + '/tools/';
const [file, list] = process.argv.slice(2);
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--autoplay-policy=no-user-gesture-required'] });
const page = await (await browser.newContext({ viewport: { width: +(process.env.VW||1920), height: +(process.env.VH||1080) } })).newPage();
await page.goto(base + file, { waitUntil: 'load', timeout: 120000 });
await page.evaluate(() => { try { localStorage.clear(); sessionStorage.clear(); } catch (e) {} });
await page.goto(base + file, { waitUntil: 'load', timeout: 120000 });
await page.waitForFunction(() => typeof window.__REGRESS !== 'undefined', null, { timeout: 120000 });
await page.waitForTimeout(1500);
const ver = await page.evaluate(() => typeof VER !== 'undefined' ? VER : '?');
await page.evaluate(() => __runPrep());
for (const v of list.split(',')) {
  const r = await Promise.race([page.evaluate(v => { const L = __REGRESS.filter(t => t.v === v); if (!L.length) return 'NONE';
    return L.map(t => { __topClear(); let r; try { r = t.run(); } catch (e) { r = 'threw: ' + (e && e.message || e); } return r ? (String(r).startsWith('SKIP') ? 'SKIP' : 'FAIL ' + String(r).slice(0, 220)) : 'PASS'; }).join(' | '); }, v),
    new Promise(ok => setTimeout(() => ok('TIMEOUT'), 150000))]);
  console.log('[' + ver + '] ' + v + ': ' + r);
}
await browser.close(); srv.close(); process.exit(0);
