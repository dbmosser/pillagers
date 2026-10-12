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

# FRAME TELEMETRY (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
var HID={w:null,lastRaf:0,fromWorker:0,ticks:0};
'@ @'
// v23.xx (gfx1), HIS ORDER 2026-10-12 ("add ALL of this stuff", the graphics program): FRAME TELEMETRY. Nobody had measured a frame at
// 4K on his PC, and this environment can time the script but not the drawing, so every graphics build after this one was going to be
// judged blind. The loop now keeps the real frame gap of every live raid frame (a raid window drawing on its own frames: not the worker
// clock, not a bot raid) in a half-millisecond histogram, and G.tel.gfx carries n (frames counted), p50 and p95 (the median and the
// 95th percentile gap in ms), slow (frames over 25 ms, the perfNote line) and q (the render scale in use). One frame in 15 also times
// the render passes (GFXP marks in render2D: world, light, fog, weather, HUD), averaged into G.tel.gfx.pass. The run record and the
// flight recorder export carry it, so his own PC gives the real number. Clocks only: no seeded draw, nothing a raid plays by.
var GFXP={on:0,k:0,last:0,cur:{}};
var GFXT={g:null,h:null,n:0,slow:0,ps:null,pn:0};
var GFXPASS=['world','light','fog','wx','hud'];
function gfxNow(){ return (typeof performance!=='undefined')?performance.now():Date.now(); }
function gfxTelFor(){
  if(GFXT.g===G&&GFXT.h) return GFXT;
  var i; GFXT.g=G; GFXT.h=[]; for(i=0;i<=200;i++) GFXT.h.push(0);
  GFXT.n=0; GFXT.slow=0; GFXT.ps={}; GFXT.pn=0;
  return GFXT;
}
function gfxPct(f){
  var want=Math.max(1,Math.ceil(GFXT.n*f)), c=0, i;
  for(i=0;i<=200;i++){ c+=GFXT.h[i]; if(c>=want) return (i>=200)?100:(i+0.5)/2; }
  return 0;
}
function gfxTelRow(){
  if(!G||G.sim||!G.tel) return null;
  return G.tel.gfx||(G.tel.gfx={n:0,p50:0,p95:0,slow:0,q:1,pass:null});
}
function gfxTel(gapMs){
  if(!G||G.sim||!G.tel||!(gapMs>0)||gapMs>1000) return false;
  var T=gfxTelFor(), row=gfxTelRow();
  T.h[Math.min(200,Math.floor(gapMs*2))]++; T.n++; if(gapMs>25) T.slow++;
  row.n=T.n; row.slow=T.slow; row.p50=gfxPct(0.5); row.p95=gfxPct(0.95);
  row.q=Math.round(gfxScaleNow()*100)/100;
  return true;
}
function gfxpBegin(){
  GFXP.k=(GFXP.k+1)%15;
  GFXP.on=(GFXP.k===0&&G&&!G.sim)?1:0;
  if(GFXP.on){ GFXP.cur={}; GFXP.last=gfxNow(); }
}
function gfxpMark(nm){
  if(!GFXP.on) return;
  var t=gfxNow(); GFXP.cur[nm]=(GFXP.cur[nm]||0)+(t-GFXP.last); GFXP.last=t;
}
function gfxpEnd(){
  if(!GFXP.on) return false;
  GFXP.on=0;
  var T=gfxTelFor(), row=gfxTelRow(), i, k, ps={};
  if(!row) return false;
  T.pn++;
  for(i=0;i<GFXPASS.length;i++){ k=GFXPASS[i]; T.ps[k]=(T.ps[k]||0)+(GFXP.cur[k]||0); ps[k]=Math.round(T.ps[k]/T.pn*100)/100; }
  ps.n=T.pn; row.pass=ps;
  return true;
}
var HID={w:null,lastRaf:0,fromWorker:0,ticks:0};
'@

SubRx @'
  if(state==='raid'&&G&&!G.over&&!G.sim&&!HID.fromWorker&&!(typeof document!=='undefined'&&document.hidden)){ try{ drsTick(gap0); }catch(_dt){} }   // v18.01: auto resolution, on real frames of a visible window
'@ @'
  if(state==='raid'&&G&&!G.over&&!G.sim&&!HID.fromWorker&&!(typeof document!=='undefined'&&document.hidden)){ try{ drsTick(gap0); }catch(_dt){} }   // v18.01: auto resolution, on real frames of a visible window
  if(state==='raid'&&G&&!G.over&&!G.sim&&!HID.fromWorker){ try{ gfxTel(gap0); }catch(_gt){} }   // v23.xx (gfx1): frame telemetry, the raw gap of real live raid frames
'@

SubRx @'
function render2D(dt){
  var p=G.player,i,j;
'@ @'
function render2D(dt){
  var p=G.player,i,j;
  gfxpBegin();   // v23.xx (gfx1): one frame in 15 times its passes
'@

SubRx @'
  // lighting overlay
  lx2.globalCompositeOperation='source-over';
'@ @'
  gfxpMark('world');   // v23.xx (gfx1): ground, bodies, props and the air pass
  // lighting overlay
  lx2.globalCompositeOperation='source-over';
'@

SubRx @'
  // vision fog
  fx2.globalCompositeOperation='source-over';
'@ @'
  gfxpMark('light');   // v23.xx (gfx1): the darkness sheet and the warm glows
  // vision fog
  fx2.globalCompositeOperation='source-over';
'@

SubRx @'
  var WX=wx();
  if(WX.rain>0){
'@ @'
  gfxpMark('fog');   // v23.xx (gfx1): fog of war, door glows, pings, rings and world text
  var WX=wx();
  if(WX.rain>0){
'@

SubRx @'
  drawHUD();
  drawBuzzFx();
}
'@ @'
  gfxpMark('wx');   // v23.xx (gfx1): rain, weather fog and the overlays
  drawHUD();
  drawBuzzFx();
  gfxpMark('hud'); gfxpEnd();   // v23.xx (gfx1)
}
'@

SubRx @'
    drawErr:T.drawErr||null,
'@ @'
    drawErr:T.drawErr||null,
    // v23.xx (gfx1): frame telemetry, a copy, so the frames after the raid ends do not move it
    gfx:(T.gfx&&T.gfx.n)?{n:T.gfx.n,p50:T.gfx.p50,p95:T.gfx.p95,slow:T.gfx.slow,q:T.gfx.q,pass:T.gfx.pass||null}:null,
'@

SubRx @'
    if(r.drawErr) line+=' DRAWERR:'+r.drawErr;
'@ @'
    if(r.drawErr) line+=' DRAWERR:'+r.drawErr;
    // v23.xx (gfx1): the frame gap this raid ran at on his PC, and what the sampled passes cost (ms of script)
    if(r.gfx&&r.gfx.n){
      line+=' gfx:'+r.gfx.p50+'/'+r.gfx.p95+'ms n:'+r.gfx.n+' slow:'+r.gfx.slow+' scale:'+r.gfx.q;
      if(r.gfx.pass&&r.gfx.pass.n) line+=' passes:world '+r.gfx.pass.world+' light '+r.gfx.pass.light+' fog '+r.gfx.pass.fog+' wx '+r.gfx.pass.wx+' hud '+r.gfx.pass.hud;
    }
'@

SubRx @'
var VER='23.60';
'@ @'
var VER='23.61';
'@

$pat = "(?m)^  now:'v23\.60:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v23.61: The flight recorder now notes how fast each raid drew on this PC, to steer the graphics work. Check 23.61 fails on v23.60',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
