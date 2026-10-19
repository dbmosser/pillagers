// host-agent.mjs : runs on the MAIN PC as him (no administrator). It lets the VM's Claude ask for the FIXED jobs in jobs.mjs and nothing else.
//
//   node host-agent.mjs            start the agent (listens on the Default Switch address only, default 192.168.160.1:8830)
//   node host-agent.mjs --status   print what it would listen on and whether the key is present, then exit
//   --ip ADDR        bind to this address instead (must be the Default Switch address; --any-ip lifts that for a test)
//   --port N         listen on this port instead of 8830
//   --once           handle one request and exit (used by the tests)
//
// It binds ONLY to the Hyper-V Default Switch address, so nothing on the real network card can reach it. Every request must carry a signature
// made with the shared key (setup-key.ps1 writes it, the same file on both machines). A request without a good signature, or a repeat of one
// already seen, or one with a far-off timestamp, is refused. The only things it ever runs are the named jobs. ASCII only.
import http from 'node:http';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  AGENT_PORT, DEFAULT_SWITCH_IP, MAX_SKEW_MS, BRIDGE_VERSION,
  dataDir, shareDir, readKey, hmac, safeEqual, sha256hex, EMPTY_HASH, sigText, makeLog, makeNonceGuard, stamp,
} from './bridge-common.mjs';
import { JOBS, JOB_NAMES } from './jobs.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO_ROOT = path.resolve(HERE, '..', '..');
const LOG = makeLog(path.join(dataDir(), 'logs', 'host-agent.log'), true);

function parseArgs(argv) {
  const o = { ip: null, port: AGENT_PORT, status: false, anyIp: false, once: false };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--status') o.status = true;
    else if (a === '--any-ip') o.anyIp = true;
    else if (a === '--once') o.once = true;
    else if (a === '--ip') o.ip = argv[++i];
    else if (a === '--port') o.port = parseInt(argv[++i], 10) || AGENT_PORT;
  }
  return o;
}

// the main PC's Default Switch address right now, or null if the switch is not up yet.
function defaultSwitchIp() {
  try {
    for (const [name, list] of Object.entries(os.networkInterfaces())) {
      if (!/default switch/i.test(name)) continue;
      for (const a of list || []) if (a.family === 'IPv4' && !a.internal) return a.address;
    }
  } catch { /* none */ }
  return null;
}

function readBody(req, cap = 16 * 1024 * 1024) {
  return new Promise((resolve, reject) => {
    const chunks = []; let n = 0;
    req.on('data', (c) => { n += c.length; if (n > cap) { reject(new Error('too big')); req.destroy(); } else chunks.push(c); });
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}
const send = (res, code, obj) => { const b = Buffer.from(JSON.stringify(obj)); res.writeHead(code, { 'content-type': 'application/json', 'content-length': b.length }); res.end(b); };

async function main() {
  const opt = parseArgs(process.argv.slice(2));
  const key = readKey();
  const liveSwitch = defaultSwitchIp();
  const bindIp = opt.ip || liveSwitch || DEFAULT_SWITCH_IP;

  if (opt.status) {
    LOG('status: key ' + (key ? 'present' : 'MISSING') + '; Default Switch ' + (liveSwitch || 'not up') + '; would bind ' + bindIp + ':' + opt.port + '; jobs: ' + JOB_NAMES.join(', '));
    process.exit(key ? 0 : 1);
  }
  if (!key) { LOG('NOT STARTED: no shared key. Run setup-key.ps1 on this PC first (it writes ' + path.join(dataDir(), 'key.txt') + ').'); process.exit(1); }
  // refuse to bind to a real network card by accident: the bind address must be the Default Switch address unless --any-ip is given for a test.
  if (!opt.anyIp && bindIp !== '127.0.0.1' && liveSwitch && bindIp !== liveSwitch) {
    LOG('NOT STARTED: ' + bindIp + ' is not the Default Switch address (' + liveSwitch + '). Use --any-ip only for a local test.'); process.exit(1);
  }

  const nonces = makeNonceGuard(MAX_SKEW_MS);
  const ctx = { log: LOG, shareDir: shareDir(), repoRoot: REPO_ROOT };

  const server = http.createServer(async (req, res) => {
    const peer = req.socket.remoteAddress || '';
    let body = Buffer.alloc(0);
    try { if (req.method === 'POST') body = await readBody(req); } catch { return send(res, 413, { ok: false, error: 'request too big' }); }
    try {
      if (req.method !== 'POST' || req.url !== '/job') return send(res, 404, { ok: false, error: 'POST /job only' });
      const job = String(req.headers['x-bridge-job'] || '');
      const ts = String(req.headers['x-bridge-ts'] || '');
      const nonce = String(req.headers['x-bridge-nonce'] || '');
      const sig = String(req.headers['x-bridge-sig'] || '');
      const bodyHash = body.length ? sha256hex(body) : EMPTY_HASH;
      const want = hmac(key, sigText(job, ts, nonce, bodyHash));
      if (!safeEqual(sig, want)) { LOG.once('badsig' + peer, 'refused a request with a bad signature from ' + peer + ' (job ' + job + ')'); return send(res, 401, { ok: false, error: 'bad signature' }); }
      const skew = Math.abs(Date.now() - (parseInt(ts, 10) || 0));
      if (!ts || skew > MAX_SKEW_MS) return send(res, 401, { ok: false, error: 'timestamp too far off (' + skew + ' ms)' });
      if (!nonce || !nonces.check(nonce)) return send(res, 409, { ok: false, error: 'nonce reused or missing (replay refused)' });
      if (!JOBS[job]) return send(res, 400, { ok: false, error: 'unknown job; allowed: ' + JOB_NAMES.join(', ') });

      let args = {};
      if (body.length) { try { args = JSON.parse(body.toString('utf8')); } catch { return send(res, 400, { ok: false, error: 'body is not JSON' }); } }
      LOG('job ' + job + ' from ' + peer + (args && args.key ? ' (' + args.key + ')' : ''));
      let out;
      try { out = await JOBS[job](args, ctx); } catch (e) { LOG('job ' + job + ' threw: ' + (e && e.message)); return send(res, 500, { ok: false, error: 'job failed: ' + (e && e.message ? e.message : e) }); }
      send(res, 200, out && typeof out === 'object' ? out : { ok: true, result: out });
    } finally {
      if (opt.once) setTimeout(() => server.close(() => process.exit(0)), 50);
    }
  });

  server.on('error', (e) => { LOG('NOT STARTED: ' + (e && e.message ? e.message : e)); process.exit(1); });
  server.listen(opt.port, bindIp, () => {
    LOG('host agent ' + BRIDGE_VERSION + ' listening on ' + bindIp + ':' + opt.port + ' (jobs: ' + JOB_NAMES.join(', ') + ')');
    LOG('share folder: ' + ctx.shareDir);
  });
  for (const sig of ['SIGINT', 'SIGTERM', 'SIGBREAK']) { try { process.on(sig, () => { LOG('stopping (' + sig + ')'); server.close(() => process.exit(0)); }); } catch { /* not on this OS */ } }
}

main().catch((e) => { LOG('fatal: ' + (e && e.stack ? e.stack : e)); process.exit(1); });
