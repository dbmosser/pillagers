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

# THE CRAWLER, REDRAWN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawCrawlerS(e){
  var S=e.r/CRAWLER_R0,fl=Math.cos(e.face)<0?-1:1;
  var hunting=e.state==='chase';
  // it hunkers and stretches forward when it commits to a rush
  var lunge=hunting?1.18:1;
  shadowE(e.x,e.y+1,15*S,5*S,.44);
  wc.fillStyle='#5a1c11';
  for(var j=0;j<6;j++){
    var side=j%2?1:-1,rank=Math.floor(j/2);
    var lx=e.x+side*(9*S+rank*1.5*S);
    var sw=Math.sin(e.legs+j*1.05)*4.5*S*lunge;
    // lower joint planted, upper joint scuttling
    wc.fillRect(lx-1.6*S,e.y-3*S-rank*1.5*S,3.2*S,8*S);
    wc.fillRect(lx-1.6*S+sw,e.y-11*S-rank*1.5*S,3.2*S,8*S);
  }
  // carapace
  wc.fillStyle='#a83c24'; wc.fillRect(e.x-13*S,e.y-19*S,26*S,11*S);
  wc.fillStyle='#c04a2e'; wc.fillRect(e.x-13*S,e.y-19*S,26*S,4*S);
  wc.fillStyle='#7d2a18'; wc.fillRect(e.x-13*S,e.y-9.5*S,26*S,2*S);
  // head and mandibles
  wc.fillStyle='#8e3220';
  wc.fillRect(e.x+fl*12*S-6*S,e.y-21*S*lunge,12*S,9*S);
  wc.fillStyle='#5a1c11';
  wc.fillRect(e.x+fl*17*S-2*S,e.y-20*S*lunge,5*S,2.4*S);
  wc.fillRect(e.x+fl*17*S-2*S,e.y-15*S*lunge,5*S,2.4*S);
  // eye cluster: three unblinking points, brighter and pulsing on the rush.
  // Scary is specificity: a thing with six legs and three eyes that all look AT
  // you reads as predatory in a way a colour swap never will.
  wc.globalCompositeOperation='lighter';
  wc.fillStyle=hunting?'#ff3b30':'#ffc04a';
  var eyA=hunting?(.85+.15*Math.sin(G.t*16)):.5;
  wc.globalAlpha=eyA;
  var ehx=e.x+fl*13*S,ehy=e.y-18*S*lunge;
  wc.beginPath(); wc.arc(ehx,ehy,1.6*S,0,6.2832); wc.fill();
  wc.beginPath(); wc.arc(ehx+fl*3*S,ehy+2.2*S,1.2*S,0,6.2832); wc.fill();
  wc.beginPath(); wc.arc(ehx-fl*2.5*S,ehy+2.6*S,1.1*S,0,6.2832); wc.fill();
  wc.fillStyle=hunting?'#ff5a3a':'#ffe08a';
  var cp=hunting?(1+Math.sin(G.t*14)*.3):1;
  wc.globalAlpha=.28;
  wc.beginPath(); wc.arc(e.x+fl*15*S,e.y-17*S*lunge,6*S*cp,0,6.2832); wc.fill();
  wc.globalAlpha=1;
  wc.beginPath(); wc.arc(e.x+fl*15*S,e.y-17*S*lunge,2.4*S,0,6.2832); wc.fill();
  wc.globalCompositeOperation='source-over';
}

'@ @'
// v23.xx (spr3), HIS ORDER (2026-10-12): "improve the sprites of all characters, bots, etc", gritty and grounded like ARC
// Raiders, silhouettes first. The sprite program, MACHINES A, build 2: THE CRAWLER. It was a red bench: six legs hanging
// straight down under a flat red box, no knees, nothing insect, the body the same red as the foe team colour and its three
// eyes lost in one glow disc. It is redrawn: a low shell of three overlapping oxide segments (rust brown, not team red), each
// lit on top with a dark seam behind it; a gunmetal sensor head with two mandible blades; three separate eye sockets in the
// sensor language (dim white idle, amber suspicious, red hunting); and six jointed legs splayed out front and back, knees
// above the shell line, feet planted wide, stepping on a tripod gait (three feet down while three swing). On a rush the shell
// drops and the front legs reach. An elite wears brass shell edges and a fourth eye. Drawn only: no random numbers, nothing
// written on the machine, its size and shadow as before.
// One leg: hip, knee, foot in the machine frame (feet at ox,oy, lx mirrored by fl), inked then metal.
function sprCrawlLeg(ox,oy,fl,S,hx,hy,kx,ky,fx,fy){
  wc.moveTo(ox+fl*hx*S,oy+hy*S); wc.lineTo(ox+fl*kx*S,oy+ky*S); wc.lineTo(ox+fl*fx*S,oy+fy*S);
}
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

'@

SubRx @'
var VER='24.10';
'@ @'
var VER='24.11';
'@

$pat = "(?m)^  now:'v24\.10:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.11: The Crawler is redrawn: a rusted three-segment shell, six jointed legs that scuttle, three eyes. Check 24.11 fails on v24.10',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
