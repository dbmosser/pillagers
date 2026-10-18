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

# PILLAGER ROLES ARE WORN GEAR, NOT MARKS IN THE AIR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawRoleMark(e){
  var r=raiderRole(e), c, x, y, fl, k, wv;
  if(!r||e.downed||e.hp<=0||e.state==='down'||e.roll>0) return;
  c=PROLE[r].c; x=e.x; y=e.y; fl=(Math.cos(e.face)<0)?-1:1;
  if(r==='rush'){
    for(k=-1;k<=1;k+=2){
      wc.fillStyle=INK; wc.beginPath(); wc.moveTo(x+k*11.5,y-24); wc.lineTo(x+k*8.5,y-34); wc.lineTo(x+k*4.5,y-24); wc.closePath(); wc.fill();
      wc.fillStyle=c; wc.beginPath(); wc.moveTo(x+k*10,y-25); wc.lineTo(x+k*8.4,y-31.5); wc.lineTo(x+k*6,y-25); wc.closePath(); wc.fill();
    }
  } else if(r==='flank'){
    wv=Math.sin(((typeof G!=='undefined'&&G)?G.t:0)*6+x*0.1)*2;
    wc.fillStyle=INK; wc.beginPath(); wc.moveTo(x-fl*2,y-29); wc.lineTo(x-fl*17,y-25+wv); wc.lineTo(x-fl*16,y-19+wv); wc.lineTo(x-fl*1,y-23); wc.closePath(); wc.fill();
    wc.fillStyle=c; wc.beginPath(); wc.moveTo(x-fl*2.5,y-28); wc.lineTo(x-fl*15,y-24.4+wv); wc.lineTo(x-fl*14.4,y-20.6+wv); wc.lineTo(x-fl*2,y-24.5); wc.closePath(); wc.fill();
  } else if(r==='supp'){
    wc.fillStyle=INK; wc.beginPath(); wc.moveTo(x-7.5,y-26); wc.lineTo(x-3.5,y-27); wc.lineTo(x+7.5,y-13); wc.lineTo(x+3.5,y-12); wc.closePath(); wc.fill();
    wc.fillStyle=c; wc.beginPath(); wc.moveTo(x-6.4,y-25.4); wc.lineTo(x-4,y-26); wc.lineTo(x+6.4,y-13.6); wc.lineTo(x+4,y-13); wc.closePath(); wc.fill();
    wc.fillStyle=INK; rrF(x+fl*7-4.4,y-18.4,8.8,8.8,1.4);
    wc.fillStyle=c; rrF(x+fl*7-3.2,y-17.2,6.4,6.4,1);
  } else if(r==='mark'){
    wc.fillStyle=INK; wc.beginPath(); wc.moveTo(x-7.5,y-29); wc.lineTo(x,y-46); wc.lineTo(x+7.5,y-29); wc.closePath(); wc.fill();
    wc.fillStyle=darkHex(c,.35); wc.beginPath(); wc.moveTo(x-6.2,y-30); wc.lineTo(x,y-43.5); wc.lineTo(x+6.2,y-30); wc.closePath(); wc.fill();
    wc.fillStyle=c; wc.fillRect(x-6.2,y-31.4,12.4,1.8);
  } else if(r==='shield'){
    wc.fillStyle=INK; rrF(x+fl*6-1,y-30.4,10,25,3);
    wc.fillStyle=c; rrF(x+fl*6,y-29.4,8,23,2);
    wc.fillStyle=litHex(c,.35); wc.fillRect(x+fl*6+1,y-28,2,20);
  }
}

'@ @'
// v28.xx (cw-rolegear), HIS ANSWER 73 (2026-10-18): "Drawn gear replaces the marks over pillagers' heads, NOW." The five role shapes of ai21 floated over the
// body: spikes and a hood in the air above the head, a plate hung beside him. Each role is worn gear now, drawn on the body and moving with it (the footfall bob,
// the sprint lean, the crouch): RUSH wears spiked shoulder pauldrons, FLANK a knotted neck scarf with a tail, SUPP a bandolier with brass rounds and an ammo box on
// the hip, MARK a hood framing the face and a mantle over the shoulders, SHIELD a strapped plate on the arm. Nothing rises above the head but the hood rim.
function roleAnchor(e){
  var ph=(e.step||0)*4, mv=!!e.moving, sp=e.state==='extract', fl=(Math.cos(e.face)<0)?-1:1;
  var bob=mv?Math.abs(Math.sin(ph))*1.5:Math.sin(ph*.35)*.5, lean=sp?fl*1.6:(mv?fl*.7:0), lift=(raiderCrouched(e)||e.pinT>0)?5:0;
  return {x:e.x+lean,ty:e.y-bob+lift,fl:fl};
}
function drawRoleMark(e){
  var r=raiderRole(e), c, cd, ch, a, cx, ty, fl, sw, k, px, wv, t, i, bx;
  if(!r||e.downed||e.hp<=0||e.state==='down'||e.roll>0) return;
  c=PROLE[r].c; cd=darkHex(c,.35); ch=litHex(c,.35); a=roleAnchor(e); cx=a.x; ty=a.ty; fl=a.fl;
  sw=(e.build==='broad')?9.2:((e.build==='curved')?7.4:6.6);
  if(r==='rush'){
    for(k=-1;k<=1;k+=2){
      px=cx+k*sw;
      wc.fillStyle=INK; wc.beginPath(); wc.moveTo(px-2.4,ty-23.6); wc.lineTo(px+k*0.5,ty-29.4); wc.lineTo(px+2.4,ty-23.6); wc.closePath(); wc.fill();
      wc.fillStyle=c; wc.beginPath(); wc.moveTo(px-1.3,ty-23.8); wc.lineTo(px+k*0.5,ty-27.6); wc.lineTo(px+1.3,ty-23.8); wc.closePath(); wc.fill();
      wc.fillStyle=INK; rrF(px-3.6,ty-24.2,7.2,6.8,2.6);
      wc.fillStyle=c; rrF(px-2.8,ty-23.4,5.6,5.2,1.9);
      wc.fillStyle=ch; wc.fillRect(px-2.0,ty-23.2,3.4,1.1);
      wc.fillStyle=cd; wc.fillRect(px-2.4,ty-19.6,4.8,0.9);
    }
  } else if(r==='flank'){
    wv=Math.sin(((typeof G!=='undefined'&&G)?G.t:0)*6+cx*0.1)*2;
    bx=cx-fl*4.6;
    wc.fillStyle=INK; wc.beginPath(); wc.moveTo(bx,ty-26.2); wc.lineTo(cx-fl*17,ty-24.6+wv); wc.lineTo(cx-fl*15.6,ty-18.6+wv); wc.lineTo(bx,ty-22.6); wc.closePath(); wc.fill();
    wc.fillStyle=c; wc.beginPath(); wc.moveTo(bx,ty-25.2); wc.lineTo(cx-fl*15.4,ty-23.4+wv); wc.lineTo(cx-fl*14.4,ty-19.8+wv); wc.lineTo(bx,ty-23.6); wc.closePath(); wc.fill();
    wc.fillStyle=cd; wc.beginPath(); wc.moveTo(bx,ty-23.8); wc.lineTo(cx-fl*14.6,ty-20.8+wv); wc.lineTo(cx-fl*14.4,ty-19.8+wv); wc.lineTo(bx,ty-22.9); wc.closePath(); wc.fill();
    wc.fillStyle=INK; rrF(cx-5.8,ty-27.4,11.6,4.8,2);
    wc.fillStyle=c; rrF(cx-4.9,ty-26.6,9.8,3.1,1.3);
    wc.fillStyle=ch; wc.fillRect(cx-4.2,ty-26.4,5.2,0.8);
    wc.fillStyle=cd; wc.fillRect(cx-4.9,ty-24.6,9.8,0.9);
    wc.fillStyle=INK; wc.beginPath(); wc.arc(bx,ty-24.8,2.3,0,6.2832); wc.fill();
    wc.fillStyle=c; wc.beginPath(); wc.arc(bx,ty-24.8,1.5,0,6.2832); wc.fill();
  } else if(r==='supp'){
    wc.fillStyle=INK; wc.beginPath(); wc.moveTo(cx-5.6,ty-22.4); wc.lineTo(cx-2.4,ty-22.8); wc.lineTo(cx+5.8,ty-11.6); wc.lineTo(cx+2.8,ty-11.0); wc.closePath(); wc.fill();
    wc.fillStyle=c; wc.beginPath(); wc.moveTo(cx-4.8,ty-22.1); wc.lineTo(cx-3.1,ty-22.4); wc.lineTo(cx+4.9,ty-11.9); wc.lineTo(cx+3.4,ty-11.5); wc.closePath(); wc.fill();
    for(i=1;i<=4;i++){ t=i/5; wc.fillStyle='#d8b05a'; wc.fillRect(cx-3.9+t*8.2-0.6,ty-22.4+t*10.8-0.9,1.2,1.8); }
    bx=cx-fl*6.8;
    wc.fillStyle=INK; rrF(bx-3.5,ty-17.6,7,7.4,1.6);
    wc.fillStyle=c; rrF(bx-2.6,ty-16.8,5.2,5.6,1.1);
    wc.fillStyle=cd; wc.fillRect(bx-2.6,ty-16.8,5.2,1.6);
    wc.fillStyle='#d8b05a'; wc.fillRect(bx-0.7,ty-15.2,1.4,1.2);
  } else if(r==='mark'){
    wc.fillStyle=INK; rrF(cx-sw-1.4,ty-25.4,2*sw+2.8,5.2,2.2);
    wc.fillStyle=cd; rrF(cx-sw-0.6,ty-24.6,2*sw+1.2,3.6,1.6);
    wc.fillStyle=c; wc.fillRect(cx-sw+0.6,ty-24.5,2*sw-1.2,1.2);
    wc.lineCap='round';
    wc.beginPath(); wc.ellipse(cx,ty-33.2,7.8,6.8,0,Math.PI*.82,Math.PI*2.18); wc.strokeStyle=INK; wc.lineWidth=3.8; wc.stroke();
    wc.beginPath(); wc.ellipse(cx,ty-33.2,7.8,6.8,0,Math.PI*.82,Math.PI*2.18); wc.strokeStyle=cd; wc.lineWidth=2.2; wc.stroke();
    wc.beginPath(); wc.ellipse(cx,ty-33.2,7.8,6.8,0,Math.PI*1.12,Math.PI*1.88); wc.strokeStyle=c; wc.lineWidth=1.0; wc.stroke();
    wc.lineCap='butt';
  } else if(r==='shield'){
    px=cx+fl*(sw+1.0);
    wc.fillStyle=INK; rrF(px-3.6,ty-24,7.2,15,2.8);
    wc.fillStyle=c; rrF(px-2.8,ty-23.2,5.6,13.4,2.1);
    wc.fillStyle=ch; wc.fillRect(px-2.2,ty-22.4,1.6,11);
    wc.fillStyle=cd; wc.fillRect(px+1.0,ty-22.4,1.4,11);
    wc.fillStyle=INK; wc.fillRect(px-2.8,ty-18.6,5.6,1.2); wc.fillRect(px-2.8,ty-13.4,5.6,1.2);
    wc.fillStyle='#dfe6ec'; wc.fillRect(px-1.8,ty-22.0,0.9,0.9); wc.fillRect(px+0.9,ty-22.0,0.9,0.9);
  }
}

'@

SubRx @'
var VER='30.26';
'@ @'
var VER='30.27';
'@

$pat = "(?m)^  now:'v30\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v30.27: Pillager role marks are now drawn gear worn on the body. Check 30.27 fails on v30.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
