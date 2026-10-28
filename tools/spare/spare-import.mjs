// spare-import.mjs : brings the SPARE PC's results into this VM (2026-10-20, his answer "16gb ram, it can stay on and connected").
// The spare PC (tools/spare/spare-runner.ps1) runs the full test run and the crash robots on each new build and pushes what it found
// to the spare-results branch on GitHub, under spare/HOSTNAME/. This takes them in, read only towards GitHub:
//   - each FINISHED full test run (corpus/corpus-MMDD-HHMM.txt with "ALL DONE", and its .head naming the tested commit) goes into the
//     scratch folder the stable picker reads (tools/stable.mjs), beside the VM's own runs; it never overwrites a file there;
//   - the robot log and problem records are mirrored to tools/handoff/spare/HOSTNAME/ (fuzz.log, fuzz-DATE.jsonl); stable.mjs reads
//     those fuzz.log files with the VM's own;
//   - tools/handoff/spare/live.txt says when a spare PC was last seen. While that is under 30 minutes old the runner (tools/nightly.sh)
//     starts no full test run and no robots in the VM, so the VM's memory goes to the helpers (10-26, his "3 quiet hours is too long --
//     make it like 30 mins": it was 3 hours; the spare PC sends a note every 10 minutes now). A spare PC that paused its tests because
//     someone is using it does not count as live, so the VM takes the tests back at once;
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
let seen = 0, seenHost = '', seenSt = {}, paused = false;
// 10-22: the main PC's idle runs (status mode=idle) send results too. They count like the spare PC's, but never as a full-time spare in
// live.txt, since the main PC tests only while he is away; the VM still starts its own runs when the spare PC is quiet.
const idleHosts = [];
const got = [], bad = [];
fs.mkdirSync(S, { recursive: true });
for (const [h, list] of Object.entries(hosts)) {
  if (list.includes('status.txt')) {
    try {
      const st = kv(blob(`spare/${h}/status.txt`).toString('utf8')); const ep = +st.epoch || 0;
      if (st.mode === 'idle') idleHosts.push([h, st, ep]); else if (ep > seen) { seen = ep; seenHost = h; seenSt = st; paused = /^paused/.test(st.test_run || ''); }
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

// The newest 40 windows a robot played at 4K in robot log f (machine h): the middle of their p50, p95 and p99 work times (ms per drawn raid frame).
function perf4k(f, h) {
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

// 10-28: per build, the main PC robot's 4K two-window raids on a real graphics card (its FUZZ START has size=3840x2160 and a gpu= naming
// Radeon, GeForce, NVIDIA or RTX; the VM's 4K robot draws on the processor and is left out). Builds with 6+ such raids, newest first, go
// to tools/handoff/spare/perf-4k.txt for jobs 120k, 124 and 125 and the coordinator. pair = p1 p50 + p2 p50 (the party's two windows
// share one thread; 8.3 ms is the 120 Hz budget); slow = frames over 25 ms; scale = the lowest draw scale seen.
function perf4kBuilds(f, h) {
  if (!fs.existsSync(f)) return [];
  let big = false, gpu = ''; const by = {};
  for (const ln of fs.readFileSync(f, 'utf8').split('\n')) {
    if (ln.includes(' FUZZ START ')) { gpu = ((/ gpu=(\S+)/.exec(ln) || [])[1] || '').replace(/_2d=.*$/, ''); big = ln.includes(' size=3840x2160') && /Radeon|GeForce|NVIDIA|RTX/i.test(gpu); continue; }
    if (!big || !/ raid \d+ demo2p /.test(ln)) continue;
    const w1 = / work=(\d+)\/([\d.]+)\/([\d.]+)\/([\d.]+)/.exec(ln), w2 = / work2=(\d+)\/([\d.]+)\/([\d.]+)\/([\d.]+)/.exec(ln), b = / build=([\d.]+)\s*$/.exec(ln);
    if (!w1 || !w2 || !b || +w1[1] < 300 || +w2[1] < 300) continue;
    const g1 = / gfx=(\d+)\/[\d.]+\/[\d.]+\/(\d+)\/([\d.]+)/.exec(ln), g2 = / gfx2=(\d+)\/[\d.]+\/[\d.]+\/(\d+)\/([\d.]+)/.exec(ln);
    const e = (by[b[1]] ||= { r: [], gpu, t: '' });
    e.r.push({ a: [+w1[2], +w1[3], +w1[4]], b: [+w2[2], +w2[3], +w2[4]], fr: (g1 ? +g1[1] : 0) + (g2 ? +g2[1] : 0), sl: (g1 ? +g1[2] : 0) + (g2 ? +g2[2] : 0), q: Math.min(g1 ? +g1[3] : 1, g2 ? +g2[3] : 1) });
    e.t = ln.slice(5, 16);
  }
  const med = (a) => { const s = [...a].sort((x, y) => x - y); return s[Math.floor(s.length / 2)]; };
  return Object.entries(by).filter(([, v]) => v.r.length >= 6).map(([ver, v]) => {
    const r = v.r, p = (k, i) => med(r.map((x) => x[k][i])), fr = r.reduce((s, x) => s + x.fr, 0), sl = r.reduce((s, x) => s + x.sl, 0);
    return { t: v.t, line: `v${ver} 4K two windows on ${v.gpu} (${h}): ${r.length} raids; work p50/p95/p99 ms p1 ${p('a', 0)}/${p('a', 1)}/${p('a', 2)}, p2 ${p('b', 0)}/${p('b', 1)}/${p('b', 2)}; pair p50 ${med(r.map((x) => x.a[0] + x.b[0]))} (8.3 = 120 Hz); slow ${fr ? (100 * sl / fr).toFixed(1) : '?'}%; scale ${Math.min(...r.map((x) => x.q))}; newest ${v.t}` };
  });
}
function writePerf4k(SP) {
  const out = []; for (const h of fs.readdirSync(SP)) out.push(...perf4kBuilds(path.join(SP, h, 'fuzz.log'), h));
  out.sort((x, y) => (x.t < y.t ? 1 : -1));
  if (out.length) { const f = path.join(SP, 'perf-4k.txt'); fs.writeFileSync(f + '.part', out.slice(0, 40).map((x) => x.line).join('\n') + '\n'); fs.renameSync(f + '.part', f); }
}

// 3 the live mark and the status line
// a paused spare PC writes epoch=0 (host and seen stay for the dashboard), so nightly.sh sets spl=0 on its next pass
if (seen) fs.writeFileSync(path.join(SP, 'live.txt'), `epoch=${paused ? 0 : seen}\nhost=${seenHost}\nseen=${seenSt.seen || ''}\n${paused ? 'paused=1\n' : ''}`);
const ago = seen ? Math.round((Date.now() / 1000 - seen) / 60) : -1;
let line = !seen ? `no spare PC has reported yet (checked ${stamp()})`
  : `${seenHost} last seen ${seenSt.seen || '?'} (${ago} min ago${ago >= 30 ? ', QUIET: the VM runs the tests and robots again' : paused ? ', PAUSED (someone is using it): the VM runs the tests and robots' : ''}), game ${seenSt.game || '?'}, ` +
    `test run ${seenSt.test_run || '?'}, robots ${seenSt.robots || '?'}, push ${seenSt.push_ok === '0' ? 'FAILING' : 'ok'}` +
    (seenSt.cpu_threads ? `, ram ${seenSt.ram_free_gb || '?'} of ${seenSt.ram_total_gb || '?'} GB free, cpu ${seenSt.cpu_pct || '?'}% of ${seenSt.cpu_threads} threads` : '');
// 10-28: a spare PC that keeps reporting in but has stopped working. 10-22 10:23 to 10-25 15:26 it sat on v34.13 with no full run for
// 77 hours while about 70 builds shipped, and nothing said so, since it never went quiet. STALLED goes first in the line (tools/health.sh
// makes it a PROBLEM) when its game copy is 3 hours behind the newest game change here, or no full run from any machine has finished
// in 5 hours (by its start minute) while the game changed after the last one. Never while it is quiet or paused.
const gameTimes = (from) => { try { return git(['log', '--format=%ct', `${from}..HEAD`, '--', 'dark_raiders.html']).split('\n').filter(Boolean).map(Number); } catch { return null; } };
const stall = [];
if (seen && ago < 30 && !paused) {
  const sha = (seenSt.game || '').split(' ')[0], now = Date.now() / 1000;
  const behind = /^[0-9a-f]{7,40}$/.test(sha) ? gameTimes(sha) : null;
  if (behind && behind.length && now - Math.min(...behind) >= 3 * 3600) stall.push(`its game copy ${seenSt.game} is ${((now - Math.min(...behind)) / 3600).toFixed(1)} h behind (${behind.length} newer game commits)`);
  let last = '', lastH = '';
  for (const [h, list] of Object.entries(hosts)) for (const n of list) { const m = /^corpus\/corpus-(\d{4}-\d{4})\.txt\.head$/.exec(n); if (m && m[1] > last) { last = m[1]; lastH = h; } }
  if (last) {
    const d = new Date(new Date().getFullYear(), +last.slice(0, 2) - 1, +last.slice(2, 4), +last.slice(5, 7), +last.slice(7, 9));
    if (d > new Date()) d.setFullYear(d.getFullYear() - 1);
    let head = ''; try { head = blob(`spare/${lastH}/corpus/corpus-${last}.txt.head`).toString('utf8').trim().split(/\s+/)[0]; } catch { }
    const since = /^[0-9a-f]{7,40}$/.test(head) ? gameTimes(head) : null, hrs = (now - d / 1000) / 3600;
    if (since && since.length && hrs >= 5) stall.push(`its newest finished full run started ${hrs.toFixed(1)} h ago (corpus-${last} on ${lastH}) and the game changed ${since.length} time(s) since`);
  }
}
if (stall.length) line = `STALLED: ${stall.join('; ')}; ` + line;
for (const [h, st, ep] of idleHosts) line += `; main PC ${h} last seen ${st.seen || '?'} (${ep ? Math.round((Date.now() / 1000 - ep) / 60) : '?'} min ago): ${st.test_run || '?'}, robots ${st.robots || '0'}${st.spare_pc ? `; spare PC as the main PC sees it: ${st.spare_pc}` : ''}`;
for (const h of fs.readdirSync(SP)) { const p = perf4k(path.join(SP, h, 'fuzz.log'), h); if (p) line += '; ' + p; }
try { writePerf4k(SP); } catch (e) { console.log(`${stamp().slice(6)} perf-4k.txt not written: ${String(e.message || e).slice(0, 120)}`); }   // 10-28: one line per build for the 4K jobs
{ const p = perf4k(path.join(R, 'tools', 'handoff', 'fuzz', 'fuzz.log'), 'the VM'); if (p) line += '; ' + p; }   // 10-22: the VM's own second robot plays at 4K
if (got.length) line += `; took ${got.length} finished run(s) now: ${got.join(', ').slice(0, 200)}`;
if (bad.length) line += `; could not take ${bad.length}: ${bad.join('; ').slice(0, 300)}`;
say(line + ` (checked ${stamp()})`);
if (got.length || bad.length) console.log(`${stamp().slice(6)} spare PC: ${got.length} finished test run(s) in${got.length ? ' (' + got.join(', ') + ')' : ''}${bad.length ? ', ' + bad.length + ' not taken: ' + bad.join('; ').slice(0, 200) : ''}`);
