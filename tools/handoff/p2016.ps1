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

# LONG HAIR LEAVES A CURVED CHEST SHOWING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    if(_NCT==='long'){ rrF(hx2-9.6,ty-38.6,19.2,20.5,6); }
'@ @'
    if(_NCT==='long'){ if(_BLD==='curved'){ rrF(hx2-9.6,ty-38.6,19.2,17.8,6); rrF(hx2-9.6,ty-26,3.0,7.9,1.5); rrF(hx2+6.6,ty-26,3.0,7.9,1.5); } else rrF(hx2-9.6,ty-38.6,19.2,20.5,6); }   // v20.16, code review: on Curved the long hair falls down the sides, off the chest
'@

SubRx @'
var VER='20.15';
'@ @'
var VER='20.16';
'@

$pat = "(?m)^  now:'v20\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.16: Long-haired Curved teammates, pillagers and crowd keep their chest visible. Check 20.16 fails on v20.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
