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

# AIMING ZOOMS TOWARD THE CROSSHAIR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function render2D(dt){
'@ @'
// v28.xx (cw-cx-aimfocus), HIS WORDS 2026-10-29: "the zoom should happen towards their scope"; "half way between the cursor and the character".
// v28.xx (cw-cx-aimfocus): ease a WORLD focal point, half way along the aim (0.6 for long guns). Calibrate its screen slot on entry so zoom preserves the aimed ground point.
// v28.xx (cw-cx-aimfocus): a literal halfway zoom pivot moves the aimed target; the entry bias reconciles halfway look-ahead with zoom-to-cursor. Never feed screen-pixel lean back into world focus.
function adsCameraFrame(dt){
  var p=G.player, oldZ=ZOOM(), baseZ=ZC*hudRes(), kx=W/2, ky=H*.54;
  var d=Math.max(0,Math.min(.1,+dt||0)), ke=Math.min(1,Math.max(0,+dt||0)*9);
  var m=opticMag(), amount=(CFG.adsZoom===undefined)?.35:CFG.adsZoom;
  var live=!G.sim&&!G.over&&state==='raid';
  var aiming=!!(live&&p.ads&&!p.downed&&!(p.roll>0)&&p.wep&&p.wep.mag>0&&!(typeof PAD!=='undefined'&&PAD&&PAD.adsing&&!PAD.adsAim));
  var target=aiming?Math.max(1,ADS_ZMIN+(m-1)*amount):((CFG.sprintZoom!==0&&G.sprinting&&live&&!p.downed)?SPRINT_ZK:1);
  var pad=!!(typeof PAD!=='undefined'&&PAD&&PAD.curOwn), reach=pad?(PAD.reach===undefined?(p.wep&&p.wep.rng||200):PAD.reach):0;
  var angle=pad?(PAD.aimA===undefined?p.face:PAD.aimA):0;
  var oldX=G.camX===undefined?p.x-kx/oldZ:G.camX, oldY=G.camY===undefined?p.y-ky/oldZ:G.camY;
  var aimX=pad?p.x+Math.cos(angle)*reach:oldX+mouse.x/oldZ;
  var aimY=pad?p.y+Math.sin(angle)*reach:oldY+mouse.y/oldZ;
  var oldQ=Math.max(0,1-baseZ/oldZ), share=m>=2.5?.6:.5;
  var lean=lookLean(p), leanX=(mouse.x-W/2)*lean, leanY=(mouse.y-H/2)*lean;
  var snap=G.anchX===undefined;
  if(snap){
    G.anchX=p.x; G.anchY=p.y; G.leanSX=leanX; G.leanSY=leanY; G.adsCam=null; GFX.tr=0; GFX.shL=+G.shake||0;
    oldX=p.x-(kx-leanX)/oldZ; oldY=p.y-(ky-leanY)/oldZ;
    if(!pad){ aimX=oldX+mouse.x/oldZ; aimY=oldY+mouse.y/oldZ; }
  }
  G.anchX+=(p.x-G.anchX)*ke; G.anchY+=(p.y-G.anchY)*ke;
  G.leanSX+=(leanX-G.leanSX)*ke; G.leanSY+=(leanY-G.leanSY)*ke;
  var hx=G.anchX+G.leanSX/baseZ, hy=G.anchY+G.leanSY/baseZ;
  var c=G.adsCam, fx=p.x+share*(aimX-p.x), fy=p.y+share*(aimY-p.y), qm=1-1/target;
  if(aiming&&(!c||!c.on||c.mag!==m||c.pad!==pad||c.target!==target)){
    var endX=hx+(aimX-hx)*qm, endY=hy+(aimY-hy)*qm;
    var ex=oldX+kx/oldZ-hx, ey=oldY+ky/oldZ-hy;
    if(oldQ>0.000001){ endX=hx+ex*qm/oldQ; endY=hy+ey*qm/oldQ; ex=0; ey=0; }
    else if(pad){ endX=fx; endY=fy; }
    c=G.adsCam={on:true,mag:m,pad:pad,target:target,share:share,qm:qm,fx:fx,fy:fy,bx:endX-fx,by:endY-fy,ex:ex,ey:ey};
  }
  if(c&&c.on&&!aiming){
    c.on=false;
    c.rx=oldQ>0.000001?(oldX+kx/oldZ-hx)/oldQ:0;
    c.ry=oldQ>0.000001?(oldY+ky/oldZ-hy)/oldQ:0;
  }
  if(!(G.adsZ>0)) G.adsZ=1;
  G.adsZ+=(target-G.adsZ)*(1-Math.exp(-d*11));
  if(Math.abs(target-G.adsZ)<.0005) G.adsZ=target;
  var z=ZOOM(), q=Math.max(0,1-baseZ/z), x=G.anchX-(kx-G.leanSX)/z, y=G.anchY-(ky-G.leanSY)/z;
  if(c&&live&&(aiming||q>0)){
    if(aiming){
      c.fx+=(fx-c.fx)*ke; c.fy+=(fy-c.fy)*ke;
      c.ex*=1-ke; c.ey*=1-ke;
      if(pad){ c.bx*=1-ke; c.by*=1-ke; }
      x=hx+(c.fx+c.bx-hx)*q/c.qm+c.ex*(1-q)-kx/z;
      y=hy+(c.fy+c.by-hy)*q/c.qm+c.ey*(1-q)-ky/z;
    }else{ x=hx+c.rx*q-kx/z; y=hy+c.ry*q-ky/z; }
    // v28.xx (cw-cx-aimfocus): safety wins over a pointer at the far edge; keep the local pillager inside the middle 76 percent, then respect world bounds.
    x=clamp(x,p.x-W*.88/z,p.x-W*.12/z);
    y=clamp(y,p.y-H*.88/z,p.y-H*.12/z);
  }else if(!aiming) G.adsCam=null;
  return {x:camClamp(x,W/z,WORLD_W),y:camClamp(y,H/z,WORLD_H),z:z,pad:pad,angle:angle,reach:reach};
}
function render2D(dt){
'@

SubRx @'
  // v18.76, his note: the scope zoom eases toward its target here, once a frame, before anything reads ZOOM.
  (function(){ var m=opticMag(), k=(CFG.adsZoom===undefined)?0.35:CFG.adsZoom, gun=!!(p.ads&&!p.downed&&!(p.roll>0)&&p.wep&&p.wep.mag>0), tgt=(gun&&!G.sim&&!G.over&&!(typeof PAD!=='undefined'&&PAD&&PAD.adsing&&!PAD.adsAim))?Math.max(1,ADS_ZMIN+(m-1)*k):((CFG.sprintZoom!==0&&G.sprinting&&!G.sim&&!G.over&&!p.downed)?SPRINT_ZK:1), d=Math.max(0,Math.min(0.1,+dt||0));
    if(!(G.adsZ>0)) G.adsZ=1; G.adsZ+=(tgt-G.adsZ)*(1-Math.exp(-d*11)); if(Math.abs(tgt-G.adsZ)<0.0005) G.adsZ=tgt; })();
  var Z=ZOOM(),VW=W/Z,VH=H/Z;
  // camera with cursor lean
  // HIS NOTE, 2026-08-24: "zooming with the mouse is janky". The easing was
  // already smooth and geometric, so the remaining problem was not the zoom, it
  // was that the CAMERA and the ZOOM eased at different rates against coupled
  // targets. The old target was tx = p.x + lean - VW/2, and VW is W/Z, so every
  // frame the zoom eased it moved the camera target by a large amount, and the
  // camera then chased it at its own slower rate. Algebraically the player's
  // screen position is independent of Z at rest, which is why it looked right
  // once it settled; during the ease the two rates disagree and the world slides
  // under you and then settles back. That is the jank.
  // The fix separates what is being smoothed. A world-space anchor eases toward
  // the player, the cursor lean eases in SCREEN pixels where it is already
  // zoom-invariant, and the camera is then derived exactly from the current
  // eased zoom. Nothing chases a target that zoom is moving, so a wheel spin
  // changes the scale and nothing else.
  var lean=p.ads?(opticMag()>1?.46:.30):lookLean(p);   // v26.xx (feel12): the look-ahead, longer for the long guns
  var leanSX=(mouse.x-W/2)*lean, leanSY=(mouse.y-H/2)*lean;
  if(G.anchX===undefined){ G.anchX=p.x; G.anchY=p.y; G.leanSX=leanSX; G.leanSY=leanSY; GFX.tr=0; GFX.shL=+G.shake||0; }   // v23.xx (gfx38): a snapped camera (raid start, respawn, redrop) starts with no trauma
  var ke=Math.min(1,dt*9);
  G.anchX+=(p.x-G.anchX)*ke;       G.anchY+=(p.y-G.anchY)*ke;
  G.leanSX+=(leanSX-G.leanSX)*ke;  G.leanSY+=(leanSY-G.leanSY)*ke;
  camX=G.anchX-(W/2-G.leanSX)/Z;   camY=G.anchY-(H*.54-G.leanSY)/Z;
  camX=camClamp(camX,VW,WORLD_W); camY=camClamp(camY,VH,WORLD_H);
  G.camX=camX; G.camY=camY;
'@ @'
  // v28.xx (cw-cx-aimfocus): solve aim and zoom together, before any draw or aim projection reads the new camera.
  var camera=adsCameraFrame(dt), Z=camera.z, VW=W/Z, VH=H/Z;
  camX=camera.x; camY=camera.y;
  G.camX=camX; G.camY=camY;
  // v28.xx (cw-cx-aimfocus): the pad owns a world endpoint; project it again through this frame's camera, without waiting for the next input poll.
  if(camera.pad&&!G.mapOpen&&!G.bagOpen) padCursorPut((p.x-camX)*Z,(p.y-camY)*Z,Math.cos(camera.angle)*camera.reach*Z,Math.sin(camera.angle)*camera.reach*Z);
'@

SubRx @'
var VER='36.28';
'@ @'
var VER='36.29';
'@

$pat = "(?m)^  now:'v36\.28:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.29: aiming zooms toward the crosshair; watch that it never feels seasick and your pillager never leaves the screen Check 36.29 fails on v36.28',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
