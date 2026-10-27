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

# EVERY BUSH AND TREE STANDS ON A PATCH OF GRASS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  for(i=0;i<Math.round(380*AREA);i++){

'@ @'
  // v28.xx (cw-bushturf), HIS NOTE (2026-10-25, v34.78 photo): "Why do we have bricks on the floor but a bush on top of the bricks, makes no sense."
  // Every bush and tree gets a ragged patch of turf under it, baked into the ground (render layer only: grit() hashes, no rr/rnd, nothing moves).
  // Two passes: a wide faint rim so the edge blends, then the solid patch. The grass tufts below land on it too.
  (function(){
    var all=(map.bushes||[]).slice(),q,pass,k2,a,rr0,P,tw,tc=vegT(isDay()?'#627f47':'#27381d',map.veg);
    for(q=0;q<map.walls.length;q++){ tw=map.walls[q]; if(tw.tree) all.push({x:tw.x+tw.w/2,y:tw.y+tw.h/2,r:Math.max(tw.w,tw.h)*0.5}); }
    c.fillStyle=tc;
    for(q=0;q<all.length;q++){ P=all[q];
      for(pass=0;pass<2;pass++){
        c.globalAlpha=pass?1:0.30; c.beginPath();
        for(k2=0;k2<24;k2++){
          a=k2/24*6.2832; rr0=P.r+(pass?5:12)+grit(P.x+k2*37,P.y+k2*91)*(pass?9:10);
          if(k2) c.lineTo(P.x+Math.cos(a)*rr0,P.y+Math.sin(a)*rr0*0.86); else c.moveTo(P.x+Math.cos(a)*rr0,P.y+Math.sin(a)*rr0*0.86);
        }
        c.closePath(); c.fill();
      }
    }
    c.globalAlpha=1;
  })();
  for(i=0;i<Math.round(380*AREA);i++){

'@

SubRx @'
var VER='34.99';
'@ @'
var VER='35.00';
'@

$pat = "(?m)^  now:'v34\.99:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.00: Bushes and trees sit on a patch of grass instead of on bare slab. Check 35.00 fails on v34.99',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
