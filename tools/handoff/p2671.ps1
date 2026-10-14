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

# AIR STRIKE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
      if(!G.over){ updateEnts(dt); }
'@ @'
      if(!G.over){ try{ flowTick(dt); }catch(_flt){} updateEnts(dt); }   // v26.xx (flow2): the raid flow (the air strike meter and call) reads the bodies before they are cleared
'@

SubRx @'
  try{ drawThrowMarker(ctx,p); }catch(_dtm){}   // v26.xx (feel17): the arc and the landing ring of the throwable in your hand
'@ @'
  try{ drawThrowMarker(ctx,p); }catch(_dtm){}   // v26.xx (feel17): the arc and the landing ring of the throwable in your hand
  try{ flowDraw(ctx,p); }catch(_fdw){}   // v26.xx (flow2): the raid flow on the HUD (the air strike aim, the strikes in flight and the meter)
'@

SubRx @'
  if(code==='KeyQ'&&G&&!G.over&&!G.paused&&!repeat) wheelOpen();   // v26.xx (wheel2): HOLD Q opens the item wheel
'@ @'
  if(code==='KeyQ'&&G&&!G.over&&!G.paused&&!repeat) wheelOpen();   // v26.xx (wheel2): HOLD Q opens the item wheel
  if(code==='KeyG'&&G&&!G.over&&!G.paused&&!repeat){ try{ airKey(); }catch(_ak){} }   // v26.xx (flow2): G aims the air strike once the meter is full (LMB calls it, G again cancels)
'@

SubRx @'
['KeyH','heal (tap), armour plate (hold)'],
'@ @'
['KeyH','heal (tap), armour plate (hold)'],['KeyG','air strike (when charged)'],
'@

SubRx @'
['FIGHT',['KeyR','KeyQ','KeyV','KeyF','KeyH']]
'@ @'
['FIGHT',['KeyR','KeyQ','KeyV','KeyF','KeyH','KeyG']]
'@

SubRx @'
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@ @'
// v26.xx (flow2), HIS YES (2026-10-14) to suggestion 5: "no codes but a air strike would be cool, it should be something you have to build up by
// doing so much damage". THE AIR STRIKE. A METER fills from the damage YOU deal: every frame (before the bodies are cleared, so a killing blow
// is seen) the tick reads each hostile body's health, and a drop while the body carries your hit mark (pHitT, which every round, charge,
// strike of the crowbar and shock of yours sets for a third of a second) is damage dealt, never more than the health it had. AIR.need (1,500)
// fills it; the callout says AIR STRIKE READY, PRESS G. G aims it: the gun goes quiet (the trigger yields, as with the wheel), a dashed red
// ring follows the cursor out to AIR.reach (1,100) from you, LMB calls it on that spot, G or opening the map, backpack or wheel cancels. AIR STRIKE
// INBOUND, then 1.5 s later six blasts (AIR.R 105 wide each, one every 0.2 s) walk over the ring (150 across): each deals up to 212 to every
// hostile machine and every hostile pillager in reach, wakes the survivors toward you and credits you the kills. IT NEVER HURTS ALLIES: it
// never calls damagePlayer, never reaches a teammate, your hire, a friendly pillager or a peaceful bystander, the Peddler or the Survivor. The
// strike's own damage never refills the meter. The meter starts empty each raid and is spent by the call. DEMO and CAREER are the same. The
// blasts are placed with Math.random like the wave director and nothing draws from the seeded stream.
var AIR={need:1500,R:105,dmg:170,delay:1.5,n:6,gap:0.2,spread:150,reach:1100,aimMin:0.15};
function airS(){ var S=flowS(); if(!S.air) S.air={m:0,aim:0,aimT:0,prev:0,sk:[],used:0,dealt:0,rdy:0}; return S.air; }
function airReady(){ return airS().m>=AIR.need; }
function airSide(e){ return !!e&&!e.neutral&&e.kind!=='peddler'&&e.kind!=='stray'&&!e.merc&&!e.friendlyPC&&!e.friendly&&!e.hire&&!(e.kind==='raider'&&!e.hostile); }
function airFoe(e){ return airSide(e)&&e.hp>0&&!e.finished; }
function airClamp(x,y){
  var p=G.player, d=Math.hypot(x-p.x,y-p.y), k=(d>AIR.reach)?AIR.reach/d:1;
  return {x:clamp(p.x+(x-p.x)*k,20,WORLD_W-20),y:clamp(p.y+(y-p.y)*k,20,WORLD_H-20)};
}
function airScan(){
  var A=airS(), i, e, h, drop;
  for(i=0;i<G.ents.length;i++){
    e=G.ents[i]; if(!e) continue;
    h=(+e.hp>0)?+e.hp:0;
    if(typeof e.airH==='number'&&h<e.airH&&(+e.pHitT||0)>0&&airSide(e)){
      drop=e.airH-h; A.dealt+=drop;
      if(A.m<AIR.need){ A.m=Math.min(AIR.need,A.m+drop); if(A.m>=AIR.need&&!A.rdy){ A.rdy=1; say('AIR STRIKE READY','ext',{sub:'PRESS G'}); } }
    }
    e.airH=h;
  }
}
function airKey(){
  var A=airS(), p=G&&G.player;
  if(!flowOn()||G.paused||!p||p.downed||p.dying||p.specOut) return false;
  if(A.aim){ A.aim=0; return true; }
  if(!airReady()){ say('AIR STRIKE '+Math.floor(100*A.m/AIR.need)+'%','info',{sub:'DEAL DAMAGE TO CHARGE'}); return false; }
  if(G.wheel||p.cooking||G.bagOpen||G.mapOpen) return false;
  if(p.hand) handCancel(p);
  A.aim=1; A.aimT=0; A.prev=!!mouse.down;
  return true;
}
function airCall(x,y){
  var A=airS(), pts=[], i, a0=Math.random()*6.2832, a, r;
  for(i=0;i<AIR.n;i++){ a=a0+i*2.4; r=AIR.spread*Math.sqrt((i+0.5)/AIR.n); pts.push({x:x+Math.cos(a)*r,y:y+Math.sin(a)*r}); }
  A.m=0; A.aim=0; A.rdy=0; A.used=(A.used|0)+1;
  A.sk.push({x:x,y:y,t:0,n:0,pts:pts});
  say('AIR STRIKE INBOUND','warn');
  return true;
}
function airBlast(st,i){
  var q=st.pts[i], p=G.player, R=AIR.R, j, e, de, dm;
  sfx('boom',q.x,q.y);
  spark(q.x,q.y,'#ffcf7a',26,320); flash(q.x,q.y,260,'#ffb267',.4);
  try{ boomFx(q.x,q.y,1.2,'frag'); }catch(_ab){}
  try{ gfxBlastScar(q.x,q.y,1,false); }catch(_as){}
  G.shake=Math.max(G.shake||0,Math.max(2,7-dist(p,q)/150));
  for(j=G.ents.length-1;j>=0;j--){
    e=G.ents[j];
    if(!airFoe(e)) continue;
    de=dist(e,q); if(de>=R+e.r) continue;
    dm=Math.round(AIR.dmg*(1-Math.max(0,de-e.r)/R)+AIR.dmg*0.25);
    if(typeof NET==='object'&&NET&&NET.on&&typeof netEntsPeer==='function'&&netEntsPeer()) netShotSend(e,dm,Math.atan2(e.y-q.y,e.x-q.x),null); else e.hp-=dm;
    e.airH=(e.hp>0)?e.hp:0; e.hitT=.2; e.pHitT=.3; e.pHitSeat=0;
    if(e.hp<=0){ e.byPlayer=true; e.bySeat=0; }
    else if(e.state!=='alarm'&&!e.downed){ e.state='chase'; e.alert=2.5; e.tx=p.x; e.ty=p.y; }
  }
}
function airTick(dt){
  var A=airS(), p=G.player, i, st, m, T;
  if(A.aim){
    if(G.over||G.paused||!p||p.downed||p.dying||p.specOut||G.wheel||G.bagOpen||G.mapOpen||p.cooking||!airReady()) A.aim=0;
    else {
      A.aimT+=dt; p.trigYield=1;
      if(mouse.down&&!A.prev&&A.aimT>=AIR.aimMin){ m=mouseWorld(); T=airClamp(m.x,m.y); airCall(T.x,T.y); }
      A.prev=!!mouse.down;
    }
  }
  for(i=A.sk.length-1;i>=0;i--){
    st=A.sk[i]; st.t+=dt;
    while(st.n<AIR.n&&st.t>=AIR.delay+st.n*AIR.gap){ airBlast(st,st.n); st.n++; }
    if(st.n>=AIR.n&&st.t>=AIR.delay+AIR.n*AIR.gap+0.6) A.sk.splice(i,1);
  }
}
function airDraw(c,p){
  var A=G.flow&&G.flow.air, z, q, s, m, T, i, j, st, tf, dd, pt, pulse, bw, bh, x, y, c0, fl, rdy, R, t=G.t||0, ar, bx, bwid, by, hd;
  if(!A) return;
  z=Math.max(1,hudRes()); q=ZOOM(); R=AIR.R*q; ar=AIR.spread*q+R*0.4;
  c.save();
  if(A.aim){
    m=mouseWorld(); T=airClamp(m.x,m.y); s=w2s(T.x,0,T.y); pulse=0.5+0.5*Math.sin(t*9);
    c.fillStyle='rgba(255,98,66,'+(0.05+0.04*pulse).toFixed(3)+')'; c.beginPath(); c.arc(s.x,s.y,ar,0,6.2832); c.fill();
    c.setLineDash([12*z,9*z]); c.strokeStyle='rgba(255,98,66,'+(0.75+0.25*pulse).toFixed(3)+')'; c.lineWidth=2.4*z;
    c.beginPath(); c.arc(s.x,s.y,ar,0,6.2832); c.stroke(); c.setLineDash([]);
    c.lineWidth=2*z; c.beginPath(); c.moveTo(s.x-22*z,s.y); c.lineTo(s.x-8*z,s.y); c.moveTo(s.x+8*z,s.y); c.lineTo(s.x+22*z,s.y);
    c.moveTo(s.x,s.y-22*z); c.lineTo(s.x,s.y-8*z); c.moveTo(s.x,s.y+8*z); c.lineTo(s.x,s.y+22*z); c.stroke();
    c.textAlign='center'; c.font=hudFS(TYPE.head); c.fillStyle='#ffd0c0'; hudText('AIR STRIKE',s.x,s.y-ar-LH(24));
    c.font=hudFS(TYPE.micro); c.fillStyle=UIC.tx_2; hudText((padOn()?pbn(7):'LMB')+' CALL     G CANCEL',s.x,s.y-ar-LH(8));
  }
  for(i=0;i<A.sk.length;i++){
    st=A.sk[i]; s=w2s(st.x,0,st.y);
    c.strokeStyle='rgba(255,98,66,.45)'; c.lineWidth=1.6*z; c.beginPath(); c.arc(s.x,s.y,ar,0,6.2832); c.stroke();
    for(j=0;j<st.pts.length;j++){
      pt=w2s(st.pts[j].x,0,st.pts[j].y); tf=AIR.delay+j*AIR.gap; dd=st.t-tf;
      if(dd<0){
        c.strokeStyle='rgba(255,170,90,'+(0.55+0.3*Math.sin(t*14+j)).toFixed(3)+')'; c.lineWidth=2*z;
        c.beginPath(); c.arc(pt.x,pt.y,R*(0.45+0.55*Math.min(1,-dd/0.8)),0,6.2832); c.stroke();
        if(dd>-0.28){
          hd=pt.y-(-dd/0.28)*H*0.6; c.strokeStyle='rgba(255,236,190,'+(0.9*(1+dd/0.28)).toFixed(3)+')'; c.lineWidth=3*z;
          c.beginPath(); c.moveTo(pt.x,hd-90*z); c.lineTo(pt.x,hd); c.stroke();
        }
      } else if(dd<0.35){
        c.fillStyle='rgba(255,214,150,'+(0.5*(1-dd/0.35)).toFixed(3)+')'; c.beginPath(); c.arc(pt.x,pt.y,R*(0.6+0.5*dd/0.35),0,6.2832); c.fill();
      }
    }
  }
  if(A.m>0||A.aim||A.sk.length){
    c0=(G.hotCells&&G.hotCells[0])?G.hotCells[0].y:H-LH(130);
    bw=LH(200); bh=LH(28); x=Math.round(W/2+LH(16)); y=Math.round(c0-LH(112));
    rdy=A.m>=AIR.need; fl=clamp(A.m/AIR.need,0,1);
    hudPlate(x,y,bw,bh,rdy?UIC.acc:null,HUDC.plate);
    c.textAlign='left'; c.font=hudFS(TYPE.micro); c.fillStyle=rdy?UIC.acc:UIC.tx_2; hudText('AIR STRIKE',x+LH(12),y+Math.round(bh*0.64));
    bx=x+LH(96); bwid=bw-LH(96)-LH(48); by=Math.round(y+bh*0.5-LH(3));
    c.fillStyle='rgba(255,255,255,.12)'; c.fillRect(bx,by,bwid,LH(6));
    c.fillStyle=rdy?('rgba(255,192,74,'+(0.75+0.25*Math.sin(t*8)).toFixed(3)+')'):'#ff8a3c'; c.fillRect(bx,by,bwid*fl,LH(6));
    if(rdy) hudKey('G',x+bw-LH(46),y+Math.round(bh*0.7),LH(8),LH(32));
    else { c.textAlign='right'; c.fillStyle=UIC.tx_1; hudText(Math.floor(fl*100)+'%',x+bw-LH(10),y+Math.round(bh*0.64)); }
  }
  c.restore();
}
function flowTick(dt){
  if(!flowOn()) return;
  dt=(dt>0)?Math.min(dt,0.25):0;
  airScan(); airTick(dt);
  // FLOW-TICKS (the next flow builds add their ticks above this line)
}
function flowDraw(c,p){
  if(!flowOn()) return;
  airDraw(c,p);
  // FLOW-DRAWS (the next flow builds add their draws above this line)
}
// FLOW-MODULE-END (the next flow builds add their code above this line)
'@

SubRx @'
var VER='26.70';
'@ @'
var VER='26.71';
'@

$pat = "(?m)^  now:'v26\.70:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.71: Dealing damage charges an air strike: press G when it is full, click a spot, and six blasts hit the hostiles there. Check 26.71 fails on v26.70',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
