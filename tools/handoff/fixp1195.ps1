$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
# Adds the detail-pill edit to p1195 (the recipe branch read the price row's
# rarity; it reads dispR now). Idempotent.
$f = 'C:\claudecode\dark raiders\tools\handoff\p1195.ps1'
$s = [IO.File]::ReadAllText($f)
if ($s.IndexOf('dispR(outKey)') -ge 0) { Write-Output 'p1195: pill edit already present'; exit 0 }
$anchor = "# STAMPS.`nSubRx @'`nvar VER='11.94';"
$pat = ($anchor -split "`n" | ForEach-Object { [regex]::Escape($_) }) -join "\r?\n"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw ('anchor matched ' + $c + ' times') }
$block = @(
  "# The recipe branch of the detail panel read the price row's rarity; every",
  "# other panel asks dispR, so it does too.",
  "SubRx @'",
  "       '<span class=""vpill r"">'+escHtml(String((oit&&oit.r)||'common').toUpperCase())+'</span></div>'+",
  "'@ @'",
  "       '<span class=""vpill r"">'+escHtml(String(((typeof dispR==='function')&&dispR(outKey))||(oit&&oit.r)||'common').toUpperCase())+'</span></div>'+   // v11.95: the shown rarity",
  "'@",
  "",
  $anchor
) -join "`n"
$s = [regex]::Replace($s, $pat, { param($m) $block })
[IO.File]::WriteAllText($f, $s, (New-Object Text.UTF8Encoding $false))
Write-Output 'p1195: pill edit added'
