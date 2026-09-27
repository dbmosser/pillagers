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

# A CONTROLLER TAP ON THE MAP PLACES THE MARKER AND SHUTS THE MAP (stability pass before his co-op session, 2026-09-27).

SubRx @'
    if(!du&&PAD.prev[12]&&PAD.duAt!=null&&!PAD.duHeld&&G&&!G.over){
      if(G.mapOpen&&G.mapCur) netWpFromMap(); else if(G.mapOpen) G.mapOpen=false; else if(NET.on&&NET.upSeed) netPingMake(); else G.mapOpen=true;   // v16.47: with the map cursor moved, a tap places the marker
    }
'@ @'
    if(!du&&PAD.prev[12]&&PAD.duAt!=null&&!PAD.duHeld&&G&&!G.over){
      var _mcT=!!(G.mapOpen&&G.mapCur);
      if(G.mapOpen&&G.mapCur) netWpFromMap(); else if(G.mapOpen) G.mapOpen=false; else if(NET.on&&NET.upSeed) netPingMake(); else G.mapOpen=true;   // v16.47: with the map cursor moved, a tap places the marker
      // v16.49 stability, his rule of v16.46 (a tap with the map open shuts it): the tap that places the marker shuts the map too.
      // Before, once the right stick had touched the map cursor every tap placed a marker and the map stayed up, with the gun
      // dead under it, until a 0.4 s hold; a child on a controller could not get out.
      if(_mcT){ G.mapOpen=false; G.mapCur=null; }
    }
'@

SubRx @'
var VER='16.48';
'@ @'
var VER='16.49';
'@

$pat = "(?m)^  now:'v16\.48:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.49: A CONTROLLER TAP ON THE MAP PLACES THE MARKER AND SHUTS THE MAP. Stability pass before a co-op session. Once the right stick had moved the map cursor, every D-UP tap placed a marker and the map stayed open with the gun dead under it until a long hold. His rule of v16.46 is that a tap with the map open shuts it: the tap now places the marker and shuts the map. Check 16.49 fails on v16.48',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
