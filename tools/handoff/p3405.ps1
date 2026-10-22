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

# MINIMAP MARKS READ WITHOUT COLOUR (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mmArrow(s,R,col){
  ctx.save(); ctx.translate(s.x,s.y); ctx.rotate(s.a);
  ctx.beginPath(); ctx.moveTo(6*R,0); ctx.lineTo(-4*R,5*R); ctx.lineTo(-2*R,0); ctx.lineTo(-4*R,-5*R); ctx.closePath();
  ctx.lineJoin='round'; ctx.lineWidth=2*R; ctx.strokeStyle=INK; ctx.stroke(); ctx.fillStyle=col; ctx.fill();
  ctx.restore(); MMAP.ops+=2; MMAP.got.pins++;
}
'@ @'
// v28.xx (cw-cx-minicues), his 2.79 a: static shapes back up minimap colours; existing pulse rates and visibility stay unchanged.
function mmDoorMark(s,R,open,c){
  c=c||ctx;c.save();c.fillStyle=INK;c.fillRect(s.x-4.5*R,s.y-4.5*R,9*R,9*R);
  if(open){c.strokeStyle='#efe9dc';c.lineWidth=1.8*R;c.strokeRect(s.x-3*R,s.y-3*R,6*R,6*R);}
  else{c.fillStyle=UIC.acc;c.fillRect(s.x-3*R,s.y-3*R,6*R,6*R);}
  c.restore();MMAP.ops+=2;
}
function mmSealMark(s,R,done,col,c){
  c=c||ctx;c.save();c.beginPath();c.moveTo(s.x,s.y-6*R);c.lineTo(s.x+6*R,s.y);c.lineTo(s.x,s.y+6*R);c.lineTo(s.x-6*R,s.y);c.closePath();
  c.fillStyle=done?col:INK;c.fill();c.lineWidth=2*R;c.strokeStyle=col;c.stroke();c.restore();MMAP.ops+=2;
}
function mmExtractRing(s,R,col,rad,st,c){
  c=c||ctx;c.save();c.strokeStyle=col;c.lineWidth=2*R;
  if(st==='closing')c.setLineDash([3*R,2*R]);
  c.beginPath();c.arc(s.x,s.y,rad,0,6.2832);
  if(st==='closed'){
    c.moveTo(s.x-rad*.6,s.y-rad*.6);c.lineTo(s.x+rad*.6,s.y+rad*.6);
    c.moveTo(s.x+rad*.6,s.y-rad*.6);c.lineTo(s.x-rad*.6,s.y+rad*.6);
  }else if(st==='inbound'){
    c.moveTo(s.x-3*R,s.y-rad-3*R);c.lineTo(s.x-3*R,s.y-rad+3*R);
    c.moveTo(s.x+3*R,s.y-rad-3*R);c.lineTo(s.x+3*R,s.y-rad+3*R);
  }else if(st==='live'){c.moveTo(s.x+rad+3*R,s.y);c.arc(s.x,s.y,rad+3*R,0,6.2832);}
  c.stroke();c.restore();MMAP.ops++;
}
function mmArrow(s,R,col,kind,detail){
  ctx.save();ctx.translate(s.x,s.y);ctx.rotate(s.a);
  ctx.beginPath();ctx.moveTo(6*R,0);ctx.lineTo(-4*R,5*R);ctx.lineTo(-2*R,0);ctx.lineTo(-4*R,-5*R);ctx.closePath();
  ctx.lineJoin='round';ctx.lineWidth=2*R;ctx.strokeStyle=INK;ctx.stroke();ctx.fillStyle=col;ctx.fill();ctx.restore();
  MMAP.ops+=2;MMAP.got.pins++;
  if(!kind)return;
  var r=MMAP.markRect,slots=MMAP.pinSlots||(MMAP.pinSlots=[]),baseX=s.x-Math.cos(s.a)*16*R,baseY=s.y-Math.sin(s.a)*16*R,bx=baseX,by=baseY,i,j,off,clear;
  for(i=0;i<15;i++){
    off=i?Math.ceil(i/2)*18*R*(i%2?1:-1):0;
    bx=baseX-Math.sin(s.a)*off;by=baseY+Math.cos(s.a)*off;
    if(r){bx=clamp(bx,r.x+12*R,r.x+r.w-12*R);by=clamp(by,r.y+12*R,r.y+r.h-12*R);}
    clear=true;for(j=0;j<slots.length;j++)if(Math.hypot(slots[j].x-bx,slots[j].y-by)<16*R){clear=false;break;}
    if(clear)break;
  }
  slots.push({x:bx,y:by});
  ctx.save();ctx.globalAlpha=1;ctx.strokeStyle='#aaa498';ctx.lineWidth=R;ctx.beginPath();ctx.moveTo(s.x,s.y);ctx.lineTo(bx,by);ctx.stroke();
  colourCueGlyph(ctx,kind,bx,by,.85*R,col);
  if(kind==='exit'&&detail!=='open')mmExtractRing({x:bx,y:by},.7*R,col,7*R,detail);
  ctx.restore();MMAP.ops+=4;
}
'@

SubRx @'
  var got=MMAP.got={zones:[],seal:null,forge:null,doors:0,mates:0,foes:[],pins:0,wp:null};
'@ @'
  var got=MMAP.got={zones:[],seal:null,forge:null,doors:0,mates:0,foes:[],pins:0,wp:null};
  MMAP.markRect=r;MMAP.pinSlots=[]; // v28.xx (cw-cx-minicues): keep adjacent edge badges apart inside the clip.
'@

SubRx @'
    ctx.fillStyle=INK; ctx.fillRect(s.x-4.5*R,s.y-4.5*R,9*R,9*R);
    ctx.fillStyle=q.open?HUDC.gain:UIC.acc; ctx.fillRect(s.x-3*R,s.y-3*R,6*R,6*R); MMAP.ops+=2; got.doors++;
'@ @'
    mmDoorMark(s,R,q.open);got.doors++; // v28.xx (cw-cx-minicues): open is hollow, locked is solid.
'@

SubRx @'
    if(s.out){ if(st!=='closed'){ ctx.globalAlpha=a; mmArrow(s,R,col); ctx.globalAlpha=1; } continue; }
'@ @'
    if(s.out){if(st!=='closed'){ctx.globalAlpha=a;mmArrow(s,R,col,'exit',st);ctx.globalAlpha=1;}continue;}
'@

SubRx @'
    ctx.globalAlpha=a; ctx.strokeStyle=col; ctx.lineWidth=2*R; ctx.beginPath(); ctx.arc(s.x,s.y,rad,0,6.2832);
    if(st==='closed'){ ctx.moveTo(s.x-rad*0.6,s.y-rad*0.6); ctx.lineTo(s.x+rad*0.6,s.y+rad*0.6); ctx.moveTo(s.x+rad*0.6,s.y-rad*0.6); ctx.lineTo(s.x-rad*0.6,s.y+rad*0.6); }
    ctx.stroke(); MMAP.ops++;
'@ @'
    ctx.globalAlpha=a;mmExtractRing(s,R,col,rad,st);
'@

SubRx @'
    if(s.out){ if(!G.seal.done){ mmArrow(s,R,col); got.seal='pin'; } }
'@ @'
    if(s.out){if(!G.seal.done){mmArrow(s,R,col,'seal');got.seal='pin';}}
'@

SubRx @'
      ctx.beginPath(); ctx.moveTo(s.x,s.y-6*R); ctx.lineTo(s.x+6*R,s.y); ctx.lineTo(s.x,s.y+6*R); ctx.lineTo(s.x-6*R,s.y); ctx.closePath();
      ctx.lineWidth=2*R; ctx.strokeStyle=INK; ctx.stroke(); ctx.fillStyle=col; ctx.fill(); MMAP.ops+=2; got.seal='in';
'@ @'
      mmSealMark(s,R,G.seal.done,col);got.seal='in'; // v28.xx (cw-cx-minicues): pending hollow, broken filled.
'@

SubRx @'
    if(s.out){ mmArrow(s,R,FORGE_GOLD); got.forge='pin'; }
'@ @'
    if(s.out){mmArrow(s,R,FORGE_GOLD,'forge');got.forge='pin';}
'@

SubRx @'
      if(s.out){ mmArrow(s,R,'#bfe0ff'); continue; }
'@ @'
      if(s.out){mmArrow(s,R,'#bfe0ff','partywaypoint');continue;}
'@

SubRx @'
      ctx.beginPath(); ctx.moveTo(s.x,s.y-5*R); ctx.lineTo(s.x+4*R,s.y); ctx.lineTo(s.x,s.y+5*R); ctx.lineTo(s.x-4*R,s.y); ctx.closePath(); ctx.fill(); MMAP.ops++;
'@ @'
      colourCueGlyph(ctx,q.dg?'danger':q.pl?'loot':q.w?'target':'place',s.x,s.y,.85*R,ctx.fillStyle);MMAP.ops+=3;
'@

SubRx @'
    if(s.out) mmArrow(s,R,UIC.acc);
'@ @'
    if(s.out)mmArrow(s,R,UIC.acc,'waypoint');
'@

SubRx @'
    for(i=0;i<foes.length;i++){ ctx.moveTo(foes[i].x+4*R,foes[i].y); ctx.arc(foes[i].x,foes[i].y,4*R,0,6.2832); }
'@ @'
    // v28.xx (cw-cx-minicues): visible enemies are triangles, allies plus signs; keep the existing VIS-only list.
    for(i=0;i<foes.length;i++){ctx.moveTo(foes[i].x,foes[i].y-5*R);ctx.lineTo(foes[i].x+4.5*R,foes[i].y+4*R);ctx.lineTo(foes[i].x-4.5*R,foes[i].y+4*R);ctx.closePath();}
'@

SubRx @'
    ctx.lineWidth=2*R; ctx.strokeStyle=INK; ctx.stroke(); ctx.fillStyle=HUDC.danger; ctx.fill(); MMAP.ops+=2;
'@ @'
    ctx.lineWidth=2*R;ctx.strokeStyle='#efe9dc';ctx.stroke();ctx.fillStyle=HUDC.danger;ctx.fill();MMAP.ops+=2;
'@

SubRx @'
    if(s.out){ mmArrow(s,R,col); continue; }
'@ @'
    if(s.out){mmArrow(s,R,col,q.dn?'down':'ally');continue;}
'@

SubRx @'
    ctx.fillStyle=INK; ctx.beginPath(); ctx.arc(s.x,s.y,6*R,0,6.2832); ctx.fill();
    ctx.fillStyle=col; ctx.beginPath(); ctx.arc(s.x,s.y,4.2*R,0,6.2832); ctx.fill(); MMAP.ops+=2;
'@ @'
    colourCueGlyph(ctx,q.dn?'down':'ally',s.x,s.y,.85*R,col);MMAP.ops+=3;
'@

SubRx @'
    ctx.fillStyle=p.dg?'#ff4a3a':(p.w?'#ff8a3c':'#6fe0ff'); ctx.beginPath(); ctx.moveTo(px,py-6); ctx.lineTo(px+5,py); ctx.lineTo(px,py+6); ctx.lineTo(px-5,py); ctx.closePath(); ctx.fill();
'@ @'
    colourCueGlyph(ctx,p.dg?'danger':p.pl?'loot':p.w?'target':'place',px,py,Math.max(1,hudRes()),p.dg?'#ff4a3a':p.w?'#ff8a3c':'#6fe0ff'); // v28.xx (cw-cx-minicues): the same ping shapes on the sector map.
'@

SubRx @'
var VER='34.04';
'@ @'
var VER='34.05';
'@

$pat = "(?m)^  now:'v34\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.05: Enemies are triangles, allies plus signs and downed allies crosses. Doors, extraction states, pings and distant objectives have distinct shapes. Check 34.05 fails on v34.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
