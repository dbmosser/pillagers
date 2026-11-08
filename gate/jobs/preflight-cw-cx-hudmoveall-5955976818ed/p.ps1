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

# EVERY RAID HUD PANEL MOVES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HUDBOX={},HUDDRAG=null,HUDRESIZE=null;
'@ @'
var HUDBOX={},HUDDRAG=null,HUDRESIZE=null;
// v28.xx (cw-cx-hudmoveall), HIS ORDER (10-28): "ideally every single Hud element would be grabbable/ movable".
// Offsets stay in screen pixels. Each window saves its own role, including the arcade sandbox.
var HUDLAYOUT={p:null,key:'',g:null};
function hudLayoutKey(){
  var arcade=typeof ARCADE==='object'&&ARCADE&&ARCADE.on;
  var second=(typeof NET==='object'&&NET&&(NET.same==='p2'||NET.seat===1))||(arcade&&ARCADE.role==='p2');
  return SKEY+':hudlayout:'+(arcade?'arcade:':'career:')+(second?'p2':'p1');
}
function hudLayoutLoad(){
  var key=hudLayoutKey(), raw, data;
  if(HUDLAYOUT.p===P&&HUDLAYOUT.key===key) return;
  try{ raw=localStorage.getItem(key); data=raw?JSON.parse(raw):null;
    if(data&&typeof data==='object'&&!Array.isArray(data)) P.hud=data;
    else P.hud=(!HUDLAYOUT.key&&key.slice(-2)==='p1')?JSON.parse(JSON.stringify(P.hud||{})):{};
  }catch(_hl){ P.hud=P.hud||{}; }
  HUDLAYOUT.p=P; HUDLAYOUT.key=key;
}
function hudLayoutSave(){
  try{ localStorage.setItem(hudLayoutKey(),JSON.stringify(P.hud||{})); }catch(_hs){}
  saveProfile();
}
function hudLayoutReset(){
  hudLayoutLoad(); P.hud={}; HUDDRAG=null; HUDRESIZE=null;
  HUDBOX={}; _legAnchorY=null; _legBase=null;
  hudLayoutSave();
}
function hudMoveFrame(){
  hudLayoutLoad();
  if(HUDLAYOUT.g!==G){ HUDBOX={}; HUDLAYOUT.g=G; }
  for(var k in HUDBOX) if(HUDBOX[k]&&HUDBOX[k].move) delete HUDBOX[k];
}
function hudMoveBox(id,b,tg){
  if(!b||!(b.w>0&&b.h>0)) return b;
  var o=hudOff(id);
  b.x+=o.dx; b.y+=o.dy;
  if(tg){ tg.x+=o.dx; tg.y+=o.dy; }
  HUDBOX[id]={x:b.x,y:b.y,w:b.w,h:b.h,tg:tg||null,move:1};
  return b;
}
function hudMoveStart(id){ var o=hudOff(id); ctx.save(); ctx.translate(o.dx,o.dy); }
function hudMoveEnd(id,b,tg){ ctx.restore(); return hudMoveBox(id,b,tg); }
function hudMoveHit(mx,my){
  var names=Object.keys(HUDBOX), i, k, b;
  for(i=names.length-1;i>=0;i--){ k=names[i]; b=HUDBOX[k];
    if(b&&b.move&&inRect(b,mx,my)&&!inRect(b.tg,mx,my)&&!(HUDZ[k]!==undefined&&!hudOff(k).c&&hudOnGrip(b,mx,my))) return k;
  }
  return null;
}
function hudMoveGrab(mx,my){
  var id=hudMoveHit(mx,my), o;
  if(!id) return false;
  o=hudOff(id); HUDDRAG={id:id,mx:mx,my:my,dx:o.dx,dy:o.dy}; mouse.down=false;
  return true;
}
function drawMinimap(){
  var tg, result;
  hudMoveStart('mmap');
  try{ result=drawMinimapBase(); }finally{
    tg=HUDBOX.mmap&&HUDBOX.mmap.tg;
    hudMoveEnd('mmap',MMAP.box,tg);
  }
  return result;
}
'@

SubRx @'
  if(HUDDRAG){ HUDDRAG=null; try{ saveProfile(); }catch(_e2){} }
'@ @'
  if(HUDDRAG){ HUDDRAG=null; try{ hudLayoutSave(); }catch(_e2){} }
'@

SubRx @'
  if(HUDRESIZE){ HUDRESIZE=null; try{ saveProfile(); }catch(_e3){} }
'@ @'
  if(HUDRESIZE){ HUDRESIZE=null; try{ hudLayoutSave(); }catch(_e3){} }
'@

SubRx @'
  if(e.button===0&&G&&!G.over&&G.trade) return;
'@ @'
  if(e.button===0&&G&&!G.over&&G.trade) return;
  // v28.xx (cw-cx-hudmoveall): panel grabs precede belt items and the trigger.
  if(e.button===0&&state==='raid'&&G&&!G.over&&!G.paused&&!G.bagOpen&&!G.mapOpen&&!G.forgeUI&&!G.wheel&&hudMoveGrab(mouse.x,mouse.y)) return;
'@

SubRx @'
function hudHit(mx,my){
'@ @'
function hudHit(mx,my){
  var moving=hudMoveHit(mx,my); if(moving) return {id:moving,part:'bar'};
'@

SubRx @'
  var h=(HB.tg&&HB.tg.h)?HB.tg.h:14;
'@ @'
  if(HB.move) return HB; // v28.xx (cw-cx-hudmoveall): the same handle is used by hit testing and the screen clamp.
  var h=(HB.tg&&HB.tg.h)?HB.tg.h:14;
'@

SubRx @'
  hudClampAll();
'@ @'
  hudLayoutLoad(); hudClampAll(); hudMoveFrame();
'@

SubRx @'
function drawMinimap(){
  var p=G&&G.player
'@ @'
function drawMinimapBase(){
  var p=G&&G.player
'@

SubRx @'
          saveProfile(); blip('pick');
'@ @'
          hudLayoutSave(); blip('pick');
'@

SubRx @'
if(!G||!G.sim){ try{ saveProfile(); }catch(_hc){} }
'@ @'
if(!G||!G.sim){ try{ hudLayoutSave(); }catch(_hc){} }
'@

SubRx @'
  if((G.arcade||G.career)&&!_tpDn) arcadeScoreHud(_tpM,_tpz);
'@ @'
  if((G.arcade||G.career)&&!_tpDn){
    hudMoveStart('score');
    try{ arcadeScoreHud(_tpM,_tpz); }finally{ hudMoveEnd('score',SCOREBOX.g===G?SCOREBOX:null); }
    if(SCOREBOX.g===G&&SCOREBOX.y<_tpH&&SCOREBOX.y+SCOREBOX.h>0) RAIL.scR=SCOREBOX.x+SCOREBOX.w;
    else RAIL.scR=_tpIn;
  }
'@

SubRx @'
  if(!(G.arcade||G.career)||!_noClk){
'@ @'
  hudMoveStart('clock');
  if(!(G.arcade||G.career)||!_noClk){
'@

SubRx @'
  // HIS NOTE, 2026-08-26: "can you make it point to the NEAREST extraction instead,
'@ @'
  // v28.xx (cw-cx-hudmoveall): weather travels with the clock; keep the clock obstacle in screen pixels.
  hudMoveEnd('clock',CLOCKBOX.g===G?{x:CLOCKBOX.x,y:CLOCKBOX.y,w:RAIL.skR-CLOCKBOX.x,h:CLOCKBOX.h}:null);
  if(CLOCKBOX.g===G){ CLOCKBOX.x+=hudOff('clock').dx; CLOCKBOX.y+=hudOff('clock').dy;
    if(CLOCKBOX.y<_tpH&&CLOCKBOX.y+CLOCKBOX.h>0){ RAIL.clL=CLOCKBOX.x; RAIL.clR=CLOCKBOX.x+CLOCKBOX.w; }
    else { RAIL.clL=W/2; RAIL.clR=W/2; }
  }
  // HIS NOTE, 2026-08-26: "can you make it point to the NEAREST extraction instead,
'@

SubRx @'
  if(_tgt){
    var za=
'@ @'
  if(_tgt){
    hudMoveStart('extract');
    var za=
'@

SubRx @'
  ctx.textAlign='center'; ctx.font=railF(TYPE.label);
'@ @'
  if(_tgt) hudMoveEnd('extract',{x:_cdX,y:_cdY,w:_cdW,h:_cdH});
  ctx.textAlign='center'; ctx.font=railF(TYPE.label);
'@

SubRx @'
for(k in HUDBOX){ B=HUDBOX[k]; if(B&&B.w>0&&B.h>0) L.push(B); }
'@ @'
for(k in HUDBOX){ B=HUDBOX[k]; if(k!=='extarrow'&&B&&B.w>0&&B.h>0) L.push(B); }
'@

SubRx @'
    cx=Math.round(cx); cy=Math.round(cy);
'@ @'
    var _eam=hudMoveBox('extarrow',{x:Math.round(cx)-bw/2-ar*2,y:Math.round(cy)-bh/2-ar*2,w:bw+ar*4,h:bh+ar*4});
    cx=_eam.x+bw/2+ar*2; cy=_eam.y+bh/2+ar*2;
'@

SubRx @'
    var _gSel=null, _gTs=[], _gti;
'@ @'
    if(!G.hubFloor){
      var _beltMove=hudMoveBox('belt',{x:hx,y:hy-LH(12),w:tw2,h:LH(10)});
      hx=_beltMove.x; hy=_beltMove.y+LH(12);
      ctx.save(); ctx.fillStyle=HUDC.dim; ctx.globalAlpha=0.55;
      ctx.fillRect(hx+tw2/2-LH(18),hy-LH(8),LH(36),Math.max(2,LH(2))); ctx.restore();
    }
    var _gSel=null, _gTs=[], _gti;
'@

SubRx @'
R0=airPlateAt(bw,bh,z); x=R0.x; y=R0.y;
'@ @'
R0=airPlateAt(bw,bh,z); R0=hudMoveBox('air',{x:R0.x,y:R0.y,w:bw,h:bh}); x=R0.x; y=R0.y;
'@

SubRx @'
x0=Math.round(W/2-tot/2); y0=Math.round(miny-24*z); EDGEBOX.chips={x:x0,y:y0,w:tot,h:Math.round(24*z)};
'@ @'
x0=Math.round(W/2-tot/2); y0=Math.round(miny-24*z); EDGEBOX.chips=hudMoveBox('chips',{x:x0,y:y0,w:tot,h:Math.round(24*z)}); x0=EDGEBOX.chips.x; y0=EDGEBOX.chips.y;
'@

SubRx @'
  R=feedRect(); FEEDBOX.x=R.x;
'@ @'
  R=feedRect(); R.x+=hudOff('feed').dx; R.y+=hudOff('feed').dy; FEEDBOX.x=R.x;
'@

SubRx @'
  } finally { ctx.restore(); ctx.globalAlpha=oa; }
  return n;
}
function msgTick
'@ @'
  } finally { ctx.restore(); ctx.globalAlpha=oa; }
  if(n>0){ var _fb=null, _fr, _fi;
    for(_fi=0;_fi<FEEDBOX.rows.length;_fi++){ _fr=FEEDBOX.rows[_fi];
      if(!_fb) _fb={x:_fr.x,y:_fr.y,w:_fr.w,h:_fr.h};
      else { var _fx=Math.min(_fb.x,_fr.x), _fy=Math.min(_fb.y,_fr.y); _fb.w=Math.max(_fb.x+_fb.w,_fr.x+_fr.w)-_fx; _fb.h=Math.max(_fb.y+_fb.h,_fr.y+_fr.h)-_fy; _fb.x=_fx; _fb.y=_fy; }
    }
    if(_fb){ HUDBOX.feed={x:_fb.x,y:_fb.y,w:_fb.w,h:_fb.h,move:1}; }
  }
  return n;
}
function msgTick
'@

SubRx @'
  ax=dn?W/2:RAIL.clL-gap; tx0=dn?ax-tw*k/2:ax-tw*k; bw=tw*k;
'@ @'
  ax=dn?W/2:RAIL.clL-gap; tx0=dn?ax-tw*k/2:ax-tw*k; bw=tw*k;
  var _am=hudMoveBox('danger',{x:tx0,y:y0,w:bw,h:hh});
  ax+=hudOff('danger').dx; tx0=_am.x; y0=_am.y; mid=y0+hh/2;
'@

SubRx @'
  NETTEAMBOX.n=0;
  if(typeof G==='undefined'
'@ @'
  var _teamOff=hudOff('team'); _tt+=_teamOff.dy;
  NETTEAMBOX.n=0;
  if(typeof G==='undefined'
'@

SubRx @'
NETTEAMBOX={n:n,x:hudIns(),y:_tt,w:Math.round(158*_thr),h:Math.round(n*_tst*_thr)};
'@ @'
NETTEAMBOX={n:n,x:hudIns()+_teamOff.dx,y:_tt,w:Math.round(158*_thr),h:Math.round(n*_tst*_thr)}; HUDBOX.team={x:NETTEAMBOX.x,y:_tt,w:NETTEAMBOX.w,h:NETTEAMBOX.h,move:1};
'@

SubRx @'
    x=hudIns()/_thr+4; var _hfMate=
'@ @'
    x=(hudIns()+_teamOff.dx)/_thr+4; var _hfMate=
'@

SubRx @'
function setSecMove(host){
'@ @'
function setSecMove(host){
  var resetHud=host.querySelector('#set_hudreset');
  if(resetHud) resetHud.onclick=function(){ hudLayoutReset(); blip('pick'); };
'@

SubRx @'
  _SEC['THE RAID']=diffRowHtml()
'@ @'
  // v28.xx (cw-cx-hudmoveall): one reset for every raid HUD offset, size and folded state.
  _SEC.DISPLAY=(_SEC.DISPLAY||'')+'<div class="row"><div style="flex:1"><b>hud layout</b></div><button id="set_hudreset">reset hud layout</button></div>';
  _SEC['THE RAID']=diffRowHtml()
'@

SubRx @'
var VER='37.65';
'@ @'
var VER='37.66';
'@

$pat = "(?m)^  now:'v37\.65:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.66: Drag the raid readouts, extraction, belt handle, air strike, teammates, feed, danger and power chips. The gun keeps its existing handle. Settings resets the whole layout; both windows keep separate saved layouts. Check 37.66 fails on v37.65',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
