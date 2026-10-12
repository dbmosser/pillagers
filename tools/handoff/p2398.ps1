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

# EXPLOSIONS BURST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HID={w:null,lastRaf:0,fromWorker:0,ticks:0};
'@ @'
// ===== GFX-E: effects and atmosphere (the graphics program, batch E: gfx30 to gfx37) =====
// v23.xx (gfx30), HIS ORDER 2026-10-12 ("add ALL of this stuff", item 13, bigger explosions; his answer 20: gritty and grounded, like
// ARC Raiders): THE EXPLOSION MODULE. A frag charge or a Howler shell going off was an orange spark spray, one puff disc and the light
// flash: no fire, no body, nothing that hung in the air after. boomFx (the gfx2 hook, called on every window that shows the burst and
// never in a bot raid) now records one explosion in BOOMS, a render list of at most 6, and the air pass (gfxAir, after the death
// animations) draws it from its age in raid time:
// - a fireball: three baked radial sprites (gfxESprites, made once, kept in the store registry), swelling over 0.35 s, additive;
// - a shockwave: one stroked ellipse growing out in 0.22 s;
// - a smoke column: 8 to 14 baked puffs that rise, drift and spread for 2.5 to 4 s;
// - flying debris: 8 to 16 chunks thrown on arcs that land, lie and fade by 3.5 s, with a ground dot under each one in the air.
// Every random number is from the cosmetic stream (fxn), never the raid dice; nothing here is read by the sim; the light flash, the
// decal and the damage are untouched. Effects LOW (fxLevel 0) throws fewer pieces. GFX.bypass draws none of it.
var BOOMS=[];
function gfxESprites(){
  var st=gfxStore('gfxE'), m=st.m, c, x, gr;
  if(m.fire) return m;
  c=document.createElement('canvas'); c.width=c.height=128; x=c.getContext('2d');
  gr=x.createRadialGradient(64,64,0,64,64,64);
  gr.addColorStop(0,'rgba(255,214,140,1)'); gr.addColorStop(0.3,'rgba(255,150,60,.85)'); gr.addColorStop(0.6,'rgba(200,70,20,.45)');
  gr.addColorStop(0.85,'rgba(110,30,10,.15)'); gr.addColorStop(1,'rgba(60,15,5,0)');
  x.fillStyle=gr; x.fillRect(0,0,128,128); m.fire=c;
  c=document.createElement('canvas'); c.width=c.height=64; x=c.getContext('2d');
  gr=x.createRadialGradient(32,32,0,32,32,32);
  gr.addColorStop(0,'rgba(255,252,236,1)'); gr.addColorStop(0.45,'rgba(255,226,150,.8)'); gr.addColorStop(1,'rgba(255,170,80,0)');
  x.fillStyle=gr; x.fillRect(0,0,64,64); m.core=c;
  c=document.createElement('canvas'); c.width=c.height=64; x=c.getContext('2d');
  gr=x.createRadialGradient(30,28,0,32,32,32);
  gr.addColorStop(0,'rgba(150,142,132,.95)'); gr.addColorStop(0.5,'rgba(118,112,104,.7)'); gr.addColorStop(0.8,'rgba(92,88,84,.3)'); gr.addColorStop(1,'rgba(80,78,76,0)');
  x.fillStyle=gr; x.fillRect(0,0,64,64); m.smoke=c;
  return m;
}
function boomFx(x,y,size,kind){
  if(!gfxHook('boom')) return false;
  x=+x; y=+y; if(!isFinite(x)||!isFinite(y)) return false;
  var s=clamp(+size||1,0.3,2.5), thin=(CFG.fxLevel===0), i, n, a, vz, cs=['#2b2723','#38322b','#4a4036','#221f1c','#57504a'];
  var b={g:G,x:x,y:y,s:s,kind:String(kind||''),t0:G.t||0,deb:[],smoke:[]};
  n=thin?5:clamp(Math.round(8+4*s),8,16);
  for(i=0;i<n;i++){
    a=fxn(0,6.2832); vz=fxn(80,200);
    b.deb.push({ux:Math.cos(a),uy:Math.sin(a),sp:fxn(50,170)*Math.sqrt(s),vz:vz,tl:vz/260,r:fxn(2.6,5.2)*Math.min(1.4,0.7+0.3*s),c:cs[i%cs.length]});
  }
  n=thin?5:clamp(Math.round(7+4*s),8,14);
  for(i=0;i<n;i++){
    a=fxn(0,6.2832);
    b.smoke.push({ox:Math.cos(a)*fxn(3,20)*s,oy:Math.sin(a)*fxn(2,11)*s,vx:fxn(-6,10),vz:fxn(26,50)*(0.7+0.3*s),r:fxn(15,26)*s,d:fxn(0.06,0.4),life:fxn(2.5,4)});
  }
  if(BOOMS.length>=6) BOOMS.shift();
  BOOMS.push(b);
  return true;
}
function gfxBoomDraw(){
  if(!BOOMS.length) return 0;
  var i, j, b, t, k, R, sp, d, q, f, x0, y0, z, a, al, n=0, Z=ZOOM(), m=gfxESprites();
  var vx0=VX-240, vy0=VY-120, vx1=VX+W/Z+240, vy1=VY+H/Z+300;
  for(i=BOOMS.length-1;i>=0;i--){
    b=BOOMS[i]; t=(G.t||0)-b.t0;
    if(b.g!==G||t>4.6||t<-2){ BOOMS.splice(i,1); continue; }
    if(t<0||b.x<vx0||b.x>vx1||b.y<vy0||b.y>vy1) continue;
    wc.save();
    try{
      wc.globalCompositeOperation='source-over';
      for(j=0;j<b.deb.length;j++){
        d=b.deb[j]; q=Math.min(t,d.tl);
        x0=b.x+d.ux*d.sp*q; y0=b.y+d.uy*d.sp*q*0.62;
        z=(t<d.tl)?(d.vz*t-260*t*t):0;
        al=(t<2.4)?1:Math.max(0,1-(t-2.4)/1.1);
        if(al<=0) continue;
        wc.globalAlpha=al;
        if(z>1){ wc.fillStyle='rgba(0,0,0,.35)'; wc.fillRect(x0-d.r*0.6,y0-0.8,d.r*1.2,1.6); }
        wc.fillStyle=(t<0.5)?'#ffa04e':d.c; wc.fillRect(x0-d.r*0.5,y0-z-d.r*0.4,d.r,d.r*0.8);
        wc.fillStyle=(t<0.5)?'#ffe0a8':'rgba(170,160,146,.55)'; wc.fillRect(x0-d.r*0.5,y0-z-d.r*0.4,d.r,Math.max(0.8,d.r*0.22));
        n++;
      }
      if(t<0.42){
        k=Math.min(1,t/0.35); R=b.s*(24+44*Math.sqrt(k)); a=(t<0.06)?1:Math.max(0,1-Math.pow((t-0.06)/0.36,1.3));
        wc.globalCompositeOperation='lighter';
        wc.globalAlpha=0.5*a; wc.drawImage(m.fire,b.x-R*1.5,b.y-10-R*1.2,R*3,R*2.4);
        wc.globalAlpha=0.9*a; wc.drawImage(m.fire,b.x-R,b.y-14-R*0.85,R*2,R*1.7);
        wc.globalAlpha=a; wc.drawImage(m.core,b.x-R*0.5,b.y-18-R*0.45,R,R*0.9);
        n+=3;
      }
      if(t<0.22){
        k=t/0.22; R=b.s*(20+100*k);
        wc.globalCompositeOperation='source-over'; wc.globalAlpha=0.5*(1-k); wc.strokeStyle='#ffe2b8'; wc.lineWidth=1+3*(1-k);
        wc.beginPath(); wc.ellipse(b.x,b.y,R,R*0.58,0,0,6.2832); wc.stroke(); n++;
      }
      wc.globalCompositeOperation='source-over';
      for(j=0;j<b.smoke.length;j++){
        sp=b.smoke[j]; q=t-sp.d; f=q/sp.life; if(f<=0||f>=1) continue;
        R=sp.r*(0.55+0.95*f);
        wc.globalAlpha=0.8*Math.pow(1-f,1.15)*Math.min(1,q*5);
        wc.drawImage(m.smoke,b.x+sp.ox+sp.vx*q-R,b.y+sp.oy-(8+sp.vz*q*(1-0.3*f))-R,R*2,R*2);
        n++;
      }
    } finally { wc.restore(); }
  }
  return n;
}
// The air pass of batch E: one call a drawn raid frame, in the world transform, after the bodies and the death animations.
function gfxAir(dt){
  if(!gfxHook('air')) return 0;
  var n=0;
  try{ n+=gfxBoomDraw(); }catch(_gbd){}
  return n;
}
// ===== GFX-E end =====
var HID={w:null,lastRaf:0,fromWorker:0,ticks:0};
'@

SubRx @'
function boomFx(x,y,size,kind){ return gfxHook('boom'); }   // C: fireball, shockwave, smoke column, debris
'@ @'
// boomFx: the explosion module, in GFX-E (gfx30)
'@

SubRx @'
  try{ gfxBodyFx(dt); }catch(_gbf){}   // v23.xx (gfx2): body and air effects hook
'@ @'
  try{ gfxBodyFx(dt); }catch(_gbf){}   // v23.xx (gfx2): body and air effects hook
  try{ gfxAir(dt); }catch(_gae){}   // v23.xx (gfx30): batch E air pass (explosions)
'@

SubRx @'
var VER='23.97';
'@ @'
var VER='23.98';
'@

$pat = "(?m)^  now:'v23\.97:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.98: Explosions burst: fireball, shockwave, smoke column and flying debris. Check 23.98 fails on v23.97',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
