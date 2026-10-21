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

# PIXEL EFFECTS AND MEDALLIONS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var SCARMAX=6000;
'@ @'
// v28.xx (cw-cx-pixfx): "I want to do it all now before the party" (10-20), a34 B and a35 B. Art pixels only; existing motion, lifetimes, damage, muzzle flashes and tracers.
function pixFxSquare(c,x,y,s,col){
  s=Math.max(1,Math.round(s/PIX_ACT))*PIX_ACT;c.fillStyle=col;
  c.fillRect(Math.round((x-s/2)/PIX_ACT)*PIX_ACT,Math.round((y-s/2)/PIX_ACT)*PIX_ACT,s,s);
}
function pixFxSpark(sp){
  pixFxSquare(wc,sp.x,sp.y-7.8,sp.z||3.4,sp.c);
  if(sp.c!==BLOOD_SPRAY&&!sp.nc)pixFxSquare(wc,sp.x,sp.y-7.8,1.6,'#ffe9a8');
}
function pixFxPuff(q){
  var r=4+q.t/q.life*(q.r||14), s=Math.max(2,Math.round(r));
  pixFxSquare(wc,q.x,q.y-10,s,q.c);
  pixFxSquare(wc,q.x-s*.45,q.y-10+s*.18,Math.max(1,s*.7),q.c);
  pixFxSquare(wc,q.x+s*.35,q.y-10-s*.28,Math.max(1,s*.65),q.c);
}
// v28.xx (cw-cx-pixfx): filled and stroked ovals made of whole rows; no canvas arcs, antialiasing or readbacks.
function pixFxOval(c,x,y,rx,ry,lw,E){
  E=E||1;x=Math.round(x/E)*E;y=Math.round(y/E)*E;
  rx=Math.max(1,Math.round(rx/E));ry=Math.max(1,Math.round(ry/E));lw=Math.max(0,Math.round((lw||0)/E));
  var yy,hw,ih,ir=Math.max(0,rx-lw),jr=Math.max(0,ry-lw);
  for(yy=-ry;yy<=ry;yy++){
    hw=Math.floor(rx*Math.sqrt(Math.max(0,1-yy*yy/((ry+.5)*(ry+.5)))));
    if(!lw||!ir||!jr||Math.abs(yy)>jr)c.fillRect(x-hw*E,y+yy*E,(hw*2+1)*E,E);
    else{
      ih=Math.floor(ir*Math.sqrt(Math.max(0,1-yy*yy/((jr+.5)*(jr+.5)))));
      if(ih<hw){c.fillRect(x-hw*E,y+yy*E,(hw-ih)*E,E);c.fillRect(x+(ih+1)*E,y+yy*E,(hw-ih)*E,E);}
    }
  }
}
function pixFxLine(c,x,y,x1,y1,E){
  x=Math.round(x/E);y=Math.round(y/E);x1=Math.round(x1/E);y1=Math.round(y1/E);
  var dx=Math.abs(x1-x),dy=-Math.abs(y1-y),sx=x<x1?1:-1,sy=y<y1?1:-1,e=dx+dy,e2;
  for(;;){c.fillRect(x*E,y*E,E,E);if(x===x1&&y===y1)break;e2=2*e;if(e2>=dy){e+=dy;x+=sx;}if(e2<=dx){e+=dx;y+=sy;}}
}
function pixFxRing(c,x,y,rx,ry,lw,col){
  var T=c.getTransform(),E=PIX_ACT,r=Math.max(1,Math.round(rx/E)),h=Math.max(1,Math.round(ry/E)),w=Math.max(1,Math.round(lw/E)),key='fxring|'+r+'|'+h+'|'+w+'|'+col,sp;
  if(!(T.a>0)||!(T.d>0)||T.b||T.c||Math.abs(T.a-T.d)>0.00001)return false;
  sp=pixFetch('scene',key,function(){var s=pixCanvas(2*r+5,2*h+5);s.x.fillStyle=col;pixFxOval(s.x,r+2,h+2,r,h,w,1);return pixSprite(s.c,r+2,h+2,E);},key,0);
  return !!sp&&pixBlit(sp,T.a*x+T.e,T.d*y+T.f,false,c,T.a*E);
}
function pixSeatRing(x,y,seat){
  var col=SEATCOL[seat&3],key='seat|'+(seat&3),T=wc.getTransform(),sp;
  if(!(T.a>0)||!(T.d>0)||T.b||T.c||Math.abs(T.a-T.d)>0.00001)return false;
  sp=pixFetch('actors',key,function(){
    var s=pixCanvas(37,29),c=s.x;c.fillStyle=col;c.globalAlpha=.14;pixFxOval(c,18,10,14,6,0,1);
    c.globalAlpha=.85;c.fillStyle=INK;pixFxOval(c,18,10,15,7,4,1);c.globalAlpha=1;c.fillStyle=col;pixFxOval(c,18,10,14,6,2,1);
    c.fillStyle=INK;pixFxOval(c,18,18,5,5,0,1);c.fillStyle=col;pixFxOval(c,18,18,4,4,0,1);
    return pixSprite(s.c,18,9,PIX_ACT);
  },key,0);
  if(!sp)return false;pixBlit(sp,T.a*x+T.e,T.d*y+T.f,false,wc,T.a);
  wc.fillStyle='#10151b';wc.font='700 6.6px "Barlow Condensed","Bahnschrift SemiCondensed","Arial Narrow",sans-serif';wc.textAlign='center';wc.fillText(String((seat&3)+1),Math.round(x),Math.round(y+10.6));wc.textAlign='left';return true;
}
function pixScarPaint(c,s){
  var E=PIX_ENV,r=s.r,x=Math.round(s.x/E)*E,y=Math.round(s.y/E)*E,a=s.a,i,ang,len,q,px,py,n,xx,yy;
  c.save();try{
    c.globalCompositeOperation='source-over';
    if(s.k==='scorch'){
      for(i=0;i<4;i++){c.globalAlpha=a*[.13,.17,.24,.29][i];c.fillStyle=['#211a18','#1a1412','#120e0c','#090708'][i];pixFxOval(c,x,y,r*(1-i*.18),r*.86*(1-i*.18),0,E);}
    }else if(s.k==='crack'){
      c.globalAlpha=.62*a;c.fillStyle='#0a0808';n=4+Math.floor(scarH(s.s,1)*4);
      for(i=0;i<n;i++){
        ang=i/n*6.2832+scarH(s.s,i+10)*.9;len=r*(.55+.6*scarH(s.s,i+20));px=x;py=y;
        for(q=1;q<=3;q++){var aa=ang+(scarH(s.s,i*5+q+30)-.5)*.8;xx=px+Math.cos(aa)*len/3;yy=py+Math.sin(aa)*len/3*.86;pixFxLine(c,px,py,xx,yy,E);px=xx;py=yy;}
      }
    }else if(s.k==='debris'){
      n=Math.max(3,Math.min(18,Math.round(r/2)));c.globalAlpha=a;
      for(i=0;i<n;i++){ang=scarH(s.s,i)*6.2832;len=r*Math.sqrt(scarH(s.s,i+50));q=Math.max(E,Math.round((1.2+2.8*scarH(s.s,i+90))/E)*E);px=Math.round((x+Math.cos(ang)*len)/E)*E;py=Math.round((y+Math.sin(ang)*len*.8)/E)*E;c.fillStyle='#161218';c.fillRect(px+E,py+E,q,q);c.fillStyle=s.c||'#5c5854';c.fillRect(px,py,q,q);}
    }else if(s.k==='brass'){c.globalAlpha=.9*a;c.fillStyle=s.c||'#b08c3c';c.fillRect(x-E,y,2*E,E);}
  }finally{c.restore();}
}
function pixFxBake(kind){
  var smoke=kind==='smoke',s=pixCanvas(smoke?28:52,smoke?28:44),c=s.x,x=s.w/2,y=s.h/2,i;
  var pal=smoke?['#504e4c','#68625c','#827a70','#968e84']:['#7a2410','#c84618','#ff963c','#ffd68c'];
  for(i=0;i<4;i++){c.fillStyle=pal[i];pixFxOval(c,x-i,y-i,smoke?12-i*2:24-i*5,smoke?11-i*2:19-i*4,0,1);}
  return pixSprite(s.c,x,y,PIX_ACT);
}
function pixFxImage(kind,x,y,r){
  var T=wc.getTransform(),key='fx|'+kind,sp=pixFetch('actors',key,function(){return pixFxBake(kind);},key,0),S=Math.max(1,Math.round(r/(kind==='smoke'?12:24)));
  if(!sp)return false;
  return pixBlit(sp,T.a*x+T.e,T.d*y+T.f,false,wc,T.a*S);
}
function pixBoomDraw(){
  var n=0,Z=ZOOM(),i,j,b,t,d,q,x,y,z,a,k,R,f,sp,vx0=VX-240,vy0=VY-120,vx1=VX+W/Z+240,vy1=VY+H/Z+300;
  for(i=BOOMS.length-1;i>=0;i--){
    b=BOOMS[i];t=(G.t||0)-b.t0;if(b.g!==G||t>4.6||t<-2){BOOMS.splice(i,1);continue;}if(t<0||b.x<vx0||b.x>vx1||b.y<vy0||b.y>vy1)continue;
    wc.save();try{
      wc.globalCompositeOperation='source-over';
      for(j=0;j<b.deb.length;j++){
        d=b.deb[j];q=Math.min(t,d.tl);x=b.x+d.ux*d.sp*q;y=b.y+d.uy*d.sp*q*.62;z=t<d.tl?d.vz*t-260*t*t:0;a=t<2.4?1:Math.max(0,1-(t-2.4)/1.1);if(a<=0)continue;wc.globalAlpha=a;
        if(z>1)pixFxSquare(wc,x,y,Math.max(1,d.r*.6),'rgba(0,0,0,.35)');
        pixFxSquare(wc,x,y-z,d.r,t<.5?'#ffa04e':d.c);n++;
      }
      if(t<.42){
        k=Math.min(1,t/.35);R=b.s*(24+44*Math.sqrt(k));a=t<.06?1:Math.max(0,1-Math.pow((t-.06)/.36,1.3));wc.globalCompositeOperation='lighter';wc.globalAlpha=a;
        if(!pixFxImage('fire',b.x,b.y-14,R*1.5))pixFxSquare(wc,b.x,b.y-14,R,'#ff963c');n++;
      }
      if(t<.22){k=t/.22;R=boomRingR(b,k);wc.globalCompositeOperation='source-over';wc.globalAlpha=.5*(1-k);pixFxRing(wc,b.x,b.y,R,R*.58,1+3*(1-k),'#ffe2b8');n++;}
      wc.globalCompositeOperation='source-over';
      for(j=0;j<b.smoke.length;j++){
        sp=b.smoke[j];q=t-sp.d;f=q/sp.life;if(f<=0||f>=1)continue;R=sp.r*(.55+.95*f);wc.globalAlpha=.8*Math.pow(1-f,1.15)*Math.min(1,q*5);x=b.x+sp.ox+sp.vx*q;y=b.y+sp.oy-(8+sp.vz*q*(1-.3*f));
        if(!pixFxImage('smoke',x,y,R))pixFxSquare(wc,x,y,R,'#827a70');n++;
      }
    }finally{wc.restore();}
  }
  return n;
}
function pixPwrBake(kind,turn){
  var D=pwrDef(kind),R=Math.round(PWRI.R),s=pixCanvas(R*2+2,R*2+2),c=s.x,x,y,dx,dy,edge,col,cx=R+1,i,w,out;
  var pal=pixRamp(D.hex);
  for(y=1;y<s.h-1;y++)for(x=1;x<s.w-1;x++){
    dx=Math.abs(x-cx+.5);dy=Math.abs(y-cx+.5);if(Math.max(dx,dy)>R||dx+dy>R*1.62)continue;
    edge=Math.max(dx,dy)>R-3||dx+dy>R*1.62-4;
    col=edge?pal[(x+y<cx*2)?0:2]:((x+y<cx*2)?'#2b3137':'#0e1114');c.fillStyle=col;c.fillRect(x,y,1,1);
  }
  pwrGlyph(c,kind,cx,cx,R*.5,D,1);pixHarden(s);
  w=Math.round(s.w*(.5+turn/6));if(w%2)w++;out=pixCanvas(w,s.h);out.x.drawImage(s.c,0,0,w,s.h);
  return pixSprite(out.c,w/2,cx,PIX_ACT);
}
function pixPwrMedallion(c,kind,x,y,R,sxk){
  var T=c.getTransform(),turn=Math.max(0,Math.min(3,Math.round((sxk-.5)*6))),key='pwr|'+kind+'|'+turn,sp;
  if(!(T.a>0)||!(T.d>0)||T.b||T.c||Math.abs(T.a-T.d)>0.00001)return false;
  sp=pixFetch('actors',key,function(){return pixPwrBake(kind,turn);},'pwr|'+kind,turn);
  return !!sp&&pixBlit(sp,T.a*x+T.e,T.d*y+T.f,false,c,T.a*R/PWRI.R);
}
var SCARMAX=6000;
'@

SubRx @'
function scarPaint(c,s){
'@ @'
function scarPaint(c,s){
  if(pixOn()){pixScarPaint(c,s);return;} // v28.xx (cw-cx-pixfx): stamp at the ground art density
'@

SubRx @'
function gfxBoomDraw(){
  if(!BOOMS.length) return 0;
'@ @'
function gfxBoomDraw(){
  if(pixOn())return pixBoomDraw(); // v28.xx (cw-cx-pixfx)
  if(!BOOMS.length) return 0;
'@

SubRx @'
    var _sz=sp.z||3.4;
'@ @'
    if(pixOn()){pixFxSpark(sp);continue;} // v28.xx (cw-cx-pixfx): blood, sparks and chips share the whole-unit path
    var _sz=sp.z||3.4;
'@

SubRx @'
    wc.globalAlpha=a2*.55; wc.fillStyle=q.c;
    wc.beginPath(); wc.arc(q.x,q.y-10,4+(1-a2)*(q.r||14),0,6.2832); wc.fill();
'@ @'
    wc.globalAlpha=a2*.55; wc.fillStyle=q.c;
    if(pixOn())pixFxPuff(q); // v28.xx (cw-cx-pixfx)
    else{wc.beginPath(); wc.arc(q.x,q.y-10,4+(1-a2)*(q.r||14),0,6.2832); wc.fill();}
'@

SubRx @'
function drawSeatRing(x,y,s){
'@ @'
function drawSeatRing(x,y,s){
  if(pixOn()&&pixSeatRing(x,y,s))return; // v28.xx (cw-cx-pixfx)
'@

SubRx @'
    wc.beginPath(); wc.arc(z.x,z.y,z.r,0,6.2832); wc.stroke();
'@ @'
    if(!(pixOn()&&pixFxRing(wc,z.x,z.y,z.r,z.r,act?3:2,act?'#4de3d0':'rgba(148,152,158,.38)'))){wc.beginPath(); wc.arc(z.x,z.y,z.r,0,6.2832); wc.stroke();} // v28.xx (cw-cx-pixfx)
'@

SubRx @'
function pxBuildDownRing(){
  var s=pixCanvas(40,16), sp;
  s.x.imageSmoothingEnabled=true; s.x.strokeStyle='#ff4a3a'; s.x.lineWidth=2; s.x.beginPath(); s.x.ellipse(20,8,18,7,0,0,6.2832); s.x.stroke();
  pixHarden(s,100); sp=pixSprite(s.c,20,8,PIX_ACT); sp.ring=1;
  return sp;
}
'@ @'
function pxBuildDownRing(){
  // v28.xx (cw-cx-pixfx): the downed ring is stroked as whole art rows, without a readback.
  var s=pixCanvas(40,18),sp;s.x.fillStyle='#ff4a3a';pixFxOval(s.x,20,9,18,7,2,1);sp=pixSprite(s.c,20,9,PIX_ACT);sp.ring=1;return sp;
}
'@

SubRx @'
    c.save(); c.translate(s.x,cy); c.scale(sxk,1);
    gr=c.createLinearGradient(-R,-R,R,R); gr.addColorStop(0,'rgba(255,255,255,.95)'); gr.addColorStop(0.35,D.hex); gr.addColorStop(1,'rgba('+D.rgb+',.5)');
    c.fillStyle=gr; styOct(c,R,R*0.38); c.fill();
    gr=c.createRadialGradient(0,-R*0.2,R*0.1,0,0,R*0.85); gr.addColorStop(0,'#2b3137'); gr.addColorStop(1,'#0e1114');
    c.fillStyle=gr; styOct(c,R*0.8,R*0.3); c.fill(); c.strokeStyle='rgba('+D.rgb+',.75)'; c.lineWidth=1.5*z; c.stroke();
    pwrGlyph(c,it.k,0,0,R*0.5,D,z);
    u=((t*0.4+it.id*0.31)%1.6)/1.6;
    if(u<1){ c.save(); styOct(c,R,R*0.38); c.clip(); c.rotate(-0.55); gr=c.createLinearGradient(-R*0.35+(u-0.5)*R*4.6,0,R*0.35+(u-0.5)*R*4.6,0); gr.addColorStop(0,'rgba(255,255,255,0)'); gr.addColorStop(0.5,'rgba(255,255,255,.55)'); gr.addColorStop(1,'rgba(255,255,255,0)'); c.fillStyle=gr; c.fillRect(-R*3,-R*3,R*6,R*6); c.restore(); }
    c.restore();
    dd=Math.hypot
'@ @'
    // v28.xx (cw-cx-pixfx): one per-kind baked medallion on the HUD; the vector version remains the cold-cache fallback.
    if(!(pixOn()&&pixPwrMedallion(c,it.k,s.x,cy,R,sxk))){
    c.save(); c.translate(s.x,cy); c.scale(sxk,1);
    gr=c.createLinearGradient(-R,-R,R,R); gr.addColorStop(0,'rgba(255,255,255,.95)'); gr.addColorStop(0.35,D.hex); gr.addColorStop(1,'rgba('+D.rgb+',.5)');
    c.fillStyle=gr; styOct(c,R,R*0.38); c.fill();
    gr=c.createRadialGradient(0,-R*0.2,R*0.1,0,0,R*0.85); gr.addColorStop(0,'#2b3137'); gr.addColorStop(1,'#0e1114');
    c.fillStyle=gr; styOct(c,R*0.8,R*0.3); c.fill(); c.strokeStyle='rgba('+D.rgb+',.75)'; c.lineWidth=1.5*z; c.stroke();
    pwrGlyph(c,it.k,0,0,R*0.5,D,z);
    u=((t*0.4+it.id*0.31)%1.6)/1.6;
    if(u<1){ c.save(); styOct(c,R,R*0.38); c.clip(); c.rotate(-0.55); gr=c.createLinearGradient(-R*0.35+(u-0.5)*R*4.6,0,R*0.35+(u-0.5)*R*4.6,0); gr.addColorStop(0,'rgba(255,255,255,0)'); gr.addColorStop(0.5,'rgba(255,255,255,.55)'); gr.addColorStop(1,'rgba(255,255,255,0)'); c.fillStyle=gr; c.fillRect(-R*3,-R*3,R*6,R*6); c.restore(); }
    c.restore();
    }
    dd=Math.hypot
'@

SubRx @'
var VER='33.93';
'@ @'
var VER='33.94';
'@

$pat = "(?m)^  now:'v33\.93:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.94: Sparks, blood, smoke and blasts use art pixels. Power-up coins are cached on the sharp HUD canvas. Check 33.94 fails on v33.93',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
