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

# RUN INFO STAYS IN THE COLUMN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
return Math.min(Math.max(bw,need),Math.round(bw*1.6));
'@ @'
return bw;   // v28.xx (cw-runinfocol), HIS ORDER (2026-10-18, cw-trcol): everything in the upper right corner is one column, all the same width. v34.39 let the run info panel grow to 1.6 of the column to the left (323 px at 1080p, the minimap and rows stay 300), so it stuck out of the column. A row that still does not fit wraps (its short form is tried first); the width is the column's.
'@

SubRx @'
var VER='34.56';
'@ @'
var VER='34.57';
'@

$pat = "(?m)^  now:'v34\.56:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.57: The run info panel is the same width as the minimap and the rows above it. Check 34.57 fails on v34.56',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
