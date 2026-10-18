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

# the opening map prompt is one primary button and the map leaves it room (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function mapFirstPrompt(){
  var g=G, r;
  if(!g||!g.mapFirst) return null;
  if(g.mapFirstMe){ r=mapFirstPeers(); return {k:'',a:'',t:'waiting for '+mapFirstWho(r.who),wait:1}; }
  if(padOn()) return {k:String(padB('A')),a:'',t:'to start',wait:0};
  return {k:String(keyLabel('KeyE','E')),a:'or click ',t:'to start',wait:0};
}
// Drawn after the map, in the band under it, at the screen's own scale (hudRes); the plate is as tall as the band lets it be.
function mapFirstDraw(){
  var g=G, pr=mapFirstPrompt(), z, mp, top, cy, fpx, a, kh, kslot=0, gap=0, tw, dw=0, pw, ph, x0, by, tx, pl, i, T;
  if(!pr||!g||g.over||!(W>0&&H>0)) return false;
  z=(typeof hudRes==='function')?hudRes():1; T=+g.mapFirstT||0;
  mp=mapProj(); top=mp.oy+WORLD_H*mp.sc+3*z;
  ctx.save();
  try{
    ph=LH(32);
    cy=Math.min(top+(H-top)/2,H-ph*z/2-6*z);
    ctx.translate(W/2,cy); ctx.scale(z,z);
    ctx.font=FS(TYPE.head); ctx.textAlign='left'; ctx.textBaseline='alphabetic';
    fpx=parseFloat(((/([\d.]+)px/).exec(ctx.font)||[0,20])[1])||20; a=Math.round(fpx*0.7);
    kh=a+LH(7);
    tw=hudRawW(pr.a+pr.t);
    if(pr.k){ kslot=Math.max(kh+LH(2),hudRawW(pr.k)+LH(12)); gap=LH(10); }
    if(pr.wait) dw=LH(34);
    pw=LH(16)+kslot+gap+tw+dw+LH(16);
    x0=-pw/2; by=Math.round(a/2);
    pl=0.9+0.1*Math.sin(T*3.4);
    ctx.globalAlpha=pl;
    hudPlate(x0,-ph/2,pw,ph,pr.wait?HUDC.extract:UIC.acc,'rgba(14,17,20,.96)');
    ctx.strokeStyle=UIC.ui_line_hi; ctx.lineWidth=1;
    ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(x0,-ph/2,pw,ph,Math.max(0,Math.min(LH(4),ph/2))); else ctx.rect(x0,-ph/2,pw,ph); ctx.stroke();
    if(pr.k) hudKey(pr.k,x0+LH(16),by,a,kslot);
    tx=x0+LH(16)+kslot+gap;
    ctx.fillStyle=HUDC.text; ctx.textAlign='left'; ctx.fillText(pr.a+pr.t,tx,by);
    if(pr.wait){
      ctx.fillStyle=HUDC.extract;
      for(i=0;i<3;i++){ ctx.globalAlpha=pl*(0.25+0.75*Math.max(0,Math.sin(T*5-i*0.9))); ctx.beginPath(); ctx.arc(tx+tw+LH(12)+i*LH(9),by-a*0.35,LH(2.4),0,6.2832); ctx.fill(); }
    }
  } finally { ctx.restore(); }
  return true;
}
var _mapFirstSync0=syncPause;
syncPause=function(){ _mapFirstSync0(); if(mapFirstOn()) G.paused=true; };
var _mapFirstDraw0=drawMapOverlay;
drawMapOverlay=function(){ _mapFirstDraw0(); try{ if(G&&G.mapFirst&&!G.over) mapFirstDraw(); }catch(_mfd){} };

'@ @'
// v31.xx (cw-mapfirst2), from the critic on the opening map: the prompt is the one primary button of the screen, as the style guide has it (56 high, lime fill,
// ink text at the callout size, min width 200, radius 4), with the key or the pad button as a dark chip at its right: click to start with E or the mouse, start
// with A on a pad. After the press it is the same size in the panel colours, waiting for the other window. The map gives up a footer for it (mapFirstFoot) so
// at 4K the button sits under the map frame and not on it; the map the player opens himself is untouched.
function mapFirstFoot(){ var z=(typeof hudRes==='function')?hudRes():1; return Math.max(70,Math.round((LH(43)+18)*z)); }
// The one prompt: the key or the pad button of the last device used, then the words; after the press, who it waits for.
function mapFirstPrompt(){
  var g=G, r;
  if(!g||!g.mapFirst) return null;
  if(g.mapFirstMe){ r=mapFirstPeers(); return {k:'',t:'waiting for '+mapFirstWho(r.who),wait:1}; }
  if(padOn()) return {k:String(padB('A')),t:'start',wait:0};
  return {k:String(keyLabel('KeyE','E')),t:'click to start',wait:0};
}
// Drawn after the map, in the footer under it, at the screen's own scale (hudRes).
function mapFirstDraw(){
  var g=G, pr=mapFirstPrompt(), z, mp, top, cy, fpx, a, kh, kslot=0, gap=0, tw, dw=0, cw, pw, ph, x0, cx, by, pl, i, T, ready, pc, kx, ky;
  if(!pr||!g||g.over||!(W>0&&H>0)) return false;
  z=(typeof hudRes==='function')?hudRes():1; T=+g.mapFirstT||0; ready=!pr.wait;
  mp=mapProj(); top=mp.oy+WORLD_H*mp.sc+3*z;
  ctx.save();
  try{
    ph=LH(43);
    cy=Math.min(top+(H-top)/2,H-ph*z/2-6*z);
    ctx.translate(W/2,cy); ctx.scale(z,z);
    ctx.font=FS(TYPE.head); ctx.textAlign='left'; ctx.textBaseline='alphabetic';
    fpx=parseFloat(((/([\d.]+)px/).exec(ctx.font)||[0,20])[1])||20; a=Math.round(fpx*0.7);
    kh=a+LH(7);
    tw=hudRawW(pr.t);
    if(pr.k){ kslot=Math.max(kh,hudRawW(pr.k)+LH(12)); gap=LH(14); }
    if(pr.wait) dw=LH(36);
    cw=tw+dw+gap+kslot;
    pw=Math.max(LH(154),cw+LH(48));
    x0=-pw/2; cx=x0+(pw-cw)/2; by=Math.round(a/2);
    pl=0.92+0.08*Math.sin(T*3.4);
    ctx.globalAlpha=pl;
    if(ready) hudPlate(x0,-ph/2,pw,ph,null,UIC.acc);
    else {
      hudPlate(x0,-ph/2,pw,ph,HUDC.extract,'rgba(14,17,20,.96)');
      ctx.strokeStyle=UIC.ui_line_hi; ctx.lineWidth=1;
      ctx.beginPath(); if(ctx.roundRect) ctx.roundRect(x0,-ph/2,pw,ph,Math.max(0,Math.min(LH(4),ph/2))); else ctx.rect(x0,-ph/2,pw,ph); ctx.stroke();
    }
    ctx.fillStyle=ready?UIC.acc_ink:HUDC.text; ctx.textAlign='left'; ctx.fillText(pr.t,cx,by);
    if(pr.k){
      kx=cx+tw+gap; ky=by-a-LH(3.5);
      pc=(typeof HUDKEY_PAD==='object'&&HUDKEY_PAD&&padOn())?HUDKEY_PAD[pr.k]:null;
      if(pc){ ctx.fillStyle=UIC.acc_ink; ctx.beginPath(); ctx.arc(kx+kslot/2,ky+kh/2,kh/2,0,6.2832); ctx.fill(); ctx.fillStyle=pc; ctx.textAlign='center'; ctx.fillText(pr.k,kx+kslot/2,by-LH(0.5)); ctx.textAlign='left'; }
      else hudKey(pr.k,kx,by,a,kslot,{fill:UIC.acc_ink,ink:UIC.acc});
    }
    if(pr.wait){
      ctx.fillStyle=HUDC.extract;
      for(i=0;i<3;i++){ ctx.globalAlpha=pl*(0.25+0.75*Math.max(0,Math.sin(T*5-i*0.9))); ctx.beginPath(); ctx.arc(cx+tw+LH(12)+i*LH(9),by-a*0.35,LH(2.4),0,6.2832); ctx.fill(); }
    }
  } finally { ctx.restore(); }
  return true;
}
var _mapFirstSync0=syncPause;
syncPause=function(){ _mapFirstSync0(); if(mapFirstOn()) G.paused=true; };
var _mapFirstDraw0=drawMapOverlay;
drawMapOverlay=function(){ _mapFirstDraw0(); try{ if(G&&G.mapFirst&&!G.over) mapFirstDraw(); }catch(_mfd){} };
// The map under the opening prompt: the same projection with the room for the footer taken from the bottom (the top margin and the width are as ever).
var _mapFirstProj0=mapProj;
mapProj=function(){
  var r=_mapFirstProj0(), availH, sc;
  if(!mapFirstOn()) return r;
  availH=H-70-mapFirstFoot(); sc=Math.min(r.sc,availH/WORLD_H);
  if(!(sc>0)) return r;
  return {sc:sc,ox:(W-WORLD_W*sc)/2,oy:70+(availH-WORLD_H*sc)/2};
};
'@

SubRx @'
var VER='31.22';
'@ @'
var VER='31.23';
'@

$pat = "(?m)^  now:'v31\.22:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v31.23: The opening map has one start button. Click it, press E or press A. After you press it says waiting for your partner. Check 31.23 fails on v31.22',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
