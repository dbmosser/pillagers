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

# UNDER THE TITLE, ONLY THE WORLD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawHubHUD(ox,oy){
'@ @'
function drawHubHUD(ox,oy){
  if(titleOn()) return;   // v17.84: nothing of the floor HUD under the title
'@

SubRx @'
    var s3=HB.stations[i],on=HB.near===s3;
'@ @'
    var s3=HB.stations[i],on=HB.near===s3;
    if(titleOn()) continue;   // v17.84: no station names under the title
'@

SubRx @'
var VER='17.83';
'@ @'
var VER='17.84';
'@

$pat = "(?m)^  now:'v17\.83:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.84: The title backdrop shows only the Undercroft itself: no floor text shows through. Check 17.84 fails on v17.83',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
