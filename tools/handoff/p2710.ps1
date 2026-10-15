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

# GUNS IN HAND, EVEN BIGGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var GUNSPR=null;
'@ @'
// v27.xx (guns2x), HIS ANSWER 42 (2026-10-13): the guns in hand "even bigger". Everything that is drawn in the hands (the baked gun,
// both arms, the hands, the Forge shine, the flash on the gun) is now drawn at GUNK times the size, from the same shoulder point. The
// flash of the shot, the first stretch of the tracer and the ejected brass follow the DRAWN muzzle and port (gunMuzzleAt, gunMuzD,
// gunPortOff) for the player and for pillagers; the real round does not move: it still spawns 17 units out, with the same speed,
// spread and range, and a body's collision radius is unchanged. Cosmetic only.
var GUNK=1.3;
function gunMuzD(sh,wep){
  var D;
  if(!sh||!wep||!G||!(sh===G.player||sh.kind==='raider')) return 0;
  D=GUNDEF[wep.id]||GUNDEF.rifle;
  return (D.tip+(D.pist?2:0))*GUNK;
}
function gunMuzzleAt(sh,wep,a){
  var L=gunMuzD(sh,wep), D, sg, by;
  if(!(L>0)) return null;
  D=GUNDEF[wep.id]||GUNDEF.rifle; sg=(Math.cos(a)<0)?-1:1; by=D.by*GUNK*sg;
  return {x:sh.x+Math.cos(a)*L-Math.sin(a)*by, y:sh.y-20+Math.sin(a)*L+Math.cos(a)*by};
}
function gunPortOff(sh,wep,a){
  var D, d;
  if(!(gunMuzD(sh,wep)>0)) return {x:0,y:0};
  D=GUNDEF[wep.id]||GUNDEF.rifle; d=(D.port?D.port[0]:8)*GUNK;
  return {x:Math.cos(a)*d, y:Math.sin(a)*d};
}
var GUNSPR=null;
'@

SubRx @'
try{ S=Math.min(5,wallSpriteScale()+1); }catch(_s){ S=2; }
'@ @'
try{ S=Math.min(6,Math.ceil((wallSpriteScale()+1)*GUNK)); }catch(_s){ S=2; }   // v27.xx (guns2x): baked for the bigger size
'@

SubRx @'
wc.save(); wc.translate(px,gy); wc.rotate(ang); if(fl<0) wc.scale(1,-1);
'@ @'
wc.save(); wc.translate(px,gy); wc.rotate(ang); if(fl<0) wc.scale(1,-1); wc.scale(GUNK,GUNK); aw/=1.12;   // v27.xx (guns2x): the whole held gun, arms and hands at GUNK times the size
'@

SubRx @'
GFXMUZ.push({g:G,x:sh.x+Math.cos(ang)*17,y:sh.y+Math.sin(ang)*17-12,
'@ @'
var _mz=null; try{ _mz=gunMuzzleAt(sh,wep,ang); }catch(_gm){}   // v27.xx (guns2x): the flash sits on the drawn muzzle of a player or a pillager
  GFXMUZ.push({g:G,x:_mz?_mz.x:sh.x+Math.cos(ang)*17,y:_mz?_mz.y:sh.y+Math.sin(ang)*17-12,
'@

SubRx @'
G.shells.push({brass:1,x:sh.x,y:sh.y,
'@ @'
var _pt=gunPortOff(sh,wep,ang);   // v27.xx (guns2x): the brass leaves the ejection port of the drawn gun
    G.shells.push({brass:1,x:sh.x+_pt.x,y:sh.y+_pt.y,
'@

SubRx @'
G.bullets.push({x:sh.x+Math.cos(ang)*17,
'@ @'
G.bullets.push({sx:sh.x,sy:sh.y,mzd:Math.max(0,gunMuzD(sh,wep)-17),x:sh.x+Math.cos(ang)*17,
'@

SubRx @'
wc.beginPath(); wc.moveTo(b.x-b.vx/bm*9*_trc,b.y-b.vy/bm*9*_trc-12);
'@ @'
var _gtl=9*_trc, _gtv;
    if(b.mzd>0){ _gtv=Math.hypot(b.x-b.sx,b.y-b.sy); if(_gtv<b.mzd) continue; _gtl=Math.min(_gtl,_gtv-b.mzd); }   // v27.xx (guns2x): a tracer starts at the drawn muzzle, not inside the gun
    wc.beginPath(); wc.moveTo(b.x-b.vx/bm*_gtl,b.y-b.vy/bm*_gtl-12);
'@

SubRx @'
var VER='27.09';
'@ @'
var VER='27.10';
'@

$pat = "(?m)^  now:'v27\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.10: The guns in your hands are bigger again, and the muzzle flash, tracer and brass come from the end of the barrel. Check 27.10 fails on v27.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
