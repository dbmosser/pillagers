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

# MAP NOTICES WAIT THEIR TURN (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HUBTOAST_T=null;
'@ @'
// v28.xx (cw-cx-sectorhold-o03): "while the sector map is open, hold them, then show them in order once it closes. do not drop any."
// v28.xx (cw-cx-sectorhold-o03): a presentation queue owned by this raid; no world clock or seeded roll is changed.
function mapPopupState(){ return G.mapPop||(G.mapPop={q:[],wait:0,replay:0,open:false,at:0}); }
function mapPopupSync(){
  if(!G||G.sim||G.over||state!=='raid') return;
  var S=mapPopupState(), el=document.getElementById('hubtoast'), now=Date.now(), f=G.feed;
  if(G.mapOpen&&!S.open){
    S.open=true; S.at=G.t||0;
    S.wait=Math.max(S.wait,G.msgT||0,(f&&f[1]&&f[1].T)||0,(G.alert&&G.alert.T)||0);
    if(G.fd&&G.fd.lines.length) S.wait=Math.max(S.wait,FEED.hold-((G.fd.t||0)-G.fd.lines[G.fd.lines.length-1].at));
    if(el&&el.classList.contains('on')){
      S.hub={text:el.textContent,life:Math.max(0.1,(HUBTOAST_UNTIL-now)/1000)};
      if(HUBTOAST_T) clearTimeout(HUBTOAST_T); HUBTOAST_T=null; el.classList.remove('on');
    }
  } else if(!G.mapOpen&&S.open){
    S.open=false;
    var gap=Math.max(0,(G.t||0)-S.at);
    // v28.xx (cw-cx-sectorhold-o03): expiry/protection stamps also wait, even when an ordinary M map leaves the world running.
    if(typeof G.msgAt==='number') G.msgAt+=gap;
    (G.feed||[]).forEach(function(r){ if(r&&typeof r.at==='number') r.at+=gap; });
    (G.msgQM||[]).forEach(function(r){ if(r&&typeof r.t==='number') r.t+=gap; });
    (G.alertQ||[]).forEach(function(r){ if(r&&typeof r.t==='number') r.t+=gap; });
    [G.alert,G.loc,G.lore].forEach(function(r){ if(r&&typeof r.at==='number') r.at+=gap; });
    if(S.hub){ S.replay++; try{ hubToast(S.hub.text,S.hub.life); S.wait=Math.max(S.wait,S.hub.life); }finally{ S.replay--; S.hub=null; } }
  }
}
function mapPopupHold(kind,args){
  if(!G||G.sim||G.over||state!=='raid') return false;
  mapPopupSync();
  var S=mapPopupState(); if(S.replay) return false;
  if(!G.mapOpen&&!S.q.length&&!(S.wait>0)) return false;
  S.q.push({kind:kind,args:Array.prototype.slice.call(args)}); return true;
}
function mapPopupTick(dt){
  var S=mapPopupState(), e, a;
  if(G.mapOpen) return;
  S.wait=Math.max(0,S.wait-dt); if(S.wait>0||!S.q.length) return;
  e=S.q.shift(); a=e.args; S.replay++;
  try{
    if(e.kind==='hub'){ hubToast.apply(null,a); S.wait=(a[1]>0)?a[1]:5; }
    else if(e.kind==='feed'){ feedAdd.apply(null,a); S.wait=FEED.hold+FEED.enter; }
    else { say.apply(null,a); S.wait=Math.max(3.2,(G.alert&&G.alert.T)||0); }
  }finally{ S.replay--; }
}
var HUBTOAST_T=null, HUBTOAST_UNTIL=0;
'@

SubRx @'
function hubToast(t){
'@ @'
function hubToast(t,life){
  if(mapPopupHold('hub',arguments)) return;
  HUBTOAST_UNTIL=Date.now()+1000*((life>0)?life:5);
'@

SubRx @'
  },5000);
}
// v13.33:
'@ @'
  },1000*((life>0)?life:5));
}
// v13.33:
'@

SubRx @'
function say(m,kind,o){
'@ @'
function say(m,kind,o){
  if(mapPopupHold('say',arguments)) return;
'@

SubRx @'
function sayWhenFree(m,kind,o){
'@ @'
function sayWhenFree(m,kind,o){
  if(mapPopupHold('say',arguments)) return;
'@

SubRx @'
function feedAdd(segs,fk,o){
'@ @'
function feedAdd(segs,fk,o){
  if(mapPopupHold('feed',arguments)) return null;
'@

SubRx @'
function msgTick(dt){
  if(!G) return;
'@ @'
function msgTick(dt){
  if(!G) return;
  mapPopupSync();
  if(G.mapOpen&&!G.over&&!G.sim) return;
  if(!G.sim&&!G.over) mapPopupTick((dt>0)?Math.min(0.1,dt):0);
'@

SubRx @'
  if(G.mapFirst) mapFirstStep(dt);   // cw-mapfirst: the opening map, its press and its wait for the other windows (the clock below stays still while it is up)
'@ @'
  mapPopupSync();   // v28.xx (cw-cx-sectorhold-o03): also catch an existing page toast while MAPFIRST holds the simulation.
  if(G.mapFirst) mapFirstStep(dt);   // cw-mapfirst: the opening map still owns the raid-start clock hold.
'@

SubRx @'
  if(G.mapOpen){ drawMapOverlay(); try{ _lanes(); }catch(_ln){} }   // v22.xx (R38): the message band over the map
'@ @'
  if(G.mapOpen){ FEEDBOX.on=0; FEEDBOX.rows=[]; drawMapOverlay(); }   // v28.xx (cw-cx-sectorhold-o03): clear the previous feed layout while its draw pass waits behind the map.
'@

SubRx @'
  body.mapcard #topright{ visibility:hidden; }   /* v31.xx (cw-mapstyle): the sector map card has its own header; the corner readout is hidden under it */
'@ @'
  body.mapcard #topright, body.mapcard #hubtoast{ visibility:hidden; }   /* v28.xx (cw-cx-sectorhold-o03): page toasts wait with the canvas notices. */
'@

SubRx @'
function mapSeatColor(s){
  if(typeof s!=='number'||!(s>=0)) return UIC.acc;
  return [UIC.acc,UIC.ally,SEATCOL[2],SEATCOL[3]][s&3];
}
'@ @'
function mapSeatColor(s){
  // v28.xx (cw-cx-sectorhold-o03), his 3.13 a: "player 1 amber, player 2 cyan, everywhere"; solo is player 1.
  return SEATCOL[(typeof s==='number'&&s>=0)?(s&3):0];
}
'@

SubRx @'
var MAPICONS=[], MAPBOX=null, _mapHalo=0;
'@ @'
var MAPICONS=[], MAPBOX=null, _mapHalo=0, MAPTAG=null;   // v28.xx (cw-cx-sectorhold-o03): exact icon anchor for each cache/strongbox label.
'@

SubRx @'
function mapLabel(txt,x,y,col,font){
'@ @'
function mapLabel(txt,x,y,col,font,markY){
  // v28.xx (cw-cx-sectorhold-o03): each cache keeps its label and exact icon anchor; the final placer owns spacing, not the old duplicate suppressor.
  if(typeof markY==='number'){
    var saveTag=MAPTAG; MAPTAG={x:x,y:markY,m:ctx.getTransform()};
    ctx.font=font||hudFS(TYPE.label); ctx.textAlign='center'; ctx.fillStyle=mapLabelCol(col);
    try{ ctx.fillText(txt,x,y); }finally{ MAPTAG=saveTag; ctx.textAlign='left'; } return;
  }
'@

SubRx @'
    mapLabel(CQ.opened?'LOOTED':'CACHE',qx,qy-20*_MZ,UIC.tx_1);   // v19.65, seen on the 4K map (2026-10-08): clear of its own ring (up to 12 above the centre) at the grown text size
'@ @'
    mapLabel(CQ.opened?'LOOTED':'CACHE',qx,qy-20*_MZ,UIC.tx_1,null,qy);   // v28.xx (cw-cx-sectorhold-o03): one label per cache, including the two inside a locked room.
'@

SubRx @'
    ctx.fillText('STRONGBOX',sbx,sby-15*_MZ); ctx.textAlign='left';
'@ @'
    mapLabel('STRONGBOX',sbx,sby-20*_MZ,UIC.tx_1,ctx.font,sby);   // v28.xx (cw-cx-sectorhold-o03): the strongbox has its own anchored label too.
'@

SubRx @'
    Q.push({s:s,x:x,y:y,font:ctx.font,fs:ctx.fillStyle,ta:ctx.textAlign,tb:ctx.textBaseline,ga:ctx.globalAlpha,m:ctx.getTransform(),fp:fp,h:_mapHalo,w:CanvasRenderingContext2D.prototype.measureText.call(ctx,td).width});
'@ @'
    Q.push({mark:MAPTAG,s:s,x:x,y:y,font:ctx.font,fs:ctx.fillStyle,ta:ctx.textAlign,tb:ctx.textBaseline,ga:ctx.globalAlpha,m:ctx.getTransform(),fp:fp,h:_mapHalo,w:CanvasRenderingContext2D.prototype.measureText.call(ctx,td).width});
'@

SubRx @'
    if(cur&&L.p!==9&&cur.p!==9&&L.ta===cur.last.ta&&Math.abs(L.x-cur.last.x)<1&&L.y>cur.last.y&&L.y-cur.last.y<2.4*Math.max(L.fp,cur.last.fp)){ cur.items.push(L); cur.last=L; cur.p=Math.max(cur.p,L.p); continue; }
'@ @'
    if(cur&&!L.mark&&!cur.last.mark&&L.p!==9&&cur.p!==9&&L.ta===cur.last.ta&&Math.abs(L.x-cur.last.x)<1&&L.y>cur.last.y&&L.y-cur.last.y<2.4*Math.max(L.fp,cur.last.fp)){ cur.items.push(L); cur.last=L; cur.p=Math.max(cur.p,L.p); continue; }
'@

SubRx @'
    tries=[[0,0],[0,-(gh+3)],[-(gw*0.6),0],[gw*0.6,0],[0,-2*(gh+3)],[0,gh+3],[0,2*(gh+3)],[0,-3*(gh+3)],[0,3*(gh+3)]];
'@ @'
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
'@

SubRx @'
    if(!ok&&g.p>=3){ g.dx=0; g.dy=0; placed.push(g.r); out.push(g); }
'@ @'
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
'@

SubRx @'
    ctx.font=L.font; ctx.fillStyle=L.fs; ctx.textAlign=L.ta; ctx.textBaseline=L.tb; ctx.globalAlpha=L.ga;
'@ @'
    ctx.font=L.font; ctx.fillStyle=L.fs; ctx.textAlign=L.ta; ctx.textBaseline=L.tb; ctx.globalAlpha=L.ga;
    // v28.xx (cw-cx-sectorhold-o03): a displaced loot label stays visibly attached to its own icon, never a neighbouring cache.
    if(L.mark&&(Math.abs(g.dx||0)>1||Math.abs(g.dy||0)>1)){
      var B=mapLabelRect(L,g.dx,g.dy), M=L.mark, ax=M.x*M.m.a+M.m.e, ay=M.y*M.m.d+M.m.f,
          ex=clamp(ax,B.l,B.r), ey=clamp(ay,B.t,B.b), vx=ex-ax, vy=ey-ay, len=Math.sqrt(vx*vx+vy*vy), cut=14*_mz;
      if(len>cut+2){ ctx.save(); ctx.setTransform(1,0,0,1,0,0); ctx.strokeStyle=UIC.tx_2; ctx.lineWidth=Math.max(1,_mz); ctx.beginPath(); ctx.moveTo(ax+vx*cut/len,ay+vy*cut/len); ctx.lineTo(ex,ey); ctx.stroke(); ctx.restore(); }
    }
'@

SubRx @'
var VER='32.26';
'@ @'
var VER='32.27';
'@

$pat = "(?m)^  now:'v32\.26:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v32.27: Notices keep their time and wait in order until the map closes. Each cache and strongbox has a separate label attached to its icon. Map seats match their rings. Check 32.27 fails on v32.26',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
