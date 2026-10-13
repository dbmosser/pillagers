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

# THE ATTRACT PAGES GROW WITH A 4K SCREEN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
'font:800 clamp(12px,1.15vw,30px) var(--f-cond);letter-spacing:.08em;color:#f2e6c8;text-shadow:0 2px 0 #000;text-align:center}'+
'@ @'
'font:800 clamp(12px,1.15vw,60px) var(--f-cond);letter-spacing:.08em;color:#f2e6c8;text-shadow:0 2px 0 #000;text-align:center}'+   // vNN.xx (ui5q1u): the same share of a 4K screen as of 1080p (the cap was 30px)
'@

SubRx @'
var VER='24.77';
'@ @'
var VER='24.78';
'@

$pat = "(?m)^  now:'v24\.77:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.78: The arcade attract pages fill a 4K screen as they do a 1080p one. Check 24.78 fails on v24.77',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
