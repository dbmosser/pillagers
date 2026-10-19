// bridge-common.mjs : shared helpers for the HOST BRIDGE (see README.md next to this file).
//
// The host bridge lets the VM's Claude ask the MAIN PC to run a FIXED set of named Pillagers jobs (graphics card / local AI stats, play the
// game in the main PC's Chrome and report fps + a picture, read the pads, report memory / CPU / GPU, swap files through one shared folder, run
// the move-kit scripts). It is NOT a general "run any command" shell: the only things that run are the named jobs in jobs.mjs. A new job is a new
// named entry, added on purpose.
//
//   host-agent.mjs  runs on the MAIN PC as him (no administrator). It listens only on the Hyper-V Default Switch address (192.168.160.1) so only
//                   the VM can reach it, and every request must carry a valid signature made with the shared key.
//   hostctl.mjs     runs INSIDE THE VM. It is what the VM's Claude calls; it signs the request and prints the JSON result.
//
// The shared key is 32 random bytes written by setup-key.ps1 to a file outside the repository, the same file on both machines (he copies it over
// once). Nothing on the real network can reach the agent, the firewall rule limits callers to the Default Switch, and every request is signed, so
// a request cannot be forged or replayed. ASCII only.
import crypto from 'node:crypto';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

export const BRIDGE_VERSION = '1.0';
export const AGENT_PORT = 8830;          // the host agent, bound to the Default Switch address only
export const DEFAULT_SWITCH_IP = '192.168.160.1';
export const MAX_SKEW_MS = 120000;       // a signed request older or newer than this (clock difference allowed for) is refused

// PILLAGERS_BRIDGE_DIR moves everything (tests use it). Default %LOCALAPPDATA%\PillagersBridge, outside the repository on purpose.
export function dataDir() {
  return process.env.PILLAGERS_BRIDGE_DIR || path.join(process.env.LOCALAPPDATA || path.join(os.homedir(), 'AppData', 'Local'), 'PillagersBridge');
}
export const keyFile = () => path.join(dataDir(), 'key.txt');
export const shareDir = () => path.join(dataDir(), 'share');   // the one folder files may be swapped through

export function sha256hex(buf) { return crypto.createHash('sha256').update(buf).digest('hex'); }
export const EMPTY_HASH = sha256hex(Buffer.alloc(0));
export function hashFileSafe(file) {
  return new Promise((resolve) => {
    const h = crypto.createHash('sha256');
    fs.createReadStream(file).on('data', (c) => h.update(c)).on('error', () => resolve('')).on('end', () => resolve(h.digest('hex')));
  });
}
export function hmac(key, text) { return crypto.createHmac('sha256', Buffer.from(key, 'hex')).update(String(text)).digest('hex'); }
export function safeEqual(a, b) {
  const x = Buffer.from(String(a || ''));
  const y = Buffer.from(String(b || ''));
  return x.length === y.length && crypto.timingSafeEqual(x, y);
}
export function newKey() { return crypto.randomBytes(32).toString('hex'); }
export const isKey = (k) => /^[0-9a-f]{64}$/.test(String(k || ''));

export function readKey(file = keyFile()) {
  try { const k = fs.readFileSync(file, 'utf8').trim(); return isKey(k) ? k : null; } catch { return null; }
}
export function writeKey(key, file = keyFile()) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, key + '\n', { mode: 0o600 });
}

// What the signature covers. Timestamp + a one-time nonce stop replay; the body hash ties the signature to this exact job and arguments.
export function sigText(job, ts, nonce, bodyHash) { return [BRIDGE_VERSION, String(job), String(ts), String(nonce), bodyHash].join('|'); }

function pad2(n) { return String(n).padStart(2, '0'); }
export function stamp(d = new Date()) {
  return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()) + ' ' + pad2(d.getHours()) + ':' + pad2(d.getMinutes()) + ':' + pad2(d.getSeconds());
}
// A small logger: one line per call, rolled to .old at 4 MB. A log that cannot be written never stops the bridge.
export function makeLog(file, echo = false) {
  let ok = true;
  try { fs.mkdirSync(path.dirname(file), { recursive: true }); } catch { ok = false; }
  const recent = new Map();
  const log = (msg) => {
    const line = stamp() + ' ' + String(msg).replace(/[\r\n\t]+/g, ' ').replace(/[^\x20-\x7e]/g, '?').slice(0, 600);
    if (echo) { try { process.stdout.write(line + '\n'); } catch { /* no console */ } }
    if (!ok) return;
    try {
      try { if (fs.statSync(file).size > 4 * 1024 * 1024) fs.renameSync(file, file + '.old'); } catch { /* new file */ }
      fs.appendFileSync(file, line + '\n');
    } catch { /* ignore */ }
  };
  // the same key again within 60 s is not written again (a VM that is off would otherwise fill the log)
  log.once = (key, msg) => { const t = recent.get(key); if (t && Date.now() - t < 60000) return; recent.set(key, Date.now()); if (recent.size > 100) recent.clear(); log(msg); };
  return log;
}

// A nonce store that refuses a repeat within the skew window (replay guard). Kept small and swept by time.
export function makeNonceGuard(windowMs = MAX_SKEW_MS) {
  const seen = new Map();
  return {
    check(nonce) {
      const now = Date.now();
      for (const [k, t] of seen) if (now - t > windowMs) seen.delete(k);
      if (!nonce || seen.has(nonce)) return false;
      seen.set(nonce, now);
      return true;
    },
  };
}
