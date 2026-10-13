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

# DEMO HITS LAND LIKE CAREER HITS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ARCADE_DMG=0.5;
'@ @'
// 2026-10-12 (unify1), HIS ANSWER: "GAMEPLAY ELEMENTS ... SHOULD BE EXACTLY THE SAME IN DEMO AND CAREER" and 6 a, TTK as now.
// A DEMO hit took half (arcade10), so the same gun killed a DEMO player in twice the time it kills a CAREER player. The dial is
// now 1: a DEMO hit takes what the same hit takes in CAREER. The hook stays so a later order can move it in one place.
var ARCADE_DMG=1;
'@

SubRx @'
var VER='24.75';
'@ @'
var VER='24.76';
'@

$pat = "(?m)^  now:'v24\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.76: A hit in DEMO now does the same damage as in CAREER. Check 24.76 fails on v24.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
