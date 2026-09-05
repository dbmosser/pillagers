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

# THE TRIM MOVED THE WORLD: 374 entities on the mile became 369, because the
# partitions were cut before the crawlers were counted into rooms. The cut now
# runs at the END of the map build, after every roll, where the ruin pass runs,
# so placement sees the walls it always saw and only the finished geometry
# changes. The two bookmarks and the in-building pass come out.
SubRx @'
  function idoor(a,b,c,e){ IDOORS.push({x:a,y:b,w:c,h:e}); }
  var _bd0=BDOORS.length;                        // v11.18: this building's doors start here
'@ @'
  function idoor(a,b,c,e){ IDOORS.push({x:a,y:b,w:c,h:e}); }
'@
SubRx @'
  var _po0=out.length;                           // v11.18: and its partitions start here
  var plans=['open','spine','core','pinwheel','cells','lsplit'];
'@ @'
  var plans=['open','spine','core','pinwheel','cells','lsplit'];
'@
SubRx @'
  // v11.18: NO PARTITION ENDS INSIDE A DOORWAY. A spine wall runs wall to wall,
  // an L split runs floor to ceiling and an alcove hangs off a wall at a rolled
  // height, and none of them knew where the shell had put its doors. Measured
  // on v11.17 at seed 4242: 3 doors on COLD STORAGE and 19 on THE COLD MILE had
  // a partition running into the gap, and 4 of the mile's left under 30 units
  // either side of it, so nothing 30 wide could use the door at all; the door
  // at 2960,3167 was 26 above and 22 below. Every partition of this building
  // that reaches into a door's zone, the gap grown 30 along the wall and 40
  // through it, has that part cut away, so the door opens onto floor. The cut
  // draws no random number. partDoor 0 restores.
  if((CFG.partDoor===undefined?1:CFG.partDoor)){
    var _pend=out.length;
    for(var _pi=_bd0;_pi<BDOORS.length;_pi++){
      var _pd=BDOORS[_pi],_pdh=_pd.w>=_pd.h;
      var _zx=_pdh?_pd.x-30:_pd.x-40,_zy=_pdh?_pd.y-40:_pd.y-30;
      var _zw=_pdh?_pd.w+60:_pd.w+80,_zh=_pdh?_pd.h+80:_pd.h+60;
      for(var _pj=_po0;_pj<_pend;_pj++){
        var _pe=out[_pj];
        if(!_pe||_pe.ib!==bid||_pe.furn||_pe.lockWall||_pe.w<3||_pe.h<3) continue;
        if(!(_pe.x<_zx+_zw&&_pe.x+_pe.w>_zx&&_pe.y<_zy+_zh&&_pe.y+_pe.h>_zy)) continue;
        if(_pe.w>=_pe.h){
          var _a=Math.max(_pe.x,_zx),_b=Math.min(_pe.x+_pe.w,_zx+_zw),_L=_a-_pe.x,_R=(_pe.x+_pe.w)-_b;
          if(_L>=3&&_R>=3){ var _c2={},_k2; for(_k2 in _pe) if(Object.prototype.hasOwnProperty.call(_pe,_k2)) _c2[_k2]=_pe[_k2]; _c2.x=_b; _c2.w=_R; out.push(_c2); _pe.w=_L; }
          else if(_L>=3){ _pe.w=_L; }
          else if(_R>=3){ _pe.x=_b; _pe.w=_R; }
          else { _pe.w=0; }
        } else {
          var _a2=Math.max(_pe.y,_zy),_b2=Math.min(_pe.y+_pe.h,_zy+_zh),_T=_a2-_pe.y,_D=(_pe.y+_pe.h)-_b2;
          if(_T>=3&&_D>=3){ var _c3={},_k3; for(_k3 in _pe) if(Object.prototype.hasOwnProperty.call(_pe,_k3)) _c3[_k3]=_pe[_k3]; _c3.y=_b2; _c3.h=_D; out.push(_c3); _pe.h=_T; }
          else if(_T>=3){ _pe.h=_T; }
          else if(_D>=3){ _pe.y=_b2; _pe.h=_D; }
          else { _pe.h=0; }
        }
      }
    }
    for(var _pk=out.length-1;_pk>=_po0;_pk--){ var _pq=out[_pk]; if(_pq&&_pq.ib===bid&&!_pq.furn&&(_pq.w<3||_pq.h<3)) out.splice(_pk,1); }
  }
  // Furniture. "Graphics need more detail all around": interiors were floors
'@ @'
  // Furniture. "Graphics need more detail all around": interiors were floors
'@

# THE PASS, AT THE END OF THE BUILD, AFTER EVERY ROLL.
SubRx @'
  var _nb=(CFG.navBody===undefined?15:CFG.navBody);
  var mapNavD=carveDoors(_nb>0?buildNav(walls,_nb):mapNav,BDOORS,walls,_nb);
'@ @'
  // v11.18: NO PARTITION ENDS INSIDE A DOORWAY. A spine wall runs wall to wall,
  // an L split runs floor to ceiling and an alcove hangs off a wall at a rolled
  // height, and none of them knew where the shell had put its doors. Measured
  // on v11.17 at seed 4242: 3 doors on COLD STORAGE and 19 on THE COLD MILE had
  // a partition running into the gap, and 4 of the mile's left under 30 units
  // either side of it, so nothing 30 wide could use the door at all; the door
  // at 2960,3167 was 26 above and 22 below. Every partition that reaches into
  // a door's zone on its own building, the gap grown 30 along the wall and 40
  // through it, has that part cut away, so the door opens onto floor.
  // AT THE END, AFTER EVERY ROLL, like the ruin pass: my first cut ran inside
  // makeBuilding and 374 entities on the mile became 369, because crawlers are
  // counted into the rooms the partitions make. Placement sees the walls it
  // always saw; only the finished geometry changes. partDoor 0 restores.
  if((CFG.partDoor===undefined?1:CFG.partDoor)&&BDOORS.length){
    var _pcut=0,_pend=walls.length;
    for(var _pi=0;_pi<BDOORS.length;_pi++){
      var _pd=BDOORS[_pi],_pdh=_pd.w>=_pd.h;
      var _zx=_pdh?_pd.x-30:_pd.x-40,_zy=_pdh?_pd.y-40:_pd.y-30;
      var _zw=_pdh?_pd.w+60:_pd.w+80,_zh=_pdh?_pd.h+80:_pd.h+60;
      for(var _pj=0;_pj<_pend;_pj++){
        var _pe=walls[_pj];
        if(!_pe||_pe.ib===undefined||_pe.furn||_pe.lockWall||_pe.w<3||_pe.h<3) continue;
        if(!(_pe.x<_zx+_zw&&_pe.x+_pe.w>_zx&&_pe.y<_zy+_zh&&_pe.y+_pe.h>_zy)) continue;
        // its own building's door, or leave it: the door has to lie on that
        // building's perimeter.
        var _pb=buildings[_pe.ib];
        if(!_pb||_pd.x<_pb.x-1||_pd.x+_pd.w>_pb.x+_pb.w+1||_pd.y<_pb.y-1||_pd.y+_pd.h>_pb.y+_pb.h+1) continue;
        if(_pe.w>=_pe.h){
          var _a=Math.max(_pe.x,_zx),_b=Math.min(_pe.x+_pe.w,_zx+_zw),_L=_a-_pe.x,_R=(_pe.x+_pe.w)-_b;
          if(_L>=3&&_R>=3){ var _c2={},_k2; for(_k2 in _pe) if(Object.prototype.hasOwnProperty.call(_pe,_k2)) _c2[_k2]=_pe[_k2]; _c2.x=_b; _c2.w=_R; walls.push(_c2); _pe.w=_L; }
          else if(_L>=3){ _pe.w=_L; }
          else if(_R>=3){ _pe.x=_b; _pe.w=_R; }
          else { _pe.w=0; }
        } else {
          var _a2=Math.max(_pe.y,_zy),_b2=Math.min(_pe.y+_pe.h,_zy+_zh),_T=_a2-_pe.y,_D=(_pe.y+_pe.h)-_b2;
          if(_T>=3&&_D>=3){ var _c3={},_k3; for(_k3 in _pe) if(Object.prototype.hasOwnProperty.call(_pe,_k3)) _c3[_k3]=_pe[_k3]; _c3.y=_b2; _c3.h=_D; walls.push(_c3); _pe.h=_T; }
          else if(_T>=3){ _pe.h=_T; }
          else if(_D>=3){ _pe.y=_b2; _pe.h=_D; }
          else { _pe.h=0; }
        }
        _pcut++;
      }
    }
    if(_pcut){
      for(var _pk=walls.length-1;_pk>=0;_pk--){ var _pq=walls[_pk]; if(_pq&&_pq.ib!==undefined&&!_pq.furn&&(_pq.w<3||_pq.h<3)) walls.splice(_pk,1); }
      mapNav=buildNav(walls);
    }
  }
  var _nb=(CFG.navBody===undefined?15:CFG.navBody);
  var mapNavD=carveDoors(_nb>0?buildNav(walls,_nb):mapNav,BDOORS,walls,_nb);
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
