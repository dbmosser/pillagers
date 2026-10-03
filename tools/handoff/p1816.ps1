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

# THE TREES AND BUSHES BAKE THEIR BLOBS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var WALLSPR={m:{},n:0,key:'',max:320,tick:0};
'@ @'
var WALLSPR={m:{},n:0,key:'',max:320,tick:0};
// v18.16, AAA CHECK (2026-10-03, the frame cost): THE TREES AND BUSHES BAKE THEIR BLOBS. A canopy was three filled circles and a
// bush four, every tree and bush, every frame, about 250 arcs a frame in a grove. The blobs are a pure function of the radius
// and the palette, so each size is painted once into a sprite (a dozen sizes a map) and drawn in one call, at the sway offset the
// live paint used. The trunk, the bush's base and the shadows stay live. Same colours, same shapes; a bush's blobs now sway
// together instead of each at its own rate, which at raid distance is the same bush.
var VEGSPR={m:{},key:''};
function vegSprite(kind,r){
  var ss, day, pal, gk, rr, k, e, cv2, c2, ox, oy, w, h, blf;
  if(CFG.wallBake===0||!(r>0)||!G||!G.vegPal) return null;
  ss=wallSpriteScale(); day=isDay();
  pal=(kind==='tree')?(day?G.vegPal.treeD:G.vegPal.treeN):(day?G.vegPal.bushD:G.vegPal.bushN);
  if(!pal) return null;
  gk=String(G.seed)+'|'+(day?'d':'n')+'|'+ss;
  if(VEGSPR.key!==gk){ VEGSPR.m={}; VEGSPR.key=gk; }
  rr=Math.round(r); k=kind+rr; e=VEGSPR.m[k];
  if(e) return e;
  if(kind==='tree'){ ox=rr+2; oy=rr*1.35+2; w=rr*2+4; h=rr*2+4; }
  else { ox=rr*0.9+2; oy=rr+2; w=rr*1.8+4; h=rr*1.3+4; }
  cv2=document.createElement('canvas'); cv2.width=Math.ceil(w*ss); cv2.height=Math.ceil(h*ss); c2=cv2.getContext('2d'); if(!c2) return null;
  c2.setTransform(ss,0,0,ss,ox*ss,oy*ss);
  if(kind==='tree'){
    c2.fillStyle=pal[0]; c2.beginPath(); c2.arc(0,-rr*.35,rr,0,6.2832); c2.fill();
    c2.fillStyle=pal[1]; c2.beginPath(); c2.arc(-rr*.25,-rr*.5,rr*.72,0,6.2832); c2.fill();
    c2.fillStyle=pal[2]; c2.beginPath(); c2.arc(-rr*.35,-rr*.62,rr*.45,0,6.2832); c2.fill();
  } else {
    blf=rr*0.55;
    c2.fillStyle=pal[1]; c2.beginPath(); c2.arc(-rr*0.34,-blf*0.50,rr*0.52,0,6.2832); c2.fill();
    c2.beginPath(); c2.arc(rr*0.30,-blf*0.42,rr*0.48,0,6.2832); c2.fill();
    c2.fillStyle=pal[2]; c2.beginPath(); c2.arc(0,-blf*0.78,rr*0.54,0,6.2832); c2.fill();
    c2.fillStyle=pal[3]; c2.beginPath(); c2.arc(-rr*0.16,-blf*0.96,rr*0.32,0,6.2832); c2.fill();
  }
  e={c:cv2,ss:ss,ox:ox,oy:oy}; VEGSPR.m[k]=e;
  return e;
}
function vegDraw(kind,r,x,y){
  var e=vegSprite(kind,r);
  if(!e) return false;
  wc.drawImage(e.c,0,0,e.c.width,e.c.height,x-e.ox,y-e.oy,e.c.width/e.ss,e.c.height/e.ss);
  return true;
}
'@

SubRx @'
      var canY=tby-30,cr2=TR.canopy;
      wc.fillStyle=isDay()?G.vegPal.treeD[0]:G.vegPal.treeN[0];
      wc.beginPath(); wc.arc(tcx+swayT,canY-cr2*.35,cr2,0,6.2832); wc.fill();
      wc.fillStyle=isDay()?G.vegPal.treeD[1]:G.vegPal.treeN[1];
      wc.beginPath(); wc.arc(tcx+swayT-cr2*.25,canY-cr2*.5,cr2*.72,0,6.2832); wc.fill();
      wc.fillStyle=isDay()?G.vegPal.treeD[2]:G.vegPal.treeN[2];
      wc.beginPath(); wc.arc(tcx+swayT-cr2*.35,canY-cr2*.62,cr2*.45,0,6.2832); wc.fill();
'@ @'
      var canY=tby-30,cr2=TR.canopy;
      if(!vegDraw('tree',cr2,tcx+swayT,canY)){   // v18.16: the canopy off a baked sprite; the live paint below when there is none
      wc.fillStyle=isDay()?G.vegPal.treeD[0]:G.vegPal.treeN[0];
      wc.beginPath(); wc.arc(tcx+swayT,canY-cr2*.35,cr2,0,6.2832); wc.fill();
      wc.fillStyle=isDay()?G.vegPal.treeD[1]:G.vegPal.treeN[1];
      wc.beginPath(); wc.arc(tcx+swayT-cr2*.25,canY-cr2*.5,cr2*.72,0,6.2832); wc.fill();
      wc.fillStyle=isDay()?G.vegPal.treeD[2]:G.vegPal.treeN[2];
      wc.beginPath(); wc.arc(tcx+swayT-cr2*.35,canY-cr2*.62,cr2*.45,0,6.2832); wc.fill();
      }
'@

SubRx @'
      wc.fillStyle=isDay()?G.vegPal.bushD[1]:G.vegPal.bushN[1];
      wc.beginPath(); wc.arc(BU.x-BU.r*0.34+bsw,BU.y-blf*0.50,BU.r*0.52,0,6.2832); wc.fill();
      wc.beginPath(); wc.arc(BU.x+BU.r*0.30+bsw,BU.y-blf*0.42,BU.r*0.48,0,6.2832); wc.fill();
      wc.fillStyle=isDay()?G.vegPal.bushD[2]:G.vegPal.bushN[2];
      wc.beginPath(); wc.arc(BU.x+bsw*1.2,BU.y-blf*0.78,BU.r*0.54,0,6.2832); wc.fill();
      wc.fillStyle=isDay()?G.vegPal.bushD[3]:G.vegPal.bushN[3];
      wc.beginPath(); wc.arc(BU.x-BU.r*0.16+bsw*1.3,BU.y-blf*0.96,BU.r*0.32,0,6.2832); wc.fill();
'@ @'
      if(!vegDraw('bush',BU.r,BU.x+bsw*1.15,BU.y)){   // v18.16: the blobs off a baked sprite, swaying together; the live paint below when there is none
      wc.fillStyle=isDay()?G.vegPal.bushD[1]:G.vegPal.bushN[1];
      wc.beginPath(); wc.arc(BU.x-BU.r*0.34+bsw,BU.y-blf*0.50,BU.r*0.52,0,6.2832); wc.fill();
      wc.beginPath(); wc.arc(BU.x+BU.r*0.30+bsw,BU.y-blf*0.42,BU.r*0.48,0,6.2832); wc.fill();
      wc.fillStyle=isDay()?G.vegPal.bushD[2]:G.vegPal.bushN[2];
      wc.beginPath(); wc.arc(BU.x+bsw*1.2,BU.y-blf*0.78,BU.r*0.54,0,6.2832); wc.fill();
      wc.fillStyle=isDay()?G.vegPal.bushD[3]:G.vegPal.bushN[3];
      wc.beginPath(); wc.arc(BU.x-BU.r*0.16+bsw*1.3,BU.y-blf*0.96,BU.r*0.32,0,6.2832); wc.fill();
      }
'@

SubRx @'
var VER='18.15';
'@ @'
var VER='18.16';
'@

$pat = "(?m)^  now:'v18\.15:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.16: Trees and bushes are painted once per size and reused, the second biggest drawing cost after the walls. Check 18.16 fails on v18.15',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
