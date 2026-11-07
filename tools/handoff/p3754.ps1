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

# OUT FIRST WATCHES AND PINGS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function netPingMake(){
'@ @'
// v28.xx (cw-cx-outwatch), his 2.25 b: "Their partner's view, live, with a small line saying they are waiting"; g-54: "Yes, pings only".
function netWatchOn(){
  return !!(typeof NET==='object'&&NET&&NET.on&&typeof G!=='undefined'&&G&&!G.sim&&!G.hubFloor&&G.player&&
    ((NET.role==='host'&&NET.specG===G)||(G.arcade&&!G.over&&G.player.specOut&&(G.arcX||(typeof ARCADE==='object'&&ARCADE&&ARCADE.xOut==='h')))));
}
function netWatchBody(){
  if(!netWatchOn()) return null;
  var i, u;
  for(i=0;i<NET.up.length;i++){
    u=NET.up[i];
    if(!netUpShown(u)||netUpGone(u)||netUpHid(u)) continue;
    if(!isFinite(u.tx)||!isFinite(u.ty)) continue;
    return {x:isFinite(u.x)?u.x:u.tx,y:isFinite(u.y)?u.y:u.ty,face:isFinite(u.f)?u.f:(u.tf||0)};
  }
  return null;
}
function netWatchHud(){
  ctx.save();
  try{
    netPingDraw();
    var y=H-LH(38), label='waiting', w;
    ctx.font=hudFS(TYPE.label); ctx.textAlign='center'; ctx.textBaseline='middle';
    w=ctx.measureText(label).width+LH(32);
    ctx.fillStyle='rgba(11,12,13,.88)'; ctx.fillRect((W-w)/2,y-LH(18),w,LH(36));
    ctx.fillStyle=HUDC.ally; ctx.fillText(label,W/2,y);
  }finally{ ctx.restore(); }
}
function netWatchPad(gp){
  var b=gp.buttons||[], a=padRaidAxes(gp.axes||[]), rs=padStick(a[2]||0,a[3]||0), map=padMapArr(), pb=b[map[12]], down=!!(pb&&(pb.pressed||pb.value>0.5));
  padRelease(); mouse.down=false; PAD.mx=0; PAD.my=0; PAD.firing=false; PAD.afire=0; PAD.adsing=false; PAD.aiming=false;
  if(rs.x||rs.y){ PAD.aimA=Math.atan2(rs.y,rs.x); var z=ZOOM(), reach=200; padCursorPut(W/2,H/2,Math.cos(PAD.aimA)*reach*z,Math.sin(PAD.aimA)*reach*z); }
  if(down&&!PAD.watchPing) netPingMake();
  PAD.watchPing=down;
  PAD.prev=b.map(function(q){ return !!(q&&(q.pressed||q.value>0.5)); });
}
function netPingMake(){
'@

SubRx @'
function adsCameraFrame(dt){
'@ @'
function adsCameraFrame(dt){
  // v28.xx (cw-cx-outwatch): render and aim share this camera; the extracted body stays untouched in the simulation.
  var watch=netWatchBody();
  if(watch){ G.adsZ=1; var wz=ZOOM(); return {x:camClamp(watch.x-W/(2*wz),W/wz,WORLD_W),y:camClamp(watch.y-H/(2*wz),H/wz,WORLD_H),z:wz,pad:false}; }
'@

SubRx @'
  var p=G.player,i,j;
  gfxpBegin();
'@ @'
  var p=G.player, eye=netWatchBody()||p,i,j; // v28.xx (cw-cx-outwatch): only the render eye follows the partner.
  gfxpBegin();
'@

SubRx @'
    ev.seen=(evc>=1)?canSee(p.x,p.y,p.face,ev.x,ev.y,G.vseg)
'@ @'
    ev.seen=(evc>=1)?canSee(eye.x,eye.y,eye.face,ev.x,ev.y,G.vseg)
'@

SubRx @'
                    :canSee(p.x,p.y,p.face,ev.x,ev.y,G.vseg,VF()*evc,undefined,AMBR()*evc);
'@ @'
                    :canSee(eye.x,eye.y,eye.face,ev.x,ev.y,G.vseg,VF()*evc,undefined,AMBR()*evc);
'@

SubRx @'
    if(!canSee(p.x,p.y,p.face,_fp.x,_fp.y,G.vseg)) continue;
'@ @'
    if(!canSee(eye.x,eye.y,eye.face,_fp.x,_fp.y,G.vseg)) continue;
'@

SubRx @'
    if((dc.print||dc.ripple)&&!dc.mine&&!canSee(p.x,p.y,p.face,dc.x,dc.y,G.vseg)) continue;
'@ @'
    if((dc.print||dc.ripple)&&!dc.mine&&!canSee(eye.x,eye.y,eye.face,dc.x,dc.y,G.vseg)) continue;
'@

SubRx @'
    // frame, so a thing that ducks behind cover gets its ring back.
    if(canSee(p.x,p.y,p.face,pn.x,pn.y,G.vseg)) continue;
    // Distance encoding: a faint small mark is far off, a large bright one is
'@ @'
    // frame, so a thing that ducks behind cover gets its ring back.
    if(canSee(eye.x,eye.y,eye.face,pn.x,pn.y,G.vseg)) continue;
    // Distance encoding: a faint small mark is far off, a large bright one is
'@

SubRx @'
    if(!canSee(p.x,p.y,p.face,CW.x,CW.y,G.vseg)) continue;
'@ @'
    if(!canSee(eye.x,eye.y,eye.face,CW.x,CW.y,G.vseg)) continue;
'@

SubRx @'
  var pol2=buildVisPoly(p.x,p.y,p.face,G.vseg);
'@ @'
  var pol2=buildVisPoly(eye.x,eye.y,eye.face,G.vseg);
'@

SubRx @'
  var psx=p.x,psy=p.y;
'@ @'
  var psx=eye.x,psy=eye.y;
'@

SubRx @'
      if(canSee(p.x,p.y,p.face,pn.x,pn.y,G.vseg)) continue;
'@ @'
      if(canSee(eye.x,eye.y,eye.face,pn.x,pn.y,G.vseg)) continue;
'@

SubRx @'
  var p=G.player, dx, dy, d, k, i, e, R=VF(), A=Math.max(70,AMBR()), r0=(r>0)?+r:0;
'@ @'
  var p=netWatchBody()||G.player, dx, dy, d, k, i, e, R=VF(), A=Math.max(70,AMBR()), r0=(r>0)?+r:0; // v28.xx (cw-cx-outwatch): live effects use the watched sight cone.
'@

SubRx @'
  if(!ascOut(p)) DR.push(
'@ @'
  if(!ascOut(p)&&!netWatchOn()) DR.push(
'@

SubRx @'
  try{ if(!G.sim) aimMarks(p); }
'@ @'
  try{ if(!G.sim&&!netWatchOn()) aimMarks(p); }
'@

SubRx @'
  var _pcs=msPlayerScreen(); padClaimDraw(_pcs.x,_pcs.y);
'@ @'
  if(netWatchOn()){ netWatchHud(); return; } // v28.xx (cw-cx-outwatch): a waiting view has no own-body HUD or run-over card.
  var _pcs=msPlayerScreen(); padClaimDraw(_pcs.x,_pcs.y);
'@

SubRx @'
function arcadeAttShow(){
'@ @'
function arcadeAttShow(){
  if(netWatchOn()){ if(ATT.on||ATT.pending||ATT.loading) attStop(); return false; } // v28.xx (cw-cx-outwatch): never cover a live watch with the attract loop.
'@

SubRx @'
  if(G&&G.arcade&&!arcadeBenched()){ if(ATT.on) attStop(); return; }
'@ @'
  if(G&&G.arcade&&(!arcadeBenched()||netWatchOn())){ if(ATT.on) attStop(); return; }
'@

SubRx @'
    try{ arcadeAttShow(); }catch(_xa){}
'@ @'
    try{ attStop(); }catch(_xa){} // v28.xx (cw-cx-outwatch): host watches player 2 until both are out.
'@

SubRx @'
  if(easyKey(e)) return true;
'@ @'
  // v28.xx (cw-cx-outwatch): consume every play action except ping; an out player can never unbench through input.
  if(netWatchOn()){
    var wc=keyRemap(String(e.code||'')), wt=String(e.type||'');
    if((wt==='keydown'||wt==='keyup')&&(wc==='KeyN'||wc==='Mouse1')) return false;
    if((wt==='mousedown'||wt==='mouseup')&&e.button===1) return false;
    try{ e.preventDefault(); e.stopImmediatePropagation(); }catch(_we){} return true;
  }
  if(easyKey(e)) return true;
'@

SubRx @'
function raidKey(code,repeat,ev){
'@ @'
function raidKey(code,repeat,ev){
  // v28.xx (cw-cx-outwatch): the career spectator also has only ping input, with no latched movement or search keys.
  if(netWatchOn()){ keys[code]=false; if(ev) ev.preventDefault(); if(!repeat&&(code==='KeyN'||code==='Mouse1')) netPingMake(); return; }
'@

SubRx @'
  e=keyRemapEvent(e);
'@ @'
  e=keyRemapEvent(e);
  if(netWatchOn()){ raidKey(e.code,e.repeat,e); return; } // v28.xx (cw-cx-outwatch): watch keys never open a menu or change a world dial.
'@

SubRx @'
typeof G!=='undefined'&&G&&!G.over&&state==='raid'
'@ @'
typeof G!=='undefined'&&G&&(!G.over||netWatchOn())&&state==='raid'
'@

SubRx @'
cv.addEventListener('mousedown',function(e){
'@ @'
cv.addEventListener('mousedown',function(e){
  if(netWatchOn()){ mouse.down=false; return; } // v28.xx (cw-cx-outwatch): clicks cannot fire or search while watching.
'@

SubRx @'
  indevPadTick(gp);
'@ @'
  if(netWatchOn()){ netWatchPad(gp); return; } // v28.xx (cw-cx-outwatch): stick aim and ping only, before movement, auto-fire and menu actions.
  PAD.watchPing=false; PAD.watchAim=0;
  indevPadTick(gp);
'@

SubRx @'
  if(typeof G==='undefined'||!G||G.over||!G.player||G.hubFloor||G.sim||G.paused||G.bagOpen||G.trade||G.forgeUI||G.player.downed||G.player.dying||(NET.on&&!NET.upSeed)) return null;
'@ @'
  if(typeof G==='undefined'||!G||(G.over&&!netWatchOn())||!G.player||G.hubFloor||G.sim||G.paused||G.bagOpen||G.trade||G.forgeUI||(!netWatchOn()&&(G.player.downed||G.player.dying))||(NET.on&&!NET.upSeed)) return null;
'@

SubRx @'
  if(G.mapOpen) return netWpFromMap();
'@ @'
  if(G.mapOpen&&!netWatchOn()) return netWpFromMap(); // v28.xx (cw-cx-outwatch): watch aim always projects through the world camera.
'@

SubRx @'
  document.getElementById('outcome').classList.add('on');
'@ @'
  if(!netWatchOn()) document.getElementById('outcome').classList.add('on'); // v28.xx (cw-cx-outwatch): reveal the settled card after the partner is out.
'@

SubRx @'
  NET.status='party back \u00b7 raid over';
'@ @'
  if(keep===S&&state==='raid'&&S&&S.over) document.getElementById('outcome').classList.add('on'); // v28.xx (cw-cx-outwatch): settlement was already done once.
  NET.status='party back \u00b7 raid over';
'@

SubRx @'
var VER='37.53';
'@ @'
var VER='37.54';
'@

$pat = "(?m)^  now:'v37\.53:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v37.54: Extracted demo players follow the partner with a small waiting line. N, middle mouse and the pad ping still mark targets, including double-tap danger, without rejoining or using the map. The retained career host can also watch and ping until the party finishes. Check 37.54 fails on v37.53',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
