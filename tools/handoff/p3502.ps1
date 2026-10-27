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

# FULLSCREEN GATE AND GO FULLSCREEN BUTTONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var W=0,H=0,DPR=1,DPRH=1;   // v23.xx (gfx4): DPRH is the HUD canvas ratio (the screen's own, capped at 2); DPR is the world's, with the render scale in it
'@ @'
var W=0,H=0,DPR=1,DPRH=1;   // v23.xx (gfx4): DPRH is the HUD canvas ratio (the screen's own, capped at 2); DPR is the world's, with the render scale in it
// v35.02 (cw-fsgate), HIS ORDER (2026-10-27): "make it so the game can ONLY be played in fullscreen mode or player has to hold the mouse
// down for 5 seconds to confirm that they are not in fullscreen and understand that this may cause glitches -- make this an autopause
// screen that pops any time they exit fullscreen". FSG is that gate (fsGateShow, beside applyMenuZoom). These listeners are the first on
// the window, so while the gate is up no key or click reaches the game: Enter or Space goes fullscreen (a key press is a gesture the
// browser accepts), F11 passes on to the game's own F11 toggle, and anything aimed outside the gate stops here. The windowed choice
// (FSG.ok) is never saved: it lasts until fullscreen is next left.
var FSG={open:0,ok:0,force:0,why:'start',was:0,hold:0,mq:null};
try{
  window.addEventListener('keydown',function(ev){
    if(!FSG.open||!ev) return;
    try{ attPoke(); }catch(_ap){}
    if(ev.code==='F11') return;
    ev.preventDefault(); ev.stopImmediatePropagation();
    if((ev.code==='Enter'||ev.code==='NumpadEnter'||ev.code==='Space')&&!ev.repeat){ try{ fsGateGo(); }catch(_fg){} }
  },true);
  ['mousedown','mouseup','click','dblclick','contextmenu','wheel','touchstart'].forEach(function(evn){
    window.addEventListener(evn,function(ev){
      if(!FSG.open||!ev) return;
      try{ attPoke(); }catch(_ap){}
      var t=ev.target;
      if(t&&t.closest&&t.closest('#fsgate')) return;
      ev.stopImmediatePropagation();
    },true);
  });
}catch(_fsgl){}
'@

SubRx @'
  #root #pausebox #charselbtn, #root #pausebox #arcendbtn{ min-height:48px;
'@ @'
  #root #pausebox #charselbtn, #root #pausebox #arcendbtn, #root #pausebox #pausefsbtn{ min-height:48px;
'@

SubRx @'
    <button id="resumebtn" style="padding:8px 22px">Resume run</button>
'@ @'
    <button id="resumebtn" style="padding:8px 22px">Resume run</button>
    <!-- v35.02 (cw-fsgate), HIS ORDER (2026-10-27): "also add a 'go fullscreen' button on the pause menu". Shown only while windowed (fsPauseBtnSync) -->
    <button id="pausefsbtn" style="padding:8px 22px">go fullscreen</button>
'@

SubRx @'
syncPause=function(){ _mapFirstSync0(); if(mapFirstOn()) G.paused=true; };
'@ @'
syncPause=function(){ _mapFirstSync0(); if(mapFirstOn()) G.paused=true; };
var _fsg0=syncPause;   // v35.02 (cw-fsgate): the fullscreen gate holds this window paused, like the pause box
syncPause=function(){ _fsg0(); if(FSG.open&&G) G.paused=true; };
'@

SubRx @'
function padOpenModal(){
'@ @'
function padOpenModal(){
  if(FSG.open){ var _fg=document.getElementById('fsgate'); if(_fg) return _fg; }   // v35.02 (cw-fsgate): the fullscreen gate is over everything
'@

SubRx @'
    var _lbb=document.getElementById('lbbtn'); if(_lbb) _lbb.style.display=(_inRaid||_bleed||_arcP)?'none':'';   // v27.NN (cboard4): the LEADERBOARD button is the floor's
'@ @'
    var _lbb=document.getElementById('lbbtn'); if(_lbb) _lbb.style.display=(_inRaid||_bleed||_arcP)?'none':'';   // v27.NN (cboard4): the LEADERBOARD button is the floor's
    try{ fsPauseBtnSync(); }catch(_pfs){}   // v35.02 (cw-fsgate): go fullscreen shows only while windowed
'@

SubRx @'
function attIdle(){ return attTitleUp()&&Date.now()-ATT.last>=ATTRACT_IDLE*1000; }
'@ @'
function attIdle(){ if(FSG.open) return false; return attTitleUp()&&Date.now()-ATT.last>=ATTRACT_IDLE*1000; }   // v35.02 (cw-fsgate): no attract clip over the fullscreen gate
'@

SubRx @'
  try{ txTagSync(); }catch(_tg){}   // v30.xx (cw-txkey): the tag that says Edit the words is on, on every screen
'@ @'
  try{ txTagSync(); }catch(_tg){}   // v30.xx (cw-txkey): the tag that says Edit the words is on, on every screen
  try{ fsRaidBtnSync(); }catch(_fsr){}   // v35.02 (cw-fsgate): the fullscreen gate watch and the raid screen go fullscreen button
'@

SubRx @'
  if(!ARCADE.on||ARCADE.role!=='host') return false;
'@ @'
  if(!ARCADE.on||ARCADE.role!=='host') return false;
  if(FSG.open) return false;   // v35.02 (cw-fsgate): nobody drops in under the fullscreen gate
'@

SubRx @'
  if(!arcadeBenched()) return false;
'@ @'
  if(!arcadeBenched()) return false;
  if(FSG.open) return false;   // v35.02 (cw-fsgate)
'@

SubRx @'
function applyMenuZoom(){
'@ @'
// v35.02 (cw-fsgate), HIS ORDER (2026-10-27), the rest of it: "make this compatible with 2 player mode also. also make a similar screen
// pop at the beginning of the game that forces fullscreen or a 5 second confirm that they are not in fullscreen -- and also tells them
// not to hit esc because it will leave fullscreen, use tab instead" and "also add a 'go fullscreen' button on the pause menu, and also one
// inside the main raid HUD that only shows up when player isn't fullscreened. ALso on the beginning screen, note for player to hit F11
// any time to fullscreen on Chrome." One gate, two reasons: start (the page opened windowed) and lost (fullscreen was left). It pauses
// this window only (syncPause), so in 2P the other window plays on, as it does under the pause box. A test page (window.__isFixture)
// never sees it unless a check sets FSG.force; a browser that cannot go fullscreen here (no API, an iframe without leave) never does.
function fsFull(){
  if(fsOn()) return true;
  try{ if(!FSG.mq&&window.matchMedia) FSG.mq=window.matchMedia('(display-mode: fullscreen)'); if(FSG.mq&&FSG.mq.matches) return true; }catch(_mm){}
  try{ var sc=window.screen; if(sc&&sc.width>0&&sc.height>0&&window.innerWidth>=sc.width-1&&window.innerHeight>=sc.height-1) return true; }catch(_sz){}   // the browser's own F11, when the key never reached the page
  return false;
}
// requestFullscreen answers with a promise. A refusal (no gesture: a pad press) must never reach the crash catcher, so it is caught here.
function fsGateGo(){
  try{
    var el=document.documentElement, rq=el.requestFullscreen||el.webkitRequestFullscreen||el.mozRequestFullScreen||el.msRequestFullscreen;
    if(!rq) return false;
    var pr=rq.call(el); if(pr&&pr.catch) pr.catch(function(){});
    return true;
  }catch(_rq){ return false; }
}
function fsGateWant(){
  return !!((FSG.force||!window.__isFixture)&&fsCan()&&document.fullscreenEnabled!==false&&!FSG.ok&&!fsFull());
}
function fsGateBuild(){
  var g=document.getElementById('fsgate'); if(g) return g;
  g=document.createElement('div'); g.id='fsgate';
  g.style.cssText='position:fixed;inset:0;z-index:30000;display:none;align-items:center;justify-content:center;background:rgba(5,6,7,.9);font-family:var(--f-cond,sans-serif);color:var(--tx-1,#efe9dc);user-select:none;-webkit-user-select:none';
  var ln='font-size:19px;letter-spacing:.04em;color:var(--tx-2,#aaa498);margin-top:12px';
  var ky='display:inline-block;min-width:36px;padding:3px 8px;margin:0 4px;border:1px solid var(--tx-3,#7a766e);border-radius:3px;color:var(--tx-1,#efe9dc);font-weight:700';
  g.innerHTML=
    '<div style="box-sizing:border-box;width:min(560px,calc(100vw - 32px));padding:34px 36px 28px;background:var(--ui-void,#0b0c0d);border:1px solid var(--ui-line-hi,#3a3f44);border-top:3px solid var(--acc,#e6ff3d);border-radius:4px;box-shadow:0 18px 60px rgba(0,0,0,.6);text-align:center">'+
      '<div id="fsgtitle" style="font-size:42px;font-weight:700;letter-spacing:.03em;line-height:1;color:var(--tx-1,#efe9dc)">play fullscreen</div>'+
      '<button id="fsggo" type="button" style="display:block;box-sizing:border-box;width:100%;min-height:60px;margin:26px 0 4px;padding:0 20px;background:var(--acc,#e6ff3d);border:1px solid var(--acc,#e6ff3d);border-radius:3px;color:var(--acc-ink,#11150a);font:700 26px/1 var(--f-cond,sans-serif);letter-spacing:.08em;cursor:pointer">go fullscreen</button>'+
      '<div style="'+ln+'"><span style="'+ky+'">f11</span> any time on chrome</div>'+
      '<div style="'+ln+'"><span style="'+ky+'">esc</span> leaves fullscreen. pause with <span style="'+ky+'">tab</span></div>'+
      '<div id="fsgpad" style="'+ln+';display:none">pad: click or <span style="'+ky+'">f11</span></div>'+
      '<button id="fsghold" type="button" style="position:relative;display:block;box-sizing:border-box;width:100%;min-height:48px;margin:30px 0 0;padding:0 16px;overflow:hidden;background:var(--ui-raised,#1e2225);border:1px solid var(--tx-3,#7a766e);border-radius:3px;color:var(--tx-2,#aaa498);font:600 19px/1 var(--f-cond,sans-serif);letter-spacing:.06em;cursor:pointer;touch-action:none">'+
        '<span id="fsgfill" style="position:absolute;left:0;top:0;bottom:0;width:0%;background:rgba(230,255,61,.24)"></span>'+
        '<span style="position:relative">hold 5s to play windowed</span></button>'+
      '<div style="font-size:16px;letter-spacing:.04em;color:var(--tx-3,#7a766e);margin-top:8px">may cause glitches</div>'+
    '</div>';
  document.body.appendChild(g);
  var go=document.getElementById('fsggo'), hold=document.getElementById('fsghold');
  if(go) go.addEventListener('click',function(ev){ if(ev) ev.stopPropagation(); fsGateGo(); });
  if(hold){
    hold.addEventListener('pointerdown',function(ev){
      if(!ev||(ev.button!==undefined&&ev.button!==0)) return;
      ev.preventDefault();
      try{ hold.setPointerCapture(ev.pointerId); }catch(_pc){}
      fsGateHoldStop();
      var t0=performance.now();
      FSG.hold=setInterval(function(){
        var p=Math.min(1,(performance.now()-t0)/5000), f=document.getElementById('fsgfill');
        if(f) f.style.width=(p*100).toFixed(1)+'%';
        if(p>=1) fsGateWindowed();
      },50);
    });
    ['pointerup','pointercancel','lostpointercapture'].forEach(function(n){ hold.addEventListener(n,function(){ fsGateHoldStop(); }); });
  }
  return g;
}
function fsGateHoldStop(){
  if(FSG.hold){ clearInterval(FSG.hold); FSG.hold=0; }
  var f=document.getElementById('fsgfill'); if(f) f.style.width='0%';
}
// The 5 s hold: this window plays windowed until fullscreen is next left. Nothing is written to storage, so it asks again every time.
function fsGateWindowed(){ fsGateHoldStop(); FSG.ok=1; return fsGateHide(); }
function fsGateClear(){
  try{ for(var k in keys) delete keys[k]; }catch(_k){}
  try{ mouse.down=false; }catch(_m){}
}
function fsGateShow(why){
  var g=fsGateBuild(); if(!g) return false;
  FSG.why=(why==='lost')?'lost':'start';
  var t=document.getElementById('fsgtitle'); if(t) t.textContent=(FSG.why==='lost')?'fullscreen lost':'play fullscreen';
  var pl=document.getElementById('fsgpad');
  if(pl){ var pads=0; try{ var gp=navigator.getGamepads?navigator.getGamepads():[]; for(var i=0;i<gp.length;i++) if(gp[i]) pads++; }catch(_gp){} pl.style.display=pads?'':'none'; }
  fsGateHoldStop();
  FSG.open=1; g.style.display='flex';
  fsGateClear();
  try{ syncPause(); }catch(_sp){}
  try{ var rb=document.getElementById('raidfsbtn'); if(rb) rb.style.display='none'; }catch(_rb){}
  return true;
}
function fsGateHide(){
  var g=document.getElementById('fsgate'), was=FSG.open;
  fsGateHoldStop();
  FSG.open=0;
  if(g) g.style.display='none';
  if(!was) return false;
  fsGateClear();
  try{ syncPause(); }catch(_sp){}
  // Back from a lost gate in a live raid: land on the pause menu and resume with tab, never straight into the fight.
  if(FSG.why==='lost'&&state==='raid'&&typeof G!=='undefined'&&G&&!G.over&&!pauseOpen){ try{ togglePauseBox(true); }catch(_tp){} }
  try{ fsPauseBtnSync(); }catch(_pb){}
  return true;
}
function fsPauseBtnSync(){
  var b=document.getElementById('pausefsbtn'); if(!b) return false;
  var on=!fsFull()&&fsCan()&&document.fullscreenEnabled!==false;
  b.style.display=on?'':'none';
  return on;
}
// Every frame (the loop) and on every fullscreenchange: catch the edges, the browser's own F11 too (it fires no event in the page).
function fsGateTick(){
  var on=fsFull()?1:0;
  if(on){ FSG.ok=0; if(FSG.open) fsGateHide(); }
  else if(FSG.was&&!FSG.open&&fsGateWant()) fsGateShow('lost');
  if(on!==FSG.was){ FSG.was=on; try{ fsPauseBtnSync(); }catch(_pb){} }
  return on;
}
// The raid screen button: a live raid, windowed, nothing over the fight. It sits left of the score plate at the top edge.
function fsRaidBtnSync(){
  var on=fsGateTick();
  if(FSG.open&&typeof G!=='undefined'&&G&&!G.paused) G.paused=true;   // a 2P raid the host starts builds a fresh G under the gate
  var b=document.getElementById('raidfsbtn');
  var want=!on&&!FSG.open&&state==='raid'&&typeof G!=='undefined'&&G&&!G.over&&!G.paused&&!G.mapOpen&&!G.bagOpen&&!G.trade&&fsCan()&&document.fullscreenEnabled!==false&&(FSG.force||!window.__isFixture);
  if(want){ try{ if(padOpenModal()) want=false; }catch(_pm){} }
  if(!want){ if(b&&b.style.display!=='none') b.style.display='none'; return false; }
  if(!b){
    b=document.createElement('button'); b.id='raidfsbtn'; b.type='button'; b.textContent='go fullscreen';
    b.style.cssText='position:fixed;z-index:34;display:none;box-sizing:border-box;min-height:0;padding:7px 14px;background:rgba(11,12,13,.82);border:1px solid var(--acc,#e6ff3d);border-radius:3px;color:var(--acc,#e6ff3d);font:700 15px/1 var(--f-cond,sans-serif);letter-spacing:.06em;cursor:pointer;white-space:nowrap';
    b.addEventListener('click',function(ev){ if(ev){ ev.stopPropagation(); ev.preventDefault(); } fsGateGo(); });
    b.addEventListener('mousedown',function(ev){ if(ev) ev.stopPropagation(); });
    document.body.appendChild(b);
  }
  var r=cv.getBoundingClientRect(), sx=(W>0)?r.width/W:1, sy=(H>0)?r.height/H:1, left, tf, top=Math.round(r.top+8*sy);
  if(SCOREBOX.g===G&&SCOREBOX.w>0){ left=Math.round(r.left+(SCOREBOX.x-12)*sx); tf='translateX(-100%)'; }
  else { left=Math.round(r.left+(W/2)*sx); tf='translateX(-50%)'; }
  var lp=left+'px', tp=top+'px';
  if(b.style.left!==lp) b.style.left=lp;
  if(b.style.top!==tp) b.style.top=tp;
  if(b.style.transform!==tf) b.style.transform=tf;
  if(b.style.display!=='') b.style.display='';
  return true;
}
try{ var _pfb=document.getElementById('pausefsbtn'); if(_pfb) _pfb.onclick=function(ev){ if(ev) ev.stopPropagation(); fsGateGo(); }; }catch(_pfw){}
var _fsSync0=fsSync;
fsSync=function(){ try{ _fsSync0(); }catch(_s0){} try{ fsGateTick(); }catch(_gt){} };
// The start gate waits one turn: a test page marks itself (window.__isFixture) after this script has run.
setTimeout(function(){ try{ FSG.was=fsFull()?1:0; if(fsGateWant()) fsGateShow('start'); }catch(_gs){} },0);
function applyMenuZoom(){
'@

SubRx @'
var VER='35.01';
'@ @'
var VER='35.02';
'@

$pat = "(?m)^  now:'v35\.01:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.02: Play fullscreen or hold 5 s for windowed; the gate returns whenever fullscreen is left. Check 35.02 fails on v35.01',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
