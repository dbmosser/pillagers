// fetch-notes.mjs : brings his in-game notes and run reports from the MAIN PC into this VM's exports/ (coord-01, 2026-10-20).
// His process answer 14 a: "Add a fetch my notes job to the main PC link". He plays the party copy on the main PC
// (C:\claudecode\pillagers-party), so his notes (feedback-*.txt and .png) and run reports (run-*.txt) land in that copy's exports folder,
// which this VM cannot see. The main PC's minute check (tools/migrate/host-night-memory.ps1 -GameCheck, item 7) copies each new one into the
// bridge share as pcnote-NAME. This takes each pcnote- file the VM does not have yet (exports/NAME or exports/consumed-NAME) with the
// existing share-get job, checks its sha256, and writes exports/NAME. No new bridge job: only share-list and share-get.
// It never overwrites, never deletes anything on the main PC (the main PC clears its own pcnote- files after 3 days), never touches 8802.
// The runner (tools/nightly.sh) calls it every 5 minutes. It prints a line only when something arrived or failed, and always writes
// tools/handoff/notes-fetch.txt: "last fetch MM-DD HH:MM, N new (NAMES), M on the main PC side". ASCII only.
import { execFileSync } from 'node:child_process';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const R = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const EXP = path.join(R, 'exports');
const STATUS = path.join(R, 'tools', 'handoff', 'notes-fetch.txt');
const OK_NAME = /^pcnote-(feedback-[A-Za-z0-9._-]+\.(txt|png)|run-[A-Za-z0-9._-]+\.txt)$/;
const stamp = () => { const d = new Date(), p = (n) => String(n).padStart(2, '0'); return `${p(d.getMonth() + 1)}-${p(d.getDate())} ${p(d.getHours())}:${p(d.getMinutes())}`; };

function host(...args) {
  const out = execFileSync(process.execPath, [path.join(R, 'tools', 'bridge', 'hostctl.mjs'), ...args],
    { cwd: R, timeout: 120000, maxBuffer: 64 * 1024 * 1024, windowsHide: true, encoding: 'utf8' });
  return JSON.parse(out);
}

let list;
try { list = host('share-list'); } catch (e) {
  fs.writeFileSync(STATUS, `last try ${stamp()}: the main PC link did not answer (${String(e.message || e).split('\n')[0].slice(0, 120)})\n`);
  process.exit(0);   // the main PC may be asleep; try again next time, quietly
}
if (!list.ok) { fs.writeFileSync(STATUS, `last try ${stamp()}: share-list said ${JSON.stringify(list).slice(0, 160)}\n`); process.exit(0); }
fs.mkdirSync(EXP, { recursive: true });
const notes = (list.files || []).filter((f) => OK_NAME.test(f.name));
const got = [], bad = [];
for (const f of notes) {
  const name = f.name.slice('pcnote-'.length);
  if (fs.existsSync(path.join(EXP, name)) || fs.existsSync(path.join(EXP, 'consumed-' + name))) continue;
  try {
    const j = host('share-get', 'name=' + f.name);
    if (!j.ok || !j.base64) { bad.push(name + ': ' + (j.error || 'no data')); continue; }
    const buf = Buffer.from(j.base64, 'base64');
    if (j.sha256 && crypto.createHash('sha256').update(buf).digest('hex') !== j.sha256) { bad.push(name + ': checksum differs, try again'); continue; }
    const tmp = path.join(EXP, '.part-' + name);
    fs.writeFileSync(tmp, buf);
    if (fs.existsSync(path.join(EXP, name))) { fs.unlinkSync(tmp); continue; }   // never overwrite
    fs.renameSync(tmp, path.join(EXP, name));
    got.push(name);
  } catch (e) { bad.push(name + ': ' + String(e.message || e).split('\n')[0].slice(0, 100)); }
}
// 10-20 evening: the main PC's minute check writes notes=... into gaming.txt only once he has run the setup with the note copying,
// so this says whether the copying is live without asking him
let side = 'main PC copying: unknown';
if ((list.files || []).some((f) => f.name === 'gaming.txt')) {
  try { const g = host('share-get', 'name=gaming.txt'); const m = /^notes=(.*)$/m.exec(Buffer.from(g.base64 || '', 'base64').toString('utf8'));
    side = m ? 'main PC copying: ' + m[1].trim().slice(0, 120) : 'main PC copying: NOT LIVE (its setup was not run again after 10-20 17:00)'; } catch { }
}
const line = `last fetch ${stamp()}, ${got.length} new${got.length ? ' (' + got.join(', ').slice(0, 300) + ')' : ''}, ${notes.length} on the main PC side, ${side}` +
  (bad.length ? `; could not take ${bad.length}: ${bad.join('; ').slice(0, 300)}` : '');
fs.writeFileSync(STATUS, line + '\n');
if (got.length || bad.length) console.log(`${stamp().slice(6)} notes from the main PC: ${got.length} new${got.length ? ' (' + got.join(', ').slice(0, 200) + ')' : ''}${bad.length ? ', ' + bad.length + ' failed' : ''}`);
