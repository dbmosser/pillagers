// report.mjs : the plain morning / evening report, with pictures. Node only, no AI calls, no network.
// His order 2026-10-18: "a plain report of what changed, morning and evening, with pictures."
// Writes ONE self-contained, phone-friendly, dark HTML page: tools/handoff/reports/YYYY-MM-DD-am.html (or -pm.html).
// It lists every version shipped since the last report (git subjects "vNN.NN: ..." are already plain sentences), grouped as screens,
// gameplay, fixes and art; before/after pictures named in tools/handoff/console/notes/ui/changes.md (shrunk to small JPEGs and embedded);
// the helpers' jobs and spend (tools/handoff/console/runs.log); the robots; the stable build; and what waits on him
// (tools/handoff/console/questions.md). The runner (tools/nightly.sh) calls it at 07:00 and 18:00 with --auto.
// Usage: node tools/report.mjs [--kind am|pm] [--since "YYYY-MM-DD HH:MM"] [--out FILE] [--no-state] [--auto] [--max-mb 8]
//   --since    start of the window (default: the time of the last report, or 24 hours ago for the first one)
//   --no-state do not move the "last report" mark (for a trial run)
//   --auto     skip when the file for this slot already exists and is under 12 hours old
// Pictures are shrunk by tools/report-resize.ps1 (Windows System.Drawing) and cached in tools/handoff/reports/cache/.
import { readFileSync, writeFileSync, existsSync, readdirSync, statSync, mkdirSync, unlinkSync } from 'fs';
import { execFileSync, spawnSync } from 'child_process';
import { createHash } from 'crypto';

const R = 'C:/claudecode/dark raiders', H = R + '/tools/handoff', C = H + '/console', NOTES = C + '/notes', REP = H + '/reports', CACHE = REP + '/cache';
const argv = process.argv.slice(2);
const opt = (n, d = '') => { const i = argv.indexOf('--' + n); return i >= 0 && argv[i + 1] && !argv[i + 1].startsWith('--') ? argv[i + 1] : d; };
const flag = n => argv.includes('--' + n);
const now = new Date();
const kind = opt('kind') === 'pm' || opt('kind') === 'am' ? opt('kind') : (now.getHours() < 12 ? 'am' : 'pm');
const MAX_BYTES = Math.round((+opt('max-mb', '8') || 8) * 1048576);
const pad = n => String(n).padStart(2, '0');
const ymd = d => `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
const hm = d => `${pad(d.getHours())}:${pad(d.getMinutes())}`;
const DAYS = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'], MONS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const nice = d => `${DAYS[d.getDay()].slice(0, 3)} ${MONS[d.getMonth()]} ${d.getDate()}, ${hm(d)}`;
const rd = (p, d = '') => { try { return readFileSync(p, 'utf8'); } catch { return d; } };
const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const git = a => { try { return execFileSync('git', a, { cwd: R, encoding: 'utf8', windowsHide: true, maxBuffer: 64 << 20 }).trim(); } catch { return ''; } };
const kv = p => { const o = {}; rd(p).split(/\r?\n/).forEach(l => { const m = /^(\w+)=(.*)$/.exec(l.trim()); if (m) o[m[1]] = m[2]; }); return o; };

mkdirSync(REP, { recursive: true }); mkdirSync(CACHE, { recursive: true });
const outFile = opt('out') || `${REP}/${ymd(now)}-${kind}.html`;
if (flag('auto') && existsSync(outFile) && Date.now() - statSync(outFile).mtimeMs < 12 * 3600e3) { console.log(`report: ${outFile} is fresh, skipped`); process.exit(0); }

// ---------------------------------------------------------------- the window
const state = (() => { try { return JSON.parse(rd(REP + '/state.json')); } catch { return {}; } })();
let since = new Date(now.getTime() - 24 * 3600e3);
if (state.lastAt && !isNaN(Date.parse(state.lastAt))) since = new Date(state.lastAt);
if (opt('since')) { const s = opt('since').replace(' ', 'T'); const d = new Date(/[zZ]|[+-]\d\d:?\d\d$/.test(s) ? s : s + ':00'); if (!isNaN(d)) since = d; }

// ---------------------------------------------------------------- versions shipped
const allCommits = git(['log', '--since=' + since.toISOString(), '--format=%H%x1f%aI%x1f%s']).split('\n').filter(Boolean).map(l => l.split('\x1f'));
const versions = [];   // oldest first
for (const [h, iso, subj] of allCommits.slice().reverse()) {
  const m = /^v(\d+)\.(\d+): (.+)$/.exec(subj); if (m) versions.push({ hash: h, at: new Date(iso), ver: `${m[1]}.${m[2]}`, text: m[3].replace(/\s+$/, '') });
}
const fixtureCommits = allCommits.length - versions.length;
const vset = new Map(versions.map(v => [v.ver, v]));
function groupOf(t) {
  const s = t.toLowerCase();
  if (/\b(screens?|cards?|menus?|settings|pause|title|hud|panels?|buttons?|pages?|party|board|backdrop|keys?|footer|window|tabs?|labels?|hints?|callout|scrim|layout|stash|shop|ui|text|wordmark|toast|feed|chips?|rows?|header|pane|scoreboard|operator|attract|modal|dialog|credits|readout)\b/.test(s)) return 'screens';
  if (/\b(fix|fixes|fixed|bug|crash|crashes|stuck|freez\w*|broken|wrong|leaks?|clips?|clipped|overlaps?|never|no longer|does not|doesn't|cannot|missing|duplicate|double)\b/.test(s)) return 'fixes';
  if (/\b(draws?|drawn|art|sprites?|looks?|colou?rs?|shadows?|glow|lights?|lighting|helmets?|bandolier|body|silhouette|shapes?|portrait|icons?|models?|animations?|textures?|paint|chipped|wreckage|bloom|smoke|sparks?|particles?|blur|tint|remains)\b/.test(s)) return 'art';
  return 'gameplay';
}
const GROUPS = [['screens', 'Screens and menus'], ['gameplay', 'Gameplay'], ['fixes', 'Fixes'], ['art', 'Art and look']];
const byGroup = { screens: [], gameplay: [], fixes: [], art: [] };
versions.forEach(v => { v.group = groupOf(v.text); byGroup[v.group].push(v); });

// ---------------------------------------------------------------- helpers' jobs and spend (runs.log)
function humanTask(n) { return n.replace(/^(?:[a-f]-)?\d+[a-z]?-/, '').replace(/^cw-/, '').replace(/-r2$/, '').replace(/-/g, ' '); }
const jobs = { done: [], failed: [], partial: 0, stalls: 0, cost: 0, allCost: 0, firstDay: '' };
for (const l of rd(C + '/runs.log').split(/\r?\n/)) {
  const m = /^(\d\d)-(\d\d) (\d\d):(\d\d) (.*)$/.exec(l); if (!m) continue;
  let d = new Date(now.getFullYear(), +m[1] - 1, +m[2], +m[3], +m[4]); if (d.getTime() > now.getTime() + 864e5) d = new Date(now.getFullYear() - 1, +m[1] - 1, +m[2], +m[3], +m[4]);
  const r = /^(\S+): (done|failed|partial \(run \d+ of \d+\)), \$([0-9.]+)/.exec(m[5]);
  if (r) { jobs.allCost += +r[3]; if (!jobs.firstDay) jobs.firstDay = `${m[1]}/${m[2]}`; }   // the whole log, for the since-the-start total
  if (d < since) continue;
  if (!r) { if (/error|waiting|resting|cannot/i.test(m[5])) jobs.stalls++; continue; }
  jobs.cost += +r[3];
  if (r[2] === 'done') jobs.done.push(humanTask(r[1])); else if (r[2] === 'failed') jobs.failed.push(humanTask(r[1])); else jobs.partial++;
}
const uniq = a => [...new Set(a)];
const planUse = (() => { const p = rd(C + '/plan-usage.txt').trim().split(/\s+/); if (p.length >= 3 && Date.now() / 1000 - +p[2] < 24 * 3600) return { ses: p[0], wk: p[1], at: new Date(+p[2] * 1000) }; return null; })();

// ---------------------------------------------------------------- robots, tests, stable
let raids = 0, rProblems = 0;
for (const l of rd(H + '/fuzz/fuzz.log').split('\n')) {
  const m = /^(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d) raid \d+ .*? problems=(\d+) /.exec(l); if (!m) continue;
  if (new Date(+m[1], +m[2] - 1, +m[3], +m[4], +m[5], +m[6]) < since) continue;
  raids++; rProblems += +m[7];
}
const stable = kv(H + '/stable.txt');
const stStat = rd(H + '/stable-status.txt').split(/\r?\n/);
const newestRun = (() => { const i = stStat.findIndex(l => /^Newest test runs/.test(l)); const l = i >= 0 ? stStat[i + 1] : ''; const m = /(corpus-\S+)\s+v(\S+)\s+failing (\d+), new (\d+).*?-> (.*)$/.exec(l || ''); return m ? { ver: m[2], failing: m[3], fresh: m[4], why: m[5] } : null; })();

// ---------------------------------------------------------------- before / after pictures (changes.md)
function expandVersions(line) {
  const out = new Set(), re = /\bv(\d{1,2})\.(\d{2})(?:\s*(?:-|to)\s*v?(\d{1,2})(?:\.(\d{2}))?)?/g; let m;
  while ((m = re.exec(line))) {
    const M1 = +m[1], n1 = +m[2];
    if (m[3] === undefined) { out.add(`${M1}.${m[2]}`); continue; }
    const M2 = m[4] !== undefined ? +m[3] : M1, n2 = m[4] !== undefined ? +m[4] : +m[3];
    if (M2 === M1 && n2 >= n1 && n2 - n1 <= 40) for (let n = n1; n <= n2; n++) out.add(`${M1}.${pad(n)}`); else { out.add(`${M1}.${m[2]}`); out.add(`${M2}.${pad(n2)}`); }
  }
  return out;
}
const imgFiles = d => { try { return readdirSync(`${NOTES}/shots/${d}`).filter(f => /\.(jpe?g|png)$/i.test(f)); } catch { return []; } };
function picRefs(line) {
  const re = /(?:notes\/)?shots\/([A-Za-z0-9_.-]+)(?:\/([A-Za-z0-9_.-]+\.(?:jpe?g|png)))?/g, refs = []; let m;
  while ((m = re.exec(line))) {
    const before = line.slice(Math.max(0, m.index - 40), m.index).toLowerCase();
    const role = /after\W*$/.test(before) ? 'after' : /before\W*$/.test(before) ? 'before' : '';
    refs.push({ dir: m[1], file: m[2] || '', role });
  }
  return refs;
}
function pairsFor(line) {
  const refs = picRefs(line); if (!refs.length) return [];
  let b = refs.find(r => r.role === 'before'), a = refs.find(r => r.role === 'after');
  if (!b && !a && refs.length >= 2) { b = refs[0]; a = refs[1]; }
  else if (b && !a) a = refs.find(r => r !== b); else if (a && !b) b = refs.find(r => r !== a);
  if (!b || !a || (b.dir === a.dir && b.file === a.file)) return [];
  const nums = new Set((line.match(/\b\d{2}\b/g) || []));
  if (b.file && a.file) { const p = [b.file, a.file]; return existsSync(`${NOTES}/shots/${b.dir}/${p[0]}`) && existsSync(`${NOTES}/shots/${a.dir}/${p[1]}`) ? [{ bdir: b.dir, bfile: p[0], adir: a.dir, afile: p[1] }] : []; }
  const bf = b.file ? [b.file] : imgFiles(b.dir), af = new Set(a.file ? [a.file] : imgFiles(a.dir));
  let common = bf.filter(f => af.has(f));
  if (!common.length && b.file) common = [...af].filter(f => f.slice(0, 2) === b.file.slice(0, 2));
  common.sort((x, y) => (nums.has(y.slice(0, 2)) ? 1 : 0) - (nums.has(x.slice(0, 2)) ? 1 : 0) || x.localeCompare(y));
  return common.slice(0, 3).map(f => ({ bdir: b.dir, bfile: b.file || f, adir: a.dir, afile: a.file || f }));
}
const picEntries = [], seenPairs = new Set();
for (const line of rd(NOTES + '/ui/changes.md').split(/\r?\n/)) {
  if (!/^\s*-?\s*\d{4}-\d\d-\d\d/.test(line)) continue;
  const vs = [...expandVersions(line)].filter(v => vset.has(v)); if (!vs.length) continue;
  const pairs = pairsFor(line).filter(p => { const k = `${p.bdir}/${p.bfile}>${p.adir}/${p.afile}`; if (seenPairs.has(k)) return false; seenPairs.add(k); return true; });
  if (!pairs.length) continue;
  const task = (/\|\s*([^|]+?)\s*\|/.exec(line) || /^\s*-?\s*\d{4}-\d\d-\d\d[,|]\s*([^,|]+)[,|]/.exec(line) || [])[1] || '';
  vs.sort((x, y) => (y.split('.').map(Number)[0] - x.split('.').map(Number)[0]) || (+y.split('.')[1] - +x.split('.')[1]));
  picEntries.push({ vs, task: humanTask(task.trim()), pairs });
}
picEntries.sort((x, y) => { const a = x.vs[0].split('.').map(Number), b = y.vs[0].split('.').map(Number); return b[0] - a[0] || b[1] - a[1]; });

// ---- shrink and embed (a JPEG about 960 px wide; budget = 70 percent of the size cap)
const PIC_BUDGET = Math.round(MAX_BYTES * 0.7), W = 960, Q = 60;
const srcOf = (d, f) => `${NOTES}/shots/${d}/${f}`;
function cachePath(src) { const st = statSync(src); return `${CACHE}/${createHash('sha1').update(`${src}|${st.mtimeMs}|${st.size}|${W}|${Q}`).digest('hex').slice(0, 20)}.jpg`; }
const wanted = [];
let picCount = 0;
for (const e of picEntries) { e.pairs = e.pairs.slice(0, 3); if (picCount >= 18) { e.pairs = []; continue; } e.pairs = e.pairs.slice(0, 18 - picCount); picCount += e.pairs.length; }
for (const e of picEntries) for (const p of e.pairs) for (const [d, f] of [[p.bdir, p.bfile], [p.adir, p.afile]]) { const s = srcOf(d, f); const c = cachePath(s); if (!existsSync(c)) wanted.push({ src: s.replace(/\//g, '\\'), dst: c.replace(/\//g, '\\'), w: W, q: Q }); }
if (wanted.length) {
  const jf = `${CACHE}/jobs-${process.pid}.json`; writeFileSync(jf, JSON.stringify(wanted));
  const ps = (process.env.SystemRoot || 'C:\\Windows') + '\\System32\\WindowsPowerShell\\v1.0\\powershell.exe';
  const r = spawnSync(ps, ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', R + '/tools/report-resize.ps1', jf.replace(/\//g, '\\')], { encoding: 'utf8', windowsHide: true, timeout: 300000 });
  const bad = (r.stdout || '').split(/\r?\n/).filter(l => l.startsWith('fail')); if (bad.length) console.log('report: could not shrink ' + bad.length + ' picture(s): ' + bad[0].slice(0, 160));
  try { unlinkSync(jf); } catch {}
}
let picBytes = 0;
const dataUri = (d, f) => { try { const c = cachePath(srcOf(d, f)); if (!existsSync(c)) return ''; const b = readFileSync(c); picBytes += Math.ceil(b.length * 4 / 3); return 'data:image/jpeg;base64,' + b.toString('base64'); } catch { return ''; } };
const picHtml = [];
outer: for (const e of picEntries) {
  const cards = [];
  for (const p of e.pairs) {
    if (picBytes > PIC_BUDGET) break outer;
    const bu = dataUri(p.bdir, p.bfile), au = dataUri(p.adir, p.afile); if (!bu || !au) continue;
    const label = p.afile.replace(/-1080\.\w+$/, '').replace(/^\d+-/, '').replace(/-/g, ' ');
    cards.push(`<figure class="pair"><figcaption>${esc(label)}</figcaption><div class="ba"><div><span>Before</span><img loading="lazy" alt="before: ${esc(label)}" src="${bu}"></div><div><span>After</span><img loading="lazy" alt="after: ${esc(label)}" src="${au}"></div></div></figure>`);
  }
  if (!cards.length) continue;
  const subj = e.vs.slice(0, 3).map(v => `v${v}: ${vset.get(v).text}`);
  picHtml.push(`<section class="pic"><h3>${esc(subj[0])}${e.vs.length > 1 ? `<small> and ${e.vs.length - 1} more version${e.vs.length > 2 ? 's' : ''} in the same job</small>` : ''}</h3>${e.task ? `<p class="dim">Job: ${esc(e.task)}</p>` : ''}${cards.join('')}</section>`);
}

// ---------------------------------------------------------------- what waits on him (questions.md)
const qs = [];
{ let head = '', cur = null;
  for (const l of rd(C + '/questions.md').split(/\r?\n/)) {
    if (/^#{2,}\s/.test(l)) { head = l.replace(/^#+\s*/, ''); cur = null; continue; }
    if (/^\s*-\s+/.test(l)) { cur = { head, text: l.replace(/^\s*-\s+/, '') }; qs.push(cur); continue; }
    if (cur && l.trim() && !/^#/.test(l)) cur.text += ' ' + l.trim(); else if (!l.trim()) cur = null;
  } }
const qItems = qs.map(q => {
  const m = /^(\d\d-\d\d(?: \d\d:\d\d)?)?\s*\(([^)]+)\):?\s*(.*)$/.exec(q.text);
  const hd = q.head.replace(/^\d{4}-\d\d-\d\d\s*/, '').split(' ')[0];
  const who = m ? humanTask(m[2]) : (hd ? humanTask(hd) : 'A helper');
  let when = m && m[1] ? m[1] : (/^(\d{4})-(\d\d)-(\d\d)/.exec(q.head) ? q.head.slice(5, 10) : '');
  const full = m ? m[3] : q.text, body = full.slice(0, 700);
  // recent = dated today, yesterday or later (or undated); older notes are folded away
  let recent = true; const dm = /^(\d\d)-(\d\d)/.exec(when || '');
  if (dm) { const dd = new Date(now.getFullYear(), +dm[1] - 1, +dm[2]); recent = now.getTime() - dd.getTime() < 3 * 864e5; }
  return { recent, html: `<li><b>${esc(who)}</b>${when ? ` <span class="dim">${esc(when)}</span>` : ''}<br>${esc(body)}${full.length > 700 ? ' ...' : ''}</li>` };
});
const qNew = qItems.filter(x => x.recent).map(x => x.html), qOld = qItems.filter(x => !x.recent).map(x => x.html);
const qHtml = qNew.concat(qOld);

// ---------------------------------------------------------------- the page
const first = versions[0], last = versions[versions.length - 1];
const li = v => `<li><b>v${esc(v.ver)}</b> ${esc(v.text)} <span class="dim">${hm(v.at)}</span></li>`;
const groupHtml = GROUPS.filter(([k]) => byGroup[k].length).map(([k, name]) => {
  const L = byGroup[k].slice().reverse();
  return `<section class="grp"><h3>${name} <small>${L.length}</small></h3><ul>${L.slice(0, 8).map(li).join('')}</ul>${L.length > 8 ? `<details><summary>Show the other ${L.length - 8}</summary><ul>${L.slice(8).map(li).join('')}</ul></details>` : ''}</section>`;
}).join('');
const sum = GROUPS.filter(([k]) => byGroup[k].length).map(([k, n]) => `${byGroup[k].length} ${n.toLowerCase()}`).join(', ');
const tiles = [
  [String(versions.length), 'new versions' + (first ? ` (v${first.ver} to v${last.ver})` : '')],
  [stable.version ? 'v' + stable.version : 'none yet', 'latest stable build' + (stable.at ? ` (${stable.at})` : '')],
  [`${raids}`, `robot raids, ${rProblems ? rProblems + ' problem(s)' : 'no crashes'}`],
  [`$${jobs.cost.toFixed(2)}`, `of helper work, ${jobs.done.length} job${jobs.done.length === 1 ? '' : 's'} finished`]
].map(([a, b]) => `<div class="tile"><b>${esc(a)}</b><span>${esc(b)}</span></div>`).join('');
// one plain sentence about the newest finished full test run (from tools/handoff/stable-status.txt)
const testNote = !newestRun ? '' : (newestRun.ver === stable.version ? `The newest full test run is the one behind this stable build.`
  : +newestRun.fresh > 0 ? `The newest full test run (on v${esc(newestRun.ver)}) had ${esc(newestRun.failing)} checks red, ${esc(newestRun.fresh)} of them new, so no newer build can be stable until those are fixed or accepted.`
  : /waiting for robots/.test(newestRun.why) ? `The newest full test run (on v${esc(newestRun.ver)}) is clean; the robots still have to play 30 minutes on that exact version.`
  : `The newest full test run (on v${esc(newestRun.ver)}): ${esc(newestRun.why.replace(/\s*\|.*$/, ''))}.`);
const stableLine = stable.version
  ? `The latest <b>stable</b> build is <b>v${esc(stable.version)}</b> (made stable ${esc(stable.at)}). On your PC open <code>http://localhost:8802/stable.html</code> to play it. ${testNote}`
  : 'No build is marked stable yet.';
const helpersHtml = (jobs.done.length || jobs.failed.length || jobs.partial)
  ? `<p>${jobs.done.length} job${jobs.done.length === 1 ? '' : 's'} finished${jobs.partial ? `, ${jobs.partial} attempt${jobs.partial === 1 ? '' : 's'} that needed another try (a job gets up to 5)` : ''}${jobs.failed.length ? `, ${uniq(jobs.failed).length} given up` : ''}. Work in this window: about <b>$${jobs.cost.toFixed(2)}</b>.</p>` +
    (jobs.done.length ? `<p class="dim">Finished: ${esc(uniq(jobs.done).slice(0, 14).join('; '))}${uniq(jobs.done).length > 14 ? ' ...' : ''}</p>` : '') +
    (jobs.failed.length ? `<p class="dim">Given up on: ${esc(uniq(jobs.failed).join('; '))}</p>` : '')
  : '<p>The helpers finished no jobs in this window.</p>';
const moneyLine = `<p class="dim">Costs are the helpers' own estimates at list prices (the Console Billing page has the exact balance). Since the helpers started${jobs.firstDay ? ' on ' + esc(jobs.firstDay) : ''}: about $${jobs.allCost.toFixed(2)}.${planUse ? ` Your Claude plan: ${esc(planUse.wk)}% of the week used (as of ${hm(planUse.at)}).` : ''}</p>`;
const when = `${DAYS[now.getDay()]}, ${MONS[now.getMonth()]} ${now.getDate()}`;
const html = `<!doctype html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="color-scheme" content="dark"><meta name="theme-color" content="#0e1013">
<title>Pillagers report ${ymd(now)} ${kind}</title>
<style>
:root{--bg:#0e1013;--card:#171a1f;--line:#262b33;--ink:#e9e6df;--dim:#9aa1ab;--amber:#f0a83a;--green:#5fd47a;--red:#ff6b5e}
*{box-sizing:border-box}html,body{margin:0;overflow-x:hidden}body{background:var(--bg);color:var(--ink);font:16px/1.5 "Segoe UI",system-ui,sans-serif;-webkit-text-size-adjust:100%}
main{max-width:780px;margin:0 auto;padding:16px 16px 48px}
h1{margin:8px 0 2px;font-size:24px;letter-spacing:.04em;color:var(--amber)}h2{margin:28px 0 8px;font-size:18px;letter-spacing:.04em;border-top:1px solid var(--line);padding-top:16px}
h3{margin:18px 0 6px;font-size:16px}h3 small{color:var(--dim);font-weight:400}
p{margin:8px 0}.dim{color:var(--dim);font-size:14px}code{background:#232830;border-radius:4px;padding:1px 6px;font-size:14px;overflow-wrap:anywhere}
.lead{font-size:17px}.tiles{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:10px;margin:16px 0}
.tile{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:12px}.tile b{display:block;font-size:22px;color:var(--ink)}.tile span{font-size:13px;color:var(--dim)}
ul{margin:6px 0;padding-left:20px}li{margin:5px 0;overflow-wrap:anywhere}li b{color:var(--amber)}
.grp,.pic{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:4px 16px 12px;margin:12px 0}
details{margin-top:6px}summary{cursor:pointer;color:var(--amber);padding:6px 0}
figure{margin:12px 0}figcaption{font-size:14px;color:var(--dim);margin-bottom:4px;text-transform:capitalize}
.ba{display:grid;grid-template-columns:1fr;gap:8px}.ba div{position:relative}.ba span{position:absolute;top:6px;left:6px;background:#000a;color:var(--ink);font-size:12px;padding:2px 8px;border-radius:10px}
.ba img{width:100%;height:auto;display:block;border-radius:6px;border:1px solid var(--line)}
@media(min-width:620px){.ba{grid-template-columns:1fr 1fr}}
.q li{background:var(--card);border:1px solid var(--line);border-radius:10px;padding:10px 12px;list-style:none;margin:8px 0}.q{padding-left:0}
.foot{margin-top:32px;color:var(--dim);font-size:13px}
</style></head><body><main>
<h1>PILLAGERS REPORT</h1>
<p class="dim">${esc(when)}, ${kind === 'am' ? 'morning' : 'evening'}. Covers ${esc(nice(since))} to ${esc(nice(now))}.</p>
<p class="lead">${versions.length ? `${versions.length} new version${versions.length === 1 ? '' : 's'} went into the game: ${esc(sum)}.` : 'No new versions went into the game in this window.'}</p>
<div class="tiles">${tiles}</div>
<p>${stableLine}</p>

<h2>WHAT CHANGED</h2>
${groupHtml || '<p>Nothing new.</p>'}
${fixtureCommits > 0 ? `<p class="dim">Plus ${fixtureCommits} behind-the-scenes update${fixtureCommits === 1 ? '' : 's'} to the automatic tests and tools (no change to the game itself).</p>` : ''}

<h2>BEFORE AND AFTER</h2>
${picHtml.length ? `<p class="dim">Screens the helpers redrew, as they looked before and after. Small copies; tap and hold to save.</p>${picHtml.join('')}` : '<p>No before and after pictures for these versions.</p>'}

<h2>YOUR HELPERS</h2>
${helpersHtml}
${moneyLine}

<h2>TESTS AND ROBOTS</h2>
<p>The crash-hunting robots played <b>${raids}</b> raid${raids === 1 ? '' : 's'} in this window and found <b>${rProblems ? rProblems + ' problem' + (rProblems === 1 ? '' : 's') : 'no crashes'}</b>.${newestRun ? ` The newest finished run of the full test set (about 2,000 checks) was on v${esc(newestRun.ver)}: ${esc(newestRun.failing)} checks red, ${esc(newestRun.fresh)} of them new.` : ''}</p>

<h2>WAITING ON YOU</h2>
${qHtml.length ? `<p class="dim">${qHtml.length} question${qHtml.length === 1 ? '' : 's'} from the helpers. Each one was left as it was until you say yes or no.</p><ul class="q">${qNew.slice(0, 10).join('')}</ul>${(qNew.length > 10 || qOld.length) ? `<details><summary>Show ${qNew.length > 10 ? 'the other ' + (qNew.length - 10) + ' and ' : ''}${qOld.length} older</summary><ul class="q">${qNew.slice(10).concat(qOld).join('')}</ul></details>` : ''}` : '<p>Nothing is waiting on you.</p>'}

<p class="foot">Made by tools/report.mjs at ${hm(now)} from the game's change history, the helpers' logs and notes. No AI was used to write this page.</p>
</main></body></html>
`;
const bytes = Buffer.byteLength(html);
writeFileSync(outFile, html);
if (!flag('no-state')) writeFileSync(REP + '/state.json', JSON.stringify({ lastAt: now.toISOString(), lastFile: outFile.replace(/^.*\//, ''), lastVersion: last ? last.ver : (state.lastVersion || '') }, null, 1) + '\n');
console.log(`report: wrote ${outFile} (${(bytes / 1048576).toFixed(2)} MB, ${versions.length} versions, ${picHtml.length} picture groups, ${qs.length} questions, window ${nice(since)} to ${nice(now)})`);
if (bytes > MAX_BYTES) { console.log(`report: WARNING the page is over ${MAX_BYTES} bytes`); process.exitCode = 1; }
