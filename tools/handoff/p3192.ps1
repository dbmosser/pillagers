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

# THE SENTRY IS A HUMANOID COMBAT ROBOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawSentryS(e){
  var S=e.r/SENTRY_R0, fl=Math.cos(e.face)<0?-1:1, x=e.x, y=e.y, st=e.step||0, i, tx, off, EY=sprEyeOf(e);
  var lean=Math.sin(st*3)*1.3, brass=!!e.elite, t=(typeof G!=='undefined'&&G)?(G.t||0):0;
  shadowE(x,y+2,20*S,7*S,.46);
  // THE TREAD: an ink block, dark rubber, teeth top and bottom that run with the step, three road wheels in the gap
  wc.fillStyle=INK; rrF(x-19.2*S,y-13.2*S,38.4*S,14.4*S,4*S);
  wc.fillStyle='#1b1f24'; rrF(x-18*S,y-12*S,36*S,12*S,3*S);
  off=((st*6)%7+7)%7;
  wc.fillStyle='#363d45';
  for(i=-1;i<6;i++){ tx=-18+i*7+off*fl; if(tx<-18||tx>15) continue; wc.fillRect(x+tx*S,y-2.2*S,3*S,2*S); wc.fillRect(x+tx*S,y-12*S,3*S,1.6*S); }
  wc.fillStyle='#2a2f35'; wc.fillRect(x-16*S,y-9.5*S,32*S,6*S);
  for(i=-1;i<=1;i++){
    wc.fillStyle='#4a525b'; wc.beginPath(); wc.arc(x+i*11*S,y-6.5*S,3.3*S,0,6.2832); wc.fill();
    wc.fillStyle='#7c868f'; wc.beginPath(); wc.arc(x+i*11*S-0.7*S,y-7.2*S,1.2*S,0,6.2832); wc.fill();
  }
  // THE HULL: inked, a sloped glacis on the side it faces, the lit top plate and left rim, the shaded right face, grime low down
  sprMP(x,y,fl,S,[-15,-13,-15,-33,8.5,-33,15,-26.5,15,-13]); wc.strokeStyle=INK; wc.lineWidth=2.4*S; wc.lineJoin='round'; wc.stroke();
  wc.fillStyle='#59626b'; wc.fill();
  wc.fillStyle='#3e454c'; wc.fillRect(x+12*S,y-(fl>0?26.5:33)*S,3*S,(fl>0?13.5:20)*S);
  wc.fillStyle='#7c868f'; wc.fillRect(x-15*S,y-(fl>0?33:26.5)*S,1.1*S,(fl>0?20:13.5)*S);
  sprMR(x,y,fl,S,-15,-33,23.5,3.4);
  wc.fillStyle='#9aa4ad'; sprMP(x,y,fl,S,[8.5,-33,15,-26.5,15,-23,8.5,-29.6]); wc.fill();
  if(brass){ wc.fillStyle='#c9a24a'; sprMR(x,y,fl,S,-15,-33,23.5,1.1); }
  wc.fillStyle='rgba(58,44,30,.42)'; wc.fillRect(x-15*S,y-17.2*S,30*S,4.2*S);
  wc.fillStyle='#3e454c'; sprMR(x,y,fl,S,-15,-22.2,30,0.9); sprMR(x,y,fl,S,-2.5,-29.6,0.9,7.4);
  wc.fillStyle='#c8962e';
  for(i=0;i<2;i++){ tx=-9+i*6; sprMP(x,y,fl,S,[tx,-21,tx+2.6,-21,tx+5,-18.6,tx+2.6,-16.2,tx,-16.2,tx+2.4,-18.6]); wc.fill(); }
  wc.fillStyle='#2a2f35'; sprMR(x,y,fl,S,-12.5,-28,1.1,1.1); sprMR(x,y,fl,S,3,-28,1.1,1.1); sprMR(x,y,fl,S,-12.5,-15.6,1.1,1.1); sprMR(x,y,fl,S,10.5,-15.6,1.1,1.1);
  wc.fillStyle='#a9b2ba'; sprMR(x,y,fl,S,-12.5,-28.8,1.1,0.6); sprMR(x,y,fl,S,3,-28.8,1.1,0.6); sprMR(x,y,fl,S,-6,-13.9,2.2,0.7); sprMR(x,y,fl,S,13.4,-21,0.8,1.6);
  // THE MAST, the whip antenna leaning with the roll (two on an elite), and the camera head
  wc.fillStyle=INK; sprMR(x,y,fl,S,0.2,-39,4.6,6.5);
  wc.fillStyle='#3e454c'; sprMR(x,y,fl,S,1,-38.5,3,5.6);
  wc.strokeStyle=INK; wc.lineWidth=1.1*S; wc.beginPath();
  wc.moveTo(x-fl*2.5*S,y-46*S); wc.lineTo(x-fl*(3.5+lean*0.6)*S,y-53*S);
  if(brass){ wc.moveTo(x-fl*0.5*S,y-46*S); wc.lineTo(x-fl*(1+lean*0.6)*S,y-51.5*S); }
  wc.stroke();
  wc.fillStyle=(EY.h>0)?EY.c:'#8a949c'; wc.fillRect(x-fl*(3.5+lean*0.6)*S-0.7*S,y-53.8*S,1.4*S,1.4*S);
  sprMP(x,y,fl,S,[-4.5,-38.2,-4.5,-46,8,-46,10.5,-43.5,10.5,-38.2]); wc.strokeStyle=INK; wc.lineWidth=2.4*S; wc.stroke();
  wc.fillStyle='#59626b'; wc.fill();
  wc.fillStyle='#7c868f'; sprMR(x,y,fl,S,-4.5,-46,12.5,1.8);
  wc.fillStyle='#3e454c'; sprMR(x,y,fl,S,-4.5,-40.2,15,2);
  if(brass){ wc.fillStyle='#c9a24a'; sprMR(x,y,fl,S,-4.5,-46,12.5,0.8); }
  // THE LENS: an ink socket proud of the face, the core in the sensor language, a white glint top left
  var lx=x+fl*8.6*S, ly=y-42*S;
  wc.fillStyle=INK; wc.beginPath(); wc.arc(lx,ly,3.3*S,0,6.2832); wc.fill();
  wc.fillStyle='#2a2f35'; wc.beginPath(); wc.arc(lx,ly,2.5*S,0,6.2832); wc.fill();
  wc.globalCompositeOperation='lighter';
  wc.fillStyle=EY.c;
  if(EY.h>0){ wc.globalAlpha=0.30*EY.a; wc.beginPath(); wc.arc(lx,ly,2.6*EY.h*S*(EY.c==='#ff3b30'?(1+Math.sin(t*9)*0.12):1),0,6.2832); wc.fill(); }
  wc.globalAlpha=EY.a; wc.beginPath(); wc.arc(lx,ly,1.7*S,0,6.2832); wc.fill();
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  wc.fillStyle='rgba(255,255,255,.85)'; wc.fillRect(lx-1.3*S,ly-1.4*S,0.9*S,0.9*S);
  drawWindupGlow(e,lx,ly);
  // THE GUN turns to the aim: a mount, a perforated cooling shroud, twin barrels with a lit top line, a muzzle brake
  wc.save(); wc.translate(x,y-25*S); wc.rotate(e.face);
  wc.fillStyle=INK; wc.fillRect(1*S,-5*S,10.6*S,10*S); wc.fillRect(9.4*S,-4.2*S,13.4*S,8.4*S); wc.fillRect(21.6*S,-3.6*S,7.4*S,7.2*S); wc.fillRect(27.6*S,-4.4*S,4.6*S,8.8*S);
  wc.fillStyle='#3e454c'; wc.fillRect(2*S,-4*S,8.6*S,8*S);
  wc.fillStyle='#59626b'; wc.fillRect(2*S,-4*S,8.6*S,1.6*S);
  wc.fillStyle='#2a2f35'; wc.fillRect(10.4*S,-3.2*S,11.4*S,6.4*S);
  wc.fillStyle='#0e1114'; wc.fillRect(12.4*S,-0.9*S,1.6*S,1.8*S); wc.fillRect(15.6*S,-0.9*S,1.6*S,1.8*S); wc.fillRect(18.8*S,-0.9*S,1.6*S,1.8*S);
  wc.fillStyle='#4a525b'; wc.fillRect(21.8*S,-2.6*S,6.2*S,2*S); wc.fillRect(21.8*S,0.6*S,6.2*S,2*S);
  wc.fillStyle='#8d98a3'; wc.fillRect(21.8*S,-2.6*S,6.2*S,0.6*S); wc.fillRect(10.4*S,-3.2*S,11.4*S,0.6*S);
  wc.fillStyle='#2a2f35'; wc.fillRect(28.4*S,-3.6*S,3*S,7.2*S);
  if(e.muzzle>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,194,122,'+(0.95*flashK()).toFixed(3)+')';
    wc.beginPath(); wc.arc(32*S,-1.6*S,4.2*S,0,6.2832); wc.fill();
    wc.beginPath(); wc.arc(32*S,1.6*S,4.2*S,0,6.2832); wc.fill();
    wc.globalCompositeOperation='source-over';
  }
  wc.restore();
}
'@ @'
// v31.92 (cw-sentrybot), HIS ORDER (2026-10-19): "I want the sentry to look a bit more humanoid robot-y, instead of like a big garbage can".
// The Sentry was a tread, a boxy hull and a camera on a mast. It is now a heavy humanoid combat robot, plainly a machine: two armoured legs
// (the back one darker) with knee plates and flat feet that walk on e.step, a pelvis, a chest broad at the shoulders under two pauldrons, a
// small head whose visor holds the same sensor lens, the whip antenna (two on an elite), one arm hanging and swinging with the gait and the
// other arm BEING the gun, pivoted at its shoulder to e.face. Same palette and ink outline, same size, shadow, feet at y and mirror with the
// facing. The legs only walk while e.moving, else both feet stand planted. Drawn only: no random numbers, nothing written on the machine.
// sprML strokes a polyline in the machine frame, sprRR fills a rounded rect in it, sprKnee solves the knee of a two bone leg (it bends forward).
var SENTRY_LEGC=[['#3e454c','#363d45','#4a525b','#2a2f35','#59626b'],['#59626b','#4e565f','#7c868f','#3e454c','#9aa4ad']];
function sprML(ox,oy,fl,S,p,w,col){
  wc.strokeStyle=col; wc.lineWidth=w*S; wc.beginPath(); wc.moveTo(ox+fl*p[0]*S,oy+p[1]*S);
  for(var i=2;i<p.length;i+=2) wc.lineTo(ox+fl*p[i]*S,oy+p[i+1]*S);
  wc.stroke();
}
function sprRR(ox,oy,fl,S,lx,ly,w,h,r){ rrF(fl>0?ox+lx*S:ox-(lx+w)*S,oy+ly*S,w*S,h*S,r*S); }
function sprKnee(hx,hy,ax,ay,a,b){
  var dx=ax-hx, dy=ay-hy, D=Math.sqrt(dx*dx+dy*dy)||0.01, ux=dx/D, uy=dy/D, d=Math.min(D,a+b-0.05), al=(d*d+a*a-b*b)/(2*d), pp=Math.sqrt(Math.max(0,a*a-al*al));
  return [hx+ux*al+uy*pp, hy+uy*al-ux*pp];
}
function drawSentryS(e){
  var S=e.r/SENTRY_R0, fl=Math.cos(e.face)<0?-1:1, x=e.x, y=e.y, st=e.step||0, i, k, EY=sprEyeOf(e), mv=!!e.moving, K, c, hx, hy, fx, ph, lf, sw, tx;
  var lean=Math.sin(st*3)*1.3, brass=!!e.elite, t=(typeof G!=='undefined'&&G)?(G.t||0):0;
  var g=st*1.5, bob=mv?-Math.abs(Math.cos(g))*1.2:0, yb=y+bob*S;
  shadowE(x,y+2,20*S,7*S,.46);
  wc.lineCap='round'; wc.lineJoin='round';
  // THE LEGS: two armoured legs, hip to knee to ankle, the knee bent forward, a flat foot on each. They walk on the step, one swinging forward and
  // lifting while the other stands and pushes back. The back leg (drawn first) is the darker one; the front leg is drawn after the arm that hangs.
  for(k=0;k<2;k++){
    if(k===1){
      // THE HANGING ARM, far side: shoulder, elbow, a clenched fist, swinging against the leg on its side
      sw=mv?Math.sin(g+3.14159)*3.6:0;
      sprML(x,yb,fl,S,[-14.2,-35.5,-16.2+sw*0.4,-27.8],8.2,INK); sprML(x,yb,fl,S,[-16.2+sw*0.4,-27.8,-15.6+sw,-20.6],7.8,INK);
      sprML(x,yb,fl,S,[-14.2,-35.5,-16.2+sw*0.4,-27.8],5.8,'#3e454c'); sprML(x,yb,fl,S,[-16.2+sw*0.4,-27.8,-15.6+sw,-20.6],5.4,'#3e454c');
      sprML(x-1.1*S,yb,fl,S,[-14.2,-35.5,-16.2+sw*0.4,-27.8,-15.6+sw,-20.6],1.1,'#59626b');
      wc.fillStyle=INK; wc.beginPath(); wc.arc(x+fl*(-16.2+sw*0.4)*S,yb-27.8*S,3.5*S,0,6.2832); wc.fill();
      wc.fillStyle='#4a525b'; wc.beginPath(); wc.arc(x+fl*(-16.2+sw*0.4)*S,yb-27.8*S,2.5*S,0,6.2832); wc.fill();
      wc.fillStyle=INK; sprRR(x,yb,fl,S,-15.6+sw-3.9,-21.6,7.8,7.4,2.2);
      wc.fillStyle='#2a2f35'; sprRR(x,yb,fl,S,-15.6+sw-3,-20.8,6,5.8,1.6);
      wc.fillStyle='#59626b'; sprRR(x,yb,fl,S,-15.6+sw-3,-20.8,6,1.5,1);
      wc.fillStyle='#1b1f24'; sprRR(x,yb,fl,S,-15.6+sw-3,-17.6,6,0.8,0.4);
    }
    c=SENTRY_LEGC[k]; ph=g+k*3.14159; sw=mv?Math.sin(ph)*3.4:0; lf=mv?Math.max(0,Math.cos(ph))*3.8:0;
    hx=k?6:-6; hy=-21+bob; fx=(k?9.6:-9.6)+sw;
    K=sprKnee(hx,hy,fx-0.6,-4.6-lf,9.2,9.2);
    sprML(x,y,fl,S,[hx,hy,K[0],K[1]],10.6,INK); sprML(x,y,fl,S,[K[0],K[1],fx-0.6,-4.6-lf],9,INK);
    sprML(x,y,fl,S,[hx,hy,K[0],K[1]],8.2,c[0]); sprML(x,y,fl,S,[K[0],K[1],fx-0.6,-4.6-lf],6.6,c[1]);
    sprML(x-1.3*S,y,fl,S,[hx,hy,K[0],K[1],fx-0.6,-4.6-lf],1.1,c[4]);
    // the knee plate, the ankle cuff, then the flat foot with its toe forward
    wc.fillStyle=INK; wc.beginPath(); wc.arc(x+fl*(K[0]+0.9)*S,y+K[1]*S,4.3*S,0,6.2832); wc.fill();
    wc.fillStyle=c[2]; wc.beginPath(); wc.arc(x+fl*(K[0]+0.9)*S,y+K[1]*S,3.2*S,0,6.2832); wc.fill();
    wc.fillStyle=c[4]; wc.beginPath(); wc.arc(x+fl*(K[0]+0.9)*S-0.8*S,y+K[1]*S-0.9*S,1.1*S,0,6.2832); wc.fill();
    if(brass){ wc.strokeStyle='#c9a24a'; wc.lineWidth=0.9*S; wc.beginPath(); wc.arc(x+fl*(K[0]+0.9)*S,y+K[1]*S,3.2*S,0,6.2832); wc.stroke(); }
    wc.fillStyle='#2a2f35'; sprMR(x,y,fl,S,fx-3.6,-7.2-lf,6.4,1.5);
    sprMP(x,y,fl,S,[fx-5,-lf,fx+8.2,-lf,fx+9.2,-lf-1.6,fx+7,-lf-3.6,fx+3,-lf-4.4,fx-2.6,-lf-4.4,fx-5.2,-lf-2.6]);
    wc.strokeStyle=INK; wc.lineWidth=2.2*S; wc.stroke(); wc.fillStyle=c[3]; wc.fill();
    wc.fillStyle='#1b1f24'; sprMR(x,y,fl,S,fx-5,-lf-1.1,14,1.1);
    wc.fillStyle=c[4]; sprMR(x,y,fl,S,fx+3.2,-lf-3.9,4.4,0.9);
  }
  // THE PELVIS: a belted block over both hips with a ball joint at each
  wc.fillStyle=INK; sprRR(x,yb,fl,S,-10.6,-26.6,21.2,8,2.6);
  wc.fillStyle='#3e454c'; sprRR(x,yb,fl,S,-9.4,-25.4,18.8,5.6,2);
  wc.fillStyle='#2a2f35'; sprMR(x,yb,fl,S,-9.4,-25.4,18.8,1.5);
  wc.fillStyle='#59626b'; sprMR(x,yb,fl,S,-8.4,-23.7,16.8,0.8);
  wc.fillStyle='#c8962e'; sprMR(x,yb,fl,S,-1.2,-24,2.4,2.4);
  wc.fillStyle='#2a2f35'; sprMR(x,yb,fl,S,-7.6,-21.8,3.2,0.8); sprMR(x,yb,fl,S,4.4,-21.8,3.2,0.8);
  // THE CHEST: inked, broad at the shoulders and narrowing to the waist; lit top and left rim, shaded right face, a forward plate with the ochre chevrons
  sprMP(x,yb,1,S,[-14.6,-39.6,14.6,-39.6,15.8,-35.2,9.6,-26,-9.6,-26,-15.8,-35.2]); wc.strokeStyle=INK; wc.lineWidth=2.4*S; wc.stroke();
  wc.fillStyle='#59626b'; wc.fill();
  wc.fillStyle='#3e454c'; sprMP(x,yb,1,S,[8.6,-38.6,14.4,-38.6,15.4,-35.2,9.4,-26.4,7,-26.4]); wc.fill();
  wc.fillStyle='#7c868f'; sprMP(x,yb,1,S,[-14.4,-39,-12.8,-39,-8.6,-27,-9.6,-26.4,-15.2,-35.4]); wc.fill();
  wc.fillStyle='#9aa4ad'; sprMR(x,yb,1,S,-14.4,-39.4,28.8,1.5);
  if(brass){ wc.fillStyle='#c9a24a'; sprMR(x,yb,1,S,-14.4,-39.4,28.8,0.8); }
  wc.fillStyle='rgba(58,44,30,.42)'; sprMR(x,yb,1,S,-9.6,-29,19.2,3);
  wc.fillStyle='#3e454c'; sprMR(x,yb,fl,S,-9.4,-28.4,18.8,0.8); sprMR(x,yb,fl,S,-8.8,-26.9,17.6,0.7);
  wc.fillStyle=INK; sprRR(x,yb,fl,S,-2.4,-38.2,13.8,10.4,2);
  wc.fillStyle='#4a525b'; sprRR(x,yb,fl,S,-1.4,-37.2,11.8,8.4,1.4);
  wc.fillStyle='#69737c'; sprMR(x,yb,fl,S,-1.4,-37.2,11.8,1);
  wc.fillStyle='#c8962e';
  for(i=0;i<2;i++){ tx=0.4+i*4.9; sprMP(x,yb,fl,S,[tx,-35.4,tx+2.4,-35.4,tx+4.6,-33,tx+2.4,-30.6,tx,-30.6,tx+2.2,-33]); wc.fill(); }
  wc.fillStyle='#1b1f24'; sprMR(x,yb,fl,S,-11.6,-36.2,5.6,6.4); wc.fillStyle='#a77a28'; for(i=0;i<3;i++) sprMR(x,yb,fl,S,-10.8,-35.2+i*2,4,0.9);
  wc.fillStyle='#2a2f35'; sprMR(x,yb,fl,S,-12.4,-36.8,0.9,0.9); sprMR(x,yb,fl,S,11.2,-28.8,0.9,0.9); sprMR(x,yb,fl,S,-6.6,-28.8,0.9,0.9);
  wc.fillStyle='#a9b2ba'; sprMR(x,yb,fl,S,-12.4,-37.4,0.9,0.5);
  // THE PAULDRONS: a big rounded plate on each shoulder, the far one a shade darker, the near one carries the gun
  for(k=0;k<2;k++){
    tx=k?-14.4:8.4;
    wc.fillStyle=INK; sprRR(x,yb,fl,S,tx-0.9,-42.2,11.4,9.4,3.6);
    wc.fillStyle=k?'#4a525b':'#59626b'; sprRR(x,yb,fl,S,tx,-41.3,9.6,7.6,2.9);
    wc.fillStyle=k?'#69737c':'#8d98a3'; sprRR(x,yb,fl,S,tx+0.6,-41.3,8.4,2.4,1.5);
    wc.fillStyle='#2a2f35'; sprMR(x,yb,fl,S,tx+1.2,-37,7.2,0.8);
    if(brass){ wc.fillStyle='#c9a24a'; sprMR(x,yb,fl,S,tx+1,-41.3,7.6,0.8); }
  }
  // THE HEAD: a small armoured head on a short neck, a dark visor across the face, the antenna on its back
  wc.fillStyle=INK; sprMR(x,yb,fl,S,-2.6,-41.4,6,3.4);
  wc.fillStyle='#2a2f35'; sprMR(x,yb,fl,S,-1.8,-41,4.4,2.6);
  wc.strokeStyle=INK; wc.lineWidth=1.1*S; wc.beginPath();
  wc.moveTo(x-fl*2.5*S,yb-47.6*S); wc.lineTo(x-fl*(3.5+lean*0.6)*S,yb-53.2*S);
  if(brass){ wc.moveTo(x-fl*0.5*S,yb-47.6*S); wc.lineTo(x-fl*(1+lean*0.6)*S,yb-51.8*S); }
  wc.stroke();
  wc.fillStyle=(EY.h>0)?EY.c:'#8a949c'; wc.fillRect(x-fl*(3.5+lean*0.6)*S-0.7*S,yb-54*S,1.4*S,1.4*S);
  sprMP(x,yb,fl,S,[-5.4,-47.6,5.6,-47.6,9.4,-45.2,9.4,-40.2,-5.4,-40.2]); wc.strokeStyle=INK; wc.lineWidth=2.4*S; wc.stroke();
  wc.fillStyle='#59626b'; wc.fill();
  wc.fillStyle='#7c868f'; sprMR(x,yb,fl,S,-5.4,-47.6,11,1.6);
  wc.fillStyle='#3e454c'; sprMR(x,yb,fl,S,-5.4,-41.8,14.8,1.6); sprMR(x,yb,fl,S,-5.4,-46,3,4);
  if(brass){ wc.fillStyle='#c9a24a'; sprMR(x,yb,fl,S,-5.4,-47.6,11,0.8); }
  wc.fillStyle=INK; sprRR(x,yb,fl,S,1.2,-46.2,8.8,5.2,2);
  wc.fillStyle='#14171a'; sprRR(x,yb,fl,S,1.9,-45.5,7.4,3.8,1.5);
  // THE LENS: an ink socket proud of the visor, the core in the sensor language, a white glint top left
  var lx=x+fl*7.8*S, ly=yb-43.6*S;
  wc.fillStyle=INK; wc.beginPath(); wc.arc(lx,ly,3.3*S,0,6.2832); wc.fill();
  wc.fillStyle='#2a2f35'; wc.beginPath(); wc.arc(lx,ly,2.5*S,0,6.2832); wc.fill();
  wc.globalCompositeOperation='lighter';
  wc.fillStyle=EY.c;
  if(EY.h>0){ wc.globalAlpha=0.30*EY.a; wc.beginPath(); wc.arc(lx,ly,2.6*EY.h*S*(EY.c==='#ff3b30'?(1+Math.sin(t*9)*0.12):1),0,6.2832); wc.fill(); }
  wc.globalAlpha=EY.a; wc.beginPath(); wc.arc(lx,ly,1.7*S,0,6.2832); wc.fill();
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  wc.fillStyle='rgba(255,255,255,.85)'; wc.fillRect(lx-1.3*S,ly-1.4*S,0.9*S,0.9*S);
  drawWindupGlow(e,lx,ly);
  // THE GUN ARM turns to the aim from its shoulder ball: a bracket, a perforated cooling shroud, twin barrels with a lit top line, a muzzle brake
  wc.lineCap='butt'; wc.lineJoin='miter';
  wc.save(); wc.translate(x+fl*12.2*S,yb-36.8*S); wc.rotate(e.face); if(fl<0) wc.scale(1,-1);
  wc.fillStyle=INK; wc.beginPath(); wc.arc(0,0,5.6*S,0,6.2832); wc.fill();
  wc.fillRect(2*S,-5*S,8.4*S,10*S); wc.fillRect(8.6*S,-4.2*S,12.2*S,8.4*S); wc.fillRect(19.8*S,-3.6*S,6.8*S,7.2*S); wc.fillRect(25.2*S,-4.4*S,4.2*S,8.8*S);
  wc.fillStyle='#4a525b'; wc.beginPath(); wc.arc(0,0,4.5*S,0,6.2832); wc.fill();
  wc.fillStyle='#8d98a3'; wc.beginPath(); wc.arc(-1.1*S,-1.2*S,1.5*S,0,6.2832); wc.fill();
  wc.fillStyle='#2a2f35'; wc.beginPath(); wc.arc(1.2*S,1.3*S,1.1*S,0,6.2832); wc.fill();
  wc.fillStyle='#3e454c'; wc.fillRect(3*S,-4*S,6.6*S,8*S);
  wc.fillStyle='#59626b'; wc.fillRect(3*S,-4*S,6.6*S,1.6*S);
  wc.fillStyle='#c8962e'; wc.fillRect(5.4*S,-4*S,1.3*S,8*S);
  wc.fillStyle='#2a2f35'; wc.fillRect(9.6*S,-3.2*S,10.4*S,6.4*S);
  wc.fillStyle='#0e1114'; wc.fillRect(11.4*S,-0.9*S,1.6*S,1.8*S); wc.fillRect(14.4*S,-0.9*S,1.6*S,1.8*S); wc.fillRect(17.4*S,-0.9*S,1.6*S,1.8*S);
  wc.fillStyle='#4a525b'; wc.fillRect(20*S,-2.6*S,5.8*S,2*S); wc.fillRect(20*S,0.6*S,5.8*S,2*S);
  wc.fillStyle='#8d98a3'; wc.fillRect(20*S,-2.6*S,5.8*S,0.6*S); wc.fillRect(9.6*S,-3.2*S,10.4*S,0.6*S);
  wc.fillStyle='#2a2f35'; wc.fillRect(26*S,-3.6*S,2.8*S,7.2*S);
  if(brass){ wc.fillStyle='#c9a24a'; wc.fillRect(26*S,-3.6*S,2.8*S,0.9*S); wc.fillRect(2*S,-4*S,1*S,8*S); }
  if(e.muzzle>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,194,122,'+(0.95*flashK()).toFixed(3)+')';
    wc.beginPath(); wc.arc(30*S,-1.6*S,4.2*S,0,6.2832); wc.fill();
    wc.beginPath(); wc.arc(30*S,1.6*S,4.2*S,0,6.2832); wc.fill();
    wc.globalCompositeOperation='source-over';
  }
  wc.restore();
}
'@

SubRx @'
// v28.xx (cw-wrecksentry), HIS NOTE (2026-10-18): "it would be cool if it showed wreckage instead. same for other enemy deaths." The Sentry wreck:
// the scorched tread with its wheel row, the slumped grey hull with its ochre chevrons, the camera head snapped off with a dead black lens, the twin gun fallen on the ground, a bent mast. Same palette as the live machine (MBPAL). Unsearched it shows ember cracks and smokes; searched the hull is an open black cavity.
// A pure function of the container: grit(x,y) for the facing, nothing random.
function drawWreckSentry(ct){
  var P=MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, i;
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl,1);
  wc.fillStyle='rgba(8,6,4,.5)'; wc.beginPath(); wc.ellipse(0,3,30,9,0,0,6.2832); wc.fill();
  wc.fillStyle=P.ink; rrF(-23,-9,46,13,4);
  wc.fillStyle=P.rub; rrF(-22,-8,44,11,3);
  wc.fillStyle=P.tooth; for(i=0;i<6;i++) wc.fillRect(-20+i*7,-8,3,1.6);
  for(i=-1;i<=1;i++){ wc.fillStyle=P.gm[1]; wc.beginPath(); wc.arc(i*12,-2.5,3.4,0,6.2832); wc.fill(); wc.fillStyle=P.gm[3]; wc.beginPath(); wc.arc(i*12-.7,-3.2,1.2,0,6.2832); wc.fill(); }
  wc.fillStyle=P.ink; rrF(-18,-24,36,17,5);
  wc.fillStyle=P.gm[2]; rrF(-17,-23,34,15,4);
  wc.fillStyle=P.gm[3]; rrF(-17,-23,34,3,2);
  wc.fillStyle=P.ox[0]; wc.fillRect(-17,-13,34,2);
  wc.fillStyle=P.grime; wc.fillRect(-17,-12,34,4);
  wc.fillStyle=P.och; mbPoly([-12,-19,-9.4,-19,-7,-16.6,-9.4,-14.2,-12,-14.2,-9.6,-16.6]); mbPoly([-6,-19,-3.4,-19,-1,-16.6,-3.4,-14.2,-6,-14.2,-3.6,-16.6]);
  wc.fillStyle=P.ink; mbPoly([8,-24,13,-24,17,-20,10,-17]);
  if(o){ wc.fillStyle='#0e0b09'; rrF(0,-21,13,9,2); }
  else { wc.strokeStyle='#d8651f'; wc.lineWidth=.9; wc.beginPath(); wc.moveTo(2,-12); wc.lineTo(5,-17); wc.lineTo(3,-21); wc.moveTo(10,-12); wc.lineTo(8,-16); wc.stroke(); }
  wc.fillStyle=P.ink; rrF(-3,-30,7,8,1.5); wc.fillStyle=P.gm[1]; rrF(-2,-29,5,6,1);
  wc.strokeStyle=P.ink; wc.lineWidth=1.3; wc.beginPath(); wc.moveTo(2,-30); wc.lineTo(8,-36); wc.lineTo(5,-41); wc.stroke();
  wc.fillStyle=P.ink; rrF(18,-6,19,13,4);
  wc.fillStyle=P.gm[1]; rrF(19,-5,17,11,3);
  wc.fillStyle=P.gm[3]; wc.fillRect(20,-5,15,1.6);
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(31,1,3.6,0,6.2832); wc.fill();
  wc.fillStyle='#050505'; wc.beginPath(); wc.arc(31,1,2.3,0,6.2832); wc.fill();
  wc.lineCap='round';
  wc.strokeStyle=P.ink; wc.lineWidth=8; wc.beginPath(); wc.moveTo(-40,7); wc.lineTo(-21,4); wc.stroke();
  wc.strokeStyle=P.gm[1]; wc.lineWidth=5.4; wc.stroke();
  wc.strokeStyle=P.steel; wc.lineWidth=1.1; wc.beginPath(); wc.moveTo(-38,5.4); wc.lineTo(-23,3); wc.stroke();
  wc.strokeStyle=P.ink; wc.lineWidth=3; wc.beginPath(); wc.moveTo(-40,9.5); wc.lineTo(-22,6.5); wc.stroke(); wc.lineCap='butt';
  wc.restore();
  wreckSmoke(ct,26);
}
'@ @'
// v31.92 (cw-sentrybot), HIS ORDER (2026-10-19): the Sentry is a humanoid combat robot now, so its wreck is a TOPPLED ROBOT:
// the torso lying on its back with the ochre chevron plate up and its shoulder plate at the head end, the head knocked off with a dead black lens and a
// dented visor, one leg bent up at the knee with its flat foot, one leg snapped at the knee, the gun arm lying apart on the ground, a bent antenna. Same palette as
// the live machine (MBPAL). Unsearched it shows ember cracks and smokes; searched the chest hatch is open on a black cavity.
// A pure function of the container: grit(x,y) for the facing, nothing random.
function drawWreckSentry(ct){
  var P=MBPAL, fl=grit(ct.x,ct.y)>.5?1:-1, o=!!ct.opened, i;
  wc.save(); wc.translate(ct.x,ct.y-1); wc.scale(fl,1);
  wc.fillStyle='rgba(8,6,4,.5)'; wc.beginPath(); wc.ellipse(0,3,30,9,0,0,6.2832); wc.fill();
  wc.lineCap='round'; wc.lineJoin='round';
  // the legs, behind the body: the snapped one first (its break torn open, a wire hanging), then the one bent up at the knee with its foot
  wc.strokeStyle=P.ink; wc.lineWidth=8.2; wc.beginPath(); wc.moveTo(-14,-2); wc.lineTo(-26,1.5); wc.stroke();
  wc.strokeStyle=P.gm[0]; wc.lineWidth=5.8; wc.stroke();
  wc.fillStyle=P.ink; mbPoly([-26.5,-3.4,-29.6,-1.6,-27.6,0,-30,2.6,-26.6,5,-25,1]);
  wc.strokeStyle='#d8651f'; wc.lineWidth=.9; wc.beginPath(); wc.moveTo(-28,1); wc.lineTo(-31,4.5); wc.lineTo(-30,7.5); wc.stroke();
  wc.strokeStyle=P.ink; wc.lineWidth=8.4; wc.beginPath(); wc.moveTo(-15,-6); wc.lineTo(-25,-15); wc.lineTo(-33,-7); wc.stroke();
  wc.strokeStyle=P.gm[1]; wc.lineWidth=6; wc.stroke();
  wc.strokeStyle=P.steel; wc.lineWidth=1.1; wc.beginPath(); wc.moveTo(-16,-8); wc.lineTo(-25.6,-16.6); wc.lineTo(-33.8,-8.4); wc.stroke();
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(-24.2,-15,4.6,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[2]; wc.beginPath(); wc.arc(-24.2,-15,3.4,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[3]; wc.beginPath(); wc.arc(-25,-15.9,1.1,0,6.2832); wc.fill();
  wc.fillStyle=P.ink; mbPoly([-42,-0.2,-29,-0.2,-27.6,-2.2,-30,-4.6,-34.6,-5.4,-39,-5,-42.2,-3]);
  wc.fillStyle=P.gm[0]; mbPoly([-41,-1,-29.6,-1,-28.8,-2.2,-30.6,-3.8,-34.6,-4.4,-38.4,-4,-41,-2.6]);
  wc.fillStyle=P.gm[3]; wc.fillRect(-38,-4.1,6,.9);
  // the pelvis, tipped over, and the torso lying on its back: shoulder plate at the right, the chest plate up
  wc.fillStyle=P.ink; rrF(-20,-10,13,10,3);
  wc.fillStyle=P.gm[1]; rrF(-19,-9,11,8,2.4);
  wc.fillStyle=P.gm[0]; wc.fillRect(-19,-9,11,1.8);
  wc.fillStyle=P.och; wc.fillRect(-15.6,-6.4,2.4,2.4);
  wc.fillStyle=P.ink; mbPoly([-9,-12,3,-15.4,14,-16.6,17.6,-12,17.6,-3,14,0,-9,0]);
  wc.fillStyle=P.gm[2]; mbPoly([-8,-11,3,-14.2,13.4,-15.4,16.4,-11.4,16.4,-3.4,13.4,-1,-8,-1]);
  wc.fillStyle=P.gm[3]; mbPoly([-8,-11,3,-14.2,13.4,-15.4,13.4,-13.4,3,-12.2,-8,-9.2]);
  wc.fillStyle=P.ox[0]; wc.fillRect(-8,-4,24,1.6);
  wc.fillStyle=P.grime; wc.fillRect(-8,-3,24,3);
  wc.fillStyle=P.och; mbPoly([-5.6,-10.2,-3.2,-10.2,-1,-8,-3.2,-5.8,-5.6,-5.8,-3.4,-8]); mbPoly([-0.8,-10.4,1.6,-10.4,3.8,-8.2,1.6,-6,-0.8,-6,1.4,-8.2]);
  if(o){
    wc.fillStyle=P.ink; mbPoly([4.4,-13.6,12.8,-14.6,13.4,-3.4,4.4,-3.4]);
    wc.fillStyle='#0e0b09'; mbPoly([5.4,-12.6,12,-13.4,12.4,-4.4,5.4,-4.4]);
    wc.fillStyle=P.ink; mbPoly([4,-14,13.6,-15.2,15.6,-23,6,-22]);
    wc.fillStyle=P.gm[2]; mbPoly([5,-14.6,12.8,-15.6,14.4,-21.8,6.8,-21]);
    wc.fillStyle=P.och; wc.fillRect(8,-19.8,3,1.1);
  } else {
    wc.strokeStyle='#d8651f'; wc.lineWidth=.9; wc.beginPath(); wc.moveTo(5,-14); wc.lineTo(8,-9); wc.lineTo(6,-5); wc.moveTo(12,-14.6); wc.lineTo(10,-10); wc.lineTo(12.6,-6); wc.stroke();
  }
  wc.fillStyle=P.ink; rrF(12,-20,10,14,4);
  wc.fillStyle=P.gm[1]; rrF(13,-19,8,12,3);
  wc.fillStyle=P.gm[3]; wc.fillRect(14,-19,6,1.8);
  wc.fillStyle=P.gm[0]; wc.fillRect(14,-12.2,6,.9);
  // the head, knocked off and lying tilted: a dented visor with its lens gone dead black, the antenna bent beside it
  wc.save(); wc.translate(31,-6); wc.rotate(.5);
  wc.fillStyle=P.ink; mbPoly([-7.4,-5.6,5.4,-5.6,8.4,-3,8.4,3.8,-7.4,3.8]);
  wc.fillStyle=P.gm[2]; mbPoly([-6.4,-4.6,4.8,-4.6,7.4,-2.4,7.4,2.8,-6.4,2.8]);
  wc.fillStyle=P.gm[3]; wc.fillRect(-6.4,-4.6,10,1.3);
  wc.fillStyle=P.gm[0]; wc.fillRect(-6.4,1.2,13.8,1.6);
  wc.fillStyle=P.ink; wc.fillRect(-3.4,-3.1,10,4.6);
  wc.fillStyle='#14171a'; wc.fillRect(-2.6,-2.4,8.4,3.2);
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(4.4,-0.6,3,0,6.2832); wc.fill();
  wc.fillStyle='#050505'; wc.beginPath(); wc.arc(4.4,-0.6,2,0,6.2832); wc.fill();
  wc.strokeStyle=P.ink; wc.lineWidth=.9; wc.beginPath(); wc.moveTo(-1,-4.6); wc.lineTo(0.4,-1.6); wc.lineTo(-1.4,1.2); wc.stroke();
  wc.restore();
  wc.strokeStyle=P.ink; wc.lineWidth=1.3; wc.beginPath(); wc.moveTo(23.6,-2); wc.lineTo(27,2.4); wc.lineTo(33,1.6); wc.stroke();
  // the gun arm, lying apart on the ground in front: the shoulder ball, the shroud, the twin barrels, a black muzzle
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(-1,6,5.4,0,6.2832); wc.fill(); rrF(1,1.4,10,9.2,2); rrF(9.4,2.2,12.6,7.6,2); rrF(20.6,2.8,8,6.4,1.5); rrF(27.4,1.8,4.4,8.4,1.5);
  wc.fillStyle=P.gm[1]; wc.beginPath(); wc.arc(-1,6,4.2,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[3]; wc.beginPath(); wc.arc(-2,5,1.4,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[2]; wc.fillRect(2,2.4,8,7.2); wc.fillRect(10.4,3.2,11,5.6);
  wc.fillStyle=P.gm[3]; wc.fillRect(2,2.4,8,1.4); wc.fillRect(10.4,3.2,11,1);
  wc.fillStyle=P.och; wc.fillRect(5,2.4,1.3,7.2);
  wc.fillStyle=P.gm[0]; wc.fillRect(21.4,3.8,6.6,2); wc.fillRect(21.4,6.6,6.6,2);
  wc.fillStyle='#050505'; wc.beginPath(); wc.arc(31.6,6,1.9,0,6.2832); wc.fill();
  wc.lineCap='butt'; wc.lineJoin='miter';
  wc.restore();
  wreckSmoke(ct,22);
}
'@

SubRx @'
var VER='31.91';
'@ @'
var VER='31.92';
'@

$pat = "(?m)^  now:'v31\.91:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.92: the sentry is a walking humanoid combat robot, and its wreck is a toppled robot. Check 31.92 fails on v31.91',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
