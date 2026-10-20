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

# PLAYERS IN ACTION: BOUNCY WALK, HIT FLASH, LOW HEALTH, KNEELING DOWNED, FALL TO LIGHT, AIM LINE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawOp0(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@ @'
// v32.xx (cw-playerstates), HIS PICKS a11 B, a12 B, a13 D, a14 B, a15 B (art survey, 2026-10-19). drawOp is a wrapper now and the old body is drawOp0:
// the bouncy squash and stretch (a11), the whole-body white flash then red with a recoil (a12), the red outline pulse and the drips at low health (a13),
// the kneeling downed body with a pulsing red ring and its gun on the floor (a14), and the fall that turns to light (a15) are all done around it.
// Cosmetic only: no random draw, nothing the sim reads. Dead and flash passes run only for the moments they show.
var OPX={ng:0,inScr:0,scr:null,sx:null};
function opGround(x,y,st){
  shadowE(x+1.5,y+2,12.5,5,0.5); shadowE(x+7,y+3,8,3,0.28);   // the shadow cw-figlook made, drawn here so the squash and the fall leave it standing
  var _SE=seatMarkOf(st);   // -1 when no party is on, else this body seat
  if(_SE>=0) drawSeatRing(x,y,_SE);
}
function opEase(k){ return k<=0?0:(k>=1?1:1-(1-k)*(1-k)); }
function opIsPlayer(st){ var o=st&&st.own; return !!(st&&(st.hero||(o&&typeof o.seat==='number'&&!o.kind))); }
function opLow(st){ var o=st&&st.own; return !!(o&&opIsPlayer(st)&&!o.downed&&!o.dn&&o.hp>0&&o.hp<32); }
function opInkPulse(){ var k=0.5+0.5*Math.sin(((G&&G.t)||0)*hpFlashRate()); return 'rgb('+Math.round(18+k*206)+','+Math.round(14+k*22)+','+Math.round(12+k*14)+')'; }
function opHitAge(st){ if(!(st.hurt>0)) return 9; return (typeof st.hurtAge==='number')?st.hurtAge:Math.max(0,0.45-st.hurt); }
function opCopy(st){ var s2={}, q; for(q in st) s2[q]=st[q]; s2.moving=false; s2.sprint=false; s2.ads=false; s2.hurt=0; s2.low=0; return s2; }
function opGroundGun(x,y,fl,w){
  var id, fk, el, wt, rc, S=2, B;
  try{
    if(!w||!w.id||w.id==='fists'||!GUNDEF[w.id]) return;
    id=w.id; fk=(w.fk===1||w.fk===2)?w.fk:0; el=(fk===2&&w.el&&ELEM[w.el])?w.el:'';
    wt=gunTier(w); rc=(w.q==='gold')?'#ffc72e':(wt>=5?RCOL.gold:(wt>=4?RCOL.elite:(wt===3?RCOL.rare:(wt===2?RCOL.uncommon:RCOL.common))));
    try{ S=Math.min(6,Math.ceil((wallSpriteScale()+1)*GUNK)); }catch(_s){ S=2; }
    B=gunBake(id,fk,el,rc,S);
    shadowE(x+fl*17,y+1,9,2.5,.30);
    wc.save(); wc.translate(x+fl*17,y-2); wc.rotate(fl*0.10); wc.scale(fl*GUNK,GUNK*0.85);
    wc.drawImage(B.c,B.x0-(GUNDEF[id].tip||16)*0.5,B.y0,B.w,B.h);
    wc.restore();
  }catch(_g){}
}
function opKneel(x,y,face,coat,pk,iv,st,fl){
  var o=st.own, k=0.5+0.5*Math.sin(((G&&G.t)||0)*7.5398), s2=opCopy(st);   // 1.2 Hz
  opGround(x,y,st);
  wc.save();
  wc.strokeStyle='#ff4a3a'; wc.globalAlpha=wc.globalAlpha*(0.4+0.5*k); wc.lineWidth=2;
  wc.beginPath(); wc.ellipse(x,y+1,18,7,0,0,6.2832); wc.stroke();
  wc.restore();
  opGroundGun(x,y,fl,o.wep);
  wc.save(); wc.translate(x,y-9); wc.rotate(fl*0.3); wc.translate(-x,-y+10.5);   // head dropped: the body bows forward about the hips
  OPX.ng=1;
  try{ drawOpB(x,y,face,0,coat,pk,0,'crouchnone',iv,s2); }
  finally{ OPX.ng=0; wc.restore(); }
}
function opDeath(x,y,face,coat,pk,iv,st,fl){
  var o=st.own, t=(G&&typeof G.deathBeat==='number')?Math.max(0,1.5-G.deathBeat):9, sg=o.hitDX||-fl, k, u, i, px, py, s2, _S, col, a0;
  if(t>=0.9) return;
  k=Math.min(1,t/0.22); u=(t<0.4)?1:1-(t-0.4)/0.5; a0=wc.globalAlpha;
  wc.save(); wc.globalAlpha=a0*u;
  opGround(x,y,st);
  s2=opCopy(st);
  wc.translate(0,6*k*k); wc.translate(x,y); wc.rotate(sg*1.5708*k*k); wc.translate(-x,-y);
  OPX.ng=1;
  try{ drawOpB(x,y,face,0,coat,pk,0,'none',iv,s2); }
  finally{ OPX.ng=0; wc.restore(); }
  if(t>=0.4){
    u=Math.min(1,(t-0.4)/0.5); _S=seatMarkOf(st); col=(_S>=0)?SEATCOL[_S&3]:'#ffb02e';
    wc.save(); wc.globalCompositeOperation='lighter'; wc.fillStyle=col; wc.globalAlpha=a0*(1-u);
    for(i=0;i<14;i++){ px=x+Math.sin(i*12.9898)*5+Math.cos(i*4.1)*6*u; py=y-7-(i%3)*2-22*u; wc.fillRect(px-1,py-1,2,2); }
    wc.restore();
  }
}
function opLowDrops(x,y,fl){
  var t=(G&&G.t)||0, n=Math.floor(t/0.9), j, age, fy, h, a0=wc.globalAlpha;
  wc.save(); wc.fillStyle='#a8261c';
  for(j=0;j<2;j++){
    age=t-(n-j)*0.9; if(age<0||age>=1) continue;
    fy=(y-17)+Math.min(1,age/0.35)*17; wc.globalAlpha=a0*0.9*(1-age);
    for(h=0;h<2;h++) wc.fillRect(x+fl*(h?10:4)-1.5,fy-1.5,3,3);
  }
  wc.restore();
}
function opWash(x,y,face,ph,coat,pk,muzzle,mode,iv,st,age){
  var m, dx, dy, w, h, c2, W0=wc, a;
  if(!wc.getTransform) return;
  m=wc.getTransform(); if(Math.abs(m.b)>1e-6||Math.abs(m.c)>1e-6||!(m.a>0)||!(m.d>0)) return;
  w=Math.ceil(80*m.a)+2; h=Math.ceil(90*m.d)+2; if(w>1400||h>1400) return;
  if(!OPX.scr){ OPX.scr=document.createElement('canvas'); OPX.sx=OPX.scr.getContext('2d'); }
  if(OPX.scr.width<w) OPX.scr.width=w;
  if(OPX.scr.height<h) OPX.scr.height=h;
  c2=OPX.sx; c2.setTransform(1,0,0,1,0,0); c2.globalCompositeOperation='source-over'; c2.globalAlpha=1; c2.clearRect(0,0,w,h);
  dx=Math.floor(m.a*(x-40)+m.e); dy=Math.floor(m.d*(y-70)+m.f);
  c2.setTransform(m.a,0,0,m.d,m.e-dx,m.f-dy);
  OPX.inScr=1; OPX.ng=1; wc=c2;
  try{ drawOpB(x,y,face,ph,coat,pk,muzzle,mode,iv,st); }
  finally{ wc=W0; OPX.inScr=0; OPX.ng=0; }
  c2.setTransform(1,0,0,1,0,0); c2.globalCompositeOperation='source-atop';
  if(age<0.066) c2.fillStyle='rgba(255,255,255,.9)';
  else { a=0.55*Math.max(0,1-(age-0.066)/0.234); c2.fillStyle='rgba(255,60,48,'+a.toFixed(3)+')'; }
  c2.fillRect(0,0,w,h); c2.globalCompositeOperation='source-over';
  W0.save(); W0.setTransform(1,0,0,1,0,0); W0.drawImage(OPX.scr,0,0,w,h,dx,dy,w,h); W0.restore();
}
function drawOp0(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
  var o, fl, age, ink0, rx=0, sx=1, sy=1, k, low, hurt, rec;
  if(OPX.inScr||!st||mode==='roll') return drawOpB(x,y,face,ph,coat,pk,muzzle,mode,iv,st);
  o=st.own; fl=Math.cos(face)<0?-1:1;
  if(mode==='down'){
    if(o&&opIsPlayer(st)){
      if(o.downed||o.dn){ opKneel(x,y,face,coat,pk,iv,st,fl); return; }
      if(st.hero&&o.hp<=0){ opDeath(x,y,face,coat,pk,iv,st,fl); return; }
    }
    return drawOpB(x,y,face,ph,coat,pk,muzzle,mode,iv,st);
  }
  low=opLow(st);
  if(low){ st.low=1; ph*=0.7; }   // v32.xx (cw-playerstates): a13, the walk slowed 30 percent
  age=opHitAge(st); hurt=age<0.3;
  opGround(x,y,st);
  if(hurt&&o&&o.hitDX){ rec=(age<0.08)?2.5*opEase(age/0.08):((age<0.22)?2.5*(1-(age-0.08)/0.14):0); rx=o.hitDX*rec; }
  if(st.moving){ k=Math.min(1,Math.abs(Math.sin(ph))/0.6); k=k*k*(3-2*k); sy=0.94+0.09*k; sx=1.04-0.06*k; }   // a11: down on the footfall, tall at the top of the step
  wc.save();
  if(rx||sx!==1||sy!==1){ wc.translate(x+rx,y); wc.scale(sx,sy); wc.translate(-x,-y); }
  ink0=INK; if(low) INK=opInkPulse();
  OPX.ng=1;
  try{
    drawOpB(x,y,face,ph,coat,pk,muzzle,mode,iv,st);
    if(hurt) opWash(x,y,face,ph,coat,pk,muzzle,mode,iv,st,age);
  }
  finally{ OPX.ng=0; INK=ink0; wc.restore(); }
  if(low) opLowDrops(x,y,fl);
}
// v32.xx (cw-playerstates), HIS PICK a16 B and his note ("the better/rarer version of each gun can also have the red laser"): a faint dotted line from the
// gun to 40 px short of the crosshair, always on while a gun is held; the two highest rarity tiers (4 elite and 5 gold, the same table gunHeld colours by)
// and the golden gun show the red laser while the sights are held, and the dots hide while it shows.
function gunTier(w){ return (w&&WTIER[w.id]!==undefined)?WTIER[w.id]+((typeof RV_BASE!=='undefined'&&RV_BASE[w.id])?1:0):1; }
function gunLaserOk(w){ return !!(w&&w.id&&w.id!=='fists'&&(w.q==='gold'||gunTier(w)>=4)); }
function aimRay(mx,my,dx,dy,maxT){
  var t=maxT, i, e, vx, vy, pr, pp;
  try{ t=rayHitG(mx,my,dx,dy,maxT); }catch(_r){ t=maxT; }
  if(G&&G.ents) for(i=0;i<G.ents.length;i++){
    e=G.ents[i]; if(!e||e.dead||!(e.hp>0)||e.friendly||e.merc||e.kind==='stray'||e.kind==='peddler') continue;
    vx=e.x-mx; vy=(e.y-12)-my; pr=vx*dx+vy*dy; if(pr<=0||pr>=t) continue;
    pp=Math.abs(vx*dy-vy*dx); if(pp<(e.r||10)) t=pr;
  }
  return t;
}
function drawAimMark(sh,wep,ang,dist,ads,bld){
  var D=GUNDEF[wep.id]||GUNDEF.rifle, sg=(Math.cos(ang)<0)?-1:1, L=(D.tip+(D.pist?2:0))*GUNK, by=D.by*GUNK*sg, c=Math.cos(ang), s=Math.sin(ang),
      fs=(typeof FIG_SCALE==='number'&&bld!==null)?FIG_SCALE:1, fk=(fs===1)?[1,1]:figBuildK(bld||'lean'),
      mx=sh.x+(c*L-s*by)*fs*fk[0], my=sh.y+(-20+s*L+c*by)*fs*fk[1], len, n, i, t;   // the gun scales with the figure about its feet (cw-figlook)
  if(ads&&gunLaserOk(wep)){
    t=aimRay(mx,my,c,s,900);
    wc.save(); wc.strokeStyle='rgba(255,74,58,.55)'; wc.lineWidth=1.5; wc.beginPath(); wc.moveTo(mx,my); wc.lineTo(mx+c*t,my+s*t); wc.stroke();
    wc.fillStyle='rgba(255,74,58,.9)'; wc.beginPath(); wc.arc(mx+c*t,my+s*t,1.5,0,6.2832); wc.fill(); wc.restore();
    return 2;
  }
  len=dist-40-L; if(!(len>8)) return 0;
  n=Math.min(60,Math.floor(len/8));
  wc.save(); wc.fillStyle='rgba(255,255,255,.22)'; wc.beginPath();
  for(i=1;i<=n;i++) wc.rect(mx+c*i*8-1,my+s*i*8-1,2,2);
  wc.fill(); wc.restore();
  return 1;
}
function aimMarks(p){
  var w=p.wep, mw, d, M, i, g, n=0;
  if(w&&w.id&&w.id!=='fists'&&p.hp>0&&!p.downed&&!(G.deathBeat>0)&&!(p.roll>0)&&!(G.handsT>0)&&!p.hand&&!(G.punchT>0)){
    mw=mouseWorld(); d=Math.hypot(mw.x-p.x,mw.y-p.y);
    if(drawAimMark(p,w,p.face,d,!!p.ads,cosWorn('build'))) n++;
  }
  if(NET.on&&NET.up) for(i=0;i<NET.up.length;i++){
    g=NET.up[i]; if(!netUpShown(g)||g.dn||g.hd||g.roll>0||!g.wep||g.wep.id==='fists') continue;
    if(drawAimMark(g,g.wep,g.f,200,false,g.lk&&g.lk.build)) n++;
  }
  return n;
}
function drawOpB(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
'@

SubRx @'
  shadowE(x+1.5,y+2,12.5,5,.5);   // v32.64 (cw-figlook), a09 B: a bigger, darker shadow
  shadowE(x+7,y+3,8,3,.28);
  var _SEAT=seatMarkOf(st);   // v28.09 (cosm2): -1 when no party is on, else this body seat
  if(_SEAT>=0) drawSeatRing(x,y,_SEAT);
'@ @'
  if(!OPX.ng) opGround(x,y,st);   // v32.xx (cw-playerstates): the wrapper draws the ground first and the body squashes without it
'@

SubRx @'
  var amp=moving?(sprint?4.2:2.9):0;
'@ @'
  var amp=moving?(sprint?5.0:3.4):0;   // v32.xx (cw-playerstates), HIS PICK a11 B: a bouncy walk and sprint (leg swing 3.4 and 5.0, was 2.9 and 4.2)
'@

SubRx @'
  var bobY=moving?Math.abs(Math.sin(ph))*1.5:Math.sin(ph*.35)*.5;
'@ @'
  var bobY=moving?Math.abs(Math.sin(ph))*(sprint?3.6:2.6):Math.sin(ph*.35)*.5;   // v32.xx (cw-playerstates), a11 B: bob 2.6 walking and 3.6 sprinting, was 1.5
'@

SubRx @'
  var leanX=sprint?fl*1.6:(moving?fl*.7:0);
  var ty=y-bobY+lift;
'@ @'
  var leanX=sprint?fl*2.8:(moving?fl*1.2:0);   // v32.xx (cw-playerstates), a11 B: lean 1.2 walking and 2.8 sprinting, was 0.7 and 1.6
  var ty=y-bobY+lift+(st.low?1.5:0);   // a13 D: the shoulders drop 1.5 px at low health
'@

SubRx @'
  if(st.hurt>0){
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,70,56,'
'@ @'
  if(st.low){   // v32.xx (cw-playerstates), HIS PICK a13 D: two dark red stains on the chest and the gun arm at low health
    wc.fillStyle='rgba(138,28,20,.8)'; wc.fillRect(x+leanX-fl*2.5-1.5,ty-19,3,3); wc.fillRect(x+leanX+fl*3.5-2,ty-16,4,3);
  }
  if(st.hurt>0&&0){   // v32.xx (cw-playerstates), HIS PICK a12 B: the red chest glow is replaced by the white flash then red over the whole body (opWash)
    wc.globalCompositeOperation='lighter';
    wc.fillStyle='rgba(255,70,56,'
'@

SubRx @'
  p.hitFlash=Math.max(p.hitFlash||0,.20+.30*_sev);
'@ @'
  p.hitFlash=Math.max(p.hitFlash||0,.20+.30*_sev);
  p.hitAge=0; p.hitDX=(typeof sx==='number'&&isFinite(sx))?((p.x>=sx)?1:-1):0;   // v32.xx (cw-playerstates), a12 B: the white flash is timed from the hit and the recoil goes away from the shot
'@

SubRx @'
  if(p.hitFlash>0) p.hitFlash-=dt;
'@ @'
  if(p.hitFlash>0){ p.hitFlash-=dt; p.hitAge=(p.hitAge||0)+dt; }
'@

SubRx @'
hurt:p.hitFlash,bulk:armorById(p.rig).bulk,
'@ @'
hurt:p.hitFlash,hurtAge:p.hitAge,bulk:armorById(p.rig).bulk,
'@

SubRx @'
    drawOp(g.x,g.y,g.f,(g.roll>0)?(1-g.roll/0.38)*12.6:g.bob,fit[1],0,0,mode,0,
      {hero:0,own:g,team:(NET.mode==='pvp')?'foe':'ally',moving:!!g.mv,sprint:!!g.sp,ads:false,hurt:0,rl:0,bulk:0,
'@ @'
    var _hg=0, _ha=9;   // v32.xx (cw-playerstates), a12 B: a teammate whose health drops flashes too (his window says the health, not the hit)
    if(typeof g._hpSeen==='number'&&g.hp<g._hpSeen-0.5) g._hitAt=G.t;
    g._hpSeen=g.hp;
    if(typeof g._hitAt==='number'){ _ha=G.t-g._hitAt; if(_ha>=0&&_ha<0.4) _hg=0.4-_ha; else _ha=9; }
    drawOp(g.x,g.y,g.f,(g.roll>0)?(1-g.roll/0.38)*12.6:g.bob,fit[1],0,0,mode,0,
      {hero:0,own:g,team:(NET.mode==='pvp')?'foe':'ally',moving:!!g.mv,sprint:!!g.sp,ads:false,hurt:_hg,hurtAge:_ha,rl:0,bulk:0,
'@

SubRx @'
  var crouchP=crouchHeld();
'@ @'
  try{ if(!G.sim) aimMarks(p); }catch(_am){}   // v32.xx (cw-playerstates), HIS PICK a16 B: the dotted aim line and the rare gun laser, under the bodies
  var crouchP=crouchHeld();
'@

SubRx @'
var VER='32.64';
'@ @'
var VER='32.65';
'@

$pat = "(?m)^  now:'v32\.64:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.65: Bodies bounce, flash white then red when hit, show blood and a red outline at low health, kneel when downed, fall into light when dead, and every gun shows a dotted aim line (rare guns a red laser while aiming). Check 32.65 fails on v32.64',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
