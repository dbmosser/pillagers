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

# ELITE MACHINES GET AN OUTLINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawAffixMark(e){

'@ @'
// v26.xx (aip1), HIS ANSWER (2026-10-14 night playtest): "tint and/or outline" for the elites, and "all the new features need to be integrated
// and polished up to a AAA level like the previous stuff". An elite machine wore a glow and two rings on the ground and a badge over its
// head, which the nameplate covered; the body itself looked like any other. Now the BODY carries it: the machine is drawn into a
// scratch canvas (same scale, same pixel grid, shadow still on the ground), a clean outline in its colour is stamped round the silhouette
// (a crisp inner line and a soft outer one that breathes), a faint tint of the colour is laid over the body only, and the two go back
// to the world canvas under and over the unchanged sprite. The ground ring is one thin ring now. Cosmetic code: it draws no random
// number, and a machine that is not an elite is drawn exactly as before.
var RIM={ca:null,cb:null,xa:null,xb:null,on:0,h:null,n:0};
function rimOpen(e,col){
  var T, cx, cy, hw, up, dn, sx, sy, w, h, h1, k;
  if(!e||!col||RIM.on||typeof wc==='undefined'||!wc||!wc.getTransform||(typeof G!=='undefined'&&G&&G.sim)) return null;
  try{
    T=wc.getTransform();
    if(!(T.a>0)||!(T.d>0)||T.b||T.c||!isFinite(e.x)||!isFinite(e.y)) return null;
    cx=T.a*e.x+T.e; cy=T.d*e.y+T.f;
    hw=(e.r*1.9+20)*T.a; up=(spriteTop(e)+34)*T.d; dn=(e.r*0.9+12)*T.d;
    sx=Math.floor(cx-hw)-4; sy=Math.floor(cy-up)-4; w=Math.ceil(hw*2)+8; h=Math.ceil(up+dn)+8;
    if(w<8||h<8||w>1400||h>1400) return null;
    if(!RIM.ca){ RIM.ca=document.createElement('canvas'); RIM.cb=document.createElement('canvas'); RIM.xa=RIM.ca.getContext('2d'); RIM.xb=RIM.cb.getContext('2d'); }
    if(!RIM.xa||!RIM.xb) return null;
    if(RIM.ca.width<w){ RIM.ca.width=w; RIM.cb.width=w; }
    if(RIM.ca.height<h){ RIM.ca.height=h; RIM.cb.height=h; }
    RIM.xa.setTransform(1,0,0,1,0,0); RIM.xa.globalAlpha=1; RIM.xa.globalCompositeOperation='source-over'; RIM.xa.clearRect(0,0,w,h);
    RIM.xa.setTransform(T.a,0,0,T.d,T.e-sx,T.f-sy);
    h1={w0:wc,sh0:shadowE,col:col,sx:sx,sy:sy,w:w,h:h,u:T.a,e:e};
    RIM.on=1; RIM.h=h1;
    shadowE=function(x,y,rx,ry,a){ var w1=wc; wc=h1.w0; try{ h1.sh0(x,y,rx,ry,a); } finally{ wc=w1; } };   // the ground shadow stays on the world canvas, out of the outline
    wc=RIM.xa;
    return h1;
  }catch(_ro){ rimAbort(); return null; }
}
function rimAbort(){
  var h=RIM.h;
  if(h){ wc=h.w0; shadowE=h.sh0; }
  RIM.on=0; RIM.h=null;
}
function rimClose(h){
  var k, d, dx, dy, m, pu, xa=RIM.xa, xb=RIM.xb;
  if(!h) return;
  wc=h.w0; shadowE=h.sh0; RIM.on=0; RIM.h=null;
  try{
    pu=0.5+0.5*Math.sin(((typeof G!=='undefined'&&G)?(G.t||0):0)*3.2+h.e.x*0.02);
    xa.setTransform(1,0,0,1,0,0); xa.globalCompositeOperation='source-atop'; xa.fillStyle=hexA(h.col,0.12+0.05*pu); xa.fillRect(0,0,h.w,h.h); xa.globalCompositeOperation='source-over';
    wc.save(); wc.setTransform(1,0,0,1,0,0);
    for(m=0;m<2;m++){
      d=m?Math.max(1,Math.round(h.u*0.55)):Math.max(2,Math.round(h.u*1.3));
      xb.setTransform(1,0,0,1,0,0); xb.globalCompositeOperation='source-over'; xb.clearRect(0,0,h.w,h.h);
      for(k=0;k<8;k++){ dx=Math.round(Math.cos(k*0.7854)*d); dy=Math.round(Math.sin(k*0.7854)*d); xb.drawImage(RIM.ca,0,0,h.w,h.h,dx,dy,h.w,h.h); }
      xb.globalCompositeOperation='source-in'; xb.fillStyle=hexA(h.col,m?(0.86+0.14*pu):(0.26+0.12*pu)); xb.fillRect(0,0,h.w,h.h); xb.globalCompositeOperation='source-over';
      wc.drawImage(RIM.cb,0,0,h.w,h.h,h.sx,h.sy,h.w,h.h);
    }
    wc.drawImage(RIM.ca,0,0,h.w,h.h,h.sx,h.sy,h.w,h.h);
    wc.restore();
    RIM.n++;
  }catch(_rc){ try{ wc.restore(); }catch(_r2){} }
}
function drawAffixMark(e){

'@

SubRx @'
    gr=wc.createRadialGradient(x,y,r*0.3,x,y,r*2.2); gr.addColorStop(0,hexA(A.c,0.34*pu)); gr.addColorStop(1,hexA(A.c,0));
    wc.fillStyle=gr; wc.beginPath(); wc.ellipse(x,y+2,r*2.2,r*1.15,0,0,6.2832); wc.fill();
    wc.strokeStyle=hexA(A.c,0.55+0.35*pu); wc.lineWidth=3; wc.beginPath(); wc.ellipse(x,y+2,r*1.45,r*0.72,0,0,6.2832); wc.stroke();
    wc.lineWidth=1.5; wc.beginPath(); wc.ellipse(x,y+2,r*1.85,r*0.93,0,0,6.2832); wc.stroke();

'@ @'
    gr=wc.createRadialGradient(x,y,r*0.3,x,y,r*1.9); gr.addColorStop(0,hexA(A.c,0.15*pu)); gr.addColorStop(1,hexA(A.c,0));
    wc.fillStyle=gr; wc.beginPath(); wc.ellipse(x,y+2,r*1.9,r*1.0,0,0,6.2832); wc.fill();
    wc.strokeStyle=hexA(A.c,0.42+0.22*pu); wc.lineWidth=1.6; wc.beginPath(); wc.ellipse(x,y+2,r*1.32,r*0.66,0,0,6.2832); wc.stroke();
    wc.strokeStyle=hexA(A.c,0.16); wc.lineWidth=1; wc.beginPath(); wc.ellipse(x,y+2,r*1.62,r*0.81,0,0,6.2832); wc.stroke();

'@

SubRx @'
      if(e2.kind==='choir') drawChoirS(e2);

'@ @'
      var _rm=null;
      if(e2.elite&&e2.affix&&AFFIX[e2.affix]) _rm=rimOpen(e2,AFFIX[e2.affix].c);   // v26.xx (aip1): the elite outline
      if(e2.kind==='choir') drawChoirS(e2);

'@

SubRx @'
build:e2.build}),drawRoleMark(e2);   // v26.xx (ai21): his role mark on top of the body

'@ @'
build:e2.build}),drawRoleMark(e2);   // v26.xx (ai21): his role mark on top of the body
      rimClose(_rm);   // v26.xx (aip1)

'@

SubRx @'
    }catch(drErr){

'@ @'
    }catch(drErr){
      try{ rimAbort(); }catch(_ra){}   // v26.xx (aip1): the world canvas first, whatever the body left

'@

SubRx @'
var VER='27.29';
'@ @'
var VER='27.30';
'@

$pat = "(?m)^  now:'v27\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.30: Elite machines now wear a clean coloured outline and a faint tint, and one thin ring on the ground. Check 27.30 fails on v27.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
