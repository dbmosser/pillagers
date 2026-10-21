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

# PIXEL MACHINES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
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
'@ @'
function drawSentryS(e){
  if(pixOn()&&!PIXM.paint&&pixMachDraw(e,drawSentryS)) return; // v28.xx (cw-cx-pixmachines): the body is cached at PIX_ACT, including job 80 size
  var S=e.r/SENTRY_R0, fl=Math.cos(e.face)<0?-1:1, x=e.x, y=e.y, st=e.step||0, i, k, EY=sprEyeOf(e), mv=!!e.moving, K, c, hx, hy, fx, ph, lf, sw, tx;
  var lean=Math.sin(st*3)*1.3, brass=!!e.elite, t=(typeof G!=='undefined'&&G)?(pixMachTime()||0):0;
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
  if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
  wc.fillStyle=EY.c;
  if(EY.h>0){ wc.globalAlpha=0.30*EY.a; wc.beginPath(); wc.arc(lx,ly,2.6*EY.h*S*(EY.c==='#ff3b30'?(1+Math.sin(t*9)*0.12):1),0,6.2832); wc.fill(); }
  wc.globalAlpha=EY.a; wc.beginPath(); wc.arc(lx,ly,1.7*S,0,6.2832); wc.fill();
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else { wc.fillStyle=EY.c; wc.globalAlpha=EY.a; wc.beginPath(); wc.arc(lx,ly,1.7*S,0,6.2832); wc.fill(); wc.globalAlpha=1; }
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
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,194,122,'+(0.95*flashK()).toFixed(3)+')';
    wc.beginPath(); wc.arc(30*S,-1.6*S,4.2*S,0,6.2832); wc.fill();
    wc.beginPath(); wc.arc(30*S,1.6*S,4.2*S,0,6.2832); wc.fill();
    wc.globalCompositeOperation='source-over'; } else {  }
  }
  wc.restore();
}
'@

SubRx @'
function drawCrawlerS(e){
  var S=e.r/CRAWLER_R0, fl=Math.cos(e.face)<0?-1:1, x=e.x, y=e.y, i, k, side, EY=sprEyeOf(e), t=(typeof G!=='undefined'&&G)?(G.t||0):0;
  var hunting=e.state==='chase', drop=hunting?2:0, brass=!!e.elite, lg=e.legs||0;
  // the legs per side (far, near): hip, knee, foot for the rear, middle and front leg; the rear and front knees stand out past
  // the shell ends, the middle knees bend low under it
  var LG=[[[-6,-11.5,-13.5,-16.5,-14.5,-2.5],[-1,-10.5,-4,-6,-4.5,-2.5],[6,-11.5,12,-19.5,13.5,-2.5]],
          [[-7,-11,-15.5,-15.5,-17.5,0],[1,-10,5,-5.5,4.5,0],[7,-11,13.8,-18.8,16.5,0]]];
  shadowE(x,y+1,15*S,5*S,.44);
  // THE LEGS, far side first (darker, set back), then the near side, then the shell over their hips. A tripod gait: near rear, far middle and
  // near front swing together while the other three stand, each swinging foot lifted and carried forward.
  for(side=0;side<2;side++){
    var far=side===0, pts=[], L;
    for(i=0;i<3;i++){
      L=LG[side][i];
      var ph=lg+((((i+side)%2)===0)?0:Math.PI), sw=Math.cos(ph)*2.2, lift=Math.max(0,Math.sin(ph))*2.4;
      var reach=(hunting&&i===2)?3:0;
      pts.push([L[0],L[1]+drop, L[2]+sw*0.5+reach*0.6,L[3]+drop*0.5-lift*0.6, L[4]+sw+reach,L[5]-lift]);
    }
    wc.lineCap='round'; wc.lineJoin='round';
    wc.strokeStyle=INK; wc.lineWidth=3.8*S; wc.beginPath();
    for(i=0;i<3;i++) sprCrawlLeg(x,y,fl,S,pts[i][0],pts[i][1],pts[i][2],pts[i][3],pts[i][4],pts[i][5]);
    wc.stroke();
    wc.strokeStyle=far?'#2f353c':'#4a525b'; wc.lineWidth=2.1*S; wc.beginPath();
    for(i=0;i<3;i++) sprCrawlLeg(x,y,fl,S,pts[i][0],pts[i][1],pts[i][2],pts[i][3],pts[i][4],pts[i][5]);
    wc.stroke();
    // knee joints catch the light; the near feet are planted claws
    wc.fillStyle=far?'#4a525b':'#8d98a3';
    for(i=0;i<3;i++){ wc.fillRect(x+fl*pts[i][2]*S-0.8*S,y+pts[i][3]*S-0.8*S,1.6*S,1.6*S); }
    if(side===1){
      // THE SHELL over the hips of both rows of legs: three overlapping oxide segments, rear to front, each a dark rim, the paint,
      // a lit crown offset to the light, a dark seam at its back edge
      var SG=[[-8.5,9,8],[-0.5,10.5,9.5],[7.5,9.5,8.5]];
      for(k=0;k<3;k++){
        var cx=x+fl*SG[k][0]*S, cy=y+(-13.5+drop)*S, rw=SG[k][1]/2*S, rh=SG[k][2]/2*S;
        wc.fillStyle=INK; wc.beginPath(); wc.ellipse(cx,cy,rw+1.2*S,rh+1.2*S,0,0,6.2832); wc.fill();
        wc.fillStyle='#4e2419'; wc.beginPath(); wc.ellipse(cx,cy,rw,rh,0,0,6.2832); wc.fill();
        wc.fillStyle='#7a3a2a'; wc.beginPath(); wc.ellipse(cx-0.3*S,cy-0.9*S,rw-0.6*S,rh-1.1*S,0,0,6.2832); wc.fill();
        wc.fillStyle='#9c5038'; wc.beginPath(); wc.ellipse(cx-1.0*S,cy-rh*0.5,rw*0.62,rh*0.3,0,0,6.2832); wc.fill();
        if(brass){ wc.strokeStyle='#c9a24a'; wc.lineWidth=0.9*S; wc.beginPath(); wc.ellipse(cx,cy,rw-0.2*S,rh-0.2*S,0,3.5,5.95); wc.stroke(); }
      }
      wc.fillStyle='#2a1610';
      sprMR(x,y,fl,S,-4.6,-17.5+drop,0.9,7.5); sprMR(x,y,fl,S,3.6,-17.5+drop,0.9,7.5);
      wc.fillStyle='#b99a86'; sprMR(x,y,fl,S,-10,-17.4+drop,1.6,0.6); sprMR(x,y,fl,S,2,-18.1+drop,1.2,0.6); sprMR(x,y,fl,S,9.5,-11+drop,0.8,1.2);
      // THE HEAD: a gunmetal sensor block forward of the shell, two mandible blades under it
      var hy=-13.5+drop;
      wc.fillStyle=INK; sprMP(x,y,fl,S,[11,hy-5.6,17.5,hy-5.6,20.4,hy-2.2,20.4,hy+3.2,11,hy+3.6]); wc.fill();
      wc.fillStyle='#3e454c'; sprMP(x,y,fl,S,[12,hy-4.6,17,hy-4.6,19.4,hy-1.8,19.4,hy+2.4,12,hy+2.6]); wc.fill();
      wc.fillStyle='#59626b'; sprMR(x,y,fl,S,12,hy-4.6,5,1.3);
      wc.fillStyle=INK;
      sprMP(x,y,fl,S,[16.5,hy+1.2,23.2,hy+1.6,24.2,hy+3.8,21.2,hy+3.2,16.5,hy+3.6]); wc.fill();
      sprMP(x,y,fl,S,[15.5,hy+3,21.6,hy+4.6,22,hy+6.8,19,hy+5.6,15.5,hy+5.4]); wc.fill();
      wc.fillStyle='#8d98a3'; sprMR(x,y,fl,S,17,hy+1.6,5.6,0.7); sprMR(x,y,fl,S,16.2,hy+3.4,4.6,0.7);
      // THREE EYES (four on an elite), each its own socket, the main one largest
      var EYES=brass?[[17,-1.3,2.1,1.5],[13.9,-2.4,1.5,1.0],[14.6,0.9,1.5,1.0],[18.2,1.3,1.2,0.8]]:[[17,-1.3,2.1,1.5],[13.9,-2.4,1.5,1.0],[14.6,0.9,1.5,1.0]];
      for(k=0;k<EYES.length;k++){
        var ex=x+fl*EYES[k][0]*S, ey=y+(hy+EYES[k][1])*S;
        wc.fillStyle=INK; wc.beginPath(); wc.arc(ex,ey,EYES[k][2]*S,0,6.2832); wc.fill();
      }
      wc.globalCompositeOperation='lighter'; wc.fillStyle=EY.c;
      if(EY.h>0){ wc.globalAlpha=0.30*EY.a; wc.beginPath(); wc.arc(x+fl*17*S,y+(hy-1.3)*S,1.5*EY.h*S*(hunting?(1+Math.sin(t*14)*0.15):1),0,6.2832); wc.fill(); }
      wc.globalAlpha=EY.a;
      for(k=0;k<EYES.length;k++){ wc.beginPath(); wc.arc(x+fl*EYES[k][0]*S,y+(hy+EYES[k][1])*S,EYES[k][3]*S,0,6.2832); wc.fill(); }
      wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
      wc.fillStyle='rgba(255,255,255,.8)'; wc.fillRect(x+fl*17*S-1.1*S,y+(hy-2.5)*S,0.7*S,0.7*S);
    }
  }
  wc.lineCap='butt'; wc.lineJoin='miter';
}
'@ @'
function drawCrawlerS(e){
  if(pixOn()&&!PIXM.paint&&pixMachDraw(e,drawCrawlerS)) return; // v28.xx (cw-cx-pixmachines): the body is cached at PIX_ACT, including job 80 size
  var S=e.r/CRAWLER_R0, fl=Math.cos(e.face)<0?-1:1, x=e.x, y=e.y, i, k, side, EY=sprEyeOf(e), t=(typeof G!=='undefined'&&G)?(pixMachTime()||0):0;
  var hunting=e.state==='chase', drop=hunting?2:0, brass=!!e.elite, lg=e.legs||0;
  // the legs per side (far, near): hip, knee, foot for the rear, middle and front leg; the rear and front knees stand out past
  // the shell ends, the middle knees bend low under it
  var LG=[[[-6,-11.5,-13.5,-16.5,-14.5,-2.5],[-1,-10.5,-4,-6,-4.5,-2.5],[6,-11.5,12,-19.5,13.5,-2.5]],
          [[-7,-11,-15.5,-15.5,-17.5,0],[1,-10,5,-5.5,4.5,0],[7,-11,13.8,-18.8,16.5,0]]];
  shadowE(x,y+1,15*S,5*S,.44);
  // THE LEGS, far side first (darker, set back), then the near side, then the shell over their hips. A tripod gait: near rear, far middle and
  // near front swing together while the other three stand, each swinging foot lifted and carried forward.
  for(side=0;side<2;side++){
    var far=side===0, pts=[], L;
    for(i=0;i<3;i++){
      L=LG[side][i];
      var ph=lg+((((i+side)%2)===0)?0:Math.PI), sw=Math.cos(ph)*2.2, lift=Math.max(0,Math.sin(ph))*2.4;
      var reach=(hunting&&i===2)?3:0;
      pts.push([L[0],L[1]+drop, L[2]+sw*0.5+reach*0.6,L[3]+drop*0.5-lift*0.6, L[4]+sw+reach,L[5]-lift]);
    }
    wc.lineCap='round'; wc.lineJoin='round';
    wc.strokeStyle=INK; wc.lineWidth=3.8*S; wc.beginPath();
    for(i=0;i<3;i++) sprCrawlLeg(x,y,fl,S,pts[i][0],pts[i][1],pts[i][2],pts[i][3],pts[i][4],pts[i][5]);
    wc.stroke();
    wc.strokeStyle=far?'#2f353c':'#4a525b'; wc.lineWidth=2.1*S; wc.beginPath();
    for(i=0;i<3;i++) sprCrawlLeg(x,y,fl,S,pts[i][0],pts[i][1],pts[i][2],pts[i][3],pts[i][4],pts[i][5]);
    wc.stroke();
    // knee joints catch the light; the near feet are planted claws
    wc.fillStyle=far?'#4a525b':'#8d98a3';
    for(i=0;i<3;i++){ wc.fillRect(x+fl*pts[i][2]*S-0.8*S,y+pts[i][3]*S-0.8*S,1.6*S,1.6*S); }
    if(side===1){
      // THE SHELL over the hips of both rows of legs: three overlapping oxide segments, rear to front, each a dark rim, the paint,
      // a lit crown offset to the light, a dark seam at its back edge
      var SG=[[-8.5,9,8],[-0.5,10.5,9.5],[7.5,9.5,8.5]];
      for(k=0;k<3;k++){
        var cx=x+fl*SG[k][0]*S, cy=y+(-13.5+drop)*S, rw=SG[k][1]/2*S, rh=SG[k][2]/2*S;
        wc.fillStyle=INK; wc.beginPath(); wc.ellipse(cx,cy,rw+1.2*S,rh+1.2*S,0,0,6.2832); wc.fill();
        wc.fillStyle='#4e2419'; wc.beginPath(); wc.ellipse(cx,cy,rw,rh,0,0,6.2832); wc.fill();
        wc.fillStyle='#7a3a2a'; wc.beginPath(); wc.ellipse(cx-0.3*S,cy-0.9*S,rw-0.6*S,rh-1.1*S,0,0,6.2832); wc.fill();
        wc.fillStyle='#9c5038'; wc.beginPath(); wc.ellipse(cx-1.0*S,cy-rh*0.5,rw*0.62,rh*0.3,0,0,6.2832); wc.fill();
        if(brass){ wc.strokeStyle='#c9a24a'; wc.lineWidth=0.9*S; wc.beginPath(); wc.ellipse(cx,cy,rw-0.2*S,rh-0.2*S,0,3.5,5.95); wc.stroke(); }
      }
      wc.fillStyle='#2a1610';
      sprMR(x,y,fl,S,-4.6,-17.5+drop,0.9,7.5); sprMR(x,y,fl,S,3.6,-17.5+drop,0.9,7.5);
      wc.fillStyle='#b99a86'; sprMR(x,y,fl,S,-10,-17.4+drop,1.6,0.6); sprMR(x,y,fl,S,2,-18.1+drop,1.2,0.6); sprMR(x,y,fl,S,9.5,-11+drop,0.8,1.2);
      // THE HEAD: a gunmetal sensor block forward of the shell, two mandible blades under it
      var hy=-13.5+drop;
      wc.fillStyle=INK; sprMP(x,y,fl,S,[11,hy-5.6,17.5,hy-5.6,20.4,hy-2.2,20.4,hy+3.2,11,hy+3.6]); wc.fill();
      wc.fillStyle='#3e454c'; sprMP(x,y,fl,S,[12,hy-4.6,17,hy-4.6,19.4,hy-1.8,19.4,hy+2.4,12,hy+2.6]); wc.fill();
      wc.fillStyle='#59626b'; sprMR(x,y,fl,S,12,hy-4.6,5,1.3);
      wc.fillStyle=INK;
      sprMP(x,y,fl,S,[16.5,hy+1.2,23.2,hy+1.6,24.2,hy+3.8,21.2,hy+3.2,16.5,hy+3.6]); wc.fill();
      sprMP(x,y,fl,S,[15.5,hy+3,21.6,hy+4.6,22,hy+6.8,19,hy+5.6,15.5,hy+5.4]); wc.fill();
      wc.fillStyle='#8d98a3'; sprMR(x,y,fl,S,17,hy+1.6,5.6,0.7); sprMR(x,y,fl,S,16.2,hy+3.4,4.6,0.7);
      // THREE EYES (four on an elite), each its own socket, the main one largest
      var EYES=brass?[[17,-1.3,2.1,1.5],[13.9,-2.4,1.5,1.0],[14.6,0.9,1.5,1.0],[18.2,1.3,1.2,0.8]]:[[17,-1.3,2.1,1.5],[13.9,-2.4,1.5,1.0],[14.6,0.9,1.5,1.0]];
      for(k=0;k<EYES.length;k++){
        var ex=x+fl*EYES[k][0]*S, ey=y+(hy+EYES[k][1])*S;
        wc.fillStyle=INK; wc.beginPath(); wc.arc(ex,ey,EYES[k][2]*S,0,6.2832); wc.fill();
      }
      if(!PIXM.baking){ wc.globalCompositeOperation='lighter'; wc.fillStyle=EY.c;
      if(EY.h>0){ wc.globalAlpha=0.30*EY.a; wc.beginPath(); wc.arc(x+fl*17*S,y+(hy-1.3)*S,1.5*EY.h*S*(hunting?(1+Math.sin(t*14)*0.15):1),0,6.2832); wc.fill(); }
      wc.globalAlpha=EY.a;
      for(k=0;k<EYES.length;k++){ wc.beginPath(); wc.arc(x+fl*EYES[k][0]*S,y+(hy+EYES[k][1])*S,EYES[k][3]*S,0,6.2832); wc.fill(); }
      wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else { wc.fillStyle=EY.c; wc.globalAlpha=EY.a; for(k=0;k<EYES.length;k++){ wc.beginPath(); wc.arc(x+fl*EYES[k][0]*S,y+(hy+EYES[k][1])*S,EYES[k][3]*S,0,6.2832); wc.fill(); } wc.globalAlpha=1; }
      wc.fillStyle='rgba(255,255,255,.8)'; wc.fillRect(x+fl*17*S-1.1*S,y+(hy-2.5)*S,0.7*S,0.7*S);
    }
  }
  wc.lineCap='butt'; wc.lineJoin='miter';
}
'@

SubRx @'
function drawSnitchS(e){
  // v23.xx (spr4), HIS ORDER (2026-10-12): "improve the sprites of all characters, bots, etc", gritty and grounded like ARC
  // Raiders, silhouettes first. The sprite program, MACHINES A, build 3: THE CRIER. It was a grey square tilted on its corner
  // and spinning like a sticker, with a bulb on top: it read as a picture frame or a die, nothing said drone and nothing said it
  // was about to shout. It is redrawn as a loudspeaker drone: an inked pod on an X frame with four rotor hubs, each rotor a pale
  // spinning blur (the blur spins, the body does not), a loudspeaker horn under the pod pointing where it faces with an ochre
  // ring at its mouth, and a lamp on top in the sensor language (dim white idle, red when it calls). The body tilts a little
  // into its facing instead of spinning. When it calls the ALARM the horn mouth glows red and the expanding ring and the
  // countdown arc come out of the horn; the ALARM word stays. An elite has a brass frame and a second lamp. Drawn only: no
  // random numbers, nothing written on the machine, the hover, its size and its shadow as before.
  var S=e.r/SNITCH_R0, fl=Math.cos(e.face)<0?-1:1, t=(typeof G!=='undefined'&&G)?(G.t||0):0;
  var al=e.state==='alarm', brass=!!e.elite, EY=sprEyeOf(e), i, k, a=fl*0.1;
  var hov=(17+Math.sin(t*6+e.x*.1)*4)*S;
  shadowE(e.x,e.y+1,8*S,3*S,.32);
  var cy=e.y-hov, ox=e.x, oy=cy-7*S;
  // where the horn mouth is in the world, for the alarm ring
  var hmx=ox+(fl*9.6*S)*Math.cos(a)-(4.6*S)*Math.sin(a), hmy=oy+(fl*9.6*S)*Math.sin(a)+(4.6*S)*Math.cos(a);
  // SPEC 8.3: visually distinctive at a distance so it can be identified and prioritised. A winding Crier throws an expanding
  // red alarm ring and a filling countdown arc from its horn, so from across the map you can see one is calling and how long
  // you have left to stop it.
  if(al&&e.wind!==undefined&&e.wind!==null){
    var wf=1-clamp(e.wind/4,0,1);
    wc.globalCompositeOperation='lighter';
    var pulse=(t*2)%1;
    wc.strokeStyle='rgba(255,59,48,'+(0.5*(1-pulse))+')'; wc.lineWidth=2.5*S;
    wc.beginPath(); wc.arc(hmx,hmy,(16+44*pulse)*S,0,6.2832); wc.stroke();
    wc.strokeStyle='#ff3b30'; wc.lineWidth=3*S;
    wc.beginPath(); wc.arc(hmx,hmy,22*S,-1.5708,-1.5708+6.2832*wf); wc.stroke();
    wc.globalCompositeOperation='source-over';
    wc.font=FS(TYPE.label); wc.textAlign='center';
    wc.fillStyle=INK; wc.fillText('ALARM',e.x+1,cy-30*S+1);
    wc.fillStyle='#ff5040'; wc.fillText('ALARM',e.x,cy-30*S);
    wc.textAlign='left';
  }
  wc.save(); wc.translate(ox,oy); wc.rotate(a); wc.scale(fl*S,S);
  var frame=brass?'#8a6a2a':'#2a2f35', frameHi=brass?'#c9a24a':'#59626b';
  // rotors: a hub and a spinning blur at each end of the X; the two at the back first
  var RH=[[-7.5,-4.6],[7.5,-4.6],[-10.5,0.6],[10.5,0.6]], spin=t*(al?38:24);
  function rotor(hx,hy,k2){
    var ph=spin+k2*1.7, bx=Math.cos(ph)*6, by=Math.sin(ph)*1.6;
    wc.globalCompositeOperation='lighter';
    wc.fillStyle=al?'rgba(255,140,110,.22)':'rgba(190,210,225,.25)';
    wc.beginPath(); wc.ellipse(hx,hy-2.2,6.4,1.9,0,0,6.2832); wc.fill();
    wc.strokeStyle=al?'rgba(255,170,150,.45)':'rgba(220,232,240,.45)'; wc.lineWidth=0.9;
    wc.beginPath(); wc.moveTo(hx-bx,hy-2.2-by); wc.lineTo(hx+bx,hy-2.2+by); wc.stroke();
    wc.globalCompositeOperation='source-over';
    wc.fillStyle=INK; wc.fillRect(hx-1.2,hy-2.6,2.4,2.8);
    wc.fillStyle=frameHi; wc.fillRect(hx-0.6,hy-2.6,1.2,0.9);
  }
  function arm(hx,hy){
    wc.strokeStyle=INK; wc.lineWidth=2.8; wc.beginPath(); wc.moveTo(0,0); wc.lineTo(hx,hy); wc.stroke();
    wc.strokeStyle=frame; wc.lineWidth=1.4; wc.beginPath(); wc.moveTo(0,0); wc.lineTo(hx,hy); wc.stroke();
  }
  wc.lineCap='round';
  for(k=0;k<2;k++){ arm(RH[k][0],RH[k][1]); rotor(RH[k][0],RH[k][1],k); }
  // THE HORN under the pod, flaring forward, an ochre ring at the mouth (red hot while it calls)
  wc.fillStyle=INK; wc.beginPath(); wc.moveTo(1.4,0.6); wc.lineTo(5.6,1.2); wc.lineTo(10.6,-0.6); wc.lineTo(10.6,9.8); wc.lineTo(5.6,7.6); wc.lineTo(1.4,7.2); wc.closePath(); wc.fill();
  wc.fillStyle='#3e454c'; wc.beginPath(); wc.moveTo(2.4,1.8); wc.lineTo(5.8,2.2); wc.lineTo(9.6,0.6); wc.lineTo(9.6,8.6); wc.lineTo(5.8,6.6); wc.lineTo(2.4,6.2); wc.closePath(); wc.fill();
  wc.fillStyle='#59626b'; wc.beginPath(); wc.moveTo(2.4,1.8); wc.lineTo(5.8,2.2); wc.lineTo(9.6,0.6); wc.lineTo(9.6,2.0); wc.lineTo(5.8,3.3); wc.lineTo(2.4,3.0); wc.closePath(); wc.fill();
  wc.fillStyle='#c8962e'; wc.beginPath(); wc.ellipse(9.8,4.6,1.6,5,0,0,6.2832); wc.fill();
  wc.fillStyle=al?'#ff3b30':'#1b1f24'; wc.beginPath(); wc.ellipse(10.0,4.6,0.9,3.8,0,0,6.2832); wc.fill();
  if(al){ wc.globalCompositeOperation='lighter'; wc.fillStyle='rgba(255,59,48,'+(0.35+0.25*Math.sin(t*16)).toFixed(3)+')';
    wc.beginPath(); wc.ellipse(10.6,4.6,3.2,6.2,0,0,6.2832); wc.fill(); wc.globalCompositeOperation='source-over'; }
  // THE POD: inked, machine grey, a lit top, a shaded belly, one seam and two rivets
  wc.fillStyle=INK; rrF(-8.2,-6.2,16.4,11.6,3.6);
  wc.fillStyle='#3e454c'; rrF(-7,-5,14,9.2,2.8);
  wc.fillStyle='#59626b'; rrF(-7,-5,14,7,2.8);
  wc.fillStyle='#7c868f'; rrF(-7,-5,14,2.2,1.8);
  wc.fillStyle='#2a2f35'; wc.fillRect(-1.6,-2.4,0.8,6.6); wc.fillRect(-4.6,2.4,1,1); wc.fillRect(2.8,2.4,1,1);
  wc.fillStyle='#c8962e'; wc.fillRect(1,-0.6,4,1.2);
  // the front arms and rotors over the pod
  for(k=2;k<4;k++){ arm(RH[k][0],RH[k][1]); rotor(RH[k][0],RH[k][1],k); }
  // THE LAMP on top in the sensor language, blinking while it calls; an elite carries a second
  var LP=brass?[[0,-6.6],[-3.8,-6.2]]:[[0,-6.6]];
  for(k=0;k<LP.length;k++){ wc.fillStyle=INK; wc.beginPath(); wc.arc(LP[k][0],LP[k][1],2.2,0,6.2832); wc.fill(); }
  var la=EY.a*(al?((Math.sin(t*16)>0)?1:0.35):1);
  wc.globalCompositeOperation='lighter'; wc.fillStyle=EY.c;
  if(EY.h>0){ wc.globalAlpha=0.30*la; wc.beginPath(); wc.arc(LP[0][0],LP[0][1],1.5*EY.h,0,6.2832); wc.fill(); }
  wc.globalAlpha=la;
  for(k=0;k<LP.length;k++){ wc.beginPath(); wc.arc(LP[k][0],LP[k][1],1.5,0,6.2832); wc.fill(); }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  wc.restore();
}
'@ @'
function drawSnitchS(e){
  if(pixOn()&&!PIXM.paint&&pixMachDraw(e,drawSnitchS)) return; // v28.xx (cw-cx-pixmachines): the body is cached at PIX_ACT, including job 80 size
  // v23.xx (spr4), HIS ORDER (2026-10-12): "improve the sprites of all characters, bots, etc", gritty and grounded like ARC
  // Raiders, silhouettes first. The sprite program, MACHINES A, build 3: THE CRIER. It was a grey square tilted on its corner
  // and spinning like a sticker, with a bulb on top: it read as a picture frame or a die, nothing said drone and nothing said it
  // was about to shout. It is redrawn as a loudspeaker drone: an inked pod on an X frame with four rotor hubs, each rotor a pale
  // spinning blur (the blur spins, the body does not), a loudspeaker horn under the pod pointing where it faces with an ochre
  // ring at its mouth, and a lamp on top in the sensor language (dim white idle, red when it calls). The body tilts a little
  // into its facing instead of spinning. When it calls the ALARM the horn mouth glows red and the expanding ring and the
  // countdown arc come out of the horn; the ALARM word stays. An elite has a brass frame and a second lamp. Drawn only: no
  // random numbers, nothing written on the machine, the hover, its size and its shadow as before.
  var S=e.r/SNITCH_R0, fl=Math.cos(e.face)<0?-1:1, t=(typeof G!=='undefined'&&G)?(pixMachTime()||0):0;
  var al=e.state==='alarm', brass=!!e.elite, EY=sprEyeOf(e), i, k, a=fl*0.1;
  var hov=(17+Math.sin(t*6+e.x*.1)*4)*S;
  shadowE(e.x,e.y+1,8*S,3*S,.32);
  var cy=e.y-hov, ox=e.x, oy=cy-7*S;
  // where the horn mouth is in the world, for the alarm ring
  var hmx=ox+(fl*9.6*S)*Math.cos(a)-(4.6*S)*Math.sin(a), hmy=oy+(fl*9.6*S)*Math.sin(a)+(4.6*S)*Math.cos(a);
  // SPEC 8.3: visually distinctive at a distance so it can be identified and prioritised. A winding Crier throws an expanding
  // red alarm ring and a filling countdown arc from its horn, so from across the map you can see one is calling and how long
  // you have left to stop it.
  if(al&&!PIXM.baking&&e.wind!==undefined&&e.wind!==null){
    var wf=1-clamp(e.wind/4,0,1);
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
    var pulse=(t*2)%1;
    wc.strokeStyle='rgba(255,59,48,'+(0.5*(1-pulse))+')'; wc.lineWidth=2.5*S;
    wc.beginPath(); wc.arc(hmx,hmy,(16+44*pulse)*S,0,6.2832); wc.stroke();
    wc.strokeStyle='#ff3b30'; wc.lineWidth=3*S;
    wc.beginPath(); wc.arc(hmx,hmy,22*S,-1.5708,-1.5708+6.2832*wf); wc.stroke();
    wc.globalCompositeOperation='source-over'; } else {  }
    wc.font=FS(TYPE.label); wc.textAlign='center';
    if(pixOn()) pixMachAlarm(e); else { wc.fillStyle=INK; wc.fillText('ALARM',e.x+1,cy-30*S+1);
    wc.fillStyle='#ff5040'; wc.fillText('ALARM',e.x,cy-30*S); }
    wc.textAlign='left';
  }
  wc.save(); wc.translate(ox,oy); wc.rotate(a); wc.scale(fl*S,S);
  var frame=brass?'#8a6a2a':'#2a2f35', frameHi=brass?'#c9a24a':'#59626b';
  // rotors: a hub and a spinning blur at each end of the X; the two at the back first
  var RH=[[-7.5,-4.6],[7.5,-4.6],[-10.5,0.6],[10.5,0.6]], spin=t*(al?38:24);
  function rotor(hx,hy,k2){
    var ph=spin+k2*1.7, bx=Math.cos(ph)*6, by=Math.sin(ph)*1.6;
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
    wc.fillStyle=al?'rgba(255,140,110,.22)':'rgba(190,210,225,.25)';
    wc.beginPath(); wc.ellipse(hx,hy-2.2,6.4,1.9,0,0,6.2832); wc.fill();
    wc.strokeStyle=al?'rgba(255,170,150,.45)':'rgba(220,232,240,.45)'; wc.lineWidth=0.9;
    wc.beginPath(); wc.moveTo(hx-bx,hy-2.2-by); wc.lineTo(hx+bx,hy-2.2+by); wc.stroke();
    wc.globalCompositeOperation='source-over'; } else {  }
    wc.fillStyle=INK; wc.fillRect(hx-1.2,hy-2.6,2.4,2.8);
    wc.fillStyle=frameHi; wc.fillRect(hx-0.6,hy-2.6,1.2,0.9);
  }
  function arm(hx,hy){
    wc.strokeStyle=INK; wc.lineWidth=2.8; wc.beginPath(); wc.moveTo(0,0); wc.lineTo(hx,hy); wc.stroke();
    wc.strokeStyle=frame; wc.lineWidth=1.4; wc.beginPath(); wc.moveTo(0,0); wc.lineTo(hx,hy); wc.stroke();
  }
  wc.lineCap='round';
  for(k=0;k<2;k++){ arm(RH[k][0],RH[k][1]); rotor(RH[k][0],RH[k][1],k); }
  // THE HORN under the pod, flaring forward, an ochre ring at the mouth (red hot while it calls)
  wc.fillStyle=INK; wc.beginPath(); wc.moveTo(1.4,0.6); wc.lineTo(5.6,1.2); wc.lineTo(10.6,-0.6); wc.lineTo(10.6,9.8); wc.lineTo(5.6,7.6); wc.lineTo(1.4,7.2); wc.closePath(); wc.fill();
  wc.fillStyle='#3e454c'; wc.beginPath(); wc.moveTo(2.4,1.8); wc.lineTo(5.8,2.2); wc.lineTo(9.6,0.6); wc.lineTo(9.6,8.6); wc.lineTo(5.8,6.6); wc.lineTo(2.4,6.2); wc.closePath(); wc.fill();
  wc.fillStyle='#59626b'; wc.beginPath(); wc.moveTo(2.4,1.8); wc.lineTo(5.8,2.2); wc.lineTo(9.6,0.6); wc.lineTo(9.6,2.0); wc.lineTo(5.8,3.3); wc.lineTo(2.4,3.0); wc.closePath(); wc.fill();
  wc.fillStyle='#c8962e'; wc.beginPath(); wc.ellipse(9.8,4.6,1.6,5,0,0,6.2832); wc.fill();
  wc.fillStyle=al?'#ff3b30':'#1b1f24'; wc.beginPath(); wc.ellipse(10.0,4.6,0.9,3.8,0,0,6.2832); wc.fill();
  if(al){ if(!PIXM.baking){ wc.globalCompositeOperation='lighter'; wc.fillStyle='rgba(255,59,48,'+(0.35+0.25*Math.sin(t*16)).toFixed(3)+')';
    wc.beginPath(); wc.ellipse(10.6,4.6,3.2,6.2,0,0,6.2832); wc.fill(); wc.globalCompositeOperation='source-over'; } else {  } }
  // THE POD: inked, machine grey, a lit top, a shaded belly, one seam and two rivets
  wc.fillStyle=INK; rrF(-8.2,-6.2,16.4,11.6,3.6);
  wc.fillStyle='#3e454c'; rrF(-7,-5,14,9.2,2.8);
  wc.fillStyle='#59626b'; rrF(-7,-5,14,7,2.8);
  wc.fillStyle='#7c868f'; rrF(-7,-5,14,2.2,1.8);
  wc.fillStyle='#2a2f35'; wc.fillRect(-1.6,-2.4,0.8,6.6); wc.fillRect(-4.6,2.4,1,1); wc.fillRect(2.8,2.4,1,1);
  wc.fillStyle='#c8962e'; wc.fillRect(1,-0.6,4,1.2);
  // the front arms and rotors over the pod
  for(k=2;k<4;k++){ arm(RH[k][0],RH[k][1]); rotor(RH[k][0],RH[k][1],k); }
  // THE LAMP on top in the sensor language, blinking while it calls; an elite carries a second
  var LP=brass?[[0,-6.6],[-3.8,-6.2]]:[[0,-6.6]];
  for(k=0;k<LP.length;k++){ wc.fillStyle=INK; wc.beginPath(); wc.arc(LP[k][0],LP[k][1],2.2,0,6.2832); wc.fill(); }
  var la=EY.a*(al?((Math.sin(t*16)>0)?1:0.35):1);
  if(!PIXM.baking){ wc.globalCompositeOperation='lighter'; wc.fillStyle=EY.c;
  if(EY.h>0){ wc.globalAlpha=0.30*la; wc.beginPath(); wc.arc(LP[0][0],LP[0][1],1.5*EY.h,0,6.2832); wc.fill(); }
  wc.globalAlpha=la;
  for(k=0;k<LP.length;k++){ wc.beginPath(); wc.arc(LP[k][0],LP[k][1],1.5,0,6.2832); wc.fill(); }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else { wc.fillStyle=EY.c; wc.globalAlpha=EY.a; for(k=0;k<LP.length;k++){ wc.beginPath(); wc.arc(LP[k][0],LP[k][1],1.5,0,6.2832); wc.fill(); } wc.globalAlpha=1; }
  wc.restore();
}
'@

SubRx @'
function drawListenerS(e){
  // Nothing else on this map is this shape. Tall, thin, no face, arms too long,
  // and a wide dish where a head should be. Dormant it is nearly black and
  // hunched, so at a glance it is a bit of standing scrap; awake it straightens
  // up, which is the moment you are meant to feel.
  var dorm=(e.state==='dormant'),wk=dorm?0:1;
  var h=dorm?26:40, sway=Math.sin(e.legs*0.6)*(dorm?0.6:2.2);
  shadowE(e.x,e.y+1,10,4,.40);
  var body=dorm?'#1d2028':'#3b4250', edge=dorm?'#2a2f38':'#5d6878';
  // legs
  wc.fillStyle=INK;
  rrF(e.x-5.5,e.y-h*0.46,4.6,h*0.46,1.6);
  rrF(e.x+1.1,e.y-h*0.46,4.6,h*0.46,1.6);
  wc.fillStyle=body;
  rrF(e.x-4.9,e.y-h*0.44,3.4,h*0.43,1.2);
  rrF(e.x+1.6,e.y-h*0.44,3.4,h*0.43,1.2);
  // torso, narrow
  wc.fillStyle=INK; rrF(e.x-5.6+sway*.3,e.y-h,11.2,h*0.58,3);
  wc.fillStyle=body; rrF(e.x-4.8+sway*.3,e.y-h+0.8,9.6,h*0.56,2.6);
  wc.fillStyle=edge; wc.fillRect(e.x-4.4+sway*.3,e.y-h+1,8.8,1.8);
  // long arms
  wc.fillStyle=INK;
  rrF(e.x-8.6+sway,e.y-h+2,3.4,h*0.62,1.4);
  rrF(e.x+5.2+sway,e.y-h+2,3.4,h*0.62,1.4);
  wc.fillStyle=body;
  rrF(e.x-8.1+sway,e.y-h+2.6,2.4,h*0.58,1.1);
  rrF(e.x+5.7+sway,e.y-h+2.6,2.4,h*0.58,1.1);
  // the dish. No eyes: it is not looking at you.
  var hy=e.y-h-(dorm?2:7);
  wc.fillStyle=INK;
  wc.beginPath(); wc.ellipse(e.x+sway*1.2,hy,9.4,6.2,0,0,6.2832); wc.fill();
  wc.fillStyle=dorm?'#242833':'#4a5364';
  wc.beginPath(); wc.ellipse(e.x+sway*1.2,hy,8.2,5.2,0,0,6.2832); wc.fill();
  wc.fillStyle=dorm?'#1a1d25':'#2b3240';
  wc.beginPath(); wc.ellipse(e.x+sway*1.2,hy+0.6,5.2,3.2,0,0,6.2832); wc.fill();
  if(!dorm){
    var pl=0.55+0.45*Math.sin((G?G.t:0)*7);
    wc.save(); wc.globalCompositeOperation='lighter'; wc.globalAlpha=0.5*pl;
    var lg=wc.createRadialGradient(e.x+sway*1.2,hy,1,e.x+sway*1.2,hy,26);
    lg.addColorStop(0,'#ff5a4a'); lg.addColorStop(1,'rgba(0,0,0,0)');
    wc.fillStyle=lg; wc.beginPath(); wc.arc(e.x+sway*1.2,hy,26,0,6.2832); wc.fill();
    wc.restore();
    wc.fillStyle='#ff5a4a';
    wc.fillRect(e.x-1.4+sway*1.2,hy-1.2,2.8,2.4);
  }
}
'@ @'
function drawListenerS(e){
  if(pixOn()&&!PIXM.paint&&pixMachDraw(e,drawListenerS)) return; // v28.xx (cw-cx-pixmachines): the body is cached at PIX_ACT, including job 80 size
  // Nothing else on this map is this shape. Tall, thin, no face, arms too long,
  // and a wide dish where a head should be. Dormant it is nearly black and
  // hunched, so at a glance it is a bit of standing scrap; awake it straightens
  // up, which is the moment you are meant to feel.
  var dorm=(e.state==='dormant'),wk=dorm?0:1;
  var h=dorm?26:40, sway=Math.sin(e.legs*0.6)*(dorm?0.6:2.2);
  shadowE(e.x,e.y+1,10,4,.40);
  var body=dorm?'#1d2028':'#3b4250', edge=dorm?'#2a2f38':'#5d6878';
  // legs
  wc.fillStyle=INK;
  rrF(e.x-5.5,e.y-h*0.46,4.6,h*0.46,1.6);
  rrF(e.x+1.1,e.y-h*0.46,4.6,h*0.46,1.6);
  wc.fillStyle=body;
  rrF(e.x-4.9,e.y-h*0.44,3.4,h*0.43,1.2);
  rrF(e.x+1.6,e.y-h*0.44,3.4,h*0.43,1.2);
  // torso, narrow
  wc.fillStyle=INK; rrF(e.x-5.6+sway*.3,e.y-h,11.2,h*0.58,3);
  wc.fillStyle=body; rrF(e.x-4.8+sway*.3,e.y-h+0.8,9.6,h*0.56,2.6);
  wc.fillStyle=edge; wc.fillRect(e.x-4.4+sway*.3,e.y-h+1,8.8,1.8);
  // long arms
  wc.fillStyle=INK;
  rrF(e.x-8.6+sway,e.y-h+2,3.4,h*0.62,1.4);
  rrF(e.x+5.2+sway,e.y-h+2,3.4,h*0.62,1.4);
  wc.fillStyle=body;
  rrF(e.x-8.1+sway,e.y-h+2.6,2.4,h*0.58,1.1);
  rrF(e.x+5.7+sway,e.y-h+2.6,2.4,h*0.58,1.1);
  // the dish. No eyes: it is not looking at you.
  var hy=e.y-h-(dorm?2:7);
  wc.fillStyle=INK;
  wc.beginPath(); wc.ellipse(e.x+sway*1.2,hy,9.4,6.2,0,0,6.2832); wc.fill();
  wc.fillStyle=dorm?'#242833':'#4a5364';
  wc.beginPath(); wc.ellipse(e.x+sway*1.2,hy,8.2,5.2,0,0,6.2832); wc.fill();
  wc.fillStyle=dorm?'#1a1d25':'#2b3240';
  wc.beginPath(); wc.ellipse(e.x+sway*1.2,hy+0.6,5.2,3.2,0,0,6.2832); wc.fill();
  if(!dorm){
    var pl=0.55+0.45*Math.sin((G?pixMachTime():0)*7);
if(!PIXM.baking){     wc.save(); wc.globalCompositeOperation='lighter'; wc.globalAlpha=0.5*pl;
    if(pixOn()){ pixMachListenerGlow(e.x+sway*1.2,hy,1); } else {
    var lg=wc.createRadialGradient(e.x+sway*1.2,hy,1,e.x+sway*1.2,hy,26);
    lg.addColorStop(0,'#ff5a4a'); lg.addColorStop(1,'rgba(0,0,0,0)');
    wc.fillStyle=lg; wc.beginPath(); wc.arc(e.x+sway*1.2,hy,26,0,6.2832); wc.fill();
    }
    wc.restore(); }
    wc.fillStyle='#ff5a4a';
    wc.fillRect(e.x-1.4+sway*1.2,hy-1.2,2.8,2.4);
  }
}
'@

SubRx @'
function drawBulwarkS(e){
  // v23.xx (spr11), HIS ORDER (2026-10-12) on the sprite program: THE BULWARK REDESIGN (MACHINES B 3). The slab was light
  // blue-grey, the same steel as human armour, the body behind it a dark lozenge with a blinking dot on two pebbles, and the
  // slab hung below its own shadow. Now a squat walker on two stompy feet that step as it moves, a hunched gunmetal body set
  // back behind the slab with one sensor eye on top (the sensor language: dim white, amber, red, orange), and the slab in dark
  // gunmetal with rust edge trim, an ochre-and-black chevron band along its top, three rivets and a viewing slit lit in the
  // eye colour. The slab still turns to its facing (band up whichever side it faces), pivots higher so its foot stands on the ground inside the shadow. Elite:
  // a brass slab edge. Drawn only: the radius, the shield arc and the weak point are unchanged.
  var P=MBPAL,x=e.x,y=e.y,st=(e.step||0),el=!!e.elite,E=mbEye(e,G.t),i;
  var bx=x-Math.cos(e.face)*3, lf=Math.max(0,Math.sin(st*2.2))*2, rf=Math.max(0,-Math.sin(st*2.2))*2;
  shadowE(x,y+2,e.r*.95,4,.36);
  // FEET and short legs
  wc.fillStyle=P.gm[0]; wc.fillRect(bx-10,y-9-lf,4,8); wc.fillRect(bx+6,y-9-rf,4,8);
  wc.fillStyle=P.ink; rrF(bx-14,y-2-lf,9.6,6.4,2); rrF(bx+4.4,y-2-rf,9.6,6.4,2);
  wc.fillStyle=P.gm[1]; rrF(bx-13,y-1-lf,7.6,4.4,1.5); rrF(bx+5.4,y-1-rf,7.6,4.4,1.5);
  wc.fillStyle=P.gm[3]; wc.fillRect(bx-12.4,y-1-lf,6.4,1.1); wc.fillRect(bx+6,y-1-rf,6.4,1.1);
  // THE BODY: hunched, set back behind the slab, rust plate on its back, grime low
  wc.fillStyle=P.ink; rrF(bx-14.6,y-31,29.2,25,7);
  wc.fillStyle=P.gm[2]; rrF(bx-13.4,y-29.8,26.8,22.6,6);
  wc.fillStyle=P.gm[3]; rrF(bx-11.4,y-29.8,22.8,4.6,3);
  wc.fillStyle=P.gm[1]; wc.fillRect(bx-13.4,y-14,26.8,1);
  wc.fillStyle=P.grime; rrF(bx-13.4,y-12,26.8,4.8,3);
  wc.fillStyle=P.ox[1]; rrF(bx-12,y-24.6,9,9,1.6);
  wc.fillStyle=P.ox[2]; wc.fillRect(bx-12,y-24.6,9,1.1);
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.rect(bx-10.6,y-17.4,1.2,1.2); wc.rect(bx-5.2,y-17.4,1.2,1.2); wc.rect(bx+8,y-21,1.2,1.2); wc.fill();
  // THE HEAD: a sensor dome on top, its eye toward the facing
  var ex=bx+Math.cos(e.face)*3.4;
  wc.fillStyle=P.ink; rrF(bx-6.6,y-37.6,13.2,9.6,4);
  wc.fillStyle=P.gm[1]; rrF(bx-5.4,y-36.4,10.8,7.2,3);
  wc.fillStyle=P.gm[3]; wc.fillRect(bx-4,y-36.4,8,1.2);
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(ex,y-32.4,2.8,0,6.2832); wc.fill();
  wc.globalCompositeOperation='lighter'; wc.fillStyle=E[0]; wc.globalAlpha=E[1];
  wc.beginPath(); wc.arc(ex,y-32.4,1.9,0,6.2832); wc.fill();
  if(E[2]){ wc.globalAlpha=E[2]>1?.22:.15; wc.beginPath(); wc.arc(ex,y-32.4,4.2,0,6.2832); wc.fill(); }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  if(e.hitT>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,70,56,'+clamp(e.hitT*2,0,.7)+')';
    rrF(bx-13.4,y-29.8,26.8,22.6,6);
    wc.globalCompositeOperation='source-over';
  }
  // THE SLAB: turned to its facing, pivoting high so its foot stands on the ground
  wc.save(); wc.translate(x,y-18); wc.rotate(e.face); if(Math.cos(e.face)<-0.01) wc.scale(1,-1);
  wc.fillStyle=P.ink; rrF(7,-24,17,47.4,3);
  wc.fillStyle=P.gm[1]; rrF(8.2,-22.8,14.6,45,2.4);
  wc.fillStyle=P.gm[0]; wc.fillRect(19.6,-17.6,3.2,39.4);
  wc.fillStyle=P.ox[1]; wc.fillRect(8.2,-17.6,1.6,39.6); wc.fillRect(18.4,-17.6,1.4,39.6);
  wc.fillStyle=P.och; rrF(8.2,-22.8,14.6,5.2,2.4);
  wc.fillStyle=P.ink; wc.beginPath();
  for(i=0;i<3;i++){ wc.moveTo(9.6+i*4.8,-17.6); wc.lineTo(12.2+i*4.8,-17.6); wc.lineTo(14.8+i*4.8,-22.8); wc.lineTo(12.2+i*4.8,-22.8); wc.closePath(); }
  wc.fill();
  wc.fillStyle=P.ink; rrF(9.6,-13.6,11.8,3,1.2);
  wc.globalCompositeOperation='lighter'; wc.fillStyle=E[0]; wc.globalAlpha=E[1]*.9;
  wc.fillRect(10.6,-12.8,9.8,1.4);
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.arc(14.4,-2,1.5,0,6.2832); wc.moveTo(15.9,8); wc.arc(14.4,8,1.5,0,6.2832); wc.moveTo(15.9,17); wc.arc(14.4,17,1.5,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[3]; wc.beginPath(); wc.rect(13.8,-3.6,1,0.8); wc.rect(13.8,6.4,1,0.8); wc.rect(13.8,15.4,1,0.8); wc.fill();
  wc.fillStyle=P.steel; wc.beginPath(); wc.rect(8.4,-8,1.2,1.6); wc.rect(21.6,4,1,1.8); wc.rect(10,21,2,0.8); wc.fill();
  if(el){ wc.strokeStyle=P.brass[1]; wc.lineWidth=1; wc.strokeRect(8.2,-22.8,14.6,45); }
  wc.restore();
}
'@ @'
function drawBulwarkS(e){
  if(pixOn()&&!PIXM.paint&&pixMachDraw(e,drawBulwarkS)) return; // v28.xx (cw-cx-pixmachines): the body is cached at PIX_ACT, including job 80 size
  // v23.xx (spr11), HIS ORDER (2026-10-12) on the sprite program: THE BULWARK REDESIGN (MACHINES B 3). The slab was light
  // blue-grey, the same steel as human armour, the body behind it a dark lozenge with a blinking dot on two pebbles, and the
  // slab hung below its own shadow. Now a squat walker on two stompy feet that step as it moves, a hunched gunmetal body set
  // back behind the slab with one sensor eye on top (the sensor language: dim white, amber, red, orange), and the slab in dark
  // gunmetal with rust edge trim, an ochre-and-black chevron band along its top, three rivets and a viewing slit lit in the
  // eye colour. The slab still turns to its facing (band up whichever side it faces), pivots higher so its foot stands on the ground inside the shadow. Elite:
  // a brass slab edge. Drawn only: the radius, the shield arc and the weak point are unchanged.
  var P=MBPAL,x=e.x,y=e.y,st=(e.step||0),el=!!e.elite,E=mbEye(e,pixMachTime()),i;
  var bx=x-Math.cos(e.face)*3, lf=Math.max(0,Math.sin(st*2.2))*2, rf=Math.max(0,-Math.sin(st*2.2))*2;
  shadowE(x,y+2,e.r*.95,4,.36);
  // FEET and short legs
  wc.fillStyle=P.gm[0]; wc.fillRect(bx-10,y-9-lf,4,8); wc.fillRect(bx+6,y-9-rf,4,8);
  wc.fillStyle=P.ink; rrF(bx-14,y-2-lf,9.6,6.4,2); rrF(bx+4.4,y-2-rf,9.6,6.4,2);
  wc.fillStyle=P.gm[1]; rrF(bx-13,y-1-lf,7.6,4.4,1.5); rrF(bx+5.4,y-1-rf,7.6,4.4,1.5);
  wc.fillStyle=P.gm[3]; wc.fillRect(bx-12.4,y-1-lf,6.4,1.1); wc.fillRect(bx+6,y-1-rf,6.4,1.1);
  // THE BODY: hunched, set back behind the slab, rust plate on its back, grime low
  wc.fillStyle=P.ink; rrF(bx-14.6,y-31,29.2,25,7);
  wc.fillStyle=P.gm[2]; rrF(bx-13.4,y-29.8,26.8,22.6,6);
  wc.fillStyle=P.gm[3]; rrF(bx-11.4,y-29.8,22.8,4.6,3);
  wc.fillStyle=P.gm[1]; wc.fillRect(bx-13.4,y-14,26.8,1);
  wc.fillStyle=P.grime; rrF(bx-13.4,y-12,26.8,4.8,3);
  wc.fillStyle=P.ox[1]; rrF(bx-12,y-24.6,9,9,1.6);
  wc.fillStyle=P.ox[2]; wc.fillRect(bx-12,y-24.6,9,1.1);
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.rect(bx-10.6,y-17.4,1.2,1.2); wc.rect(bx-5.2,y-17.4,1.2,1.2); wc.rect(bx+8,y-21,1.2,1.2); wc.fill();
  // THE HEAD: a sensor dome on top, its eye toward the facing
  var ex=bx+Math.cos(e.face)*3.4;
  wc.fillStyle=P.ink; rrF(bx-6.6,y-37.6,13.2,9.6,4);
  wc.fillStyle=P.gm[1]; rrF(bx-5.4,y-36.4,10.8,7.2,3);
  wc.fillStyle=P.gm[3]; wc.fillRect(bx-4,y-36.4,8,1.2);
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(ex,y-32.4,2.8,0,6.2832); wc.fill();
  if(!PIXM.baking){ wc.globalCompositeOperation='lighter'; wc.fillStyle=E[0]; wc.globalAlpha=E[1];
  wc.beginPath(); wc.arc(ex,y-32.4,1.9,0,6.2832); wc.fill();
  if(E[2]){ wc.globalAlpha=E[2]>1?.22:.15; wc.beginPath(); wc.arc(ex,y-32.4,4.2,0,6.2832); wc.fill(); }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else { wc.fillStyle=E[0]; wc.globalAlpha=E[1]; wc.beginPath(); wc.arc(ex,y-32.4,1.9,0,6.2832); wc.fill(); wc.globalAlpha=1; }
  if(e.hitT>0){
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,70,56,'+clamp(e.hitT*2,0,.7)+')';
    rrF(bx-13.4,y-29.8,26.8,22.6,6);
    wc.globalCompositeOperation='source-over'; } else {  }
  }
  // THE SLAB: turned to its facing, pivoting high so its foot stands on the ground
  wc.save(); wc.translate(x,y-18); wc.rotate(e.face); if(Math.cos(e.face)<-0.01) wc.scale(1,-1);
  wc.fillStyle=P.ink; rrF(7,-24,17,47.4,3);
  wc.fillStyle=P.gm[1]; rrF(8.2,-22.8,14.6,45,2.4);
  wc.fillStyle=P.gm[0]; wc.fillRect(19.6,-17.6,3.2,39.4);
  wc.fillStyle=P.ox[1]; wc.fillRect(8.2,-17.6,1.6,39.6); wc.fillRect(18.4,-17.6,1.4,39.6);
  wc.fillStyle=P.och; rrF(8.2,-22.8,14.6,5.2,2.4);
  wc.fillStyle=P.ink; wc.beginPath();
  for(i=0;i<3;i++){ wc.moveTo(9.6+i*4.8,-17.6); wc.lineTo(12.2+i*4.8,-17.6); wc.lineTo(14.8+i*4.8,-22.8); wc.lineTo(12.2+i*4.8,-22.8); wc.closePath(); }
  wc.fill();
  wc.fillStyle=P.ink; rrF(9.6,-13.6,11.8,3,1.2);
  if(!PIXM.baking){ wc.globalCompositeOperation='lighter'; wc.fillStyle=E[0]; wc.globalAlpha=E[1]*.9;
  wc.fillRect(10.6,-12.8,9.8,1.4);
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else { wc.fillStyle=E[0]; wc.globalAlpha=E[1]*.9; wc.fillRect(10.6,-12.8,9.8,1.4); wc.globalAlpha=1; }
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.arc(14.4,-2,1.5,0,6.2832); wc.moveTo(15.9,8); wc.arc(14.4,8,1.5,0,6.2832); wc.moveTo(15.9,17); wc.arc(14.4,17,1.5,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[3]; wc.beginPath(); wc.rect(13.8,-3.6,1,0.8); wc.rect(13.8,6.4,1,0.8); wc.rect(13.8,15.4,1,0.8); wc.fill();
  wc.fillStyle=P.steel; wc.beginPath(); wc.rect(8.4,-8,1.2,1.6); wc.rect(21.6,4,1,1.8); wc.rect(10,21,2,0.8); wc.fill();
  if(el){ wc.strokeStyle=P.brass[1]; wc.lineWidth=1; wc.strokeRect(8.2,-22.8,14.6,45); }
  wc.restore();
}
'@

SubRx @'
function drawHowlerS(e){
  // v23.xx (spr12), HIS ORDER (2026-10-12) on the sprite program: THE HOWLER REDESIGN (MACHINES B 4). It was a black lunchbox
  // with a tube stuck in it at a fixed angle, the lowest contrast in the cast (gone on a dark floor), and the mortar never
  // pointed at what it was shooting. Now a mortar walker: four short splayed legs that step as it moves, a hull under a round
  // turret ring (the lightest thing on it, so it reads on a dark floor), a FAT tube with an ochre muzzle ring raised at its
  // firing elevation and leaning toward its facing (shorter when it faces you, longer when it faces away), an ammo drum on
  // the off side and a spotting lamp in the sensor language. Elite: a brass muzzle ring. Drawn only: radius and fight unchanged.
  var P=MBPAL,x=e.x,y=e.y,st=(e.step||0),el=!!e.elite,E=mbEye(e,G.t),fl=Math.cos(e.face)>=0?1:-1,i,s,lx,lift;
  shadowE(x,y+2,e.r*.9,4,.35);
  // LEGS: two back, then the hull, then two front; opposite corners step together
  function leg(hx,hy,fx,fy,up){ wc.strokeStyle=P.ink; wc.lineWidth=4.6; wc.beginPath(); wc.moveTo(x+hx,y+hy); wc.lineTo(x+(hx+fx)/2+(fx>hx?1.5:-1.5),y+hy-3-up); wc.lineTo(x+fx,y+fy-up); wc.stroke();
    wc.strokeStyle=P.gm[1]; wc.lineWidth=2.6; wc.stroke();
    wc.fillStyle=P.ink; rrF(x+fx-3.4,y+fy-1.6-up,6.8,3.8,1.4); wc.fillStyle=P.gm[2]; wc.fillRect(x+fx-2.4,y+fy-0.8-up,4.8,1.2); }
  lift=Math.max(0,Math.sin(st*2.4))*2; s=Math.max(0,-Math.sin(st*2.4))*2;
  wc.lineCap='round'; wc.lineJoin='round';
  leg(-7,-12,-15,-5,s); leg(7,-12,15,-5,lift);
  // THE HULL
  wc.fillStyle=P.ink; rrF(x-14,y-19,28,15,5);
  wc.fillStyle=P.gm[1]; rrF(x-12.8,y-17.8,25.6,12.6,4);
  wc.fillStyle=P.grime; rrF(x-12.8,y-9.6,25.6,4.4,3);
  wc.fillStyle=P.ox[1]; wc.fillRect(x-12.8,y-12.6,25.6,1.6);
  leg(-8,-8,-17,3,lift); leg(8,-8,17,3,s);
  wc.lineCap='butt'; wc.lineJoin='miter';
  // AMMO DRUM on the off side
  lx=x-fl*13.4;
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(lx,y-15,6,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[1]; wc.beginPath(); wc.arc(lx,y-15,4.8,0,6.2832); wc.fill();
  wc.fillStyle=P.ox[1]; wc.fillRect(lx-4.8,y-16,9.6,2);
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.arc(lx,y-15,1.6,0,6.2832); wc.fill();
  // THE TURRET RING: lit top, shaded band
  wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(x,y-21,13.4,7.4,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[2]; wc.beginPath(); wc.ellipse(x,y-20,12.2,6,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[3]; wc.beginPath(); wc.ellipse(x,y-22,12.2,4.8,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.rect(x-9.6,y-22.4,1.2,1.2); wc.rect(x+8.4,y-22.4,1.2,1.2); wc.rect(x-0.6,y-25.6,1.2,1.2); wc.fill();
  // SPOTTING LAMP on the turret front
  var sx=x+fl*8.6;
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(sx,y-19.4,2.7,0,6.2832); wc.fill();
  wc.globalCompositeOperation='lighter'; wc.fillStyle=E[0]; wc.globalAlpha=E[1];
  wc.beginPath(); wc.arc(sx,y-19.4,1.8,0,6.2832); wc.fill();
  if(E[2]){ wc.globalAlpha=E[2]>1?.22:.15; wc.beginPath(); wc.arc(sx,y-19.4,4,0,6.2832); wc.fill(); }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  // THE TUBE: raised, leaning toward the facing, foreshortened when it faces you
  var Lt=15.5-Math.sin(e.face)*4;
  wc.save(); wc.translate(x,y-22); wc.rotate(Math.cos(e.face)*0.62);
  wc.fillStyle=P.ink; rrF(-6,-4.4,12,7.4,2.4);
  wc.fillStyle=P.gm[1]; rrF(-4.8,-3.4,9.6,5.4,1.8);
  wc.fillStyle=P.ink; rrF(-5.7,-Lt-1.2,11.4,Lt+1.6,3);
  wc.fillStyle=P.gm[2]; rrF(-4.5,-Lt,9,Lt,2.4);
  wc.fillStyle=P.gm[3]; wc.fillRect(-3.6,-Lt+2.6,1.6,Lt-4);
  wc.fillStyle=P.gm[0]; wc.fillRect(2.4,-Lt+2.6,2.1,Lt-4);
  wc.fillStyle=el?P.brass[1]:P.och; rrF(-4.5,-Lt,9,2.8,1.4);
  wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(0,-Lt+0.2,3.3,1.2,0,0,6.2832); wc.fill();
  wc.restore();
  if(e.hitT>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,70,56,'+clamp(e.hitT*2,0,.7)+')';
    rrF(x-12.8,y-17.8,25.6,12.6,4);
    wc.globalCompositeOperation='source-over';
  }
}
'@ @'
function drawHowlerS(e){
  if(pixOn()&&!PIXM.paint&&pixMachDraw(e,drawHowlerS)) return; // v28.xx (cw-cx-pixmachines): the body is cached at PIX_ACT, including job 80 size
  // v23.xx (spr12), HIS ORDER (2026-10-12) on the sprite program: THE HOWLER REDESIGN (MACHINES B 4). It was a black lunchbox
  // with a tube stuck in it at a fixed angle, the lowest contrast in the cast (gone on a dark floor), and the mortar never
  // pointed at what it was shooting. Now a mortar walker: four short splayed legs that step as it moves, a hull under a round
  // turret ring (the lightest thing on it, so it reads on a dark floor), a FAT tube with an ochre muzzle ring raised at its
  // firing elevation and leaning toward its facing (shorter when it faces you, longer when it faces away), an ammo drum on
  // the off side and a spotting lamp in the sensor language. Elite: a brass muzzle ring. Drawn only: radius and fight unchanged.
  var P=MBPAL,x=e.x,y=e.y,st=(e.step||0),el=!!e.elite,E=mbEye(e,pixMachTime()),fl=Math.cos(e.face)>=0?1:-1,i,s,lx,lift;
  shadowE(x,y+2,e.r*.9,4,.35);
  // LEGS: two back, then the hull, then two front; opposite corners step together
  function leg(hx,hy,fx,fy,up){ wc.strokeStyle=P.ink; wc.lineWidth=4.6; wc.beginPath(); wc.moveTo(x+hx,y+hy); wc.lineTo(x+(hx+fx)/2+(fx>hx?1.5:-1.5),y+hy-3-up); wc.lineTo(x+fx,y+fy-up); wc.stroke();
    wc.strokeStyle=P.gm[1]; wc.lineWidth=2.6; wc.stroke();
    wc.fillStyle=P.ink; rrF(x+fx-3.4,y+fy-1.6-up,6.8,3.8,1.4); wc.fillStyle=P.gm[2]; wc.fillRect(x+fx-2.4,y+fy-0.8-up,4.8,1.2); }
  lift=Math.max(0,Math.sin(st*2.4))*2; s=Math.max(0,-Math.sin(st*2.4))*2;
  wc.lineCap='round'; wc.lineJoin='round';
  leg(-7,-12,-15,-5,s); leg(7,-12,15,-5,lift);
  // THE HULL
  wc.fillStyle=P.ink; rrF(x-14,y-19,28,15,5);
  wc.fillStyle=P.gm[1]; rrF(x-12.8,y-17.8,25.6,12.6,4);
  wc.fillStyle=P.grime; rrF(x-12.8,y-9.6,25.6,4.4,3);
  wc.fillStyle=P.ox[1]; wc.fillRect(x-12.8,y-12.6,25.6,1.6);
  leg(-8,-8,-17,3,lift); leg(8,-8,17,3,s);
  wc.lineCap='butt'; wc.lineJoin='miter';
  // AMMO DRUM on the off side
  lx=x-fl*13.4;
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(lx,y-15,6,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[1]; wc.beginPath(); wc.arc(lx,y-15,4.8,0,6.2832); wc.fill();
  wc.fillStyle=P.ox[1]; wc.fillRect(lx-4.8,y-16,9.6,2);
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.arc(lx,y-15,1.6,0,6.2832); wc.fill();
  // THE TURRET RING: lit top, shaded band
  wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(x,y-21,13.4,7.4,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[2]; wc.beginPath(); wc.ellipse(x,y-20,12.2,6,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[3]; wc.beginPath(); wc.ellipse(x,y-22,12.2,4.8,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.rect(x-9.6,y-22.4,1.2,1.2); wc.rect(x+8.4,y-22.4,1.2,1.2); wc.rect(x-0.6,y-25.6,1.2,1.2); wc.fill();
  // SPOTTING LAMP on the turret front
  var sx=x+fl*8.6;
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(sx,y-19.4,2.7,0,6.2832); wc.fill();
  if(!PIXM.baking){ wc.globalCompositeOperation='lighter'; wc.fillStyle=E[0]; wc.globalAlpha=E[1];
  wc.beginPath(); wc.arc(sx,y-19.4,1.8,0,6.2832); wc.fill();
  if(E[2]){ wc.globalAlpha=E[2]>1?.22:.15; wc.beginPath(); wc.arc(sx,y-19.4,4,0,6.2832); wc.fill(); }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else { wc.fillStyle=E[0]; wc.globalAlpha=E[1]; wc.beginPath(); wc.arc(sx,y-19.4,1.8,0,6.2832); wc.fill(); wc.globalAlpha=1; }
  // THE TUBE: raised, leaning toward the facing, foreshortened when it faces you
  var Lt=15.5-Math.sin(e.face)*4;
  wc.save(); wc.translate(x,y-22); wc.rotate(Math.cos(e.face)*0.62);
  wc.fillStyle=P.ink; rrF(-6,-4.4,12,7.4,2.4);
  wc.fillStyle=P.gm[1]; rrF(-4.8,-3.4,9.6,5.4,1.8);
  wc.fillStyle=P.ink; rrF(-5.7,-Lt-1.2,11.4,Lt+1.6,3);
  wc.fillStyle=P.gm[2]; rrF(-4.5,-Lt,9,Lt,2.4);
  wc.fillStyle=P.gm[3]; wc.fillRect(-3.6,-Lt+2.6,1.6,Lt-4);
  wc.fillStyle=P.gm[0]; wc.fillRect(2.4,-Lt+2.6,2.1,Lt-4);
  wc.fillStyle=el?P.brass[1]:P.och; rrF(-4.5,-Lt,9,2.8,1.4);
  wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(0,-Lt+0.2,3.3,1.2,0,0,6.2832); wc.fill();
  wc.restore();
  if(e.hitT>0){
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,70,56,'+clamp(e.hitT*2,0,.7)+')';
    rrF(x-12.8,y-17.8,25.6,12.6,4);
    wc.globalCompositeOperation='source-over'; } else {  }
  }
}
'@

SubRx @'
function drawChoirS(e){
  // v23.xx (spr13), HIS ORDER (2026-10-12) on the sprite program: THE PILLBOX REDESIGN (MACHINES B 5). It was a purple drum
  // with seven lilac bubbles and a black porthole: the pipes read as candles, the mouth as a speaker, and purple is the elite
  // colour. Now a gunmetal emplacement: a bolted plinth with rusty sandbag lumps at its corners, a gunmetal drum with a rust
  // band, a crown of seven brass organ pipes of different heights standing on its top and still slowly turning (that is its
  // name), and a big round port with a six-blade iris that opens when it is live, the charge inside it in the sensor
  // language (red when live, orange when venting, dim white asleep). Venting heat now rises from the pipe tops. Elite: a
  // brass ring around the crown. Drawn only: the mouth sits where its weak point is, and the fight is unchanged.
  var P=MBPAL,x=e.x,y=e.y,el=!!e.elite,i,q,v;
  var hot=(e.overheat||0)>0;
  var live=e.seenYou&&!hot;
  shadowE(x,y+3,30,10,.5);
  // BOLTED DOWN. A wide flat plinth, drawn first and drawn low, so the shape reads as emplaced from any distance.
  wc.fillStyle=P.ink; rrF(x-26,y-9,52,13,4);
  wc.fillStyle=P.gm[1]; rrF(x-25,y-8,50,11,3);
  wc.fillStyle=P.gm[2]; wc.fillRect(x-24,y-8,48,2);
  wc.fillStyle=P.grime; wc.fillRect(x-24,y-1,48,3);
  wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(x-22,y+0.5,5.6,4,0,0,6.2832); wc.moveTo(x+27.6,y+0.5); wc.ellipse(x+22,y+0.5,5.6,4,0,0,6.2832); wc.fill();
  wc.fillStyle=P.ox[0]; wc.beginPath(); wc.ellipse(x-22,y+0.5,4.6,3,0,0,6.2832); wc.moveTo(x+26.6,y+0.5); wc.ellipse(x+22,y+0.5,4.6,3,0,0,6.2832); wc.fill();
  wc.fillStyle=P.ox[1]; wc.beginPath(); wc.ellipse(x-22.6,y-0.6,3,1.4,0,0,6.2832); wc.moveTo(x+24.4,y-0.6); wc.ellipse(x+21.4,y-0.6,3,1.4,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[0]; wc.beginPath(); for(i=0;i<4;i++){ wc.moveTo(x-13+i*8.7+1.5,y-4); wc.arc(x-13+i*8.7,y-4,1.5,0,6.2832); } wc.fill();
  wc.fillStyle=P.gm[3]; wc.beginPath(); for(i=0;i<4;i++) wc.rect(x-13.6+i*8.7,y-5.5,1.2,0.8); wc.fill();
  // THE DRUM: gunmetal, lit on top and on its left, shaded right, a rust band with rivets, grime low
  wc.fillStyle=P.ink; rrF(x-19,y-40,38,33,7);
  wc.fillStyle=P.gm[1]; rrF(x-18,y-39,36,31,6);
  wc.fillStyle=P.gm[2]; rrF(x-18,y-39,30,25,6);
  wc.fillStyle=P.gm[0]; wc.fillRect(x+13,y-33,4.6,22);
  wc.fillStyle=P.gm[3]; wc.fillRect(x-17,y-33,1.4,18);
  wc.fillStyle=P.ox[1]; wc.fillRect(x-18,y-20,36,5);
  wc.fillStyle=P.ox[2]; wc.fillRect(x-18,y-20,36,1);
  wc.fillStyle=P.grime; rrF(x-18,y-14,36,6,4);
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.rect(x-14.6,y-17.4,1.2,1.2); wc.rect(x-5.6,y-17.4,1.2,1.2); wc.rect(x+4.4,y-17.4,1.2,1.2); wc.rect(x+13.4,y-17.4,1.2,1.2); wc.fill();
  // THE CROWN: seven brass organ pipes in a ring on the drum top, slowly turning (back ones first)
  wc.fillStyle=P.gm[3]; wc.beginPath(); wc.ellipse(x,y-38.6,16.4,4.6,0,0,6.2832); wc.fill();
  var PH=[7.5,10.5,6.5,9.5,7,10,8.5], pl=[];
  for(q=0;q<7;q++){ var pa=(q/7)*6.2832+G.t*0.20; pl.push([Math.sin(pa),x+Math.cos(pa)*12.6,y-38.6+Math.sin(pa)*3.6,PH[q]]); }
  pl.sort(function(a,b){ return a[0]-b[0]; });
  if(el){ wc.strokeStyle=P.brass[1]; wc.lineWidth=1.2; wc.beginPath(); wc.ellipse(x,y-38.6,17.2,5.4,0,3.1416,6.2832); wc.stroke(); }
  for(q=0;q<7;q++){ var px=pl[q][1], py=pl[q][2], ph=pl[q][3];
    wc.fillStyle=P.ink; rrF(px-3,py-ph-0.8,6,ph+2,2);
    wc.fillStyle=P.brass[0]; rrF(px-2.1,py-ph,4.2,ph+0.6,1.4);
    wc.fillStyle=P.brass[1]; wc.fillRect(px-2.1,py-ph+1,1.4,ph-1.4);
    wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(px,py-ph+0.4,1.7,0.8,0,0,6.2832); wc.fill(); }
  if(el){ wc.strokeStyle=P.brass[1]; wc.lineWidth=1.2; wc.beginPath(); wc.ellipse(x,y-38.6,17.2,5.4,0,0,3.1416); wc.stroke(); }
  // THE MOUTH, front, which is one of its two weak points and the thing that brightens as the next shot loads: a port
  // with a six-blade iris that opens when it is live.
  var mx=x+Math.cos(e.face)*17, my=y-24+Math.sin(e.face)*5;
  var ap=live?5.2:(hot?4.2:2.2);
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(mx,my,9,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[2]; wc.beginPath(); wc.arc(mx,my,7.8,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.arc(mx,my+0.4,6.6,0,6.2832); wc.fill();
  wc.globalCompositeOperation='lighter';
  wc.fillStyle=hot?'#ff8a3c':(live?'#ff3b30':'#dfe9f0');
  wc.globalAlpha=hot?(.5+.4*Math.sin(G.t*14)):(live?(.55+.35*Math.sin(G.t*7)):.35);
  wc.beginPath(); wc.arc(mx,my+0.4,ap,0,6.2832); wc.fill();
  // While it is awake it wears a faint halo, which is the only cue you get at range that you have wandered inside its reach.
  if(live){ wc.globalAlpha=.08; wc.beginPath(); wc.arc(x,y-22,26,0,6.2832); wc.fill(); }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  wc.strokeStyle=P.ink; wc.lineWidth=0.9; wc.beginPath();
  for(i=0;i<6;i++){ var ia=i*1.0472+ap*0.18; wc.moveTo(mx+Math.cos(ia)*ap,my+0.4+Math.sin(ia)*ap); wc.lineTo(mx+Math.cos(ia+0.5)*6.6,my+0.4+Math.sin(ia+0.5)*6.6); }
  wc.stroke();
  // VENTING. Unmistakable, because the four seconds it buys are the reward for hitting a weak point and the player has to know
  // they have them: heat rises from the pipe tops.
  if(hot){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,138,60,.42)';
    for(v=0;v<3;v++){
      var vy=y-52-((G.t*40+v*14)%24);
      wc.beginPath(); wc.ellipse(x+(v-1)*10,vy,4.6,2.8,0,0,6.2832); wc.fill();
    }
    wc.globalCompositeOperation='source-over';
  }
  if(e.hitT>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,70,56,'+clamp(e.hitT*2,0,.7)+')';
    rrF(x-18,y-39,36,31,6);
    wc.globalCompositeOperation='source-over';
  }
  if(e.muzzle>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='#ffb070'; wc.globalAlpha=clamp(e.muzzle*6,0,1)*flashK();
    wc.beginPath(); wc.arc(mx,my,8,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  }
}
'@ @'
function drawChoirS(e){
  if(pixOn()&&!PIXM.paint&&pixMachDraw(e,drawChoirS)) return; // v28.xx (cw-cx-pixmachines): the body is cached at PIX_ACT, including job 80 size
  // v23.xx (spr13), HIS ORDER (2026-10-12) on the sprite program: THE PILLBOX REDESIGN (MACHINES B 5). It was a purple drum
  // with seven lilac bubbles and a black porthole: the pipes read as candles, the mouth as a speaker, and purple is the elite
  // colour. Now a gunmetal emplacement: a bolted plinth with rusty sandbag lumps at its corners, a gunmetal drum with a rust
  // band, a crown of seven brass organ pipes of different heights standing on its top and still slowly turning (that is its
  // name), and a big round port with a six-blade iris that opens when it is live, the charge inside it in the sensor
  // language (red when live, orange when venting, dim white asleep). Venting heat now rises from the pipe tops. Elite: a
  // brass ring around the crown. Drawn only: the mouth sits where its weak point is, and the fight is unchanged.
  var P=MBPAL,x=e.x,y=e.y,el=!!e.elite,i,q,v;
  var hot=(e.overheat||0)>0;
  var live=e.seenYou&&!hot;
  shadowE(x,y+3,30,10,.5);
  // BOLTED DOWN. A wide flat plinth, drawn first and drawn low, so the shape reads as emplaced from any distance.
  wc.fillStyle=P.ink; rrF(x-26,y-9,52,13,4);
  wc.fillStyle=P.gm[1]; rrF(x-25,y-8,50,11,3);
  wc.fillStyle=P.gm[2]; wc.fillRect(x-24,y-8,48,2);
  wc.fillStyle=P.grime; wc.fillRect(x-24,y-1,48,3);
  wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(x-22,y+0.5,5.6,4,0,0,6.2832); wc.moveTo(x+27.6,y+0.5); wc.ellipse(x+22,y+0.5,5.6,4,0,0,6.2832); wc.fill();
  wc.fillStyle=P.ox[0]; wc.beginPath(); wc.ellipse(x-22,y+0.5,4.6,3,0,0,6.2832); wc.moveTo(x+26.6,y+0.5); wc.ellipse(x+22,y+0.5,4.6,3,0,0,6.2832); wc.fill();
  wc.fillStyle=P.ox[1]; wc.beginPath(); wc.ellipse(x-22.6,y-0.6,3,1.4,0,0,6.2832); wc.moveTo(x+24.4,y-0.6); wc.ellipse(x+21.4,y-0.6,3,1.4,0,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[0]; wc.beginPath(); for(i=0;i<4;i++){ wc.moveTo(x-13+i*8.7+1.5,y-4); wc.arc(x-13+i*8.7,y-4,1.5,0,6.2832); } wc.fill();
  wc.fillStyle=P.gm[3]; wc.beginPath(); for(i=0;i<4;i++) wc.rect(x-13.6+i*8.7,y-5.5,1.2,0.8); wc.fill();
  // THE DRUM: gunmetal, lit on top and on its left, shaded right, a rust band with rivets, grime low
  wc.fillStyle=P.ink; rrF(x-19,y-40,38,33,7);
  wc.fillStyle=P.gm[1]; rrF(x-18,y-39,36,31,6);
  wc.fillStyle=P.gm[2]; rrF(x-18,y-39,30,25,6);
  wc.fillStyle=P.gm[0]; wc.fillRect(x+13,y-33,4.6,22);
  wc.fillStyle=P.gm[3]; wc.fillRect(x-17,y-33,1.4,18);
  wc.fillStyle=P.ox[1]; wc.fillRect(x-18,y-20,36,5);
  wc.fillStyle=P.ox[2]; wc.fillRect(x-18,y-20,36,1);
  wc.fillStyle=P.grime; rrF(x-18,y-14,36,6,4);
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.rect(x-14.6,y-17.4,1.2,1.2); wc.rect(x-5.6,y-17.4,1.2,1.2); wc.rect(x+4.4,y-17.4,1.2,1.2); wc.rect(x+13.4,y-17.4,1.2,1.2); wc.fill();
  // THE CROWN: seven brass organ pipes in a ring on the drum top, slowly turning (back ones first)
  wc.fillStyle=P.gm[3]; wc.beginPath(); wc.ellipse(x,y-38.6,16.4,4.6,0,0,6.2832); wc.fill();
  var PH=[7.5,10.5,6.5,9.5,7,10,8.5], pl=[];
  for(q=0;q<7;q++){ var pa=(q/7)*6.2832+pixMachTime()*0.20; pl.push([Math.sin(pa),x+Math.cos(pa)*12.6,y-38.6+Math.sin(pa)*3.6,PH[q]]); }
  pl.sort(function(a,b){ return a[0]-b[0]; });
  if(el){ wc.strokeStyle=P.brass[1]; wc.lineWidth=1.2; wc.beginPath(); wc.ellipse(x,y-38.6,17.2,5.4,0,3.1416,6.2832); wc.stroke(); }
  for(q=0;q<7;q++){ var px=pl[q][1], py=pl[q][2], ph=pl[q][3];
    wc.fillStyle=P.ink; rrF(px-3,py-ph-0.8,6,ph+2,2);
    wc.fillStyle=P.brass[0]; rrF(px-2.1,py-ph,4.2,ph+0.6,1.4);
    wc.fillStyle=P.brass[1]; wc.fillRect(px-2.1,py-ph+1,1.4,ph-1.4);
    wc.fillStyle=P.ink; wc.beginPath(); wc.ellipse(px,py-ph+0.4,1.7,0.8,0,0,6.2832); wc.fill(); }
  if(el){ wc.strokeStyle=P.brass[1]; wc.lineWidth=1.2; wc.beginPath(); wc.ellipse(x,y-38.6,17.2,5.4,0,0,3.1416); wc.stroke(); }
  // THE MOUTH, front, which is one of its two weak points and the thing that brightens as the next shot loads: a port
  // with a six-blade iris that opens when it is live.
  var mx=x+Math.cos(e.face)*17, my=y-24+Math.sin(e.face)*5;
  var ap=live?5.2:(hot?4.2:2.2);
  wc.fillStyle=P.ink; wc.beginPath(); wc.arc(mx,my,9,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[2]; wc.beginPath(); wc.arc(mx,my,7.8,0,6.2832); wc.fill();
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.arc(mx,my+0.4,6.6,0,6.2832); wc.fill();
  if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
  wc.fillStyle=hot?'#ff8a3c':(live?'#ff3b30':'#dfe9f0');
  wc.globalAlpha=hot?(.5+.4*Math.sin(pixMachTime()*14)):(live?(.55+.35*Math.sin(pixMachTime()*7)):.35);
  wc.beginPath(); wc.arc(mx,my+0.4,ap,0,6.2832); wc.fill();
  // While it is awake it wears a faint halo, which is the only cue you get at range that you have wandered inside its reach.
  if(live){ wc.globalAlpha=.08; wc.beginPath(); wc.arc(x,y-22,26,0,6.2832); wc.fill(); }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else { wc.fillStyle=hot?'#ff8a3c':(live?'#ff3b30':'#dfe9f0'); wc.globalAlpha=hot?.7:(live?.75:.35); wc.beginPath(); wc.arc(mx,my+0.4,ap,0,6.2832); wc.fill(); wc.globalAlpha=1; }
  wc.strokeStyle=P.ink; wc.lineWidth=0.9; wc.beginPath();
  for(i=0;i<6;i++){ var ia=i*1.0472+ap*0.18; wc.moveTo(mx+Math.cos(ia)*ap,my+0.4+Math.sin(ia)*ap); wc.lineTo(mx+Math.cos(ia+0.5)*6.6,my+0.4+Math.sin(ia+0.5)*6.6); }
  wc.stroke();
  // VENTING. Unmistakable, because the four seconds it buys are the reward for hitting a weak point and the player has to know
  // they have them: heat rises from the pipe tops.
  if(hot){
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,138,60,.42)';
    for(v=0;v<3;v++){
      var vy=y-52-((pixMachTime()*40+v*14)%24);
      wc.beginPath(); wc.ellipse(x+(v-1)*10,vy,4.6,2.8,0,0,6.2832); wc.fill();
    }
    wc.globalCompositeOperation='source-over'; } else {  }
  }
  if(e.hitT>0){
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,70,56,'+clamp(e.hitT*2,0,.7)+')';
    rrF(x-18,y-39,36,31,6);
    wc.globalCompositeOperation='source-over'; } else {  }
  }
  if(e.muzzle>0){
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
    wc.fillStyle='#ffb070'; wc.globalAlpha=clamp(e.muzzle*6,0,1)*flashK();
    wc.beginPath(); wc.arc(mx,my,8,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else {  }
  }
}
'@

SubRx @'
function drawWardenS(e){
  var x=e.x,y=e.y,B=!!(e.boss||e.name===BOSS_NAME),P=B?MBPAL_OV:MBPAL,fl=Math.cos(e.face)>=0?1:-1,st=(e.step||0),el=!!e.elite,i,a,tx;
  shadowE(x,y+2,26,8,.45);
  wc.save(); wc.translate(x,y); wc.scale(fl,1);
  // TRACKS: rubber, links running with travel (top run forward, bottom back), four road wheels that turn
  wc.fillStyle=P.ink; rrF(-21,-14.5,42,15.5,5.5);
  wc.fillStyle=P.rub; rrF(-19.8,-13.3,39.6,13.1,4.5);
  a=(st*7)%4.8; wc.fillStyle=P.tooth; wc.beginPath();
  for(i=0;i<8;i++){ tx=-17.5+((i*4.8+a)%36); wc.rect(tx,-13.3,2.2,1.7); tx=-17.5+((i*4.8+36-a)%36); wc.rect(tx,-1.9,2.2,1.6); }
  wc.fill();
  wc.fillStyle=P.gm[1]; wc.beginPath();
  for(i=0;i<4;i++){ wc.moveTo(-12.6+i*8.4+3.7,-6.6); wc.arc(-12.6+i*8.4,-6.6,3.7,0,6.2832); } wc.fill();
  wc.fillStyle=P.gm[0]; wc.beginPath();
  for(i=0;i<4;i++){ wc.moveTo(-12.6+i*8.4+1.5,-6.6); wc.arc(-12.6+i*8.4,-6.6,1.5,0,6.2832); } wc.fill();
  wc.fillStyle=P.gm[3]; wc.beginPath(); a=st*1.7;
  for(i=0;i<4;i++) wc.rect(-12.6+i*8.4+Math.cos(a+i)*2.4-0.6,-6.6+Math.sin(a+i)*2.4-0.6,1.2,1.2); wc.fill();
  // CHASSIS: a sloped block on the tracks, oxide track guards with ochre stencils
  wc.fillStyle=P.ink; mbPoly([-20.5,-11.5,20.5,-11.5,17,-22,-17.5,-22]);
  wc.fillStyle=P.gm[1]; mbPoly([-19.2,-12.6,19.2,-12.6,16.2,-20.8,-16.6,-20.8]);
  wc.fillStyle=P.ox[1]; wc.fillRect(-19.2,-14.8,38.4,2.4);
  wc.fillStyle=P.och; mbPoly([-15,-14.8,-12.6,-14.8,-14,-12.4,-16.4,-12.4]); mbPoly([12,-14.8,14.4,-14.8,13,-12.4,10.6,-12.4]);
  // EXHAUST STACKS behind the hunch
  wc.fillStyle=P.ink; rrF(-11.4,-50,4.4,12,1.4); rrF(-6.6,-48,4.4,10,1.4);
  wc.fillStyle=P.gm[0]; wc.fillRect(-10.6,-49.2,2.8,10.5); wc.fillRect(-5.8,-47.2,2.8,8.5);
  wc.fillStyle=P.gm[2]; wc.fillRect(-10.6,-49.2,2.8,1.2); wc.fillRect(-5.8,-47.2,2.8,1.2);
  // THE OVERSEER: its second cannon, on the far shoulder, behind the hull
  if(B){ wc.fillStyle=P.ink; rrF(4,-43.6,28.6,7,2); rrF(27,-45,6.4,9.8,1.6);
    wc.fillStyle=P.gm[1]; wc.fillRect(5,-42.4,22.4,4.6); wc.fillStyle=P.steel; wc.fillRect(5,-42.4,22.4,1);
    wc.fillStyle=P.gm[0]; wc.fillRect(28,-44,4.4,7.8); wc.fillStyle=P.och; wc.fillRect(28,-44,4.4,1.2); }
  // TORSO: hunched forward, lit on top, shaded on the front face, grime low
  wc.fillStyle=P.ink; mbPoly([-17,-18,-17,-36,-11.5,-45.2,3,-47.2,14.6,-42,19,-30,17,-18]);
  wc.fillStyle=P.gm[2]; mbPoly([-15.8,-19.2,-15.8,-35.6,-10.8,-44,3,-46,13.6,-41.2,17.6,-30,15.8,-19.2]);
  wc.fillStyle=P.gm[3]; mbPoly([-10.8,-44,3,-46,13.6,-41.2,11,-39,-9,-39.6]);
  wc.fillStyle=P.gm[1]; mbPoly([13.6,-41.2,17.6,-30,15.8,-19.2,11.6,-19.2,13.4,-30.5,11,-39]);
  wc.fillStyle=P.grime; wc.fillRect(-15.8,-23.4,29,4.2);
  wc.fillStyle=P.gm[0]; wc.fillRect(-15.8,-31.2,27.2,0.9);
  // LAUNCHER POD on the off shoulder: a 2x2 rack of tube mouths (the Overseer trails cable bundles there instead)
  if(!B){
  wc.fillStyle=P.ink; rrF(-23,-43,12.4,12.6,2.4);
  wc.fillStyle=P.gm[1]; rrF(-21.8,-41.8,10,10.2,1.8);
  wc.fillStyle=P.gm[2]; wc.fillRect(-21.8,-41.8,10,1.6);
  wc.fillStyle=P.ink; wc.beginPath();
  for(i=0;i<4;i++){ wc.moveTo(-19.2+(i%2)*4.8+1.7,-37.6+((i>>1)*4.6)); wc.arc(-19.2+(i%2)*4.8,-37.6+((i>>1)*4.6),1.7,0,6.2832); } wc.fill();
  wc.fillStyle=P.och; wc.fillRect(-21.8,-33.2,10,1.0);
  } else {
    wc.lineCap='round'; wc.strokeStyle=P.ink; wc.lineWidth=3.2; wc.beginPath();
    wc.moveTo(-14,-40); wc.bezierCurveTo(-24,-38,-22,-26,-20,-17); wc.moveTo(-12,-36); wc.bezierCurveTo(-20,-30,-17,-22,-16.4,-15.6); wc.moveTo(-15.6,-31); wc.bezierCurveTo(-24,-28,-25,-20,-23.4,-14.8); wc.stroke();
    wc.strokeStyle=P.gm[2]; wc.lineWidth=1.3; wc.stroke(); wc.lineCap='butt';
    wc.fillStyle=P.och; wc.beginPath(); wc.rect(-21.6,-25,3,1.4); wc.rect(-18.6,-23.6,2.8,1.4); wc.rect(-24.6,-22,2.8,1.4); wc.fill();
  }
  // BELLY PLATE: oxide, hazard stencils
  wc.fillStyle=P.ink; rrF(-13.4,-29.4,17.4,9.4,2);
  wc.fillStyle=P.ox[1]; rrF(-12.4,-28.4,15.4,7.4,1.5);
  wc.fillStyle=P.ox[2]; wc.fillRect(-12.4,-28.4,15.4,1.2);
  wc.fillStyle=P.och; mbPoly([-10.4,-26.6,-7.6,-26.6,-9.8,-22.6,-12.4,-22.6]); mbPoly([-5.6,-26.6,-2.8,-26.6,-5,-22.6,-7.8,-22.6]);
  // THE HEAD: set low between the shoulders, a visor slit in the sensor language (the Overseer: a crown of three sensor masts and one big lens)
  var E=mbEye(e,G.t);
  if(B){
    wc.lineCap='round'; wc.strokeStyle=P.ink; wc.lineWidth=2.6; wc.beginPath();
    wc.moveTo(4.6,-44); wc.lineTo(3.4,-55.4); wc.moveTo(9.4,-45); wc.lineTo(9.4,-58.4); wc.moveTo(14.2,-43); wc.lineTo(15.6,-54.6); wc.stroke();
    wc.strokeStyle=P.och; wc.lineWidth=1.1; wc.stroke(); wc.lineCap='butt';
    wc.globalCompositeOperation='lighter'; wc.fillStyle='#ff3b30'; wc.globalAlpha=.55+.35*Math.sin(G.t*4);
    wc.beginPath(); wc.arc(3.4,-55.8,1.5,0,6.2832); wc.moveTo(10.9,-58.8); wc.arc(9.4,-58.8,1.5,0,6.2832); wc.moveTo(17.1,-55); wc.arc(15.6,-55,1.5,0,6.2832); wc.fill();
    wc.globalAlpha=.18; wc.beginPath(); wc.arc(3.4,-55.8,3,0,6.2832); wc.moveTo(12.4,-58.8); wc.arc(9.4,-58.8,3,0,6.2832); wc.moveTo(18.6,-55); wc.arc(15.6,-55,3,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  }
  wc.fillStyle=P.ink; rrF(1.4,-45,16,11.6,3);
  wc.fillStyle=P.gm[1]; rrF(2.6,-43.8,13.6,9.2,2.2);
  wc.fillStyle=P.gm[3]; wc.fillRect(3.4,-43.8,12,1.5);
  if(B){
    if(E[2]===2) E[0]='#d0202a';
    wc.fillStyle=P.ink; wc.beginPath(); wc.arc(9.4,-39.2,5.2,0,6.2832); wc.fill();
    wc.strokeStyle=P.och; wc.lineWidth=0.9; wc.beginPath(); wc.arc(9.4,-39.2,4.4,0,6.2832); wc.stroke();
    wc.globalCompositeOperation='lighter'; wc.fillStyle=E[0]; wc.globalAlpha=Math.min(1,E[1]+.15);
    wc.beginPath(); wc.arc(9.4,-39.2,3.3,0,6.2832); wc.fill();
    if(E[2]){ wc.globalAlpha=E[2]>1?.24:.16; wc.beginPath(); wc.arc(9.4,-39.2,5.3,0,6.2832); wc.fill(); }
    wc.globalAlpha=.85; wc.fillStyle='#ffffff'; wc.beginPath(); wc.arc(8.2,-40.4,.8,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  } else {
  wc.fillStyle=P.ink; rrF(4.2,-40.6,12.4,4.8,1.8);
  wc.globalCompositeOperation='lighter'; wc.fillStyle=E[0]; wc.globalAlpha=E[1];
  wc.fillRect(5.2,-39.6,10.4,2.6);
  if(E[2]){ wc.globalAlpha=E[2]>1?.22:.16; wc.beginPath(); wc.arc(10.4,-38.3,E[2]>1?7:5,0,6.2832); wc.fill(); }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  }
  // CANNON ARM: a piston from the chassis, the barrel, the muzzle block
  wc.strokeStyle=P.ink; wc.lineWidth=4.4; wc.beginPath(); wc.moveTo(8.4,-17.6); wc.lineTo(20.6,-25); wc.stroke();
  wc.strokeStyle=P.gm[0]; wc.lineWidth=2.6; wc.beginPath(); wc.moveTo(8.4,-17.6); wc.lineTo(14.6,-21.3); wc.stroke();
  wc.strokeStyle=P.steel; wc.lineWidth=1.2; wc.beginPath(); wc.moveTo(14.6,-21.3); wc.lineTo(20.6,-25); wc.stroke();
  wc.fillStyle=P.ink; rrF(12,-30.6,18,7.2,2); rrF(25.8,-32,6.6,10,1.6);
  wc.fillStyle=P.gm[1]; wc.fillRect(13.2,-29.4,13,4.8);
  wc.fillStyle=P.steel; wc.fillRect(13.2,-29.4,13,1.1);
  wc.fillStyle=P.gm[0]; wc.fillRect(26.8,-31,4.6,8);
  wc.fillStyle=P.gm[2]; wc.fillRect(26.8,-31,4.6,1.2);
  // OXIDE PAULDRON over the cannon joint
  wc.fillStyle=P.ink; mbPoly([5.4,-34.6,17.6,-33.4,19.8,-23.2,7.6,-21.6]);
  wc.fillStyle=P.ox[1]; mbPoly([6.7,-33.4,16.6,-32.3,18.4,-24.2,8.4,-22.9]);
  wc.fillStyle=P.ox[2]; mbPoly([6.7,-33.4,16.6,-32.3,16.8,-31,6.9,-32]);
  wc.fillStyle=P.ox[0]; mbPoly([18.4,-24.2,8.4,-22.9,8.3,-24.3,18.1,-25.5]);
  if(el){ wc.strokeStyle=P.brass[1]; wc.lineWidth=0.9; wc.beginPath(); wc.moveTo(6.7,-33.4); wc.lineTo(16.6,-32.3); wc.lineTo(18.4,-24.2);
    wc.moveTo(-12.4,-28.4); wc.lineTo(3,-28.4); wc.stroke(); }
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.rect(-14.2,-34.4,1.2,1.2); wc.rect(-0.8,-24.2,1.2,1.2); wc.rect(9,-24.8,1.2,1.2); wc.rect(-2.4,-38,1.2,1.2); wc.rect(16.4,-26.6,1.2,1.2); wc.fill();
  wc.fillStyle=P.steel; wc.beginPath(); wc.rect(15.6,-32.6,1.8,0.8); wc.rect(3.6,-43.6,1.2,0.8); wc.rect(-15.6,-20.4,1.6,0.8); wc.rect(1.6,-28.4,1.4,0.8); wc.fill();
  // ELITE: a brass antenna with a lamp
  if(el){ wc.strokeStyle=P.brass[0]; wc.lineWidth=1.2; wc.beginPath(); wc.moveTo(-1,-46.6); wc.lineTo(-2,-56); wc.stroke();
    wc.fillStyle=P.brass[1]; wc.beginPath(); wc.arc(-2,-56.4,1.5,0,6.2832); wc.fill(); }
  if(e.hitT>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,70,56,'+clamp(e.hitT*2,0,.7)+')';
    mbPoly([-15.8,-19.2,-15.8,-35.6,-10.8,-44,3,-46,13.6,-41.2,17.6,-30,15.8,-19.2]);
    wc.globalCompositeOperation='source-over';
  }
  wc.restore();
  if(e.muzzle>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='#ffc04a'; wc.globalAlpha=clamp(e.muzzle*6,0,1)*flashK();
    wc.beginPath(); wc.arc(x+fl*32.4,y-27,7,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  }
  drawWindupGlow(e,x+fl*32.4,y-27);
}
'@ @'
function drawWardenS(e){
  if(pixOn()&&!PIXM.paint&&pixMachDraw(e,drawWardenS)) return; // v28.xx (cw-cx-pixmachines): the body is cached at PIX_ACT, including job 80 size
  var x=e.x,y=e.y,B=!!(e.boss||e.name===BOSS_NAME),P=B?MBPAL_OV:MBPAL,fl=Math.cos(e.face)>=0?1:-1,st=(e.step||0),el=!!e.elite,i,a,tx;
  shadowE(x,y+2,26,8,.45);
  wc.save(); wc.translate(x,y); wc.scale(fl,1);
  // TRACKS: rubber, links running with travel (top run forward, bottom back), four road wheels that turn
  wc.fillStyle=P.ink; rrF(-21,-14.5,42,15.5,5.5);
  wc.fillStyle=P.rub; rrF(-19.8,-13.3,39.6,13.1,4.5);
  a=(st*7)%4.8; wc.fillStyle=P.tooth; wc.beginPath();
  for(i=0;i<8;i++){ tx=-17.5+((i*4.8+a)%36); wc.rect(tx,-13.3,2.2,1.7); tx=-17.5+((i*4.8+36-a)%36); wc.rect(tx,-1.9,2.2,1.6); }
  wc.fill();
  wc.fillStyle=P.gm[1]; wc.beginPath();
  for(i=0;i<4;i++){ wc.moveTo(-12.6+i*8.4+3.7,-6.6); wc.arc(-12.6+i*8.4,-6.6,3.7,0,6.2832); } wc.fill();
  wc.fillStyle=P.gm[0]; wc.beginPath();
  for(i=0;i<4;i++){ wc.moveTo(-12.6+i*8.4+1.5,-6.6); wc.arc(-12.6+i*8.4,-6.6,1.5,0,6.2832); } wc.fill();
  wc.fillStyle=P.gm[3]; wc.beginPath(); a=st*1.7;
  for(i=0;i<4;i++) wc.rect(-12.6+i*8.4+Math.cos(a+i)*2.4-0.6,-6.6+Math.sin(a+i)*2.4-0.6,1.2,1.2); wc.fill();
  // CHASSIS: a sloped block on the tracks, oxide track guards with ochre stencils
  wc.fillStyle=P.ink; mbPoly([-20.5,-11.5,20.5,-11.5,17,-22,-17.5,-22]);
  wc.fillStyle=P.gm[1]; mbPoly([-19.2,-12.6,19.2,-12.6,16.2,-20.8,-16.6,-20.8]);
  wc.fillStyle=P.ox[1]; wc.fillRect(-19.2,-14.8,38.4,2.4);
  wc.fillStyle=P.och; mbPoly([-15,-14.8,-12.6,-14.8,-14,-12.4,-16.4,-12.4]); mbPoly([12,-14.8,14.4,-14.8,13,-12.4,10.6,-12.4]);
  // EXHAUST STACKS behind the hunch
  wc.fillStyle=P.ink; rrF(-11.4,-50,4.4,12,1.4); rrF(-6.6,-48,4.4,10,1.4);
  wc.fillStyle=P.gm[0]; wc.fillRect(-10.6,-49.2,2.8,10.5); wc.fillRect(-5.8,-47.2,2.8,8.5);
  wc.fillStyle=P.gm[2]; wc.fillRect(-10.6,-49.2,2.8,1.2); wc.fillRect(-5.8,-47.2,2.8,1.2);
  // THE OVERSEER: its second cannon, on the far shoulder, behind the hull
  if(B){ wc.fillStyle=P.ink; rrF(4,-43.6,28.6,7,2); rrF(27,-45,6.4,9.8,1.6);
    wc.fillStyle=P.gm[1]; wc.fillRect(5,-42.4,22.4,4.6); wc.fillStyle=P.steel; wc.fillRect(5,-42.4,22.4,1);
    wc.fillStyle=P.gm[0]; wc.fillRect(28,-44,4.4,7.8); wc.fillStyle=P.och; wc.fillRect(28,-44,4.4,1.2); }
  // TORSO: hunched forward, lit on top, shaded on the front face, grime low
  wc.fillStyle=P.ink; mbPoly([-17,-18,-17,-36,-11.5,-45.2,3,-47.2,14.6,-42,19,-30,17,-18]);
  wc.fillStyle=P.gm[2]; mbPoly([-15.8,-19.2,-15.8,-35.6,-10.8,-44,3,-46,13.6,-41.2,17.6,-30,15.8,-19.2]);
  wc.fillStyle=P.gm[3]; mbPoly([-10.8,-44,3,-46,13.6,-41.2,11,-39,-9,-39.6]);
  wc.fillStyle=P.gm[1]; mbPoly([13.6,-41.2,17.6,-30,15.8,-19.2,11.6,-19.2,13.4,-30.5,11,-39]);
  wc.fillStyle=P.grime; wc.fillRect(-15.8,-23.4,29,4.2);
  wc.fillStyle=P.gm[0]; wc.fillRect(-15.8,-31.2,27.2,0.9);
  // LAUNCHER POD on the off shoulder: a 2x2 rack of tube mouths (the Overseer trails cable bundles there instead)
  if(!B){
  wc.fillStyle=P.ink; rrF(-23,-43,12.4,12.6,2.4);
  wc.fillStyle=P.gm[1]; rrF(-21.8,-41.8,10,10.2,1.8);
  wc.fillStyle=P.gm[2]; wc.fillRect(-21.8,-41.8,10,1.6);
  wc.fillStyle=P.ink; wc.beginPath();
  for(i=0;i<4;i++){ wc.moveTo(-19.2+(i%2)*4.8+1.7,-37.6+((i>>1)*4.6)); wc.arc(-19.2+(i%2)*4.8,-37.6+((i>>1)*4.6),1.7,0,6.2832); } wc.fill();
  wc.fillStyle=P.och; wc.fillRect(-21.8,-33.2,10,1.0);
  } else {
    wc.lineCap='round'; wc.strokeStyle=P.ink; wc.lineWidth=3.2; wc.beginPath();
    wc.moveTo(-14,-40); wc.bezierCurveTo(-24,-38,-22,-26,-20,-17); wc.moveTo(-12,-36); wc.bezierCurveTo(-20,-30,-17,-22,-16.4,-15.6); wc.moveTo(-15.6,-31); wc.bezierCurveTo(-24,-28,-25,-20,-23.4,-14.8); wc.stroke();
    wc.strokeStyle=P.gm[2]; wc.lineWidth=1.3; wc.stroke(); wc.lineCap='butt';
    wc.fillStyle=P.och; wc.beginPath(); wc.rect(-21.6,-25,3,1.4); wc.rect(-18.6,-23.6,2.8,1.4); wc.rect(-24.6,-22,2.8,1.4); wc.fill();
  }
  // BELLY PLATE: oxide, hazard stencils
  wc.fillStyle=P.ink; rrF(-13.4,-29.4,17.4,9.4,2);
  wc.fillStyle=P.ox[1]; rrF(-12.4,-28.4,15.4,7.4,1.5);
  wc.fillStyle=P.ox[2]; wc.fillRect(-12.4,-28.4,15.4,1.2);
  wc.fillStyle=P.och; mbPoly([-10.4,-26.6,-7.6,-26.6,-9.8,-22.6,-12.4,-22.6]); mbPoly([-5.6,-26.6,-2.8,-26.6,-5,-22.6,-7.8,-22.6]);
  // THE HEAD: set low between the shoulders, a visor slit in the sensor language (the Overseer: a crown of three sensor masts and one big lens)
  var E=mbEye(e,pixMachTime());
  if(B){
    wc.lineCap='round'; wc.strokeStyle=P.ink; wc.lineWidth=2.6; wc.beginPath();
    wc.moveTo(4.6,-44); wc.lineTo(3.4,-55.4); wc.moveTo(9.4,-45); wc.lineTo(9.4,-58.4); wc.moveTo(14.2,-43); wc.lineTo(15.6,-54.6); wc.stroke();
    wc.strokeStyle=P.och; wc.lineWidth=1.1; wc.stroke(); wc.lineCap='butt';
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter'; wc.fillStyle='#ff3b30'; wc.globalAlpha=.55+.35*Math.sin(pixMachTime()*4);
    wc.beginPath(); wc.arc(3.4,-55.8,1.5,0,6.2832); wc.moveTo(10.9,-58.8); wc.arc(9.4,-58.8,1.5,0,6.2832); wc.moveTo(17.1,-55); wc.arc(15.6,-55,1.5,0,6.2832); wc.fill();
    wc.globalAlpha=.18; wc.beginPath(); wc.arc(3.4,-55.8,3,0,6.2832); wc.moveTo(12.4,-58.8); wc.arc(9.4,-58.8,3,0,6.2832); wc.moveTo(18.6,-55); wc.arc(15.6,-55,3,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else { wc.fillStyle='#ff3b30'; wc.beginPath(); wc.arc(3.4,-55.8,1.5,0,6.2832); wc.moveTo(10.9,-58.8); wc.arc(9.4,-58.8,1.5,0,6.2832); wc.moveTo(17.1,-55); wc.arc(15.6,-55,1.5,0,6.2832); wc.fill(); }
  }
  wc.fillStyle=P.ink; rrF(1.4,-45,16,11.6,3);
  wc.fillStyle=P.gm[1]; rrF(2.6,-43.8,13.6,9.2,2.2);
  wc.fillStyle=P.gm[3]; wc.fillRect(3.4,-43.8,12,1.5);
  if(B){
    if(E[2]===2) E[0]='#d0202a';
    wc.fillStyle=P.ink; wc.beginPath(); wc.arc(9.4,-39.2,5.2,0,6.2832); wc.fill();
    wc.strokeStyle=P.och; wc.lineWidth=0.9; wc.beginPath(); wc.arc(9.4,-39.2,4.4,0,6.2832); wc.stroke();
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter'; wc.fillStyle=E[0]; wc.globalAlpha=Math.min(1,E[1]+.15);
    wc.beginPath(); wc.arc(9.4,-39.2,3.3,0,6.2832); wc.fill();
    if(E[2]){ wc.globalAlpha=E[2]>1?.24:.16; wc.beginPath(); wc.arc(9.4,-39.2,5.3,0,6.2832); wc.fill(); }
    wc.globalAlpha=.85; wc.fillStyle='#ffffff'; wc.beginPath(); wc.arc(8.2,-40.4,.8,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else { wc.fillStyle=E[0]; wc.beginPath(); wc.arc(9.4,-39.2,3.3,0,6.2832); wc.fill(); wc.fillStyle='#ffffff'; wc.beginPath(); wc.arc(8.2,-40.4,.8,0,6.2832); wc.fill(); }
  } else {
  wc.fillStyle=P.ink; rrF(4.2,-40.6,12.4,4.8,1.8);
  if(!PIXM.baking){ wc.globalCompositeOperation='lighter'; wc.fillStyle=E[0]; wc.globalAlpha=E[1];
  wc.fillRect(5.2,-39.6,10.4,2.6);
  if(E[2]){ wc.globalAlpha=E[2]>1?.22:.16; wc.beginPath(); wc.arc(10.4,-38.3,E[2]>1?7:5,0,6.2832); wc.fill(); }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else { wc.fillStyle=E[0]; wc.globalAlpha=E[1]; wc.fillRect(5.2,-39.6,10.4,2.6); wc.globalAlpha=1; }
  }
  // CANNON ARM: a piston from the chassis, the barrel, the muzzle block
  wc.strokeStyle=P.ink; wc.lineWidth=4.4; wc.beginPath(); wc.moveTo(8.4,-17.6); wc.lineTo(20.6,-25); wc.stroke();
  wc.strokeStyle=P.gm[0]; wc.lineWidth=2.6; wc.beginPath(); wc.moveTo(8.4,-17.6); wc.lineTo(14.6,-21.3); wc.stroke();
  wc.strokeStyle=P.steel; wc.lineWidth=1.2; wc.beginPath(); wc.moveTo(14.6,-21.3); wc.lineTo(20.6,-25); wc.stroke();
  wc.fillStyle=P.ink; rrF(12,-30.6,18,7.2,2); rrF(25.8,-32,6.6,10,1.6);
  wc.fillStyle=P.gm[1]; wc.fillRect(13.2,-29.4,13,4.8);
  wc.fillStyle=P.steel; wc.fillRect(13.2,-29.4,13,1.1);
  wc.fillStyle=P.gm[0]; wc.fillRect(26.8,-31,4.6,8);
  wc.fillStyle=P.gm[2]; wc.fillRect(26.8,-31,4.6,1.2);
  // OXIDE PAULDRON over the cannon joint
  wc.fillStyle=P.ink; mbPoly([5.4,-34.6,17.6,-33.4,19.8,-23.2,7.6,-21.6]);
  wc.fillStyle=P.ox[1]; mbPoly([6.7,-33.4,16.6,-32.3,18.4,-24.2,8.4,-22.9]);
  wc.fillStyle=P.ox[2]; mbPoly([6.7,-33.4,16.6,-32.3,16.8,-31,6.9,-32]);
  wc.fillStyle=P.ox[0]; mbPoly([18.4,-24.2,8.4,-22.9,8.3,-24.3,18.1,-25.5]);
  if(el){ wc.strokeStyle=P.brass[1]; wc.lineWidth=0.9; wc.beginPath(); wc.moveTo(6.7,-33.4); wc.lineTo(16.6,-32.3); wc.lineTo(18.4,-24.2);
    wc.moveTo(-12.4,-28.4); wc.lineTo(3,-28.4); wc.stroke(); }
  wc.fillStyle=P.gm[0]; wc.beginPath(); wc.rect(-14.2,-34.4,1.2,1.2); wc.rect(-0.8,-24.2,1.2,1.2); wc.rect(9,-24.8,1.2,1.2); wc.rect(-2.4,-38,1.2,1.2); wc.rect(16.4,-26.6,1.2,1.2); wc.fill();
  wc.fillStyle=P.steel; wc.beginPath(); wc.rect(15.6,-32.6,1.8,0.8); wc.rect(3.6,-43.6,1.2,0.8); wc.rect(-15.6,-20.4,1.6,0.8); wc.rect(1.6,-28.4,1.4,0.8); wc.fill();
  // ELITE: a brass antenna with a lamp
  if(el){ wc.strokeStyle=P.brass[0]; wc.lineWidth=1.2; wc.beginPath(); wc.moveTo(-1,-46.6); wc.lineTo(-2,-56); wc.stroke();
    wc.fillStyle=P.brass[1]; wc.beginPath(); wc.arc(-2,-56.4,1.5,0,6.2832); wc.fill(); }
  if(e.hitT>0){
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,70,56,'+clamp(e.hitT*2,0,.7)+')';
    mbPoly([-15.8,-19.2,-15.8,-35.6,-10.8,-44,3,-46,13.6,-41.2,17.6,-30,15.8,-19.2]);
    wc.globalCompositeOperation='source-over'; } else {  }
  }
  wc.restore();
  if(e.muzzle>0){
    if(!PIXM.baking){ wc.globalCompositeOperation='lighter';
    wc.fillStyle='#ffc04a'; wc.globalAlpha=clamp(e.muzzle*6,0,1)*flashK();
    wc.beginPath(); wc.arc(x+fl*32.4,y-27,7,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over'; } else {  }
  }
  drawWindupGlow(e,x+fl*32.4,y-27);
}
'@

SubRx @'
function drawWardenAt(e){
'@ @'
function drawWardenAt(e){
  if(pixOn()&&!PIXM.paint&&pixMachDraw(e,drawWardenS)) return wardenDrawScale(e); // v28.xx (cw-cx-pixmachines): boss size is baked, never applied to a finished sprite
'@

SubRx @'
function drawWindupGlow(e,gx,gy){
'@ @'
function drawWindupGlow(e,gx,gy){
  if(PIXM.baking) return; // v28.xx (cw-cx-pixmachines): charging ring remains live after the body
'@

SubRx @'
function sprEyeOf(e){
  var t=(typeof G!=='undefined'&&G)?(G.t||0):0;
'@ @'
function sprEyeOf(e){
  var t=pixMachTime(); // v28.xx (cw-cx-pixmachines): stable sensor state while baking
'@

SubRx @'
var _mm=machScaleBegin(e2); _svd+=_mm;   // v28.xx (cw-machbig): the machine body, shadow, elite ring, affix mark, windup glow and weak points all ride the bigger body
'@ @'
var _pm=pixOn()&&MACH_KIND[e2.kind]===1, _mm=_pm?0:machScaleBegin(e2); _svd+=_mm; // v28.xx (cw-cx-pixmachines): FIG_MACH is inside the art, not the finished blit
'@

SubRx @'
var _kb=animHitShift(e2); if(_kb){ wc.save(); _svd++; wc.translate(_kb.x,_kb.y); }   // v17.47: his pick 29, the hit jolt
'@ @'
var _kb=animHitShift(e2); if(_kb&&_pm){ _kb.x*=machMul(e2); _kb.y*=machMul(e2); } if(_kb){ wc.save(); _svd++; wc.translate(_kb.x,_kb.y); }   // v17.47: his pick 29, the hit jolt
'@

SubRx @'
      if(e2.elite&&e2.affix&&AFFIX[e2.affix]) drawAffixMark(e2);   // v26.xx (ai25): an affixed elite wears its own colour, not the purple ring
'@ @'
      var _em=_pm?machScaleBegin(e2):0; // v28.xx (cw-cx-pixmachines): live ground marks retain job 80 size
      if(e2.elite&&e2.affix&&AFFIX[e2.affix]) drawAffixMark(e2);   // v26.xx (ai25): an affixed elite wears its own colour, not the purple ring
'@

SubRx @'
else if(e2.elite&&!(pixOn()&&e2.kind==='raider'&&pxEliteRing(e2))){   // v33.81 (cw-pixgear) a20 A: a pillager bot elite ring is a baked pixel ring
'@ @'
else if(e2.elite&&!_pm&&!(pixOn()&&e2.kind==='raider'&&pxEliteRing(e2))){   // v33.81 (cw-pixgear) a20 A: a pillager bot elite ring is a baked pixel ring
'@

SubRx @'
      var _rm=null, _tlf=0, _tlh=0, _gb=null;   // v32.xx (cw-botlook): the body tell and the golden body
'@ @'
      machScaleEnd(_em);
      var _rm=null, _tlf=0, _tlh=0, _gb=null;   // v32.xx (cw-botlook): the body tell and the golden body
'@

SubRx @'
if(e2.elite&&e2.affix&&AFFIX[e2.affix]) _rm=rimOpen(e2,AFFIX[e2.affix].c);   // v26.xx (aip1): the elite outline
'@ @'
if(!_pm&&e2.elite&&e2.affix&&AFFIX[e2.affix]) _rm=rimOpen(e2,AFFIX[e2.affix].c);   // v26.xx (aip1): the elite outline
'@

SubRx @'
      if(e2.elite&&e2.affix&&AFFIX[e2.affix]) drawAffixTop(e2);   // v26.xx (ai25): its badge, shield bubble and mend beams
'@ @'
      var _ef=_pm?machScaleBegin(e2):0; // v28.xx (cw-cx-pixmachines): weak points and affix lights are live at the old size
      if(e2.elite&&e2.affix&&AFFIX[e2.affix]) drawAffixTop(e2);   // v26.xx (ai25): its badge, shield bubble and mend beams
'@

SubRx @'
      if(_kb){ wc.restore(); _svd--; }
'@ @'
      machScaleEnd(_ef);
      if(_kb){ wc.restore(); _svd--; }
'@

SubRx @'
if(!e||!e.golden||(pixOn()&&e.kind==='raider')||typeof wc==='undefined'||!wc||!wc.getTransform||!('filter' in wc)||(typeof G!=='undefined'&&G&&G.sim)||GOLDB.h) return null;
'@ @'
if(!e||!e.golden||(pixOn()&&(e.kind==='raider'||MACH_KIND[e.kind]===1))||typeof wc==='undefined'||!wc||!wc.getTransform||!('filter' in wc)||(typeof G!=='undefined'&&G&&G.sim)||GOLDB.h) return null;
'@

SubRx @'
function(){ return pixWrapBake(w,h,d,o.up==null?h*0.75:o.up,paint,x,y); }
'@ @'
function(){ var sp=pixWrapBake(w,h,d,o.up==null?h*0.75:o.up,paint,x,y,o.actor); return o.finish?o.finish(sp):sp; }
'@

SubRx @'
function pixWrapBake(w,h,d,up,paint,x,y){
'@ @'
function pixWrapBake(w,h,d,up,paint,x,y,actor){ // v28.xx (cw-cx-pixmachines): actors have no ground shadow in their body mask
'@

SubRx @'
if(a<64){ p[k+3]=0; continue; }
'@ @'
if(a<64||(actor&&a<128)){ p[k+3]=0; continue; } // v28.xx (cw-cx-pixmachines): one actor cutoff, matching the opaque silhouette
'@

SubRx @'
if(a<200&&(p[k]*3+p[k+1]*6+p[k+2])<400){ sh[i]=1; continue; }
'@ @'
if(!actor&&a<200&&(p[k]*3+p[k+1]*6+p[k+2])<400){ sh[i]=1; continue; } // v28.xx (cw-cx-pixmachines): prop shadow recovery must not grow actor edges
'@

SubRx @'
// ---- ?pixbench: every registered asset at 1x and 4x, and the ramp tables, on a plain page. pixReg(name, fn) registers an asset: fn() returns a pixSprite ----
'@ @'
// v28.xx (cw-cx-pixmachines): his 10-20 order, "I want to do it all now before the party". Existing designs, baked at their full job 80 size. No simulation writes or random draws.
var PIXM={paint:0,baking:0,time:0,paints:0,draws:0,near:0,last:null,halo:null};
gfxStore('pixmachines',function(){PIXM.halo=null;PIXM.last=null;});
function pixMachTime(){ return PIXM.baking?PIXM.time:((typeof G!=='undefined'&&G&&G.t)||0); }
function pixMachKind(e){ return e.kind==='warden'&&(e.boss||e.name===BOSS_NAME)?'overseer':e.kind; }
function pixMachEye(e){
  if(e.kind==='listener') return e.state==='dormant'?0:2;
  if(e.overheat>0) return 3;
  if(e.state==='chase'||e.state==='alarm'||e.seenYou) return 2;
  if(e.state==='investigate'||e.state==='search') return 1;
  return 0;
}
function pixMachPose(e){
  var k=pixMachKind(e), t=pixMachTime(), ph=e.step||0, eye=pixMachEye(e), a=((Math.round((e.face||0)*8/Math.PI)%16)+16)%16;
  if(k==='sentry') ph*=1.5;
  else if(k==='crawler') ph=e.legs||0;
  else if(k==='bulwark') ph*=2.2;
  else if(k==='howler') ph*=2.4;
  else if(k==='warden'||k==='overseer') ph*=7/4.8*Math.PI*2;
  else if(k==='listener') ph=(e.legs||0)*0.6;
  else if(k==='choir') ph=t*0.20;
  else ph=t*6;
  var f=Math.floor(((ph/(Math.PI*2))%1+1)%1*4)%4, mir=Math.cos(e.face||0)<0?1:0, q={}, n, phase=f*Math.PI/2, m=machMul(e)*(e.kind==='warden'?wardenDrawScale(e):1), size=1;
  if(e.kind==='sentry') size=e.r/SENTRY_R0;
  if(e.kind==='crawler') size=e.r/CRAWLER_R0;
  if(e.kind==='snitch') size=e.r/SNITCH_R0;
  for(n in {kind:1,boss:1,name:1,r:1,hp:1,state:1,seenYou:1,elite:1,golden:1,overheat:1,affix:1,moving:1}) q[n]=e[n];
  q.x=0; q.y=0; q.face=a*Math.PI/8;
  if(Math.abs(Math.cos(q.face))<1e-6) q.face+=(mir?1:-1)*(a===4?1:-1)*1e-8;
  q.step=phase/(k==='sentry'?1.5:(k==='bulwark'?2.2:(k==='howler'?2.4:((k==='warden'||k==='overseer')?7/4.8*Math.PI*2:1))));
  q.legs=phase/(k==='listener'?0.6:1); q.hitT=0; q.muzzle=0; q.windup=null; q.wind=null;
  var fam='mach|'+k+'|'+mir+'|'+eye+'|'+(e.elite?1:0)+'|'+(e.golden?1:0)+'|'+m+'|'+size+'|'+(e.moving?1:0)+'|'+e.state+'|'+(e.seenYou?1:0)+'|'+(e.affix||'')+'|'+(isDay()?'d':'n');
  return {q:q,k:k,f:f,a:a,mir:mir,eye:eye,m:m,size:size,day:isDay(),fam:fam,key:fam+'|'+f+'|'+a,time:k==='choir'?phase/0.20:0};
}
function pixMachNearest(p){
  var best=null, bd=1e9;
  PIXSTORE.m.actors.forEach(function(s){
    var q=s.mp, da, df, d;
    if(!q||q.k!==p.k||q.m!==p.m||q.size!==p.size||q.day!==p.day||!!q.q.elite!==!!p.q.elite||!!q.q.golden!==!!p.q.golden||(q.q.affix||'')!==(p.q.affix||'')) return;
    da=Math.abs(q.a-p.a); df=Math.abs(q.f-p.f); d=Math.min(da,16-da)*4+Math.min(df,4-df)+(q.eye!==p.eye?80:0)+(q.mir!==p.mir?160:0)+(!!q.q.moving!==!!p.q.moving?12:0)+(q.q.state!==p.q.state?8:0);
    if(d<bd){bd=d;best=s;}
  });
  if(best) PIXM.near++;
  return best;
}
function pixMachFinish(s,p){
  var im, b, i, L, c, ring, r, col=p.q.affix&&AFFIX[p.q.affix]?AFFIX[p.q.affix].c:'#d08ce8';
  if(p.q.golden){
    im=s.c.getContext('2d').getImageData(0,0,s.c.width,s.c.height); b=im.data;
    for(i=0;i<b.length;i+=4){
      if(!b[i+3]) continue;
      L=b[i]*0.3+b[i+1]*0.59+b[i+2]*0.11;
      c=L<26?[22,18,28]:(L<55?[110,76,16]:(L<95?[180,138,28]:(L<145?[240,200,64]:[255,240,160])));
      b[i]=c[0]; b[i+1]=c[1]; b[i+2]=c[2];
    }
    s.c.getContext('2d').putImageData(im,0,0);
  }
  ring=pixRing(s.c,PIX_INK,0,1); r=pixSprite(ring.c,s.ax+1,s.ay+1,PIX_ACT); r.mp=p;
  r.flash=pixSprite(pixSilhouette(r.c,'#ff4638').c,r.ax,r.ay,PIX_ACT);
  r.bytes+=r.flash.bytes;
  if(p.q.elite){
    ring=pixRing(r.c,col,0,0);ring.x.globalCompositeOperation='destination-out';ring.x.drawImage(r.c,1,1);ring.x.globalCompositeOperation='source-over';
    r.edge=pixSprite(ring.c,r.ax+1,r.ay+1,PIX_ACT); r.bytes+=r.edge.bytes;
  }
  return r;
}
// v28.xx (cw-cx-pixmachines): shadows are live ground art; the mask contains only the body, so a hit never paints the floor.
function pixMachShadow(e,p){
  var k=e.kind, S=p.size, rx=20*S, ry=7*S, yy=2, alpha=.46;
  if(k==='crawler'){rx=15*S;ry=5*S;yy=1;alpha=.44;}
  else if(k==='snitch'){rx=8*S;ry=3*S;yy=1;alpha=.32;}
  else if(k==='warden'){rx=26;ry=8;alpha=.45;}
  else if(k==='choir'){rx=30;ry=10;yy=3;alpha=.5;}
  else if(k==='listener'){rx=10;ry=4;yy=1;alpha=.4;}
  else if(k==='howler'){rx=e.r*.9;ry=4;alpha=.35;}
  else if(k==='bulwark'){rx=e.r*.95;ry=4;alpha=.36;}
  shadowE(e.x,e.y+yy*p.m,rx*p.m,ry*p.m,alpha);
}
function pixMachGlow(x,y,r,col,a){
  wc.save(); wc.globalCompositeOperation='lighter'; wc.fillStyle=col;
  wc.globalAlpha*=a*.16; wc.beginPath(); wc.arc(x,y,r,0,Math.PI*2); wc.fill();
  wc.globalAlpha*=2; wc.beginPath(); wc.arc(x,y,r*.55,0,Math.PI*2); wc.fill(); wc.restore();
}
function pixMachListenerGlow(x,y,a){
  if(!PIXM.halo){
    var s=pixCanvas(54,54),g=s.x.createRadialGradient(27,27,1,27,27,26);
    g.addColorStop(0,'#ff5a4a');g.addColorStop(1,'rgba(0,0,0,0)');s.x.fillStyle=g;s.x.beginPath();s.x.arc(27,27,26,0,Math.PI*2);s.x.fill();PIXM.halo=s.c;
  }
  wc.save();wc.globalCompositeOperation='lighter';wc.globalAlpha*=a;wc.drawImage(PIXM.halo,x-27,y-27);wc.restore();
}
function pixMachAlarm(e){
  if(e.state!=='alarm'||e.wind===undefined||e.wind===null) return;
  var S=e.r/SNITCH_R0, hov=(17+Math.sin(pixMachTime()*6+e.x*.1)*4)*S;
  CACHETAGS.push({t:'alarm',x:e.x,y:e.y-(hov+30*S)*machMul(e),c:'#ff5040',f:TYPE.label,always:1});
}
// v28.xx (cw-cx-pixmachines): all light is live after the cached body. Coordinates use the pose actually blitted on a budget miss.
function pixMachLive(e,p,dy){
  var q=p.q,k=e.kind,S=p.size,fl=p.mir?-1:1,t=pixMachTime(),E=sprEyeOf(e),phase=p.f*Math.PI/2,ey,ex,bob=k==='sentry'&&q.moving?-Math.abs(Math.cos(phase))*1.2:0;
  wc.save(); wc.translate(e.x,e.y+dy); wc.scale(p.m,p.m);
  function eye(x,y,r){
    if(E.h) pixMachGlow(x,y,r*E.h,E.c,E.a);
  }
  if(k==='sentry'){
    eye(fl*7.8*S,(bob-43.6)*S,1.7*S);
    drawWindupGlow(e,fl*7.8*S,(bob-43.6)*S);
    if(e.muzzle>0){
      wc.save();wc.translate(fl*12.2*S,(bob-36.8)*S);wc.rotate(q.face);if(fl<0)wc.scale(1,-1);
      pixMachGlow(30*S,-1.6*S,6*S,'#ffc27a',flashK());pixMachGlow(30*S,1.6*S,6*S,'#ffc27a',flashK());wc.restore();
    }
  }else if(k==='crawler'){
    var hy=-13.5+(q.state==='chase'?2:0), eyes=e.elite?[[17,-1.3,1.5],[13.9,-2.4,1],[14.6,.9,1],[18.2,1.3,.8]]:[[17,-1.3,1.5],[13.9,-2.4,1],[14.6,.9,1]];
    eyes.forEach(function(v){eye(fl*v[0]*S,(hy+v[1])*S,v[2]*S);});
  }else if(k==='listener'){
    if(e.state!=='dormant'){
      var sway=Math.sin(q.legs*.6)*2.2; ex=sway*1.2; ey=-47;
      pixMachListenerGlow(ex,ey,.5*(.55+.45*Math.sin(t*7)));
    }
  }else if(k==='warden'){
    eye(fl*(p.k==='overseer'?9.4:10.4),p.k==='overseer'?-39.2:-38.3,p.k==='overseer'?3.3:2);
    if(p.k==='overseer') [[3.4,-55.8],[9.4,-58.8],[15.6,-55]].forEach(function(v){pixMachGlow(fl*v[0],v[1],3,'#ff3b30',.55+.35*Math.sin(t*4));});
    if(e.muzzle>0)pixMachGlow(fl*32.4,-27,9,'#ffc04a',clamp(e.muzzle*6,0,1)*flashK());
    drawWindupGlow(e,fl*32.4,-27);
  }else if(k==='howler'){
    eye(fl*8.6,-19.4,1.8);
  }else if(k==='bulwark'){
    eye(Math.cos(q.face)*.4,-32.4,1.9);
  }else if(k==='choir'){
    ex=Math.cos(q.face)*17;ey=-24+Math.sin(q.face)*5;
    eye(ex,ey+.4,p.eye===2?5.2:(p.eye===3?4.2:2.2));
    if(e.overheat>0) for(var v=0;v<3;v++)pixMachGlow((v-1)*10,-52-((t*40+v*14)%24),4.6,'#ff8a3c',.42);
    if(e.muzzle>0)pixMachGlow(ex,ey,8,'#ffb070',clamp(e.muzzle*6,0,1)*flashK());
  }else if(k==='snitch'){
    var tilt=fl*.1, al=e.state==='alarm', hov=17*S, ox=0, oy=-hov-7*S;
    var hmx=(fl*9.6*S)*Math.cos(tilt)-(4.6*S)*Math.sin(tilt),hmy=oy+(fl*9.6*S)*Math.sin(tilt)+(4.6*S)*Math.cos(tilt);
    if(al&&e.wind!==undefined&&e.wind!==null){
      var wf=1-clamp(e.wind/4,0,1), pulse=(t*2)%1;
      wc.save();wc.globalCompositeOperation='lighter';wc.strokeStyle='rgba(255,59,48,'+(.5*(1-pulse))+')';wc.lineWidth=2.5*S;
      wc.beginPath();wc.arc(hmx,hmy,(16+44*pulse)*S,0,Math.PI*2);wc.stroke();
      wc.strokeStyle='#ff3b30';wc.lineWidth=3*S;wc.beginPath();wc.arc(hmx,hmy,22*S,-Math.PI/2,-Math.PI/2+Math.PI*2*wf);wc.stroke();wc.restore();
    }
    wc.save();wc.translate(ox,oy);wc.rotate(tilt);wc.scale(fl*S,S);
    eye(0,-6.6,1.5);if(e.elite)eye(-3.8,-6.2,1.5);
    if(al)pixMachGlow(10.6,4.6,6.2,'#ff3b30',.35+.25*Math.sin(t*16));
    [[-7.5,-4.6],[7.5,-4.6],[-10.5,.6],[10.5,.6]].forEach(function(v,i){
      var a=t*(al?38:24)+i*1.7,bx=Math.cos(a)*6,by=Math.sin(a)*1.6;
      wc.save();wc.globalCompositeOperation='lighter';wc.fillStyle=al?'rgba(255,140,110,.22)':'rgba(190,210,225,.25)';
      wc.beginPath();wc.ellipse(v[0],v[1]-2.2,6.4,1.9,0,0,Math.PI*2);wc.fill();wc.strokeStyle='rgba(220,232,240,.45)';wc.lineWidth=.9;
      wc.beginPath();wc.moveTo(v[0]-bx,v[1]-2.2-by);wc.lineTo(v[0]+bx,v[1]-2.2+by);wc.stroke();wc.restore();
    });wc.restore();
  }
  wc.restore();
  if(k==='snitch')pixMachAlarm(e);
}
function pixMachDraw(e,paint){
  if(PIXM.paint||!MACH_KIND[e.kind]||!pixOn()||(typeof G!=='undefined'&&G&&G.sim))return false;
  var T=wc.getTransform(),p=pixMachPose(e),key=p.key,s=null,near=null,oldShadow=shadowE,oldTime=PIXM.time,box,dy=0;
  if(!(T.a>0)||!(T.d>0)||T.b||T.c)return false;
  if(e.kind==='warden')paint=drawWardenS;
  var boxes={sentry:[110,106,90],crawler:[66,40,33],snitch:[64,56,52],listener:[44,66,60],choir:[76,88,78],warden:[92,90,78],howler:[64,66,58],bulwark:[80,96,68]};
  box=boxes[e.kind];
  if(!PIXSTORE.m.actors.has(key+'|'+PIX_ACT+(isDay()?'d':'n'))&&(PIX.fB>=PIXSTORE.maxBuilds||PIX.fMs>=PIXSTORE.maxMs)){
    near=pixMachNearest(p);if(near){p=near.mp;key=p.key;}
  }
  if(e.kind==='snitch')dy=-Math.sin(pixMachTime()*6+e.x*.1)*4*p.size*p.m;
  function body(){
    PIXM.paint=1;PIXM.baking=1;PIXM.time=p.time;PIXM.paints++;shadowE=function(){};
    wc.save();wc.translate(e.x,e.y+dy);wc.scale(p.m,p.m);
    try{paint(p.q);}finally{wc.restore();shadowE=oldShadow;PIXM.time=oldTime;PIXM.baking=0;PIXM.paint=0;}
  }
  pixMachShadow(e,p);wc.save();
  try{
    s=pixWrap(key,2*Math.ceil(box[0]*p.m*p.size/2),Math.ceil(box[1]*p.m*p.size),PIX_ACT,body,e.x,e.y+dy,{actor:true,up:Math.ceil(box[2]*p.m*p.size),finish:function(sp){return pixMachFinish(sp,p);}});
  }finally{wc.restore();}
  if(!s){
    // v28.xx (cw-cx-pixmachines): a cold kind has no nearest pose yet; the existing vector art remains visible until its budget slot arrives.
    wc.save();wc.translate(e.x,e.y);wc.scale(p.m,p.m);wc.translate(-e.x,-e.y);PIXM.paint=1;
    shadowE=function(){};try{paint(e);}finally{shadowE=oldShadow;PIXM.paint=0;wc.restore();}return true;
  }
  PIXM.last=s;PIXM.draws++;p=s.mp;
  // v28.xx (cw-cx-pixmachines): the adapter already blitted the body; ring-only pixels never cover it, and the hit uses the exact same silhouette.
  if(s.edge){wc.save();wc.globalAlpha*=.55+.25*Math.sin(pixMachTime()*3.2+e.x*.02);pixBlit(s.edge,T.a*e.x+T.e,T.d*(e.y+dy)+T.f,false,wc,T.a*PIX_ACT);wc.restore();}
  if(e.hitT>0){wc.save();wc.globalAlpha*=clamp(e.hitT*2,0,.7);pixBlit(s.flash,T.a*e.x+T.e,T.d*(e.y+dy)+T.f,false,wc,T.a*PIX_ACT);wc.restore();}
  pixMachLive(e,p,dy);return true;
}
function pixMachSample(k){
  var kind=k==='overseer'?'warden':k,r=kind==='sentry'?SENTRY_R0:(kind==='crawler'?CRAWLER_R0:(kind==='snitch'?SNITCH_R0:(kind==='warden'?(k==='overseer'?44:30):22)));
  return {kind:kind,boss:k==='overseer'?1:0,name:k==='overseer'?BOSS_NAME:k,x:0,y:0,r:r,hp:400,maxhp:400,face:0,step:0,legs:0,moving:false,state:'patrol',seenYou:false,overheat:0,hitT:0,muzzle:0,windup:null,wind:null};
}
function pixMachPainter(k){return {sentry:drawSentryS,crawler:drawCrawlerS,snitch:drawSnitchS,listener:drawListenerS,choir:drawChoirS,warden:drawWardenS,overseer:drawWardenAt,howler:drawHowlerS,bulwark:drawBulwarkS}[k];}
// v28.xx (cw-cx-pixmachines): the same nine actual bodies are available on ?pixbench, at their common actor density.
pixReg('machines',function(){
  var old=wc,cfg=CFG.xfPix,s=pixCanvas(920,210),names=['sentry','crawler','snitch','bulwark','howler','listener','choir','warden','overseer'];
  try{CFG.xfPix=1;wc=s.x;names.forEach(function(k,i){var e=pixMachSample(k);e.x=50+i*100;e.y=170;pixFrame();pixMachPainter(k)(e);});}finally{wc=old;CFG.xfPix=cfg;}
  return pixSprite(s.c,0,0,PIX_ACT);
});
// ---- ?pixbench: every registered asset at 1x and 4x, and the ramp tables, on a plain page. pixReg(name, fn) registers an asset: fn() returns a pixSprite ----
'@

SubRx @'
var VER='33.88';
'@ @'
var VER='33.89';
'@

$pat = "(?m)^  now:'v33\.88:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.89: Machines use cached pixel bodies. Gold, elite outlines and hit masks are baked. Charging rings and weak points stay live. Check 33.89 fails on v33.88',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
