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

# ============ HIS NOTE, 2026-09-03 about 21:20: "pillagers still glitching into
# ============ walls in the undercroft". The errand walk (v8.07) already calls
# ============ collide(c,HB.walls) every step, and it did nothing: collide pushes
# ============ a body out by its radius r, and the loose crowd and the hired man
# ============ were built without one, so d2<r*r was never true and every walker
# ============ passed through the piers, the counters and the lift housing. The
# ============ post holders have a radius and drift home without any push at all,
# ============ and the separation pass and the hired man's follow move bodies with
# ============ no push either. Every body has a radius now and every move that
# ============ changes a position is followed by the wall push.

# 1. A radius on every body.
SubRx @'
    crowd.push({x:170,y:400,face:0,t0:rnd(0,6),job:'follow',mercTag:1,
'@ @'
    crowd.push({x:170,y:400,r:12,face:0,t0:rnd(0,6),job:'follow',mercTag:1,   // v10.60: r, or collide cannot push him
'@
SubRx @'
      crowd.push({x:px2, y:py2,
'@ @'
      crowd.push({x:px2, y:py2, r:12,   // v10.60: r, or the errand walk's collide is inert
'@

# 2. The post holder drifting home takes the push.
SubRx @'
        c.x+=hdx/hd*hs; c.y+=hdy/hd*hs;
'@ @'
        c.x+=hdx/hd*hs; c.y+=hdy/hd*hs;
        collide(c,HB.walls);   // v10.60: home is beside a counter; the walk back goes round it
'@

# 3. The separation pass and the hired man's follow take the push.
SubRx @'
            _B2.x=clamp(_B2.x+_sx2/_sd2*_pu2,34,HUBW-34); _B2.y=clamp(_B2.y+_sy2/_sd2*_pu2,34,HUBH-34);
'@ @'
            _B2.x=clamp(_B2.x+_sx2/_sd2*_pu2,34,HUBW-34); _B2.y=clamp(_B2.y+_sy2/_sd2*_pu2,34,HUBH-34);
            collide(_A2,HB.walls); collide(_B2,HB.walls);   // v10.60: a shove never lands anyone in a wall
'@
SubRx @'
          if(_dm>70){ _c.x+=_dxm/_dm*126*dt; _c.y+=_dym/_dm*126*dt; _mv=1; }
'@ @'
          if(_dm>70){ _c.x+=_dxm/_dm*126*dt; _c.y+=_dym/_dm*126*dt; _mv=1; collide(_c,HB.walls); }   // v10.60
'@

SubRx @'
var VER='10.59';
'@ @'
var VER='10.60';
'@
SubRx @'
  now:'v10.59: behind a wall you look like yourself, faded, instead of turning into a light-blue cutout. Your coat, your racks, your stance and your gun, seen through the wall.',
'@ @'
  now:'v10.60: nobody in the Undercroft walks through a wall any more. The crowd, the counter staff and the hired man all take the same wall push you do.',
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
