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

# THE OVERSEER FIGHTS IN THREE PHASES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function feudFoe(a,b){
'@ @'
// v26.xx (ai24), HIS YES (2026-10-14, suggestion 24): THE OVERSEER'S PHASES. It was one long health bar with a cannon. Now it has three
// readable phases by health: PHASE 1 above 66 percent is as it was. At 66 percent it PAUSES for 1.4 seconds (a shockwave ring, the
// camera shakes, a callout), then PHASE 2 calls crawlers out of the ground around it (three at once, again every 20 seconds while it
// has seen you, never more than six of its own alive). At 33 percent it pauses again and PHASE 3 begins a SWEEPING LASER every ten
// seconds: it stands still, turns to your bearing, charges for a second (the red aim lane of ai20 fills), then sweeps a beam across
// about 90 degrees at 0.6 radians a second, stopped by walls, which hurts anyone in it (8 every tenth of a second; outrun it along the
// sweep, or put a wall in the way). When the sweep ends its CORE IS EXPOSED: it vents for four seconds (no move, no shot, as a seam hit
// does it) and every round that hits it does half again as much. The big score for killing it (ARCADE_BOSSPTS) is unchanged. The host
// runs all of it; a linked window sees the beam through a flag bit and the phase lines through a mark. Its crawlers are made on the
// cosmetic stream (fxBorrow), so the seeded stream of the raid never moves.
var OV_P2=0.66, OV_P3=0.33, OV_SUMMON=20, OV_SWEEPCD=10, OV_CHARGE=1.0, OV_SWEEP=2.6, OV_RATE=0.6, OV_HALF=18, OV_TICK=0.1, OV_DMG=8, OV_MAXC=6;
function overseerPhaseOf(e){ var f=(e&&e.maxhp>0)?e.hp/e.maxhp:1; return f>OV_P2?1:(f>OV_P3?2:3); }
function ovPhaseLine(n){ return (n>=3)?'OVERSEER SWEEP LASER':'OVERSEER CALLS CRAWLERS'; }
function overseerBeam(e){
  var ux, uy, t;
  if(!e||!(e.swpT>0)||!(e.hp>0)) return null;
  ux=Math.cos(e.face); uy=Math.sin(e.face);
  try{ t=rayHitG(e.x,e.y,ux,uy,e.rng||868); }catch(_ob){ t=e.rng||868; }
  if(!(t>0)) return null;
  return {x1:e.x+ux*e.r*0.6,y1:e.y+uy*e.r*0.6,x2:e.x+ux*t,y2:e.y+uy*t,ux:ux,uy:uy,len:t};
}
function overseerSummon(e){
  var n=0, made=0, i, c, a, x, y, pl=G.player;
  for(i=0;i<G.ents.length;i++){ c=G.ents[i]; if(c.summoned&&c.hp>0&&!c.downed) n++; }
  for(i=0;i<12&&made<3&&n+made<OV_MAXC;i++){
    a=i*0.5236+(G.t||0)*0.7; x=e.x+Math.cos(a)*(e.r+80); y=e.y+Math.sin(a)*(e.r+80);
    if(!(x>60&&y>60&&x<WORLD_W-60&&y<WORLD_H-60)||!spotFree(G.map,x,y,18)) continue;
    c=null; fxBorrow(function(){ c=mkCrawler(x,y); });
    c.summoned=1; c.state='chase'; c.alert=3; c.tx=pl?pl.x:x; c.ty=pl?pl.y:y;
    G.ents.push(c); made++;
    i+=3;
  }
  return made;
}
function overseerTick(e,p,sees,dt){
  var ph, i, pl, pls, L, dx, dy, al, pp;
  if(!e||!e.boss||!(e.hp>0)) return false;
  ph=overseerPhaseOf(e);
  if(!e.phase) e.phase=1;
  if(ph>e.phase){
    e.phase=ph; e.stagT=1.4; e.sumT=0; e.sweepCd=OV_SWEEPCD*0.5; e.chgT=0; e.swpT=0; e.windup=null;
    if(!G.sim){
      G.shake=Math.max(G.shake||0,6); sfx('alarm',e.x,e.y); ping(e.x,e.y,900,false,false,'robot','fire',e);
      say(ovPhaseLine(ph),'warn');
      if(NET.on) netMarkSend({t:'mark',k:'phase',nid:e.nid|0,n:ph});
    }
  }
  if(e.stagT>0){ e.stagT-=dt; e.moving=false; e.cd=Math.max(e.cd||0,0.4); return true; }
  if(ph>=2&&e.seenYou){ e.sumT=(e.sumT||0)-dt; if(e.sumT<=0){ e.sumT=OV_SUMMON; overseerSummon(e); } }
  if(ph<3) return false;
  if(e.chgT>0){
    e.chgT-=dt; e.windup=Math.max(0.001,0.7*e.chgT/OV_CHARGE); e.moving=false; e.cd=Math.max(e.cd||0,0.4);
    e.face+=clamp(angDiff(e.swpA,e.face),-4*dt,4*dt);
    if(e.chgT<=0){ e.chgT=0; e.windup=null; e.swpT=OV_SWEEP; e.swpTk=0; e.face=e.swpA; if(!G.sim) sfx('alarm',e.x,e.y); }
    return true;
  }
  if(e.swpT>0){
    e.swpT-=dt; e.swpA+=e.swpD*OV_RATE*dt; e.face=e.swpA; e.moving=false; e.cd=Math.max(e.cd||0,0.4);
    e.swpTk=(e.swpTk||0)-dt;
    if(e.swpTk<=0){
      e.swpTk=OV_TICK; L=overseerBeam(e);
      if(L){
        pls=(typeof netPlayersList==='function')?netPlayersList():[G.player];
        for(i=0;i<pls.length;i++){
          pl=pls[i]; if(!pl||pl.downed||pl.dying||pl.specOut) continue;
          dx=pl.x-e.x; dy=pl.y-e.y; al=dx*L.ux+dy*L.uy; pp=Math.abs(dx*L.uy-dy*L.ux);
          if(al>0&&al<L.len+(pl.r||11)&&pp<OV_HALF+(pl.r||11)) netHitPlayer(pl,OV_DMG,'warden',BOSS_NAME,e.x,e.y);
        }
      }
    }
    if(e.swpT<=0){ e.swpT=0; e.overheat=4.0; e.htImmune=Math.max(e.htImmune||0,7); e.sweepCd=OV_SWEEPCD; e.cd=Math.max(e.cd||0,1.2); }
    return true;
  }
  e.sweepCd=(e.sweepCd===undefined?OV_SWEEPCD*0.5:e.sweepCd)-dt;
  if(e.sweepCd<=0&&sees&&p&&!p.downed&&dist(e,p)<e.rng){
    e.swpN=(e.swpN||0)+1; e.swpD=(e.swpN%2)?1:-1;
    e.swpA=Math.atan2(p.y-e.y,p.x-e.x)-e.swpD*(OV_RATE*OV_SWEEP*0.5);
    e.chgT=OV_CHARGE; e.windup=0.7; if(!G.sim) sfx('charge',e.x,e.y);
    return true;
  }
  return false;
}
function feudFoe(a,b){
'@

SubRx @'
      var _bhold=false;
'@ @'
      if(e.boss&&overseerTick(e,p,sees,dt)){ collide(e,G.map.walls); continue; }   // v26.xx (ai24): the Overseer phases, host only
      var _bhold=false;
'@

SubRx @'
// noise pings. v4.05: drawn AFTER the darkness now, see below; this pass
'@ @'
  // v26.xx (ai24): the Overseer sweeping laser, a wide red beam on the ground from the machine to the first wall.
  for(i=0;i<G.ents.length;i++){
    var _ob=G.ents[i];
    if(!_ob.boss||!_ob.seen||!(_ob.swpT>0)) continue;
    var _on=overseerBeam(_ob); if(!_on) continue;
    var _onx=-_on.uy*OV_HALF, _ony=_on.ux*OV_HALF;
    wc.save();
    wc.fillStyle='rgba(255,36,28,0.30)';
    wc.beginPath(); wc.moveTo(_on.x1+_onx,_on.y1+_ony); wc.lineTo(_on.x2+_onx,_on.y2+_ony); wc.lineTo(_on.x2-_onx,_on.y2-_ony); wc.lineTo(_on.x1-_onx,_on.y1-_ony); wc.closePath(); wc.fill();
    wc.globalCompositeOperation='lighter';
    wc.strokeStyle='rgba(255,190,170,0.85)'; wc.lineWidth=4;
    wc.beginPath(); wc.moveTo(_on.x1,_on.y1); wc.lineTo(_on.x2,_on.y2); wc.stroke();
    wc.restore();
  }
// noise pings. v4.05: drawn AFTER the darkness now, see below; this pass
'@

SubRx @'
              if(b.el==='acid'&&ELEM_MACH[en.kind]) edmg*=1.25;
'@ @'
              if(en.boss&&en.overheat>0) edmg*=1.5;   // v26.xx (ai24): the Overseer core is exposed while it vents
              if(b.el==='acid'&&ELEM_MACH[en.kind]) edmg*=1.25;
'@

SubRx @'
  if(e.downed&&e.getUp>0) f|=8388608;   // pillrevive: he is getting up
'@ @'
  if(e.downed&&e.getUp>0) f|=8388608;   // pillrevive: he is getting up
  if(e.swpT>0) f|=1073741824;   // v26.xx (ai24): the Overseer is sweeping, so player 2 sees the beam
'@

SubRx @'
  e.steady=!!(f&8192);
'@ @'
  e.swpT=(f&1073741824)?0.4:0;   // v26.xx (ai24)
  e.steady=!!(f&8192);
'@

SubRx @'
  if(k==='pill'){
'@ @'
  if(k==='phase'){ if(!G.sim) say(ovPhaseLine(m.n|0),'warn'); return 'mark:phase'; }   // v26.xx (ai24): the Overseer changed phase, said to the whole party
  if(k==='pill'){
'@

SubRx @'
var VER='26.69';
'@ @'
var VER='26.70';
'@

$pat = "(?m)^  now:'v26\.69:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.70: The Overseer now has three phases: it calls crawlers at two thirds health, then sweeps a laser, and its core is exposed when the laser ends. Check 26.70 fails on v26.69',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
