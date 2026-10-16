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

# FRAME CAP UP TO 240 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
     {n:'30',  cfg:{fpsCap:30}}
'@ @'
     {n:'30',  cfg:{fpsCap:30}},
     // lean5, HIS ORDER (2026-10-15): "Frame cap options above 60: 75, 90, 120, 144, 165, 240". They go at the END so a saved choice (an index) keeps meaning what it did.
     {n:'75',  cfg:{fpsCap:75}},
     {n:'90',  cfg:{fpsCap:90}},
     {n:'120', cfg:{fpsCap:120}},
     {n:'144', cfg:{fpsCap:144}},
     {n:'165', cfg:{fpsCap:165}},
     {n:'240', cfg:{fpsCap:240}}
'@

SubRx @'
var VER='28.69';
'@ @'
var VER='28.70';
'@

$pat = "(?m)^  now:'v28\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.70: The Frame cap setting now goes up to 75, 90, 120, 144, 165 and 240. Check 28.70 fails on v28.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
