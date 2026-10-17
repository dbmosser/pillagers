// review-batch.mjs : the nightly half-price code review (2026-10-17, his "ok do everything that you think you should").
// Sends each game commit of the last 24 h, as its diff, to the Message Batches API (half price, on his Console credits), waits for
// the batch, writes tools/handoff/console/review/<date>.md, adds its cost to spend.txt, and queues a lane-a task when a HIGH
// finding needs checking. Run by tools/review-nightly.sh, which passes ANTHROPIC_API_KEY (never printed) and CW_WS (workspace).
import { execFileSync } from 'child_process';
import { writeFileSync, mkdirSync, appendFileSync } from 'fs';
const R = 'C:/claudecode/dark raiders', C = R + '/tools/handoff/console', e = process.env;
const day = new Date().toLocaleDateString('en-CA');
const H = { 'x-api-key': e.ANTHROPIC_API_KEY, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' };
if (e.CW_WS) H['anthropic-workspace-id'] = e.CW_WS;
const git = a => execFileSync('git', a, { cwd: R, encoding: 'utf8', maxBuffer: 64e6 });
const commits = git(['log', '--since=' + (e.CW_SINCE || '24.hours'), '--format=%H\t%s', '--', 'dark_raiders.html'])
  .trim().split('\n').filter(Boolean).map(l => l.split('\t'));
if (!commits.length) { console.log(day + ' review: no game commits'); process.exit(0); }
const SYS = 'You review ONE shipped change to PILLAGERS, a one-file Canvas 2D browser game (about 4 MB of plain JavaScript). You see ' +
  'only the diff. Report only real defects you can point to in the diff: a crash or exception, a logic error, behaviour that ' +
  'contradicts the change\'s own comment or title, NaN or undefined reaching canvas calls, an allocation or heavy loop in per-frame ' +
  'code, a test check that cannot fail. No style notes and no guesses about code you cannot see. Answer NONE, or one finding per ' +
  'line as: HIGH|MED <the code it concerns> -- <why it is wrong>.';
const reqs = commits.map(([h, s]) => ({ custom_id: h.slice(0, 12), params: {
  model: e.CW_REVIEW_MODEL || 'claude-sonnet-5-5', max_tokens: 1500, system: SYS,
  messages: [{ role: 'user', content: 'Title: ' + s + '\n\n' + git(['show', '--format=', '-U4', h, '--', 'dark_raiders.html']).slice(0, 80000) }] } }));
const API = 'https://api.anthropic.com/v1/messages/batches';
let r = await fetch(API, { method: 'POST', headers: H, body: JSON.stringify({ requests: reqs }) }), b = await r.json();
if (!r.ok) { console.log(day + ' review: batch refused ' + r.status + ' ' + JSON.stringify(b.error || b).slice(0, 300)); process.exit(1); }
console.log(day + ' review: batch ' + b.id + ' sent, ' + commits.length + ' commits');
for (let i = 0; i < 360 && b.processing_status !== 'ended'; i++) {
  await new Promise(z => setTimeout(z, 60000));
  b = await (await fetch(API + '/' + b.id, { headers: H })).json();
}
if (b.processing_status !== 'ended') { console.log(day + ' review: batch ' + b.id + ' not done after 6 h'); process.exit(1); }
const res = (await (await fetch(b.results_url, { headers: H })).text()).trim().split('\n').map(l => JSON.parse(l));
const subj = Object.fromEntries(commits.map(([h, s]) => [h.slice(0, 12), s]));
let cost = 0, highs = 0, md = '# Code review ' + day + ' (' + commits.length + ' game commits, Batch API, half price)\n';
for (const x of res) {
  const m = x.result && x.result.message;
  const t = m ? m.content.map(c => c.text || '').join('').trim() : 'ERROR ' + JSON.stringify(x.result).slice(0, 200);
  if (m) { const u = m.usage || {}; cost += ((u.input_tokens || 0) * 1.5 + (u.output_tokens || 0) * 7.5) / 1e6; }
  if (/^NONE\b/.test(t)) continue;
  highs += (t.match(/^HIGH/mg) || []).length;
  md += '\n## ' + x.custom_id + ' ' + subj[x.custom_id] + '\n' + t + '\n';
}
mkdirSync(C + '/review', { recursive: true });
writeFileSync(C + '/review/' + day + '.md', md);
appendFileSync(C + '/spend.txt', day + ' ' + cost.toFixed(4) + ' review\n');
if (highs) writeFileSync(C + '/tasks/50-review-' + day.replace(/-/g, '') + '.md',
  'The nightly code review of ' + day + ' flagged ' + highs + ' HIGH findings: tools\\handoff\\console\\review\\' + day + '.md. ' +
  'The reviewer saw only each diff, so many may be false alarms: confirm each one against the current code first. Fix the ' +
  'confirmed ones as cw- keys (one fix per key) and write a verdict for every HIGH (REAL and fixed, or FALSE ALARM and why) in ' +
  'your notes. TASK DONE when every HIGH has a verdict.\n');
console.log(day + ' review: ' + commits.length + ' commits, ' + highs + ' HIGH, $' + cost.toFixed(3));
