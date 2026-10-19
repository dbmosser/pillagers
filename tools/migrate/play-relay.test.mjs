// play-relay.test.mjs : tests for play-relay.mjs. No admin, no npm packages. Run:   node --test play-relay.test.mjs      (from tools\migrate)
// It starts throwaway servers and relays on 127.0.0.1 ports RELAY_TEST_BASE .. +9 (default 18802..18811) and one optional test that uses the
// Default Switch address (192.168.160.1) and tools\serve.ps1 to prove the HTTP.sys path. It never touches 8802, 8799 or any real server,
// reads no real vm-address.txt (every relay gets --vm-file in a temp folder) and cleans up after itself.
// ASCII only.
import { describe, it, before, after } from 'node:test';
import assert from 'node:assert/strict';
import net from 'node:net';
import http from 'node:http';
import os from 'node:os';
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { spawn, spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import {
  parsePortSpecs, isPrivateIPv4, classifyHostToken, parseAddressFile, parseArgs, UsageError, probePort,
} from './play-relay.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const RELAY = path.join(HERE, 'play-relay.mjs');
const BASE = Number(process.env.RELAY_TEST_BASE || 18802);
const P_RELAY = BASE;          // the relay listens here
const P_TARGET = BASE + 1;     // the fake "VM" server listens here
const P_RELAY2 = BASE + 2;
const P_TARGET2 = BASE + 3;
const TMP = fs.mkdtempSync(path.join(os.tmpdir(), 'play-relay-test-'));
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const children = new Set();
const servers = new Set();
const shared = {};

function cleanEnv(extra = {}) {
  const e = { ...process.env };
  delete e.PILLAGERS_VM_HOST; delete e.PILLAGERS_VM_NAME; delete e.PILLAGERS_RELAY_PORTS;
  return { ...e, ...extra };
}

async function freePortCheck(port) {
  const r = await probePort('127.0.0.1', port, 500);
  assert.equal(r, 'refused', 'test port ' + port + ' is not free (' + r + '); set RELAY_TEST_BASE to another number');
}

// ------------------------------------------------------------------ helpers: relay process
function startRelay(args, { env = {}, name = 'r' + Math.random().toString(36).slice(2, 7), waitStart = true, vmFileContent = null } = {}) {
  const logFile = path.join(TMP, name + '.log');
  const statusFile = path.join(TMP, name + '.status.json');
  const vmFile = path.join(TMP, name + '.vm-address.txt');
  if (vmFileContent !== null) fs.writeFileSync(vmFile, vmFileContent);
  const full = [RELAY, '--log', logFile, '--status-file', statusFile];
  if (!args.includes('--vm-file')) full.push('--vm-file', vmFile);
  if (!args.includes('--vm-name')) full.push('--vm-name', '');
  full.push(...args);
  const proc = spawn(process.execPath, full, { env: cleanEnv(env), stdio: ['ignore', 'pipe', 'pipe'], windowsHide: true });
  children.add(proc);
  let out = '';
  proc.stdout.on('data', (d) => { out += d; });
  proc.stderr.on('data', (d) => { out += d; });
  const exited = new Promise((resolve) => proc.once('exit', (code) => resolve(code)));
  const handle = {
    proc, logFile, statusFile, vmFile, exited,
    out: () => out,
    log: () => { try { return fs.readFileSync(logFile, 'utf8'); } catch { return ''; } },
    status: () => { try { return JSON.parse(fs.readFileSync(statusFile, 'utf8')); } catch { return null; } },
    stop: async () => { if (proc.exitCode === null) { proc.kill(); await exited; } },
  };
  if (!waitStart) return Promise.resolve(handle);
  return new Promise((resolve, reject) => {
    const t0 = Date.now();
    const iv = setInterval(() => {
      if (/relay started/.test(handle.log())) { clearInterval(iv); resolve(handle); }
      else if (proc.exitCode !== null) { clearInterval(iv); reject(new Error('relay exited early with code ' + proc.exitCode + ': ' + out + handle.log())); }
      else if (Date.now() - t0 > 8000) { clearInterval(iv); reject(new Error('relay did not start in 8 s: ' + out)); }
    }, 50);
  });
}

// ------------------------------------------------------------------ helpers: servers and clients
function listen(server, port, host = '127.0.0.1') {
  servers.add(server);
  return new Promise((resolve, reject) => { server.once('error', reject); server.listen(port, host, () => resolve(server)); });
}
function closeServer(server) {
  servers.delete(server);
  return new Promise((resolve) => { try { server.closeAllConnections?.(); } catch { /* old node */ } server.close(() => resolve()); });
}

// One raw HTTP exchange over a TCP socket (so the Host header is exactly what we write). Reads until the server closes.
function rawHttp({ host = '127.0.0.1', port, hostHeader, pathName = '/', method = 'GET', body = null, timeout = 20000, onData = null }) {
  return new Promise((resolve, reject) => {
    const s = net.connect({ host, port });
    const chunks = [];
    const timer = setTimeout(() => { s.destroy(); reject(new Error('client timeout')); }, timeout);
    s.on('connect', () => {
      let req = method + ' ' + pathName + ' HTTP/1.1\r\nHost: ' + hostHeader + '\r\nConnection: close\r\n';
      if (body) req += 'Content-Length: ' + body.length + '\r\n';
      s.write(req + '\r\n');
      if (body) s.write(body);
    });
    s.on('data', (d) => { chunks.push(d); if (onData) onData(d, s); });
    s.on('error', (e) => { clearTimeout(timer); reject(e); });
    s.on('close', () => {
      clearTimeout(timer);
      const buf = Buffer.concat(chunks);
      const i = buf.indexOf('\r\n\r\n');
      const head = i >= 0 ? buf.slice(0, i).toString('latin1') : buf.toString('latin1');
      const status = Number((/^HTTP\/1\.[01] (\d{3})/.exec(head) || [])[1] || 0);
      resolve({ status, head, body: i >= 0 ? buf.slice(i + 4) : Buffer.alloc(0), raw: buf });
    });
  });
}

const sha = (buf) => crypto.createHash('sha256').update(buf).digest('hex');

// ------------------------------------------------------------------ tests
before(async () => {
  for (const p of [P_RELAY, P_TARGET, P_RELAY2, P_TARGET2]) await freePortCheck(p);
});

after(async () => {
  for (const c of children) { try { if (c.exitCode === null) c.kill(); } catch { /* gone */ } }
  for (const s of [...servers]) { try { await closeServer(s); } catch { /* gone */ } }
  try { fs.rmSync(TMP, { recursive: true, force: true }); } catch { /* leave it */ }
});

describe('pure pieces', () => {
  it('parsePortSpecs', () => {
    assert.deepEqual(parsePortSpecs('8802,8799'), [{ listen: 8802, target: 8802 }, { listen: 8799, target: 8799 }]);
    assert.deepEqual(parsePortSpecs(' 18802:18803 '), [{ listen: 18802, target: 18803 }]);
    for (const bad of ['', 'abc', '80', '8802,8802', '70000', '8802:0', '8802:', '8802;8799']) assert.throws(() => parsePortSpecs(bad), UsageError, bad);
  });
  it('isPrivateIPv4', () => {
    for (const ok of ['10.0.0.1', '127.0.0.1', '172.16.5.5', '172.31.255.1', '192.168.164.103', '192.168.160.1', '169.254.1.1']) assert.equal(isPrivateIPv4(ok), true, ok);
    for (const no of ['8.8.8.8', '172.32.0.1', '172.15.0.1', '192.169.0.1', '0.0.0.0', '255.255.255.255', '1.2.3', '300.1.1.1', 'localhost', '']) assert.equal(isPrivateIPv4(no), false, no);
  });
  it('classifyHostToken', () => {
    assert.deepEqual(classifyHostToken('192.168.1.5'), { kind: 'ip', value: '192.168.1.5' });
    assert.deepEqual(classifyHostToken('VM_Oct2026.mshome.net'), { kind: 'name', value: 'VM_Oct2026.mshome.net' });
    for (const bad of ['', ' ', 'a b', 'x;rm', '-bad', 'bad-', '1.2.3', 'http://x', 'a/b', 'a\\b', 'a:b']) assert.equal(classifyHostToken(bad), null, JSON.stringify(bad));
  });
  it('parseAddressFile', () => {
    assert.deepEqual(parseAddressFile('192.168.164.103\n'), { ips: ['192.168.164.103'], names: [] });
    assert.deepEqual(parseAddressFile('\uFEFF# comment\r\ncomputer=VM_Oct2026\r\nip=192.168.164.103\r\nmshome=VM_Oct2026.mshome.net\r\nhostAddress=192.168.160.1\r\n'),
      { ips: ['192.168.164.103'], names: ['VM_Oct2026', 'VM_Oct2026.mshome.net'] });
    assert.deepEqual(parseAddressFile('ip=not an address\nip=8.8.8.8;evil\n; junk\n'), { ips: [], names: [] });
    assert.deepEqual(parseAddressFile('myvm'), { ips: [], names: ['myvm'] });
    assert.deepEqual(parseAddressFile(''), { ips: [], names: [] });
  });
  it('parseArgs', () => {
    const c = parseArgs(['--ports', '18802', '--vm-host=10.1.2.3', '--idle-seconds', '5'], {});
    assert.equal(c.specs[0].listen, 18802);
    assert.equal(c.vmHostArg, '10.1.2.3');
    assert.equal(c.idleSeconds, 5);
    assert.equal(parseArgs([], { PILLAGERS_VM_HOST: '10.9.9.9' }).vmHostEnv, '10.9.9.9');
    assert.equal(parseArgs([], {}).specs.map((s) => s.listen).join(), '8802,8799');
    for (const bad of [['--nope'], ['--ports'], ['stray'], ['--vm-host', 'a b'], ['--idle-seconds', '0'], ['--probe=1']]) assert.throws(() => parseArgs(bad, {}), UsageError, bad.join(' '));
  });
});

describe('forwarding', () => {
  it('forwards HTTP byte for byte and keeps the Host header untouched', async () => {
    let seenHost = '';
    const srv = http.createServer((req, res) => { seenHost = req.headers.host; res.setHeader('X-Seen-Host', req.headers.host); res.end('hello from the vm'); });
    await listen(srv, P_TARGET);
    const relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1']);
    try {
      const r = await rawHttp({ port: P_RELAY, hostHeader: 'localhost:' + P_RELAY });
      assert.equal(r.status, 200);
      assert.equal(r.body.toString(), 'hello from the vm');
      assert.equal(seenHost, 'localhost:' + P_RELAY);
      assert.match(r.head, /x-seen-host: localhost:/i);
    } finally { await relay.stop(); await closeServer(srv); }
  });

  it('handles a client half-close (request, FIN, then the answer still arrives)', async () => {
    const srv = net.createServer({ allowHalfOpen: true }, (c) => {
      let got = '';
      c.on('data', (d) => { got += d; });
      c.on('end', () => { c.end('echo:' + got + ':done'); });   // answers only after the client's FIN
    });
    await listen(srv, P_TARGET);
    const relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1']);
    try {
      const reply = await new Promise((resolve, reject) => {
        const c = net.connect({ port: P_RELAY, host: '127.0.0.1', allowHalfOpen: true });
        let buf = '';
        c.on('data', (d) => { buf += d; });
        c.on('error', reject);
        c.on('close', () => resolve(buf));
        c.on('connect', () => c.end('ping'));
        setTimeout(() => { c.destroy(); reject(new Error('timeout')); }, 8000);
      });
      assert.equal(reply, 'echo:ping:done');
    } finally { await relay.stop(); await closeServer(srv); }
  });

  it('moves large data both ways intact, and a slow reader makes the sender wait (backpressure)', async () => {
    const SIZE = 96 * 1024 * 1024;
    const chunk = crypto.randomBytes(1024 * 1024);
    let serverWritten = 0;
    let uploadHash = '';
    const srv = net.createServer({ allowHalfOpen: true }, (c) => {
      c.once('data', (first) => {
        const cmd = first.toString().split('\n')[0];
        if (cmd === 'DOWN') {
          let left = SIZE;
          const hash = crypto.createHash('sha256');
          const pump = () => {
            while (left > 0) {
              const n = Math.min(left, chunk.length);
              const piece = n === chunk.length ? chunk : chunk.subarray(0, n);
              hash.update(piece);
              left -= n;
              serverWritten += n;
              if (!c.write(piece)) { c.once('drain', pump); return; }
            }
            shared.downHash = hash.digest('hex');
            c.end();
          };
          pump();
        } else {
          const hash = crypto.createHash('sha256');
          let total = 0;
          const feed = (d) => { hash.update(d); total += d.length; };
          feed(first.subarray(first.indexOf('\n') + 1));
          c.on('data', feed);
          c.on('end', () => { uploadHash = hash.digest('hex') + ':' + total; c.end('ok'); });
        }
      });
    });
    await listen(srv, P_TARGET);
    const relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1']);
    try {
      // download with a reader that stops for a while
      serverWritten = 0;
      const t0 = Date.now();
      const down = await new Promise((resolve, reject) => {
        const c = net.connect({ port: P_RELAY, host: '127.0.0.1' });
        const hash = crypto.createHash('sha256');
        let total = 0;
        let stalledAt = -1;
        c.on('connect', () => c.write('DOWN\n'));
        c.on('data', (d) => {
          hash.update(d); total += d.length;
          if (stalledAt < 0 && total > 2 * 1024 * 1024) {
            stalledAt = total;
            c.pause();
            setTimeout(() => {
              const wroteWhilePaused = serverWritten;
              c.resume();
              resolve0.stalledWrite = wroteWhilePaused;
            }, 1500);
          }
        });
        const resolve0 = {};
        c.on('error', reject);
        c.on('close', () => resolve({ hash: hash.digest('hex'), total, stalledWrite: resolve0.stalledWrite }));
        setTimeout(() => { c.destroy(); reject(new Error('download timeout')); }, 60000);
      });
      assert.equal(down.total, SIZE);
      assert.equal(down.hash, shared.downHash, 'downloaded bytes differ');
      assert.ok(down.stalledWrite < 48 * 1024 * 1024, 'the server was able to write ' + Math.round(down.stalledWrite / 1048576) + ' MB while the client was paused: the relay is buffering');
      // upload 48 MB
      const up = crypto.randomBytes(48 * 1024 * 1024);
      const reply = await new Promise((resolve, reject) => {
        const c = net.connect({ port: P_RELAY, host: '127.0.0.1', allowHalfOpen: true });
        let buf = '';
        c.on('data', (d) => { buf += d; });
        c.on('error', reject);
        c.on('close', () => resolve(buf));
        c.on('connect', () => { c.write('UP\n'); c.end(up); });
        setTimeout(() => { c.destroy(); reject(new Error('upload timeout')); }, 60000);
      });
      assert.equal(reply, 'ok');
      assert.equal(uploadHash, sha(up) + ':' + up.length);
      assert.ok(Date.now() - t0 < 60000);
    } finally { await relay.stop(); await closeServer(srv); }
  });

  it('serves 200 connections at once', async () => {
    const srv = net.createServer((c) => { c.on('data', (d) => c.write(d)); c.on('error', () => {}); });
    await listen(srv, P_TARGET);
    const relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1']);
    try {
      const jobs = [];
      for (let i = 0; i < 200; i++) {
        jobs.push(new Promise((resolve, reject) => {
          const token = 'token-' + i + '-' + crypto.randomBytes(8).toString('hex');
          const c = net.connect({ port: P_RELAY, host: '127.0.0.1' });
          c.on('connect', () => c.write(token));
          c.on('data', (d) => { assert.equal(d.toString(), token); c.end(); });
          c.on('error', reject);
          c.on('close', () => resolve());
          setTimeout(() => { c.destroy(); reject(new Error('timeout ' + i)); }, 15000);
        }));
      }
      await Promise.all(jobs);
      assert.ok(relay.proc.exitCode === null, 'relay is still up');
      await sleep(5600);
      const st = relay.status();
      assert.equal(st.stats.accepted, 200);
      assert.equal(st.stats.active, 0);
    } finally { await relay.stop(); await closeServer(srv); }
  });

  it('closes an idle connection after --idle-seconds', async () => {
    const srv = net.createServer((c) => { c.on('data', () => {}); c.on('error', () => {}); });
    await listen(srv, P_TARGET);
    const relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1', '--idle-seconds', '1']);
    try {
      const t0 = Date.now();
      const closedAfter = await new Promise((resolve, reject) => {
        const c = net.connect({ port: P_RELAY, host: '127.0.0.1' });
        c.on('connect', () => c.write('x'));
        c.on('close', () => resolve(Date.now() - t0));
        c.on('error', () => {});
        setTimeout(() => { c.destroy(); reject(new Error('never closed')); }, 10000);
      });
      assert.ok(closedAfter >= 900 && closedAfter < 5000, 'closed after ' + closedAfter + ' ms');
    } finally { await relay.stop(); await closeServer(srv); }
  });

  it('listens on 127.0.0.1 only (not on this PC\'s network addresses)', async () => {
    const relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1']);
    try {
      const addrs = [];
      for (const list of Object.values(os.networkInterfaces())) for (const a of list || []) if (a.family === 'IPv4' && !a.internal) addrs.push(a.address);
      assert.ok(addrs.length > 0, 'this PC has no non-loopback IPv4 address to test with');
      for (const a of addrs) {
        const r = await probePort(a, P_RELAY, 800);
        assert.notEqual(r, 'open', 'the relay answered on ' + a);
      }
      assert.equal(await probePort('127.0.0.1', P_RELAY, 800), 'open');
    } finally { await relay.stop(); }
  });
});

describe('the VM is away or moves', () => {
  it('answers with a plain 502 page, logs one folded line, stays up, and recovers when the VM returns', async () => {
    const relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1']);   // nothing listens on P_TARGET yet
    let srv;
    try {
      const results = await Promise.all([1, 2, 3, 4, 5, 6].map(() => rawHttp({ port: P_RELAY, hostHeader: 'localhost:' + P_RELAY })));
      for (const r of results) {
        assert.equal(r.status, 502);
        assert.match(r.body.toString(), /not answering/);
        assert.match(r.body.toString(), /nothing answers on port/);   // ECONNREFUSED text
      }
      const log = relay.log();
      const errLines = log.split('\n').filter((l) => /connection error: 127\.0\.0\.1:/.test(l));
      assert.ok(errLines.length >= 1 && errLines.length <= 2, 'expected 1 folded error line, got ' + errLines.length + '\n' + log);
      assert.match(errLines[0], /ECONNREFUSED/);
      assert.ok(relay.proc.exitCode === null);
      // the VM comes back
      srv = http.createServer((req, res) => res.end('back'));
      await listen(srv, P_TARGET);
      await sleep(2300);   // the short "recently failed" memory is 2 seconds
      const ok = await rawHttp({ port: P_RELAY, hostHeader: 'localhost:' + P_RELAY });
      assert.equal(ok.status, 200);
      assert.equal(ok.body.toString(), 'back');
    } finally { await relay.stop(); if (srv) await closeServer(srv); }
  });

  it('with no address at all it says so, and starts working once vm-address.txt appears (no restart)', async () => {
    const srv = http.createServer((req, res) => res.end('found you'));
    await listen(srv, P_TARGET);
    const relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET]);   // no --vm-host, no file, no name
    try {
      const miss = await rawHttp({ port: P_RELAY, hostHeader: 'localhost:' + P_RELAY });
      assert.equal(miss.status, 502);
      assert.match(miss.body.toString(), /cannot find the vm/);
      fs.writeFileSync(relay.vmFile, '# written by a test\r\nip=127.0.0.1\r\n');
      await sleep(3200);   // the "found nothing" memory is 3 seconds
      const hit = await rawHttp({ port: P_RELAY, hostHeader: 'localhost:' + P_RELAY });
      assert.equal(hit.status, 200);
      assert.equal(hit.body.toString(), 'found you');
      assert.match(relay.log(), /the VM is at 127\.0\.0\.1 \(file vm-address\.txt\)/);
    } finally { await relay.stop(); await closeServer(srv); }
  });

  it('looks the VM up again after a failure and moves to the new address (stale file entry -> name)', async () => {
    const srv = http.createServer((req, res) => res.end('new home'));
    await listen(srv, P_TARGET);
    // 127.0.0.2 is a loopback address nothing listens on (refused at once); the name "localhost" resolves to the working 127.0.0.1
    const relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET], { vmFileContent: 'ip=127.0.0.2\ncomputer=localhost\n' });
    try {
      const r = await rawHttp({ port: P_RELAY, hostHeader: 'localhost:' + P_RELAY });
      assert.equal(r.status, 200, relay.log());
      assert.equal(r.body.toString(), 'new home');
      const log = relay.log();
      assert.match(log, /the VM is at 127\.0\.0\.2/);
      assert.match(log, /the VM is at 127\.0\.0\.1 \(file vm-address\.txt, was 127\.0\.0\.2\)/);
    } finally { await relay.stop(); await closeServer(srv); }
  });

  it('refuses addresses that are not private (file entry and command line)', async () => {
    const relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET], { vmFileContent: 'ip=8.8.8.8\n' });
    try {
      const r = await rawHttp({ port: P_RELAY, hostHeader: 'localhost:' + P_RELAY });
      assert.equal(r.status, 502);
      assert.match(r.body.toString(), /cannot find the vm/);
      assert.match(relay.log(), /8\.8\.8\.8 is not a private address, refused|not a private address/);
    } finally { await relay.stop(); }
    const bad = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '8.8.8.8'], { waitStart: false });
    assert.equal(await bad.exited, 2);
    assert.match(bad.out(), /not a private address/);
  });
});

describe('address order', () => {
  it('command line beats env beats file', async () => {
    const a = http.createServer((req, res) => res.end('A')); await listen(a, P_TARGET, '127.0.0.1');
    // the file and env point at a dead loopback address; only the command line (127.0.0.1) works
    const r1 = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1'], { env: { PILLAGERS_VM_HOST: '127.0.0.2' }, name: 'o1' });
    fs.writeFileSync(r1.vmFile, 'ip=127.0.0.3\n');
    try {
      const x = await rawHttp({ port: P_RELAY, hostHeader: 'x' });
      assert.equal(x.body.toString(), 'A');
      assert.match(r1.log(), /the VM is at 127\.0\.0\.1 \(command line --vm-host\)/);
    } finally { await r1.stop(); }
    // env works (and beats the file) without a command line address
    const r2 = await startRelay(['--ports', P_RELAY + ':' + P_TARGET], { env: { PILLAGERS_VM_HOST: '127.0.0.1' }, name: 'o2' });
    fs.writeFileSync(r2.vmFile, 'ip=127.0.0.3\n');
    try {
      const x = await rawHttp({ port: P_RELAY, hostHeader: 'x' });
      assert.equal(x.body.toString(), 'A');
      assert.match(r2.log(), /the VM is at 127\.0\.0\.1 \(env PILLAGERS_VM_HOST\)/);
    } finally { await r2.stop(); }
    // an env name is looked up
    const r3 = await startRelay(['--ports', P_RELAY + ':' + P_TARGET], { env: { PILLAGERS_VM_HOST: 'localhost' }, name: 'o3' });
    try {
      const x = await rawHttp({ port: P_RELAY, hostHeader: 'x' });
      assert.equal(x.body.toString(), 'A');
    } finally { await r3.stop(); await closeServer(a); }
  });
});

describe('refusing to start', () => {
  it('refuses when the listen port is already taken (plain net server)', async () => {
    const blocker = net.createServer(() => {});
    await listen(blocker, P_RELAY);
    try {
      const r = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1'], { waitStart: false });
      assert.equal(await r.exited, 3);
      assert.match(r.log(), /NOT STARTED: port \d+ on 127\.0\.0\.1 is already in use/);
      assert.equal(r.status(), null, 'a refused relay must not leave a status file');
    } finally { await closeServer(blocker); }
  });

  it('a second relay on the same port is refused and does not disturb the first', async () => {
    const srv = http.createServer((req, res) => res.end('one')); await listen(srv, P_TARGET);
    const first = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1'], { name: 'first' });
    try {
      const second = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1'], { name: 'second', waitStart: false });
      assert.equal(await second.exited, 3);
      const r = await rawHttp({ port: P_RELAY, hostHeader: 'x' });
      assert.equal(r.body.toString(), 'one');
      assert.equal(first.status().pid, first.proc.pid);
    } finally { await first.stop(); await closeServer(srv); }
  });

  it('all or nothing: if the second port is taken, the first is released again', async () => {
    const blocker = net.createServer(() => {});
    await listen(blocker, P_RELAY2);
    try {
      const r = await startRelay(['--ports', P_RELAY + ':' + P_TARGET + ',' + P_RELAY2 + ':' + P_TARGET2, '--vm-host', '127.0.0.1'], { waitStart: false });
      assert.equal(await r.exited, 3);
      await sleep(200);
      assert.equal(await probePort('127.0.0.1', P_RELAY, 500), 'refused', 'the first port should be free again');
    } finally { await closeServer(blocker); }
  });

  it('refuses when an HTTP.sys server (like tools\\serve.ps1) holds the port (Windows)', { skip: process.platform !== 'win32' }, async () => {
    const holder = path.join(TMP, 'hold.ps1');
    fs.writeFileSync(holder, 'param([int]$Port)\r\n$l = New-Object System.Net.HttpListener\r\n$l.Prefixes.Add("http://localhost:$Port/")\r\n$l.Start()\r\nStart-Sleep -Seconds 40\r\n');
    const ps = spawn('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', holder, '-Port', String(P_RELAY)], { stdio: 'ignore', windowsHide: true });
    children.add(ps);
    try {
      for (let i = 0; i < 40 && (await probePort('127.0.0.1', P_RELAY, 300)) !== 'open'; i++) await sleep(250);
      assert.equal(await probePort('127.0.0.1', P_RELAY, 300), 'open', 'the HttpListener did not start');
      const r = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1'], { waitStart: false });
      assert.equal(await r.exited, 3);
      assert.match(r.log(), /NOT STARTED/);
    } finally { ps.kill(); await sleep(300); }
  });

  it('rejects bad options with exit code 2', async () => {
    const r = await startRelay(['--bogus'], { waitStart: false });
    assert.equal(await r.exited, 2);
    assert.match(r.out(), /unknown option --bogus/);
  });
});

describe('logs and status', () => {
  it('never writes request or response contents to the log or the status file', async () => {
    const marker = 'SECRET-MARKER-' + crypto.randomBytes(6).toString('hex');
    const srv = net.createServer((c) => { c.on('data', () => c.write('reply-' + marker)); c.on('error', () => {}); });
    await listen(srv, P_TARGET);
    const relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1', '--verbose']);
    try {
      const body = await new Promise((resolve) => {
        const c = net.connect({ port: P_RELAY, host: '127.0.0.1' });
        let b = '';
        c.on('connect', () => c.write('GET /x?token=' + marker + ' HTTP/1.1\r\nHost: localhost\r\nCookie: ' + marker + '\r\n\r\n'));
        c.on('data', (d) => { b += d; c.destroy(); });
        c.on('close', () => resolve(b));
      });
      assert.ok(body.includes(marker));
      // an upstream failure and a reset too
      await closeServer(srv);
      await rawHttp({ port: P_RELAY, hostHeader: 'localhost', pathName: '/y?token=' + marker });
      await sleep(5600);
      assert.ok(!relay.log().includes(marker), 'the log contains request or response text');
      assert.ok(!JSON.stringify(relay.status()).includes(marker), 'the status file contains request or response text');
      const st = relay.status();
      assert.equal(st.pid, relay.proc.pid);
      assert.equal(st.state, 'running');
      assert.deepEqual(st.listen, [{ listen: P_RELAY, target: P_TARGET }]);
      assert.equal(st.target.ip, '127.0.0.1');
      assert.ok(st.stats.rssMB > 0);
    } finally { await relay.stop(); }
  });
});

describe('--probe', () => {
  it('reports open ports (exit 0), a closed port (exit 5) and no address (exit 4)', async () => {
    const srv = net.createServer(() => {}); await listen(srv, P_TARGET);
    const run = (args) => spawnSync(process.execPath, [RELAY, '--probe', '--vm-file', path.join(TMP, 'probe-none.txt'), '--vm-name', '', ...args], { env: cleanEnv(), encoding: 'utf8', windowsHide: true });
    try {
      let r = run(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', '127.0.0.1']);
      assert.equal(r.status, 0, r.stdout + r.stderr);
      assert.match(r.stdout, /^vm=127\.0\.0\.1$/m);
      assert.match(r.stdout, new RegExp('^port\\.' + P_TARGET + '=open$', 'm'));
      assert.match(r.stdout, /^ok=yes$/m);
      r = run(['--ports', P_RELAY + ':' + P_TARGET2, '--vm-host', '127.0.0.1']);
      assert.equal(r.status, 5);
      assert.match(r.stdout, new RegExp('^port\\.' + P_TARGET2 + '=refused$', 'm'));
      assert.match(r.stdout, /^ok=no$/m);
      r = run(['--ports', P_RELAY + ':' + P_TARGET]);
      assert.equal(r.status, 4);
      assert.match(r.stdout, /^ok=no$/m);
    } finally { await closeServer(srv); }
  });
});

// The path the real game takes: Chrome -> relay -> an HTTP.sys server (tools\serve.ps1 = HttpListener "http://localhost:P/") reached through the
// Hyper-V Default Switch address of this PC, with the Host header "localhost:P". Windows only, and only when the Default Switch address exists.
const SWITCH_ADDR = (() => {
  for (const [name, list] of Object.entries(os.networkInterfaces())) {
    if (!/default switch/i.test(name)) continue;
    for (const a of list || []) if (a.family === 'IPv4') return a.address;
  }
  return '';
})();
const SERVE = path.resolve(HERE, '..', 'serve.ps1');
describe('HTTP.sys through the Default Switch address', { skip: process.platform !== 'win32' || !SWITCH_ADDR || !fs.existsSync(SERVE) }, () => {
  it('serves a 24 MB file identically direct and through the relay; the Host header is passed on unchanged', async () => {
    const root = path.join(TMP, 'httpsys-root');
    fs.mkdirSync(root);
    const big = crypto.randomBytes(24 * 1024 * 1024);
    fs.writeFileSync(path.join(root, 'big.html'), big);
    fs.writeFileSync(path.join(root, 'small.html'), 'small page');
    const ps = spawn('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', SERVE, '-Root', root, '-Port', String(P_TARGET)], { stdio: 'ignore', windowsHide: true });
    children.add(ps);
    let relay;
    try {
      for (let i = 0; i < 60 && (await probePort('127.0.0.1', P_TARGET, 300)) !== 'open'; i++) await sleep(250);
      assert.equal(await probePort('127.0.0.1', P_TARGET, 300), 'open', 'serve.ps1 did not start');
      // the relay forwards to the switch address, as it will to the VM's address
      relay = await startRelay(['--ports', P_RELAY + ':' + P_TARGET, '--vm-host', SWITCH_ADDR]);
      const direct = await rawHttp({ port: P_TARGET, hostHeader: 'localhost:' + P_TARGET, pathName: '/big.html' });
      assert.equal(direct.status, 200);
      const viaRelay = await rawHttp({ port: P_RELAY, hostHeader: 'localhost:' + P_TARGET, pathName: '/big.html' });
      assert.equal(viaRelay.status, 200);
      assert.equal(viaRelay.body.length, big.length);
      assert.equal(sha(viaRelay.body), sha(big));
      assert.equal(sha(viaRelay.body), sha(direct.body));
      // HTTP.sys looks only at the host NAME in the Host header (it ignores the port there), so a browser at localhost:<relay port> is accepted
      // by a server on another port. A Host that names an address instead of localhost is refused: this proves the relay passes it on unchanged.
      const otherPort = await rawHttp({ port: P_RELAY, hostHeader: 'localhost:' + P_RELAY, pathName: '/small.html' });
      assert.equal(otherPort.status, 200);
      assert.equal(otherPort.body.toString(), 'small page');
      const rawIp = await rawHttp({ port: P_RELAY, hostHeader: SWITCH_ADDR + ':' + P_RELAY, pathName: '/small.html' });
      assert.equal(rawIp.status, 400);
    } finally { if (relay) await relay.stop(); ps.kill(); await sleep(300); }
  });
});
