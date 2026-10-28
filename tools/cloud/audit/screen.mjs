// node screen.mjs OUT NAME W H : one uishots screen from the shared staging list, from tools/fixture.html
import http from 'node:http'; import fs from 'node:fs'; import path from 'node:path';
import { createRequire } from 'node:module'; const require = createRequire(import.meta.url);
const pw = require('/opt/node22/lib/node_modules/playwright'); const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..', '..', '..');
const [out, name, W, H] = process.argv.slice(2);
const srv = http.createServer((q, r) => { const p = path.join(ROOT, decodeURIComponent(q.url.split('?')[0])); if (!fs.existsSync(p) || fs.statSync(p).isDirectory()) { r.writeHead(404); r.end(); return; } r.writeHead(200, { 'content-type': p.endsWith('.html') ? 'text/html; charset=utf-8' : 'application/octet-stream' }); fs.createReadStream(p).pipe(r); });
await new Promise(ok => srv.listen(0, '127.0.0.1', ok)); const base = 'http://127.0.0.1:' + srv.address().port + '/tools/';
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const page = await (await browser.newContext({ viewport: { width: +W, height: +H } })).newPage();
await page.goto(base + 'fixture.html'); await page.evaluate(() => localStorage.clear()); await page.goto(base + 'fixture.html');
await page.waitForFunction(() => typeof window.__gx === 'function' && typeof window.__deploy === 'function', null, { timeout: 120000 }); await page.waitForTimeout(1500);
const d = JSON.parse(fs.readFileSync(ROOT + '/tools/handoff/shots/ui-screens-js.json', 'utf8'));
await page.evaluate(d.prelude); const sc = d.screens.find(s => s.name.startsWith(name));
const r = await page.evaluate('(async function(){ var U=window.__uis; await U.prep(); ' + sc.js + ' })()');
const meas = await page.evaluate(() => { const c = document.querySelector('#mapcell, .mapcell, #lmap, canvas.premap'); return c ? JSON.stringify(c.getBoundingClientRect()) : ''; });
console.log(sc.name, W + 'x' + H, 'staged:', r, meas);
await page.screenshot({ path: `${out}/${sc.name}-${W}x${H}.jpg`, type: 'jpeg', quality: 80 });
await browser.close(); srv.close(); process.exit(0);
