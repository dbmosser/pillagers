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

# THE WHAT IS NEW CARD NAMES THE NIGHT OF OCTOBER 3 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='18.04';
'@ @'
var WHATSNEW_VER='18.18';
'@

SubRx @'
  'YOUR NOTES OF OCTOBER 3. Player 2 picks a character from the saves list, and every character can play 1 PLAYER. F11 fullscreens both windows. ESC pauses player 1 even with the player 2 window selected. Kid mode set in one window shows in the other, and a Settings change keeps its place. The banner reads EXTRACT IN PROGRESS, extraction takes 30 seconds to arrive and stays 30, the seal spawns at a new landmark each raid and opens a little quicker. Every menu shares one look. When the game runs slowly it lowers its own render resolution a notch at a time, and the fog and darkness layers draw at half size.',
'@ @'
  'THE NIGHT OF OCTOBER 3. Fewer big robots at the extraction. You see what your teammate sees: their view cone is open in your fog and the enemies in it are shown (Settings: Shared sight). Kid firing turns player 2 toward the nearest enemy before it is in range. Trading works in the Undercroft: right-click a stash item and OFFER it. Guns and items are painted like objects, sharp, and fill their cells. The title, the menus and the raid HUD share one look. Walls and trees are painted once and reused, so a busy street runs smoother. Trading is on every key legend and the Party window explains it.',
  'YOUR NOTES OF OCTOBER 3. Player 2 picks a character from the saves list, and every character can play 1 PLAYER. F11 fullscreens both windows. ESC pauses player 1 even with the player 2 window selected. Kid mode set in one window shows in the other, and a Settings change keeps its place. The banner reads EXTRACT IN PROGRESS, extraction takes 30 seconds to arrive and stays 30, the seal spawns at a new landmark each raid and opens a little quicker. Every menu shares one look. When the game runs slowly it lowers its own render resolution a notch at a time, and the fog and darkness layers draw at half size.',
'@

SubRx @'
var VER='18.17';
'@ @'
var VER='18.18';
'@

$pat = "(?m)^  now:'v18\.17:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.18: The what is new card names the night of October 3. Check 18.18 fails on v18.17',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
