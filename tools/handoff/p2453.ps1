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

# THE HOWLER REDESIGN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawHowlerS(e){
  shadowE(e.x,e.y+2,e.r*.9,4,.35);
  wc.fillStyle=INK; rrF(e.x-16,e.y-14,32,22,6);
  wc.fillStyle=e.hitT>0?'#8a4a42':'#2c333c'; rrF(e.x-14,e.y-12,28,18,5);
  wc.fillStyle='#3c4650'; rrF(e.x-14,e.y-12,28,6,4);
  wc.save(); wc.translate(e.x,e.y-8); wc.rotate(-0.6);
  wc.fillStyle=INK; rrF(-4,-22,9,24,3);
  wc.fillStyle='#4a545e'; rrF(-3,-21,7,22,2.5);
  wc.fillStyle='#ffc04a'; rrF(-3,-21,7,3,1.5);
  wc.restore();
  wc.fillStyle='#20262c';
  rrF(e.x-18,e.y+4,8,5,2); rrF(e.x+10,e.y+4,8,5,2);
  var _hbl=Math.sin(G.t*4+e.x*0.01)>0;
  wc.fillStyle=_hbl?'#ff5a3c':'#5a2c24';
  wc.beginPath(); wc.arc(e.x+9,e.y-9,2.2,0,6.2832); wc.fill();
}

'@ @'
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

'@

SubRx @'
var VER='24.52';
'@ @'
var VER='24.53';
'@

$pat = "(?m)^  now:'v24\.52:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.53: The Howler is redrawn: a four-legged mortar walker whose fat tube turns toward what it is shooting at. Check 24.53 fails on v24.52',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
