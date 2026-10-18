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

# F2 turns Edit the words on and off from anywhere and freezes the raid while it is on (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v11.52, HIS NOTE: credits and XP shown at all times in the upper right, in
'@ @'
// v30.xx (cw-txkey), HIS ORDER (2026-10-18): "add a toggle key for text editing mode so that I can edit text at anytime e.g middle of a raid. ... ideally when I click it the game would pause too so
// whatever is on screen stays there for me to modify". F2 (the key that renames a thing in Windows) turns Edit the words on and off from anywhere: the title, the menus, the Undercroft and the middle
// of a raid. Only on this machine (DEV_LOCAL), exactly as the Settings row. ONE SETTING: the key is that row's own click (cycleGameOpt), so the row, the key, the profile and the tag cannot disagree.
// THE FREEZE: while the mode is on a live raid is paused through the one pause every other door uses (syncPause: the pause box and the tuning console make it too), so the world, the enemies, the raid
// clock, the bleed-out and every timer stand still while the screen keeps drawing exactly what it had, HUD included, for a click to find. The pause box is NOT opened (it would cover the HUD).
// In a shared raid it is the pause box rule (v16.04): this window player stands still and the world runs on for the others until every window is paused, so press F2 in each window to stop it all.
// An edge press only (a held key does not toggle twice), taken in the capture phase ahead of every other key listener, so it never reaches the game as any other action.
function devFreeze(){ return !!(DEV_LOCAL&&CFG.textEdit===1&&typeof G!=='undefined'&&G&&!G.over&&!G.sim&&state==='raid'); }
function devLetGo(){ keys={}; mouse.down=false; try{ HHOLD.arm=0; }catch(_hh){} }
function txKeyToggle(){
  if(!DEV_LOCAL) return false;
  cycleGameOpt('textEdit');   // the row's own click: the next option, the console's claim let go, applied, saved
  devLetGo();   // no key and no mouse button stays held across the switch, so nothing walks or fires when the game carries on
  try{ syncPause(); }catch(_sp){}
  try{ var _sm=document.getElementById('settingsmodal'); if(_sm&&_sm.classList.contains('on')) renderSettings(); }catch(_rs){}
  try{ txTagSync(); }catch(_tg){}
  try{ hubToast(CFG.textEdit===1?'edit words on':'edit words off'); }catch(_ht){}
  return true;
}
// The tag: a small plate top left (under SHOW FPS, clear of the upper right corner) so he knows why a click opens an editor and does not shoot. A page element, not drawn on the canvas, no pointer.
var TXTAG=null, _txTagOn=-1;
function txTagSync(){
  var on=(DEV_LOCAL&&CFG.textEdit===1)?1:0, el=TXTAG;
  if(on===_txTagOn&&(!on||(el&&el.isConnected))) return on;
  _txTagOn=on;
  if(!el||!el.isConnected){
    if(!on) return on;
    el=document.createElement('div'); el.id='txtag';
    el.style.cssText='position:fixed;left:8px;top:38px;z-index:9001;display:none;padding:2px 10px 1px 12px;background:rgba(11,12,13,.82);border:1px solid var(--ui-line-hi);color:var(--acc);font:700 14px/1.3 var(--f-cond);letter-spacing:.1em;pointer-events:none;clip-path:polygon(8px 0,100% 0,100% 100%,0 100%,0 8px)';
    el.textContent='edit words: on (f2)';
    document.body.appendChild(el); TXTAG=el;
  }
  el.style.display=on?'block':'none';
  return on;
}
(function(){
  try{
    window.addEventListener('keydown',function(e){
      if(!DEV_LOCAL||!e||e.code!=='F2') return;
      if(e.ctrlKey||e.altKey||e.metaKey||e.shiftKey) return;
      try{ if(typeof KEYS==='object'&&KEYS&&KEYS.waiting) return; }catch(_kw){}   // the Keys window is waiting for a key to bind: it says F2 keeps its own job
      try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_x){}
      if(e.repeat) return;
      try{ txKeyToggle(); }catch(_t){}
    },true);
  }catch(_e){}
})();
// v30.xx (cw-txkey): A WORD EDITED IN THE ARCADE IS KEPT. In the 2 player demo P is a sandbox copy of his profile that is never saved and is swapped for his own (ARCADE.realJs) when the demo is
// left, so a line he reworded in a demo raid was gone at the next title. The one edit (the line and its shape) is written into his own profile string as well, which that swap puts back and saves.
function txArcMirror(orig,pat){
  if(typeof ARCADE!=='object'||!ARCADE||!ARCADE.on||typeof ARCADE.realJs!=='string') return false;
  var rj=JSON.parse(ARCADE.realJs), m=txMap(), pm=txPatMap();
  if(!rj||typeof rj!=='object') return false;
  if(!rj.txt||typeof rj.txt!=='object') rj.txt={};
  if(!rj.txp||typeof rj.txp!=='object') rj.txp={};
  if(typeof m[orig]==='string') rj.txt[orig]=m[orig]; else delete rj.txt[orig];
  if(pat){ if(typeof pm[pat]==='string') rj.txp[pat]=pm[pat]; else delete rj.txp[pat]; }
  ARCADE.realJs=JSON.stringify(rj);
  return true;
}
// v11.52, HIS NOTE: credits and XP shown at all times in the upper right, in
'@

SubRx @'
function syncPause(){ if(G) G.paused=pauseOpen||tuneOpen; }
'@ @'
function syncPause(){ if(G) G.paused=pauseOpen||tuneOpen||devFreeze(); }   // v30.xx (cw-txkey): and Edit the words (devFreeze) holds a live raid still the same way
'@

SubRx @'
var KEYS_V=2, KEYS_FIXED={Escape:1,Tab:1,KeyP:1,Backspace:1,Backquote:1,F9:1,F11:1};
'@ @'
var KEYS_V=2, KEYS_FIXED={Escape:1,Tab:1,KeyP:1,Backspace:1,Backquote:1,F9:1,F11:1};
if(DEV_LOCAL) KEYS_FIXED.F2=1;   // v30.xx (cw-txkey): F2 turns Edit the words on and off on this machine, so no action can be bound to it
'@

SubRx @'
var KEYS_LOCKED=[['SELECT A GUN','1 - 9'],['PAUSE','P'],['PAUSE, OR BACK OUT','TAB'],['CLOSE A WINDOW','ESC'],['PUT THE CURSOR BACK','BACKSPACE'],['SUPERHOT MODE','LEFT OF 1'],['FULLSCREEN','F11']];
'@ @'
var KEYS_LOCKED=[['SELECT A GUN','1 - 9'],['PAUSE','P'],['PAUSE, OR BACK OUT','TAB'],['CLOSE A WINDOW','ESC'],['PUT THE CURSOR BACK','BACKSPACE'],['SUPERHOT MODE','LEFT OF 1'],['FULLSCREEN','F11']];
if(DEV_LOCAL) KEYS_LOCKED.push(['EDIT THE WORDS','F2']);   // v30.xx (cw-txkey): the Keys window names it too (this machine only)
'@

SubRx @'
  try{ syncTopRight(); }catch(_tr2){}   // v11.52: a string compare per frame, a DOM write only on change
'@ @'
  try{ syncTopRight(); }catch(_tr2){}   // v11.52: a string compare per frame, a DOM write only on change
  try{ txTagSync(); }catch(_tg){}   // v30.xx (cw-txkey): the tag that says Edit the words is on, on every screen
'@

SubRx @'
  if(G.arcade&&G.arcEnd){ var _ae=G.arcEnd;
'@ @'
  if(G._dz!==devFreeze()){ G._dz=devFreeze(); try{ syncPause(); }catch(_dz){} }   // v30.xx (cw-txkey): the Edit the words freeze starts and ends on the frame the mode does, whichever door turned it on (the key, the Settings row, a check)
  if(G.arcade&&G.arcEnd){ var _ae=G.arcEnd;
'@

SubRx @'
  TXPANY=0; for(var q in pm){ TXPANY=1; break; }
'@ @'
  try{ txArcMirror(orig,so.pat); }catch(_am){}   // v30.xx (cw-txkey): a word edited in the arcade is kept
  TXPANY=0; for(var q in pm){ TXPANY=1; break; }
'@

SubRx @'
Your wording is saved with your profile and follows the phrase everywhere it appears.',
'@ @'
Your wording is saved with your profile and follows the phrase everywhere it appears. F2 turns it on and off from anywhere, and a raid stands still while it is on.',
'@

SubRx @'
var VER='31.04';
'@ @'
var VER='31.05';
'@

$pat = "(?m)^  now:'v31\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.05: F2 turns the word editor on and off from anywhere. In a raid it freezes the game so you can click and edit any text, and F2 again carries on. Check 31.05 fails on v31.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
