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

# THE PIXEL TREE, BUSH AND SHADOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function vegSprite(kind,r){
'@ @'
// v33.67 (cw-pixveg), HIS ORDER (2026-10-20 22:45 to 23:05): THE PIXEL TREE, BUSH AND SHADOW, job 86d ship 2. With the pixel look on a canopy and a bush bake once at one pixel per 2 world units (no screen scale in the key): the same blobs
// as the vector paint, filled whole pixels, tones of the map's own day or night leaf palette (G.vegPal), hard alpha (0 or 255), a bottom and right edge pixel in a dark tone of the palette, a few lit specks by grit(). A ground shadow is a hard
// pixel ellipse (a stamp of solid pixels laid at the shadow's alpha, a little bigger and darker than the soft one, his a09 B). Only grit() and the size, never rr().
var PIX_VEGRGB={};
function pixVegRGB(hx,dk){ var k=hx+(dk?'d':''), r=PIX_VEGRGB[k], n; if(!r){ n=parseInt(hx.slice(1),16); r=[n>>16,(n>>8)&255,n&255]; if(dk) r=[(r[0]*0.55)|0,(r[1]*0.55)|0,(r[2]*0.55)|0]; PIX_VEGRGB[k]=r; } return r; }
function pixVegBake(kind,rr,pal){
  var E=PIX_ENV, tree=(kind==='tree'), ox, oy, w, h, aw, ah, s, id, p, D, tn, x, y, i, wx, wy, dx, dy, t, o, kc=tree?1:2, ed, k;
  if(tree){ ox=rr+2; oy=rr*1.35+2; w=rr*2+4; h=rr*2+4; D=[[0,-rr*.35,rr,0],[-rr*.25,-rr*.5,rr*.72,1],[-rr*.35,-rr*.62,rr*.45,2]]; }
  else { ox=rr*0.9+2; oy=rr+2; w=rr*1.8+4; h=rr*1.3+4; D=[[-rr*0.34,-rr*0.55*0.50,rr*0.52,1],[rr*0.30,-rr*0.55*0.42,rr*0.48,1],[0,-rr*0.55*0.78,rr*0.54,2],[-rr*0.16,-rr*0.55*0.96,rr*0.32,3]]; }
  aw=Math.max(1,Math.ceil(w/E)); ah=Math.max(1,Math.ceil(h/E));
  s=pixCanvas(aw,ah); id=s.x.createImageData(aw,ah); p=id.data; tn=new Array(aw*ah);
  for(y=0;y<ah;y++) for(x=0;x<aw;x++){
    wx=(x+0.5)*E-ox; wy=(y+0.5)*E-oy; t=-1;
    if(!tree&&(wx*wx)/(rr*0.96*rr*0.96)+(wy*wy)/(rr*0.5*rr*0.5)<=1) t=0;   // the bush's ground blob (it was a live ellipse)
    for(i=0;i<D.length;i++){ dx=wx-D[i][0]; dy=wy-D[i][1]; if(dx*dx+dy*dy<=D[i][2]*D[i][2]) t=D[i][3]; }
    tn[y*aw+x]=t;
  }
  for(y=0;y<ah;y++) for(x=0;x<aw;x++){
    t=tn[y*aw+x]; if(t<0) continue;
    ed=((x+1>=aw||tn[y*aw+x+1]<0)||(y+1>=ah||tn[(y+1)*aw+x]<0));
    if(!ed&&t<pal.length-1&&grit(x*7+rr,y*11+kc)>0.9) t++;
    k=pixVegRGB(ed?pal[0]:pal[t],ed); o=(y*aw+x)*4; p[o]=k[0]; p[o+1]=k[1]; p[o+2]=k[2]; p[o+3]=255;
  }
  s.x.putImageData(id,0,0);
  return {c:s.c,ss:1/E,px:true,ox:ox,oy:oy};
}
function pixSmooth(){ var q=ZOOM()*DPR*PIX_ENV; return Math.abs(q-Math.round(q))>0.001; }
function pixShadow(x,y,rx,ry,a){
  var E=PIX_ENV, ra=Math.max(1,Math.round(rx*1.12/E)), rb=Math.max(1,Math.round(ry*1.12/E)), k='px:'+ra+','+rb, e=SHADSPR.m[k], s, id, p, i, j, u, v, o, a0, sm;
  if(!e){
    if(SHADSPR.n>300){ SHADSPR.m={}; SHADSPR.n=0; }
    s=pixCanvas(ra*2+1,rb*2+1); id=s.x.createImageData(ra*2+1,rb*2+1); p=id.data;
    for(j=0;j<rb*2+1;j++) for(i=0;i<ra*2+1;i++){ u=(i-ra)/(ra+0.4); v=(j-rb)/(rb+0.4); if(u*u+v*v<=1){ o=(j*(ra*2+1)+i)*4; p[o+3]=255; } }
    s.x.putImageData(id,0,0); e=SHADSPR.m[k]={c:s.c,px:true}; SHADSPR.n++;
  }
  a0=wc.globalAlpha; sm=wc.imageSmoothingEnabled; wc.imageSmoothingEnabled=pixSmooth(); wc.globalAlpha=a0*Math.min(0.62,a*1.3+0.04);
  wc.drawImage(e.c,Math.round((x-(ra+0.5)*E)/E)*E,Math.round((y-(rb+0.5)*E)/E)*E,e.c.width*E,e.c.height*E);
  wc.globalAlpha=a0; wc.imageSmoothingEnabled=sm;
  return true;
}
function vegSprite(kind,r){
'@

SubRx @'
  gk=String(G.seed)+'|'+(day?'d':'n')+'|'+ss;
'@ @'
  gk=String(G.seed)+'|'+(day?'d':'n')+'|'+(pixOn()?'px':ss);   // v33.67 (cw-pixveg): the pixel look has no screen scale in its key
'@

SubRx @'
  if(kind==='tree'){ ox=rr+2; oy=rr*1.35+2; w=rr*2+4; h=rr*2+4; }
'@ @'
  if(pixOn()){ try{ e=pixVegBake(kind,rr,pal); }catch(_pv){ PIX.errs++; e=null; } if(e){ VEGSPR.m[k]=e; return e; } }   // v33.67 (cw-pixveg)
  if(kind==='tree'){ ox=rr+2; oy=rr*1.35+2; w=rr*2+4; h=rr*2+4; }
'@

SubRx @'
  wc.drawImage(e.c,0,0,e.c.width,e.c.height,x-e.ox,y-e.oy,e.c.width/e.ss,e.c.height/e.ss);
'@ @'
  if(e.px){   // v33.67 (cw-pixveg): whole art pixels, the sway moves it a pixel at a time
    var _vm=wc.imageSmoothingEnabled; wc.imageSmoothingEnabled=pixSmooth();
    wc.drawImage(e.c,Math.round((x-e.ox)/PIX_ENV)*PIX_ENV,Math.round((y-e.oy)/PIX_ENV)*PIX_ENV,e.c.width*PIX_ENV,e.c.height*PIX_ENV);
    wc.imageSmoothingEnabled=_vm; return true;
  }
  wc.drawImage(e.c,0,0,e.c.width,e.c.height,x-e.ox,y-e.oy,e.c.width/e.ss,e.c.height/e.ss);
'@

SubRx @'
      wc.beginPath(); wc.ellipse(BU.x,BU.y,BU.r*0.96,BU.r*0.50,0,0,6.2832); wc.fill();
'@ @'
      if(!(pixOn()&&CFG.wallBake!==0)){ wc.beginPath(); wc.ellipse(BU.x,BU.y,BU.r*0.96,BU.r*0.50,0,0,6.2832); wc.fill(); }   // v33.67 (cw-pixveg): the pixel bush carries its own ground blob
'@

SubRx @'
      wc.fillRect(tcx-TR.w*.32,tby-26,TR.w*.64,26);
'@ @'
      var _tx=tcx-TR.w*.32, _tw=TR.w*.64, _ty=tby-26, _tl=TR.w*.2;
      if(pixOn()){ _tx=Math.round(_tx/PIX_ENV)*PIX_ENV; _tw=Math.max(PIX_ENV*2,Math.round(_tw/PIX_ENV)*PIX_ENV); _ty=Math.round(_ty/PIX_ENV)*PIX_ENV; _tl=Math.max(PIX_ENV,Math.round(_tl/PIX_ENV)*PIX_ENV); }   // v33.67 (cw-pixveg): the trunk is drawn at art pixels
      wc.fillRect(_tx,_ty,_tw,tby-_ty);
'@

SubRx @'
      wc.fillRect(tcx-TR.w*.32,tby-26,TR.w*.2,26);
'@ @'
      wc.fillRect(_tx,_ty,_tl,tby-_ty);
'@

SubRx @'
  var ss, k, e, R, cv2, c2;
'@ @'
  var ss, k, e, R, cv2, c2;
  if(pixOn()&&CFG.wallBake!==0&&rx>0&&ry>0&&rx<400&&ry<400&&pixShadow(x,y,rx,ry,a)) return;   // v33.67 (cw-pixveg): a hard pixel shadow
'@

SubRx @'
var VER='33.68';
'@ @'
var VER='33.69';
'@

$pat = "(?m)^  now:'v33\.68:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.69: With the pixel look on (the default), trees, bushes and ground shadows are chunky hard-edged pixels. With the look off, nothing changes. Check 33.69 fails on v33.68',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
