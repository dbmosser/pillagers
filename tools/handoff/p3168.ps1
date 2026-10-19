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

# PARTY CARD LABELS NEVER DRAW UNDER 16PX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
body #attract .arcpage th{ font-size:calc(var(--fs-label) * var(--attz,1)); }

'@ @'
body #attract .arcpage th{ font-size:calc(var(--fs-label) * var(--attz,1)); }
/* v31.xx (cw-partylook6), the critic on the party cards (46 52 55 56 64, all 3 or 2): "labels are about 14px, below the 16px minimum for anything read from a couch". Every small label on the how to play page, the board and the run over card (table heads, the seeded night line, stat labels, best moment labels, the initials lines) never draws under 16px, whatever the menu scale. Restyle only. */
body #attract .arcpage th, body #attract .arcpage .apb, body #attract .arcover .aosc i, body #attract .arcover .aoi, body #attract .arcover .aoq{ font-size:max(16px, calc(var(--fs-label) * var(--attz,1))); }
body #attract .arcover .aobmt > div:first-child{ font-size:max(16px, calc(var(--fs-label) * var(--attz,1))) !important; }

'@

SubRx @'
var VER='31.67';
'@ @'
var VER='31.68';
'@

$pat = "(?m)^  now:'v31\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.68: Small labels on the how to play page, the board and the run over card are never under 16px. Check 31.68 fails on v31.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
