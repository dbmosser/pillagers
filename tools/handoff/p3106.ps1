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

# shock, toxic waste and dry ice barrels join the red one (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var BRL_TAG=47, BRL_CL=14, BRL_HP=30, BRL_R=170, BRL_HIT=13;
'@ @'
var BRL_TAG=47, BRL_CL=14, BRL_HP=30, BRL_R=170, BRL_HIT=13;
// v28.xx (cw-barrels3), HIS NOTE (2026-10-18 15:47, in a raid, build 30.73): "add other exploding barrels, e.g. electricity, toxic waste, dry ice". THREE NEW KINDS NEXT
// TO THE RED ONE, on the elements the Forge gives a gun (ELEM): SHOCK (electricity), ACID (toxic waste), CRYO (dry ice). No barrel was added and nothing was drawn from a
// stream: brlPlace lays the same barrels on the same spots as before and the kind of each is a PURE HASH of the raid seed and where it stands (brlKindAt), so every window
// of a party reads the same kind, the seeded stream is untouched and the seed 4242 fingerprint holds (ents 85/374, containers 165/593). THE MIX: 55 percent red, 15 percent
// each of shock, acid and cryo (BRL_MIX). A barrel with no kind (B.k) is red, as every older barrel and check. THE RED BARREL IS UNTOUCHED. The three blasts are
// brlBlastK: SHOCK is a smaller blast that stuns what it strikes (elemStun, the gun's stun) and chains arcs on to the next bodies (elemSoak and elemArcFx, the gun's arc),
// ACID the smallest blast, it eats armour (elemShred, elemHit acid) and leaves a pool that keeps eating, CRYO a frost burst (elemChill, elemHit cryo, the gun's cold: the
// middle freezes, the rim is slowed) that leaves a fog that keeps chilling. Every kind lights the barrels in its reach (brlNear, a chain) and any blast shatters a frozen
// crawler. Players are hurt as by the red one: only by a barrel no player lit or one they lit themselves (his rule of no team damage), each window running its own copy of
// the blast; the host window runs the bodies and sends the arcs, and the statuses ride the bits of netEntFlags that the gun already uses.
var BRL_MIX=[0.55,0.70,0.85];
var BRLK={
  shock:{R:150,pd:38,pb:12,ed:80,eb:15,ping:520,snd:'barrelShock',nm:'SHOCK BARREL'},
  acid:{R:120,pd:30,pb:10,ed:60,eb:14,ping:380,snd:'barrelAcid',nm:'ACID BARREL',pool:1},
  cryo:{R:150,pd:14,pb:6,ed:30,eb:8,ping:300,snd:'barrelCryo',nm:'CRYO BARREL',pool:1}
};
var BRL_POOL={
  acid:{r:72,life:6,pl:4,src:'acid',nm:'ACID POOL',en:10,mach:1.25,shred:34,plate:3,sp:7,col:'#9cff4a'},
  cryo:{r:96,life:5,pl:2,src:'cold',nm:'FROST FOG',chill:1,sp:5,col:'#dff6ff'}
};
var BRL_ARC=28, BRL_Z=[], BRL_ZAPN=0;
function brlKindAt(seed,x,y){
  var h=Math.imul((seed|0)^0x9e3779b9,0x85ebca6b)^Math.imul(Math.round(x)|0,0xc2b2ae35)^Math.imul(Math.round(y)|0,0x27d4eb2f), u;
  h^=h>>>15; h=Math.imul(h,0x2c1b3c6d); h^=h>>>12; h=Math.imul(h,0x297a2d39); h^=h>>>15;
  u=(h>>>0)/4294967296;
  return u<BRL_MIX[0]?'red':(u<BRL_MIX[1]?'shock':(u<BRL_MIX[2]?'acid':'cryo'));
}
'@

SubRx @'
      g.brl.push({id:g.brl.length,x:s.x,y:s.y,hp:BRL_HP,fuse:-1,by:-1,gone:0});
'@ @'
      g.brl.push({id:g.brl.length,x:s.x,y:s.y,hp:BRL_HP,fuse:-1,by:-1,gone:0,k:brlKindAt(g.seed,s.x,s.y)});
'@

SubRx @'
          if(brlOk(g,x,y)){ g.brl.push({id:g.brl.length,x:x,y:y,hp:BRL_HP,fuse:-1,by:-1,gone:0}); break; }
'@ @'
          if(brlOk(g,x,y)){ g.brl.push({id:g.brl.length,x:x,y:y,hp:BRL_HP,fuse:-1,by:-1,gone:0,k:brlKindAt(g.seed,x,y)}); break; }
'@

SubRx @'
function brlFireAdd(x,y,by){
'@ @'
function brlFireAdd(x,y,by,k){
'@

SubRx @'
  var f={x:x,y:y,r:BRL_FIRE_R,t:0,life:BRL_FIRE_LIFE,by:by,bt:0};
'@ @'
  var Q=(k&&BRL_POOL[k])||null, f={x:x,y:y,r:Q?Q.r:BRL_FIRE_R,t:0,life:Q?Q.life:BRL_FIRE_LIFE,by:by,bt:0,k:Q?k:'fire'};   // v28.xx (cw-barrels3): a pool of acid or a fog of frost is one of these too
'@

SubRx @'
    if(f.t>=f.life) continue;
'@ @'
    if(f.t>=f.life) continue;
    if(f.k&&f.k!=='fire'){ brlPoolTick(f,dt,peer,me); continue; }   // v28.xx (cw-barrels3): the acid pool and the frost fog
'@

SubRx @'
function brlFireDraw(f){
'@ @'
function brlFireDraw(f){
  if(f.k&&f.k!=='fire') return brlPoolDraw(f);   // v28.xx (cw-barrels3): the acid pool and the frost fog
'@

SubRx @'
  x=B.x; y=B.y; s=B.by; bp={x:x,y:y};
  B.gone=1; B.fuse=-1;
'@ @'
  if(B.k&&B.k!=='red') return brlBlastK(B);   // v28.xx (cw-barrels3): shock, acid and cryo barrels have their own blast
  x=B.x; y=B.y; s=B.by; bp={x:x,y:y};
  B.gone=1; B.fuse=-1;
'@

SubRx @'
      dm=120*(1-Math.max(0,de-e.r)/R)+30;
      e.hp-=dm; e.hitT=.2;
'@ @'
      dm=120*(1-Math.max(0,de-e.r)/R)+30;
      if(brlShatterOk(e)){ dm=e.hp+1; brlShatterFx(e); }   // v28.xx (cw-barrels3): a blast shatters a frozen crawler
      e.hp-=dm; e.hitT=.2;
'@

SubRx @'
  if(peer) return;   // a linked window: the host runs the bodies
'@ @'
  if(peer){ brlPeerShatter(x,y,R); return; }   // a linked window: the host runs the bodies (and this window shows the shards of a frozen crawler it breaks)
'@

SubRx @'
function brlDraw(B){
'@ @'
// v28.xx (cw-barrels3): SHATTER. A crawler that is frozen when any barrel blast reaches it breaks apart: the blast takes the rest of its health, with the crack of a freeze.
function brlShatterOk(e){ return !!(e&&e.kind==='crawler'&&e.frozenT>0&&e.hp>0&&!e.finished); }
function brlShatterFx(e){
  if(!G||G.sim||!e) return false;
  sfx('elFreeze',e.x,e.y); spark(e.x,e.y-10,'#ffffff',14,260); spark(e.x,e.y-8,'#9fdcff',10,200);
  G.puffs.push({x:e.x,y:e.y-6,t:0,life:.5,c:'#dff6ff',r:24});
  return true;
}
function brlPeerShatter(x,y,R){
  var i, e, n=0;
  if(!G||G.sim) return 0;
  for(i=0;i<G.ents.length;i++){ e=G.ents[i]; if(brlShatterOk(e)&&Math.hypot(e.x-x,e.y-y)<R+(e.r||12)&&losClear(x,y,e.x,e.y,G.map.segs)){ brlShatterFx(e); n++; } }
  return n;
}
// v28.xx (cw-barrels3): what each blast looks like, in every window. Cosmetic only (fxn, never the seeded stream). The arcs from the barrel to the bodies it struck are the host's
// (brlArcs sends them); the ones thrown round the barrel are each window's own.
function brlBlastFx(k,x,y,R){
  var j, a, d, q;
  if(!G||G.sim) return false;
  if(k==='shock'){
    flash(x,y,300,'#9ccaff',.45);
    spark(x,y,'#bfe0ff',26,360); spark(x,y,'#ffffff',12,240);
    G.puffs.push({x:x,y:y,t:0,life:.45,c:'#8fc0ff',r:56});
    decal(x,y,'#0e1624',fxn(24,32));
    for(j=0;j<5;j++){
      a=fxn(0,6.2832); d=fxn(R*0.5,R*0.95);
      if(elemArcFx(x,y,x+Math.cos(a)*d,y+Math.sin(a)*d*0.6,0)){ q=G.arcs[G.arcs.length-1]; if(q) q.life=0.28; }
    }
  } else if(k==='acid'){
    flash(x,y,240,'#a6ff5a',.35);
    spark(x,y,'#9cff4a',28,300); spark(x,y,'#e6ffb0',10,200);
    G.puffs.push({x:x,y:y,t:0,life:.8,c:'#7fd13a',r:60}); G.puffs.push({x:x,y:y-10,t:0,life:1.4,c:'#31521a',r:48});
    decal(x,y,'#2a5a12',fxn(30,40));
    for(j=0;j<6;j++){ a=fxn(0,6.2832); d=fxn(R*0.3,R*0.9); decal(x+Math.cos(a)*d,y+Math.sin(a)*d*0.6,'#3d7a1a',fxn(5,10)); }
  } else {
    flash(x,y,300,'#c8ecff',.4);
    spark(x,y,'#f2fcff',30,300); spark(x,y,'#9fdcff',14,200);
    G.puffs.push({x:x,y:y,t:0,life:1.1,c:'#e9f9ff',r:80}); G.puffs.push({x:x,y:y-8,t:0,life:1.8,c:'#bfe6fa',r:64});
    decal(x,y,'#bcdcec',fxn(28,36));
  }
  return true;
}
// v28.xx (cw-barrels3): THE SHOCK, ACID AND CRYO BLASTS. The same shape as brlBlast (the player of this window by the no team damage rule, the walls spared, the barrels in
// reach lit, a linked window stops before the bodies, the kill credited to whoever lit the barrel) with its own reach and its own damage (BRLK) and the gun's effect on every
// body it reaches: SHOCK stuns it (elemStun, 1 s a machine, 0.6 s a pillager, never a boss) and then arcs on (brlArcs); ACID eats its armour (elemShred) and corrodes it (elemHit
// acid), a machine taking a quarter more; CRYO chills it (elemChill: the middle freezes, the rim is slowed). A frozen crawler shatters.
function brlBlastK(B){
  var K=BRLK[B.k], p=G.player, R, x=B.x, y=B.y, s=B.by, me=brlMe(), i, e, de, dm, sd, bp={x:x,y:y}, peer=netEntsPeer();
  if(!K) return;
  R=K.R; B.gone=1; B.fuse=-1;
  sd=Math.hypot(x-p.x,y-p.y);
  try{ if(sd<R*1.8) padRumble(Math.max(0.25,0.9-sd/(R*1.8)),200); }catch(_rb){}
  sfx(K.snd,x,y);
  brlBlastFx(B.k,x,y,R);
  G.shake=Math.max(G.shake,sd<300?7:(sd<800?3:1));
  ping(x,y,K.ping,false,false,'env','fire');
  if(K.pool) brlFireAdd(x,y,s,B.k);
  if(!p.specOut&&!p.dying&&(s<0||s===me)&&sd<R&&losClear(x,y,p.x,p.y,G.map.segs))
    damagePlayer(K.pd*(1-sd/R)+K.pb,'barrel',K.nm,x,y);
  brlNear(x,y,R,s);
  if(peer){ brlPeerShatter(x,y,R); return; }
  BRL_ZAPN++; BRL_Z.length=0;
  for(i=G.ents.length-1;i>=0;i--){
    e=G.ents[i];
    if(!e||e.finished) continue;
    if(s>=0&&e.merc&&!e.downed) continue;
    de=dist(e,bp);
    if(!(de<R+e.r&&losClear(x,y,e.x,e.y,G.map.segs))) continue;
    dm=K.ed*(1-Math.max(0,de-e.r)/R)+K.eb;
    if(brlShatterOk(e)){ dm=e.hp+1; brlShatterFx(e); }
    else if(B.k==='acid'&&ELEM_MACH[e.kind]) dm*=1.25;
    e.hp-=dm; e.hitT=.2;
    if(s===0) notoAggress(e); else if(s>0&&e.kind==='raider'&&e.hostile===false&&!e.friendlyPC) e.hostile=true;
    if(e.hp<=0){ e.byPlayer=(s===0); e.bySeat=(s>0)?s:0; }
    if(s>=0){ e.pHitT=.3; e.pHitSeat=s; e.blow='x'; e.blowT=G.t; }
    if(e.state!=='alarm'&&e.kind!=='peddler'&&e.kind!=='stray'&&!e.downed&&!e.merc){ e.state='chase'; e.alert=2.5; e.tx=(s===0)?p.x:x; e.ty=(s===0)?p.y:y; }
    if(B.k==='shock'){ e.zapN=BRL_ZAPN; BRL_Z.push(e); if(e.hp>0&&elemOk(e)) elemStun(e,1); }
    else if(e.hp>0&&elemOk(e)){
      if(B.k==='acid'){ elemShred(e,dm); elemHit(e,'acid',dm,s>0?s:0); }
      else { elemChill(e,(de<R*0.5)?6.5:3); elemSnd(e,'cryo'); }
    }
  }
  if(B.k==='shock'&&BRL_Z.length) brlArcs(s,x,y,p);
}
// v28.xx (cw-barrels3): THE CHAIN OF ARCS of a shock blast. From the barrel to each body it struck (up to 8), and from each of those on to the nearest body not yet struck within 150
// with a clear line, twice (the gun's arc: half-strength soaked by armour, never the shield, turns the man on the one who lit the barrel, and stuns). Sent to the party as the gun's are.
function brlArcs(s,x,y,p){
  var i, n=BRL_Z.length, cur, best, bd, j, t, dd, depth, a;
  for(i=0;i<n&&i<8;i++){
    cur=BRL_Z[i];
    elemArcFx(x,y,cur.x,cur.y,1);
    for(depth=0;depth<2;depth++){
      best=null; bd=150;
      for(j=0;j<G.ents.length;j++){
        t=G.ents[j];
        if(t.zapN===BRL_ZAPN||!elemArcOk(t)) continue;
        dd=Math.hypot(t.x-cur.x,t.y-cur.y);
        if(dd<bd&&losClear(cur.x,cur.y,t.x,t.y,G.map.segs)){ bd=dd; best=t; }
      }
      if(!best) break;
      best.zapN=BRL_ZAPN;
      a=elemSoak(best,BRL_ARC*(depth?0.7:1));
      best.hp-=a; best.hitT=.16;
      if(s>=0){ best.pHitT=.3; best.pHitSeat=s; if(best.hp<=0){ best.byPlayer=(s===0); best.bySeat=(s>0)?s:0; } }
      elemProvoke(best,(s===0)?p.x:x,(s===0)?p.y:y,s>0?s:0);
      if(best.hp>0) elemStun(best,1);
      elemArcFx(cur.x,cur.y,best.x,best.y,1);
      if(!G.sim&&CFG.dmgNumbers!==0) dmgNum(best.x,best.y-Math.round(best.r*1.1),Math.max(1,Math.round(a)),ELEM.shock.c,best.hp<=0);
      cur=best;
    }
  }
}
// v28.xx (cw-barrels3): THE ACID POOL AND THE FROST FOG (G.bfire, like the fire pool, each window lays its own from its own copy of the blast). Acid: the player in it takes 4 every half
// second and loses 3 of his plate (never a pool a teammate lit), a body 10 a second (a machine a quarter more) and its armour is eaten (elemShred, 34 a second of "round"). Cryo: the
// player takes 2 every half second, and every half second a body in it takes one more cold (elemChill), so a body that stays in the fog is slowed and in the end frozen. The host window
// runs the bodies. Cosmetic sparks from the cosmetic stream only.
function brlPoolTick(f,dt,peer,me){
  var Q=BRL_POOL[f.k], p=G.player, j, e, a, d2, tick;
  if(!Q) return;
  if(fxr()<dt*Q.sp){ a=fxn(0,6.2832); d2=fxn(0,f.r*0.8); spark(f.x+Math.cos(a)*d2,f.y+Math.sin(a)*d2*0.6,Q.col,1,50); }
  f.bt+=dt; tick=(f.bt>=0.5); if(tick) f.bt-=0.5;
  if(tick&&p&&!p.specOut&&!p.dying&&!p.downed&&(f.by<0||f.by===me)&&Math.hypot(p.x-f.x,p.y-f.y)<f.r+(p.r||11)&&losClear(f.x,f.y,p.x,p.y,G.map.segs)){
    damagePlayer(Q.pl,Q.src,Q.nm,f.x,f.y);
    if(f.k==='acid'&&p.armor>0) p.armor=Math.max(0,p.armor-Q.plate);
  }
  if(peer) return;
  for(j=0;j<G.ents.length;j++){
    e=G.ents[j];
    if(!e||!(e.hp>0)||e.finished||e.kind==='snitch') continue;
    if(f.by>=0&&e.merc&&!e.downed) continue;
    if(!(Math.hypot(e.x-f.x,e.y-f.y)<f.r+(e.r||12)&&losClear(f.x,f.y,e.x,e.y,G.map.segs))) continue;
    if(f.k==='acid'){
      e.hp-=Q.en*dt*(ELEM_MACH[e.kind]?Q.mach:1); e.hitT=Math.max(e.hitT||0,0.1);
      if(elemOk(e)){ elemShred(e,Q.shred*dt); G.elemAny=1; }
      if(e.hp<=0&&f.by>=0){ e.byPlayer=(f.by===0); e.bySeat=(f.by>0)?f.by:0; }
    } else if(tick&&elemOk(e)) elemChill(e,Q.chill);
  }
}
// v28.xx (cw-barrels3): THE LOOK OF A KIND. SHOCK is a yellow drum with a black bolt and a blue spark that jumps off the lid; ACID a toxic green drum with the black trefoil and a drop
// that runs down its side; CRYO a pale ice-blue drum with a deep blue snowflake and wisps of cold rising off the lid; the red one stays red with its white !. Each has a slow pulse
// of its own light on the floor so it is read from across the lane. Drawn with a few canvas calls from constants and the clock: no object, string or array is made in a frame, and
// the pool and the fog are one baked sprite (brlSpr) drawn a few times, never a gradient made in a frame.
var BRLP={
  shock:{body:'#e3b81c',fl:'#fff2a0',lid:'#f3d853',lidf:'#ffffff',band:'#2a2206',sym:'#15110a',glow:'#6ea8ff',hole:'#7a5f08'},
  acid:{body:'#4fa72a',fl:'#c8ff8a',lid:'#78cc48',lidf:'#e2ffb8',band:'#1c3a0e',sym:'#112209',glow:'#8cff3c',hole:'#2a5c12'},
  cryo:{body:'#b8dfee',fl:'#ffffff',lid:'#e6f6fc',lidf:'#ffffff',band:'#4b86a8',sym:'#18537f',glow:'#bfeaff',hole:'#6f9db8'}
};
var BRL_SNOW=(function(){
  var o=[], j, m, a, d, px, py;
  for(j=0;j<3;j++){
    for(m=0;m<2;m++){
      a=1.5708+j*1.0472+m*3.1416;
      o.push(0,0,Math.cos(a)*6.8,Math.sin(a)*6.8);
      px=Math.cos(a)*4.3; py=Math.sin(a)*4.3;
      d=a+0.75; o.push(px,py,px+Math.cos(d)*2.7,py+Math.sin(d)*2.7);
      d=a-0.75; o.push(px,py,px+Math.cos(d)*2.7,py+Math.sin(d)*2.7);
    }
  }
  return o;
})();
var BRLSPR={};
function brlSpr(k){
  var c, x, gr;
  if(BRLSPR[k]) return BRLSPR[k];
  c=document.createElement('canvas'); c.width=c.height=96; x=c.getContext('2d');
  gr=x.createRadialGradient(48,48,4,48,48,47);
  if(k==='acid'){ gr.addColorStop(0,'rgba(150,255,70,.95)'); gr.addColorStop(0.55,'rgba(88,190,36,.75)'); gr.addColorStop(1,'rgba(40,110,18,0)'); }
  else { gr.addColorStop(0,'rgba(255,255,255,.95)'); gr.addColorStop(0.5,'rgba(206,238,252,.6)'); gr.addColorStop(1,'rgba(170,220,245,0)'); }
  x.fillStyle=gr; x.fillRect(0,0,96,96);
  BRLSPR[k]=c; return c;
}
function brlPoolDraw(f){
  var t=(G&&G.t)||0, R=f.r, x=f.x, y=f.y, age=f.t, fade, j, ph, a, s, sp=brlSpr(f.k);
  fade=(age<f.life)?1:Math.max(0,1-(age-f.life)/BRL_FIRE_EMB);
  if(fade<=0) return;
  R*=Math.min(1,0.35+age/0.45);   // it spreads over the first half second
  wc.save();
  if(f.k==='acid'){
    wc.globalAlpha=0.55*fade; wc.fillStyle='#16300a'; wc.beginPath(); wc.ellipse(x,y,R,R*0.6,0,0,6.2832); wc.fill();
    wc.globalAlpha=0.8*fade; wc.drawImage(sp,x-R*1.05,y-R*0.66,R*2.1,R*1.32);
    wc.globalAlpha=0.5*fade; wc.strokeStyle='#caff8a'; wc.lineWidth=1.4; wc.beginPath(); wc.ellipse(x,y,R*0.96,R*0.58,0,0,6.2832); wc.stroke();
    wc.lineWidth=1;
    for(j=0;j<6;j++){   // bubbles that swell and break
      ph=(t*0.8+j*0.37+f.x*0.013)%1; a=j*2.4+f.y;
      wc.globalAlpha=0.7*fade*(1-ph);
      wc.beginPath(); wc.arc(x+Math.cos(a)*R*0.55*((j%3+1)/3),y+Math.sin(a)*R*0.33*((j%3+1)/3),1+ph*3,0,6.2832); wc.stroke();
    }
  } else {
    wc.globalAlpha=0.20*fade; wc.fillStyle='#d6f1ff'; wc.beginPath(); wc.ellipse(x,y,R*0.9,R*0.54,0,0,6.2832); wc.fill();
    wc.globalAlpha=0.45*fade; wc.strokeStyle='#ffffff'; wc.lineWidth=1.2; wc.beginPath(); wc.ellipse(x,y,R*0.88,R*0.53,0,0,6.2832); wc.stroke();
    for(j=0;j<5;j++){   // five soft clouds that drift round the middle
      a=j*1.2566+t*0.22; s=R*(0.62+0.1*Math.sin(t*0.9+j*1.7));
      wc.globalAlpha=0.34*fade; wc.drawImage(sp,x+Math.cos(a)*R*0.34-s,y+Math.sin(a)*R*0.2-s*0.62-16,s*2,s*1.24);
    }
    wc.fillStyle='#ffffff';
    for(j=0;j<7;j++){   // and ice dust that glints
      ph=(t*1.3+j*0.43)%1; a=j*3.1+f.x*0.01;
      wc.globalAlpha=Math.sin(ph*3.1416)*0.8*fade;
      wc.fillRect(x+Math.cos(a)*R*0.7*(0.4+0.6*((j*37)%10)/10),y+Math.sin(a)*R*0.4*(0.4+0.6*((j*53)%10)/10)-8-ph*10,1.6,1.6);
    }
  }
  wc.restore();
}
function brlDrawK(B){
  var P=BRLP[B.k], k=B.k, x=B.x, y=B.y, w=11, h=27, lit=(B.fuse>=0), t=(G&&G.t)||0, fl=lit&&(Math.floor(t*24)%2===0), pu=0.5+0.5*Math.sin(t*3.2+B.id), cy=y-h*0.5-1, ph, j, a, o;
  if(!P) return;
  shadowE(x,y+1,14,4.5,.38);
  wc.save();
  if(!lit){   // the slow pulse of its own light on the floor
    wc.globalCompositeOperation='lighter'; wc.globalAlpha=0.10+0.10*pu; wc.fillStyle=P.glow;
    wc.beginPath(); wc.ellipse(x,y-2,w+9+pu*3,(w+9+pu*3)*0.42,0,0,6.2832); wc.fill();
    wc.globalCompositeOperation='source-over'; wc.globalAlpha=1;
  }
  wc.fillStyle=INK; wc.fillRect(x-w-1,y-h-1,w*2+2,h+2);
  wc.fillStyle=fl?P.fl:P.body; wc.fillRect(x-w,y-h,w*2,h);
  wc.fillStyle='rgba(0,0,0,.30)'; wc.fillRect(x+w*0.35,y-h,w*0.65,h);
  wc.fillStyle='rgba(255,255,255,.16)'; wc.fillRect(x-w+2,y-h,3,h);
  wc.fillStyle=P.band; wc.fillRect(x-w,y-h+4,w*2,2); wc.fillRect(x-w,y-4,w*2,2);
  wc.fillStyle=fl?P.lidf:P.lid; wc.beginPath(); wc.ellipse(x,y-h,w,4.2,0,0,6.2832); wc.fill();
  wc.strokeStyle=INK; wc.lineWidth=1.2; wc.stroke();
  wc.fillStyle=P.hole; wc.beginPath(); wc.ellipse(x+4.5,y-h,2.2,1.2,0,0,6.2832); wc.fill();
  if(k==='shock'){   // a black bolt
    wc.fillStyle=P.sym; wc.beginPath(); wc.moveTo(x+3,cy-7.5); wc.lineTo(x-4.4,cy+1); wc.lineTo(x-0.6,cy+1); wc.lineTo(x-3,cy+8); wc.lineTo(x+4.6,cy-2); wc.lineTo(x+0.8,cy-2); wc.closePath(); wc.fill();
  } else if(k==='acid'){   // the black trefoil
    wc.fillStyle=P.sym;
    for(j=0;j<3;j++){ a=-1.5708+j*2.0944; wc.beginPath(); wc.moveTo(x,cy); wc.arc(x,cy,7,a-0.5236,a+0.5236); wc.closePath(); wc.fill(); }
    wc.fillStyle=P.body; wc.beginPath(); wc.arc(x,cy,2.5,0,6.2832); wc.fill();
    wc.fillStyle=P.sym; wc.beginPath(); wc.arc(x,cy,1.3,0,6.2832); wc.fill();
  } else {   // a deep blue snowflake
    wc.strokeStyle=P.sym; wc.lineWidth=1.5; wc.lineCap='round'; wc.beginPath();
    for(j=0;j<BRL_SNOW.length;j+=4){ wc.moveTo(x+BRL_SNOW[j],cy+BRL_SNOW[j+1]); wc.lineTo(x+BRL_SNOW[j+2],cy+BRL_SNOW[j+3]); }
    wc.stroke();
  }
  if(!lit){   // the idle tell
    if(k==='shock'){
      ph=(t*0.85+B.id*0.37)%1;
      if(ph<0.22){   // a spark jumps off the lid now and then
        o=((Math.floor(t*0.85+B.id*0.37)*37+B.id*11)%9)-4;
        wc.globalCompositeOperation='lighter'; wc.globalAlpha=1-ph*4; wc.strokeStyle='#cfe6ff'; wc.lineWidth=1.4; wc.lineCap='round';
        wc.beginPath(); wc.moveTo(x+o*0.6,y-h-1); wc.lineTo(x+o*0.6+3,y-h-5); wc.lineTo(x+o*0.6-2,y-h-8); wc.lineTo(x+o*0.6+4,y-h-13); wc.stroke();
        wc.strokeStyle='#ffffff'; wc.lineWidth=0.6; wc.stroke();
      }
    } else if(k==='acid'){
      ph=(t*0.5+B.id*0.31)%1;   // a drop runs down the side and lands in a ring at the foot
      wc.fillStyle='#d4ffa0'; wc.strokeStyle='#d4ffa0';
      if(ph<0.8){ wc.globalAlpha=0.95; wc.beginPath(); wc.ellipse(x+w-1.5,y-h+3+ph/0.8*(h-5),1.3,2.2,0,0,6.2832); wc.fill(); }
      else { wc.globalAlpha=1-(ph-0.8)/0.2; wc.lineWidth=1; wc.beginPath(); wc.ellipse(x+w-1,y+1.5,2+(ph-0.8)*30,1+(ph-0.8)*12,0,0,6.2832); wc.stroke(); }
      ph=(t*0.9+B.id*0.53)%1;   // and a bubble breaks on the lid
      wc.globalAlpha=0.9*(1-ph); wc.lineWidth=1; wc.beginPath(); wc.arc(x-3,y-h-0.5,0.6+ph*2.2,0,6.2832); wc.stroke();
    } else {
      wc.fillStyle='#e6f8ff';
      for(j=0;j<3;j++){   // a wisp of cold rises off the lid
        ph=(t*0.4+j*0.3333+B.id*0.19)%1;
        wc.globalAlpha=0.55*(1-ph)*(ph<0.15?ph/0.15:1);
        wc.beginPath(); wc.ellipse(x+Math.sin(t*1.1+j*2.3+B.id)*(2+ph*5),y-h-2-ph*18,3+ph*5,1.8+ph*2.4,0,0,6.2832); wc.fill();
      }
    }
  } else {   // lit: a glow in its own colour on the lid, and a shock barrel crackles
    wc.globalCompositeOperation='lighter'; wc.globalAlpha=fl?0.55:0.30; wc.fillStyle=P.glow;
    wc.beginPath(); wc.arc(x,y-h,10,0,6.2832); wc.fill();
    if(k==='shock'){
      o=((Math.floor(t*24)*37+B.id*11)%11)-5;
      wc.globalAlpha=0.9; wc.strokeStyle='#ffffff'; wc.lineWidth=1.2; wc.lineCap='round';
      wc.beginPath(); wc.moveTo(x+o,y-h-2); wc.lineTo(x+o+4,y-h-8); wc.lineTo(x+o-1,y-h-12); wc.stroke();
    }
  }
  wc.restore();
}
function brlDraw(B){
  if(B.k&&B.k!=='red') return brlDrawK(B);   // v28.xx (cw-barrels3): shock, acid and cryo barrels
'@

SubRx @'
    DR.push({k:_bf.y-30,fn:brlFireDraw.bind(null,_bf)});
'@ @'
    DR.push({k:_bf.y+(_bf.k==='cryo'?60:(_bf.k==='acid'?-70:-30)),fn:brlFireDraw.bind(null,_bf)});   // v28.xx (cw-barrels3): the acid pool lies under the bodies, the frost fog hangs over them
'@

SubRx @'
    if(ELEM_MACH[e.kind]&&!e.boss&&!(e.stunImm>0)){ e.stunT=(e.kind==='warden'||e.kind==='choir')?0.25:0.5; e.stunImm=e.stunT+2.5; }
'@ @'
    elemStun(e,0);   // v28.xx (cw-barrels3): the gun's stun, now a function the shock barrel calls too
'@

SubRx @'
    e.chill=(e.chill||0)+clamp(d/25,0.35,3)*flowCryo(e); e.chillT=2.5;   // v26.xx (flow8): twice the cold inside a coolant rupture
    if(e.chill>=6-1e-6&&!(e.freezeImm>0)){
      e.frozenT=e.boss?0.6:((e.kind==='warden'||e.kind==='choir')?0.7:1.4);
      e.chill=0; e.freezeImm=e.frozenT+4; e.roll=0;
      if(!G.sim){ sfx('elFreeze',e.x,e.y); spark(e.x,e.y-10,'#ffffff',10,200); }   // v23.xx (forge8): the crack of the freeze
    }
'@ @'
    elemChill(e,clamp(d/25,0.35,3));   // v28.xx (cw-barrels3): the gun's cold, now a function the cryo barrel calls too (the code is elemChill, unchanged)
'@

SubRx @'
function elemHit(e,el,d,seat,sx,sy){
'@ @'
// v28.xx (cw-barrels3): the gun's stun and the gun's cold as functions (they were inline in elemHit, the same lines), so a shock barrel and a cryo barrel do what a shock gun and a
// cryo gun do. elemStun: a machine is stunned 0.5 s (a Warden or a Choir 0.25 s), never a boss, then it cannot be stunned again for 2.5 s; with all set (a shock barrel) a pillager
// is held too, 0.6 s, and a machine twice as long. elemChill adds cold c (6 freezes, flowCryo doubles it inside a coolant rupture) and answers true when the body froze.
function elemStun(e,all){
  var t;
  if(!e||e.boss||e.stunImm>0) return false;
  if(!all&&!ELEM_MACH[e.kind]) return false;
  t=(e.kind==='warden'||e.kind==='choir')?0.25:0.5;
  if(all) t*=ELEM_MACH[e.kind]?2:1.2;
  e.stunT=t; e.stunImm=t+2.5; G.elemAny=1;
  return true;
}
function elemChill(e,c){
  e.chill=(e.chill||0)+c*flowCryo(e); e.chillT=2.5; G.elemAny=1;
  if(e.chill>=6-1e-6&&!(e.freezeImm>0)){
    e.frozenT=e.boss?0.6:((e.kind==='warden'||e.kind==='choir')?0.7:1.4);
    e.chill=0; e.freezeImm=e.frozenT+4; e.roll=0;
    if(!G.sim){ sfx('elFreeze',e.x,e.y); spark(e.x,e.y-10,'#ffffff',10,200); }   // v23.xx (forge8): the crack of the freeze
    return true;
  }
  return false;
}
function elemHit(e,el,d,seat,sx,sy){
'@

SubRx @'
// ---------------------------------------------------------------- the active reload (yours, on the HUD bus)
'@ @'
// v28.xx (cw-barrels3): THE THREE NEW BARRELS, each with its own blast, all on the world bus and built from the recordings already in the bank (no new file), pitched. SHOCK: a short bang
// pitched up and thin, the force field hum pitched way up, a falling saw zap and a scatter of crackle. ACID: the drum's hollow burst slowed, a low thump, a long hiss and the pops of bubbles.
// CRYO: a glass-bright snap, the drum slowed and soft, a rush of venting gas and the ring of ice.
SPK_CAT.barrelShock='imp';
SPK_INFO.barrelShock={grp:'world',lab:'BARREL: shock',len:1.1,kind:'both',uses:['xplShort','forceField']};
SPK_GEN.barrelShock=function(a,OUT,vol,t,wid,d){
  var M, o, i;
  if(!spkGate('barrelShock',0.06,t)) return null;
  spkDuck(d);
  M=spkMaster(a,OUT,vol,t);
  o=spkSamp(a,M,'xplShort',{at:t,g:0.75,rate:1.45+Math.random()*0.1,hp:260});
  spkSamp(a,M,'forceField',{at:t,g:0.8,rate:1.9,dur:0.8});
  spkOsc(a,M,{ty:'sawtooth',f0:2600,f1:140,at:t,dur:0.2,g:0.09,shp:3,lp:7000,atk:0.001});
  spkTick(a,M,t,5200,1.2,0.05,0.22,'highpass');
  for(i=0;i<10;i++) spkTick(a,M,t+0.05+Math.random()*0.75,2600+Math.random()*4400,2+Math.random()*3,0.012+Math.random()*0.02,0.13*(1-i/14),'highpass');
  spkSub(a,M,95,40,0.35,0.3,t);
  return spkH(M,o,t+1.1);
};
SPK_CAT.barrelAcid='imp';
SPK_INFO.barrelAcid={grp:'world',lab:'BARREL: acid',len:1.3,kind:'both',uses:['drumBonk','xplShort']};
SPK_GEN.barrelAcid=function(a,OUT,vol,t,wid,d){
  var M, o, i;
  if(!spkGate('barrelAcid',0.06,t)) return null;
  spkDuck(d);
  M=spkMaster(a,OUT,vol,t);
  o=spkSamp(a,M,'drumBonk',{at:t,g:0.9,rate:0.62});
  spkSamp(a,M,'xplShort',{at:t,g:0.45,rate:0.7,lp:2200,lp1:700});
  spkSub(a,M,100,38,0.4,0.3,t);
  spkNoise(a,M,{at:t+0.02,dur:0.95,g:0.16,ft:'bandpass',f0:3400,f1:1800,q:1.4,sh:'swell',pk:0.15});
  for(i=0;i<9;i++) spkOsc(a,M,{ty:'sine',f0:180+Math.random()*160,f1:420+Math.random()*300,at:t+0.12+Math.random()*0.9,dur:0.05,g:0.06,atk:0.003});
  spkCrunch(a,M,t,0.08,0.3);
  return spkH(M,o,t+1.3);
};
SPK_CAT.barrelCryo='imp';
SPK_INFO.barrelCryo={grp:'world',lab:'BARREL: cryo',len:1.5,kind:'both',uses:['metalHit','drumBonk']};
SPK_GEN.barrelCryo=function(a,OUT,vol,t,wid,d){
  var M, o, i;
  if(!spkGate('barrelCryo',0.06,t)) return null;
  spkDuck(d);
  M=spkMaster(a,OUT,vol,t);
  o=spkSamp(a,M,'metalHit',{at:t,g:0.7,rate:2.2,hp:1500});
  spkSamp(a,M,'drumBonk',{at:t,g:0.5,rate:0.9,lp:1800,lp1:600});
  spkNoise(a,M,{at:t,dur:1.25,g:0.18,ft:'highpass',f0:2500,f1:6000,q:0.7,sh:'swell',pk:0.1});
  for(i=0;i<3;i++) spkOsc(a,M,{ty:'sine',f0:2200+i*1100,f1:2200+i*1100,at:t+i*0.03,dur:0.3,g:0.045,atk:0.002});
  for(i=0;i<3;i++) spkTick(a,M,t+0.02+i*0.04,3600,3,0.03,0.2);
  spkSub(a,M,120,50,0.3,0.25,t);
  return spkH(M,o,t+1.5);
};

// ---------------------------------------------------------------- the active reload (yours, on the HUD bus)
'@

SubRx @'
barrelBlast:0.612,barrelChain:0.638,
'@ @'
barrelBlast:0.612,barrelChain:0.638,barrelShock:0.6,barrelAcid:0.6,barrelCryo:0.58,
'@

SubRx @'
barrelBlast:{r:120,hear:1500}, barrelChain:{r:110,hear:1500},
'@ @'
barrelBlast:{r:120,hear:1500}, barrelChain:{r:110,hear:1500}, barrelShock:{r:110,hear:1400}, barrelAcid:{r:80,hear:1100}, barrelCryo:{r:70,hear:1100},
'@

SubRx @'
var VER='31.05';
'@ @'
var VER='31.06';
'@

$pat = "(?m)^  now:'v31\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.06: Three new barrels join the red one: shock, toxic waste and dry ice. Each blast does its own thing, and a frozen crawler shatters. Check 31.06 fails on v31.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
