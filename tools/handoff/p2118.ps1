$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# F9 RECORDS YOUR PLAY FOR THE TITLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function showScreen(s){
'@ @'
// v21.18, HIS ASK (2026-10-08), the other half of attract mode: "i want to record or capture myself playing somehow". THE RECORDER.
// F9 starts recording what the game draws (the world and the HUD, composed at up to 1920 wide, 30 frames a second) and F9 again
// stops it; it stops by itself after REC.max seconds. The clip is kept in this browser as the attract clip the title plays when
// nobody is playing, and a copy goes to the downloads as pillagers-attract.webm (rename it attract.webm beside the game file to
// ship it). The red REC mark is a page element, not part of the drawing, so it is never in the clip. Menus drawn as page
// elements are not in the clip either, which suits a gameplay reel.
var REC={on:false,mr:null,cv:null,cx:null,chunks:[],t0:0,raf:0,mark:null,max:180};
function recTell(s){ try{ if(typeof G!=='undefined'&&G&&!G.over&&!G.sim) say(s); else if(typeof hubToast==='function') hubToast(s); }catch(e){} }
function recMark(on){
  if(!REC.mark){
    REC.mark=document.createElement('div'); REC.mark.id='recmark';
    REC.mark.style.cssText='position:fixed;left:14px;top:14px;z-index:9001;display:none;padding:4px 10px 4px 8px;border-radius:999px;background:rgba(0,0,0,.6);'+
      'color:#ff5a4a;font:800 15px "Rubik",system-ui,sans-serif;letter-spacing:.1em;pointer-events:none';
    REC.mark.innerHTML='&#9679; REC';
    document.body.appendChild(REC.mark);
  }
  REC.mark.style.display=on?'block':'none';
}
function recDraw(){
  if(!REC.on) return;
  var c=REC.cv, x=REC.cx;
  try{
    x.fillStyle='#000'; x.fillRect(0,0,c.width,c.height);
    if(cv&&cv.width) x.drawImage(cv,0,0,c.width,c.height);
    if(hcv&&hcv.width&&hcv.style.display!=='none') x.drawImage(hcv,0,0,c.width,c.height);
  }catch(e){}
  if(Date.now()-REC.t0>REC.max*1000){ recStop(); return; }
  REC.raf=requestAnimationFrame(recDraw);
}
function recStart(){
  var w, h, mt='', o;
  if(REC.on) return false;
  if(typeof MediaRecorder==='undefined'||!HTMLCanvasElement.prototype.captureStream){ recTell('This browser cannot record the game.'); return false; }
  w=Math.min(1920,(cv&&cv.width)||1920); h=Math.round(w*(((cv&&cv.height)||1080)/((cv&&cv.width)||1920)));
  REC.cv=document.createElement('canvas'); REC.cv.width=w; REC.cv.height=h; REC.cx=REC.cv.getContext('2d');
  ['video/webm;codecs=vp9','video/webm;codecs=vp8','video/webm'].forEach(function(m){ try{ if(!mt&&MediaRecorder.isTypeSupported(m)) mt=m; }catch(_t){} });
  o={videoBitsPerSecond:3500000}; if(mt) o.mimeType=mt;
  try{ REC.mr=new MediaRecorder(REC.cv.captureStream(30),o); }catch(e){ recTell('This browser cannot record the game.'); return false; }
  REC.chunks=[];
  REC.mr.ondataavailable=function(ev){ if(ev.data&&ev.data.size) REC.chunks.push(ev.data); };
  REC.mr.onstop=recSave;
  REC.on=true; REC.t0=Date.now();
  try{ REC.mr.start(1000); }catch(e){ REC.on=false; recTell('This browser cannot record the game.'); return false; }
  recDraw(); recMark(true);
  recTell('Recording. Press F9 again to stop (it stops by itself after 3 minutes).');
  return true;
}
function recStop(){
  if(!REC.on) return false;
  REC.on=false;
  try{ cancelAnimationFrame(REC.raf); }catch(e){}
  recMark(false);
  try{ REC.mr.stop(); }catch(e){ recSave(); }
  return true;
}
function recSave(){
  var b=null, a;
  try{ b=new Blob(REC.chunks,{type:'video/webm'}); }catch(e){ b=null; }
  REC.chunks=[];
  if(!b||b.size<20000){ recTell('That recording was too short to keep.'); return; }
  attClipPut(b,function(ok){ recTell(ok?('Recording kept: it plays on the title when nobody is playing. A copy is in your downloads.'):'This browser could not keep the recording; a copy is in your downloads.'); });
  try{ a=document.createElement('a'); a.href=URL.createObjectURL(b); a.download='pillagers-attract.webm'; document.body.appendChild(a); a.click();
       setTimeout(function(){ try{ URL.revokeObjectURL(a.href); a.parentNode.removeChild(a); }catch(_r){} },5000); }catch(e){}
}
try{ window.addEventListener('keydown',function(e){ if(e.code!=='F9'||e.repeat) return; try{ e.preventDefault(); }catch(_p){} if(REC.on) recStop(); else recStart(); }); }catch(_rk){}
function showScreen(s){
'@

SubRx @'
var VER='21.17';
'@ @'
var VER='21.18';
'@

$pat = "(?m)^  now:'v21\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.18: Press F9 to record your play and F9 again to stop; the title then shows it when nobody is playing. Check 21.18 fails on v21.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
