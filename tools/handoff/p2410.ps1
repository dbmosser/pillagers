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

# THE SENTRY, REDRAWN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawSentryS(e){
  var S=e.r/SENTRY_R0,fl=Math.cos(e.face)<0?-1:1;
  var hunting=e.state==='chase',alerted=hunting||e.state==='investigate';
  var churn=Math.sin((e.step||0)*3)*1.4*S;
  shadowE(e.x,e.y+2,20*S,7*S,.46);
  // tread base
  wc.fillStyle='#1b2027';
  wc.fillRect(e.x-18*S,e.y-11*S,36*S,11*S);
  wc.fillStyle='#2b333c';
  for(var t=0;t<5;t++) wc.fillRect(e.x-17*S+t*7*S+churn,e.y-10*S,4*S,9*S);
  wc.fillStyle='#39424d'; wc.fillRect(e.x-18*S,e.y-13*S,36*S,3*S);
  // hull
  wc.fillStyle='#4b535d'; wc.fillRect(e.x-15*S,e.y-33*S,30*S,21*S);
  wc.fillStyle='#3a424b'; wc.fillRect(e.x-15*S,e.y-33*S,30*S,5*S);
  wc.fillStyle='#5d6773'; wc.fillRect(e.x-15*S,e.y-35*S,30*S,3*S);
  // hazard stripe so it reads as industrial even in the dark
  wc.fillStyle=alerted?'#8a3a22':'#6a5a28';
  wc.fillRect(e.x-15*S,e.y-22*S,30*S,3*S);
  // shoulder armour on the gun side
  wc.fillStyle='#39414b'; wc.fillRect(e.x+fl*9*S-7*S,e.y-31*S,14*S,10*S);
  // sensor head
  wc.fillStyle='#333b45'; wc.fillRect(e.x+fl*7*S-8*S,e.y-46*S,16*S,12*S);
  wc.fillStyle='#4a535e'; wc.fillRect(e.x+fl*7*S-8*S,e.y-46*S,16*S,2.5*S);
  var ec=hunting?'#ff3a2a':(e.state==='investigate'?'#ffc04a':'#ffc04a');
  wc.globalCompositeOperation='lighter';
  wc.fillStyle=ec;
  // eye plus a halo that swells while hunting
  var pulse=hunting?(1+Math.sin(G.t*9)*.25):1;
  wc.globalAlpha=.30;
  wc.beginPath(); wc.arc(e.x+fl*12*S,e.y-40*S,7*S*pulse,0,6.2832); wc.fill();
  drawWindupGlow(e,e.x+fl*12*S,e.y-40*S);
  wc.globalAlpha=1;
  wc.beginPath(); wc.arc(e.x+fl*12*S,e.y-40*S,3.4*S,0,6.2832); wc.fill();
  wc.globalCompositeOperation='source-over';
  // gun
  wc.save(); wc.translate(e.x,e.y-25*S); wc.rotate(e.face);
  wc.fillStyle='#2b323b'; wc.fillRect(2*S,-4*S,10*S,8*S);
  wc.fillStyle='#333b45'; wc.fillRect(10*S,-2.6*S,18*S,5.2*S);
  wc.fillStyle='#242a31'; wc.fillRect(26*S,-3.4*S,4*S,6.8*S);
  if(e.muzzle>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,194,122,.95)';
    wc.beginPath(); wc.arc(31*S,0,7*S,0,6.2832); wc.fill();
    wc.globalCompositeOperation='source-over';
  }
  wc.restore();
}

'@ @'
// v23.xx (spr2), HIS ORDER (2026-10-12): "improve the sprites of all characters, bots, etc -- spend time on that -- make them
// all look better", gritty and grounded like ARC Raiders (his answer 20 "a"), silhouettes first (answer 24 "b"). The sprite
// program (tools/handoff/research/sprites-design-2026-10-12.md), MACHINES A, build 1: THE SENTRY. It was a grey filing cabinet
// on a skateboard: no ink contour (it melted into a dark floor), one flat grey, a thin single barrel, an amber eye even when it
// had seen nothing. It is redrawn in the machine style: an INK contour round the tread, hull, head and gun; tread teeth that
// run as it rolls; a lit top plate, lit left rim and shaded right face (one light, from the top left); a sloped glacis on the
// side it faces; two ochre hazard chevrons; rivets, seams and a few chips of bare metal at fixed spots; a camera head on a mast
// with a round lens that speaks the sensor language (dim cool white idle, amber suspicious, red hunting, orange venting); a
// whip antenna; a twin-barrel gun under a perforated cooling shroud. The whole body turns with its facing. An elite wears a
// brass edge and a second antenna. Drawn only: no random numbers, nothing written on the machine, its size and shadow as before.
// sprMR and sprMP draw a rect or a closed path in the machine own frame: lx forward of its centre (mirrored by fl), feet at ox,oy.
function sprMR(ox,oy,fl,S,lx,ly,w,h){ wc.fillRect(fl>0?ox+lx*S:ox-(lx+w)*S,oy+ly*S,w*S,h*S); }
function sprMP(ox,oy,fl,S,p){ wc.beginPath(); wc.moveTo(ox+fl*p[0]*S,oy+p[1]*S); for(var i=2;i<p.length;i+=2) wc.lineTo(ox+fl*p[i]*S,oy+p[i+1]*S); wc.closePath(); }
// THE SENSOR LANGUAGE, one face for every machine: idle a dim cool white with no halo, suspicious amber, hunting red and
// pulsing (its halo at most 1.6 times the lens), venting an orange flicker, dead black. c colour, a alpha, h halo factor.
function sprEyeOf(e){
  var t=(typeof G!=='undefined'&&G)?(G.t||0):0;
  if(!e||e.hp<=0) return {c:'#000000',a:1,h:0};
  if((e.overheat||0)>0) return {c:'#ff8a3c',a:0.65+0.35*Math.sin(t*22),h:1.3};
  if(e.state==='chase'||e.state==='alarm'||e.seenYou) return {c:'#ff3b30',a:0.85+0.15*Math.sin(t*9),h:1.6};
  if(e.state==='investigate'||e.state==='search') return {c:'#ffc04a',a:0.9,h:1.3};
  return {c:'#dfe9f0',a:0.5,h:0};
}
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
    wc.fillStyle='rgba(255,194,122,.95)';
    wc.beginPath(); wc.arc(32*S,-1.6*S,4.2*S,0,6.2832); wc.fill();
    wc.beginPath(); wc.arc(32*S,1.6*S,4.2*S,0,6.2832); wc.fill();
    wc.globalCompositeOperation='source-over';
  }
  wc.restore();
}

'@

SubRx @'
var VER='24.09';
'@ @'
var VER='24.10';
'@

$pat = "(?m)^  now:'v24\.09:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.10: The Sentry is redrawn: outlined, lit, a camera eye that shows its mood, twin barrels. Check 24.10 fails on v24.09',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
