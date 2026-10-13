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

# THE MINIMAP MARKS WHAT MATTERS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawMinimap(){
'@ @'
// v24.xx (minimap2), HIS ORDER (2026-10-12): "add minimap", the markers. What the minimap shows on the street it bakes:
// - the extraction points in their state: OPEN (teal ring), INBOUND (called, teal, pulsing), LIVE (the hold running, green, pulsing
//   fast), CLOSING (amber, from the two minute warning) and CLOSED (dim, crossed out), each with its letter;
// - the seal (a pale blue diamond, amber once broken), the Forge station when the raid has one, and the vault and locked room doors
//   (an amber square, green once open);
// - your waypoint and the party's marks and pings, in the colours the sector map gives them;
// - teammates (player 2 and the co-op party) as ally dots with their facing, red while down;
// - enemies ONLY while you can see them: the list the world itself draws by (VIS, built from canSee each frame, shared sight
//   included), so the minimap never shows a machine or a pillager through a wall. They share one path, one fill.
// An objective out of range (an extraction that is not closed, the seal, the Forge, your waypoint, a teammate) pins to the edge of
// the minimap as a small arrow in its colour, pointing the way. The pulse runs off the raid clock; nothing here draws a seeded number.
function mmPin(r,R,dx,dy){
  var h=r.w/2, k=Math.max(Math.abs(dx),Math.abs(dy)), t;
  if(k<=h-4*R) return {x:r.x+h+dx,y:r.y+h+dy,a:0,out:false};
  t=(h-8*R)/k;
  return {x:r.x+h+dx*t,y:r.y+h+dy*t,a:Math.atan2(dy,dx),out:true};
}
function mmArrow(s,R,col){
  ctx.save(); ctx.translate(s.x,s.y); ctx.rotate(s.a);
  ctx.beginPath(); ctx.moveTo(6*R,0); ctx.lineTo(-4*R,5*R); ctx.lineTo(-2*R,0); ctx.lineTo(-4*R,-5*R); ctx.closePath();
  ctx.lineJoin='round'; ctx.lineWidth=2*R; ctx.strokeStyle=INK; ctx.stroke(); ctx.fillStyle=col; ctx.fill();
  ctx.restore(); MMAP.ops+=2; MMAP.got.pins++;
}
function mmFoe(e){ return !!e&&!e.dead&&!(e.hp<=0)&&!e.merc&&!e.friendly&&!e.friendlyPC&&!e.neutral&&e.kind!=='peddler'&&e.kind!=='stray'; }
function mmMarks(r,sc,R){
  var p=G.player, i, q, s, col, st, rad, a, lt=G.t||0, foes=[], mates, fg;
  var got=MMAP.got={zones:[],seal:null,forge:null,doors:0,mates:0,foes:[],pins:0,wp:null};
  function at(x,y){ return mmPin(r,R,(x-p.x)*sc,(y-p.y)*sc); }
  ctx.font=hudFS(TYPE.micro); ctx.textAlign='center'; ctx.textBaseline='middle';
  // vault and locked room doors
  for(i=0;i<((G.map&&G.map.locked)||[]).length;i++){
    q=G.map.locked[i]; s=at((q.doorX!==undefined)?q.doorX:q.x+q.w/2,(q.doorY!==undefined)?q.doorY:q.y+q.h/2);
    if(s.out) continue;
    ctx.fillStyle=INK; ctx.fillRect(s.x-4.5*R,s.y-4.5*R,9*R,9*R);
    ctx.fillStyle=q.open?HUDC.gain:UIC.acc; ctx.fillRect(s.x-3*R,s.y-3*R,6*R,6*R); MMAP.ops+=2; got.doors++;
  }
  // the extraction points, in their state
  for(i=0;i<(G.zones||[]).length;i++){
    q=G.zones[i];
    if(!q.open) st='closed';
    else if(q.beaconT!==null&&q.beaconT!==undefined&&q.beaconT>0) st='inbound';
    else if(q.beaconT!==null&&q.beaconT!==undefined&&q.hold!==null&&q.hold!==undefined) st='live';
    else if(q.closeAt!==undefined&&G.timeLeft<=q.closeAt+120) st='closing';
    else st='open';
    got.zones.push(st);
    col=(st==='closed')?UIC.tx_off:((st==='live')?HUDC.gain:((st==='closing')?UIC.warn:HUDC.extract));
    a=(st==='inbound')?(0.6+0.4*Math.sin(lt*6)):((st==='live')?(0.55+0.45*Math.sin(lt*12)):1);
    s=at(q.x,q.y);
    if(s.out){ if(st!=='closed'){ ctx.globalAlpha=a; mmArrow(s,R,col); ctx.globalAlpha=1; } continue; }
    rad=Math.max(6*R,(q.r||0)*sc);
    ctx.globalAlpha=a; ctx.strokeStyle=col; ctx.lineWidth=2*R; ctx.beginPath(); ctx.arc(s.x,s.y,rad,0,6.2832);
    if(st==='closed'){ ctx.moveTo(s.x-rad*0.6,s.y-rad*0.6); ctx.lineTo(s.x+rad*0.6,s.y+rad*0.6); ctx.moveTo(s.x+rad*0.6,s.y-rad*0.6); ctx.lineTo(s.x-rad*0.6,s.y+rad*0.6); }
    ctx.stroke(); MMAP.ops++;
    ctx.fillStyle=col; ctx.fillText(String.fromCharCode(65+i),s.x,s.y+0.5); MMAP.ops++;
    ctx.globalAlpha=1;
  }
  // the seal
  if(G.seal&&isFinite(G.seal.x)){
    col=G.seal.done?UIC.acc:'#8fd0ff'; s=at(G.seal.x,G.seal.y);
    if(s.out){ if(!G.seal.done){ mmArrow(s,R,col); got.seal='pin'; } }
    else {
      ctx.beginPath(); ctx.moveTo(s.x,s.y-6*R); ctx.lineTo(s.x+6*R,s.y); ctx.lineTo(s.x,s.y+6*R); ctx.lineTo(s.x-6*R,s.y); ctx.closePath();
      ctx.lineWidth=2*R; ctx.strokeStyle=INK; ctx.stroke(); ctx.fillStyle=col; ctx.fill(); MMAP.ops+=2; got.seal='in';
    }
  }
  // the Forge station, when the raid has one
  fg=G.forge||G.forgeSt||null;
  if(fg&&isFinite(fg.x)&&isFinite(fg.y)){
    s=at(fg.x,fg.y);
    if(s.out){ mmArrow(s,R,FORGE_GOLD); got.forge='pin'; }
    else { ctx.fillStyle=INK; ctx.beginPath(); ctx.arc(s.x,s.y,6*R,0,6.2832); ctx.fill(); ctx.fillStyle=FORGE_GOLD; ctx.beginPath(); ctx.arc(s.x,s.y,4*R,0,6.2832); ctx.fill(); MMAP.ops+=2; got.forge='in'; }
  }
  // the party's marks and pings, then your waypoint
  if(typeof NET==='object'&&NET){
    if(NET.wps) for(var _ws in NET.wps){
      if(!Object.prototype.hasOwnProperty.call(NET.wps,_ws)) continue;
      q=NET.wps[_ws]; if(!q||!isFinite(q.x)) continue; s=at(q.x,q.y);
      if(s.out){ mmArrow(s,R,'#bfe0ff'); continue; }
      ctx.strokeStyle='#bfe0ff'; ctx.lineWidth=2*R; ctx.beginPath(); ctx.arc(s.x,s.y,4.5*R,0,6.2832); ctx.stroke(); MMAP.ops++;
    }
    for(i=0;i<(NET.pings||[]).length;i++){
      q=NET.pings[i]; if(!q||!isFinite(q.x)) continue; s=at(q.x,q.y); if(s.out) continue;
      ctx.fillStyle=q.dg?'#ff4a3a':(q.w?'#ff8a3c':'#6fe0ff');
      ctx.beginPath(); ctx.moveTo(s.x,s.y-5*R); ctx.lineTo(s.x+4*R,s.y); ctx.lineTo(s.x,s.y+5*R); ctx.lineTo(s.x-4*R,s.y); ctx.closePath(); ctx.fill(); MMAP.ops++;
    }
  }
  if(G.waypoint&&isFinite(G.waypoint.x)){
    s=at(G.waypoint.x,G.waypoint.y); got.wp=s.out?'pin':'in';
    if(s.out) mmArrow(s,R,UIC.acc);
    else {
      ctx.strokeStyle=UIC.acc; ctx.lineWidth=1.6*R; ctx.beginPath(); ctx.arc(s.x,s.y,4.5*R,0,6.2832);
      ctx.moveTo(s.x-8*R,s.y); ctx.lineTo(s.x-2*R,s.y); ctx.moveTo(s.x+2*R,s.y); ctx.lineTo(s.x+8*R,s.y);
      ctx.moveTo(s.x,s.y-8*R); ctx.lineTo(s.x,s.y-2*R); ctx.moveTo(s.x,s.y+2*R); ctx.lineTo(s.x,s.y+8*R); ctx.stroke(); MMAP.ops++;
    }
  }
  // enemies you can see now: the world's own list (VIS), never one behind a wall. One path, one edge, one fill.
  for(i=0;i<VIS.length;i++){
    q=VIS[i]; if(!mmFoe(q)) continue;
    s=at(q.x,q.y); if(s.out) continue;
    foes.push(s); got.foes.push(q);
  }
  if(foes.length){
    ctx.beginPath();
    for(i=0;i<foes.length;i++){ ctx.moveTo(foes[i].x+4*R,foes[i].y); ctx.arc(foes[i].x,foes[i].y,4*R,0,6.2832); }
    ctx.lineWidth=2*R; ctx.strokeStyle=INK; ctx.stroke(); ctx.fillStyle=HUDC.danger; ctx.fill(); MMAP.ops+=2;
  }
  // teammates: player 2 and the co-op party, in the ally colour, red while down
  mates=(typeof NET==='object'&&NET&&NET.up)?NET.up:[];
  for(i=0;i<mates.length;i++){
    q=mates[i];
    try{ if(!netUpShown(q)) continue; }catch(_nu){ continue; }
    if(!isFinite(q.x)||!isFinite(q.y)) continue;
    col=q.dn?HUDC.danger:HUDC.ally; s=at(q.x,q.y); got.mates++;
    if(s.out){ mmArrow(s,R,col); continue; }
    ctx.fillStyle=INK; ctx.beginPath(); ctx.arc(s.x,s.y,6*R,0,6.2832); ctx.fill();
    ctx.fillStyle=col; ctx.beginPath(); ctx.arc(s.x,s.y,4.2*R,0,6.2832); ctx.fill(); MMAP.ops+=2;
    if(!q.dn&&isFinite(q.f)){ ctx.strokeStyle=col; ctx.lineWidth=1.6*R; ctx.beginPath(); ctx.moveTo(s.x,s.y); ctx.lineTo(s.x+Math.cos(q.f)*10*R,s.y+Math.sin(q.f)*10*R); ctx.stroke(); MMAP.ops++; }
  }
  ctx.textAlign='left'; ctx.textBaseline='alphabetic';
}
function drawMinimap(){
'@

SubRx @'
  // you: an amber arrow, ink edged, pointing where you face
'@ @'
  try{ mmMarks(r,sc,R); }catch(_mk){ ctx.globalAlpha=1; ctx.textAlign='left'; ctx.textBaseline='alphabetic'; }   // v24.xx (minimap2): the markers, under your arrow
  // you: an amber arrow, ink edged, pointing where you face
'@

SubRx @'
var VER='25.40';
'@ @'
var VER='25.41';
'@

$pat = "(?m)^  now:'v25\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v25.41: The minimap marks the extractions and their state, the seal, teammates, doors and the enemies you can see. Check 25.41 fails on v25.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
