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

# ELITE MACHINES CARRY AN AFFIX (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function feudFoe(a,b){
'@ @'
// v26.xx (ai25), HIS YES (2026-10-14, suggestion 25): "ok for elites, they should be a diff color or obviously different though".
// ELITE AFFIXES. An elite MACHINE (the 8 percent that already have 2.2 times the health) now carries one affix, chosen with no new draw
// (from where the elite roll fell inside its 8 percent, so every affix is as common as the others and the seeded stream is as it was):
//   SHIELDED (cyan): a shield worth half its health that soaks ROUNDS first; a blast, a mine or fire goes straight past it.
//   VOLATILE (orange): it explodes when it dies (130 units, up to 55 to you or to anything near it).
//   FAST (yellow): a third quicker on its feet.
//   MENDER (green): mends every machine within 260 of it by 5 percent every half second; kill it first.
// Each shows as its own colour, not the old purple elite ring: a glow and two rings on the ground, a badge over the head (a hexagon, a
// burst, a double chevron, a plus), the shield as a bubble that thins as it is shot, the mender's reach as a faint ring and a beam to
// each machine it mends. A kill pays three times the score of its kind (the plain elite pays two). The pillager elites keep their
// better guns and the purple ring; the Overseer has no affix. A linked window is told the affix with the new body, and the shield
// through a flag bit. Cosmetic code draws nothing from any random stream.
var AFFIX={
  shield:{c:'#4fd6ff'},
  boom:{c:'#ff8a3c'},
  fast:{c:'#f2e84a'},
  mend:{c:'#5cff8a'}
};
var AFFIX_KEYS=['shield','boom','fast','mend'], AFFIX_BOOM_R=130, AFFIX_MEND_R=260;
function affixApply(e,ix){
  var k;
  if(!e||e.kind==='raider'||e.boss||e.affix||!e.elite) return null;
  k=AFFIX_KEYS[((Math.floor(ix)%4)+4)%4];
  e.affix=k;
  if(k==='fast') e.spd=Math.round((e.spd||100)*1.35);
  else if(k==='shield') e.shieldHp=Math.round((e.maxhp||100)*0.5);
  return k;
}
function affixSoak(en,d){
  var a;
  if(!en||!(en.shieldHp>0)) return d;
  a=Math.min(en.shieldHp,d); en.shieldHp-=a;
  if(!G.sim){ spark(en.x,en.y-en.r*0.6,AFFIX.shield.c,8,200); if(!(en.shieldHp>0)) sfx('clank',en.x,en.y,'armor'); }
  return d-a;
}
function affixBoom(e){
  var R=AFFIX_BOOM_R, pls, i, pl, d, o, de;
  e.finished=1;
  sfx('boom',e.x,e.y);
  if(!G.sim){
    spark(e.x,e.y,AFFIX.boom.c,28,320); G.puffs.push({x:e.x,y:e.y,t:0,life:.6,c:AFFIX.boom.c,r:44}); G.shake=Math.max(G.shake||0,6);
    flash(e.x,e.y,260,AFFIX.boom.c,.4);
    try{ boomFx(e.x,e.y,1,'frag'); }catch(_ab){}
  }
  ping(e.x,e.y,520,false,false,'env','fire');
  pls=(typeof netPlayersList==='function')?netPlayersList():[G.player];
  for(i=0;i<pls.length;i++){
    pl=pls[i]; if(!pl||pl.dying||pl.specOut) continue;
    d=dist(pl,e);
    if(d<R&&losClear(e.x,e.y,pl.x,pl.y,G.map.segs)) netHitPlayer(pl,45*(1-d/R)+10,e.kind,e.name,e.x,e.y);
  }
  for(i=G.ents.length-1;i>=0;i--){
    o=G.ents[i]; if(o===e||o.finished||o.boss||!(o.hp>0)) continue;
    de=dist(o,e);
    if(de<R+o.r&&losClear(e.x,e.y,o.x,o.y,G.map.segs)){ o.hp-=55*(1-Math.max(0,de-o.r)/R)+5; o.hitT=.2; if(o.hp<=0){ o.byPlayer=false; o.bySeat=0; } }
  }
}
function affixMend(e){
  var i, o, n=0;
  e.mendTo=[];
  for(i=0;i<G.ents.length;i++){
    o=G.ents[i];
    if(o===e||o.boss||o.kind==='raider'||o.kind==='peddler'||o.kind==='stray'||o.neutral||o.downed||o.finished||!(o.hp>0)||!(o.hp<o.maxhp)) continue;
    if(dist(o,e)>AFFIX_MEND_R) continue;
    o.hp=Math.min(o.maxhp,o.hp+Math.max(3,o.maxhp*0.05)); n++;
    if(e.mendTo.length<4) e.mendTo.push({x:o.x,y:o.y});
  }
  e.mendFx=(n>0)?0.4:0;
  return n;
}
function drawAffixMark(e){
  var A=AFFIX[e.affix], t=(typeof G!=='undefined'&&G)?(G.t||0):0, pu, r=e.r, x=e.x, y=e.y, gr;
  if(!A||!isFinite(x)||!isFinite(y)||!(r>0)) return;
  pu=0.6+0.4*Math.sin(t*4+x*0.02);
  wc.save();
  try{
    wc.globalCompositeOperation='lighter';
    gr=wc.createRadialGradient(x,y,r*0.3,x,y,r*2.2); gr.addColorStop(0,hexA(A.c,0.34*pu)); gr.addColorStop(1,hexA(A.c,0));
    wc.fillStyle=gr; wc.beginPath(); wc.ellipse(x,y+2,r*2.2,r*1.15,0,0,6.2832); wc.fill();
    wc.strokeStyle=hexA(A.c,0.55+0.35*pu); wc.lineWidth=3; wc.beginPath(); wc.ellipse(x,y+2,r*1.45,r*0.72,0,0,6.2832); wc.stroke();
    wc.lineWidth=1.5; wc.beginPath(); wc.ellipse(x,y+2,r*1.85,r*0.93,0,0,6.2832); wc.stroke();
    if(e.affix==='mend'){ wc.strokeStyle=hexA(A.c,0.16); wc.lineWidth=1; wc.beginPath(); wc.ellipse(x,y+2,AFFIX_MEND_R,AFFIX_MEND_R*0.6,0,0,6.2832); wc.stroke(); }
  }catch(_am){}
  wc.restore();
}
function drawAffixTop(e){
  var A=AFFIX[e.affix], k=e.affix, x=e.x, y=e.y-spriteTop(e)-12, fl=(Math.cos(e.face)<0)?-1:1, f, j, aa, rr, cx, pts, o;
  if(!A||!isFinite(e.x)||!isFinite(e.y)) return;
  function ptsFill(col,p){ var q; wc.fillStyle=col; wc.beginPath(); for(q=0;q<p.length;q+=2){ if(q===0) wc.moveTo(p[0],p[1]); else wc.lineTo(p[q],p[q+1]); } wc.closePath(); wc.fill(); }
  wc.save();
  try{
    if(k==='shield'&&e.shieldHp>0){
      f=clamp(e.shieldHp/((e.maxhp||100)*0.5),0,1);
      wc.globalCompositeOperation='lighter';
      wc.strokeStyle=hexA(A.c,0.25+0.4*f); wc.lineWidth=2.5;
      wc.beginPath(); wc.ellipse(e.x,e.y-e.r*0.9,e.r*1.3,e.r*1.45,0,0,6.2832); wc.stroke();
      wc.fillStyle=hexA(A.c,0.07+0.08*f); wc.fill();
      wc.globalCompositeOperation='source-over';
    }
    if(k==='mend'&&e.mendFx>0&&e.mendTo){
      wc.strokeStyle=hexA(A.c,0.7); wc.lineWidth=2;
      for(j=0;j<e.mendTo.length;j++){ o=e.mendTo[j]; wc.beginPath(); wc.moveTo(e.x,e.y-e.r*0.8); wc.lineTo(o.x,o.y-8); wc.stroke(); }
    }
    pts=[];
    if(k==='shield'){
      for(j=0;j<6;j++){ aa=j*1.0472+0.5236; pts.push(x+Math.cos(aa)*8,y+Math.sin(aa)*8); } ptsFill(INK,pts); pts=[];
      for(j=0;j<6;j++){ aa=j*1.0472+0.5236; pts.push(x+Math.cos(aa)*6,y+Math.sin(aa)*6); } ptsFill(A.c,pts);
    } else if(k==='boom'){
      for(j=0;j<16;j++){ aa=j*0.3927; rr=(j%2)?4.2:9; pts.push(x+Math.cos(aa)*rr,y+Math.sin(aa)*rr); } ptsFill(INK,pts); pts=[];
      for(j=0;j<16;j++){ aa=j*0.3927; rr=(j%2)?2.6:7; pts.push(x+Math.cos(aa)*rr,y+Math.sin(aa)*rr); } ptsFill(A.c,pts);
    } else if(k==='fast'){
      for(j=0;j<2;j++){
        cx=x+fl*(j*6-3);
        pts=[cx-fl*3,y-6,cx+fl*4,y,cx-fl*3,y+6,cx-fl*5.5,y+6,cx+fl*1.5,y,cx-fl*5.5,y-6];
        wc.strokeStyle=INK; wc.lineWidth=2.5; wc.beginPath(); wc.moveTo(pts[0],pts[1]); wc.lineTo(pts[2],pts[3]); wc.lineTo(pts[4],pts[5]); wc.lineTo(pts[6],pts[7]); wc.lineTo(pts[8],pts[9]); wc.lineTo(pts[10],pts[11]); wc.closePath(); wc.stroke();
        ptsFill(A.c,pts);
      }
    } else if(k==='mend'){
      wc.fillStyle=INK; wc.fillRect(x-8,y-3.5,16,7); wc.fillRect(x-3.5,y-8,7,16);
      wc.fillStyle=A.c; wc.fillRect(x-6.5,y-2,13,4); wc.fillRect(x-2,y-6.5,4,13);
    }
  }catch(_at){}
  wc.restore();
}
function feudFoe(a,b){
'@

SubRx @'
  return e;
}
function mkSentry(x,y){
'@ @'
  if(e.kind!=='raider') affixApply(e,Math.floor(roll/rate*4));   // v26.xx (ai25): the affix, from where the elite roll fell; no new draw
  return e;
}
function mkSentry(x,y){
'@

SubRx @'
  e.elite=1; e.hp=Math.round(e.hp*hm); e.maxhp=Math.round(e.maxhp*hm); e.r=Math.round(e.r*1.12);
'@ @'
  e.elite=1; e.hp=Math.round(e.hp*hm); e.maxhp=Math.round(e.maxhp*hm); e.r=Math.round(e.r*1.12);
  if(e.kind!=='raider') affixApply(e,((Math.round(e.x)*73856093)^(Math.round(e.y)*19349663))>>>0);   // v26.xx (ai25): a wave elite machine, from a hash of where it stands
'@

SubRx @'
    if(_se.shotT>0){ _se.shotT-=dt; if(_se.shotT<0) _se.shotT=0; }
'@ @'
    if(_se.shotT>0){ _se.shotT-=dt; if(_se.shotT<0) _se.shotT=0; }
    if(_se.mendFx>0) _se.mendFx-=dt;   // v26.xx (ai25)
    if(_se.affix==='mend'&&_se.hp>0&&!_se.downed&&!_se.finished){ _se.mendT=(_se.mendT||0)-dt; if(_se.mendT<=0){ _se.mendT=0.5; affixMend(_se); } }
'@

SubRx @'
netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar,b.el); else en.hp-=edmg;
'@ @'
netShotSend(en,edmg,Math.atan2(b.vy,b.vx),WK,_nar,b.el); else en.hp-=affixSoak(en,edmg);
'@

SubRx @'
e.hp-=d; e.hitT=.16; e.pHitT=.3;
'@ @'
e.hp-=affixSoak(e,d); e.hitT=.16; e.pHitT=.3;
'@

SubRx @'
      if(!G.sim) G.puffs.push({x:e.x,y:e.y,t:0,life:.55,c:e.kind==='raider'?'#c8452f':'#ffc04a',r:26});
      G.ents.splice(i,1); continue;
'@ @'
      if(e.affix==='boom') affixBoom(e);   // v26.xx (ai25): a volatile machine goes off as it dies
      if(!G.sim) G.puffs.push({x:e.x,y:e.y,t:0,life:.55,c:e.kind==='raider'?'#c8452f':'#ffc04a',r:26});
      G.ents.splice(i,1); continue;
'@

SubRx @'
arcadeKill(e.kind,e.elite,e.boss,e.x,e.y)
'@ @'
arcadeKill(e.kind,(e.elite&&e.affix)?3:e.elite,e.boss,e.x,e.y)
'@

SubRx @'
careerKill(e.kind,e.elite,e.boss,e.x,e.y)
'@ @'
careerKill(e.kind,(e.elite&&e.affix)?3:e.elite,e.boss,e.x,e.y)
'@

SubRx @'
function arcadeKillPts(k,el,boss){ var n=boss?ARCADE_BOSSPTS:(ARCADE_KILLPTS[k]|0); return el?n*2:n; }
'@ @'
function arcadeKillPts(k,el,boss){ var n=boss?ARCADE_BOSSPTS:(ARCADE_KILLPTS[k]|0); return el?n*(el>1?el:2):n; }   // v26.xx (ai25): an affixed elite passes 3, a plain elite 2
'@

SubRx @'
!!(m.el||(e&&e.elite))
'@ @'
((e&&e.elite&&e.affix)?3:!!(m.el||(e&&e.elite)))
'@

SubRx @'
      if(e2.elite){
'@ @'
      if(e2.elite&&e2.affix&&AFFIX[e2.affix]) drawAffixMark(e2);   // v26.xx (ai25): an affixed elite wears its own colour, not the purple ring
      else if(e2.elite){
'@

SubRx @'
      var WL=weakOf(e2);
'@ @'
      if(e2.elite&&e2.affix&&AFFIX[e2.affix]) drawAffixTop(e2);   // v26.xx (ai25): its badge, shield bubble and mend beams
      var WL=weakOf(e2);
'@

SubRx @'
el:e.elite?1:0,ho:e.hostile?1:0};
'@ @'
el:e.elite?1:0,ho:e.hostile?1:0,af:e.affix?String(e.affix):''};
'@

SubRx @'
e.elite=m.el?1:0; e.hostile=!!m.ho;
'@ @'
e.elite=m.el?1:0; e.hostile=!!m.ho; e.affix=(typeof m.af==='string'&&AFFIX[m.af])?m.af:null;   // v26.xx (ai25)
'@

SubRx @'
  if(e.downed&&e.getUp>0) f|=8388608;   // pillrevive: he is getting up
'@ @'
  if(e.downed&&e.getUp>0) f|=8388608;   // pillrevive: he is getting up
  if(e.shieldHp>0) f|=536870912;   // v26.xx (ai25): the shield is up, so player 2 sees the bubble
'@

SubRx @'
  e.steady=!!(f&8192);
'@ @'
  if(e.affix==='shield') e.shieldHp=(f&536870912)?Math.max(e.shieldHp||0,1):0;   // v26.xx (ai25)
  e.steady=!!(f&8192);
'@

SubRx @'
var VER='26.71';
'@ @'
var VER='26.72';
'@

$pat = "(?m)^  now:'v26\.71:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.72: Elite machines now carry one affix each: shielded, volatile, fast or mender, each in its own colour with a badge. Check 26.72 fails on v26.71',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
