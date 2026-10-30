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

# GOLDEN ENEMIES BOLT AND STAY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var GOLD={tag:65,hp:3,big:1.1,minD:700,kinds:{crawler:1,sentry:1,raider:1,bulwark:1,howler:1,listener:1}};
'@ @'
var GOLD={tag:65,hp:3,big:1.1,minD:700,runT:3.5,runCd:5,runSpd:1.35,kinds:{crawler:1,sentry:1,raider:1,bulwark:1,howler:1,listener:1}};
'@

SubRx @'
  e.golden=1; e.maxhp=Math.round((e.maxhp||e.hp)*GOLD.hp); e.hp=e.maxhp; e.r=Math.round(e.r*GOLD.big);
'@ @'
  e.golden=1; e.maxhp=Math.round((e.maxhp||e.hp)*GOLD.hp); e.hp=e.maxhp; e.r=Math.round(e.r*GOLD.big);
  e.gHp=e.hp;   // v28.xx (cw-cx-goldbolt): remember the first hit after gilding.
'@

SubRx @'
function goldS(){ var S=flowS(); if(!S.gold) S.gold={ref:null,hp0:0,dead:0,tried:0}; return S.gold; }
'@ @'
// v28.xx (cw-cx-goldbolt), his g-21 and g-22: "Run, so you chase it" and "No, it stays all raid".
function goldRunTick(e,dt){
  if(!e.golden||flowPeer()) return false;
  var hit=e.gHp!==undefined&&e.hp<e.gHp, men, p=null, d=Infinity, i, dd, a, offsets, x, y, step, ox, oy;
  e.gRunCd=Math.max(0,(e.gRunCd||0)-dt);
  if(!(e.hp>0)||e.downed) return false;
  if(e.state==='extract'){ e.state='patrol'; e.extracting=0; }
  men=netPlayersList();
  for(i=0;i<men.length;i++){ dd=dist(e,men[i]); if(dd<d){ d=dd; p=men[i]; } }
  if(hit&&p&&!(e.gRunT>0)&&!(e.gRunCd>0)){
    e.gRunT=GOLD.runT; a=Math.atan2(e.y-p.y,e.x-p.x); offsets=[0,0.6,-0.6,1.2,-1.2];
    e.gRunX=e.x; e.gRunY=e.y;
    for(i=0;i<offsets.length;i++){
      x=e.x+Math.cos(a+offsets[i])*520; y=e.y+Math.sin(a+offsets[i])*520;
      if(spotFree(G.map,x,y,e.r+4)&&navReachable(G.map,x,y)){ e.gRunX=x; e.gRunY=y; break; }
    }
    if(i===offsets.length){
      step=Math.max(0,rayHitG(e.x,e.y,Math.cos(a),Math.sin(a),520)-40);
      x=clamp(e.x+Math.cos(a)*step,e.r+4,WORLD_W-e.r-4);
      y=clamp(e.y+Math.sin(a)*step,e.r+4,WORLD_H-e.r-4);
      if(spotFree(G.map,x,y,e.r+4)&&navReachable(G.map,x,y)){ e.gRunX=x; e.gRunY=y; }
    }
    e.path=null; e.pathT=0; e.pathFail=false; e.roll=0; e.glint=0;
  }
  if(!(e.gRunT>0)) return false;
  ox=e.x; oy=e.y;
  navSeek(e,e.gRunX,e.gRunY,e.spd*GOLD.runSpd,dt);
  collide(e,G.map.walls);
  e.moving=Math.hypot(e.x-ox,e.y-oy)>0.01;
  if(e.moving) e.face=Math.atan2(e.y-oy,e.x-ox);
  e.gRunT=Math.max(0,e.gRunT-dt);
  if(e.gRunT<1e-7){
    e.gRunT=0; e.gRunCd=GOLD.runCd; e.state='chase'; e.alert=2.6;
    if(p){ e.tx=p.x; e.ty=p.y; }
    e.path=null; e.pathT=0; e.pathFail=false;
  }
  return true;
}
function goldS(){ var S=flowS(); if(!S.gold) S.gold={ref:null,hp0:0,dead:0,tried:0}; return S.gold; }
'@

SubRx @'
    // A man on the floor does nothing but bleed. No AI below this line runs for
'@ @'
    if(goldRunTick(e,dt)) continue;   // v28.xx (cw-cx-goldbolt): fleeing owns this turn, before rolls, bites or guns.
    // A man on the floor does nothing but bleed. No AI below this line runs for
'@

SubRx @'
    e.face+=clamp(angDiff(want,e.face),-5.5*dt,5.5*dt);
    collide(e,G.map.walls);
  }
}
'@ @'
    e.face+=clamp(angDiff(want,e.face),-5.5*dt,5.5*dt);
    collide(e,G.map.walls);
  }
  // v28.xx (cw-cx-goldbolt): snapshot every golden after all AI branches, including early continues.
  if(!flowPeer()) for(var _gh=0;_gh<G.ents.length;_gh++) if(G.ents[_gh].golden) G.ents[_gh].gHp=G.ents[_gh].hp;
}
'@

SubRx @'
if(e.kind==='raider'&&e.state!=='extract'&&!e.cornered&&e.hp<e.maxhp*0.3){   // v23.xx: a man who turned on the one shooting him (runnerTurns) does not bolt again
'@ @'
if(e.kind==='raider'&&!e.golden&&e.state!=='extract'&&!e.cornered&&e.hp<e.maxhp*0.3){   // v23.xx: a man who turned on the one shooting him (runnerTurns) does not bolt again
'@

SubRx @'
        if(!e.goal||(e.looted||0)>=(e.ghostHaul||CFG.raiderHaul)) e.state='extract';
'@ @'
        // v28.xx (cw-cx-goldbolt): the golden haul stays here; no loot left means a patrol.
        if(!e.golden&&(!e.goal||(e.looted||0)>=(e.ghostHaul||CFG.raiderHaul))) e.state='extract';
        else if(e.golden&&!e.goal) e.state='patrol';
'@

SubRx @'
    if(!e||!e.arcWave||e.boss||!(e.hp>0)) continue;
'@ @'
    if(!e||!e.arcWave||e.boss||e.golden||!(e.hp>0)) continue;   // v28.xx (cw-cx-goldbolt): a living golden stays all raid.
'@

SubRx @'
    if(evBodyAway(e)) G.ents.splice(k,1);   // v27.43 (rvw1, cloud review 10): out of the world only where nobody can see it
'@ @'
    if(!e.golden&&evBodyAway(e)) G.ents.splice(k,1);   // v27.43 (rvw1, cloud review 10): out of the world only where nobody can see it
'@

SubRx @'
  if(e.hp<(e.maxhp||100)*0.45&&(e.smkT===undefined||e.smkT<=0)){
'@ @'
  if(!e.golden&&e.hp<(e.maxhp||100)*0.45&&(e.smkT===undefined||e.smkT<=0)){   // v28.xx (cw-cx-goldbolt): the golden chase drops no smoke.
'@

SubRx @'
  if(e&&!S.dead&&(!(e.hp>0)||G.ents.indexOf(e)<0)){ S.dead=1; S.dx=e.x; S.dy=e.y; S.kind=e.kind; goldDrop(e.x,e.y,e.kind); }
'@ @'
  if(e&&!S.dead&&!(e.hp>0)){ S.dead=1; S.dx=e.x; S.dy=e.y; S.kind=e.kind; goldDrop(e.x,e.y,e.kind); }   // v28.xx (cw-cx-goldbolt): only a real death pays the hoard.
'@

SubRx @'
var VER='36.63';
'@ @'
var VER='36.64';
'@

$pat = "(?m)^  now:'v36\.63:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.64: Hurt golden enemies run for 3.5 seconds at 1.35 speed, then chase again with a five second cooldown. They never extract, get culled, or leave with a convoy. Only death drops the hoard. Check 36.64 fails on v36.63',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
