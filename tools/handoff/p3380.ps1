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

# THE PIXEL DOWNED AND DEAD (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pxBob(ph,moving){
'@ @'
// v33.79 (cw-pixdown), HIS PICKS a14 B, a15 B and a23 B (art survey 2026-10-19), job 86g ship 2: THE DOWNED, DEAD AND FALLEN IN PIXELS. A downed player kneels (the crouch legs, the shoulders bowed a pixel forward and
// v33.79 (cw-pixdown):  down) inside a pulsing red ring with the gun lying on the floor; a dead player and a falling pillager bot topple in 8 baked art resolution frames (pxToppleSpr, the standing legs and upper
// v33.79 (cw-pixdown):  body turned about the feet with nearest sampling and hardened, so no pixel is a blend), and the player fades into light as before. Timings, angles and the light dust are the vector ones.
function pxBuildDownRing(){
  var s=pixCanvas(40,16), sp;
  s.x.imageSmoothingEnabled=true; s.x.strokeStyle='#ff4a3a'; s.x.lineWidth=2; s.x.beginPath(); s.x.ellipse(20,8,18,7,0,0,6.2832); s.x.stroke();
  pixHarden(s,100); sp=pixSprite(s.c,20,8,PIX_ACT); sp.ring=1;
  return sp;
}
function pxBuildFloorGun(w,fl){   // the gun lying flat, from the same bake as the vector floor gun, hardened with the ink ring
  var id=w.id, fk=(w.fk===1||w.fk===2)?w.fk:0, el=(fk===2&&w.el&&ELEM[w.el])?w.el:'', wt=gunTier(w), B, K=GUNK, sx=fl*K, sy=K*0.85, x0, lo, hi, y0, y1, px, py, s, sp, rc;
  rc=(w.q==='gold')?'#ffc72e':(wt>=5?RCOL.gold:(wt>=4?RCOL.elite:(wt===3?RCOL.rare:(wt===2?RCOL.uncommon:RCOL.common))));
  B=gunBake(id,fk,el,rc,3); x0=B.x0-(GUNDEF[id].tip||16)*0.5;
  lo=Math.min(x0*sx,(x0+B.w)*sx); hi=Math.max(x0*sx,(x0+B.w)*sx); y0=B.y0*sy; y1=(B.y0+B.h)*sy;
  px=Math.ceil(-lo)+1; py=Math.ceil(-y0)+1; s=pixCanvas(Math.ceil(hi)+px+2,Math.ceil(y1)+py+2);
  s.x.imageSmoothingEnabled=true; s.x.translate(px,py); s.x.scale(sx,sy); s.x.drawImage(B.c,x0,B.y0,B.w,B.h);
  pixHarden(s,110); sp=pixSprite(pixRing(s.c,PIX_INK).c,px+1,py+1,PIX_ACT); sp.fg=1;
  return sp;
}
function pxKneelGround(x,y,fl,o,m){   // a14 B: the ring (1.2 Hz) under the kneeling body and the gun on the floor
  var k=0.5+0.5*Math.sin(((G&&G.t)||0)*7.5398), r=pixFetch('actors','k|ring',pxBuildDownRing,'k|ring',0), a0=wc.globalAlpha, w=o&&o.wep, gs;
  if(r){ wc.globalAlpha=a0*(0.4+0.5*k); pxBlit(r,x,y+1,m); wc.globalAlpha=a0; }
  if(w&&w.id&&w.id!=='fists'&&GUNDEF[w.id]){
    gs=pixFetch('actors','f|'+w.id+'|'+w.fk+'|'+w.el+'|'+w.q+'|'+fl,function(){ return pxBuildFloorGun(w,fl); },'f|'+w.id+'|'+fl,0);
    if(gs) pxBlit(gs,x+fl*17,y-2,m);
  }
}
// the standing body (legs, empty hands) turned about the feet: frame f of 8 is f/7 of the angle A, sg is the way it falls; the sprite anchor is the feet
function pxToppleSpr(lk,mir,sg,f,A){
  var fam='t|'+lk.head+'|'+lk.skin+'|'+lk.clothes+'|'+lk.bot+'|'+mir+'|'+sg+'|'+A;
  return pixFetch('actors',fam+'|'+f,function(){
    var lg=pxBuildLegs({clothes:lk.clothes,bot:lk.bot,mir:mir,kind:'s',fr:0}), up=pxBuildUpper({head:lk.head,skin:lk.skin,clothes:lk.clothes,bot:lk.bot,mir:mir,pup:0,arms:1,lamp:'',band:'',low:0}), R=62, s=pixCanvas(R*2+1,R*2+1);
    s.x.imageSmoothingEnabled=false; s.x.translate(R,R); s.x.rotate(sg*A*f/7);
    s.x.drawImage(lg.c,-lg.ax,-lg.ay); s.x.drawImage(up.c,-up.ax,-up.ay);
    pixHarden(s,128);
    return pixSprite(s.c,R,R,PIX_ACT);
  },fam,f);
}
function pxDeath(x,y,face,st,lk,m){   // a15 B: the player falls in 0.22 s, holds, then turns to light by 0.9 s
  var o=st.own, fl=Math.cos(face)<0?-1:1, t=(G&&typeof G.deathBeat==='number')?Math.max(0,1.5-G.deathBeat):9, sg=(o.hitDX||-fl)<0?-1:1, k, u, spr, a0=wc.globalAlpha, u2, col, i, qx, qy, S;
  if(t>=0.9) return true;
  k=Math.min(1,t/0.22); u=(t<0.4)?1:1-(t-0.4)/0.5;
  spr=pxToppleSpr(lk,fl<0?1:0,sg,Math.round(k*k*7),1.5708); if(!spr) return false;
  wc.globalAlpha=a0*u; opGround(x,y,st); pxBlit(spr,x,y+Math.round(6*k*k),m); wc.globalAlpha=a0;
  if(t>=0.4){
    u2=Math.min(1,(t-0.4)/0.5); S=seatMarkOf(st); col=(S>=0)?SEATCOL[S&3]:'#ffb02e';
    wc.save(); wc.globalCompositeOperation='lighter'; wc.fillStyle=col; wc.globalAlpha=a0*(1-u2);
    for(i=0;i<14;i++){ qx=Math.round(x+Math.sin(i*12.9898)*5+Math.cos(i*4.1)*6*u2); qy=Math.round(y-7-(i%3)*2-22*u2); wc.fillRect(qx-1,qy-1,2,2); }
    wc.restore();
  }
  PIX.bodies++;
  return true;
}
function pxFallTry(o,x,y,t,sg,st){   // a23 B: a pillager bot tips 85 degrees away from the player over 0.2 s and fades by 0.7 s; false draws the vector fall
  var lk, m, k, u, fl, spr, a0=wc.globalAlpha;
  try{
    if(!wc.getTransform) return false;
    lk=pxLookOf(st);
    if(!lk) return false;
    m=wc.getTransform(); if(Math.abs(m.b)>1e-9||Math.abs(m.c)>1e-9||!(m.a>0)||Math.abs(m.a-m.d)>1e-6) return false;
    fl=Math.cos(o.face||0)<0?-1:1; k=Math.min(1,t/0.2); u=(t<0.2)?1:1-(t-0.2)/0.5;
    spr=pxToppleSpr(lk,fl<0?1:0,sg<0?-1:1,Math.round((1-(1-k)*(1-k))*7),1.4835); if(!spr) return false;
    wc.globalAlpha=a0*u; shadowE(x+1.5,y+2,12.5,5,0.5); pxBlit(spr,x,y,m); wc.globalAlpha=a0;
    PIX.bodies++;
    return true;
  }catch(_pf){ PIX.errs++; PIX.fall++; try{ wc.globalAlpha=a0; }catch(_q){} return false; }
}
function pxBob(ph,moving){
'@

SubRx @'
  if(mode==='down'||mode==='fist') return false;
'@ @'
  if(mode==='fist') return false;
  if(mode==='down'){   // v33.79 (cw-pixdown): a14 B kneel (1) and a15 B death (2) are pixel; any other down body stays vector
    if(!(st.own&&opIsPlayer(st))) return false;
    dn=(st.own.downed||st.own.dn)?1:((st.hero&&st.own.hp<=0)?2:0);
    if(!dn) return false;
    if(dn===1) mode='crouchnone';
  }
'@

SubRx @'
  var age, hurt, lw, rx=0, fx=null, m,
'@ @'
  var age, hurt, lw, rx=0, fx=null, dn=0, m,
'@

SubRx @'
  lk=pxLookOf(st); if(!lk) return false;
'@ @'
  lk=pxLookOf(st); if(!lk) return false;
  if(dn===2) return pxDeath(x,y,face,st,lk,m);
'@

SubRx @'
  if(mode&&mode!=='none'&&mode!=='crouch'&&mode!=='crouchnone'&&mode!=='roll') return false;
'@ @'
  if(mode&&dn!==2&&mode!=='none'&&mode!=='crouch'&&mode!=='crouchnone'&&mode!=='roll') return false;
'@

SubRx @'
  age=opHitAge(st); hurt=age<0.3; lw=opLow(st);   // v33.78 (cw-pixhurt): a12 B and a13 D
'@ @'
  age=opHitAge(st); hurt=age<0.3&&!dn; lw=opLow(st);   // v33.78 (cw-pixhurt): a12 B and a13 D
  if(dn){ moving=false; sprint=false; ads=false; rl=0; }   // v33.79 (cw-pixdown): a kneeling body stands still
'@

SubRx @'
  lean=sprint?fl*3:(moving?fl:0);
'@ @'
  lean=dn?fl*2:(sprint?fl*3:(moving?fl:0));   // a14 B: the kneeling shoulders bow a pixel forward
'@

SubRx @'
  dyUp=(crouch?5:0)-bob+(lw?1:0);   // a13 D: the shoulders drop
'@ @'
  dyUp=(crouch?5:0)-bob+(lw?1:0)+(dn?2:0);   // a13 D: the shoulders drop; a14 B: and the kneel
'@

SubRx @'
  pxLayer(lg,x+rx,y,m,fx);
'@ @'
  if(dn) pxKneelGround(x,y,fl,st.own,m);
  pxLayer(lg,x+rx,y,m,fx);
'@

SubRx @'
  wc.save(); wc.globalAlpha=wc.globalAlpha*u;
'@ @'
  if(pixOn()&&figOn()&&pxFallTry(o,x,y,t,a.sg,st)) return 1;   // v33.79 (cw-pixdown): a23 B in pixels
  wc.save(); wc.globalAlpha=wc.globalAlpha*u;
'@

SubRx @'
var VER='33.79';
'@ @'
var VER='33.80';
'@

$pat = "(?m)^  now:'v33\.79:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.80: A downed player kneels in a pulsing red pixel ring with the gun on the floor; a dead player and a falling pillager bot topple in baked pixel frames and fade. Check 33.80 fails on v33.79',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
