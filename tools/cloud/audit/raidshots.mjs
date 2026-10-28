// node raidshots.mjs OUTDIR [W H] : 1-player raid pictures on the 4 maps, day and night, 3 spots each, from tools/fixture.html
import http from 'node:http'; import fs from 'node:fs'; import path from 'node:path';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const pw = require('/opt/node22/lib/node_modules/playwright');
const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..', '..', '..');
const [out, W = 1920, H = 1080] = process.argv.slice(2); fs.mkdirSync(out, { recursive: true });
const srv = http.createServer((q, r) => { const p = path.join(ROOT, decodeURIComponent(q.url.split('?')[0]));
  if (!p.startsWith(ROOT) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) { r.writeHead(404); r.end(); return; }
  r.writeHead(200, { 'content-type': p.endsWith('.html') ? 'text/html; charset=utf-8' : (p.endsWith('.js') ? 'text/javascript' : 'application/octet-stream') }); fs.createReadStream(p).pipe(r); });
await new Promise(ok => srv.listen(0, '127.0.0.1', ok));
const base = 'http://127.0.0.1:' + srv.address().port + '/tools/';
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--autoplay-policy=no-user-gesture-required'] });
const page = await (await browser.newContext({ viewport: { width: +W, height: +H } })).newPage();
const errs = []; page.on('pageerror', e => errs.push(e.message));
await page.goto(base + 'fixture.html', { waitUntil: 'load', timeout: 120000 });
await page.evaluate(() => { try { localStorage.clear(); } catch (e) {} });
await page.goto(base + 'fixture.html', { waitUntil: 'load', timeout: 120000 });
await page.waitForFunction(() => typeof window.__deploy === 'function' && typeof window.__gx === 'function', null, { timeout: 120000 });
await page.waitForTimeout(2000);
const pre = JSON.parse(fs.readFileSync(ROOT + '/tools/handoff/shots/ui-screens-js.json', 'utf8')).prelude;
await page.evaluate(pre);
const log = [];
for (let m = 0; m < 4; m++) for (const cond of ['day', 'night']) {
  const info = await page.evaluate(async ([m, cond]) => { const U = window.__uis;
    try { __gx('try{ if(G&&!G.over) __endRaid(); }catch(e){}'); } catch (e) {}
    __gx('P.cond=' + JSON.stringify(cond));
    U.dep({ kit: ['gun_carbine', 'medkit', 'bandage', 'bandage', 'plate', 'frag', 'smoke'], seed: 4242, mapIx: m });
    __gx('G.player.hp=G.player.maxHp||100;');
    await U.wait(4000);
    return __gx('JSON.stringify({map:(G.map&&(G.map.name||G.map.id))||G.mapIx, cond:P.cond, night:!!G.night, ents:G.ents.length, cont:(G.containers||[]).length, px:Math.round(G.player.x), py:Math.round(G.player.y), W:(G.map&&G.map.w), H:(G.map&&G.map.h)})');
  }, [m, cond]);
  log.push('map ' + m + ' ' + cond + ' ' + info);
  await page.screenshot({ path: `${out}/m${m}-${cond}-a-spawn.jpg`, type: 'jpeg', quality: 78 });
  for (const [tag, frac] of [['b-mid', 0.5], ['c-far', 0.95]]) {
    const r = await page.evaluate(async ([frac]) => { const U = window.__uis;
      const s = __gx('(function(){ var p=G.player, L=(G.containers||[]).slice().sort(function(a,b){ return Math.hypot(a.x-p.x,a.y-p.y)-Math.hypot(b.x-p.x,b.y-p.y); }); var c=L[Math.min(L.length-1,Math.floor(L.length*' + frac + '))]; if(!c) return "none"; p.x=c.x+30; p.y=c.y+40; p.hp=p.maxHp||100; return Math.round(c.x)+","+Math.round(c.y)+" "+(c.kind||c.type||""); })()');
      await U.wait(2500); __gx('G.player.hp=G.player.maxHp||100'); return s; }, [frac]);
    log.push('  ' + tag + ' at ' + r);
    await page.screenshot({ path: `${out}/m${m}-${cond}-${tag}.jpg`, type: 'jpeg', quality: 78 });
  }
}
log.push('page errors: ' + errs.length + (errs.length ? ' first: ' + errs[0] : ''));
fs.writeFileSync(out + '/log.txt', log.join('\n') + '\n'); console.log(log.join('\n'));
await browser.close(); srv.close(); process.exit(0);
