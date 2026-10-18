// stable.mjs : decides whether a newer STABLE build exists and, if so, publishes it (called by tools/stable.sh, hourly by the runner).
// His order 2026-10-18: "Tag builds as stable vs. intermediate/bridge; my play window always loads the latest stable build."
//
// A version is STABLE when all three hold:
//   (a) GATE   : it is a shipped version (a git commit named "vNN.NN: ...", which only exists after the ship gate passed).
//   (b) CORPUS : the full overnight test set (corpus, ~2000 checks, ~3.5 h) ran to the end on exactly that version and made
//                no check newly fail (rules below).
//   (c) ROBOTS : the crash-hunting robots (fuzz.ps1) played at least 30 minutes on exactly that version with zero problems.
//
// "NEW failure" (the corpus always has some red checks that are only red because the hidden test browser is busy: 9 to 79 per run):
//   a check that failed in this run and in none of the 4 completed runs before it, or a check an earlier run flagged as new that
//   is still failing (a "suspect" stays blocking until one full run passes it). Checks listed in tools/handoff/stable-known-red.txt
//   (one prefix per line, e.g. "v29.10") are ignored. The oldest run in the list is only a reference (it cannot be judged).
//
// What it writes:
//   stable.html                       (project root; an exact copy of dark_raiders.html at that version; gitignored; served by :8802)
//   tools/handoff/stable.txt          (version=..., at=..., etc.; read by the dashboard and the report)
//   tools/handoff/stable-status.txt   (why the newest candidate is or is not stable yet; overwritten every run)
//   tools/handoff/stable-history.log  (one line per promotion)
//   git tag stable-vNN.NN             (on the "vNN.NN:" commit)
// Reads only: git objects, the corpus files, nightly.log, fuzz.log. It never touches the working copy of dark_raiders.html.
// Usage: node tools/stable.mjs [--quiet] [--dry]     (--dry: judge but publish nothing)
import { readFileSync, writeFileSync, existsSync, readdirSync, statSync, renameSync, appendFileSync, mkdirSync, unlinkSync } from 'fs';
import { execFileSync } from 'child_process';

const R = 'C:/claudecode/dark raiders', H = R + '/tools/handoff';
const S = process.env.PILLAGERS_SCRATCH || 'C:/Users/User1/AppData/Local/Temp/claude/C--Users-User1-Desktop-dark-raiders/8a09e991-b4f4-4b23-b10f-ded92e837fc3/scratchpad';
const NLOG = H + '/nightly/nightly.log', FUZZ = H + '/fuzz/fuzz.log';
const STABLE_HTML = R + '/stable.html', STABLE_TXT = H + '/stable.txt', STATUS = H + '/stable-status.txt', HIST = H + '/stable-history.log';
const FREEZE = H + '/stable.freeze', KNOWN = H + '/stable-known-red.txt';
const ADDRESS = 'http://localhost:8802/stable.html';
const WINDOW = 4, MIN_ROBOT_MIN = 30, MAX_RUNS = 12;
const args = process.argv.slice(2), QUIET = args.includes('--quiet'), DRY = args.includes('--dry');

const rd = (p, d = '') => { try { return readFileSync(p, 'utf8'); } catch { return d; } };
const git = a => execFileSync('git', a, { cwd: R, encoding: 'utf8', windowsHide: true, maxBuffer: 64 << 20 }).trim();
const gitTry = a => { try { return git(a); } catch { return ''; } };
const pad = n => String(n).padStart(2, '0');
const stamp = (d = new Date()) => `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
const cmpVer = (a, b) => { const [a1, a2] = a.split('.').map(Number), [b1, b2] = b.split('.').map(Number); return a1 - b1 || a2 - b2; };
const out = [];
const say = s => { out.push(s); if (!QUIET) console.log(s); };

// ---- the current stable version
function readKV(p) { const o = {}; rd(p).split(/\r?\n/).forEach(l => { const m = /^(\w+)=(.*)$/.exec(l.trim()); if (m) o[m[1]] = m[2]; }); return o; }
const cur = readKV(STABLE_TXT);
const curVer = cur.version || '0.0';

// ---- (b) the corpus runs, oldest first
function failsOf(txt) {
  // a failing check is the text after " || " that starts "vNN.NN "; its key is the words up to " -> " (max 80 chars)
  const segs = txt.replace(/\r/g, '').replace(/\n+/g, ' ').split(' || '), set = new Set();
  for (let i = 1; i < segs.length; i++) {
    const s = segs[i].trim(); if (!/^v\d+\.\d+ /.test(s)) continue;
    set.add(s.split(' -> ')[0].slice(0, 80).trim());
  }
  return set;
}
const nl = rd(NLOG), starts = [];
for (const l of nl.split(/\r?\n/)) { const m = /^(?:\d\d-\d\d )?(\d\d):(\d\d) corpus start at ([0-9a-f]{7,40})/.exec(l); if (m) starts.push({ hhmm: m[1] + m[2], hash: m[3] }); }
let files = [];
try { files = readdirSync(S).filter(f => /^corpus-\d{4}-\d{4}\.txt$/.test(f)).sort(); } catch {}
const hashOf = {};
{ let limit = starts.length;   // newest file first, matching each to the latest unused "corpus start" line with the same HHMM
  for (const f of files.slice().reverse()) {
    const side = rd(S + '/' + f + '.head').trim().split(/\s+/)[0];   // written by the runner once it has the 10-18 change
    if (/^[0-9a-f]{7,40}$/.test(side)) { hashOf[f] = side; continue; }
    const hhmm = f.slice(12, 16);
    for (let i = limit - 1; i >= 0; i--) if (starts[i].hhmm === hhmm) { hashOf[f] = starts[i].hash; limit = i; break; }
  } }
let runs = files.map(f => {
  const txt = rd(S + '/' + f);
  return { file: f, done: /ALL DONE/.test(txt), partial: /STALLED|result could not be read/.test(txt), fails: failsOf(txt), hash: hashOf[f] || '' };
}).filter(r => r.done && !r.partial).slice(-MAX_RUNS);
const ignorePre = rd(KNOWN).split(/\r?\n/).map(s => s.replace(/#.*$/, '').trim()).filter(Boolean);
const ignored = c => ignorePre.some(p => c.startsWith(p));
const suspects = new Set();
runs.forEach((r, i) => {
  r.verdict = 'ref'; r.newFails = [];
  if (i === 0) return;
  const known = new Set(); for (let k = Math.max(0, i - WINDOW); k < i; k++) runs[k].fails.forEach(c => known.add(c));
  r.newFails = [...r.fails].filter(c => !ignored(c) && (!known.has(c) || suspects.has(c)));
  r.verdict = r.newFails.length ? 'dirty' : 'clean';
  r.newFails.forEach(c => suspects.add(c));
  for (const c of [...suspects]) if (!r.fails.has(c)) suspects.delete(c);
});

// ---- the game version of each run, from the commit the runner tested
const verCache = {};
function blobInfo(hash) {
  if (!hash) return null; if (verCache[hash] !== undefined) return verCache[hash];
  let r = null;
  try {
    const buf = execFileSync('git', ['cat-file', 'blob', hash + ':dark_raiders.html'], { cwd: R, maxBuffer: 64 << 20, windowsHide: true });
    const m = /var VER='([0-9]+\.[0-9]+)';/.exec(buf.toString('latin1', 0, Math.min(buf.length, 400000)) ) || /var VER='([0-9]+\.[0-9]+)';/.exec(buf.toString('latin1'));
    if (m) r = { ver: m[1], blob: git(['rev-parse', hash + ':dark_raiders.html']), size: buf.length };
  } catch {}
  return (verCache[hash] = r);
}
runs.forEach(r => { const b = blobInfo(r.hash); r.ver = b ? b.ver : ''; r.blob = b ? b.blob : ''; });

// ---- (c) the robots, per build
function robots(ver) {
  let sec = 0, problems = 0, raids = 0;
  for (const l of rd(FUZZ).split(/\n/)) {
    if (!l.endsWith(' build=' + ver)) continue;
    const m = / raid \d+ \S+ raidSeed=\d+ .*? sec=(\d+) end=(\S+) problems=(\d+) /.exec(l); if (!m) continue;
    raids++; sec += +m[1]; problems += +m[3]; if (m[2] === 'cdp') problems++;
  }
  return { minutes: Math.round(sec / 60), problems, raids };
}

// ---- judge every run, newest first
say(`Stable check ${stamp()}. Current stable: ${cur.version ? 'v' + cur.version : 'none yet'}${existsSync(FREEZE) ? ' (FROZEN: party freeze file present)' : ''}`);
say(`Test runs read: ${runs.length} finished (${files.length} files). Rule: finished, no new failing checks, robots 30+ minutes with no problem, same version.`);
let pick = null;
const rows = [];
for (let i = runs.length - 1; i >= 0; i--) {
  const r = runs[i], bot = r.ver ? robots(r.ver) : { minutes: 0, problems: 0, raids: 0 };
  let why;
  if (!r.ver) why = 'could not tell which version it tested';
  else if (r.verdict === 'ref') why = 'oldest run kept only as a reference';
  else if (r.verdict === 'dirty') why = `${r.newFails.length} check(s) newly failing, e.g. ${r.newFails.slice(0, 2).map(c => c.slice(0, 60)).join(' | ')}`;
  else if (bot.problems > 0) why = `robots hit ${bot.problems} problem(s) on it`;
  else if (bot.minutes < MIN_ROBOT_MIN) why = `waiting for robots: ${bot.minutes} of ${MIN_ROBOT_MIN} minutes on this exact version`;
  else if (cmpVer(r.ver, curVer) <= 0) why = r.ver === curVer ? 'this is the current stable' : 'older than the current stable';
  else why = 'QUALIFIES';
  r.why = why; r.bot = bot;
  rows.push(`  ${r.file.replace('.txt', '')}  v${r.ver || '?'}  failing ${r.fails.size}, new ${r.newFails.length}  robots ${bot.minutes} min/${bot.problems} problems  -> ${why}`);
  if (!pick && why === 'QUALIFIES') pick = r;
}
rows.slice(0, 6).forEach(say);

// ---- publish
function materialize(ver, blobRef) {
  const buf = execFileSync('git', ['cat-file', 'blob', blobRef], { cwd: R, maxBuffer: 64 << 20, windowsHide: true });
  if (buf.length < 3000000 || !buf.toString('latin1').includes("var VER='" + ver + "';")) throw new Error('blob for v' + ver + ' looks wrong');
  const tmp = STABLE_HTML + '.tmp'; writeFileSync(tmp, buf);
  for (let i = 0; i < 5; i++) { try { renameSync(tmp, STABLE_HTML); return buf.length; } catch (e) { if (i === 4) throw e; execFileSync('node', ['-e', 'setTimeout(()=>{},1500)']); } }
}
let result = 'no change';
if (existsSync(FREEZE)) {
  result = 'frozen (party freeze file): no change';
} else if (pick && !DRY) {
  const v = pick.ver, blobRef = pick.hash + ':dark_raiders.html';
  const size = materialize(v, blobRef);
  // tag the "vNN.NN:" commit when it holds the same file; otherwise the commit the corpus tested
  let target = gitTry(['log', '-n', '1', '--format=%H', '--grep=^v' + v.replace('.', '\\.') + ': ']);
  if (!target || gitTry(['rev-parse', target + ':dark_raiders.html']) !== pick.blob) target = gitTry(['rev-parse', pick.hash]);
  const tag = 'stable-v' + v;
  if (!gitTry(['tag', '-l', tag])) gitTry(['tag', tag, target]);
  const now = new Date();
  writeFileSync(STABLE_TXT, [`version=${v}`, `at=${stamp(now)}`, `iso=${now.toISOString()}`, `commit=${target}`, `tag=${tag}`, `address=${ADDRESS}`,
    `corpus=${pick.file}`, `corpus_failing=${pick.fails.size}`, `corpus_new_failures=0`, `robot_minutes=${pick.bot.minutes}`, `robot_raids=${pick.bot.raids}`, `robot_problems=0`, `size=${size}`].join('\n') + '\n');
  appendFileSync(HIST, `${stamp(now)} promoted v${v} (was ${cur.version ? 'v' + cur.version : 'none'}): corpus ${pick.file}, ${pick.fails.size} known-red checks, 0 new; robots ${pick.bot.minutes} min on ${pick.bot.raids} raids, 0 problems; tag ${tag}\n`);
  result = `PROMOTED v${v} (was ${cur.version ? 'v' + cur.version : 'none'}); play address ${ADDRESS}`;
} else if (pick && DRY) {
  result = `would promote v${pick.ver} (dry run)`;
} else if (cur.version && !DRY) {
  // nothing new, but make sure the served file is still the stable version
  let ok = false; try { ok = existsSync(STABLE_HTML) && readFileSync(STABLE_HTML, 'latin1').includes("var VER='" + cur.version + "';"); } catch {}
  if (!ok) { const ref = cur.commit ? cur.commit + ':dark_raiders.html' : 'refs/tags/' + (cur.tag || 'stable-v' + cur.version) + ':dark_raiders.html'; try { materialize(cur.version, ref); result = `restored stable.html for v${cur.version}`; } catch (e) { result = 'could not restore stable.html: ' + e.message; } }
}
say('Result: ' + result);
const nowS = readKV(STABLE_TXT);
const blockers = suspects.size ? ['Checks that are newly red and still red (they block until fixed or listed in tools/handoff/stable-known-red.txt):', ...[...suspects].slice(0, 12).map(c => '  ' + c)] : [];
if (!DRY) try { writeFileSync(STATUS, [`Latest stable: ${nowS.version ? 'v' + nowS.version + ' (' + nowS.at + ')' : 'none yet'}`, `Checked: ${stamp()}`, `Play address: ${ADDRESS}`, `Result: ${result}`, '', 'Newest test runs, newest first:', ...rows.slice(0, 8), '', ...blockers].join('\n') + '\n'); } catch {}
if (QUIET) console.log(`stable: ${result}; current ${nowS.version ? 'v' + nowS.version : 'none'}; newest run ${runs.length ? runs[runs.length - 1].file.replace('.txt', '') + ' v' + (runs[runs.length - 1].ver || '?') + ': ' + runs[runs.length - 1].why : 'none'}`);
