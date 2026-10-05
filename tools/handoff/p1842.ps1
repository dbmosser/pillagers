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

# THE KEY ITEMS ARE PAINTED LIKE OBJECTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawItemIcon(c,key,cx,cy,S){
'@ @'
// v18.42, HIS ORDER (2026-10-05): THE KEY ITEMS ARE PAINTED LIKE OBJECTS. The heals, the plate, the ammo box and the throwables
// were three or four flat fills each. Each is now drawn as the thing it is: lit from the top left with gradients, an ink outline,
// a highlight, and the parts that name it (a gauze roll with its tail, a red case with a handle and latches, a syringe, a
// ballistic plate with its bevel, a box of brass rounds, a canister with its pin and smoke, a beacon with its waves, a pineapple
// grenade with its spoon and ring). Called with the origin already at the icon centre; returns false for any other key.
function keyIcon(c,key,S,col){
  var u=S/100, ink='#0b0d12', OL=Math.max(1,S*0.035), g, i;
  function lin(x0,y0,x1,y1,stops){ var q=c.createLinearGradient(x0*u,y0*u,x1*u,y1*u); for(var k=0;k<stops.length;k++) q.addColorStop(stops[k][0],stops[k][1]); return q; }
  function rad(x,y,r,stops){ var q=c.createRadialGradient(x*u,y*u,0,x*u,y*u,r*u); for(var k=0;k<stops.length;k++) q.addColorStop(stops[k][0],stops[k][1]); return q; }
  function rr(x,y,w,h,r){ c.beginPath(); if(c.roundRect) c.roundRect(x*u,y*u,w*u,h*u,r*u); else c.rect(x*u,y*u,w*u,h*u); }
  function ell(x,y,rx,ry,rot){ c.beginPath(); c.ellipse(x*u,y*u,rx*u,ry*u,rot||0,0,6.2832); }
  function inkS(w){ c.strokeStyle=ink; c.lineWidth=w||OL; c.lineJoin='round'; c.lineCap='round'; c.stroke(); }
  function ground(w,y){ c.fillStyle='rgba(0,0,0,.28)'; ell(0,y||40,w||34,6); c.fill(); }
  c.save();
  if(key==='bandage'){
    ground(34,38);
    c.beginPath(); c.moveTo(-6*u,18*u); c.bezierCurveTo(12*u,26*u,28*u,22*u,42*u,30*u); c.lineTo(38*u,40*u); c.bezierCurveTo(24*u,33*u,8*u,36*u,-10*u,30*u); c.closePath();
    c.fillStyle=lin(0,18,0,40,[[0,'#f4f0e6'],[1,'#c9c1b0']]); c.fill(); inkS();
    c.strokeStyle='rgba(120,110,90,.35)'; c.lineWidth=u*1.2; for(i=0;i<4;i++){ c.beginPath(); c.moveTo((4+i*9)*u,(23+i*2)*u); c.lineTo((2+i*9)*u,(33+i*1.5)*u); c.stroke(); }
    ell(-10,-4,30,32); c.fillStyle=rad(-20,-16,44,[[0,'#ffffff'],[0.6,'#ebe5d8'],[1,'#bdb4a0']]); c.fill(); inkS();
    c.strokeStyle='rgba(150,138,112,.55)'; c.lineWidth=u*1.6; for(i=1;i<4;i++){ ell(-10,-4,30-i*6.5,32-i*7); c.stroke(); }
    ell(-10,-4,7,8); c.fillStyle=rad(-10,-4,8,[[0,'#6c6252'],[1,'#a59a84']]); c.fill(); inkS(OL*0.8);
    c.fillStyle='rgba(255,255,255,.75)'; ell(-22,-20,7,4,-0.6); c.fill();
    c.fillStyle='#d8433a'; rr(14,-30,16,6,1); c.fill(); rr(19,-35,6,16,1); c.fill();
  } else if(key==='medkit'){
    ground(40,40);
    c.beginPath(); c.arc(0,-26*u,14*u,Math.PI,0); c.lineWidth=7*u; c.strokeStyle=ink; c.stroke(); c.lineWidth=4*u; c.strokeStyle='#5d6168'; c.stroke();
    rr(-40,-28,80,62,10); c.fillStyle=lin(0,-28,0,34,[[0,'#ff7b72'],[0.55,col||'#e05c5c'],[1,'#8e2a26']]); c.fill(); inkS();
    c.fillStyle='rgba(0,0,0,.22)'; rr(-40,-2,80,4,1); c.fill();
    c.fillStyle='rgba(255,255,255,.28)'; rr(-34,-24,68,10,5); c.fill();
    c.fillStyle='#3a3d44'; rr(-34,-6,10,9,2); c.fill(); rr(24,-6,10,9,2); c.fill();
    c.fillStyle='rgba(0,0,0,.25)'; rr(-9,-15,22,36,2); c.fill(); rr(-18,-6,40,18,2); c.fill();
    c.fillStyle=lin(0,-17,0,17,[[0,'#ffffff'],[1,'#dfe3e8']]); rr(-11,-17,22,36,2); c.fill(); rr(-20,-8,40,18,2); c.fill();
  } else if(key==='stim'){
    ground(34,38);
    c.rotate(-0.72); c.scale(1.3,1.3);   // a syringe is thin; drawn a size up so it reads at belt size
    rr(-46,-4,18,8,2); c.fillStyle='#9aa3ad'; c.fill(); inkS(OL*0.8);
    rr(-30,-13,6,26,2); c.fillStyle='#c9d0d8'; c.fill(); inkS(OL*0.8);
    rr(-24,-10,48,20,5); c.fillStyle=lin(0,-10,0,10,[[0,'rgba(230,250,255,.95)'],[1,'rgba(150,180,190,.95)']]); c.fill(); inkS();
    rr(-14,-7,34,14,3); c.fillStyle=lin(0,-7,0,7,[[0,'#b8fff2'],[0.5,col||'#7fe0d0'],[1,'#2e9e8e']]); c.fill();
    c.strokeStyle='rgba(20,40,40,.55)'; c.lineWidth=u*1.2; for(i=0;i<4;i++){ c.beginPath(); c.moveTo((-10+i*8)*u,-10*u); c.lineTo((-10+i*8)*u,-5*u); c.stroke(); }
    c.fillStyle='rgba(255,255,255,.7)'; rr(-20,-8,36,3,1.5); c.fill();
    rr(24,-5,8,10,2); c.fillStyle='#8a939c'; c.fill(); inkS(OL*0.8);
    c.beginPath(); c.moveTo(32*u,-1.4*u); c.lineTo(50*u,0); c.lineTo(32*u,1.4*u); c.closePath(); c.fillStyle='#e6ebf0'; c.fill(); c.strokeStyle=ink; c.lineWidth=u*0.9; c.stroke();
  } else if(key==='plate'){
    ground(34,42);
    c.beginPath(); c.moveTo(-22*u,-40*u); c.lineTo(22*u,-40*u); c.lineTo(36*u,-24*u); c.lineTo(34*u,26*u); c.quadraticCurveTo(0,44*u,-34*u,26*u); c.lineTo(-36*u,-24*u); c.closePath();
    c.fillStyle=lin(-30,-40,30,40,[[0,'#bfe3ff'],[0.45,col||'#5aa9e6'],[1,'#21507a']]); c.fill(); inkS();
    c.beginPath(); c.moveTo(-17*u,-32*u); c.lineTo(17*u,-32*u); c.lineTo(27*u,-20*u); c.lineTo(25*u,20*u); c.quadraticCurveTo(0,34*u,-25*u,20*u); c.lineTo(-27*u,-20*u); c.closePath();
    c.strokeStyle='rgba(255,255,255,.45)'; c.lineWidth=u*2.4; c.stroke();
    c.fillStyle='rgba(10,20,35,.55)'; c.beginPath(); c.moveTo(0,-10*u); c.lineTo(12*u,2*u); c.lineTo(6*u,2*u); c.lineTo(0,-4*u); c.lineTo(-6*u,2*u); c.lineTo(-12*u,2*u); c.closePath(); c.fill();
    c.beginPath(); c.moveTo(0,4*u); c.lineTo(12*u,16*u); c.lineTo(6*u,16*u); c.lineTo(0,10*u); c.lineTo(-6*u,16*u); c.lineTo(-12*u,16*u); c.closePath(); c.fill();
    c.fillStyle='rgba(255,255,255,.35)'; c.beginPath(); c.moveTo(-20*u,-36*u); c.lineTo(-4*u,-36*u); c.lineTo(-28*u,8*u); c.lineTo(-30*u,-22*u); c.closePath(); c.fill();
  } else if(key==='ammobox'){
    ground(42,40);
    c.beginPath(); c.moveTo(-38*u,-8*u); c.lineTo(-24*u,-22*u); c.lineTo(40*u,-22*u); c.lineTo(26*u,-8*u); c.closePath(); c.fillStyle=lin(0,-22,0,-8,[[0,'#8fa266'],[1,'#6b7d45']]); c.fill(); inkS();
    c.beginPath(); c.moveTo(26*u,-8*u); c.lineTo(40*u,-22*u); c.lineTo(40*u,18*u); c.lineTo(26*u,32*u); c.closePath(); c.fillStyle='#3f4a28'; c.fill(); inkS();
    rr(-38,-8,64,40,2); c.fillStyle=lin(0,-8,0,32,[[0,'#7d9152'],[1,'#4b5a2e']]); c.fill(); inkS();
    c.fillStyle='rgba(0,0,0,.3)'; rr(-38,-2,64,3,1); c.fill();
    c.fillStyle='#2b3020'; rr(-10,-6,12,10,2); c.fill();
    c.fillStyle='rgba(236,226,190,.85)'; c.font='bold '+Math.round(11*u)+'px sans-serif'; c.textAlign='center'; c.fillText('AMMO',-6*u,24*u);
    for(i=0;i<4;i++){ var bx=(-22+i*12)*u, by=-34*u;
      rr(-22+i*12-4,-34,8,16,2); c.fillStyle=lin(-22+i*12-4,0,-22+i*12+4,0,[[0,'#f6d77a'],[0.5,'#d8a83a'],[1,'#8f6a1e']]); c.fill(); c.strokeStyle=ink; c.lineWidth=u*1; c.stroke();
      c.beginPath(); c.moveTo(bx-4*u,by); c.quadraticCurveTo(bx,by-12*u,bx+4*u,by); c.closePath(); c.fillStyle='#c27a3a'; c.fill(); c.stroke(); }
  } else if(key==='smoke'){
    c.fillStyle='rgba(220,226,232,.55)'; ell(10,-42,12,9); c.fill(); ell(22,-52,10,8); c.fill(); ell(0,-52,8,6); c.fill();
    ground(24,40);
    rr(-18,-26,36,64,6); c.fillStyle=lin(-18,0,18,0,[[0,'#6c757d'],[0.35,'#c6cfd6'],[0.7,col||'#9aa5ad'],[1,'#4c545b']]); c.fill(); inkS();
    c.fillStyle='rgba(40,45,50,.65)'; rr(-18,-8,36,5,1); c.fill(); rr(-18,22,36,5,1); c.fill();
    c.fillStyle='rgba(240,240,240,.85)'; c.font='bold '+Math.round(9*u)+'px sans-serif'; c.textAlign='center'; c.fillText('SMK',0,12*u);
    rr(-12,-36,24,12,3); c.fillStyle=lin(0,-36,0,-24,[[0,'#8a929a'],[1,'#4a5056']]); c.fill(); inkS(OL*0.9);
    c.beginPath(); c.moveTo(10*u,-34*u); c.quadraticCurveTo(26*u,-30*u,24*u,6*u); c.lineWidth=5*u; c.strokeStyle=ink; c.stroke(); c.lineWidth=3*u; c.strokeStyle='#b7bec5'; c.stroke();
    c.beginPath(); c.arc(-16*u,-36*u,7*u,0,6.2832); c.lineWidth=3*u; c.strokeStyle=ink; c.stroke(); c.lineWidth=1.8*u; c.strokeStyle='#d8dde2'; c.stroke();
  } else if(key==='decoy'){
    ground(34,40);
    c.strokeStyle='rgba(255,120,100,.75)'; c.lineWidth=3*u; c.lineCap='round';
    for(i=0;i<3;i++){ c.beginPath(); c.arc(14*u,-34*u,(10+i*9)*u,-2.4,-0.7); c.stroke(); }
    c.beginPath(); c.moveTo(10*u,-6*u); c.lineTo(14*u,-34*u); c.lineWidth=4*u; c.strokeStyle=ink; c.stroke(); c.lineWidth=2.2*u; c.strokeStyle='#9aa3ad'; c.stroke();
    ell(14,-36,5,5); c.fillStyle=rad(13,-37,6,[[0,'#fff3e8'],[0.4,'#ff6a52'],[1,'#a01e10']]); c.fill(); inkS(OL*0.7);
    rr(-30,-8,60,44,7); c.fillStyle=lin(0,-8,0,36,[[0,'#fff0a8'],[0.4,col||'#e0c060'],[1,'#8a6a1e']]); c.fill(); inkS();
    rr(-22,0,30,18,3); c.fillStyle='#2a2e36'; c.fill();
    c.fillStyle='#5df0a0'; for(i=0;i<3;i++){ rr(-18+i*9,8-i*3,5,6+i*3,1); c.fill(); }
    c.fillStyle='#2a2e36'; c.beginPath(); c.arc(18*u,10*u,6*u,0,6.2832); c.fill();
    c.fillStyle='rgba(255,255,255,.3)'; rr(-26,-4,52,6,3); c.fill();
  } else if(key==='frag'){
    ground(30,42);
    ell(0,6,28,32); c.fillStyle=rad(-10,-6,40,[[0,'#ffb38a'],[0.45,col||'#e07040'],[1,'#6e2a12']]); c.fill(); inkS();
    c.save(); ell(0,6,28,32); c.clip();
    c.strokeStyle='rgba(40,14,4,.55)'; c.lineWidth=u*2.2;
    for(i=-2;i<=2;i++){ c.beginPath(); c.ellipse(i*11*u,6*u,4*u,34*u,0,0,6.2832); c.stroke(); }
    for(i=-2;i<=2;i++){ c.beginPath(); c.moveTo(-30*u,(6+i*12)*u); c.quadraticCurveTo(0,(10+i*12)*u,30*u,(6+i*12)*u); c.stroke(); }
    c.restore();
    c.fillStyle='rgba(255,255,255,.45)'; ell(-11,-8,7,5,-0.6); c.fill();
    rr(-11,-34,22,12,3); c.fillStyle=lin(0,-34,0,-22,[[0,'#8b939b'],[1,'#3d4248']]); c.fill(); inkS(OL*0.9);
    c.beginPath(); c.moveTo(8*u,-32*u); c.quadraticCurveTo(26*u,-30*u,26*u,0); c.lineWidth=5*u; c.strokeStyle=ink; c.stroke(); c.lineWidth=3*u; c.strokeStyle='#c3c9cf'; c.stroke();
    c.beginPath(); c.arc(-18*u,-36*u,7*u,0,6.2832); c.lineWidth=3*u; c.strokeStyle=ink; c.stroke(); c.lineWidth=1.8*u; c.strokeStyle='#e6c86a'; c.stroke();
  } else { c.restore(); return false; }
  c.restore();
  return true;
}
function drawItemIcon(c,key,cx,cy,S){
'@

SubRx @'
  function shadow(w,h){ c.fillStyle='rgba(0,0,0,.35)'; c.fillRect(-w/2+1.5,-h/2+1.5,w,h); }
  switch(key){
'@ @'
  function shadow(w,h){ c.fillStyle='rgba(0,0,0,.35)'; c.fillRect(-w/2+1.5,-h/2+1.5,w,h); }
  // v18.42: the key items have their own painter (keyIcon, above)
  try{ if(typeof keyIcon==='function'&&keyIcon(c,key,S,col)){ c.restore(); return; } }catch(_ki){}
  switch(key){
'@

SubRx @'
var VER='18.41';
'@ @'
var VER='18.42';
'@

$pat = "(?m)^  now:'v18\.41:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.42: Bandages, medkits, stims, plates, ammo, smoke, decoys and frags have new detailed, shaded icons everywhere. Check 18.42 fails on v18.41',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
