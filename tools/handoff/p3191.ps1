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

# CRYO BARREL ICE SLIDE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
cryo:{R:150,pd:14,pb:6,ed:30
'@ @'
cryo:{R:150,pd:0,pb:0,ed:30
'@

SubRx @'
damagePlayer(K.pd*(1-sd/R)+K.pb,'barrel',K.nm,x,y);
'@ @'
if(K.pd+K.pb>0) damagePlayer(K.pd*(1-sd/R)+K.pb,'barrel',K.nm,x,y);   // v31.91 (cw-iceslide), HIS ORDER (2026-10-19): "Ice should not hurt player": the cryo blast has no player damage (pd and pb are 0), the bodies keep theirs
'@

SubRx @'
cryo:{r:96,life:5,pl:2,src:'cold'
'@ @'
cryo:{r:96,life:5,pl:0,src:'cold'
'@

SubRx @'
if(tick&&p&&!p.specOut
'@ @'
if(tick&&Q.pl>0&&p&&!p.specOut
'@

SubRx @'
function brlDrawK(B){
'@ @'
// v31.91 (cw-iceslide), HIS ORDER (2026-10-19): "Player should slide across cold patches made by ice barrels, with limited direction change, like players feet are ice, ala
// Fortnite. Ice should not hurt player". THE FROST FOG LEAVES ICE. While a pillager's feet are on the ice sheet under a cryo fog (the ellipse it is drawn as, for the life of
// the fog) the walk is a slide: the ground velocity (p.iceVx, p.iceVy) steers toward the input only slowly (ICE_ACC run speeds a second, so a full turn about takes a second),
// the top glide is ICE_TOP times the run, and with no input it fades by only ICE_FRIC run speeds a second, so he keeps gliding. The step is cut into slices of 6 units and every
// slice goes through collide, so a slide never passes a wall; the velocity is then read back from the ground really covered, so a wall takes the part that ran into it. Off the
// ice the leftover momentum is gone in under 0.3 s (ICE_OFF run speeds a second toward the input), and off the ice with no momentum nothing here touches the walk. A roll or a
// fall ends the slide. The fog and the cryo blast do the player no harm (pl, pd and pb are 0). Nothing here draws a random number.
var ICE_TOP=1.2, ICE_ACC=2.4, ICE_FRIC=0.35, ICE_OFF=8, ICE_RY=0.6, ICE_FADE=1;
function iceStop(p){ p.iceSl=0; p.iceVx=0; p.iceVy=0; p.iceGl=0; p.iceSp=0; p.iceMv=0; }
function iceK(f){ return (f.t<=f.life-ICE_FADE)?1:Math.max(0,(f.life-f.t)/ICE_FADE); }
function iceUnder(p){
  var F=G&&G.bfire, i, f, R, dx, dy;
  if(!F||!F.length||!G.map) return null;
  for(i=0;i<F.length;i++){
    f=F[i];
    if(f.k!=='cryo'||!(f.t<f.life)) continue;
    R=f.r*Math.min(1,0.35+f.t/0.45);   // the sheet spreads over the first half second, as the fog does
    dx=(p.x-f.x)/(R+4); dy=(p.y-f.y)/(R*ICE_RY+3);
    if(dx*dx+dy*dy<1&&losClear(f.x,f.y,p.x,p.y,G.map.segs)) return f;
  }
  return null;
}
function iceStep(p,dt,tx,ty,spd){
  var f=(G&&G.bfire&&G.bfire.length)?iceUnder(p):null, vx=p.iceVx||0, vy=p.iceVy||0, a, dx, dy, d, sp, n, i, ox, oy;
  if(!f&&!p.iceSl){ p.iceVx=tx; p.iceVy=ty; p.iceGl=0; return false; }   // bare ground and no momentum: the walk as it always was (the step is kept for the moment the ice starts)
  if(!(dt>0)) return true;
  p.iceSl=1;
  if(f){
    tx*=ICE_TOP; ty*=ICE_TOP;
    if(tx||ty){
      a=ICE_ACC*spd*dt; dx=tx-vx; dy=ty-vy; d=Math.sqrt(dx*dx+dy*dy);
      if(d<=a){ vx=tx; vy=ty; } else { vx+=dx/d*a; vy+=dy/d*a; }
    } else {
      sp=Math.sqrt(vx*vx+vy*vy); a=ICE_FRIC*spd*dt;
      if(sp<=a){ vx=0; vy=0; } else { vx*=(sp-a)/sp; vy*=(sp-a)/sp; }
    }
  } else {
    a=ICE_OFF*spd*dt; dx=tx-vx; dy=ty-vy; d=Math.sqrt(dx*dx+dy*dy);
    if(d<=a){ p.iceSl=0; p.iceVx=tx; p.iceVy=ty; p.iceGl=0; p.iceSp=0; p.iceMv=0; return false; }   // control is back: the walk takes this step
    vx+=dx/d*a; vy+=dy/d*a;
  }
  ox=p.x; oy=p.y; sp=Math.sqrt(vx*vx+vy*vy);
  if(sp>0.01){
    n=Math.min(40,Math.max(1,Math.ceil(sp*dt/6)));
    for(i=0;i<n;i++){ p.x+=vx*dt/n; p.y+=vy*dt/n; collide(p,G.map.walls); }
    vx=(p.x-ox)/dt; vy=(p.y-oy)/dt; sp=Math.sqrt(vx*vx+vy*vy);
  }
  p.iceVx=vx; p.iceVy=vy; p.iceSp=sp; p.iceMv=Math.sqrt((p.x-ox)*(p.x-ox)+(p.y-oy)*(p.y-oy)); p.iceGl=(!tx&&!ty&&sp>30)?1:0;
  return true;
}
// v31.91 (cw-iceslide): THE ICE SHEET, a pale glossy sheet on the floor under the frost fog: a cold blue-white sheen, a few cracks and a glint or two, all from constants, the pool's
// position and the clock (no random draw, no gradient made in a frame: the soft white is the baked fog sprite). It fades out over the last second of the fog's life, which is also
// the moment the slide ends. It is its own item in the draw order, under the bodies (the fog cloud above it hangs over them).
var ICE_CR=(function(){
  var o=[], j, a, s, b, c, d, r1, r2;
  for(j=0;j<7;j++){
    a=0.4+j*0.8976; s=(j%2)?1:-1;
    b=a+0.30*s; c=b-0.11*s*((j%3)+1); r1=0.40+0.04*(j%3); r2=0.78+0.05*(j%2); d=b+0.9*((j%2)?-1:1);
    o.push(Math.cos(a)*0.08,Math.sin(a)*0.08, Math.cos(b)*r1,Math.sin(b)*r1, Math.cos(c)*r2,Math.sin(c)*r2, Math.cos(b)*r1+Math.cos(d)*0.17,Math.sin(b)*r1+Math.sin(d)*0.17);
  }
  return o;
})();
function brlIceDraw(f){
  var t=(G&&G.t)||0, k=iceK(f), R, ry, x=f.x, y=f.y, j, q, o, ph, a, rot, c, s, X, Y, ux, uy;
  if(k<=0) return;
  R=f.r*Math.min(1,0.35+f.t/0.45); ry=R*ICE_RY;
  rot=((f.x*0.0137+f.y*0.0071)%1)*6.2832; c=Math.cos(rot); s=Math.sin(rot);
  wc.save();
  wc.globalAlpha=0.36*k; wc.fillStyle='#8fc4e0'; wc.beginPath(); wc.ellipse(x,y,R,ry,0,0,6.2832); wc.fill();
  wc.globalAlpha=0.5*k; wc.drawImage(brlSpr('cryo'),x-R*0.95,y-ry*0.95,R*1.9,ry*1.9);
  wc.globalAlpha=0.22*k; wc.fillStyle='#eaf8ff'; wc.beginPath(); wc.ellipse(x-R*0.05,y-ry*0.07,R*0.78,ry*0.74,0,0,6.2832); wc.fill();
  wc.globalAlpha=0.4*k; wc.fillStyle='#ffffff';
  wc.beginPath(); wc.ellipse(x-R*0.3,y-ry*0.38,R*0.34,ry*0.07,-0.3,0,6.2832); wc.fill();
  wc.beginPath(); wc.ellipse(x+R*0.24,y+ry*0.3,R*0.2,ry*0.05,-0.3,0,6.2832); wc.fill();
  for(q=0;q<2;q++){   // the cracks: a dark line and a white one beside it
    o=q?-0.8:0.8; wc.strokeStyle=q?'#ffffff':'#4f8fb6'; wc.lineWidth=q?0.9:1.5; wc.globalAlpha=(q?0.62:0.4)*k; wc.beginPath();
    for(j=0;j<ICE_CR.length;j+=8){
      ux=ICE_CR[j]; uy=ICE_CR[j+1]; wc.moveTo(x+(ux*c-uy*s)*R+o,y+(ux*s+uy*c)*ry+o);
      ux=ICE_CR[j+2]; uy=ICE_CR[j+3]; X=x+(ux*c-uy*s)*R+o; Y=y+(ux*s+uy*c)*ry+o; wc.lineTo(X,Y);
      ux=ICE_CR[j+4]; uy=ICE_CR[j+5]; wc.lineTo(x+(ux*c-uy*s)*R+o,y+(ux*s+uy*c)*ry+o);
      wc.moveTo(X,Y); ux=ICE_CR[j+6]; uy=ICE_CR[j+7]; wc.lineTo(x+(ux*c-uy*s)*R+o,y+(ux*s+uy*c)*ry+o);
    }
    wc.stroke();
  }
  wc.globalAlpha=0.6*k; wc.strokeStyle='#ffffff'; wc.lineWidth=1.6; wc.beginPath(); wc.ellipse(x,y,R*0.985,ry*0.985,0,0,6.2832); wc.stroke();
  wc.globalAlpha=0.38*k; wc.strokeStyle='#7fb6d6'; wc.lineWidth=1; wc.beginPath(); wc.ellipse(x,y,R*0.9,ry*0.9,0,0,6.2832); wc.stroke();
  wc.fillStyle='#ffffff';
  for(j=0;j<5;j++){   // a few glints that come and go
    ph=(t*0.9+j*0.37+f.x*0.003)%1; a=rot+j*2.1;
    wc.globalAlpha=Math.sin(ph*3.1416)*0.85*k;
    wc.fillRect(x+Math.cos(a)*R*(0.3+0.1*j)-1.1,y+Math.sin(a)*ry*(0.3+0.1*j)-1.1,2.2,2.2);
  }
  wc.restore();
}
function brlDrawK(B){
'@

SubRx @'
DR.push({k:_bf.y+(_bf.k==='cryo'?60:(_bf.k==='acid'?-70:-30)),fn:brlFireDraw.bind(null,_bf)});
'@ @'
DR.push({k:_bf.y+(_bf.k==='cryo'?60:(_bf.k==='acid'?-70:-30)),fn:brlFireDraw.bind(null,_bf)}); if(_bf.k==='cryo') DR.push({k:_bf.y-84,fn:brlIceDraw.bind(null,_bf)});
'@

SubRx @'
p.x+=(mx/mg)*spd*ana*dt; p.y+=(my/mg)*spd*ana*dt; p.bob+=dt*(sprint?15:9); p.moving=true;
'@ @'
if(!iceStep(p,dt,(mx/mg)*spd*ana,(my/mg)*spd*ana,spd)){ p.x+=(mx/mg)*spd*ana*dt; p.y+=(my/mg)*spd*ana*dt; } p.bob+=dt*(sprint?15:9); p.moving=true;   // v31.91 (cw-iceslide): on ice the step is the slide's
'@

SubRx @'
} else { p.noiseAcc=0; p.moving=false; p.bob+=dt*1.2; T.tStill+=dt; collide(p,G.map.walls); }
'@ @'
} else { p.noiseAcc=0; p.moving=false; p.bob+=dt*1.2; if(iceStep(p,dt,0,0,spd)&&p.iceGl){ p.moving=true; T.distance+=p.iceMv; } else T.tStill+=dt; collide(p,G.map.walls); }   // v31.91 (cw-iceslide): and he glides on with no input
'@

SubRx @'
if(p.dbOn){ p.dbOn=0; p.dbSpent=0; p.dbLock=0; p.dbGainT=0; }
'@ @'
if(p.roll>0) iceStop(p);   // v31.91 (cw-iceslide): a roll takes over from the slide
  if(p.dbOn){ p.dbOn=0; p.dbSpent=0; p.dbLock=0; p.dbGainT=0; }
'@

SubRx @'
downBarTick(p,dt);
'@ @'
iceStop(p);   // v31.91 (cw-iceslide): and so does a fall
    downBarTick(p,dt);
'@

SubRx @'
if(!p.moving||p.downed||p.roll>0){ if(PSTEP<0) PSTEP=0; return; }
'@ @'
if(!p.moving||p.downed||p.roll>0||p.iceGl){ if(PSTEP<0) PSTEP=0; return; }   // v31.91 (cw-iceslide): a glide on ice makes no footsteps
'@

SubRx @'
var VER='31.90';
'@ @'
var VER='31.91';
'@

$pat = "(?m)^  now:'v31\.90:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.91: A cryo barrel now leaves a slick ice sheet under its frost fog: a pillager on it runs up to 1.2 times faster, steers slowly (a turn about takes a second), glides on with no input and is still stopped by walls, and neither the fog nor the cryo blast hurts him. Check 31.91 fails on v31.90',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
