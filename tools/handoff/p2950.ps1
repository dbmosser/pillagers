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

# The item wheel opens in the Undercroft (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HUBBELT={cells:[]};
'@ @'
// v28.xx (cw-wheelhub), HIS ORDER (2026-10-15): "The wheel is accessible in the Undercroft, even though nothing can be used there." Q held on the floor opens the
// same item wheel (the same ring, the same eight slots, the counts read from what the stash packs, so the pouch and the backpack kit), and the floor has no raid to use
// anything in: letting go on a slot says so in one line and closes. Nothing is taken out, nothing is spent. A window, the backpack, the title and the pause box keep
// the wheel shut.
var HUBWHEEL=null;
function hubWheelOk(){ return state==='hub'&&!!HB&&!hubBagOpen&&!titleOn()&&!hubWinOn()&&!pauseOpen; }
function hubWheelList(){
  var old=G, w=HUBWHEEL;
  if(!w) return;
  try{ G=hubBagState(); w.list=wheelList(); }catch(_hw){ w.list=[]; }
  finally{ G=old; }
}
function hubWheelOpen(){
  if(HUBWHEEL) return true;
  if(!hubWheelOk()) return false;
  HUBWHEEL={t:0,list:[],sel:-1,mx:W/2,my:H/2,ox:mouse.x,oy:mouse.y,armed:0,d:0,hub:1};
  hubWheelList();
  return HUBWHEEL.list.length>0;
}
function hubWheelRelease(){
  var w=HUBWHEEL;
  HUBWHEEL=null;
  if(w&&w.sel>=0){ try{ hubToast('Nothing to use down here'); }catch(_ht){} }
}
function hubWheelStep(dt){
  var w=HUBWHEEL, dx, dy, d, m, gm;
  if(!w) return;
  if(!hubWheelOk()){ HUBWHEEL=null; return; }
  if(!keys['KeyQ']){ hubWheelRelease(); return; }
  w.t+=dt; hubWheelList(); m=w.list.length;
  if(!m){ HUBWHEEL=null; return; }
  gm=wheelGeom(); w.mx=gm.cx; w.my=gm.cy;
  dx=mouse.x-w.mx; dy=mouse.y-w.my; d=Math.sqrt(dx*dx+dy*dy);
  if(!w.armed&&Math.abs(mouse.x-w.ox)+Math.abs(mouse.y-w.oy)>=LH(10)) w.armed=1;
  w.sel=(!w.armed||d<gm.dz)?-1:wheelAt(m,dx,dy);
  w.d=d;
}
function hubWheelDraw(){
  var w=HUBWHEEL, old=G, st;
  if(!w||!w.list||!w.list.length) return;
  try{ st=hubBagState(); st.wheel=w; G=st; drawWheel(); }catch(_hd){}
  finally{ G=old; }
}
var HUBBELT={cells:[]};
'@

SubRx @'
if(e.code==='Space'&&!e.repeat&&!_hubBusy&&HB&&HB.player&&!(HB.player.rollT>0)){
'@ @'
if(e.code==='KeyQ'&&!e.repeat&&!_hubBusy&&HB){ hubWheelOpen(); e.preventDefault(); return; }   // v28.xx (cw-wheelhub): HOLD Q on the floor opens the item wheel, as in a raid
    if(e.code==='Space'&&!e.repeat&&!_hubBusy&&HB&&HB.player&&!(HB.player.rollT>0)){
'@

SubRx @'
if(!titleOn()){ if(hubBagOpen) drawHubBag(); else drawHubBelt(); }   // v17.83: not under the title
'@ @'
if(!titleOn()){ if(hubBagOpen) drawHubBag(); else drawHubBelt(); }   // v17.83: not under the title
        hubWheelStep(dt); hubWheelDraw();   // v28.xx (cw-wheelhub): the item wheel on the floor
'@

SubRx @'
ctx.font=FS(TYPE.label); tw=ctx.measureText('RELEASE TO TAKE OUT').width+LH(52);
'@ @'
ctx.font=FS(TYPE.label); tw=ctx.measureText(w.hub?'RELEASE TO CLOSE':'RELEASE TO TAKE OUT').width+LH(52);
'@

SubRx @'
hudText('RELEASE TO TAKE OUT',-tw/2+LH(46),LH(2));
'@ @'
hudText(w.hub?'RELEASE TO CLOSE':'RELEASE TO TAKE OUT',-tw/2+LH(46),LH(2));
'@

SubRx @'
var VER='29.49';
'@ @'
var VER='29.50';
'@

$pat = "(?m)^  now:'v29\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v29.50: Hold Q on the Undercroft floor to see the item wheel. Check 29.50 fails on v29.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
