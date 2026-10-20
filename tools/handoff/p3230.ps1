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

# MAP LABELS HAVE ROOM (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mapPlaceLabels(Q,hdrY,fn){
  var zn={}, i, j, G2=[], cur=null, placed=[], out=[], L, P0, k, tries, ok, dx, dy, r, rr, gh, gw;
  if(!Q.length) return 0;
  try{ ((G&&G.map&&G.map.zones)||[]).forEach(function(z){ if(z&&z.name) zn[z.name]=1; }); }catch(_z){}
  function pri(L){ var t=String(L.s);
    if((hdrY!==null&&L.y<=hdrY+2)||(/^SURVEYED|^what you walk/).test(t)) return 9;
    if(zn[t]||L.ga<0.6) return 0;
    if((/^EXTRACT |^WAYPOINT/).test(t)) return 6;
    if((/LOCKED|^SEAL/).test(t)) return 5;
    if((/^HOT GROUND|^PEDDLER|^SURVIVOR|^ENCAMPMENT/).test(t)) return 4;
    if((/^CACHE|^STRONGBOX/).test(t)) return 3;
    return 2; }
  for(i=0;i<Q.length;i++){
    L=Q[i]; L.p=pri(L);
    if(cur&&!L.mark&&!cur.last.mark&&L.p!==9&&cur.p!==9&&L.ta===cur.last.ta&&Math.abs(L.x-cur.last.x)<1&&L.y>cur.last.y&&L.y-cur.last.y<2.4*Math.max(L.fp,cur.last.fp)){ cur.items.push(L); cur.last=L; cur.p=Math.max(cur.p,L.p); continue; }
    cur={items:[L],last:L,p:L.p,i:i}; G2.push(cur);
  }
  G2.forEach(function(g){ var u=null; g.items.forEach(function(L){ var q=mapLabelRect(L,0,0); u=u?{l:Math.min(u.l,q.l),t:Math.min(u.t,q.t),r:Math.max(u.r,q.r),b:Math.max(u.b,q.b)}:q; }); g.r=u; });
  /* v31.xx (cw-mapstyle3): the mark a tag is anchored to (the tag sits just above it) is no obstacle for that tag, so the tag keeps its place at the mark and is not pushed off it (the critic: labels float away from their icons) */
  var _mz=(typeof hudRes==='function')?hudRes():1;
  G2.forEach(function(g){ var L0=g.items[0], sx=L0.x*L0.m.a+L0.m.e, sy=L0.y*L0.m.d+L0.m.f, q, I; g.own=[]; for(q=0;q<MAPICONS.length;q++){ I=MAPICONS[q]; if(sx>=I.l&&sx<=I.r&&sy>=I.t-30*_mz&&sy<=(I.t+I.b)/2) g.own.push(q); } });
  function hits(a,ic,own){ var _ax=Math.max(2,(a.b-a.t)*0.3); for(var h=0;h<placed.length;h++){ var b=placed[h]; if(a.l<b.r+_ax&&b.l<a.r+_ax&&a.t<b.b+1&&b.t<a.b+1) return true; }   /* v31.xx (cw-mapstyle3): a tag keeps a third of its height of air from a tag beside it (blast freezer, locked touched strongbox) */
    if(ic) for(var h2=0;h2<MAPICONS.length;h2++){ if(own&&own.indexOf(h2)>=0) continue; var b2=MAPICONS[h2]; if(a.l<b2.r+5&&b2.l<a.r+5&&a.t<b2.b+5&&b2.t<a.b+5) return true; }   // v31.xx (cw-mapstyle): a label never sits on a mark
    return false; }
  // v19.31, seen on the 4K map screenshot (2026-10-08): a label moved off a clash could be moved anywhere, so RECEIVING APRON went up
  // past the SECTOR MAP line and half off the top of the screen. A moved label now stays on the screen and below the header line.
  var _bT=0, _bL=0, _bW=(ctx&&ctx.canvas)?ctx.canvas.width:1e9, _bH=(ctx&&ctx.canvas)?ctx.canvas.height:1e9;
  /* v31.xx (cw-mapstyle): a moved label stays inside the map frame, not the whole screen */ if(MAPBOX){ _bT=MAPBOX.t; _bL=MAPBOX.l; _bW=MAPBOX.r; _bH=MAPBOX.b; }  G2.slice().sort(function(a,b){ return (b.p-a.p)||(a.i-b.i); }).forEach(function(g){
    gh=g.r.b-g.r.t; gw=g.r.r-g.r.l; ok=false;
    if(g.p===9){ placed.push(g.r); g.dx=0; g.dy=0; out.push(g); if(hdrY!==null&&g.items.some(function(L){ return L.y<=hdrY+2; })) _bT=Math.max(_bT,g.r.b); return; }
    // v19.64, seen on the 4K map screenshot (2026-10-08): a tag sits just above its marker, so moving it DOWN off a clash put it on its
    // own marker (CACHE printed across its ring). Up and to the sides are tried first now, down last.
    tries=[[0,0],[0,-(gh+3)],[-(gw*0.6),0],[gw*0.6,0],[0,-2*(gh+3)],[0,gh+3],[0,2*(gh+3)],[0,-3*(gh+3)],[0,3*(gh+3)]];
    // v28.xx (cw-cx-sectorhold-o03): try rows immediately beside each icon before sending a packed label above the room.
    if(g.items[0].mark){
      var M0=g.items[0].mark, px=M0.x*M0.m.a+M0.m.e, py=M0.y*M0.m.d+M0.m.f,
          midX=(g.r.l+g.r.r)/2, midY=(g.r.t+g.r.b)/2, sideY=py-midY,
          leftX=px-20*_mz-g.r.r, rightX=px+20*_mz-g.r.l, pitch=gh+4*_mz, clusterL=px-15*_mz, clusterR=px+15*_mz,
          clusterMarks=[{l:clusterL,t:py-15*_mz,r:clusterR,b:py+15*_mz}];
      MAPICONS.forEach(function(I){ if(Math.abs((I.l+I.r)/2-px)<=45*_mz&&Math.abs((I.t+I.b)/2-py)<=45*_mz){ clusterL=Math.min(clusterL,I.l); clusterR=Math.max(clusterR,I.r); clusterMarks.push(I); } });
      var clusterLeft=clusterL-6*_mz-g.r.r, clusterRight=clusterR+6*_mz-g.r.l;
      tries=[[0,0],[leftX,sideY],[rightX,sideY],[px-midX,py-20*_mz-g.r.b],[px-midX,py+20*_mz-g.r.t]];
      tries.push([clusterLeft,sideY],[clusterRight,sideY]);
      for(var row=1;row<=8;row++){
        tries.push([leftX,sideY-row*pitch],[rightX,sideY-row*pitch],[leftX,sideY+row*pitch],[rightX,sideY+row*pitch],[clusterLeft,sideY-row*pitch],[clusterRight,sideY-row*pitch],[clusterLeft,sideY+row*pitch],[clusterRight,sideY+row*pitch],[0,-row*pitch],[0,row*pitch]);
      }
      // v28.xx (cw-cx-sectorhold-o03): include exact clearances around nearby labels and icons; whole-row jumps can miss a usable gap of only a few pixels.
      var localX=[0,leftX,rightX,clusterLeft,clusterRight,_bL-g.r.l,_bW-g.r.r], localY=[0,sideY], xpad=Math.max(8*_mz,gh*0.3+_mz), ypad=4*_mz;
      clusterMarks.forEach(function(I){ localX.push(I.l-6*_mz-g.r.r,I.r+6*_mz-g.r.l); localY.push(I.t-6*_mz-g.r.b,I.b+6*_mz-g.r.t); });
      placed.forEach(function(B){ if(Math.abs((B.l+B.r)/2-px)<gw+80*_mz&&Math.abs((B.t+B.b)/2-py)<gh+80*_mz){ localX.push(B.l-xpad-g.r.r,B.r+xpad-g.r.l); localY.push(B.t-ypad-g.r.b,B.b+ypad-g.r.t); } });
      localX.forEach(function(x){ localY.forEach(function(y){ if(g.r.l+x>=_bL&&g.r.r+x<=_bW&&g.r.t+y>=_bT&&g.r.b+y<=_bH) tries.push([x,y]); }); });
      // v28.xx (cw-cx-sectorhold-o03): stay next to the marker group first, then minimize movement; the connector still identifies this tag's exact icon.
      function nearScore(q){ var gap=Infinity; clusterMarks.forEach(function(I){ var dx=Math.max(0,I.l-(g.r.r+q[0]),g.r.l+q[0]-I.r), dy=Math.max(0,I.t-(g.r.b+q[1]),g.r.t+q[1]-I.b); gap=Math.min(gap,dx*dx+dy*dy); }); return gap*1000+q[0]*q[0]+q[1]*q[1]; }
      tries.forEach(function(q){ q[2]=nearScore(q); }); tries.sort(function(a,b){ return a[2]-b[2]; });
    }
    for(var _pass=0;_pass<2&&!ok;_pass++) for(k=0;k<tries.length&&!ok;k++){ dx=tries[k][0]; dy=tries[k][1]; r={l:g.r.l+dx,t:g.r.t+dy,r:g.r.r+dx,b:g.r.b+dy}; if(r.t<_bT||r.b>_bH||r.l<_bL||r.r>_bW) continue; if(!hits(r,_pass===0,dy<=0?g.own:null)){ ok=true; g.dx=dx; g.dy=dy; placed.push(r); out.push(g); } }   // v31.xx (cw-mapstyle): first clear of the marks too, then clear of the other labels only
    // v28.xx (cw-cx-sectorhold-o03): exhaust the map for an anchored tag instead of deliberately painting it across another label.
    if(!ok&&g.items[0].mark){
      var best=null, score=Infinity, step=gh+4*_mz;
      for(var yy=_bT;yy+gh<=_bH;yy+=step) for(var xx=_bL;xx+gw<=_bW;xx+=8*_mz){
        var box={l:xx,t:yy,r:xx+gw,b:yy+gh}, dist2=Math.pow(xx-g.r.l,2)+Math.pow(yy-g.r.t,2);
        if(dist2<score&&!hits(box,false,null)){ best=box; score=dist2; }
      }
      if(best){ g.dx=best.l-g.r.l; g.dy=best.t-g.r.t; placed.push(best); out.push(g); ok=true; }
    }
    if(!ok&&g.p>=3&&!g.items[0].mark){ g.dx=0; g.dy=0; placed.push(g.r); out.push(g); }
  });
  out.sort(function(a,b){ return a.i-b.i; });
  out.forEach(function(g){ g.items.forEach(function(L){
    ctx.save(); try{ ctx.setTransform(L.m); }catch(_t){}
    ctx.font=L.font; ctx.fillStyle=L.fs; ctx.textAlign=L.ta; ctx.textBaseline=L.tb; ctx.globalAlpha=L.ga;
    // v28.xx (cw-cx-sectorhold-o03): a displaced loot label stays visibly attached to its own icon, never a neighbouring cache.
    if(L.mark&&(Math.abs(g.dx||0)>1||Math.abs(g.dy||0)>1)){
      var B=mapLabelRect(L,g.dx,g.dy), M=L.mark, ax=M.x*M.m.a+M.m.e, ay=M.y*M.m.d+M.m.f,
          ex=clamp(ax,B.l,B.r), ey=clamp(ay,B.t,B.b), vx=ex-ax, vy=ey-ay, len=Math.sqrt(vx*vx+vy*vy), cut=14*_mz;
      if(len>cut+2){ ctx.save(); ctx.setTransform(1,0,0,1,0,0); ctx.strokeStyle=UIC.tx_2; ctx.lineWidth=Math.max(1,_mz); ctx.beginPath(); ctx.moveTo(ax+vx*cut/len,ay+vy*cut/len); ctx.lineTo(ex,ey); ctx.stroke(); ctx.restore(); }
    }
    if(L.h>0){ try{ ctx.lineJoin='round'; ctx.lineWidth=L.h; ctx.strokeStyle='rgba(11,12,13,.88)'; ctx.strokeText((typeof TX==='function')?TX(String(L.s)):String(L.s),L.x+(g.dx||0)/(L.m.a||1),L.y+(g.dy||0)/(L.m.d||1)); }catch(_hl){} }   // v31.xx (cw-mapstyle): the halo
    (fn||CanvasRenderingContext2D.prototype.fillText).call(ctx,L.s,L.x+(g.dx||0)/(L.m.a||1),L.y+(g.dy||0)/(L.m.d||1));
    ctx.restore(); }); });
  return out.length;
}

'@ @'
// v28.xx (cw-cx-mapspace-o03): keep every loot tag; 12 scaled px of air separates labels, and leaders start at their own icon.
function mapPlaceLabels(Q,hdrY,fn){
  var zn={}, i, j, G2=[], cur=null, placed=[], out=[], L, P0, k, tries, ok, dx, dy, r, rr, gh, gw;
  if(!Q.length) return 0;
  try{ ((G&&G.map&&G.map.zones)||[]).forEach(function(z){ if(z&&z.name) zn[z.name]=1; }); }catch(_z){}
  function pri(L){ var t=String(L.s);
    if((hdrY!==null&&L.y<=hdrY+2)||(/^SURVEYED|^what you walk/).test(t)) return 9;
    if(zn[t]||L.ga<0.6) return 0;
    if((/^EXTRACT |^WAYPOINT/).test(t)) return 6;
    if((/LOCKED|^SEAL/).test(t)) return 5;
    if((/^HOT GROUND|^PEDDLER|^SURVIVOR|^ENCAMPMENT/).test(t)) return 4;
    if((/^CACHE|^STRONGBOX/).test(t)) return 3;
    return 2; }
  for(i=0;i<Q.length;i++){
    L=Q[i]; L.p=pri(L);
    if(cur&&!L.mark&&!cur.last.mark&&L.p!==9&&cur.p!==9&&L.ta===cur.last.ta&&Math.abs(L.x-cur.last.x)<1&&L.y>cur.last.y&&L.y-cur.last.y<2.4*Math.max(L.fp,cur.last.fp)){ cur.items.push(L); cur.last=L; cur.p=Math.max(cur.p,L.p); continue; }
    cur={items:[L],last:L,p:L.p,i:i}; G2.push(cur);
  }
  G2.forEach(function(g){ var u=null; g.items.forEach(function(L){ var q=mapLabelRect(L,0,0); u=u?{l:Math.min(u.l,q.l),t:Math.min(u.t,q.t),r:Math.max(u.r,q.r),b:Math.max(u.b,q.b)}:q; }); g.r=u; });
  /* v31.xx (cw-mapstyle3): the mark a tag is anchored to (the tag sits just above it) is no obstacle for that tag, so the tag keeps its place at the mark and is not pushed off it (the critic: labels float away from their icons) */
  var _mz=(typeof hudRes==='function')?hudRes():1;
  G2.forEach(function(g){ var L0=g.items[0], sx=L0.x*L0.m.a+L0.m.e, sy=L0.y*L0.m.d+L0.m.f, q, I; g.own=[]; for(q=0;q<MAPICONS.length;q++){ I=MAPICONS[q]; if(sx>=I.l&&sx<=I.r&&sy>=I.t-30*_mz&&sy<=(I.t+I.b)/2) g.own.push(q); } });
  function hits(a,ic,own){ var _ax=12*_mz, _ay=12*_mz; for(var h=0;h<placed.length;h++){ var b=placed[h]; if(a.l<b.r+_ax&&b.l<a.r+_ax&&a.t<b.b+_ay&&b.t<a.b+_ay) return true; }   /* v31.xx (cw-mapstyle3): a tag keeps a third of its height of air from a tag beside it (blast freezer, locked touched strongbox) */
    if(ic) for(var h2=0;h2<MAPICONS.length;h2++){ if(own&&own.indexOf(h2)>=0) continue; var b2=MAPICONS[h2]; if(a.l<b2.r+5&&b2.l<a.r+5&&a.t<b2.b+5&&b2.t<a.b+5) return true; }   // v31.xx (cw-mapstyle): a label never sits on a mark
    return false; }
  // v19.31, seen on the 4K map screenshot (2026-10-08): a label moved off a clash could be moved anywhere, so RECEIVING APRON went up
  // past the SECTOR MAP line and half off the top of the screen. A moved label now stays on the screen and below the header line.
  var _bT=0, _bL=0, _bW=(ctx&&ctx.canvas)?ctx.canvas.width:1e9, _bH=(ctx&&ctx.canvas)?ctx.canvas.height:1e9;
  /* v31.xx (cw-mapstyle): a moved label stays inside the map frame, not the whole screen */ if(MAPBOX){ _bT=MAPBOX.t; _bL=MAPBOX.l; _bW=MAPBOX.r; _bH=MAPBOX.b; }  G2.slice().sort(function(a,b){ return (b.p-a.p)||(a.i-b.i); }).forEach(function(g){
    gh=g.r.b-g.r.t; gw=g.r.r-g.r.l; ok=false;
    if(g.p===9){ placed.push(g.r); g.dx=0; g.dy=0; out.push(g); if(hdrY!==null&&g.items.some(function(L){ return L.y<=hdrY+2; })) _bT=Math.max(_bT,g.r.b); return; }
    // v19.64, seen on the 4K map screenshot (2026-10-08): a tag sits just above its marker, so moving it DOWN off a clash put it on its
    // own marker (CACHE printed across its ring). Up and to the sides are tried first now, down last.
    tries=[[0,0],[0,-(gh+3)],[-(gw*0.6),0],[gw*0.6,0],[0,-2*(gh+3)],[0,gh+3],[0,2*(gh+3)],[0,-3*(gh+3)],[0,3*(gh+3)]];
    // v28.xx (cw-cx-sectorhold-o03): try rows immediately beside each icon before sending a packed label above the room.
    if(g.items[0].mark){
      var M0=g.items[0].mark, px=M0.x*M0.m.a+M0.m.e, py=M0.y*M0.m.d+M0.m.f,
          midX=(g.r.l+g.r.r)/2, midY=(g.r.t+g.r.b)/2, sideY=py-midY,
          leftX=px-20*_mz-g.r.r, rightX=px+20*_mz-g.r.l, pitch=gh+12*_mz, clusterL=px-15*_mz, clusterR=px+15*_mz,
          clusterMarks=[{l:clusterL,t:py-15*_mz,r:clusterR,b:py+15*_mz}];
      MAPICONS.forEach(function(I){ if(Math.abs((I.l+I.r)/2-px)<=45*_mz&&Math.abs((I.t+I.b)/2-py)<=45*_mz){ clusterL=Math.min(clusterL,I.l); clusterR=Math.max(clusterR,I.r); clusterMarks.push(I); } });
      var clusterLeft=clusterL-6*_mz-g.r.r, clusterRight=clusterR+6*_mz-g.r.l;
      tries=[[0,0],[leftX,sideY],[rightX,sideY],[px-midX,py-20*_mz-g.r.b],[px-midX,py+20*_mz-g.r.t]];
      tries.push([clusterLeft,sideY],[clusterRight,sideY]);
      for(var row=1;row<=8;row++){
        tries.push([leftX,sideY-row*pitch],[rightX,sideY-row*pitch],[leftX,sideY+row*pitch],[rightX,sideY+row*pitch],[clusterLeft,sideY-row*pitch],[clusterRight,sideY-row*pitch],[clusterLeft,sideY+row*pitch],[clusterRight,sideY+row*pitch],[0,-row*pitch],[0,row*pitch]);
      }
      // v28.xx (cw-cx-sectorhold-o03): include exact clearances around nearby labels and icons; whole-row jumps can miss a usable gap of only a few pixels.
      var localX=[0,leftX,rightX,clusterLeft,clusterRight,_bL-g.r.l,_bW-g.r.r], localY=[0,sideY], xpad=12*_mz, ypad=12*_mz;
      clusterMarks.forEach(function(I){ localX.push(I.l-6*_mz-g.r.r,I.r+6*_mz-g.r.l); localY.push(I.t-6*_mz-g.r.b,I.b+6*_mz-g.r.t); });
      placed.forEach(function(B){ if(Math.abs((B.l+B.r)/2-px)<gw+80*_mz&&Math.abs((B.t+B.b)/2-py)<gh+80*_mz){ localX.push(B.l-xpad-g.r.r,B.r+xpad-g.r.l); localY.push(B.t-ypad-g.r.b,B.b+ypad-g.r.t); } });
      localX.forEach(function(x){ localY.forEach(function(y){ if(g.r.l+x>=_bL&&g.r.r+x<=_bW&&g.r.t+y>=_bT&&g.r.b+y<=_bH) tries.push([x,y]); }); });
      // v28.xx (cw-cx-sectorhold-o03): stay next to the marker group first, then minimize movement; the connector still identifies this tag's exact icon.
      function nearScore(q){ var I={l:px-8*_mz,r:px+8*_mz,t:py-8*_mz,b:py+8*_mz}, dx=Math.max(0,I.l-(g.r.r+q[0]),g.r.l+q[0]-I.r), dy=Math.max(0,I.t-(g.r.b+q[1]),g.r.t+q[1]-I.b); return (dx*dx+dy*dy)*1000+q[0]*q[0]+q[1]*q[1]; }
      tries.forEach(function(q){ q[2]=nearScore(q); }); tries.sort(function(a,b){ return a[2]-b[2]; });
    }
    for(var _pass=0;_pass<(g.items[0].mark?1:2)&&!ok;_pass++) for(k=0;k<tries.length&&!ok;k++){ dx=tries[k][0]; dy=tries[k][1]; r={l:g.r.l+dx,t:g.r.t+dy,r:g.r.r+dx,b:g.r.b+dy}; if(r.t<_bT||r.b>_bH||r.l<_bL||r.r>_bW) continue; if(!hits(r,_pass===0,(!g.items[0].mark&&dy<=0)?g.own:null)){ ok=true; g.dx=dx; g.dy=dy; placed.push(r); out.push(g); } }   // v31.xx (cw-mapstyle): first clear of the marks too, then clear of the other labels only
    // v28.xx (cw-cx-sectorhold-o03): exhaust the map for an anchored tag instead of deliberately painting it across another label.
    if(!ok&&g.items[0].mark){
      var best=null, score=Infinity, step=gh+12*_mz;
      for(var yy=_bT;yy+gh<=_bH;yy+=step) for(var xx=_bL;xx+gw<=_bW;xx+=8*_mz){
        var box={l:xx,t:yy,r:xx+gw,b:yy+gh}, dist2=Math.pow(xx-g.r.l,2)+Math.pow(yy-g.r.t,2);
        if(dist2<score&&!hits(box,true,null)){ best=box; score=dist2; }
      }
      if(best){ g.dx=best.l-g.r.l; g.dy=best.t-g.r.t; placed.push(best); out.push(g); ok=true; }
    }
    if(!ok&&g.p>=3&&!g.items[0].mark){ g.dx=0; g.dy=0; placed.push(g.r); out.push(g); }
  });
  out.sort(function(a,b){ return a.i-b.i; });
  out.forEach(function(g){ g.items.forEach(function(L){
    ctx.save(); try{ ctx.setTransform(L.m); }catch(_t){}
    ctx.font=L.font; ctx.fillStyle=L.fs; ctx.textAlign=L.ta; ctx.textBaseline=L.tb; ctx.globalAlpha=L.ga;
    // v28.xx (cw-cx-sectorhold-o03): a displaced loot label stays visibly attached to its own icon, never a neighbouring cache.
    if(L.mark&&(Math.abs(g.dx||0)>1||Math.abs(g.dy||0)>1)){
      var B=mapLabelRect(L,g.dx,g.dy), M=L.mark, ax=M.x*M.m.a+M.m.e, ay=M.y*M.m.d+M.m.f,
          ex=clamp(ax,B.l,B.r), ey=clamp(ay,B.t,B.b), vx=ex-ax, vy=ey-ay, len=Math.sqrt(vx*vx+vy*vy), cut=8*_mz;
      if(len>cut+2){ ctx.save(); ctx.setTransform(1,0,0,1,0,0); ctx.strokeStyle=UIC.tx_2; ctx.lineWidth=Math.max(1,_mz); ctx.beginPath(); ctx.moveTo(ax+vx*cut/len,ay+vy*cut/len); ctx.lineTo(ex,ey); ctx.stroke(); ctx.restore(); }
    }
    if(L.h>0){ try{ ctx.lineJoin='round'; ctx.lineWidth=L.h; ctx.strokeStyle='rgba(11,12,13,.88)'; ctx.strokeText((typeof TX==='function')?TX(String(L.s)):String(L.s),L.x+(g.dx||0)/(L.m.a||1),L.y+(g.dy||0)/(L.m.d||1)); }catch(_hl){} }   // v31.xx (cw-mapstyle): the halo
    (fn||CanvasRenderingContext2D.prototype.fillText).call(ctx,L.s,L.x+(g.dx||0)/(L.m.a||1),L.y+(g.dy||0)/(L.m.d||1));
    ctx.restore(); }); });
  return out.length;
}

'@

SubRx @'
function mapContractsDraw(cd,rows){
  var c=cd.col, z=cd.z, u=cd.u, q=Math.round(20*u), th=Math.round(52*u), r=Math.max(2,Math.round(4*z)), lw=Math.max(1,Math.round(z)), n=rows.length, nd=0, i, row, ry, pitch, two,
      y0, avail, nat=Math.round(76*u), mid, mid2, wRew, wCnt, maxW, barW, bh=Math.max(3,Math.round(4*z)), txt, cnt, cc, ch, fr, fcol,
      nameFont=FSz('600 15.4px '+HUDF,z), cntFont=FSz(TYPE.label,z), rewFont=FSz('600 12px '+HUDF,z);
  for(i=0;i<n;i++) if(rows[i].done) nd++;
  y0=c.y+th; avail=c.h-th-Math.round(8*u); pitch=Math.min(nat,Math.floor(avail/n));
  ch=Math.min(c.h,th+n*pitch+Math.round(8*u));
  if(th+n*nat+Math.round(8*u)>=0.7*c.h){ pitch=Math.floor(avail/n); ch=c.h; }   // v31.xx (cw-mapstyle3): a list that fills the column runs to the bottom of the map frame (the panel ended 6 px short of it)
  two=(pitch>=Math.round(58*u));
  ctx.save();
  try{
    mapRR(c.x+lw/2,c.y+lw/2,c.w-lw,ch-lw,r); ctx.fillStyle=UIC.ui_raised; ctx.fill(); ctx.lineWidth=lw; ctx.strokeStyle=UIC.ui_line; ctx.stroke();
    ctx.textBaseline='middle'; ctx.textAlign='left';
    ctx.font=nameFont; ctx.fillStyle=UIC.tx_1; ctx.fillText('contracts',c.x+q,c.y+th/2);
    ctx.font=cntFont; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(nd+' of '+n+' done',c.x+c.w-q,c.y+th/2); ctx.textAlign='left';
    ctx.strokeStyle=UIC.ui_line; ctx.lineWidth=lw; ctx.beginPath(); ctx.moveTo(c.x+lw,c.y+th); ctx.lineTo(c.x+c.w-lw,c.y+th); ctx.stroke();
    for(i=0;i<n;i++){
      row=rows[i]; ry=y0+i*pitch;
      cnt=row.done?'done':(row.rule?row.rule:(row.p+'/'+row.n));
      cc=row.done?UIC.ok:((row.rule==='broken')?UIC.danger:((row.rule==='ready')?UIC.ok:UIC.tx_2));
      fr=row.rule?((row.rule==='holding'||row.rule==='open')?0:1):(row.p/row.n);   // a rule contract has the same bar: empty while it holds, full when it is ready or broken
      fcol=(row.done||row.rule==='ready')?UIC.ok:((row.rule==='broken')?UIC.danger:UIC.acc);
      txt=row.pay?('$'+row.pay.toLocaleString()):'';
      ctx.font=rewFont; wRew=txt?hudRawW(txt):0;
      ctx.font=cntFont; wCnt=hudRawW(cnt);
      mid=two?(ry+pitch*0.34):(ry+pitch*0.40); mid2=ry+pitch*0.74;
      maxW=c.w-2*q-(wRew?(wRew+q):0)-(two?0:(wCnt+q));
      ctx.font=nameFont; ctx.fillStyle=UIC.tx_1; ctx.textAlign='left'; ctx.fillText(mapFit(row.name,maxW),c.x+q,mid);
      if(txt){ ctx.font=rewFont; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(txt,c.x+c.w-q,mid); ctx.textAlign='left'; }
      if(two){
        barW=c.w-2*q-wCnt-Math.round(12*u);
        ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(c.x+q,mid2-bh/2,barW,bh);
        if(fr>0){ ctx.fillStyle=fcol; ctx.fillRect(c.x+q,mid2-bh/2,barW*fr,bh); }
        ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q,mid2); ctx.textAlign='left';
      } else {
        ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q-(wRew?(wRew+q):0),mid); ctx.textAlign='left';
        barW=c.w-2*q; ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW,bh);
        if(fr>0){ ctx.fillStyle=fcol; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW*fr,bh); }
      }
      if(i<n-1&&two){ ctx.strokeStyle=UIC.ui_line; ctx.lineWidth=lw; ctx.beginPath(); ctx.moveTo(c.x+q,ry+pitch); ctx.lineTo(c.x+c.w-q,ry+pitch); ctx.stroke(); }
    }
  } finally { ctx.restore(); }
}

'@ @'
// v28.xx (cw-cx-mapspace-o03): fixed status width aligns all tracks; secondary names keep the map first. No contract is hidden.
function mapContractsDraw(cd,rows){
  var c=cd.col, z=cd.z, u=cd.u, q=Math.round(20*u), th=Math.round(52*u), r=Math.max(2,Math.round(4*z)), lw=Math.max(1,Math.round(z)), n=rows.length, nd=0, i, row, ry, pitch, two,
      y0, avail, nat=Math.round(76*u), mid, mid2, wRew, wCnt, maxW, barW, bh=Math.max(3,Math.round(4*z)), txt, cnt, cc, ch, fr, fcol,
      nameFont=FSz('600 15.4px '+HUDF,z), cntFont=FSz(TYPE.label,z), rewFont=FSz(TYPE.label,z);
  for(i=0;i<n;i++) if(rows[i].done) nd++;
  y0=c.y+th; avail=c.h-th-Math.round(8*u); pitch=Math.min(nat,Math.floor(avail/n));
  ch=Math.min(c.h,th+n*pitch+Math.round(8*u));
  if(th+n*nat+Math.round(8*u)>=0.7*c.h){ pitch=Math.floor(avail/n); ch=c.h; }   // v31.xx (cw-mapstyle3): a list that fills the column runs to the bottom of the map frame (the panel ended 6 px short of it)
  two=(pitch>=Math.round(58*u));
  ctx.save();
  try{
    mapRR(c.x+lw/2,c.y+lw/2,c.w-lw,ch-lw,r); ctx.fillStyle=UIC.ui_raised; ctx.fill(); ctx.lineWidth=lw; ctx.strokeStyle=UIC.ui_line; ctx.stroke();
    ctx.textBaseline='middle'; ctx.textAlign='left';
    ctx.font=nameFont; ctx.fillStyle=UIC.tx_1; ctx.fillText('contracts',c.x+q,c.y+th/2);
    ctx.font=cntFont; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(nd+' of '+n+' done',c.x+c.w-q,c.y+th/2); ctx.textAlign='left';
    ctx.strokeStyle=UIC.ui_line; ctx.lineWidth=lw; ctx.beginPath(); ctx.moveTo(c.x+lw,c.y+th); ctx.lineTo(c.x+c.w-lw,c.y+th); ctx.stroke();
    for(i=0;i<n;i++){
      row=rows[i]; ry=y0+i*pitch;
      cnt=row.done?'done':(row.rule?row.rule:(row.p+'/'+row.n));
      cc=row.done?UIC.ok:((row.rule==='broken')?UIC.danger:((row.rule==='ready'||row.rule==='holding')?UIC.ok:UIC.tx_2));
      fr=row.rule?((row.rule==='holding'||row.rule==='open')?0:1):(row.p/row.n);   // a rule contract has the same bar: empty while it holds, full when it is ready or broken
      fcol=(row.done||row.rule==='ready')?UIC.ok:((row.rule==='broken')?UIC.danger:UIC.acc);
      txt=row.pay?('$'+row.pay.toLocaleString()):'';
      ctx.font=rewFont; wRew=txt?hudRawW(txt):0;
      ctx.font=cntFont; wCnt=Math.max(hudRawW('holding'),hudRawW('broken'),hudRawW('99/99'));
      mid=two?(ry+pitch*0.34):(ry+pitch*0.40); mid2=ry+pitch*0.74;
      maxW=c.w-2*q-(wRew?(wRew+q):0)-(two?0:(wCnt+q));
      ctx.font=nameFont; ctx.fillStyle=row.done?UIC.ok:UIC.tx_2; ctx.textAlign='left'; ctx.fillText(mapFit(row.name,maxW),c.x+q,mid);
      if(txt){ ctx.font=rewFont; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(txt,c.x+c.w-q,mid); ctx.textAlign='left'; }
      if(two){
        barW=c.w-2*q-wCnt-Math.round(12*u);
        ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(c.x+q,mid2-bh/2,barW,bh);
        if(fr>0){ ctx.fillStyle=fcol; ctx.fillRect(c.x+q,mid2-bh/2,barW*fr,bh); }
        ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q,mid2); ctx.textAlign='left';
      } else {
        ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q-(wRew?(wRew+q):0),mid); ctx.textAlign='left';
        barW=c.w-2*q; ctx.fillStyle=UIC.ui_line_hi; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW,bh);
        if(fr>0){ ctx.fillStyle=fcol; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW*fr,bh); }
      }
      // v28.xx (cw-cx-mapspace-o03): one progress track per row supplies rhythm without an extra divider.
    }
  } finally { ctx.restore(); }
}

'@

SubRx @'
var VER='32.29';
'@ @'
var VER='32.30';
'@

$pat = "(?m)^  now:'v32\.29:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.30: Individual cache and strongbox labels have twelve scaled pixels of clearance. Their leaders stay attached to their own icons. Contract tracks align and secondary rows are quieter. Check 32.30 fails on v32.29',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
