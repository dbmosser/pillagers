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

# THROWABLES BANK ONCE OFF COVER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function losClear(ax,ay,bx,by,segs){
'@ @'
// v28.xx (cw-cx-throwbank), HIS 10-25 g-14: "Yes, one bounce"; 10-28 #8: "yes". Keep the struck face as well as its distance.
function rayHitSegG(px,py,dx,dy,maxT){
  var qx=px+dx*maxT,qy=py+dy*maxT;
  var segs=G.grid?segsBox(G.grid,Math.min(px,qx),Math.min(py,qy),Math.max(px,qx),Math.max(py,qy)):G.map.segs;
  var best=maxT,hit=null;
  for(var i=0;i<segs.length;i++){
    var s=segs[i],sx=s.x2-s.x1,sy=s.y2-s.y1;
    var den=dx*sy-dy*sx; if(den>-1e-9&&den<1e-9) continue;
    var qxx=s.x1-px,qyy=s.y1-py;
    var t=(qxx*sy-qyy*sx)/den; if(t<0||t>=best) continue;
    var u=(qxx*dy-qyy*dx)/den; if(u<0||u>1) continue;
    best=t; hit=s;
  }
  return {t:best,seg:hit};
}
function losClear(ax,ay,bx,by,segs){
'@

SubRx @'
function throwAim(p){
  var _mw=mouseWorld(), dx=_mw.x-p.x, dy=_mw.y-p.y, d=Math.sqrt(dx*dx+dy*dy), rngT=Math.min(d,270), ux=(d>1?dx/d:1), uy=(d>1?dy/d:0), wt, blocked;
  wt=rayHitG(p.x,p.y,ux,uy,rngT); blocked=wt<rngT;
  if(blocked) rngT=Math.max(wt*0.6,wt-12);
  return {ux:ux,uy:uy,rngT:rngT,blocked:blocked,tx:p.x+ux*rngT,ty:p.y+uy*rngT};
}
'@ @'
// v28.xx (cw-cx-throwbank): one reflection, half the remaining reach, then a wall stop; tripwires keep the straight throw.
function throwAim(p,kind){
  var mw=mouseWorld(),dx=mw.x-p.x,dy=mw.y-p.y,d=Math.hypot(dx,dy),reach=Math.min(d,270),ux=d>1?dx/d:1,uy=d>1?dy/d:0;
  var tk=kind||(p.cooking?p.cookKind:THROWKEYS[G.tsel]),hit=rayHitSegG(p.x,p.y,ux,uy,reach),wt=hit.t,blocked=wt<reach;
  var rngT=blocked?Math.max(wt*0.6,wt-12):reach,tx=p.x+ux*rngT,ty=p.y+uy*rngT,bx=null,by=null;
  var left=(reach-wt)*0.5;
  if(blocked&&left>=8&&hit.seg&&(tk==='frag'||tk==='smoke'||tk==='decoy')){
    var s=hit.seg,nx=-(s.y2-s.y1),ny=s.x2-s.x1,nl=Math.hypot(nx,ny);
    if(nl>0){
      nx/=nl; ny/=nl; var dot=ux*nx+uy*ny;
      if(dot>0){ nx=-nx; ny=-ny; dot=-dot; }
      var rx=ux-2*dot*nx,ry=uy-2*dot*ny;
      bx=p.x+ux*wt; by=p.y+uy*wt;
      var ox=bx+nx*6,oy=by+ny*6,wt2=rayHitG(ox,oy,rx,ry,left);
      var leg=wt2<left?Math.max(wt2*0.6,wt2-12):left;
      tx=ox+rx*leg; ty=oy+ry*leg;
      rngT=wt+Math.hypot(tx-bx,ty-by);
    }
  }
  return {ux:ux,uy:uy,rngT:rngT,blocked:blocked,tx:tx,ty:ty,bx:bx,by:by};
}
// v28.xx (cw-cx-throwbank): distance, not time per leg; all three consumers follow the same bend and low second hop.
function throwPath(th,f){
  var sx=th.sx,sy=th.sy,tx=th.tx,ty=th.ty,t=clamp(f,0,1),hop=false;
  if(th.bx!=null&&th.by!=null){
    var a=Math.hypot(th.bx-sx,th.by-sy),b=Math.hypot(tx-th.bx,ty-th.by),walk=t*(a+b);
    if(walk<a){ tx=th.bx; ty=th.by; t=a>0?walk/a:1; }
    else { sx=th.bx; sy=th.by; t=b>0?(walk-a)/b:1; hop=true; }
  }
  return {x:sx+(tx-sx)*t,y:sy+(ty-sy)*t,t:t,hop:hop};
}
'@

SubRx @'
tk=p.cookKind; A=throwAim(p);
  return {kind:tk,sx:p.x,sy:p.y,tx:A.tx,ty:A.ty,blocked:A.blocked,
'@ @'
tk=p.cookKind; A=throwAim(p,tk);
  return {kind:tk,sx:p.x,sy:p.y,tx:A.tx,ty:A.ty,bx:A.bx,by:A.by,blocked:A.blocked,
'@

SubRx @'
    t=i/n; pt=w2s(m.sx+(m.tx-m.sx)*t,22*(1-t)+Math.sin(3.1416*t)*arcH,m.sy+(m.ty-m.sy)*t);
'@ @'
    // v28.xx (cw-cx-throwbank): the preview bends at the face and the rebound is a low hop.
    var path=throwPath(m,i/n); t=path.t;
    var legH=path.hop?Math.min(24,Math.hypot(m.tx-m.bx,m.ty-m.by)*0.25):arcH;
    pt=w2s(path.x,(path.hop?0:22*(1-t))+Math.sin(Math.PI*t)*legH,path.y);
'@

SubRx @'
var _ta=throwAim(p), ux=_ta.ux, uy=_ta.uy, rngT=_ta.rngT, blocked=_ta.blocked, tx=_ta.tx, ty=_ta.ty;
'@ @'
var _ta=throwAim(p,tk), ux=_ta.ux, uy=_ta.uy, rngT=_ta.rngT, blocked=_ta.blocked, tx=_ta.tx, ty=_ta.ty;
'@

SubRx @'
G.throws.push({x:p.x,y:p.y,sx:p.x,sy:p.y,tx:tx,ty:ty,t:0,dur:Math.max(.25,rngT/430),kind:tk,cook:cookT||0});
'@ @'
G.throws.push({x:p.x,y:p.y,sx:p.x,sy:p.y,tx:tx,ty:ty,bx:_ta.bx,by:_ta.by,t:0,dur:Math.max(.25,rngT/430),kind:tk,cook:cookT||0}); // v28.xx (cw-cx-throwbank): duration covers both legs
'@

SubRx @'
if(blocked&&rngT<(tk==='frag'?(CFG.fragR===undefined?190:CFG.fragR):110))
'@ @'
if(blocked&&Math.hypot(tx-p.x,ty-p.y)<(tk==='frag'?(CFG.fragR===undefined?190:CFG.fragR):110))
'@

SubRx @'
    th.x=th.sx+(th.tx-th.sx)*f; th.y=th.sy+(th.ty-th.sy)*f;
'@ @'
    var path=throwPath(th,f); th.x=path.x; th.y=path.y; // v28.xx (cw-cx-throwbank): traverse the bend by length
'@

SubRx @'
    wc.beginPath(); wc.arc(th.x,th.y-6-Math.sin(f*Math.PI)*26,3,0,6.2832); wc.fill();
'@ @'
    // v28.xx (cw-cx-throwbank): the second flight has a lower hop; straight throws retain their old arc.
    var path=throwPath(th,f);
    wc.beginPath(); wc.arc(th.x,th.y-6-Math.sin(path.t*Math.PI)*(path.hop?12:26),3,0,6.2832); wc.fill();
'@

SubRx @'
  // A thrown object used to be slid straight from hand to target with no wall
  // test at all, so a frag reached into a room you had never seen and killed
  // what was in it. Measured before this: from open ground about one in seven
  // enemies inside throwing range had no line of sight to you, and from a
  // container inside a building about half did. There is no height in this
  // simulation, every wall stops sight and gunfire outright, and nothing on the
  // map throws anything back, so lobbing over cover was a player-only way
  // through the one rule the game is built on. The throw now stops at the first
  // wall in its path, a short way off the face so it detonates against cover
  // rather than inside it.
  // (the wall test is in throwAim, v26.xx feel17)
  // Never behind the thrower: the standoff shrinks when the wall is close, so a
  // throw into cover you are hugging still lands in front of you.
  // (the standoff off the face is in throwAim too)
  // (and so is the landing point)

'@ @'
  // v28.xx (cw-cx-throwbank), HIS 10-25 g-14: "Yes, one bounce"; approved again 10-28 #8.
  // Frag, smoke and decoy bank once; a second wall stops them. Tripwire mines keep the first-wall stop.
  // The marker, flight and landing all read the same final point; pillager charges do not use this path.

'@

SubRx @'
// it stops at the first wall like every throw. Where it lands it strings a wire ACROSS the throw: each half runs out sideways until a
'@ @'
// v28.xx (cw-cx-throwbank): tripwires keep the first-wall stop. The landing strings a wire ACROSS the throw: each half runs out sideways until a
'@

SubRx @'
var VER='35.90';
'@ @'
var VER='35.91';
'@

$pat = "(?m)^  now:'v35\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.91: Frag, smoke and decoy bank once off a wall; the marker follows both legs and the rebound is a low hop. Check 35.91 fails on v35.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
