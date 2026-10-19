// hostctl.mjs : runs INSIDE THE VM. This is what the VM's Claude calls to ask the MAIN PC to run a named job. It signs the request with the
// shared key and prints the JSON reply. It never runs anything itself; it only asks the host agent, which only does the fixed jobs.
//
//   node hostctl.mjs ping
//   node hostctl.mjs stats
//   node hostctl.mjs kit ollama-status
//   node hostctl.mjs kit play-status
//   node hostctl.mjs share-list
//   node hostctl.mjs share-get name=run-123.json           (prints the file's text; add --save PATH to write it)
//   node hostctl.mjs share-put name=note.txt --file ./note.txt
//
//   --host ADDR   the main PC's Default Switch address (default: env PILLAGERS_HOST_IP, else 192.168.160.1)
//   --port N      default 8830
//   --save PATH   for share-get: write the file out instead of printing it
//   --file PATH   for share-put: the local file to send
//   key=VALUE ... extra arguments for the job (parsed as strings)
//
// The key is read from the same file as on the main PC (setup-key.ps1 wrote it; he copied it into the VM once). ASCII only.
import crypto from 'node:crypto';
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import { AGENT_PORT, DEFAULT_SWITCH_IP, BRIDGE_VERSION, dataDir, keyFile, readKey, hmac, sha256hex, EMPTY_HASH, sigText } from './bridge-common.mjs';

function parse(argv) {
  const o = { host: process.env.PILLAGERS_HOST_IP || DEFAULT_SWITCH_IP, port: AGENT_PORT, job: null, args: {}, save: null, file: null };
  const rest = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--host') o.host = argv[++i];
    else if (a === '--port') o.port = parseInt(argv[++i], 10) || AGENT_PORT;
    else if (a === '--save') o.save = argv[++i];
    else if (a === '--file') o.file = argv[++i];
    else if (/^[A-Za-z0-9_]+=/.test(a)) { const k = a.slice(0, a.indexOf('=')); o.args[k] = a.slice(a.indexOf('=') + 1); }
    else rest.push(a);
  }
  o.job = rest[0] || null;
  if (rest[1] && o.job === 'kit' && !o.args.key) o.args.key = rest[1];   // allow: kit ollama-status
  return o;
}

function request(opt, key) {
  return new Promise((resolve, reject) => {
    if (opt.job === 'share-put' && opt.file) {
      try { opt.args.base64 = fs.readFileSync(opt.file).toString('base64'); if (!opt.args.name) opt.args.name = path.basename(opt.file); } catch (e) { return reject(new Error('cannot read --file: ' + e.message)); }
    }
    const body = Buffer.from(JSON.stringify(opt.args || {}));
    const ts = String(Date.now());
    const nonce = crypto.randomBytes(16).toString('hex');
    const bodyHash = body.length ? sha256hex(body) : EMPTY_HASH;
    const sig = hmac(key, sigText(opt.job, ts, nonce, bodyHash));
    const req = http.request({
      host: opt.host, port: opt.port, path: '/job', method: 'POST',
      headers: { 'content-type': 'application/json', 'content-length': body.length, 'x-bridge-job': opt.job, 'x-bridge-ts': ts, 'x-bridge-nonce': nonce, 'x-bridge-sig': sig },
      timeout: 200000,
    }, (res) => {
      const chunks = [];
      res.on('data', (c) => chunks.push(c));
      res.on('end', () => { const txt = Buffer.concat(chunks).toString('utf8'); let j = null; try { j = JSON.parse(txt); } catch { /* raw */ } resolve({ status: res.statusCode, json: j, raw: txt }); });
    });
    req.on('timeout', () => { req.destroy(new Error('the main PC did not answer in time')); });
    req.on('error', reject);
    req.end(body);
  });
}

async function main() {
  const opt = parse(process.argv.slice(2));
  if (!opt.job) { console.error('usage: node hostctl.mjs <ping|stats|kit|share-list|share-get|share-put> [key=value ...]  (see the top of this file)'); process.exit(2); }
  const key = readKey();
  if (!key) { console.error('no shared key in ' + keyFile() + '. Copy key.txt from the main PC into ' + dataDir() + ' in this VM (setup-key.ps1 -Show prints it on the main PC).'); process.exit(1); }
  let r;
  try { r = await request(opt, key); } catch (e) {
    console.error(JSON.stringify({ ok: false, error: 'cannot reach the main PC at ' + opt.host + ':' + opt.port + ' (' + (e && e.message ? e.message : e) + '). Is host-agent running on the main PC, and is the firewall rule in place?', bridge: BRIDGE_VERSION }));
    process.exit(1);
  }
  // share-get with --save: write the decoded file out, print a short note.
  if (opt.job === 'share-get' && opt.save && r.json && r.json.ok && r.json.base64) {
    fs.writeFileSync(opt.save, Buffer.from(r.json.base64, 'base64'));
    console.log(JSON.stringify({ ok: true, saved: opt.save, size: r.json.size, sha256: r.json.sha256 }));
    process.exit(0);
  }
  console.log(r.json ? JSON.stringify(r.json, null, 2) : r.raw);
  process.exit(r.json && r.json.ok === false ? 1 : 0);
}

main().catch((e) => { console.error('hostctl: ' + (e && e.stack ? e.stack : e)); process.exit(1); });
