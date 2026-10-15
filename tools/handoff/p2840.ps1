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

# PLAYER 2 SEES SEARCH CONES ON BUILT BODIES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(e.net) return e.srch===1;
'@ @'
  if(e.net||(NET.on&&netEntsPeer())) return e.srch===1;   // v28.40 (cloud-coop-search-cones-built), CLOUD HUNT 2026-10-15: player 2 own built bodies run no AI there, so they take searching from the host flag too
'@

SubRx @'
  L=e.net?1:Math.max(0,Math.min(SEARCH_MAXL,e.searchLvl|0));
'@ @'
  L=(e.net||(NET.on&&netEntsPeer()))?1:Math.max(0,Math.min(SEARCH_MAXL,e.searchLvl|0));   // v28.40 (cloud-coop-search-cones-built), CLOUD HUNT 2026-10-15: player 2 own built bodies draw the middle ring a linked window draws, as the bodies the host sends do
'@

SubRx @'
var VER='28.39';
'@ @'
var VER='28.40';
'@

$pat = "(?m)^  now:'v28\.39:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.40: In co-op, player 2 now sees the amber search cone on every searching enemy, the same as player 1. Check 28.40 fails on v28.39',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
