// serve.mjs : the spare PC's test server (2026-10-20, his spare PC answer "16gb ram, it can stay on and connected").
// Serves one folder (tools\ of the spare PC's game copy) to this PC only: it listens on 127.0.0.1 and ::1, never on the network card, so
// Windows asks no firewall question. The full test run (corpq.sh) opens http://localhost:8806/fxcorpus.html and the robots (fuzz.ps1)
// probe 8803 to 8810 for their copy, the same addresses the VM uses. GET and HEAD only, Content-Length always set (the robots read it),
// no caching, nothing outside the folder. Never port 8802.
// Usage: node tools\spare\serve.mjs --root "C:\claudecode\dark raiders\tools" --port 8806
import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';

const arg = (k, d) => { const i = process.argv.indexOf('--' + k); return i > 0 ? process.argv[i + 1] : d; };
const ROOT = path.resolve(arg('root', path.join(process.cwd(), 'tools')));
const PORT = +arg('port', 8806);
if (PORT === 8802 || !(PORT > 1024 && PORT < 65536)) { console.error('refusing port ' + PORT); process.exit(2); }
const TYPES = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.mjs': 'text/javascript', '.css': 'text/css',
  '.json': 'application/json', '.png': 'image/png', '.jpg': 'image/jpeg', '.webp': 'image/webp', '.svg': 'image/svg+xml', '.txt': 'text/plain' };

function handle(req, res) {
  if (req.method !== 'GET' && req.method !== 'HEAD') { res.writeHead(405); res.end(); return; }
  let rel;
  try { rel = decodeURIComponent(new URL(req.url, 'http://x').pathname).replace(/^\/+/, ''); } catch { res.writeHead(400); res.end(); return; }
  if (!rel) rel = 'fixture.html';
  const file = path.resolve(ROOT, rel);
  if (file !== ROOT && !file.startsWith(ROOT + path.sep)) { res.writeHead(403); res.end(); return; }
  fs.stat(file, (e, st) => {
    if (e || !st.isFile()) { res.writeHead(404); res.end(); return; }
    res.writeHead(200, { 'Content-Type': TYPES[path.extname(file).toLowerCase()] || 'application/octet-stream',
      'Content-Length': st.size, 'Cache-Control': 'no-store' });
    if (req.method === 'HEAD') { res.end(); return; }
    const s = fs.createReadStream(file); s.on('error', () => res.destroy()); s.pipe(res);
  });
}

let up = 0;
for (const host of ['127.0.0.1', '::1']) {
  const srv = http.createServer(handle);
  srv.on('error', (e) => { if (host === '127.0.0.1') { console.error('could not listen on ' + host + ':' + PORT + ' (' + e.code + ')'); process.exit(1); } });
  srv.listen(PORT, host, () => { up++; console.log('serving ' + ROOT + ' on ' + host + ':' + PORT); });
}
setTimeout(() => { if (!up) process.exit(1); }, 5000);
