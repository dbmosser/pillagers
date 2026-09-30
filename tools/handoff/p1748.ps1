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

# THE WHAT IS NEW CARD NAMES TRADING, DROP-IN AND THE BOSS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='17.41';
'@ @'
var WHATSNEW_VER='17.48';
'@

SubRx @'
  'NEW FOR THE PARTY. Every player chooses a kit when the party ascends from the sector page. Tap D-UP, N or the middle mouse button to ping a spot or an enemy for your party; hold D-UP for the map, where the right stick moves a cursor and a tap places a marker everyone sees. A kill feed names who killed what, an arrow points to a teammate off screen, and the end of raid card shows the whole party. Kid mode in Settings gives player 2 less damage, and Settings opens from the pause box in a raid.',
'@ @'
  'TRADING, DROP-IN AND A BOSS. With the backpack open, T or Y offers the selected item to your teammate, who takes it with T or Y. A teammate in the Undercroft can JOIN THE RAID IN PROGRESS. THE OVERSEER guards the middle of every map. The stash has search and sort, Settings has Render resolution, Frame cap and Effects, and hits and deaths are animated.',
  'NEW FOR THE PARTY. Every player chooses a kit when the party ascends from the sector page. Tap D-UP, N or the middle mouse button to ping a spot or an enemy for your party; hold D-UP for the map, where the right stick moves a cursor and a tap places a marker everyone sees. A kill feed names who killed what, an arrow points to a teammate off screen, and the end of raid card shows the whole party. Kid mode in Settings gives player 2 less damage, and Settings opens from the pause box in a raid.',
'@

SubRx @'
var VER='17.47';
'@ @'
var VER='17.48';
'@

$pat = "(?m)^  now:'v17\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.48: THE WHAT IS NEW CARD NAMES TRADING, DROP-IN AND THE BOSS: one line for his picks v17.42 to v17.47 (trading, drop-in, THE OVERSEER, stash search and sort, graphics options, hit and death animation), and the stamp moves to this build. Check 17.48 fails on v17.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
