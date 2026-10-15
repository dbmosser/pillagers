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

# THE STRONGHOLD IS PART OF THE MAP (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v26.xx (flow11), HIS YES (2026-10-14) to suggestion 4, STRONGHOLDS: "1-2 advertised fortified compounds, with a gate, two defending waves and a purple+ cache". Once the raid
// is 3 s old it plans one, and half the time a second, stronghold on the side stream SH.tag of its seed: a ring of ground SH.r (240) across, on open reachable floor at
// least 650 from the drop, 500 from any extraction ring and 900 from the other, with a gate on the side that faces the drop where the ground is open. THEY ARE ADVERTISED:
// STRONGHOLD in the alert at the start and a mark with an arrow on the minimap and the sector map. THE FENCE: the ring is a fence of steel mesh (drawn on the HUD) that
// nobody crosses, the player, the machines and the pillagers alike (each body keeps the side it started on; bullets fly through the mesh), except through the gate once
// it is open. WAVE ONE is the garrison, three sentries and three crawlers inside. THE GATE is breached by standing within 100 of it from outside for 3 s (a ring fills
// round it); a hold that is broken drains twice as fast. The breach is loud, opens the gate for good and sends WAVE TWO at you from inside: three elite crawlers, a
// Bulwark and a sentry. The PURPLE CACHE in the middle (four items, every one purple or better, the last from the jackpot table) shows on the maps once the gate is
// open. CLEAR it (gate open and both waves dead) and the STRONGHOLD CHIP of 1,000 is paid into the run score. Made on side streams. DEMO and CAREER are the same.
var SH={tag:64,r:240,gw:0.24,n1:6,breach:3.0,chip:1000,reach:100};
function shS(){ var S=flowS(); if(!S.sh) S.sh={sites:null}; return S.sh; }
function shAt(x,y,pad){
  var SS=G&&G.flow&&G.flow.sh, i, s;
  if(!SS||!SS.sites) return null;
  for(i=0;i<SS.sites.length;i++){ s=SS.sites[i]; if(Math.hypot(x-s.x,y-s.y)<s.r+(pad||0)) return s; }
  return null;
}
function shGatePt(s){ return {x:s.x+Math.cos(s.ga)*s.r,y:s.y+Math.sin(s.ga)*s.r}; }
function shAlive(e){ return !!e&&e.hp>0&&!e.downed&&G.ents.indexOf(e)>=0; }
function shGate(x,y,from){
  var base=Math.atan2(from.y-y,from.x-x), k, a, best=null, bd=9, cx, cy, d;
  for(k=0;k<24;k++){
    a=k*0.2618; cx=Math.cos(a); cy=Math.sin(a);
    if(!(spotFree(G.map,x+cx*(SH.r-34),y+cy*(SH.r-34),12)&&spotFree(G.map,x+cx*(SH.r+34),y+cy*(SH.r+34),12))) continue;
    d=Math.abs(angDiff(a,base)); if(d<bd){ bd=d; best=a; }
  }
  return best;
}
function shLayout(){
  var p=G.player, sites=[];
  sideStream((G.seed>>>0)||1,SH.tag,function(){
    var n=1+(rr()<0.5?1:0), k, tries, x, y, ga, j, ok;
    for(k=0;k<n;k++){
      for(tries=0;tries<200;tries++){
        x=350+rr()*(WORLD_W-700); y=350+rr()*(WORLD_H-700);
        if(Math.hypot(x-p.x,y-p.y)<650) continue;
        ok=1; for(j=0;j<sites.length;j++) if(Math.hypot(x-sites[j].x,y-sites[j].y)<900) ok=0;
        if(!ok||!spotFree(G.map,x,y,50)||!navReachable(G.map,x,y)||shutRoomAt(G.map,x,y)||flowZoneNear(x,y,SH.r+260)) continue;
        ga=shGate(x,y,p); if(ga===null) continue;
        sites.push({i:sites.length,x:x,y:y,r:SH.r,ga:ga,gw:SH.gw,open:0,prog:0,w2:0,clear:0,def:[],def2:[],cache:null}); break;
      }
    }
  });
  return sites;
}
function shLoot(){
  var L=[], k, t, key;
  for(k=0;k<4;k++){
    for(t=0;t<40;t++){ key=rollLoot(k===3?LOOT.jackpot:LOOT.cache); if((_RRANK[dispR(key)]||0)>=3) break; }
    L.push(key);
  }
  return L;
}
function shPopulate(s){
  var seed=(((G.seed>>>0)^Math.imul(s.i+1,40503))>>>0)||1, list=[], L=[], c=null, i;
  sideStream(seed,SH.tag+1,function(){
    var k, t, a, r, x, y, e;
    for(k=0;k<SH.n1;k++){
      for(t=0;t<30;t++){
        a=rr()*6.2832; r=rr()*s.r*0.65; x=s.x+Math.cos(a)*r; y=s.y+Math.sin(a)*r;
        if(spotFree(G.map,x,y,26)){ e=(k<3)?mkSentry(x,y):mkCrawler(x,y); e.shS=[0,0,0]; e.shS[s.i]=1; e.shi=s.i; list.push(e); break; }
      }
    }
    L=shLoot();
  });
  for(i=0;i<list.length;i++) G.ents.push(list[i]);
  s.def=list;
  sideStream(seed,SH.tag+2,function(){ c=setLoot(mkContainer(s.x,s.y,'cache'),L); });
  c.time=4.4; c.tag='STRONGHOLD CACHE'; c.wreck=1; G.containers.push(c); s.cache=c;
}
function shReinforce(s){
  var seed=(((G.seed>>>0)^Math.imul(s.i+1,40503)^0x9e3779b1)>>>0)||1, list=[], p=G.player, i, kinds=['crawler','crawler','crawler','bulwark','sentry'];
  sideStream(seed,SH.tag+3,function(){
    var k, t, a, r, x, y, e;
    for(k=0;k<kinds.length;k++){
      for(t=0;t<30;t++){
        a=s.ga+(rr()-0.5)*1.0; r=s.r*(0.35+rr()*0.3); x=s.x+Math.cos(a)*r; y=s.y+Math.sin(a)*r;
        if(spotFree(G.map,x,y,26)){
          e=(kinds[k]==='crawler')?mkCrawler(x,y):((kinds[k]==='bulwark')?mkBulwark(x,y):mkSentry(x,y));
          if(kinds[k]==='crawler') arcadeWaveElite(e);
          e.shS=[0,0,0]; e.shS[s.i]=1; e.shi=s.i; e.state='chase'; e.alert=3; e.tx=p.x; e.ty=p.y; list.push(e); break;
        }
      }
    }
  });
  for(i=0;i<list.length;i++) G.ents.push(list[i]);
  s.def2=list; s.w2=1;
}
function shOpen(s){
  var gp=shGatePt(s);
  s.open=1; s.prog=1;
  try{ sfx('boom',gp.x,gp.y); ping(gp.x,gp.y,700,false,false,'env','fire'); spark(gp.x,gp.y,'#ffcf7a',24,300); }catch(_so){}
  try{ say('GATE BREACHED','warn',{sub:'THEY ARE COMING'}); }catch(_sg){}
  shReinforce(s);
  if(s.cache) evS().wrecks.push(s.cache);
}
// keep o on the side of the fence it is on, except through an open gate; true when it was moved
function shKeep(s,o,rad){
  var dx=o.x-s.x, dy=o.y-s.y, d=Math.sqrt(dx*dx+dy*dy), a, side, tgt, nx, ny;
  if(!o.shS) o.shS=[0,0,0];
  if(!o.shS[s.i]) o.shS[s.i]=(d<s.r)?1:2;
  if(d>s.r+400) return false;
  a=Math.atan2(dy,dx);
  if(s.open&&Math.abs(angDiff(a,s.ga))<=s.gw){ o.shS[s.i]=(d<s.r)?1:2; return false; }
  side=o.shS[s.i];
  if(side===1){ if(d<=s.r-rad-2) return false; tgt=s.r-rad-6; } else { if(d>=s.r+rad+2) return false; tgt=s.r+rad+6; }
  if(d<0.5) a=0;
  nx=s.x+Math.cos(a)*tgt; ny=s.y+Math.sin(a)*tgt;
  if(spotFree(G.map,nx,ny,Math.max(6,rad*0.6))){ o.x=nx; o.y=ny; return true; }
  return false;
}
function shTick(dt){
  var SS=shS(), i, j, k, s, e, p=G.player, gp, d, near, alive;
  if(flowPeer()){ shPeerTick(dt); return; }   // v27.12 (coop4): a linked player 2 window lays out and fills no stronghold, it keeps the host ones (shNetTake)
  if(!SS.sites){
    if((G.t||0)<3) return;
    SS.sites=shLayout();
    for(i=0;i<SS.sites.length;i++) shPopulate(SS.sites[i]);
    if(SS.sites.length){ try{ say('STRONGHOLD','info',{sub:SS.sites.length+' ON THE MAP'}); }catch(_st){} }
  }
  for(i=0;i<SS.sites.length;i++){
    s=SS.sites[i];
    if(p&&!p.specOut) shKeep(s,p,p.r||11);
    for(j=0;j<G.ents.length;j++){ e=G.ents[j]; if(!e||!(e.hp>0)||e.kind==='snitch') continue; shKeep(s,e,e.r||12); }
    if(!s.open&&p&&((!p.downed&&!p.dying)||(G.t||0)-(+s.p2at||-9)<0.6)){   // v27.12 (coop4): or a partner is at the gate
      gp=shGatePt(s); d=Math.hypot(p.x-gp.x,p.y-gp.y);
      near=((d<SH.reach)&&(p.shS&&p.shS[s.i]===2)&&!p.downed&&!p.dying)||((G.t||0)-(+s.p2at||-9)<0.6);
      s.prog=near?Math.min(1,s.prog+dt/SH.breach):Math.max(0,s.prog-dt*2/SH.breach);
      if(s.prog>=1) shOpen(s);
    }
    if(s.open&&!s.clear){
      alive=0;
      for(k=0;k<s.def.length;k++) if(shAlive(s.def[k])) alive++;
      for(k=0;k<s.def2.length;k++) if(shAlive(s.def2[k])) alive++;
      if(!alive){ s.clear=1; flowChip(SH.chip,'STRONGHOLD CLEARED','STRONGHOLD'); }
    }
  }
}
function shMarks(out){
  var SS=G.flow&&G.flow.sh, i, s;
  if(!SS||!SS.sites) return;
  for(i=0;i<SS.sites.length;i++){
    s=SS.sites[i];
    out.push({x:s.x,y:s.y,r:s.r,col:s.clear?'#7a8a80':'#ff8a3a',shape:'sq',kind:'sh',txt:'STRONGHOLD'+(s.clear?' CLEARED':''),pin:s.clear?0:1,a:s.clear?0.55:1});
  }
}
function shDraw(c){
  var SS=G.flow&&G.flow.sh, i, s, sc, q, z, R, k, a, gp, gs, t=G.t||0, U, p=G.player, dim;
  if(!SS||!SS.sites||!SS.sites.length) return;
  q=ZOOM(); z=Math.max(1,hudRes()); U=function(v){ return LH(v)*z; };
  c.save();
  for(i=0;i<SS.sites.length;i++){
    s=SS.sites[i]; sc=w2s(s.x,0,s.y); R=s.r*q; dim=s.clear?0.4:1;
    if(sc.x<-R*1.3||sc.y<-R*1.3||sc.x>W+R*1.3||sc.y>H+R*1.3) continue;
    c.lineCap='butt';
    c.strokeStyle='rgba(24,28,32,'+(0.85*dim).toFixed(3)+')'; c.lineWidth=8*z; c.beginPath(); c.arc(sc.x,sc.y,R,s.ga+s.gw,s.ga+6.2832-s.gw); c.stroke();
    c.strokeStyle='rgba(150,162,172,'+(0.9*dim).toFixed(3)+')'; c.lineWidth=3*z; c.beginPath(); c.arc(sc.x,sc.y,R,s.ga+s.gw,s.ga+6.2832-s.gw); c.stroke();
    c.fillStyle='rgba(90,100,110,'+(0.95*dim).toFixed(3)+')';
    for(k=0;k<30;k++){ a=s.ga+s.gw+0.12+k*((6.2832-2*s.gw-0.24)/29); c.fillRect(sc.x+Math.cos(a)*R-3*z,sc.y+Math.sin(a)*R-3*z,6*z,6*z); }
    c.lineWidth=7*z;
    c.strokeStyle=s.open?'rgba(95,191,106,.55)':'rgba(255,72,48,'+(0.7+0.25*Math.sin(t*5)).toFixed(3)+')';
    if(s.open) c.setLineDash([10*z,10*z]);
    c.beginPath(); c.arc(sc.x,sc.y,R,s.ga-s.gw,s.ga+s.gw); c.stroke(); c.setLineDash([]);
    gp=shGatePt(s); gs=w2s(gp.x,0,gp.y);
    if(!s.open&&s.prog>0){
      c.strokeStyle='rgba(255,192,74,.95)'; c.lineWidth=5*z; c.beginPath(); c.arc(gs.x,gs.y,U(30),-1.5708,-1.5708+6.2832*s.prog); c.stroke();
    }
    if(!s.open&&p&&Math.hypot(p.x-gp.x,p.y-gp.y)<600){
      c.textAlign='center'; c.font=hudFS(TYPE.label); c.fillStyle='#ffd0a0'; hudText(s.prog>0?'BREACHING':'STAND AT THE GATE',gs.x,gs.y-U(40));
    }
  }
  c.restore();
}

'@ @'
// v27.46 (flow11, REBUILT by sh2), HIS YES (2026-10-14) to suggestion 4, STRONGHOLDS: "1-2 advertised fortified compounds, with a gate, two defending waves and a purple+ cache". And HIS ORDER OF THE SAME NIGHT, after
// he played it: "this stand at the gate feature is a mess, the map needs to be adapted, you can't just stick a circle in the middle of existing buildings lol". THE STRONGHOLD IS NOW PART OF THE MAP. The first
// version drew a 240 wide circular fence and gate on the HUD over whatever stood there (it only asked whether the middle was free), so it cut through buildings. Now, once the raid is 3 s old, it picks a REAL BUILDING
// on the side stream SH.tag of its seed: one whose room is big enough for six defenders and a cache (SH.minArea of floor, SH.minSide across), on open reachable ground at least 650 from the drop, clear of every
// extraction ring (260 and half its length), touching no other building or locked room, with nobody peaceful in it, and 900 from the other stronghold. ITS OWN DOORWAY BECOMES THE GATE: the door nearest the drop whose outside
// is open and reachable gets a steel shutter built into the wall (a real wall: it blocks bodies, rounds and sight until it is breached), and every other doorway of the building is barricaded the same way, so the gate is the one
// way in; the building shell, windows and all, cannot be broken (noDes), so nothing walks, shoots or blasts a way round. The walls are added after the build, with no draw from the seeded stream, and the sight lines, collision
// grids and nav are rebuilt from them (rebuildGeometry, the call a destroyed wall or a keyed door makes). WAVE ONE is the garrison, three sentries and three crawlers inside, tethered to the room (camp and campR). THE GATE is
// breached by holding in front of it from outside for 3 s (a ring fills at the gate and nowhere else; a hold that is broken drains twice as fast); the label at the gate says HOLD TO BREACH. The breach blows the shutter off
// (a blast, a scar, a shake, flying metal), opens the way for good, and sends WAVE TWO at you from inside: three elite crawlers, a Bulwark and a sentry. The PURPLE CACHE inside (four items, every one purple or better, the
// last from the jackpot table) shows on the maps once the gate is open. CLEAR it (gate open and both waves dead) and the STRONGHOLD CHIP of 1,000 is paid into the run score. A window of a two player game builds the very same
// walls from the host word (shNetTake), so both players see and hit the same compound. REAL BUILDINGS ONLY (his answer): no compound is ever built in the open, and a raid with no building that fits has no stronghold. Made on side streams. DEMO and CAREER are the same.
var SH={tag:64,n1:6,breach:3.0,chip:1000,reach:100,minArea:90000,minSide:240,wid:9000};
function shS(){ var S=flowS(); if(!S.sh) S.sh={sites:null}; return S.sh; }
function shAt(x,y,pad){
  var SS=G&&G.flow&&G.flow.sh, i, s, d=pad||0;
  if(!SS||!SS.sites) return null;
  for(i=0;i<SS.sites.length;i++){ s=SS.sites[i]; if(x>s.x-d&&x<s.x+s.w+d&&y>s.y-d&&y<s.y+s.h+d) return s; }
  return null;
}
function shGatePt(s){ return {x:s.gx+s.gw/2,y:s.gy+s.gh/2}; }
function shAlive(e){ return !!e&&e.hp>0&&!e.downed&&G.ents.indexOf(e)>=0; }
function shHit(a,b,pad){ return a.x<b.x+b.w+pad&&a.x+a.w>b.x-pad&&a.y<b.y+b.h+pad&&a.y+a.h>b.y-pad; }
function shInterior(s){ return {x:s.x+16,y:s.y+16,w:s.w-32,h:s.h-32}; }
// the outer doorways of a building: the gaps makeBuilding left in its shell (the map keeps them as map.doors)
function shDoorsOf(m,b){
  var out=[], j, d;
  for(j=0;j<(m.doors||[]).length;j++){ d=m.doors[j]; if(d.x>=b.x-1&&d.y>=b.y-1&&d.x+d.w<=b.x+b.w+1&&d.y+d.h<=b.y+b.h+1) out.push(d); }
  return out;
}
// the buildings that can be a stronghold, with the doorway that would be its gate (no draw)
function shCands(sites){
  var m=G.map, p=G.player, B=m.buildings||[], out=[], i, j, k, b, iw, ih, cx, cy, D, bad, e, best, bd, dc, nx, ny, ox, oy, ix, iy, gp, d, o;
  for(i=0;i<B.length;i++){
    b=B[i]; iw=b.w-32; ih=b.h-32;
    if(iw*ih<SH.minArea||Math.min(iw,ih)<SH.minSide) continue;
    cx=b.x+b.w/2; cy=b.y+b.h/2;
    if(Math.hypot(cx-p.x,cy-p.y)<650||flowZoneNear(cx,cy,260+Math.max(b.w,b.h)/2)) continue;
    D=shDoorsOf(m,b); if(!D.length) continue;
    bad=0;
    for(k=0;k<B.length&&!bad;k++) if(k!==i&&shHit(b,B[k],4)) bad=1;
    for(k=0;k<(m.locked||[]).length&&!bad;k++) if(shHit(b,m.locked[k],0)) bad=1;
    for(k=0;k<G.ents.length&&!bad;k++){ e=G.ents[k]; if(e&&(e.neutral||e.kind==='peddler'||e.kind==='stray')&&e.x>b.x&&e.x<b.x+b.w&&e.y>b.y&&e.y<b.y+b.h) bad=1; }
    for(k=0;k<sites.length&&!bad;k++) if(Math.hypot(cx-(sites[k].x+sites[k].w/2),cy-(sites[k].y+sites[k].h/2))<900) bad=1;
    if(bad) continue;
    best=null; bd=1e9;
    for(j=0;j<D.length;j++){
      d=D[j]; gp={x:d.x+d.w/2,y:d.y+d.h/2};
      if(d.w>=d.h){ nx=0; ny=(gp.y<cy)?-1:1; } else { nx=(gp.x<cx)?-1:1; ny=0; }
      ox=gp.x+nx*48; oy=gp.y+ny*48; ix=gp.x-nx*48; iy=gp.y-ny*48;
      if(!spotFree(m,ox,oy,18)||!navReachable(m,ox,oy)||!navReachable(m,ix,iy)) continue;
      dc=Math.hypot(gp.x-p.x,gp.y-p.y);
      if(dc<bd){ bd=dc; best={d:d,nx:nx,ny:ny}; }
    }
    if(best) out.push({bi:i,b:b,gate:best});
  }
  return out;
}
function shMakeB(i,c){
  var b=c.b, d=c.gate.d;
  return {i:i,kind:'b',bi:c.bi,x:b.x,y:b.y,w:b.w,h:b.h,gx:d.x,gy:d.y,gw:d.w,gh:d.h,nx:c.gate.nx,ny:c.gate.ny,open:0,prog:0,w2:0,clear:0,def:[],def2:[],cache:null,walls:[],gateWall:null};
}
function shLayout(){
  var sites=[];
  sideStream((G.seed>>>0)||1,SH.tag,function(){
    var n=1+(rr()<0.5?1:0), k, C, s;
    for(k=0;k<n;k++){
      C=shCands(sites); s=null;
      if(C.length) s=shMakeB(sites.length,C[Math.floor(rr()*C.length)]);   // real buildings only: a raid with no building that fits has no stronghold
      if(s) sites.push(s);
    }
  });
  return sites;
}
function shLoot(){
  var L=[], k, t, key;
  for(k=0;k<4;k++){
    for(t=0;t<40;t++){ key=rollLoot(k===3?LOOT.jackpot:LOOT.cache); if((_RRANK[dispR(key)]||0)>=3) break; }
    L.push(key);
  }
  return L;
}
// a wall of the compound: a real wall of the map, so it blocks, it draws, it stops rounds and sight; never broken. Added once (a second call with the same rectangle gives the first back).
function shWall(s,x,y,w,h,kind,d){
  var S=shS(), m=G.map, i, wl;
  for(i=0;i<m.walls.length;i++){ wl=m.walls[i]; if(wl.sh!==undefined&&wl[kind]&&wl.x===x&&wl.y===y&&wl.w===w&&wl.h===h){ if(s.walls.indexOf(wl)<0) s.walls.push(wl); return wl; } }
  S.wn=(S.wn|0)+1;
  wl={x:x,y:y,w:w,h:h,d:d,noDes:1,sh:s.i,wid:SH.wid+(S.wn|0)}; wl[kind]=1;
  m.walls.push(wl); s.walls.push(wl);
  return wl;
}
// the compound's walls: the shell sealed, the gate shutter and the barricades (no rebuild here, the caller rebuilds once)
function shBuild(s){
  var m=G.map, b, D, j, d, k, w2;
  if(s.built) return s.walls.length;
  s.built=1;
  if(s.kind==='b'){
    b=m.buildings[s.bi]; if(!b) return 0;
    for(k=0;k<m.walls.length;k++){
      w2=m.walls[k];
      if(w2.sh!==undefined||w2.ib!==undefined||w2.tree||w2.furn||w2.wreck||w2.ruin||w2.door||w2.lockWall||w2.ledge) continue;
      if(w2.x>=b.x-1&&w2.y>=b.y-1&&w2.x+w2.w<=b.x+b.w+1&&w2.y+w2.h<=b.y+b.h+1&&(w2.x<b.x+18||w2.y<b.y+18||w2.x+w2.w>b.x+b.w-18||w2.y+w2.h>b.y+b.h-18)) w2.noDes=1;
    }
    D=shDoorsOf(m,b);
    for(j=0;j<D.length;j++){
      d=D[j];
      if(Math.abs(d.x-s.gx)<1&&Math.abs(d.y-s.gy)<1&&Math.abs(d.w-s.gw)<1&&Math.abs(d.h-s.gh)<1){ s.gx=d.x; s.gy=d.y; s.gw=d.w; s.gh=d.h; s.gateWall=shWall(s,d.x,d.y,d.w,d.h,'sgate',b.d); }
      else shWall(s,d.x,d.y,d.w,d.h,'sblk',b.d);
    }
  }
  return s.walls.length;
}
// bodies that stand where a new wall went are put outside it, along the way out of the compound
function shClear(s){
  var i, j, wl, o, L=[G.player], cx=s.x+s.w/2, cy=s.y+s.h/2, r, dx, dy;
  for(i=0;i<G.ents.length;i++) L.push(G.ents[i]);
  for(j=0;j<s.walls.length;j++){
    wl=s.walls[j];
    for(i=0;i<L.length;i++){
      o=L[i]; if(!o||!isFinite(o.x)||!isFinite(o.y)) continue;
      r=(o.r||12)+2;
      if(o.x>wl.x-r&&o.x<wl.x+wl.w+r&&o.y>wl.y-r&&o.y<wl.y+wl.h+r){
        dx=(wl.x+wl.w/2)-cx; dy=(wl.y+wl.h/2)-cy;
        if(Math.abs(dx)*s.h>Math.abs(dy)*s.w) o.x=(dx>0)?wl.x+wl.w+r+4:wl.x-r-4; else o.y=(dy>0)?wl.y+wl.h+r+4:wl.y-r-4;
      }
    }
  }
}
// the shutter comes out of the wall (the way in is open for good); the sight lines, collision and nav are rebuilt
function shUnseal(s){
  var ix=s.gateWall?G.map.walls.indexOf(s.gateWall):-1;
  if(ix>=0){ G.map.walls.splice(ix,1); rebuildGeometry(); }
  s.gateWall=null;
}
// the blast that takes the shutter: sound, flash, sparks and flying metal, a scar on the ground, a shake
function shBreachFx(s){
  var gp=shGatePt(s), p=G.player;
  try{ sfx('boom',gp.x,gp.y); }catch(_a){}
  try{ spark(gp.x,gp.y,'#ffcf7a',26,320); spark(gp.x,gp.y,'#9aa3ac',16,260); flash(gp.x,gp.y,300,'#ffb267',.5); }catch(_b){}
  try{ boomFx(gp.x,gp.y,1.3,'frag'); }catch(_c){}
  try{ gfxBlastScar(gp.x,gp.y,1.1,false); }catch(_d){}
  if(p) G.shake=Math.max(G.shake||0,Math.max(3,8-dist(p,gp)/130));
}
function shSpot(s,I,pad,away){
  var t, x, y, gp=shGatePt(s);
  for(t=0;t<40;t++){
    x=I.x+rr()*I.w; y=I.y+rr()*I.h;
    if(spotFree(G.map,x,y,pad)&&Math.hypot(x-gp.x,y-gp.y)>=away) return {x:x,y:y};
  }
  return null;
}
function shPopulate(s){
  var seed=(((G.seed>>>0)^Math.imul(s.i+1,40503))>>>0)||1, list=[], L=[], c=null, i, I=shInterior(s), ccx=I.x+I.w/2, ccy=I.y+I.h/2, R=Math.max(70,Math.min(I.w,I.h)*0.42);
  sideStream(seed,SH.tag+1,function(){
    var k, sp, e;
    for(k=0;k<SH.n1;k++){
      sp=shSpot(s,I,26,110); if(!sp) continue;
      e=(k<3)?mkSentry(sp.x,sp.y):mkCrawler(sp.x,sp.y); e.camp={x:ccx,y:ccy}; e.campR=R; e.shi=s.i; list.push(e);
    }
    L=shLoot();
  });
  for(i=0;i<list.length;i++) G.ents.push(list[i]);
  s.def=list;
  sideStream(seed,SH.tag+2,function(){ var q=shSpot(s,I,34,140)||shSpot(s,I,28,60)||{x:ccx,y:ccy}; c=setLoot(mkContainer(q.x,q.y,'cache'),L); });
  c.time=4.4; c.tag='STRONGHOLD CACHE'; c.wreck=1; G.containers.push(c); s.cache=c;
}
function shReinforce(s){
  var seed=(((G.seed>>>0)^Math.imul(s.i+1,40503)^0x9e3779b1)>>>0)||1, list=[], p=G.player, i, kinds=['crawler','crawler','crawler','bulwark','sentry'], I=shInterior(s), gp=shGatePt(s);
  sideStream(seed,SH.tag+3,function(){
    var k, t, x, y, e, dd, lt;
    for(k=0;k<kinds.length;k++){
      for(t=0;t<30;t++){
        dd=70+rr()*130; lt=(rr()-0.5)*160;
        x=gp.x-s.nx*dd-s.ny*lt; y=gp.y-s.ny*dd+s.nx*lt;
        if(x>I.x&&x<I.x+I.w&&y>I.y&&y<I.y+I.h&&spotFree(G.map,x,y,26)){
          e=(kinds[k]==='crawler')?mkCrawler(x,y):((kinds[k]==='bulwark')?mkBulwark(x,y):mkSentry(x,y));
          if(kinds[k]==='crawler') arcadeWaveElite(e);
          e.shi=s.i; e.state='chase'; e.alert=3; e.tx=p.x; e.ty=p.y; list.push(e); break;
        }
      }
    }
  });
  for(i=0;i<list.length;i++) G.ents.push(list[i]);
  s.def2=list; s.w2=1;
}
function shOpen(s){
  var gp=shGatePt(s);
  s.open=1; s.prog=1;
  shBreachFx(s);
  try{ ping(gp.x,gp.y,700,false,false,'env','fire'); }catch(_so){}
  shUnseal(s);
  try{ say('GATE BREACHED','warn',{sub:'THEY ARE COMING'}); }catch(_sg){}
  shReinforce(s);
  if(s.cache) evS().wrecks.push(s.cache);
}
// is this body at the gate, outside it, close enough to be breaching it
function shNear(s,p){
  var gp=shGatePt(s), dx=p.x-gp.x, dy=p.y-gp.y;
  return Math.hypot(dx,dy)<SH.reach&&(dx*s.nx+dy*s.ny)>-10;
}
function shTick(dt){
  var SS=shS(), i, k, s, p=G.player, near, alive, p2;
  if(flowPeer()){ shPeerTick(dt); return; }   // v27.46 (coop4): a linked player 2 window lays out and fills no stronghold, it keeps the host ones (shNetTake)
  if(!SS.sites){
    if((G.t||0)<3) return;
    SS.sites=shLayout();
    for(i=0;i<SS.sites.length;i++) shBuild(SS.sites[i]);
    if(SS.sites.length){
      rebuildGeometry();
      for(i=0;i<SS.sites.length;i++){ shClear(SS.sites[i]); shPopulate(SS.sites[i]); }
      try{ say('STRONGHOLD','info',{sub:SS.sites.length+' ON THE MAP'}); }catch(_st){}
    }
  }
  for(i=0;i<SS.sites.length;i++){
    s=SS.sites[i];
    p2=((G.t||0)-(+s.p2at||-9)<0.6);   // v27.46 (coop4): or a partner is at the gate
    if(!s.open&&p&&((!p.downed&&!p.dying)||p2)){
      near=(!p.downed&&!p.dying&&shNear(s,p))||p2;
      s.prog=near?Math.min(1,s.prog+dt/SH.breach):Math.max(0,s.prog-dt*2/SH.breach);
      if(s.prog>=1) shOpen(s);
    }
    if(s.open&&!s.clear){
      alive=0;
      for(k=0;k<s.def.length;k++) if(shAlive(s.def[k])) alive++;
      for(k=0;k<s.def2.length;k++) if(shAlive(s.def2[k])) alive++;
      if(!alive){ s.clear=1; flowChip(SH.chip,'STRONGHOLD CLEARED','STRONGHOLD'); }
    }
  }
}
function shMarks(out){
  var SS=G.flow&&G.flow.sh, i, s;
  if(!SS||!SS.sites) return;
  for(i=0;i<SS.sites.length;i++){
    s=SS.sites[i];
    out.push({x:s.x+s.w/2,y:s.y+s.h/2,r:0,col:s.clear?'#7a8a80':'#ff8a3a',shape:'sq',kind:'sh',txt:'STRONGHOLD'+(s.clear?' CLEARED':''),pin:s.clear?0:1,a:s.clear?0.55:1});
  }
}
// the world label and the fill ring, at the gate only (the compound itself is walls of the map)
function shDraw(c){
  var SS=G.flow&&G.flow.sh, i, s, gp, gs, ls, z, U, p=G.player, txt, d, gl;
  if(!SS||!SS.sites||!SS.sites.length) return;
  z=Math.max(1,hudRes()); U=function(v){ return LH(v)*z; };
  c.save();
  for(i=0;i<SS.sites.length;i++){
    s=SS.sites[i]; if(s.open) continue;
    gp=shGatePt(s); gs=w2s(gp.x,0,gp.y);
    if(gs.x<-300||gs.y<-300||gs.x>W+300||gs.y>H+300) continue;
    if(!s.open){
      c.save(); c.globalCompositeOperation='lighter';
      gl=c.createRadialGradient(gs.x,gs.y,0,gs.x,gs.y,Math.max(40,95*ZOOM()));
      gl.addColorStop(0,'rgba(255,70,45,'+(0.16+0.10*Math.sin((G.t||0)*5)).toFixed(3)+')'); gl.addColorStop(1,'rgba(255,60,40,0)');
      c.fillStyle=gl; c.beginPath(); c.arc(gs.x,gs.y,Math.max(40,95*ZOOM()),0,6.2832); c.fill(); c.restore();
    }
    if(s.prog>0){
      c.strokeStyle='rgba(0,0,0,.45)'; c.lineWidth=7*z; c.beginPath(); c.arc(gs.x,gs.y,U(30),0,6.2832); c.stroke();
      c.strokeStyle='rgba(255,192,74,.95)'; c.lineWidth=5*z; c.beginPath(); c.arc(gs.x,gs.y,U(30),-1.5708,-1.5708+6.2832*s.prog); c.stroke();
    }
    d=p?Math.hypot(p.x-gp.x,p.y-gp.y):1e9;
    if(d<600){
      ls=w2s(gp.x+s.nx*70,0,gp.y+s.ny*70);
      txt=(s.prog>0)?('BREACHING  '+Math.round(s.prog*100)+'%'):'HOLD TO BREACH';
      c.textAlign='center'; c.font=hudFS(TYPE.label); c.fillStyle='rgba(6,9,13,.72)';
      c.fillRect(ls.x-c.measureText(txt).width/2-U(8),ls.y-U(18),c.measureText(txt).width+U(16),U(22));
      c.fillStyle=(s.prog>0)?'#ffc04a':'#ffd0a0'; hudText(txt,ls.x,ls.y-U(2));
    }
  }
  c.restore();
}
// the walls of a compound, painted in the wall pass: the shutter, a barricade, a stretch of fence. LIFT is the wall lift; the faces are what the other walls have, a roof strip and a front.
function shWallDraw(c,w,LIFT){
  var x=w.x, y=w.y, ww=w.w, hh=w.h, fy=y+hh-LIFT, ty=y-LIFT, t=G.t||0, k, horiz=(ww>=hh), n, a;
  if(w.sgate){
    a=0.55+0.4*Math.sin(t*5);
    c.fillStyle='#101215'; c.fillRect(x-1,ty-1,ww+2,hh+LIFT+2);
    c.fillStyle='#4a525b'; c.fillRect(x,fy,ww,LIFT);
    c.fillStyle='#626d79'; c.fillRect(x,ty,ww,hh);
    c.fillStyle='rgba(0,0,0,.30)';
    if(horiz){ for(k=x+5;k<x+ww-2;k+=7) c.fillRect(k,fy+7,1.3,LIFT-18); }
    else { for(k=fy+8;k<fy+LIFT-8;k+=6) c.fillRect(x+2,k,ww-4,1.3); }
    // hazard band along the foot of the slab, wide stripes
    n=horiz?Math.floor(ww/10):Math.floor(LIFT/10);
    for(k=0;k<n;k++){
      c.fillStyle=(k&1)?'#f0c020':'#15171a';
      if(horiz) c.fillRect(x+2+k*10,fy+LIFT-10,10,8); else c.fillRect(x+2,fy+2+k*10,ww-4,8);
    }
    // the lamp bar across the head of the slab: red while the gate holds, pulsing
    c.fillStyle='#0c0d0f'; c.fillRect(x+2,fy+1,ww-4,6);
    c.fillStyle='rgba(255,64,40,'+a.toFixed(3)+')'; c.fillRect(x+3,fy+2,ww-6,4);
    c.fillStyle='rgba(255,230,200,.20)'; c.fillRect(x,ty,ww,1.2);
    return;
  }
  if(w.sblk){
    c.fillStyle='#16130f'; c.fillRect(x-1,ty-1,ww+2,hh+LIFT+2);
    c.fillStyle='#3a2f22'; c.fillRect(x,fy,ww,LIFT);
    c.fillStyle='#4a3c2a'; c.fillRect(x,ty,ww,hh);
    c.strokeStyle='#7a6244'; c.lineWidth=3.2;
    c.beginPath();
    if(horiz){ c.moveTo(x+3,fy+3); c.lineTo(x+ww-3,fy+LIFT-3); c.moveTo(x+ww-3,fy+3); c.lineTo(x+3,fy+LIFT-3); }
    else { c.moveTo(x+2,fy+3); c.lineTo(x+ww-2,fy+LIFT-3); c.moveTo(x+ww-2,fy+3); c.lineTo(x+2,fy+LIFT-3); }
    c.stroke();
    c.fillStyle='#b9a37c';
    c.fillRect(x+ww/2-1,fy+LIFT/2-1,2.4,2.4); c.fillRect(x+3,fy+3,2,2); c.fillRect(x+ww-5,fy+LIFT-5,2,2);
    c.fillStyle='rgba(232,214,186,.14)'; c.fillRect(x,ty,ww,1.2);
    return;
  }
}

'@

SubRx @'
function shNetOut(){
  var SS=G.flow&&G.flow.sh, a=[], i, s;
  if(!SS||!SS.sites) return a;
  for(i=0;i<SS.sites.length&&i<3;i++){ s=SS.sites[i]; a.push([s.i|0,Math.round(s.x),Math.round(s.y),+(+s.ga).toFixed(3),s.open?1:0,+(+s.prog).toFixed(2),s.clear?1:0]); }
  return a;
}
function shNetTake(rows){
  var SS=shS(), i, j, r, s, wasOpen, wasClear;
  if(!SS.sites) SS.sites=[];
  for(i=0;i<rows.length&&i<3;i++){
    r=rows[i];
    if(!r||typeof r.length!=='number'||r.length<7||!isFinite(+r[1])||!isFinite(+r[2])||!isFinite(+r[3])) continue;
    s=null; for(j=0;j<SS.sites.length;j++) if(SS.sites[j].i===(r[0]|0)){ s=SS.sites[j]; break; }
    if(!s){ s={i:r[0]|0,x:0,y:0,r:SH.r,ga:0,gw:SH.gw,open:0,prog:0,w2:0,clear:0,def:[],def2:[],cache:null}; SS.sites.push(s); }
    wasOpen=s.open; wasClear=s.clear;
    s.x=+r[1]; s.y=+r[2]; s.ga=+r[3]; s.open=r[4]?1:0; s.clear=r[6]?1:0;
    s.prog=s.open?1:Math.max(+r[5]||0,(wasOpen?0:s.prog));
    if(s.open&&!wasOpen&&s.fresh){ try{ var gp=shGatePt(s); sfx('boom',gp.x,gp.y); spark(gp.x,gp.y,'#ffcf7a',24,300); say('GATE BREACHED','warn',{sub:'THEY ARE COMING'}); }catch(_so){} }
    if(s.clear&&!wasClear&&s.fresh){ try{ say('STRONGHOLD CLEARED','ext',{sub:'STRONGHOLD'}); }catch(_sc){} }
    s.fresh=1;
  }
  if(SS.sites.length&&!SS.told){ SS.told=1; try{ say('STRONGHOLD','info',{sub:SS.sites.length+' ON THE MAP'}); }catch(_st){} }
  return SS.sites.length;
}
function shPeerTick(dt){
  var SS=shS(), i, s, p=G.player, gp, d, near, t=G.t||0;
  if(!SS.sites||!p) return;
  for(i=0;i<SS.sites.length;i++){
    s=SS.sites[i];
    if(!p.specOut) shKeep(s,p,p.r||11);
    if(s.open||p.downed||p.dying){ continue; }
    gp=shGatePt(s); d=Math.hypot(p.x-gp.x,p.y-gp.y);
    near=(d<SH.reach)&&(p.shS&&p.shS[s.i]===2);
    s.prog=near?Math.min(0.999,s.prog+dt/SH.breach):Math.max(0,s.prog-dt*2/SH.breach);   // looks only: the host counts the real breach
    if(near&&(t-(+s.gateAt||-9)>=0.25||t<(+s.gateAt||0))){ s.gateAt=t; flowNetPost({k:'gate',i:s.i}); }
  }
}

'@ @'
function shNetOut(){
  var SS=G.flow&&G.flow.sh, a=[], i, s;
  if(!SS||!SS.sites) return a;
  for(i=0;i<SS.sites.length&&i<3;i++){ s=SS.sites[i]; a.push([s.i|0,0,s.bi|0,Math.round(s.x),Math.round(s.y),Math.round(s.w),Math.round(s.h),Math.round(s.gx),Math.round(s.gy),Math.round(s.gw),Math.round(s.gh),s.nx|0,s.ny|0,s.open?1:0,+(+s.prog).toFixed(2),s.clear?1:0]); }
  return a;
}
// v27.46 (sh2): a linked window builds the very same walls from the word (the building and the doorway are told, the map is the same), once, and breaks the gate when the host says it is open
function shNetTake(rows){
  var SS=shS(), i, j, r, s, wasOpen, wasClear, fresh, built=0;
  if(!SS.sites) SS.sites=[];
  for(i=0;i<rows.length&&i<3;i++){
    r=rows[i];
    if(!r||typeof r.length!=='number'||r.length<16) continue;
    for(j=3;j<11;j++) if(!isFinite(+r[j])) { r=null; break; }
    if(!r) continue;
    s=null; for(j=0;j<SS.sites.length;j++) if(SS.sites[j].i===(r[0]|0)){ s=SS.sites[j]; break; }
    fresh=!s;
    if(!s){
      s={i:r[0]|0,kind:'b',bi:r[2]|0,x:+r[3],y:+r[4],w:+r[5],h:+r[6],gx:+r[7],gy:+r[8],gw:+r[9],gh:+r[10],nx:r[11]|0,ny:r[12]|0,open:0,prog:0,w2:0,clear:0,def:[],def2:[],cache:null,walls:[],gateWall:null};
      SS.sites.push(s);
      if(shBuild(s)){ built=1; shClear(s); }
    }
    wasOpen=s.open; wasClear=s.clear;
    s.open=r[13]?1:0; s.clear=r[15]?1:0;
    s.prog=s.open?1:Math.max(+r[14]||0,(wasOpen?0:s.prog));
    if(s.open&&!wasOpen){
      if(!fresh){ try{ shBreachFx(s); say('GATE BREACHED','warn',{sub:'THEY ARE COMING'}); }catch(_so){} }
      shUnseal(s); built=0;
    }
    if(s.clear&&!wasClear&&!fresh){ try{ say('STRONGHOLD CLEARED','ext',{sub:'STRONGHOLD'}); }catch(_sc){} }
  }
  if(built) rebuildGeometry();
  if(SS.sites.length&&!SS.told){ SS.told=1; try{ say('STRONGHOLD','info',{sub:SS.sites.length+' ON THE MAP'}); }catch(_st){} }
  return SS.sites.length;
}
function shPeerTick(dt){
  var SS=shS(), i, s, p=G.player, near, t=G.t||0;
  if(!SS.sites||!p) return;
  for(i=0;i<SS.sites.length;i++){
    s=SS.sites[i];
    if(s.open||p.downed||p.dying) continue;
    near=shNear(s,p);
    s.prog=near?Math.min(0.999,s.prog+dt/SH.breach):Math.max(0,s.prog-dt*2/SH.breach);   // looks only: the host counts the real breach
    if(near&&(t-(+s.gateAt||-9)>=0.25||t<(+s.gateAt||0))){ s.gateAt=t; flowNetPost({k:'gate',i:s.i}); }
  }
}

'@

SubRx @'
      if(wl2.door){
        var _dk=false,_dq;
'@ @'
      if(wl2.sh!==undefined){ try{ shWallDraw(wc,wl2,LIFT); }catch(_swd){} continue; }   // v27.46 (sh2): the shutter, a barricade or a stretch of fence of a stronghold
      if(wl2.door){
        var _dk=false,_dq;
'@

SubRx @'
        if(e.camp){ var ga2=rnd(0,6.2832),gr2=rnd(40,240); e.tx=e.camp.x+Math.cos(ga2)*gr2; e.ty=e.camp.y+Math.sin(ga2)*gr2; }
'@ @'
        if(e.camp){ var ga2=rnd(0,6.2832),gr2=rnd(Math.min(40,(e.campR||240)*0.3),e.campR||240); e.tx=e.camp.x+Math.cos(ga2)*gr2; e.ty=e.camp.y+Math.sin(ga2)*gr2; }   // v27.46 (sh2): a camp may be a room, not a field (campR)
'@

SubRx @'
var VER='27.45';
'@ @'
var VER='27.46';
'@

$pat = "(?m)^  now:'v27\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.46: Strongholds are now real buildings with a shutter gate you hold in front of to breach, not a circle on the map. Check 27.46 fails on v27.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
