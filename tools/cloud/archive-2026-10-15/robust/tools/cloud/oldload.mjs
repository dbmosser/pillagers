// Cloud tool: loads a saved profile (a JSON file) into the current fixture as salvagerun:profile, boots, then opens every
// menu render, applies every kit choice, plays a CAREER raid to extraction and a DEMO run, and checks the save round trip.
//   node tools/cloud/oldload.mjs FILE SAVEJSON
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
const [file, saveF] = process.argv.slice(2);
const save = fs.readFileSync(saveF, 'utf8').trim();
const browser = await pw.chromium.launch({ executablePath: '/opt/pw-browsers/chromium' });
const page = await (await browser.newContext({ viewport: { width: 1920, height: 1080 } })).newPage();
const pe = []; page.on('pageerror', e => pe.push((e.stack || e.message).split('\n').slice(0, 3).join(' / ')));
await page.goto(base + file, { waitUntil: 'load', timeout: 180000 });
await page.evaluate(s => { localStorage.clear(); localStorage.setItem('salvagerun:profile', s); }, save);
await page.goto(base + file, { waitUntil: 'load', timeout: 180000 });
await page.waitForFunction(() => typeof window.__gx === 'function', null, { timeout: 180000 });
await page.waitForTimeout(4000);
console.log('boot pageerrors: ' + JSON.stringify(pe.splice(0)));
const r = await page.evaluate(() => window.__gx(`(function(){
  var out={errs:[],steps:[]}, i, k;
  function tr(n,f){ try{ var v=f(); out.steps.push(n+(v!==undefined?'='+String(v).slice(0,60):'')); }catch(e){ out.errs.push(n+': '+(e&&e.stack||e).split('\\n').slice(0,3).join(' / ')); } }
  function frames(n){ var t=performance.now(); for(var f=0;f<n;f++){ t+=50; HID.fromWorker=1; try{ loop(t); }catch(e){ out.errs.push('loop: '+(e&&e.stack||e).split('\\n').slice(0,3).join(' / ')); break; } finally{ HID.fromWorker=0; } } }
  tr('ver',function(){ return VER+' credits '+P.credits+' keys '+Object.keys(P).length; });
  tr('crashes at boot',function(){ return JSON.stringify(P.crashes||[]).slice(0,300); });
  try{ var _bt=document.getElementById('title'); if(_bt) _bt.classList.remove('on'); }catch(e){}
  tr('hub frames',function(){ frames(40); });
  ['renderHub','renderShop','renderShopGrid','renderMainframe','renderRoadmap','renderCarry','renderTerms','renderSeason','renderMerc','renderMercGrid','renderGamble','renderWirtLot','renderCrate','renderKitCol','renderWork','renderCraftGrid','renderParty','renderSector','renderFreeKit','renderSettings','renderTrophies','renderCodex','trophyOpen','codexOpen'].forEach(function(n){ tr(n,function(){ var f=eval(n); if(typeof f!=='function') return 'absent'; f(); }); });
  tr('trophyScan',function(){ trophyScan(false); });
  ['mine','free','random','best'].forEach(function(kd){ tr('kitApply '+kd,function(){ kitApply(kd); return JSON.stringify(P.kit||[]).slice(0,80)+' eq '+P.equipped; }); });
  tr('saveProfile',function(){ saveProfile(); });
  tr('career raid',function(){ CAREER_ON=1; __deploy({kit:['bandage'],mapIx:0,seed:777}); frames(400); if(G&&!G.over) endRaid('extract'); frames(120); return 'over '+(G&&G.over)+' state '+state; });
  tr('outcome close',function(){ var oc=document.getElementById('outcome'); if(oc) oc.classList.remove('on'); showScreen('hub'); frames(20); });
  tr('career raid 2 death',function(){ __deploy({kit:[],mapIx:1,seed:778}); frames(200); if(G&&!G.over) endRaid('death'); frames(120); var oc=document.getElementById('outcome'); if(oc) oc.classList.remove('on'); showScreen('hub'); frames(20); });
  tr('demo run',function(){ CAREER_ON=0; arcadeSoloPick(); arcadeDeploy({mapIx:0,seed:779}); frames(400); if(G&&G.arcade&&!G.over){ if(!arcadeRunEnd('quit')) arcadeRaidStop('end'); } frames(120); arcadeLeave(); frames(20); return 'state '+state+' arc '+ARCADE.on; });
  tr('crashes after',function(){ return JSON.stringify(P.crashes||[]).slice(0,400); });
  tr('save',function(){ saveProfile(); });
  out.P=JSON.stringify(P);
  return JSON.stringify(out); })()`));
const o = JSON.parse(r);
console.log('steps: ' + o.steps.join(' | '));
console.log('errs: ' + JSON.stringify(o.errs, null, 1));
await page.waitForTimeout(1500);
// round trip: reload and compare P to what was saved
const before = o.P;
await page.goto(base + file, { waitUntil: 'load', timeout: 180000 });
await page.waitForFunction(() => typeof window.__gx === 'function', null, { timeout: 180000 });
await page.waitForTimeout(4000);
const after = await page.evaluate(() => window.__gx('JSON.stringify(P)'));
const A = JSON.parse(before), B = JSON.parse(after), diff = [];
for (const k of new Set([...Object.keys(A), ...Object.keys(B)])) if (JSON.stringify(A[k]) !== JSON.stringify(B[k])) diff.push(k + ': ' + JSON.stringify(A[k]).slice(0, 120) + ' -> ' + JSON.stringify(B[k]).slice(0, 120));
console.log('round trip diffs: ' + JSON.stringify(diff, null, 1));
console.log('pageerrors: ' + JSON.stringify(pe));
await browser.close(); srv.close(); process.exit(0);
