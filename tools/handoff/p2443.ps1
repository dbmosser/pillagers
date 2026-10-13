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

# THE CRIER, REDRAWN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawSnitchS(e){
  var S=e.r/SNITCH_R0;
  var al=e.state==='alarm';
  var hov=(17+Math.sin(G.t*6+e.x*.1)*4)*S;
  shadowE(e.x,e.y+1,8*S,3*S,.32);
  var cy=e.y-hov;
  // SPEC 8.3: visually distinctive at a distance so it can be identified and
  // prioritised. A winding snitch throws an expanding red alarm ring and a
  // filling countdown arc, so from across the map you can see one is calling
  // and how long you have left to stop it.
  if(al&&e.wind!==undefined&&e.wind!==null){
    var wf=1-clamp(e.wind/4,0,1);
    wc.globalCompositeOperation='lighter';
    var pulse=(G.t*2)%1;
    wc.strokeStyle='rgba(255,59,48,'+(0.5*(1-pulse))+')'; wc.lineWidth=2.5*S;
    wc.beginPath(); wc.arc(e.x,cy,(16+44*pulse)*S,0,6.2832); wc.stroke();
    wc.strokeStyle='#ff3b30'; wc.lineWidth=3*S;
    wc.beginPath(); wc.arc(e.x,cy,22*S,-1.5708,-1.5708+6.2832*wf); wc.stroke();
    wc.globalCompositeOperation='source-over';
    wc.font=FS(TYPE.label); wc.textAlign='center';
    wc.fillStyle=INK; wc.fillText('ALARM',e.x+1,cy-30*S+1);
    wc.fillStyle='#ff5040'; wc.fillText('ALARM',e.x,cy-30*S);
    wc.textAlign='left';
  }
  // rotor blur, faster when it is running its mouth
  wc.globalCompositeOperation='lighter';
  wc.strokeStyle=al?'rgba(255,120,90,.30)':'rgba(150,175,200,.22)';
  wc.lineWidth=1.4*S;
  var rr=13*S+Math.sin(G.t*(al?26:15))*1.5*S;
  wc.beginPath(); wc.ellipse(e.x,cy-9*S,rr,4*S,0,0,6.2832); wc.stroke();
  wc.globalCompositeOperation='source-over';
  wc.save(); wc.translate(e.x,cy-7*S); wc.rotate(.785+G.t*1.2);
  // Ink plate, body, shade band, light top lip. The light outline this used to
  // carry is what made it visible at night at all, so it keeps a bright lip
  // rather than going to pure contour like everything else.
  wc.fillStyle=INK; wc.fillRect(-9.4*S,-9.4*S,18.8*S,18.8*S);
  wc.fillStyle='#6b7684'; wc.fillRect(-8*S,-8*S,16*S,16*S);
  wc.fillStyle='#4d5765'; wc.fillRect(-8*S,-8*S,16*S,5*S);
  wc.fillStyle='#9fb0c2'; wc.fillRect(-8*S,-8*S,16*S,1.4*S);
  wc.restore();
  var on=al?(Math.sin(G.t*16)>0):(Math.sin(G.t*4)>-.4);
  if(on){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle=al?'#ff3a2a':'#ffc04a';
    wc.globalAlpha=.32;
    wc.beginPath(); wc.arc(e.x,cy-19*S,7*S,0,6.2832); wc.fill();
    wc.globalAlpha=1;
    wc.beginPath(); wc.arc(e.x,cy-19*S,3*S,0,6.2832); wc.fill();
    wc.globalCompositeOperation='source-over';
  }
}

'@ @'
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

'@

SubRx @'
var VER='24.42';
'@ @'
var VER='24.43';
'@

$pat = "(?m)^  now:'v24\.42:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.43: The Crier is redrawn as a loudspeaker drone: four rotors, a horn, and the alarm comes out of the horn. Check 24.43 fails on v24.42',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
