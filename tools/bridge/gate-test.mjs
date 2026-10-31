// gate-test.mjs : the host bridge job "gate-test" (10-27). The main PC Claude's fullscreen-gate check (fsgate-test.mjs, the 35.21 proof),
// made a fixed job so the VM can run it with no Claude open on the main PC. On HIS screens (the left 4K monitor at 300%), never on his 8802:
// it serves the party copy (C:\claudecode\pillagers-party) on 127.0.0.1:8817 with tools\spare\serve.mjs, and each case is a throwaway
// Chrome with its own temp profile (never his), a zoom seeded for localhost the way his Preferences hold it, 8799 and 8802 blocked so no
// run report or request reaches his servers. Per case: whether the "play fullscreen" gate is up 2.5 s after load, the screen / window /
// page sizes the game saw, and a JPEG of the page put in the bridge share folder as gate-<label>.jpg (share-get pulls it).
// Runs only when nobody has touched the keyboard or mouse for 10 minutes (the windows open on his screen). Fixed cases, no VM arguments.
import { spawn, execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import os from 'node:os';

const CHROME = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const PARTY = 'C:\\claudecode\\pillagers-party';
const PORT = 8817;   // not 8802 (his), 8799 (his collector), 8803-8811 (the robots' copies), 8806 (the runner's test server)
const URL0 = 'http://localhost:' + PORT + '/dark_raiders.html';
// label, zoom %, mode (max: maximized like his window, then reloaded; f11: --start-fullscreen; windowed: a 1000x600 window), CDP port
export const CASES = [
  ['max100', 100, 'max', 9351], ['max75', 75, 'max', 9352], ['f11z100', 100, 'f11', 9353], ['f11z75', 75, 'f11', 9354], ['windowed75', 75, 'windowed', 9355],
];
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// seconds since the last key or mouse input on this desktop (GetLastInputInfo)
function idleSec() {
  const ps = 'Add-Type -TypeDefinition \'using System;using System.Runtime.InteropServices;public static class PvIdle{[StructLayout(LayoutKind.Sequential)]struct L{public uint s;public uint t;}[DllImport("user32.dll")]static extern bool GetLastInputInfo(ref L l);public static uint Ms(){L l=new L();l.s=8;GetLastInputInfo(ref l);return (uint)Environment.TickCount-l.t;}}\'; [PvIdle]::Ms()';
  try { return Math.floor(Number(execFileSync('powershell', ['-NoProfile', '-NonInteractive', '-Command', ps], { timeout: 20000, windowsHide: true }).toString().trim()) / 1000); } catch { return -1; }
}

async function up(url) { try { const r = await fetch(url, { method: 'HEAD' }); return r.ok; } catch { return false; } }

async function runCase([label, zoomPct, mode, port], shareDir) {
  const dir = path.join(os.tmpdir(), 'pv-gate-' + label + '-' + Date.now());
  fs.mkdirSync(path.join(dir, 'Default'), { recursive: true });
  // 10-27: this throwaway Chrome saves any download into its own folder, never his Downloads (tools/chrome-nodownloads.ps1 does the same for the test Chromes)
  fs.mkdirSync(path.join(dir, 'downloads'), { recursive: true });
  const prefs = { partition: { per_host_zoom_levels: { x: {} } }, download: { default_directory: path.join(dir, 'downloads'), prompt_for_download: false, directory_upgrade: true }, savefile: { default_directory: path.join(dir, 'downloads') } };
  if (zoomPct !== 100) prefs.partition.per_host_zoom_levels.x.localhost = { last_modified: '13437019067440923', zoom_level: Math.log(zoomPct / 100) / Math.log(1.2) };
  fs.writeFileSync(path.join(dir, 'Default', 'Preferences'), JSON.stringify(prefs));
  // 10-28: --force-prefers-no-reduced-motion: normal motion whatever the OS asks (see tools/cdp.ps1)
  const args = ['--user-data-dir=' + dir, '--remote-debugging-port=' + port, '--no-first-run', '--no-default-browser-check', '--disable-extensions', '--disable-sync',
    '--force-prefers-no-reduced-motion', '--window-position=-1200,40', mode === 'f11' ? '--start-fullscreen' : mode === 'max' ? '--start-maximized' : '--window-size=1000,600', 'about:blank'];
  const ch = spawn(CHROME, args, { stdio: 'ignore', detached: false, windowsHide: false });
  const out = { label, zoomPct, mode };
  try {
    let target;
    for (let i = 0; i < 60 && !target; i++) {
      await sleep(250);
      try { target = (await (await fetch('http://127.0.0.1:' + port + '/json/list')).json()).find((t) => t.type === 'page'); } catch { /* not up yet */ }
    }
    if (!target) throw new Error('no page target');
    const ws = new WebSocket(target.webSocketDebuggerUrl);
    await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
    let id = 0; const pending = new Map();
    ws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); } };
    const send = (method, params = {}) => new Promise((r) => { const n = ++id; pending.set(n, r); ws.send(JSON.stringify({ id: n, method, params })); });
    const evalJs = async (expr) => (await send('Runtime.evaluate', { expression: expr, returnByValue: true, awaitPromise: true })).result?.result?.value;
    const waitLoaded = async () => { for (let i = 0; i < 80; i++) { if (await evalJs("document.readyState==='complete'&&!!document.getElementById('titlever')&&document.getElementById('titlever').textContent!==''")) break; await sleep(250); } };
    await send('Network.enable');
    await send('Network.setBlockedURLs', { urls: ['*:8799/*', '*:8802/*'] });
    await send('Page.enable');
    await send('Page.navigate', { url: URL0 });
    await sleep(500);
    await waitLoaded();
    if (mode === 'max') {
      const bws = new WebSocket((await (await fetch('http://127.0.0.1:' + port + '/json/version')).json()).webSocketDebuggerUrl);
      await new Promise((res, rej) => { bws.onopen = res; bws.onerror = rej; });
      let bid = 0;
      const bsend = (method, params) => new Promise((r) => { const n = ++bid; bws.onmessage = (e) => { const m = JSON.parse(e.data); if (m.id === n) r(m); }; bws.send(JSON.stringify({ id: n, method, params })); });
      const w = await bsend('Browser.getWindowForTarget', { targetId: target.id });
      await bsend('Browser.setWindowBounds', { windowId: w.result.windowId, bounds: { windowState: 'maximized' } });
      await sleep(800);
      out.cdpBounds = (await bsend('Browser.getWindowBounds', { windowId: w.result.windowId })).result?.bounds;
      bws.close();
      await sleep(800);
      await send('Page.reload', {});
      await sleep(500);
      await waitLoaded();
    }
    await sleep(2500);
    Object.assign(out, await evalJs(`(()=>{const g=document.getElementById('fsgate');return {
      ver:document.getElementById('titlever')?.textContent, gate:g?getComputedStyle(g).display:'none (not built)',
      gateTitle:document.getElementById('fsgtitle')?.textContent||null,
      screen:screen.width+'x'+screen.height, avail:screen.availWidth+'x'+screen.availHeight, at:screenX+','+screenY,
      outer:outerWidth+'x'+outerHeight, inner:innerWidth+'x'+innerHeight,
      dpr:devicePixelRatio, displayModeFullscreen:matchMedia('(display-mode: fullscreen)').matches,
      fullscreenElement:!!document.fullscreenElement}})()`));
    const shot = await send('Page.captureScreenshot', { format: 'jpeg', quality: 60 });
    if (shot.result?.data) { const name = 'gate-' + label + '.jpg'; fs.mkdirSync(shareDir, { recursive: true }); fs.writeFileSync(path.join(shareDir, name), Buffer.from(shot.result.data, 'base64')); out.shot = name; }
    ws.close();
  } catch (e) { out.error = String(e && e.message || e); }
  finally {
    try { execFileSync('taskkill', ['/PID', String(ch.pid), '/T', '/F'], { stdio: 'ignore', windowsHide: true }); } catch { /* gone */ }
    await sleep(1500);
    try { fs.rmSync(dir, { recursive: true, force: true }); } catch { /* a Chrome file still held; the temp folder is cleaned later */ }
  }
  return out;
}

export async function gateTest(ctx) {
  if (!fs.existsSync(CHROME)) return { ok: false, error: 'Chrome is not at ' + CHROME };
  if (!fs.existsSync(path.join(PARTY, 'dark_raiders.html'))) return { ok: false, error: 'no party copy at ' + PARTY };
  // 10-31 (CEO, low RAM): no start under 5 GB free (his 4 GB floor plus this Chrome), none on party night; a refusal is a skip, not a fail
  const n = new Date();
  if (n >= new Date(2026, 9, 31, 17, 0) && n < new Date(2026, 10, 1, 6, 0)) return { ok: false, refused: true, error: 'party night: no tests until Sun 06:00' };
  const freeGB = Math.round(os.freemem() / 1073741824 * 10) / 10;
  if (freeGB < 5) return { ok: false, refused: true, freeGB, error: 'low ram: ' + freeGB + ' GB free, a test needs 5; ask again later' };
  const idle = idleSec();
  if (idle < 600) return { ok: false, refused: true, idleSec: idle, error: idle < 0 ? 'could not read the last input time' : 'he used the keyboard or mouse ' + idle + ' s ago; this opens windows on his screen, so it runs only after 10 minutes without input' };
  const serveJs = path.join(ctx.repoRoot, 'tools', 'spare', 'serve.mjs');
  if (await up(URL0)) return { ok: false, error: 'port ' + PORT + ' is already in use' };
  const srv = spawn(process.execPath, [serveJs, '--root', PARTY, '--port', String(PORT)], { stdio: 'ignore', windowsHide: true });
  const results = [];
  try {
    let ok = false; for (let i = 0; i < 40 && !ok; i++) { await sleep(250); ok = await up(URL0); }
    if (!ok) return { ok: false, error: 'the test server on ' + PORT + ' did not start' };
    for (const c of CASES) { results.push(await runCase(c, ctx.shareDir)); if (idleSec() < 30) { results.push({ stopped: 'he is back at the PC' }); break; } }
  } finally { try { srv.kill(); } catch { /* gone */ } }
  return { ok: results.every((r) => !r.error), idleSec: idle, served: PARTY + ' on ' + PORT, results };
}
