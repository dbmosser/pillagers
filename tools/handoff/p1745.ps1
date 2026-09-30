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

# THE OVERSEER, A BOSS AT THE MIDDLE OF THE MAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mkWarden(x,y){
'@ @'
// v17.45, HIS PICK 21 (2026-09-30): ONE BIG BOSS, THE OVERSEER, in a lair at the middle of every map. A warden four times
// over: 4000 health (times the enemy health dial), half again the damage, a warden's speed, in the open ground nearest the
// map centre (bossLair: a spiral out from the centre, tested on the wall grid as freeSpot tests). It comes up two seconds
// into the raid, not at the build, and is made from fixed numbers, so the map, its fingerprint and the seeded draws of the
// build are untouched; live play and the bot make it the same way. It guards its lair: with the player more than 1100 from
// the lair it walks home. Down, it leaves the WARDEN WRECK and the OVERSEER HOARD. The host runs it; a linked window mirrors it.
var BOSS_NAME='THE OVERSEER';
function bossLair(){
  var map=G.map, pad=50, gr, cx=WORLD_W/2, cy=WORLD_H/2, r, a, n, x, y, nw, i, w, ok;
  gr=(G.wgrid&&G.wgrid.walls===map.walls)?G.wgrid:((map._fsGrid&&map._fsGrid.walls===map.walls)?map._fsGrid:(map._fsGrid=buildWallGrid(map.walls,WORLD_W,WORLD_H)));
  for(r=0;r<=1600;r+=40){
    n=r?24:1;
    for(a=0;a<n;a++){
      x=cx+Math.cos(a/n*6.2832)*r; y=cy+Math.sin(a/n*6.2832)*r;
      if(x<70||y<70||x>WORLD_W-70||y>WORLD_H-70) continue;
      ok=1; nw=wallsNear(gr,x,y,pad);
      for(i=0;i<nw.length;i++){ w=nw[i]; if(x>w.x-pad&&x<w.x+w.w+pad&&y>w.y-pad&&y<w.y+w.h+pad){ ok=0; break; } }
      if(ok) return {x:x,y:y};
    }
  }
  return {x:cx,y:cy};
}
function bossTick(){
  var L, hp, e;
  if(typeof G==='undefined'||!G||G.over||G.bossDone||!G.map||(G.t||0)<2) return null;
  if(typeof NET!=='undefined'&&NET&&NET.on&&NET.role==='join') return null;
  if(CFG.boss===0){ G.bossDone=1; return null; }
  L=bossLair(); hp=Math.round(4000*(CFG.eHp||1));
  e={kind:'warden',boss:1,x:L.x,y:L.y,r:44,hp:hp,maxhp:hp,name:BOSS_NAME,face:0,state:'patrol',tx:L.x,ty:L.y,cd:0,alert:0,
     spd:WARDEN_SPD,dmg:Math.round((CFG.wardenDmg===undefined?46:CFG.wardenDmg)*1.5),rng:(CFG.wardenRng===undefined?620:CFG.wardenRng),
     cone:1.15,hitT:0,seenYou:false,lairX:L.x,lairY:L.y};
  G.ents.push(e); G.bossDone=1; G.bossRef=e;
  return e;
}function mkWarden(x,y){
'@

SubRx @'
function updateEnts(dt){
'@ @'
function updateEnts(dt){
  try{ bossTick(); }catch(_bt){}   // v17.45: his pick 21, THE OVERSEER comes up two seconds in
'@

SubRx @'
      if(sees){ e.seenYou=true; e.tx=p.x; e.ty=p.y; e.alert=4;
'@ @'
      if(sees){ e.seenYou=true; e.tx=p.x; e.ty=p.y; e.alert=4;
      if(e.boss&&e.lairX!==undefined&&Math.hypot(p.x-e.lairX,p.y-e.lairY)>1100){ e.tx=e.lairX; e.ty=e.lairY; e.seenYou=true; }   // v17.45: his pick 21, it guards its lair
'@

SubRx @'
        cw.cache=1; cw.time=2.0; cw.tag='WARDEN WRECK'; G.containers.push(cw);
'@ @'
        cw.cache=1; cw.time=2.0; cw.tag='WARDEN WRECK'; G.containers.push(cw);
        if(e.boss){ var cb=setLoot(mkContainer(e.x+40,e.y+10,'cache'),['reactor','codex','bloom','titan','coil']); cb.cache=1; cb.time=3.0; cb.tag='OVERSEER HOARD'; G.containers.push(cb); say(e.name+' is down. Its hoard is open.'); }   // v17.45: his pick 21
'@

SubRx @'
function drawHUD(){
'@ @'
// v17.45, his pick 21: the boss bar, top centre, while THE OVERSEER is alive and within 900 of this player.
function drawBossBar(){
  var e=null, p=G&&G.player, i, w, x, y, f;
  if(!G||G.over||!p||!G.ents) return;
  if(G.bossRef&&G.ents.indexOf(G.bossRef)>=0) e=G.bossRef;
  else for(i=0;i<G.ents.length;i++) if(G.ents[i]&&G.ents[i].name===BOSS_NAME){ e=G.ents[i]; break; }
  if(!e||!(e.hp>0)||Math.hypot(e.x-p.x,e.y-p.y)>900) return;
  f=Math.max(0,Math.min(1,e.hp/(e.maxhp||e.hp)));
  w=Math.min(520,W*0.4); x=W/2-w/2; y=LH(64);
  ctx.save();
  ctx.fillStyle='rgba(6,9,13,.72)'; ctx.fillRect(x-4,y-LH(16),w+8,LH(16)+10);
  ctx.fillStyle='#3a0d0d'; ctx.fillRect(x,y,w,6);
  ctx.fillStyle='#ff4a3a'; ctx.fillRect(x,y,w*f,6);
  ctx.font=FS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle='#ffc04a'; ctx.fillText(e.name,W/2,y-LH(4));
  ctx.restore();
}function drawHUD(){
  try{ drawBossBar(); }catch(_bb){}   // v17.45: his pick 21
'@

SubRx @'
var VER='17.44';
'@ @'
var VER='17.45';
'@

$pat = "(?m)^  now:'v17\.44:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v17.45: THE OVERSEER, his pick from the feature list: one big boss in a lair at the middle of every map, a warden four times over (4000 health, half again the damage), up two seconds into the raid, guarding its lair, with a boss bar while you are near, and the OVERSEER HOARD where it falls. The map build and its fingerprint are untouched. Check 17.45 fails on v17.44',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
