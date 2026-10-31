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

# THE SHIP GLOW NEVER CRASHES THE FRAME (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var urg=inb?1-Math.max(0,G.beaconT)/Math.max(1,CFG.extractWait):0;
'@ @'
var urg=inb?clamp(1-Math.max(0,G.beaconT)/Math.max(1,CFG.extractWait),0,1):0;   // v28.xx (cw-urgclamp): the beacon glow radius is 60+70*urg; a countdown longer than the wait (the wait went 30 to 20 on 10-28) made urg negative and arc threw, stopping the frame
'@

SubRx @'
var VER='36.94';
'@ @'
var VER='36.95';
'@

$pat = "(?m)^  now:'v36\.94:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.95: The ship glow cannot throw when the countdown is longer than the extract wait. Check 36.95 fails on v36.94',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
