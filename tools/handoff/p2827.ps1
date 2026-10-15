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

# POWER-UPS ARE BIG FLOATING ICONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// the glyph in the middle of a pickup coin (x, y the middle, s the size)
function pwrGlyph(c,k,x,y,s,D,z){
  var j;
  c.save(); c.strokeStyle='rgba('+D.rgb+',1)'; c.fillStyle='rgba('+D.rgb+',1)'; c.lineWidth=2.2*z; c.lineCap='round'; c.lineJoin='round';
  if(k==='clip'){ c.beginPath(); c.arc(x-s*0.5,y,s*0.5,0,6.2832); c.stroke(); c.beginPath(); c.arc(x+s*0.5,y,s*0.5,0,6.2832); c.stroke(); }
  else if(k==='dmg'){ c.font=hudFS(TYPE.label); c.textAlign='center'; c.fillText('2X',x,y+4*z); }
  else if(k==='rapid'){ for(j=0;j<3;j++){ c.beginPath(); c.moveTo(x-s*0.9+j*s*0.62,y-s*0.7); c.lineTo(x-s*0.35+j*s*0.62,y); c.lineTo(x-s*0.9+j*s*0.62,y+s*0.7); c.stroke(); } }
  else if(k==='shield'){
    c.beginPath(); c.moveTo(x,y-s); c.lineTo(x+s*0.8,y-s*0.55); c.lineTo(x+s*0.8,y+s*0.15); c.lineTo(x,y+s); c.lineTo(x-s*0.8,y+s*0.15); c.lineTo(x-s*0.8,y-s*0.55); c.closePath(); c.stroke();
  }
  else if(k==='pulse'){
    c.beginPath(); c.arc(x,y,s*0.28,0,6.2832); c.fill();
    c.beginPath(); c.arc(x,y,s*0.65,0,6.2832); c.stroke();
    c.beginPath(); c.arc(x,y,s*1.0,-0.8,0.8); c.stroke(); c.beginPath(); c.arc(x,y,s*1.0,2.34,3.94); c.stroke();
  }
  // PWR-GLYPHS (the next party builds add their glyphs above this line)
  c.restore();
}
'@ @'
// v28.27 (partyp7), HIS WORDS on the power-ups (2026-10-14, the party playtest): "i never saw one so not sure" and "floating icon". A pickup was a thirty pixel coin
// with a thin beam, and he never saw one in a raid. Now each is a BIG FLOATING ICON in the style of the CoD Zombies power-ups: a chamfered metal medallion (the shape
// of the medals) with a rim in the power-up's colour and a picture that is its alone, floating PWRI.hover above the ground, bobbing, and spinning on its axis
// (it narrows to half its width twice every four seconds and opens again), over a tall light beam (PWRI.beam, so he sees one from far away, and a pickup just
// off the screen still shows its beam) with sparks rising in it, a glow on the ground and a turning ring that is exactly the reach that picks it up (PWR.pick). It
// comes in with a flash and a growing ring (PWRI.spawn), shows its name under it when he is near (PWRI.label), and over its last PWR.blink seconds it blinks, faster
// over the last PWRI.fast. The pictures: BOTTOMLESS CLIP an infinity sign over a row of rounds, DOUBLE DAMAGE a bold 2X, RAPID FIRE three chevrons,
// SHIELD BUBBLE a shield, SCREEN CLEAR a blast. Cosmetic only: nothing here draws from a seeded stream.
var PWRI={R:34,hover:44,bob:5,beam:340,spin:1.6,fast:2,spawn:0.45,label:380};
// the glyph in the middle of a pickup medallion or a timer (x, y the middle, s the half size)
function pwrGlyph(c,k,x,y,s,D,z){
  var j, lw=Math.max(2.2*z,s*0.2);
  c.save(); c.strokeStyle='rgba('+D.rgb+',1)'; c.fillStyle='rgba('+D.rgb+',1)'; c.lineWidth=lw; c.lineCap='round'; c.lineJoin='round';
  if(k==='clip'){
    c.beginPath(); c.moveTo(x,y+s*0.2);
    c.bezierCurveTo(x+s*0.4,y-s*0.45,x+s*1.1,y-s*0.45,x+s*1.1,y+s*0.2);
    c.bezierCurveTo(x+s*1.1,y+s*0.85,x+s*0.4,y+s*0.85,x,y+s*0.2);
    c.bezierCurveTo(x-s*0.4,y-s*0.45,x-s*1.1,y-s*0.45,x-s*1.1,y+s*0.2);
    c.bezierCurveTo(x-s*1.1,y+s*0.85,x-s*0.4,y+s*0.85,x,y+s*0.2); c.stroke();
    for(j=-1;j<=1;j++) c.fillRect(x+j*s*0.52-s*0.1,y-s*1.05,s*0.2,s*0.42);
  }
  else if(k==='dmg'){ c.font='800 '+Math.round(s*1.75)+'px '+HUDF; c.textAlign='center'; c.textBaseline='middle'; c.fillText('2X',x,y+s*0.06); }
  else if(k==='rapid'){ for(j=0;j<3;j++){ c.beginPath(); c.moveTo(x-s*0.98+j*s*0.64,y-s*0.78); c.lineTo(x-s*0.3+j*s*0.64,y); c.lineTo(x-s*0.98+j*s*0.64,y+s*0.78); c.stroke(); } }
  else if(k==='shield'){
    c.beginPath(); c.moveTo(x,y-s); c.lineTo(x+s*0.82,y-s*0.55); c.lineTo(x+s*0.82,y+s*0.15); c.lineTo(x,y+s); c.lineTo(x-s*0.82,y+s*0.15); c.lineTo(x-s*0.82,y-s*0.55); c.closePath();
    c.save(); c.globalAlpha=c.globalAlpha*0.22; c.fill(); c.restore(); c.stroke();
    c.beginPath(); c.moveTo(x-s*0.34,y-s*0.02); c.lineTo(x-s*0.06,y+s*0.3); c.lineTo(x+s*0.4,y-s*0.34); c.stroke();
  }
  else if(k==='pulse'){
    c.beginPath(); c.arc(x,y,s*0.26,0,6.2832); c.fill();
    c.beginPath(); c.arc(x,y,s*0.62,0,6.2832); c.stroke();
    c.beginPath(); c.arc(x,y,s*1.02,-0.8,0.8); c.stroke(); c.beginPath(); c.arc(x,y,s*1.02,2.34,3.94); c.stroke();
    for(j=0;j<4;j++){ c.beginPath(); c.moveTo(x+Math.cos(j*1.5708+0.785)*s*0.82,y+Math.sin(j*1.5708+0.785)*s*0.82); c.lineTo(x+Math.cos(j*1.5708+0.785)*s*1.18,y+Math.sin(j*1.5708+0.785)*s*1.18); c.stroke(); }
  }
  // PWR-GLYPHS (the next party builds add their glyphs above this line)
  c.restore();
}
'@

SubRx @'
  var S=G&&G.pwr, q, z, t, i, it, D, s, bob, left, a, R, ph, gr, k, n, ids=[], tw, tot, x0, y0, cy, miny, f, sc, ew;
'@ @'
  var S=G&&G.pwr, q, z, t, i, it, D, s, bob, left, a, R, ph, gr, k, n, ids=[], tw, tot, x0, y0, cy, miny, f, sc, ew, bl, ap, hov, ang, sxk, fl, u, mx, my, dd, la;
'@

SubRx @'
  for(i=0;i<S.items.length;i++){
    it=S.items[i]; D=pwrDef(it.k); if(!D) continue;
    s=w2s(it.x,0,it.y); if(s.x<-120||s.y<-180||s.x>W+120||s.y>H+120) continue;
    left=it.life-it.t; a=(left<PWR.blink&&(Math.floor(left*7)%2))?0.35:1;
    bob=Math.sin(t*3+it.id*1.3)*4*q; R=15*q; cy=s.y-bob-8*q;
    c.globalAlpha=a; c.globalCompositeOperation='lighter';
    ph=(t*0.9+it.id*0.37)%1;
    c.strokeStyle='rgba('+D.rgb+','+(0.5*(1-ph)).toFixed(3)+')'; c.lineWidth=2*z;
    c.beginPath(); c.ellipse(s.x,s.y+4*q,R*(1+ph*1.8),R*(1+ph*1.8)*0.45,0,0,6.2832); c.stroke();
    gr=c.createLinearGradient(0,cy-110*q,0,cy);
    gr.addColorStop(0,'rgba('+D.rgb+',0)'); gr.addColorStop(1,'rgba('+D.rgb+',.36)');
    c.fillStyle=gr; c.fillRect(s.x-6*q,cy-110*q,12*q,110*q);
    gr=c.createRadialGradient(s.x,cy,R*0.2,s.x,cy,R*2.4);
    gr.addColorStop(0,'rgba('+D.rgb+',.55)'); gr.addColorStop(1,'rgba('+D.rgb+',0)');
    c.fillStyle=gr; c.beginPath(); c.arc(s.x,cy,R*2.4,0,6.2832); c.fill();
    c.globalCompositeOperation='source-over';
    c.fillStyle='rgba(14,16,20,.92)'; c.beginPath(); c.arc(s.x,cy,R,0,6.2832); c.fill();
    c.strokeStyle='rgba('+D.rgb+',1)'; c.lineWidth=2.4*z; c.beginPath(); c.arc(s.x,cy,R,0,6.2832); c.stroke();
    pwrGlyph(c,it.k,s.x,cy,R*0.62,D,z);
  }
'@ @'
  for(i=0;i<S.items.length;i++){
    it=S.items[i]; D=pwrDef(it.k); if(!D) continue;
    s=w2s(it.x,0,it.y); bl=PWRI.beam*q; if(s.x<-160||s.y<-220||s.x>W+160||s.y>H+bl) continue;
    left=it.life-it.t; ap=Math.min(1,it.t/PWRI.spawn); ap=1-(1-ap)*(1-ap);
    a=(left<PWR.blink&&(Math.floor(left*(left<PWRI.fast?13:7))%2))?0.3:1;
    R=PWRI.R*q*(0.45+0.55*ap); hov=PWRI.hover*q*ap; bob=Math.sin(t*2.4+it.id*1.3)*PWRI.bob*q; cy=s.y-hov-bob;
    sxk=0.5+0.5*Math.abs(Math.cos(t*PWRI.spin+it.id*1.3)); fl=0.82+0.18*Math.sin(t*9+it.id*2.1);
    c.globalAlpha=a;
    c.fillStyle='rgba(0,0,0,'+(0.3*ap).toFixed(3)+')'; c.beginPath(); c.ellipse(s.x,s.y+3*q,R*0.8*(1-0.08*Math.sin(t*2.4+it.id*1.3)),R*0.3,0,0,6.2832); c.fill();
    c.globalCompositeOperation='lighter';
    gr=c.createRadialGradient(s.x,s.y,0,s.x,s.y,PWR.pick*q*1.7); gr.addColorStop(0,'rgba('+D.rgb+',.5)'); gr.addColorStop(1,'rgba('+D.rgb+',0)');
    c.fillStyle=gr; c.beginPath(); c.arc(s.x,s.y,PWR.pick*q*1.7,0,6.2832); c.fill();
    c.setLineDash([7*z,9*z]); c.lineDashOffset=-t*26*z; c.strokeStyle='rgba('+D.rgb+',.8)'; c.lineWidth=2.2*z;
    c.beginPath(); c.arc(s.x,s.y,PWR.pick*q,0,6.2832); c.stroke(); c.setLineDash([]);
    ph=(t*0.9+it.id*0.37)%1; c.strokeStyle='rgba('+D.rgb+','+(0.55*(1-ph)).toFixed(3)+')'; c.lineWidth=2*z;
    c.beginPath(); c.arc(s.x,s.y,PWR.pick*q*(1+ph*1.3),0,6.2832); c.stroke();
    if(it.t<0.5){ u=it.t/0.5; c.strokeStyle='rgba(255,255,255,'+(0.9*(1-u)).toFixed(3)+')'; c.lineWidth=(2+5*(1-u))*z; c.beginPath(); c.arc(s.x,s.y,PWR.pick*q*(0.4+2.2*u),0,6.2832); c.stroke(); }
    gr=c.createLinearGradient(0,s.y,0,s.y-bl); gr.addColorStop(0,'rgba('+D.rgb+','+(0.5*fl).toFixed(3)+')'); gr.addColorStop(0.55,'rgba('+D.rgb+','+(0.22*fl).toFixed(3)+')'); gr.addColorStop(1,'rgba('+D.rgb+',0)');
    c.fillStyle=gr; c.beginPath(); c.moveTo(s.x-14*q,s.y); c.lineTo(s.x-5*q,s.y-bl); c.lineTo(s.x+5*q,s.y-bl); c.lineTo(s.x+14*q,s.y); c.closePath(); c.fill();
    gr=c.createLinearGradient(0,s.y,0,s.y-bl*0.8); gr.addColorStop(0,'rgba(255,255,255,'+(0.55*fl).toFixed(3)+')'); gr.addColorStop(1,'rgba(255,255,255,0)');
    c.fillStyle=gr; c.fillRect(s.x-1.6*q,s.y-bl*0.8,3.2*q,bl*0.8);
    for(k=0;k<6;k++){ u=(t*0.35+k/6+it.id*0.13)%1; mx=s.x+Math.sin(t*2.2+k*2.4+it.id)*(9+7*u)*q; my=s.y-u*bl*0.7; c.fillStyle='rgba(255,255,255,'+(0.75*(1-u)).toFixed(3)+')'; c.fillRect(mx-1.4*q,my-1.4*q,2.8*q,2.8*q); }
    gr=c.createRadialGradient(s.x,cy,R*0.3,s.x,cy,R*2.4); gr.addColorStop(0,'rgba('+D.rgb+',.6)'); gr.addColorStop(1,'rgba('+D.rgb+',0)');
    c.fillStyle=gr; c.beginPath(); c.arc(s.x,cy,R*2.4,0,6.2832); c.fill();
    c.globalCompositeOperation='source-over';
    c.save(); c.translate(s.x,cy); c.scale(sxk,1);
    gr=c.createLinearGradient(-R,-R,R,R); gr.addColorStop(0,'rgba(255,255,255,.95)'); gr.addColorStop(0.35,D.hex); gr.addColorStop(1,'rgba('+D.rgb+',.5)');
    c.fillStyle=gr; styOct(c,R,R*0.38); c.fill();
    gr=c.createRadialGradient(0,-R*0.2,R*0.1,0,0,R*0.85); gr.addColorStop(0,'#2b3137'); gr.addColorStop(1,'#0e1114');
    c.fillStyle=gr; styOct(c,R*0.8,R*0.3); c.fill(); c.strokeStyle='rgba('+D.rgb+',.75)'; c.lineWidth=1.5*z; c.stroke();
    pwrGlyph(c,it.k,0,0,R*0.5,D,z);
    u=((t*0.4+it.id*0.31)%1.6)/1.6;
    if(u<1){ c.save(); styOct(c,R,R*0.38); c.clip(); c.rotate(-0.55); gr=c.createLinearGradient(-R*0.35+(u-0.5)*R*4.6,0,R*0.35+(u-0.5)*R*4.6,0); gr.addColorStop(0,'rgba(255,255,255,0)'); gr.addColorStop(0.5,'rgba(255,255,255,.55)'); gr.addColorStop(1,'rgba(255,255,255,0)'); c.fillStyle=gr; c.fillRect(-R*3,-R*3,R*6,R*6); c.restore(); }
    c.restore();
    dd=Math.hypot(it.x-p.x,it.y-p.y);
    if(dd<PWRI.label){ la=Math.min(1,(PWRI.label-dd)/120)*ap; c.globalAlpha=a*la; c.font=hudFS(TYPE.micro); c.textAlign='center'; c.textBaseline='alphabetic'; c.fillStyle='rgba('+D.rgb+',1)'; hudText(D.n,Math.round(s.x),Math.round(s.y+26*q)); c.textAlign='left'; }
  }
'@

SubRx @'
var VER='28.26';
'@ @'
var VER='28.27';
'@

$pat = "(?m)^  now:'v28\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v28.27: Power-ups are big floating icons over a tall beam, spinning and blinking before they vanish. Check 28.27 fails on v28.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
