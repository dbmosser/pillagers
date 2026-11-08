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

# THE JUGGERNAUT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
}function mkWarden(x,y){
'@ @'
}
// v28.xx (cw-cx-juggernaut), his g-52: "Yes, a machine boss too". Only the raid authority builds it; all new draws borrow the effects stream.
var BOSS2_NAME='the juggernaut';
function bossTick2(force,known){
  if(typeof G==='undefined'||!G||G.over||G.boss2Done||!G.map||!(G.arcade||G.career)||(G.t||0)<4) return null;
  if(!force&&NET&&NET.on&&NET.role==='join') return null;
  if(CFG.boss===0){ G.boss2Done=1; return null; }
  var L=bossLair(), best=null, bd=1800, map=G.map, e=null;
  fxBorrow(function(){
    var pts=(map.spawns||[]).slice(), j, k, p, d, ok, w, near;
    var gr=(G.wgrid&&G.wgrid.walls===map.walls)?G.wgrid:((map._fsGrid&&map._fsGrid.walls===map.walls)?map._fsGrid:(map._fsGrid=buildWallGrid(map.walls,WORLD_W,WORLD_H)));
    for(j=0;j<40;j++) pts.push(freeSpot(map,50));
    for(j=0;j<pts.length;j++){
      p=pts[j]; d=dist(p,L); if(d<bd||p.x<70||p.y<70||p.x>WORLD_W-70||p.y>WORLD_H-70) continue;
      ok=true; near=wallsNear(gr,p.x,p.y,50);
      for(k=0;k<near.length;k++){ w=near[k]; if(p.x>w.x-50&&p.x<w.x+w.w+50&&p.y>w.y-50&&p.y<w.y+w.h+50){ ok=false; break; } }
      if(!ok) continue;
      for(k=0;k<(map.spawns||[]).length;k++) if(dist(p,map.spawns[k])<900){ ok=false; break; }
      for(k=0;ok&&k<(G.zones||[]).length;k++) if(dist(p,G.zones[k])<900) ok=false;
      if(ok){ best={x:p.x,y:p.y}; bd=d; }
    }
    if(known) best={x:typeof known.lairX==='number'?known.lairX:known.x,y:typeof known.lairY==='number'?known.lairY:known.y};
    if(best) e=mkBulwark(best.x,best.y);
  });
  G.boss2Done=1;
  if(!e) return null;
  e.elite=0; e.affix=null; e.shieldHp=0; e.spd=52; e.boss2=1; e.name=BOSS2_NAME; e.r=31;
  e.hp=e.maxhp=Math.round(3000*CFG.eHp); e.dmg=22; e.rng=420;
  e.lairX=best.x; e.lairY=best.y; G.ents.push(e); G.boss2Ref=e;
  return e;
}
// v28.xx (cw-cx-juggernaut): the bulwark uses the generic machine AI, not the warden branch. Its own leash keeps the same big-shot/open cycle.
function juggernautTick(e,p,sees,dt){
  var lx=e.lairX, ly=e.lairY, d=dist(e,p), target;
  if(sees){ e.seenYou=true; e.state='chase'; e.alert=4; e.tx=p.x; e.ty=p.y; }
  if(e.seenYou){
    if(Math.hypot(e.tx-lx,e.ty-ly)>1600||(!sees&&dist(e,{x:e.tx,y:e.ty})<70)){ e.tx=lx; e.ty=ly; }
    target={x:e.tx,y:e.ty};
    if(!sees||Math.hypot(p.x-lx,p.y-ly)>1600){ if(dist(e,target)>40) navSeek(e,target.x,target.y,e.spd,dt); }
    else if(d>e.rng*.72) navSeek(e,target.x,target.y,e.spd,dt);
    else if(d<e.rng*.35&&Math.hypot(e.x-lx,e.y-ly)<1550) moveToward(e,e.x-(p.x-e.x),e.y-(p.y-e.y),e.spd*.6,dt);
  }else{
    if(e.cd<=0) fxBorrow(function(){
      var s=freeSpot(G.map,50), a=Math.atan2(s.y-ly,s.x-lx), reach=Math.min(1600,dist(s,{x:lx,y:ly}),Math.max(0,rayHitG(lx,ly,Math.cos(a),Math.sin(a),1660)-60));
      e.tx=lx+Math.cos(a)*reach; e.ty=ly+Math.sin(a)*reach; e.cd=rnd(6,10);
    });
    if(Math.hypot(e.tx-lx,e.ty-ly)>1600){ e.tx=lx; e.ty=ly; }
    moveToward(e,e.tx,e.ty,e.spd*.6,dt);
  }
  if(Math.hypot(e.x-lx,e.y-ly)>1600) navSeek(e,lx,ly,e.spd,dt);
  var want=Math.atan2((sees?p.y:e.ty)-e.y,(sees?p.x:e.tx)-e.x);
  e.face+=clamp(angDiff(want,e.face),-2.5*dt,2.5*dt);
  if(e.cd>0) e.cd-=dt;
  if(e.windup!==undefined&&e.windup!==null){
    e.windup-=dt;
    if(e.windup<=0){
      e.windup=null;
      if(sees&&d<e.rng*1.15&&!p.downed){ fireWeapon(e,{dmg:e.dmg*(e.bigW?2.5:1),spread:.10,rng:e.rng,noise:340,tint:'#ff9a6a'},p.x+rnd(-16,16),p.y+rnd(-16,16),false); e.shotN=(e.shotN||0)+1; if(e.bigW) e.openT=BULWARK_OPEN; }
      e.bigW=0; e.cd=rnd(0,.35);
    }
  }else if(e.cd<=0&&sees&&d<e.rng&&!p.downed){ e.bigW=((e.shotN||0)+1)%BULWARK_SHOT_N===0?1:0; e.windup=e.bigW?.7:.4; if(!G.sim) sfx('charge',e.x,e.y); }
  collide(e,G.map.walls);
}
function mkWarden(x,y){
'@

SubRx @'
  try{ bossTick(); }catch(_bt){}
'@ @'
  try{ bossTick(); bossTick2(); }catch(_bt){}
'@

SubRx @'
    if(e.kind==='warden'){
      // THE GHOST RUN DIES HERE
'@ @'
    if(e.boss2){ juggernautTick(e,p,sees,dt); continue; } // v28.xx (cw-cx-juggernaut): authority only, after death and status handling.
    if(e.kind==='warden'){
      // THE GHOST RUN DIES HERE
'@

SubRx @'
      if(e.kind==='warden'){
        var cw=setLoot
'@ @'
      // v28.xx (cw-cx-juggernaut): the normal bulwark wreck still drops below; the boss also leaves its hoard.
      if(e.boss2){
        fxBorrow(function(){ var c=setLoot(mkContainer(e.x+40,e.y+10,'cache'),['reactor','titan','coil',vaultGunPick()]); c.cache=1; c.time=3.0; c.tag='juggernaut hoard'; G.containers.push(c); });
        say('the juggernaut destroyed','obj');
      }
      if(e.kind==='warden'){
        var cw=setLoot
'@

SubRx @'
e.kind==='bulwark'?FIG_MACH*BULWARK_BIG:FIG_MACH
'@ @'
e.kind==='bulwark'?FIG_MACH*BULWARK_BIG*(e.boss2?1.3:1):FIG_MACH
'@

SubRx @'
  e.boss=(e.kind==='warden'&&e.name===BOSS_NAME)?1:0;
'@ @'
  e.boss2=(e.kind==='bulwark'&&e.name===BOSS2_NAME)?1:0; // v28.xx (cw-cx-juggernaut): late bodies keep the larger art and identity.
  e.boss=(e.kind==='warden'&&e.name===BOSS_NAME)?1:0;
'@

SubRx @'
hit.kind==='raider'||hit.boss||hit.name===BOSS_NAME
'@ @'
hit.kind==='raider'||hit.boss||hit.boss2||hit.name===BOSS_NAME
'@

SubRx @'
  if(e.kind==='raider'){ m.fk=
'@ @'
  if(e.boss2){ m.lx=e.lairX; m.ly=e.lairY; } // v28.xx (cw-cx-juggernaut): keep the original far lair for takeover.
  if(e.kind==='raider'){ m.fk=
'@

SubRx @'
  if(e.kind==='raider'){
    if(typeof m.c==='string'
'@ @'
  if(e.boss2&&typeof m.lx==='number'&&typeof m.ly==='number'){ e.lairX=m.lx; e.lairY=m.ly; }
  if(e.kind==='raider'){
    if(typeof m.c==='string'
'@

SubRx @'
var _i, _e, _boss=null, _b, _k;
'@ @'
var _i, _e, _boss=null, _boss2=null, _b, _k;
'@

SubRx @'
if(_e.net){ if(_e.name===BOSS_NAME&&!_boss) _boss=_e; continue; }
'@ @'
if(_e.net){ if(_e.name===BOSS_NAME&&!_boss) _boss=_e; if(_e.name===BOSS2_NAME&&!_boss2) _boss2=_e; continue; }
'@

SubRx @'
if(_e.name===BOSS_NAME) _boss=_e; G.ents.splice(_i,1);
'@ @'
if(_e.name===BOSS_NAME) _boss=_e; if(_e.name===BOSS2_NAME) _boss2=_e; G.ents.splice(_i,1);
'@

SubRx @'
  else if((G.t||0)>=2) G.bossDone=1;
'@ @'
  else if((G.t||0)>=2) G.bossDone=1;
  // v28.xx (cw-cx-juggernaut): a dead or absent boss stays gone; a surviving mirror resumes its health share and last position.
  if(_boss2&&_boss2.hp>0){ G.boss2Done=0; _b=bossTick2(true,_boss2); if(_b){ _b.hp=Math.max(1,Math.round(_b.maxhp*Math.min(1,_boss2.hp/(_boss2.maxhp||1)))); _b.x=_boss2.x; _b.y=_boss2.y; } }
  else if((G.t||0)>=4) G.boss2Done=1;
'@

SubRx @'
function arcadeKillPts(k,el,boss){ var n=boss?ARCADE_BOSSPTS:
'@ @'
function arcadeKillPts(k,el,boss,boss2){ var n=boss2?ARCADE_BOSSPTS/2:boss?ARCADE_BOSSPTS:
'@

SubRx @'
n=arcadeKillPts(e.kind,e.affix&&e.elite?3:e.elite,e.boss);
'@ @'
n=arcadeKillPts(e.kind,e.affix&&e.elite?3:e.elite,e.boss,e.boss2);
'@

SubRx @'
function scoreKill(st,k,el,boss,x,y){
  var n=arcadeKillPts(k,el,boss);
'@ @'
function scoreKill(st,k,el,boss,x,y,boss2){
  var n=arcadeKillPts(k,el,boss,boss2);
'@

SubRx @'
var n=scoreKill(G.cs,k,el,boss,x,y);
'@ @'
var n=scoreKill(G.cs,k,el,boss,x,y,ke&&ke.boss2);
'@

SubRx @'
function arcadeKill(k,el,boss,x,y,ke){
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  try{ flowKill(k,el,boss); }catch(_fk1){}   // v26.xx (flow3): the run goals count what died
  var n=arcadeKillPts(k,el,boss);
'@ @'
function arcadeKill(k,el,boss,x,y,ke){
  if(!ARCADE.on||!G||!G.arcade||G.sim||G.over) return 0;
  try{ flowKill(k,el,boss); }catch(_fk1){}   // v26.xx (flow3): the run goals count what died
  var n=arcadeKillPts(k,el,boss,ke&&ke.boss2);
'@

SubRx @'
affix:!!m.af,boss:!!m.boss,x:m.x,y:m.y
'@ @'
affix:!!m.af,boss:!!m.boss,boss2:!!m.boss2,x:m.x,y:m.y
'@

SubRx @'
af:e.affix?1:0,boss:!!e.boss,x:e.x,y:e.y
'@ @'
af:e.affix?1:0,boss:!!e.boss,boss2:!!e.boss2,x:e.x,y:e.y
'@

SubRx @'
var VER='37.58';
'@ @'
var VER='37.59';
'@

$pat = "(?m)^  now:'v37\.58:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.59: A larger bulwark boss roams the far half, pays 1000 base sp and leaves a juggernaut hoard. Its name, size and health survive party mirroring and takeover. Check 37.59 fails on v37.58',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
