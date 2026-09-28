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

# A CLICK IN ONE WINDOW NO LONGER SHUTS THE BACKPACK OF THE OTHER PLAYER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function releaseAllKeys(){
'@ @'
function releaseAllKeys(soft){
'@

SubRx @'
  if(G){ G.bagOpen=false; G.drag=null; }
'@ @'
  // v17.01, co-op hunt 2026-09-28: A CLICK IN ONE WINDOW NO LONGER SHUTS THE BACKPACK OF THE OTHER PLAYER. On one PC both
  // windows are played at once: the player 2 backpack is opened by its controller while the other window has focus, and the
  // host backpack by keys handed over from the player 2 window. A focus change (soft, the blur and focus listeners below) in a
  // same-machine window leaves the backpack open and keeps a controller drag; a mouse drag is still dropped, and the cursor
  // reset and a hidden tab (no soft) still close everything, as does a window played alone.
  var keepBag=!!(soft===true&&typeof NET!=='undefined'&&NET&&NET.same);
  if(G){ if(!keepBag) G.bagOpen=false; if(!(keepBag&&G.drag&&G.drag.pad)) G.drag=null; }
'@

SubRx @'
window.addEventListener('blur',releaseAllKeys);
'@ @'
window.addEventListener('blur',function(){ releaseAllKeys(true); });   // v17.01: a focus change is soft, see releaseAllKeys
'@

SubRx @'
window.addEventListener('focus',function(){ releaseAllKeys(); lastTs=performance.now(); });
'@ @'
window.addEventListener('focus',function(){ releaseAllKeys(true); lastTs=performance.now(); });
'@

SubRx @'
var VER='17.00';
'@ @'
var VER='17.01';
'@

$pat = "(?m)^  now:'v17\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.01: A CLICK IN ONE WINDOW NO LONGER SHUTS THE BACKPACK OF THE OTHER PLAYER. On one PC the player 2 backpack is opened by its controller while the other window has focus, and any click that moved focus between the windows shut it and dropped the item being moved. A focus change in a two-window game now leaves the backpack open and keeps a controller drag; a mouse drag is still dropped, and one window alone, the cursor reset key and a hidden tab still close it. Check 17.01 fails on v17.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
