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

# THE PIXEL GROUND (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  var g=document.createElement('canvas'); g.width=WORLD_W; g.height=WORLD_H;
'@ @'
  // v28.xx (cw-cx-pixground), HIS ORDER (2026-10-20 22:45 to 23:05, the pixel pass): with the pixel look on this SAME code runs into a canvas scaled 1/PIX_ENV, so every rr() draw stays in its old order and the stream does not move. COLD STORAGE is 2100x1700 (about 14 MB) instead of about 57.
  var _px=arguments[1]===undefined?pixOn():!!arguments[1], _t0=pixNow(), _lw=_px?PIX_ENV:1, g=document.createElement('canvas'); g.width=_px?Math.ceil(WORLD_W/PIX_ENV):WORLD_W; g.height=_px?Math.ceil(WORLD_H/PIX_ENV):WORLD_H;
'@

SubRx @'
  var c=g.getContext('2d'),i,j,k;
'@ @'
  var c=g.getContext('2d',_px?{willReadFrequently:true}:undefined),i,j,k;   // v28.xx (cw-cx-pixground):  the pixel bake is posterized from CPU memory in chunks, so it is read often
  if(_px) c.scale(1/PIX_ENV,1/PIX_ENV);
'@

SubRx @'
c.strokeStyle='rgba(20,16,24,.5)'; c.lineWidth=1.4;
'@ @'
c.strokeStyle='rgba(20,16,24,.5)'; c.lineWidth=_px?PIX_ENV:1.4;
'@

SubRx @'
c.strokeStyle='rgba(0,0,0,.28)'; c.lineWidth=1;
'@ @'
c.strokeStyle='rgba(0,0,0,.28)'; c.lineWidth=_lw;   // v28.xx (cw-cx-pixground): one art pixel wide in the pixel look, so the floor lines survive the posterize
'@

SubRx @'
c.save(); c.globalAlpha=(_bf===2?.18:.13); c.fillStyle=D3.wallTop;
'@ @'
c.save(); c.globalAlpha=(_bf===2?.18:.13)*(_px?2.4:1); c.fillStyle=D3.wallTop;   // v28.xx (cw-cx-pixground): the shed number must still be a step darker after the snap
'@

SubRx @'
  return g;
}
// Is a specific point clear of every collider by pad?
'@ @'
  if(_px){ c.setTransform(1,0,0,1,0,0); pixGroundQueue(g,map,_t0); if(arguments[2]) pixGroundPrime(g,arguments[2]); }
  return g;
}
// Is a specific point clear of every collider by pad?
'@

SubRx @'
// ---- ?pixbench: every registered asset at 1x and 4x, and the ramp tables, on a plain page. pixReg(name, fn) registers an asset: fn() returns a pixSprite ----
'@ @'
// v28.xx (cw-cx-pixground), HIS ORDER (2026-10-20 22:45 to 23:05, "I want to do it all now before the party"): THE PIXEL GROUND, job 86b. The baked floor is drawn into a canvas of half the world size (one art pixel is
// v28.xx (cw-cx-pixground):  PIX_ENV world units), then a pass in 64 pixel chunks (256 took 5.8 ms and 128 took 4.1 ms on the VM, over the 4 ms a step may take) snaps every pixel to a 4 tone ramp of its district hue (value bands kept, day and night), cuts slab seams and 1x2, 1x3 strokes into the concrete on a
// v28.xx (cw-cx-pixground):  jittered grid, and gives the turf grass teeth on its edges. The halos and fades of the bake become stepped bands because the ramps are steps. Nothing here draws a number from the raid stream: the texture is
// v28.xx (cw-cx-pixground):  grit() and its own hashes of the art pixel, so two windows bake the same pixels and the seeded stream and the 4242 fingerprint do not move. The chunks nearest the camera are done at once, the rest at most
// v28.xx (cw-cx-pixground):  PIXG.budget ms a frame (the ascend countdown frames); a lost graphics context rebakes through the same queue. When the last chunk is done the CPU canvas is copied to a plain one, for the per frame blit.
var PIXG={ch:64,budget:4,n:0,ms:0,maxMs:0,bake:0,rasterMs:0,slow:null};
function pixGroundHex(h){ var n=parseInt(h.slice(1),16); return [n>>16,(n>>8)&255,n&255]; }
function pixGroundMix(a,b,t){
  var A=pixGroundHex(a), B=pixGroundHex(b), r=Math.round(A[0]*(1-t)+B[0]*t), g=Math.round(A[1]*(1-t)+B[1]*t), l=Math.round(A[2]*(1-t)+B[2]*t);
  return '#'+((1<<24)+(r<<16)+(g<<8)+l).toString(16).slice(1);
}
// v28.xx (cw-cx-pixground):  the five families of one district, 4 tones each light to deep: open floor, building floor, road, water, turf. rgb is the flat list the snap writes; lut finds the nearest tone of a 5 bit colour
function pixGroundPal(map,d,day){
  var K=d+(day?'d':'n'), C=map._pixPal||(map._pixPal={}), D, R, base, acc, fam, hx, rgb, refs, luma, gb, q2, i, q;
  if(C[K]) return C[K];
  D=DISTRICTS[d]||DISTRICTS[3]; R=PIXRAMPS.districts[D.name][day?'day':'night'];
  base=day?D.floor:darkHex(D.floor,0.34); acc=day?D.accent:darkHex(D.accent,0.26);
  fam=[R.floor,pixRamp(pixGroundMix(pixGroundMix(base,'#000000',0.3),acc,0.55)),pixRamp(day?'#857C6F':'#3c3242'),pixRamp(day?'#5F93A0':'#22383f'),pixRamp(vegT(day?'#6E8A52':'#2b3d20',map.veg))];
  hx=[]; rgb=[]; refs=[]; luma=[];
  gb=(map.ground&&(day?map.ground.day:map.ground.night))||(day?'#6E6A63':'#252c38');
  for(i=0;i<fam.length;i++) for(q=0;q<4;q++){ hx.push(fam[i][q]); q2=pixGroundHex(fam[i][q]); rgb.push(q2); luma.push(q2[0]*0.3+q2[1]*0.59+q2[2]*0.11); refs.push([q2,i]); }
  // v28.xx (cw-cx-pixground):  the bare ground, the district floor and their darker shades all belong to the open floor family: the tone is picked by lightness, so a fade between them becomes steps
  [gb,pixGroundMix(gb,'#000000',0.3),pixGroundMix(gb,'#000000',0.5),base,pixGroundMix(base,'#000000',0.3),pixGroundMix(base,'#000000',0.5)].forEach(function(h2){ refs.push([pixGroundHex(h2),0]); });
  return C[K]={hex:hx,rgb:rgb,luma:luma,refs:refs,lut:new Uint16Array(32768).fill(65535)};
}
function pixGroundNear(P,r,g,b){
  var k=((r>>3)<<10)|((g>>3)<<5)|(b>>3), v=P.lut[k], R, G2, B, i, d, bd, bf, lm, t, bt, e;
  if(v!==65535) return v;
  R=(r&248)|4; G2=(g&248)|4; B=(b&248)|4; bd=1e9; bf=0;
  for(i=0;i<P.refs.length;i++){ e=P.refs[i][0]; d=(R-e[0])*(R-e[0])+(G2-e[1])*(G2-e[1])+(B-e[2])*(B-e[2]); if(d<bd){ bd=d; bf=P.refs[i][1]; } }
  lm=R*0.3+G2*0.59+B*0.11; bd=1e9; bt=0;
  for(t=0;t<4;t++){ d=Math.abs(P.luma[bf*4+t]-lm); if(d<bd){ bd=d; bt=t; } }
  return P.lut[k]=bf*4+bt;
}
function pixGroundQueue(g,map,t0){
  // v28.xx (cw-cx-pixground): drain the original painter before starting the incremental pass. This read is included in the whole-bake timer, never hidden from the 1500 ms limit.
  var rasterStart=pixNow();
  g.getContext('2d').getImageData(0,0,1,1);
  var rasterMs=pixNow()-rasterStart;
  var ch=PIXG.ch, cols=Math.ceil(g.width/32), rows=Math.ceil(g.height/32), day=isDay(), dist=new Uint8Array(cols*rows), pal=[], x, y, d, nx=Math.ceil(g.width/ch), ny=Math.ceil(g.height/ch);
  for(y=0;y<rows;y++) for(x=0;x<cols;x++){ d=map.districtAt?map.districtAt(x*64+32,y*64+32):3; dist[y*cols+x]=(d===undefined||d<0||d>3)?3:d; }
  for(d=0;d<DISTRICTS.length;d++) pal.push(pixGroundPal(map,d,day));
  g._pe=PIX_ENV; g._day=day; g._pq=true;
  g._pg={dist:dist,cols:cols,pal:pal,nx:nx,ny:ny,source:new Uint8Array(g.width*g.height).fill(255),done:new Uint8Array(nx*ny),left:nx*ny,order:null,next:0};
  PIXG.n=0; PIXG.ms=0; PIXG.maxMs=0; PIXG.slow=null; PIXG.rasterMs=rasterMs; PIXG.bake=pixNow()-t0;
}
// v28.xx (cw-cx-pixground):  the texture, on the palette index map I (family*4+tone, tone 0 light .. 3 deep) of the chunk: x0,y0,w,h is the inner rect, rx,ry the origin of I, rw its width
function pixGroundTex(I,rw,rh,rx,ry,x0,y0,w,h){
  var x, y, ax, ay, v, f, t, band, jo, c8x, c8y, h0, px, py, ln, hz, sh, j, ix, iy, yi, xi, k;
  function put(ax2,ay2,fams,dt){   // v28.xx (cw-cx-pixground):  shift the tone of one pixel when its family is one of fams
    var X=ax2-rx, Y=ay2-ry, V, T2;
    if(X<x0-rx||Y<y0-ry||X>=x0-rx+w||Y>=y0-ry+h) return;
    V=I[Y*rw+X]; if(fams.indexOf(V>>2)<0) return;
    T2=(V&3)+dt; I[Y*rw+X]=(V&12)|(T2<0?0:T2>3?3:T2);
  }
  // v28.xx (cw-cx-pixground):  slab seams: a vertical seam every 24 art px, shifted per 20 row band, and a horizontal seam on every 20th row where the hash allows; the pixel after a seam is one step lighter
  for(ay=y0;ay<y0+h;ay++){
    band=(ay/20)|0; jo=(grit(band,977)*24)|0;
    for(ax=x0+((24-((x0+jo)%24))%24);ax<x0+w;ax+=24){ put(ax,ay,[0],1); put(ax+1,ay,[0],-1); }
    if(ay%20===0){ for(ax=x0;ax<x0+w;ax++) if(grit(ax>>4,band+7)<0.8) put(ax,ay,[0],1); }
    else if(ay%20===1){ for(ax=x0;ax<x0+w;ax++) if(grit(ax>>4,band+7)<0.8) put(ax,ay,[0],-1); }
  }
  // v28.xx (cw-cx-pixground):  1x2 and 1x3 strokes: one 8x8 cell in five holds one, level or upright, a step lighter or deeper (water: level and lighter)
  for(c8y=(y0>>3)-1;c8y<=((y0+h)>>3);c8y++) for(c8x=(x0>>3)-1;c8x<=((x0+w)>>3);c8x++){
    h0=grit(c8x+4001,c8y+313); if(h0>=0.2) continue;
    px=(grit(c8x+11,c8y+7001)*5)|0; py=(grit(c8x+21,c8y+9001)*7)|0; ln=2+(grit(c8x+31,c8y+4111)>0.5?1:0); hz=grit(c8x+41,c8y+5113)>0.5; sh=grit(c8x+51,c8y+6133)>0.5?-1:1;
    for(j=0;j<ln;j++){
      ix=c8x*8+px+(hz?j:0); iy=c8y*8+py+(hz?0:j);
      put(ix,iy,[0,2],sh); put(ix,iy,[3],-1);
    }
  }
  // v28.xx (cw-cx-pixground):  turf: a tooth stands up out of every second edge pixel, a few edge pixels are bitten away, and single blades of the light tone sit inside
  for(y=y0-ry;y<y0-ry+h;y++){
    ay=ry+y;
    for(x=x0-rx;x<x0-rx+w;x++){
      ax=rx+x; v=I[y*rw+x]; f=v>>2;
      if(f!==4){
        if(y+1<rh&&(I[(y+1)*rw+x]>>2)===4&&grit(ax,ay+9001)<0.5) I[y*rw+x]=17;
      } else {
        if(y>0&&(I[(y-1)*rw+x]>>2)!==4&&grit(ax+5,ay)>0.72) I[y*rw+x]=1;
        else if(grit(ax+13,ay+27)<0.06){ I[y*rw+x]=16; if(y+1<rh&&y+1<y0-ry+h&&(I[(y+1)*rw+x]>>2)===4&&grit(ax+17,ay)<0.5) I[(y+1)*rw+x]=16; }
      }
    }
  }
}
function pixGroundChunk(g,cx,cy){
  var t0=pixNow(), T=g._pg, ch=PIXG.ch, x0=cx*ch, y0=cy*ch, w=Math.min(ch,g.width-x0), h=Math.min(ch,g.height-y0), rx=Math.max(0,x0-1), ry=Math.max(0,y0-1),
      rw=Math.min(g.width,x0+w+1)-rx, rh=Math.min(g.height,y0+h+1)-ry, c=g.getContext('2d'), id=c.getImageData(rx,ry,rw,rh), p=id.data, I=new Uint8Array(rw*rh),
      x, y, k, P, dt, pa, v, row, si, readEnd=pixNow(), classifyEnd, textureEnd;
  for(y=0;y<rh;y++){
    row=((ry+y)>>5)*T.cols;
    for(x=0;x<rw;x++){
      P=T.pal[T.dist[row+((rx+x)>>5)]]; k=(y*rw+x)*4;
      // v28.xx (cw-cx-pixground): retain the original classification at shared tile edges; camera order must not change the texture.
      si=(ry+y)*g.width+rx+x;
      if(T.source[si]===255) T.source[si]=pixGroundNear(P,p[k],p[k+1],p[k+2]);
      I[y*rw+x]=T.source[si];
    }
  }
  classifyEnd=pixNow();
  pixGroundTex(I,rw,rh,rx,ry,x0,y0,w,h);
  textureEnd=pixNow();
  for(y=y0-ry;y<y0-ry+h;y++){
    row=((ry+y)>>5)*T.cols;
    for(x=x0-rx;x<x0-rx+w;x++){
      pa=T.pal[T.dist[row+((rx+x)>>5)]].rgb[I[y*rw+x]]; k=(y*rw+x)*4;
      p[k]=pa[0]; p[k+1]=pa[1]; p[k+2]=pa[2]; p[k+3]=255;
    }
  }
  c.putImageData(id,rx,ry,x0-rx,y0-ry,w,h);
  T.done[cy*T.nx+cx]=1; T.left--;
  dt=pixNow()-t0; PIXG.n++; PIXG.ms+=dt; if(dt>PIXG.maxMs){
    PIXG.maxMs=dt;
    PIXG.slow={x:cx,y:cy,read:readEnd-t0,classify:classifyEnd-readEnd,texture:textureEnd-classifyEnd,write:dt-(textureEnd-t0)};
  }
}
// v28.xx (cw-cx-pixground):  all done: the CPU canvas goes to a plain one for the per frame blit, and the queue is gone
function pixGroundFinal(g){
  var f;
  if(!g||!g._pg||g._pg.left>0) return g;
  f=document.createElement('canvas'); f.width=g.width; f.height=g.height; f.getContext('2d').drawImage(g,0,0);
  f._pe=g._pe; f._day=g._day; g._pq=false; g._pg=null;
  if(typeof G!=='undefined'&&G&&G.ground===g) G.ground=f;
  return f;
}
// v28.xx (cw-cx-pixground):  every chunk now (the check; a rebake that cannot wait)
function pixGroundFinish(g){
  var T=g&&g._pg, cx, cy;
  if(!T) return g;
  for(cy=0;cy<T.ny;cy++) for(cx=0;cx<T.nx;cx++) if(!T.done[cy*T.nx+cx]) pixGroundChunk(g,cx,cy);
  return pixGroundFinal(g);
}
// v28.xx (cw-cx-pixground): finish the spawn view before buildRaid returns, including the cursor lean margin. No seeded draw.
function pixGroundPrime(g,p){
  var T=g._pg, ch=PIXG.ch*g._pe, z=ZDEFAULT*hudRes(), vw=W/z, vh=H/z, cx, cy;
  if(!T) return;
  for(cy=Math.max(0,Math.floor((p.y-vh*0.9)/ch));cy<=Math.min(T.ny-1,Math.floor((p.y+vh*0.9)/ch));cy++)
    for(cx=Math.max(0,Math.floor((p.x-vw*0.85)/ch));cx<=Math.min(T.nx-1,Math.floor((p.x+vw*0.85)/ch));cx++)
      if(!T.done[cy*T.nx+cx]) pixGroundChunk(g,cx,cy);
}
// v28.xx (cw-cx-pixground): after spawn, work only within the frame budget; visible tiles have priority.
function pixGroundStep(ox,oy,VW,VH){
  var g=G.ground, T=g&&g._pg, ch=PIXG.ch*((g&&g._pe)||1), a, b, cx, cy, i, t1, fx, fy, o;
  if(!T) return;
  t1=pixNow();
  a=Math.max(0,Math.floor(ox/ch)); b=Math.min(T.nx-1,Math.floor((ox+VW)/ch));
  for(cy=Math.max(0,Math.floor(oy/ch));cy<=Math.min(T.ny-1,Math.floor((oy+VH)/ch));cy++) for(cx=a;cx<=b;cx++) if(!T.done[cy*T.nx+cx]&&pixNow()-t1+Math.max(0.25,Math.min(1.5,PIXG.maxMs))<PIXG.budget) pixGroundChunk(g,cx,cy);
  if(!T.order){
    fx=(ox+VW/2)/ch-0.5; fy=(oy+VH/2)/ch-0.5; o=[];
    for(cy=0;cy<T.ny;cy++) for(cx=0;cx<T.nx;cx++) o.push([(cx-fx)*(cx-fx)+(cy-fy)*(cy-fy),cx,cy]);
    o.sort(function(m,n){ return m[0]-n[0]; }); T.order=o;
  }
  while(T.left>0&&T.next<T.order.length&&pixNow()-t1+Math.max(0.25,Math.min(1.5,PIXG.maxMs))<PIXG.budget){
    i=T.order[T.next++]; if(!T.done[i[2]*T.nx+i[1]]) pixGroundChunk(g,i[1],i[2]);
  }
  if(T.left<=0) pixGroundFinal(g);
}
// ---- ?pixbench: every registered asset at 1x and 4x, and the ramp tables, on a plain page. pixReg(name, fn) registers an asset: fn() returns a pixSprite ----
'@

SubRx @'
  var gx0=Math.max(0,Math.floor(ox)),gy0=Math.max(0,Math.floor(oy));
'@ @'
  if(G.ground._pq){ try{ pixGroundStep(ox,oy,VW,VH); }catch(_pgs){ PIX.errs++; G.ground._pq=false; } }   // v28.xx (cw-cx-pixground): the pixel floor's chunks
  var _gpe=G.ground._pe||1;
  var gx0=Math.max(0,Math.floor(ox/_gpe)*_gpe),gy0=Math.max(0,Math.floor(oy/_gpe)*_gpe);
'@

SubRx @'
  var gx1=Math.min(G.ground.width,Math.ceil(ox+VW)),gy1=Math.min(G.ground.height,Math.ceil(oy+VH));
'@ @'
  var gx1=Math.min(G.ground.width*_gpe,Math.ceil((ox+VW)/_gpe)*_gpe),gy1=Math.min(G.ground.height*_gpe,Math.ceil((oy+VH)/_gpe)*_gpe);
'@

SubRx @'
  if(gx1>gx0&&gy1>gy0) wc.drawImage(G.ground,gx0,gy0,gx1-gx0,gy1-gy0,gx0,gy0,gx1-gx0,gy1-gy0);
'@ @'
  if(gx1>gx0&&gy1>gy0){
    if(_gpe>1){   // v28.xx (cw-cx-pixground): the half density floor, 2 world units a pixel: nearest when the art pixel is a whole number of screen pixels, smooth otherwise
      var _gsm=wc.imageSmoothingEnabled; wc.imageSmoothingEnabled=Math.abs(Z*DPR*_gpe-Math.round(Z*DPR*_gpe))>0.001;
      wc.drawImage(G.ground,gx0/_gpe,gy0/_gpe,(gx1-gx0)/_gpe,(gy1-gy0)/_gpe,gx0,gy0,gx1-gx0,gy1-gy0);
      wc.imageSmoothingEnabled=_gsm;
    } else wc.drawImage(G.ground,gx0,gy0,gx1-gx0,gy1-gy0,gx0,gy0,gx1-gx0,gy1-gy0);
  }
'@

SubRx @'
  if(!gr||!gr.getContext||!(x>=0&&y>=0&&x<gr.width&&y<gr.height)) return false;
'@ @'
  var pe=(gr&&gr._pe)||1;   // v28.xx (cw-cx-pixground): the half density floor keeps its stamps on the art grid
  if(pe>1){ x=Math.round(x/pe)*pe; y=Math.round(y/pe)*pe; }
  if(!gr||!gr.getContext||!(x>=0&&y>=0&&x<gr.width*pe&&y<gr.height*pe)) return false;
'@

SubRx @'
  scarPaint(gr.getContext('2d'),s);
'@ @'
  scarOn(gr,s);
'@

SubRx @'
function gfxScarReplay(){

'@ @'
// v28.xx (cw-cx-pixground): a stamp is painted in world units, so the half density floor is scaled for the length of the paint
function scarOn(gr,s){
  var c=gr.getContext('2d'), pe=gr._pe||1;
  if(pe>1){
    s=Object.assign({},s,{x:Math.round(s.x/pe)*pe,y:Math.round(s.y/pe)*pe});
    c.save(); c.setTransform(1/pe,0,0,1/pe,0,0);
  }
  try{ scarPaint(c,s); } finally { if(pe>1) c.restore(); }
}
function gfxScarReplay(){

'@

SubRx @'
  for(i=0;i<Lg.length;i++){ try{ scarPaint(c,Lg[i]); n++; }catch(_sp){} }
'@ @'
  for(i=0;i<Lg.length;i++){ try{ scarOn(gr,Lg[i]); n++; }catch(_sp){} }
'@

SubRx @'
G.ground=bakeGround(G.map);
'@ @'
G.ground=bakeGround(G.map,!!(G.ground&&G.ground._pe>1),G.player);   /* v28.xx (cw-cx-pixground): context restore keeps the raid entry choice and queues the same bake */
'@

SubRx @'
ground:sim?null:bakeGround(map)
'@ @'
ground:sim?null:bakeGround(map,undefined,start)
'@

SubRx @'
var VER='33.59';
'@ @'
var VER='33.60';
'@

$pat = "(?m)^  now:'v33\.59:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.60: With the pixel look on (the default), the ground is chunky pixel art in stepped district colours, and the first seconds of a raid finish baking it. With the look off, nothing changes. Check 33.60 fails on v33.59',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
