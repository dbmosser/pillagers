$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\dark_raiders.html'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $new = $new.Replace("`r`n", "`n")
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# THE OVERSEER STAYS IN ITS LAIR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
navSeek(e,e.tx,e.ty,e.spd,dt); wantW=Math.atan2(e.ty-e.y,e.tx-e.x);
'@ @'
        // v20.56, from the whole-game bug hunt of 2026-10-08 (H8): THE OVERSEER GUARDS THE MIDDLE, IT DOES NOT TOUR THE RINGS. Its
        // leash (v17.45) was only asked while it could see you, so once it lost you it did what every warden does: walked to
        // where you had been, then to the nearest extraction ring, then the next, for the rest of the raid; and its unaware
        // walk took any free spot on the whole map from its first frame. Now a place it is sent past 1100 from its lair (by a
        // round or a blast) sends it home instead, losing you sends it home instead of to a ring, and its unaware walk is a
        // short beat around the lair. The same draws are made in the same places; only where it walks moved.
        if(e.boss&&e.lairX!==undefined&&Math.hypot(e.tx-e.lairX,e.ty-e.lairY)>1100){ e.tx=e.lairX; e.ty=e.lairY; }
navSeek(e,e.tx,e.ty,e.spd,dt); wantW=Math.atan2(e.ty-e.y,e.tx-e.x);
'@

SubRx @'
        if(!sees&&dist(e,{x:e.tx,y:e.ty})<70&&G.zones&&G.zones.length){
'@ @'
        if(e.boss&&e.lairX!==undefined){ if(!sees&&dist(e,{x:e.tx,y:e.ty})<70){ e.tx=e.lairX; e.ty=e.lairY; } }   // v20.56 (H8): it lost you, so it goes home, not to a ring
        else if(!sees&&dist(e,{x:e.tx,y:e.ty})<70&&G.zones&&G.zones.length){
'@

SubRx @'
        if(e.cd<=0){ var wsp=freeSpot(G.map,40); e.tx=wsp.x; e.ty=wsp.y; e.cd=rnd(6,10); }
        moveToward(e,e.tx,e.ty,e.spd*.6,dt); wantW=Math.atan2(e.ty-e.y,e.tx-e.x);
        if(dist(e,{x:e.tx,y:e.ty})<40) e.cd=0;
'@ @'
        if(e.cd<=0){ var wsp=freeSpot(G.map,40); e.tx=wsp.x; e.ty=wsp.y; e.cd=rnd(6,10);
          // v20.56 (H8): the Overseer keeps the same draw and walks only the first stretch of it from its lair: at most 240,
          // and 60 short of the first wall on that line, so its beat stays in the open ground around the lair.
          if(e.boss&&e.lairX!==undefined){
            var _bwx=wsp.x-e.lairX,_bwy=wsp.y-e.lairY,_bwl=Math.sqrt(_bwx*_bwx+_bwy*_bwy),_bwt=0;
            if(_bwl>1){ _bwx/=_bwl; _bwy/=_bwl; _bwt=Math.max(0,Math.min(_bwl,240,rayHitG(e.lairX,e.lairY,_bwx,_bwy,300)-60)); }
            e.tx=e.lairX+_bwx*_bwt; e.ty=e.lairY+_bwy*_bwt;
          }
        }
        moveToward(e,e.tx,e.ty,e.spd*.6,dt); wantW=Math.atan2(e.ty-e.y,e.tx-e.x);
        if(dist(e,{x:e.tx,y:e.ty})<40&&!e.boss) e.cd=0;   // v20.56 (H8): the Overseer waits out its clock at each point of its beat, so a point beside the lair never draws a new one every frame
'@

SubRx @'
var VER='20.55';
'@ @'
var VER='20.56';
'@

$pat = "(?m)^  now:'v20\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.56: THE OVERSEER now stays near the middle of the map instead of touring the extraction rings. Check 20.56 fails on v20.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
