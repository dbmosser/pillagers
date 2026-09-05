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

# 1. THE DIAL. doorClear 0 skips the strict pass for the A/B.
SubRx @'
bldgRuin:0.09,touchSees:1,winWalk:1,furnDoor:1,navBody:15};
'@ @'
bldgRuin:0.09,touchSees:1,winWalk:1,furnDoor:1,navBody:15,doorClear:1};
'@

# 2. A DOOR CELL SITS CLEAR OF EVERY WALL, NOT JUST THE JAMBS. The carve rejected
#    only cells whose centre was INSIDE a wall, so a cell one unit off a partition
#    that meets the door was opened as a route waypoint, and a body steering at it
#    stood against the partition. Measured on THE COLD MILE: the west door of the
#    building at 2960,3130 has a partition at 2976,3193 behind it, and the carve
#    opened 2968,3192, 2984,3192 and 3000,3192, one unit above it; the crawler out
#    of building 20, routed through that building, stood at 3000,3178 with the
#    waypoint 3000,3192 fourteen units into the wall's padding. A jamb piece is a
#    wall on the door's own line, and the jamb band already handles those. If the
#    stricter rule would leave a door with no cell at all, the old rule is used for
#    that door, so no door that was open before is closed by this.
SubRx @'
    for(j=y0;j<=y1;j++) for(k=x0;k<=x1;k++){
      var id=j*gw+k;
      if(!b[id]) continue;
      var cx=k*cc+cc*0.5, cy=j*cc+cc*0.5, solid=false;
      if(jamb>0){
        if(_dh){ if(cx<D.x+jamb||cx>D.x+D.w-jamb) continue; }
        else { if(cy<D.y+jamb||cy>D.y+D.h-jamb) continue; }
      }
      for(var q=0;q<walls.length;q++){
        var W=walls[q];
        if(cx>W.x&&cx<W.x+W.w&&cy>W.y&&cy<W.y+W.h){ solid=true; break; }
      }
      if(!solid){ b[id]=0; out.opened++; }
    }
  }
  return out;
}
'@ @'
    // v11.16: two passes. The first asks every cell to sit jamb clear of every
    // wall that is not on the door's own line; if that opens nothing for this
    // door, the second falls back to the old rule, not inside a wall, so no
    // door that was open before is closed. doorClear 0 skips the first pass.
    var _strict=(jamb>0&&(CFG.doorClear===undefined?1:CFG.doorClear))?1:0;
    for(var _pass=(_strict?0:1);_pass<2;_pass++){
      var _got=0;
      for(j=y0;j<=y1;j++) for(k=x0;k<=x1;k++){
        var id=j*gw+k;
        if(!b[id]) continue;
        var cx=k*cc+cc*0.5, cy=j*cc+cc*0.5, solid=false;
        if(jamb>0){
          if(_dh){ if(cx<D.x+jamb||cx>D.x+D.w-jamb) continue; }
          else { if(cy<D.y+jamb||cy>D.y+D.h-jamb) continue; }
        }
        for(var q=0;q<walls.length;q++){
          var W=walls[q];
          if(cx>W.x&&cx<W.x+W.w&&cy>W.y&&cy<W.y+W.h){ solid=true; break; }
          if(_pass===0){
            var _onLine=_dh?(W.y===D.y&&W.h===D.h):(W.x===D.x&&W.w===D.w);
            if(!_onLine&&cx>W.x-jamb&&cx<W.x+W.w+jamb&&cy>W.y-jamb&&cy<W.y+W.h+jamb){ solid=true; break; }
          }
        }
        if(!solid){ b[id]=0; out.opened++; _got++; }
      }
      if(_got>0) break;
    }
  }
  return out;
}
'@

# 3. VERSION STAMPS, both of them.
SubRx @'
var VER='11.15';
'@ @'
var VER='11.16';
'@
SubRx @'
var WHATSNEW_VER='11.15';
'@ @'
var WHATSNEW_VER='11.16';
'@
SubRx @'
  'MACHINES WALK THROUGH THE MIDDLE OF DOORS AND ROUND CORNERS.
'@ @'
  'A DOORWAY WITH A WALL RIGHT BEHIND IT NO LONGER CATCHES A MACHINE ON THAT WALL. The route through a door stayed clear of the door frame but not of a partition just inside it, so a machine cutting through a neighbouring building could be sent straight into the partition and stand there. It keeps its distance from every wall now.',
  'MACHINES WALK THROUGH THE MIDDLE OF DOORS AND ROUND CORNERS.
'@

# 4. THE WATCHDOG.
SubRx @'
  now:'v11.15: the route grid is padded for the body that walks it. Routes were planned on a grid padded 12 for bodies of 15, and the string pull straightened them with a zero width line, so a crawler could be handed a waypoint one unit inside a door jamb or grazing the end of a partition, see it, steer at it, and stand against the wall for the rest of the raid. Buildings 15 and 18 on COLD STORAGE, traced. The route grid is padded 15 now, door cells sit 15 clear of both jambs, and the pull tests the body\'s width. map.nav still decides placement at 12, so nothing in the world moves.',
'@ @'
  now:'v11.16: a door cell sits clear of every wall, not only the door frame. The carve that opens the route through a doorway rejected only cells inside a wall, so a cell one unit off a partition meeting the door became a waypoint and a machine steering at it stood against the partition. Found by walking THE COLD MILE: the crawler out of building 20, routed through the building next door, stood at 3000,3178 for the rest of its trial. With the first map at 12 of 13 and the mile sampled at 9 of 10, this is the shape of what is left.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
