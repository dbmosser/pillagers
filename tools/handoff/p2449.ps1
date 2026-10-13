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

# MENUS ANSWER WITH SOUND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var SND_DUCK={};
'@ @'
// v24.49, HIS ORDER 2026-10-12 (his #45, improve all sound as much as possible, punchy arcade like CoD and Fortnite): MENUS ANSWER.
// Moving through a menu, pressing a button, backing out and opening the pause box or the backpack were all silent, so a press on
// a controller or the arrow keys gave no sign it landed, where every shooter menu ticks and clicks. Now the HUD bus (never ducked
// or compressed) plays a short tick when the highlight moves, a rising click when a button is pressed, a falling one when you
// back out (CLOSE, LEAVE, BACK, ESC, TAB, B), a dull buzz on something locked, and a soft rise and fall when the pause box or the
// backpack opens and closes. The initials card ticks on each letter. A short guard stops one action from playing twice. Cosmetic
// only: no seeded draw and no game state.
var SND_UI_LAST='', SND_UI_AT=-1, SND_UI_N=0;
var SND_UI={move:{ty:'triangle',f1:2200,f2:2100,d:0.022,v:0.022},ok:{ty:'triangle',f1:660,f2:990,d:0.08,v:0.045},
  back:{ty:'triangle',f1:720,f2:440,d:0.08,v:0.04},deny:{ty:'square',f1:170,f2:140,d:0.12,v:0.03},
  open:{ty:'sine',f1:420,f2:840,d:0.12,v:0.04},close:{ty:'sine',f1:840,f2:420,d:0.1,v:0.035}};
function sndUi(kind){
  var K=SND_UI[kind], a, out, t, o, g;
  if(!K||(G&&G.sim)) return false;
  if(typeof NET==='object'&&NET&&NET.specTick) return false;
  a=ac(); if(!a) return false;
  out=sndBus('ui'); if(!out) return false;
  t=a.currentTime;
  if(t-SND_UI_AT<0.03&&t>=SND_UI_AT) return false;   // one action, one sound: a press that also shuts a window plays once
  SND_UI_LAST=kind; SND_UI_AT=t; SND_UI_N++;
  try{
    o=a.createOscillator(); g=a.createGain(); o.type=K.ty;
    o.frequency.setValueAtTime(K.f1,t); o.frequency.exponentialRampToValueAtTime(K.f2,t+K.d);
    g.gain.setValueAtTime(0.0001,t); g.gain.exponentialRampToValueAtTime(K.v,t+0.004); g.gain.exponentialRampToValueAtTime(0.0001,t+K.d);
    o.connect(g); g.connect(out); o.start(t); o.stop(t+K.d+0.02);
  }catch(e){ return false; }
  return true;
}
// A press on a menu control, read in the capture phase so every panel answers the same way: the way out falls, a locked thing buzzes.
function sndUiClick(ev){
  var t=ev&&ev.target, el=(t&&t.closest)?t.closest('button,.sectorpick,.cell,.vcell,[data-slot],.crow,.invtab,.costile,.avslot,.tag,.imenurow'):null, tx;
  if(!el) return;
  if(el.disabled||(el.classList&&(el.classList.contains('locked')||el.classList.contains('dim')))){ sndUi('deny'); return; }
  tx=String(el.textContent||'').trim();
  sndUi(/^(close|leave|back|cancel|not yet|keep my kit)/i.test(tx)?'back':'ok');
}
try{ document.addEventListener('click',sndUiClick,true); }catch(_uc){}
var SND_DUCK={};
'@

SubRx @'
function padSetFocus(el){
  var old=document.querySelector('.padfocus');
  if(old) old.classList.remove('padfocus');
  if(!el) return;
  el.classList.add('padfocus');
'@ @'
function padSetFocus(el){
  var old=document.querySelector('.padfocus');
  if(old) old.classList.remove('padfocus');
  if(!el) return;
  el.classList.add('padfocus');
  if(el!==old){ try{ sndUi('move'); }catch(_su){} }   // v24.49 (his #45): the highlight ticks as it moves
'@

SubRx @'
  pauseOpen=on;
'@ @'
  if(!!on!==!!pauseOpen){ try{ sndUi(on?'open':'close'); }catch(_su){} }   // v24.49 (his #45)
  pauseOpen=on;
'@

SubRx @'
function escCloseTopModal(){
'@ @'
// v24.49 (his #45): a window shut by ESC or TAB answers with the back sound
function escCloseTopModal(){ var _r=escCloseTopModal0(); if(_r){ try{ sndUi('back'); }catch(_su){} } return _r; }
function escCloseTopModal0(){
'@

SubRx @'
    G.bagOpen=!G.bagOpen; G.bagSel=0; G.drag=null;
'@ @'
    G.bagOpen=!G.bagOpen; G.bagSel=0; G.drag=null;
    try{ sndUi(G.bagOpen?'open':'close'); }catch(_su){}   // v24.49 (his #45)
'@

SubRx @'
function hubBagOpenSet(on){
'@ @'
function hubBagOpenSet(on){
  if(!!on!==!!hubBagOpen){ try{ sndUi(on?'open':'close'); }catch(_su){} }   // v24.49 (his #45)
'@

SubRx @'
  n.touched=1; n.at=Date.now();
'@ @'
  n.touched=1; n.at=Date.now();
  try{ sndUi(op==='next'?'ok':(op==='back'?'back':'move')); }catch(_su){}   // v24.49 (his #45): each letter ticks
'@

SubRx @'
var VER='24.48';
'@ @'
var VER='24.49';
'@

$pat = "(?m)^  now:'v24\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.49: Menus tick, click and buzz as you move, press and back out. Check 24.49 fails on v24.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
