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

# THE PARTS AND THE SALVAGE ARE PAINTED LIKE OBJECTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function keyIcon(c,key,S,col){
'@ @'
// v18.44, HIS ORDER (2026-10-05, the icons, continued): THE PARTS AND THE SALVAGE ARE PAINTED LIKE OBJECTS TOO. Scrap, wire,
// coils, cells, boards, lenses, servos, kits, cores, ledgers, codices, the black box, the reactor core, the bloom sample and the
// meat were flat shapes; each is drawn as the thing it is, lit from the top left, ink outlined, in its own rarity colour.
function partIcon(c,key,S,col){
  var u=S/100, ink='#0b0d12', OL=Math.max(1,S*0.035), i, a;
  function lin(x0,y0,x1,y1,st){ var q=c.createLinearGradient(x0*u,y0*u,x1*u,y1*u); for(var k=0;k<st.length;k++) q.addColorStop(st[k][0],st[k][1]); return q; }
  function rad(x,y,r,st){ var q=c.createRadialGradient(x*u,y*u,0,x*u,y*u,r*u); for(var k=0;k<st.length;k++) q.addColorStop(st[k][0],st[k][1]); return q; }
  function rr(x,y,w,h,r){ c.beginPath(); if(c.roundRect) c.roundRect(x*u,y*u,w*u,h*u,(r||1)*u); else c.rect(x*u,y*u,w*u,h*u); }
  function ell(x,y,rx,ry,rot){ c.beginPath(); c.ellipse(x*u,y*u,rx*u,ry*u,rot||0,0,6.2832); }
  function P(pts){ c.beginPath(); c.moveTo(pts[0][0]*u,pts[0][1]*u); for(var k=1;k<pts.length;k++) c.lineTo(pts[k][0]*u,pts[k][1]*u); c.closePath(); }
  function inkS(w){ c.strokeStyle=ink; c.lineWidth=w||OL; c.lineJoin='round'; c.lineCap='round'; c.stroke(); }
  function sh(base){ return lin(0,-40,0,40,[[0,litHex(base,0.32,true)],[0.5,base],[1,darkHex(base,0.55)]]); }
  function ground(w,y){ c.fillStyle='rgba(0,0,0,.28)'; ell(0,y||40,w||32,6); c.fill(); }
  function ln(x0,y0,x1,y1,w,s){ c.beginPath(); c.moveTo(x0*u,y0*u); c.lineTo(x1*u,y1*u); c.lineWidth=(w||1.4)*u; c.strokeStyle=s||'rgba(0,0,0,.4)'; c.lineCap='round'; c.stroke(); }
  function glow(x,y,r,cl){ var q=c.createRadialGradient(x*u,y*u,0,x*u,y*u,r*u); q.addColorStop(0,'#ffffff'); q.addColorStop(0.35,cl); q.addColorStop(1,'rgba(0,0,0,0)'); c.fillStyle=q; c.beginPath(); c.arc(x*u,y*u,r*u,0,6.2832); c.fill(); }
  c.save();
  if(key==='scrap'){
    ground(36,38);
    P([[-38,22],[-30,-18],[-10,-30],[6,-14],[26,-34],[40,-6],[30,30],[2,24],[-14,34]]); c.fillStyle=sh(col); c.fill(); inkS();
    c.fillStyle='rgba(150,80,40,.55)'; ell(18,8,9,6,0.4); c.fill(); ell(-18,14,6,4); c.fill();
    for(i=0;i<3;i++){ ell(-22+i*20,-6+i*6,3.2,3.2); c.fillStyle='#2a2d33'; c.fill(); }
    ln(-26,-10,-2,-20,1.6,'rgba(255,255,255,.35)');
  } else if(key==='wire'){
    ground(34,38);
    ell(-20,0,10,28); c.fillStyle='#6b5a44'; c.fill(); inkS();
    rr(-20,-28,40,56,3); c.fillStyle=lin(0,-28,0,28,[[0,'#f2a774'],[0.5,col],[1,'#7a3a18']]); c.fill(); inkS();
    for(i=0;i<9;i++) ln(-18+i*4.4,-26,-18+i*4.4,26,1.2,'rgba(80,30,10,.5)');
    ell(20,0,10,28); c.fillStyle=lin(0,-28,0,28,[[0,'#a08868'],[1,'#5a4a34']]); c.fill(); inkS(); ell(20,0,4,10); c.fillStyle='#2a2218'; c.fill();
    c.beginPath(); c.moveTo(20*u,-20*u); c.bezierCurveTo(40*u,-34*u,46*u,-10*u,34*u,6*u); c.lineWidth=4*u; c.strokeStyle=ink; c.stroke(); c.lineWidth=2.4*u; c.strokeStyle='#e88a52'; c.stroke();
  } else if(key==='coil'){
    ground(34,38);
    rr(-34,-18,68,36,6); c.fillStyle=sh('#5a6470'); c.fill(); inkS();
    for(i=0;i<7;i++){ rr(-26+i*8,-20,6,40,2); c.fillStyle=lin(0,-20,0,20,[[0,'#f2a774'],[0.5,'#c9703f'],[1,'#6e3214']]); c.fill(); c.strokeStyle=ink; c.lineWidth=u*0.8; c.stroke(); }
    glow(-38,0,14,col); glow(38,0,14,col);
    ell(-36,0,6,14); c.fillStyle=col; c.fill(); inkS(OL*0.8); ell(36,0,6,14); c.fill(); inkS(OL*0.8);
  } else if(key==='cell'||key==='titan'){
    ground(26,40);
    rr(-20,-30,40,66,9); c.fillStyle=lin(-20,0,20,0,[[0,darkHex(col,0.5)],[0.35,litHex(col,0.3,true)],[0.7,col],[1,darkHex(col,0.45)]]); c.fill(); inkS();
    rr(-8,-38,16,9,2); c.fillStyle=lin(0,-38,0,-29,[[0,'#d8dde2'],[1,'#7d858d']]); c.fill(); inkS(OL*0.8);
    c.fillStyle='rgba(0,0,0,.35)'; rr(-20,-12,40,6,1); c.fill(); rr(-20,16,40,6,1); c.fill();
    c.fillStyle='rgba(255,255,255,.85)'; rr(-2,-4,4,14,1); c.fill(); rr(-7,1,14,4,1); c.fill();
    if(key==='cell'){ c.beginPath(); c.moveTo(-14*u,-24*u); c.lineTo(-4*u,-14*u); c.lineTo(-10*u,-6*u); c.lineTo(2*u,6*u); c.lineWidth=2*u; c.strokeStyle='#1a1d12'; c.stroke(); }
    else { glow(0,30,16,'rgba(150,210,255,.6)'); }
  } else if(key==='board'){
    ground(38,38);
    P([[-38,-26],[38,-26],[38,26],[-30,26],[-38,18]]); c.fillStyle=sh(col); c.fill(); inkS();
    c.strokeStyle='#d8c070'; c.lineWidth=1.4*u;
    [[-30,-16,-6,-16,-6,4],[-30,16,4,16,4,-8],[12,-18,12,-4,30,-4],[18,20,30,8]].forEach(function(t){ c.beginPath(); c.moveTo(t[0]*u,t[1]*u); for(var k=2;k<t.length;k+=2) c.lineTo(t[k]*u,t[k+1]*u); c.stroke(); });
    rr(-20,-8,18,14,1.5); c.fillStyle='#1c1f24'; c.fill(); rr(10,4,16,12,1.5); c.fill();
    for(i=0;i<4;i++){ rr(-19+i*4.5,-11,2,3,0.3); c.fillStyle='#e0c060'; c.fill(); rr(-19+i*4.5,6,2,3,0.3); c.fill(); }
    c.fillStyle='rgba(255,255,255,.2)'; rr(-36,-24,72,6,2); c.fill();
  } else if(key==='relay'){
    ground(30,40);
    rr(-8,6,16,26,3); c.fillStyle=sh('#5a6470'); c.fill(); inkS();
    ell(0,-6,34,16,-0.25); c.fillStyle=lin(0,-22,0,10,[[0,'#ffffff'],[0.4,litHex(col,0.3,true)],[1,darkHex(col,0.5)]]); c.fill(); inkS();
    ell(0,-6,24,10,-0.25); c.fillStyle='rgba(60,30,90,.35)'; c.fill();
    ln(0,-6,6,-30,2.6,ink); ln(0,-6,6,-30,1.4,'#c8ced4'); glow(6,-32,8,col);
  } else if(key==='optic'){
    ground(30,40);
    ell(0,0,34,34); c.fillStyle=lin(0,-34,0,34,[[0,'#d8dde2'],[1,'#4a5056']]); c.fill(); inkS();
    ell(0,0,26,26); c.fillStyle=rad(-8,-10,32,[[0,'#ffffff'],[0.3,litHex(col,0.4,true)],[0.7,col],[1,'#0f3a3a']]); c.fill(); inkS(OL*0.8);
    c.fillStyle='rgba(255,255,255,.7)'; ell(-10,-12,8,4,-0.6); c.fill();
    for(i=0;i<8;i++){ a=i*0.785; rr(Math.cos(a)*30-1.5,Math.sin(a)*30-1.5,3,3,0.5); c.fillStyle='#2a2d33'; c.fill(); }
  } else if(key==='servo'){
    ground(36,40);
    rr(-34,-14,46,38,4); c.fillStyle=sh(col); c.fill(); inkS();
    c.fillStyle='rgba(0,0,0,.3)'; for(i=0;i<4;i++){ rr(-28,-6+i*7,34,3,1); c.fill(); }
    c.beginPath(); for(i=0;i<16;i++){ a=i*Math.PI/8; var r0=(i%2)?15:19; c.lineTo((24+Math.cos(a)*r0)*u,(-6+Math.sin(a)*r0)*u); } c.closePath(); c.fillStyle=lin(0,-26,0,14,[[0,'#e8ecef'],[1,'#6a727a']]); c.fill(); inkS();
    ell(24,-6,5,5); c.fillStyle='#2a2d33'; c.fill();
    c.beginPath(); c.moveTo(-34*u,16*u); c.quadraticCurveTo(-44*u,22*u,-40*u,34*u); c.lineWidth=3*u; c.strokeStyle='#d84a3a'; c.stroke();
  } else if(key==='comp'){
    ground(38,40);
    rr(-38,-16,76,48,6); c.fillStyle=sh(col); c.fill(); inkS();
    c.fillStyle='rgba(0,0,0,.25)'; rr(-38,-2,76,4,1); c.fill();
    c.beginPath(); c.arc(0,-16*u,12*u,Math.PI,0); c.lineWidth=5*u; c.strokeStyle=ink; c.stroke(); c.lineWidth=3*u; c.strokeStyle='#5d6168'; c.stroke();
    rr(-6,-6,12,10,2); c.fillStyle='#d8dde2'; c.fill(); inkS(OL*0.7);
    for(i=0;i<3;i++){ ell(-26+i*26,18,4,4); c.fillStyle='#8a929a'; c.fill(); inkS(OL*0.6); ln(-28+i*26,18,-24+i*26,18,1,'#2a2d33'); }
  } else if(key==='core'||key==='wcore'){
    ground(28,40);
    if(key==='core'){
      P([[0,-38],[26,-20],[26,20],[0,38],[-26,20],[-26,-20]]); c.fillStyle=sh('#3a4552'); c.fill(); inkS();
      P([[0,-26],[16,-13],[16,13],[0,26],[-16,13],[-16,-13]]); c.fillStyle=rad(-4,-8,30,[[0,'#ffffff'],[0.3,litHex(col,0.35,true)],[1,darkHex(col,0.4)]]); c.fill(); inkS(OL*0.7);
      for(i=0;i<3;i++) ln(-10,-10+i*10,10,-10+i*10,1.2,'rgba(255,255,255,.55)');
    } else {
      glow(0,0,40,'rgba(255,192,74,.55)');
      ell(0,0,22,22); c.fillStyle=rad(-6,-6,24,[[0,'#ffffff'],[0.35,'#ffe08a'],[1,'#b8720f']]); c.fill(); inkS();
      for(i=0;i<4;i++){ a=i*0.785; c.save(); c.rotate(a); rr(-30,-3,60,6,2); c.fillStyle='#4a5056'; c.fill(); c.strokeStyle=ink; c.lineWidth=OL*0.7; c.stroke(); c.restore(); }
      ell(0,0,8,8); c.fillStyle='#fff6d8'; c.fill();
    }
  } else if(key==='ledger'||key==='codex'){
    ground(34,40);
    rr(-30,-34,58,70,4); c.fillStyle='#e8e0cc'; c.fill(); inkS();
    for(i=0;i<5;i++) ln(26,-30+i*14,26,-24+i*14,1,'rgba(120,100,70,.5)');
    rr(-34,-36,58,70,4); c.fillStyle=sh(col); c.fill(); inkS();
    rr(-34,-36,10,70,3); c.fillStyle='rgba(0,0,0,.28)'; c.fill();
    if(key==='ledger'){ c.fillStyle='rgba(255,255,255,.8)'; rr(-16,-18,30,4,1); c.fill(); rr(-16,-10,22,3,1); c.fill(); ell(-2,12,10,10); c.lineWidth=2.4*u; c.strokeStyle='rgba(255,255,255,.75)'; c.stroke(); }
    else { rr(18,-6,12,14,2); c.fillStyle='#c8a040'; c.fill(); inkS(OL*0.7); ell(-4,4,10,10); c.fillStyle=rad(-6,2,10,[[0,'#ff8a7a'],[1,'#8a1a12']]); c.fill(); inkS(OL*0.7); }
  } else if(key==='blackbox'){
    ground(36,40);
    rr(-34,-22,68,52,5); c.fillStyle=lin(0,-22,0,30,[[0,'#ff9a4a'],[0.5,'#e06a1a'],[1,'#7a3008']]); c.fill(); inkS();
    c.save(); rr(-34,-22,68,52,5); c.clip(); c.strokeStyle='rgba(20,10,0,.75)'; c.lineWidth=6*u; for(i=-4;i<5;i++){ c.beginPath(); c.moveTo((i*16-10)*u,30*u); c.lineTo((i*16+20)*u,-22*u); c.stroke(); } c.restore();
    rr(-24,-12,48,22,3); c.fillStyle=lin(0,-12,0,10,[[0,'#3a3d44'],[1,'#16181c']]); c.fill(); inkS(OL*0.8);
    c.fillStyle=col; c.font='bold '+Math.round(8*u)+'px sans-serif'; c.textAlign='center'; c.fillText('REC',0,3*u);
    c.beginPath(); c.arc(0,-22*u,12*u,Math.PI,0); c.lineWidth=5*u; c.strokeStyle=ink; c.stroke(); c.lineWidth=3*u; c.strokeStyle='#8a929a'; c.stroke();
  } else if(key==='reactor'){
    ground(30,40);
    rr(-24,-36,48,72,8); c.fillStyle=lin(-24,0,24,0,[[0,'#3a3d44'],[0.4,'#8a929a'],[1,'#2a2d33']]); c.fill(); inkS();
    for(i=0;i<5;i++){ rr(-28,-30+i*14,56,4,1.5); c.fillStyle='#5a6068'; c.fill(); c.strokeStyle=ink; c.lineWidth=u*0.8; c.stroke(); }
    rr(-12,-22,24,44,6); c.fillStyle=rad(0,0,30,[[0,'#ffffff'],[0.3,litHex(col,0.3,true)],[1,darkHex(col,0.4)]]); c.fill(); inkS(OL*0.8);
    glow(0,0,26,'rgba(224,140,255,.45)');
  } else if(key==='bloom'){
    ground(24,40);
    c.beginPath(); c.moveTo(-8*u,-34*u); c.lineTo(8*u,-34*u); c.lineTo(8*u,-12*u); c.quadraticCurveTo(28*u,4*u,24*u,22*u); c.quadraticCurveTo(20*u,36*u,0,36*u); c.quadraticCurveTo(-20*u,36*u,-24*u,22*u); c.quadraticCurveTo(-28*u,4*u,-8*u,-12*u); c.closePath();
    c.fillStyle='rgba(220,240,255,.35)'; c.fill(); inkS();
    c.save(); c.clip(); c.fillStyle=lin(0,0,0,36,[[0,litHex(col,0.3,true)],[1,darkHex(col,0.45)]]); c.fillRect(-30*u,4*u,60*u,34*u); c.restore();
    glow(0,20,22,'rgba(255,156,232,.6)');
    for(i=0;i<3;i++){ ell(-8+i*8,14+(i%2)*8,2.4,2.4); c.fillStyle='rgba(255,255,255,.85)'; c.fill(); }
    rr(-11,-40,22,9,2); c.fillStyle='#7a4a2a'; c.fill(); inkS(OL*0.8);
    c.fillStyle='rgba(255,255,255,.55)'; rr(-4,-30,3,16,1.5); c.fill();
  } else if(key==='meat'){
    ground(36,38);
    c.beginPath(); c.moveTo(-34*u,-4*u); c.bezierCurveTo(-34*u,-30*u,10*u,-34*u,22*u,-12*u); c.bezierCurveTo(30*u,4*u,20*u,30*u,-6*u,28*u); c.bezierCurveTo(-26*u,26*u,-34*u,14*u,-34*u,-4*u); c.closePath();
    c.fillStyle=rad(-10,-10,44,[[0,'#e8826a'],[0.6,col],[1,'#5a2014']]); c.fill(); inkS();
    c.strokeStyle='rgba(255,230,210,.6)'; c.lineWidth=3*u; c.beginPath(); c.moveTo(-24*u,-6*u); c.bezierCurveTo(-14*u,-18*u,4*u,-18*u,12*u,-6*u); c.stroke();
    ln(18,-4,40,-16,6,ink); ln(18,-4,40,-16,4,'#efe6d4'); ell(42,-18,5,5); c.fillStyle='#efe6d4'; c.fill(); inkS(OL*0.7);
  } else { c.restore(); return false; }
  c.restore();
  return true;
}
function keyIcon(c,key,S,col){
'@

SubRx @'
  try{ if(typeof keyIcon==='function'&&keyIcon(c,key,S,col)){ c.restore(); return; } }catch(_ki){}
'@ @'
  try{ if(typeof keyIcon==='function'&&keyIcon(c,key,S,col)){ c.restore(); return; } }catch(_ki){}
  try{ if(typeof partIcon==='function'&&partIcon(c,key,S,col)){ c.restore(); return; } }catch(_pi){}   // v18.44: the parts and salvage painter
'@

SubRx @'
var VER='18.43';
'@ @'
var VER='18.44';
'@

$pat = "(?m)^  now:'v18\.43:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.44: Parts and salvage (scrap, wire, cores, boards, the black box and the rest) have new detailed icons. Check 18.44 fails on v18.43',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
