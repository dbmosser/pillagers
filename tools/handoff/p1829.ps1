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

# THE WHAT IS NEW CARD SAYS TRADING IS DROPPING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WHATSNEW_VER='18.18';
'@ @'
var WHATSNEW_VER='18.29';
'@

SubRx @'
  'THE NIGHT OF OCTOBER 3. Fewer big robots at the extraction. You see what your teammate sees: their view cone is open in your fog and the enemies in it are shown (Settings: Shared sight). Kid firing turns player 2 toward the nearest enemy before it is in range. Trading works in the Undercroft: right-click a stash item and OFFER it. Guns and items are painted like objects, sharp, and fill their cells. The title, the menus and the raid HUD share one look. Walls and trees are painted once and reused, so a busy street runs smoother. Trading is on every key legend and the Party window explains it.',
'@ @'
  'TRADING IS DROPPING. Up top, press Z (Y on a controller, backpack open) and the item is a pile at your feet; your teammate searches it like any box. In the Undercroft, right-click a stash item (Y on a controller), choose Drop on the floor, and they press E beside the crate. The key legends and the Party window say so. New characters start with short dark hair.',
  'THE NIGHT OF OCTOBER 3. Fewer big robots at the extraction. You see what your teammate sees: their view cone is open in your fog and the enemies in it are shown (Settings: Shared sight). Kid firing turns player 2 toward the nearest enemy before it is in range. Trading works in the Undercroft: right-click a stash item and OFFER it. Guns and items are painted like objects, sharp, and fill their cells. The title, the menus and the raid HUD share one look. Walls and trees are painted once and reused, so a busy street runs smoother. Trading is on every key legend and the Party window explains it.',
'@

SubRx @'
var VER='18.28';
'@ @'
var VER='18.29';
'@

$pat = "(?m)^  now:'v18\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.29: The what is new card says how trading works now. Check 18.29 fails on v18.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
