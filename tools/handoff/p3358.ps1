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

# THE PIXEL PILLAGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function pixBenchOpen(){
'@ @'
// v33.58 (cw-pixbody), HIS ORDERS (2026-10-20 22:45 to 23:05: "3 head options, 3 skin options, 3 clothing (with pack) options", pixel art like the style test): THE PIXEL PILLAGER, job 86c ship 1.
// One body at PIX_ACT (1 world unit per art px, 36 by 50 art px before the ink ring), drawn in layers that are baked once and blitted: the legs (a pose per walk frame), the upper body (torso, pack and
// the chibi head, shifted a whole pixel for the bob and the breath) and the gun with its arms (painted at art density and rotated in 32 steps at art resolution, flipped when aiming left). The front
// view is baked twice: the mirror is the same parts flipped with the light still from the top left. Heads (short, long, hood), skins (fair, tan, umber) and clothes (scav, recon, heavy, each with its own
// pack) come from pixLook (job 86a); the pillager bots draw the same parts in the red ramp with angry brows and red eyes. Whatever is not pixel yet (armour tiers, hurt, downed, death, fists, sets, the
// peddler, the survivor, a forged gun, a reload) draws today's vector body, and a throw falls back to the vector body and is logged. Shapes use whole pixel masks and hand placed pixels only: no rr(),
// no random, so two windows bake the same pixels and the seed does not move.
PIX.bodies=0;
var PXB={W:36,H:50,AX:19,AY:51,PV:22,TARGET:50};   // the art grid, the anchor between the feet in the ringed sprite, the gun pivot (art px above the feet), the drawn height the check expects
var PXB_HAIR=['#5a4a4c','#3a2e34','#241c24','#14101a'];
var PXB_BOOT=['#6a5a4a','#4a3e34','#322a22','#1e1914'];
var PXB_EYE={white:'#f2e8e4',lid:'#d6c6c2',ink:'#1c1218',iris:'#4a3228',red:'#e03a28',redDeep:'#8e1a1c',brow:'#2a1418'};
var PXB_RAMP={   // light to deep: coat, trousers, gear (straps, plates), pack; acc is the one bright note
  scav:{coat:['#dcbc8a','#b68e5a','#80603c','#4a3626'],trs:['#8a7a60','#66583f','#463c2a','#2c261a'],gear:['#b8a070','#8c7448','#60502e','#3c321d'],pack:['#b09a6c','#86703f','#5c4a2a','#3a2e1a'],acc:'#e8c050'},
  recon:{coat:['#a2ae70','#6e7c46','#475430','#2c371d'],trs:['#68734a','#4a5632','#323c22','#1f2615'],gear:['#6a6a50','#4a4a36','#34342a','#22221b'],pack:['#6a7648','#4a5632','#34401f','#222b14'],acc:'#d8c850'},
  heavy:{coat:['#a0aab8','#6c7684','#464e5c','#2a303a'],trs:['#58606e','#3e4552','#2a303a','#191d24'],gear:['#c4ccd6','#929cac','#626c7c','#3c4452'],pack:['#6a7484','#4a5260','#343a46','#20242c'],acc:'#ff7a3a'}
};
var PXB_REDS={coat:['#e4553a','#c4302a','#8e1f1c','#561420'],trs:['#a8281f','#7e1c1c','#561420','#3a0e16'],gear:['#ec6a48','#c4302a','#8e1f1c','#561420'],pack:['#a8281f','#821c1c','#5c1620','#3a0e16'],acc:'#ffb21e'};   // every clothes pixel of a pillager bot
function pxM(){ return new Uint8Array(PXB.W*PXB.H); }
function pxIn(x,y){ return x>=0&&y>=0&&x<PXB.W&&y<PXB.H; }
function pxRect(m,x0,y0,x1,y1){ var x, y; for(y=y0;y<=y1;y++) for(x=x0;x<=x1;x++) if(pxIn(x,y)) m[y*PXB.W+x]=1; return m; }
function pxEll(m,x0,y0,x1,y1){
  var cx=(x0+x1+1)/2, cy=(y0+y1+1)/2, rx=(x1-x0+1)/2, ry=(y1-y0+1)/2, x, y, u, v;
  for(y=y0;y<=y1;y++) for(x=x0;x<=x1;x++){ u=(x+0.5-cx)/rx; v=(y+0.5-cy)/ry; if(u*u+v*v<=1.04&&pxIn(x,y)) m[y*PXB.W+x]=1; }
  return m;
}
function pxRR(m,x0,y0,x1,y1,r){   // rounded rectangle, inclusive pixel bounds
  var x, y, px, py, cx, cy;
  for(y=y0;y<=y1;y++) for(x=x0;x<=x1;x++){
    px=x+0.5; py=y+0.5; cx=Math.min(Math.max(px,x0+r),x1+1-r); cy=Math.min(Math.max(py,y0+r),y1+1-r);
    if((px-cx)*(px-cx)+(py-cy)*(py-cy)<=r*r&&pxIn(x,y)) m[y*PXB.W+x]=1;
  }
  return m;
}
function pxSeg(m,x0,y0,x1,y1,r){   // a bar: pixel centres within r of the segment
  var dx=x1-x0, dy=y1-y0, L2=dx*dx+dy*dy||1, x, y, px, py, t, ex, ey;
  for(y=0;y<PXB.H;y++) for(x=0;x<PXB.W;x++){
    px=x+0.5; py=y+0.5; t=((px-x0)*dx+(py-y0)*dy)/L2; t=t<0?0:(t>1?1:t); ex=x0+dx*t-px; ey=y0+dy*t-py;
    if(ex*ex+ey*ey<=r*r) m[y*PXB.W+x]=1;
  }
  return m;
}
// a figure being painted: parts go on back to front, each shaded in 4 tones toward the light, with a dark line where it sits over an earlier part. mir builds the geometry for the flipped sprite
// with the light reversed, so after the flip the light is on the top left again; hand placed pixels go through Pl so they stay on the lit side.
function pxPaint(mir){
  var W=PXB.W, H=PXB.H, F=new Array(W*H).fill(null), LINE='#1c1622', me={F:F};
  me.stamp=function(m,T,R,line){
    var x, y, i, mark=[];
    if(line!==false){
      for(y=0;y<H;y++) for(x=0;x<W;x++){
        i=y*W+x;
        if(!m[i]&&F[i]&&((x>0&&m[i-1])||(x<W-1&&m[i+1])||(y>0&&m[i-W])||(y<H-1&&m[i+W]))) mark.push(i);
      }
      for(i=0;i<mark.length;i++) F[mark[i]]=line||LINE;
    }
    for(i=0;i<W*H;i++) if(m[i]) F[i]=R[T[i]];
  };
  me.put=function(m,R,o){
    var o2={}, k, T;
    o=o||{}; for(k in o) o2[k]=o[k];
    o2.lx=(o.lx==null?-0.45:o.lx)*(mir?-1:1);
    T=pixTones(m,W,H,o2); me.stamp(m,T,R,o.line); return T;
  };
  me.P=function(x,y,c){ if(pxIn(x,y)) F[y*W+x]=c; };
  me.Pl=function(x,y,c){ me.P(mir?W-1-x:x,y,c); };
  me.sprite=function(){
    var s=pixCanvas(W,H), d=s.x.createImageData(W,H), i, x, y, n, j;
    for(y=0;y<H;y++) for(x=0;x<W;x++){
      i=y*W+x; if(!F[i]) continue;
      n=parseInt(F[i].slice(1),16); j=(y*W+(mir?W-1-x:x))*4;
      d.data[j]=n>>16; d.data[j+1]=(n>>8)&255; d.data[j+2]=n&255; d.data[j+3]=255;
    }
    s.x.putImageData(d,0,0);
    return pixSprite(pixRing(s.c,PIX_INK).c,PXB.AX,PXB.AY,PIX_ACT);
  };
  return me;
}
// the upper body: pack, torso, neck and the head with its face. o: head, skin, clothes, bot, mir, pup (-1, 0, 1: the pupils toward the aim), arms (1: empty hands hang at the sides), lamp (team colour), band (seat colour)
function pxBuildUpper(o){
  var p=pxPaint(o.mir), W=PXB.W, C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair, hr=PXB_HAIR, E=PXB_EYE, bot=!!o.bot, dxp=o.mir?-o.pup:o.pup, cl=o.clothes, m, y, x, skull, op, belt, mk, ml;
  // pack, on the side away from the facing (the left of the unflipped sprite)
  if(cl==='recon'){
    p.put(pxRR(pxM(),4,15,10,40,2),C.pack); p.put(pxRR(pxM(),2,11,11,15,2.2),C.gear);
    for(y=17;y<=38;y++) p.P(5,y,C.pack[3]);
  } else if(cl==='heavy'){
    p.put(pxRR(pxM(),2,21,10,40,1.2),C.pack); p.put(pxRect(pxM(),4,24,8,29),C.gear);
    p.P(5,31,C.acc); p.P(7,31,C.acc); p.P(5,33,C.gear[0]); p.P(6,33,C.gear[0]);
    for(y=5;y<=20;y++) p.P(4,y,C.gear[2]);
    p.P(4,4,C.acc); p.P(3,4,C.gear[1]);
  } else {
    p.put(pxRR(pxM(),3,26,10,38,2),C.pack); p.put(pxRect(pxM(),4,27,9,29),C.gear); p.P(6,30,C.acc);
  }
  // torso, then what each clothes pick wears on it
  p.put(pxRR(pxM(),10,22,25,35,2.5),C.coat);
  if(cl==='recon'){
    p.put(pxSeg(pxM(),12,22.6,23.5,33.5,0.9),C.gear); p.put(pxSeg(pxM(),23.5,22.6,12,33.5,0.9),C.gear); p.put(pxRR(pxM(),15,29,20,32,1),C.pack);
  } else if(cl==='heavy'){
    p.put(pxRR(pxM(),12,23,23,31,1.5),C.gear); p.put(pxRR(pxM(),8,21,12,26,1.5),C.gear); p.put(pxRR(pxM(),23,21,27,26,1.5),C.gear);
    p.Pl(13,24,C.gear[0]); p.Pl(9,22,C.gear[0]);
  } else {
    p.put(pxSeg(pxM(),12.5,23,22.5,33.5,1.1),C.gear); p.put(pxRR(pxM(),11,28,14,31,1),C.gear); p.put(pxRR(pxM(),21,28,24,31,1),C.gear);
  }
  belt=o.band?pixRamp(o.band):[C.gear[1],C.gear[2],C.gear[3],C.gear[3]];
  p.put(pxRect(pxM(),10,34,25,35),belt,{line:false}); p.P(17,34,C.acc); p.P(18,34,C.acc);
  if(o.arms){
    p.put(pxRR(pxM(),8,23,10,33,1.2),C.coat); p.put(pxRR(pxM(),25,23,27,33,1.2),C.coat);
    p.put(pxRR(pxM(),8,33,10,36,1.2),sk); p.put(pxRR(pxM(),25,33,27,36,1.2),sk);
  }
  if(o.lamp){ p.Pl(11,22,o.lamp); p.Pl(12,22,o.lamp); p.Pl(11,23,o.lamp); p.Pl(12,23,o.lamp); }
  p.put(pxRect(pxM(),16,19,19,21),sk,{line:false});
  // the head: hair behind first, then the skull, then what covers it
  if(o.head==='long'){
    p.put(pxEll(pxM(),6,2,29,22),hr); p.put(pxSeg(pxM(),10,15,6.5,29,2.3),hr);
    p.P(8,19,C.acc); p.P(9,19,C.acc); p.P(8,20,C.acc);
  }
  skull=pxEll(pxM(),9,3,26,18); p.put(skull,sk);
  if(o.head==='hood'){
    ml=pxEll(pxM(),6,0,29,21); op=pxRR(pxM(),11,8,24,19,3.2);
    for(y=0;y<PXB.H*W;y++) if(op[y]) ml[y]=0;
    p.put(pxRR(pxM(),7,19,28,24,2),C.coat);
    p.put(ml,C.coat,{lx:-0.75,ly:-0.66,b1:0.24,b2:0.56,b3:0.82});
    mk=pxRR(pxM(),11,15,24,19,2); p.put(mk,[C.coat[0],C.coat[0],C.coat[1],C.coat[2]],{line:false});
    p.Pl(12,3,C.coat[0]); p.Pl(13,3,C.coat[0]); p.Pl(11,4,C.coat[0]);
  } else {
    ml=pxM(); for(y=3;y<=8;y++) for(x=9;x<=26;x++) if(skull[y*W+x]) ml[y*W+x]=1;
    pxRect(ml,9,9,10,o.head==='long'?18:11); pxRect(ml,25,9,26,o.head==='long'?18:11); pxRect(ml,10,9,o.head==='long'?24:20,9);
    p.put(ml,hr,{line:false});
    p.P(17,16,sk[3]); p.P(18,16,sk[3]);
  }
  // the face: two 3 by 3 eyes, the pupils a pixel toward the aim; a bot has red eyes and angry brows
  function eye(ex){
    var px=ex+1+dxp, yy, xx;
    for(yy=11;yy<=13;yy++) for(xx=ex;xx<=ex+2;xx++) p.P(xx,yy,yy===11?E.lid:E.white);
    if(bot){ p.P(px,12,E.red); p.P(px,13,E.redDeep); } else { p.P(px,12,E.iris); p.P(px,13,E.ink); }
  }
  eye(12); eye(21);
  if(bot){ p.P(11,10,E.brow); p.P(12,10,E.brow); p.P(13,11,E.brow); p.P(14,11,E.brow); p.P(24,10,E.brow); p.P(23,10,E.brow); p.P(22,11,E.brow); p.P(21,11,E.brow); p.P(13,10,E.brow); p.P(22,10,E.brow); }
  return p.sprite();
}
// the legs and boots, a pose per call: kind s (standing), w (walk), r (sprint), c (crouch); fr is the walk frame 0 to 5 (the swing and the lift of the vector walk, to whole pixels)
function pxBuildLegs(o){
  var p=pxPaint(o.mir), C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), B=PXB_BOOT, kind=o.kind, ph, amp=0, sw=0, lA=0, lB=0, k;
  if(kind==='w'||kind==='r'){
    ph=((o.fr|0)+0.5)/6*6.28318; amp=(kind==='r')?5:3.4; k=(kind==='r')?3.4:2.2;
    sw=Math.sin(ph)*amp; lA=Math.max(0,Math.sin(ph))*k; lB=Math.max(0,-Math.sin(ph))*k;
  }
  function leg(cx,su,sl,lift,toe){
    var bt=45-lift;
    p.put(pxRR(pxM(),cx-2+su,37,cx+2+su,bt,1),C.trs);
    p.put(pxRR(pxM(),cx+(toe>0?-2:-4)+sl,bt,cx+(toe>0?4:2)+sl,bt+4,1.6),B);
  }
  if(kind==='c'){
    p.put(pxRR(pxM(),10,39,25,44,2),C.trs,{line:false});
    p.put(pxRR(pxM(),11,42,16,46,1),C.trs); p.put(pxRR(pxM(),19,42,24,46,1),C.trs);
    p.put(pxRR(pxM(),8,45,15,49,1.6),B); p.put(pxRR(pxM(),20,45,27,49,1.6),B);
    p.P(14,46,B[0]); p.P(26,46,B[0]);
  } else {
    p.put(pxRR(pxM(),11,33,24,40,2),C.trs,{line:false});
    leg(14,Math.round(-sw*0.45),Math.round(-sw*0.9),Math.round(lB),-1); leg(21,Math.round(sw*0.45),Math.round(sw*0.9),Math.round(lA),1);
  }
  return p.sprite();
}
// the roll: a ball of coat, the head and the boots going round it (4 frames)
function pxBuildRoll(o){
  var p=pxPaint(o.mir), C=o.bot?PXB_REDS:(PXB_RAMP[o.clothes]||PXB_RAMP.scav), sk=PIXRAMPS.skins[o.skin]||PIXRAMPS.skins.fair, a=(o.fr|0)*1.5708+0.7854, c=Math.cos(a), s=Math.sin(a), t, hx, hy, bx, by, kx, ky;
  p.put(pxEll(pxM(),10,34,25,49),C.coat);
  for(t=a+0.9;t<=a+2.6;t+=0.1) p.P(Math.round(17.5+Math.cos(t)*6.4),Math.round(41.5+Math.sin(t)*6.4),C.gear[1]);
  kx=Math.cos(a+1.5708); ky=Math.sin(a+1.5708); p.put(pxRR(pxM(),Math.round(17.5+kx*5)-2,Math.round(41.5+ky*5)-2,Math.round(17.5+kx*5)+1,Math.round(41.5+ky*5)+1,1),C.pack);
  hx=Math.round(17.5+c*5.2); hy=Math.round(41.5+s*5.2); p.put(pxEll(pxM(),hx-2,hy-2,hx+2,hy+2),sk);
  bx=Math.round(17.5-c*5.8); by=Math.round(41.5-s*5.8); p.put(pxRR(pxM(),bx-1,by-1,bx+1,by+1,0.8),PXB_BOOT);
  return p.sprite();
}
// the gun and both arms, painted at art density from the same baked gun, rotated at art resolution in 32 steps (flipped when aiming left): the pivot is the shoulder, the muzzle is kept with the sprite
function pxBuildGun(id,fk,el,rc,step,fl,sl,hd,ext,low){
  var D=GUNDEF[id]||GUNDEF.rifle, K=GUNK, ang=step*Math.PI/16, c0=Math.cos(ang), s0=Math.sin(ang), sg=fl<0?-1:1, B=gunBake(id,fk,el,rc,3), co=[[-6,-11],[D.tip+ext+5,-11],[D.tip+ext+5,12],[-6,12]],
      mnx=1e9, mny=1e9, mxx=-1e9, mxy=-1e9, i, lx, ly, rx, ry, px, py, w, h, s, c, aw=2.1/1.12, sx, gx, tx, spr;
  for(i=0;i<4;i++){
    lx=K*co[i][0]; ly=K*co[i][1]*sg; rx=c0*lx-s0*ly; ry=s0*lx+c0*ly;
    if(rx<mnx) mnx=rx; if(rx>mxx) mxx=rx; if(ry<mny) mny=ry; if(ry>mxy) mxy=ry;
  }
  px=Math.ceil(-mnx)+1; py=Math.ceil(-mny)+1; w=Math.ceil(mxx)+px+1; h=Math.ceil(mxy)+py+1;
  s=pixCanvas(w,h); c=s.x; c.imageSmoothingEnabled=true; try{ c.imageSmoothingQuality='high'; }catch(_q){}
  c.translate(px,py); c.rotate(ang); if(fl<0) c.scale(1,-1); c.scale(K,K);
  sx=D.pist?(D.grip+ext+0.4):(D.fg+ext);
  if(!low){ c.fillStyle=PIX_INK; c.fillRect(-0.5,0.4,sx+0.6,3.8); c.fillStyle=sl; c.fillRect(0,0.9,sx-0.4,2.8); }
  c.drawImage(B.c,B.x0+ext,B.y0,B.w,B.h);
  gx=D.grip+ext-1.2;
  c.fillStyle=PIX_INK; c.fillRect(-1.2,-aw-0.5,gx+1.4,2*aw+1); c.fillStyle=sl; c.fillRect(-0.8,-aw,gx+0.8,2*aw);
  c.fillStyle=PIX_INK; c.fillRect(gx-0.5,-0.1,4.4,4.4); c.fillStyle=hd; c.fillRect(gx,0.4,3.4,3.4);
  if(!low){ tx=D.pist?(D.grip+ext+0.2):(D.fg+ext-1.7); c.fillStyle=PIX_INK; c.fillRect(tx-0.5,D.pist?0.9:-0.3,4.4,4.4); c.fillStyle=hd; c.fillRect(tx,D.pist?1.4:0.2,3.4,3.4); }
  pixHarden(s,110);
  spr=pixSprite(s.c,px,py,PIX_ACT);
  spr.mx=c0*K*(D.tip+ext)-s0*K*sg*D.by; spr.my=s0*K*(D.tip+ext)+c0*K*sg*D.by;   // where the muzzle is, from the shoulder pivot
  return spr;
}
// ---- who is drawn, and how ----
function pxHash(str){ var h=2166136261>>>0, i; for(i=0;i<str.length;i++){ h^=str.charCodeAt(i); h=Math.imul(h,16777619)>>>0; } h=Math.imul(h^(h>>>15),2246822507)>>>0; return (h^(h>>>13))>>>0; }
var PXB_HEADS=['short','long','hood'], PXB_SKINS=['fair','tan','umber'], PXB_CLOTHS=['scav','recon','heavy'];
// the pixel look of a body, or null when it is not a plain pillager (a set, the peddler, the survivor): vector then
function pxLookOf(st){
  var o=st.own, hero=!!st.hero, sc=schemeOf(st), oid, lk, r, bot, h;
  oid=hero?cosWorn('outfit'):st.outfit;
  if(oid&&oid!=='outnone'&&!PIX_OUTFIT[oid]) return null;
  lk=hero?{hat:cosWorn('hat'),cut:cosWorn('cut'),skin:cosWorn('skin'),scheme:sc?sc.id:cosWorn('scheme'),fit:cosWorn('fit'),outfit:oid}
         :{hat:st.hat,cut:st.cut,skin:st.skin,scheme:sc?sc.id:st.scheme,outfit:oid};
  r=pixLook(lk);
  if(r.set!=='none') return null;
  bot=!hero&&st.team==='foe'&&!st.merc&&!(o&&(o.merc||o.friendly));
  if(bot){   // a pillager bot: head, skin and clothes picked evenly from his own look hash (raiderLook), drawn in red
    h=pxHash([st.hair,st.cut,st.hat,st.skin,st.beard,st.eyes,st.faceMark,st.boots,st.gloves,st.pack,st.patch,st.tattoo,st.build].join('|'));
    return {head:PXB_HEADS[h%3],skin:PXB_SKINS[(h>>>4)%3],clothes:PXB_CLOTHS[(h>>>8)%3],bot:1};
  }
  return {head:r.head,skin:r.skin,clothes:r.clothes,bot:0};
}
function pxUpper(o){
  var fam='u|'+o.head+'|'+o.skin+'|'+o.clothes+'|'+o.bot+'|'+o.mir;
  return pixFetch('actors',fam+'|'+o.pup+'|'+o.arms+'|'+(o.lamp||'')+'|'+(o.band||''),function(){ return pxBuildUpper(o); },fam,0);
}
function pxLegs(o){
  var fam='g|'+o.clothes+'|'+o.bot+'|'+o.mir+'|'+o.kind;
  return pixFetch('actors',fam+'|'+(o.fr|0),function(){ return pxBuildLegs(o); },fam,o.fr|0);
}
function pxRoll(o){
  var fam='r|'+o.head+'|'+o.skin+'|'+o.clothes+'|'+o.bot+'|'+o.mir;
  return pixFetch('actors',fam+'|'+(o.fr|0),function(){ return pxBuildRoll(o); },fam,o.fr|0);
}
function pxGun(id,fk,el,rc,step,fl,sl,hd,ext,low){
  var fam='n|'+id+'|'+fk+'|'+el+'|'+rc+'|'+fl+'|'+sl+'|'+hd+'|'+ext+'|'+low;
  return pixFetch('actors',fam+'|'+step,function(){ return pxBuildGun(id,fk,el,rc,step,fl,sl,hd,ext,low); },fam,step);
}
// a baked layer onto the world canvas on whole device pixels: the anchor lands on a whole device pixel; a whole scale draws nearest, any other scale draws the prescale smooth (sharp bilinear)
function pxBlit(spr,wx,wy,m){
  var S=m.a*(spr.d||PIX_ACT), whole=Math.abs(S-Math.round(S))<0.001, src, w=spr.c.width, h=spr.c.height, dw, dh, dx, dy;
  PIX.S=S;
  if(whole){ S=Math.round(S); src=spr.c; dw=w*S; dh=h*S; if(wc.imageSmoothingEnabled) wc.imageSmoothingEnabled=false; }
  else { src=pixPre(spr,Math.ceil(S)); dw=Math.round(w*S); dh=Math.round(h*S); if(!wc.imageSmoothingEnabled) wc.imageSmoothingEnabled=true; }
  dx=Math.round(m.a*wx+m.e-spr.ax*S); dy=Math.round(m.d*wy+m.f-spr.ay*S);
  wc.drawImage(src,(dx-m.e)/m.a,(dy-m.f)/m.d,dw/m.a,dh/m.d);
}
// draws one body in pixels and returns true, or returns false having drawn nothing (the caller then draws the vector body)
function pixDrawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
  var m, lk, fl, mir, moving, sprint, crouch, ads, rl, hold, back, kind, fr, bob, lean, dyUp, uo, lg, up, ro, gn=null, gv=0, w, id, D, fk, el, wt, rc, low, ext, ang, step, C, sk, sl, hd, sm, px, py, ty, pxd, k;
  if(!st||iv>0||OPX.inScr||st.bulk>0||st.low) return false;
  if(mode==='down'||mode==='fist') return false;
  if(mode&&mode!=='none'&&mode!=='crouch'&&mode!=='crouchnone'&&mode!=='roll') return false;
  if(opHitAge(st)<0.3) return false;
  if(!wc||!wc.getTransform) return false;
  m=wc.getTransform();
  if(Math.abs(m.b)>1e-9||Math.abs(m.c)>1e-9||!(m.a>0)||Math.abs(m.a-m.d)>1e-6) return false;
  lk=pxLookOf(st); if(!lk) return false;
  fl=Math.cos(face)<0?-1:1; mir=fl<0?1:0; moving=!!st.moving; sprint=!!st.sprint; ads=!!st.ads; rl=st.rl||0; crouch=(mode==='crouch'||mode==='crouchnone');
  C=lk.bot?PXB_REDS:(PXB_RAMP[lk.clothes]||PXB_RAMP.scav); sk=PIXRAMPS.skins[lk.skin]||PIXRAMPS.skins.fair;
  if(mode==='roll'){
    ro=pxRoll({head:lk.head,skin:lk.skin,clothes:lk.clothes,bot:lk.bot,mir:mir,fr:Math.floor(((ph/12.6)%1+1)%1*4)%4});
    if(!ro) return false;
    opGround(x,y,st); pxBlit(ro,x,y,m); wc.imageSmoothingEnabled=true; PIX.bodies++; return true;
  }
  hold=gunHeldOn(st,mode); back=hold&&Math.sin(face)<-0.3;
  if(crouch){ kind='c'; fr=0; }
  else if(moving){ kind=sprint?'r':'w'; fr=Math.floor(((ph/6.28318531)%1+1)%1*6)%6; }
  else { kind='s'; fr=0; }
  bob=moving?Math.round(Math.abs(Math.sin(ph))*(sprint?3.6:2.6)):(((((G&&G.t)||0)*0.8)|0)&1);
  lean=sprint?fl*3:(moving?fl:0);
  dyUp=(crouch?5:0)-bob;
  sm=seatMarkOf(st);
  uo={head:lk.head,skin:lk.skin,clothes:lk.clothes,bot:lk.bot,mir:mir,pup:(Math.cos(face)*1.4>0.6?1:(Math.cos(face)*1.4<-0.6?-1:0)),arms:hold?0:1,
      lamp:(st.team==='ally'||st.team==='foe')&&typeof TEAMCOL!=='undefined'?TEAMCOL[st.team]:'',band:sm>=0?SEATCOL[sm&3]:''};
  lg=pxLegs({clothes:lk.clothes,bot:lk.bot,mir:mir,kind:kind,fr:fr}); if(!lg) return false;
  up=pxUpper(uo); if(!up) return false;
  ty=y+dyUp; pxd=x+lean; px=pxd; py=ty-PXB.PV+(ads?-1:0);
  if(hold){
    w=(st.own&&st.own.wep&&st.own.wep.id)?st.own.wep:null; id=(w&&GUNDEF[w.id])?w.id:'rifle'; D=GUNDEF[id];
    fk=(w&&(w.fk===1||w.fk===2))?w.fk:0; el=(fk===2&&w.el&&ELEM[w.el])?w.el:'';
    if(fk||rl>0) gv=1;   // a forged gun (its shine) and a reload (the arm to the magazine) keep the vector gun on the pixel body
    else {
      wt=(w&&WTIER[w.id]!==undefined)?WTIER[w.id]+(RV_BASE[w.id]?1:0):1;
      rc=!w?'':((w.q==='gold')?'#ffc72e':(wt>=5?RCOL.gold:(wt>=4?RCOL.elite:(wt===3?RCOL.rare:(wt===2?RCOL.uncommon:RCOL.common)))));
      low=!!sprint; ext=(D.pist?2:0)+(ads?2:(low?-2:0)); ang=face+fl*(low?0.45:0);
      step=((Math.round(ang/(Math.PI/16))%32)+32)%32;
      gn=pxGun(id,fk,el,rc,step,fl,C.coat[1],sk[1],ext,low?1:0); if(!gn) return false;
    }
  }
  opGround(x,y,st);
  pxBlit(lg,x,y,m);
  if(back){ if(gv){ wc.imageSmoothingEnabled=true; gunHeld(pxd,ty,face,fl,st,C.coat[1],null,true,ads,sprint,rl,muzzle); } else if(gn) pxBlit(gn,px,py,m); }
  pxBlit(up,pxd,ty,m);
  if(hold&&!back){ if(gv){ wc.imageSmoothingEnabled=true; gunHeld(pxd,ty,face,fl,st,C.coat[1],null,true,ads,sprint,rl,muzzle); } else if(gn) pxBlit(gn,px,py,m); }
  wc.imageSmoothingEnabled=true;
  if(gn&&muzzle>0){
    k=flashK(); wc.globalCompositeOperation='lighter'; wc.fillStyle='rgba(255,212,138,'+(0.95*k).toFixed(3)+')';
    wc.fillRect(Math.round(px+gn.mx)-3,Math.round(py+gn.my)-1,7,3); wc.fillRect(Math.round(px+gn.mx)-1,Math.round(py+gn.my)-3,3,7);
    wc.globalCompositeOperation='source-over';
  }
  PIX.bodies++;
  return true;
}
// the 27 looks as one sheet (9 across, 3 down): the standing front view with empty hands, a bot row under it when bot is set; used by ?pixbench and the check
function pixBodyCell(head,skin,clothes,bot,mir,pup){
  var s=pixCanvas(PXB.W+2,PXB.H+2), lg=pxBuildLegs({clothes:clothes,bot:bot,mir:mir,kind:'s',fr:0}), up=pxBuildUpper({head:head,skin:skin,clothes:clothes,bot:bot,mir:mir,pup:pup||0,arms:1,lamp:'',band:''});
  s.x.drawImage(lg.c,0,0); s.x.drawImage(up.c,0,0); return s.c;
}
function pixBodySheet(bot){
  var cw=PXB.W+2, ch=PXB.H+2, s=pixCanvas(cw*9,ch*3), i=0, h, k, c;
  for(h=0;h<3;h++) for(k=0;k<3;k++) for(c=0;c<3;c++){ s.x.drawImage(pixBodyCell(PXB_HEADS[h],PXB_SKINS[k],PXB_CLOTHS[c],bot?1:0,0,0),(i%9)*cw,Math.floor(i/9)*ch); i++; }
  return pixSprite(s.c,0,0,PIX_ACT);
}
// one call for drawOp: a throw anywhere in the pixel body is counted, logged as the raid's render fault text and the vector body is drawn instead
function pixBodyTry(x,y,face,ph,coat,pk,muzzle,mode,iv,st){
  try{ return pixDrawOp(x,y,face,ph,coat,pk,muzzle,mode,iv,st); }
  catch(e){
    PIX.errs++; PIX.fall++;
    try{ wc.imageSmoothingEnabled=true; wc.globalCompositeOperation='source-over'; }catch(_r){}
    if(typeof G!=='undefined'&&G&&!G.drawErr){ G.drawErr='pixel pillager: '+(e&&e.message||e); if(G.tel) G.tel.drawErr=G.drawErr; }
    return false;
  }
}
pixReg('pillager looks 27',function(){ return pixBodySheet(0); });
pixReg('pillager bots 27',function(){ return pixBodySheet(1); });
function pixBenchOpen(){
'@

SubRx @'
  if(!figOn()) return drawOp0(x,y,face,ph,coat,pk,muzzle,mode,iv,st);
'@ @'
  if(!figOn()) return drawOp0(x,y,face,ph,coat,pk,muzzle,mode,iv,st);
  if(pixOn()&&pixBodyTry(x,y,face,ph,coat,pk,muzzle,mode,iv,st)) return;   // v33.58 (cw-pixbody): the pixel pillager; false draws the vector body below
'@

SubRx @'
var VER='33.57';
'@ @'
var VER='33.58';
'@

$pat = "(?m)^  now:'v33\.57:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.58: With the pixel look on, every plain pillager is a pixel figure with a pixel gun. Armour, hits, downed, fists and sets still draw the old figure. Check 33.58 fails on v33.57',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
