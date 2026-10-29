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

# NO ROLLING IN WATER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  if(!p.downed&&!(p.roll>0)&&!(p.rollCd>0)&&p.stam<ROLLSTAM){
'@ @'
  // v28.xx (cw-cx-waterroll), HIS WORDS 2026-10-28: "roll shouldn't work in water". Refuse before stamina or the tired callout.
  if(inWater(p.x,p.y)){ if(!G.sim) blip('clank'); return; }
  if(!p.downed&&!(p.roll>0)&&!(p.rollCd>0)&&p.stam<ROLLSTAM){
'@

SubRx @'
  if(p.rollCd>0) p.rollCd-=dt;
'@ @'
  if(p.rollCd>0) p.rollCd-=dt;
  // v28.xx (cw-cx-waterroll): entering water by a shove or correction also ends an active roll.
  if(p.roll>0&&inWater(p.x,p.y)){ p.roll=0; p.rollWet=true; }
'@

SubRx @'
      p.x+=p.rollDir.x*rd/rsl; p.y+=p.rollDir.y*rd/rsl;
      collide(p,G.map.walls);
'@ @'
      var rwx=p.x,rwy=p.y;
      p.x+=p.rollDir.x*rd/rsl; p.y+=p.rollDir.y*rd/rsl;
      collide(p,G.map.walls);
      // v28.xx (cw-cx-waterroll): finish at the bank, with no remaining roll-speed steps this frame.
      if(rollWaterEnd(p,rwx,rwy)){ G.sprinting=false; break; }
'@

SubRx @'
  var wading=inWaterDeep(p.x,p.y,(CFG.wadeInset===undefined?11:CFG.wadeInset));
'@ @'
  // v28.xx (cw-cx-waterroll): a roll stopped at the bank wades immediately; normal walking keeps its existing shore inset.
  if(p.rollWet&&!inWater(p.x,p.y)) p.rollWet=false;
  var wading=inWaterDeep(p.x,p.y,(CFG.wadeInset===undefined?11:CFG.wadeInset))||!!p.rollWet;
'@

SubRx @'
var ROLLSPD=320,ROLLSTAM=45;
'@ @'
var ROLLSPD=320,ROLLSTAM=45;
// v28.xx (cw-cx-waterroll), HIS WORDS: "roll shouldn't work in water". Both human seats and pillagers stop at the first wet point.
function rollWaterEnd(p,ox,oy){
  var nx=p.x,ny=p.y,parts=Math.max(1,Math.ceil(Math.hypot(nx-ox,ny-oy))),lo=0,hi=0;
  // v28.xx (cw-cx-waterroll): sample inside the existing collision step too, so a thin strip cannot be skipped by a dry endpoint.
  for(var i=1;i<=parts;i++){
    var t=i/parts;
    if(inWater(ox+(nx-ox)*t,oy+(ny-oy)*t)){ lo=(i-1)/parts; hi=t; break; }
  }
  if(!hi) return false;
  for(var j=0;j<10;j++){
    var mid=(lo+hi)*0.5;
    if(inWater(ox+(nx-ox)*mid,oy+(ny-oy)*mid)) hi=mid; else lo=mid;
  }
  p.x=ox+(nx-ox)*hi; p.y=oy+(ny-oy)*hi; p.roll=0; p.rollWet=true;
  return true;
}
'@

SubRx @'
      var _rr=ROLLSPD*dt,_rsl=Math.max(1,Math.ceil(_rr/8));
      for(var _rs2=0;_rs2<_rsl;_rs2++){
        e.x+=(e.rollDir.x*_rr)/_rsl; e.y+=(e.rollDir.y*_rr)/_rsl;
        collide(e,G.map.walls);
      }
'@ @'
      // v28.xx (cw-cx-waterroll): pillagers share the water stop; dry movement and the existing cooldown draw stay in place.
      var _rr=inWater(e.x,e.y)?0:ROLLSPD*dt,_rsl=Math.max(1,Math.ceil(_rr/8));
      if(!_rr) e.roll=0;
      for(var _rs2=0;_rs2<_rsl;_rs2++){
        var _rwx=e.x,_rwy=e.y;
        e.x+=(e.rollDir.x*_rr)/_rsl; e.y+=(e.rollDir.y*_rr)/_rsl;
        collide(e,G.map.walls);
        if(rollWaterEnd(e,_rwx,_rwy)) break;
      }
'@

SubRx @'
                 !en.roll&&!(en.rollCd>0)&&en.hp>0&&
'@ @'
                 !en.roll&&!(en.rollCd>0)&&en.hp>0&&!inWater(en.x,en.y)&&   /* v28.xx (cw-cx-waterroll): a shot cannot start a water roll. */
'@

SubRx @'
  if(m.sk&&CFG.raiderRoll!==0&&e.kind==='raider'&&!e.downed&&!e.finished&&!e.roll&&!(e.rollCd>0)&&e.hp>0&&typeof m.a==='number'&&isFinite(m.a)&&
'@ @'
  if(m.sk&&CFG.raiderRoll!==0&&e.kind==='raider'&&!e.downed&&!e.finished&&!e.roll&&!(e.rollCd>0)&&e.hp>0&&!inWater(e.x,e.y)&&typeof m.a==='number'&&isFinite(m.a)&&   /* v28.xx (cw-cx-waterroll): the partner shot obeys the same water rule. */
'@

SubRx @'
var VER='36.41';
'@ @'
var VER='36.42';
'@

$pat = "(?m)^  now:'v36\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.42: no rolling in water Check 36.42 fails on v36.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
