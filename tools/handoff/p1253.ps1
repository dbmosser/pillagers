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

# FROM THE 2026-09-07 READ-ONLY AUDIT (P2), two findings that are one defect
# seen from two ends. Specced from the source.
#
# A machine that loses you goes to investigate, and the scatter pushes its last
# sighting 90 to 240 units in a random direction so a pack fans out rather than
# all walking to the same spot. That point is never tested for being somewhere a
# body can stand. It can land inside a locked shell, inside a ruin block, inside
# a wreck, or outside the world edge.
#
# And investigate has exactly one way out: get within 34 units of the point.
# There is no clock. So a point nothing can reach holds the machine for the rest
# of the raid: it walks to the nearest face and pushes at it, hugging and
# orbiting, until the raid ends. The wander that re-rolls a target explicitly
# skips investigate, and the noise waker only re-points patrol and loot.
#
# v12.07 met the same shape in the chase and gave it an overtime cap, with the
# comment that a point nothing can reach must not hold it forever. This is that
# rule applied one state along, plus the scatter no longer choosing a point
# inside a wall in the first place.
SubRx @'
    var a=(n++)*1.05+rnd(-0.3,0.3),r=rnd(90,240);
    e.tx+=Math.cos(a)*r; e.ty+=Math.sin(a)*r;
'@ @'
    var a=(n++)*1.05+rnd(-0.3,0.3),r=rnd(90,240);
    // v12.53, 2026-09-07 audit: THE SCATTER PICKS SOMEWHERE A BODY CAN STAND.
    // This offset was never tested for anything, so it could land inside a
    // locked shell, a ruin block, a wreck or past the world edge, and the state
    // it belongs to has only one exit, arriving. searchSector already tests its
    // own points this way; this one never did. If the scattered point is not
    // open the machine keeps the sighting it actually had, which is always a
    // place a body was standing.
    var _sx=e.tx+Math.cos(a)*r, _sy=e.ty+Math.sin(a)*r;
    var _sw=(G.map.cols*G.map.cw), _sh=(G.map.rows*G.map.ch);
    if(_sx>44&&_sy>44&&_sx<_sw-44&&_sy<_sh-44&&spotFree(G.map,_sx,_sy,12)){ e.tx=_sx; e.ty=_sy; }
'@

SubRx @'
    else if(e.state==='investigate'){
      navSeek(e,e.tx,e.ty,e.spd*.75,dt); want=Math.atan2(e.ty-e.y,e.tx-e.x);
      if(dist(e,{x:e.tx,y:e.ty})<34){
        e.state=e.kind==='raider'?'loot':'patrol'; e.cd=rnd(.5,1.6); e.scattered=0;
      }
    }
'@ @'
    else if(e.state==='investigate'){
      navSeek(e,e.tx,e.ty,e.spd*.75,dt); want=Math.atan2(e.ty-e.y,e.tx-e.x);
      // v12.53, 2026-09-07 audit: AND IT GIVES UP ON A POINT IT CANNOT REACH.
      // Arriving was the only way out of this state and there was no clock, so a
      // point inside a wall or past the world edge held the machine for the rest
      // of the raid, walking into the nearest face and orbiting it. The wander
      // that re-rolls a target skips this state on purpose and the noise waker
      // only re-points patrol and loot, so nothing else could ever free it.
      // Same rule v12.07 gave the chase, one state along. The clock is per
      // point, so a machine sent somewhere new starts it again, and twenty
      // seconds is more than three times the longest honest walk here: the
      // scatter reaches 240 units and the walk is at three quarters speed.
      var _ig=Math.round(e.tx)+','+Math.round(e.ty);
      if(e.invGoal!==_ig){ e.invGoal=_ig; e.invT=0; }
      e.invT=(e.invT||0)+dt;
      if(dist(e,{x:e.tx,y:e.ty})<34){
        e.state=e.kind==='raider'?'loot':'patrol'; e.cd=rnd(.5,1.6); e.scattered=0;
        e.invT=0; e.invGoal=null;
      }
      else if(e.invT>20){
        e.state=e.kind==='raider'?'loot':'patrol'; e.cd=rnd(.5,1.6); e.scattered=0;
        e.invT=0; e.invGoal=null; e.path=null; e.pathFail=false;
      }
    }
'@

# NEW IN.
SubRx @'
  'A PILLAGER WHOSE REACH IS INSIDE HIS OWN BLAST NO LONGER THROWS A CHARGE. One gun in nine has a shorter reach than the radius of a frag, and the man carrying it had a throwing window one unit wide, entirely inside his own explosion.',
'@ @'
  'A PILLAGER WHOSE REACH IS INSIDE HIS OWN BLAST NO LONGER THROWS A CHARGE. One gun in nine has a shorter reach than the radius of a frag, and the man carrying it had a throwing window one unit wide, entirely inside his own explosion.',
  'A MACHINE SEARCHING FOR YOU CAN NO LONGER GET STUCK FOR THE REST OF THE RAID. When one lost you it picked a point to search, never checked that anything could stand there, and had no way out except arriving. A point inside a wall held it against that wall until the raid ended.',
'@

# STAMPS.
SubRx @'
var VER='12.52';
'@ @'
var VER='12.53';
'@
SubRx @'
var WHATSNEW_VER='12.52';
'@ @'
var WHATSNEW_VER='12.53';
'@
$cnt=([regex]::Matches($s,"now:'v12\.52:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.52 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.52:[^']*'",{ param($m) "now:'v12.53: 2026-09-07 audit (P2), two findings that are one defect seen from two ends. A machine that loses you goes to investigate, and the scatter pushes its last sighting 90 to 240 units in a random direction so a pack fans out rather than all walking to the same spot. That point was never tested for being somewhere a body can stand: it could land inside a locked shell, a ruin block, a wreck or past the world edge. And investigate has exactly one way out, getting within 34 units of the point, with no clock at all. So a point nothing can reach held the machine for the rest of the raid, walking into the nearest face and orbiting it, and nothing else could free it either, because the wander that re-rolls a target skips this state on purpose and the noise waker only re-points patrol and loot. v12.07 met the same shape in the chase and gave it an overtime cap with the comment that a point nothing can reach must not hold it forever; this is that rule one state along, plus a scatter that no longer chooses a point inside a wall in the first place. Twenty seconds is more than three times the longest honest walk here, since the scatter reaches 240 units and the walk is at three quarters speed, and the clock is per point so a machine sent somewhere new starts it again. Check 12.53 parks a crawler on a point it can never reach and requires it back on patrol and moving again, with a control that a point on open ground still ends the search by arriving and not by the clock; fails on v12.52.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
