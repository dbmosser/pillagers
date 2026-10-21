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

# EXPERIMENTAL GROUP NAMES SHOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
#root #settingsmodal.expmode #setlist .expgroup{ height:48px; min-height:48px; margin:0; padding:16px var(--sp-3) 8px; border:0; background:transparent; box-shadow:none; opacity:1 !important; }
'@ @'
/* v33.31 (cw-expgrp) critic 61 rounds 1 to 2 (score 2): the four group names never showed because cw-setsechd zeroes every opacity:.7 row with !important. Scoped back on for the experimental page: 48px band, 16px name. */
#root #settingsmodal.expmode #setlist .expgroup{ height:48px !important; min-height:48px !important; margin:0 !important; padding:16px var(--sp-3) 8px !important; border:0 !important; background:transparent; box-shadow:none; opacity:1 !important; overflow:visible !important; display:flex !important; }
'@

SubRx @'
var VER='33.32';
'@ @'
var VER='33.33';
'@

$pat = "(?m)^  now:'v33\.32:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.33: The experimental page shows raid, combat, events and extras headings. Check 33.33 fails on v33.32',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
