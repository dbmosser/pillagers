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

# THE SEAL NEVER SITS ON A CRATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function sealSpot(map,def){
  var C=sealCands(def), n=C.length, MW=(map&&map.walls)||[], ML=(map&&map.locked)||[], t, c, k;
  if(!n) return {x:WORLD_W*0.5,y:WORLD_H*0.5};
  function built(c){
    var r, R;
    for(r=0;r<MW.length;r++){ R=MW[r]; if(R&&c.x>R.x-34&&c.x<R.x+R.w+34&&c.y>R.y-34&&c.y<R.y+R.h+34) return false; }
    for(r=0;r<ML.length;r++){ R=ML[r]; if(R&&c.x>R.x-40&&c.x<R.x+R.w+40&&c.y>R.y-40&&c.y<R.y+R.h+40) return false; }
    return true;
  }
  for(t=0;t<60;t++){ c=C[Math.min(n-1,Math.floor(rr()*n))]; if(built(c)) return {x:c.x,y:c.y}; }
  k=Math.min(n-1,Math.floor(rr()*n));
  for(t=0;t<n;t++){ c=C[(k+t)%n]; if(built(c)) return {x:c.x,y:c.y}; }
  return {x:C[k].x,y:C[k].y};
}
function sealPayout(tier){
'@ @'
// v24.xx (sealfixa), FROM THE SKEPTIC OF HIS ORDER "seal should spawn in random spots" (2026-10-12): THE SEAL NEVER SITS ON A CRATE.
// The random roll above checked the walls and locked rooms the build added but never the containers, which are already placed when
// the seal is rolled. In 17 raids of 300 a crate stood within 46 of the slab (seed 308841: 15 away, hidden under it), and while the
// seal is uncut holding E there cuts the seal instead of searching the crate (the cut owns the key and returns early), so the crate
// gave nothing and the alarm drew the machines. A spot is now refused when any container is within SEAL_CRATE (the 70 cut reach plus
// the 46 search reach), rolled again on the same side stream; if no spot on the map passes, the walls-only rule of v24.82 decides.
var SEAL_CRATE=120;
function sealSpot(map,def,cons){
  var C=sealCands(def), n=C.length, MW=(map&&map.walls)||[], ML=(map&&map.locked)||[], CN=cons||[], t, c, k;
  if(!n) return {x:WORLD_W*0.5,y:WORLD_H*0.5};
  function built(c){
    var r, R;
    for(r=0;r<MW.length;r++){ R=MW[r]; if(R&&c.x>R.x-34&&c.x<R.x+R.w+34&&c.y>R.y-34&&c.y<R.y+R.h+34) return false; }
    for(r=0;r<ML.length;r++){ R=ML[r]; if(R&&c.x>R.x-40&&c.x<R.x+R.w+40&&c.y>R.y-40&&c.y<R.y+R.h+40) return false; }
    return true;
  }
  function crateFree(c){
    for(var r=0;r<CN.length;r++){ var Q=CN[r]; if(Q&&Math.abs(Q.x-c.x)<SEAL_CRATE&&Math.abs(Q.y-c.y)<SEAL_CRATE&&Math.hypot(Q.x-c.x,Q.y-c.y)<SEAL_CRATE) return false; }
    return true;
  }
  for(t=0;t<60;t++){ c=C[Math.min(n-1,Math.floor(rr()*n))]; if(built(c)&&crateFree(c)) return {x:c.x,y:c.y}; }
  k=Math.min(n-1,Math.floor(rr()*n));
  for(t=0;t<n;t++){ c=C[(k+t)%n]; if(built(c)&&crateFree(c)) return {x:c.x,y:c.y}; }
  for(t=0;t<n;t++){ c=C[(k+t)%n]; if(built(c)) return {x:c.x,y:c.y}; }
  return {x:C[k].x,y:C[k].y};
}
function sealPayout(tier){
'@

SubRx @'
    G_SEAL_SPOT=sealSpot(map,FIXED_MAPS[mapIx]);
'@ @'
    G_SEAL_SPOT=sealSpot(map,FIXED_MAPS[mapIx],containers);   // v24.xx (sealfixa): never on top of a crate
'@

SubRx @'
var VER='25.37';
'@ @'
var VER='25.38';
'@

$pat = "(?m)^  now:'v25\.37:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.38: The seal never turns up on top of a crate, so E at a crate always searches it. Check 25.38 fails on v25.37',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
