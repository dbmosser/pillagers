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

# A LATE TEAMMATE SEES THE MAP MARKERS ALREADY PLACED (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(id=0;id<G.ents.length;id++) if(G.ents[id]&&G.ents[id].nid>=(NET.entBuilt||1e9)) netSend(peer,netEntNewWord(G.ents[id]));
'@ @'
  for(id=0;id<G.ents.length;id++) if(G.ents[id]&&G.ents[id].nid>=(NET.entBuilt||1e9)) netSend(peer,netEntNewWord(G.ents[id]));
  // v17.59: and the map markers already placed (the host's, and any other teammate's), which went out once, as they were placed
  if(G.waypoint&&typeof G.waypoint.x==='number') netSend(peer,{t:'wp',x:Math.round(G.waypoint.x),y:Math.round(G.waypoint.y)});
  if(NET.wps) for(id in NET.wps) if(Object.prototype.hasOwnProperty.call(NET.wps,id)&&(id|0)!==peer.seat&&NET.wps[id]&&typeof NET.wps[id].x==='number') netSend(peer,{t:'wp',s:id|0,x:Math.round(NET.wps[id].x),y:Math.round(NET.wps[id].y)});
'@

SubRx @'
var VER='17.58';
'@ @'
var VER='17.59';
'@

$pat = "(?m)^  now:'v17\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.59: JOIN THE RAID IN PROGRESS: map markers your party already placed show for the teammate who joins. Check 17.59 fails on v17.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
