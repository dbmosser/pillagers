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

# THE UNDERCROFT WALLS SIT IN THE ROOM LIGHT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function hubWall(o,x,y,w,h,d){ o.push({x:x,y:y,w:w,h:h,d:d===undefined?0:d}); }
'@ @'
function hubWall(o,x,y,w,h,d){ o.push({x:x,y:y,w:w,h:h,d:d===undefined?0:d}); }
// v19.35: a wall colour taken part of the way toward the Undercroft's dim navy (k 0 keeps it, 1 is the navy). Cached per colour.
var HUBWC={};
function hubWallHex(hex,k){
  var key=hex+'|'+k, v=HUBWC[key], a, b=[0x1c,0x24,0x40], i, c, o='#';
  if(v) return v;
  a=[parseInt(hex.slice(1,3),16),parseInt(hex.slice(3,5),16),parseInt(hex.slice(5,7),16)];
  for(i=0;i<3;i++){ c=Math.max(0,Math.min(255,Math.round(a[i]+(b[i]-a[i])*k))); o+=(c<16?'0':'')+c.toString(16); }
  return HUBWC[key]=o;
}
'@

SubRx @'
      wc.fillStyle=DISTRICTS[d3].wall; wc.fillRect(q.x,q.y+q.h-L,q.w,L);
      wc.fillStyle=DISTRICTS[d3].wallTop; wc.fillRect(q.x,q.y-L,q.w,q.h);
'@ @'
      // v19.35, seen on the 4K Undercroft screenshot (2026-10-08): the walls here wore the raid's daylight colours at full strength, so
      // in this dark navy room the blue ones by the lift, the purple by the shop and the green by Settings glowed like lit panels. Each
      // keeps its colour, taken about half way down into the room's own light (hubWallHex), so the walls sit in the room.
      wc.fillStyle=hubWallHex(DISTRICTS[d3].wall,0.55); wc.fillRect(q.x,q.y+q.h-L,q.w,L);
      wc.fillStyle=hubWallHex(DISTRICTS[d3].wallTop,0.45); wc.fillRect(q.x,q.y-L,q.w,q.h);
'@

SubRx @'
var VER='19.34';
'@ @'
var VER='19.35';
'@

$pat = "(?m)^  now:'v19\.34:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v19.35: The Undercroft walls are dimmed to suit the room; each keeps its colour. Check 19.35 fails on v19.34',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
