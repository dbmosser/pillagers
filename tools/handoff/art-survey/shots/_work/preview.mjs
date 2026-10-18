// preview.mjs SNIPNAME t1,t2,... [cols] : writes _work/prev/SNIPNAME.png, a contact sheet of the snippet frozen at those times (data-t on the root)
import fs from 'node:fs';
import { execFileSync } from 'node:child_process';
import { AS, WORK } from './lib.mjs';
const [name, times, colsArg] = process.argv.slice(2);
const ts = times.split(',').map(Number), cols = +(colsArg || 3);
const src = fs.readFileSync(AS + '/snip/' + name + '.html', 'utf8');
const style = src.match(/<style>[\s\S]*?<\/style>/)[0];
const script = src.match(/<script>[\s\S]*<\/script>/)[0];
const rootLine = src.split('\n').find(l => l.startsWith('<div class="' + name + '"'));
const tiles = ts.map(t => '<div style="position:relative;width:560px;height:340px">' + rootLine.replace('<div class="' + name + '"', '<div data-t="' + t + '" class="' + name + '"') + '<div style="position:absolute;right:6px;top:4px;color:#e4ff2e;font:600 14px sans-serif;z-index:5">t=' + t + '</div></div>').join('');
const rows = Math.ceil(ts.length / cols);
const html = '<!doctype html><meta charset="utf-8"><body style="margin:0;background:#222;display:grid;grid-template-columns:repeat(' + cols + ',560px);gap:6px;width:' + (cols * 566) + 'px">' + style + tiles + script + '</body>';
fs.mkdirSync(WORK + '/prev', { recursive: true });
const hp = WORK + '/prev/' + name + '.html', png = WORK + '/prev/' + name + '.png';
fs.writeFileSync(hp, html);
const prof = (process.env.TEMP || 'C:/Windows/Temp') + '/artprev-' + Date.now();
try { fs.unlinkSync(png); } catch (e) {}
try {
  execFileSync('C:/Program Files/Google/Chrome/Application/chrome.exe', ['--headless=new', '--disable-gpu', '--hide-scrollbars', '--user-data-dir=' + prof, '--allow-file-access-from-files', '--window-size=' + (cols * 566) + ',' + (rows * 346 + 20), '--force-device-scale-factor=1', '--virtual-time-budget=3000', '--screenshot=' + png, 'file:///' + hp.split(String.fromCharCode(92)).join('/')], { stdio: 'ignore', timeout: 60000 });
} catch (e) { console.log('chrome exit', e.message); }
try { fs.rmSync(prof, { recursive: true, force: true }); } catch (e) {}
console.log(fs.existsSync(png) ? 'ok ' + png : 'FAIL');
