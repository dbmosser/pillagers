// critic.mjs : a fresh, skeptical UI critic for the helpers' screenshots (2026-10-18). Why: Anthropic's harness write-up found that
// an agent praises its own mediocre design work, and a separate skeptical judge with a rubric works better. So the helper that
// changed a screen never grades it: it runs
//   node tools/console-sdk/critic.mjs PIC [PIC ...]      (1-4 jpg/png; a path containing "before" is the old version)
// Since 10-19 one Claude Code run on his plan (CRITIC_ENGINE=api in caps.txt: one API call on his Console credits instead). Prints JSON
// {score, better_than_before, verdict, findings:[{sev, where, what, fix}]}, records scores in notes/ui/accept.json and the cost in spend.txt.
import { readFileSync, writeFileSync, existsSync, appendFileSync, mkdirSync } from 'fs';
import { spawnSync } from 'child_process';
const R = 'C:/claudecode/dark raiders', C = R + '/tools/handoff/console', U = C + '/notes/ui';
const pics = process.argv.slice(2);
const ok = p => /^tools\/handoff\/(console\/notes|shots|ui-refs)\/[A-Za-z0-9_./-]+\.(jpe?g|png)$/i.test(p) && !p.includes('..') && existsSync(R + '/' + p);
if (!pics.length || pics.length > 4 || !pics.every(ok)) { console.log('USAGE: node tools/console-sdk/critic.mjs PIC [PIC ...] (1-4 existing jpg/png under tools/handoff/console/notes, shots or ui-refs)'); process.exit(1); }
const caps = {}; try { readFileSync(C + '/caps.txt', 'utf8').split(/\r?\n/).forEach(l => { const m = /^(\w+)=(.*)$/.exec(l.trim()); if (m) caps[m[1]] = m[2]; }); } catch {}
const guide = existsSync(U + '/style-guide.md') ? readFileSync(U + '/style-guide.md', 'utf8').slice(0, 8000) : '(no style guide yet: judge against the rubric alone)';
const sys = `You are a skeptical senior UI art director at a AAA studio reviewing screenshots of PILLAGERS, a top-down 2.5D extraction
shooter (the bar: ARC Raiders and Fortnite menus; the feel: ARC Raiders x Zero Sievert). The owner says the UI is the weakest part of
the game and wants it to "actually look good", with style consistency across every menu. Your job is to find what is wrong, not to
encourage. A 4 means a player would call it polished; most amateur game screens are a 2. Never give 5 unless it could ship in a AAA game.
Rubric (weight): hierarchy, what the eye hits first and whether it should (3); consistency with the style guide and the other screens:
type sizes, palette, panels, buttons, title and close/back placement (3); craft: alignment, spacing, padding, clipping, overlaps,
crowding, contrast (2); identity, does it feel like this game and not a generic template (1); readability at 1080 from a couch, with
pad focus visible (1). ALL LOWER CASE is required: the owner ordered every word on screen lower case (2026-10-18), so never flag lower case as a defect and flag any capital letter on screen except inside art. Clutter and explaining sentences on screen are defects.
Party walk-up screens (attract, how to play, waiting, run over, scoreboard, player 2's title) continue on ANY key or button by the owner's order (instant start for walk-up guests), and the prompt names the key or pad button of the device in use; that live prompt IS the primary action there, so judge its size, place and contrast, but never ask for a separate clickable or filled button on those screens.
Style guide:\n${guide}\n
Answer with ONLY a JSON object: {"score":1-5,"better_than_before":"yes"|"no"|"same"|"n/a","verdict":"one plain sentence",
"findings":[{"sev":"P0"|"P1"|"P2","where":"...","what":"...","fix":"concrete, numeric where possible"}]} with at most 8 findings, worst first.`;
// 10-18: lane d saw the critic flip its advice between runs ("Press any button" was a fake button, then a missing action). So it
// is shown its own last review of the same screen and told to stay consistent.
let prev = {}; try { prev = JSON.parse(readFileSync(U + '/accept.json', 'utf8')); } catch {}
const shotName = p => { const m = /(\d\d-[a-z0-9-]+?)(-1080|-4k)?\.(jpe?g|png)$/i.exec(p); return m && m[1]; };
const before = pics.filter(p => !/before/i.test(p)).map(shotName).filter(k => k && prev[k] && prev[k].findings);
const content = [];
if (before.length) content.push({ type: 'text', text: 'Your previous review of this screen (stay consistent: do not reverse earlier advice unless the new picture shows it was wrong; if the earlier advice was followed, judge the result): ' + before.map(k => k + ': score ' + prev[k].score + '; ' + JSON.stringify(prev[k].findings).slice(0, 2500)).join(' | ') });
pics.forEach((p, i) => { const b = readFileSync(R + '/' + p); content.push({ type: 'text', text: 'Image ' + (i + 1) + ' (' + (/before/i.test(p) ? 'OLD version' : 'NEW version') + '): ' + p });
  content.push({ type: 'image', source: { type: 'base64', media_type: /png$/i.test(p) ? 'image/png' : 'image/jpeg', data: b.toString('base64') } }); });
content.push({ type: 'text', text: 'Review the NEW version' + (pics.some(p => /before/i.test(p)) ? ' and compare it with the OLD one.' : '.') });
// 10-19 his order, verbatim: "Move the screen judge onto my Claude plan instead of Console credit". The plan is the default now;
// CRITIC_ENGINE=api in caps.txt goes back to the Console key (and still falls back to the plan when the credit is gone).
const viaApi = caps.CRITIC_ENGINE === 'api';
let res = { ok: false, status: 0 }, j = {};
if (viaApi) {
  const key = spawnSync('powershell', ['-NoProfile', '-Command', "[Environment]::GetEnvironmentVariable('PILLAGERS_API_KEY','User')"], { encoding: 'utf8', windowsHide: true }).stdout.trim();
  const H = { 'x-api-key': key, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' };
  if (caps.WORKSPACE_ID) H['anthropic-workspace-id'] = caps.WORKSPACE_ID;
  res = await fetch('https://api.anthropic.com/v1/messages', { method: 'POST', headers: H, body: JSON.stringify({ model: caps.MODEL || 'claude-sonnet-5-5', max_tokens: 3000, system: sys, messages: [{ role: 'user', content }] }) });
  j = await res.json().catch(() => ({})); }
let cost = 0, txt = '', book = C + '/spend.txt';
if (res.ok) { const u = j.usage || {}; cost = ((u.input_tokens || 0) * 1.71 + (u.output_tokens || 0) * 8.54) / 1e6;
  txt = (j.content || []).filter(b => b.type === 'text').map(b => b.text).join('\n'); }
else if (!viaApi || /credit/i.test(String(j.error && j.error.message))) {
  // 10-18: when the month's Console credit is gone, the same review runs once through Claude Code on his plan (Read shows pictures)
  const exe = existsSync(process.env.USERPROFILE + '/.local/bin/claude.exe') ? process.env.USERPROFILE + '/.local/bin/claude.exe' : 'claude';
  const env = { ...process.env }; delete env.ANTHROPIC_API_KEY;
  const ask = 'Read each picture with the Read tool, then answer. ' + pics.map((p, i) => 'Image ' + (i + 1) + ' (' + (/before/i.test(p) ? 'OLD version' : 'NEW version') + '): ' + R + '/' + p).join('; ') + '. Review the NEW version' + (pics.some(p => /before/i.test(p)) ? ' and compare it with the OLD one.' : '.');
  const r = spawnSync(exe, ['-p', ask, '--append-system-prompt', sys, '--model', 'sonnet', '--output-format', 'json', '--allowedTools', 'Read', '--max-turns', '8'], { cwd: R, env, encoding: 'utf8', windowsHide: true, timeout: 600000, maxBuffer: 32e6 });
  let o = {}; try { o = JSON.parse(r.stdout); } catch {}
  if (!o.result || o.is_error) { console.log('CRITIC (Claude Code) failed: ' + String(o.result || r.stderr || r.stdout).slice(0, 400)); process.exit(1); }
  cost = o.total_cost_usd || 0; txt = o.result; book = C + '/cli-spend.txt'; }
else { console.log('CRITIC API ' + res.status + ': ' + String(j.error && j.error.message).slice(0, 400)); process.exit(1); }
let v; try { v = JSON.parse(txt.slice(txt.indexOf('{'), txt.lastIndexOf('}') + 1)); } catch { v = { score: 0, verdict: 'critic answer was not JSON', raw: txt.slice(0, 1500) }; }
const task = process.env.CW_TASK || 'manual';
appendFileSync(book, new Date().toLocaleDateString('en-CA') + ' ' + cost.toFixed(4) + ' critic-' + task + '\n');
mkdirSync(U, { recursive: true });
let acc = {}; try { acc = JSON.parse(readFileSync(U + '/accept.json', 'utf8')); } catch {}
for (const p of pics.filter(p => !/before/i.test(p))) { const m = /(\d\d-[a-z0-9-]+?)(-1080|-4k)?\.(jpe?g|png)$/i.exec(p);
  if (m) acc[m[1]] = { score: v.score, pass: v.score >= 4, verdict: v.verdict, findings: (v.findings || []).slice(0, 5).map(f => f.sev + ' ' + f.where + ': ' + f.fix), pic: p, task, when: new Date().toISOString().slice(0, 16) }; }
writeFileSync(U + '/accept.json', JSON.stringify(acc, null, 1));
console.log(JSON.stringify(v));
