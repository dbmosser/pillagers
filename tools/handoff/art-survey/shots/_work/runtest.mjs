import fs from 'node:fs';
import { execFileSync } from 'node:child_process';
import { AS, WORK } from './lib.mjs';
const names = process.argv.slice(2);
for (const name of names) {
  const src = fs.readFileSync(AS + '/snip/' + name + '.html', 'utf8');
  const html = '<!doctype html><meta charset="utf-8"><body style="margin:0"><script>window.__errs=[];window.onerror=function(m,u,l){window.__errs.push(m+"@"+l)};</script>' + src + '<script>setTimeout(function(){var c=document.querySelector("canvas").getContext("2d"),d=c.getImageData(0,0,480,270).data,s=0,i;for(i=0;i<d.length;i+=997)s+=d[i];document.body.setAttribute("data-res","errs="+window.__errs.join("|")+" sum="+s);},1500);</script></body>';
  const hp = WORK + '/prev/rt-' + name + '.html'; fs.writeFileSync(hp, html);
  const prof = (process.env.TEMP || 'C:/Windows/Temp') + '/artrt-' + Date.now();
  let out = '';
  try { out = execFileSync('C:/Program Files/Google/Chrome/Application/chrome.exe', ['--headless=new', '--disable-gpu', '--user-data-dir=' + prof, '--allow-file-access-from-files', '--virtual-time-budget=3000', '--dump-dom', 'file:///' + hp.split(String.fromCharCode(92)).join('/')], { timeout: 60000, encoding: 'utf8' }); } catch (e) { out = 'EXC ' + e.message; }
  try { fs.rmSync(prof, { recursive: true, force: true }); } catch (e) {}
  const m = out.match(/data-res="([^"]*)"/);
  console.log(name, m ? m[1] : 'NO RESULT ' + out.slice(0, 120));
}
