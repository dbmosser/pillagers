// retarget.mjs : helper of tools/codex-lane.sh for Codex's fixture-retarget.json (RULES-codex.md step 5). ASCII only.
// It only reads files and prints lines; the lane (bash) does the locking, the rebuild, the checks and the commit.
//   node retarget.mjs plan JSON MK APPLIED [OUT]   validate the edit file against tools/mkfixture.ps1, write the result to OUT
//   node retarget.mjs jscheck HTML                 syntax check of the inline scripts of a built fixture
//   node retarget.mjs keys JSON                    the keys the edit file names (one line, space separated; empty if none or unreadable)
// plan prints lines "KEY value": STATUS ok|nothing|refused, MSG (why refused), WHY, FILEHASH, KEYS, EDIT, EDITHASH, DEL, RUN, RUNHOW.
// exit 0 for ok / nothing, 1 for refused.
import fs from 'node:fs';
import crypto from 'node:crypto';
import vm from 'node:vm';

const sha = (s) => crypto.createHash('sha256').update(s, 'utf8').digest('hex');
const nl = (s) => s.replace(/\r\n/g, '\n');
const VRE = /\{\s*v\s*:\s*['"](\d+\.\d+[a-z]*)['"]/g;      // a check starts {v:'31.09',what:...
const KEYRE = /^cw-cx-[a-z0-9][a-z0-9-]{1,40}$/;
const NUL = String.fromCharCode(0);
const LINEEND = new RegExp('\\r\\n|[\\r\\n' + String.fromCharCode(0x2028, 0x2029) + ']');   // V8 counts U+2028 and U+2029 as line ends too
const L = [];
const put = (k, v) => L.push(k + ' ' + v);
const done = (rc) => { process.stdout.write(L.join('\n') + '\n'); process.exit(rc); };
const refuse = (msgs) => { L.length = 0; put('STATUS', 'refused'); for (const m of msgs) put('MSG', m); done(1); };

// Codex on Windows may write a BOM or UTF-16; the lane's rd() does the same clean-up
function readLoose(p) {
  const b = fs.readFileSync(p);
  if (b.length > 1 && b[0] === 0xFF && b[1] === 0xFE) return b.subarray(2).toString('utf16le');
  if (b.length > 1 && b[0] === 0xFE && b[1] === 0xFF) { const c = Buffer.from(b.subarray(2)); c.swap16(); return c.toString('utf16le'); }
  let s = b.toString('utf8');
  if (s.charCodeAt(0) === 0xFEFF) s = s.slice(1);
  return s.indexOf(NUL) >= 0 ? s.split(NUL).join('') : s;
}
function versionsIn(s) { const o = []; let m; VRE.lastIndex = 0; while ((m = VRE.exec(s))) if (!o.includes(m[1])) o.push(m[1]); return o; }
function show(s) { return JSON.stringify(s.length > 70 ? s.slice(0, 70) + '...' : s).replace(/[^\x20-\x7e]/g, '?'); }

function plan(jsonPath, mkPath, appliedPath, outPath) {
  let raw;
  try { raw = readLoose(jsonPath); } catch (e) { refuse(['cannot read fixture-retarget.json: ' + e.message]); }
  const fileHash = sha(nl(raw));
  const applied = new Set();
  try { for (const ln of fs.readFileSync(appliedPath, 'utf8').split(/\r?\n/)) { const t = ln.trim().split(/\s+/); if (t[0] === 'file' || t[0] === 'edit') applied.add(t[1]); } } catch (e) { /* none yet */ }
  if (applied.has(fileHash)) { put('STATUS', 'nothing'); put('REASON', 'this exact file was applied before'); done(0); }

  let j;
  try { j = JSON.parse(raw); } catch (e) { refuse(['fixture-retarget.json is not valid JSON: ' + e.message]); }
  const errs = [];
  if (!j || typeof j !== 'object' || Array.isArray(j)) refuse(['fixture-retarget.json must be an object like {"why": "...", "keys": [...], "edits": [{"anchor": "...", "replacement": "..."}]}']);
  // "why" is only the commit message, so a file without it is not refused: the name is taken from why / reason / description / note, else a default
  let why = '';
  for (const k of ['why', 'reason', 'description', 'note']) if (!why && typeof j[k] === 'string') why = j[k].replace(/\s+/g, ' ').trim();
  const noWhy = !why;
  if (noWhy) why = 'old checks retargeted for the new build (no reason given in the file)';
  if (!Array.isArray(j.edits) || j.edits.length < 1) errs.push('"edits" must be a list with at least one {"anchor", "replacement"}');
  else if (j.edits.length > 40) errs.push('at most 40 edits per file (this one has ' + j.edits.length + ')');
  const keys = [];
  if (j.keys !== undefined) {
    if (!Array.isArray(j.keys)) errs.push('"keys" must be a list of the ship keys that depend on this retarget');
    else for (const k of j.keys) { if (typeof k === 'string' && KEYRE.test(k)) keys.push(k); else errs.push('"keys" has ' + show(String(k)) + ', which is not a key like cw-cx-name'); }
  }
  const extra = [];   // optional "run": ["31.83", ...] = more checks to run besides the ones in the replacements (for example the new ship check)
  if (j.run !== undefined) {
    if (!Array.isArray(j.run)) errs.push('"run" must be a list of check versions like "31.83"');
    else for (const v of j.run) { if (typeof v === 'string' && /^\d+\.\d+[a-z]*$/.test(v)) extra.push(v); else errs.push('"run" has ' + show(String(v)) + ', which is not a check version like 31.83'); }
  }
  if (errs.length) refuse(errs);

  let mkBuf, mk;
  try { mkBuf = fs.readFileSync(mkPath); mk = mkBuf.toString('utf8'); } catch (e) { refuse(['cannot read tools/mkfixture.ps1: ' + e.message]); }
  if (!Buffer.from(mk, 'utf8').equals(mkBuf)) refuse(['tools/mkfixture.ps1 is not clean UTF-8: the lane will not rewrite it']);
  const eol = mk.indexOf('\r\n') >= 0 ? '\r\n' : '\n';
  const fix = (s) => (eol === '\r\n' ? nl(s).replace(/\n/g, '\r\n') : nl(s));

  const E = [];   // the edits that are still to do
  let zero = false;
  j.edits.forEach((e, i) => {
    const n = i + 1;
    if (!e || typeof e.anchor !== 'string' || typeof e.replacement !== 'string') { errs.push('edit ' + n + ': needs "anchor" and "replacement" as strings (replacement may be "" to delete)'); return; }
    const anchor = fix(e.anchor), repl = fix(e.replacement), h = sha(nl(e.anchor) + NUL + nl(e.replacement));
    if (applied.has(h)) { put('EDIT', n + ' state=applied-before'); return; }
    if (!anchor.trim()) { errs.push('edit ' + n + ': the anchor is empty'); return; }
    if (anchor === repl) { errs.push('edit ' + n + ': the replacement equals the anchor, so it changes nothing'); return; }
    const bad = repl.match(/[^\x00-\x7f]/);
    if (bad) { errs.push('edit ' + n + ': the replacement has a non-ASCII character (code ' + bad[0].charCodeAt(0) + '); Windows PowerShell 5.1 misreads it. Write ASCII only, use \\u escapes inside the JS'); return; }
    let c = 0, pos = -1, p = -1;
    while ((p = mk.indexOf(anchor, p + 1)) >= 0) { if (c === 0) pos = p; c++; if (c > 5) break; }
    if (c !== 1) {
      errs.push('edit ' + n + ': the anchor occurs ' + (c > 5 ? 'more than 5' : c) + ' times in tools/mkfixture.ps1 and must occur exactly once ' + show(e.anchor)
        + (c === 0 && repl && mk.indexOf(repl) >= 0 ? ' (its replacement text is already in the file: was this edit applied already? then remove it from the file)' : ''));
      if (c === 0) zero = true;
      return;
    }
    E.push({ n, anchor, repl, pos, h, vs: versionsIn(anchor) });
  });
  if (zero) errs.push('copy each anchor from the CURRENT tools/mkfixture.ps1 (the lane refreshes your workspace to master before every run, and other helpers edit that file): every character must match, line breaks included');
  if (errs.length) refuse(errs);
  if (!E.length) { put('STATUS', 'nothing'); put('REASON', 'every edit in this file was applied before'); done(0); }

  E.sort((a, b) => a.pos - b.pos);
  for (let i = 1; i < E.length; i++) if (E[i].pos < E[i - 1].pos + E[i - 1].anchor.length) errs.push('edits ' + E[i - 1].n + ' and ' + E[i].n + ' overlap: merge them into one edit');
  if (errs.length) refuse(errs);

  const parts = []; let at = 0, shift = 0;
  for (const e of E) { parts.push(mk.slice(at, e.pos), e.repl); e.npos = e.pos + shift; shift += e.repl.length - e.anchor.length; at = e.pos + e.anchor.length; }
  parts.push(mk.slice(at));
  const out = parts.join('');
  // the whole fixture is ONE powershell here-string: its two marker lines must stay exactly where they are, once each
  const cnt = (s, re) => (s.match(re) || []).length;
  for (const re of [/^'@/gm, /@'[ \t]*$/gm]) if (cnt(mk, re) !== cnt(out, re)) { refuse(['the edit changes the here-string markers of tools/mkfixture.ps1 (a line starting with \'@ or ending with @\'): that would break the whole fixture']); }

  // which checks to run: the versions named in a replacement; a replacement with none (a fragment inside a check) uses the check it sits in
  const run = [], how = {};
  for (const e of E) {
    let vs = versionsIn(e.repl), w = 'repl';
    if (!vs.length && e.repl.trim()) {
      const before = out.slice(Math.max(0, e.npos - 400000), e.npos);
      const last = [...before.matchAll(VRE)].pop(); vs = last ? [last[1]] : []; w = 'enclosing';
    }
    for (const v of vs) if (!run.includes(v)) { run.push(v); how[v] = w; }
  }
  for (const v of extra) if (!run.includes(v)) { run.push(v); how[v] = 'listed'; }
  run.sort((a, b) => parseFloat(a) - parseFloat(b));
  const gone = [];
  for (const e of E) for (const v of e.vs) if (!run.includes(v) && !gone.includes(v)) gone.push(v);

  if (outPath) fs.writeFileSync(outPath, out, 'utf8');
  put('STATUS', 'ok');
  put('WHY', why.slice(0, 300));
  if (noWhy) put('WARN', 'the file has no "why" (one plain sentence for the commit message); the lane used a default');
  put('FILEHASH', fileHash);
  put('KEYS', keys.join(' '));
  for (const e of [...E].sort((x, y) => x.n - y.n)) { put('EDIT', e.n + ' anchors=1 chars=' + e.anchor.length + '->' + e.repl.length + ' state=new'); put('EDITHASH', e.h); }
  put('DEL', gone.join(' '));
  put('RUN', run.join(' '));
  for (const v of run) put('RUNHOW', v + ' ' + how[v]);
  put('NEWSIZE', Buffer.byteLength(out, 'utf8') + ' (was ' + mkBuf.length + ')');
  done(0);
}

function jscheck(htmlPath) {
  const h = fs.readFileSync(htmlPath, 'utf8');
  const re = /<script\b([^>]*)>([\s\S]*?)<\/script>/gi;
  let m, n = 0, chars = 0;
  while ((m = re.exec(h))) {
    if (/\bsrc\s*=/i.test(m[1]) || /type\s*=\s*["']?(?!text\/javascript|application\/javascript)/i.test(m[1])) continue;
    n++; chars += m[2].length;
    try { new vm.Script(m[2], { filename: 'script' + n }); }
    catch (e) {
      const st = String(e.stack || e.message).split('\n');
      const ln = /^script\d+:(\d+)/.exec(st[0]); const lineNo = ln ? +ln[1] : 0;
      const lines = m[2].split(LINEEND); let near = '';
      for (let i = Math.min(lineNo, lines.length) - 1; i >= 0 && !near; i--) { VRE.lastIndex = 0; const q = VRE.exec(lines[i]); if (q) near = q[1]; }
      const msg = (st.find((x) => /Error:/.test(x)) || e.message).replace(/[^\x20-\x7e]/g, '?');
      put('JS', 'bad: ' + msg + ' (script ' + n + ' line ' + lineNo + (near ? ', nearest check above it v' + near : '') + '): ' + (st[1] || '').replace(/[^\x20-\x7e]/g, '?').trim().slice(0, 200));
      done(1);
    }
  }
  if (!n) { put('JS', 'bad: no inline script found in ' + htmlPath); done(1); }
  put('JS', 'ok: ' + n + ' inline script(s), ' + chars + ' chars compile'); done(0);
}

const [cmd, a, b, c, d] = process.argv.slice(2);
if (cmd === 'plan' && a && b && c) plan(a, b, c, d);
else if (cmd === 'jscheck' && a) jscheck(a);
else if (cmd === 'keys' && a) { let k = []; try { const j = JSON.parse(readLoose(a)); if (Array.isArray(j.keys)) k = j.keys.filter((x) => typeof x === 'string' && KEYRE.test(x)); } catch (e) { /* the plan refuses it */ } process.stdout.write(k.join(' ') + '\n'); }
else { process.stderr.write('usage: node retarget.mjs plan JSON MK APPLIED [OUT] | jscheck HTML | keys JSON\n'); process.exit(2); }
