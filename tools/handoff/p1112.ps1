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

# 1. THE DIAL. winWalk 0 restores the old behaviour so both can run in one build.
SubRx @'
bldgRuin:0.09,touchSees:1};
'@ @'
bldgRuin:0.09,touchSees:1,winWalk:1};
'@

# 2. THE MAP BUILD KEEPS THE WINDOWS IT SKIPS.
SubRx @'
  var segs=[];
  for(var m2=0;m2<walls.length;m2++){ var w2=walls[m2];
    if(w2.win) continue;
    segs.push({x1:w2.x,y1:w2.y,x2:w2.x+w2.w,y2:w2.y});
    segs.push({x1:w2.x+w2.w,y1:w2.y,x2:w2.x+w2.w,y2:w2.y+w2.h});
    segs.push({x1:w2.x+w2.w,y1:w2.y+w2.h,x2:w2.x,y2:w2.y+w2.h});
    segs.push({x1:w2.x,y1:w2.y+w2.h,x2:w2.x,y2:w2.y});
  }
'@ @'
  // v11.12: the window segments are kept rather than dropped. A window is
  // see-through and is NOT walk-through, and every movement test in this game
  // used to read the SIGHT list, which skips them.
  var segs=[],wsegs=[];
  for(var m2=0;m2<walls.length;m2++){ var w2=walls[m2];
    if(w2.win){
      wsegs.push({x1:w2.x,y1:w2.y,x2:w2.x+w2.w,y2:w2.y});
      wsegs.push({x1:w2.x+w2.w,y1:w2.y,x2:w2.x+w2.w,y2:w2.y+w2.h});
      wsegs.push({x1:w2.x+w2.w,y1:w2.y+w2.h,x2:w2.x,y2:w2.y+w2.h});
      wsegs.push({x1:w2.x,y1:w2.y+w2.h,x2:w2.x,y2:w2.y});
      continue;
    }
    segs.push({x1:w2.x,y1:w2.y,x2:w2.x+w2.w,y2:w2.y});
    segs.push({x1:w2.x+w2.w,y1:w2.y,x2:w2.x+w2.w,y2:w2.y+w2.h});
    segs.push({x1:w2.x+w2.w,y1:w2.y+w2.h,x2:w2.x,y2:w2.y+w2.h});
    segs.push({x1:w2.x,y1:w2.y+w2.h,x2:w2.x,y2:w2.y});
  }
'@

# 3. AND HANDS THEM TO THE MAP.
SubRx @'
    navD:mapNavD,doors:BDOORS.slice(0)};
'@ @'
    navD:mapNavD,doors:BDOORS.slice(0),wsegs:wsegs};
'@

# 4. THE REBUILD AFTER A WALL COMES DOWN KEEPS THEM TOO. A window has 25 hit
#    points and breaks, so this list goes stale the moment one is shot out.
SubRx @'
  var walls=G.map.walls, segs=[];
  for(var i=0;i<walls.length;i++){ var w2=walls[i];
    if(w2.win) continue;
    segs.push({x1:w2.x,y1:w2.y,x2:w2.x+w2.w,y2:w2.y});
    segs.push({x1:w2.x+w2.w,y1:w2.y,x2:w2.x+w2.w,y2:w2.y+w2.h});
    segs.push({x1:w2.x+w2.w,y1:w2.y+w2.h,x2:w2.x,y2:w2.y+w2.h});
    segs.push({x1:w2.x,y1:w2.y+w2.h,x2:w2.x,y2:w2.y});
  }
  G.map.segs=segs;
  G.grid=buildSegGrid(segs,WORLD_W,WORLD_H);
'@ @'
  var walls=G.map.walls, segs=[], wsegs=[];
  for(var i=0;i<walls.length;i++){ var w2=walls[i];
    if(w2.win){
      wsegs.push({x1:w2.x,y1:w2.y,x2:w2.x+w2.w,y2:w2.y});
      wsegs.push({x1:w2.x+w2.w,y1:w2.y,x2:w2.x+w2.w,y2:w2.y+w2.h});
      wsegs.push({x1:w2.x+w2.w,y1:w2.y+w2.h,x2:w2.x,y2:w2.y+w2.h});
      wsegs.push({x1:w2.x,y1:w2.y+w2.h,x2:w2.x,y2:w2.y});
      continue;
    }
    segs.push({x1:w2.x,y1:w2.y,x2:w2.x+w2.w,y2:w2.y});
    segs.push({x1:w2.x+w2.w,y1:w2.y,x2:w2.x+w2.w,y2:w2.y+w2.h});
    segs.push({x1:w2.x+w2.w,y1:w2.y+w2.h,x2:w2.x,y2:w2.y+w2.h});
    segs.push({x1:w2.x,y1:w2.y+w2.h,x2:w2.x,y2:w2.y});
  }
  G.map.segs=segs;
  G.map.wsegs=wsegs;
  G.wingrid=buildSegGrid(wsegs,WORLD_W,WORLD_H);
  G.grid=buildSegGrid(segs,WORLD_W,WORLD_H);
'@

# 5. THE RAID CARRIES A GRID FOR THEM, so the walk test is a cell lookup and not
#    a scan of 488 segments per body per frame.
SubRx @'
  var g={sim:!!sim,seed:seed,grid:buildSegGrid(map.segs,WORLD_W,WORLD_H),wgrid:buildWallGrid(map.walls,WORLD_W,WORLD_H),
'@ @'
  var g={sim:!!sim,seed:seed,grid:buildSegGrid(map.segs,WORLD_W,WORLD_H),wingrid:buildSegGrid(map.wsegs||[],WORLD_W,WORLD_H),wgrid:buildWallGrid(map.walls,WORLD_W,WORLD_H),
'@

# 6. THE WALK TEST ITSELF.
SubRx @'
    segs=segsBox(G.grid,(ax<bx?ax:bx),(ay<by?ay:by),(ax<bx?bx:ax),(ay<by?by:ay));
  return rayHit(ax,ay,dx,dy,segs,d-2)>=d-2;
}
'@ @'
    segs=segsBox(G.grid,(ax<bx?ax:bx),(ay<by?ay:by),(ax<bx?bx:ax),(ay<by?by:ay));
  return rayHit(ax,ay,dx,dy,segs,d-2)>=d-2;
}
// A WINDOW IS SEE-THROUGH AND IT IS NOT WALK-THROUGH, v11.12. Every movement
// decision in this game asked the SIGHT geometry whether the way ahead was
// clear, and map.segs skips windows on purpose. So a machine standing inside a
// building with a window facing the player was told the line was clear, threw
// its route away, walked into the glass and stood there for the rest of the
// raid: collide() has never skipped a window, so it could not take one more
// step in that direction as long as it lived.
// MEASURED on COLD STORAGE at seed 4242, one crawler placed in each building
// with the player outside it and chase forced, twenty seconds each: buildings
// 6, 8, 9 and 10 all HAD a route out and not one of them got closer than 240
// units to a player standing 380 to 500 away. Traced frame by frame, the
// crawler in building 8 walked straight west to x 2551, which is a window in
// the west wall, and then moved 0.07 to 0.98 units a frame, forever.
// Refusing the shortcut is the whole fix: buildNav reads the WALL list and not
// the segment list, so the routing grid has always treated a window as solid,
// and a body denied the straight line falls through to the router and walks out
// of the door. winWalk 0 restores the old behaviour so both can be run in one
// build, which is what the v11.12 check does.
function winHit(px,py,dx,dy,maxT){
  if(CFG.winWalk===0) return maxT;
  var W=(G&&G.map)?G.map.wsegs:null;
  if(!W||!W.length) return maxT;
  var segs=W;
  if(G.wingrid&&G.wingrid.segs===W){
    var qx=px+dx*maxT,qy=py+dy*maxT;
    segs=segsBox(G.wingrid,(px<qx?px:qx),(py<qy?py:qy),(px<qx?qx:px),(py<qy?qy:py));
  }
  return rayHit(px,py,dx,dy,segs,maxT);
}
// Can a BODY go straight there. The two ray queries run one after the other on
// purpose: segsBox hands back one shared scratch array, so holding the first
// answer while asking the second question would corrupt it.
function walkClear(ax,ay,bx,by){
  if(!losClear(ax,ay,bx,by,G.map.segs)) return false;
  var dx=bx-ax,dy=by-ay,d=Math.sqrt(dx*dx+dy*dy);
  if(d<1) return true;
  return winHit(ax,ay,dx/d,dy/d,d-2)>=d-2;
}
function rayWalkG(px,py,dx,dy,maxT){
  var t=rayHitG(px,py,dx,dy,maxT),t2=winHit(px,py,dx,dy,maxT);
  return t2<t?t2:t;
}
'@

# 7. THE SHORTCUT THAT THREW THE ROUTE AWAY.
SubRx @'
  if(losClear(e.x,e.y,tx,ty,G.map.segs)){ e.path=null; e.pathFail=false; seekPoint(e,tx,ty,spd,dt); return; }
'@ @'
  // v11.12: walkClear, not losClear. Seeing the target through a window is not
  // a reason to drop a route, because the body cannot follow that line.
  if(walkClear(e.x,e.y,tx,ty)){ e.path=null; e.pathFail=false; seekPoint(e,tx,ty,spd,dt); return; }
'@

# 8. AND THE WALL HUG, which left the wall the moment it could SEE past it.
SubRx @'
    if(rayHitG(e.x,e.y,Math.cos(la),Math.sin(la),probe)>=probe-1&&d0<(e.slideD||1e9)-4){ e.slideT=0; e.slideFlip=false; }
'@ @'
    if(rayWalkG(e.x,e.y,Math.cos(la),Math.sin(la),probe)>=probe-1&&d0<(e.slideD||1e9)-4){ e.slideT=0; e.slideFlip=false; }
'@

# 9. AND THE SIDE IT PICKS, which counted a window as room to walk into.
SubRx @'
      var lft=rayHitG(e.x,e.y,Math.cos(ga-1.5708),Math.sin(ga-1.5708),420);
      var rgt=rayHitG(e.x,e.y,Math.cos(ga+1.5708),Math.sin(ga+1.5708),420);
'@ @'
      var lft=rayWalkG(e.x,e.y,Math.cos(ga-1.5708),Math.sin(ga-1.5708),420);
      var rgt=rayWalkG(e.x,e.y,Math.cos(ga+1.5708),Math.sin(ga+1.5708),420);
'@

# 10. VERSION STAMPS, both of them.
SubRx @'
var VER='11.11';
'@ @'
var VER='11.12';
'@
SubRx @'
var WHATSNEW_VER='11.11';
'@ @'
var WHATSNEW_VER='11.12';
'@
SubRx @'
  'NOTHING IN THE GAME CHANGED IN THIS BUILD. It records a limit of the robot that tests it: the robot never crouches and never hides, so no number it has ever produced describes playing carefully. The crawler bug fixed two builds ago could only ever have reached a person.',
'@ @'
  'MACHINES NO LONGER WALK INTO WINDOWS. One standing inside a building could see you through the glass, decide the way was clear, walk at the window and stay pressed against it for the rest of the raid instead of coming out of the door. On the first map, four of the buildings did this. They route round now.',
  'NOTHING IN THE GAME CHANGED IN THIS BUILD. It records a limit of the robot that tests it: the robot never crouches and never hides, so no number it has ever produced describes playing carefully. The crawler bug fixed two builds ago could only ever have reached a person.',
'@

# 11. THE WATCHDOG.
SubRx @'
  now:'v11.11: the fresh profile hour, which the alpha needs and nobody had done. A friend arrives with no runs, no stash, one gun and 600 credits; every station on the floor was walked up to and pressed on exactly that profile. Nothing threw, nothing opened empty, nothing did nothing, and the stash reads right with nothing in it. Three of my own probes cried wolf on the way, and the check that ships is written so nobody repeats them.',
  next:'His grades on the new map looks, menus and gun rarity, and his ruling on the mile-vs-cold shape the board now shows'
'@ @'
  now:'v11.12: a window is see-through and it is not walk-through, and every movement test in the game had been reading the sight geometry, which skips windows. A machine inside a building saw you through the glass, threw its route away, walked into the window and stood there. Measured on COLD STORAGE at seed 4242: four buildings had a route out and none of their crawlers got within 240 units. Bodies now ask whether they can WALK the line, not whether they can SEE it.',
  next:'His grades on the new map looks, menus and gun rarity, and his ruling on the mile-vs-cold shape the board now shows'
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
