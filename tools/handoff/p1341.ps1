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

# HIS REPORT OF 2026-09-13, two screenshots: THE RAISED DECKS ARE GONE.
#
# The DOCK CATWALK on COLD STORAGE still held him short of its edges and would not
# let him walk north off it after v12.47 moved the kerb paint, and there was another
# on the map. His words: get rid of it, start over if you have to. Every raised deck
# (two on COLD STORAGE, seven on THE COLD MILE) and every ramp is taken out.
#
# WHERE: at the very end of buildRaid, after every container, machine and pillager
# has been placed. Placement tests the wall list (freeSpot, spotFree), so taking the
# deck edges out during the map build would move every roll after the first one that
# came near a kerb. Here nothing downstream rolls, so no seed changes. The deck and
# ramp lists are emptied just before the ground bake so neither is painted, which
# draws nothing. Then segments, the three grids, the placement grid and the routing
# grid are rebuilt the way a destroyed wall rebuilds them.
# decks 1 (a fixture dial) restores the decks.
SubRx @'
function damageWall(w,amt,x,y){
'@ @'
// v13.41, HIS REPORT OF 2026-09-13: THE RAISED DECKS ARE GONE. A deck edge is a
// wall tagged ledge; it held him short of what he could see and would not let him
// off the catwalk, so every one is taken out of a finished raid, with the deck and
// ramp lists, and the ground where they stood is plain ground. Called at the end of
// buildRaid, after every placement roll, so no container or machine moves on any
// seed. The same rebuild a destroyed wall gets, done on the raid being built.
function clearDecks(g){
  var map=g.map, walls=map.walls, cut=0, i;
  for(i=walls.length-1;i>=0;i--) if(walls[i]&&walls[i].ledge){ walls.splice(i,1); cut++; }
  map.plats=[]; map.ramps=[];
  map.platAt=function(){ return null; };
  map.liftAt=function(){ return 0; };
  if(!cut) return 0;
  var segs=[], wsegs=[];
  for(i=0;i<walls.length;i++){ var w2=walls[i], L=w2.win?wsegs:segs;
    L.push({x1:w2.x,y1:w2.y,x2:w2.x+w2.w,y2:w2.y});
    L.push({x1:w2.x+w2.w,y1:w2.y,x2:w2.x+w2.w,y2:w2.y+w2.h});
    L.push({x1:w2.x+w2.w,y1:w2.y+w2.h,x2:w2.x,y2:w2.y+w2.h});
    L.push({x1:w2.x,y1:w2.y+w2.h,x2:w2.x,y2:w2.y});
  }
  map.segs=segs; map.wsegs=wsegs;
  g.grid=buildSegGrid(segs,WORLD_W,WORLD_H);
  g.wingrid=buildSegGrid(wsegs,WORLD_W,WORLD_H);
  g.wgrid=buildWallGrid(walls,WORLD_W,WORLD_H);
  g.vseg=map.segs;
  map._fsGrid=null;
  map.nav=buildNav(walls);
  var nb=(CFG.navBody===undefined?15:CFG.navBody);
  map.navD=carveDoors(nb>0?buildNav(walls,nb):map.nav,map.doors,walls,nb);
  return cut;
}
function damageWall(w,amt,x,y){
'@

SubRx @'
  var g={sim:!!sim,seed:seed,
'@ @'
  if(CFG.decks!==1){ map.plats=[]; map.ramps=[]; }   // v13.41: emptied before the ground bake below, which draws nothing from them
  var g={sim:!!sim,seed:seed,
'@

SubRx @'
    while(carried<ISSUED_HEALS){ g.bag.push('bandage'); carried++; }
  }
  return g;
'@ @'
    while(carried<ISSUED_HEALS){ g.bag.push('bandage'); carried++; }
  }
  if(CFG.decks!==1) clearDecks(g);   // v13.41: last, after every placement roll
  return g;
'@

SubRx @'
  'THE EDGE OF A RAISED DECK IS WHERE IT LOOKS. Catwalk and gantry edges were painted like building walls, 26 units taller than the thing you actually collide with, so a third of the deck you were standing on was covered by a wall you could walk through, you stopped short of the edge you could see, and standing at the near side hid you behind it.',
'@ @'
'@

SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'THE RAISED DECKS ARE GONE. The catwalks and gantries kept stopping you short of their edges and trapping you on them, so every one has been taken out of both sectors. Where a deck stood is plain ground you can walk straight across.',
'@

SubRx @'
var WHATSNEW_VER='13.34';
'@ @'
var WHATSNEW_VER='13.41';
'@

SubRx @'
var VER='13.40';
'@ @'
var VER='13.41';
'@

$pat = "(?m)^  now:'v13\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v13.41: THE RAISED DECKS ARE GONE. His report of 2026-09-13 with two screenshots: the DOCK CATWALK on COLD STORAGE still stopped him short of its edges and would not let him walk off it, and another deck was broken elsewhere; he asked for them gone. Every deck edge wall and every deck and ramp is taken out at the very end of the raid build, after every container and machine has been placed, so no seed moves; the deck and ramp lists are emptied before the ground bake so neither is painted, and segments, grids and routing are rebuilt the way a destroyed wall rebuilds them. Check 13.41 finds no deck, ramp or edge wall on either sector, walks him north across where the DOCK CATWALK stood, and requires every container and machine where it was with the decks restored; it fails on v13.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
