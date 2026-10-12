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

# GRAPHICS HOOKS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HID={w:null,lastRaf:0,fromWorker:0,ticks:0};
'@ @'
// v23.xx (gfx2), HIS ORDER 2026-10-12 ("add ALL of this stuff", the graphics program): THE HOOK SCAFFOLD AND THE STORE REGISTRY.
// Every later graphics build hangs off a named hook here instead of cutting new lines into render2D and the sim, so the frame keeps
// one shape and each build owns only its own hook body. Nothing on screen changes in this build: every hook is an empty stub.
// - Render hooks, each called once a raid frame: gfxCam (after the camera), gfxGround (ground layer, before the y-sort), gfxShadowPass
//   (under the y-sorted bodies), gfxBodyFx (the air pass), gfxLightOn/gfxLightPass (the light wrap: false keeps the CLASSIC v23.58
//   darkness sheet and warm glows verbatim), gfxPreFog (bloom and beams, BEFORE the fog sheet so nothing glows through fog), gfxPostFog
//   (the grade, before pings, rings and world text), gfxScreen (screen effects, before the HUD).
// - Sim-side stubs, called only when not a bot raid and never drawing from the raid stream: gfxShot (fireWeapon), wallMark (a round
//   that stops on or punches a wall), boomFx (frag and Howler bursts, and their linked-window copies), gfxOnDeath (deathAnimAdd, which
//   now keeps the kind). scarStamp, gfxEmit and gfxWet wait for their builds.
// - GFX.bypass=1 turns every hook off (counted, nothing done): the A/B arm and the rollback. GFX.n counts calls per hook.
// - GFXSTORES: every sprite store a graphics build makes is registered by name with gfxStore and emptied by onCtxRestored, since a lost
//   context leaves anything painted before it blank.
var GFX={bypass:0,n:{},drops:0,emit:[],WET:0};
var GFXSTORES={};
function gfxHook(nm){
  GFX.n[nm]=(GFX.n[nm]||0)+1;
  return !GFX.bypass&&typeof G!=='undefined'&&!!G&&!G.sim;
}
function gfxStore(nm,dropFn){
  var s=GFXSTORES[nm];
  if(!s) s=GFXSTORES[nm]={m:{},n:0,drop:dropFn||null};
  return s;
}
function gfxStoresDrop(){
  var nm, s, c=0;
  for(nm in GFXSTORES){
    if(!Object.prototype.hasOwnProperty.call(GFXSTORES,nm)) continue;
    s=GFXSTORES[nm]; s.m={}; s.n=0;
    if(s.drop){ try{ s.drop(s); }catch(_sd){} }
    c++;
  }
  GFX.drops++;
  return c;
}
// render hooks (one call each per drawn raid frame)
function gfxCam(dt){ if(!gfxHook('cam')) return false; GFX.emit.length=0; return true; }   // F1: trauma shake
function gfxGround(dt){ return gfxHook('ground'); }   // D: ground stamps, puddles, casings
function gfxShadowPass(dt){ return gfxHook('shadow'); }   // B: body shadows that follow the lamps
function gfxBodyFx(dt){ return gfxHook('body'); }   // C, E: damage smoke and fire, explosions, atmosphere
function gfxLightOn(){ gfxHook('light'); return false; }   // B: true hands the light to gfxLightPass; false is the CLASSIC sheet
function gfxLightPass(dt,BR){ return false; }   // B: the coloured light map
function gfxPreFog(dt){ return gfxHook('prefog'); }   // F2: bloom; loot beams
function gfxPostFog(dt){ return gfxHook('postfog'); }   // F2: the grade
function gfxScreen(dt){ return gfxHook('screen'); }   // F1: grain and screen effects
// sim-side stubs (callers guard with !G.sim; no seeded draw, ever)
function gfxShot(sh,wep,ang,fromPlayer){ return gfxHook('shot'); }   // D: the first-frame muzzle flash
function wallMark(w,x,y,ux,uy){ return gfxHook('wall'); }   // D: bullet marks painted into the wall sprite
function boomFx(x,y,size,kind){ return gfxHook('boom'); }   // C: fireball, shockwave, smoke column, debris
function gfxOnDeath(a){ return gfxHook('death'); }   // C: machine death bursts, from the kept kind
function scarStamp(kind,x,y,o){ return gfxHook('scar'); }   // D: scorch, cracks and debris into G.ground
function gfxEmit(x,y,r,col,a){
  if(!gfxHook('emit')) return false;
  if(GFX.emit.length<256) GFX.emit.push({x:x,y:y,r:r,c:col,a:a});
  return true;
}   // F2: bloom sources, registered during the frame
function gfxWet(){ return GFX.bypass?0:(+GFX.WET||0); }   // D: how wet the ground is, 0 to 1
var HID={w:null,lastRaf:0,fromWorker:0,ticks:0};
'@

SubRx @'
  var ox=Math.round(camX+(sk?fxn(-sk,sk):0)),oy=Math.round(camY+(sk?fxn(-sk,sk):0));
  VX=ox; VY=oy;
'@ @'
  var ox=Math.round(camX+(sk?fxn(-sk,sk):0)),oy=Math.round(camY+(sk?fxn(-sk,sk):0));
  VX=ox; VY=oy;
  try{ gfxCam(dt); }catch(_gcm){}   // v23.xx (gfx2): camera hook
'@

SubRx @'
  // v7.68: landed decoys and armed frags moved INTO the y-sort (they drew
  // before it and everything overpainted them). Closures, dispatched first.
  var DR=[];
'@ @'
  try{ gfxGround(dt); }catch(_ggr){}   // v23.xx (gfx2): ground hook, in the world transform, under every body
  // v7.68: landed decoys and armed frags moved INTO the y-sort (they drew
  // before it and everything overpainted them). Closures, dispatched first.
  var DR=[];
'@

SubRx @'
  DR.sort(function(a,b){return a.k-b.k;});
  var crouchP=crouchHeld();
'@ @'
  DR.sort(function(a,b){return a.k-b.k;});
  var crouchP=crouchHeld();
  try{ gfxShadowPass(dt); }catch(_gsh){}   // v23.xx (gfx2): shadow hook, under the y-sorted bodies
'@

SubRx @'
  try{ drawDeathAnims(); }catch(_dda){}   // v17.47: his pick 29
'@ @'
  try{ drawDeathAnims(); }catch(_dda){}   // v17.47: his pick 29
  try{ gfxBodyFx(dt); }catch(_gbf){}   // v23.xx (gfx2): body and air effects hook
'@

SubRx @'
  // CFG.bright lifts everything you can actually see. 1.0 is the old v0.19 look.
  var BR=CFG.bright||1;
'@ @'
  // CFG.bright lifts everything you can actually see. 1.0 is the old v0.19 look.
  var BR=CFG.bright||1;
  // v23.xx (gfx2): THE LIGHT WRAP. gfxLightOn() true hands the light to gfxLightPass; false (always, in this build) runs the
  // CLASSIC darkness sheet and warm glows below exactly as v23.58 drew them. BR stays above the wrap: the fog pass reads it.
  var _gfxL=false; try{ _gfxL=gfxLightOn(); }catch(_glo){ _gfxL=false; }
  if(_gfxL){ try{ gfxLightPass(dt,BR); }catch(_glp){} } else {
'@

SubRx @'
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  gfxpMark('light');   // v23.xx (gfx1): the darkness sheet and the warm glows
'@ @'
  wc.globalAlpha=1; wc.globalCompositeOperation='source-over';
  }   // v23.xx (gfx2): end of the CLASSIC light
  try{ gfxPreFog(dt); }catch(_gpf){}   // v23.xx (gfx2): before the fog sheet, so nothing glows through fog
  gfxpMark('light');   // v23.xx (gfx1): the darkness sheet and the warm glows
'@

SubRx @'
wc.drawImage(fogC,0,0,W,H);   // v18.03: stretched back over the frame
'@ @'
wc.drawImage(fogC,0,0,W,H);   // v18.03: stretched back over the frame
  try{ gfxPostFog(dt); }catch(_gpo){}   // v23.xx (gfx2): after the fog, before pings, rings and world text
'@

SubRx @'
  gfxpMark('wx');   // v23.xx (gfx1): rain, weather fog and the overlays
'@ @'
  try{ gfxScreen(dt); }catch(_gsc){}   // v23.xx (gfx2): screen effects hook, before the HUD
  gfxpMark('wx');   // v23.xx (gfx1): rain, weather fog and the overlays
'@

SubRx @'
    flash(sh.x+Math.cos(ang)*20,sh.y+Math.sin(ang)*20,wep.dmg>40?155:108,wep.tint||'#ffc27a',.11);
'@ @'
    flash(sh.x+Math.cos(ang)*20,sh.y+Math.sin(ang)*20,wep.dmg>40?155:108,wep.tint||'#ffc27a',.11);
    if(!G.sim){ try{ gfxShot(sh,wep,ang,fromPlayer); }catch(_gsf){} }   // v23.xx (gfx2): shot hook, no seeded draw
'@

SubRx @'
        var _decR=rnd(3,6);
'@ @'
        var _decR=rnd(3,6);
        if(_struck&&!G.sim){ try{ wallMark(_struck,b.x,b.y,ux,uy); }catch(_gwm){} }   // v23.xx (gfx2): wall mark hook, AFTER the roll and drawing nothing from the stream
'@

SubRx @'
  flash(f.x,f.y,310,'#ffb267',.45);
'@ @'
  flash(f.x,f.y,310,'#ffb267',.45);
  if(!G.sim){ try{ boomFx(f.x,f.y,1,'frag'); }catch(_gbx){} }   // v23.xx (gfx2): explosion hook
'@

SubRx @'
  flash(SH.tx,SH.ty,220,'#ff9a5c',.4);
'@ @'
  flash(SH.tx,SH.ty,220,'#ff9a5c',.4);
  if(!G.sim){ try{ boomFx(SH.tx,SH.ty,0.8,'howler'); }catch(_gbx){} }   // v23.xx (gfx2): explosion hook
'@

SubRx @'
flash(SH.tx,SH.ty,220,'#ff9a5c',.4); }   // a copy only shows the burst
'@ @'
flash(SH.tx,SH.ty,220,'#ff9a5c',.4); if(!G.sim){ try{ boomFx(SH.tx,SH.ty,0.8,'howler'); }catch(_gbx){} } }   // a copy only shows the burst (v23.xx gfx2: and its explosion hook)
'@

SubRx @'
flash(fr.x,fr.y,310,'#ffb267',.45); }   // a copy only shows the blast
'@ @'
flash(fr.x,fr.y,310,'#ffb267',.45); if(!G.sim){ try{ boomFx(fr.x,fr.y,1,'frag'); }catch(_gbx){} } }   // a copy only shows the blast (v23.xx gfx2: and its explosion hook)
'@

SubRx @'
  G.deathAnims.push({x:e.x,y:e.y,r:Math.max(8,Math.min(48,e.r||14)),face:+e.face||0,c:DEATH_COL[e.kind]||'#555c64',t0:G.t||0});
'@ @'
  // v23.xx (gfx2): the kind is kept, so a machine death burst can be sized by what died, in every window
  G.deathAnims.push({x:e.x,y:e.y,r:Math.max(8,Math.min(48,e.r||14)),face:+e.face||0,c:DEATH_COL[e.kind]||'#555c64',t0:G.t||0,kind:e.kind||''});
  try{ gfxOnDeath(G.deathAnims[G.deathAnims.length-1]); }catch(_god){}
'@

SubRx @'
  hubGround=null;
  // hubGround rebuilds lazily
'@ @'
  try{ gfxStoresDrop(); }catch(_gsd){}   // v23.xx (gfx2): every registered graphics store is blank now too
  hubGround=null;
  // hubGround rebuilds lazily
'@

SubRx @'
var VER='23.73';
'@ @'
var VER='23.74';
'@

$pat = "(?m)^  now:'v23\.73:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.74: The drawing code now has hooks for the graphics program; nothing looks different yet. Check 23.74 fails on v23.73',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
