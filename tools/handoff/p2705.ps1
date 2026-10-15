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

# RED EXPLOSIVE BARRELS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function explodeFrag(f){
'@ @'
// v27.xx (barrels), HIS ANSWER 30 (2026-10-13): "although I haven't seen any explosive barrels -- maybe make thme red with an exclamation mark
// on them?". EXPLOSIVE BARRELS, FOR REAL THIS TIME: the barrel drafts of 2026-10-12 never reached the game, so there was nothing to see. Every
// live raid (DEMO and CAREER alike, his rule that the gameplay is identical) gets clusters of one to three RED barrels with a big WHITE !, set
// out on open, reachable floor by brlPlace on their own side stream (BRL_TAG), so the seeded stream, the ents and the containers are exactly
// what they were (seed 4242: ents 85/374, containers 165/593), and the bot raid has none. Any round that reaches a barrel stops in it
// (brlShot); BRL_HP of damage lights it, and a lit barrel flickers for a moment and goes up (brlTick, brlBlast). The blast hurts everyone
// near it in line of sight (the player, machines, pillagers) and the walls as a charge does, and it lights every barrel inside its reach after
// a short beat, so a cluster goes up as a CHAIN. A charge lights them too. Kills go to the player whose round or charge lit it (by), none for
// an enemy round. His rule of no team damage holds: a barrel a player lit never hurts another player of the party. Cosmetic draws use no stream.
var BRL_TAG=47, BRL_CL=14, BRL_HP=30, BRL_R=170, BRL_HIT=13;
function brlMe(){ return (typeof NET==='object'&&NET&&NET.on&&NET.role==='join')?Math.max(1,NET.seat|0):0; }
function brlOk(g,x,y){
  var i, m=g.map, p=g.player;
  if(!(x>80&&y>80&&x<WORLD_W-80&&y<WORLD_H-80)) return false;
  if(!spotFree(m,x,y,30)||shutRoomAt(m,x,y)||!navReachable(m,x,y)) return false;
  if(p&&Math.hypot(x-p.x,y-p.y)<460) return false;
  for(i=0;i<(m.extracts||[]).length;i++) if(Math.hypot(x-m.extracts[i].x,y-m.extracts[i].y)<240) return false;
  for(i=0;i<g.containers.length;i++) if(Math.hypot(x-g.containers[i].x,y-g.containers[i].y)<40) return false;
  for(i=0;i<g.brl.length;i++) if(Math.hypot(x-g.brl[i].x,y-g.brl[i].y)<24) return false;
  try{ if(inWaterMap(m,x,y)) return false; }catch(_w){}
  return true;
}
function brlPlace(g){
  g.brl=[];
  if(!g||g.sim||!g.map||!Array.isArray(g.containers)) return;
  sideStream(g.seed,BRL_TAG,function(){
    var c, t, s, q, k, j, a, d, x, y;
    for(c=0;c<BRL_CL;c++){
      s=null;
      for(t=0;t<60&&!s;t++){ q=freeSpot(g.map,34); if(brlOk(g,q.x,q.y)) s=q; }
      if(!s) continue;
      g.brl.push({id:g.brl.length,x:s.x,y:s.y,hp:BRL_HP,fuse:-1,by:-1,gone:0});
      k=Math.floor(rr()*3);
      for(j=0;j<k;j++){
        for(t=0;t<12;t++){
          a=rr()*6.2832; d=26+rr()*16; x=s.x+Math.cos(a)*d; y=s.y+Math.sin(a)*d;
          if(brlOk(g,x,y)){ g.brl.push({id:g.brl.length,x:x,y:y,hp:BRL_HP,fuse:-1,by:-1,gone:0}); break; }
        }
      }
    }
  });
}
function brlLight(B,by,fuse){
  if(!B||B.gone||B.fuse>=0) return false;
  B.fuse=fuse; B.by=by;
  return true;
}
function brlShot(b){
  var i, B, L=G.brl;
  for(i=0;i<L.length;i++){
    B=L[i]; if(B.gone) continue;
    if(Math.abs(b.x-B.x)>BRL_HIT||Math.abs(b.y-(B.y-10))>BRL_HIT+4) continue;
    B.hp-=(+b.dmg||0);
    if(!G.sim){ spark(b.x,b.y,'#ffb070',8,180); sfx('clank',b.x,b.y,'metal'); }
    if(B.hp<=0) brlLight(B,b.player?brlMe():-1,0.06);
    return true;
  }
  return false;
}
function brlNear(x,y,R,by){
  var i, B, d;
  for(i=0;i<(G.brl||[]).length;i++){
    B=G.brl[i]; if(B.gone||B.fuse>=0) continue;
    d=Math.hypot(B.x-x,B.y-y);
    if(d<R) brlLight(B,by,0.12+0.22*d/R);
  }
}
function brlTick(dt){
  var i, B;
  if(!G||!G.brl||!G.brl.length) return;
  for(i=0;i<G.brl.length;i++){
    B=G.brl[i]; if(B.gone||B.fuse<0) continue;
    B.fuse-=dt;
    if(B.fuse<=0) brlBlast(B);
  }
}
function brlBlast(B){
  var p=G.player, R=BRL_R, x, y, s, me=brlMe(), i, e, de, dm, sd, bp, peer=netEntsPeer(), W, w, cx, cy, dd;
  if(!B||B.gone) return;
  x=B.x; y=B.y; s=B.by; bp={x:x,y:y};
  B.gone=1; B.fuse=-1;
  sd=Math.hypot(x-p.x,y-p.y);
  try{ if(sd<R*1.8) padRumble(Math.max(0.3,1-sd/(R*1.8)),240); }catch(_rb){}
  sfx('boom',x,y);
  if(!G.sim){
    spark(x,y,'#ff8a3a',40,380); spark(x,y,'#fff0c0',14,220); decal(x,y,'#141210',fxn(26,36));
    G.puffs.push({x:x,y:y,t:0,life:.7,c:'#ff7a3a',r:64}); G.puffs.push({x:x,y:y-12,t:0,life:1.4,c:'#3a3430',r:56});
    try{ boomFx(x,y,1.2,'frag'); }catch(_bfx){}
    try{ gfxBlastScar(x,y,1,false); }catch(_gbs){}
  }
  G.shake=Math.max(G.shake,sd<300?10:(sd<800?5:2));
  flash(x,y,340,'#ff8a4a',.5);
  ping(x,y,600,false,false,'env','fire');
  // the player of this window: always for a barrel no player lit, and his own; never one a teammate lit (no team damage)
  if(!p.specOut&&!p.dying&&(s<0||s===me)&&sd<R&&losClear(x,y,p.x,p.y,G.map.segs))
    damagePlayer(70*(1-sd/R)+20,'barrel','EXPLOSIVE BARREL',x,y);
  brlNear(x,y,R,s);
  if(CFG.destruct!==0){
    W=G.map.walls.slice();
    for(i=W.length-1;i>=0;i--){
      w=W[i]; cx=clamp(x,w.x,w.x+w.w); cy=clamp(y,w.y,w.y+w.h); dd=Math.hypot(cx-x,cy-y);
      if(dd<R) damageWall(w,170*(1-dd/R)+30,cx,cy);
    }
  }
  if(peer) return;   // a linked window: the host runs the bodies
  for(i=G.ents.length-1;i>=0;i--){
    e=G.ents[i];
    if(!e||e.finished) continue;
    if(s>=0&&e.merc&&!e.downed) continue;   // a barrel a player lit spares his hire, as his charge does
    de=dist(e,bp);
    if(de<R+e.r&&losClear(x,y,e.x,e.y,G.map.segs)){
      dm=120*(1-Math.max(0,de-e.r)/R)+30;
      e.hp-=dm; e.hitT=.2;
      if(s===0) notoAggress(e); else if(s>0&&e.kind==='raider'&&e.hostile===false&&!e.friendlyPC) e.hostile=true;
      if(e.hp<=0){ e.byPlayer=(s===0); e.bySeat=(s>0)?s:0; }
      if(s>=0){ e.pHitT=.3; e.pHitSeat=s; e.blow='x'; e.blowT=G.t; }
      if(e.state!=='alarm'&&e.kind!=='peddler'&&e.kind!=='stray'&&!e.downed&&!e.merc){ e.state='chase'; e.alert=2.5; e.tx=(s===0)?p.x:x; e.ty=(s===0)?p.y:y; }
    }
  }
}
function brlDraw(B){
  var x=B.x, y=B.y, w=11, h=27, lit=(B.fuse>=0), t=(G&&G.t)||0, fl=lit&&(Math.floor(t*24)%2===0), pu=0.5+0.5*Math.sin(t*3.2+B.id);
  shadowE(x,y+1,14,4.5,.38);
  if(!lit){   // a slow red pulse on the ground, so the barrel is seen from across the lane
    wc.save(); wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,60,40,'+(0.10+0.10*pu).toFixed(3)+')'; wc.beginPath(); wc.ellipse(x,y-2,w+9+pu*3,(w+9+pu*3)*0.42,0,0,6.2832); wc.fill();
    wc.restore();
  }
  wc.fillStyle=INK; wc.fillRect(x-w-1,y-h-1,w*2+2,h+2);
  wc.fillStyle=fl?'#ff7a4a':'#c4281c'; wc.fillRect(x-w,y-h,w*2,h);
  wc.fillStyle='rgba(0,0,0,.30)'; wc.fillRect(x+w*0.35,y-h,w*0.65,h);
  wc.fillStyle='rgba(255,255,255,.16)'; wc.fillRect(x-w+2,y-h,3,h);
  wc.fillStyle='#5e120d'; wc.fillRect(x-w,y-h+4,w*2,2); wc.fillRect(x-w,y-4,w*2,2);
  wc.fillStyle=fl?'#ffc08a':'#d9483c'; wc.beginPath(); wc.ellipse(x,y-h,w,4.2,0,0,6.2832); wc.fill();
  wc.strokeStyle=INK; wc.lineWidth=1.2; wc.stroke();
  wc.fillStyle='#4a0e0a'; wc.beginPath(); wc.ellipse(x+4.5,y-h,2.2,1.2,0,0,6.2832); wc.fill();
  // the big white !: a bar and a dot, inked so it reads on a dark floor and in the red
  wc.fillStyle=INK; wc.fillRect(x-3.6,y-h+6,7.2,13); wc.beginPath(); wc.arc(x,y-5.4,3.6,0,6.2832); wc.fill();
  wc.fillStyle='#f6f3ec'; wc.fillRect(x-2.6,y-h+7,5.2,11); wc.beginPath(); wc.arc(x,y-5.4,2.6,0,6.2832); wc.fill();
  if(lit){
    wc.save(); wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,150,60,'+(fl?0.55:0.30)+')'; wc.beginPath(); wc.arc(x,y-h,10,0,6.2832); wc.fill();
    wc.restore();
  }
}
function explodeFrag(f){
'@

SubRx @'
try{ gunKeysSettle({deploy:1}); }catch(_gks){}
'@ @'
if(G&&!G.sim){ try{ brlPlace(G); }catch(_bpl){ G.brl=[]; } }   // v27.xx (barrels): the explosive barrels, on their own side stream
  try{ gunKeysSettle({deploy:1}); }catch(_gks){}
'@

SubRx @'
tickTrips(dt);   // v23.xx (feat1b)
'@ @'
brlTick(dt);   // v27.xx (barrels): the lit explosive barrels (nothing to do with none lit, and the bot raid has none)
  tickTrips(dt);   // v23.xx (feat1b)
'@

SubRx @'
        if(b.player){
          for(var e2=0;e2<G.ents.length;e2++){
'@ @'
        if(G.brl&&G.brl.length&&brlShot(b)){ hit=true; break; }   // v27.xx (barrels): a round that reaches an explosive barrel stops in it
        if(b.player){
          for(var e2=0;e2<G.ents.length;e2++){
'@

SubRx @'
ping(f.x,f.y,560,false,false,'env','fire');
'@ @'
ping(f.x,f.y,560,false,false,'env','fire');
  brlNear(f.x,f.y,R,f.by?-1:brlMe());   // v27.xx (barrels): a charge lights the explosive barrels it reaches
'@

SubRx @'
    DR.push({k:ct.y,c:ct});
  }
'@ @'
    DR.push({k:ct.y,c:ct});
  }
  for(i=0;i<(G.brl||[]).length;i++){   // v27.xx (barrels): the explosive barrels
    var _bz=G.brl[i];
    if(_bz.gone||_bz.x<ox-40||_bz.x>ox+VW+40||_bz.y<oy-60||_bz.y>oy+VH+60) continue;
    DR.push({k:_bz.y,fn:brlDraw.bind(null,_bz)});
  }
'@

SubRx @'
var VER='27.04';
'@ @'
var VER='27.05';
'@

$pat = "(?m)^  now:'v27\.04:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v27.05: Red barrels with a big white ! now sit around every raid: shoot one and it explodes, setting off the barrels beside it. Check 27.05 fails on v27.04',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
