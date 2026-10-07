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

# THE WHAT IS NEW CARD SHOWS ITS NEWEST NEWS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='18.45';
'@ @'
var WHATSNEW_VER='18.57';
'@

SubRx @'
  'NEW ICONS AND A CLEANER HUD. Every gun is drawn as the real thing, and bandages, medkits, stims, plates, ammo, grenades, parts and salvage all have new detailed pictures. The raid HUD shares one look: rounded panels, capsule bars, a panel behind your gun and ammo. Busy streets run smoother. Items dropped on the Undercroft floor can always be picked up and come back to you if nobody takes them.',
  'TRADING IS DROPPING. Up top, press Z (Y on a controller, backpack open) and the item is a pile at your feet; your teammate searches it like any box. In the Undercroft, right-click a stash item (Y on a controller), choose Drop on the floor, and they press E beside the crate. The key legends and the Party window say so. New characters start with short dark hair.',

'@ @'

'@

SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'TWO PLAYERS, FEWER SNAGS. Pulling out one controller pauses only that player window. Player 2 save stays locked while their window is open, even after player 1 reloads. CHANGE KEYS lists G, Q, Z, V and O, and moving any action swaps cleanly. A seal stuck full now opens, and a covered window keeps the raid running for a teammate.',
  'NEW ICONS AND A CLEANER HUD. Every gun is drawn as the real thing, and bandages, medkits, stims, plates, ammo, grenades, parts and salvage all have new detailed pictures. The raid HUD shares one look: rounded panels, capsule bars, a panel behind your gun and ammo. Busy streets run smoother. Items dropped on the Undercroft floor can always be picked up and come back to you if nobody takes them.',
  'TRADING IS DROPPING. Up top, press Z (Y on a controller, backpack open) and the item is a pile at your feet; your teammate searches it like any box. In the Undercroft, right-click a stash item (Y on a controller), choose Drop on the floor, and they press E beside the crate. The key legends and the Party window say so. New characters start with short dark hair.',
'@

SubRx @'
var VER='18.56';
'@ @'
var VER='18.57';
'@

$pat = "(?m)^  now:'v18\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.57: The what is new card shows the two player fixes, the new icons and dropping items. Check 18.57 fails on v18.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
