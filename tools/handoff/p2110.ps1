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

# THE TOP ROW OF STATION NAMES LINES UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    {id:'gamble',x:110,y:110,r:42,label:'WIRT THE GAMBLER'
'@ @'
    // v21.10, from the whole-game bug hunt of 2026-10-08 (V-E3), seen on the 4K Undercroft screenshot: THE TOP ROW OF NAMES IS ONE LINE.
    // The gambler stood 5 lower than the lift and the Mainframe on the same back wall, so WIRT THE GAMBLER printed below ENTER RAID!
    // and THE MAINFRAME on the row of names across the top of the room. He stands on their line now; his machine, ring and light
    // move up with him, and nothing else on the floor moves.
    {id:'gamble',x:110,y:105,r:42,label:'WIRT THE GAMBLER'
'@

SubRx @'
var VER='21.09';
'@ @'
var VER='21.10';
'@

$pat = "(?m)^  now:'v21\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.10: In the Undercroft, WIRT THE GAMBLER now lines up with ENTER RAID! and THE MAINFRAME across the top of the room. Check 21.10 fails on v21.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
