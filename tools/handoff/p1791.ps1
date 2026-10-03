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

# THE WHAT IS NEW CARD NAMES THE BETTER FIRST HOUR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='17.80';
'@ @'
var WHATSNEW_VER='17.91';
'@

SubRx @'
  'SMOOTHER, LOUDER, YOURS. Settings has Master, Music and Effects volume, CHANGE KEYS to put any action on the key you want, and a KID MODE section where player 2 can come back after death. A two-player pair has one sound setting: both, player 1 only or player 2 only. A PlayStation pad is named in its own words. The sector page shows a map of each sector, the raid controls legend stays out of the way after your first raids, a covered player 1 window no longer freezes the raid for player 2, and if the player 1 window is gone, player 2 keeps the raid.',
'@ @'
  'A BETTER FIRST HOUR. The title shows the Undercroft behind it, the WELCOME PACK shows its items, and the stash tells a first raid what to do: drag a gun and two heals into the loadout, then go up at ENTER RAID! The sector page shows a map of each sector. The raid controls legend stays out of the way after your first raids, the NEW IN card is short, and if the game runs slowly it says once where the Settings levers are. A controller unplugged pauses only the window that was playing it.',
  'SMOOTHER, LOUDER, YOURS. Settings has Master, Music and Effects volume, CHANGE KEYS to put any action on the key you want, and a KID MODE section where player 2 can come back after death. A two-player pair has one sound setting: both, player 1 only or player 2 only. A PlayStation pad is named in its own words. The sector page shows a map of each sector, the raid controls legend stays out of the way after your first raids, a covered player 1 window no longer freezes the raid for player 2, and if the player 1 window is gone, player 2 keeps the raid.',
'@

SubRx @'
var VER='17.90';
'@ @'
var VER='17.91';
'@

$pat = "(?m)^  now:'v17\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.91: The what is new card names the better first hour. Check 17.91 fails on v17.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
