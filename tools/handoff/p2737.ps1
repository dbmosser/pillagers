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

# THE LOCKDOWN ALARM IS GONE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var EV_IDS=['debris','convoy','bounty','cool','lock','rampage'];
'@ @'
var EV_IDS=['debris','convoy','bounty','cool','rampage'];   // v27.37 (nolockdown): the lockdown alarm is gone for good
'@

SubRx @'
// v26.xx (flow9), HIS ANSWER (2026-10-14), the raid events, the fifth: LOCKDOWN ALARM, "blast doors seal a district for 60 s with a cache inside, and its machines
// go berserk". A 25 s warning over a ring 300 wide (450 to 1,000 from you, 450 and more from any extraction ring) with a cache in the middle: the alarm gives
// you time to get in. Then the DOORS SLAM and the ring is a wall for LOCK.seal (60) s: every body inside stays inside and every body outside stays outside
// (whoever crosses the line is put back on its own side, the player, the machines and the pillagers alike; bullets fly over). The machines inside, with a
// garrison made up to five if the ground held fewer, go BERSERK: 35 percent faster, 25 percent harder, always on the chase after you, with a red ring under
// them. At 60 s the DOORS OPEN, and the berserk machines pour out for LOCK.rel (20) more seconds, then calm down and the event ends. The LOCKDOWN CACHE in the
// middle (three cache rolls and a jackpot roll) is yours if you can take it; it is marked on the maps until opened. Made on side streams of the event.
// DEMO and CAREER are the same.
var LOCK={seal:60,rel:20,fast:1.35,hard:1.25,garrison:5};
function lockMachine(e){ return !!e&&e.hp>0&&!e.boss&&!e.merc&&!e.neutral&&e.kind!=='raider'&&e.kind!=='peddler'&&e.kind!=='stray'&&e.kind!=='snitch'&&!e.friendlyPC; }
function lockSealed(ev){ return !!ev&&ev.id==='lock'&&ev.ph==='live'&&ev.lt<LOCK.seal; }
// put o back on its own side of the ring (inside: 1, outside: 2); true when it was moved
function lockKeep(o,rad,ev,side){
  var d=Math.hypot(o.x-ev.x,o.y-ev.y), R=ev.r, a, tgt, nx, ny;
  if(side===1){ if(d<=R-rad-2) return false; tgt=R-rad-6; } else { if(d>=R+rad+2) return false; tgt=R+rad+6; }
  a=(d>0.5)?Math.atan2(o.y-ev.y,o.x-ev.x):0;
  nx=ev.x+Math.cos(a)*tgt; ny=ev.y+Math.sin(a)*tgt;
  if(spotFree(G.map,nx,ny,Math.max(6,rad*0.6))){ o.x=nx; o.y=ny; return true; }
  return false;
}
function lockCache(ev){
  var L=[], c=null, E=evS(), seed=(((G.seed>>>0)^Math.imul((ev.n|0)+91,2654435761))>>>0)||1;
  sideStream(seed,EV.tag+8,function(){ var k; for(k=0;k<3;k++) L.push(rollLoot(LOOT.cache)); L.push(rollLoot(LOOT.jackpot)); });
  sideStream(seed,EV.tag+9,function(){ c=setLoot(mkContainer(ev.x,ev.y,'cache'),L); });
  c.time=4.2; c.tag='LOCKDOWN CACHE'; c.wreck=1; G.containers.push(c); E.wrecks.push(c);
  return c;
}
EVENTS.lock={name:'LOCKDOWN ALARM',sub:'DISTRICT SEALS',warn:25,dur:80,r:300,fade:4,col:'#ff6a3a',
  pick:function(ev){
    var p=G.player, S=null;
    evStream(ev,function(){
      var k, a, d, x, y;
      for(k=0;k<80&&!S;k++){
        a=rr()*6.2832; d=450+rr()*550; x=p.x+Math.cos(a)*d; y=p.y+Math.sin(a)*d;
        if(x>400&&y>400&&x<WORLD_W-400&&y<WORLD_H-400&&spotFree(G.map,x,y,40)&&navReachable(G.map,x,y)&&!shutRoomAt(G.map,x,y)&&!flowZoneNear(x,y,450)) S={x:x,y:y};
      }
    });
    if(!S) return false;
    ev.x=S.x; ev.y=S.y;
    lockCache(ev);
    return true;
  },
  start:function(ev){
    var p=G.player, inn=[], i, e, made=[], seed=(((G.seed>>>0)^Math.imul((ev.n|0)+93,2654435761))>>>0)||1, d;
    for(i=0;i<G.ents.length;i++){
      e=G.ents[i];
      if(!e) continue;
      e.lkSide=(Math.hypot(e.x-ev.x,e.y-ev.y)<ev.r)?1:2;
      if(e.lkSide===1&&lockMachine(e)) inn.push(e);
    }
    if(inn.length<LOCK.garrison){
      sideStream(seed,EV.tag+10,function(){
        var k, t, a, r, x, y, m;
        for(k=0;inn.length+made.length<LOCK.garrison&&k<20;k++){
          for(t=0;t<12;t++){
            a=rr()*6.2832; r=rr()*ev.r*0.7; x=ev.x+Math.cos(a)*r; y=ev.y+Math.sin(a)*r;
            if(spotFree(G.map,x,y,30)){ m=(k&1)?mkSentry(x,y):mkCrawler(x,y); m.lkSide=1; made.push(m); break; }
          }
        }
      });
      for(i=0;i<made.length;i++){ G.ents.push(made[i]); inn.push(made[i]); }
    }
    for(i=0;i<inn.length;i++){ e=inn[i]; e.berserk=1; e.lkSpd=e.spd; e.lkDmg=e.dmg; e.spd=e.spd*LOCK.fast; e.dmg=e.dmg*LOCK.hard; e.state='chase'; e.alert=3; }
    ev.d.in=inn; ev.d.pSide=(Math.hypot(p.x-ev.x,p.y-ev.y)<ev.r)?1:2; ev.d.rel=0;
    try{ say(ev.d.pSide===1?'SEALED IN':'DISTRICT SEALED','crit',{sub:'MACHINES BERSERK  '+LOCK.seal+'S'}); }catch(_ls){}
  },
  tick:function(ev,dt){
    var p=G.player, i, e, sealed=lockSealed(ev), inn=ev.d.in||[], d;
    if(sealed){
      if(p&&!p.specOut) lockKeep(p,p.r||11,ev,ev.d.pSide);
      for(i=0;i<G.ents.length;i++){
        e=G.ents[i];
        if(!e||!(e.hp>0)||e.kind==='snitch') continue;
        if(!e.lkSide) e.lkSide=(Math.hypot(e.x-ev.x,e.y-ev.y)<ev.r)?1:2;
        lockKeep(e,e.r||12,ev,e.lkSide);
      }
    } else if(!ev.d.rel){
      ev.d.rel=1;
      try{ say('DOORS OPEN','warn',{sub:'THEY ARE COMING OUT'}); }catch(_lo){}
    }
    for(i=0;i<inn.length;i++){
      e=inn[i];
      if(!e||!(e.hp>0)||e.downed||G.ents.indexOf(e)<0) continue;
      e.state='chase'; e.alert=3; e.chaseHold=0; e.tx=p.x; e.ty=p.y;
    }
  },
  end:function(ev){
    var inn=ev.d.in||[], i, e;
    for(i=0;i<inn.length;i++){ e=inn[i]; if(e&&e.berserk){ e.berserk=0; if(e.lkSpd) e.spd=e.lkSpd; if(e.lkDmg) e.dmg=e.lkDmg; } }
    try{ say('LOCKDOWN OVER','info'); }catch(_le){}
  },
  live:function(ev){ return (ev.lt<LOCK.seal)?('SEALED '+fmtClock(Math.ceil(LOCK.seal-ev.lt))):'DOORS OPEN'; },
  draw:function(ev,c,s,q,z){
    var R=ev.r*q, t=G.t||0, inn=ev.d.in||[], i, e, es, a, k, sealed=lockSealed(ev), u=12*z;
    if(ev.ph==='warn'){
      c.strokeStyle='rgba(255,106,58,'+(0.35+0.3*Math.abs(Math.sin(t*6))).toFixed(3)+')'; c.lineWidth=3*z; c.setLineDash([26*z,16*z]);
      c.beginPath(); c.arc(s.x,s.y,R,0,6.2832); c.stroke(); c.setLineDash([]);
      return;
    }
    if(ev.ph==='live'){
      if(sealed){
        c.strokeStyle='rgba(255,84,48,.9)'; c.lineWidth=8*z; c.setLineDash([24*z,12*z]);
        c.beginPath(); c.arc(s.x,s.y,R,0,6.2832); c.stroke(); c.setLineDash([]);
        c.fillStyle='rgba(255,84,48,.95)';
        for(k=0;k<4;k++){ a=k*1.5708; c.save(); c.translate(s.x+Math.cos(a)*R,s.y+Math.sin(a)*R); c.rotate(a); c.fillRect(-u*0.5,-u*1.6,u,u*3.2); c.restore(); }
        c.fillStyle='rgba(255,84,48,.06)'; c.beginPath(); c.arc(s.x,s.y,R,0,6.2832); c.fill();
      } else {
        c.strokeStyle='rgba(255,170,90,.55)'; c.lineWidth=3*z; c.setLineDash([16*z,16*z]);
        c.beginPath(); c.arc(s.x,s.y,R,0,6.2832); c.stroke(); c.setLineDash([]);
      }
    }
    c.lineWidth=2.2*z;
    for(i=0;i<inn.length;i++){
      e=inn[i]; if(!e||!e.berserk||!(e.hp>0)) continue;
      es=w2s(e.x,0,e.y); c.strokeStyle='rgba(255,60,40,'+(0.5+0.4*Math.sin(t*10+i)).toFixed(3)+')';
      c.beginPath(); c.arc(es.x,es.y,(e.r||14)*q*1.7,0,6.2832); c.stroke();
    }
  }
};

'@ @'
// v27.37 (nolockdown), HIS ORDER (2026-10-14): "get rid of the sealed lockdown thing that's a mess". THE LOCKDOWN ALARM IS GONE, FOR GOOD. The event (flow9) sealed a ring of ground for a minute, with a cache in it and the
// machines inside gone berserk, and the fence ran through whatever the ring crossed. It is out of the pool, with its fences and the collision they made, its cache and the map tag of it, its callouts, its marks, its clocks and
// everything player 2 was told about it. The other five events stay (orbital debris, convoy, bounty pillager, coolant fog, Overseer rampage), one or two a raid as before: the plan is drawn on the event side stream, so it
// moves nothing else that is seeded. He is never to see it again, and it must not come back.

'@

SubRx @'
var EV_WRECK_TAGS={'DEBRIS WRECK':1,'CONVOY CRATE':1,'LOCKDOWN CACHE':1,'STRONGHOLD CACHE':1,'GOLDEN HOARD':1};
'@ @'
var EV_WRECK_TAGS={'DEBRIS WRECK':1,'CONVOY CRATE':1,'STRONGHOLD CACHE':1,'GOLDEN HOARD':1};
'@

SubRx @'
  if(ev.id==='lock'){ a=[]; for(i=0;d.in&&i<d.in.length&&i<16;i++) if(d.in[i]&&d.in[i].nid&&d.in[i].berserk&&d.in[i].hp>0) a.push(d.in[i].nid); return [a]; }
  if(ev.id==='cool'){ a=[]; for(i=0;i<G.containers.length&&a.length<24;i++){ c=G.containers[i]; if(c&&c.rich&&!c.opened&&c.cid>=0) a.push(c.cid); } return [a]; }
'@ @'
  if(ev.id==='cool'){ a=[]; for(i=0;i<G.containers.length&&a.length<24;i++){ c=G.containers[i]; if(c&&c.rich&&!c.opened&&c.cid>=0) a.push(c.cid); } return [a]; }
'@

SubRx @'
  else if(ev.id==='lock'){
    for(i=0;X[0]&&i<X[0].length&&i<16;i++){ c=evEnt(X[0][i]|0); if(c) keep[c.nid]=c; }
    for(i=0;d.in&&i<d.in.length;i++) if(d.in[i]&&!keep[d.in[i].nid]) d.in[i].berserk=0;
    d.in=[]; for(i in keep){ keep[i].berserk=1; d.in.push(keep[i]); }
  } else if(ev.id==='cool'){
'@ @'
  else if(ev.id==='cool'){
'@

SubRx @'
  if(id==='lock') ev.d.pSide=(p&&Math.hypot(p.x-ev.x,p.y-ev.y)<ev.r)?1:2;
  try{
'@ @'
  try{
'@

SubRx @'
    else if(id==='lock') say(ev.d.pSide===1?'SEALED IN':'DISTRICT SEALED','crit',{sub:'MACHINES BERSERK  '+LOCK.seal+'S'});
    else if(id==='rampage') say('OVERSEER RAMPAGE','crit',{sub:'IT HAS LEFT THE LAIR'});
'@ @'
    else if(id==='rampage') say('OVERSEER RAMPAGE','crit',{sub:'IT HAS LEFT THE LAIR'});
'@

SubRx @'
    else if(was==='live'&&ph==='end'&&id==='lock'){ try{ say('LOCKDOWN OVER','info'); }catch(_le){} }
    seen[ev.n+id]=1; E.n=Math.max(E.n|0,ev.n+1);
'@ @'
    seen[ev.n+id]=1; E.n=Math.max(E.n|0,ev.n+1);
'@

SubRx @'
    if(ev.id==='lock'&&ev.ph==='live'){   // v27.09 (coop3): the district doors, felt by this player
      if(lockSealed(ev)&&p&&!p.specOut&&ev.d.pSide) lockKeep(p,p.r||11,ev,ev.d.pSide);
      else if(!lockSealed(ev)&&!ev.d.rel){ ev.d.rel=1; try{ say('DOORS OPEN','warn',{sub:'THEY ARE COMING OUT'}); }catch(_lo){} }
    }
    if(ev.id==='debris'&&ev.ph==='live'&&ev.d.pts){
'@ @'
    if(ev.id==='debris'&&ev.ph==='live'&&ev.d.pts){
'@

SubRx @'
  'RAID EVENTS. One or two a raid, with a ring and a countdown: falling debris, a convoy, a bounty hunter, coolant fog, a lockdown, an Overseer rampage.',
'@ @'
  'RAID EVENTS. One or two a raid, with a ring and a countdown: falling debris, a convoy, a bounty hunter, coolant fog, an Overseer rampage.',
'@

SubRx @'
var VER='27.36';
'@ @'
var VER='27.37';
'@

$pat = "(?m)^  now:'v27\.36:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.37: The lockdown alarm event is gone: no more sealed rings. Check 27.37 fails on v27.36',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
