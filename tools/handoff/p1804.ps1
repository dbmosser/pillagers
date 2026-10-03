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

# THE WHAT IS NEW CARD NAMES HIS NOTES OF OCTOBER 3 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='17.91';
'@ @'
var WHATSNEW_VER='18.04';
'@

SubRx @'
  'A BETTER FIRST HOUR. The title shows the Undercroft behind it, the WELCOME PACK shows its items, and the stash tells a first raid what to do: drag a gun and two heals into the loadout, then go up at ENTER RAID! The sector page shows a map of each sector. The raid controls legend stays out of the way after your first raids, the NEW IN card is short, and if the game runs slowly it says once where the Settings levers are. A controller unplugged pauses only the window that was playing it.',
'@ @'
  'YOUR NOTES OF OCTOBER 3. Player 2 picks a character from the saves list, and every character can play 1 PLAYER. F11 fullscreens both windows. ESC pauses player 1 even with the player 2 window selected. Kid mode set in one window shows in the other, and a Settings change keeps its place. The banner reads EXTRACT IN PROGRESS, extraction takes 30 seconds to arrive and stays 30, the seal spawns at a new landmark each raid and opens a little quicker. Every menu shares one look. When the game runs slowly it lowers its own render resolution a notch at a time, and the fog and darkness layers draw at half size.',
  'A BETTER FIRST HOUR. The title shows the Undercroft behind it, the WELCOME PACK shows its items, and the stash tells a first raid what to do: drag a gun and two heals into the loadout, then go up at ENTER RAID! The sector page shows a map of each sector. The raid controls legend stays out of the way after your first raids, the NEW IN card is short, and if the game runs slowly it says once where the Settings levers are. A controller unplugged pauses only the window that was playing it.',
'@

SubRx @'
var VER='18.03';
'@ @'
var VER='18.04';
'@

$pat = "(?m)^  now:'v18\.03:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.04: The what is new card names your notes of October 3. Check 18.04 fails on v18.03',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
