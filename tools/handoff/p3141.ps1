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

# THE SECTOR MAP IS A CARD WITH EVERY CONTRACT ON IT (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mapProj(){
  var pad=70,sc=Math.min((W-pad*2)/WORLD_W,(H-pad*2)/WORLD_H);
  return {sc:sc,ox:(W-WORLD_W*sc)/2,oy:(H-WORLD_H*sc)/2};
}

'@ @'
// v31.xx (cw-mapstyle), the critic scored the opening map 2 of 5 for the map art: a navy void with a thick periwinkle frame and walls, no card, header row or
// X, labels printed over their own icons, zone names dark grey on dark grey, two small grey explaining lines. His Q6 (4 everywhere), Q7 (the style guide
// overrules his older layout and size orders) and Q43 (a window is one centred card with an X taking nearly the whole screen). The map is now inside one
// card, 90 percent of the screen (5 percent margin), a header row (the sector name, the X), the map, a footer row (the key hints and the SURVEYED figure,
// and on the opening map the start button), and, when the player has contracts (never in the demo, which hides them as the Run info box does), a dark
// column at the right that lists every one of them (his Q1). The header and the footer are the same height, so the map stays centred up and down on the
// screen as it always was. mapProj hands back the map rectangle (sc, ox, oy) as before, plus the whole card (.card).
var MAPHINT='';   // what the old hint line says (a click sets a waypoint ...); drawMapOverlayRaw fills it, the footer draws it
var MAPCON_RULE={clean:'no heals',quiet:'no kills',swift:'out in 3 min',weak:'weak points',steady:'never downed',far:'cover distance',elite:'elite kill'};
// The colours the marker tags were called with before the style guide (amber, mint, purple, salmon, teal) become the guide's tokens at the one door every tag goes through.
function mapLabelCol(c){
  var s=String(c).toLowerCase();
  if(s==='#ffc04a'||s==='#e6b4ff') return UIC.tx_1;
  if(s==='#7fc4a0') return UIC.ok;
  if(s==='#ff8a76') return UIC.danger;
  if(s==='#4de3d0') return UIC.extract;
  return c;
}
function mapSeatColor(s){
  if(typeof s!=='number'||!(s>=0)) return UIC.acc;
  return [UIC.acc,UIC.ally,SEATCOL[2],SEATCOL[3]][s&3];
}
function mapSeatBadge(x,y,z,col,seat){
  if(typeof seat!=='number'||!(seat>=0)) return;
  var r=9*z, bx=x+17*z, by=y-17*z, of=ctx.font, oa=ctx.textAlign, ob=ctx.textBaseline;
  ctx.fillStyle=INK; ctx.beginPath(); ctx.arc(bx,by,r+1.5*z,0,6.2832); ctx.fill();
  ctx.fillStyle=col; ctx.beginPath(); ctx.arc(bx,by,r,0,6.2832); ctx.fill();
  ctx.fillStyle=UIC.acc_ink; ctx.font=FSz('700 8px '+HUDF,z); ctx.textAlign='center'; ctx.textBaseline='middle'; ctx.fillText(String((seat&3)+1),bx,by+0.5*z);
  ctx.font=of; ctx.textAlign=oa; ctx.textBaseline=ob;
}
function mapGlyph(name,cx,cy,size,col,lw){
  var p=(typeof uiIconPath==='function')?uiIconPath(name):null, s=size/24;
  if(!p||!(s>0)) return;
  ctx.save();
  try{ ctx.translate(cx-12*s,cy-12*s); ctx.scale(s,s); ctx.strokeStyle=col; ctx.lineWidth=lw||2; ctx.lineCap='square'; ctx.lineJoin='miter'; ctx.stroke(p); }catch(_mg){}
  ctx.restore();
}
function mapRR(x,y,w,h,r){ ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(x,y,w,h,Math.max(0,Math.min(r,w/2,h/2))); else ctx.rect(x,y,w,h); }
function mapFit(s,maxW){
  var t=String(s);
  if(!(maxW>0)||hudRawW(t)<=maxW) return t;
  while(t.length>1&&hudRawW(t+'\u2026')>maxW) t=t.slice(0,-1);
  return t+'\u2026';
}
// What the map lists: every contract on the profile, nothing in the demo (it hides them as the Run info box does) and nothing in a bot sim.
function mapContractOk(c){ return !!c&&typeof c==='object'&&c.n!==undefined&&c.type!==undefined; }
function mapContractCount(){
  var n=0, i;
  try{
    if(typeof P!=='object'||!P||!Array.isArray(P.contracts)||typeof G!=='object'||!G||G.arcade||G.sim) return 0;
    for(i=0;i<P.contracts.length;i++) if(mapContractOk(P.contracts[i])) n++;
  }catch(_mc){ return 0; }
  return n;
}
function mapContractShort(c){
  var t=c.type, n=c.n|0, nm;
  try{
    if(t==='kill') return 'destroy '+((n>1)?(UNITPLURAL[c.tgt]||c.tgt):(UNITNAME[c.tgt]||c.tgt));
    if(t==='open') return 'search '+((c.ct==='safe')?'secure cases':(c.ct+'s'));
    if(t==='district') return 'search '+districtPlaceName(c.d);
    if(t==='exItem'){ nm=(typeof ITEMS==='object'&&ITEMS[c.item])?ITEMS[c.item].name:'salvage'; return 'carry out '+nm; }
    if(t==='haul') return 'haul over $'+(c.v|0).toLocaleString();
    if(t==='conduct') return MAPCON_RULE[c.ck]||'rule';
  }catch(_cs){}
  return String(c.desc||'contract');
}
// The state of a rule contract (extract clean, no kills, never downed ...), from the same record the run card reads: holding, broken, open or ready.
function mapContractRule(c,T){
  var ck=c.ck, K, kt=0, k;
  try{
    if(ck==='clean') return ((T.heals|0)>0)?'broken':'holding';
    if(ck==='quiet'){ K=T.kills||{}; for(k in K) kt+=K[k]||0; return (kt>0)?'broken':'holding'; }
    if(ck==='swift') return (runElapsed()>180)?'broken':'holding';
    if(ck==='steady') return ((T.downs|0)>0)?'broken':'holding';
    if(ck==='elite') return ((T.eliteKills|0)>0)?'ready':'open';
    if(ck==='far') return ((T.distance||0)>=14000)?'ready':'open';
  }catch(_cr){}
  return 'open';
}
// One row per contract: short name, progress p of n, reward in $, done, or the rule state. Nearest to done first, finished ones last.
function mapContractRows(){
  var rows=[], i, c, n, p, T=(typeof G==='object'&&G&&G.tel)?G.tel:{}, row;
  try{
    if(!mapContractCount()) return rows;
    for(i=0;i<P.contracts.length;i++){
      c=P.contracts[i]; if(!mapContractOk(c)) continue;
      n=Math.max(1,c.n|0); p=Math.max(0,Math.min(n,c.prog|0));
      row={i:i,name:mapContractShort(c),n:n,p:p,done:(p>=n),pay:Math.max(0,c.reward|0),rule:''};
      if(!row.done&&c.type==='conduct'){
        if(c.ck==='weak'){ row.p=Math.max(0,Math.min(n,T.weakHits|0)); }
        else row.rule=mapContractRule(c,T);
      }
      row.left=row.n-row.p;
      rows.push(row);
    }
  }catch(_mr){}
  rows.sort(function(a,b){ return ((a.done?1:0)-(b.done?1:0))||(a.left-b.left)||(a.i-b.i); });
  return rows;
}
// The card: 5 percent margin, a header row and a footer row of one height (so the map keeps its place on the screen), the map in the body, the contracts
// column to its right when there are contracts. u is the screen scale (hudRes) times the text size dial, so the card grows with the type.
function mapCard(){
  var z=(typeof hudRes==='function')?hudRes():1, us=(typeof uiScale==='function')?uiScale():1, u=z*us, mx, my, x, y, w, h, hh, p, fy, ix, iy, iw, ih, sc, mw, mh, oy, gx, cw, col=null,
      gap, cwMin, cwMax, has, xs;
  if(!(W>0&&H>0)) return {x:0,y:0,w:0,h:0,hh:0,fy:0,p:0,z:1,u:1,sc:1,ox:0,oy:0,col:null,has:false,xb:{x:0,y:0,w:0,h:0}};
  mx=Math.round(W*0.05); my=Math.round(H*0.05); x=mx; y=my; w=W-2*mx; h=H-2*my;
  hh=Math.round(64*u); p=Math.round(24*u); xs=Math.round(48*u); gap=p; cwMin=Math.round(340*u); cwMax=Math.round(540*u);
  has=mapContractCount()>0;
  fy=y+h-hh; ix=x+p; iy=y+hh+p; iw=w-2*p; ih=h-2*hh-2*p;
  sc=Math.min(iw/WORLD_W,ih/WORLD_H);
  if(has) sc=Math.min(ih/WORLD_H,(iw-gap-cwMin)/WORLD_W);
  if(!(sc>0)) sc=0.001;
  mw=WORLD_W*sc; mh=WORLD_H*sc; oy=iy+(ih-mh)/2;
  if(has){ cw=Math.min(cwMax,iw-gap-mw); gx=ix+(iw-(mw+gap+cw))/2; col={x:gx+mw+gap,y:oy,w:cw,h:mh}; }
  else gx=ix+(iw-mw)/2;
  return {x:x,y:y,w:w,h:h,hh:hh,fy:fy,p:p,z:z,u:u,sc:sc,ox:gx,oy:oy,col:col,has:has,xb:{x:x+w-p-xs,y:y+(hh-xs)/2,w:xs,h:xs}};
}
// The card under the map: panel fill, a 1px border, and a 1px line under the header and over the footer.
function mapCardBack(cd){
  var lw=Math.max(1,Math.round(cd.z)), r=Math.max(2,Math.round(4*cd.z));
  ctx.save();
  try{
    mapRR(cd.x+lw/2,cd.y+lw/2,cd.w-lw,cd.h-lw,r); ctx.fillStyle=UIC.ui_panel; ctx.fill();
    ctx.lineWidth=lw; ctx.strokeStyle=UIC.ui_line_hi; ctx.stroke();
    ctx.strokeStyle=UIC.ui_line; ctx.beginPath();
    ctx.moveTo(cd.x+lw,cd.y+cd.hh); ctx.lineTo(cd.x+cd.w-lw,cd.y+cd.hh);
    ctx.moveTo(cd.x+lw,cd.fy); ctx.lineTo(cd.x+cd.w-lw,cd.fy); ctx.stroke();
  } finally { ctx.restore(); }
}
// The contracts column: a dark pane, a title row, then one row per contract: the short name and the reward, and under it a progress bar with 3/5 (done in
// green, a rule contract shows holding or broken). When the rows cannot all have two lines they share the height on one line each with a thin bar.
function mapContractsDraw(cd,rows){
  var c=cd.col, z=cd.z, u=cd.u, q=Math.round(16*u), th=Math.round(48*u), r=Math.max(2,Math.round(4*z)), lw=Math.max(1,Math.round(z)), n=rows.length, nd=0, i, row, ry, pitch, two,
      y0, avail, nat=Math.round(68*u), mid, mid2, wRew, wCnt, maxW, barW, bh=Math.max(3,Math.round(6*z)), txt, cnt, cc,
      nameFont=FSz('600 15.4px '+HUDF,z), cntFont=FSz(TYPE.label,z);
  for(i=0;i<n;i++) if(rows[i].done) nd++;
  ctx.save();
  try{
    mapRR(c.x+lw/2,c.y+lw/2,c.w-lw,c.h-lw,r); ctx.fillStyle=UIC.ui_raised; ctx.fill(); ctx.lineWidth=lw; ctx.strokeStyle=UIC.ui_line; ctx.stroke();
    ctx.textBaseline='middle'; ctx.textAlign='left';
    ctx.font=nameFont; ctx.fillStyle=UIC.tx_1; ctx.fillText('contracts',c.x+q,c.y+th/2);
    ctx.font=cntFont; ctx.fillStyle=UIC.tx_2; ctx.textAlign='right'; ctx.fillText(nd+' of '+n+' done',c.x+c.w-q,c.y+th/2); ctx.textAlign='left';
    ctx.strokeStyle=UIC.ui_line; ctx.lineWidth=lw; ctx.beginPath(); ctx.moveTo(c.x+lw,c.y+th); ctx.lineTo(c.x+c.w-lw,c.y+th); ctx.stroke();
    y0=c.y+th; avail=c.h-th-Math.round(8*u); pitch=Math.min(nat,Math.floor(avail/n)); two=(pitch>=Math.round(58*u));
    for(i=0;i<n;i++){
      row=rows[i]; ry=y0+i*pitch;
      cnt=row.done?'done':(row.rule?row.rule:(row.p+'/'+row.n));
      cc=row.done?UIC.ok:((row.rule==='broken')?UIC.danger:((row.rule==='ready')?UIC.ok:UIC.tx_2));
      txt=row.pay?('$'+row.pay.toLocaleString()):'';
      ctx.font=nameFont; wRew=txt?hudRawW(txt):0;
      ctx.font=cntFont; wCnt=hudRawW(cnt);
      mid=two?(ry+pitch*0.32):(ry+pitch*0.40); mid2=ry+pitch*0.72;
      maxW=c.w-2*q-(wRew?(wRew+q):0)-(two?0:(wCnt+q));
      ctx.font=nameFont; ctx.fillStyle=row.done?UIC.tx_2:UIC.tx_1; ctx.textAlign='left'; ctx.fillText(mapFit(row.name,maxW),c.x+q,mid);
      if(txt){ ctx.textAlign='right'; ctx.fillText(txt,c.x+c.w-q,mid); ctx.textAlign='left'; }
      if(two){
        if(row.rule){ ctx.font=cntFont; ctx.fillStyle=cc; ctx.fillText(cnt,c.x+q,mid2); }
        else {
          barW=c.w-2*q-wCnt-Math.round(12*u);
          ctx.fillStyle=UIC.ui_line; ctx.fillRect(c.x+q,mid2-bh/2,barW,bh);
          ctx.fillStyle=row.done?UIC.ok:UIC.acc; ctx.fillRect(c.x+q,mid2-bh/2,barW*(row.p/row.n),bh);
          ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q,mid2); ctx.textAlign='left';
        }
      } else {
        ctx.font=cntFont; ctx.fillStyle=cc; ctx.textAlign='right'; ctx.fillText(cnt,c.x+c.w-q-(wRew?(wRew+q):0),mid); ctx.textAlign='left';
        if(!row.rule){
          barW=c.w-2*q; ctx.fillStyle=UIC.ui_line; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW,bh);
          ctx.fillStyle=row.done?UIC.ok:UIC.acc; ctx.fillRect(c.x+q,ry+pitch-bh-Math.round(2*z),barW*(row.p/row.n),bh);
        }
      }
      if(i<n-1&&two){ ctx.strokeStyle=UIC.ui_line; ctx.lineWidth=lw; ctx.beginPath(); ctx.moveTo(c.x+q,ry+pitch); ctx.lineTo(c.x+c.w-q,ry+pitch); ctx.stroke(); }
    }
  } finally { ctx.restore(); }
}
// The writing and the controls of the card, drawn after the map labels (they are placed by the map, these are not): the header (the sector name, the muted
// words sector map, the weather, the X), the contracts column and the footer (the key hints and the SURVEYED figure).
function mapCardChrome(cd){
  var z=cd.z, u=cd.u, p=cd.p, g=G, hy=cd.y+cd.hh/2, fyc=cd.fy+(cd.y+cd.h-cd.fy)/2, nm, x0, hx, wxs, xb=cd.xb, hov, f=null, hint, x1, r=Math.max(2,Math.round(4*z)),
      lw=Math.max(1,Math.round(z)), rows, ttl;
  ctx.save();
  try{
    ctx.textBaseline='middle'; ctx.textAlign='left'; ctx.globalAlpha=1;
    nm=(g.map&&g.map.name)?String(g.map.name):''; x0=cd.x+p;
    ctx.font=FSz('700 24.6px '+HUDF,z); ctx.fillStyle=UIC.tx_1;
    ttl=nm||'SECTOR MAP'; ctx.fillText(ttl,x0,hy); hx=x0+hudRawW(ttl)+Math.round(16*u);
    if(nm){ ctx.font=FSz('500 15.4px '+HUDF,z); ctx.fillStyle=UIC.tx_2; ctx.fillText('SECTOR MAP',hx,hy); hx+=hudRawW('SECTOR MAP')+Math.round(24*u); }
    if(g.intel){ ctx.font=FSz(TYPE.label,z); ctx.fillStyle=UIC.tx_2; ctx.fillText('elites and keys are live intel',hx,hy); hx+=hudRawW('elites and keys are live intel')+Math.round(24*u); }
    wxs=(isDay()?tod().name:'night')+'  '+g.wx.name+(g.wxNext?('  \u2192 '+g.wxNext.name+'  '+Math.round(g.wxT*100)+'%'):'');
    ctx.font=FSz('600 15.4px '+HUDF,z); ctx.textAlign='right'; ctx.fillStyle=(wx().id==='clear')?UIC.tx_2:UIC.tx_1; ctx.fillText(wxs,xb.x-Math.round(24*u),hy); ctx.textAlign='left';
    hov=(typeof mouse==='object'&&mouse&&mouse.x>=xb.x&&mouse.x<=xb.x+xb.w&&mouse.y>=xb.y&&mouse.y<=xb.y+xb.h);
    mapRR(xb.x+lw/2,xb.y+lw/2,xb.w-lw,xb.h-lw,r); if(hov){ ctx.fillStyle=UIC.ui_hover; ctx.fill(); }
    ctx.lineWidth=lw; ctx.strokeStyle=hov?UIC.tx_2:UIC.ui_line_hi; ctx.stroke();
    mapGlyph('close',xb.x+xb.w/2,xb.y+xb.h/2,xb.w*0.46,UIC.tx_1,2.4);
    rows=cd.col?mapContractRows():[];
    if(rows.length&&cd.col) mapContractsDraw(cd,rows);
    ctx.textBaseline='middle'; ctx.textAlign='left'; ctx.font=FSz(TYPE.label,z); ctx.fillStyle=UIC.tx_2; x1=cd.x+p;
    hint=String(MAPHINT||'');   // the words of the old header line of hints (drawMapOverlayRaw hands them over)
    if(hint){ ctx.fillText(hint,x1,fyc); x1+=hudRawW(hint)+Math.round(32*u); }
    try{ f=fogFrac(); }catch(_ff){ f=null; }
    if(f!==null&&isFinite(f)) ctx.fillText('SURVEYED  '+Math.round(f*100)+'%',x1,fyc);
  } finally { ctx.restore(); }
}
function mapProj(){
  var cd=mapCard();
  return {sc:cd.sc,ox:cd.ox,oy:cd.oy,card:cd};
}
'@

SubRx @'
function mapLabelReset(){ _mapLbl.length=0; }
'@ @'
// v31.xx (cw-mapstyle): MAPICONS are the screen boxes of the marks on the map (a label never sits on one), MAPBOX is the map frame (a moved label stays in it),
// _mapHalo is the width of the dark halo under every label (zone names read on any ground). All three are only set while the map is being drawn.
var MAPICONS=[], MAPBOX=null, _mapHalo=0;
function mapIcon(x,y,r){
  try{ var m=ctx.getTransform(); MAPICONS.push({l:(x-r)*m.a+m.e,t:(y-r)*m.d+m.f,r:(x+r)*m.a+m.e,b:(y+r)*m.d+m.f}); }catch(_mi){}
}
function mapLabelReset(){ _mapLbl.length=0; MAPICONS.length=0; }
'@

SubRx @'
function mapLabel(txt,x,y,col,font){
'@ @'
function mapLabel(txt,x,y,col,font){
  col=mapLabelCol(col);   // v31.xx (cw-mapstyle): the old tag colours are the style guide tokens now
'@

SubRx @'
  function hits(a){ for(var h=0;h<placed.length;h++){ var b=placed[h]; if(a.l<b.r+2&&b.l<a.r+2&&a.t<b.b+1&&b.t<a.b+1) return true; } return false; }
'@ @'
  function hits(a,ic){ for(var h=0;h<placed.length;h++){ var b=placed[h]; if(a.l<b.r+2&&b.l<a.r+2&&a.t<b.b+1&&b.t<a.b+1) return true; }
    if(ic) for(var h2=0;h2<MAPICONS.length;h2++){ var b2=MAPICONS[h2]; if(a.l<b2.r+1&&b2.l<a.r+1&&a.t<b2.b+1&&b2.t<a.b+1) return true; }   // v31.xx (cw-mapstyle): a label never sits on a mark
    return false; }
'@

SubRx @'
  var _bT=0, _bW=(ctx&&ctx.canvas)?ctx.canvas.width:1e9, _bH=(ctx&&ctx.canvas)?ctx.canvas.height:1e9;
'@ @'
  var _bT=0, _bL=0, _bW=(ctx&&ctx.canvas)?ctx.canvas.width:1e9, _bH=(ctx&&ctx.canvas)?ctx.canvas.height:1e9;
  /* v31.xx (cw-mapstyle): a moved label stays inside the map frame, not the whole screen */ if(MAPBOX){ _bT=MAPBOX.t; _bL=MAPBOX.l; _bW=MAPBOX.r; _bH=MAPBOX.b; }
'@

SubRx @'
    for(k=0;k<tries.length&&!ok;k++){ dx=tries[k][0]; dy=tries[k][1]; r={l:g.r.l+dx,t:g.r.t+dy,r:g.r.r+dx,b:g.r.b+dy}; if(r.t<_bT||r.b>_bH||r.l<0||r.r>_bW) continue; if(!hits(r)){ ok=true; g.dx=dx; g.dy=dy; placed.push(r); out.push(g); } }
'@ @'
    for(var _pass=0;_pass<2&&!ok;_pass++) for(k=0;k<tries.length&&!ok;k++){ dx=tries[k][0]; dy=tries[k][1]; r={l:g.r.l+dx,t:g.r.t+dy,r:g.r.r+dx,b:g.r.b+dy}; if(r.t<_bT||r.b>_bH||r.l<_bL||r.r>_bW) continue; if(!hits(r,_pass===0)){ ok=true; g.dx=dx; g.dy=dy; placed.push(r); out.push(g); } }   // v31.xx (cw-mapstyle): first clear of the marks too, then clear of the other labels only
'@

SubRx @'
    (fn||CanvasRenderingContext2D.prototype.fillText).call(ctx,L.s,L.x+(g.dx||0)/(L.m.a||1),L.y+(g.dy||0)/(L.m.d||1));
'@ @'
    if(L.h>0){ try{ ctx.lineJoin='round'; ctx.lineWidth=L.h; ctx.strokeStyle='rgba(11,12,13,.88)'; ctx.strokeText((typeof TX==='function')?TX(String(L.s)):String(L.s),L.x+(g.dx||0)/(L.m.a||1),L.y+(g.dy||0)/(L.m.d||1)); }catch(_hl){} }   // v31.xx (cw-mapstyle): the halo
    (fn||CanvasRenderingContext2D.prototype.fillText).call(ctx,L.s,L.x+(g.dx||0)/(L.m.a||1),L.y+(g.dy||0)/(L.m.d||1));
'@

SubRx @'
m:ctx.getTransform(),fp:fp,w:CanvasRenderingContext2D.prototype.measureText.call(ctx,td).width});
'@ @'
m:ctx.getTransform(),fp:fp,h:_mapHalo,w:CanvasRenderingContext2D.prototype.measureText.call(ctx,td).width});
'@

SubRx @'
    var _ml=MAPLAST; MAPLAST=null;
'@ @'
    var _ml=MAPLAST; MAPLAST=null;
    MAPBOX=null; _mapHalo=0; MAPICONS.length=0;   // v31.xx (cw-mapstyle): the map box, the halo and the mark boxes only live while the map is drawn
'@

SubRx @'
function drawMapOverlayRaw(){
  // v9.14: EVERY STRING ON THIS SCREEN FOLLOWS THE MONITOR. The map itself
  // already does, because mapProj divides by W and H, but the writing on it went
  // through the global FS, which knows about the text size dial and nothing
  // about the screen. Measured before this: the drawn world went from 1161x940
  // to 2495x2020 between 1080p and 4K while every label stayed at 18.7px.
  // Declared here so it shadows the global for this function only. All fifteen
  // font calls below pick it up, and there is one place to change it rather than
  // fifteen. hudRes() is exactly 1 at 1920x1080, so that screen is unchanged.
  var _MZ=hudRes();
  function FS(spec){ return FSz(spec,_MZ); }
  mapLabelReset();
  var p=G.player,i;
  // The sector map was the last full screen surface still wearing the old grey
  // and near-black palette: the district fills already came through because they
  // read DISTRICTS directly, but every piece of the map's own chrome was left
  // behind by the v0.84 recolour, so holding M dropped you out of a navy and
  // amber game into a grey one.
  // v21.04, from the whole-game bug hunt of 2026-10-08 (V-D2), seen on the 4K map screenshot: THE MAP BACKING IS SOLID. At .99 the
  // HUD under the map still ghosted through on a big screen (the controls card, STANDING, HP 100, CONCEALED and the extraction banner
  // all faintly readable down both sides of the map). The backing is the same colour, fully opaque.
  ctx.fillStyle='rgb(9,12,34)'; ctx.fillRect(0,0,W,H);   // v19.03, seen on the map screenshot (2026-10-07): at .94 the message toast under the map ghosted through across THE LONG DOCK; the map now hides what is under it
  var _MP=mapProj(),sc=_MP.sc,ox=_MP.ox,oy=_MP.oy;
  // double frame, matching the windows in the terminal
  // v9.15: the frame follows the screen too. Measured before this: 4 pixels
  // thick outside the map rect at 1080p AND at 4K, on a map that grew 2.15x.
  ctx.strokeStyle='#2f4394'; ctx.lineWidth=3*_MZ;
  ctx.strokeRect(ox-3*_MZ,oy-3*_MZ,WORLD_W*sc+6*_MZ,WORLD_H*sc+6*_MZ);
  ctx.strokeStyle='#7f92d8'; ctx.lineWidth=1.5*_MZ;
  ctx.strokeRect(ox,oy,WORLD_W*sc,WORLD_H*sc);
  ctx.lineWidth=1*_MZ;
  ctx.font=FS(TYPE.label); ctx.fillStyle='#ffc04a';
  // v21.38, from the 4K visual pass of 2026-10-09 (W-D3): THE MAP HEADER STANDS CLEAR OF THE FRAME. The header line (SECTOR MAP, the
  // waypoint hint and the weather) sat 10 pixels above the map at every screen size, but since v9.15 the frame grows with the screen
  // (3*_MZ out from the map, 3*_MZ thick), so at 4K the frame reached 9 pixels up and the words stood on it. The gap grows by the same
  // _MZ now. At 1080p _MZ is 1 and nothing moves.
  var _hdY=oy-10*_MZ;
  ctx.fillText('SECTOR MAP',ox,_hdY);
  // fixed offsets collided with the scaled font; walk a cursor instead
  var _hx=ox+ctx.measureText('SECTOR MAP').width+28;

  ctx.font=FS(TYPE.micro); ctx.fillStyle='#9aa8d0';
  // v7.55, his note: the no-intel shrug told the player what they already know.
  if(G.intel){
    var _hsub='elites and keys are live intel';
    ctx.fillText(_hsub,_hx,_hdY);
    _hx+=ctx.measureText(_hsub).width+28;
  }
  ctx.fillStyle='#ffc04a';
'@ @'
function drawMapOverlayRaw(){
  // v9.14: EVERY STRING ON THIS SCREEN FOLLOWS THE MONITOR. The map itself
  // already does, because mapProj divides by W and H, but the writing on it went
  // through the global FS, which knows about the text size dial and nothing
  // about the screen. Measured before this: the drawn world went from 1161x940
  // to 2495x2020 between 1080p and 4K while every label stayed at 18.7px.
  // Declared here so it shadows the global for this function only. All fifteen
  // font calls below pick it up, and there is one place to change it rather than
  // fifteen. hudRes() is exactly 1 at 1920x1080, so that screen is unchanged.
  var _MZ=hudRes();
  function FS(spec){ return FSz((spec===TYPE.micro)?TYPE.label:spec,_MZ); }   // v31.xx (cw-mapstyle): nothing on the map is smaller than the label size (the style guide's 16 px floor)
  mapLabelReset();
  var p=G.player,i;
  // The sector map was the last full screen surface still wearing the old grey
  // and near-black palette: the district fills already came through because they
  // read DISTRICTS directly, but every piece of the map's own chrome was left
  // behind by the v0.84 recolour, so holding M dropped you out of a navy and
  // amber game into a grey one.
  // v21.04, from the whole-game bug hunt of 2026-10-08 (V-D2), seen on the 4K map screenshot: THE MAP BACKING IS SOLID. At .99 the
  // HUD under the map still ghosted through on a big screen (the controls card, STANDING, HP 100, CONCEALED and the extraction banner
  // all faintly readable down both sides of the map). The backing is the same colour, fully opaque.
  // v31.xx (cw-mapstyle): the screen behind the card is the void colour, still solid (v21.04: nothing of the HUD may ghost through the map); the card, its
  // header row (the sector name and the X), the contracts column and the footer are drawn by mapCardBack and mapCardChrome (the writing after the labels).
  ctx.fillStyle=UIC.ui_void; ctx.fillRect(0,0,W,H);
  var _MP=mapProj(),sc=_MP.sc,ox=_MP.ox,oy=_MP.oy,_CD=_MP.card;
  mapCardBack(_CD);
  ctx.fillStyle=UIC.ui_bg; ctx.fillRect(ox,oy,WORLD_W*sc,WORLD_H*sc);
  var _flw=Math.max(1,Math.round(_MZ));
  ctx.strokeStyle=UIC.ui_line_hi; ctx.lineWidth=_flw; ctx.strokeRect(ox-_flw/2,oy-_flw/2,WORLD_W*sc+_flw,WORLD_H*sc+_flw);
  MAPBOX={l:ox,t:oy,r:ox+WORLD_W*sc,b:oy+WORLD_H*sc}; _mapHalo=5*_MZ;
  // The old header line of hints (kept as it was, his words) now says its words to the footer: it draws into a stub that hands the text to MAPHINT.
  var _hx=0,_hdY=0;
  (function(ctx){
'@

SubRx @'
  // conditions belong on the map, since they change how far you can see
  ctx.textAlign='right';
  ctx.fillStyle=wx().id==='clear'?'#9aa8d0':'#4de3d0';
  // v15.87, sector audit finding: AT NIGHT THE SECTOR MAP HEADER NAMES A NIGHT HOUR. buildRaid rolls G.tod with pickTod on
  // every raid, night included, so the seeded stream stays the same, and every use of that hour is gated on isDay() (the lamp
  // level, the tint, the dim, lampBase), so at night it does nothing; but this header printed it with no gate, and three rolls
  // in five put noon, 8am or 6pm over a raid that went up in the dark, the same contradiction as his v3.59 note that golden
  // hour should not happen at night. At night the header now says night beside the weather; in daylight it names the rolled
  // hour as before. The CONDITIONS row in drawHUD is gated the same way. No number, no seeded draw and no existing sentence
  // moved.
  // v15.99, weather audit finding: THE SECTOR MAP NAMES THE WEATHER IT IS LEAVING. wx() is the live blend while a turn runs,
  // and wxMix hands the blend the destination name once the turn is half way (t>=0.5), which is right for every reader that
  // wants the nearer state. This header wants the two ends of the turn, and from 7 seconds after The weather is turning is
  // heard it named the coming weather on both sides of the arrow (Storming, arrow, Storming 71%), while the CONDITIONS row,
  // which reads G.wx, still said Rainy. The left of the arrow is G.wx, the weather the turn is leaving, which buildRaid always
  // sets. The colour above and every other reader of wx() are unchanged. No number and no seeded draw moved.
  // v19.32, seen on the 4K map screenshot (2026-10-08): this line ends at the map's right edge, which on a big screen is under the credits
  // and XP readout in the top right corner (8am Clear ran into 900 CREDITS). When that readout covers the line, it ends just left of it.
  var _wxR=ox+WORLD_W*sc;
  try{
    var _trE=document.getElementById('topright'), _trR=(_trE&&!TRG.hid)?_trE.getBoundingClientRect():null, _cvR=ctx.canvas.getBoundingClientRect(), _wm=ctx.getTransform(), _wk=(_cvR.width>0)?ctx.canvas.width/_cvR.width:1;
    if(_trR&&_trR.width>0&&_wm.a){
      var _wfp=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11;
      var _trL=((_trR.left-_cvR.left)*_wk-_wm.e)/_wm.a, _trB=((_trR.bottom-_cvR.top)*_wk-_wm.f)/(_wm.d||1);
      // v19.33, seen on the 4K map screenshot after v19.32: 14 pixels read as touching beside the big 900 at 4K; the gap is a word wide now
      if(_trB>_hdY-_wfp&&_trL<_wxR+_wfp*1.6) _wxR=Math.min(_wxR,_trL-Math.max(14,_wfp*1.6));
    }
    // v30.xx (cw-trcol): and clear of the HUD column in the corner (the wallet rows and the minimap's place), which is drawn on the canvas in a raid and has no page box to read
    if(TRG.n&&EDGEBOX.trcol&&EDGEBOX.trcol.w>0&&_wm.a){
      var _tfp=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11, _tcL=(EDGEBOX.trcol.x*_wk-_wm.e)/_wm.a, _tcB=((EDGEBOX.trcol.y+EDGEBOX.trcol.h)*_wk-_wm.f)/(_wm.d||1);
      if(_tcB>_hdY-_tfp&&_tcL<_wxR+_tfp*1.6) _wxR=Math.min(_wxR,_tcL-Math.max(14,_tfp*1.6));
    }
  }catch(_wx){}
  ctx.fillText((isDay()?tod().name:'night')+'  '+G.wx.name+
    (G.wxNext?('  \u2192 '+G.wxNext.name+'  '+Math.round(G.wxT*100)+'%'):''),
    _wxR,_hdY);
  ctx.textAlign='left';
  for(i=0;i<G.map.buildings.length;i++){
    var b=G.map.buildings[i];
    var _bx=ox+b.x*sc, _by=oy+b.y*sc, _bw=b.w*sc, _bh=b.h*sc;
    // v10.83: a building that has fallen is not drawn like one that is standing.
    ctx.fillStyle=hexA(DISTRICTS[b.d].wallTop,b.ruined?.06:.15);
    ctx.fillRect(_bx,_by,_bw,_bh);
    if(b.ruined){
      // HATCH. Diagonals at a fixed screen spacing, so the mark is the same
      // weight on a small building and a large one and at any monitor size.
      ctx.save();
      ctx.beginPath(); ctx.rect(_bx,_by,_bw,_bh); ctx.clip();
      ctx.strokeStyle='rgba(232,176,96,.34)'; ctx.lineWidth=1;
      ctx.beginPath();
      for(var _hx=-_bh;_hx<_bw;_hx+=7){
        ctx.moveTo(_bx+_hx,_by+_bh); ctx.lineTo(_bx+_hx+_bh,_by);
      }
      ctx.stroke();
      ctx.restore();
      // BROKEN OUTLINE. A continuous box says the walls are there, which is the
      // one thing this building no longer has.
      ctx.strokeStyle='rgba(232,176,96,.55)'; ctx.lineWidth=1;
      var _dash=6, _gap=5, _t;
      ctx.beginPath();
      for(_t=0;_t<_bw;_t+=_dash+_gap){
        var _l=Math.min(_dash,_bw-_t);
        ctx.moveTo(_bx+_t,_by);       ctx.lineTo(_bx+_t+_l,_by);
        ctx.moveTo(_bx+_t,_by+_bh);   ctx.lineTo(_bx+_t+_l,_by+_bh);
      }
      for(_t=0;_t<_bh;_t+=_dash+_gap){
        var _m=Math.min(_dash,_bh-_t);
        ctx.moveTo(_bx,_by+_t);       ctx.lineTo(_bx,_by+_t+_m);
        ctx.moveTo(_bx+_bw,_by+_t);   ctx.lineTo(_bx+_bw,_by+_t+_m);
      }
      ctx.stroke();
    }
  }
  for(i=0;i<(G.map.water||[]).length;i++){
    var wq3=G.map.water[i];
    ctx.fillStyle='rgba(92,168,196,.50)';
    ctx.fillRect(ox+wq3.x*sc,oy+wq3.y*sc,wq3.w*sc,wq3.h*sc);
  }
  ctx.fillStyle='#5f74b8';
  for(i=0;i<G.map.walls.length;i++){
    var wl=G.map.walls[i];
    ctx.fillRect(ox+wl.x*sc,oy+wl.y*sc,Math.max(1,wl.w*sc),Math.max(1,wl.h*sc));
  }
  // Name the zones on the map for the same reason the landmarks are named: the
  // colours already separate on screen, but a colour you cannot name is not a
  // place you can plan around or tell someone to meet you in. Drawn under the
  // landmark labels so a landmark always wins the foreground.
  var zl=G.map.zones||[];
  ctx.textAlign='center';
  for(i=0;i<zl.length;i++){
    var Z2=zl[i];
    if(!Z2.cells) continue;
    // HIS NOTE, 2026-08-26: "your names of areas on the maps make no sense". A
    // capture of the sector map says it plainly: CONTRACTOR CAMP, TURBINE HALL,
    // SWITCHYARD and THE TAILRACE each appear TWICE, one on top of the other, one
    // faint and large and one small and amber. Zone captions and landmark labels
    // are both drawn at the centre of their own rectangle, and a landmark that
    // fills most of its zone shares that centre, so the same words print over
    // themselves at two sizes. It does not read as two labels, it reads as
    // garbled text, which is exactly "makes no sense".
    // The zone caption is a caption for a REGION, so it sits near the top of that
    // region rather than competing for the middle, the way a printed map letters
    // a district across the top of it.
    var zx=ox+(80+(Z2.mc+0.5)*G.map.cw)*sc;
    var zy=oy+(80+(Z2.mr+0.5)*G.map.ch)*sc-G.map.ch*sc*0.34;
    ctx.font=FS(TYPE.head);
    ctx.fillStyle=hexA(DISTRICTS[Z2.d].wallTop,.28);
    ctx.fillText(Z2.name||DISTRICTS[Z2.d].name,zx,zy);
  }
  ctx.textAlign='left';
  // SPEC 7.6 and 11.1: locked rooms display on the map so the route can be
  // planned, and they show whether you have already opened them.
  // v8.52, audit: THIS LOOP IS GONE. It stroked every locked room and captioned it
  // "LOCKED", and the v3.65 loop further down strokes the identical rectangle in
  // the same colour at the same width and captions it with the room's real NAME
  // plus the same word. Two different strings at the same anchor, so mapLabel's
  // same-text suppressor could not collapse them and its collision walker stacked
  // them instead: measured, five lock captions for two rooms.
  // SPEC 4.5: manholes on the sector map, so the fixed spawn set is learnable.
  for(i=0;i<(G.map.spawns||[]).length;i++){
    var SM=G.map.spawns[i];
    var mx3=ox+SM.x*sc,my3=oy+SM.y*sc;
    ctx.strokeStyle='rgba(180,196,210,.55)'; ctx.lineWidth=1.5*_MZ;
    ctx.beginPath(); ctx.arc(mx3,my3,5*_MZ,0,6.2832); ctx.stroke();
  }
  // Meridian caches are marked, because a guaranteed jackpot you never find is the
  // same as no jackpot. Marked whether or not you have been there, so the route
  // choice is available from the first second of the raid: the near one is on
  // your way out, the far ones are a decision.
  for(i=0;i<G.containers.length;i++){
    var CQ=G.containers[i];
    if(!CQ.cache) continue;
    var qx=ox+CQ.x*sc, qy=oy+CQ.y*sc;
    var qp=.6+.4*Math.sin(G.t*2.6+i);
    ctx.globalAlpha=CQ.opened?.35:1;
    ctx.strokeStyle='#e0a0ff'; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(qx,qy,(9+2*qp)*_MZ,0,6.2832); ctx.stroke();
    ctx.fillStyle='#e6b4ff';
    ctx.beginPath(); ctx.arc(qx,qy,3.5*_MZ,0,6.2832); ctx.fill();
    mapLabel(CQ.opened?'LOOTED':'CACHE',qx,qy-20*_MZ,'#e6b4ff');   // v19.65, seen on the 4K map (2026-10-08): clear of its own ring (up to 12 above the centre) at the grown text size
    ctx.globalAlpha=1;
  }
  // Encampments in red: advertised danger. You are told where the fight is and
  // what it pays, and choosing it is the risk half of risk versus greed.
  for(i=0;i<(G.camps||[]).length;i++){
    var CM=G.camps[i];
    var cqx=ox+CM.x*sc,cqy=oy+CM.y*sc;
    ctx.strokeStyle='#ff5040'; ctx.lineWidth=2*_MZ;
    ctx.beginPath();
    // v21.41, from the 4K visual pass of 2026-10-09 (W-D4): THE MAP MARKERS GROW WITH THE SCREEN. The words on the sector map, the
    // cache rings and his own marker have grown with the screen since v19.63, v19.65 and v10.92, but this diamond, the keyhole, the
    // intel key and elite dots, the seal, the strongbox, a revealed cache, the survivor, the Peddler, the dot in an open ring and the
    // waypoint kept their 1080p size in pixels. At 4K the Peddler was a speck under a big PEDDLER and the encampment a small diamond
    // under a big ENCAMPMENT. They, and the gaps to their names, grow by the map zoom (_MZ) now. At 1080p _MZ is 1 and nothing moves.
    ctx.moveTo(cqx,cqy-9*_MZ); ctx.lineTo(cqx+9*_MZ,cqy); ctx.lineTo(cqx,cqy+9*_MZ); ctx.lineTo(cqx-9*_MZ,cqy); ctx.closePath();
    ctx.stroke();
    mapLabel('ENCAMPMENT',cqx,cqy-14*_MZ,'#ff8a76');
  }
  // LOCKED ROOMS, v3.65. HIS NOTE: "locked rooms should be clearly indicated on
  // the map". Amber outline and a keyhole while the door stands, green and OPEN
  // once it is spent, because a used key is information worth exactly as much
  // as an unspent one.
  var lkm=(G.map.locked||[]);
  for(i=0;i<lkm.length;i++){
    var LKM=lkm[i];
    var lqx=ox+LKM.x*sc,lqy=oy+LKM.y*sc,lqw=LKM.w*sc,lqh=LKM.h*sc;
    ctx.strokeStyle=LKM.open?'rgba(127,196,160,.8)':'#ffc04a'; ctx.lineWidth=2*_MZ;
    ctx.strokeRect(lqx,lqy,lqw,lqh);
    ctx.lineWidth=1;
    var kcx=lqx+lqw/2,kcy=lqy+lqh/2-3*_MZ;   // v21.41 (W-D4): the keyhole at the map zoom
    ctx.fillStyle=LKM.open?'rgba(127,196,160,.9)':'#ffc04a';
    ctx.beginPath(); ctx.arc(kcx,kcy,3.2*_MZ,0,6.2832); ctx.fill();
    ctx.beginPath(); ctx.moveTo(kcx-2.2*_MZ,kcy+7.5*_MZ); ctx.lineTo(kcx+2.2*_MZ,kcy+7.5*_MZ); ctx.lineTo(kcx,kcy+_MZ); ctx.closePath(); ctx.fill();
'@ @'
  })({fillText:function(s){ MAPHINT=String(s); }});
  var _mapChrome=function(){ mapCardChrome(_CD); };
  if(MAPLAST){ MAPLAST.push({fn:_mapChrome,m:ctx.getTransform(),ga:ctx.globalAlpha}); } else _mapChrome();
  ctx.lineWidth=1*_MZ; ctx.textAlign='left'; ctx.textBaseline='alphabetic';
  for(i=0;i<G.map.buildings.length;i++){
    var b=G.map.buildings[i];
    var _bx=ox+b.x*sc, _by=oy+b.y*sc, _bw=b.w*sc, _bh=b.h*sc;
    // v10.83: a building that has fallen is not drawn like one that is standing.
    ctx.fillStyle=b.ruined?'rgba(239,233,220,.025)':'rgba(239,233,220,.055)';   // v31.xx (cw-mapstyle): a neutral lift on the map ground, no district tints
    ctx.fillRect(_bx,_by,_bw,_bh);
    if(b.ruined){
      // HATCH. Diagonals at a fixed screen spacing, so the mark is the same
      // weight on a small building and a large one and at any monitor size.
      ctx.save();
      ctx.beginPath(); ctx.rect(_bx,_by,_bw,_bh); ctx.clip();
      ctx.strokeStyle='rgba(170,164,152,.30)'; ctx.lineWidth=1;
      ctx.beginPath();
      for(var _hx=-_bh;_hx<_bw;_hx+=7){
        ctx.moveTo(_bx+_hx,_by+_bh); ctx.lineTo(_bx+_hx+_bh,_by);
      }
      ctx.stroke();
      ctx.restore();
      // BROKEN OUTLINE. A continuous box says the walls are there, which is the
      // one thing this building no longer has.
      ctx.strokeStyle='rgba(170,164,152,.45)'; ctx.lineWidth=1;
      var _dash=6, _gap=5, _t;
      ctx.beginPath();
      for(_t=0;_t<_bw;_t+=_dash+_gap){
        var _l=Math.min(_dash,_bw-_t);
        ctx.moveTo(_bx+_t,_by);       ctx.lineTo(_bx+_t+_l,_by);
        ctx.moveTo(_bx+_t,_by+_bh);   ctx.lineTo(_bx+_t+_l,_by+_bh);
      }
      for(_t=0;_t<_bh;_t+=_dash+_gap){
        var _m=Math.min(_dash,_bh-_t);
        ctx.moveTo(_bx,_by+_t);       ctx.lineTo(_bx,_by+_t+_m);
        ctx.moveTo(_bx+_bw,_by+_t);   ctx.lineTo(_bx+_bw,_by+_t+_m);
      }
      ctx.stroke();
    }
  }
  for(i=0;i<(G.map.water||[]).length;i++){
    var wq3=G.map.water[i];
    ctx.fillStyle='rgba(63,157,233,.30)';
    ctx.fillRect(ox+wq3.x*sc,oy+wq3.y*sc,wq3.w*sc,wq3.h*sc);
  }
  ctx.fillStyle=UIC.ui_line_hi;   // v31.xx (cw-mapstyle): the walls are a quiet neutral, the marks and the names are what the eye finds
  for(i=0;i<G.map.walls.length;i++){
    var wl=G.map.walls[i];
    ctx.fillRect(ox+wl.x*sc,oy+wl.y*sc,Math.max(1,wl.w*sc),Math.max(1,wl.h*sc));
  }
  // Name the zones on the map for the same reason the landmarks are named: the
  // colours already separate on screen, but a colour you cannot name is not a
  // place you can plan around or tell someone to meet you in. Drawn under the
  // landmark labels so a landmark always wins the foreground.
  var zl=G.map.zones||[];
  ctx.textAlign='center';
  for(i=0;i<zl.length;i++){
    var Z2=zl[i];
    if(!Z2.cells) continue;
    // HIS NOTE, 2026-08-26: "your names of areas on the maps make no sense". A
    // capture of the sector map says it plainly: CONTRACTOR CAMP, TURBINE HALL,
    // SWITCHYARD and THE TAILRACE each appear TWICE, one on top of the other, one
    // faint and large and one small and amber. Zone captions and landmark labels
    // are both drawn at the centre of their own rectangle, and a landmark that
    // fills most of its zone shares that centre, so the same words print over
    // themselves at two sizes. It does not read as two labels, it reads as
    // garbled text, which is exactly "makes no sense".
    // The zone caption is a caption for a REGION, so it sits near the top of that
    // region rather than competing for the middle, the way a printed map letters
    // a district across the top of it.
    var zx=ox+(80+(Z2.mc+0.5)*G.map.cw)*sc;
    var zy=oy+(80+(Z2.mr+0.5)*G.map.ch)*sc-G.map.ch*sc*0.34;
    ctx.font=FS(TYPE.head);
    ctx.fillStyle='rgba(239,233,220,.74)';   // v31.xx (cw-mapstyle): zone names are the style guide's tx-1 at about 70 percent over a dark halo (they were the district tint at 28 percent, dark on dark)
    ctx.fillText(Z2.name||DISTRICTS[Z2.d].name,zx,zy);
  }
  ctx.textAlign='left';
  // SPEC 7.6 and 11.1: locked rooms display on the map so the route can be
  // planned, and they show whether you have already opened them.
  // v8.52, audit: THIS LOOP IS GONE. It stroked every locked room and captioned it
  // "LOCKED", and the v3.65 loop further down strokes the identical rectangle in
  // the same colour at the same width and captions it with the room's real NAME
  // plus the same word. Two different strings at the same anchor, so mapLabel's
  // same-text suppressor could not collapse them and its collision walker stacked
  // them instead: measured, five lock captions for two rooms.
  // SPEC 4.5: manholes on the sector map, so the fixed spawn set is learnable.
  for(i=0;i<(G.map.spawns||[]).length;i++){
    var SM=G.map.spawns[i];
    var mx3=ox+SM.x*sc,my3=oy+SM.y*sc;
    ctx.strokeStyle='rgba(170,164,152,.45)'; ctx.lineWidth=1.5*_MZ;
    ctx.beginPath(); ctx.arc(mx3,my3,5*_MZ,0,6.2832); ctx.stroke();
  }
  // Meridian caches are marked, because a guaranteed jackpot you never find is the
  // same as no jackpot. Marked whether or not you have been there, so the route
  // choice is available from the first second of the raid: the near one is on
  // your way out, the far ones are a decision.
  for(i=0;i<G.containers.length;i++){
    var CQ=G.containers[i];
    if(!CQ.cache) continue;
    var qx=ox+CQ.x*sc, qy=oy+CQ.y*sc;
    var qp=.6+.4*Math.sin(G.t*2.6+i);
    ctx.globalAlpha=CQ.opened?.35:1;
    ctx.strokeStyle=UIC.tx_1; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(qx,qy,(9+2*qp)*_MZ,0,6.2832); ctx.stroke();
    ctx.fillStyle=UIC.tx_1;
    ctx.beginPath(); ctx.arc(qx,qy,3.5*_MZ,0,6.2832); ctx.fill();
    mapIcon(qx,qy,13*_MZ);
    mapLabel(CQ.opened?'LOOTED':'CACHE',qx,qy-20*_MZ,UIC.tx_1);   // v19.65, seen on the 4K map (2026-10-08): clear of its own ring (up to 12 above the centre) at the grown text size
    ctx.globalAlpha=1;
  }
  // Encampments in red: advertised danger. You are told where the fight is and
  // what it pays, and choosing it is the risk half of risk versus greed.
  for(i=0;i<(G.camps||[]).length;i++){
    var CM=G.camps[i];
    var cqx=ox+CM.x*sc,cqy=oy+CM.y*sc;
    ctx.strokeStyle=UIC.danger; ctx.lineWidth=2*_MZ;
    ctx.beginPath();
    // v21.41, from the 4K visual pass of 2026-10-09 (W-D4): THE MAP MARKERS GROW WITH THE SCREEN. The words on the sector map, the
    // cache rings and his own marker have grown with the screen since v19.63, v19.65 and v10.92, but this diamond, the keyhole, the
    // intel key and elite dots, the seal, the strongbox, a revealed cache, the survivor, the Peddler, the dot in an open ring and the
    // waypoint kept their 1080p size in pixels. At 4K the Peddler was a speck under a big PEDDLER and the encampment a small diamond
    // under a big ENCAMPMENT. They, and the gaps to their names, grow by the map zoom (_MZ) now. At 1080p _MZ is 1 and nothing moves.
    ctx.moveTo(cqx,cqy-9*_MZ); ctx.lineTo(cqx+9*_MZ,cqy); ctx.lineTo(cqx,cqy+9*_MZ); ctx.lineTo(cqx-9*_MZ,cqy); ctx.closePath();
    ctx.stroke();
    mapIcon(cqx,cqy,11*_MZ);
    mapLabel('ENCAMPMENT',cqx,cqy-14*_MZ,'#ff8a76');
  }
  // LOCKED ROOMS, v3.65. HIS NOTE: "locked rooms should be clearly indicated on
  // the map". Amber outline and a keyhole while the door stands, green and OPEN
  // once it is spent, because a used key is information worth exactly as much
  // as an unspent one.
  var lkm=(G.map.locked||[]);
  for(i=0;i<lkm.length;i++){
    var LKM=lkm[i];
    var lqx=ox+LKM.x*sc,lqy=oy+LKM.y*sc,lqw=LKM.w*sc,lqh=LKM.h*sc;
    ctx.strokeStyle=LKM.open?'rgba(118,185,124,.85)':'rgba(239,233,220,.75)'; ctx.lineWidth=2*_MZ;
    ctx.strokeRect(lqx,lqy,lqw,lqh);
    ctx.lineWidth=1;
    var kcx=lqx+lqw/2,kcy=lqy+lqh/2-3*_MZ;   // v21.41 (W-D4): the keyhole at the map zoom
    ctx.fillStyle=LKM.open?'rgba(118,185,124,.95)':'rgba(239,233,220,.85)';
    ctx.beginPath(); ctx.arc(kcx,kcy,3.2*_MZ,0,6.2832); ctx.fill();
    ctx.beginPath(); ctx.moveTo(kcx-2.2*_MZ,kcy+7.5*_MZ); ctx.lineTo(kcx+2.2*_MZ,kcy+7.5*_MZ); ctx.lineTo(kcx,kcy+_MZ); ctx.closePath(); ctx.fill();
'@

SubRx @'
  }
  // INTEL, v3.81: a burned Data Core lights the map for one raid. Gold key
  // marks on the containers that hold the locked-room keys, gone once each is
  // opened, and live purple dots on every elite still standing. Map only: the
  // world itself shows nothing, because intel is knowing, not seeing.
  if(G.intel){
    for(i=0;i<(G.intelKeys||[]).length;i++){
      var IKC=G.intelKeys[i];
      // v15.55, keys audit finding 3: THE INTEL KEY MARK LEAVES A CONTAINER ONCE ITS KEY IS TAKEN OUT. The mark asked only
      // whether the box was opened, and opened turns true only when the whole search bar fills. The staged pulls hand loot out
      // one item at a time, worst first, and a 600 to 750 key ranks below a Titanium Cell, a better gun or a Black Box, so a safe or
      // locker searched part way gave up its key first and kept its gold KEY for the rest of the raid, with the key already in
      // his backpack and no key left in the box, even after the key was spent at the door. With several locked rooms that sent
      // him back across the map for a second key that was not there: the same wrong mark v15.17 took off restocked boxes,
      // reached by an ordinary search broken off early. A box now keeps its mark only while a key_ item is still in its loot,
      // the same test startRaid used to list it, so a box that held two keys keeps it until both are out. Crates never showed
      // this (their key is always their last item). No player text, no number and no seeded draw moved.
      if(IKC.opened||!(IKC.loot||[]).some(function(_k){ return String(_k).indexOf('key_')===0; })) continue;
      var ikx=ox+IKC.x*sc,iky=oy+IKC.y*sc;
      ctx.fillStyle='#ffc04a';
      ctx.beginPath(); ctx.arc(ikx,iky-3*_MZ,2.6*_MZ,0,6.2832); ctx.fill();   // v21.41 (W-D4): the intel key at the map zoom
      ctx.fillRect(ikx-_MZ,iky-2*_MZ,2*_MZ,6*_MZ);
      mapLabel('KEY',ikx,iky-9*_MZ,'#ffc04a');
    }
    for(i=0;i<G.ents.length;i++){
      var IEE=G.ents[i];
      if(!IEE.elite||IEE.downed) continue;
      ctx.fillStyle='#d08ce8';
      ctx.beginPath(); ctx.arc(ox+IEE.x*sc,oy+IEE.y*sc,3.4*_MZ,0,6.2832); ctx.fill();   // v21.41 (W-D4): at the map zoom
    }
    mapLabel('INTEL LIVE',ox+52*_MZ,oy+14*_MZ,'#4de3d0');
  }
  // Landmarks are what the map is navigated BY, so they are labelled and boxed
  // rather than left as anonymous geometry.
  var lms=(G.map.landmarks||[]);
  for(i=0;i<lms.length;i++){
    var LM2=lms[i];
    ctx.strokeStyle='rgba(255,192,74,.55)'; ctx.lineWidth=1;
    ctx.strokeRect(ox+LM2.x*sc,oy+LM2.y*sc,LM2.w*sc,LM2.h*sc);
    ctx.fillStyle='rgba(255,192,74,.07)';
    ctx.fillRect(ox+LM2.x*sc,oy+LM2.y*sc,LM2.w*sc,LM2.h*sc);
    // A landmark whose name is simply its zone's name adds no information and
    // costs legibility, so it draws its box and keeps quiet. The box still shows
    // where the building is; the region is already captioned above it.
    var _lz=G.map.zoneAt?G.map.zoneAt(LM2.x+LM2.w/2,LM2.y+LM2.h/2):null;
    var _dupe=_lz&&_lz.name&&LM2.name&&
              String(_lz.name).toUpperCase()===String(LM2.name).toUpperCase();
    if(!_dupe){
      ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
      ctx.fillStyle='#ffc04a';
      ctx.fillText(LM2.name,ox+(LM2.x+LM2.w/2)*sc,oy+(LM2.y+LM2.h/2)*sc+3);
      ctx.textAlign='left';
    }
  }
  // THE SEAL, always marked. It is the reason you came back.
  if(G.seal){
    var slx=ox+G.seal.x*sc,sly=oy+G.seal.y*sc;   // v21.41 (W-D4): the seal ring at the map zoom
    var SRm=sealHere(),needM=sealNeed(SRm.tier);
    var pctM=clamp((SRm.cut+G.seal.gained)/needM,0,1);
    ctx.strokeStyle=G.seal.done?'#ffc04a':'#8fd0ff'; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(slx,sly,12*_MZ,0,6.2832); ctx.stroke();
    ctx.strokeStyle=G.seal.done?'#ffc04a':'#4de3d0'; ctx.lineWidth=3*_MZ;
    ctx.beginPath(); ctx.arc(slx,sly,12*_MZ,-1.5708,-1.5708+6.2832*pctM); ctx.stroke();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillStyle=G.seal.done?'#ffc04a':'#8fd0ff';
    ctx.fillText(G.seal.done?'SEAL BROKEN':('SEAL '+Math.round(pctM*100)+'%'),slx,sly-16*_MZ);
    ctx.textAlign='left';
  }
  // v26.xx (forgest1), HIS QUESTION 2026-10-14: THE FORGE on the sector map, a gold anvil in a ring with its name, at the map zoom.
  if(G.forge&&isFinite(G.forge.x)&&isFinite(G.forge.y)){
    var fgx=ox+G.forge.x*sc, fgy=oy+G.forge.y*sc;
    ctx.fillStyle='rgba(255,201,74,.16)'; ctx.beginPath(); ctx.arc(fgx,fgy,14*_MZ,0,6.2832); ctx.fill();
    ctx.strokeStyle=FORGE_GOLD; ctx.lineWidth=1.5*_MZ; ctx.beginPath(); ctx.arc(fgx,fgy,14*_MZ,0,6.2832); ctx.stroke();
    forgeAnvil(ctx,fgx,fgy,8.5*_MZ,FORGE_GOLD,INK);
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro); ctx.fillStyle=FORGE_GOLD;
    ctx.fillText(String(G.forge.name||'THE FORGE'),fgx,fgy-19*_MZ); ctx.textAlign='left';
  }
  try{ flowMap(ctx,ox,oy,sc,_MZ,FS); }catch(_fmp){}   // v26.xx (flow4): the raid flow marks on the sector map
  // THE STRONGBOX. Marked from the start: it is not a secret, it is a dare.
  for(i=0;i<G.containers.length;i++){
    var sbm=G.containers[i];
    if(!sbm.strong||sbm.opened) continue;
    var sbx=ox+sbm.x*sc,sby=oy+sbm.y*sc;   // v21.41 (W-D4): the strongbox mark at the map zoom
    ctx.strokeStyle='#ffc04a'; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(sbx,sby,10*_MZ,0,6.2832); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(sbx-14*_MZ,sby); ctx.lineTo(sbx-10*_MZ,sby);
    ctx.moveTo(sbx+10*_MZ,sby); ctx.lineTo(sbx+14*_MZ,sby);
    ctx.moveTo(sbx,sby-14*_MZ); ctx.lineTo(sbx,sby-10*_MZ);
    ctx.moveTo(sbx,sby+10*_MZ); ctx.lineTo(sbx,sby+14*_MZ); ctx.stroke();
    ctx.fillStyle='#ffc04a';
    ctx.beginPath(); ctx.arc(sbx,sby,3.6*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText('STRONGBOX',sbx,sby-15*_MZ); ctx.textAlign='left';
  }
  // YOUR BODY. The bm.mine write is unreachable (P.body is cleared on every
  // raid start and nothing recreates it), so this loop marks nothing; it stays
  // per the Q27 ruling that the body chain is zeroed rather than deleted.
  for(i=0;i<G.containers.length;i++){
    var bm=G.containers[i];
    if(!bm.mine||bm.opened) continue;
    var bmx=ox+bm.x*sc,bmy=oy+bm.y*sc;
    var bp=0.55+0.45*Math.sin(G.t*3);
    ctx.strokeStyle='rgba(53,214,200,'+bp.toFixed(2)+')'; ctx.lineWidth=2;
    ctx.beginPath(); ctx.arc(bmx,bmy,11,0,6.2832); ctx.stroke();
    ctx.fillStyle='#4de3d0';
    ctx.beginPath(); ctx.arc(bmx,bmy,4,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.label);
    ctx.textAlign='left';   // YOUR BODY map label deleted at v5.57, unreachable
  }
  // A cache the Stray told you about. This is his whole payment, so it is drawn
  // large and named: without it, being decent to him buys nothing you can see.
  for(i=0;i<G.containers.length;i++){
    var rc=G.containers[i];
    if(!rc.revealed||rc.opened) continue;
    var rmx=ox+rc.x*sc,rmy=oy+rc.y*sc;   // v21.41 (W-D4): at the map zoom
    ctx.strokeStyle='#e6b4ff'; ctx.lineWidth=1.6*_MZ;
    ctx.beginPath(); ctx.arc(rmx,rmy,8*_MZ,0,6.2832); ctx.stroke();
    ctx.fillStyle='#e6b4ff';
    ctx.beginPath(); ctx.arc(rmx,rmy,3.4*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText('CACHE',rmx,rmy-12*_MZ); ctx.textAlign='left';
  }
  // The survivor, but only once you have actually found him. He is hiding.
  for(i=0;i<G.ents.length;i++){
    var sm=G.ents[i];
    if(sm.kind!=='stray'||!sm.found) continue;
    var smx=ox+sm.x*sc,smy=oy+sm.y*sc;   // v21.41 (W-D4): at the map zoom
    ctx.fillStyle='#120e0c'; ctx.beginPath(); ctx.arc(smx,smy,6*_MZ,0,6.2832); ctx.fill();
    ctx.fillStyle=sm.helped?'#5a9a6a':'#7fc4a0';
    ctx.beginPath(); ctx.arc(smx,smy,4*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText(sm.helped?'SURVIVOR':'SURVIVOR (NEEDS)',smx,smy-11*_MZ); ctx.textAlign='left';
  }
  // The Peddler is marked. Half your bag is worth walking to him for, and a
  // trade you never found is not a decision, it is a secret.
  for(i=0;i<G.ents.length;i++){
    var pdm=G.ents[i]; if(pdm.kind!=='peddler') continue;
    var pmx=ox+pdm.x*sc,pmy=oy+pdm.y*sc;   // v21.41 (W-D4): at the map zoom
    ctx.fillStyle='#120e0c'; ctx.beginPath(); ctx.arc(pmx,pmy,6.4*_MZ,0,6.2832); ctx.fill();
    ctx.fillStyle=pedOpen()?'#ffc04a':'#8a5a4a';
    ctx.beginPath(); ctx.arc(pmx,pmy,4.4*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillStyle=pedOpen()?'#ffc04a':'#8a5a4a';
    ctx.fillText(pedOpen()?'PEDDLER':'PEDDLER (CLOSED)',pmx,pmy-11*_MZ);
    ctx.textAlign='left';
  }
  for(i=0;i<G.zones.length;i++){
    var zz=G.zones[i],act=!!zz.open;
    ctx.strokeStyle=act?'#4de3d0':'rgba(127,146,216,.42)'; ctx.lineWidth=act?2:1;
    ctx.beginPath(); ctx.arc(ox+zz.x*sc,oy+zz.y*sc,zz.r*sc+3,0,6.2832); ctx.stroke();
    if(act){ ctx.fillStyle='#4de3d0'; ctx.beginPath(); ctx.arc(ox+zz.x*sc,oy+zz.y*sc,3*_MZ,0,6.2832); ctx.fill(); }   // v21.41 (W-D4): at the map zoom
  }
  // THE WAYPOINT, v3.02. Drawn before the player marker so his own dot always
  // sits on top of it, and drawn as a ring plus crosshair rather than a filled
  // dot so it cannot be mistaken for an extract or for himself.
  try{ if(NET.on) netWpMapDraw(ox,oy,sc); }catch(_wm){}   // v16.46: the party's map markers on the map
  if(G.waypoint){
    var wpx=ox+G.waypoint.x*sc, wpy=oy+G.waypoint.y*sc;   // v21.41 (W-D4): the waypoint at the map zoom
    ctx.strokeStyle='#ffc04a'; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(wpx,wpy,7*_MZ,0,6.2832); ctx.stroke();
    ctx.lineWidth=_MZ;
    ctx.beginPath();
    ctx.moveTo(wpx-11*_MZ,wpy); ctx.lineTo(wpx-3*_MZ,wpy);
    ctx.moveTo(wpx+3*_MZ,wpy);  ctx.lineTo(wpx+11*_MZ,wpy);
    ctx.moveTo(wpx,wpy-11*_MZ); ctx.lineTo(wpx,wpy-3*_MZ);
    ctx.moveTo(wpx,wpy+3*_MZ);  ctx.lineTo(wpx,wpy+11*_MZ);
    ctx.stroke();
    ctx.font=FS(TYPE.micro); ctx.fillStyle='#ffc04a'; ctx.textAlign='center';
    ctx.fillText('WAYPOINT',wpx,wpy-14*_MZ); ctx.textAlign='left';
  }
// v4.31: what you have never seen is not on your map. Seen once, seen
  // forever, across runs. Painted over everything except your own marker and
  // the chrome, so an uncharted zone leaks neither walls nor names.
  // BOTH BLACKOUTS ARE GONE NOW: the coarse overlay at v5.30, the fine one at
  // v7.57 on his order. discArr is still marked and still on the profile,
  // purely so fogLoad can seed a map he charted before v5.29, and the fine
  // grid still feeds the SURVEYED percentage.
if(G.trail&&G.trail.length>1){
    ctx.strokeStyle='rgba(255,192,74,.55)'; ctx.lineWidth=1.5;
    ctx.setLineDash([3,4]);
    ctx.beginPath();
    ctx.moveTo(ox+G.trail[0].x*sc,oy+G.trail[0].y*sc);
    for(var _tw=1;_tw<G.trail.length;_tw++) ctx.lineTo(ox+G.trail[_tw].x*sc,oy+G.trail[_tw].y*sc);
    ctx.lineTo(ox+p.x*sc,oy+p.y*sc);
    ctx.stroke();
    ctx.setLineDash([]);
  }
  // v7.57, his order: no blackout on the map page - the whole map shows. The
  // fog DATA stays live (fogMark/fogSave feed SURVEYED % and the profile).
  // THE HOT ZONE, over the fog. His Q28 says he must be able to CHOOSE to go or
  // avoid, and a choice you cannot see until you have walked there is not one.
  (function(){
    var H=G.hotZone; if(!H) return;
    var hx=ox+H.x*sc, hy=oy+H.y*sc, hr=Math.max(6,H.r*sc);
    ctx.strokeStyle='rgba(255,120,60,.85)'; ctx.lineWidth=2;
    ctx.setLineDash([6,5]);
    ctx.beginPath(); ctx.arc(hx,hy,hr,0,6.2832); ctx.stroke();
    ctx.setLineDash([]);
    ctx.fillStyle='rgba(255,120,60,.13)';
    ctx.beginPath(); ctx.arc(hx,hy,hr,0,6.2832); ctx.fill();
    ctx.fillStyle='rgba(255,150,90,.95)'; ctx.font=FS(TYPE.micro); ctx.textAlign='center';
    // v19.29, seen on the 4K map screenshot (2026-10-08): the two lines were 12 pixels apart whatever the text size, so where the text
    // is bigger (a big screen, a bigger text setting) the second line printed over the first. They are a line height apart now.
    var _hgf=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11;
    ctx.fillText('HOT GROUND',hx,hy-hr-5);
    ctx.fillStyle='rgba(255,150,90,.65)';
    ctx.fillText('richer, and busier',hx,hy-hr-5+Math.max(12,_hgf*1.15));
    ctx.textAlign='left';
  })();
  // Drawn AFTER the fog on purpose: the extraction rings and your own marker are
  // the two things you are never allowed to lose, per his Q23.
  (function(){
    for(var _fz=0;_fz<G.zones.length;_fz++){
      var Z=G.zones[_fz];
      // v7.60, his orders: named rings, a close countdown, two-stage flashing.
      var _zAct=(Z.beaconT!==null&&Z.beaconT!==undefined);
      var _zHold=_zAct&&Z.beaconT<=0&&Z.hold!==null&&Z.hold!==undefined;
      var _fl=1;
      if(_zHold) _fl=0.55+0.45*Math.sin(G.t*10);
      else if(_zAct) _fl=0.65+0.35*Math.sin(G.t*4);
      ctx.strokeStyle=Z.open?('rgba(77,227,208,'+((((Z===G.active)?0.95:0.45))*_fl).toFixed(3)+')'):'rgba(127,146,216,.42)';
      ctx.lineWidth=(Z===G.active)?2:1;
      ctx.beginPath(); ctx.arc(ox+Z.x*sc,oy+Z.y*sc,Math.max(4,Z.r*sc),0,6.2832); ctx.stroke();
      // v11.85, HIS NOTE: "the map should show when the extracts are going to
      // close via countdown on each one". It did, since v7.60, in the smallest
      // face the game has, so he never saw it. Name as a callout, countdown as
      // a label, each on its own row.
      ctx.font=FS(TYPE.head); ctx.textAlign='center';
      ctx.fillStyle=Z.open?('rgba(77,227,208,'+(0.9*_fl).toFixed(3)+')'):'rgba(154,168,208,.80)';
      // v21.03, from the whole-game bug hunt of 2026-10-08 (V-D1), seen on the 4K map screenshot: THE EXTRACTION NAME AND THE LINE
      // UNDER IT NEVER TOUCH. Both lines are drawn in the map type, which grows with the screen (_MZ, about 2 at 4K), but the room
      // between them was a fixed LH(18), so at 4K EXTRACT C sat on closes in 2 min 57 sec and EXTRACT B on STAYS OPEN. The two
      // offsets grow by the same _MZ now. At 1080p _MZ is 1 and nothing moves.
      ctx.fillText('EXTRACT '+String.fromCharCode(65+_fz),ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(24)*_MZ);
      var _zSub;
      if(!Z.open) _zSub='CLOSED';
      else if(_zHold) _zSub='EXTRACT IN PROGRESS!  '+Math.max(0,Math.ceil(Z.hold))+'S LEFT';   // v12.21: the banner's words (v11.74, his rewording of 2026-10-03); the letter is the line above
      else if(_zAct) _zSub='CALLED  '+Math.max(0,Math.ceil(Z.beaconT))+'s';
      else if(Z.closeAt===undefined) _zSub='STAYS OPEN';
      else _zSub='closes in '+fmtDur(Math.max(0,Math.ceil(G.timeLeft-Z.closeAt)));   // v22.xx (R48): m:ss, never 2 min 57 sec
      ctx.font=FS(TYPE.label);   // v11.85: the countdown, readable
      ctx.fillText(_zSub,ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(6)*_MZ);
      // v21.15, HIS NOTE (2026-10-08): "on the map when an extract is in progress you still need to show the aggregate amt of time
      // that extract stays open in terms of match length so player can plan his route". A called ring and a ring in progress showed
      // only the call or the hold, and the closing countdown every other ring shows was gone just when the route is planned. It
      // stays now, on its own row under the ring, in the same words the other rings use.
      if(Z.open&&(_zAct||_zHold)&&(Z.closeAt===undefined||G.timeLeft>Z.closeAt)) ctx.fillText(   /* v21.27 (R9): a ring called before its cutoff runs past it; no 0:00 then */(Z.closeAt===undefined)?'STAYS OPEN':('closes in '+fmtDur(Math.max(0,Math.ceil(G.timeLeft-Z.closeAt)))),ox+Z.x*sc,oy+Z.y*sc+Math.max(4,Z.r*sc)+LH(16)*_MZ);
      ctx.textAlign='left';
    }
  })();
  // your own marker, ringed in ink so a gold dot never disappears into a gold
  // district block.
  // v10.92, HIS NOTE: it was 8 pixels across at 1920x1080 and did not follow the
  // map scale, so it was the smallest marker on a screen it is supposed to own.
  // It is roughly double now and scaled like its neighbours, with a halo under
  // it so it separates from whatever it is standing on.
  var _pmz=(typeof _MZ==='number'&&_MZ>0)?_MZ:1;
  var _pmx=ox+p.x*sc, _pmy=oy+p.y*sc;
  // v19.45, from the review (2026-10-08): since v19.02 the labels are drawn after this whole pass, so they printed over his own
  // marker and the party dots, the two things his Q23 says are never lost. The marker and the dots are handed to drawMapOverlay
  // to draw after the labels (MAPLAST), with the transform they would have had here.
  var _pmDraw=function(){
  // v27.xx (mapchev), HIS ORDER (2026-10-15): "make the player a NEON green chevron n the big map (M key) so that player is easier to see".
  // It was a gold dot with a facing line, the same gold as the district blocks and the loot marks, so it sank into the map. Now it is a
  // neon green chevron pointing where he faces, outlined in ink over a soft green halo. Same place, same scale with the map (_pmz).
  var _pf=p.face||0;
  var _pv=function(a,r){ return [_pmx+Math.cos(_pf+a)*r*_pmz, _pmy+Math.sin(_pf+a)*r*_pmz]; };
  var _pt=_pv(0,17), _pl=_pv(2.45,13), _pn=_pv(Math.PI,5), _pr=_pv(-2.45,13);
  ctx.fillStyle='rgba(57,255,20,.18)';
  ctx.beginPath(); ctx.arc(_pmx,_pmy,20*_pmz,0,6.2832); ctx.fill();
  ctx.beginPath(); ctx.moveTo(_pt[0],_pt[1]); ctx.lineTo(_pl[0],_pl[1]); ctx.lineTo(_pn[0],_pn[1]); ctx.lineTo(_pr[0],_pr[1]); ctx.closePath();
  ctx.lineJoin='round'; ctx.strokeStyle='#0b0f0a'; ctx.lineWidth=5*_pmz; ctx.stroke();
  ctx.fillStyle='#39ff14'; ctx.fill();
  ctx.lineJoin='miter';
  ctx.lineWidth=1;
  try{ if(NET.on) netMapDots(ox,oy,sc,_pmz); }catch(_nmd){}   // v16.08: the party on the sector map (the net section)
  // v22.00, from the whole-game bug hunt of 2026-10-08 (K10): THE CONTROLLER MAP CURSOR IS DRAWN. Since v16.47 the right stick
  // moves a cursor across the open map and a tap of D-UP places the marker there, but nothing drew that cursor: the only pointer
  // on the map was the mouse arrow, wherever the real mouse sat, so a pad player placed his marker blind. A ring and a cross now
  // show where it will land, after the labels like the marker above. G.mapCur is set only by the right stick and is cleared when
  // the map shuts, so a mouse player never sees it.
  if(G.mapCur){
    var _mcx=ox+G.mapCur.x*sc, _mcy=oy+G.mapCur.y*sc;
    var _mcP=function(){
      ctx.beginPath(); ctx.arc(_mcx,_mcy,9*_pmz,0,6.2832);
      ctx.moveTo(_mcx-16*_pmz,_mcy); ctx.lineTo(_mcx-5*_pmz,_mcy); ctx.moveTo(_mcx+5*_pmz,_mcy); ctx.lineTo(_mcx+16*_pmz,_mcy);
      ctx.moveTo(_mcx,_mcy-16*_pmz); ctx.lineTo(_mcx,_mcy-5*_pmz); ctx.moveTo(_mcx,_mcy+5*_pmz); ctx.lineTo(_mcx,_mcy+16*_pmz);
      ctx.stroke();
    };
    ctx.strokeStyle='#120e0c'; ctx.lineWidth=4.5*_pmz; _mcP();   // an ink edge, so it never disappears into a gold block
    ctx.strokeStyle='#ffc04a'; ctx.lineWidth=2*_pmz; _mcP();
    ctx.lineWidth=1;
  }
  };
  if(MAPLAST){ MAPLAST.push({fn:_pmDraw,m:ctx.getTransform(),ga:ctx.globalAlpha}); } else _pmDraw();
  // SURVEYED. Bottom left of the map, out of the way of every marker on it.
  (function(){
    var f=0; try{ f=fogFrac(); }catch(e){ return; }
    ctx.textAlign='left'; ctx.font=FS(TYPE.micro);
    ctx.fillStyle='rgba(214,208,190,.80)';
    // v19.29, seen on the 4K map screenshot (2026-10-08): these two were 14 pixels apart whatever the text size and printed over each
    // other on a big screen. A line height apart now, and lifted together if the second would fall off the bottom of the screen.
    var _svf=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11, _svl=Math.max(14,_svf*1.15), _sv1=oy+WORLD_H*sc+Math.max(16,_svf*1.1);
    // v19.53, from the review (2026-10-08): lifting the pair to fit (v19.29) pushed SURVEYED into the map frame and cut the bottoms off
    // the second line at 4K and at bigger text sizes. When both lines do not fit under the frame, they sit side by side on one line.
    var _svT='SURVEYED  '+Math.round(f*100)+'%';
    if(_sv1+_svl+_svf*0.25>H){
      _sv1=Math.min(_sv1,H-_svf*0.25-2);
      ctx.fillText(_svT,ox+4,_sv1);
      var _svW=ctx.measureText((typeof TX==='function')?String(TX(_svT)):_svT).width;
      ctx.fillStyle='rgba(214,208,190,.45)';
      ctx.fillText('what you walk stays on the map',ox+4+_svW+_svf*1.2,_sv1);
    } else {
      ctx.fillText(_svT,ox+4,_sv1);
      ctx.fillStyle='rgba(214,208,190,.45)';
      ctx.fillText('what you walk stays on the map',ox+4,_sv1+_svl);
    }
  })();
}
'@ @'
  }
  // INTEL, v3.81: a burned Data Core lights the map for one raid. Gold key
  // marks on the containers that hold the locked-room keys, gone once each is
  // opened, and live purple dots on every elite still standing. Map only: the
  // world itself shows nothing, because intel is knowing, not seeing.
  if(G.intel){
    for(i=0;i<(G.intelKeys||[]).length;i++){
      var IKC=G.intelKeys[i];
      // v15.55, keys audit finding 3: THE INTEL KEY MARK LEAVES A CONTAINER ONCE ITS KEY IS TAKEN OUT. The mark asked only
      // whether the box was opened, and opened turns true only when the whole search bar fills. The staged pulls hand loot out
      // one item at a time, worst first, and a 600 to 750 key ranks below a Titanium Cell, a better gun or a Black Box, so a safe or
      // locker searched part way gave up its key first and kept its gold KEY for the rest of the raid, with the key already in
      // his backpack and no key left in the box, even after the key was spent at the door. With several locked rooms that sent
      // him back across the map for a second key that was not there: the same wrong mark v15.17 took off restocked boxes,
      // reached by an ordinary search broken off early. A box now keeps its mark only while a key_ item is still in its loot,
      // the same test startRaid used to list it, so a box that held two keys keeps it until both are out. Crates never showed
      // this (their key is always their last item). No player text, no number and no seeded draw moved.
      if(IKC.opened||!(IKC.loot||[]).some(function(_k){ return String(_k).indexOf('key_')===0; })) continue;
      var ikx=ox+IKC.x*sc,iky=oy+IKC.y*sc;
      ctx.fillStyle=UIC.tx_1;
      ctx.beginPath(); ctx.arc(ikx,iky-3*_MZ,2.6*_MZ,0,6.2832); ctx.fill();   // v21.41 (W-D4): the intel key at the map zoom
      ctx.fillRect(ikx-_MZ,iky-2*_MZ,2*_MZ,6*_MZ);
      mapLabel('KEY',ikx,iky-9*_MZ,UIC.tx_1);
    }
    for(i=0;i<G.ents.length;i++){
      var IEE=G.ents[i];
      if(!IEE.elite||IEE.downed) continue;
      ctx.fillStyle=UIC.r_elite;
      ctx.beginPath(); ctx.arc(ox+IEE.x*sc,oy+IEE.y*sc,3.4*_MZ,0,6.2832); ctx.fill();   // v21.41 (W-D4): at the map zoom
    }
    mapLabel('INTEL LIVE',ox+52*_MZ,oy+14*_MZ,UIC.tx_2);
  }
  // Landmarks are what the map is navigated BY, so they are labelled and boxed
  // rather than left as anonymous geometry.
  var lms=(G.map.landmarks||[]);
  for(i=0;i<lms.length;i++){
    var LM2=lms[i];
    ctx.strokeStyle='rgba(170,164,152,.40)'; ctx.lineWidth=1;
    ctx.strokeRect(ox+LM2.x*sc,oy+LM2.y*sc,LM2.w*sc,LM2.h*sc);
    ctx.fillStyle='rgba(239,233,220,.025)';
    ctx.fillRect(ox+LM2.x*sc,oy+LM2.y*sc,LM2.w*sc,LM2.h*sc);
    // A landmark whose name is simply its zone's name adds no information and
    // costs legibility, so it draws its box and keeps quiet. The box still shows
    // where the building is; the region is already captioned above it.
    var _lz=G.map.zoneAt?G.map.zoneAt(LM2.x+LM2.w/2,LM2.y+LM2.h/2):null;
    var _dupe=_lz&&_lz.name&&LM2.name&&
              String(_lz.name).toUpperCase()===String(LM2.name).toUpperCase();
    if(!_dupe){
      ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
      ctx.fillStyle=UIC.tx_2;
      ctx.fillText(LM2.name,ox+(LM2.x+LM2.w/2)*sc,oy+(LM2.y+LM2.h/2)*sc+3);
      ctx.textAlign='left';
    }
  }
  // THE SEAL, always marked. It is the reason you came back.
  if(G.seal){
    var slx=ox+G.seal.x*sc,sly=oy+G.seal.y*sc; mapIcon(slx,sly,15*_MZ);   // v21.41 (W-D4): the seal ring at the map zoom
    var SRm=sealHere(),needM=sealNeed(SRm.tier);
    var pctM=clamp((SRm.cut+G.seal.gained)/needM,0,1);
    ctx.strokeStyle=G.seal.done?UIC.ok:UIC.ui_line_hi; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(slx,sly,12*_MZ,0,6.2832); ctx.stroke();
    ctx.strokeStyle=G.seal.done?UIC.ok:UIC.acc; ctx.lineWidth=3*_MZ;
    ctx.beginPath(); ctx.arc(slx,sly,12*_MZ,-1.5708,-1.5708+6.2832*pctM); ctx.stroke();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillStyle=G.seal.done?UIC.ok:UIC.tx_1;
    ctx.fillText(G.seal.done?'SEAL BROKEN':('SEAL '+Math.round(pctM*100)+'%'),slx,sly-16*_MZ);
    ctx.textAlign='left';
  }
  // v26.xx (forgest1), HIS QUESTION 2026-10-14: THE FORGE on the sector map, a gold anvil in a ring with its name, at the map zoom.
  if(G.forge&&isFinite(G.forge.x)&&isFinite(G.forge.y)){
    var fgx=ox+G.forge.x*sc, fgy=oy+G.forge.y*sc;
    ctx.fillStyle='rgba(239,233,220,.10)'; mapIcon(fgx,fgy,16*_MZ); ctx.beginPath(); ctx.arc(fgx,fgy,14*_MZ,0,6.2832); ctx.fill();
    ctx.strokeStyle=UIC.tx_1; ctx.lineWidth=1.5*_MZ; ctx.beginPath(); ctx.arc(fgx,fgy,14*_MZ,0,6.2832); ctx.stroke();
    forgeAnvil(ctx,fgx,fgy,8.5*_MZ,UIC.tx_1,INK);
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.tx_1;
    ctx.fillText(String(G.forge.name||'THE FORGE'),fgx,fgy-19*_MZ); ctx.textAlign='left';
  }
  try{ flowMap(ctx,ox,oy,sc,_MZ,FS); }catch(_fmp){}   // v26.xx (flow4): the raid flow marks on the sector map
  // THE STRONGBOX. Marked from the start: it is not a secret, it is a dare.
  for(i=0;i<G.containers.length;i++){
    var sbm=G.containers[i];
    if(!sbm.strong||sbm.opened) continue;
    var sbx=ox+sbm.x*sc,sby=oy+sbm.y*sc; mapIcon(sbx,sby,15*_MZ);   // v21.41 (W-D4): the strongbox mark at the map zoom
    ctx.strokeStyle=UIC.tx_1; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(sbx,sby,10*_MZ,0,6.2832); ctx.stroke();
    ctx.beginPath(); ctx.moveTo(sbx-14*_MZ,sby); ctx.lineTo(sbx-10*_MZ,sby);
    ctx.moveTo(sbx+10*_MZ,sby); ctx.lineTo(sbx+14*_MZ,sby);
    ctx.moveTo(sbx,sby-14*_MZ); ctx.lineTo(sbx,sby-10*_MZ);
    ctx.moveTo(sbx,sby+10*_MZ); ctx.lineTo(sbx,sby+14*_MZ); ctx.stroke();
    ctx.fillStyle=UIC.tx_1;
    ctx.beginPath(); ctx.arc(sbx,sby,3.6*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText('STRONGBOX',sbx,sby-15*_MZ); ctx.textAlign='left';
  }
  // YOUR BODY. The bm.mine write is unreachable (P.body is cleared on every
  // raid start and nothing recreates it), so this loop marks nothing; it stays
  // per the Q27 ruling that the body chain is zeroed rather than deleted.
  for(i=0;i<G.containers.length;i++){
    var bm=G.containers[i];
    if(!bm.mine||bm.opened) continue;
    var bmx=ox+bm.x*sc,bmy=oy+bm.y*sc;
    var bp=0.55+0.45*Math.sin(G.t*3);
    ctx.strokeStyle='rgba(53,214,200,'+bp.toFixed(2)+')'; ctx.lineWidth=2;
    ctx.beginPath(); ctx.arc(bmx,bmy,11,0,6.2832); ctx.stroke();
    ctx.fillStyle=UIC.extract;
    ctx.beginPath(); ctx.arc(bmx,bmy,4,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.label);
    ctx.textAlign='left';   // YOUR BODY map label deleted at v5.57, unreachable
  }
  // A cache the Stray told you about. This is his whole payment, so it is drawn
  // large and named: without it, being decent to him buys nothing you can see.
  for(i=0;i<G.containers.length;i++){
    var rc=G.containers[i];
    if(!rc.revealed||rc.opened) continue;
    var rmx=ox+rc.x*sc,rmy=oy+rc.y*sc; mapIcon(rmx,rmy,10*_MZ);   // v21.41 (W-D4): at the map zoom
    ctx.strokeStyle=UIC.tx_1; ctx.lineWidth=1.6*_MZ;
    ctx.beginPath(); ctx.arc(rmx,rmy,8*_MZ,0,6.2832); ctx.stroke();
    ctx.fillStyle=UIC.tx_1;
    ctx.beginPath(); ctx.arc(rmx,rmy,3.4*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText('CACHE',rmx,rmy-12*_MZ); ctx.textAlign='left';
  }
  // The survivor, but only once you have actually found him. He is hiding.
  for(i=0;i<G.ents.length;i++){
    var sm=G.ents[i];
    if(sm.kind!=='stray'||!sm.found) continue;
    var smx=ox+sm.x*sc,smy=oy+sm.y*sc; mapIcon(smx,smy,8*_MZ);   // v21.41 (W-D4): at the map zoom
    ctx.fillStyle='#120e0c'; ctx.beginPath(); ctx.arc(smx,smy,6*_MZ,0,6.2832); ctx.fill();
    ctx.fillStyle=sm.helped?'#5a9a6a':UIC.ok;
    ctx.beginPath(); ctx.arc(smx,smy,4*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillText(sm.helped?'SURVIVOR':'SURVIVOR (NEEDS)',smx,smy-11*_MZ); ctx.textAlign='left';
  }
  // The Peddler is marked. Half your bag is worth walking to him for, and a
  // trade you never found is not a decision, it is a secret.
  for(i=0;i<G.ents.length;i++){
    var pdm=G.ents[i]; if(pdm.kind!=='peddler') continue;
    var pmx=ox+pdm.x*sc,pmy=oy+pdm.y*sc; mapIcon(pmx,pmy,8*_MZ);   // v21.41 (W-D4): at the map zoom
    ctx.fillStyle='#120e0c'; ctx.beginPath(); ctx.arc(pmx,pmy,6.4*_MZ,0,6.2832); ctx.fill();
    ctx.fillStyle=pedOpen()?UIC.tx_1:UIC.tx_3;
    ctx.beginPath(); ctx.arc(pmx,pmy,4.4*_MZ,0,6.2832); ctx.fill();
    ctx.textAlign='center'; ctx.font=FS(TYPE.micro);
    ctx.fillStyle=pedOpen()?UIC.tx_1:UIC.tx_3;
    ctx.fillText(pedOpen()?'PEDDLER':'PEDDLER (CLOSED)',pmx,pmy-11*_MZ);
    ctx.textAlign='left';
  }
  for(i=0;i<G.zones.length;i++){
    var zz=G.zones[i],act=!!zz.open;
    ctx.strokeStyle=act?UIC.extract:'rgba(170,164,152,.55)'; ctx.lineWidth=act?2:1;
    ctx.beginPath(); ctx.arc(ox+zz.x*sc,oy+zz.y*sc,zz.r*sc+3,0,6.2832); ctx.stroke();
    // v31.xx (cw-mapstyle): the centre dot is the extraction glyph now (drawn with the ring below)   // v21.41 (W-D4): at the map zoom
  }
  // THE WAYPOINT, v3.02. Drawn before the player marker so his own dot always
  // sits on top of it, and drawn as a ring plus crosshair rather than a filled
  // dot so it cannot be mistaken for an extract or for himself.
  try{ if(NET.on) netWpMapDraw(ox,oy,sc); }catch(_wm){}   // v16.46: the party's map markers on the map
  if(G.waypoint){
    var wpx=ox+G.waypoint.x*sc, wpy=oy+G.waypoint.y*sc; mapIcon(wpx,wpy,12*_MZ);   // v21.41 (W-D4): the waypoint at the map zoom
    ctx.strokeStyle=UIC.tx_1; ctx.lineWidth=2*_MZ;
    ctx.beginPath(); ctx.arc(wpx,wpy,7*_MZ,0,6.2832); ctx.stroke();
    ctx.lineWidth=_MZ;
    ctx.beginPath();
    ctx.moveTo(wpx-11*_MZ,wpy); ctx.lineTo(wpx-3*_MZ,wpy);
    ctx.moveTo(wpx+3*_MZ,wpy);  ctx.lineTo(wpx+11*_MZ,wpy);
    ctx.moveTo(wpx,wpy-11*_MZ); ctx.lineTo(wpx,wpy-3*_MZ);
    ctx.moveTo(wpx,wpy+3*_MZ);  ctx.lineTo(wpx,wpy+11*_MZ);
    ctx.stroke();
    ctx.font=FS(TYPE.micro); ctx.fillStyle=UIC.tx_1; ctx.textAlign='center';
    ctx.fillText('WAYPOINT',wpx,wpy-14*_MZ); ctx.textAlign='left';
  }
// v4.31: what you have never seen is not on your map. Seen once, seen
  // forever, across runs. Painted over everything except your own marker and
  // the chrome, so an uncharted zone leaks neither walls nor names.
  // BOTH BLACKOUTS ARE GONE NOW: the coarse overlay at v5.30, the fine one at
  // v7.57 on his order. discArr is still marked and still on the profile,
  // purely so fogLoad can seed a map he charted before v5.29, and the fine
  // grid still feeds the SURVEYED percentage.
if(G.trail&&G.trail.length>1){
    ctx.strokeStyle='rgba(239,233,220,.40)'; ctx.lineWidth=1.5;
    ctx.setLineDash([3,4]);
    ctx.beginPath();
    ctx.moveTo(ox+G.trail[0].x*sc,oy+G.trail[0].y*sc);
    for(var _tw=1;_tw<G.trail.length;_tw++) ctx.lineTo(ox+G.trail[_tw].x*sc,oy+G.trail[_tw].y*sc);
    ctx.lineTo(ox+p.x*sc,oy+p.y*sc);
    ctx.stroke();
    ctx.setLineDash([]);
  }
  // v7.57, his order: no blackout on the map page - the whole map shows. The
  // fog DATA stays live (fogMark/fogSave feed SURVEYED % and the profile).
  // THE HOT ZONE, over the fog. His Q28 says he must be able to CHOOSE to go or
  // avoid, and a choice you cannot see until you have walked there is not one.
  (function(){
    var H=G.hotZone; if(!H) return;
    var hx=ox+H.x*sc, hy=oy+H.y*sc, hr=Math.max(6,H.r*sc);
    ctx.strokeStyle='rgba(229,72,47,.90)'; ctx.lineWidth=2*_MZ;
    ctx.setLineDash([6,5]);
    ctx.beginPath(); ctx.arc(hx,hy,hr,0,6.2832); ctx.stroke();
    ctx.setLineDash([]);
    ctx.fillStyle='rgba(229,72,47,.12)';
    ctx.beginPath(); ctx.arc(hx,hy,hr,0,6.2832); ctx.fill();
    mapGlyph('warning',hx,hy,22*_MZ,UIC.danger,2.4); mapIcon(hx,hy,14*_MZ);   // v31.xx (cw-mapstyle): the hot ground has its own glyph
    ctx.fillStyle=UIC.danger; ctx.font=FS(TYPE.micro); ctx.textAlign='center';
    // v19.29, seen on the 4K map screenshot (2026-10-08): the two lines were 12 pixels apart whatever the text size, so where the text
    // is bigger (a big screen, a bigger text setting) the second line printed over the first. They are a line height apart now.
    var _hgf=parseFloat(((/([\d.]+)px/).exec(String(ctx.font))||[0,11])[1])||11;
    ctx.fillText('HOT GROUND',hx,hy-hr-5);
    ctx.fillStyle='rgba(229,72,47,.78)';
    ctx.fillText('richer, and busier',hx,hy-hr-5+Math.max(12,_hgf*1.15));
    ctx.textAlign='left';
  })();
  // Drawn AFTER the fog on purpose: the extraction rings and your own marker are
  // the two things you are never allowed to lose, per his Q23.
  (function(){
    for(var _fz=0;_fz<G.zones.length;_fz++){
      var Z=G.zones[_fz];
      // v7.60, his orders: named rings, a close countdown, two-stage flashing.
      var _zAct=(Z.beaconT!==null&&Z.beaconT!==undefined);
      var _zHold=_zAct&&Z.beaconT<=0&&Z.hold!==null&&Z.hold!==undefined;
      var _fl=1;
      if(_zHold) _fl=0.55+0.45*Math.sin(G.t*10);
      else if(_zAct) _fl=0.65+0.35*Math.sin(G.t*4);
      ctx.strokeStyle=Z.open?('rgba(71,216,198,'+((((Z===G.active)?0.95:0.45))*_fl).toFixed(3)+')'):'rgba(170,164,152,.55)';
      ctx.lineWidth=(Z===G.active)?2:1;
      ctx.beginPath(); ctx.arc(ox+Z.x*sc,oy+Z.y*sc,Math.max(4,Z.r*sc),0,6.2832); ctx.stroke();
      mapGlyph('extraction',ox+Z.x*sc,oy+Z.y*sc,Math.max(10,Z.r*sc*0.9),Z.open?UIC.extract:UIC.tx_3,2.4); mapIcon(ox+Z.x*sc,oy+Z.y*sc,Math.max(4,Z.r*sc)+4);   // v31.xx (cw-mapstyle): an extraction ring has its own glyph
      // v11.85, HIS NOTE: "the map should show when the extracts are going to
      // close via countdown on each one". It did, since v7.60, in the smallest
      // face the game has, so he never saw it. Name as a callout, countdown as
      // a label, each on its own row.
      ctx.font=FS(TYPE.head); ctx.textAlign='center';
      ctx.fillStyle=Z.open?('rgba(71,216,198,'+(0.9*_fl).toFixed(3)+')'):'rgba(170,164,152,.85)';
      // v21.03, from the whole-game bug hunt of 2026-10-08 (V-D1), seen on the 4K map screenshot: THE EXTRACTION NAME AND THE LINE
      // UNDER IT NEVER TOUCH. Both lines are drawn in the map type, which grows with the screen (_MZ, about 2 at 4K), but the room
      // between them was a fixed LH(18), so at 4K EXTRACT C sat on closes in 2 min 57 sec and EXTRACT B on STAYS OPEN. The two
      // offsets grow by the same _MZ now. At 1080p _MZ is 1 and nothing moves.
      ctx.fillText('EXTRACT '+String.fromCharCode(65+_fz),ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(24)*_MZ);
      var _zSub;
      if(!Z.open) _zSub='CLOSED';
      else if(_zHold) _zSub='EXTRACT IN PROGRESS!  '+Math.max(0,Math.ceil(Z.hold))+'S LEFT';   // v12.21: the banner's words (v11.74, his rewording of 2026-10-03); the letter is the line above
      else if(_zAct) _zSub='CALLED  '+Math.max(0,Math.ceil(Z.beaconT))+'s';
      else if(Z.closeAt===undefined) _zSub='STAYS OPEN';
      else _zSub='closes in '+fmtDur(Math.max(0,Math.ceil(G.timeLeft-Z.closeAt)));   // v22.xx (R48): m:ss, never 2 min 57 sec
      ctx.font=FS(TYPE.label);   // v11.85: the countdown, readable
      ctx.fillText(_zSub,ox+Z.x*sc,oy+Z.y*sc-Math.max(4,Z.r*sc)-LH(6)*_MZ);
      // v21.15, HIS NOTE (2026-10-08): "on the map when an extract is in progress you still need to show the aggregate amt of time
      // that extract stays open in terms of match length so player can plan his route". A called ring and a ring in progress showed
      // only the call or the hold, and the closing countdown every other ring shows was gone just when the route is planned. It
      // stays now, on its own row under the ring, in the same words the other rings use.
      if(Z.open&&(_zAct||_zHold)&&(Z.closeAt===undefined||G.timeLeft>Z.closeAt)) ctx.fillText(   /* v21.27 (R9): a ring called before its cutoff runs past it; no 0:00 then */(Z.closeAt===undefined)?'STAYS OPEN':('closes in '+fmtDur(Math.max(0,Math.ceil(G.timeLeft-Z.closeAt)))),ox+Z.x*sc,oy+Z.y*sc+Math.max(4,Z.r*sc)+LH(16)*_MZ);
      ctx.textAlign='left';
    }
  })();
  // your own marker, ringed in ink so a gold dot never disappears into a gold
  // district block.
  // v10.92, HIS NOTE: it was 8 pixels across at 1920x1080 and did not follow the
  // map scale, so it was the smallest marker on a screen it is supposed to own.
  // It is roughly double now and scaled like its neighbours, with a halo under
  // it so it separates from whatever it is standing on.
  var _pmz=(typeof _MZ==='number'&&_MZ>0)?_MZ:1;
  var _pmx=ox+p.x*sc, _pmy=oy+p.y*sc;
  // v19.45, from the review (2026-10-08): since v19.02 the labels are drawn after this whole pass, so they printed over his own
  // marker and the party dots, the two things his Q23 says are never lost. The marker and the dots are handed to drawMapOverlay
  // to draw after the labels (MAPLAST), with the transform they would have had here.
  mapIcon(_pmx,_pmy,22*_pmz);
  var _pmDraw=function(){
  // v27.xx (mapchev), HIS ORDER (2026-10-15): "make the player a NEON green chevron n the big map (M key) so that player is easier to see".
  // It was a gold dot with a facing line, the same gold as the district blocks and the loot marks, so it sank into the map. Now it is a
  // neon green chevron pointing where he faces, outlined in ink over a soft green halo. Same place, same scale with the map (_pmz).
  var _pf=p.face||0;
  var _pv=function(a,r){ return [_pmx+Math.cos(_pf+a)*r*_pmz, _pmy+Math.sin(_pf+a)*r*_pmz]; };
  var _pt=_pv(0,17), _pl=_pv(2.45,13), _pn=_pv(Math.PI,5), _pr=_pv(-2.45,13);
  var _pcol=mapSeatColor(seatHere());   // v31.xx (cw-mapstyle): the player marker is the player's colour: lime for player 1 and a solo raid, the ally blue for player 2 (was a neon green for all)
  ctx.fillStyle=hexA(_pcol,.22);
  ctx.beginPath(); ctx.arc(_pmx,_pmy,20*_pmz,0,6.2832); ctx.fill();
  ctx.beginPath(); ctx.moveTo(_pt[0],_pt[1]); ctx.lineTo(_pl[0],_pl[1]); ctx.lineTo(_pn[0],_pn[1]); ctx.lineTo(_pr[0],_pr[1]); ctx.closePath();
  ctx.lineJoin='round'; ctx.strokeStyle='#0b0f0a'; ctx.lineWidth=5*_pmz; ctx.stroke();
  ctx.fillStyle=_pcol; ctx.fill();
  mapSeatBadge(_pmx,_pmy,_pmz,_pcol,seatHere());
  ctx.lineJoin='miter';
  ctx.lineWidth=1;
  try{ if(NET.on) netMapDots(ox,oy,sc,_pmz); }catch(_nmd){}   // v16.08: the party on the sector map (the net section)
  // v22.00, from the whole-game bug hunt of 2026-10-08 (K10): THE CONTROLLER MAP CURSOR IS DRAWN. Since v16.47 the right stick
  // moves a cursor across the open map and a tap of D-UP places the marker there, but nothing drew that cursor: the only pointer
  // on the map was the mouse arrow, wherever the real mouse sat, so a pad player placed his marker blind. A ring and a cross now
  // show where it will land, after the labels like the marker above. G.mapCur is set only by the right stick and is cleared when
  // the map shuts, so a mouse player never sees it.
  if(G.mapCur){
    var _mcx=ox+G.mapCur.x*sc, _mcy=oy+G.mapCur.y*sc;
    var _mcP=function(){
      ctx.beginPath(); ctx.arc(_mcx,_mcy,9*_pmz,0,6.2832);
      ctx.moveTo(_mcx-16*_pmz,_mcy); ctx.lineTo(_mcx-5*_pmz,_mcy); ctx.moveTo(_mcx+5*_pmz,_mcy); ctx.lineTo(_mcx+16*_pmz,_mcy);
      ctx.moveTo(_mcx,_mcy-16*_pmz); ctx.lineTo(_mcx,_mcy-5*_pmz); ctx.moveTo(_mcx,_mcy+5*_pmz); ctx.lineTo(_mcx,_mcy+16*_pmz);
      ctx.stroke();
    };
    ctx.strokeStyle='#120e0c'; ctx.lineWidth=4.5*_pmz; _mcP();   // an ink edge, so it never disappears into a gold block
    ctx.strokeStyle=UIC.tx_1; ctx.lineWidth=2*_pmz; _mcP();
    ctx.lineWidth=1;
  }
  };
  if(MAPLAST){ MAPLAST.push({fn:_pmDraw,m:ctx.getTransform(),ga:ctx.globalAlpha}); } else _pmDraw();
  // v31.xx (cw-mapstyle): SURVEYED moved into the footer of the card (mapCardChrome). The second grey line under it, what you walk stays on the map, is gone: the style guide has no explaining sentences on a screen (his Q8 lets the style guide shorten his explaining lines; the reason is in notes/ui/changes.md).
}
'@

SubRx @'
// The map under the opening prompt: the same projection with the room for the footer taken from the bottom (the top margin and the width are as ever).
var _mapFirstProj0=mapProj;
mapProj=function(){
  var r=_mapFirstProj0(), availH, sc;
  if(!mapFirstOn()) return r;
  availH=H-70-mapFirstFoot(); sc=Math.min(r.sc,availH/WORLD_H);
  if(!(sc>0)) return r;
  return {sc:sc,ox:(W-WORLD_W*sc)/2,oy:70+(availH-WORLD_H*sc)/2};
};
'@ @'
// v31.xx (cw-mapstyle): the map under the opening prompt used to be re-projected here to leave a footer; the card has its own footer row now (mapCard), the
// same for the opening map and the map the player opens himself, so there is nothing to wrap.

'@

SubRx @'
  mp=mapProj(); top=mp.oy+WORLD_H*mp.sc+3*z;
'@ @'
  var cd=mapCard();   // v31.xx (cw-mapstyle): the button sits in the footer row of the card, bottom right (the style guide's primary action)
'@

SubRx @'
    cy=Math.min(top+(H-top)/2,H-ph*z/2-6*z);
    ctx.translate(W/2,cy); ctx.scale(z,z);
'@ @'
    cy=cd.fy+(cd.y+cd.h-cd.fy)/2;
    ctx.translate(cd.x+cd.w-cd.p,cy); ctx.scale(z,z);
'@

SubRx @'
    x0=-pw/2; cx=x0+(pw-cw)/2; by=Math.round(a/2);
'@ @'
    x0=-pw; cx=x0+(pw-cw)/2; by=Math.round(a/2);
'@

SubRx @'
    if(e.button===0){
      var MP=mapProj();
'@ @'
    if(e.button===0){
      var _xcd=mapCard(), _xb=_xcd.xb;
      if(mouse.x>=_xb.x&&mouse.x<=_xb.x+_xb.w&&mouse.y>=_xb.y&&mouse.y<=_xb.y+_xb.h){ G.mapOpen=false; G.mapCur=null; blip('pick'); return; }   // v31.xx (cw-mapstyle): the X in the header closes the map (on the opening map the click above has started the raid already)
      var MP=mapProj();
'@

SubRx @'
function syncTopRight(){
  var el=document.getElementById('topright'); if(!el) return;

'@ @'
function syncTopRight(){
  var el=document.getElementById('topright'); if(!el) return;
  try{ var _mcOn=!!(typeof G==='object'&&G&&G.mapOpen&&!G.over&&state==='raid'); if(document.body.classList.contains('mapcard')!==_mcOn) document.body.classList.toggle('mapcard',_mcOn); }catch(_mcb){}   // v31.xx (cw-mapstyle): the corner readout steps aside while the map card is up (as it does for the other windows)

'@

SubRx @'
  try{ trColDraw(); }catch(_tc){}
'@ @'
  try{ if(!G.mapOpen) trColDraw(); }catch(_tc){}   // v31.xx (cw-mapstyle): the corner column is not drawn over the map card (its header has its own X and weather line); it comes back when the map shuts. The old note: 
'@

SubRx @'
  body:has(#partymodal.on) #topright, body:has(#termsmodal.on) #topright{ visibility:hidden; }
'@ @'
  body:has(#partymodal.on) #topright, body:has(#termsmodal.on) #topright{ visibility:hidden; }
  body.mapcard #topright{ visibility:hidden; }   /* v31.xx (cw-mapstyle): the sector map card has its own header; the corner readout is hidden under it */
'@

SubRx @'
    x=ox+g.x*sc; y=oy+g.y*sc; nm=netSeatName(g.seat)||'PILLAGER';
'@ @'
    x=ox+g.x*sc; y=oy+g.y*sc; nm=netSeatName(g.seat)||'PILLAGER'; var tc=g.dn?HUDC.danger:mapSeatColor(g.seat);   // v31.xx (cw-mapstyle): a teammate is drawn in his seat colour (lime, then the ally blue) with his number
'@

SubRx @'
    ctx.fillStyle=g.dn?HUDC.danger:HUDC.ally; ctx.beginPath(); ctx.arc(x,y,6*z,0,6.2832); ctx.fill();
'@ @'
    ctx.fillStyle=tc; ctx.beginPath(); ctx.arc(x,y,6*z,0,6.2832); ctx.fill(); mapSeatBadge(x,y,z,tc,g.seat);
'@

SubRx @'
    if(!g.dn){ ctx.strokeStyle='rgba(191,224,255,.85)'; ctx.lineWidth=2*z;
'@ @'
    if(!g.dn){ ctx.strokeStyle=tc; ctx.lineWidth=2*z;
'@

SubRx @'
    ctx.fillStyle=g.dn?HUDC.danger:HUDC.ally; ctx.fillText(nm,x,y-13*z);
'@ @'
    ctx.fillStyle=tc; ctx.fillText(nm,x,y-13*z);
'@

SubRx @'
var VER='31.40';
'@ @'
var VER='31.41';
'@

$pat = "(?m)^  now:'v31\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.41: The map you see first is a clean card with the sector name, a close button, readable zone names and every contract listed on the right. Check 31.41 fails on v31.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
