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

# ATTRACT MODE ON THE TITLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function showScreen(s){
'@ @'
// v21.17, HIS ASK (2026-10-08): "i want to record or capture myself playing somehow and then I want the game to play that when its
// idling at the first screen/char select screen -- like how old arcade games would show gameplay while no one was playing".
// ATTRACT MODE. On the title, after ATTRACT_IDLE seconds with no key, mouse or controller input, a gameplay clip plays over the
// whole screen, muted and looping, under PRESS ANY KEY. Any input stops it (that press does nothing else) and the idle clock
// starts again. The clip is the one recorded in the game (F9 in a raid, kept in this browser), or else attract.mp4 or
// attract.webm beside the game file (a clip recorded any other way, and the one an itch build ships). With neither, nothing shows.
var ATTRACT_IDLE=30, ATT={last:Date.now(),on:false,el:null,src:null,tried:false,url:null,mx:-1,my:-1};
function attTitleUp(){ var t=document.getElementById('title'); return !!(t&&t.classList.contains('on')); }
function attPoke(){ ATT.last=Date.now(); if(ATT.on) attStop(); }
function attDb(cb){
  try{ var r=indexedDB.open('pillagers-attract',1);
       r.onupgradeneeded=function(){ try{ r.result.createObjectStore('clips'); }catch(_u){} };
       r.onsuccess=function(){ cb(r.result); }; r.onerror=function(){ cb(null); }; }
  catch(e){ cb(null); }
}
function attClipGet(cb){ attDb(function(db){ if(!db) return cb(null); try{ var q=db.transaction('clips','readonly').objectStore('clips').get('main'); q.onsuccess=function(){ cb(q.result||null); }; q.onerror=function(){ cb(null); }; }catch(e){ cb(null); } }); }
function attClipPut(blob,cb){ attDb(function(db){ if(!db) return cb&&cb(false); try{ var tx=db.transaction('clips','readwrite'); tx.objectStore('clips').put(blob,'main'); tx.oncomplete=function(){ ATT.src=null; ATT.tried=false; cb&&cb(true); }; tx.onerror=function(){ cb&&cb(false); }; }catch(e){ cb&&cb(false); } }); }
function attEl(){
  if(ATT.el) return ATT.el;
  var st=document.createElement('style');
  st.textContent='#attract{position:fixed;left:0;top:0;right:0;bottom:0;z-index:9000;background:#000;display:none;cursor:none}'+
    '#attract video{width:100%;height:100%;object-fit:cover}'+
    '#attract .attpress{position:absolute;left:0;right:0;bottom:8%;text-align:center;font:800 clamp(26px,3.6vw,84px) "Rubik",system-ui,sans-serif;'+
    'letter-spacing:.08em;color:#ffc04a;text-shadow:0 3px 0 #000,0 0 24px rgba(0,0,0,.9);animation:attpulse 1.6s ease-in-out infinite}'+
    '#attract .attname{position:absolute;left:0;right:0;top:6%;text-align:center;font:800 clamp(30px,5vw,120px) "Rubik",system-ui,sans-serif;'+
    'letter-spacing:.14em;color:#f2e6c8;text-shadow:0 4px 0 #000,0 0 30px rgba(0,0,0,.9);opacity:.92}'+
    '@keyframes attpulse{0%,100%{opacity:1}50%{opacity:.35}}';
  document.head.appendChild(st);
  var d=document.createElement('div'); d.id='attract';
  d.innerHTML='<video muted loop playsinline></video><div class="attname">PILLAGERS</div><div class="attpress">PRESS ANY KEY</div>';
  document.body.appendChild(d); ATT.el=d; return d;
}
function attShow(src){
  var d=attEl(), v=d.querySelector('video');
  if(!src) return false;
  ATT.on=true; d.style.display='block';
  if(v.getAttribute('src')!==src) v.setAttribute('src',src);
  try{ var pr=v.play(); if(pr&&pr.catch) pr.catch(function(){}); }catch(e){}
  return true;
}
function attProbe(list,cb){
  if(!list.length) return cb(null);
  var t=document.createElement('video'), u=list[0], done=false;
  t.muted=true; t.preload='metadata';
  t.onloadedmetadata=function(){ if(done) return; done=true; cb(u); };
  t.onerror=function(){ if(done) return; done=true; attProbe(list.slice(1),cb); };
  t.src=u;
}
function attIdle(){ return attTitleUp()&&Date.now()-ATT.last>=ATTRACT_IDLE*1000; }
function attStart(){
  if(ATT.src) return attShow(ATT.src);
  if(ATT.tried) return false;   // looked once and found no clip; a new recording clears this
  ATT.tried=true;
  attClipGet(function(b){
    if(b){ try{ if(ATT.url) URL.revokeObjectURL(ATT.url); ATT.url=URL.createObjectURL(b); ATT.src=ATT.url; }catch(e){} }
    if(ATT.src){ if(attIdle()) attShow(ATT.src); return; }
    attProbe(['attract.mp4','attract.webm'],function(s){ ATT.src=s; if(s&&attIdle()) attShow(s); });
  });
  return false;
}
function attStop(){ ATT.on=false; if(ATT.el){ ATT.el.style.display='none'; try{ ATT.el.querySelector('video').pause(); }catch(e){} } }
function attTick(){
  var gp, i, j, a;
  try{ gp=navigator.getGamepads?navigator.getGamepads():[];
       for(i=0;gp&&i<gp.length;i++){ a=gp[i]; if(!a) continue;
         for(j=0;j<a.buttons.length;j++) if(a.buttons[j]&&a.buttons[j].pressed){ attPoke(); return; }
         for(j=0;j<a.axes.length;j++) if(Math.abs(a.axes[j])>0.45){ attPoke(); return; } } }catch(e){}
  if(!attTitleUp()){ if(ATT.on) attStop(); ATT.last=Date.now(); return; }
  if(!ATT.on&&attIdle()) attStart();
}
['keydown','mousedown','wheel','touchstart'].forEach(function(evn){
  try{ window.addEventListener(evn,function(e){
    if(ATT.on){ try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){} }   // the press that stops the clip does nothing else
    attPoke();
  },true); }catch(_ae){}
});
try{ window.addEventListener('mousemove',function(e){ if(ATT.mx<0||Math.abs(e.clientX-ATT.mx)+Math.abs(e.clientY-ATT.my)>12){ ATT.mx=e.clientX; ATT.my=e.clientY; attPoke(); } },true); }catch(_am){}
try{ setInterval(attTick,500); }catch(_ai){}
function showScreen(s){
'@

SubRx @'
var VER='21.16';
'@ @'
var VER='21.17';
'@

$pat = "(?m)^  now:'v21\.16:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.17: Leave the title screen alone for 30 seconds and a gameplay clip plays until you press a key. Check 21.17 fails on v21.16',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
