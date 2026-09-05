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

# 1. THE DIAL. partDoor 0 restores the old partitions for the A/B.
SubRx @'
bldgRuin:0.09,touchSees:1,winWalk:1,furnDoor:1,navBody:15,doorClear:1,furnIDoor:1,furnGap:1};
'@ @'
bldgRuin:0.09,touchSees:1,winWalk:1,furnDoor:1,navBody:15,doorClear:1,furnIDoor:1,furnGap:1,partDoor:1};
'@

# 2. REMEMBER WHERE THIS BUILDING'S DOORS AND PARTITIONS START.
SubRx @'
  function idoor(a,b,c,e){ IDOORS.push({x:a,y:b,w:c,h:e}); }
'@ @'
  function idoor(a,b,c,e){ IDOORS.push({x:a,y:b,w:c,h:e}); }
  var _bd0=BDOORS.length;                        // v11.18: this building's doors start here
'@
SubRx @'
  var plans=['open','spine','core','pinwheel','cells','lsplit'];
'@ @'
  var _po0=out.length;                           // v11.18: and its partitions start here
  var plans=['open','spine','core','pinwheel','cells','lsplit'];
'@

# 3. NO PARTITION ENDS INSIDE A DOORWAY. Trim the part that does.
SubRx @'
    seg(vx,hy,gx2-vx,t); seg(gx2+DOOR,hy,(ix+iw)-(gx2+DOOR),t); idoor(gx2,hy,DOOR,t);
  }
  // Furniture. "Graphics need more detail all around": interiors were floors
'@ @'
    seg(vx,hy,gx2-vx,t); seg(gx2+DOOR,hy,(ix+iw)-(gx2+DOOR),t); idoor(gx2,hy,DOOR,t);
  }
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
'@

# 4. VERSION STAMPS, both of them.
SubRx @'
var VER='11.17';
'@ @'
var VER='11.18';
'@
SubRx @'
var WHATSNEW_VER='11.17';
'@ @'
var WHATSNEW_VER='11.18';
'@
SubRx @'
  'THE DOORWAYS INSIDE BUILDINGS ARE CLEAR OF FURNITURE TOO.
'@ @'
  'NO INTERIOR WALL ENDS INSIDE A DOORWAY. A few doors opened straight onto the end of a wall inside, with too little room either side of it to get through. Those walls now stop short of the door.',
  'THE DOORWAYS INSIDE BUILDINGS ARE CLEAR OF FURNITURE TOO.
'@

# 5. THE WATCHDOG.
SubRx @'
  now:'v11.17: the doorways inside buildings are recorded and furniture keeps out of them, the way v11.14 did for the front doors. Measured on v11.16: five interiors on THE COLD MILE had no route in from their own door, all five open with the furniture stripped. No random number is drawn, so the seeded world does not move.',
'@ @'
  now:'v11.18: no interior wall ends inside a doorway. Measured on v11.17 at seed 4242: 3 doors on COLD STORAGE and 19 on THE COLD MILE opened onto the end of a partition, and 4 of the mile\'s left under 30 units either side of it, so nothing 30 wide could use the door. Every partition reaching into a door\'s zone has that part cut away. No random number is drawn.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
