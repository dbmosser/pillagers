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

# GRENADE LANDING MARKER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var _mw=mouseWorld(),wx=_mw.x,wy=_mw.y;
  var dx=wx-p.x,dy=wy-p.y,d=Math.sqrt(dx*dx+dy*dy);
  var rngT=Math.min(d,270);
  var ux=(d>1?dx/d:1),uy=(d>1?dy/d:0);
'@ @'
  var _ta=throwAim(p), ux=_ta.ux, uy=_ta.uy, rngT=_ta.rngT, blocked=_ta.blocked, tx=_ta.tx, ty=_ta.ty;   // v26.xx (feel17): the aim, the reach and the wall stop are throwAim, the marker reads the same
'@

SubRx @'
  var wt=rayHitG(p.x,p.y,ux,uy,rngT),blocked=wt<rngT;
'@ @'
  // (the wall test is in throwAim, v26.xx feel17)
'@

SubRx @'
  if(blocked) rngT=Math.max(wt*0.6,wt-12);
'@ @'
  // (the standoff off the face is in throwAim too)
'@

SubRx @'
  var tx=p.x+ux*rngT,ty=p.y+uy*rngT;
'@ @'
  // (and so is the landing point)
'@

SubRx @'
function throwFrom(tk,cookT){
'@ @'
// v26.xx (feel17), HIS ORDER (2026-10-14): "grenade landing marker ok". WHERE A THROW LANDS IS WORKED OUT IN ONE PLACE. throwAim is the aim, the
// reach (270) and the wall stop that throwFrom did inline: the point under the cursor out to the reach, stopped short of the first wall on the line.
// throwFrom now reads it, and so does the marker, so the ring on the ground is exactly where the grenade comes down (nothing about a throw
// changes). THE MARKER: while a throwable is in your hand (the pin out, the trigger held) a dotted arc runs from you to the landing point and a
// ring sits there sized to the thing: the blast of a Frag Charge (CFG.fragR), the cloud of a Smoke Grenade, a small ring for the decoy and the
// tripwire, red for a frag. The fuse left, in seconds, counts down in the middle of a frag ring and the ring pulses in the last half second.
// Drawn on the HUD, live play only, nothing it reads is changed and nothing draws from the seeded stream.
function throwAim(p){
  var _mw=mouseWorld(), dx=_mw.x-p.x, dy=_mw.y-p.y, d=Math.sqrt(dx*dx+dy*dy), rngT=Math.min(d,270), ux=(d>1?dx/d:1), uy=(d>1?dy/d:0), wt, blocked;
  wt=rayHitG(p.x,p.y,ux,uy,rngT); blocked=wt<rngT;
  if(blocked) rngT=Math.max(wt*0.6,wt-12);
  return {ux:ux,uy:uy,rngT:rngT,blocked:blocked,tx:p.x+ux*rngT,ty:p.y+uy*rngT};
}
function throwMarker(p){
  var tk, A;
  if(!G||G.sim||G.over||!p||!p.cooking||p.downed||!G.map) return null;
  tk=p.cookKind; A=throwAim(p);
  return {kind:tk,sx:p.x,sy:p.y,tx:A.tx,ty:A.ty,blocked:A.blocked,
    r:(tk==='frag')?(CFG.fragR===undefined?190:CFG.fragR):((tk==='smoke')?smokeRad():(tk==='decoy'?30:18)),
    left:(tk==='frag')?Math.max(0,FRAG_FUSE-(p.cookT||0)):-1};
}
function drawThrowMarker(c,p){
  var m=throwMarker(p), z, q, n=16, i, t, pt, s1, arcH, hot, col, pulse;
  if(!m) return false;
  z=Math.max(1,hudRes()); q=ZOOM(); hot=(m.kind==='frag');
  col=hot?'255,98,66':((m.kind==='smoke')?'205,215,225':'255,196,96');
  arcH=Math.min(90,Math.hypot(m.tx-m.sx,m.ty-m.sy)*0.35);
  c.fillStyle='rgba(255,226,160,.85)';
  for(i=1;i<n;i++){
    t=i/n; pt=w2s(m.sx+(m.tx-m.sx)*t,22*(1-t)+Math.sin(3.1416*t)*arcH,m.sy+(m.ty-m.sy)*t);
    c.beginPath(); c.arc(pt.x,pt.y,2.2*z,0,6.2832); c.fill();
  }
  s1=w2s(m.tx,0,m.ty); pulse=(hot&&m.left<0.5)?(0.5+0.5*Math.sin(G.t*28)):0;
  c.fillStyle='rgba('+col+','+(0.08+0.10*pulse).toFixed(3)+')'; c.beginPath(); c.arc(s1.x,s1.y,m.r*q,0,6.2832); c.fill();
  c.strokeStyle='rgba('+col+','+(0.80+0.2*pulse).toFixed(3)+')'; c.lineWidth=(2.4+1.6*pulse)*z; c.beginPath(); c.arc(s1.x,s1.y,m.r*q,0,6.2832); c.stroke();
  c.fillStyle='rgba('+col+',.95)'; c.beginPath(); c.arc(s1.x,s1.y,3*z,0,6.2832); c.fill();
  if(m.left>=0){ c.font=hudFS(TYPE.label); c.textAlign='center'; c.fillStyle='rgba('+col+',.98)'; c.fillText(m.left.toFixed(1),s1.x,s1.y-8*z); }
  return true;
}
function throwFrom(tk,cookT){
'@

SubRx @'
  // reticle at the cursor
'@ @'
  try{ drawThrowMarker(ctx,p); }catch(_dtm){}   // v26.xx (feel17): the arc and the landing ring of the throwable in your hand
  // reticle at the cursor
'@

SubRx @'
var VER='26.64';
'@ @'
var VER='26.65';
'@

$pat = "(?m)^  now:'v26\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.65: Holding a throwable shows an arc and a landing ring the size of the blast, with the fuse counting down. Check 26.65 fails on v26.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
