#!/usr/bin/env node
// play-relay.mjs : the PAD ROUTE. A tiny user-mode TCP relay for the MAIN PC (no administrator, no npm packages, Node 18 or newer).
//
// WHY: after the move, Pillagers runs inside the VM, but the Xbox pads stay plugged into the main PC and the browser gamepad API only works
// on a "secure" page such as http://localhost:... on the machine that has the pads. So the game is played in Chrome on the MAIN PC at
// http://localhost:8802/dark_raiders.html while the game server runs in the VM. This program is the bridge: it listens on 127.0.0.1 of the main
// PC and hands every connection, byte for byte, to the same port in the VM. Because it copies raw bytes, the browser's "Host: localhost:8802"
// header arrives unchanged, and the VM's own server (tools\serve.ps1, an HttpListener on http://localhost:8802/) accepts it. That was tested
// on this PC: an HttpListener prefix "http://localhost:P/" answers a connection that arrives on 192.168.160.1 (not only on 127.0.0.1) as long as
// the Host header names "localhost" (HTTP.sys ignores the port inside the Host header and rejects a raw address with 400). So the VM needs no
// second relay, only a firewall rule (see vm-pad-route-firewall.ps1). Side effect worth knowing: a test relay on another port, for example
// --ports 18802:8802, reaches the VM's real server on 8802, and the browser page then lives at http://localhost:18802/ (its own saved data).
//
// WHAT IT DOES
//   - Listens on 127.0.0.1 ONLY (never on the network), by default on 8802 (the game) and 8799 (the telemetry collector).
//   - Forwards each connection to the VM, same port number by default. Half-close and backpressure are handled (a slow reader never makes the
//     relay buffer a whole download in memory).
//   - Finds the VM in this order: (a) env PILLAGERS_VM_HOST (an address or a name), (b) the file
//     C:\Users\User1\AppData\Local\PillagersMove\vm-address.txt, (c) <computer name>.mshome.net (the Hyper-V Default Switch answers that name;
//     default computer name VM_Oct2026, change it with env PILLAGERS_VM_NAME or --vm-name). A command-line --vm-host beats all three.
//     When a connection to the VM fails it looks the VM up again (a changed address is picked up without a restart) and logs the new address.
//   - Refuses targets that are not private addresses (10.x, 172.16-31.x, 192.168.x, 169.254.x, 127.x) unless --allow-any-target is given, so a
//     wrong or tampered address file can never send the game's traffic to the internet.
//   - REFUSES TO START when one of its listen ports is already taken (for example the main PC's own play server is still running).
//   - Logs one line per real connection error (repeats within 10 seconds are folded into "+N similar"). It never logs request or response
//     contents, headers or cookies. Browser-side resets (a tab closing) are only counted, not logged, unless --verbose.
//   - When the VM cannot be reached it answers the browser with a short plain page (HTTP 502) that says why, instead of a blank error.
//
// USAGE (normally started by host-play-relay.ps1, hidden):
//   node play-relay.mjs                                  listen on 8802 and 8799, forward to the same ports in the VM
//   node play-relay.mjs --ports 18802                    a test relay on 18802 -> VM 18802 (does not touch 8802)
//   node play-relay.mjs --ports 18802:18803              listen 18802, forward to VM port 18803
//   node play-relay.mjs --vm-host 192.168.164.103        use this VM address (overrides env, file and name)
//   node play-relay.mjs --probe                          do not listen: look the VM up, try its ports once, print key=value lines, exit
//   options: --vm-name NAME  --vm-file PATH  --log PATH  --status-file PATH  --idle-seconds N (default 900)  --connect-timeout-ms N (default 4000)
//            --also-ipv6 (also listen on ::1)  --no-error-page  --allow-any-target  --verbose  --help
// Exit codes: 0 stopped normally / probe all open, 1 unexpected error, 2 bad options, 3 a listen port is taken (refused to start),
//             4 probe: the VM address could not be found, 5 probe: the VM did not answer on every port.
// Files: log tools\migrate\logs\play-relay.log (kept to about 2 MB, then moved to play-relay.log.old), status tools\migrate\state\play-relay.status.json.
// No secret value is ever read, printed or stored by this program.
import net from 'node:net';
import dns from 'node:dns';
import os from 'node:os';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const LOCAL_APPDATA = process.env.LOCALAPPDATA || 'C:\\Users\\User1\\AppData\\Local';
export const DEFAULT_ADDRESS_FILE = path.join(LOCAL_APPDATA, 'PillagersMove', 'vm-address.txt');
export const DEFAULT_VM_NAME = 'VM_Oct2026';
const DEFAULT_LOG = path.join(HERE, 'logs', 'play-relay.log');
const DEFAULT_STATUS = path.join(HERE, 'state', 'play-relay.status.json');
const RESOLVE_TTL_MS = 15000;      // how long a found VM address is trusted without checking again
const DOWN_TTL_MS = 2000;          // after a failed connect, further connects to the same address:port fail at once for this long
const LOG_MAX_BYTES = 2 * 1024 * 1024;

export class UsageError extends Error {}

// ------------------------------------------------------------------------------------------------ options
const VALUE_OPTS = new Set(['ports', 'vm-host', 'vm-name', 'vm-file', 'log', 'status-file', 'idle-seconds', 'connect-timeout-ms', 'ics-dns']);
const FLAG_OPTS = new Set(['also-ipv6', 'allow-any-target', 'probe', 'verbose', 'help', 'no-error-page']);

export function parsePortSpecs(text) {
  const out = [];
  const seen = new Set();
  for (const part of String(text).split(',').map((s) => s.trim()).filter(Boolean)) {
    const m = /^(\d{1,5})(?::(\d{1,5}))?$/.exec(part);
    if (!m) throw new UsageError('bad port "' + part + '" (use 8802 or 8802:8802, separated by commas)');
    const listen = Number(m[1]);
    const target = m[2] ? Number(m[2]) : listen;
    if (listen < 1024 || listen > 65535) throw new UsageError('listen port ' + listen + ' must be 1024 to 65535');
    if (target < 1 || target > 65535) throw new UsageError('target port ' + target + ' must be 1 to 65535');
    if (seen.has(listen)) throw new UsageError('listen port ' + listen + ' is listed twice');
    seen.add(listen);
    out.push({ listen, target });
  }
  if (!out.length) throw new UsageError('no ports given');
  return out;
}

export function isPrivateIPv4(ip) {
  const m = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/.exec(String(ip));
  if (!m) return false;
  const [a, b, c, d] = m.slice(1).map(Number);
  if ([a, b, c, d].some((n) => n > 255)) return false;
  if (a === 0 || (a === 255 && b === 255 && c === 255 && d === 255)) return false;
  return a === 10 || a === 127 || (a === 172 && b >= 16 && b <= 31) || (a === 192 && b === 168) || (a === 169 && b === 254);
}

// A VM address from the user: an IPv4 address or a host name (letters, digits, dot, dash, underscore). Anything else is refused.
export function classifyHostToken(text) {
  const s = String(text || '').trim();
  if (!s) return null;
  if (net.isIPv4(s)) return { kind: 'ip', value: s };
  if (s.length <= 253 && /^[A-Za-z0-9]([A-Za-z0-9_.-]*[A-Za-z0-9])?$/.test(s) && !/^[0-9.]+$/.test(s)) return { kind: 'name', value: s };
  return null;
}

// vm-address.txt: a bare address or name on a line, or key=value lines. Comment lines start with # . Returns { ips:[], names:[] } (may be empty).
export function parseAddressFile(text) {
  const ips = [];
  const names = [];
  const ipKeys = new Set(['ip', 'address', 'host', 'vm', 'vmhost', 'ipv4']);
  const nameKeys = new Set(['mshome', 'computer', 'name', 'computername']);
  const add = (list, v) => { if (v && !list.includes(v)) list.push(v); };
  const pieces = String(text || '').replace(/^\uFEFF/, '').split(/\r?\n/);
  for (const raw of pieces) {
    const line = raw.trim();
    if (!line || line.startsWith('#')) continue;
    const eq = line.indexOf('=');
    let key = '';
    let val = line;
    if (eq > 0) { key = line.slice(0, eq).trim().toLowerCase(); val = line.slice(eq + 1).trim(); }
    val = val.replace(/\s+#.*$/, '').trim();
    if (/\s/.test(val)) continue;     // one address or name per line, nothing else
    const tok = classifyHostToken(val);
    if (!tok) continue;
    if (!key) { add(tok.kind === 'ip' ? ips : names, tok.value); continue; }
    if (ipKeys.has(key)) add(tok.kind === 'ip' ? ips : names, tok.value);
    else if (nameKeys.has(key) && tok.kind === 'name') add(names, tok.value);
  }
  return { ips, names };
}

export function parseArgs(argv, env = process.env) {
  const cfg = {
    ports: env.PILLAGERS_RELAY_PORTS || '8802,8799',
    vmHostArg: '',
    vmHostEnv: env.PILLAGERS_VM_HOST || '',
    vmName: env.PILLAGERS_VM_NAME || DEFAULT_VM_NAME,
    vmFile: DEFAULT_ADDRESS_FILE,
    log: DEFAULT_LOG,
    statusFile: DEFAULT_STATUS,
    idleSeconds: 900,
    connectTimeoutMs: 4000,
    icsDns: '',
    alsoIpv6: false,
    allowAnyTarget: false,
    probe: false,
    verbose: false,
    help: false,
    errorPage: true,
  };
  for (let i = 0; i < argv.length; i++) {
    let a = argv[i];
    if (!a.startsWith('--')) throw new UsageError('unexpected argument "' + a + '"');
    let name = a.slice(2);
    let val;
    const eq = name.indexOf('=');
    if (eq >= 0) { val = name.slice(eq + 1); name = name.slice(0, eq); }
    if (FLAG_OPTS.has(name)) {
      if (val !== undefined) throw new UsageError('--' + name + ' takes no value');
      if (name === 'also-ipv6') cfg.alsoIpv6 = true;
      else if (name === 'allow-any-target') cfg.allowAnyTarget = true;
      else if (name === 'probe') cfg.probe = true;
      else if (name === 'verbose') cfg.verbose = true;
      else if (name === 'help') cfg.help = true;
      else if (name === 'no-error-page') cfg.errorPage = false;
      continue;
    }
    if (!VALUE_OPTS.has(name)) throw new UsageError('unknown option --' + name);
    if (val === undefined) {
      i++;
      if (i >= argv.length) throw new UsageError('--' + name + ' needs a value');
      val = argv[i];
    }
    switch (name) {
      case 'ports': cfg.ports = val; break;
      case 'vm-host': cfg.vmHostArg = val; break;
      case 'vm-name': cfg.vmName = val; break;
      case 'vm-file': cfg.vmFile = val; break;
      case 'log': cfg.log = val; break;
      case 'status-file': cfg.statusFile = val; break;
      case 'ics-dns': cfg.icsDns = val; break;
      case 'idle-seconds': {
        const n = Number(val);
        if (!Number.isFinite(n) || n < 1 || n > 86400) throw new UsageError('--idle-seconds must be 1 to 86400');
        cfg.idleSeconds = n; break;
      }
      case 'connect-timeout-ms': {
        const n = Number(val);
        if (!Number.isFinite(n) || n < 200 || n > 60000) throw new UsageError('--connect-timeout-ms must be 200 to 60000');
        cfg.connectTimeoutMs = n; break;
      }
      default: break;
    }
  }
  cfg.specs = parsePortSpecs(cfg.ports);
  if (cfg.vmHostArg && !classifyHostToken(cfg.vmHostArg)) throw new UsageError('--vm-host "' + cfg.vmHostArg + '" is not an IPv4 address or a host name');
  if (cfg.vmName && !classifyHostToken(cfg.vmName)) throw new UsageError('the VM name "' + cfg.vmName + '" is not a plain host name');
  if (cfg.icsDns && !net.isIPv4(cfg.icsDns)) throw new UsageError('--ics-dns must be an IPv4 address');
  return cfg;
}

export const USAGE = [
  'play-relay.mjs : listens on 127.0.0.1 and forwards each connection, byte for byte, to the same port in the Pillagers VM.',
  '  node play-relay.mjs [--ports 8802,8799] [--vm-host ADDRESS|NAME] [--vm-name NAME] [--vm-file PATH] [--log PATH] [--status-file PATH]',
  '                      [--idle-seconds N] [--connect-timeout-ms N] [--also-ipv6] [--no-error-page] [--allow-any-target] [--verbose]',
  '  node play-relay.mjs --probe      look the VM up and try its ports once (prints key=value lines)',
  'VM address order: --vm-host, env PILLAGERS_VM_HOST, file vm-address.txt, then <name>.mshome.net (name from env PILLAGERS_VM_NAME, default ' + DEFAULT_VM_NAME + ').',
].join('\n');

// ------------------------------------------------------------------------------------------------ logging
function pad2(n) { return String(n).padStart(2, '0'); }
function stamp(d = new Date()) {
  return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()) + ' ' + pad2(d.getHours()) + ':' + pad2(d.getMinutes()) + ':' + pad2(d.getSeconds());
}

export function makeLogger(file, { echo = true } = {}) {
  let written = 0;
  let ok = true;
  const recent = new Map();
  if (file) {
    try {
      fs.mkdirSync(path.dirname(file), { recursive: true });
      try { written = fs.statSync(file).size; } catch { written = 0; }
      if (written > LOG_MAX_BYTES) { try { fs.renameSync(file, file + '.old'); } catch { /* keep appending */ } written = 0; }
    } catch { ok = false; }
  }
  function write(line) {
    if (echo) { try { process.stdout.write(line + '\n'); } catch { /* no console */ } }
    if (file && ok) {
      try {
        if (written > LOG_MAX_BYTES) { try { fs.renameSync(file, file + '.old'); } catch { /* ignore */ } written = 0; }
        fs.appendFileSync(file, line + '\n');
        written += line.length + 1;
      } catch { /* a log that cannot be written must never stop the relay */ }
    }
  }
  const clean = (m) => String(m).replace(/[\r\n\t]+/g, ' ').replace(/[^\x20-\x7e]/g, '?').slice(0, 400);
  const log = (msg) => write(stamp() + ' ' + clean(msg));
  // the same message again within 10 seconds is only counted; the next different line (or the next one after 10 s) says how many were folded
  log.once = (key, msg) => {
    const now = Date.now();
    const r = recent.get(key);
    if (r && now - r.t < 10000) { r.n++; return; }
    if (r && r.n > 0) log('  (+' + r.n + ' similar in the last 10 seconds)');
    recent.set(key, { t: now, n: 0 });
    if (recent.size > 200) recent.clear();
    log(msg);
  };
  log.file = file;
  return log;
}

// ------------------------------------------------------------------------------------------------ finding the VM
function withTimeout(promise, ms, code) {
  let timer;
  const t = new Promise((_, rej) => { timer = setTimeout(() => { const e = new Error('timed out'); e.code = code || 'ETIMEDOUT'; rej(e); }, ms); });
  return Promise.race([promise, t]).finally(() => clearTimeout(timer));
}

function defaultSwitchAddress(cfg) {
  if (cfg && cfg.icsDns) return cfg.icsDns;
  try {
    for (const [name, list] of Object.entries(os.networkInterfaces())) {
      if (!/default switch/i.test(name)) continue;
      for (const a of list || []) if (a.family === 'IPv4' && !a.internal) return a.address;
    }
  } catch { /* fall through */ }
  return '192.168.160.1';
}

async function resolveName(name, cfg) {
  let err = '';
  try {
    const r = await withTimeout(dns.promises.lookup(name, { family: 4, all: true }), 3500, 'ETIMEOUT');
    if (r && r.length) return { ip: r[0].address };
  } catch (e) { err = e.code || e.message; }
  if (/\.mshome\.net$/i.test(name)) {
    // the Hyper-V Default Switch keeps its own little DNS server (on the switch address of this PC); ask it directly as well
    try {
      const rs = new dns.promises.Resolver({ timeout: 1500, tries: 1 });
      rs.setServers([defaultSwitchAddress(cfg)]);
      const a = await withTimeout(rs.resolve4(name), 3500, 'ETIMEOUT');
      if (a && a.length) return { ip: a[0] };
    } catch (e) { err = err || e.code || e.message; }
  }
  return { ip: null, err: err || 'ENOTFOUND' };
}

export class TargetResolver {
  constructor(cfg, log) {
    this.cfg = cfg;
    this.log = log;
    this.cache = null;       // { ip, source, name, at }
    this.inflight = null;
    this.lastError = '';
    this.errAt = 0;          // when the last look-up found nothing (so a burst of connections does not repeat slow look-ups)
    this.errResult = null;
  }

  // Candidate list, best first. Files are read again every time, so an edited vm-address.txt is picked up without a restart.
  candidates() {
    const c = [];
    const cfg = this.cfg;
    const addTok = (text, source) => { const t = classifyHostToken(text); if (t) c.push({ kind: t.kind, value: t.value, source }); };
    const addName = (n, source) => {
      if (!n) return;
      if (!n.includes('.')) { c.push({ kind: 'name', value: n + '.mshome.net', source }); c.push({ kind: 'name', value: n, source }); } else c.push({ kind: 'name', value: n, source });
    };
    if (cfg.vmHostArg) addTok(cfg.vmHostArg, 'command line --vm-host');
    if (cfg.vmHostEnv) {
      const t = classifyHostToken(cfg.vmHostEnv);
      if (!t) this.log.once('badenv', 'env PILLAGERS_VM_HOST is not an IPv4 address or a host name, so it is ignored');
      else if (t.kind === 'name') addName(t.value, 'env PILLAGERS_VM_HOST'); else c.push({ kind: 'ip', value: t.value, source: 'env PILLAGERS_VM_HOST' });
    }
    if (cfg.vmFile) {
      try {
        const info = parseAddressFile(fs.readFileSync(cfg.vmFile, 'utf8'));
        for (const ip of info.ips) c.push({ kind: 'ip', value: ip, source: 'file vm-address.txt' });
        for (const n of info.names) addName(n, 'file vm-address.txt');
      } catch { /* no file is normal */ }
    }
    if (cfg.vmName) addName(cfg.vmName, 'name ' + cfg.vmName + '.mshome.net');
    const seen = new Set();
    return c.filter((x) => { const k = x.kind + ':' + x.value.toLowerCase(); if (seen.has(k)) return false; seen.add(k); return true; });
  }

  async lookup(avoid) {
    const notes = [];
    let fallback = null;
    for (const cand of this.candidates()) {
      let ip = null;
      if (cand.kind === 'ip') ip = cand.value;
      else {
        const r = await resolveName(cand.value, this.cfg);
        ip = r.ip;
        if (!ip) { notes.push(cand.value + ': ' + r.err); continue; }
      }
      if (!this.cfg.allowAnyTarget && !isPrivateIPv4(ip)) { notes.push(cand.value + ' is ' + ip + ', not a private address, refused'); continue; }
      const found = { ip, source: cand.source, name: cand.kind === 'name' ? cand.value : '', at: Date.now() };
      if (!avoid || !avoid.has(ip)) return found;
      if (!fallback) fallback = found;
    }
    if (fallback) return fallback;
    return { error: notes.length ? notes.join('; ') : 'no VM address is known' };
  }

  // force = look again now (after a failed connect). avoid = addresses that just failed; another one is preferred when there is one.
  async get(force = false, avoid = null) {
    const now = Date.now();
    if (!force && this.cache && now - this.cache.at < RESOLVE_TTL_MS) return this.cache;
    if (!force && !this.cache && this.errResult && now - this.errAt < 3000) return this.errResult;
    if (this.inflight && !avoid) return this.inflight;
    const p = (async () => {
      const r = await this.lookup(avoid);
      if (r.error) {
        this.lastError = r.error;
        this.errAt = Date.now();
        this.errResult = r;
        if (!this.cache) this.log.once('noaddr', 'cannot find the VM yet: ' + r.error);
        return r;
      }
      const prev = this.cache && this.cache.ip;
      this.cache = r;
      this.lastError = '';
      this.errResult = null;
      if (prev !== r.ip) this.log('the VM is at ' + r.ip + ' (' + r.source + (prev ? ', was ' + prev : '') + ')');
      return r;
    })();
    this.inflight = p;
    try { return await p; } finally { if (this.inflight === p) this.inflight = null; }
  }
}

// ------------------------------------------------------------------------------------------------ small network helpers
function dial(ip, port, timeoutMs) {
  return new Promise((resolve, reject) => {
    const s = net.connect({ host: ip, port, allowHalfOpen: true });
    let done = false;
    const timer = setTimeout(() => {
      if (done) return;
      done = true;
      s.destroy();
      const e = new Error('connect timed out');
      e.code = 'ETIMEDOUT';
      reject(e);
    }, timeoutMs);
    const onErr = (e) => { if (done) return; done = true; clearTimeout(timer); s.destroy(); reject(e); };
    s.once('error', onErr);
    s.once('connect', () => {
      if (done) { s.destroy(); return; }
      done = true;
      clearTimeout(timer);
      s.removeListener('error', onErr);
      s.setNoDelay(true);
      s.setKeepAlive(true, 30000);
      resolve(s);
    });
  });
}

// 'open' | 'refused' | 'timeout' | 'unreachable' | an error code. Opens and closes one connection; sends nothing.
export async function probePort(ip, port, timeoutMs = 1500) {
  try {
    const s = await dial(ip, port, timeoutMs);
    s.destroy();
    return 'open';
  } catch (e) {
    if (e.code === 'ECONNREFUSED') return 'refused';
    if (e.code === 'ETIMEDOUT') return 'timeout';
    if (e.code === 'EHOSTUNREACH' || e.code === 'ENETUNREACH') return 'unreachable';
    return e.code || 'error';
  }
}

function describeFailure(code) {
  switch (code) {
    case 'ETIMEDOUT': case 'EHOSTUNREACH': case 'ENETUNREACH': return 'no answer from the VM';
    case 'ECONNREFUSED': return 'the VM answered but nothing listens on that port';
    case 'NOADDR': return 'the VM address is not known';
    default: return 'connection failed';
  }
}

function errorPageFor(spec, ip, code) {
  let why;
  if (code === 'NOADDR') why = 'the relay cannot find the vm. start the vm, then run vm-address-report.ps1 inside it, or put its address in vm-address.txt.';
  else if (code === 'ECONNREFUSED') why = 'the vm is running, but nothing answers on port ' + spec.target + ' there. start the game servers in the vm.';
  else why = 'the relay reached for the vm at ' + ip + ' port ' + spec.target + ' and got no answer. is the vm running? is the firewall rule "pillagers pad route" in place (vm-pad-route-firewall.ps1)?';
  const body = '<!doctype html><meta charset="utf-8"><title>vm not answering</title>'
    + '<body style="font:16px/1.5 Segoe UI,sans-serif;background:#111;color:#ddd;max-width:40em;margin:3em auto;padding:0 1em">'
    + '<h1 style="color:#f90;font-size:1.4em">the vm is not answering</h1><p>' + why + '</p>'
    + '<p style="color:#888">pillagers play relay on this pc, port ' + spec.listen + ' (' + code + '). reload this page when the vm is back.</p></body>';
  return 'HTTP/1.1 502 Bad Gateway\r\nContent-Type: text/html; charset=utf-8\r\nCache-Control: no-store\r\nConnection: close\r\nContent-Length: '
    + Buffer.byteLength(body) + '\r\n\r\n' + body;
}

function graceDestroy(sock, ms) {
  if (!sock || sock.destroyed) return;
  const t = setTimeout(() => { try { sock.destroy(); } catch { /* gone */ } }, ms);
  if (t.unref) t.unref();
  sock.once('close', () => clearTimeout(t));
}

const QUIET_CLIENT = new Set(['ECONNRESET', 'EPIPE', 'ECONNABORTED', 'ERR_STREAM_PREMATURE_CLOSE', 'ERR_STREAM_DESTROYED']);

// ------------------------------------------------------------------------------------------------ the relay
export function createRelay(cfg, log) {
  const resolver = new TargetResolver(cfg, log);
  const stats = {
    accepted: 0, active: 0, upstreamFailures: 0, upstreamErrors: 0, clientResets: 0, idleClosed: 0,
    bytesToVm: 0, bytesFromVm: 0,
  };
  const down = new Map();      // 'ip:port' -> { until, code }
  const sockets = new Set();
  const servers = [];
  const state = { startedAt: new Date(), lastOkAt: null, lastError: null, stopping: false };
  let statusTimer = null;

  function markDown(ip, port, code) { down.set(ip + ':' + port, { until: Date.now() + DOWN_TTL_MS, code }); }

  async function connectToVm(spec) {
    const t = await resolver.get(false);
    if (t.error) { const e = new Error(t.error); e.code = 'NOADDR'; throw e; }
    const key = t.ip + ':' + spec.target;
    const d = down.get(key);
    if (d && d.until > Date.now()) { const e = new Error('recent failure'); e.code = d.code; e.quick = true; e.ip = t.ip; throw e; }
    try {
      const s = await dial(t.ip, spec.target, cfg.connectTimeoutMs);
      state.lastOkAt = new Date();
      return { sock: s, ip: t.ip };
    } catch (e) {
      markDown(t.ip, spec.target, e.code || 'ERR');
      // the VM may have a new address: look again, and try once more if it is a different one
      const t2 = await resolver.get(true, new Set([t.ip]));
      if (!t2.error && t2.ip !== t.ip) {
        try {
          const s = await dial(t2.ip, spec.target, cfg.connectTimeoutMs);
          state.lastOkAt = new Date();
          return { sock: s, ip: t2.ip };
        } catch (e2) { markDown(t2.ip, spec.target, e2.code || 'ERR'); e2.ip = t2.ip; throw e2; }
      }
      e.ip = t.ip;
      throw e;
    }
  }

  function failClient(client, spec, err) {
    const code = err.code || 'ERR';
    stats.upstreamFailures++;
    state.lastError = { at: new Date().toISOString(), message: code + ' ' + describeFailure(code) };
    if (!err.quick || cfg.verbose) {
      log.once('fail:' + spec.listen + ':' + code, 'connection error: 127.0.0.1:' + spec.listen + ' -> VM ' + (err.ip || '?') + ':' + spec.target + ' ' + code + ' (' + describeFailure(code) + ')');
    }
    if (client.destroyed) return;
    if (cfg.errorPage) {
      try {
        client.end(errorPageFor(spec, err.ip || '?', code));
        client.resume();   // read and drop what the browser still sends, so closing does not reset the page away
        graceDestroy(client, 1500);
        return;
      } catch { /* fall through */ }
    }
    client.destroy();
  }

  function bridge(client, up, spec, upIp) {
    let counted = false;
    const finish = () => {
      if (counted) return;
      counted = true;
      stats.active = Math.max(0, stats.active - 1);
      stats.bytesToVm += client.bytesRead;
      stats.bytesFromVm += up.bytesRead;
      sockets.delete(client);
      sockets.delete(up);
    };
    sockets.add(up);
    client.setTimeout(cfg.idleSeconds * 1000);
    up.setTimeout(cfg.idleSeconds * 1000);
    const idle = () => { stats.idleClosed++; client.destroy(); up.destroy(); };
    client.once('timeout', idle);
    up.once('timeout', idle);
    up.on('error', (e) => {
      stats.upstreamErrors++;
      state.lastError = { at: new Date().toISOString(), message: (e.code || 'ERR') + ' from the VM' };
      log.once('up:' + spec.listen + ':' + (e.code || e.message), 'connection error: VM ' + upIp + ':' + spec.target + ' (port ' + spec.listen + ') ' + (e.code || e.message));
      client.destroy();
    });
    client.pipe(up);      // pipe keeps backpressure and passes a client half-close on as a half-close
    up.pipe(client);
    client.once('close', (hadError) => { if (hadError) up.destroy(); else graceDestroy(up, 30000); finish(); });
    up.once('close', (hadError) => { if (hadError) client.destroy(); else graceDestroy(client, 30000); finish(); });
  }

  async function handle(client, spec) {
    stats.accepted++;
    stats.active++;
    sockets.add(client);
    let gone = false;
    client.once('close', () => { gone = true; });
    client.on('error', (e) => {
      if (QUIET_CLIENT.has(e.code)) { stats.clientResets++; if (cfg.verbose) log.once('cr:' + spec.listen, 'browser side reset on port ' + spec.listen + ' (' + e.code + ')'); }
      else log.once('ce:' + spec.listen + ':' + e.code, 'connection error: browser side on port ' + spec.listen + ' ' + (e.code || e.message));
    });
    client.setNoDelay(true);
    let conn;
    try {
      conn = await connectToVm(spec);
    } catch (err) {
      stats.active = Math.max(0, stats.active - 1);
      sockets.delete(client);
      failClient(client, spec, err);
      return;
    }
    if (gone || client.destroyed) { conn.sock.destroy(); stats.active = Math.max(0, stats.active - 1); sockets.delete(client); return; }
    bridge(client, conn.sock, spec, conn.ip);
    client.resume();
  }

  function makeServer(spec) {
    const srv = net.createServer({ allowHalfOpen: true, pauseOnConnect: true }, (client) => { handle(client, spec).catch((e) => { log('internal error: ' + (e && e.message)); try { client.destroy(); } catch { /* gone */ } }); });
    srv.maxConnections = 1024;
    return srv;
  }

  function listenOn(srv, port, host) {
    return new Promise((resolve, reject) => {
      const onErr = (e) => reject(e);
      srv.once('error', onErr);
      srv.listen({ port, host, exclusive: true }, () => { srv.removeListener('error', onErr); resolve(); });
    });
  }

  function writeStatus(note) {
    if (!cfg.statusFile) return;
    try {
      const t = resolver.cache;
      const doc = {
        pid: process.pid,
        node: process.version,
        state: note || (state.stopping ? 'stopping' : 'running'),
        startedAt: state.startedAt.toISOString(),
        updatedAt: new Date().toISOString(),
        listen: cfg.specs.map((s) => ({ listen: s.listen, target: s.target })),
        target: t ? { ip: t.ip, source: t.source, name: t.name, foundAt: new Date(t.at).toISOString() } : null,
        targetProblem: t ? '' : resolver.lastError,
        lastOkAt: state.lastOkAt ? state.lastOkAt.toISOString() : null,
        lastError: state.lastError,
        stats: { ...stats, rssMB: Math.round(process.memoryUsage().rss / 1048576) },
      };
      fs.mkdirSync(path.dirname(cfg.statusFile), { recursive: true });
      const tmp = cfg.statusFile + '.' + process.pid + '.tmp';
      fs.writeFileSync(tmp, JSON.stringify(doc, null, 1));
      fs.renameSync(tmp, cfg.statusFile);
    } catch { /* the status file is a courtesy */ }
  }

  function removeStatus() {
    if (!cfg.statusFile) return;
    try {
      const j = JSON.parse(fs.readFileSync(cfg.statusFile, 'utf8'));
      if (j && j.pid === process.pid) fs.unlinkSync(cfg.statusFile);
    } catch { /* not ours or already gone */ }
  }

  async function portInUse(port) {
    const r = await probePort('127.0.0.1', port, 700);
    return r === 'open';
  }

  async function start() {
    // 1. refuse to start when a listen port is taken. HTTP.sys servers (tools\serve.ps1) make a plain bind fail with EACCES on Windows, so look first.
    const taken = [];
    for (const spec of cfg.specs) { if (await portInUse(spec.listen)) taken.push(spec.listen); }
    if (taken.length) {
      const err = new Error('port ' + taken.join(', ') + ' on 127.0.0.1 already answers');
      err.code = 'PORT_TAKEN';
      err.ports = taken;
      throw err;
    }
    // 2. listen. All or nothing.
    for (const spec of cfg.specs) {
      const srv = makeServer(spec);
      try {
        await listenOn(srv, spec.listen, '127.0.0.1');
      } catch (e) {
        for (const s of servers) { try { s.close(); } catch { /* ignore */ } }
        const err = new Error('cannot listen on 127.0.0.1:' + spec.listen + ' (' + (e.code || e.message) + ')');
        err.code = (e.code === 'EADDRINUSE' || e.code === 'EACCES') ? 'PORT_TAKEN' : (e.code || 'LISTEN_FAILED');
        err.ports = [spec.listen];
        err.detail = e.code || e.message;
        throw err;
      }
      servers.push(srv);
      if (cfg.alsoIpv6) {
        const s6 = makeServer(spec);
        try { await listenOn(s6, spec.listen, '::1'); servers.push(s6); } catch (e) { log('note: could not also listen on ::1:' + spec.listen + ' (' + (e.code || e.message) + ')'); }
      }
    }
    // 3. a program on ::1 would be reached first by a browser that tries localhost as ::1
    if (!cfg.alsoIpv6) {
      for (const spec of cfg.specs) {
        const r = await probePort('::1', spec.listen, 500);
        if (r === 'open') log('WARNING: something else answers on [::1]:' + spec.listen + '. A browser that tries ::1 first for "localhost" would reach it instead of the VM.');
      }
    }
    log('relay started (pid ' + process.pid + '): ' + cfg.specs.map((s) => '127.0.0.1:' + s.listen + ' -> VM port ' + s.target).join(', '));
    const t = await resolver.get(true);
    if (t.error) log('the VM address is not known yet (' + t.error + '); will keep looking whenever a connection arrives');
    writeStatus();
    statusTimer = setInterval(() => writeStatus(), 5000);
    if (statusTimer.unref) statusTimer.unref();
  }

  async function stop() {
    state.stopping = true;
    if (statusTimer) clearInterval(statusTimer);
    for (const s of servers) { try { s.close(); } catch { /* ignore */ } }
    await new Promise((r) => setTimeout(r, 300));
    for (const s of sockets) { try { s.destroy(); } catch { /* gone */ } }
    log('relay stopped');
    removeStatus();
  }

  return { start, stop, stats, resolver, servers, writeStatus };
}

// ------------------------------------------------------------------------------------------------ probe mode
async function runProbe(cfg) {
  const log = makeLogger('', { echo: false });
  const resolver = new TargetResolver(cfg, log);
  const out = (l) => process.stdout.write(l + '\n');
  const t = await resolver.get(true);
  if (t.error) {
    out('ok=no');
    out('error=' + t.error);
    out('The VM address could not be found (' + t.error + ').');
    out('Start the VM, then run vm-address-report.ps1 inside it, or set env PILLAGERS_VM_HOST / the file ' + cfg.vmFile + '.');
    return 4;
  }
  out('vm=' + t.ip);
  out('source=' + t.source);
  let allOpen = true;
  for (const spec of cfg.specs) {
    const r = await probePort(t.ip, spec.target, Math.min(cfg.connectTimeoutMs, 3000));
    out('port.' + spec.target + '=' + r);
    if (r !== 'open') allOpen = false;
    if (r === 'timeout' || r === 'unreachable') out('  port ' + spec.target + ': no answer. The VM may be off, or its firewall rule "Pillagers pad route" is missing (run vm-pad-route-firewall.ps1 in the VM).');
    else if (r === 'refused') out('  port ' + spec.target + ': the VM answers but nothing listens there. Start the game servers in the VM.');
  }
  out('ok=' + (allOpen ? 'yes' : 'no'));
  return allOpen ? 0 : 5;
}

// ------------------------------------------------------------------------------------------------ main
async function main(argv) {
  let cfg;
  try { cfg = parseArgs(argv, process.env); } catch (e) {
    if (e instanceof UsageError) { console.error('play-relay: ' + e.message); console.error(USAGE); return 2; }
    throw e;
  }
  if (cfg.help) { console.log(USAGE); return 0; }
  if (cfg.probe) return runProbe(cfg);
  try { process.stdout.on('error', () => { /* hidden window: no console to write to */ }); } catch { /* ignore */ }

  // a plainly wrong (public) literal address is refused at once, with a clear message
  if (!cfg.allowAnyTarget) {
    for (const lit of [cfg.vmHostArg, cfg.vmHostEnv]) {
      if (lit && net.isIPv4(lit) && !isPrivateIPv4(lit)) {
        console.error('play-relay: ' + lit + ' is not a private address (10.x, 172.16-31.x, 192.168.x). Refusing, so game traffic can never leave this PC by mistake. Use --allow-any-target only on purpose.');
        return 2;
      }
    }
  }
  const log = makeLogger(cfg.log);
  const relay = createRelay(cfg, log);
  try {
    await relay.start();
  } catch (e) {
    if (e.code === 'PORT_TAKEN') {
      log('NOT STARTED: port ' + (e.ports || []).join(', ') + ' on 127.0.0.1 is already in use' + (e.detail ? ' (' + e.detail + ')' : '') + '.');
      log('  Probably the main PC\'s own play server (tools\\serve.ps1) or collector is still running, or the relay or the party copy is already running.');
      log('  Nothing was changed. Stop whatever holds the port (host-stop.ps1 stops the Pillagers servers), then start the relay again.');
      return 3;
    }
    log('NOT STARTED: ' + (e && e.message ? e.message : e));
    return 1;
  }
  let crashes = 0;
  process.on('uncaughtException', (e) => {
    crashes++;
    log('unexpected error: ' + (e && e.message ? e.message : e));
    if (crashes > 50) { log('too many unexpected errors; stopping'); process.exit(1); }
  });
  const shutdown = async () => { await relay.stop(); process.exit(0); };
  for (const sig of ['SIGINT', 'SIGTERM', 'SIGBREAK']) { try { process.on(sig, shutdown); } catch { /* not on this OS */ } }
  return new Promise(() => { /* run until a signal or kill */ });
}

const isMain = process.argv[1] && pathToFileURL(path.resolve(process.argv[1])).href === import.meta.url;
if (isMain) {
  main(process.argv.slice(2)).then((code) => { if (typeof code === 'number') process.exit(code); }, (e) => { console.error('play-relay: ' + (e && e.stack ? e.stack : e)); process.exit(1); });
}
