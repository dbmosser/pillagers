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

# THE BULWARK REDESIGN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawBulwarkS(e){
  shadowE(e.x,e.y+2,e.r*.95,4,.36);
  // legs, then hull, then the slab across the front so it reads as carried
  wc.fillStyle='#20262c';
  rrF(e.x-16,e.y+4,9,6,2); rrF(e.x+7,e.y+4,9,6,2);
  wc.fillStyle=INK; rrF(e.x-15,e.y-16,30,24,6);
  wc.fillStyle=e.hitT>0?'#8a4a42':'#333c46'; rrF(e.x-13,e.y-14,26,20,5);
  wc.fillStyle='#3f4a55'; rrF(e.x-13,e.y-14,26,7,4);
  var _bl=Math.sin(G.t*3+e.x*0.01)>0;
  wc.fillStyle=_bl?'#ffc04a':'#4a3a1c';
  wc.beginPath(); wc.arc(e.x,e.y-10,2.4,0,6.2832); wc.fill();
  wc.save(); wc.translate(e.x,e.y-4); wc.rotate(e.face);
  // CAPTURED AND LOOKED AT, v3.99. The first cut drew a thin plank floating a
  // few pixels off the hull, and since the shield IS this machine, a silhouette
  // that does not say WALL at a glance is a failed design however correct the
  // damage maths is. Wider, taller, flush against the body, with a lit top edge
  // and rivets so it reads as carried plate rather than a stripe.
  wc.fillStyle=INK; rrF(8,-25,15,50,3);
  wc.fillStyle='#5d6b78'; rrF(9,-24,13,48,2.5);
  wc.fillStyle='#78899a'; rrF(9,-24,13,7,2.5);            // the lit top lip
  wc.fillStyle='#39434d'; rrF(9,17,13,7,2.5);             // shadowed foot
  wc.fillStyle='#2b333b';
  wc.beginPath(); wc.arc(15.5,-16,1.7,0,6.2832); wc.fill();
  wc.beginPath(); wc.arc(15.5,0,1.7,0,6.2832); wc.fill();
  wc.beginPath(); wc.arc(15.5,16,1.7,0,6.2832); wc.fill();
  wc.fillStyle='#8fa3b5'; rrF(9,-3,13,2,1);               // the viewing slit
  wc.restore();
}

'@ @'
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

'@

SubRx @'
var VER='24.23';
'@ @'
var VER='24.24';
'@

$pat = "(?m)^  now:'v24\.23:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.24: The Bulwark is redrawn: a squat walker behind a dark chevron-striped shield with a glowing viewing slit. Check 24.24 fails on v24.23',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
