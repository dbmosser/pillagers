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

# THE CONTROLS LIST STAYS OUT OF A RECORDING (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawLegend(fz){   // v20.74 (H40): fz is the zoom the full list is drawn at, so it can stop above the belt as seen on the screen
  var MONO=FS(TYPE.micro);   // audit: bypassed FS, sat below the floor
  delete HUDBOX.legend;
'@ @'
function drawLegend(fz){   // v20.74 (H40): fz is the zoom the full list is drawn at, so it can stop above the belt as seen on the screen
  var MONO=FS(TYPE.micro);   // audit: bypassed FS, sat below the floor
  delete HUDBOX.legend;
  if(typeof REC==='object'&&REC&&REC.on) return;   // v21.54: while F9 records, the controls list stays off the screen, so the attract clip is clean gameplay
'@

SubRx @'
var VER='21.53';
'@ @'
var VER='21.54';
'@

$pat = "(?m)^  now:'v21\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v21.54: While you record with F9, the controls list is hidden so the clip shows clean gameplay. Check 21.54 fails on v21.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
