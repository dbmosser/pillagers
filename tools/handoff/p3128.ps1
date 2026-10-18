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

# player 2 prompt follows the device player 2 used last (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
w=(ARCADE.role==='p2')?'PLAYER 2: PRESS A':
'@ @'
w=(ARCADE.role==='p2')?/* v31.28 (cw-p2prompt), HIS ORDER (2026-10-18): player 2 names the device it used last, like player 1: a key press reads press any key, the pad reads its A */('PLAYER 2: PRESS '+(padOn()?padB('A'):'ANY KEY')):
'@

SubRx @'
var VER='31.27';
'@ @'
var VER='31.28';
'@

$pat = "(?m)^  now:'v31\.27:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.28: The player 2 prompt reads player 2: press any key after a key press and player 2: press a after a press on its pad, like player 1. Check 31.28 fails on v31.27',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
