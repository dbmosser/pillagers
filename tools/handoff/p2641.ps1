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

# MOUSE SENSITIVITY, HIP AND AIMING DOWN SIGHTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'rumble', label:'Controller rumble',
'@ @'
  // v26.xx (settings3), HIS ORDER 2026-10-14 ("ok add all this stuff to settings"): MOUSE SENSITIVITY, for the hip and for aiming down sights.
  // The mouse is the cursor, so the sensitivity is how far the AIM TURNS for a move of the mouse: the angle of the cursor round the player is
  // scaled (2x turns twice as far, 0.5x half as far) and the distance is left as it is. 100% is the cursor exactly as it was. See msMove.
  {k:'msHip', label:'MOUSE SENSITIVITY', sec:'CONTROLS',
   hint:'HOW FAR THE AIM TURNS FOR A MOVE OF THE MOUSE. 100% IS THE CURSOR AS IT IS. NOT WHILE THE BACKPACK, THE MAP OR THE WHEEL IS OPEN.',
   opts:[
     {n:'50%',  cfg:{msHip:0.5}},
     {n:'75%',  cfg:{msHip:0.75}},
     {n:'100%', cfg:{msHip:1}},
     {n:'125%', cfg:{msHip:1.25}},
     {n:'150%', cfg:{msHip:1.5}},
     {n:'200%', cfg:{msHip:2}}
   ], def:2},
  {k:'msAds', label:'AIM DOWN SIGHTS SENSITIVITY', sec:'CONTROLS',
   hint:'THE SAME, WHILE YOU AIM DOWN SIGHTS. LOWER IS STEADIER.',
   opts:[
     {n:'50%',  cfg:{msAds:0.5}},
     {n:'75%',  cfg:{msAds:0.75}},
     {n:'100%', cfg:{msAds:1}},
     {n:'125%', cfg:{msAds:1.25}},
     {n:'150%', cfg:{msAds:1.5}},
     {n:'200%', cfg:{msAds:2}}
   ], def:2},
  {k:'rumble', label:'Controller rumble',
'@

SubRx @'
cv.addEventListener('mousemove',function(e){
'@ @'
// v26.xx (settings3), HIS ORDER 2026-10-14: MOUSE SENSITIVITY. In a live raid, with no panel to point at, a move of the mouse turns the aim by the
// row's factor (hip, or aiming down sights while the sights are up): the angle of the real cursor round the player on screen is followed by the
// crosshair scaled, its distance kept, and drawn in along its own line if that would leave the screen. At 100% (or in any menu, the backpack, the
// map, the wheel, the stall, the pause box, over the belt or a HUD panel's bar) the crosshair is the real cursor exactly, as it was. It follows from
// where the crosshair is when scaling starts, so nothing jumps; the real cursor, hidden while aiming, is the OS pointer over the belt and the panels.
var MS={rx:null,ry:null,th:null};
function msSens(){ var p=G&&G.player, v=(p&&p.ads)?CFG.msAds:CFG.msHip; return (typeof v==='number'&&v>=0.2&&v<=4)?v:1; }
function msPlayerScreen(){
  var p=G.player, z=ZOOM(), cx=(G.camX===undefined?p.x-W/(2*z):G.camX), cy=(G.camY===undefined?p.y-H/z*0.54:G.camY);
  return {x:(p.x-cx)*z,y:(p.y-cy)*z};
}
function msLive(rx,ry){
  var i, c, h;
  if(state!=='raid'||!G||G.over||G.sim||!G.player||G.player.downed||G.paused||pauseOpen||tuneOpen) return false;
  if(G.bagOpen||G.mapOpen||G.wheel||G.trade||G.forgeUI||HUDDRAG||HUDRESIZE) return false;
  for(i=0;G.hotCells&&i<G.hotCells.length;i++){ c=G.hotCells[i]; if(rx>=c.x&&rx<=c.x+c.w&&ry>=c.y&&ry<=c.y+c.h) return false; }
  h=(typeof hudHit==='function')?hudHit(rx,ry):null;
  if(h&&(h.part==='bar'||h.part==='glyph'||h.part==='grip')) return false;
  return true;
}
function msMove(rx,ry,px,py){
  var s=msSens(), ps, a0, a1, da, d, x, y, t, m;
  if(s===1||!msLive(rx,ry)){ MS.th=null; MS.rx=null; return false; }
  ps=msPlayerScreen();
  if(MS.th===null||MS.rx===null){ MS.th=Math.atan2(py-ps.y,px-ps.x); MS.rx=px; MS.ry=py; }
  a0=Math.atan2(MS.ry-ps.y,MS.rx-ps.x); a1=Math.atan2(ry-ps.y,rx-ps.x); da=a1-a0;
  while(da>Math.PI) da-=2*Math.PI;
  while(da<-Math.PI) da+=2*Math.PI;
  MS.th+=da*s; MS.rx=rx; MS.ry=ry;
  d=Math.sqrt((rx-ps.x)*(rx-ps.x)+(ry-ps.y)*(ry-ps.y));
  if(!(d>=1)) return true;
  x=d*Math.cos(MS.th); y=d*Math.sin(MS.th); t=1; m=20*hudRes();
  if(W>0&&H>0){
    if(x>0&&ps.x+x>W-m) t=Math.min(t,(W-m-ps.x)/x);
    if(x<0&&ps.x+x<m) t=Math.min(t,(m-ps.x)/x);
    if(y>0&&ps.y+y>H-m) t=Math.min(t,(H-m-ps.y)/y);
    if(y<0&&ps.y+y<m) t=Math.min(t,(m-ps.y)/y);
    if(!(t>0)) t=0;
  }
  mouse.x=clamp(ps.x+x*t,0,W); mouse.y=clamp(ps.y+y*t,0,H);
  return true;
}
cv.addEventListener('mousemove',function(e){
'@

SubRx @'
  mouse.x=e.clientX-r.left; mouse.y=e.clientY-r.top;
'@ @'
  var _mpx=mouse.x, _mpy=mouse.y, _mrx=e.clientX-r.left, _mry=e.clientY-r.top;   // v26.xx (settings3): the crosshair before this move, and the real cursor now
  mouse.x=_mrx; mouse.y=_mry;
'@

SubRx @'
if(typeof PAD!=='undefined'&&PAD&&!(typeof NET!=='undefined'&&NET&&NET.same==='p2')) PAD.curOwn=0;
'@ @'
if(typeof PAD!=='undefined'&&PAD&&!(typeof NET!=='undefined'&&NET&&NET.same==='p2')) PAD.curOwn=0;
  try{ msMove(_mrx,_mry,_mpx,_mpy); }catch(_ms){ MS.th=null; }   // v26.xx (settings3): MOUSE SENSITIVITY
'@

SubRx @'
var VER='26.40';
'@ @'
var VER='26.41';
'@

$pat = "(?m)^  now:'v26\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.41: Controls has mouse sensitivity for the hip and for aiming down sights. Check 26.41 fails on v26.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
