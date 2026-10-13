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

# THE SEAL CAN BE ANYWHERE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
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
  function defClear(x,y){
    if(x<90||y<90||x>WORLD_W-90||y>WORLD_H-90) return false;
    var q,W2;
    for(q=0;q<def.walls.length;q++){
      W2=def.walls[q];
      if(x>W2.x-30&&x<W2.x+W2.w+30&&y>W2.y-30&&y<W2.y+W2.h+30) return false;
    }
    for(q=0;q<def.buildings.length;q++){
      W2=def.buildings[q];
      if(x>W2.x-30&&x<W2.x+W2.w+30&&y>W2.y-30&&y<W2.y+W2.h+30) return false;
    }
    for(q=0;q<(def.water||[]).length;q++){
      W2=def.water[q];
      if(x>W2.x&&x<W2.x+W2.w&&y>W2.y&&y<W2.y+W2.h) return false;
    }
    return true;
  }
  for(var r=60;r<=760;r+=40){
    for(var a=0;a<16;a++){
      var ang=a*Math.PI/8;
      var x=best.x+Math.cos(ang)*r,y=best.y+Math.sin(ang)*r;
      if(defClear(x,y)) return {x:x,y:y};
    }
  }
  return {x:clamp(best.x,120,WORLD_W-120),y:clamp(best.y,120,WORLD_H-120)};
}
function sealPayout(tier){
'@ @'
// v24.xx (sealrandom), HIS ORDER (2026-10-12): "seal should spawn in random spots, i don't like where it spawns". THE SEAL CAN BE
// ANYWHERE. v17.96 rolled it among the map's far landmarks and then walked rings out from the landmark centre at fixed angles to the
// first clear point, so on COLD STORAGE it stood in the same place or two raid after raid. Now each raid picks uniformly among
// EVERY fair spot of the whole map: a 40 unit grid over the map DEFINITION (sealCands, built once per map), kept where the slab is
// clear of the map edge, walls, building footprints, locked rooms, water and the catwalks, reachable on foot from the spawns (a
// flood over the same grid), at least SEAL_SAFE from EVERY player spawn point and at least SEAL_EXT from every way out. The roll is
// drawn on the raid's own seeded side stream (v8.35, tag 4), so the main stream and every count that hangs on it are untouched, and
// both windows of a pair, which build the same map from the same seed, roll the same door. A pick that lands on something the build
// added (a tree, a fallen rack, the tower rubble) is rolled again on the same stream. DEMO and CAREER use this same roll.
var SEAL_SAFE=450, SEAL_EXT=420, SEAL_STEP=40, SEAL_CANDS=null;
function sealCands(def){
  if(SEAL_CANDS&&SEAL_CANDS.def===def) return SEAL_CANDS.list;
  var W=def.w, H=def.h, F=SEAL_STEP, nx=Math.floor(W/F), ny=Math.floor(H/F), i, j, k, q, x, y, d, ok;
  function inR(L,x,y,m){
    for(var r=0;r<(L||[]).length;r++){ var R=L[r]; if(x>R.x-m&&x<R.x+R.w+m&&y>R.y-m&&y<R.y+R.h+m) return true; }
    return false;
  }
  var open=[], seen=[], list=[], st=[], sp=def.spawns||[], ex=def.extracts||[];
  for(j=0;j<ny;j++) for(i=0;i<nx;i++){
    x=(i+0.5)*F; y=(j+0.5)*F;
    open.push(!(x<54||y<54||x>W-54||y>H-54||inR(def.walls,x,y,14)||inR(def.buildings,x,y,0)||inR(def.water,x,y,0)||inR(def.locked,x,y,0)));
    seen.push(false);
  }
  // the flood: every open cell a player can walk to from a spawn
  for(q=0;q<sp.length;q++){
    var bk=-1, bd=1e18;
    for(k=0;k<open.length;k++){ if(!open[k]) continue; x=((k%nx)+0.5)*F-sp[q].x; y=(Math.floor(k/nx)+0.5)*F-sp[q].y; d=x*x+y*y; if(d<bd){ bd=d; bk=k; } }
    if(bk>=0&&!seen[bk]){ seen[bk]=true; st.push(bk); }
  }
  while(st.length){
    k=st.pop(); i=k%nx; j=Math.floor(k/nx);
    if(i>0&&open[k-1]&&!seen[k-1]){ seen[k-1]=true; st.push(k-1); }
    if(i<nx-1&&open[k+1]&&!seen[k+1]){ seen[k+1]=true; st.push(k+1); }
    if(j>0&&open[k-nx]&&!seen[k-nx]){ seen[k-nx]=true; st.push(k-nx); }
    if(j<ny-1&&open[k+nx]&&!seen[k+nx]){ seen[k+nx]=true; st.push(k+nx); }
  }
  for(k=0;k<open.length;k++){
    if(!seen[k]) continue;
    x=((k%nx)+0.5)*F; y=(Math.floor(k/nx)+0.5)*F;
    if(x<120||y<120||x>W-120||y>H-120) continue;
    if(inR(def.walls,x,y,40)||inR(def.buildings,x,y,40)||inR(def.locked,x,y,40)||inR(def.water,x,y,40)||
       inR(def.plats,x,y,30)||inR(def.ramps,x,y,30)) continue;
    ok=true;
    for(q=0;q<sp.length&&ok;q++){ d=Math.sqrt((sp[q].x-x)*(sp[q].x-x)+(sp[q].y-y)*(sp[q].y-y)); if(d<SEAL_SAFE) ok=false; }
    for(q=0;q<ex.length&&ok;q++){ d=Math.sqrt((ex[q].x-x)*(ex[q].x-x)+(ex[q].y-y)*(ex[q].y-y)); if(d<SEAL_EXT) ok=false; }
    if(ok) list.push({x:x,y:y});
  }
  SEAL_CANDS={def:def,list:list};
  return list;
}
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
'@

SubRx @'
  // THE SEAL. Not a container: a door you cut at, rolled to a new landmark each raid (v17.96, his order of 2026-10-03).
'@ @'
  // THE SEAL. Not a container: a door you cut at, rolled to a fair spot anywhere on the map each raid (sealSpot, his order of 2026-10-12).
'@

SubRx @'
var VER='24.81';
'@ @'
var VER='24.82';
'@

$pat = "(?m)^  now:'v24\.81:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.82: The seal now turns up in a different place each raid, anywhere on the map, never right beside a spawn or a way out. Check 24.82 fails on v24.81',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
