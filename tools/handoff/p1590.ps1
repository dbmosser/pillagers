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

SubRx @'
  for(i=0;i<N_RAIDER;i++){
    var s3=far(freeSpot(map,30),1190);
'@ @'
  for(i=0;i<N_RAIDER;i++){
    var s3=far(freeSpot(map,30),1190);
    // v15.90, doors audit finding: PILLAGERS NEVER SPAWN INSIDE A LOCKED ROOM. freeSpot only asks whether a point is
    // clear of wall rects, and the inside of a locked room is open floor between four 16 unit strips, so at pad 30 a
    // 230 room leaves about 138 by 138 of legal ground and far() kept such a spot like any other. Nothing after this
    // line looked at it: _capHouses moves crawlers, the reach pass moves containers, mkRaider takes the point as given.
    // A pillager born inside started in loot, opened the room's three caches (the sector map then read LOOTED on a room
    // whose key you had not found) and could never route out, so his name sat on the board for the whole raid. Same
    // shape as the crier fix at v9.04: projected out, not re-rolled. He stands below the door face on the first clear
    // point walking down from it (spotFree draws nothing), so the draws in far() and every draw after it are untouched
    // and the seeded map is byte for byte what it was. shutRoomAt is the v15.89 helper beside navReachable.
    var _lr3=shutRoomAt(map,s3.x,s3.y);
    if(_lr3){ var _oy3=_lr3.y+_lr3.h+34, _ok3=false;
      for(var _k3=0;_k3<6&&!_ok3;_k3++){ if(spotFree(map,_lr3.doorX,_oy3+_k3*20,14)){ s3={x:_lr3.doorX,y:_oy3+_k3*20}; _ok3=true; } }
      if(!_ok3) s3={x:_lr3.doorX,y:_oy3}; }
'@
SubRx @'
    var _c=freeSpot(G.map,30), _cd=NET.on?netNearDist(_c):dist(_c,G.player);   // v15.80: far from EVERY player, the party up top included; the 24 draws are unchanged
    if(_cd>bd){ bd=_cd; sp=_c; }
'@ @'
    var _c=freeSpot(G.map,30), _cd=NET.on?netNearDist(_c):dist(_c,G.player);   // v15.80: far from EVERY player, the party up top included; the 24 draws are unchanged
    // v15.90, doors audit finding: PILLAGERS NEVER SPAWN INSIDE A LOCKED ROOM. The farthest of the 24 was taken as it
    // came, and the open floor inside a shut room is legal ground to freeSpot. With you in the south west of COLD
    // STORAGE the FOREMAN OFFICE in the far corner is exactly where the farthest candidate lands, and a man born there
    // took its caches and never left. A candidate inside a room whose door is still shut is passed over; the 24 draws
    // still happen, and the bd<900 gate below already covers the wave where every candidate was inside one. No draw
    // moved.
    if(_cd>bd&&!shutRoomAt(G.map,_c.x,_c.y)){ bd=_cd; sp=_c; }
'@
SubRx @'
var VER='15.89';
'@ @'
var VER='15.90';
'@

$pat = "(?m)^  now:'v15\.89:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.90: PILLAGERS NEVER SPAWN INSIDE A LOCKED ROOM. A pillager placed at the drop or arriving in a wave could land on the open floor inside BLAST FREEZER or FOREMAN OFFICE, take its caches before you had found the key and stay trapped there for the whole raid with his name on the board. One placed there at the drop now stands outside its door instead, and a wave passes over any spot inside a room whose door is still shut. Check 15.90 forces a wave with every candidate inside a shut room and again with one clear spot among them; it fails on v15.89',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
