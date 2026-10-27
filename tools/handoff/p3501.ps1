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

# CORNER MONEY PRINTED ONCE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var on=(now-TRG.t<200)?1:0;
'@ @'
var on; now=(typeof performance!=='undefined')?performance.now():Date.now(); on=(now-TRG.t<200)?1:0;   // v28.xx (cw-walletonce), HIS NOTE (2026-10-25) on the photo of v34.78: "Text collisions on the menu thing". The corner rows are stamped with the real clock, but the loop passed its own frame time: a driven loop (the camera staging, a test) runs ahead of the real clock, the page text came back and printed over the canvas rows. Both sides now read the same clock.
'@

SubRx @'
var VER='35.00';
'@ @'
var VER='35.01';
'@

$pat = "(?m)^  now:'v35\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.01: The top right money box shows one layout only. Check 35.01 fails on v35.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
