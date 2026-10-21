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

# CAMERA FURTHER OUT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ZDEFAULT=1.3,ZT=ZDEFAULT,ZC=ZDEFAULT,zoomSaveT=0;
'@ @'
// v28.xx (cw-camfar105), HIS ORDER (2026-10-20 evening): "default camera needs to be further away from player", then with his picture: "this is a good distance for default camera". His picture shows a pillager 6.4 percent of the screen height; 1.3 drew it 7.9 percent, so the default is 1.05 (1.3 x 6.4 / 7.9). Reverses the 1.3 of v31.85; a zoom he set himself stays.
var ZDEFAULT=1.05,ZT=ZDEFAULT,ZC=ZDEFAULT,zoomSaveT=0;
'@

SubRx @'
['Numpad0','zoom to 130%']
'@ @'
['Numpad0','zoom to 105%']
'@

SubRx @'
var VER='33.22';
'@ @'
var VER='33.23';
'@

$pat = "(?m)^  now:'v33\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.23: The default camera is further out. Reset zoom returns to 105 percent. Check 33.23 fails on v33.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
