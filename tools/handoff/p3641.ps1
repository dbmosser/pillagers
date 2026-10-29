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

# HUD CLEARS YOUR PILLAGER (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function drawHUD(){
'@ @'
// v28.xx (cw-cx-hudfade), HIS NOTE (2026-10-28): "if the player is partially obscured (or nearly obscured) by a hud element, it should go highly translucent (65%?) until the player is no longer obscured".
var HUDFADE={g:null,panels:{},active:null,now:0,live:false,bodies:[],layer:null,dom:[],scan:0};
var HUDFADE_PROPS=['fillStyle','strokeStyle','font','textAlign','textBaseline','direction','lineWidth','lineCap','lineJoin','miterLimit','lineDashOffset','globalAlpha','globalCompositeOperation','shadowBlur','shadowColor','shadowOffsetX','shadowOffsetY','imageSmoothingEnabled','imageSmoothingQuality','filter','fontKerning','fontStretch','fontVariantCaps','letterSpacing','wordSpacing','textRendering'];
function hudFadeNow(){ return performance.now()/1000; }
function hudFadeBody(p,build){
  var z=ZOOM(), s=w2s(p.x,0,p.y), k=figKS(build), rx=24*k[0]*z, ht=52*k[1]*z;
  return {x:s.x-rx,y:s.y-ht,w:rx*2,h:ht+10*z};
}
function hudFadeStep(s,b,people,scale,now){
  var margin=(s.near?32:24)*scale, hit=false, i, p, dt=Math.max(0,Math.min(0.25,now-s.at)), target;
  if(b&&b.w>0&&b.h>0) for(i=0;i<people.length;i++){
    p=people[i];
    if(p.x<b.x+b.w+margin&&p.x+p.w>b.x-margin&&p.y<b.y+b.h+margin&&p.y+p.h>b.y-margin){ hit=true; break; }
  }
  s.near=hit; s.at=now; target=hit?0.35:1;
  s.a=target<s.a?Math.max(target,s.a-0.65*dt/0.15):Math.min(target,s.a+0.65*dt/0.15);
  if(Math.abs(s.a-target)<0.00001) s.a=target;
  return s.a;
}
function hudFadeFrame(){
  var F=HUDFADE, i, p, list;
  F.now=hudFadeNow();
  F.live=!!(G&&G.player&&!G.over&&!G.sim&&!G.hubFloor&&!G.bagOpen&&!G.mapOpen&&!G.forgeUI&&state==='raid');
  if(F.g!==G){ hudFadeDomReset(); F.g=G; F.panels={}; F.scan=0; }
  F.bodies=[];
  if(!F.live){ hudFadeDomReset(); return; }
  F.bodies.push(hudFadeBody(G.player,cosWorn('build')));
  // v28.xx (cw-cx-hudfade): separate windows use their own pillager. A shared viewport's local players use the same camera transform.
  list=G.players;
  if(Array.isArray(list)) for(i=0;i<list.length;i++){ p=list[i]; if(p&&p!==G.player&&p.hp>0&&!p.gone) F.bodies.push(hudFadeBody(p,p.build)); }
  hudFadeDom();
}
function hudFadeCopy(from,to){
  var i,k,t=from.getTransform();
  for(i=0;i<HUDFADE_PROPS.length;i++){ k=HUDFADE_PROPS[i]; if(k in from) to[k]=from[k]; }
  to.setLineDash(from.getLineDash()); to.setTransform(t.a,t.b,t.c,t.d,t.e,t.f);
}
function hudFadeBegin(key){
  var F=HUDFADE,s,t,c;
  if(!F.live||F.active) return null;
  s=F.panels[key]; if(!s) s=F.panels[key]={a:1,near:false,at:F.now,box:null};
  hudFadeStep(s,s.box,F.bodies,hudRes(),F.now);
  t={key:key,s:s,base:ctx,box:null,capture:s.a<0.99999}; F.active=t;
  if(t.capture){
    if(!F.layer) F.layer=document.createElement('canvas');
    c=F.layer;
    if(c.width!==ctx.canvas.width||c.height!==ctx.canvas.height){ c.width=ctx.canvas.width; c.height=ctx.canvas.height; }
    t.ink=c.getContext('2d');
    t.ink.setTransform(1,0,0,1,0,0); t.ink.clearRect(0,0,c.width,c.height);
    hudFadeCopy(ctx,t.ink); ctx=t.ink;
  }
  return t;
}
function hudFadeBounds(b){
  var t=HUDFADE.active, a, x,y;
  if(!t||!b||!(b.w>0&&b.h>0)) return;
  a=t.box;
  if(!a){ t.box={x:b.x,y:b.y,w:b.w,h:b.h}; return; }
  x=Math.min(a.x,b.x); y=Math.min(a.y,b.y);
  a.w=Math.max(a.x+a.w,b.x+b.w)-x; a.h=Math.max(a.y+a.h,b.y+b.h)-y; a.x=x; a.y=y;
}
function hudFadeRect(x,y,w,h){
  var t,m,d=DPRH||1;
  if(!HUDFADE.active) return;
  t=ctx.getTransform();
  m={x:(t.a*x+t.c*y+t.e)/d,y:(t.b*x+t.d*y+t.f)/d,w:Math.abs(t.a*w/d)+Math.abs(t.c*h/d),h:Math.abs(t.b*w/d)+Math.abs(t.d*h/d)};
  hudFadeBounds(m);
}
function hudFadeEnd(t,b){
  var ink;
  if(!t) return;
  if(b) hudFadeBounds(b);
  t.s.box=t.box; t.s.drawnA=t.s.a; t.s.seen=HUDFADE.now;
  if(t.capture){
    ink=ctx; ctx=t.base;
    hudFadeCopy(ink,ctx);
    ctx.save();
    try{
      ctx.setTransform(1,0,0,1,0,0); ctx.globalAlpha=t.s.a; ctx.globalCompositeOperation='source-over';
      ctx.shadowBlur=0; ctx.shadowOffsetX=0; ctx.shadowOffsetY=0; ctx.shadowColor='rgba(0,0,0,0)'; ctx.filter='none';
      ctx.drawImage(ink.canvas,0,0);
    } finally { ctx.restore(); }
  }
  HUDFADE.active=null;
}
function hudFadeCall(key,fn,args,bounds){
  var t=hudFadeBegin(key), a=args?args.slice():[], i;
  if(t&&t.capture) for(i=0;i<a.length;i++) if(a[i]===t.base) a[i]=ctx;
  try{ return fn.apply(null,a); } finally { hudFadeEnd(t,bounds?bounds():null); }
}
function hudFadeDomReset(){
  var F=HUDFADE,i,e;
  for(i=0;i<F.dom.length;i++){ e=F.dom[i]; if(e.changed){ e.el.style.opacity=e.inline; e.changed=false; } }
}
function hudFadeDom(){
  var F=HUDFADE,els,i,j,e,c,b,s,a,old,entry,root=document.getElementById('root');
  if(!root) return;
  if(F.now>=F.scan){
    old=F.dom; F.dom=[]; F.scan=F.now+0.05;
    els=root.querySelectorAll(':scope > *,[data-hud-panel]');
    for(i=0;i<els.length;i++){
      e=els[i]; if(/^(CANVAS|SCRIPT|STYLE)$/.test(e.tagName)||e.matches('.screen,.modal,.pausebox,.outcome')||e.closest('.screen,.modal,.pausebox,.outcome')) continue;
      c=getComputedStyle(e); b=e.getBoundingClientRect();
      if((c.position==='fixed'||c.position==='absolute'||e.hasAttribute('data-hud-panel'))&&b.width>0&&b.height>0&&b.width<W*0.75&&b.height<H*0.75){
        entry=null;
        for(j=0;j<old.length;j++) if(old[j].el===e){entry=old[j];break;}
        F.dom.push(entry||{el:e,inline:e.style.opacity,base:parseFloat(c.opacity),changed:false,s:{a:1,near:false,at:F.now}});
      }
    }
    for(j=0;j<old.length;j++) if(F.dom.indexOf(old[j])<0&&old[j].changed) old[j].el.style.opacity=old[j].inline;
  }
  for(i=0;i<F.dom.length;i++){
    e=F.dom[i]; b=e.el.getBoundingClientRect(); c=getComputedStyle(e.el);
    s=(b.width>0&&b.height>0&&c.visibility!=='hidden'&&c.display!=='none')?{x:b.left,y:b.top,w:b.width,h:b.height}:null;
    a=hudFadeStep(e.s,s,F.bodies,hudRes(),F.now);
    if(a<1){ e.el.style.opacity=String(e.base*a); e.changed=true; }
    else if(e.changed){ e.el.style.opacity=e.inline; e.changed=false; }
  }
}
function drawHUD(){
  hudFadeFrame();
'@

SubRx @'
function hudPlate(x,y,w,h,accent,fill){
'@ @'
function hudPlate(x,y,w,h,accent,fill){
  hudFadeRect(x,y,w,h);
'@

SubRx @'
function hudPanel(x,y,w,h,a,plain){
'@ @'
function hudPanel(x,y,w,h,a,plain){
  hudFadeRect(x,y,w,h);
'@

SubRx @'
function trPlate(x,y,w,h){
'@ @'
function trPlate(x,y,w,h){
  hudFadeRect(x,y,w,h);
'@

SubRx @'
function statusPill(x0,cy,x1,h){
'@ @'
function statusPill(x0,cy,x1,h){
  hudFadeRect(x0,cy-h/2,Math.max(h,x1-x0),h);
'@

SubRx @'
function legChipDraw(s){
'@ @'
function legChipDraw(s){
  hudFadeRect(s.x,s.y,s.w,s.h);
'@

SubRx @'
  try{ drawBossBar(); }catch(_bb){}   // v17.45: his pick 21
'@ @'
  try{ hudFadeCall('boss',drawBossBar,[]); }catch(_bb){}   // v17.45: his pick 21
'@

SubRx @'
  try{ drawGiftLine(); }catch(_gl){}   // v17.52: an open trade offer stays on screen
'@ @'
  try{ hudFadeCall('gift',drawGiftLine,[]); }catch(_gl){}   // v17.52: an open trade offer stays on screen
'@

SubRx @'
  try{ drawLore(); }catch(_lr){}   // v22.xx (R39): the map story card
'@ @'
  try{ hudFadeCall('lore',drawLore,[]); }catch(_lr){}   // v22.xx (R39): the map story card
'@

SubRx @'
  try{ drawUseBar(); }catch(_ub){}   // v18.75, his note: the bandage, medkit and plate wind-ups on the HUD
'@ @'
  try{ hudFadeCall('use',drawUseBar,[]); }catch(_ub){}   // v18.75, his note: the bandage, medkit and plate wind-ups on the HUD
'@

SubRx @'
  try{ drawMinimap(); }catch(_mm){ MMAP.box=null; }   // v24.xx (minimap1): his "add minimap", top right, before CONDITIONS so it can start below it
'@ @'
  try{ hudFadeCall('minimap',drawMinimap,[],function(){return MMAP.box;}); }catch(_mm){ MMAP.box=null; }   // v24.xx (minimap1): his "add minimap", top right, before CONDITIONS so it can start below it
'@

SubRx @'
  try{ feedDraw(); }catch(_fdw){}   // v27.24 (feed1): the feed, bottom left (over the map too)
'@ @'
  try{ hudFadeCall('feed',feedDraw,[]); }catch(_fdw){}   // v27.24 (feed1): the feed, bottom left (over the map too)
'@

SubRx @'
  try{ drawHand(); }catch(_dhd){}   // v26.xx (wheel3): and the item in hand
'@ @'
  try{ hudFadeCall('hand',drawHand,[]); }catch(_dhd){}   // v26.xx (wheel3): and the item in hand
'@

SubRx @'
  try{ drawStatusIcons(); }catch(_sti){}   // v19.00, his note (2026-10-07): the status icons down the left, under the backpack, a trade and the map
'@ @'
  try{ hudFadeCall('status',drawStatusIcons,[]); }catch(_sti){}   // v19.00, his note (2026-10-07): the status icons down the left, under the backpack, a trade and the map
'@

SubRx @'
  EDGEBOX.feed=null; try{ if(NET.on) netFeedDraw(); }catch(_nfd){}   // v16.42: the kill feed
'@ @'
  EDGEBOX.feed=null; try{ if(NET.on) hudFadeCall('partyfeed',netFeedDraw,[]); }catch(_nfd){}   // v16.42: the kill feed
'@

SubRx @'
  try{ if(NET.same) netPadHud(); }catch(_nph){}   // v16.78: the controller paused word, in the window whose pad went quiet
'@ @'
  try{ if(NET.same) hudFadeCall('padnotice',netPadHud,[]); }catch(_nph){}   // v16.78: the controller paused word, in the window whose pad went quiet
'@

SubRx @'
  try{ if(!G.mapOpen) trColDraw(); }catch(_tc){}   // v31.xx (cw-mapstyle): the corner column is not drawn over the map card (its header has its own X and weather line); it comes back when the map shuts. The old note:    // v30.xx (cw-trcol): the wallet and notes rows of the corner column, over everything else the way the page text was
'@ @'
  try{ if(!G.mapOpen) hudFadeCall('notes',trColDraw,[]); }catch(_tc){}   // v31.xx (cw-mapstyle): the corner column is not drawn over the map card (its header has its own X and weather line); it comes back when the map shuts. The old note:    // v30.xx (cw-trcol): the wallet and notes rows of the corner column, over everything else the way the page text was
'@

SubRx @'
  RSTAT.on=0; if(keys['AltLeft']&&!G.mapOpen&&!G.bagOpen&&!G.trade){ try{ raidStatusDraw(); }catch(_rsd){} } RSTAT.rows=null;   // v25.xx (altstatus): hold ALT, the raid status over everything else
'@ @'
  RSTAT.on=0; if(keys['AltLeft']&&!G.mapOpen&&!G.bagOpen&&!G.trade){ try{ hudFadeCall('raidstatus',raidStatusDraw,[]); }catch(_rsd){} } RSTAT.rows=null;   // v25.xx (altstatus): hold ALT, the raid status over everything else
'@

SubRx @'
  if(G.arcade){ try{ arcadeHud(); }catch(_ahd){} }   // v23.23 (arcade4): the arcade layer, the EXTRACTED! banner
'@ @'
  if(G.arcade){ try{ hudFadeCall('arcadebanner',arcadeHud,[]); }catch(_ahd){} }   // v23.23 (arcade4): the arcade layer, the EXTRACTED! banner
'@

SubRx @'
  try{ styMedalDraw(ctx,p); }catch(_smd){}   // v27.38 (partyp1): the medal row at the left edge
'@ @'
  try{ hudFadeCall('medals',styMedalDraw,[ctx,p],function(){return STYBOX.n?STYBOX:null;}); }catch(_smd){}   // v27.38 (partyp1): the medal row at the left edge
'@

SubRx @'
  drawBelt();
  try{ drawWheel(); }catch(_dwh){}   // v26.xx (wheel2): the item wheel, over the belt
'@ @'
  hudFadeCall('belt',drawBelt,[],function(){var c=G.hotCells||[]; for(var i=0;i<c.length;i++) hudFadeBounds({x:c[i].x-4,y:c[i].y-4,w:c[i].w+8,h:c[i].h+8}); return null;});
  try{ drawWheel(); }catch(_dwh){}   // v26.xx (wheel2): the item wheel, over the belt
'@

SubRx @'
  ctx.save(); hudZoomIn('cond',W,0);
  (function(){
'@ @'
  hudFadeCall('conditions',function(){
  ctx.save(); hudZoomIn('cond',W,0);
  (function(){
'@

SubRx @'
  if(HUDBOX.cond) HUDBOX.cond=hudZoomRect('cond',W,0,HUDBOX.cond);
'@ @'
  if(HUDBOX.cond) HUDBOX.cond=hudZoomRect('cond',W,0,HUDBOX.cond);
  },[],function(){return HUDBOX.cond;});
'@

SubRx @'
  var _boB=hudOff('body');
  ctx.save(); ctx.translate(_boB.dx,_boB.dy);
'@ @'
  var _boB=hudOff('body');
  hudFadeCall('vitals',function(){
  ctx.save(); ctx.translate(_boB.dx,_boB.dy);
'@

SubRx @'
  ctx.restore();                          // v8.08: end of the corner scale
  ctx.restore();
'@ @'
  ctx.restore();                          // v8.08: end of the corner scale
  ctx.restore();
  },[],function(){return HUDBOX.body;});
'@

SubRx @'
  var _boG=hudOff('gear');
  ctx.save(); ctx.translate(_boG.dx,_boG.dy);
'@ @'
  var _boG=hudOff('gear');
  hudFadeCall('gun',function(){
  ctx.save(); ctx.translate(_boG.dx,_boG.dy);
'@

SubRx @'
ctx.restore();
  // v8.43, audit: RIGHT ALIGNED, on the line itself.
'@ @'
ctx.restore();
  },[],function(){return GUNCARD.g===G?GUNCARD:HUDBOX.gear;});
  // v8.43, audit: RIGHT ALIGNED, on the line itself.
'@

SubRx @'
    hudPlate(cx-cw,top,cw*2,cBot-top,null,HUDC.plate);
'@ @'
    hudFadeCall('clock',function(){
    hudPlate(cx-cw,top,cw*2,cBot-top,null,HUDC.plate);
'@

SubRx @'
    apo=(fin&&ct>0)?clockPopIn(cx,clockY-ch*.3,G.timeLeft):false;ctx.font=fc;ctx.fillStyle=fin?'#ff5a4a':'#cdd6dd';hudText(Math.floor(ct/60)+':'+(ct%60<10?'0':'')+(ct%60),cx,clockY);if(apo)ctx.restore();
'@ @'
    apo=(fin&&ct>0)?clockPopIn(cx,clockY-ch*.3,G.timeLeft):false;ctx.font=fc;ctx.fillStyle=fin?'#ff5a4a':'#cdd6dd';hudText(Math.floor(ct/60)+':'+(ct%60<10?'0':'')+(ct%60),cx,clockY);if(apo)ctx.restore();
    });
'@

SubRx @'
  hudPlate(cx-pw,top,pw*2,bot-top,null,rushUI?'rgba(17,19,21,.96)':HUDC.plate);   // v28.xx (cw-cx-rushlayout): score labels stay legible over a wall or rain.
'@ @'
  hudFadeCall('score',function(){
  hudPlate(cx-pw,top,pw*2,bot-top,null,rushUI?'rgba(17,19,21,.96)':HUDC.plate);   // v28.xx (cw-cx-rushlayout): score labels stay legible over a wall or rain.
'@

SubRx @'
  if(!solo){gx=Math.round(cx+w/2+24*z);ctx.font=fs;ctx.textAlign='left';ctx.fillStyle=UIC.tx_2;hudText('YOU '+arcadeCr(mine),gx,Math.round(scoreY-lh*.5));hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate),gx,Math.round(scoreY+lh*.75));}
'@ @'
  if(!solo){gx=Math.round(cx+w/2+24*z);ctx.font=fs;ctx.textAlign='left';ctx.fillStyle=UIC.tx_2;hudText('YOU '+arcadeCr(mine),gx,Math.round(scoreY-lh*.5));hudText((ARCADE.role==='p2'?'P1 ':'P2 ')+arcadeCr(mate),gx,Math.round(scoreY+lh*.75));}
  });
'@

SubRx @'
    if(_f1L) LEGFULL=null; drawLegend(G.legendOn===2&&!HOL.c?_fz:1,!!_f1L); if(_f1L&&LEGFULL) LEGSIDE={x:_f1L.x+(LEGFULL.x-6)*_fz,y:_f1L.b+(LEGFULL.y-H)*_fz,w:LEGFULL.w*_fz,h:LEGFULL.h*_fz}; // v28.xx (cw-cx-foldedhint): the full-list fit scale belongs only to the open full list.
'@ @'
    if(_f1L) LEGFULL=null; hudFadeCall('controls',drawLegend,[G.legendOn===2&&!HOL.c?_fz:1,!!_f1L]); if(_f1L&&LEGFULL) LEGSIDE={x:_f1L.x+(LEGFULL.x-6)*_fz,y:_f1L.b+(LEGFULL.y-H)*_fz,w:LEGFULL.w*_fz,h:LEGFULL.h*_fz}; // v28.xx (cw-cx-foldedhint): the full-list fit scale belongs only to the open full list.
'@

SubRx @'
    drawRaiderBoard();
'@ @'
    hudFadeCall('valueatrisk',drawRaiderBoard,[]);
'@

SubRx @'
    if(_alL&&G){ try{ alertDraw(_alL); }catch(_ad){} }   // v22.13 (R08): the alert lane, at the top of the band
'@ @'
    if(_alL&&G){ try{ hudFadeCall('alert',alertDraw,[_alL]); }catch(_ad){} }   // v22.13 (R08): the alert lane, at the top of the band
'@

SubRx @'
    else if(_loc&&G){ try{ locDraw(_loc); }catch(_ld){} }   // v22.xx (R34): the location tag in the free alert slot
'@ @'
    else if(_loc&&G){ try{ hudFadeCall('location',locDraw,[_loc]); }catch(_ld){} }   // v22.xx (R34): the location tag in the free alert slot
'@

SubRx @'
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(x-4,y-15,w+8,36);
'@ @'
    var _hfMate=hudFadeBegin('partner-'+g.seat);
    try{
    hudFadeRect(x-4,y-15,w+8,36);
    ctx.fillStyle='rgba(6,9,13,.62)'; ctx.fillRect(x-4,y-15,w+8,36);
'@

SubRx @'
    ctx.restore();   // v19.07: the row's own scale ends before the edge arrow, which works in screen space
'@ @'
    } finally { hudFadeEnd(_hfMate); }
    ctx.restore();   // v19.07: the row's own scale ends before the edge arrow, which works in screen space
'@

SubRx @'
    G.airBox={x:x,y:y,w:bw,h:bh};
'@ @'
    G.airBox={x:x,y:y,w:bw,h:bh};
    var _hfAir=hudFadeBegin('air'); c=ctx;
    try{
'@

SubRx @'
    else { c.textAlign='right'; c.fillStyle=UIC.tx_1; hudText(Math.floor(fl*100)+'%',x+bw-U(10),y+Math.round(bh*0.64)); }
'@ @'
    else { c.textAlign='right'; c.fillStyle=UIC.tx_1; hudText(Math.floor(fl*100)+'%',x+bw-U(10),y+Math.round(bh*0.64)); }
    } finally { hudFadeEnd(_hfAir,G.airBox); c=ctx; }
'@

SubRx @'
  if(ids.length){
    c.font=hudFS(TYPE.micro); c.textAlign='left'; tot=-8*z;
'@ @'
  if(ids.length){
    var _hfChips=hudFadeBegin('powerchips'); c=ctx;
    try{
    c.font=hudFS(TYPE.micro); c.textAlign='left'; tot=-8*z;
'@

SubRx @'
      x0+=Math.round(ew+8*z);
    }
  }
  c.restore();
'@ @'
      x0+=Math.round(ew+8*z);
    }
    } finally { hudFadeEnd(_hfChips,EDGEBOX.chips); c=ctx; }
  }
  c.restore();
'@

SubRx @'
  if(extBandOn(p)){   // v35.xx (cw-clockcard): within 250 m
'@ @'
  hudFadeCall('extractionband',function(){
  if(extBandOn(p)){   // v35.xx (cw-clockcard): within 250 m
'@

SubRx @'
  // HIS NOTE, v3.58: "THE SEAL NEEDS some sort of visual indicator to tell you
'@ @'
  });
  // HIS NOTE, v3.58: "THE SEAL NEEDS some sort of visual indicator to tell you
'@

SubRx @'
    ctx.fillStyle='rgba(60,8,5,.30)'; ctx.fillRect(0,0,W,H);   // v34.40 (cw-downedcard3), critic on screen 34 (P1 'the heavy red wash tints every HUD colour'): the downed wash is 30 percent, was 45, so the HUD keeps its contrast
'@ @'
    ctx.fillStyle='rgba(60,8,5,.30)'; ctx.fillRect(0,0,W,H);   // v34.40 (cw-downedcard3), critic on screen 34 (P1 'the heavy red wash tints every HUD colour'): the downed wash is 30 percent, was 45, so the HUD keeps its contrast
    hudFadeCall('downed',function(){
'@

SubRx @'
    ctx.restore();
  }
  // HIS NOTE: "a middle-of-the-screen HOLD E TO EXTRACT once its open, even if
'@ @'
    ctx.restore();
    });
  }
  // HIS NOTE: "a middle-of-the-screen HOLD E TO EXTRACT once its open, even if
'@

SubRx @'
  ctx.fillStyle='rgba(6,9,13,.84)'; ctx.fillRect(cx-bw/2,y-LH(56),bw,bh);
'@ @'
  hudFadeRect(cx-bw/2,y-LH(56),bw,bh);
  ctx.fillStyle='rgba(6,9,13,.84)'; ctx.fillRect(cx-bw/2,y-LH(56),bw,bh);
'@

SubRx @'
var VER='36.40';
'@ @'
var VER='36.41';
'@

$pat = "(?m)^  now:'v36\.40:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.41: hud panels go see-through over your pillager Check 36.41 fails on v36.40',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
