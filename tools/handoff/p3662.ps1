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

# material hit puffs (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function spark(x,y,col,n,spread){
'@ @'
// v28.xx (cw-cx-materialpuffs): his pick 80, match the sound material with a few brief chips, dust or sparks. Cosmetic stream only.
function wallImpactFx(w,x,y,ux,uy){
  if(!G||G.sim||!fowLive(x,y)) return 0;
  if(G._impFxFrame!==G.frameN){ G._impFxFrame=G.frameN; G._impFxN=0; }
  if((G._impFxN||0)>=8) return 0;
  G._impFxN=(G._impFxN||0)+1;
  var mat=matOf(w), reduced=CFG.fxLevel===0||GFXQ.particles===0||CFG.flashRed===1;
  var n=reduced?1:(mat==='concrete'?2:4), a=Math.atan2(-uy,-ux), i, ang, speed;
  for(i=0;i<n;i++){
    if(mat==='concrete'){
      G.puffs.push({x:x+fxn(-3,3),y:y+fxn(-2,2),t:0,life:fxn(.20,.28),c:'#b1a28d',r:fxn(5,9)});
    }else{
      ang=a+fxn(-1.25,1.25); speed=fxn(35,105);
      G.sparks.push({x:x,y:y,vx:Math.cos(ang)*speed,vy:Math.sin(ang)*speed,t:0,
        life:mat==='wood'?fxn(.18,.28):fxn(.10,.18),c:mat==='wood'?'#ba8a51':(mat==='glass'?'#b4d5dc':'#ffd58b'),
        z:mat==='wood'?2:1.8,nc:mat!=='metal',sl:mat==='wood'?6:4});
    }
  }
  return n;
}
function spark(x,y,col,n,spread){
'@

SubRx @'
          spark(b.x,b.y,'#ffd9a0',3,110);
          if(!G.sim) G.puffs.push({x:b.x,y:b.y,t:0,life:.18,c:'#8a939c',r:6});
'@ @'
          wallImpactFx(_struck,b.x-ux*_ex,b.y-uy*_ex,ux,uy);   // v28.xx (cw-cx-materialpuffs): entry face, same material as the sound
'@

SubRx @'
          spark(b.x,b.y,'#ffd9a0',5,150);
          if(!G.sim) G.puffs.push({x:b.x,y:b.y,t:0,life:.22,c:'#8a939c',r:9});
'@ @'
          wallImpactFx(_struck,b.x,b.y,ux,uy);   // v28.xx (cw-cx-materialpuffs): stop and bounce share the bounded material burst
'@

SubRx @'
    var _sz=sp.z||3.4;   // v32.xx (cw-machfx) a34 B: 3.4 px sparks with a white-yellow core (#ffe9a8); blood and metal chunks have no core
'@ @'
    // v28.xx (cw-cx-materialpuffs): slim moving splinters and short spark streaks in the smooth look; pixel mode keeps its whole-unit chips.
    if(sp.sl){
      var _sa=Math.atan2(sp.vy,sp.vx), _sx=Math.cos(_sa)*sp.sl/2, _sy=Math.sin(_sa)*sp.sl/2;
      wc.strokeStyle=sp.c; wc.lineWidth=sp.z||1.8; wc.beginPath();
      wc.moveTo(sp.x-_sx,sp.y-7.8-_sy); wc.lineTo(sp.x+_sx,sp.y-7.8+_sy); wc.stroke(); continue;
    }
    var _sz=sp.z||3.4;   // v28.xx (cw-cx-materialpuffs): existing sparks keep their square core
'@

SubRx @'
    if(b.life<=0||(G.map&&G.map.segs&&!losClear(b.x,b.y,nx,ny,G.map.segs))) G.fxBullets.splice(i,1); else { b.x=nx; b.y=ny; }
'@ @'
    // v28.xx (cw-cx-materialpuffs): the other window derives its own visible hit from the existing cosmetic tracer; no new packet or shared state.
    var _fxBlocked=G.map&&G.map.segs&&!losClear(b.x,b.y,nx,ny,G.map.segs);
    if(_fxBlocked){
      var _fxD=Math.hypot(nx-b.x,ny-b.y), _fxW=null, _fxT=_fxD+1, _fxL=G.map.walls||[], _fi, _ft;
      if(_fxD>0) for(_fi=0;_fi<_fxL.length;_fi++){
        if(_fxL[_fi].win) continue;
        _ft=rayRect(b.x,b.y,b.vx*dt/_fxD,b.vy*dt/_fxD,_fxL[_fi],_fxD);
        if(_ft>=0&&_ft<_fxT){ _fxT=_ft; _fxW=_fxL[_fi]; }
      }
      if(_fxW) wallImpactFx(_fxW,b.x+b.vx*dt/_fxD*_fxT,b.y+b.vy*dt/_fxD*_fxT,b.vx*dt/_fxD,b.vy*dt/_fxD);
    }
    if(b.life<=0||_fxBlocked) G.fxBullets.splice(i,1); else { b.x=nx; b.y=ny; }
'@

SubRx @'
var VER='36.61';
'@ @'
var VER='36.62';
'@

$pat = "(?m)^  now:'v36\.61:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.62: A few short-lived splinters, dust puffs or sparks use matOf, including teammate tracers. Eight bursts per frame, cosmetic randomness only. LOCAL: no linked review. Check 36.62 fails on v36.61',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
