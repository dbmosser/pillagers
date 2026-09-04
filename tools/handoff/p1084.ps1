$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# ============ HIS NOTE: A CRAWLER GOT CLOSE AND DID NOT HURT ME.
# ============
# ============ REPRODUCED: stand outside a building with a crawler inside it, in
# ============ chase with full alert, and after TWENTY SECONDS it has never come
# ============ closer than 97 units and you have taken zero damage. The same
# ============ crawler in the open closes to a gap of 9.6 and kills in ten
# ============ seconds; inside the same building as you it closes to 9.4 and
# ============ kills. The attack, the reach, the cooldown and the states are all
# ============ fine. It cannot get out.
# ============
# ============ THE ROUTER SAYS SO: pathFail 1 for the whole chase, so it falls
# ============ through to the local wall hug and bumps around indoors.
# ============
# ============ CAUSE: the nav grid is 16 unit cells and every wall is inflated by
# ============ 12 before cells are marked. A doorway is a 64 unit gap in a 16
# ============ unit wall, so 40 units survive, two and a half cells, and anything
# ============ that narrows it further seals on the grid a door that is open in
# ============ the world. Counted at seed 4242, buildings a machine cannot route
# ============ out of: 4 of 13 on COLD STORAGE, 15 of 59 on THE COLD MILE.
# ============
# ============ AND THE FIRST CUT OF THIS FIX WAS WRONG, CAUGHT BY THE HARNESS.
# ============ Carving the doorways into map.nav ITSELF changed what the map
# ============ places, because navReach reads the same grid to decide which
# ============ container and cache spots anything can reach. Entity and container
# ============ COUNTS stayed identical, which is what I checked and why I nearly
# ============ shipped it, but v10.46 went red: the operator's jersey read 3 pale
# ============ pixels against 21, because the scene around him had moved.
# ============
# ============ SO THE DOORS GET THEIR OWN GRID. map.nav is untouched and keeps
# ============ deciding what is reachable when the map is filled; map.navD is a
# ============ copy with the doorways opened and it is what bodies ROUTE on. A
# ============ cell is opened only where its centre is outside every wall with no
# ============ padding at all, so no route can be cut through anything solid.
SubRx @'
function makeBuilding(x,y,w,h,out,d,bid,forcePlan){
  var t=16,gap=64;
'@ @'
// v10.84: every doorway this function cuts, recorded, so the routing grid can be
// told where the holes are. Reset by the caller before it builds its buildings.
var BDOORS=[];
// A COPY of a nav grid with the doorways opened. The original is left alone
// because navReach reads it to decide what the map can place where, and opening
// cells there moves the contents of the world.
function carveDoors(nav,doors,walls){
  if(!nav||!doors||!doors.length) return nav;
  var out={w:nav.w,h:nav.h,c:nav.c,blk:new Uint8Array(nav.blk),run:0,opened:0};
  var b=out.blk,gw=out.w,gh=out.h,cc=out.c,i,j,k;
  for(i=0;i<doors.length;i++){
    var D=doors[i];
    var x0=Math.max(0,Math.floor((D.x-NAVPADD)/cc)), x1=Math.min(gw-1,Math.ceil((D.x+D.w+NAVPADD)/cc));
    var y0=Math.max(0,Math.floor((D.y-NAVPADD)/cc)), y1=Math.min(gh-1,Math.ceil((D.y+D.h+NAVPADD)/cc));
    for(j=y0;j<=y1;j++) for(k=x0;k<=x1;k++){
      var id=j*gw+k;
      if(!b[id]) continue;
      var cx=k*cc+cc*0.5, cy=j*cc+cc*0.5, solid=false;
      for(var q=0;q<walls.length;q++){
        var W=walls[q];
        if(cx>W.x&&cx<W.x+W.w&&cy>W.y&&cy<W.y+W.h){ solid=true; break; }
      }
      if(!solid){ b[id]=0; out.opened++; }
    }
  }
  return out;
}
function makeBuilding(x,y,w,h,out,d,bid,forcePlan){
  var t=16,gap=64;
  function door(a,b,c,e){ BDOORS.push({x:a,y:b,w:c,h:e}); }
'@
SubRx @'
  if(doors[0]){var a1=x+rnd(30,w-30-gap);seg(x,y,a1-x,t);seg(a1+gap,y,x+w-(a1+gap),t);} else seg(x,y,w,t);
  if(doors[1]){var a2=x+rnd(30,w-30-gap);seg(x,y+h-t,a2-x,t);seg(a2+gap,y+h-t,x+w-(a2+gap),t);} else seg(x,y+h-t,w,t);
  if(doors[2]){var a3=y+rnd(30,h-30-gap);seg(x,y,t,a3-y);seg(x,a3+gap,t,y+h-(a3+gap));} else seg(x,y,t,h);
  if(doors[3]){var a4=y+rnd(30,h-30-gap);seg(x+w-t,y,t,a4-y);seg(x+w-t,a4+gap,t,y+h-(a4+gap));} else seg(x+w-t,y,t,h);
'@ @'
  if(doors[0]){var a1=x+rnd(30,w-30-gap);seg(x,y,a1-x,t);seg(a1+gap,y,x+w-(a1+gap),t);door(a1,y,gap,t);} else seg(x,y,w,t);
  if(doors[1]){var a2=x+rnd(30,w-30-gap);seg(x,y+h-t,a2-x,t);seg(a2+gap,y+h-t,x+w-(a2+gap),t);door(a2,y+h-t,gap,t);} else seg(x,y+h-t,w,t);
  if(doors[2]){var a3=y+rnd(30,h-30-gap);seg(x,y,t,a3-y);seg(x,a3+gap,t,y+h-(a3+gap));door(x,a3,t,gap);} else seg(x,y,t,h);
  if(doors[3]){var a4=y+rnd(30,h-30-gap);seg(x+w-t,y,t,a4-y);seg(x+w-t,a4+gap,t,y+h-(a4+gap));door(x+w-t,a4,t,gap);} else seg(x+w-t,y,t,h);
'@
SubRx @'
  var buildings=[];
  var _wallsBeforeBuildings=walls.length;
'@ @'
  var buildings=[];
  BDOORS=[];                                   // v10.84: this map's doorways
  var _wallsBeforeBuildings=walls.length;
'@
SubRx @'
  var segs=[];
  for(var m2=0;m2<walls.length;m2++){ var w2=walls[m2];
'@ @'
  // v10.84: the routing grid, doorways opened. map.nav is deliberately NOT this
  // one: it decides what the map can place where, and opening cells there moves
  // the contents of the world.
  var mapNavD=carveDoors(mapNav,BDOORS,walls);
  var segs=[];
  for(var m2=0;m2<walls.length;m2++){ var w2=walls[m2];
'@
SubRx @'
    spawns:def.spawns,extracts:extractsOutside(def.extracts,buildings),nav:mapNav};
'@ @'
    spawns:def.spawns,extracts:extractsOutside(def.extracts,buildings),nav:mapNav,
    navD:mapNavD,doors:BDOORS.slice(0)};
'@

# ---- Bodies route on the carved grid. Two call sites, the far-body branch and
# ---- the near one, and nothing else in the file asks navPath for a route.
SubRx @'
      e.path=navPath(G.map.nav,e.x,e.y,tx,ty);
      e.pathFail=!e.path;
      e.pathI=0; e.pathT=10+rr()*4; e.pathGoal={x:tx,y:ty};
'@ @'
      e.path=navPath(G.map.navD||G.map.nav,e.x,e.y,tx,ty);
      e.pathFail=!e.path;
      e.pathI=0; e.pathT=10+rr()*4; e.pathGoal={x:tx,y:ty};
'@
SubRx @'
    e.path=navPath(G.map.nav,e.x,e.y,tx,ty);
'@ @'
    e.path=navPath(G.map.navD||G.map.nav,e.x,e.y,tx,ty);
'@
# ---- And when a wall comes down mid raid both grids are rebuilt, or the routing
# ---- one goes stale the first time somebody blows a hole in something.
SubRx @'
  G.map.nav=buildNav(walls);
'@ @'
  G.map.nav=buildNav(walls);
  G.map.navD=carveDoors(G.map.nav,G.map.doors,walls);
'@

SubRx @'
var VER='10.83';
'@ @'
var VER='10.84';
'@
SubRx @'
  now:'v10.83: the map tells you which buildings have fallen. A destroyed building sat at 64 to 69 brightness against 73 to 82 for the standing ones near it, a gap of 3.6 where the standing buildings vary by 9.4 among themselves, so it was only darker by accident. It is hatched and broken-outlined now.',
'@ @'
  now:'v10.84: your crawler note, and it was worse than a crawler. A machine inside a building could not find its way out to you: twenty seconds, never closer than 97 units, no damage, while the same crawler in the open kills in ten. The doorways were sealed on the routing grid, not in the world.',
'@
SubRx @'
  'THE MAP MARKS THE FALLEN BUILDINGS.
'@ @'
  'MACHINES CAN FIND THE DOOR NOW. One inside a building could not work out how to get out to you, so it bumped about indoors while you stood outside untouched. Nineteen buildings across the two maps were traps like that and eleven still are, but if something is in there with you it is far likelier to come.',
  'THE MAP MARKS THE FALLEN BUILDINGS.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
