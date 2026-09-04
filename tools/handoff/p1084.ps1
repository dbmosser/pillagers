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
# ============ REPRODUCED, and it is worse than a crawler. Stand outside a
# ============ building with a crawler inside it, in chase, alert full, and after
# ============ TWENTY SECONDS it has never come closer than 97 units and you have
# ============ taken zero damage. The same crawler in the open closes to a gap of
# ============ 9.6 and kills you in ten seconds, and inside the same building as
# ============ you it closes to 9.4 and kills you. So it is not the attack, the
# ============ reach, the cooldown or the states: it is that it cannot get out.
# ============
# ============ THE ROUTER SAYS THERE IS NO ROUTE. Watched frame by frame, the
# ============ crawler carries path null and pathFail 1 for the whole chase, so
# ============ it falls through to the local wall hug and bumps around inside
# ============ forever while its alert decays.
# ============
# ============ WHY: the nav grid is 16 unit cells and every wall is inflated by
# ============ 12 before the cells are marked. A doorway is a 64 unit gap in a 16
# ============ unit wall, so the two runs either side eat 12 each and what is left
# ============ is 40 units, two and a half cells; when anything narrows it
# ============ further, furniture, a landmark wall, a split run, the last free
# ============ cell disappears and a door that a body can WALK through becomes a
# ============ door no body can ROUTE through. Measured on COLD STORAGE at seed
# ============ 4242: FIVE of twenty buildings are boxes a machine cannot path out
# ============ of.
# ============
# ============ THE FIX opens the doorways on the grid and nothing else. Each
# ============ building records the gaps it cut, and after the grid is built a
# ============ cell inside one of those gaps is unblocked ONLY IF ITS CENTRE IS
# ============ GENUINELY OUTSIDE EVERY WALL, tested against the real rectangles
# ============ with no padding at all. So this can never open a route through
# ============ solid geometry: it can only stop the padding from sealing a hole
# ============ that is really there.
SubRx @'
function makeBuilding(x,y,w,h,out,d,bid,forcePlan){
  var t=16,gap=64;
'@ @'
// v10.84: every doorway this function cuts, recorded, so the pathing grid can be
// told where the holes are. Reset by the caller before it builds its buildings.
var BDOORS=[];
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
  // v10.84: OPEN THE DOORWAYS ON THE PATHING GRID. See the long note in
  // DESIGN.md. A cell is only unblocked when its centre is outside EVERY wall
  // rectangle with no padding, so this cannot cut a route through anything
  // solid; it only stops the 12 unit padding from sealing a hole that is real.
  var _doorLog={doors:BDOORS.length,cells:0};
  if(mapNav&&BDOORS.length){
    var _nb=mapNav.blk,_nw=mapNav.w,_nh=mapNav.h,_nc=mapNav.c;
    for(var _di=0;_di<BDOORS.length;_di++){
      var _D=BDOORS[_di];
      var _dx0=Math.max(0,Math.floor((_D.x-NAVPADD)/_nc)), _dx1=Math.min(_nw-1,Math.ceil((_D.x+_D.w+NAVPADD)/_nc));
      var _dy0=Math.max(0,Math.floor((_D.y-NAVPADD)/_nc)), _dy1=Math.min(_nh-1,Math.ceil((_D.y+_D.h+NAVPADD)/_nc));
      for(var _cy2=_dy0;_cy2<=_dy1;_cy2++) for(var _cx2=_dx0;_cx2<=_dx1;_cx2++){
        var _cid=_cy2*_nw+_cx2;
        if(!_nb[_cid]) continue;
        var _pcx=_cx2*_nc+_nc*0.5, _pcy=_cy2*_nc+_nc*0.5;
        var _solid=false;
        for(var _wq2=0;_wq2<walls.length;_wq2++){
          var _WQ2=walls[_wq2];
          if(_pcx>_WQ2.x&&_pcx<_WQ2.x+_WQ2.w&&_pcy>_WQ2.y&&_pcy<_WQ2.y+_WQ2.h){ _solid=true; break; }
        }
        if(!_solid){ _nb[_cid]=0; _doorLog.cells++; }
      }
    }
  }
  var segs=[];
  for(var m2=0;m2<walls.length;m2++){ var w2=walls[m2];
'@
SubRx @'
    roadRects:roadRects,roadDashes:roadDashes,cullLog:_cullLog,ruinLog:_ruinLog,
'@ @'
    roadRects:roadRects,roadDashes:roadDashes,cullLog:_cullLog,ruinLog:_ruinLog,doorLog:_doorLog,
'@

SubRx @'
var VER='10.83';
'@ @'
var VER='10.84';
'@
SubRx @'
  now:'v10.83: the map tells you which buildings have fallen. A destroyed building sat at 64 to 69 brightness against 73 to 82 for the standing ones near it, a gap of 3.6 where the standing buildings vary by 9.4 among themselves, so it was only darker by accident. It is hatched and broken-outlined now.',
'@ @'
  now:'v10.84: your crawler note, and it was worse than a crawler. A machine inside a building could not find its way out to you: five of the twenty buildings on COLD STORAGE were boxes nothing could path out of, so it bumped about inside while you stood outside untouched. The doorways were sealed on the pathing grid, not in the world.',
'@
SubRx @'
  'THE MAP MARKS THE FALLEN BUILDINGS.
'@ @'
  'MACHINES CAN FIND THE DOOR NOW. A machine inside a building could not work out how to get out to you, so it bumped about indoors while you stood outside taking no damage. Five of the twenty buildings on COLD STORAGE were traps like that. If something is in there with you, it is coming.',
  'THE MAP MARKS THE FALLEN BUILDINGS.
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
