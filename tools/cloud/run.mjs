// Cloud test driver (Linux, headless Chromium 1920x1080). Serves the repo root over http.
//   node tools/cloud/run.mjs parse FILE            parsecheck.html?f=FILE, prints PASS/FAIL
//   node tools/cloud/run.mjs check FILE V [N]      runs every __REGRESS entry with v===V, N times (default 2)
//   node tools/cloud/run.mjs verify FILE           __verifySafe(): pass, ents, containers
//   node tools/cloud/run.mjs range FILE A B        __regressBg(A,B) slice, prints summary and fails
//   node tools/cloud/run.mjs eval FILE 'JS'       runs JS in the loaded page, prints the result
//   node tools/cloud/run.mjs net FILE [run|runsame] nettest.html?f=FILE, presses RUN or RUN SAME MACHINE, prints the result and log
// FILE is a name inside tools/. Exit code 0 only when the result is PASS.
import http from 'node:http'; import fs from 'node:fs'; import path from 'node:path';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
let pw; try { pw = require('playwright'); } catch (e) { pw = require('/opt/node22/lib/node_modules/playwright'); }
const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..', '..');
const TYPES = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.json': 'application/json', '.css': 'text/css', '.png': 'image/png', '.ogg': 'audio/ogg', '.mp3': 'audio/mpeg', '.wav': 'audio/wav' };
const srv = http.createServer((q, r) => {
  const p = path.join(ROOT, decodeURIComponent(q.url.split('?')[0]));
  if (!p.startsWith(ROOT) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) { r.writeHead(404); r.end(); return; }
  r.writeHead(200, { 'content-type': TYPES[path.extname(p)] || 'application/octet-stream' }); fs.createReadStream(p).pipe(r);
});
await new Promise(ok => srv.listen(0, '127.0.0.1', ok));
const base = 'http://127.0.0.1:' + srv.address().port + '/tools/';
const [cmd, file, a3, a4] = process.argv.slice(2);
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--autoplay-policy=no-user-gesture-required', '--use-fake-device-for-media-stream', '--use-fake-ui-for-media-stream'] });
const page = await (await browser.newContext({ viewport: { width: 1920, height: 1080 } })).newPage();
page.on('pageerror', e => console.log('pageerror: ' + e.message));
let ok = false;
async function load(f) {
  await page.goto(base + f, { waitUntil: 'load', timeout: 120000 });
  await page.evaluate(() => { try { localStorage.clear(); sessionStorage.clear(); } catch (e) {} });
  await page.goto(base + f, { waitUntil: 'load', timeout: 120000 });
  await page.waitForFunction(() => typeof window.__REGRESS !== 'undefined' && typeof window.__verifySafe === 'function', null, { timeout: 120000 });
  await page.waitForTimeout(1500);
}
try {
  if (cmd === 'parse') {
    await page.goto(base + 'parsecheck.html?f=' + encodeURIComponent(file), { waitUntil: 'load' });
    await page.waitForFunction(() => /^(PASS|FAIL)/.test(document.title), null, { timeout: 120000 });
    const t = await page.title(); ok = t.startsWith('PASS');
    console.log(t); if (!ok) console.log((await page.textContent('#out')).slice(0, 3000));
  } else if (cmd === 'check') {
    await load(file); const n = +(a4 || 2);
    const res = await page.evaluate(([v, n]) => {
      __runPrep(); const out = [];
      const L = __REGRESS.filter(t => t.v === v);
      if (!L.length) return ['NONE: no check with v ' + v];
      for (let k = 0; k < n; k++) for (const t of L) {
        __topClear(); let r; try { r = t.run(); } catch (e) { r = 'threw: ' + (e && e.stack || e); }
        out.push(r ? (String(r).indexOf('SKIP: ') === 0 ? 'SKIP ' + String(r).slice(6) : 'FAIL ' + r) : 'PASS');
      }
      return out;
    }, [a3, n]);
    res.forEach((r, i) => console.log('run ' + (i + 1) + ': ' + String(r).slice(0, 1500)));
    ok = res.length && res.every(r => r === 'PASS');
  } else if (cmd === 'verify') {
    await load(file);
    const r = await page.evaluate(() => { __runPrep(); const r = __verifySafe(); return { pass: r.pass, summary: r.summary, ents: r.ents, containers: r.containers, fail: r.fail }; });
    console.log(JSON.stringify(r)); ok = !!r.pass;
  } else if (cmd === 'range') {
    await load(file);
    console.log(await page.evaluate(([a, b]) => __regressBg(+a, +b), [a3, a4]));
    let last = ''; page.on('console', m => { const t = m.text(); if (t.startsWith('REGRESS start')) last = t; });
    try { await page.waitForFunction(() => window.__PROG && window.__PROG.finished, null, { timeout: +(process.env.RANGE_MS || 900000), polling: 2000 }); }
    catch (e) { const pr = await page.evaluate(() => window.__PROG ? { done: __PROG.done, cur: __PROG.cur } : null).catch(() => null); console.log('STUCK at ' + last + ' ' + JSON.stringify(pr)); throw e; }
    const r = await page.evaluate(() => __PROG.res);
    console.log(r.summary); r.fail.forEach(f => console.log('  ' + f.slice(0, 400))); ok = r.pass;
  } else if (cmd === 'seq') {
    // one check per evaluate, each with its own time limit, so a stalled check is named and the rest still run
    await load(file); await page.evaluate(() => __runPrep());
    const n = await page.evaluate(() => __REGRESS.length), a = +a3 || 0, b = Math.min(a4 === undefined ? n : +a4, n);
    const fails = []; let skip = 0, ran = 0;
    for (let i = a; i < b; i++) {
      const r = await Promise.race([page.evaluate(i => { __topClear(); const t = __REGRESS[i]; let r; try { r = t.run(); } catch (e) { r = 'threw: ' + (e && e.stack || e); } return { v: t.v, r: r ? String(r) : null }; }, i),
        new Promise(ok => setTimeout(() => ok({ v: '?', r: 'TIMEOUT at index ' + i }), +(process.env.CHECK_MS || 120000)))]);
      ran++;
      if (r.r && r.r.startsWith('SKIP: ')) skip++; else if (r.r) { fails.push('v' + r.v + ' [' + i + '] ' + r.r.slice(0, 300)); if (r.r.startsWith('TIMEOUT')) break; }
    }
    console.log((fails.length ? 'FAIL x' + fails.length : 'PASS') + ', ' + ran + ' run, ' + skip + ' skipped [' + a + ',' + b + ')'); fails.forEach(f => console.log('  ' + f)); ok = !fails.length;
  } else if (cmd === 'eval') {
    await load(file); const r = await page.evaluate(a3); console.log(typeof r === 'string' ? r : JSON.stringify(r)); ok = true;
  } else if (cmd === 'net') {
    const btn = '#' + (a3 || 'run');
    page.on('popup', p => p.setViewportSize({ width: 1920, height: 1080 }).catch(() => {}));
    await page.goto(base + 'nettest.html?f=' + encodeURIComponent(file) + (process.env.NETQ || ''), { waitUntil: 'load' });
    await page.waitForFunction(b => { const e = document.querySelector(b); return e && !e.disabled; }, btn, { timeout: 180000 });
    await page.click(btn);
    await page.waitForFunction(() => /^(PASS|FAIL)/.test(document.title), null, { timeout: 600000, polling: 1000 });
    ok = (await page.title()).startsWith('PASS');
    console.log(await page.textContent('#result')); console.log((await page.textContent('#log')).split('\n').slice(-80).join('\n'));
  } else { console.log('usage: parse|check|verify|range|net'); }
} catch (e) { console.log('driver error: ' + e.message); }
await browser.close(); srv.close(); process.exit(ok ? 0 : 1);
