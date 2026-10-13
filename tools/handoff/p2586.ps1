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

# DEMO RAIDS BUILD LIKE CAREER RAIDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ARCADE_CFG={raidSec:0};
'@ @'
// v25.xx (demounify), HIS RULE (2026-10-12): "GAMEPLAY ELEMENTS ... SHOULD BE EXACTLY THE SAME IN DEMO AND CAREER". The last dial the overlay
// set was the raid clock (raidSec 0, from the endless first arcade). Since the 10 minute DEMO clock (ARCADE_RAID_SEC, set on the raid by
// arcadePostBuild) nothing needs it, and it still made the DEMO different in two ways: the first weather change is drawn from the raid
// clock dial at the build (wxAt: 85 to 120 s in a DEMO raid, 85 to 189 s in a CAREER raid), and Settings read NO CLOCK in a DEMO raid
// that has one (and a raid length chosen there moved nothing). The overlay is empty now: a DEMO raid builds from the same dials a CAREER raid does.
var ARCADE_CFG={};
'@

SubRx @'
var VER='25.85';
'@ @'
var VER='25.86';
'@

$pat = "(?m)^  now:'v25\.85:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.86: A demo raid now builds from the same settings as a career raid, so the weather comes at the same time. Check 25.86 fails on v25.85',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
