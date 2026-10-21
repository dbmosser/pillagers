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

# THE PIXEL WALL (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function wallSprite(wl2,d3,LIFT){
'@ @'
// v33.57 (cw-pixwalls), HIS ORDER (2026-10-20 22:45 to 23:05, "I want to do it all now before the party"): THE PIXEL WALL, job 86d ship 1. With the pixel look on a plain wall bakes at a fixed 1/PIX_ENV, so it never rebuilds on a zoom or
// an Auto resolution step (the sprite key has no screen scale in it): a lit back row on the roof, a face of brick or panel courses chosen by grit(), one INK row at the foot with a damp row above it, and a bullet mark is one INK pixel
// with a lit rim. Every colour is a tone of the district wall or roof ramp (PIXRAMPS.districts, day and night, value bands kept) or the ink. Only grit() and the wall's own position, never rr(): two windows bake the same pixels.
var PIX_WALLRGB={};
function pixWallRGB(hx){ var r=PIX_WALLRGB[hx], n; if(!r){ n=parseInt(hx.slice(1),16); r=PIX_WALLRGB[hx]=[n>>16,(n>>8)&255,n&255]; } return r; }
function pixWallRamps(d3){ var D=DISTRICTS[(d3>=0&&d3<DISTRICTS.length)?d3:3]; return PIXRAMPS.districts[D.name][isDay()?'day':'night']; }
function pixWallChip(c,R,ax,ay,s,aw,ah){   // a bullet chip on the face: ink core, lit rim up and left, two dark flecks
  function put(x,y,hx){ if(x>=0&&y>=0&&x<aw&&y<ah){ c.fillStyle=hx; c.fillRect(x,y,1,1); } }
  put(ax-1,ay,R.wall[0]); put(ax,ay-1,R.wall[0]); put(ax,ay,PIX_INK);
  put(ax+1+((grit(s,3)*2)|0),ay+1,R.wall[3]); put(ax-1-((grit(s,5)*2)|0),ay+1+((grit(s,9)*2)|0),R.wall[3]);
}
function pixWallBake(wl2,d3,LIFT){
  var R=pixWallRamps(d3), E=PIX_ENV, aw=Math.max(1,Math.ceil(wl2.w/E)), tr=Math.max(1,Math.round(wl2.h/E)), fr=Math.max(0,Math.round(LIFT/E)), ah=tr+fr,
      s=pixCanvas(aw,ah), id=s.x.createImageData(aw,ah), p=id.data, dec=CFG.decay!==0, wx=wl2.x|0, wy=wl2.y|0, brick=grit(wx,wy+77)<0.5, ck=grit(wx,wy+3),
      cx=(ck>0.66&&aw>9)?((aw*(0.2+ck*0.55))|0):-1, cs=(ck>0.83)?1:-1, x, y, fy, ci, t, q, bk, Lm, i;
  function put(x2,y2,hx){ var o=(y2*aw+x2)*4, k=pixWallRGB(hx); p[o]=k[0]; p[o+1]=k[1]; p[o+2]=k[2]; p[o+3]=255; }
  for(y=0;y<tr;y++) for(x=0;x<aw;x++){   // the roof: lit back row, a deeper row where it meets the face, a few specks, bites and stains
    t=1;
    if(y===0) t=0;
    else if(y===tr-1&&tr>2) t=2;
    else { q=grit(wx+x*E,wy+y*E+5); t=q>0.93?2:(q<0.04?0:1); }
    if(dec&&y===0&&grit(wx+x*E,wy+21)>0.8) t=2;
    if(dec&&y>0&&y<tr-1&&grit(wx+x*E,wy+33)>0.82&&y<1+((grit(wx+x*E,wy+34)*4)|0)) t=2;
    put(x,y,R.top[t]);
  }
  for(fy=0;fy<fr;fy++){   // the face
    y=tr+fy; ci=(fy/3)|0;
    for(x=0;x<aw;x++){
      if(fy===fr-1){ put(x,y,PIX_INK); continue; }
      if(fy===fr-2){ put(x,y,R.wall[3]); continue; }
      if(fy===0){ put(x,y,R.wall[2]); continue; }
      t=1;
      if(brick){
        bk=((x+(ci&1)*3)/6)|0; q=grit(wx+bk*7,wy+ci*13);
        if(fy%3===2||((x+(ci&1)*3)%6)===0) t=3; else if(q>0.86) t=0; else if(q<0.08) t=2;
      } else {
        q=grit(wx+x*E,wy+fy*E+61);
        if(fy%5===3) t=3; else if(x%12===0) t=2; else if(q>0.95) t=0; else if(q<0.05) t=2;
      }
      if(dec&&grit(wx+x*E,wy+1)>0.9&&fy<2+((grit(wx+x*E,wy+2)*(fr-3))|0)) t=2;
      put(x,y,R.wall[t]);
      if(cx>=0&&fy<fr-2&&x===cx+cs*((fy*0.22)|0)) put(x,y,PIX_INK);
    }
  }
  s.x.putImageData(id,0,0);
  try{ Lm=WALLMK&&WALLMK.get(wl2); if(Lm) for(i=0;i<Lm.length;i++) pixWallChip(s.x,R,((Lm[i].x-wl2.x)/E)|0,((Lm[i].y-(wl2.y-LIFT))/E)|0,Lm[i].s,aw,ah); }catch(_pm){}
  return {c:s.c,ss:1,px:true,R:R,t:WALLSPR.tick,w:wl2,lift:LIFT};
}
function wallSprite(wl2,d3,LIFT){
'@

SubRx @'
  var ss, gk, k, e, w, h, cv2, c2, ks, i;
'@ @'
  var ss, gk, k, e, w, h, cv2, c2, ks, i, _px;
'@

SubRx @'
  gk=String(G&&G.seed)+'|'+(isDay()?'d':'n')+'|'+(CFG.decay!==0?1:0)+'|'+ss;
'@ @'
  _px=pixOn();   // v33.57 (cw-pixwalls): the pixel look has no screen scale in its key, so a zoom or a resolution step never rebuilds it
  gk=String(G&&G.seed)+'|'+(isDay()?'d':'n')+'|'+(CFG.decay!==0?1:0)+'|'+(_px?'px':ss);
'@

SubRx @'
  if(e){ e.t=WALLSPR.tick; return e; }
'@ @'
  if(e){ e.t=WALLSPR.tick; return e; }
  if(_px){
    try{ e=pixWallBake(wl2,d3,LIFT); }catch(_pw){ PIX.errs++; e=null; }
    if(e){
      if(WALLSPR.n>=WALLSPR.max){
        ks=Object.keys(WALLSPR.m); ks.sort(function(a,b){ return WALLSPR.m[a].t-WALLSPR.m[b].t; });
        for(i=0;i<ks.length/4;i++){ delete WALLSPR.m[ks[i]]; WALLSPR.n--; }
      }
      e.t=WALLSPR.tick; WALLSPR.m[k]=e; WALLSPR.n++;
      return e;
    }
  }
'@

SubRx @'
      if(_ws) wc.drawImage(_ws.c,0,0,_ws.c.width,_ws.c.height,wl2.x-1/_ws.ss,wl2.y-LIFT-1/_ws.ss,_ws.c.width/_ws.ss,_ws.c.height/_ws.ss);
'@ @'
      if(_ws&&_ws.px){   // v33.57 (cw-pixwalls): art pixels, nearest when an art pixel is a whole number of screen pixels
        var _wsm=wc.imageSmoothingEnabled, _wq=ZOOM()*DPR*PIX_ENV; wc.imageSmoothingEnabled=Math.abs(_wq-Math.round(_wq))>0.001;
        wc.drawImage(_ws.c,wl2.x,wl2.y-LIFT,_ws.c.width*PIX_ENV,_ws.c.height*PIX_ENV);
        wc.imageSmoothingEnabled=_wsm;
      }
      else if(_ws) wc.drawImage(_ws.c,0,0,_ws.c.width,_ws.c.height,wl2.x-1/_ws.ss,wl2.y-LIFT-1/_ws.ss,_ws.c.width/_ws.ss,_ws.c.height/_ws.ss);
'@

SubRx @'
    c=e.c.getContext('2d'); if(!c) continue;
'@ @'
    c=e.c.getContext('2d'); if(!c) continue;
    if(e.px){ pixWallChip(c,e.R,((mk.x-w.x)/PIX_ENV)|0,((mk.y-(w.y-e.lift))/PIX_ENV)|0,mk.s,e.c.width,e.c.height); continue; }   // v33.57 (cw-pixwalls): a pixel chip
'@

SubRx @'
var VER='33.65';
'@ @'
var VER='33.66';
'@

$pat = "(?m)^  now:'v33\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.66: With the pixel look on (the default), walls are chunky stepped-colour pixel brick and panel. With the look off, nothing changes. Check 33.66 fails on v33.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
