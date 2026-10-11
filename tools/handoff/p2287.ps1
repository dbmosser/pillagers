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

# LINES SAID WITH THE MAP OPEN DRAW OVER IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _frows=feedRows(), _alL=ALERTL, _loc=_alL?null:locUp();   // v21.86 (R04): the rows msgLayout laid out; v22.13 (R08): and the alert over them; v22.xx (R34): or the location tag
'@ @'
  // v22.xx, the raid text rewrite (R38): A LINE SAID WITH THE MAP OPEN DRAWS OVER IT. HIS ORDER (2026-10-09): the raid text reads like
  // a shooter HUD, and in those a callout is never hidden by the map. The message band (the alert, the location tag and the feed)
  // was drawn here, before the sector map, whose opaque backing is drawn last, so with the map open WAYPOINT MARKED, a ring
  // closing or a Crier marking you was drawn underneath it and never seen. The band is now one function (_lanes): it is drawn here
  // as before with the map shut, and after drawMapOverlay with the map open, so it shows over the map.
  var _lanes=function(){
  var _frows=feedRows(), _alL=ALERTL, _loc=_alL?null:locUp();   // v21.86 (R04): the rows msgLayout laid out; v22.13 (R08): and the alert over them; v22.xx (R34): or the location tag
'@

SubRx @'
    ctx.restore();                              // v10.43: end of the message scale
  }
'@ @'
    ctx.restore();                              // v10.43: end of the message scale
  }
  };
  if(!G.mapOpen) _lanes();   // v22.xx (R38): with the map open the band is drawn after it, below
'@

SubRx @'
  if(G.mapOpen) drawMapOverlay();
'@ @'
  if(G.mapOpen){ drawMapOverlay(); try{ _lanes(); }catch(_ln){} }   // v22.xx (R38): the message band over the map
'@

SubRx @'
var VER='22.86';
'@ @'
var VER='22.87';
'@

$pat = "(?m)^  now:'v22\.86:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v22.87: Messages and alerts said while the sector map is open now show over the map instead of under it. Check 22.87 fails on v22.86',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
