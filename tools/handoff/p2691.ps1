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

# STRONGHOLDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@ @'
  shTick(dt);
  // FLOW-TICKS (the next flow builds add their ticks above this line)
'@

SubRx @'
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@ @'
  shDraw(c);
  // FLOW-DRAWS (the next flow builds add their draws above this line)
'@

SubRx @'
  // FLOW-MARKS (the next flow builds add their marks above this line)
'@ @'
  shMarks(out);
  // FLOW-MARKS (the next flow builds add their marks above this line)
'@

SubRx @'
  if(fireAt(x,y,60)) return false;   // v26.xx (flow4): and never in a fire
'@ @'
  if(fireAt(x,y,60)) return false;   // v26.xx (flow4): and never in a fire
  if(shAt(x,y,40)) return false;   // v26.xx (flow11): nor inside a stronghold
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
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
    if(!s.open&&p&&!p.downed&&!p.dying){
      gp=shGatePt(s); d=Math.hypot(p.x-gp.x,p.y-gp.y);
      near=(d<SH.reach)&&(p.shS&&p.shS[s.i]===2);
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
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='26.90';
'@ @'
var VER='26.91';
'@

$pat = "(?m)^  now:'v26\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.91: Each raid has one or two fenced strongholds on the map: breach the gate, beat two waves, take the purple cache. Check 26.91 fails on v26.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
