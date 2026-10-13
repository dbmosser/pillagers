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

# THE PILLBOX REDESIGN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawChoirS(e){
  var x=e.x,y=e.y;
  var hot=(e.overheat||0)>0;
  var live=e.seenYou&&!hot;
  shadowE(x,y+3,30,10,.5);
  // BOLTED DOWN. A wide flat plinth, drawn first and drawn low, so the shape
  // reads as emplaced from any distance.
  wc.fillStyle=INK;      rrF(x-26,y-9,52,13,4);
  wc.fillStyle='#241d2e'; rrF(x-25,y-8,50,11,3);
  wc.fillStyle='#3a2f47';
  for(var b=0;b<5;b++) wc.fillRect(x-21+b*10,y-7,5,9);
  // The drum, and a ring of pipes around it: this is the choir.
  wc.fillStyle=INK;      rrF(x-19,y-40,38,33,7);
  wc.fillStyle='#3c2f4c'; rrF(x-18,y-39,36,31,6);
  wc.fillStyle='#54426a'; wc.fillRect(x-16,y-39,32,6);
  var pipes=7;
  for(var q=0;q<pipes;q++){
    var pa=(q/pipes)*6.2832+G.t*0.20;
    var px=x+Math.cos(pa)*15, py=y-24+Math.sin(pa)*5;
    var ph=6+Math.sin(pa)*2.5;
    wc.fillStyle=INK;      rrF(px-2.6,py-ph,5.2,ph+3,2);
    wc.fillStyle='#6b5484'; rrF(px-1.8,py-ph+0.7,3.6,ph+1.6,1.6);
  }
  // THE MOUTH, front, which is one of its two weak points and the thing that
  // brightens as the next shot loads.
  var fl=Math.cos(e.face)>=0?1:-1;
  var mx=x+Math.cos(e.face)*17, my=y-24+Math.sin(e.face)*5;
  wc.fillStyle=INK; wc.beginPath(); wc.arc(mx,my,9,0,6.2832); wc.fill();
  wc.globalCompositeOperation='lighter';
  wc.fillStyle=hot?'#ff8a3c':(live?'#e0a0ff':'#8a6fa8');
  wc.globalAlpha=hot?(.5+.4*Math.sin(G.t*14)):(live?(.55+.35*Math.sin(G.t*7)):.32);
  wc.beginPath(); wc.arc(mx,my,live?8:5.5,0,6.2832); wc.fill();
  // While it is awake it wears a faint halo, which is the only cue you get at
  // range that you have wandered inside its reach.
  if(live){
    wc.globalAlpha=.16;
    wc.beginPath(); wc.arc(x,y-22,26,0,6.2832); wc.fill();
  }
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  // VENTING. Unmistakable, because the four seconds it buys are the reward for
  // hitting a weak point and the player has to know they have them.
  if(hot){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,138,60,.42)';
    for(var v=0;v<3;v++){
      var vy=y-40-((G.t*40+v*14)%26);
      wc.beginPath(); wc.ellipse(x+(v-1)*9,vy,5,3,0,0,6.2832); wc.fill();
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
    wc.fillStyle='#e0a0ff'; wc.globalAlpha=clamp(e.muzzle*6,0,1);
    wc.beginPath(); wc.arc(mx,my,8,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  }
}

'@ @'
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
    wc.fillStyle='#ffb070'; wc.globalAlpha=clamp(e.muzzle*6,0,1);
    wc.beginPath(); wc.arc(mx,my,8,0,6.2832); wc.fill();
    wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  }
}

'@

SubRx @'
var VER='24.55';
'@ @'
var VER='24.56';
'@

$pat = "(?m)^  now:'v24\.55:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.56: The Pillbox is redrawn: a gunmetal emplacement with a crown of brass organ pipes and an iris mouth that charges red. Check 24.56 fails on v24.55',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
