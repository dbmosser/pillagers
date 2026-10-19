// jobs.mjs : the FIXED set of jobs the host bridge can run on the main PC. This file IS the allowlist. Nothing runs that is not a named job here.
//
// Each job gets (args, ctx) and returns a plain object (sent back as JSON). args is whatever the VM passed (already parsed, never a shell string).
// ctx has { log, shareDir, repoRoot }. Jobs that run a program use execFile with a fixed program and fixed/validated arguments, never a shell line
// built from the VM's text, so the VM can only ask for the exact things listed below. ASCII only.
import { execFile } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { BRIDGE_VERSION, hashFileSafe } from './bridge-common.mjs';

const PS = 'powershell';
const PS_BASE = ['-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-Command'];

// run a program with fixed args, capped output, a timeout. Resolves { code, out, err } and never rejects.
function run(program, argv, { timeoutMs = 60000, cwd } = {}) {
  return new Promise((resolve) => {
    execFile(program, argv, { timeout: timeoutMs, cwd, windowsHide: true, maxBuffer: 8 * 1024 * 1024 }, (e, out, err) => {
      resolve({ code: e && typeof e.code === 'number' ? e.code : (e ? 1 : 0), out: String(out || ''), err: String(err || ''), timedOut: !!(e && e.killed) });
    });
  });
}
const ps = (script, opts) => run(PS, [...PS_BASE, script], opts);

// ---- the move-kit scripts the VM may ask the main PC to run, by fixed name. The value is the file under tools/migrate. A key not in this map is
// refused. These take no VM-supplied arguments; they do what their own -Status / read-only default does unless a fixed flag is listed.
const KIT = {
  'ollama-status':   { file: 'host-ollama-bridge.ps1', args: ['-Status'] },
  'play-status':     { file: 'host-play-relay.ps1',    args: ['-Status'] },
  'host-verify':     { file: 'host-verify.ps1',        args: [] },
  'vm-address-hint': { file: 'host-play-relay.ps1',    args: ['-Status'] },
};

// a share-folder path from the VM: a plain file name, no folders, no dots-dots. Keeps the swap inside the one share folder.
function shareName(name) {
  const s = String(name || '').trim();
  if (!s || s.length > 120 || !/^[A-Za-z0-9._-]+$/.test(s) || s.startsWith('.') || s.includes('..')) return null;
  return s;
}

export const JOBS = {
  // health check: no key needed beyond the signature. Proves the agent is up and says what it is.
  ping(_args, ctx) {
    return { ok: true, version: BRIDGE_VERSION, host: process.env.COMPUTERNAME || '', now: new Date().toISOString(), repoRoot: ctx.repoRoot };
  },

  // memory / CPU / graphics-card report, as JSON. Read only.
  async stats(_args, _ctx) {
    const script = [
      '$os=Get-CimInstance Win32_OperatingSystem;',
      '$cpu=Get-CimInstance Win32_Processor | Select-Object -First 1;',
      '$gpu=Get-CimInstance Win32_VideoController | Where-Object { $_.AdapterRAM -gt 0 -or $_.Name -match "Radeon|NVIDIA|AMD" } | Select-Object -First 1;',
      '$load=(Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average;',
      '[pscustomobject]@{',
      '  freeMB=[int]($os.FreePhysicalMemory/1KB); totalMB=[int]($os.TotalVisibleMemorySize/1KB);',
      '  cpuName=$cpu.Name; cpuLoadPct=[int]$load; logicalCpus=$cpu.NumberOfLogicalProcessors;',
      '  gpuName=$gpu.Name; gpuDriver=$gpu.DriverVersion;',
      '} | ConvertTo-Json -Compress',
    ].join(' ');
    const r = await ps(script, { timeoutMs: 20000 });
    let data = null; try { data = JSON.parse(r.out.trim()); } catch { /* leave raw */ }
    return data ? { ok: true, stats: data } : { ok: false, error: 'could not read stats', raw: r.out.slice(0, 500) + r.err.slice(0, 500) };
  },

  // run one of the allowlisted move-kit scripts. args.key picks it; no other arguments reach the script.
  async kit(args, ctx) {
    const entry = KIT[String(args && args.key)];
    if (!entry) return { ok: false, error: 'unknown kit job; allowed: ' + Object.keys(KIT).join(', ') };
    const file = path.join(ctx.repoRoot, 'tools', 'migrate', entry.file);
    if (!fs.existsSync(file)) return { ok: false, error: 'script missing: ' + entry.file };
    const r = await ps('& ' + JSON.stringify(file) + ' ' + entry.args.join(' '), { timeoutMs: 180000, cwd: path.join(ctx.repoRoot, 'tools', 'migrate') });
    return { ok: r.code === 0, code: r.code, out: r.out.slice(-6000), err: r.err.slice(-2000), job: String(args.key) };
  },

  // list what is in the one shared folder.
  async ['share-list'](_args, ctx) {
    fs.mkdirSync(ctx.shareDir, { recursive: true });
    const names = fs.readdirSync(ctx.shareDir).filter((n) => { try { return fs.statSync(path.join(ctx.shareDir, n)).isFile(); } catch { return false; } });
    const files = [];
    for (const n of names) { try { const st = fs.statSync(path.join(ctx.shareDir, n)); files.push({ name: n, size: st.size, mtime: st.mtime.toISOString() }); } catch { /* skip */ } }
    return { ok: true, dir: ctx.shareDir, files };
  },

  // read a file out of the share folder (base64). Capped so a huge file cannot be pulled through the signed channel.
  async ['share-get'](args, ctx) {
    const n = shareName(args && args.name);
    if (!n) return { ok: false, error: 'bad name (plain file name only, no folders)' };
    const file = path.join(ctx.shareDir, n);
    if (!fs.existsSync(file)) return { ok: false, error: 'not found: ' + n };
    const st = fs.statSync(file);
    if (st.size > 12 * 1024 * 1024) return { ok: false, error: 'too big for the channel (' + st.size + ' bytes); it is in the share folder already' };
    const hash = await hashFileSafe(file);
    return { ok: true, name: n, size: st.size, sha256: hash, base64: fs.readFileSync(file).toString('base64') };
  },

  // write a file into the share folder (base64 in args.base64). The main PC's own tools / his Explorer pick it up from there.
  async ['share-put'](args, ctx) {
    const n = shareName(args && args.name);
    if (!n) return { ok: false, error: 'bad name (plain file name only, no folders)' };
    let buf;
    try { buf = Buffer.from(String(args.base64 || ''), 'base64'); } catch { return { ok: false, error: 'base64 did not decode' }; }
    if (buf.length > 12 * 1024 * 1024) return { ok: false, error: 'too big (' + buf.length + ' bytes)' };
    fs.mkdirSync(ctx.shareDir, { recursive: true });
    fs.writeFileSync(path.join(ctx.shareDir, n), buf);
    return { ok: true, name: n, size: buf.length };
  },
};

export const JOB_NAMES = Object.keys(JOBS);
export { KIT };
