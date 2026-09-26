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
// Tests the cell and its eight neighbours, because a container sits at a point
// while a body needs a cell next to it, and a 16 unit grid rounds hard.
function navReachable(map,x,y){
'@ @'
// v15.89, doors audit finding: YOUR HIRE ON FOLLOW KEEPS FOLLOWING PAST A LOCKED ROOM. The room, if any, that is still
// shut around a point. A locked room is four walls and a door wall that only its key removes (the walls are pushed in the
// map build, the spend is in updatePlayer), so until its open flag is set no route reaches anything inside it. The FOLLOW
// pick in updateEnts tested _CT.locked, which nothing ever sets on a container: the three caches inside a room are marked
// inLocked, the strongbox sits there by spotIn, and stray crates land there by design (the reach pass keeps them). This is
// the same strict inside test that pass uses. The rooms list is short, so it is cheap to ask per box. No seeded draw.
function shutRoomAt(map,x,y){
  var L=(map&&map.locked)||[];
  for(var i=0;i<L.length;i++){ var R=L[i]; if(!R.open&&x>R.x&&x<R.x+R.w&&y>R.y&&y<R.y+R.h) return R; }
  return null;
}
// Tests the cell and its eight neighbours, because a container sits at a point
// while a body needs a cell next to it, and a 16 unit grid rounds hard.
function navReachable(map,x,y){
'@
SubRx @'
              if(_CT.opened||_CT.locked||_CT.mine||(_CT.prog||0)>0) continue;
              if(dist(e,_CT)<160&&dist(p,_CT)<420){ e.mgoal=_CT; e.mlootT=0; break; }
'@ @'
              // v15.89, doors audit finding: YOUR HIRE ON FOLLOW KEEPS FOLLOWING PAST A LOCKED ROOM. The _CT.locked test
              // here was dead: no container ever carries it, so the caches inside BLAST FREEZER or FOREMAN OFFICE passed
              // this filter. Walking past the south side of a shut room put him within 160 of one, he picked it, navPath
              // gave no route into another region, seekPoint steered him straight at it and he ground along the shell
              // wall. The drop line above lets go only at 280 from the box, which a 230 room never allows, and the FOLLOW
              // walk below never runs while a goal is held, so he stood there and stopped following for as long as you
              // stayed within 420 of him; when you spent the key he was already aimed at the cache and took it first. A
              // box inside a room whose door is still shut is skipped now (shutRoomAt, beside navReachable); once the key
              // opens the room its boxes are picked as before, and a room never shuts again. No text, number or seeded
              // draw moved.
              if(_CT.opened||_CT.mine||(_CT.prog||0)>0||shutRoomAt(G.map,_CT.x,_CT.y)) continue;
              if(dist(e,_CT)<160&&dist(p,_CT)<420){ e.mgoal=_CT; e.mlootT=0; break; }
'@
SubRx @'
var VER='15.88';
'@ @'
var VER='15.89';
'@

$pat = "(?m)^  now:'v15\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v15.89: YOUR HIRE ON FOLLOW KEEPS FOLLOWING PAST A LOCKED ROOM. Under FOLLOW your hire picked any shut box within 160 of him, and the caches inside a locked room passed that test, so walking past BLAST FREEZER or FOREMAN OFFICE he aimed at a box no route reaches, ground along its wall and stopped following you until you moved 420 away or spent the key, and then he took the cache first. A box inside a room whose door is still shut is no longer picked, and once the key opens the room he takes its boxes as before. Check 15.89 stages him outside a shut room and again with its door opened by the key; it fails on v15.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
