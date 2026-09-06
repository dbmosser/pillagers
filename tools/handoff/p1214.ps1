$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# FIRST TEN MINUTES AUDIT, 2026-09-06: with the Undercroft backpack open, ESC
# raised the pause box instead of closing the backpack, because the backpack
# is not a modal and the pause branch runs before the backpack's own ESC
# line; a second ESC only closed the pause box. ESC could never close it.
SubRx @'
    if((e.code==='Escape'||e.code==='KeyP')&&!e.repeat&&!_titleUp&&!document.querySelector('.modal.on')&&
       !document.querySelector('.imenu')&&!document.getElementById('hub').classList.contains('on')){
      togglePauseBox(!document.getElementById('pausebox').classList.contains('on'));
      e.preventDefault(); return;
    }
'@ @'
    // v12.14: NOT OVER AN OPEN BACKPACK. The floor backpack is not a modal, so
    // ESC over it raised the pause box here and the backpack's own ESC line
    // further down could never run; a second ESC closed the pause box and the
    // backpack stayed. ESC belongs to whatever is in front, and the backpack is.
    if((e.code==='Escape'||e.code==='KeyP')&&!e.repeat&&!_titleUp&&!document.querySelector('.modal.on')&&
       !document.querySelector('.imenu')&&!document.getElementById('hub').classList.contains('on')&&
       !(e.code==='Escape'&&hubBagOpen)){
      togglePauseBox(!document.getElementById('pausebox').classList.contains('on'));
      e.preventDefault(); return;
    }
'@

# STAMPS.
SubRx @'
var VER='12.13';
'@ @'
var VER='12.14';
'@
SubRx @'
var WHATSNEW_VER='12.13';
'@ @'
var WHATSNEW_VER='12.14';
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'ESC CLOSES THE OPEN BACKPACK IN THE UNDERCROFT instead of raising the pause box over it.',
'@
$cnt=([regex]::Matches($s,"now:'v12\.13:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.13 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.13:[^']*'",{ param($m) "now:'v12.14: from the 2026-09-06 first-ten-minutes audit, ESC over the open Undercroft backpack raised the pause box instead of closing the backpack, because the backpack is not a modal and the pause branch ran first; ESC could never close it. The pause branch now steps aside while the backpack is open. Check 12.14 opens the backpack on the floor, presses ESC and requires it closed with no pause box, then presses ESC again and requires the pause box; fails on v12.13.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
