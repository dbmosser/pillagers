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

# THE KEYS WINDOW NAMES EVERY KEY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
['KeyZ','drop an item for a teammate'],['KeyO','order your hire'],['AltLeft','raid status (hold)']];
'@ @'
['KeyZ','drop an item for a teammate'],['KeyO','order your hire'],['AltLeft','raid status (hold)'],
  // v26.xx (settings11), HIS ORDER 2026-10-14 ("make sure it covers every current action"): THE KEYS THAT WERE MISSING. H (tap to heal, hold for an armour plate, v25.xx holdhplate),
  // CAPS LOCK (auto-jog), the HUD size pair, the zoom pair and the zoom reset all work in the raid and were not on the list, so none could be moved and a bind onto one
  // did not swap. They are on it now. The keys that cannot move (1 to 9, P, TAB, ESC, BACKSPACE, the key left of 1, F11) are listed at the end, locked.
  ['KeyH','heal (tap), armour plate (hold)'],['CapsLock','auto-jog'],['Equal','hud bigger'],['Minus','hud smaller'],['NumpadAdd','zoom in'],['NumpadSubtract','zoom out'],['Digit0','zoom to 100%']];
'@

SubRx @'
var KEYS_SECT=[['MOVE',['KeyW','KeyA','KeyS','KeyD','Space','ShiftLeft','ControlLeft','KeyC']],['FIGHT',['KeyR','KeyQ','KeyV','KeyF']],
'@ @'
var KEYS_SECT=[['MOVE',['KeyW','KeyA','KeyS','KeyD','Space','ShiftLeft','ControlLeft','KeyC','CapsLock']],['FIGHT',['KeyR','KeyQ','KeyV','KeyF','KeyH']],
'@

SubRx @'
  ['WORLD',['KeyE','KeyX','KeyB','KeyI','Enter','KeyM','F1','KeyO','AltLeft']],['PARTY',['KeyT','KeyZ','KeyN','Mouse1']]];
'@ @'
  ['WORLD',['KeyE','KeyX','KeyB','KeyI','Enter','KeyM','F1','KeyO','AltLeft']],['PARTY',['KeyT','KeyZ','KeyN','Mouse1']],['VIEW',['Equal','Minus','NumpadAdd','NumpadSubtract','Digit0']]];
'@

SubRx @'
function keysNoteShow(){
'@ @'
// v26.xx (settings11): THE KEYS THAT CANNOT MOVE, listed under the others so the window names every key the game answers. 1 to 9 pick a gun (the stash sets which gun is on which),
// P and TAB pause or back out, ESC closes a window, BACKSPACE puts the cursor back, the key left of 1 is Superhot and F11 is fullscreen.
var KEYS_LOCKED=[['SELECT A GUN','1 - 9'],['PAUSE','P'],['PAUSE, OR BACK OUT','TAB'],['CLOSE A WINDOW','ESC'],['PUT THE CURSOR BACK','BACKSPACE'],['SUPERHOT MODE','`'],['FULLSCREEN','F11']];
function keysFixedHtml(){
  var h='<div class="keysec">LOCKED: THESE KEEP THEIR JOBS</div>', i;
  for(i=0;i<KEYS_LOCKED.length;i++) h+='<div class="row"><div style="flex:1"><b>'+KEYS_LOCKED[i][0]+'</b></div><span class="keyfixed">'+KEYS_LOCKED[i][1]+'</span></div>';
  return h;
}
function keysNoteShow(){
'@

SubRx @'
  if(left.length){ h+='<div class="keysec">OTHER</div>'; for(i=0;i<left.length;i++) h+=keysRow1(left[i]); }
'@ @'
  if(left.length){ h+='<div class="keysec">OTHER</div>'; for(i=0;i<left.length;i++) h+=keysRow1(left[i]); }
  h+=keysFixedHtml();   // v26.xx (settings11): and the keys that cannot move
'@

SubRx @'
  #root #keyslist .keybtn.wait{ color:var(--acc-ink) !important; background:var(--acc) !important; border-color:var(--acc) !important; }
'@ @'
  #root #keyslist .keybtn.wait{ color:var(--acc-ink) !important; background:var(--acc) !important; border-color:var(--acc) !important; }
  /* v26.xx (settings11): a locked key, drawn like a key button but dashed and dim, with nothing to press. */
  #root #keyslist .keyfixed{ display:inline-flex; align-items:center; justify-content:center; min-width:120px; min-height:40px; box-sizing:border-box; padding:0 12px; border:1px dashed var(--ui-line-hi);
    border-radius:4px; color:var(--tx-3); font-family:var(--f-cond); font-weight:700; font-size:16px; letter-spacing:.08em; text-transform:uppercase; }
'@

SubRx @'
var VER='26.51';
'@ @'
var VER='26.52';
'@

$pat = "(?m)^  now:'v26\.51:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.52: The Keys window now lists every key the raid answers, and the locked ones. Check 26.52 fails on v26.51',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
