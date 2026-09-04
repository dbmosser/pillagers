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

# 1. THE DIAL. navBody 0 restores the 12 unit grid, the unpadded door cells and
#    the zero width string-pull, all three at once, for the A/B.
SubRx @'
bldgRuin:0.09,touchSees:1,winWalk:1,furnDoor:1};
'@ @'
bldgRuin:0.09,touchSees:1,winWalk:1,furnDoor:1,navBody:15};
'@

# 2. A DOOR CELL SITS CLEAR OF BOTH JAMBS.
SubRx @'
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
'@ @'
// v11.15: jamb is how far a door cell's centre must sit from either jamb. With
// no jamb a cell one unit inside the gap was a route waypoint, and a body of
// radius 15 steering at it walked into the wall beside the door and stood
// there: building 18 on COLD STORAGE, waypoint at 2728,2696 in a door running
// 2695 to 2759. The search box grows with it so the wider band a body sized
// grid blocks around the door is still reached.
function carveDoors(nav,doors,walls,jamb){
  if(!nav||!doors||!doors.length) return nav;
  jamb=jamb||0;
  var out={w:nav.w,h:nav.h,c:nav.c,blk:new Uint8Array(nav.blk),run:0,opened:0};
  var b=out.blk,gw=out.w,gh=out.h,cc=out.c,i,j,k,_pd=Math.max(NAVPADD,jamb);
  for(i=0;i<doors.length;i++){
    var D=doors[i],_dh=D.w>=D.h;
    var x0=Math.max(0,Math.floor((D.x-_pd)/cc)), x1=Math.min(gw-1,Math.ceil((D.x+D.w+_pd)/cc));
    var y0=Math.max(0,Math.floor((D.y-_pd)/cc)), y1=Math.min(gh-1,Math.ceil((D.y+D.h+_pd)/cc));
    for(j=y0;j<=y1;j++) for(k=x0;k<=x1;k++){
      var id=j*gw+k;
      if(!b[id]) continue;
      var cx=k*cc+cc*0.5, cy=j*cc+cc*0.5, solid=false;
      if(jamb>0){
        if(_dh){ if(cx<D.x+jamb||cx>D.x+D.w-jamb) continue; }
        else { if(cy<D.y+jamb||cy>D.y+D.h-jamb) continue; }
      }
'@

# 3. THE ROUTE GRID IS PADDED FOR THE BODY. map.nav stays at 12 and keeps
#    deciding placement, so nothing in the world moves.
SubRx @'
  var mapNavD=carveDoors(mapNav,BDOORS,walls);
'@ @'
  // v11.15: the ROUTE grid is padded for the body that walks it, 15, while
  // map.nav stays at 12 and keeps deciding what the map places where. A route
  // cell 12 from a wall is a place a 15 unit body cannot stand, and the string
  // pull then handed bodies waypoints on jambs and corners they could see and
  // not reach. Measured: the same three buildings have no route either way.
  var _nb=(CFG.navBody===undefined?15:CFG.navBody);
  var mapNavD=carveDoors(_nb>0?buildNav(walls,_nb):mapNav,BDOORS,walls,_nb);
'@
SubRx @'
  G.map.navD=carveDoors(G.map.nav,G.map.doors,walls);
'@ @'
  var _nb2=(CFG.navBody===undefined?15:CFG.navBody);
  G.map.navD=carveDoors(_nb2>0?buildNav(walls,_nb2):G.map.nav,G.map.doors,walls,_nb2);
'@

# 4. THE PULL TESTS THE BODY'S WIDTH. Three lines, centre and both edges; the
#    edges are only asked when the centre passes, so the cost lands on accepted
#    corners and not on every cell pair.
SubRx @'
function walkClear(ax,ay,bx,by){
  if(!losClear(ax,ay,bx,by,G.map.segs)) return false;
  var dx=bx-ax,dy=by-ay,d=Math.sqrt(dx*dx+dy*dy);
  if(d<1) return true;
  return winHit(ax,ay,dx/d,dy/d,d-2)>=d-2;
}
'@ @'
function walkClear(ax,ay,bx,by){
  if(!losClear(ax,ay,bx,by,G.map.segs)) return false;
  var dx=bx-ax,dy=by-ay,d=Math.sqrt(dx*dx+dy*dy);
  if(d<1) return true;
  return winHit(ax,ay,dx/d,dy/d,d-2)>=d-2;
}
// v11.15: can a body of radius r go straight there. The centre line and the
// two lines a body's width either side of it, edges asked only when the centre
// passes. A zero width line sees past a corner that a 15 unit body catches on:
// building 15 on COLD STORAGE, a pull from 3176,1934 to 3240,1976 grazing the
// end of a partition at 3216,1960, and the crawler stood at 3226,1949 for as
// long as it lived. navBody 0 makes this the plain line again.
function walkClearR(ax,ay,bx,by,r){
  if(!walkClear(ax,ay,bx,by)) return false;
  if(!(r>0)||CFG.navBody===0) return true;
  var dx=bx-ax,dy=by-ay,d=Math.sqrt(dx*dx+dy*dy);
  if(d<1) return true;
  var px=-dy/d*r,py=dx/d*r;
  return walkClear(ax+px,ay+py,bx+px,by+py)&&walkClear(ax-px,ay-py,bx-px,by-py);
}
'@
SubRx @'
function navPath(nav,sx,sy,tx,ty){
'@ @'
function navPath(nav,sx,sy,tx,ty,r){
'@
SubRx @'
      var a=pt(cells[i2]),b2=pt(cells[j]);
      // v11.12: walkClear. A corner that only looks skippable because there is
      // a window in the way is the corner that takes the body out of the door.
      if(walkClear(a.x,a.y,b2.x,b2.y)) break;
'@ @'
      var a=pt(cells[i2]),b2=pt(cells[j]);
      // v11.12: walkClear. A corner that only looks skippable because there is
      // a window in the way is the corner that takes the body out of the door.
      // v11.15: and the body's width, or the pull straightens across corners
      // the body cannot round.
      if(walkClearR(a.x,a.y,b2.x,b2.y,r)) break;
'@

# 5. THE CALLERS HAND OVER THEIR RADIUS, and the shortcut asks the same question.
SubRx @'
      e.path=navPath(G.map.navD||G.map.nav,e.x,e.y,tx,ty);
      e.pathFail=!e.path;
      e.pathI=0; e.pathT=10+rr()*4; e.pathGoal={x:tx,y:ty};
'@ @'
      e.path=navPath(G.map.navD||G.map.nav,e.x,e.y,tx,ty,e.r);
      e.pathFail=!e.path;
      e.pathI=0; e.pathT=10+rr()*4; e.pathGoal={x:tx,y:ty};
'@
SubRx @'
  if(walkClear(e.x,e.y,tx,ty)){ e.path=null; e.pathFail=false; seekPoint(e,tx,ty,spd,dt); return; }
'@ @'
  if(walkClearR(e.x,e.y,tx,ty,e.r)){ e.path=null; e.pathFail=false; seekPoint(e,tx,ty,spd,dt); return; }
'@
SubRx @'
    e.path=navPath(G.map.navD||G.map.nav,e.x,e.y,tx,ty);
    // Whether a route exists is now a question with an exact answer, and the
'@ @'
    e.path=navPath(G.map.navD||G.map.nav,e.x,e.y,tx,ty,e.r);
    // Whether a route exists is now a question with an exact answer, and the
'@

# 6. VERSION STAMPS, both of them.
SubRx @'
var VER='11.14';
'@ @'
var VER='11.15';
'@
SubRx @'
var WHATSNEW_VER='11.14';
'@ @'
var WHATSNEW_VER='11.15';
'@
SubRx @'
  'NOTHING IS PARKED IN A DOORWAY ANY MORE.
'@ @'
  'MACHINES WALK THROUGH THE MIDDLE OF DOORS AND ROUND CORNERS. Their route was planned for a body smaller than they are, so some of them steered at a door jamb or a partition end they could see past and not fit past, and stood there. The route is planned for their own size now.',
  'NOTHING IS PARKED IN A DOORWAY ANY MORE.
'@

# 7. THE WATCHDOG.
SubRx @'
  now:'v11.14: no piece of furniture sits in a doorway. Measured before: 11 of 37 doorways on COLD STORAGE and 35 of 151 on THE COLD MILE held a piece leaving under 30 units for a body that needs 30, so the machines inside could route out and not walk out. A piece landing in a doorway zone slides along the wall until it is clear, with no random number drawn, so the seeded world does not move.',
'@ @'
  now:'v11.15: the route grid is padded for the body that walks it. Routes were planned on a grid padded 12 for bodies of 15, and the string pull straightened them with a zero width line, so a crawler could be handed a waypoint one unit inside a door jamb or grazing the end of a partition, see it, steer at it, and stand against the wall for the rest of the raid. Buildings 15 and 18 on COLD STORAGE, traced. The route grid is padded 15 now, door cells sit 15 clear of both jambs, and the pull tests the body\'s width. map.nav still decides placement at 12, so nothing in the world moves.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
