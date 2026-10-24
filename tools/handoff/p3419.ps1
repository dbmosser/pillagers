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

# RANK BARS GROW WITH RANK (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#appavatarpicker .costile[data-rar]{ border-top:3px solid var(--rar,#9da3a8); }
'@ @'
#appavatarpicker .costile[data-rar]{ border-top:3px solid var(--rar,#9da3a8); }
/* v28.xx (cw-cosrarthick) 2.79 a: rank also reads in greyscale, the top bar grows 2 to 6px from common to gold */
#appavatarpicker .costile[data-rar="common"]{ border-top-width:2px; }
#appavatarpicker .costile[data-rar="uncommon"]{ border-top-width:3px; }
#appavatarpicker .costile[data-rar="rare"]{ border-top-width:4px; }
#appavatarpicker .costile[data-rar="elite"]{ border-top-width:5px; }
#appavatarpicker .costile[data-rar="gold"]{ border-top-width:6px; }
'@

SubRx @'
var VER='34.18';
'@ @'
var VER='34.19';
'@

$pat = "(?m)^  now:'v34\.18:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.19: Fashion tiles show rank by bar thickness too. Check 34.19 fails on v34.18',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
