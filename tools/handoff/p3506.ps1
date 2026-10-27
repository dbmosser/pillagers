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

# FOG OF WAR OPTION (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  fogMark();
'@ @'
  fogMark();
  try{ fowMark(); }catch(_fw){}   // v35.xx (cw-fogwar): this raid's explored ground, only while the option is on
'@

SubRx @'
// PERSISTENCE. Bit-packed, because a per-cell array in JSON would be 2310
'@ @'
// v35.xx (cw-fogwar) HIS ORDER 10-27: "i want to adda fog of war effect that doesnt let you see the map
// -- whether in the main raid or in the map screen -- until you've explored it." A Settings option, off
// by default. G.fow is this raid only (G.seen keeps the career map), so every raid starts black.
// A cell counts as explored once you stood near it or its centre sat inside your sight (or your mate's,
// with shared sight on). The mask is one pixel per cell, rebuilt only when a new cell opens.
function fowEnsure(){ var n=G.seen.w*G.seen.h; if(!G.fow||G.fow.length!==n){ G.fow=new Uint8Array(n); G._fowDirty=1; } }
function fowAt(wx,wy){
  if(CFG.fogWar!==1||!G||!G.seen) return true;
  var cx=Math.floor(wx/FOG_CELL), cy=Math.floor(wy/FOG_CELL);
  if(!(cx>=0&&cy>=0&&cx<G.seen.w&&cy<G.seen.h)) return true;
  return !!(G.fow&&G.fow[cy*G.seen.w+cx]===1);
}
function fowInPoly(x,y,poly){ var c=false,i,j,a,b; for(i=0,j=poly.length-1;i<poly.length;j=i++){ a=poly[i]; b=poly[j]; if(((a.y>y)!==(b.y>y))&&(x<(b.x-a.x)*(y-a.y)/(b.y-a.y)+a.x)) c=!c; } return c; }
function fowMark(){
  if(CFG.fogWar!==1||!G||!G.seen||G.sim||!G.player) return;
  fowEnsure();
  var S=G.seen,F=G.fow,p=G.player,x,y,i,n=0,k,dx,dy;
  var near=150, r0=Math.ceil(near/FOG_CELL), cx=Math.floor(p.x/FOG_CELL), cy=Math.floor(p.y/FOG_CELL);
  for(y=cy-r0;y<=cy+r0;y++){ if(y<0||y>=S.h) continue;
    for(x=cx-r0;x<=cx+r0;x++){ if(x<0||x>=S.w) continue; k=y*S.w+x; if(F[k]) continue;
      dx=(x+0.5)*FOG_CELL-p.x; dy=(y+0.5)*FOG_CELL-p.y; if(dx*dx+dy*dy<=near*near){ F[k]=1; n++; } } }
  if(!(G._fowT>G.t-0.1)){
    G._fowT=G.t;
    var eyes=[{x:p.x,y:p.y,f:p.face}], R=Math.max(VF(),AMBR()), segs=G.vseg||G.map.segs;
    if(CFG.sharedSight!==0&&NET.on){ try{ var M=netMates(); for(i=0;i<M.length;i++) eyes.push({x:M[i].x,y:M[i].y,f:M[i].f}); }catch(_m){} }
    for(i=0;i<eyes.length;i++){
      var e=eyes[i]; if(!isFinite(e.x)||!isFinite(e.y)||!isFinite(e.f)) continue;
      var poly=buildVisPoly(e.x,e.y,e.f,segs); if(!poly||poly.length<3) continue;
      var x0=Math.max(0,Math.floor((e.x-R)/FOG_CELL)), x1=Math.min(S.w-1,Math.floor((e.x+R)/FOG_CELL));
      var y0=Math.max(0,Math.floor((e.y-R)/FOG_CELL)), y1=Math.min(S.h-1,Math.floor((e.y+R)/FOG_CELL));
      for(y=y0;y<=y1;y++) for(x=x0;x<=x1;x++){ k=y*S.w+x; if(F[k]) continue;
        var px=(x+0.5)*FOG_CELL, py=(y+0.5)*FOG_CELL; dx=px-e.x; dy=py-e.y;
        if(dx*dx+dy*dy<=R*R&&fowInPoly(px,py,poly)){ F[k]=1; n++; } }
    }
  }
  if(n) G._fowDirty=1;
}
function fowMask(){
  if(CFG.fogWar!==1||!G||!G.seen) return null;
  fowEnsure();
  var S=G.seen, cv=G._fowCv;
  if(!cv||cv.width!==S.w||cv.height!==S.h){ cv=document.createElement('canvas'); cv.width=S.w; cv.height=S.h; G._fowCv=cv; G._fowDirty=1; }
  if(G._fowDirty){
    var c=cv.getContext('2d'); if(!c) return null;
    var im=c.createImageData(S.w,S.h), d=im.data, F=G.fow;
    for(var i=0;i<F.length;i++){ var q=i*4; d[q]=4; d[q+1]=5; d[q+2]=8; d[q+3]=F[i]?0:255; }
    c.putImageData(im,0,0); G._fowDirty=0;
  }
  return cv;
}
// PERSISTENCE. Bit-packed, because a per-cell array in JSON would be 2310
'@

SubRx @'
  fx2.setTransform(Z*SOFTR,0,0,Z*SOFTR,-ox*Z*SOFTR,-oy*Z*SOFTR);   // v18.03: world units on the small sheet
'@ @'
  fx2.setTransform(Z*SOFTR,0,0,Z*SOFTR,-ox*Z*SOFTR,-oy*Z*SOFTR);   // v18.03: world units on the small sheet
  if(CFG.fogWar===1){ try{ var _fm=fowMask(); if(_fm){ fx2.save(); fx2.imageSmoothingEnabled=true; fx2.globalAlpha=1; fx2.globalCompositeOperation='source-over'; fx2.drawImage(_fm,0,0,G.seen.w*FOG_CELL,G.seen.h*FOG_CELL); fx2.restore(); } }catch(_fw){} }   // v35.xx (cw-fogwar)
'@

SubRx @'
      if(_LK.open) continue;
'@ @'
      if(_LK.open) continue;
      if(CFG.fogWar===1&&!fowAt(_LK.doorX,_LK.doorY)) continue;   // v35.xx (cw-fogwar)
'@

SubRx @'
    mmDoorMark(s,R,q.open);got.doors++; // v28.xx (cw-cx-minicues): open is hollow, locked is solid.
'@ @'
    if(CFG.fogWar===1&&!fowAt((q.doorX!==undefined)?q.doorX:q.x+q.w/2,(q.doorY!==undefined)?q.doorY:q.y+q.h/2)) continue;   // v35.xx (cw-fogwar)
    mmDoorMark(s,R,q.open);got.doors++; // v28.xx (cw-cx-minicues): open is hollow, locked is solid.
'@

SubRx @'
  t=hudZoomRect('cond',W,0,{x:f.tg.x,y:f.tg.y,w:f.tg.w,h:LH(20)});
'@ @'
  if(CFG.fogWar===1){ try{ var _fm2=fowMask(); if(_fm2){ ctx.save(); ctx.imageSmoothingEnabled=true; ctx.globalAlpha=1; ctx.globalCompositeOperation='source-over'; ctx.drawImage(_fm2,0,0,_fm2.width,_fm2.height,r.x+(0-x0)*sc,r.y+(0-y0)*sc,G.seen.w*FOG_CELL*sc,G.seen.h*FOG_CELL*sc); ctx.restore(); } }catch(_fw){} }   // v35.xx (cw-fogwar)
  t=hudZoomRect('cond',W,0,{x:f.tg.x,y:f.tg.y,w:f.tg.w,h:LH(20)});
'@

SubRx @'
  try{ drawMapOverlayRaw(); }
'@ @'
  var _fwB=ctx.getTransform();   // v35.xx (cw-fogwar)
  try{ drawMapOverlayRaw(); }
'@

SubRx @'
    if(had) ctx.fillText=prev; else delete ctx.fillText;
'@ @'
    if(had) ctx.fillText=prev; else delete ctx.fillText;
    if(CFG.fogWar===1&&G&&G.seen){ try{   // v35.xx (cw-fogwar): unexplored ground is black on the map screen, and its names go with it
      ctx.save(); ctx.setTransform(_fwB); var _M=mapProj();
      ctx.beginPath(); ctx.rect(_M.ox,_M.oy,WORLD_W*_M.sc,WORLD_H*_M.sc); ctx.clip();
      ctx.globalAlpha=1; ctx.globalCompositeOperation='source-over'; ctx.imageSmoothingEnabled=true;
      var _fm3=fowMask(); if(_fm3) ctx.drawImage(_fm3,_M.ox,_M.oy,G.seen.w*FOG_CELL*_M.sc,G.seen.h*FOG_CELL*_M.sc);
      ctx.restore();
      for(var _qi=Q.length-1;_qi>=0;_qi--){ var _L=Q[_qi], _t=String(_L.s);
        if(_t==='SECTOR MAP'||_t==='WAYPOINT'||_t.indexOf('SURVEYED')===0||(hdrY!==null&&_L.y<=hdrY+2)) continue;
        var _m=_L.m, _sx=_m.a*_L.x+_m.c*_L.y+_m.e, _sy=_m.b*_L.x+_m.d*_L.y+_m.f;
        var _w=mapScreenToWorld((_sx-_fwB.e)/_fwB.a,(_sy-_fwB.f)/_fwB.d);
        if(_w.x>=0&&_w.y>=0&&_w.x<=WORLD_W&&_w.y<=WORLD_H&&!fowAt(_w.x,_w.y)) Q.splice(_qi,1);
      }
    }catch(_fw){} }
'@

SubRx @'
  {k:'gfxScale', label:'Render resolution',
'@ @'
  {k:'fogWar', label:'Fog of war',
   hint:'Unexplored ground stays black, in the raid and on the map.',   // v35.xx (cw-fogwar): his order of 10-27
   opts:[
     {n:'Off', cfg:{fogWar:0}},
     {n:'On',  cfg:{fogWar:1}}
   ], def:0},
  {k:'gfxScale', label:'Render resolution',
'@

SubRx @'
sharedSight:'THE RAID',raiders:'THE RAID',
'@ @'
sharedSight:'THE RAID',fogWar:'THE RAID',raiders:'THE RAID',
'@

SubRx @'
var VER='35.05';
'@ @'
var VER='35.06';
'@

$pat = "(?m)^  now:'v35\.05:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v35.06: Settings has a fog of war option. On, ground you have not explored stays black in the raid and on the map. Check 35.06 fails on v35.05',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
