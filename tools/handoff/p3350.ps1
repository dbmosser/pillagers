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

# DEFAULT CAMERA EXACTLY 1.0 (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var ZDEFAULT=1.05,ZT=ZDEFAULT,ZC=ZDEFAULT,zoomSaveT=0;
'@ @'
var ZDEFAULT=1.0,ZT=ZDEFAULT,ZC=ZDEFAULT,zoomSaveT=0;   // v33.49 (cw-pixzoom): job 86a, the pixel art pass. 1.05 becomes exactly 1.0 so a 1080p screen is pixel exact (scale 1) and 4K is scale 2. A zoom he set himself stays his.
'@

SubRx @'
var VER='33.49';
'@ @'
var VER='33.50';
'@

$pat = "(?m)^  now:'v33\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.50: The default camera is a touch further out (1.0 instead of 1.05). A saved zoom is unchanged. Check 33.50 fails on v33.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
