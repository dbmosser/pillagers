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

# SEARCHING AND LOOT AUDIT OF 2026-09-14, finding 1: YOUR OWN DROPPED ITEMS PAID THE HOT ZONE BONUS,
# WITHOUT LIMIT. Opening a container inside the hot zone rolls two extra items from the safe
# table onto it, guarded only against caches and containers already opened. A pile you drop from
# the backpack is a fresh unopened crate, so inside the zone every drop and search back up made
# two high-tier items from nothing: cores, titanium, black boxes, marksman rifles, longshots,
# keys. The bonus is for the zone's own containers; a pile you dropped is not one of them.
SubRx @'
  if(G.hotZone&&!ct.cache&&!ct.opened){
'@ @'
  if(G.hotZone&&!ct.cache&&!ct.opened&&!ct.dropped){   // v13.85, loot audit: a pile you dropped earns no bonus
'@
SubRx @'
var VER='13.84';
'@ @'
var VER='13.85';
'@

$pat = "(?m)^  now:'v13\.84:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.85: A PILE YOU DROP EARNS NO HOT ZONE BONUS. Searching and loot audit of 2026-09-14, finding 1: opening a container in the hot zone rolls two items from the safe table onto it, guarded only against caches and opened containers, so a pile dropped from the backpack inside the zone paid two high-tier items every time it was searched back up. The bonus now skips dropped piles. Check 13.85 drops one item in the hot zone and searches it back up, requiring the backpack to hold that one item, with an ordinary crate in the zone still paying the bonus as the control; it fails on v13.84',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
