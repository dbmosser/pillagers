// p2.mjs : THE ONLINE TWO PLAYER TEST ACROSS TWO REAL PCS (2026-10-30, his "yes i want the auto test", through the CEO chat).
// His party plan: two PCs, both on keyboard and mouse, one HOSTS A PARTY and the other JOINS with the copied code. tools/nettest.html
// tests that path inside one browser; this tests it between the VM (host) and the spare PC (guest) over his home network.
//   host          (the VM) a headless Chrome on a test port opens a copy of the test build, presses HOST A PARTY, puts the invite in
//                 the p2-mailbox branch, waits for the reply there, presses LET THEM IN, ascends, watches player 2 move and shoot,
//                 extracts, and waits for player 2 to say it is back in the Undercroft. Result: tools/handoff/spare/p2-online-test.txt
//   guest-daemon  (the spare PC; spare-runner.ps1 keeps one going) looks in p2-mailbox every 20 s and runs guest for a new invite.
//   guest         joins with the invite, puts the reply in the mailbox, answers MY LOADOUT, walks, shoots, comes home, reports.
// The codes go by text through git, so this proves the codes, the link and the raid, not the clipboard of COPY CODE.
// The mailbox is its own clone beside the game folder (..\p2mailbox), never a branch switch in the game folder.
// Never port 8802. Calls no AI. Usage: node tools/p2online/p2.mjs host|guest-daemon [--root DIR]
import { spawn, execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const arg = (k, d) => { const i = process.argv.indexOf('--' + k); return i > 0 ? process.argv[i + 1] : d; };
const ROLE = process.argv[2] || '';
const R = path.resolve(arg('root', path.join(path.dirname(fileURLToPath(import.meta.url)), '..', '..')));
const T = path.join(R, 'tools');
const MB = path.resolve(arg('mailbox', path.join(path.dirname(R), 'p2mailbox')));
const HOST = os.hostname();
const sleep = ms => new Promise(r => setTimeout(r, ms));
const now = () => new Date().toISOString().replace('T', ' ').slice(0, 19);
const LOG = [];
function log(s) { const l = now() + ' ' + HOST + ' ' + s; LOG.push(l); console.log(l); }

// ---- the mailbox
function git(a, cwd = MB) { return execFileSync('git', a, { cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'], timeout: 90000 }).trim(); }
function mbSync() {
  if (!fs.existsSync(path.join(MB, '.git'))) git(['clone', '-q', '--single-branch', '--branch', 'p2-mailbox', git(['remote', 'get-url', 'origin'], R), MB], R);
  git(['fetch', '-q', 'origin', 'p2-mailbox']); git(['reset', '-q', '--hard', 'origin/p2-mailbox']);
}
function mbRead(f) { try { return JSON.parse(fs.readFileSync(path.join(MB, f), 'utf8')); } catch { return null; } }
async function mbPut(f, o) {
  let e0 = null;
  for (let i = 0; i < 6; i++) {
    try {
      mbSync(); fs.writeFileSync(path.join(MB, f), JSON.stringify(o, null, 1) + '\n'); git(['add', f]);
      git(['-c', 'user.name=p2online', '-c', 'user.email=p2online@localhost', 'commit', '-q', '-m', 'p2: ' + f + ' from ' + HOST]);
      git(['push', '-q', 'origin', 'HEAD:p2-mailbox']); return;
    } catch (e) { e0 = e; await sleep(3000 + 2000 * i); }
  }
  throw new Error('mailbox push failed: ' + String(e0 && e0.message).slice(0, 200));
}
async function mbWait(f, ms) { const end = Date.now() + ms; for (;;) { try { mbSync(); } catch {} const o = mbRead(f); if (o) return o; if (Date.now() > end) return null; await sleep(8000); } }

// ---- the browser (its own profile and port; WebRTC host addresses shown, since the VM sits behind its own NAT)
const CHROME = ['C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe', 'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe',
  'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe'].find(p => fs.existsSync(p));
async function cdpUp(port) { try { const r = await fetch('http://127.0.0.1:' + port + '/json/version'); return r.ok; } catch { return false; } }
async function chromeStart(port) {
  if (await cdpUp(port)) return;
  spawn(CHROME, ['--headless=new', '--remote-debugging-port=' + port, '--user-data-dir=' + path.join(os.tmpdir(), 'pillagers-p2online-' + port),
    '--window-size=1600,900', '--no-first-run', '--no-default-browser-check', '--force-prefers-no-reduced-motion', '--mute-audio',
    '--autoplay-policy=no-user-gesture-required', '--disable-features=WebRtcHideLocalIpsWithMdns', '--disable-background-timer-throttling',
    '--disable-renderer-backgrounding', '--disable-backgrounding-occluded-windows', 'about:blank'], { detached: true, stdio: 'ignore' }).unref();
  for (let i = 0; i < 60; i++) { await sleep(500); if (await cdpUp(port)) return; }
  throw new Error('no test Chrome on ' + port);
}
async function chromeClose(port) {
  try { const v = await (await fetch('http://127.0.0.1:' + port + '/json/version')).json(); const ws = new WebSocket(v.webSocketDebuggerUrl);
    await new Promise(r => { ws.onopen = () => { ws.send('{"id":1,"method":"Browser.close"}'); setTimeout(r, 1500); }; ws.onerror = r; }); } catch {}
}
class Tab {
  static async open(port, url) {
    const j = await (await fetch('http://127.0.0.1:' + port + '/json/new?' + url, { method: 'PUT' })).json();
    const t = new Tab(); t.n = 0; t.cb = new Map(); t.ws = new WebSocket(j.webSocketDebuggerUrl);
    t.ws.onmessage = m => { const d = JSON.parse(m.data); const f = d.id && t.cb.get(d.id); if (f) { t.cb.delete(d.id); f(d); } };
    await new Promise((res, rej) => { t.ws.onopen = res; t.ws.onerror = () => rej(new Error('CDP socket')); });
    await t.send('Emulation.setFocusEmulationEnabled', { enabled: true }).catch(() => {});
    return t;
  }
  send(method, params = {}) {
    const id = ++this.n;
    return new Promise((res, rej) => { const to = setTimeout(() => { this.cb.delete(id); rej(new Error('CDP timeout ' + method)); }, 90000);
      this.cb.set(id, d => { clearTimeout(to); d.error ? rej(new Error(d.error.message)) : res(d.result); }); this.ws.send(JSON.stringify({ id, method, params })); });
  }
  async ev(x) {
    const r = await this.send('Runtime.evaluate', { expression: x, awaitPromise: true, returnByValue: true });
    if (r.exceptionDetails) throw new Error('page: ' + String((r.exceptionDetails.exception && r.exceptionDetails.exception.description) || r.exceptionDetails.text).slice(0, 300));
    return r.result.value;
  }
  async until(x, ms, what) { const end = Date.now() + ms; for (;;) { let v = null; try { v = await this.ev(x); } catch {} if (v) return v; if (Date.now() > end) throw new Error('waited ' + Math.round(ms / 1000) + ' s for ' + what); await sleep(250); } }
}

// ---- the page side (needs the test build: window.__net with ?netslot, __hubEnter, __station, __deploy, __endRaid, __state)
const LIB = `window.__p2=(function(){
  function el(id){ return document.getElementById(id); }
  function click(id){ var b=el(id); if(!b) throw new Error('no #'+id); b.click(); }
  function put(id,v){ var t=el(id); if(!t) throw new Error('no #'+id); t.value=v; t.dispatchEvent(new Event('input',{bubbles:true})); }
  function clear(){ try{ click('closeparty'); }catch(e){} [].forEach.call(document.querySelectorAll('.modal.on'),function(m){ if(m.id!=='askmodal') m.classList.remove('on'); });
    var pb=el('pausebox'), rb=el('resumebtn'); if(pb&&pb.classList.contains('on')&&rb) rb.click(); if(pb) pb.classList.remove('on'); }
  function hold(code,key,ms){ window.dispatchEvent(new KeyboardEvent('keydown',{code:code,key:key,bubbles:true,cancelable:true}));
    return new Promise(function(r){ setTimeout(function(){ window.dispatchEvent(new KeyboardEvent('keyup',{code:code,key:key,bubbles:true,cancelable:true})); r(1); },ms); }); }
  var ka=null;
  function keep(on){ if(ka){ clearInterval(ka); ka=null; } if(on) ka=setInterval(function(){ try{ var g=window.__state(), p=g&&g.player; if(p&&!g.over){ if(p.downed) p.downT=Math.max(p.downT||0,8); else if(p.hp>0) p.hp=Math.max(p.hp,p.maxhp||100); } }catch(e){} },200); }
  function boot(){ try{ var tl=el('title'), ts=el('titlestart'); if(tl&&ts&&tl.classList.contains('on')) ts.click(); }catch(e){} try{ if(window.__hubEnter) window.__hubEnter(); }catch(e){}
    clear(); window.__net.open(); return {ver:window.__net.ver,st:window.__net.state()}; }
  function code(p){ var c=el('partycode'); return (c&&c.value.indexOf(p)===0)?c.value:''; }
  function two(){ var s=window.__net.state(); return s.roster.length>=2?s:null; }
  function where(){ var o=el('outcome'), tl=el('title'); if(window.__net.up().on) return 'raid'; if(o&&o.classList.contains('on')) return 'run card'; if(tl&&tl.classList.contains('on')) return 'title'; return (window.__hubP&&window.__hubP())?'hub':'unknown'; }   // the game keeps its screen word to itself
  function ascend(){ try{ if(typeof window.__station==='function'){ var r=window.__station('lift','KeyE'); if(r&&r.fired){ var sd=el('sectordeploy'); if(sd){ sd.click(); var ay=el('askyes'); if(ay){ ay.click(); return 'the lift and the sector page'; } } } } }catch(e){}
    clear(); window.__deploy({kit:[],safe:null,mapIx:0,seed:4242}); return '__deploy on sector 0'; }
  function answer(){ var m=el('askmodal'), y=el('askyes'); if(m&&m.classList.contains('on')&&y){ y.click(); return 1; } return 0; }
  function home(){ try{ var o=el('outcome'), b=el('oc_btn'); if(o&&o.classList.contains('on')&&b) b.click(); }catch(e){} return where(); }
  function diag(){ var g=null; try{ g=window.__state(); }catch(e){} var o=el('outcome'); return 'screen '+where()+', raid over '+!!(g&&g.over)+', run card '+!!(o&&o.classList.contains('on'))+', up top '+window.__net.up().on; }
  function watch(ms){ var p0=null, maxd=0, seen=0, hp0={}, v0=window.__net.up(), mySeat=v0.me?v0.me.seat:0, end=Date.now()+ms;
    window.__net.ents().list.forEach(function(e){ if(e.id) hp0[e.id]=e.hp; });
    return new Promise(function(res){ (function tick(){ var v=window.__net.up();
      v.list.forEach(function(o){ if(o.seat!==mySeat){ seen++; if(!p0) p0={x:o.x,y:o.y}; else maxd=Math.max(maxd,Math.hypot(o.x-p0.x,o.y-p0.y)); } });
      if(Date.now()<end&&v.on) return setTimeout(tick,100);
      var drop=[], now={}; window.__net.ents().list.forEach(function(e){ if(e.id) now[e.id]=e.hp; });
      for(var k in hp0){ var h1=(k in now)?now[k]:0; if(h1<hp0[k]-0.5) drop.push(k+':'+Math.round(hp0[k])+'>'+Math.round(h1)); }
      res({seen:seen,moved:Math.round(maxd),drops:drop,on:v.on}); })(); }); }
  function shoot(ms){ var g=window.__state(), me=window.__net.up().me, L=window.__net.ents().list.filter(function(e){ return e.id&&e.hp>0; });
    if(!me||!L.length) return Promise.resolve({shots:0,why:'no target near'});
    L.sort(function(a,b){ return Math.hypot(a.x-me.x,a.y-me.y)-Math.hypot(b.x-me.x,b.y-me.y); });
    var t=L[0], cv=el('cv'), s0=(g.tel&&g.tel.shots)|0, end=Date.now()+ms, n=0, down=false;
    function ev(tg,type){ var r=cv.getBoundingClientRect(); tg.dispatchEvent(new MouseEvent(type,{clientX:r.left+r.width/2+Math.round(r.width*0.08),clientY:r.top+r.height/2,button:0,bubbles:true})); }
    return new Promise(function(res){ (function aim(){ try{ var c=null, E=window.__net.ents().list, i; for(i=0;i<E.length;i++) if(E[i].id===t.id) c=E[i];
        if(c) window.__net.stand(c.x-90,c.y); ev(cv,'mousemove'); n++; if(!down){ down=true; ev(cv,'mousedown'); } else if(n%8===0){ ev(window,'mouseup'); down=false; } }catch(e){}
      if(Date.now()<end) return setTimeout(aim,16); try{ ev(window,'mouseup'); }catch(e){}
      var g2=window.__state(); res({target:t.id,kind:t.k,shots:((g2.tel&&g2.tel.shots)|0)-s0}); })(); }); }
  return {el:el,click:click,put:put,clear:clear,hold:hold,keep:keep,boot:boot,code:code,two:two,where:where,ascend:ascend,answer:answer,home:home,diag:diag,watch:watch,shoot:shoot};
})(); 1`;

// The test copy: both PCs build it from the same commit (the host names it), since two copies on different builds refuse to link.
// tools/mkfixture.ps1 -Src -Dst, from git show COMMIT:dark_raiders.html; the game folder's own files are never touched.
// Served by tools/spare/serve.mjs (the spare PC runs one on 8806).
async function servePage(port, name, commit) {
  try { git(['fetch', '-q', 'origin', 'master'], R); } catch {}
  const src = path.join(os.tmpdir(), 'p2online-src-' + name), dst = path.join(T, name);
  fs.writeFileSync(src, execFileSync('git', ['show', commit + ':dark_raiders.html'], { cwd: R, maxBuffer: 64 << 20, timeout: 60000 }));
  execFileSync('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', path.join(T, 'mkfixture.ps1'), '-Root', R, '-Src', src, '-Dst', dst], { stdio: 'ignore', timeout: 600000 });
  if (!fs.existsSync(dst) || fs.statSync(dst).size < 5000000 || Date.now() - fs.statSync(dst).mtimeMs > 600000) throw new Error('the test copy of ' + commit.slice(0, 8) + ' did not build');
  const ok = async () => { try { return (await fetch('http://127.0.0.1:' + port + '/' + name, { method: 'HEAD' })).ok; } catch { return false; } };
  if (!(await ok())) { spawn(process.execPath, [path.join(T, 'spare', 'serve.mjs'), '--root', T, '--port', String(port)], { detached: true, stdio: 'ignore' }).unref();
    for (let i = 0; i < 40 && !(await ok()); i++) await sleep(250); }
  if (!(await ok())) throw new Error('the test server on ' + port + ' did not come up');
  return 'http://localhost:' + port + '/' + name;
}
async function openGame(cdp, url) {
  await chromeStart(cdp); const t = await Tab.open(cdp, url);
  await t.until('!!(window.__net&&window.__hubEnter&&window.__state)', 90000, 'the test build to load (window.__net)');
  await t.ev(LIB); await sleep(1500); return t;
}

// ---- host (the VM)
async function host() {
  const cdp = +arg('cdp', 9361), port = +arg('port', 8817), out = path.join(T, 'handoff', 'spare', 'p2-online-test.txt');
  if (port === 8802) throw new Error('refusing 8802');
  const id = new Date().toISOString().replace(/[-:T]/g, '').slice(0, 12) + '-' + HOST, steps = [], bad = [];
  const step = (ok, s) => { steps.push((ok ? 'PASS ' : 'FAIL ') + s); if (!ok) bad.push(s); log((ok ? 'PASS ' : 'FAIL ') + s); };
  let t = null, guest = null, ver = '', commit = '';
  try {
    commit = arg('commit', git(['rev-parse', 'origin/master'], R)); log('building the test copy of ' + commit.slice(0, 8));
    t = await openGame(cdp, (await servePage(port, 'fixture-soak-p2host.html', commit)) + '?netslot=A');
    const b = await t.ev('__p2.boot()'); ver = b.ver; log('host page up, v' + ver);
    await t.ev("__p2.click('partyhost'),1");
    const invite = await t.until("__p2.code('PTY1o')", 30000, 'the invite code');
    step(true, 'HOST A PARTY made an invite code (' + invite.length + ' characters)');
    await mbPut('req.json', { id, ver, commit, invite, at: now(), host: HOST });
    log('invite in the mailbox as ' + id + '; waiting for the spare PC');
    const rep = await mbWait('reply-' + id + '.json', 25 * 60000);
    if (!rep) { let why = ''; try { why = git(['show', 'origin/spare-results:spare/DESKTOP-82BKOP4/status.txt'], R).split(String.fromCharCode(10)).map(l => l.trim()).filter(l => /^(seen|test_run)=/.test(l)).join(', '); } catch {} throw new Error('no reply code from the spare PC in 25 minutes (its runner: ' + (why || 'unknown') + ')'); }
    step(rep.reply && rep.reply.indexOf('PTY1a') === 0, 'the spare PC joined with the invite and sent a reply code (v' + rep.ver + (rep.ver === ver ? ', same build' : ', NOT the host build v' + ver) + ')');
    await t.ev("__p2.put('partyreplyin'," + JSON.stringify(rep.reply) + "),__p2.click('partyaccept'),1");
    const st = await t.until('__p2.two()', 45000, 'LET THEM IN to link both PCs').catch(e => null);
    let ns = ''; if (!st) { try { ns = JSON.stringify(await t.ev('(function(){var s=__net.state();return {status:s.status,err:s.err,links:s.links,roster:s.roster.length};})()')); } catch {} }
    step(!!st, 'LET THEM IN linked both PCs' + (st ? ' (roster ' + st.roster.length + ')' : ' (host party window: ' + ns + ')'));
    if (!st) throw new Error('no link');
    await t.ev('__p2.clear(),__p2.keep(true),1'); await sleep(1000);
    const how = await t.ev('__p2.ascend()'); log('host ascends through ' + how);
    const up = await t.until('__net.up().on?__net.up():null', 90000, 'the host to be up top').catch(() => null);
    step(!!up, 'the host ascended (' + how + ')');
    if (!up) throw new Error('host not up');
    const g2 = await t.until('(function(){var v=__net.up();return v.list.some(function(o){return o.seat!==(v.me?v.me.seat:0);})?1:0;})()', 60000, 'player 2 to show up top').catch(() => 0);
    step(!!g2, 'player 2 ascended into the same raid and the host draws him');
    if (g2) {
      const w = await t.ev('__p2.watch(35000)');
      step(w.moved >= 40, 'the host saw player 2 move (' + w.moved + ' units)');
      step(w.drops.length > 0, 'the host saw player 2 rounds land on its machines (' + (w.drops.slice(0, 4).join(', ') || 'no damage') + ')');
    }
    await t.ev("__endRaid('extract'),1"); await sleep(3000);
    const back = await t.until("__p2.home()==='hub'?1:0", 45000, 'the host back in the Undercroft').catch(() => 0);
    step(!!back, 'the host extracted and is back in the Undercroft' + (back ? '' : ' (' + await t.ev('__p2.diag()') + ')'));
    guest = await mbWait('guest-' + id + '.json', 6 * 60000);
    if (!guest) step(false, 'the spare PC said nothing after the raid in 6 minutes');
    else { step(!!guest.back, 'the spare PC came back to the Undercroft after the extraction (' + (guest.where || '?') + ')');
      step(guest.shots > 0, 'player 2 fired ' + guest.shots + ' rounds on its own screen' + (guest.why ? ' (' + guest.why + ')' : '')); }
  } catch (e) { step(false, 'stopped: ' + e.message); }
  finally { if (t) { try { await t.ev('__p2.keep(false),1'); } catch {} } await chromeClose(cdp); }
  const head = 'p2 online test ' + id + ': ' + (bad.length ? 'FAIL (' + bad.length + ')' : 'PASS') + ', host ' + HOST + ' v' + ver + ', guest ' + (guest ? guest.host + ' v' + guest.ver : '?');
  const txt = [head, '(VM hosts in a headless Chrome on a test port; the spare PC joins from its own test copy; codes by text through the p2-mailbox branch; keyboard and mouse input)', ...steps, '', 'guest notes: ' + (guest ? (guest.notes || []).join(' | ') : '-'), '', 'log:', ...LOG].join('\r\n') + '\r\n';
  fs.mkdirSync(path.dirname(out), { recursive: true }); fs.writeFileSync(out, txt);
  try { await mbPut('host-' + id + '.json', { id, head, steps }); } catch {}
  console.log(head); process.exitCode = bad.length ? 1 : 0;
}

// ---- guest (the spare PC)
async function guest(req) {
  const cdp = +arg('cdp', 9362), port = +arg('port', 8806), notes = [], res = { id: req.id, host: HOST, ver: '', joined: false, up: false, shots: 0, back: false, notes };
  const note = s => { notes.push(s); log(s); };
  let t = null;
  try {
    note('building the test copy of ' + String(req.commit).slice(0, 8)); t = await openGame(cdp, (await servePage(port, 'fixture-soak-p2guest.html', req.commit)) + '?netslot=B');
    const b = await t.ev('__p2.boot()'); res.ver = b.ver; note('guest page up, v' + b.ver + (b.ver === req.ver ? '' : ' (host is v' + req.ver + ')'));
    await t.ev("__p2.put('partyin'," + JSON.stringify(req.invite) + "),__p2.click('partyjoin'),1");
    const reply = await t.until("__p2.code('PTY1a')", 45000, 'a reply code');
    await mbPut('reply-' + req.id + '.json', { id: req.id, ver: res.ver, reply, at: now(), host: HOST }); note('reply code in the mailbox (' + reply.length + ' characters)');
    await t.until('__p2.two()', 10 * 60000, 'the host to let us in'); res.joined = true; note('linked to the host');
    const end = Date.now() + 4 * 60000;
    while (Date.now() < end && !(await t.ev('__net.up().on?1:0'))) { if (await t.ev('__p2.answer()')) note('answered MY LOADOUT'); await sleep(300); }
    res.up = !!(await t.ev('__net.up().on?1:0')); note(res.up ? 'up top in the host raid' : 'never got up top');
    if (res.up) {
      await t.ev('__p2.clear(),__p2.keep(true),1'); await sleep(3000);
      await t.ev("__p2.hold('KeyD','d',1500)"); await t.ev("__p2.hold('KeyS','s',1500)"); note('walked right then down');
      const s = await t.ev('__p2.shoot(9000)'); res.shots = s.shots; res.why = s.why || ''; note('fired ' + s.shots + ' rounds at ' + (s.kind || '-') + ' ' + (s.target || ''));
      await sleep(20000); await t.ev("__endRaid('extract'),1"); note('extracted (each player extracts on his own)');
      await t.until('__net.up().on?0:1', 60000, 'the raid to end here').catch(() => note('still up top a minute after extracting'));
      await sleep(3000); res.where = await t.until("__p2.home()==='hub'?'hub':''", 30000, 'the Undercroft').catch(async () => await t.ev('__p2.where()'));
      res.back = res.where === 'hub'; note('after the raid: ' + (res.back ? 'in the Undercroft' : await t.ev('__p2.diag()')));
    }
  } catch (e) { note('stopped: ' + e.message); }
  finally { if (t) { try { await t.ev('__p2.keep(false),1'); } catch {} } await chromeClose(cdp); }
  try { await mbPut('guest-' + req.id + '.json', res); } catch (e) { log('could not report: ' + e.message); }
}
async function guestDaemon() {
  const seen = path.join(os.tmpdir(), 'pillagers-p2online-seen.txt'), me = fileURLToPath(import.meta.url), m0 = fs.statSync(me).mtimeMs;
  for (;;) {
    if (fs.statSync(me).mtimeMs !== m0) { log('p2.mjs changed: stopping, the runner starts the new one'); return; }
    try {
      mbSync(); const q = mbRead('req.json'), last = fs.existsSync(seen) ? fs.readFileSync(seen, 'utf8').trim() : '';
      if (q && q.id && q.id !== last && !mbRead('guest-' + q.id + '.json') && q.commit && q.at && Date.now() - Date.parse(q.at.replace(' ', 'T') + 'Z') < 20 * 60000) {
        fs.writeFileSync(seen, q.id); log('invite ' + q.id + ' from ' + q.host); await guest(q);
      }
    } catch (e) { log('daemon: ' + String(e.message).slice(0, 200)); }
    await sleep(20000);
  }
}

if (ROLE === 'host') await host();
else if (ROLE === 'guest-daemon') await guestDaemon();
else { console.log('usage: node tools/p2online/p2.mjs host|guest-daemon [--root DIR]'); process.exitCode = 2; }
