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

# TEXT STARTS AT 100 PERCENT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
cfg:null,menuZoom:1.3,lastSim:null,
'@ @'
cfg:null,menuZoom:1,uiScale:1,/* v36.xx (cw-cx-text100), his 10-31 order: text size starts at 100 percent. Only this literal (a NEW profile) changes; a save replaces P whole and keeps its own size */lastSim:null,
'@

SubRx @'
var SLOT=(function()
'@ @'
var P_BORN={uiScale:P.uiScale,menuZoom:P.menuZoom};   // v36.xx (cw-cx-text100): what a new profile is born with, kept so a check can read it after P is replaced by a save
var SLOT=(function()
'@

SubRx @'
crashes:[],uiScale:1.5,menuZoom:1.25};
'@ @'
crashes:[],uiScale:1,menuZoom:1};   // v36.xx (cw-cx-text100), his 10-31 order "text size should default to 100%": the demo starts at 100 percent text (UISCALES step 0 with its menu zoom), no longer the TV size of cw-tvtext (monitors tonight).
'@

SubRx @'
var VER='36.69';
'@ @'
var VER='36.70';
'@

$pat = "(?m)^  now:'v36\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.70: Text size now starts at 100 percent for new players and in the demo. Settings and the minus and equals keys still change it. Check 36.70 fails on v36.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
