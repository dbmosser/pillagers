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

# THE PIXEL ADAPTER AND THE LOOT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// ---- the ramp tables, as data
'@ @'
// v33.65 (cw-pixprops), HIS ORDER (2026-10-20 22:45 to 23:05, "I want to do it all now before the party"): THE PIXEL ADAPTER, job 86e ship 1. pixWrap(key,w,h,d,paint,x,y,o) runs a vector painter UNCHANGED into an art
// v33.65 (cw-pixprops):  resolution scratch (wc points at it, scaled 1/d, the ground shadow still goes to the world), once per key. The bake then hardens the alpha (a soft shadow becomes one flat tone), snaps every colour to the
// v33.65 (cw-pixprops):  few the painter used, adds a darker bottom and right edge, crops to the shape and caches it by kind, state, variant and day. After that a prop is ONE drawImage. A throw puts wc back (finally) and the caller
// v33.65 (cw-pixprops):  paints the vector way. Bake time only reads pixels back; the draw never does. Live things (wreck smoke) are not baked: wreckSmoke records its height while PIXW.on and the caller draws it on top.
var PIXW={on:0,smoke:0,clip:0,last:null};
var PIXW_SHAD={day:[60,52,46],night:[20,17,15]};
function pixWrapBake(w,h,d,up,paint,x,y){
  var aw=Math.ceil(w/d)+2, ah=Math.ceil(h/d)+2, n=aw*ah, s=pixCanvas(aw,ah), w0=wc, sh0=shadowE, ox=x-w/2, oy=y-up, sm=0, sh=new Uint8Array(n), cnt={}, tot=0, near={}, pal=[], ks, im, p, sr, i, j, k, a, key, q, c0, best, bd, dd, r, g, b, xx, yy, mx=aw, my=ah, Mx=-1, My=-1, bx, by, out, spr, ink=[22,18,28];
  PIXW.on=1; PIXW.smoke=0;
  s.x.setTransform(1/d,0,0,1/d,1-ox/d,1-oy/d);
  wc=s.x;
  shadowE=function(sx,sy,rx,ry,sa){ var w1=wc; wc=w0; try{ sh0(sx,sy,rx,ry,sa); } finally{ wc=w1; } };
  try{ paint(); } finally{ wc=w0; shadowE=sh0; PIXW.on=0; sm=PIXW.smoke; }
  s.x.setTransform(1,0,0,1,0,0);
  im=s.x.getImageData(0,0,aw,ah); p=im.data; sr=PIXW_SHAD[isDay()?'day':'night'];
  for(i=0;i<n;i++){   // alpha to 0 or 255: a dark half see through pixel is the painter's ground shadow and becomes the one shadow tone
    k=i*4; a=p[k+3];
    if(a<64){ p[k+3]=0; continue; }
    if(a<200&&(p[k]*3+p[k+1]*6+p[k+2])<400){ sh[i]=1; continue; }
    if(a<128){ p[k+3]=0; continue; }
    p[k+3]=255; key=(p[k]<<16)|(p[k+1]<<8)|p[k+2]; cnt[key]=(cnt[key]||0)+1; tot++;
  }
  ks=Object.keys(cnt).sort(function(u,v){ return cnt[v]-cnt[u]||u-v; });
  for(i=0;i<ks.length&&pal.length<12;i++){ if(i===0||cnt[ks[i]]>=Math.max(3,tot*0.012)) pal.push(+ks[i]); }
  for(i=0;i<n;i++){   // every colour to the nearest of the painter's own few
    k=i*4;
    if(sh[i]){ p[k]=sr[0]; p[k+1]=sr[1]; p[k+2]=sr[2]; p[k+3]=255; continue; }
    if(!p[k+3]) continue;
    key=(p[k]<<16)|(p[k+1]<<8)|p[k+2]; q=near[key];
    if(q===undefined){
      best=pal[0]; bd=1e9;
      for(j=0;j<pal.length;j++){ c0=pal[j]; r=(c0>>16)-p[k]; g=((c0>>8)&255)-p[k+1]; b=(c0&255)-p[k+2]; dd=r*r+g*g+b*b; if(dd<bd){ bd=dd; best=c0; } }
      q=near[key]=best;
    }
    p[k]=q>>16; p[k+1]=(q>>8)&255; p[k+2]=q&255;
  }
  for(yy=0;yy<ah;yy++) for(xx=0;xx<aw;xx++){   // the edge: a lit pixel with clear ground to the south or east takes a darker tone; the bounds of the shape
    i=yy*aw+xx; k=i*4;
    if(!p[k+3]) continue;
    if(xx<mx) mx=xx; if(xx>Mx) Mx=xx; if(yy<my) my=yy; if(yy>My) My=yy;
    if(sh[i]) continue;
    if((xx+1>=aw||!p[k+7])||(yy+1>=ah||!p[k+aw*4+3])){
      if(p[k]+p[k+1]+p[k+2]>150){ p[k]=((p[k]*55+ink[0]*45)/100)|0; p[k+1]=((p[k+1]*55+ink[1]*45)/100)|0; p[k+2]=((p[k+2]*55+ink[2]*45)/100)|0; }
    }
  }
  if(Mx<0){ spr=pixSprite(pixCanvas(1,1).c,0,0,d); spr.smoke=0; return spr; }
  bx=Mx-mx+1; by=My-my+1; out=pixCanvas(bx,by); out.x.putImageData(im,-mx,-my,mx,my,bx,by);
  if(mx<=0||my<=0||Mx>=aw-1||My>=ah-1) PIXW.clip++;
  spr=pixSprite(out.c,(w/(2*d)+1)-mx,(up/d+1)-my,d); spr.smoke=sm;
  return spr;
}
// paint(): the old vector painter as a closure that draws on wc around world (x, y). Returns the cached sprite (it has been drawn) or null (the caller paints the vector way).
function pixWrap(key,w,h,d,paint,x,y,o){
  var T, e, kind;
  if(!pixOn()||PIXW.on||typeof wc==='undefined'||!wc||!wc.getTransform||(typeof G!=='undefined'&&G&&G.sim)) return null;
  try{
    T=wc.getTransform();
    if(!(T.a>0)||!(T.d>0)||T.b||T.c||!isFinite(x)||!isFinite(y)) return null;
    o=o||{}; kind=o.kind||(d>=PIX_ENV?'scene':'actors');
    e=pixFetch(kind,key+'|'+d+(isDay()?'d':'n'),function(){ return pixWrapBake(w,h,d,o.up==null?h*0.75:o.up,paint,x,y); },key,0);
    if(!e) return null;
    pixBlit(e,T.a*x+T.e,T.d*y+T.f,false,wc,T.a*d);
    PIXW.last=e;
    return e;
  }catch(_pw){ PIX.errs++; return null; }
}
// ---- the ramp tables, as data
'@

SubRx @'
function wreckSmoke(ct,h){
'@ @'
function wreckSmoke(ct,h){
  if(PIXW.on){ PIXW.smoke=h; return; }   // v33.65 (cw-pixprops): inside a bake the smoke is not painted, its height is kept and drawContS draws it live over the cached wreck
'@

SubRx @'
if(ct.bot&&WRECKDRAW[ct.bot]){
'@ @'
var pwPaint=function(){   // v33.65 (cw-pixprops): the body of the box, wreck, corpse or carcass, closed over so the pixel look can bake it once
if(ct.bot&&WRECKDRAW[ct.bot]){
'@

SubRx @'
if(ct.dropped&&!ct.opened&&!G.sim&&ct.best){ try{ lootShaft(ct,lift); }catch(_ls){} }
'@ @'
};
  // v33.65 (cw-pixprops), HIS ORDER (2026-10-20 22:45 to 23:05, the pixel pass): with the pixel look on this body is one cached sprite (opened and closed are two), at 1 world unit per art pixel; the ground shadow, the dim of an
  // opened box, the search bar, the amber tell and the wreck smoke stay live. A miss or a throw paints the vector way.
  var pwE=null, pwK, pwG;
  if(pixOn()){
    pwG=grit(ct.x,ct.y);
    if(ct.bot&&WRECKDRAW[ct.bot]) pwK='wr:'+ct.bot+(ct.ov?'v':'')+(pwG>.5?'1':'0')+(ct.opened?'o':'c');
    else if(ct.type==='botwreck') pwK='bw:'+Math.round(pwG*4096)+(ct.opened?'o':'c');
    else if(ct.carcass==='deer') pwK='dr:'+(pwG>.5?'1':'0')+(grit(ct.x+7,ct.y+3)>.55?'a':'n');
    else if(ct.type==='body') pwK='bd:'+Math.round(pwG*4096);
    else pwK='bx:'+ct.type+(ct.camp?'c':'')+(ct.opened?'o':'c');
    pwE=pixWrap(pwK,160,124,PIX_ACT,pwPaint,ct.x,ct.y,{up:90});
  }
  if(!pwE) pwPaint(); else if(pwE.smoke) wreckSmoke(ct,pwE.smoke);
  wc.globalAlpha=1;
  if(ct.dropped&&!ct.opened&&!G.sim&&ct.best){ try{ lootShaft(ct,lift); }catch(_ls){} }
'@

SubRx @'
var VER='33.67';
'@ @'
var VER='33.68';
'@

$pat = "(?m)^  now:'v33\.67:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.68: With the pixel look on, crates, lockers, safes, caches, bodies, deer and the machine wrecks draw as crisp pixel sprites; opened ones still dim. Wreck smoke still rises. With the look off nothing changes. Check 33.68 fails on v33.67',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
