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

# THE SEAL SPAWNS AT RANDOM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// Fixed per map, derived from the map's own geometry so it is always the same
// door in the same place: the far corner from the first authored spawn.
function sealSpot(map,def){
  var s0=def.spawns[0],best=null,bd=-1;
  for(var i=0;i<def.landmarks.length;i++){
    var L=def.landmarks[i],cx=L.x+L.w/2,cy=L.y+L.h/2;
    var d=dist({x:cx,y:cy},s0);
    if(d>bd){ bd=d; best={x:cx,y:cy}; }
  }
  if(!best) best={x:WORLD_W*0.5,y:WORLD_H*0.5};
  // MUST be the same door in the same place every raid, so the candidate test
  // uses the map DEFINITION only. Testing against the built wall list looked
  // right and was not: furniture and interior partitions are rolled fresh each
  // raid, so a spot that was clear last time can be blocked this time and the
  // seal walks. Measured on COLD STORAGE, where it moved across four raids.
'@ @'
// v17.96, HIS ORDER (2026-10-03): THE SEAL SPAWNS AT RANDOM. It stood in the same far corner every raid; now each raid rolls it
// among the map's landmarks from the raid's own seeded side stream (v8.35), so both windows of a pair roll the same door and the
// main stream, and every count that hangs on it, is untouched. Never the landmark nearest the first spawn, and never one closer
// than half the farthest, so the cut stays a journey. The clear-spot search below is unchanged.
function sealSpot(map,def){
  var s0=def.spawns[0],best=null,bd=-1,nearest=null,nd=1e9,cands=[],i,L,cx,cy,d;
  for(i=0;i<def.landmarks.length;i++){
    L=def.landmarks[i]; cx=L.x+L.w/2; cy=L.y+L.h/2; d=dist({x:cx,y:cy},s0);
    cands.push({x:cx,y:cy,d:d});
    if(d>bd){ bd=d; best={x:cx,y:cy}; }
    if(d<nd){ nd=d; nearest=cands[cands.length-1]; }
  }
  var far=[]; for(i=0;i<cands.length;i++){ if(cands[i]!==nearest&&cands[i].d>=bd*0.5) far.push(cands[i]); }
  if(far.length>1){ var pick=far[Math.min(far.length-1,Math.floor(rr()*far.length))]; best={x:pick.x,y:pick.y}; }
  if(!best) best={x:WORLD_W*0.5,y:WORLD_H*0.5};
  // The candidate test uses the map DEFINITION only, so the two windows of a pair, which build the same definition from the
  // same seed, agree on the door: furniture and interior partitions are rolled fresh each raid, and a test against the built
  // wall list once walked the seal across four raids on COLD STORAGE.
'@

SubRx @'
  // THE SEAL. Not a container: a door you cut at, in the same place every raid.
'@ @'
  // THE SEAL. Not a container: a door you cut at, rolled to a new landmark each raid (v17.96, his order of 2026-10-03).
'@

SubRx @'
var VER='17.95';
'@ @'
var VER='17.96';
'@

$pat = "(?m)^  now:'v17\.95:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.96: The seal now spawns at a different landmark each raid. Check 17.96 fails on v17.95',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
