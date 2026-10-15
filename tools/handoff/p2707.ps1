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

# PLAYER 2 SEES AND FEELS THE RAID EVENTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var S=G&&G.flow, F, i, f, a=[];
'@ @'
  var S=G&&G.flow, F, i, f, a=[], o;
'@

SubRx @'
  return {f:a};
'@ @'
  o={f:a};
  o.e=evNetOut();   // v27.07 (coop2): and the raid events
  // FLOW-NET-OUT (the next coop builds add their keys above this line)
  return o;
'@

SubRx @'
  if(fl.f&&typeof fl.f.length==='number') fireNetTake(fl.f);
'@ @'
  if(fl.f&&typeof fl.f.length==='number') fireNetTake(fl.f);
  if(fl.e&&typeof fl.e.length==='number') evNetTake(fl.e);   // v27.07 (coop2): the raid events
  // FLOW-NET-IN (the next coop builds take their keys above this line)
'@

SubRx @'
function evTick(dt){
  var E=evS(), i, ev, def, pl, t=G.t||0, busy=0;
'@ @'
function evTick(dt){
  var E=evS(), i, ev, def, pl, t=G.t||0, busy=0;
  if(flowPeer()){ evPeerTick(dt); return; }   // v27.07 (coop2): a linked player 2 window plans and launches no event, it keeps the host events (evNetTake)
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v27.07 (coop2), HIS ORDER (2026-10-14), the two player first: THE RAID EVENTS COME TO PLAYER 2. The six events (orbital debris, machine convoy, bounty pillager, coolant
// rupture, lockdown alarm, Overseer rampage) were planned and run by every window for itself, so player 2 had events of his own on other dice, or none, and none
// of the host ones: no ring, no countdown, no debris, no fog. The host now lists its live events in the same world word as the fires (key e: per event its kind, number,
// phase, place, size and clocks, and what the kind needs: the five debris points and which have landed, the carrier and crew of a convoy, the hunter, the Overseer and the
// sweep it is on, the machines gone berserk, the crates the rupture made richer; a body is told by its body number, which the linked window already has). The linked
// window plans and launches none (evTick), rebuilds each event from the word, runs its clocks between words and says what the host says: the warning when it comes, and the
// start of a live event. Everything the old draw and mark code read is in the rebuilt event, so the ring, the count, the pieces about to land, the fog and the marks on both
// maps come from the code that was there. Player 2 FEELS a piece of debris that lands on him: the blast, the shake and the damage are his own window's. The machines of an event
// are the host's bodies and come over in the body words; the crate an event leaves comes over in the box words and is marked on the maps by its name.
var EV_WRECK_TAGS={'DEBRIS WRECK':1,'CONVOY CRATE':1,'LOCKDOWN CACHE':1,'STRONGHOLD CACHE':1,'GOLDEN HOARD':1};
function evEnt(nid){ return (nid>0&&NET.entMap&&NET.entMap[nid])||null; }
function evNetX(ev){
  var d=ev.d, a, i, c;
  if(ev.id==='debris'){ a=[]; for(i=0;d.pts&&i<d.pts.length&&i<8;i++) a.push([Math.round(d.pts[i].x),Math.round(d.pts[i].y),+(+d.pts[i].at).toFixed(2),d.pts[i].done?1:0]); return a; }
  if(ev.id==='convoy'){ a=[(d.car&&d.car.nid)|0,[],d.over?1:0]; for(i=0;d.crew&&i<d.crew.length&&i<8;i++) if(d.crew[i]&&d.crew[i].nid) a[1].push(d.crew[i].nid); return a; }
  if(ev.id==='bounty') return [(d.e&&d.e.nid)|0,d.over?1:0];
  if(ev.id==='rampage') return [(d.b&&d.b.nid)|0,d.wi|0,(d.wps&&d.wps.length)|0,d.over?1:0];
  if(ev.id==='lock'){ a=[]; for(i=0;d.in&&i<d.in.length&&i<16;i++) if(d.in[i]&&d.in[i].nid&&d.in[i].berserk&&d.in[i].hp>0) a.push(d.in[i].nid); return [a]; }
  if(ev.id==='cool'){ a=[]; for(i=0;i<G.containers.length&&a.length<24;i++){ c=G.containers[i]; if(c&&c.rich&&!c.opened&&c.cid>=0) a.push(c.cid); } return [a]; }
  return 0;
}
function evNetOut(){
  var E=G.flow&&G.flow.ev, a=[], i, ev, def, x, y;
  if(!E) return a;
  for(i=0;i<E.live.length&&i<3;i++){
    ev=E.live[i]; def=EVENTS[ev.id]; if(!def) continue;
    x=def.mx?def.mx(ev):ev.x; y=def.my?def.my(ev):ev.y;
    a.push([EV_IDS.indexOf(ev.id),ev.n|0,(ev.ph==='warn')?0:((ev.ph==='live')?1:2),Math.round(x),Math.round(y),Math.round(ev.r),+(+ev.t).toFixed(1),+(+ev.lt).toFixed(1),+(+ev.et).toFixed(1),+(+ev.warn).toFixed(1),+(+ev.dur).toFixed(1),+(+ev.fade).toFixed(1),evNetX(ev)]);
  }
  return a;
}
function evNetTakeX(ev,X){
  var d=ev.d, i, a, c, keep={};
  if(!X) return;
  if(ev.id==='debris'&&typeof X.length==='number'){
    if(!d.pts) d.pts=[];
    for(i=0;i<X.length&&i<8;i++){
      a=X[i]; if(!a||a.length<4||!isFinite(+a[0])||!isFinite(+a[1])||!isFinite(+a[2])) continue;
      if(!d.pts[i]) d.pts[i]={x:0,y:0,at:0,done:0,i:i,fx:0};
      d.pts[i].x=+a[0]; d.pts[i].y=+a[1]; d.pts[i].at=+a[2]; if(a[3]) d.pts[i].done=1;
    }
  } else if(ev.id==='convoy'){
    d.car=evEnt(X[0]|0); d.crew=[]; for(i=0;X[1]&&i<X[1].length&&i<8;i++){ c=evEnt(X[1][i]|0); if(c) d.crew.push(c); } d.over=X[2]?1:0;
  } else if(ev.id==='bounty'){ d.e=evEnt(X[0]|0); d.over=X[1]?1:0; }
  else if(ev.id==='rampage'){ d.b=evEnt(X[0]|0); d.wi=X[1]|0; d.wps=new Array(Math.max(0,Math.min(9,X[2]|0))); d.over=X[3]?1:0; }
  else if(ev.id==='lock'){
    for(i=0;X[0]&&i<X[0].length&&i<16;i++){ c=evEnt(X[0][i]|0); if(c) keep[c.nid]=c; }
    for(i=0;d.in&&i<d.in.length;i++) if(d.in[i]&&!keep[d.in[i].nid]) d.in[i].berserk=0;
    d.in=[]; for(i in keep){ keep[i].berserk=1; d.in.push(keep[i]); }
  } else if(ev.id==='cool'){
    d.rich=(X[0]&&X[0].length)|0;
    for(i=0;X[0]&&i<X[0].length&&i<24;i++){ c=(typeof netContOf==='function')?netContOf(X[0][i]|0):null; if(c) c.rich=1; }
  }
}
// what a linked window says when a live event starts: the host said it in its own start code
function evPeerStart(ev){
  var p=G.player, id=ev.id;
  if(id==='lock') ev.d.pSide=(p&&Math.hypot(p.x-ev.x,p.y-ev.y)<ev.r)?1:2;
  try{
    if(id==='debris') say('DEBRIS INBOUND','crit');
    else if(id==='convoy') say('CONVOY MOVING','warn',{sub:'KILL THE CARRIER'});
    else if(id==='bounty') say('BOUNTY ON THE MAP','warn',{sub:'HE HUNTS '+String(((typeof netSeatName==='function')?netSeatName(0):'')||'THE HOST').toUpperCase()+'  $'+BOUNTY.pay});
    else if(id==='cool') say('COOLANT RUPTURE','crit',{sub:'RICHER CRATES  '+(ev.d.rich|0)});
    else if(id==='lock') say(ev.d.pSide===1?'SEALED IN':'DISTRICT SEALED','crit',{sub:'MACHINES BERSERK  '+LOCK.seal+'S'});
    else if(id==='rampage') say('OVERSEER RAMPAGE','crit',{sub:'IT HAS LEFT THE LAIR'});
  }catch(_eps){}
}
function evNetTake(rows){
  var E=evS(), L=E.live, i, j, r, ev, def, id, ph, seen={}, was;
  for(i=0;i<rows.length&&i<3;i++){
    r=rows[i];
    if(!r||typeof r.length!=='number'||r.length<13) continue;
    id=EV_IDS[r[0]|0]; def=id?EVENTS[id]:null; if(!def) continue;
    ph=(r[2]===1)?'live':((r[2]===2)?'end':'warn');
    ev=null; for(j=0;j<L.length;j++) if(L[j].id===id&&L[j].n===(r[1]|0)){ ev=L[j]; break; }
    if(!ev){
      ev={id:id,n:r[1]|0,name:def.name,t:0,warn:def.warn||EV.warn,dur:def.dur||30,ph:ph,lt:0,et:0,fade:def.fade||4,x:0,y:0,r:def.r||300,d:{},told:0};
      L.push(ev); was=null;
      if(ph==='warn'){ try{ say(def.name,'warn',{sub:def.sub?(def.sub+'  '+Math.round(+r[9])+'S'):(Math.round(+r[9])+'S')}); }catch(_en){} }
    } else was=ev.ph;
    if(isFinite(+r[3])&&isFinite(+r[4])){ ev.x=+r[3]; ev.y=+r[4]; }
    if(+r[5]>0) ev.r=+r[5];
    if(isFinite(+r[6])) ev.t=+r[6];
    if(isFinite(+r[7])) ev.lt=+r[7];
    if(isFinite(+r[8])) ev.et=+r[8];
    if(+r[9]>0) ev.warn=+r[9];
    if(+r[10]>0) ev.dur=+r[10];
    if(+r[11]>0) ev.fade=+r[11];
    ev.ph=ph;
    evNetTakeX(ev,r[12]);
    if(was==='warn'&&ph!=='warn') evPeerStart(ev);
    seen[ev.n+id]=1; E.n=Math.max(E.n|0,ev.n+1);
  }
  for(j=L.length-1;j>=0;j--) if(!seen[L[j].n+L[j].id]) L.splice(j,1);
  return L.length;
}
// a piece of debris landed: its blast, its shake and its damage on THIS player (the bodies, the fire and the wreck are the host)
function debrisImpactPeer(pt){
  var p=G.player, R=72, d;
  sfx('boom',pt.x,pt.y);
  spark(pt.x,pt.y,'#ffcf7a',30,340); flash(pt.x,pt.y,300,'#ffb267',.5);
  try{ boomFx(pt.x,pt.y,1.4,'frag'); }catch(_de){}
  try{ gfxBlastScar(pt.x,pt.y,1.3,false); }catch(_ds){}
  G.shake=Math.max(G.shake||0,Math.max(3,9-dist(p,pt)/120));
  d=Math.hypot(p.x-pt.x,p.y-pt.y);
  if(d<R+(p.r||11)&&!p.downed&&!p.dying&&!p.specOut) damagePlayer(Math.round(150*(1-d/(R+(p.r||11)))+30),'debris','ORBITAL DEBRIS',pt.x,pt.y);
}
function evPeerTick(dt){
  var E=evS(), L=E.live, i, j, ev, pt, c, t=G.t||0;
  for(i=L.length-1;i>=0;i--){
    ev=L[i]; ev.t+=dt;
    if(ev.ph==='live') ev.lt+=dt;
    else if(ev.ph==='end'){ ev.et+=dt; if(ev.et>=ev.fade+2){ L.splice(i,1); continue; } }
    if(ev.id==='debris'&&ev.ph==='live'&&ev.d.pts){
      for(j=0;j<ev.d.pts.length;j++){
        pt=ev.d.pts[j];
        if(!pt.fx&&(ev.lt>=pt.at||pt.done)){ pt.fx=1; if(ev.lt<pt.at+2) debrisImpactPeer(pt); }
      }
    }
  }
  if(t-(+E.wkT||-9)>=1||t<(+E.wkT||0)){
    E.wkT=t;
    for(i=E.wrecks.length-1;i>=0;i--) if(!E.wrecks[i]||E.wrecks[i].opened||G.containers.indexOf(E.wrecks[i])<0) E.wrecks.splice(i,1);
    for(i=0;i<G.containers.length;i++){ c=G.containers[i]; if(c&&c.tag&&EV_WRECK_TAGS[c.tag]&&!c.opened&&!c.fwk){ c.fwk=1; E.wrecks.push(c); } }
  }
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='27.06';
'@ @'
var VER='27.07';
'@

$pat = "(?m)^  now:'v27\.06:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.07: Player 2 now sees the raid events, with their warning rings, and feels the debris and the fog. Check 27.07 fails on v27.06',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
