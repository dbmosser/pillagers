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

# THE BAR LINES UP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
       '<div class="hint">'+B.desc+'  Each lasts '+fmtMS(B.dur)+'.</div></div>'+
'@ @'
       // v20.98, from the 4K visual pass of 2026-10-08 (V-C4): THE LINE UNDER A DRINK STARTS UNDER ITS NAME. The line under Liquor and
       // Blotter kept the inset of a hint box, so it began a step to the right of the drink name above it. It starts where the name starts.
       '<div class="hint" style="padding-left:0;padding-right:0">'+B.desc+'  Each lasts '+fmtMS(B.dur)+'.</div></div>'+
'@

SubRx @'
var VER='20.97';
'@ @'
var VER='20.98';
'@

$pat = "(?m)^  now:'v20\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.98: At the bar, the line under each drink now starts right under its name. Check 20.98 fails on v20.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
