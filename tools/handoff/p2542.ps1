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

# A CRAWLER ON YOU STAYS ON YOUR SIDE OF THE WALL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var UNITPLURAL={sentry:'sentries',crawler:'crawlers',raider:'pillagers',snitch:'criers',listener:'listeners'};
'@ @'
// latchfixa (2026-10-12), found by the review of crawlerlatch: A LATCHED CRAWLER IS NEVER SHOVED THROUGH A WALL. It was set at
// your side each frame with no wall test, 28 units from your centre. Walk toward a wall with it on that side and its centre landed
// 17 units inside the face; collide() then pushed it out through the nearest face, which for any wall thinner than about 34 (the
// median is 16) is the FAR one. The wall then sat between you, it let go after 0.3 s and was stranded on the other side, 98 to 502
// units away. Measured on 34 building walls with a crawler hanging on between him and the wall: it went through 32. Now the spot
// at your side must be clear (no wall over its body, and a clear line from you to it); when the side it holds is blocked it slides
// round you, 0.3 rad at a time either way, to the first clear spot, and if you are boxed in on every side it stays put this frame.
function latchSpotOk(b,x,y,r){
  var ws, i, w, dx, dy;
  if(x<8||y<8||x>WORLD_W-8||y>WORLD_H-8) return false;
  ws=(G.wgrid&&G.wgrid.walls===G.map.walls)?wallsNear(G.wgrid,x,y,r):G.map.walls;
  for(i=0;i<ws.length;i++){ w=ws[i]; dx=x-clamp(x,w.x,w.x+w.w); dy=y-clamp(y,w.y,w.y+w.h); if(dx*dx+dy*dy<r*r) return false; }
  return losClear(b.x,b.y,x,y,G.map.segs);
}
function crawlerLatchPlace(e,b){
  var a0=Math.atan2(e.y-b.y,e.x-b.x), lr=e.r+(b.r||11)+2, k, a, x, y;
  for(k=0;k<=21;k++){
    a=a0+(k?((k%2?1:-1)*Math.ceil(k/2)*0.3):0);
    x=b.x+Math.cos(a)*lr; y=b.y+Math.sin(a)*lr;
    if(latchSpotOk(b,x,y,e.r)){ e.x=x; e.y=y; return true; }
  }
  return false;
}
var UNITPLURAL={sentry:'sentries',crawler:'crawlers',raider:'pillagers',snitch:'criers',listener:'listeners'};
'@

SubRx @'
          var _la=Math.atan2(e.y-_lb.y,e.x-_lb.x), _lr=e.r+(_lb.r||11)+2;
          e.x=_lb.x+Math.cos(_la)*_lr; e.y=_lb.y+Math.sin(_la)*_lr;
'@ @'
          crawlerLatchPlace(e,_lb);   // latchfixa: at your side, never inside or through a wall
'@

SubRx @'
var VER='25.41';
'@ @'
var VER='25.42';
'@

$pat = "(?m)^  now:'v25\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.42: A crawler hanging on to you can no longer be shoved through a wall and lost; it slides round to your side and keeps biting. Check 25.42 fails on v25.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
