$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new, [int]$want = 1) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne $want) { throw "regex matched $c times, wanted ${want}: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# HIS QUESTION OF 2026-09-13: reduce the viewport for itch. The recommended embed is
# 1280x720, and the menus never shrank below their 1080p size: titleRes was floored at 1
# and his menu size (1.3 by default) multiplied on top, so a 720p window drew the
# Undercroft at 1.2 times a layout built for 1080p. Built under rulebook rule 1 on the
# default: below 1080p the menus fit the screen. At 1080p and above nothing changes.
SubRx @'
  return clamp(Math.min(W/1920,H/1080),1,1.9);
'@ @'
  return clamp(Math.min(W/1920,H/1080),0.5,1.9);   // v13.46: below 1080p it shrinks, down to half
'@
SubRx @'
function titleRes(){
'@ @'
// v13.46, HIS ITCH WINDOW: THE ONE SCALE FOR MENUS. At 1080p and above it is his menu
// size times the screen factor, as before. Below 1080p it is the screen factor alone,
// so a 1280x720 embed shows the whole 1080p layout scaled to fit instead of a layout
// 1.2 times too big for the window.
function menuScale(){
  var tr=titleRes();
  return tr<1?tr:Math.max(1,(P&&P.menuZoom)||1)*tr;
}
function titleRes(){
'@
SubRx @'
  var _mz=Math.max(1,(P&&P.menuZoom)||1)*titleRes();
'@ @'
  var _mz=menuScale();   // v13.46
'@ 2
SubRx @'
  var _sf=z*titleRes();
'@ @'
  var _sf=menuScale();   // v13.46: below 1080p the menus fit the screen
'@
SubRx @'
    var _want=z*titleRes(), _col=
'@ @'
    var _want=menuScale(), _col=
'@
SubRx @'
g.style.zoom=Math.max(1,(P&&P.menuZoom)||1)*titleRes();
'@ @'
g.style.zoom=menuScale();
'@
SubRx @'
var VER='13.45';
'@ @'
var VER='13.46';
'@

$pat = "(?m)^  now:'v13\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.46: THE MENUS FIT A 1280x720 ITCH WINDOW. His question of 2026-09-13 about the itch viewport; the recommended embed is 1280x720 and the menus never shrank below their 1080p size, because titleRes was floored at 1 and his menu size multiplied on top. One helper, menuScale, now gives every menu site the same factor: his size times the screen factor at 1080p and above, and the screen factor alone below it, floored at half. Check 13.46 forces 1280x720 and requires the Undercroft and the corner readout drawn at the size that fits, and his 1.3 intact at 1920x1080; it fails on v13.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
