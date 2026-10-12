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

# ARROWS AND ENTER IN THE PAUSE BOX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function raidKey(code,repeat,ev){
'@ @'
// v24.15, HIS ORDER 2026-10-12 (his #39, full controller navigation, keyboard and mouse first): THE ARROWS AND ENTER WORK THE PAUSE BOX.
// The ESC / TAB box answered only P, ESC and TAB from the keyboard, so RESUME, SETTINGS, ABANDON and END RUN were mouse or pad only:
// the title had arrows and ENTER (v15.76) and the box that comes up mid-raid had none. Now, with the box up, the first arrow press
// highlights its first button, LEFT and UP step back, RIGHT and DOWN step on (wrapping), and ENTER or SPACE presses the highlighted
// button, the same click a mouse or the pad A makes, so ABANDON still asks YES and END RUN still arms first. The note field keeps its
// own typing, since a key aimed at a text field never reaches here. Returns whether the key was taken.
function pauseKeyNav(code){
  var pb=document.getElementById('pausebox'), list, cur, ix, d;
  if(!pauseOpen||!pb||!pb.classList.contains('on')||typeof padFocusables!=='function') return false;
  list=padFocusables(pb).filter(function(el){ return el.tagName==='BUTTON'; });
  if(!list.length) return false;
  cur=(PAD.focus&&list.indexOf(PAD.focus)>=0)?PAD.focus:null;
  if(code==='Enter'||code==='NumpadEnter'||code==='Space'){ if(!cur) return false; cur.click(); return true; }
  d=(code==='ArrowLeft'||code==='ArrowUp')?-1:((code==='ArrowRight'||code==='ArrowDown')?1:0);
  if(!d) return false;
  if(!cur){ padSetFocus(list[0]); return true; }
  ix=(list.indexOf(cur)+d+list.length)%list.length;
  padSetFocus(list[ix]);
  return true;
}
function raidKey(code,repeat,ev){
'@

SubRx @'
  if(pauseOpen&&code!=='KeyP'&&code!=='Escape'&&code!=='Tab'){ if(ev) ev.preventDefault(); return; }
'@ @'
  if(pauseOpen&&code!=='KeyP'&&code!=='Escape'&&code!=='Tab'){ if(ev) ev.preventDefault(); if(!repeat){ keys[code]=false; pauseKeyNav(code); } return; }   // v24.15 (his #39): arrows and ENTER work the box
'@

SubRx @'
    if(pauseOpen&&e.code!=='KeyP'&&e.code!=='Escape'&&e.code!=='Tab'){ e.preventDefault(); return; }
'@ @'
    if(pauseOpen&&e.code!=='KeyP'&&e.code!=='Escape'&&e.code!=='Tab'){ e.preventDefault(); if(!e.repeat){ keys[e.code]=false; pauseKeyNav(e.code); } return; }   // v24.15 (his #39): arrows and ENTER work the box
'@

SubRx @'
var VER='24.14';
'@ @'
var VER='24.15';
'@

$pat = "(?m)^  now:'v24\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.15: The arrow keys and ENTER work the pause box buttons. Check 24.15 fails on v24.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
