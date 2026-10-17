// run-api.mjs : one Console worker task as a small agent loop on the plain Claude API (2026-10-17).
// Why: his Max plan's monthly API credits cover the Claude API but not Claude Code, and the Agent SDK runs the Claude Code engine,
// so both answered "Credit balance is too low" while a plain API call with the same key worked.
// The lockdown lives in this file: the tools below can read anything, write only the worker's own files, and run only the
// project's ship and test scripts (ALLOW_CMD). Called by tools/console-worker.sh with CW_* variables and ANTHROPIC_API_KEY
// (read from his Windows variable, never printed). Prints one JSON line: result, total_cost_usd, terminal_reason, subtype.
import { readFileSync, writeFileSync, readdirSync, statSync, mkdirSync } from 'fs';
import { resolve, dirname, join } from 'path';
import { spawnSync } from 'child_process';
const e = process.env;
const R = 'C:/claudecode/dark raiders', S = e.CW_S, KEY = e.ANTHROPIC_API_KEY;
const MODEL = e.CW_MODEL || 'claude-sonnet-5-5', BUDGET = Number(e.CW_BUDGET || 1), MAX_TURNS = Number(e.CW_TURNS || 150);
const PRICE = { in: Number(e.CW_P_IN || 3), out: Number(e.CW_P_OUT || 15), cr: Number(e.CW_P_CR || 0.3), cw: Number(e.CW_P_CW || 3.75) };
const BASH = 'C:/Program Files/Git/bin/bash.exe';
const norm = p => resolve(R, String(p || '').replace(/\\/g, '/')).replace(/\\/g, '/');
const low = p => norm(p).toLowerCase();
const SL = S.replace(/\\/g, '/').toLowerCase(), RL = R.toLowerCase();
const canWrite = p => { const x = low(p);
  return (x.startsWith(SL + '/mk-cw-') && x.endsWith('.ps1') && !x.slice(SL.length + 1).includes('/'))
    || x.startsWith(RL + '/tools/handoff/console/notes/') || x === RL + '/tools/handoff/console/questions.md'; };
const canEdit = p => canWrite(p) || low(p) === RL + '/tools/mkfixture.ps1';
const esc = s => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
const Sx = esc(S.replace(/\\/g, '/'));
const ALLOW_CMD = [
  new RegExp('^bash ' + Sx + '/shipq\\.sh cw-[A-Za-z0-9_-]+$'),
  new RegExp('^bash ' + Sx + '/shipdraft\\.sh [A-Za-z0-9_-]+$'),
  new RegExp('^(HELD=1 )?bash ' + Sx + '/fixq\\.sh "[^"`$\\\\;&|<>]+"$'),
  new RegExp('^bash ' + Sx + '/genP\\.sh [0-9]+$'),
  new RegExp('^bash ' + Sx + '/runchk\\.sh [^"`$\\\\;&|<>]+$'),
  new RegExp('^bash ' + Sx + '/(lock|unlock|clearstale)\\.sh$'),
  new RegExp('^powershell -NoProfile -ExecutionPolicy Bypass -File ' + Sx + '/mk-cw-[A-Za-z0-9_-]+\\.ps1$'),
  /^powershell -NoProfile -ExecutionPolicy Bypass -File tools\/cdp\.ps1 -Start -Port 9346$/,
  /^git (status|log|diff|show)( [^"`$\\;&|<>]*)?$/,
  /^bash tools\/handoff\/preflight\.sh [abc] cw-[A-Za-z0-9_-]+$/ ];   // 10-17: the gate without the lock, on the lane's own Chrome
const cut = (s, n) => s.length > n ? s.slice(0, n) + '\n[cut at ' + n + ' chars]' : s;
function readLines(p, off, lim) {
  const L = readFileSync(norm(p), 'utf8').split(/\r?\n/); const o = Math.max(1, off || 1), n = Math.min(lim || 200, 400);
  return cut(L.slice(o - 1, o - 1 + n).map((l, i) => (o + i) + '\t' + l).join('\n'), 20000) + (o - 1 + n < L.length ? '\n[' + L.length + ' lines in all]' : '');
}
function walk(p, out, depth) {
  const st = statSync(p); if (st.isFile()) { out.push(p); return; }
  if (depth > 6) return;
  for (const f of readdirSync(p)) { if (f === 'node_modules' || f === '.git') continue; walk(join(p, f), out, depth + 1); if (out.length > 3000) return; }
}
function grep(pat, p, ctx, max) {
  const re = new RegExp(pat); const files = []; walk(norm(p), files, 0); const hits = []; max = Math.min(max || 40, 120); ctx = Math.min(ctx || 0, 10);
  for (const f of files) { if (statSync(f).size > 20e6) continue; const L = readFileSync(f, 'utf8').split(/\r?\n/);
    for (let i = 0; i < L.length && hits.length < max; i++) if (re.test(L[i])) {
      const a = Math.max(0, i - ctx), b = Math.min(L.length, i + ctx + 1);
      hits.push(f.replace(/\\/g, '/') + ':' + (i + 1) + ':\n' + L.slice(a, b).map((l, j) => '  ' + (a + j + 1) + (a + j === i ? '> ' : '  ') + cut(l, 400)).join('\n')); }
    if (hits.length >= max) break; }
  return cut(hits.join('\n') || 'no matches', 12000);
}
const TOOLS = [
  { name: 'read_file', description: 'Read lines of a file, numbered. Never read the whole game file or fixture: grep first, then read about 150 lines.', input_schema: { type: 'object', properties: { path: { type: 'string' }, offset: { type: 'integer', description: 'first line, 1-based' }, limit: { type: 'integer', description: 'lines, at most 400' } }, required: ['path'] } },
  { name: 'grep', description: 'Search a file or folder (recursive) with a JavaScript regex; returns path:line with optional context lines.', input_schema: { type: 'object', properties: { pattern: { type: 'string' }, path: { type: 'string' }, context: { type: 'integer' }, max: { type: 'integer' } }, required: ['pattern', 'path'] } },
  { name: 'list_dir', description: 'List a folder.', input_schema: { type: 'object', properties: { path: { type: 'string' } }, required: ['path'] } },
  { name: 'write_file', description: 'Create or replace a file. Allowed only for S/mk-cw-*.ps1, tools/handoff/console/notes/**, tools/handoff/console/questions.md.', input_schema: { type: 'object', properties: { path: { type: 'string' }, content: { type: 'string' } }, required: ['path', 'content'] } },
  { name: 'edit_file', description: 'Replace one exact, unique piece of text in a file (the write paths plus tools/mkfixture.ps1).', input_schema: { type: 'object', properties: { path: { type: 'string' }, old_text: { type: 'string' }, new_text: { type: 'string' } }, required: ['path', 'old_text', 'new_text'] } },
  { name: 'run', description: 'Run ONE allowed command exactly as listed in your rules (ship, fixq, genP, runchk, lock, unlock, clearstale, a mk-cw script, the cdp 9346 restart, read-only git). Anything else is refused.', input_schema: { type: 'object', properties: { command: { type: 'string' } }, required: ['command'] } } ];
function useTool(name, a) {
  try {
    if (name === 'read_file') return readLines(a.path, a.offset, a.limit);
    if (name === 'grep') return grep(a.pattern, a.path, a.context, a.max);
    if (name === 'list_dir') return readdirSync(norm(a.path)).slice(0, 500).join('\n');
    if (name === 'write_file') { if (!canWrite(a.path)) return 'REFUSED: you may not write ' + a.path;
      mkdirSync(dirname(norm(a.path)), { recursive: true }); writeFileSync(norm(a.path), a.content); return 'written'; }
    if (name === 'edit_file') { if (!canEdit(a.path)) return 'REFUSED: you may not edit ' + a.path;
      const t = readFileSync(norm(a.path), 'utf8'); const n = t.split(a.old_text).length - 1;
      if (n !== 1) return 'NOT CHANGED: old_text found ' + n + ' times (must be exactly once)';
      writeFileSync(norm(a.path), t.replace(a.old_text, () => a.new_text)); return 'edited'; }
    if (name === 'run') { const c = String(a.command).trim().replace(/\\/g, '/');
      if (!ALLOW_CMD.some(re => re.test(c))) return 'REFUSED: not an allowed command. See the exact forms in your rules.';
      // 10-17 16:30: a helper took the lock with lock.sh, then ran fixq.sh without HELD=1, and fixq waited 46 minutes for the
      // lock its own helper held, blocking every ship. The loop now remembers a lock it took and adds HELD=1 itself.
      const c2 = (heldLock && /\/fixq\.sh /.test(c) && !/^HELD=1 /.test(c)) ? 'HELD=1 ' + c : c;
      const r = spawnSync(BASH, ['-c', c2], { cwd: R, encoding: 'utf8', timeout: 4 * 3600 * 1000, maxBuffer: 64e6, env: { ...e, ANTHROPIC_API_KEY: '' } });
      if (/\/lock\.sh$/.test(c) && r.status === 0) { heldLock = true; lockAt = Date.now(); }
      if (/\/unlock\.sh$/.test(c)) heldLock = false;
      const o = (r.stdout || '') + (r.stderr ? '\n[stderr]\n' + r.stderr : '');
      return 'exit ' + r.status + '\n' + (o.length > 5000 ? '[first part cut]\n' + o.slice(-5000) : o); }
    return 'unknown tool';
  } catch (err) { return 'ERROR: ' + String(err && err.message || err).slice(0, 500); }
}
const out = { result: '', total_cost_usd: 0, terminal_reason: '', subtype: '' };
let cost = 0, lastText = '', heldLock = false, lockAt = 0;
const sys = [{ type: 'text', text: readFileSync(e.CW_RULES, 'utf8') + '\n\nS (the scratchpad) is ' + S.replace(/\\/g, '/') + '. Your tools: read_file, grep, list_dir, write_file, edit_file, run.', cache_control: { type: 'ephemeral' } }];
const msgs = [{ role: 'user', content: [{ type: 'text', text: 'Your task id is ' + e.CW_TASK + '. Your lane is ' + (e.CW_LANE || 'a') + '. ' + readFileSync(e.CW_PROMPT_FILE, 'utf8') }] }];
const headers = { 'x-api-key': KEY, 'anthropic-version': '2023-06-01', 'content-type': 'application/json' };
if (e.CW_WS) headers['anthropic-workspace-id'] = e.CW_WS;
// 10-17, his "I just want them to be spent EFFICIENTLY": every turn re-sends the whole history, so keep it small. When the old tool
// outputs pass TRIM characters, all but the newest KEEP are cleared (and the big file bodies the worker wrote). That costs one cache
// rewrite of a smaller history, instead of reading a big one on every later turn.
const TRIM = Number(e.CW_TRIM || 120000), KEEP = 8;
function trim() {
  const tr = []; for (const m of msgs) for (const b of m.content) if (b.type === 'tool_result') tr.push(b);
  if (tr.reduce((s, b) => s + String(b.content).length, 0) < TRIM) return;
  for (const b of tr.slice(0, -KEEP)) if (String(b.content).length > 300) b.content = '[older output cleared to save cost; run the tool again if you need it]';
  const tu = []; for (const m of msgs) if (m.role === 'assistant') for (const b of m.content) if (b.type === 'tool_use') tu.push(b);
  for (const b of tu.slice(0, -KEEP)) for (const k of ['content', 'new_text', 'old_text'])
    if (b.input && typeof b.input[k] === 'string' && b.input[k].length > 300) b.input[k] = '[cleared]';
}
try {
  for (let turn = 0; ; turn++) {
    if (turn >= MAX_TURNS) { out.terminal_reason = 'max_turns'; break; }
    if (cost >= BUDGET) { out.terminal_reason = 'budget'; break; }
    trim();
    // cache everything up to the newest message, so each turn re-reads the history at the cache price
    for (const m of msgs) for (const b of m.content) delete b.cache_control;
    const lastC = msgs[msgs.length - 1].content; lastC[lastC.length - 1].cache_control = { type: 'ephemeral' };
    let res, j;
    for (let tries = 0; tries < 5; tries++) {
      res = await fetch('https://api.anthropic.com/v1/messages', { method: 'POST', headers, body: JSON.stringify({ model: MODEL, max_tokens: 16000, system: sys, tools: TOOLS, messages: msgs }) });
      j = await res.json().catch(() => ({}));
      if (res.status === 429 || res.status === 529 || res.status >= 500) { await new Promise(r => setTimeout(r, 20000 * (tries + 1))); continue; }
      break;
    }
    if (!res.ok) { out.result = 'API ' + res.status + ': ' + String((j.error && j.error.message) || '').slice(0, 300); out.terminal_reason = 'api_error'; break; }
    const u = j.usage || {};
    cost += ((u.input_tokens || 0) * PRICE.in + (u.output_tokens || 0) * PRICE.out + (u.cache_read_input_tokens || 0) * PRICE.cr + (u.cache_creation_input_tokens || 0) * PRICE.cw) / 1e6;
    msgs.push({ role: 'assistant', content: j.content });
    const txt = j.content.filter(b => b.type === 'text').map(b => b.text).join('\n'); if (txt) lastText = txt;
    if (j.stop_reason !== 'tool_use') { out.terminal_reason = j.stop_reason || 'end'; break; }
    const results = j.content.filter(b => b.type === 'tool_use').map(b => ({ type: 'tool_result', tool_use_id: b.id, content: useTool(b.name, b.input || {}) }));
    // 10-17 17:50: a helper held the lock 47 minutes with nothing to commit while two ships waited. Past 8 minutes the loop
    // gives the lock back itself and tells the helper (8 minutes, his "does it really need to be 15 mins").
    if (heldLock && Date.now() - lockAt > 8 * 60000) {
      try { spawnSync(BASH, ['-c', 'bash ' + S.replace(/\\/g, '/') + '/unlock.sh'], { cwd: R, encoding: 'utf8', timeout: 60000 }); } catch {}
      heldLock = false;
      results.push({ type: 'text', text: 'NOTE: you held the ship lock over 8 minutes, so it was released for the other workers. Commit any fixture edits with fixq.sh (it takes the lock itself), and next time prepare your edits before you take the lock.' });
    }
    msgs.push({ role: 'user', content: results });
  }
} catch (err) { out.result = 'worker error: ' + String(err && err.message || err).slice(0, 500); out.terminal_reason = 'api_error'; }
// a run that ends while still holding the lock it took would stop every ship: give it back
if (heldLock) { try { spawnSync(BASH, ['-c', 'bash ' + S.replace(/\\/g, '/') + '/unlock.sh'], { cwd: R, encoding: 'utf8', timeout: 60000 }); } catch {} }
out.total_cost_usd = Math.round(cost * 10000) / 10000;
if (!out.result) out.result = lastText.slice(-3000) + (out.terminal_reason === 'budget' ? '\nTASK PARTIAL: the run hit its budget' : out.terminal_reason === 'max_turns' ? '\nTASK PARTIAL: the run hit its turn limit' : '');
out.subtype = out.terminal_reason;
console.log(JSON.stringify(out));
