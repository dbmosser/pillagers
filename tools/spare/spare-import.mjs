// spare-import.mjs : brings the SPARE PC's results into this VM (2026-10-20, his answer "16gb ram, it can stay on and connected").
// The spare PC (tools/spare/spare-runner.ps1) runs the full test run and the crash robots on each new build and pushes what it found
// to the spare-results branch on GitHub, under spare/HOSTNAME/. This takes them in, read only towards GitHub:
//   - each FINISHED full test run (corpus/corpus-MMDD-HHMM.txt with "ALL DONE", and its .head naming the tested commit) goes into the
//     scratch folder the stable picker reads (tools/stable.mjs), beside the VM's own runs; it never overwrites a file there;
//   - the robot log and problem records are mirrored to tools/handoff/spare/HOSTNAME/ (fuzz.log, fuzz-DATE.jsonl); stable.mjs reads
//     those fuzz.log files with the VM's own;
//   - tools/handoff/spare/live.txt says when a spare PC was last seen. While that is under 3 hours old the runner (tools/nightly.sh)
//     starts no full test run and no robots in the VM, so the VM's memory goes to the helpers;
//   - tools/handoff/spare-status.txt: one plain line for the health check and the coordinator, with the 4K frame numbers when a robot
//     played at 4K (the main PC's second robot, fuzz.ps1 -Size 3840x2160: work= is ms of the game's own work per drawn frame, 16.7 = 60 fps).
// The runner calls it every 5 minutes. It prints a line only when a run arrived or something failed. ASCII only.
// Usage: node tools/spare/spare-import.mjs [--remote NAME_OR_URL] [--scratch DIR] [--out DIR]   (the options are for tests)
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const R = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const arg = (k, d) => { const i = process.argv.indexOf('--' + k); return i > 0 ? process.argv[i + 1] : d; };
const REMOTE = arg('remote', 'origin');
const S = arg('scratch', process.env.PILLAGERS_SCRATCH || 'C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad');
const SP = arg('out', path.join(R, 'tools', 'handoff', 'spare'));
const STATUS = arg('out', '') ? path.join(SP, 'spare-status.txt') : path.join(R, 'tools', 'handoff', 'spare-status.txt');
const BR = 'spare-results', REF = 'refs/spare-import/' + BR;
const pad = (n) => String(n).padStart(2, '0');
const stamp = (d = new Date()) => `${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
const git = (a) => execFileSync('git', a, { cwd: R, encoding: 'utf8', windowsHide: true, maxBuffer: 64 << 20, timeout: 180000, stdio: ['ignore', 'pipe', 'pipe'] }).trim();
const blob = (p) => execFileSync('git', ['cat-file', 'blob', REF + ':' + p], { cwd: R, windowsHide: true, maxBuffer: 64 << 20, timeout: 60000 });
const say = (s) => fs.writeFileSync(STATUS, s + '\n');
fs.mkdirSync(SP, { recursive: true });

// 1 fetch only the results branch, into a private ref (it never touches the VM's branches or origin/master)
try { git(['fetch', '-q', '--no-tags', REMOTE, `+refs/heads/${BR}:${REF}`]); } catch (e) {
  const m = String(e.stderr || e.message || e);
  if (/couldn't find remote ref|not our ref|no such ref/i.test(m)) { say(`not set up yet (no ${BR} branch on GitHub; checked ${stamp()})`); process.exit(0); }
  say(`last try ${stamp()}: GitHub did not answer (${m.split('\n')[0].slice(0, 120)})`); process.exit(0);
}

// 2 what each spare PC pushed
const hosts = {};
for (const f of git(['ls-tree', '-r', '--name-only', REF, '--', 'spare/']).split('\n').filter(Boolean)) {
  const m = /^spare\/([A-Za-z0-9_.-]{1,40})\/(.+)$/.exec(f); if (m) (hosts[m[1]] ||= []).push(m[2]);
}
// 10-21 (coordinator): also reads the pairs when they come on one line. The first spare runner wrote its whole status as one line
// ("host=... seen=2026-10-21 23:17 epoch=..."; PowerShell's comma binds before +), so epoch was never read, live.txt never written,
// and the VM ran its own full test run beside the spare's. A value runs up to the next " word=".
const kv = (t) => Object.fromEntries([...t.replace(/\r?\n/g, ' ').matchAll(/(?:^|\s)(\w+)=(.*?)(?=\s+\w+=|\s*$)/g)].map((m) => [m[1], m[2].trim()]));
let seen = 0, seenHost = '', seenSt = {};
// 10-22: the main PC's idle runs (status mode=idle) send results too. They count like the spare PC's, but never as a full-time spare in
// live.txt, since the main PC tests only while he is away; the VM still starts its own runs when the spare PC is quiet.
const idleHosts = [];
const got = [], bad = [];
fs.mkdirSync(S, { recursive: true });
for (const [h, list] of Object.entries(hosts)) {
  if (list.includes('status.txt')) {
    try {
      const st = kv(blob(`spare/${h}/status.txt`).toString('utf8')); const ep = +st.epoch || 0;
      if (st.mode === 'idle') idleHosts.push([h, st, ep]); else if (ep > seen) { seen = ep; seenHost = h; seenSt = st; }
    } catch { }
  }
  // finished full test runs
  for (const n of list.filter((x) => /^corpus\/corpus-\d{4}-\d{4}\.txt$/.test(x)).sort()) {
    const base = n.slice('corpus/'.length), dst = path.join(S, base);
    if (fs.existsSync(dst)) continue;   // already taken, or a VM run with the same start minute: never overwrite
    try {
      const txt = blob(`spare/${h}/${n}`);
      if (!/ALL DONE/.test(txt.toString('latin1'))) continue;
      const head = list.includes(n + '.head') ? blob(`spare/${h}/${n}.head`).toString('utf8').trim().split(/\s+/)[0] : '';
      if (!/^[0-9a-f]{7,40}$/.test(head)) { bad.push(base + ': no commit named'); continue; }
      try { git(['cat-file', '-e', head + '^{commit}']); } catch { bad.push(base + ': commit ' + head.slice(0, 8) + ' is not in the VM yet'); continue; }
      fs.writeFileSync(dst + '.head', head + '\n');   // the side file first, so the stable picker never guesses the commit
      fs.writeFileSync(dst + '.part', txt); fs.renameSync(dst + '.part', dst);
      got.push(base);
    } catch (e) { bad.push(base + ': ' + String(e.message || e).split('\n')[0].slice(0, 100)); }
  }
  // the robot log and problem records, mirrored
  const hd = path.join(SP, h); fs.mkdirSync(hd, { recursive: true });
  for (const n of list.filter((x) => /^fuzz\/(fuzz\.log|fuzz-\d{4}-\d\d-\d\d\.jsonl)$/.test(x))) {
    try {
      const b = blob(`spare/${h}/${n}`), dst = path.join(hd, n.slice('fuzz/'.length));
      if (fs.existsSync(dst) && fs.readFileSync(dst).equals(b)) continue;
      fs.writeFileSync(dst + '.part', b); fs.renameSync(dst + '.part', dst);
    } catch (e) { bad.push(h + ' ' + n + ': ' + String(e.message || e).split('\n')[0].slice(0, 100)); }
  }
}

// The newest 40 windows a robot played at 4K on host h: the middle of their p50, p95 and p99 work times (ms per drawn raid frame).
function perf4k(h) {
  const f = path.join(SP, h, 'fuzz.log');
  if (!fs.existsSync(f)) return '';
  let big = false, last = ''; const w = [];
  for (const ln of fs.readFileSync(f, 'utf8').split('\n')) {
    if (ln.includes(' FUZZ START ')) { big = ln.includes(' size=3840x2160'); continue; }
    if (!big || !/ raid \d+ /.test(ln)) continue;
    for (const m of ln.matchAll(/ work2?=(\d+)\/([\d.]+)\/([\d.]+)\/([\d.]+)/g)) if (+m[1] >= 300) { w.push([+m[2], +m[3], +m[4]]); last = ln.slice(5, 16); }
  }
  if (!w.length) return '';
  const k = w.slice(-40), mid = (i) => { const a = k.map((x) => x[i]).sort((x, y) => x - y); return a[Math.floor(a.length / 2)]; };
  return `4K frames on ${h}: work ${mid(0)} ms typical, ${mid(1)} ms slowest 1 in 20, ${mid(2)} ms slowest 1 in 100 (${k.length} windows, newest ${last})`;
}

// 3 the live mark and the status line
if (seen) fs.writeFileSync(path.join(SP, 'live.txt'), `epoch=${seen}\nhost=${seenHost}\nseen=${seenSt.seen || ''}\n`);
const ago = seen ? Math.round((Date.now() / 1000 - seen) / 60) : -1;
let line = !seen ? `no spare PC has reported yet (checked ${stamp()})`
  : `${seenHost} last seen ${seenSt.seen || '?'} (${ago} min ago${ago >= 180 ? ', QUIET: the VM runs the tests and robots again' : ''}), game ${seenSt.game || '?'}, ` +
    `test run ${seenSt.test_run || '?'}, robots ${seenSt.robots || '?'}, push ${seenSt.push_ok === '0' ? 'FAILING' : 'ok'}`;
for (const [h, st, ep] of idleHosts) line += `; main PC ${h} last seen ${st.seen || '?'} (${ep ? Math.round((Date.now() / 1000 - ep) / 60) : '?'} min ago): ${st.test_run || '?'}, robots ${st.robots || '0'}${st.spare_pc ? `; spare PC as the main PC sees it: ${st.spare_pc}` : ''}`;
for (const h of fs.readdirSync(SP)) { const p = perf4k(h); if (p) line += '; ' + p; }
if (got.length) line += `; took ${got.length} finished run(s) now: ${got.join(', ').slice(0, 200)}`;
if (bad.length) line += `; could not take ${bad.length}: ${bad.join('; ').slice(0, 300)}`;
say(line + ` (checked ${stamp()})`);
if (got.length || bad.length) console.log(`${stamp().slice(6)} spare PC: ${got.length} finished test run(s) in${got.length ? ' (' + got.join(', ') + ')' : ''}${bad.length ? ', ' + bad.length + ' not taken: ' + bad.join('; ').slice(0, 200) : ''}`);
