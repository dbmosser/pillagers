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

# 1. THE DIAL. furnIDoor 0 restores the old placement inside for the A/B.
SubRx @'
bldgRuin:0.09,touchSees:1,winWalk:1,furnDoor:1,navBody:15,doorClear:1};
'@ @'
bldgRuin:0.09,touchSees:1,winWalk:1,furnDoor:1,navBody:15,doorClear:1,furnIDoor:1};
'@

# 2. THE INTERIOR DOORWAYS ARE RECORDED, the way BDOORS records the shell doors.
SubRx @'
var BDOORS=[];
'@ @'
var BDOORS=[];
// v11.17: this map's INTERIOR doorways, the gaps the plans cut in partitions.
// v11.14 kept furniture out of the shell doorways and nothing knew these
// existed, so five building interiors on THE COLD MILE had no route in from
// their own front door.
var IDOORS=[];
'@
SubRx @'
  BDOORS=[];                                   // v10.84: this map's doorways
'@ @'
  BDOORS=[];                                   // v10.84: this map's doorways
  IDOORS=[];                                   // v11.17: and the ones inside
'@
SubRx @'
  function door(a,b,c,e){ BDOORS.push({x:a,y:b,w:c,h:e}); }
'@ @'
  function door(a,b,c,e){ BDOORS.push({x:a,y:b,w:c,h:e}); }
  function idoor(a,b,c,e){ IDOORS.push({x:a,y:b,w:c,h:e}); }
'@

# 3. EACH PLAN NAMES THE GAPS IT CUTS. pinwheel and cells cut none.
SubRx @'
    seg(ix,cy0,s1-ix,t); seg(s1+DOOR,cy0,(ix+iw)-(s1+DOOR),t);
    seg(ix,cy0+cw2-t,s2-ix,t); seg(s2+DOOR,cy0+cw2-t,(ix+iw)-(s2+DOOR),t);
'@ @'
    seg(ix,cy0,s1-ix,t); seg(s1+DOOR,cy0,(ix+iw)-(s1+DOOR),t); idoor(s1,cy0,DOOR,t);
    seg(ix,cy0+cw2-t,s2-ix,t); seg(s2+DOOR,cy0+cw2-t,(ix+iw)-(s2+DOOR),t); idoor(s2,cy0+cw2-t,DOOR,t);
'@
SubRx @'
    if(side===0){ dp=kx+rnd(8,Math.max(9,kw-8-DOOR)); seg(kx,ky,dp-kx,t); seg(dp+DOOR,ky,kx+kw-(dp+DOOR),t); }
'@ @'
    if(side===0){ dp=kx+rnd(8,Math.max(9,kw-8-DOOR)); seg(kx,ky,dp-kx,t); seg(dp+DOOR,ky,kx+kw-(dp+DOOR),t); idoor(dp,ky,DOOR,t); }
'@
SubRx @'
    if(side===1){ dp=kx+rnd(8,Math.max(9,kw-8-DOOR)); seg(kx,ky+kh-t,dp-kx,t); seg(dp+DOOR,ky+kh-t,kx+kw-(dp+DOOR),t); }
'@ @'
    if(side===1){ dp=kx+rnd(8,Math.max(9,kw-8-DOOR)); seg(kx,ky+kh-t,dp-kx,t); seg(dp+DOOR,ky+kh-t,kx+kw-(dp+DOOR),t); idoor(dp,ky+kh-t,DOOR,t); }
'@
SubRx @'
    if(side===2){ dp=ky+rnd(8,Math.max(9,kh-8-DOOR)); seg(kx,ky,t,dp-ky); seg(kx,dp+DOOR,t,ky+kh-(dp+DOOR)); }
'@ @'
    if(side===2){ dp=ky+rnd(8,Math.max(9,kh-8-DOOR)); seg(kx,ky,t,dp-ky); seg(kx,dp+DOOR,t,ky+kh-(dp+DOOR)); idoor(kx,dp,t,DOOR); }
'@
SubRx @'
    if(side===3){ dp=ky+rnd(8,Math.max(9,kh-8-DOOR)); seg(kx+kw-t,ky,t,dp-ky); seg(kx+kw-t,dp+DOOR,t,ky+kh-(dp+DOOR)); }
'@ @'
    if(side===3){ dp=ky+rnd(8,Math.max(9,kh-8-DOOR)); seg(kx+kw-t,ky,t,dp-ky); seg(kx+kw-t,dp+DOOR,t,ky+kh-(dp+DOOR)); idoor(kx+kw-t,dp,t,DOOR); }
'@
SubRx @'
    seg(vx,iy,t,gy2-iy); seg(vx,gy2+DOOR,t,(iy+ih)-(gy2+DOOR));
'@ @'
    seg(vx,iy,t,gy2-iy); seg(vx,gy2+DOOR,t,(iy+ih)-(gy2+DOOR)); idoor(vx,gy2,t,DOOR);
'@
SubRx @'
    seg(vx,hy,gx2-vx,t); seg(gx2+DOOR,hy,(ix+iw)-(gx2+DOOR),t);
'@ @'
    seg(vx,hy,gx2-vx,t); seg(gx2+DOOR,hy,(ix+iw)-(gx2+DOOR),t); idoor(gx2,hy,DOOR,t);
'@

# 4. AND FURNITURE KEEPS OUT OF THEM, the same zone as the shell doors.
SubRx @'
          if(fx4<_zx+_zw&&fx4+fw2>_zx&&fy4<_zy+_zh&&fy4+fh2>_zy){ _fdrop=true; break; }
        }
        if(_fdrop) continue;
      }
'@ @'
          if(fx4<_zx+_zw&&fx4+fw2>_zx&&fy4<_zy+_zh&&fy4+fh2>_zy){ _fdrop=true; break; }
        }
        if(_fdrop) continue;
      }
      // v11.17: AND THE DOORWAYS INSIDE. Measured on v11.16 at seed 4242, a
      // route asked from just inside each building's own front door to its
      // centre: 5 of 84 interiors on THE COLD MILE had none, 32, 33, 37, 38 and
      // 74, and every one of them had one with the furniture stripped. The
      // same zone as the shell doors, drawing no random number.
      if((CFG.furnIDoor===undefined?1:CFG.furnIDoor)){
        var _fdrop2=false;
        for(var _dj=0;_dj<IDOORS.length;_dj++){
          var _de=IDOORS[_dj],_deh=_de.w>=_de.h;
          var _ex=_deh?_de.x-12:_de.x-40,_ey=_deh?_de.y-40:_de.y-12;
          var _ew=_deh?_de.w+24:_de.w+80,_eh=_deh?_de.h+80:_de.h+24;
          if(fx4<_ex+_ew&&fx4+fw2>_ex&&fy4<_ey+_eh&&fy4+fh2>_ey){ _fdrop2=true; break; }
        }
        if(_fdrop2) continue;
      }
'@

# 5. THE MAP CARRIES THE LIST, so a check can read it.
SubRx @'
    navD:mapNavD,doors:BDOORS.slice(0),wsegs:wsegs};
'@ @'
    navD:mapNavD,doors:BDOORS.slice(0),idoors:IDOORS.slice(0),wsegs:wsegs};
'@

# 6. VERSION STAMPS, both of them.
SubRx @'
var VER='11.16';
'@ @'
var VER='11.17';
'@
SubRx @'
var WHATSNEW_VER='11.16';
'@ @'
var WHATSNEW_VER='11.17';
'@
SubRx @'
  'A DOORWAY WITH A WALL RIGHT BEHIND IT NO LONGER CATCHES A MACHINE ON THAT WALL.
'@ @'
  'THE DOORWAYS INSIDE BUILDINGS ARE CLEAR OF FURNITURE TOO. A few buildings had a piece parked in the gap between two rooms, so the back room could be seen and never reached, by you or by anything hunting you. Nothing is parked in those gaps now.',
  'A DOORWAY WITH A WALL RIGHT BEHIND IT NO LONGER CATCHES A MACHINE ON THAT WALL.
'@

# 7. THE WATCHDOG.
SubRx @'
  now:'v11.16: a door cell sits clear of every wall, not only the door frame. The carve that opens the route through a doorway rejected only cells inside a wall, so a cell one unit off a partition meeting the door became a waypoint and a machine steering at it stood against the partition. Found by walking THE COLD MILE: the crawler out of building 20, routed through the building next door, stood at 3000,3178 for the rest of its trial. With the first map at 12 of 13 and the mile sampled at 9 of 10, this is the shape of what is left.',
'@ @'
  now:'v11.17: the doorways inside buildings are recorded and furniture keeps out of them, the way v11.14 did for the front doors. Measured on v11.16: five interiors on THE COLD MILE had no route in from their own door, all five open with the furniture stripped. No random number is drawn, so the seeded world does not move.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
