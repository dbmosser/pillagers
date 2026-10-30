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

# BULLETS THROUGH THE RETICLE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@ @'
// v28.xx (cw-cx-reticleflight), his 10-29 note: "ideally bullets should go through the center of the reticule, right?"
// v28.xx (cw-cx-reticleflight): drawing only. Leave the muzzle at gun height, then meet the sim line over 220 world px; every window uses its existing shot origin.
function shotDrawLift(b,back){
  if(b._rico) return 0;
  var ly=(b.ly>0)?b.ly:12, sx=isFinite(b.sx)?b.sx:b.x, sy=isFinite(b.sy)?b.sy:b.y;
  var t=clamp((Math.hypot(b.x-sx,b.y-sy)-(back||0)-(b.mzd||0))/220,0,1);
  return ly*(1-t*t*(3-2*t));
}
function fireWeapon(sh,wep,tx,ty,fromPlayer){
'@

SubRx @'
    var _ly=(b.ly>0)?b.ly:12;   // v28.xx (cw-thirdsize): at the gun line of the drawn body that fired it (12 for a machine)
    wc.beginPath(); wc.moveTo(b.x-b.vx/bm*_gtl,b.y-b.vy/bm*_gtl-_ly);
    wc.lineTo(b.x,b.y-_ly); wc.stroke();
    if(b.rkt){ wc.fillStyle='#fff3c8'; wc.beginPath(); wc.arc(b.x,b.y-_ly,4,0,6.2832); wc.fill(); }   // v28.xx (cw-rocket): the rocket has a hot head
    if(_trc>1){
      wc.strokeStyle='rgba(255,236,180,.9)'; wc.lineWidth=1;
      wc.beginPath(); wc.moveTo(b.x-b.vx/bm*14,b.y-b.vy/bm*14-_ly);
      wc.lineTo(b.x,b.y-_ly); wc.stroke();
    }
'@ @'
    var _ly=shotDrawLift(b,0), _lt=shotDrawLift(b,_gtl);   // v28.xx (cw-cx-reticleflight): each end follows the blend, so the streak meets the reticle instead of staying parallel above it
    wc.beginPath(); wc.moveTo(b.x-b.vx/bm*_gtl,b.y-b.vy/bm*_gtl-_lt);
    wc.lineTo(b.x,b.y-_ly); wc.stroke();
    if(b.rkt){ wc.fillStyle='#fff3c8'; wc.beginPath(); wc.arc(b.x,b.y-_ly,4,0,6.2832); wc.fill(); }
    if(_trc>1){
      var _gtn=Math.min(14,_gtl);
      wc.strokeStyle='rgba(255,236,180,.9)'; wc.lineWidth=1;
      wc.beginPath(); wc.moveTo(b.x-b.vx/bm*_gtn,b.y-b.vy/bm*_gtn-shotDrawLift(b,_gtn));
      wc.lineTo(b.x,b.y-_ly); wc.stroke();
    }
'@

SubRx @'
G.fxBullets.push({x:+a[0]||0,y:+a[1]||0,vx:+a[2]||0,vy:+a[3]||0,
'@ @'
G.fxBullets.push({x:+a[0]||0,y:+a[1]||0,vx:+a[2]||0,vy:+a[3]||0,_rico:a[7]?1:0,sx:(+a[0]||0)-(+a[2]||0)/(Math.hypot(+a[2]||0,+a[3]||0)||1)*17,sy:(+a[1]||0)-(+a[3]||0)/(Math.hypot(+a[2]||0,+a[3]||0)||1)*17, /* v28.xx (cw-cx-reticleflight): reconstruct the cosmetic origin for every received round, including machines and legacy words; a bounce stays at its impact height; no new packet fields */
'@

SubRx @'
var VER='36.57';
'@ @'
var VER='36.58';
'@

$pat = "(?m)^  now:'v36\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.58: Local, partner and hostile streaks ease from gun height to ground level over 220 world px. Muzzle flashes, sim flight, hits and impacts keep their positions. Check 36.58 fails on v36.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
