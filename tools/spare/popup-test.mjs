// popup-test.mjs : 11-01 (Main PC Correspondent, the main PC Claude's "does same machine co-op join"). tools/nettest.html frames player 1
// and stands in for player 2 with another iframe, so it only tests the framed path (itch). This tests his own case: player 1 is a top
// level page, 2 PLAYER CO-OP (SAME MACHINE) opens a real popup, and the two pair over their real channel. A real Chrome window (off screen,
// no --headless), its own temp profile and downloads folder, its own test server. Never port 8802. Calls no AI. Popups are allowed by a
// flag, because a script click is not his click, so the blocker and RETRY are not tested here. Everything it starts is ended by PID.
// Player 1 carries ?netslot=A only because the game gives its test handle to such a copy; its player 2 address is the plain top level one.
// Usage: node tools/spare/popup-test.mjs [--root DIR] [--port 8818] [--cdp 9336] [--headless]. Exit 0 pass, 1 fail, 2 could not run.
import { spawn } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const arg = (k, d) => { const i = process.argv.indexOf('--' + k); return i > 0 ? process.argv[i + 1] : d; };
const R = path.resolve(arg('root', path.join(path.dirname(fileURLToPath(import.meta.url)), '..', '..')));
const T = path.join(R, 'tools');
const PORT = +arg('port', 8818), CDP = +arg('cdp', 9336);
const PAGE = 'fixture-soak-' + PORT + '.html';
const sleep = ms => new Promise(r => setTimeout(r, ms));
const say = s => console.log(new Date().toTimeString().slice(0, 8) + ' ' + s);
const CHROME = ['C:/Program Files/Google/Chrome/Application/chrome.exe', 'C:/Program Files (x86)/Google/Chrome/Application/chrome.exe',
  path.join(process.env.LOCALAPPDATA || '', 'Google/Chrome/Application/chrome.exe')].find(p => fs.existsSync(p));

async function pages() { return (await (await fetch('http://127.0.0.1:' + CDP + '/json')).json()).filter(p => p.type === 'page'); }
function evalIn(pg, expr) {
  return new Promise((res, rej) => {
    const ws = new WebSocket(pg.webSocketDebuggerUrl), to = setTimeout(() => { try { ws.close(); } catch (e) {} rej(new Error('no answer')); }, 20000);
    ws.onopen = () => ws.send(JSON.stringify({ id: 1, method: 'Runtime.evaluate', params: { expression: expr, returnByValue: true } }));
    ws.onmessage = m => { const j = JSON.parse(m.data); if (j.id !== 1) return; clearTimeout(to); ws.close(); res(j.result && j.result.result ? j.result.result.value : undefined); };
    ws.onerror = () => { clearTimeout(to); rej(new Error('socket')); };
  });
}
const LOOK = "JSON.stringify((function(){var n=window.__net,s=null,r=null,pl=document.getElementById('p2line');try{s=n.same()}catch(e){}try{r=n.state().roster}catch(e){}"
  + "return{ver:n&&n.ver,key:n&&n.key,p2:n&&n.p2,same:s,roster:r,title:document.title,p2line:pl?{shown:pl.style.display!=='none',text:pl.textContent}:null,msg:(document.getElementById('modemsg')||{}).textContent||''}})())";

let srv = null, ch = null, code = 2;
const fixture = path.join(T, 'fixture.html'), copy = path.join(T, PAGE);
const prof = fs.mkdtempSync(path.join(os.tmpdir(), 'pillagers-popup-'));
try {
  if (!CHROME) throw new Error('no Chrome');
  if (!fs.existsSync(fixture)) throw new Error('no ' + fixture);
  fs.copyFileSync(fixture, copy);   // its own copy: a rebuilt fixture.html mid-run must not change the build
  fs.mkdirSync(path.join(prof, 'Default'), { recursive: true });
  fs.writeFileSync(path.join(prof, 'Default', 'Preferences'), JSON.stringify({ download: { default_directory: path.join(prof, 'dl'), prompt_for_download: false }, profile: { default_content_setting_values: { automatic_downloads: 2 } } }));
  srv = spawn(process.execPath, [path.join(T, 'spare', 'serve.mjs'), '--root', T, '--port', String(PORT)], { stdio: 'ignore', windowsHide: true });
  const flags = ['--remote-debugging-port=' + CDP, '--user-data-dir=' + prof, '--no-first-run', '--no-default-browser-check', '--disable-popup-blocking',
    '--disable-background-timer-throttling', '--disable-renderer-backgrounding', '--disable-backgrounding-occluded-windows', '--autoplay-policy=no-user-gesture-required',
    '--window-size=1280,720', '--window-position=-3000,0', 'http://localhost:' + PORT + '/' + PAGE + '?netslot=A'];
  if (process.argv.includes('--headless')) flags.unshift('--headless=new');
  ch = spawn(CHROME, flags, { stdio: 'ignore' });
  let A = null;
  for (let i = 0; i < 40 && !A; i++) { await sleep(1000); try { A = (await pages()).find(p => p.url.includes(PAGE)); } catch (e) {} }
  if (!A) throw new Error('the test Chrome did not open the page');
  let up = false;
  for (let i = 0; i < 90 && !up; i++) { await sleep(1000); try { up = await evalIn(A, "!!(window.__net&&document.getElementById('modecoop')&&!window.__preReload)"); } catch (e) {} }
  if (!up) throw new Error('player 1 did not boot in 90 s');
  await sleep(3000);
  say('player 1 up: ' + await evalIn(A, LOOK));
  const t0 = Date.now();
  await evalIn(A, "(function(){try{if(window.__hubEnter)window.__hubEnter()}catch(e){};document.getElementById('modecoop').click();return 1})()");
  let C = null, a = null, c = null, joined = false;
  while (Date.now() - t0 < 120000 && !joined) {
    await sleep(2000);
    try {
      C = (await pages()).find(p => /[?&]p2=1(&|$)/.test(p.url));
      a = JSON.parse(await evalIn(A, LOOK));
      if (C) { c = JSON.parse(await evalIn(C, LOOK)); joined = a.roster && c.roster && a.roster.length === 2 && c.roster.length === 2; }
    } catch (e) { /* the window is still loading */ }
  }
  const bad = [];
  if (!C) bad.push('no player 2 window opened');
  if (C && /[?&]emb=1(&|$)/.test(C.url)) bad.push('the top level player 1 asked for the framed path: ' + C.url);
  if (C && !c) bad.push('the player 2 window never booted');
  if (c && !(c.p2line && c.p2line.shown && /player 2/i.test(c.p2line.text))) bad.push('the player 2 window does not say it is player 2: ' + JSON.stringify(c.p2line));
  if (c && !/player 2/i.test(c.title)) bad.push('its window title reads ' + c.title);
  if (a && c && a.key === c.key) bad.push('both windows play the same save ' + a.key);
  if (!joined) bad.push('both rosters did not show two in 120 s');
  say('player 1: ' + JSON.stringify(a));
  say('player 2: ' + JSON.stringify(c) + (C ? ' at ' + C.url : ''));
  code = bad.length ? 1 : 0;
  say((bad.length ? 'FAIL: ' + bad.join('; ') : 'PASS: same machine co-op joined through a real popup in ' + (Date.now() - t0) + ' ms') + ' (build v' + (a && a.ver) + ')');
} catch (e) { say('COULD NOT RUN: ' + e.message); }
finally {
  for (const p of [ch, srv]) { try { if (p) spawn('taskkill', ['/PID', String(p.pid), '/T', '/F'], { stdio: 'ignore' }); } catch (e) {} }
  await sleep(1500);
  try { fs.rmSync(copy, { force: true }); } catch (e) {}
  try { fs.rmSync(prof, { recursive: true, force: true }); } catch (e) {}
}
process.exit(code);
