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

# THE ATTRACT SCREEN FILLS A 4K TV (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
font:800 clamp(26px,3.6vw,84px) var(--f-cond);
'@ @'
font:800 clamp(26px,3.6vw,168px) var(--f-cond);
'@

SubRx @'
font:800 clamp(30px,5vw,120px) var(--f-cond);
'@ @'
font:800 clamp(30px,5vw,240px) var(--f-cond);
'@

SubRx @'
font:800 clamp(15px,1.6vw,38px) var(--f-cond);
'@ @'
font:800 clamp(15px,1.6vw,76px) var(--f-cond);
'@

SubRx @'
font:800 clamp(16px,1.9vw,46px) var(--f-cond);
'@ @'
font:800 clamp(16px,1.9vw,92px) var(--f-cond);
'@

SubRx @'
function arcadeAttHow(pg){
'@ @'
// vNN.xx, UI REDESIGN ui5q1y (his #50, the 4K attract pictures): the attract name, PRESS ANY BUTTON, the team strip and the RUN OVER
// card size with the screen up to a 4K TV (their caps doubled: 168, 240, 76 and 92px), as the attract pages do since ui5q1u.
function arcadeAttHow(pg){
'@

SubRx @'
var VER='24.88';
'@ @'
var VER='24.89';
'@

$pat = "(?m)^  now:'v24\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.89: The arcade attract screen and RUN OVER card fill a 4K TV as they fill a 1080p one. Check 24.89 fails on v24.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
