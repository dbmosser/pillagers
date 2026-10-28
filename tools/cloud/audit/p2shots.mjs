// node p2shots.mjs OUTDIR MAPIX : the real 2-player arcade demo (two windows, paired), pictures from both windows
import http from 'node:http'; import fs from 'node:fs'; import path from 'node:path';
import { createRequire } from 'node:module';
const require = createRequire(import.meta.url);
const pw = require('/opt/node22/lib/node_modules/playwright');
const ROOT = path.resolve(path.dirname(new URL(import.meta.url).pathname), '..', '..', '..');
const [out, mapIx = '0'] = process.argv.slice(2); fs.mkdirSync(out, { recursive: true });
const srv = http.createServer((q, r) => { const p = path.join(ROOT, decodeURIComponent(q.url.split('?')[0]));
  if (!p.startsWith(ROOT) || !fs.existsSync(p) || fs.statSync(p).isDirectory()) { r.writeHead(404); r.end(); return; }
  r.writeHead(200, { 'content-type': p.endsWith('.html') ? 'text/html; charset=utf-8' : (p.endsWith('.js') ? 'text/javascript' : 'application/octet-stream') }); fs.createReadStream(p).pipe(r); });
await new Promise(ok => srv.listen(0, '127.0.0.1', ok));
const base = 'http://127.0.0.1:' + srv.address().port + '/tools/';
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--autoplay-policy=no-user-gesture-required'] });
const ctx = await browser.newContext({ viewport: { width: 1920, height: 1080 } });
const p1 = await ctx.newPage(); const errs = { p1: [], p2: [] }; p1.on('pageerror', e => errs.p1.push(e.message));
const gx = (pg, s) => pg.evaluate(s => window.__gx(s), s);
const log = []; const L = s => { log.push(s); console.log(s); };
await p1.goto(base + 'fixture.html', { waitUntil: 'load', timeout: 120000 });
await p1.evaluate(() => { try { localStorage.clear(); } catch (e) {} });
await p1.goto(base + 'fixture.html', { waitUntil: 'load', timeout: 120000 });
await p1.waitForFunction(() => typeof window.__gx === 'function' && typeof window.__deploy === 'function', null, { timeout: 120000 });
await p1.waitForTimeout(2000);
const r1 = await gx(p1, '(function(){ try{ __topClear(); __runPrep(); CAREER_ON=0; NET.sess="aud' + mapIx + '"; try{ localStorage.removeItem("salvagerun:p2raid"); localStorage.removeItem("salvagerun:p2live"); }catch(_lk){} window.__p2url=""; window.open=function(u){ window.__p2url=String(u); return {closed:false,focus:function(){}}; }; var r=arcadePick(); return JSON.stringify({ok:(r==="opened"&&NET.same==="host"&&!!ARCADE.on&&!!window.__p2url),r:r,url:window.__p2url}); }catch(e){ return "ERR "+e; } })()');
L('pick: ' + r1);
const url = new URL(JSON.parse(r1).url, base + 'fixture.html').href;
const p2 = await ctx.newPage(); p2.on('pageerror', e => errs.p2.push(e.message));
await p2.goto(url, { waitUntil: 'load', timeout: 120000 });
await p2.waitForFunction(() => typeof window.__gx === 'function' && typeof window.__deploy === 'function', null, { timeout: 120000 });
await p2.waitForTimeout(1500);
L('p2 modals at load: ' + await p2.evaluate(() => [].slice.call(document.querySelectorAll('.modal.on')).map(m => m.id).join(' ')));
const pad = fs.readFileSync(ROOT + '/tools/fuzz-pad.js', 'utf8').replaceAll('__SEED__', '12345');
L('pad: ' + await gx(p2, pad));
const P1PROBE = '(function(){ try{ return JSON.stringify({inn:netInCount(),arc:ARCADE.on?1:0,raid:(state==="raid"&&G)?1:0,garc:(G&&G.arcade)?1:0,err:NET.err||""}); }catch(e){ return "ERR "+e; } })()';
let linked = false, h = '', q = '';
for (let i = 0; i < 60 && !linked; i++) { h = await gx(p1, P1PROBE); q = await gx(p2, P1PROBE); if (/"inn":[1-9]/.test(h) && /"arc":1/.test(q)) linked = true; else await p1.waitForTimeout(750); }
L('linked ' + linked + ' host=' + h + ' p2=' + q);
L('deploy: ' + await gx(p1, '(function(){ try{ try{ attStop(); }catch(_a){} var ok=arcadeDeploy({role:"host",mapIx:' + mapIx + ',seed:4242}); return JSON.stringify({ok:!!(ok&&G&&G.arcade&&!ARCADE.solo&&NET.on)}); }catch(e){ return "ERR "+e; } })()'));
let joined = false;
for (let i = 0; i < 60 && !joined; i++) { if (i % 5 === 1) await gx(p2, 'window.__fzpad.press(0,300)'); await p1.waitForTimeout(800); q = await gx(p2, P1PROBE); if (/"raid":1/.test(q) && /"garc":1/.test(q)) joined = true; }
L('joined ' + joined + ' p2=' + q);
await gx(p2, 'window.__fzpad.on=false');
L('p2 modals after join: ' + await p2.evaluate(() => [].slice.call(document.querySelectorAll('.modal.on')).map(m => m.id).join(' ')) + ' wn=' + await gx(p2, 'JSON.stringify({seen:P.whatsNewSeen||P.wnSeen||null, WV:typeof WHATSNEW_VER!=="undefined"?WHATSNEW_VER:null})'));

for (const [tag, ms] of [['a', 4000], ['b', 8000]]) {
  await p1.waitForTimeout(ms);
  await p1.screenshot({ path: `${out}/m${mapIx}-${tag}-p1.jpg`, type: 'jpeg', quality: 78 });
  await p2.screenshot({ path: `${out}/m${mapIx}-${tag}-p2.jpg`, type: 'jpeg', quality: 78 });
  L(tag + ' easy p1 ' + await gx(p1, 'JSON.stringify({ask:ARCADE.easyAsk||null,asked:ARCADE.easyAsked,easy:ARCADE.easy,role:ARCADE.role,live:easyLive()})') + ' p2 ' + await gx(p2, 'JSON.stringify({ask:ARCADE.easyAsk||null,asked:ARCADE.easyAsked,easy:ARCADE.easy,role:ARCADE.role,live:easyLive()})'));
  L(tag + ' p1 ' + await gx(p1, 'JSON.stringify({hp:G.player.hp|0, mates:(G.ents||[]).filter(function(e){return e&&e.friendlyPC}).length})') + ' p2 ' + await gx(p2, 'JSON.stringify({hp:G.player.hp|0})'));
}
L('page errors p1 ' + errs.p1.length + ' p2 ' + errs.p2.length + ' ' + (errs.p1[0] || errs.p2[0] || ''));
fs.writeFileSync(out + `/log-m${mapIx}.txt`, log.join('\n') + '\n');
await browser.close(); srv.close(); process.exit(0);
