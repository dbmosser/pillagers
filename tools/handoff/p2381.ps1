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

# THE WHAT IS NEW CARD LISTS THE TRIPWIRE MINE ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  'ARCADE AND RUNNERS. One player arcade, hold E to loot, credits as score, a title that always fits, and pillagers who run now fight back when shot.',
  'TRIPWIRE MINE. It goes on the belt like a grenade and strings a wire across a doorway that blows when a machine or a pillager walks through.',
'@ @'
  'ARCADE AND RUNNERS. One player arcade, hold E to loot, credits as score, a title that always fits, and pillagers who run now fight back when shot.',
'@

SubRx @'
var VER='23.80';
'@ @'
var VER='23.81';
'@

$pat = "(?m)^  now:'v23\.80:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.81: The what is new card lists the Tripwire Mine once. Check 23.81 fails on v23.80',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
