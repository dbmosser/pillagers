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

# CONTROLLER CROSSHAIR ALWAYS ON SCREEN WITH A TRAIL (stability pass, 2026-09-27; drafted by a review agent, reviewed by a second).

SubRx @'
  mouse.x=e.clientX-r.left; mouse.y=e.clientY-r.top;
'@ @'
  mouse.x=e.clientX-r.left; mouse.y=e.clientY-r.top;
  // v16.77, his order: a real mouse move takes the crosshair back from the pad, which places it every frame while it owns
  // it (padCursorPut). Not in the player 2 window of a same machine party: that window has no mouse of its own, so the
  // host pointer crossing it must not drag the child crosshair away.
  if(typeof PAD!=='undefined'&&PAD&&!(typeof NET!=='undefined'&&NET&&NET.same==='p2')) PAD.curOwn=0;
'@

SubRx @'
// v6.89: pollPad has no dt, so anything that MOVES over time inside it needs one. Clamped
'@ @'
// v16.77, his order: WITH A CONTROLLER THE CROSSHAIR IS ALWAYS ON SCREEN, AND IT LEAVES A SLIGHT TRAIL. The pad placed the
// crosshair a reach out from the player and nothing asked whether that point was still on the canvas: aiming toward a map
// edge (where the camera stops following and the player stands near the screen edge), a long aim distance or a zoomed in
// view put it past the edge, and there was no crosshair anywhere. With both sticks idle nothing wrote it at all, so a change
// of aim distance, or the camera settling, left it where it last was, off screen for good. Every pad placement now comes
// through here: the point is drawn in along its own line until it sits inside the canvas, so the aim direction never
// changes, only how far out the mark sits; the pad takes ownership of the crosshair (a real mouse move gives it back); and
// the last six places it stood are kept with their time for the trail drawHUD draws. Every frame the pad owns it with both
// sticks idle, pollPad places it again from where the player stands on screen now (after the stick blocks).
function padCursorPut(psx,psy,dx,dy){
  var m=20*hudRes(), t=1, x, y, now, T, L;
  if(W>0&&H>0){
    if(dx>0&&psx+dx>W-m) t=Math.min(t,(W-m-psx)/dx);
    if(dx<0&&psx+dx<m) t=Math.min(t,(m-psx)/dx);
    if(dy>0&&psy+dy>H-m) t=Math.min(t,(H-m-psy)/dy);
    if(dy<0&&psy+dy<m) t=Math.min(t,(m-psy)/dy);
    if(!(t>0)) t=0;
  }
  x=psx+dx*t; y=psy+dy*t;
  if(W>0&&H>0){ x=clamp(x,0,W); y=clamp(y,0,H); }
  mouse.x=x; mouse.y=y; mouse.init=true; PAD.curOwn=1;
  now=netPadNow(); T=PAD.trail=(PAD.trail||[]); L=T.length?T[T.length-1]:null;
  if(!L||Math.abs(L.x-x)>=1||Math.abs(L.y-y)>=1){ T.push({x:x,y:y,t:now}); while(T.length>6) T.shift(); }
}
// v6.89: pollPad has no dt, so anything that MOVES over time inside it needs one. Clamped
'@

SubRx @'
    mouse.x=_fsx+(PAD.mx/_fl)*_fr*_fz; mouse.y=_fsy+(PAD.my/_fl)*_fr*_fz; mouse.init=true;
'@ @'
    PAD.aimA=Math.atan2(PAD.my,PAD.mx);   // v16.77, his order: the angle the idle frames keep the crosshair on
    padCursorPut(_fsx,_fsy,(PAD.mx/_fl)*_fr*_fz,(PAD.my/_fl)*_fr*_fz);
'@

SubRx @'
    mouse.x=psx+rx*_rr2*pz; mouse.y=psy+ry*_rr2*pz; mouse.init=true;
'@ @'
    PAD.aimA=Math.atan2(ry,rx);   // v16.77, his order: the angle the idle frames keep the crosshair on
    padCursorPut(psx,psy,rx*_rr2*pz,ry*_rr2*pz);
'@

SubRx @'
  // v16.47: A CONTROLLER PLACES A MAP MARKER. With the map open, the right stick moves a cursor across the map (from where you
'@ @'
  // v16.77, his order: BOTH STICKS IDLE, THE CROSSHAIR STAYS. While the pad owns the crosshair it is placed again every frame:
  // the aim distance along the last aim angle from where the player stands on screen now, so it rides with the camera,
  // follows the aim distance as it is changed, and is drawn in to the canvas edge by padCursorPut. Only in a raid, and not
  // under the open map or backpack, where the pointer is the instrument. A pad that never aimed keeps the angle the
  // crosshair already had from the player.
  if(G&&!G.over&&state==='raid'&&G.player&&PAD.curOwn&&!rx&&!ry&&!PAD.mx&&!PAD.my&&!G.mapOpen&&!G.bagOpen){
    var _ip=G.player,_iz=ZOOM();
    var _icx=(G.camX===undefined?_ip.x-W/(2*_iz):G.camX);
    var _icy=(G.camY===undefined?_ip.y-H/_iz*0.54:G.camY);
    var _isx=(_ip.x-_icx)*_iz,_isy=(_ip.y-_icy)*_iz;
    if(PAD.aimA===undefined) PAD.aimA=Math.atan2(mouse.y-_isy,mouse.x-_isx);
    var _ir=(PAD.reach===undefined?200:PAD.reach)*_iz;
    padCursorPut(_isx,_isy,Math.cos(PAD.aimA)*_ir,Math.sin(PAD.aimA)*_ir);
  }
  // v16.47: A CONTROLLER PLACES A MAP MARKER. With the map open, the right stick moves a cursor across the map (from where you
'@

SubRx @'
    var rx0=mouse.x,ry0=mouse.y;
'@ @'
    var rx0=mouse.x,ry0=mouse.y;
    // v16.77, his order: A SLIGHT TRAIL BEHIND THE CONTROLLER CROSSHAIR. The last few places the pad put it (padCursorPut
    // keeps up to six, each with its time), drawn as plain copies of the cross that fade out over a third of a second, so
    // a sweep leaves a short tail and a crosshair at rest shows nothing extra. Nothing is drawn for a mouse.
    if(PAD.on&&PAD.curOwn&&PAD.trail&&PAD.trail.length){
      var _tnow=netPadNow(), _trz=hudRes(), _tg=8*_trz, _tl=7*_trz, _ti, _tp, _ta;
      ctx.lineWidth=1.2*_trz;
      for(_ti=0;_ti<PAD.trail.length;_ti++){
        _tp=PAD.trail[_ti]; _ta=0.30*(1-(_tnow-_tp.t)/0.32);
        if(!(_ta>0)||(Math.abs(_tp.x-rx0)<1&&Math.abs(_tp.y-ry0)<1)) continue;
        ctx.strokeStyle='rgba(230,240,246,'+_ta.toFixed(3)+')';
        ctx.beginPath();
        ctx.moveTo(_tp.x-_tg-_tl,_tp.y); ctx.lineTo(_tp.x-_tg,_tp.y);
        ctx.moveTo(_tp.x+_tg,_tp.y); ctx.lineTo(_tp.x+_tg+_tl,_tp.y);
        ctx.moveTo(_tp.x,_tp.y-_tg-_tl); ctx.lineTo(_tp.x,_tp.y-_tg);
        ctx.moveTo(_tp.x,_tp.y+_tg); ctx.lineTo(_tp.x,_tp.y+_tg+_tl);
        ctx.stroke();
      }
    }
'@

SubRx @'
var VER='16.76';
'@ @'
var VER='16.77';
'@

$pat = "(?m)^  now:'v16\.76:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v16.77: THE CONTROLLER CROSSHAIR IS ALWAYS ON SCREEN, WITH A TRAIL. His order: with a controller the aim crosshair stays on screen when the right stick is untouched, when standing still and when adjusting the aim distance, and it leaves a short fading trail. Check 16.77 fails on v16.76',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
