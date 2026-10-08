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

# THE CHOIR STAYS ON ITS CACHE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
    containers.push(cc); caches.push({x:use.x,y:use.y,tag:tag});
'@ @'
    containers.push(cc); caches.push({x:use.x,y:use.y,tag:tag,cc:cc});   // v20.48 (H58): and the box itself, so the Choir can follow it
'@

SubRx @'
  if(caches.length>1){
    var _cg=caches[1];
    ents.push(mkChoir(_cg.x,_cg.y));
  } else if(caches.length){
    ents.push(mkChoir(caches[0].x,caches[0].y));
  }
'@ @'
  // v20.48, from the whole-game bug hunt of 2026-10-08 (H58): THE CHOIR FOLLOWS ITS CACHE BOX. It was placed from a copy of where the
  // box first landed, and the reach pass below and the pad clearance in the raid build both move only the box, so a moved cache left
  // the pillbox guarding nothing: on COLD STORAGE about one raid in ten on or beside the north extraction ring. It is still made
  // here, so every seeded draw stays where it was, and at the end of the build it is moved onto the box, where the box ended up.
  var _choir=null, _choirOn=null;
  if(caches.length>1){
    var _cg=caches[1];
    ents.push(_choir=mkChoir(_cg.x,_cg.y)); _choirOn=_cg.cc||null;
  } else if(caches.length){
    ents.push(_choir=mkChoir(caches[0].x,caches[0].y)); _choirOn=caches[0].cc||null;
  }
'@

SubRx @'
  for(var _wid=0;_wid<g.map.walls.length;_wid++) g.map.walls[_wid].wid=_wid;
'@ @'
  for(var _wid=0;_wid<g.map.walls.length;_wid++) g.map.walls[_wid].wid=_wid;
  // v20.48 (H58): the Choir stands on its cache box where the box ended up, unless that spot is against a wall. No draw.
  if(_choir&&_choirOn&&(_choir.x!==_choirOn.x||_choir.y!==_choirOn.y)&&spotFree(g.map,_choirOn.x,_choirOn.y,20)){
    _choir.x=_choir.tx=_choir.homeX=_choirOn.x; _choir.y=_choir.ty=_choir.homeY=_choirOn.y;
  }
'@

SubRx @'
var VER='20.47';
'@ @'
var VER='20.48';
'@

$pat = "(?m)^  now:'v20\.47:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v20.48: The Choir pillbox always stands on its cache, never on a spot the cache was moved away from. Check 20.48 fails on v20.47',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
