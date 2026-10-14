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

# THE FORGE STANDS IN EVERY RAID (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  story:{x:1900,y:360,name:'THE MANIFEST',
'@ @'
  // v26.xx (forgest1), HIS QUESTION 2026-10-14 ("I still haven't seen the forge to improve weapons, is it on the map?"): THE FORGE STATION. The
  // upgrade rules shipped (v24.03 to v25.58); this is the place you walk up to. Authored in the 170 unit aisle between the PACKING FLOOR racking
  // and the CHILL ROW units, 330 from the middle of the map; forgeSpot nudges it to the nearest clear, reachable ground. A map with no forge
  // field has no station.
  forge:{x:2420,y:1540,name:'THE FORGE'},
  story:{x:1900,y:360,name:'THE MANIFEST',
'@

SubRx @'
function sealPayout(tier){
'@ @'
// v26.xx (forgest1), HIS QUESTION 2026-10-14: THE FORGE STATION is placed at the raid build, after every seeded pass, and draws NOTHING from any
// stream (the spiral is fixed), so a seed builds the same raid as before: the same ents and the same containers. It is not a wall and not an
// ent, like the seal slab. From the authored point of the map it takes the first spot that is clear of every solid wall by 34, clear of every
// crate by 60 and on ground a body can reach; else the same 16 heading spiral the seal uses, 40 units a ring out to 400; else the authored
// point itself, so the station is never lost. Both windows of a pair build the same walls from the same seed, so they agree on the spot.
var FORGE_REACH=70;
function forgeSpot(map,def,cons){
  var f=def&&def.forge, MW=(map&&map.walls)||[], CN=cons||[], r, h, a, x, y;
  if(!f||!isFinite(f.x)||!isFinite(f.y)) return null;
  function clearAt(px,py){
    var i, R, Q;
    if(px<140||py<140||px>WORLD_W-140||py>WORLD_H-140) return false;
    for(i=0;i<MW.length;i++){ R=MW[i]; if(R&&!R.win&&!R.ledge&&px>R.x-34&&px<R.x+R.w+34&&py>R.y-34&&py<R.y+R.h+34) return false; }
    for(i=0;i<CN.length;i++){ Q=CN[i]; if(Q&&Math.abs(Q.x-px)<60&&Math.abs(Q.y-py)<60&&Math.hypot(Q.x-px,Q.y-py)<60) return false; }
    if(map&&map.reachGrid&&!navReachable(map,px,py)) return false;
    return true;
  }
  if(clearAt(f.x,f.y)) return {x:f.x,y:f.y,name:String(f.name||'THE FORGE')};
  for(r=40;r<=400;r+=40) for(h=0;h<16;h++){
    a=h*0.3926991; x=Math.round(f.x+Math.cos(a)*r); y=Math.round(f.y+Math.sin(a)*r);
    if(clearAt(x,y)) return {x:x,y:y,name:String(f.name||'THE FORGE')};
  }
  return {x:f.x,y:f.y,name:String(f.name||'THE FORGE')};
}
// The anvil, one silhouette for the world, the minimap and the sector map: a horn on the left, a flat face, a waist and a base. c is the
// context, (x,y) the middle, s the half width; filled in fill with an ink edge.
var FORGE_ANVIL=[[-1,-0.35],[-0.45,-0.58],[0.95,-0.58],[0.95,-0.14],[0.3,-0.14],[0.2,0.14],[0.55,0.46],[0.55,0.78],[-0.55,0.78],[-0.55,0.46],[-0.2,0.14],[-0.28,-0.14],[-0.7,-0.14]];
function forgeAnvil(c,x,y,s,fill,ink){
  var i, P=FORGE_ANVIL;
  c.save();
  c.beginPath(); c.moveTo(x+P[0][0]*s,y+P[0][1]*s);
  for(i=1;i<P.length;i++) c.lineTo(x+P[i][0]*s,y+P[i][1]*s);
  c.closePath();
  c.lineJoin='round'; c.lineWidth=Math.max(1.2,s*0.3); c.strokeStyle=ink; c.stroke();
  c.fillStyle=fill; c.fill();
  c.restore();
}
function sealPayout(tier){
'@

SubRx @'
seal:(sim?null:{x:G_SEAL_SPOT.x,y:G_SEAL_SPOT.y,gained:0}),
'@ @'
seal:(sim?null:{x:G_SEAL_SPOT.x,y:G_SEAL_SPOT.y,gained:0}), forge:(sim?null:forgeSpot(map,FIXED_MAPS[mapIx],containers)),
'@

SubRx @'
  function _pushThrown(){
'@ @'
  // v26.xx (forgest1), HIS QUESTION 2026-10-14: THE FORGE STATION in the world, from the depth sort. A furnace block with a pulsing molten
  // mouth, a chimney with embers rising, an anvil on top, a warm glow on the ground (and a bloom source for the night), a dashed reach ring
  // and its name over it, a clear landmark from across the aisle. Cosmetic only: the pulse runs off the raid clock, nothing is drawn
  // from any stream.
  function drawForge(){
    var F=G.forge, t=G.t||0, sp, pu, pv, k, ph, fx, fy, gl, near;
    if(!F||!isFinite(F.x)||!isFinite(F.y)) return;
    sp=w2s(F.x,0,F.y);
    if(sp.x<-220||sp.x>W+220||sp.y<-260||sp.y>H+220) return;
    fx=F.x; fy=F.y; near=!!G.nearForge;
    pu=0.5+0.5*Math.sin(t*2.6); pv=0.5+0.5*Math.sin(t*7.1+1.3);
    wc.save(); wc.globalCompositeOperation='lighter';
    gl=wc.createRadialGradient(fx,fy+4,6,fx,fy+4,96);
    gl.addColorStop(0,'rgba(255,150,40,'+(0.30+0.12*pu).toFixed(3)+')'); gl.addColorStop(1,'rgba(255,110,20,0)');
    wc.fillStyle=gl; wc.beginPath(); wc.ellipse(fx,fy+4,96,54,0,0,6.2832); wc.fill();
    wc.restore();
    wc.save(); wc.strokeStyle=near?'rgba(255,201,74,.60)':'rgba(255,201,74,.22)'; wc.lineWidth=near?2:1.4; wc.setLineDash([6,7]);
    wc.beginPath(); wc.ellipse(fx,fy+4,FORGE_REACH,FORGE_REACH*0.56,0,0,6.2832); wc.stroke(); wc.restore();
    wc.fillStyle='rgba(10,8,6,.42)'; wc.beginPath(); wc.ellipse(fx,fy+6,34,11,0,0,6.2832); wc.fill();
    wc.fillStyle=INK; rrF(fx-28,fy-13,56,19,3);
    wc.fillStyle='#3b414a'; rrF(fx-26,fy-12,52,16,2); wc.fillStyle='#5b6470'; wc.fillRect(fx-26,fy-12,52,2);
    wc.fillStyle=INK; rrF(fx-24,fy-50,48,40,3);
    wc.fillStyle='#2a2f37'; rrF(fx-22,fy-48,44,36,2); wc.fillStyle='#454d58'; wc.fillRect(fx-22,fy-48,44,3);
    wc.fillStyle='rgba(0,0,0,.30)'; for(k=0;k<3;k++) wc.fillRect(fx-22,fy-40+k*9,44,1);
    wc.fillStyle=INK; wc.fillRect(fx+9,fy-70,13,24); wc.fillStyle='#343a43'; wc.fillRect(fx+11,fy-68,9,22); wc.fillStyle='#4b535e'; wc.fillRect(fx+11,fy-68,9,2);
    wc.fillStyle=INK; wc.fillRect(fx-16,fy-41,32,17);
    gl=wc.createLinearGradient(0,fy-39,0,fy-26);
    gl.addColorStop(0,'#ffe9a8'); gl.addColorStop(0.45,'#ff9a2a'); gl.addColorStop(1,'#a8300a');
    wc.globalAlpha=0.78+0.22*pv; wc.fillStyle=gl; wc.fillRect(fx-14,fy-39,28,13); wc.globalAlpha=1;
    wc.save(); wc.globalCompositeOperation='lighter'; wc.globalAlpha=0.30+0.20*pv; wc.fillStyle='#ff8a2a'; wc.fillRect(fx-14,fy-39,28,13); wc.restore();
    forgeAnvil(wc,fx-7,fy-60,14,'#59626e',INK);
    wc.save(); wc.globalCompositeOperation='lighter';
    for(k=0;k<4;k++){ ph=(t*0.55+k*0.25)%1; wc.globalAlpha=(1-ph)*0.85; wc.fillStyle=(k&1)?'#ffb040':'#ff7a2a'; wc.fillRect(fx+14+Math.sin(t*2.3+k*1.9)*6,fy-72-ph*40,2,2); }
    wc.restore();
    wc.textAlign='center'; wc.font=FS(TYPE.label);
    wc.fillStyle=INK; wc.fillText(F.name||'THE FORGE',fx+1,fy-83);
    wc.fillStyle=FORGE_GOLD; wc.fillText(F.name||'THE FORGE',fx,fy-84);
    wc.textAlign='left';
    gfxEmit(fx,fy-30,120,'#ff8a2a',0.5+0.12*pv);
  }
  function _pushThrown(){
'@

SubRx @'
  if(G.seal) DR.push({k:G.seal.y,fn:drawSealSlab});
'@ @'
  if(G.seal) DR.push({k:G.seal.y,fn:drawSealSlab});
  if(G.forge) DR.push({k:G.forge.y,fn:drawForge});   // v26.xx (forgest1): the Forge station
'@

SubRx @'
    else { ctx.fillStyle=INK; ctx.beginPath(); ctx.arc(s.x,s.y,6*R,0,6.2832); ctx.fill(); ctx.fillStyle=FORGE_GOLD; ctx.beginPath(); ctx.arc(s.x,s.y,4*R,0,6.2832); ctx.fill(); MMAP.ops+=2; got.forge='in'; }
'@ @'
    else { forgeAnvil(ctx,s.x,s.y,6.5*R,FORGE_GOLD,INK); MMAP.ops+=2; got.forge='in'; }   // v26.xx (forgest1): the anvil, not a dot
'@

SubRx @'
  // THE STRONGBOX. Marked from the start: it is not a secret, it is a dare.
'@ @'
  // v26.xx (forgest1), HIS QUESTION 2026-10-14: THE FORGE on the sector map, a gold anvil in a ring with its name, at the map zoom.
  if(G.forge&&isFinite(G.forge.x)&&isFinite(G.forge.y)){
    var fgx=ox+G.forge.x*sc, fgy=oy+G.forge.y*sc;
    ctx.fillStyle='rgba(255,201,74,.16)'; ctx.beginPath(); ctx.arc(fgx,fgy,14*_MZ,0,6.2832); ctx.fill();
    ctx.strokeStyle=FORGE_GOLD; ctx.lineWidth=1.5*_MZ; ctx.beginPath(); ctx.arc(fgx,fgy,14*_MZ,0,6.2832); ctx.stroke();
    forgeAnvil(ctx,fgx,fgy,8.5*_MZ,FORGE_GOLD,INK);
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro); ctx.fillStyle=FORGE_GOLD;
    ctx.fillText(String(G.forge.name||'THE FORGE'),fgx,fgy-19*_MZ); ctx.textAlign='left';
  }
  // THE STRONGBOX. Marked from the start: it is not a secret, it is a dare.
'@

SubRx @'
var VER='26.19';
'@ @'
var VER='26.20';
'@

$pat = "(?m)^  now:'v26\.19:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.20: THE FORGE now stands in every raid and is marked on the minimap and the map. Upgrading guns there comes next. Check 26.20 fails on v26.19',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
