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

# TRIPWIRE MINES ARE DRAWN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      wc.fillRect(_LK.doorX-2,_LK.doorY-32,4,7);
    }
    wc.restore();
  }
'@ @'
      wc.fillRect(_LK.doorX-2,_LK.doorY-32,4,7);
    }
    wc.restore();
  }
  if((G.trips&&G.trips.length)||(p.cooking&&p.cookKind==='trip')) tripDraw(Z,ox,oy);   // v23.xx (feat1d): the Tripwire Mines, above the fog
'@

SubRx @'
function explodeFrag(f){
'@ @'
// v23.xx (feat1d), HIS #6 (2026-10-12): THE TRIPWIRE MINE IS DRAWN. Every strung wire draws above the fog, so you and your teammate
// always see your wires: a faint red line with a slow pulse, a small emitter at each end with an LED (amber and blinking while it
// arms, red once live), dashed while it arms. While a mine is in your hand (the trigger held) a dashed preview shows where the wire
// will go: the same landing and the same wall stops as the throw (throwFrom and tripArm). Cosmetic only: no draw on any stream.
function tripPreview(){
  var p=G.player, mw=mouseWorld(), dx=mw.x-p.x, dy=mw.y-p.y, d=Math.sqrt(dx*dx+dy*dy), r=Math.min(d,270), ux=d>1?dx/d:1, uy=d>1?dy/d:0;
  var wt=rayHitG(p.x,p.y,ux,uy,r); if(wt<r) r=Math.max(wt*0.6,wt-12);
  var tx=p.x+ux*r, ty=p.y+uy*r, nx=-uy, ny=ux;
  var h=function(sx,sy){ var q=rayHitG(tx,ty,sx,sy,TRIP_REACH); return q<TRIP_REACH?Math.max(2,q-4):TRIP_HALF; };
  var a=h(nx,ny), b=h(-nx,-ny);
  return {x:tx,y:ty,ax:tx+nx*a,ay:ty+ny*a,bx:tx-nx*b,by:ty-ny*b};
}
function tripDraw(Z,ox,oy){
  var i, T, pu, lv, k, ex, ey, P2=G.player, pv;
  wc.save(); wc.scale(Z,Z); wc.translate(-ox,-oy);
  wc.lineCap='round';
  for(i=0;i<(G.trips||[]).length;i++){
    T=G.trips[i]; lv=!(T.arm>0);
    pu=0.5+0.5*Math.sin(G.t*3+i*1.3);
    wc.strokeStyle='rgba(255,74,74,'+(0.14+0.08*pu).toFixed(3)+')'; wc.lineWidth=1.6;
    if(!lv) wc.setLineDash([6,5]);
    wc.beginPath(); wc.moveTo(T.ax,T.ay); wc.lineTo(T.bx,T.by); wc.stroke();
    if(!lv) wc.setLineDash([]);
    for(k=0;k<2;k++){
      ex=k?T.bx:T.ax; ey=k?T.by:T.ay;
      wc.fillStyle='#2e3238'; wc.fillRect(ex-3,ey-3,6,6);
      wc.fillStyle=lv?('rgba(255,60,60,'+(0.55+0.45*pu).toFixed(3)+')'):((Math.floor(G.t*6)%2)?'#ffc04a':'#5a4410');
      wc.fillRect(ex-1.2,ey-1.2,2.4,2.4);
    }
  }
  if(P2&&P2.cooking&&P2.cookKind==='trip'){
    pv=tripPreview();
    wc.strokeStyle='rgba(255,120,110,.55)'; wc.lineWidth=1.4; wc.setLineDash([4,6]);
    wc.beginPath(); wc.moveTo(pv.ax,pv.ay); wc.lineTo(pv.bx,pv.by); wc.stroke();
    wc.setLineDash([]);
    wc.strokeStyle='rgba(255,120,110,.4)'; wc.beginPath(); wc.arc(pv.x,pv.y,5,0,6.2832); wc.stroke();
  }
  wc.restore();
}
function explodeFrag(f){
'@

SubRx @'
        ctx.fillText('RELEASE TO THROW',cs2.x,cs2.y-LH(14));
'@ @'
        ctx.fillText(p.cookKind==='trip'?'RELEASE TO SET':'RELEASE TO THROW',cs2.x,cs2.y-LH(14));   // v23.xx (feat1d): a Tripwire Mine is set, not thrown at something
'@

SubRx @'
  } else if(key==='frag'){
    ground(30,42);
'@ @'
  } else if(key==='trip'){
    // v23.xx (feat1d): the Tripwire Mine, a squat charge with a red eye and its two emitters on a dashed red wire
    ground(40,38);
    c.strokeStyle='rgba(255,74,74,.9)'; c.lineWidth=2.4*u; if(c.setLineDash) c.setLineDash([7*u,4*u]);
    c.beginPath(); c.moveTo(-44*u,-26*u); c.lineTo(44*u,-26*u); c.stroke(); if(c.setLineDash) c.setLineDash([]);
    c.beginPath(); c.moveTo(-8*u,-8*u); c.lineTo(-40*u,-24*u); c.moveTo(8*u,-8*u); c.lineTo(40*u,-24*u); c.lineWidth=2.2*u; c.strokeStyle='#9aa3ad'; c.stroke();
    rr(-50,-32,12,12,2); c.fillStyle='#5d6168'; c.fill(); inkS(OL*0.7);
    rr(38,-32,12,12,2); c.fillStyle='#5d6168'; c.fill(); inkS(OL*0.7);
    rr(-30,-8,60,40,8); c.fillStyle=lin(0,-8,0,32,[[0,'#7a828c'],[0.5,'#4a5058'],[1,'#22262c']]); c.fill(); inkS();
    c.fillStyle='rgba(255,255,255,.22)'; rr(-24,-4,48,6,3); c.fill();
    ell(0,13,8,8); c.fillStyle=rad(-2,11,10,[[0,'#ffe0d8'],[0.45,col||'#ff4a4a'],[1,'#7a1010']]); c.fill(); inkS(OL*0.7);
  } else if(key==='frag'){
    ground(30,42);
'@

SubRx @'
var VER='23.75';
'@ @'
var VER='23.76';
'@

$pat = "(?m)^  now:'v23\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.76: Tripwire Mines are now drawn as a faint red wire with a preview while you hold one, and the mine has its own icon. Check 23.76 fails on v23.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
