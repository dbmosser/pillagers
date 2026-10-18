// balance.mjs : the REAL Console spend, read from Anthropic's cost report (2026-10-18, his "can't you make it so they pull the
// actual number instead of guessing??" after the helpers' price estimate ran 1.76x high and they stopped with $89.92 still left).
// His usual key may not read billing (403), so this needs an Admin key that HE creates and stores in the Windows user variable
// PILLAGERS_ADMIN_KEY (read here, never printed). Writes tools/handoff/console/real-spend.json:
//   { month, month_usd, today_usd, at } ; console-lane.sh and the dashboard use it instead of the estimate when it is fresh.
// Usage: node tools/console-sdk/balance.mjs   (prints the JSON, or why it could not)
import { writeFileSync } from 'fs';
import { spawnSync } from 'child_process';
const C = 'C:/claudecode/dark raiders/tools/handoff/console';
const key = spawnSync('powershell', ['-NoProfile', '-Command', "[Environment]::GetEnvironmentVariable('PILLAGERS_ADMIN_KEY','User')"], { encoding: 'utf8', windowsHide: true }).stdout.trim();
if (!key) { console.log('NO ADMIN KEY: the Windows user variable PILLAGERS_ADMIN_KEY is not set'); process.exit(2); }
const now = new Date(), month = now.toISOString().slice(0, 7), today = now.toISOString().slice(0, 10);
let url = 'https://api.anthropic.com/v1/organizations/cost_report?starting_at=' + month + '-01T00:00:00Z&bucket_width=1d&limit=31', cents = 0, todayC = 0;
for (let page = 0; page < 10 && url; page++) {
  const r = await fetch(url, { headers: { 'x-api-key': key, 'anthropic-version': '2023-06-01' } });
  const j = await r.json().catch(() => ({}));
  if (!r.ok) { console.log('COST REPORT ' + r.status + ': ' + String(j.error && j.error.message).slice(0, 200)); process.exit(1); }
  for (const b of j.data || []) for (const x of b.results || []) { const a = parseFloat(x.amount) || 0; cents += a; if (String(b.starting_at).slice(0, 10) === today) todayC += a; }
  url = j.has_more && j.next_page ? 'https://api.anthropic.com/v1/organizations/cost_report?starting_at=' + month + '-01T00:00:00Z&bucket_width=1d&limit=31&page=' + encodeURIComponent(j.next_page) : '';
}
// the cost report gives amounts in cents (lowest currency unit)
const out = { month, month_usd: Math.round(cents) / 100, today_usd: Math.round(todayC) / 100, at: now.toISOString() };
writeFileSync(C + '/real-spend.json', JSON.stringify(out));
console.log(JSON.stringify(out));
