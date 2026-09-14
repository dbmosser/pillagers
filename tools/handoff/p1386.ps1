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

# SEARCHING AND LOOT AUDIT OF 2026-09-14, finding 2: A PILE YOU DROPPED RESTOCKED AS A RANDOM CRATE.
# Opened crates and lockers refill after 170 seconds, and the restock tests only the container's
# type. A pile dropped from the backpack is type crate, so once it was searched back up it
# refilled with one or two fresh crate items every 170 seconds for the rest of the raid, still
# marked dropped, so it searched in 0.6 seconds. Every drop left another permanent refilling
# pile. A pile you dropped is not a crate the world stocks, and it no longer restocks.
SubRx @'
    if(_rc.type!=='crate'&&_rc.type!=='locker'){ continue; }
'@ @'
    if(_rc.dropped){ continue; }   // v13.86, loot audit: a pile you dropped is not a crate the world restocks
    if(_rc.type!=='crate'&&_rc.type!=='locker'){ continue; }
'@
SubRx @'
var VER='13.85';
'@ @'
var VER='13.86';
'@

$pat = "(?m)^  now:'v13\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.86: A PILE YOU DROP DOES NOT RESTOCK. Searching and loot audit of 2026-09-14, finding 2: opened crates and lockers refill after 170 seconds and the restock tested only the type, so a pile dropped from the backpack, which is type crate, refilled with fresh crate items every 170 seconds for the rest of the raid once it was searched back up. The restock now skips dropped piles. Check 13.86 drops an item, searches the pile back up, ages it 171 seconds and requires it still opened, with an ordinary opened crate restocking as the control; it fails on v13.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
