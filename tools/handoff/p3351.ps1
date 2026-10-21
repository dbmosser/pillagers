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

# THE PIXEL LOOK SWITCH AND KIT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  // XF_ROWS_END
'@ @'
  ['xfPix','pixel look','pixel art','l'],   // v33.51 (cw-pixkit): job 86a, the pixel art pass. Local: each window has its own row; only he flips it
  // XF_ROWS_END
'@

SubRx @'
['extras',['xfNeed','xfHaul','xfShop','xfSeed']]
'@ @'
['extras',['xfNeed','xfHaul','xfShop','xfSeed','xfPix']]
'@

SubRx @'
// render hooks (one call each per drawn raid frame)
'@ @'
// v33.51 (cw-pixkit), HIS ORDERS (2026-10-20 22:45 to 23:05: "I want to do it all now before the party", pixel art like the style test): THE PIXEL KIT, job 86a. One switch (Settings,
// experimental, pixel look: CFG.xfPix, local, on by default, only he flips it) and pixOn() gates every pixel path the later jobs add; off is today's game, byte for byte. Nothing
// draws differently in this build. What is here: pixBlit (a baked art canvas to the screen on whole device pixels), PIXSTORE (byte capped LRU caches for sprites with a build budget
// and a nearest-pose fallback), the kit from the style test (4 tone ramps, banding toward the top left light, harden, a 1 px ink ring, silhouettes, a palette swap), the ramp tables
// as data, a pix row in the frame telemetry and the ?pixbench page. Rules for every user: shape with grit() and your own hashes only, never rr(); a miss draws the old vector art.
var PIX_ACT=1, PIX_ENV=2, PIX_INK='#16121c';   // world units per art px: actors and loot at 1, the scene at 2
var PIX={builds:0,bakeMs:0,hits:0,miss:0,refused:0,evict:0,errs:0,fall:0,fB:0,fMs:0,S:1,reg:{}};
function pixOn(){ return !!CFG&&CFG.xfPix!==0; }
var PIXSTORE={cap:{actors:24*1048576,scene:16*1048576},bytes:{actors:0,scene:0},m:{actors:new Map(),scene:new Map()},maxBuilds:2,maxMs:2};
function pixDropAll(){ var k; for(k in PIXSTORE.m){ PIXSTORE.m[k].clear(); PIXSTORE.bytes[k]=0; } }
gfxStore('pix',function(){ pixDropAll(); });   // a lost canvas context empties the caches with the other sprite stores
function pixNow(){ return (typeof performance!=='undefined')?performance.now():Date.now(); }
function pixFrame(){ PIX.fB=0; PIX.fMs=0; }   // once a drawn frame (gfxpBegin): the build budget starts over
function pixCanvas(w,h){
  var c=document.createElement('canvas'), x;
  c.width=w; c.height=h; x=c.getContext('2d',{willReadFrequently:true}); x.imageSmoothingEnabled=false;
  return {c:c,x:x,w:w,h:h};
}
// a finished sprite: the art canvas, its anchor (between the feet) in art px, and the world units one art px covers (PIX_ACT or PIX_ENV)
function pixSprite(c,ax,ay,d){ return {c:c,w:c.width,h:c.height,ax:ax||0,ay:ay||0,d:d||PIX_ACT,bytes:c.width*c.height*4,pre:null,kind:''}; }
function pixPre(spr,k){   // a nearest prescale to a whole factor, cached on the sprite, for the smooth step at a scale that is not whole
  var p, s;
  if(!spr.pre) spr.pre={};
  p=spr.pre[k];
  if(!p){
    s=pixCanvas(spr.c.width*k,spr.c.height*k); s.x.drawImage(spr.c,0,0,s.w,s.h); p=spr.pre[k]=s.c;
    spr.bytes+=s.w*s.h*4; if(spr.kind&&PIXSTORE.bytes[spr.kind]!==undefined) PIXSTORE.bytes[spr.kind]+=s.w*s.h*4;
  }
  return p;
}
// S = world scale x the sprite's world units per art px = device px per art px. The anchor lands on a whole device pixel. A whole S draws nearest; any other S draws a nearest
// prescale to ceil(S) and then a smooth step down, so only the edges blend. The smoothing flag is set on every call (a canvas resize resets it).
function pixBlit(spr,x,y,flip,c,S){
  var w, h, whole, src, dw, dh, dx, dy, ax;
  if(!spr||!spr.c) return false;
  c=c||wc; if(!c) return false;
  if(!(S>0)) S=ZOOM()*(spr.d||PIX_ACT);
  PIX.S=S; w=spr.c.width; h=spr.c.height; ax=spr.ax||0;
  whole=Math.abs(S-Math.round(S))<0.001;
  if(whole){ S=Math.round(S); src=spr.c; dw=w*S; dh=h*S; }
  else { src=pixPre(spr,Math.ceil(S)); dw=Math.round(w*S); dh=Math.round(h*S); }
  dx=Math.round(x-(flip?(w-ax):ax)*S); dy=Math.round(y-(spr.ay||0)*S);
  c.save(); c.setTransform(flip?-1:1,0,0,1,flip?dx+dw:dx,dy);
  c.imageSmoothingEnabled=!whole;
  c.drawImage(src,0,0,dw,dh);
  c.restore();
  return true;
}
function pixGet(kind,key){
  var m=PIXSTORE.m[kind], e=m.get(key);
  if(e){ m.delete(key); m.set(key,e); PIX.hits++; return e; }
  PIX.miss++; return null;
}
function pixPut(kind,key,e){
  var m=PIXSTORE.m[kind], old=m.get(key), k;
  if(old){ PIXSTORE.bytes[kind]-=old.bytes; m.delete(key); }
  e.kind=kind; e.key=key; e.bytes=e.bytes||(e.c.width*e.c.height*4);
  m.set(key,e); PIXSTORE.bytes[kind]+=e.bytes;
  while(PIXSTORE.bytes[kind]>PIXSTORE.cap[kind]&&m.size>1){   // least recently used out first, never the one just put
    k=m.keys().next().value; PIXSTORE.bytes[kind]-=m.get(k).bytes; m.delete(k); PIX.evict++;
  }
  return e;
}
// build a sprite (fn returns a pixSprite) unless this frame has already spent 2 builds or 2 ms: then null, and the caller uses pixNearest or its vector painter
function pixBuild(kind,key,fn,fam,pose){
  var t0, e, dt;
  if(PIX.fB>=PIXSTORE.maxBuilds||PIX.fMs>=PIXSTORE.maxMs){ PIX.refused++; return null; }
  t0=pixNow();
  try{ e=fn(); }catch(_pb){ PIX.errs++; return null; }
  if(!e||!e.c){ PIX.errs++; return null; }
  dt=pixNow()-t0; PIX.fB++; PIX.fMs+=dt; PIX.builds++; PIX.bakeMs+=dt;
  e.fam=fam||''; e.pose=+pose||0;
  return pixPut(kind,key,e);
}
function pixNearest(kind,fam,pose){   // the cached pose of the same family closest to the one wanted, or null
  var best=null, bd=1e9, d;
  PIXSTORE.m[kind].forEach(function(e){ if(e.fam===fam){ d=Math.abs(e.pose-pose); if(d<bd){ bd=d; best=e; } } });
  return best;
}
function pixFetch(kind,key,fn,fam,pose){
  var e=pixGet(kind,key)||pixBuild(kind,key,fn,fam,pose)||pixNearest(kind,fam,pose);
  if(!e) PIX.fall++;
  return e;
}
function pixTelRow(){
  return {builds:PIX.builds,ms:Math.round(PIX.bakeMs*10)/10,hits:PIX.hits,miss:PIX.miss,refused:PIX.refused,bytes:PIXSTORE.bytes.actors+PIXSTORE.bytes.scene,S:Math.round(PIX.S*100)/100};
}
// ---- the kit, from the style test (tools/handoff/art-survey/style-test): 4 tone ramps, banding toward the top left light, harden, ink ring, silhouettes, palette swap ----
function pixHsl(hex){
  var n=parseInt(hex.slice(1),16), r=(n>>16)/255, g=((n>>8)&255)/255, b=(n&255)/255, mx=Math.max(r,g,b), mn=Math.min(r,g,b), l=(mx+mn)/2, d=mx-mn, h=0, s=0;
  if(d>0){ s=d/(1-Math.abs(2*l-1)); h=mx===r?((g-b)/d)%6:mx===g?(b-r)/d+2:(r-g)/d+4; h*=60; if(h<0) h+=360; }
  return [h,s,l];
}
function pixHex(h,s,l){
  h=((h%360)+360)%360; s=Math.max(0,Math.min(1,s)); l=Math.max(0,Math.min(1,l));
  var c=(1-Math.abs(2*l-1))*s, x=c*(1-Math.abs((h/60)%2-1)), m=l-c/2, t=[[c,x,0],[x,c,0],[0,c,x],[0,x,c],[x,0,c],[c,0,x]][Math.floor(h/60)%6];
  return '#'+t.map(function(v){ var q=Math.round((v+m)*255).toString(16); return q.length<2?'0'+q:q; }).join('');
}
function pixToward(h,to,deg){ var d=((to-h+540)%360)-180; return h+Math.max(-deg,Math.min(deg,d)); }
// any base colour to 4 tones, light to deep: highlights lean warm, shades lean cool
function pixRamp(col){
  var q=pixHsl(String(col).toLowerCase()), h=q[0], s=q[1], l=q[2];
  return [pixHex(pixToward(h,50,8),s*1.1,l+0.12),String(col).toLowerCase(),pixHex(pixToward(h,260,7),s,l*0.66),pixHex(pixToward(h,260,14),s*0.85,l*0.4)];
}
// 4 tones between two lightness values (percent), the hue leaning warm at the top and cool at the bottom: the ramps of the scene keep to their value band
function pixBandRamp(col,lo,hi,sat,cool){
  var q=pixHsl(col), h=q[0], s=Math.min(1,q[1]*(sat||1)), i, out=[];
  for(i=0;i<4;i++) out.push(pixHex(pixToward(h,i<2?50:(cool||260),i===0?6:(i===1?2:(i===2?6:10))),s*(i===3?0.88:1),(hi-(hi-lo)*i/3)/100));
  return out;
}
// tone index per pixel (0 light .. 3 deep) from where it sits between the lit (top left) and the dark edge of its part; m is a Uint8Array mask, w by h
function pixTones(m,w,h,o){
  o=o||{};
  var lx=o.lx==null?-0.45:o.lx, ly=o.ly==null?-0.9:o.ly, n=Math.sqrt(lx*lx+ly*ly), b1=o.b1==null?0.2:o.b1, b2=o.b2==null?0.6:o.b2, b3=o.b3==null?0.86:o.b3, T=new Int8Array(w*h), x, y, u, d, t;
  lx/=n; ly/=n;
  function at(fx,fy){ var ix=Math.floor(fx), iy=Math.floor(fy); return ix>=0&&iy>=0&&ix<w&&iy<h&&m[iy*w+ix]; }
  for(y=0;y<h;y++) for(x=0;x<w;x++){
    if(!m[y*w+x]) continue;
    u=1; d=1;
    while(u<60&&at(x+0.5+lx*u,y+0.5+ly*u)) u++;
    while(d<60&&at(x+0.5-lx*d,y+0.5-ly*d)) d++;
    t=(u-0.5)/(u+d-1);
    T[y*w+x]=t<b1?0:t<b2?1:t<b3?2:3;
  }
  return T;
}
function pixHarden(s,cut){   // every pixel solid or clear: kills any soft edge from an arc, text or drawImage. Bake time only.
  var d=s.x.getImageData(0,0,s.w,s.h), p=d.data, k;
  cut=cut==null?128:cut;
  for(k=3;k<p.length;k+=4) p[k]=p[k]>=cut?255:0;
  s.x.putImageData(d,0,0); return s;
}
function pixSilhouette(src,col){   // the shape of a canvas in one colour, by composite: no readback
  var s=pixCanvas(src.width,src.height);
  s.x.drawImage(src,0,0); s.x.globalCompositeOperation='source-in'; s.x.fillStyle=col; s.x.fillRect(0,0,s.w,s.h); s.x.globalCompositeOperation='source-over';
  return s;
}
// the shape grown by one pixel all round in col: a canvas 2 wider and 2 taller, so the art sits at (1,1). diag adds the corners. Pass 0 for the ring alone (a hit flash, an elite ring).
function pixRing(src,col,diag,keepArt){
  var s=pixCanvas(src.width+2,src.height+2), sil=pixSilhouette(src,col||PIX_INK).c, o=[[0,1],[2,1],[1,0],[1,2]], i;
  if(diag) o.push([0,0],[2,0],[0,2],[2,2]);
  for(i=0;i<o.length;i++) s.x.drawImage(sil,o[i][0],o[i][1]);
  if(keepArt!==0) s.x.drawImage(src,1,1);
  return s;
}
function pixSwap(src,map){   // palette swap at bake time: map is {'#rrggbb':'#rrggbb'}; every other pixel is kept
  var s=pixCanvas(src.width,src.height), d, p, k, key, to={}, a;
  for(a in map){ if(Object.prototype.hasOwnProperty.call(map,a)){ k=parseInt(a.slice(1),16); to[(k>>16)+','+((k>>8)&255)+','+(k&255)]=parseInt(map[a].slice(1),16); } }
  s.x.drawImage(src,0,0); d=s.x.getImageData(0,0,s.w,s.h); p=d.data;
  for(k=0;k<p.length;k+=4){
    if(!p[k+3]) continue;
    key=p[k]+','+p[k+1]+','+p[k+2];
    if(to[key]!==undefined){ a=to[key]; p[k]=a>>16; p[k+1]=(a>>8)&255; p[k+2]=a&255; }
  }
  s.x.putImageData(d,0,0); return s.c;
}
// ---- the ramp tables, as data (86b ground and 86d walls and trees read these) ----
// value bands in lightness percent, kept from the district palette: floor 42-50, wall face 54-60, wall top 72-78, actors and loot 80-94. Night keeps the same order and the same gaps,
// lower (86j measures the night read and tunes these).
var PIX_BANDS={day:{floor:[42,50],wall:[54,60],top:[72,78],act:[80,94]},night:{floor:[16,22],wall:[24,30],top:[36,42],act:[52,66]}};
var PIXRAMPS={districts:{},plants:{},mb:{},skins:{}};
(function(){
  var i, d, t, nm, b, o;
  for(i=0;i<DISTRICTS.length;i++){
    d=DISTRICTS[i]; o=PIXRAMPS.districts[d.name]={};
    for(nm in PIX_BANDS){
      b=PIX_BANDS[nm]; t=(nm==='night');
      o[nm]={floor:pixBandRamp(d.floor,b.floor[0],b.floor[1],t?0.8:1,t?250:260),wall:pixBandRamp(d.wall,b.wall[0],b.wall[1],t?0.8:1,t?250:260),
             top:pixBandRamp(d.wallTop,b.top[0],b.top[1],t?0.8:1,t?250:260),act:pixBandRamp(d.accent,b.act[0],b.act[1],1,t?250:260)};
    }
  }
  PIXRAMPS.plants={leaf:['#a6c46a','#6f9a40','#4a7430','#2e4c26'],leafDry:['#d0b45e','#a88a3a','#7a6228','#4e3e1e'],bark:['#9a7a58','#70543a','#4c3828','#30241c'],bush:['#8cb452','#5c8a38','#3e6430','#284422']};
  PIXRAMPS.mb={gm:MBPAL.gm.slice(),ox:MBPAL.ox.slice(),och:pixRamp(MBPAL.och),brass:MBPAL.brass.slice(),steel:pixRamp(MBPAL.steel),ink:MBPAL.ink,ov:{gm:MBPAL_OV.gm.slice(),ox:MBPAL_OV.ox.slice(),brass:MBPAL_OV.brass.slice(),ink:MBPAL_OV.ink}};
  PIXRAMPS.skins={fair:['#fdd6b6','#eeb08a','#c87c5c','#8e4a3c'],tan:['#f0bc84','#d09460','#a26a42','#6a4030'],umber:['#c48a62','#946040','#683e2a','#42261e']};
})();
// ---- ?pixbench: every registered asset at 1x and 4x, and the ramp tables, on a plain page. pixReg(name, fn) registers an asset: fn() returns a pixSprite ----
function pixReg(nm,fn){ PIX.reg[nm]=fn; return nm; }
function pixBenchOpen(){
  var el=document.getElementById('pixbench'), nm, n=0, sp, row, lab, a, b, k, r, sw, g, q, ramps;
  if(el) el.remove();
  el=document.createElement('div'); el.id='pixbench';
  el.style.cssText='position:fixed;left:0;top:0;right:0;bottom:0;z-index:99999;background:'+PIX_INK+';color:#d8d0c8;font:14px monospace;overflow:auto;padding:16px';
  function lbl(t){ var d=document.createElement('div'); d.textContent=t; d.style.cssText='margin:10px 0 4px'; el.appendChild(d); }
  lbl('pixel bench: '+Object.keys(PIX.reg).length+' assets, art px 1x and 4x');
  for(nm in PIX.reg){
    n++; try{ sp=PIX.reg[nm](); }catch(_pe){ lbl(nm+': threw'); continue; }
    if(!sp||!sp.c){ lbl(nm+': nothing'); continue; }
    lbl(nm+'  '+sp.c.width+'x'+sp.c.height+'  '+(sp.d||PIX_ACT)+' world per art px');
    row=document.createElement('div'); row.style.cssText='display:flex;gap:24px;align-items:flex-end';
    for(k=1;k<=4;k+=3){ a=document.createElement('canvas'); a.width=sp.c.width*k; a.height=sp.c.height*k; a.getContext('2d').imageSmoothingEnabled=false; a.getContext('2d').drawImage(sp.c,0,0,a.width,a.height); row.appendChild(a); }
    el.appendChild(row);
  }
  if(!n) lbl('no pixel assets registered yet');
  lbl('ramps (light to deep)');
  ramps=[];
  for(nm in PIXRAMPS.districts) for(k in PIXRAMPS.districts[nm]) for(q in PIXRAMPS.districts[nm][k]) ramps.push([nm.toLowerCase()+' '+k+' '+q,PIXRAMPS.districts[nm][k][q]]);
  for(nm in PIXRAMPS.skins) ramps.push(['skin '+nm,PIXRAMPS.skins[nm]]);
  for(nm in PIXRAMPS.plants) ramps.push(['plant '+nm,PIXRAMPS.plants[nm]]);
  for(r=0;r<ramps.length;r++){
    g=document.createElement('div'); g.style.cssText='display:flex;align-items:center;gap:8px;margin:2px 0';
    sw=document.createElement('span'); sw.textContent=ramps[r][0]; sw.style.cssText='width:260px'; g.appendChild(sw);
    for(k=0;k<ramps[r][1].length;k++){ b=document.createElement('span'); b.style.cssText='width:36px;height:16px;background:'+ramps[r][1][k]; g.appendChild(b); }
    el.appendChild(g);
  }
  document.body.appendChild(el);
  return el;
}
try{ if(typeof location!=='undefined'&&/[?&]pixbench\b/.test(location.search||'')) addEventListener('load',function(){ pixBenchOpen(); }); }catch(_pq){}

// render hooks (one call each per drawn raid frame)
'@

SubRx @'
row.q=Math.round(gfxScaleNow()*100)/100;
'@ @'
row.q=Math.round(gfxScaleNow()*100)/100;
  row.pix=pixTelRow();   // v33.51 (cw-pixkit): builds, bake ms, hits, misses, bytes and the device scale S
'@

SubRx @'
function gfxpBegin(){

'@ @'
function gfxpBegin(){
  pixFrame();   // v33.51 (cw-pixkit): the pixel build budget starts over each drawn frame

'@

SubRx @'
var VER='33.50';
'@ @'
var VER='33.51';
'@

$pat = "(?m)^  now:'v33\.50:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.51: A new experimental row, pixel look, is in Settings. The art kit for the pixel look is in the build; nothing on screen changes yet. Check 33.51 fails on v33.50',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
