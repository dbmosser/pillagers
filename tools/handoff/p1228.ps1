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

# HIS NOTE OF 2026-09-06 20:55 ("crawlers still getting stuck when pathfinding
# / chasing the player occasionally"), reproduced on the dry fixture at v12.26:
# of 105 crawlers set chasing a standing player across twelve spots, one never
# made a yard of progress in ten seconds. CRAWLER A-31, an elite, stood in a
# 110-cell island of the nav grid that no route leaves: the 230 by 230 shell of
# the cs_freezer locked room, five walls and a keyed door drawn as a sixth.
# freeSpot knows walls, not rooms, so a body can be placed inside a vault, where
# no route exists until the key is spent. Twelve seeds across both maps: ten
# bodies sealed in twelve raids, five in one (seed 555, THE COLD MILE): crawlers,
# a sentry, a howler that shells from a box nothing can reach, a pillager that
# never loots or leaves. Every sealed body is walked out through its own door to
# the first clear spot outside, in door-normal steps, then in a ring; no draw is
# consumed, so every seed's stream and every container is byte-identical, and
# the body counts do not move. unseal 0 restores the old placement so the two
# can be run against each other in one build.
SubRx @'
  clearOfPads(containers);
  // Meridian caches.
'@ @'
  clearOfPads(containers);
  // v12.28, HIS NOTE: NOTHING IS BORN SEALED IN A VAULT. freeSpot knows walls, not
  // rooms, so a body could be placed inside a locked room shell, where no route
  // exists until the key is spent: a crawler that scrabbles at the inside of the
  // wall for the whole raid when it hears you, a howler shelling from a box
  // nothing can reach, a pillager that never loots. Measured across twelve seeds
  // on both maps: ten bodies sealed in twelve raids, five in one. Each is walked
  // out through its own door to the first clear spot outside; no draw is
  // consumed, so the stream and every container are byte-identical. unseal 0
  // restores the old placement.
  function unsealEnts(map,list){
    if(CFG.unseal===0) return 0;
    var L=map.locked||[]; if(!L.length) return 0;
    var gr=(map._fsGrid&&map._fsGrid.walls===map.walls)?map._fsGrid:(map._fsGrid=buildWallGrid(map.walls,WORLD_W,WORLD_H));
    function clear(x,y,pad){
      if(x<pad||y<pad||x>WORLD_W-pad||y>WORLD_H-pad) return false;
      var nw=wallsNear(gr,x,y,pad);
      for(var i=0;i<nw.length;i++){ var w=nw[i]; if(x>w.x-pad&&x<w.x+w.w+pad&&y>w.y-pad&&y<w.y+w.h+pad) return false; }
      return true;
    }
    var moved=0;
    for(var i=0;i<list.length;i++){ var e=list[i];
      for(var j=0;j<L.length;j++){ var R=L[j];
        if(!(e.x>R.x&&e.x<R.x+R.w&&e.y>R.y&&e.y<R.y+R.h)) continue;
        var pad=Math.max(22,(e.r||14)+8), ok=false, s;
        for(s=0;s<12&&!ok;s++){ var px=R.doorX, py=R.doorY+8+pad+s*26; if(clear(px,py,pad)){ e.x=px; e.y=py; ok=true; } }
        for(s=1;s<40&&!ok;s++){ for(var a=0;a<8&&!ok;a++){ var ang=a*0.7854, px2=R.doorX+Math.cos(ang)*s*26, py2=R.doorY+8+pad+Math.sin(ang)*s*26;
          if(px2>R.x-pad&&px2<R.x+R.w+pad&&py2>R.y-pad&&py2<R.y+R.h+pad) continue;
          if(clear(px2,py2,pad)){ e.x=px2; e.y=py2; ok=true; } } }
        if(e.tx!==undefined){ e.tx=e.x; e.ty=e.y; }   // a patrol target inside the vault would walk it back to the wall
        moved++; break;
      } }
    return moved;
  }
  // Meridian caches.
'@
SubRx @'
    containers:(clearOfPads(containers),containers),ents:ents,bullets:[],pings:[],puffs:[],noiseRings:[],
'@ @'
    containers:(clearOfPads(containers),containers),ents:(unsealEnts(map,ents),ents),bullets:[],pings:[],puffs:[],noiseRings:[],   // v12.28: nothing is born sealed in a vault
'@
SubRx @'
furnIDoor:1,furnGap:1,partDoor:1};
'@ @'
furnIDoor:1,furnGap:1,partDoor:1,unseal:1};
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'NOTHING IS BORN SEALED INSIDE A LOCKED ROOM. A machine or a pillager the map had placed inside a vault could never reach you or leave; it scrabbled at the wall when it heard you. It starts outside the door now.',
'@

# STAMPS.
SubRx @'
var VER='12.27';
'@ @'
var VER='12.28';
'@
SubRx @'
var WHATSNEW_VER='12.27';
'@ @'
var WHATSNEW_VER='12.28';
'@
$cnt=([regex]::Matches($s,"now:'v12\.27:[^']*'")).Count
if($cnt -ne 1){ throw "DEVNOW v12.27 matched $cnt times" }
$s=[regex]::Replace($s,"now:'v12\.27:[^']*'",{ param($m) "now:'v12.28: his note that crawlers still get stuck chasing, reproduced: a body the map placed inside a locked room shell has no route until the key is spent, so it scrabbled at the wall whenever it heard you; ten bodies sealed in twelve raids across both maps, a howler and a pillager among them. Every sealed body is walked out through its own door at birth, no draw consumed, counts unchanged. Check 12.28 deploys seed 555 on THE COLD MILE with the old placement (dial unseal 0) and requires bodies sealed, then with the new and requires none, same counts, each moved body outside near its door and clear of walls; and the 85 and 165 of seed 4242 stand; fails on v12.27.'" })
$n++

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count + 1
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
