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

# the crowbar breaks windows, cover and walls the way a bullet does (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
if(!G.sim&&!_swHit&&fromPlayer&&!(G.barT>0)) blip('foot');
'@ @'
if(wep.crowbar&&fromPlayer&&!_swHit&&!G.sim&&crowbarWalls(sh,base)) _swHit=true;   // v28.xx (cw-meleebreak): a swing that struck nobody strikes the wall, window or piece of cover in front of it
    if(!G.sim&&!_swHit&&fromPlayer&&!(G.barT>0)) blip('foot');
'@

SubRx @'
function meleeStrike(){
'@ @'
// v28.xx (cw-meleebreak), HIS NOTE (2026-10-18 11:42, in the game): "melee should damge world elements like windows, walls etc". THE CROWBAR BREAKS THINGS, BY THE ROAD A BULLET TAKES.
// A swing that strikes no body strikes what is in front of it: the nearest wall, window, piece of furniture, wreck, tree or building wall along the swing line (the line ahead and four
// more, to 0.8 rad either side, the middle one first), within CROWBAR_WALL_R (46) of him. The blow is CROWBAR_WALL (40) and goes through damageWall, the one door every wall damage
// uses, so a thing breaks exactly as one shot does: wallHp decides what it is (a window 25, furniture 60, a tree 120, a wreck 150, a building wall 320, terrain 700), its bar shows,
// the geometry is rebuilt (walls, sight, routing), the debris and the crash are the same, and in a shared raid the window of player 2 asks the host, which breaks it and tells every
// window (netWallAsk, netWallGone). What a bullet cannot break stays whole: the map edge, a locked room, a keyed door, a stronghold shell (wallHp is null), and the destruction setting
// (CFG.destruct 0) protects glass too; those only ring (a clank and a few sparks, nothing counted). A body in the blow takes it instead (the wall behind is not struck). Breaking
// something is loud (CROWBAR_WALL_NOISE, 340, a pistol is 330), a plain hit is not. Live play only; no seeded draw but the ones damageWall already makes when a wall falls.
var CROWBAR_WALL=40, CROWBAR_WALL_R=46, CROWBAR_WALL_NOISE=340, CROWBAR_RAYS=[0,0.4,-0.4,0.8,-0.8];
function rayRect(px,py,ux,uy,w,maxT){   // distance along the ray to where it enters the rectangle (0 when it starts inside), or -1
  var t0=0, t1=maxT, a, b, lo, hi;
  if(Math.abs(ux)<1e-9){ if(px<w.x||px>w.x+w.w) return -1; }
  else { a=(w.x-px)/ux; b=(w.x+w.w-px)/ux; lo=Math.min(a,b); hi=Math.max(a,b); if(lo>t0) t0=lo; if(hi<t1) t1=hi; if(t0>t1) return -1; }
  if(Math.abs(uy)<1e-9){ if(py<w.y||py>w.y+w.h) return -1; }
  else { a=(w.y-py)/uy; b=(w.y+w.h-py)/uy; lo=Math.min(a,b); hi=Math.max(a,b); if(lo>t0) t0=lo; if(hi<t1) t1=hi; if(t0>t1) return -1; }
  return t0;
}
function crowbarWallAt(p,base){
  var k, a, ux, uy, L, i, w, t, best, bt;
  if(!G||!G.wgrid||!p) return null;
  for(k=0;k<CROWBAR_RAYS.length;k++){
    a=base+CROWBAR_RAYS[k]; ux=Math.cos(a); uy=Math.sin(a);
    L=wallsNear(G.wgrid,p.x+ux*CROWBAR_WALL_R*0.5,p.y+uy*CROWBAR_WALL_R*0.5,CROWBAR_WALL_R);
    best=null; bt=CROWBAR_WALL_R+1;
    for(i=0;i<L.length;i++){ w=L[i]; t=rayRect(p.x,p.y,ux,uy,w,CROWBAR_WALL_R); if(t>=0&&t<bt){ bt=t; best=w; } }
    if(best) return {w:best,x:p.x+ux*bt,y:p.y+uy*bt};
  }
  return null;
}
function crowbarWalls(p,base){
  var h=crowbarWallAt(p,base), w;
  if(!h||!G||G.sim) return false;
  w=h.w;
  if(CFG.destruct===0||wallHp(w)===null){ spark(h.x,h.y,'#cdd6dd',5,150); sfx('clank',h.x,h.y,matOf(w)); return true; }   // it rings and holds
  damageWall(w,CROWBAR_WALL*pwrMul('dmg',true),h.x,h.y);
  spark(h.x,h.y,'#ffd9a0',6,170); if(G.puffs) G.puffs.push({x:h.x,y:h.y,t:0,life:.22,c:'#8a939c',r:9});
  sfx('clank',h.x,h.y,matOf(w)); G.shake=Math.max(G.shake||0,1.4); if(G.barT>0) meleeFoley('hit',h.x,h.y);   // the crowbar thuds as it lands
  if(w.hpLeft!==undefined&&w.hpLeft<=0) ping(h.x,h.y,CROWBAR_WALL_NOISE,false,false,'player','fire');   // it went: glass and brick are loud
  return true;
}
function meleeStrike(){
'@

SubRx @'
var VER='31.21';
'@ @'
var VER='31.22';
'@

$pat = "(?m)^  now:'v31\.21:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.22: the crowbar breaks windows, cover and walls the way a bullet does: a window in one swing, a building wall in about eight. Check 31.22 fails on v31.21',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
