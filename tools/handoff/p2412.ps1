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

# THE WARDEN REDESIGN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v17.49, polish after his pick 21: THE OVERSEER is drawn to its size.
'@ @'
// v23.xx (spr9), HIS ORDER (2026-10-12): "improve the sprites of all characters, bots, etc -- spend time on that -- make them all
// look better", gritty and grounded like ARC Raiders (his answer 20), silhouettes first (his answer 24). THE WARDEN REDESIGN
// (tools/handoff/research/sprites-design-2026-10-12.md, MACHINES B 1). It was a purple dustbin on treads with a yellow letterbox
// and a stub: purple is the elite colour, the hull never turned, the tread barely moved and the hunting halo washed the whole face
// pink. Now it is a hunched walker-tank: twin tracks whose links run with its travel (e.step) over four road wheels, a sloped
// chassis, a heavy gunmetal torso leaning toward its facing with oxide plates on the shoulder and the belly, a low visor slit
// in the sensor language (dim white idle, amber investigating, red hunting, orange venting; halo kept small), a cannon arm with
// a hydraulic piston on the facing side, a launcher pod with a 2x2 rack of tubes on the off side, exhaust stacks, rivets,
// chipped edges and a grime band. The whole hull mirrors with its facing. Elite wears brass trim and a brass antenna.
// MBPAL and mbEye are the machine palette and sensor language for the MACHINES B group. Cosmetic only: the raid clock and
// e.step are read, nothing is written, no draw from the raid stream; the collision radius, the shadow and the weak points
// (weakPos) are unchanged.
var MBPAL={ink:'#120e0c',gm:['#2a2f35','#3e454c','#59626b','#7c868f'],ox:['#4e2419','#7a3a2a','#9c5038'],och:'#c8962e',
  brass:['#8a6a2a','#c9a24a'],rub:'#1b1f24',tooth:'#353d46',steel:'#a3aeb8',grime:'rgba(46,30,18,.38)'};
function mbEye(e,T){
  if((e.overheat||0)>0) return ['#ff8a3c',.55+.35*Math.sin(T*14),1];
  if(e.seenYou||e.state==='chase'||e.state==='hunt') return ['#ff3b30',.75+.25*Math.sin(T*9),2];
  if(e.state==='investigate') return ['#ffc04a',.8,1];
  return ['#dfe9f0',.45,0];
}
function mbPoly(p){ wc.beginPath(); wc.moveTo(p[0],p[1]); for(var i=2;i<p.length;i+=2) wc.lineTo(p[i],p[i+1]); wc.closePath(); wc.fill(); }
// v17.49, polish after his pick 21: THE OVERSEER is drawn to its size.
'@

SubRx @'
}function drawWardenS(e){
  var x=e.x,y=e.y,tread=Math.sin(G.t*3+x*.01)*1.5;
  shadowE(x,y+2,26,8,.45);
  wc.fillStyle=INK; rrF(x-19,y-14,38,15,4);
  wc.fillStyle='#2a2430'; rrF(x-18,y-13,36,13,3);
  wc.fillStyle='#1a161f';
  for(var t2=0;t2<4;t2++) wc.fillRect(x-16+t2*8.6,y-12+((t2%2)?tread:-tread)*.4,6,11);
  wc.fillStyle=INK; rrF(x-16,y-46,32,34,6);
  wc.fillStyle='#463a50'; rrF(x-15,y-45,30,32,5);
  wc.fillStyle='#5d4e6a'; wc.fillRect(x-13,y-45,26,7);
  wc.fillStyle='#2e2636'; wc.fillRect(x-13,y-17,26,3);
  // scarring
  wc.fillStyle='rgba(20,14,10,.5)';
  wc.fillRect(x-9,y-40,3,14); wc.fillRect(x+5,y-33,4,9);
  // cannon arm
  var fl2=Math.cos(e.face)>=0?1:-1;
  wc.fillStyle=INK; rrF(x+fl2*10-2,y-38,fl2*16+ (fl2>0?4:-4),9,3);
  wc.fillStyle='#241e2c'; rrF(x+fl2*11-1,y-37,fl2*14+(fl2>0?2:-2),7,2);
  // the eye: a slit that tracks you
  var hunting=e.seenYou;
  wc.fillStyle=INK; rrF(x-11,y-41,22,9,4);
  wc.globalCompositeOperation='lighter';
  wc.fillStyle=hunting?'#ff3b30':'#ffc04a';
  wc.globalAlpha=hunting?(.75+.25*Math.sin(G.t*9)):.5;
  wc.fillRect(x-8+Math.cos(e.face)*3,y-39,16,4);
  wc.globalAlpha=.25;
  wc.beginPath(); wc.arc(x,y-37,hunting?16:9,0,6.2832); wc.fill();
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  if(e.hitT>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,70,56,'+clamp(e.hitT*2,0,.7)+')';
    rrF(x-15,y-45,30,32,5);
    wc.globalCompositeOperation='source-over';
  }
  if(e.muzzle>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='#ffc04a'; wc.globalAlpha=clamp(e.muzzle*6,0,1);
    wc.beginPath(); wc.arc(x+fl2*26,y-34,7,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  }
  drawWindupGlow(e,x+fl2*26,y-34);
}

'@ @'
}function drawWardenS(e){
  var x=e.x,y=e.y,P=MBPAL,fl=Math.cos(e.face)>=0?1:-1,st=(e.step||0),el=!!e.elite,i,a,tx;
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
  // TORSO: hunched forward, lit on top, shaded on the front face, grime low
  wc.fillStyle=P.ink; mbPoly([-17,-18,-17,-36,-11.5,-45.2,3,-47.2,14.6,-42,19,-30,17,-18]);
  wc.fillStyle=P.gm[2]; mbPoly([-15.8,-19.2,-15.8,-35.6,-10.8,-44,3,-46,13.6,-41.2,17.6,-30,15.8,-19.2]);
  wc.fillStyle=P.gm[3]; mbPoly([-10.8,-44,3,-46,13.6,-41.2,11,-39,-9,-39.6]);
  wc.fillStyle=P.gm[1]; mbPoly([13.6,-41.2,17.6,-30,15.8,-19.2,11.6,-19.2,13.4,-30.5,11,-39]);
  wc.fillStyle=P.grime; wc.fillRect(-15.8,-23.4,29,4.2);
  wc.fillStyle=P.gm[0]; wc.fillRect(-15.8,-31.2,27.2,0.9);
  // LAUNCHER POD on the off shoulder: a 2x2 rack of tube mouths
  wc.fillStyle=P.ink; rrF(-23,-43,12.4,12.6,2.4);
  wc.fillStyle=P.gm[1]; rrF(-21.8,-41.8,10,10.2,1.8);
  wc.fillStyle=P.gm[2]; wc.fillRect(-21.8,-41.8,10,1.6);
  wc.fillStyle=P.ink; wc.beginPath();
  for(i=0;i<4;i++){ wc.moveTo(-19.2+(i%2)*4.8+1.7,-37.6+((i>>1)*4.6)); wc.arc(-19.2+(i%2)*4.8,-37.6+((i>>1)*4.6),1.7,0,6.2832); } wc.fill();
  wc.fillStyle=P.och; wc.fillRect(-21.8,-33.2,10,1.0);
  // BELLY PLATE: oxide, hazard stencils
  wc.fillStyle=P.ink; rrF(-13.4,-29.4,17.4,9.4,2);
  wc.fillStyle=P.ox[1]; rrF(-12.4,-28.4,15.4,7.4,1.5);
  wc.fillStyle=P.ox[2]; wc.fillRect(-12.4,-28.4,15.4,1.2);
  wc.fillStyle=P.och; mbPoly([-10.4,-26.6,-7.6,-26.6,-9.8,-22.6,-12.4,-22.6]); mbPoly([-5.6,-26.6,-2.8,-26.6,-5,-22.6,-7.8,-22.6]);
  // THE HEAD: set low between the shoulders, a visor slit in the sensor language
  wc.fillStyle=P.ink; rrF(1.4,-45,16,11.6,3);
  wc.fillStyle=P.gm[1]; rrF(2.6,-43.8,13.6,9.2,2.2);
  wc.fillStyle=P.gm[3]; wc.fillRect(3.4,-43.8,12,1.5);
  wc.fillStyle=P.ink; rrF(4.2,-40.6,12.4,4.8,1.8);
  var E=mbEye(e,G.t);
  wc.globalCompositeOperation='lighter'; wc.fillStyle=E[0]; wc.globalAlpha=E[1];
  wc.fillRect(5.2,-39.6,10.4,2.6);
  if(E[2]){ wc.globalAlpha=E[2]>1?.22:.16; wc.beginPath(); wc.arc(10.4,-38.3,E[2]>1?7:5,0,6.2832); wc.fill(); }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
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
    wc.fillStyle='#ffc04a'; wc.globalAlpha=clamp(e.muzzle*6,0,1);
    wc.beginPath(); wc.arc(x+fl*32.4,y-27,7,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  }
  drawWindupGlow(e,x+fl*32.4,y-27);
}

'@

SubRx @'
var VER='24.11';
'@ @'
var VER='24.12';
'@

$pat = "(?m)^  now:'v24\.11:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.12: The Warden is redrawn: a hunched gunmetal walker-tank with rust plates, a cannon arm and a visor that shows its mood. Check 24.12 fails on v24.11',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
