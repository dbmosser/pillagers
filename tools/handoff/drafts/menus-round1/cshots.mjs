// node cshots.mjs FILE OUTDIR name,name,...  : the uishots recipes (tools/handoff/shots/ui-screens-js.json) in cloud headless Chromium, 1920x1080
import http from 'node:http'; import fs from 'node:fs'; import path from 'node:path';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const pw = require('/opt/node22/lib/node_modules/playwright');
const ROOT = '/home/user/pillagers';
const srv = http.createServer((q, r) => { const p = path.join(ROOT, decodeURIComponent(q.url.split('?')[0]));
  if (!p.startsWith(ROOT) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) { r.writeHead(404); r.end(); return; }
  r.writeHead(200, { 'content-type': p.endsWith('.html') ? 'text/html; charset=utf-8' : 'application/octet-stream' }); fs.createReadStream(p).pipe(r); });
await new Promise(ok => srv.listen(0, '127.0.0.1', ok));
const [file, out, names] = process.argv.slice(2);
const D = JSON.parse(fs.readFileSync(ROOT + '/tools/handoff/shots/ui-screens-js.json', 'utf8'));
const want = names.split(',');
fs.mkdirSync(out, { recursive: true });
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--autoplay-policy=no-user-gesture-required'] });
for (const s of D.screens.filter(s => want.includes(s.name))) {
  const page = await (await browser.newContext({ viewport: { width: 1920, height: 1080 } })).newPage();
  const errs = []; page.on('pageerror', e => errs.push(e.message));
  const url = 'http://127.0.0.1:' + srv.address().port + '/tools/' + file + (s.query || '');
  try {
    await page.goto(url, { waitUntil: 'load', timeout: 120000 });
    await page.evaluate(() => { try { localStorage.clear(); } catch (e) {} });
    await page.goto(url, { waitUntil: 'load', timeout: 120000 });
    await page.waitForFunction(() => document.readyState === 'complete' && typeof window.__topClear === 'function' && typeof window.__deploy === 'function', null, { timeout: 120000 });
    await page.waitForTimeout(1200);
    await page.evaluate(D.prelude);
    const r = await page.evaluate(async (js) => { const U = window.__uis; try { const f = new Function('U', 'return (async function(){' + js + '})();'); return await f(U); } catch (e) { return 'THREW ' + e.message; } }, s.js);
    const ok = s.expect ? await page.evaluate((x) => { const U = window.__uis; try { return !!eval(x); } catch (e) { return false; } }, s.expect) : true;
    await page.waitForTimeout(400);
    await page.screenshot({ path: out + '/' + s.name + '.png' });
    console.log(s.name, ok ? 'OK' : 'NOT STAGED', r ? String(r).slice(0, 80) : '', errs.length ? 'errs:' + errs[0].slice(0, 80) : '');
  } catch (e) { console.log(s.name, 'FAIL', e.message.slice(0, 120)); }
  await page.context().close();
}
await browser.close(); srv.close();
