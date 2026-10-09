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

# SORT BY RARITY FOLLOWS THE COLOURS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(m==='rarity') return ((_RRANK[Y.r]||0)-(_RRANK[X.r]||0))||(ival(y)-ival(x));
'@ @'
    // v20.67, from the whole-game bug hunt of 2026-10-08 (H29): BY THE RARITY THE CELL WEARS. A gun wears the colour of its tier
    // (dispR, the v7.99 rule: the tier table is the truth for a gun), not the rarity on its item row, so the gold Longshot sorted
    // below every purple item, the purple Marksman Rifle sat among the blues and the blue Magnum among the greens.
    if(m==='rarity') return ((_RRANK[dispR(y)||Y.r]||0)-(_RRANK[dispR(x)||X.r]||0))||(ival(y)-ival(x));
'@

SubRx @'
var VER='20.66';
'@ @'
var VER='20.67';
'@

$pat = "(?m)^  now:'v20\.66:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.67: Stash SORT RARITY now orders guns by the rarity colour they show. Check 20.67 fails on v20.66',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
