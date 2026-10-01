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

# A LATE TEAMMATE SEES THE WALLS ALREADY DOWN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  NET.entBuilt=g.nidN;   // v17.50: the first number a body that comes up after the build takes
'@ @'
  NET.entBuilt=g.nidN;   // v17.50: the first number a body that comes up after the build takes
  NET.wallN0=(g&&g.map&&g.map.walls)?g.map.walls.length:0;   // v17.58: how many walls the build made, for a late join
'@

SubRx @'
  m.gone=gone;
'@ @'
  m.gone=gone;
  // v17.58: and the walls already down. Every wall keeps the number it was built with (v17.36); a wall that fell went out once,
  // as a word, so a late window built them all and stood behind walls the host had blown open, its shots stopped by them.
  var have={}, wn=NET.wallN0|0, wi; m.wg=[];
  for(wi=0;wi<G.map.walls.length;wi++){ have[G.map.walls[wi].wid]=1; if(G.map.walls[wi].wid+1>wn) wn=G.map.walls[wi].wid+1; }
  for(wi=0;wi<wn&&m.wg.length<1500;wi++) if(!have[wi]) m.wg.push(wi);
'@

SubRx @'
  if(typeof L.t==='number'&&isFinite(L.t)&&L.t>0) G.t=L.t;
'@ @'
  if(m.wg&&m.wg.length&&G.map&&G.map.walls){   // v17.58: the walls the host already has down come down here too
    var wk=0, wq, ww;
    for(i=0;i<m.wg.length&&i<1500;i++){ ww=netWallById(m.wg[i]|0); if(!ww) continue; G.map.walls.splice(G.map.walls.indexOf(ww),1); if(G.dmgWalls){ wq=G.dmgWalls.indexOf(ww); if(wq>=0) G.dmgWalls.splice(wq,1); } wk++; }
    if(wk) rebuildGeometry();
  }  if(typeof L.t==='number'&&isFinite(L.t)&&L.t>0) G.t=L.t;
'@

SubRx @'
var VER='17.57';
'@ @'
var VER='17.58';
'@

$pat = "(?m)^  now:'v17\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.58: JOIN THE RAID IN PROGRESS: walls already blown open in the raid are open for the teammate who joins too. Check 17.58 fails on v17.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
