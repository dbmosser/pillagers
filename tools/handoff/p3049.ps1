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

# RUN INFO SHOWS THE 3 CLOSEST CONTRACTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var EDGEBOX={}, GUNCARD_LAST=null;   // v24.9x (ringbadge): the gun card, pickup rows and co-op kill feed as last drawn, screen pixels
'@ @'
// v28.xx (cw-hudcontracts), HIS ANSWER Q1 (2026-10-18): "the Run info box shows at most the 3 contracts closest to done; ALL contracts are listed on the map screen."
// Replaces his v6.79 "ALL of them, not three and a footnote". runInfoCap takes the live contract rows and returns the 3 nearest to finishing, nearest first.
var RUNINFO_MAX=3;
function runInfoCap(live){
  var a=(live||[]).slice();
  a.sort(function(x,y){ return x.left-y.left; });
  return a.slice(0,RUNINFO_MAX);
}
var EDGEBOX={}, GUNCARD_LAST=null;   // v24.9x (ringbadge): the gun card, pickup rows and co-op kill feed as last drawn, screen pixels
'@

SubRx @'
      _live.sort(function(a,b){ return a.left-b.left; });
'@ @'
      _live=runInfoCap(_live);   // v28.xx (cw-hudcontracts), his Q1 (2026-10-18): the 3 closest to done, not all of them (the map screen lists all)
'@

SubRx @'
var VER='30.48';
'@ @'
var VER='30.49';
'@

$pat = "(?m)^  now:'v30\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.49: The Run info box in the raid shows only the 3 contracts closest to done. Check 30.49 fails on v30.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
