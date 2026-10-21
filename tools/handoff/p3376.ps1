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

# THE PIXEL DOOR AND WINDOW (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function wallSprite(wl2,d3,LIFT){
'@ @'
// v33.xx (cw-pixdoors), HIS ORDER (2026-10-20 22:45 to 23:05, "I want to do it all now before the party"): job 86d ship 3, THE PIXEL DOOR, WINDOW, STRONGHOLD WALL AND UNDERCROFT WALL. These were still vector rects with
// translucent washes. With the pixel look on every one is filled on the 2 unit art grid (pixFill snaps), solid (alpha 255), from the district wall ramp, the ink and a few fixed accents (lock lights, glass, hazard). Kerbs (ledge) and ruins
// already bake through wallSprite, so they were pixel with the plain wall. Only grit() and positions, never rr(). Look off: the old vector code runs untouched.
var PIX_GLASS={day:['#c4e6f2','#8cbfd6','#5f93ad'],night:['#5f869c','#3a5c72','#26404f']};
function pixSn(v){ return Math.round(v/PIX_ENV)*PIX_ENV; }
function pixFill(c,hx,x0,y0,x1,y1){ var a=pixSn(x0), b=pixSn(y0), w=pixSn(x1)-a, h=pixSn(y1)-b; if(w<PIX_ENV) w=PIX_ENV; if(h<PIX_ENV) h=PIX_ENV; c.fillStyle=hx; c.fillRect(a,b,w,h); }
function pixDoorDraw(c,w,d3,LIFT,keyed){   // the slab, its frame, two panels, the lock plate and the tag under it
  var R=pixWallRamps(d3), E=PIX_ENV, x0=w.x, y0=w.y-LIFT, x1=w.x+w.w, y1=w.y+w.h, hw=(x0+x1)/2, my=y0+(y1-y0)*0.42, lk=keyed?'#7fc4a0':'#ffc04a', ty=y1+16;
  pixFill(c,PIX_INK,x0,y0,x1,y1);
  pixFill(c,R.wall[2],x0+E,y0+E,x1-E,y1-E);
  pixFill(c,R.wall[0],x0+E,y0+E,x1-E,y0+2*E);
  pixFill(c,R.wall[3],x0+3*E,y0+3*E,hw-E,y1-3*E); pixFill(c,R.wall[3],hw+E,y0+3*E,x1-3*E,y1-3*E);
  pixFill(c,R.wall[1],x0+3*E,y0+3*E,hw-E,y0+4*E); pixFill(c,R.wall[1],hw+E,y0+3*E,x1-3*E,y0+4*E);
  pixFill(c,PIX_INK,hw-2*E,my,hw+2*E,my+5*E); pixFill(c,lk,hw-E,my+E,hw+E,my+4*E); pixFill(c,PIX_INK,hw-E/2,my+2*E,hw+E/2,my+3*E);
  pixFill(c,PIX_INK,hw-4*E,ty-4*E,hw+4*E,ty+3*E);   // the tag that floats under it
  pixFill(c,lk,hw-2*E,ty-2*E,hw+2*E,ty+2*E);
  pixFill(c,lk,hw-2*E,ty-4*E,hw-E,ty-2*E); pixFill(c,lk,hw+E,ty-4*E,hw+2*E,ty-2*E);
  pixFill(c,PIX_INK,hw-E/2,ty-E,hw+E/2,ty+E);
}
function pixWinDraw(c,w,d3,LIFT){   // a sill in the wall tones, an ink frame, three tones of glass, a lit streak, muntins
  var R=pixWallRamps(d3), E=PIX_ENV, GL=isDay()?PIX_GLASS.day:PIX_GLASS.night, sillH=Math.min(8,w.h), gTop=w.y-LIFT+8, gH=w.h+LIFT-8-sillH, x0=w.x, x1=w.x+w.w, gB=gTop+gH, sy=w.y+w.h-sillH, mx=(x0+x1)/2, my=gTop+gH/2;
  pixFill(c,R.wall[1],x0,sy,x1,w.y+w.h); pixFill(c,R.wall[0],x0,sy,x1,sy+E); pixFill(c,PIX_INK,x0,w.y+w.h-E,x1,w.y+w.h);
  pixFill(c,PIX_INK,x0,gTop,x1,gB);
  pixFill(c,GL[1],x0+E,gTop+E,x1-E,gB-E);
  pixFill(c,GL[2],x0+E,gB-2*E,x1-E,gB-E);
  pixFill(c,GL[0],x0+E,gTop+E,x0+E+Math.max(2*E,w.w*0.2),gB-2*E);
  pixFill(c,GL[0],x0+E,gTop+E,x1-E,gTop+2*E);
  if(w.w>w.h&&w.w>26) pixFill(c,PIX_INK,mx-E/2,gTop+E,mx+E/2,gB-E);
  if(gH>12) pixFill(c,PIX_INK,x0+E,my,x1-E,my+E);
}
function pixShDraw(c,w,LIFT){   // the stronghold shutter (sgate) and barricade (sblk); false for anything else
  var E=PIX_ENV, x=w.x, y=w.y, ww=w.w, hh=w.h, fy=y+hh-LIFT, ty=y-LIFT, horiz=(ww>=hh), k, n, N, px, py, on=Math.sin((G&&G.t||0)*5)>0;
  if(w.sgate){
    pixFill(c,'#4a525b',x,fy,x+ww,y+hh); pixFill(c,'#626d79',x,ty,x+ww,ty+hh); pixFill(c,'#8a96a3',x,ty,x+ww,ty+E);
    if(horiz){ for(k=x+6;k<x+ww-2;k+=8) pixFill(c,'#3a4048',k,fy+8,k+E,fy+LIFT-12); }
    else { for(k=fy+8;k<fy+LIFT-8;k+=8) pixFill(c,'#3a4048',x+2,k,x+ww-2,k+E); }
    n=horiz?Math.floor(ww/10):Math.floor(LIFT/10);
    for(k=0;k<n;k++){ if(horiz) pixFill(c,(k&1)?'#f0c020':'#15171a',x+2+k*10,fy+LIFT-10,x+12+k*10,fy+LIFT-2); else pixFill(c,(k&1)?'#f0c020':'#15171a',x+2,fy+2+k*10,x+ww-2,fy+12+k*10); }
    pixFill(c,PIX_INK,x+2,fy+1,x+ww-2,fy+7); pixFill(c,on?'#ff4028':'#9a2418',x+3,fy+2,x+ww-3,fy+6);
    pixFill(c,PIX_INK,x,y+hh-E,x+ww,y+hh);
    return true;
  }
  if(w.sblk){
    pixFill(c,'#3a2f22',x,fy,x+ww,y+hh); pixFill(c,'#4a3c2a',x,ty,x+ww,ty+hh); pixFill(c,'#7a6244',x,ty,x+ww,ty+E);
    N=Math.ceil(Math.max(ww,LIFT)/E);
    for(k=0;k<=N;k++){
      px=x+3+(ww-6)*k/N; py=fy+3+(LIFT-6)*k/N; pixFill(c,'#7a6244',px,py,px+2*E,py+2*E);
      px=x+ww-3-(ww-6)*k/N-2*E; pixFill(c,'#7a6244',px,py,px+2*E,py+2*E);
    }
    pixFill(c,'#b9a37c',x+ww/2-E,fy+LIFT/2-E,x+ww/2+E,fy+LIFT/2+E); pixFill(c,'#b9a37c',x+3,fy+3,x+3+E,fy+3+E); pixFill(c,'#b9a37c',x+ww-5,fy+LIFT-5,x+ww-5+E,fy+LIFT-5+E);
    pixFill(c,PIX_INK,x,y+hh-E,x+ww,y+hh);
    return true;
  }
  return false;
}
var PIXHUBW={};
function pixHubWall(c,q,d3,L){   // the Undercroft copy of the wall: baked once per wall, its tones pulled toward the room navy by hubWallHex as before
  var k=q.x+','+q.y+','+q.w+','+q.h+','+d3+','+L, e=PIXHUBW[k], E=PIX_ENV, D=DISTRICTS[d3], aw, tr, fr, s, id, p, T, F, x, y, fy, t, ci, bk, qv, wx=q.x|0, wy=q.y|0, sm;
  if(!D) return false;
  if(!e){
    aw=Math.max(1,Math.ceil(q.w/E)); tr=Math.max(1,Math.round(q.h/E)); fr=Math.max(0,Math.round(L/E));
    T=[hubWallHex(D.wallTop,0.30),hubWallHex(D.wallTop,0.45),hubWallHex(D.wallTop,0.58)];
    F=[hubWallHex(D.wall,0.42),hubWallHex(D.wall,0.55),hubWallHex(D.wall,0.66),hubWallHex(D.wall,0.76)];
    s=pixCanvas(aw,tr+fr); id=s.x.createImageData(aw,tr+fr); p=id.data;
    var put=function(x2,y2,hx){ var o=(y2*aw+x2)*4, r=pixWallRGB(hx); p[o]=r[0]; p[o+1]=r[1]; p[o+2]=r[2]; p[o+3]=255; };
    for(y=0;y<tr;y++) for(x=0;x<aw;x++){ qv=grit(wx+x*E,wy+y*E+5); t=(y===0)?0:(qv>0.93?2:1); put(x,y,T[t]); }
    for(fy=0;fy<fr;fy++){
      y=tr+fy; ci=(fy/3)|0;
      for(x=0;x<aw;x++){
        if(fy===fr-1){ put(x,y,PIX_INK); continue; }
        if(fy===fr-2){ put(x,y,F[3]); continue; }
        if(fy===0){ put(x,y,F[2]); continue; }
        bk=((x+(ci&1)*3)/6)|0; qv=grit(wx+bk*7,wy+ci*13);
        t=(fy%3===2||((x+(ci&1)*3)%6)===0)?3:(qv>0.86?0:(qv<0.08?2:1));
        put(x,y,F[t]);
      }
    }
    s.x.putImageData(id,0,0); e=PIXHUBW[k]=s.c;
  }
  sm=c.imageSmoothingEnabled; c.imageSmoothingEnabled=false;
  c.drawImage(e,q.x,q.y-L,e.width*E,e.height*E);
  c.imageSmoothingEnabled=sm;
  return true;
}
function wallSprite(wl2,d3,LIFT){
'@

SubRx @'
        var dTop=wl2.y-LIFT, dH=wl2.h+LIFT, dBot=wl2.y+wl2.h;
'@ @'
        if(pixOn()){ try{ pixDoorDraw(wc,wl2,d3,LIFT,_dk); continue; }catch(_pd){ PIX.errs++; } }   // v33.xx (cw-pixdoors): the pixel door, slab and tag
        var dTop=wl2.y-LIFT, dH=wl2.h+LIFT, dBot=wl2.y+wl2.h;
'@

SubRx @'
        var sillH=Math.min(8,wl2.h);
'@ @'
        if(pixOn()){ try{ pixWinDraw(wc,wl2,d3,LIFT); continue; }catch(_pw2){ PIX.errs++; } }   // v33.xx (cw-pixdoors): the pixel window
        var sillH=Math.min(8,wl2.h);
'@

SubRx @'
  var x=w.x, y=w.y, ww=w.w, hh=w.h, fy=y+hh-LIFT, ty=y-LIFT, t=G.t||0, k, horiz=(ww>=hh), n, a;
'@ @'
  if(pixOn()){ try{ if(pixShDraw(c,w,LIFT)) return; }catch(_ps){ PIX.errs++; } }   // v33.xx (cw-pixdoors): the pixel shutter and barricade
  var x=w.x, y=w.y, ww=w.w, hh=w.h, fy=y+hh-LIFT, ty=y-LIFT, t=G.t||0, k, horiz=(ww>=hh), n, a;
'@

SubRx @'
      wc.fillStyle=hubWallHex(DISTRICTS[d3].wall,0.55); wc.fillRect(q.x,q.y+q.h-L,q.w,L);
      wc.fillStyle=hubWallHex(DISTRICTS[d3].wallTop,0.45); wc.fillRect(q.x,q.y-L,q.w,q.h);
      wc.fillStyle='rgba(232,214,186,.10)'; wc.fillRect(q.x,q.y-L,q.w,1.2);
      wc.fillStyle='rgba(18,14,12,.55)';
      wc.fillRect(q.x,q.y+q.h-L,q.w,1);
      wc.fillRect(q.x,q.y+q.h-1,q.w,1);
'@ @'
      var _hpx=false; if(pixOn()){ try{ _hpx=pixHubWall(wc,q,d3,L); }catch(_ph){ PIX.errs++; } }   // v33.xx (cw-pixdoors): the pixel Undercroft wall
      if(!_hpx){
      wc.fillStyle=hubWallHex(DISTRICTS[d3].wall,0.55); wc.fillRect(q.x,q.y+q.h-L,q.w,L);
      wc.fillStyle=hubWallHex(DISTRICTS[d3].wallTop,0.45); wc.fillRect(q.x,q.y-L,q.w,q.h);
      wc.fillStyle='rgba(232,214,186,.10)'; wc.fillRect(q.x,q.y-L,q.w,1.2);
      wc.fillStyle='rgba(18,14,12,.55)';
      wc.fillRect(q.x,q.y+q.h-L,q.w,1);
      wc.fillRect(q.x,q.y+q.h-1,q.w,1);
      }
'@

SubRx @'
var VER='33.75';
'@ @'
var VER='33.76';
'@

$pat = "(?m)^  now:'v33\.75:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v33.76: With the pixel look on (the default), doors, windows, stronghold gates and barricades and the Undercroft walls are chunky solid pixels like the walls. With the look off, nothing changes. Check 33.76 fails on v33.75',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
