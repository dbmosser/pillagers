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

# ============ HIS NOTE: THE PLAYER MARKER ON THE MAP IS TOO SMALL.
# ============
# ============ "player marker on map sohuld be much larger, hard to see right
# ============ now", 2026-09-04.
# ============
# ============ REPRODUCED, measured on the drawn map at 1920x1080: the gold dot
# ============ that is YOU is 8 pixels across and 7 tall, 43 gold pixels in
# ============ total, on a two million pixel screen.
# ============
# ============ TWO REASONS IT IS THE SMALLEST THING ON A SCREEN IT SHOULD OWN.
# ============ Its radius is a bare 4, and unlike every neighbour it is NOT
# ============ multiplied by the map's own scale: the cache ring is 9+2q times
# ============ that scale, the encampment 5 times, the key 3.2 times. So the one
# ============ marker he needs to find first is the only one that does not grow
# ============ when he makes the map bigger.
# ============
# ============ THE FIX: the dot roughly doubles and joins the same scale as its
# ============ neighbours, the ink ring around it grows with it so it still reads
# ============ on a gold district block, the heading line gets longer so which
# ============ way he is facing is legible at a glance, and a soft halo goes
# ============ under the lot so the marker separates from whatever it is standing
# ============ on. Per his Q23 this and the extraction rings are the two things
# ============ he is never allowed to lose, and it was losing.
SubRx @'
  // your own marker, ringed in ink so a gold dot never disappears into a gold
  // district block
  ctx.fillStyle='#120e0c';
  ctx.beginPath(); ctx.arc(ox+p.x*sc,oy+p.y*sc,5.6,0,6.2832); ctx.fill();
  ctx.fillStyle='#ffc04a';
  ctx.beginPath(); ctx.arc(ox+p.x*sc,oy+p.y*sc,4,0,6.2832); ctx.fill();
  ctx.strokeStyle='rgba(255,192,74,.65)'; ctx.lineWidth=1.5;
  ctx.beginPath(); ctx.moveTo(ox+p.x*sc,oy+p.y*sc);
  ctx.lineTo(ox+p.x*sc+Math.cos(p.face)*11,oy+p.y*sc+Math.sin(p.face)*11); ctx.stroke();
'@ @'
  // your own marker, ringed in ink so a gold dot never disappears into a gold
  // district block.
  // v10.92, HIS NOTE: it was 8 pixels across at 1920x1080 and did not follow the
  // map scale, so it was the smallest marker on a screen it is supposed to own.
  // It is roughly double now and scaled like its neighbours, with a halo under
  // it so it separates from whatever it is standing on.
  var _pmz=(typeof _MZ==='number'&&_MZ>0)?_MZ:1;
  var _pmx=ox+p.x*sc, _pmy=oy+p.y*sc;
  ctx.fillStyle='rgba(255,192,74,.18)';
  ctx.beginPath(); ctx.arc(_pmx,_pmy,15*_pmz,0,6.2832); ctx.fill();
  ctx.fillStyle='#120e0c';
  ctx.beginPath(); ctx.arc(_pmx,_pmy,11*_pmz,0,6.2832); ctx.fill();
  ctx.fillStyle='#ffc04a';
  ctx.beginPath(); ctx.arc(_pmx,_pmy,8*_pmz,0,6.2832); ctx.fill();
  ctx.strokeStyle='rgba(255,192,74,.85)'; ctx.lineWidth=2.5*_pmz;
  ctx.beginPath(); ctx.moveTo(_pmx,_pmy);
  ctx.lineTo(_pmx+Math.cos(p.face)*24*_pmz,_pmy+Math.sin(p.face)*24*_pmz); ctx.stroke();
  ctx.lineWidth=1;
'@

SubRx @'
var VER='10.91';
'@ @'
var VER='10.92';
'@
SubRx @'
  now:'v10.91: the resize grip had nowhere to drag to, your note. The gear panel sits 8 pixels from the right of the screen and its grip was in that corner, so there was no room to make it bigger. A panel pinned to the right edge grips on its LEFT now and is sized from its top-right corner.',
'@ @'
  now:'v10.92: your marker on the map was 8 pixels across, the smallest thing on a screen it is meant to own, and the only marker that did not grow with the map. It is roughly double now, scaled like its neighbours, with a halo under it and a longer heading line.',
'@
SubRx @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
'@ @'
  'THIS IS AN ALPHA. Things will break. When something does, the game writes it into your run report and tells you so; that report is how it gets fixed.',
  'YOU ARE MUCH EASIER TO FIND ON THE MAP. Your marker was eight pixels across and was the only one that did not grow when the map did. It is about twice the size now, with a halo under it and a longer line showing which way you are facing.',
'@
SubRx @'
var WHATSNEW_VER='10.91';
'@ @'
var WHATSNEW_VER='10.92';
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
