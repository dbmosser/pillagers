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

# THE SHOP TILES FILL THEIR FRAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  .vendgrid{ display:grid; grid-template-columns:repeat(auto-fill,minmax(150px,190px));
'@ @'
  /* v20.90, from the whole-game bug hunt of 2026-10-08 (V-A3): THE TILES FILL THEIR FRAME. The columns stopped at 190, so the BUY,
     CRAFT and HIRE grids left an empty strip almost a tile wide inside the right edge of their frame (four tiles and a gap on the 4K
     screenshots, five and a gap at 1080p). The columns now share the whole width, never under 170, so a tile stays about the size
     it was and one more fits on a row. */
  .vendgrid{ display:grid; grid-template-columns:repeat(auto-fill,minmax(170px,1fr));
'@

SubRx @'
var VER='20.89';
'@ @'
var VER='20.90';
'@

$pat = "(?m)^  now:'v20\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.90: The shop, bench and hire tiles now fill their frame, with no empty strip on the right. Check 20.90 fails on v20.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
