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

# SCREEN SHAKE, BRIGHTNESS AND SHOW FPS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  {k:'rumble', label:'Controller rumble',
'@ @'
  // v26.xx (settings5), HIS ORDER 2026-10-14 ("ok add all this stuff to settings"): SCREEN SHAKE, BRIGHTNESS and SHOW FPS, in DISPLAY. All three start as
  // the game was: shake at its usual strength, the picture as drawn, no readout. SCREEN SHAKE scales the camera trauma shake alone (EFFECT INTENSITY
  // still scales it with the hit pause and the rest). BRIGHTNESS is a gamma on the world canvas (it lifts or sinks the shadows, the way a night
  // raid needs), applied at once. SHOW FPS puts a small frame rate plate in the top left corner of every screen.
  {k:'shake', label:'SCREEN SHAKE', sec:'DISPLAY',
   hint:'HOW HARD THE PICTURE SHAKES: BLASTS, HEAVY HITS AND THE WARDEN. OFF HOLDS IT STILL.',
   opts:[
     {n:'OFF',      cfg:{shake:0}},
     {n:'LIGHT',    cfg:{shake:0.5}},
     {n:'STANDARD', cfg:{shake:1}},
     {n:'STRONG',   cfg:{shake:1.5}}
   ], def:2},
  {k:'gam', label:'BRIGHTNESS', sec:'DISPLAY',
   hint:'LIFTS OR SINKS THE SHADOWS OF THE WORLD. NIGHT RAIDS ARE DARK ON PURPOSE.',
   opts:[
     {n:'DARKER',    cfg:{gam:1.25}},
     {n:'STANDARD',  cfg:{gam:1}},
     {n:'BRIGHTER',  cfg:{gam:0.8}},
     {n:'BRIGHTEST', cfg:{gam:0.65}}
   ], def:1},
  {k:'showFps', label:'SHOW FPS', sec:'DISPLAY',
   hint:'THE FRAMES EACH SECOND, SMALL, IN THE TOP LEFT CORNER.',
   opts:[
     {n:'OFF', cfg:{showFps:0}},
     {n:'ON',  cfg:{showFps:1}}
   ], def:0},
  {k:'rumble', label:'Controller rumble',
'@

SubRx @'
function gfxTrauma(dt){
'@ @'
// v26.xx (settings5), HIS ORDER 2026-10-14: SCREEN SHAKE. The Settings row (OFF, LIGHT 0.5, STANDARD 1, STRONG 1.5) scales the trauma shake below on top of
// EFFECT INTENSITY; an unset or odd value is the usual strength.
function shakeK(){ var s=+CFG.shake; return (isFinite(s)&&s>=0&&s<=3)?s:1; }
// v26.xx (settings5): BRIGHTNESS. A gamma on the world canvas through an SVG filter (the exponent below 1 lifts the shadows, above 1 sinks them);
// at 1, the default, the canvas has no filter at all. brightApply runs every frame and writes only when the row changed.
var BRT={v:1};
function brightApply(){
  var v=+CFG.gam, svg, fl, i, fs, ids=['R','G','B'];
  if(!(v>0.3&&v<3)) v=1;
  if(BRT.v===v&&(v===1||document.getElementById('gamf'))) return false;
  if(v!==1){
    svg=document.getElementById('gamsvg');
    if(!svg){
      svg=document.createElementNS('http://www.w3.org/2000/svg','svg'); svg.id='gamsvg'; svg.setAttribute('width','0'); svg.setAttribute('height','0'); svg.style.position='absolute';
      fl=document.createElementNS('http://www.w3.org/2000/svg','filter'); fl.id='gamf'; fl.setAttribute('color-interpolation-filters','sRGB');
      fs=document.createElementNS('http://www.w3.org/2000/svg','feComponentTransfer'); fl.appendChild(fs);
      for(i=0;i<3;i++){ var f=document.createElementNS('http://www.w3.org/2000/svg','feFunc'+ids[i]); f.setAttribute('type','gamma'); f.setAttribute('amplitude','1'); f.setAttribute('offset','0'); f.setAttribute('exponent','1'); fs.appendChild(f); }
      svg.appendChild(fl); document.body.appendChild(svg);
    }
    [].forEach.call(svg.querySelectorAll('feComponentTransfer > *'),function(f){ f.setAttribute('exponent',String(v)); });
    cv.style.filter='url(#gamf)';
  } else cv.style.filter='';
  BRT.v=v;
  return true;
}
// v26.xx (settings5): SHOW FPS. A small plate (#fpsbox, a DOM element, so it shows on every screen) with the frames each second, measured over half a
// second of the frames the loop really runs, one number written twice a second. Off, the plate is hidden and nothing is measured.
var FPSV={t0:0,n:0,fps:0,el:null};
function fpsTick(ts){
  var el, s;
  if(CFG.showFps!==1){ if(FPSV.el&&FPSV.el.className) FPSV.el.className=''; FPSV.t0=0; FPSV.n=0; return false; }
  if(!FPSV.t0){ FPSV.t0=ts; FPSV.n=0; return true; }
  FPSV.n++;
  if(ts-FPSV.t0>=500){
    FPSV.fps=Math.round(FPSV.n*1000/(ts-FPSV.t0)); FPSV.t0=ts; FPSV.n=0;
    el=FPSV.el; if(!el||!el.isConnected){ el=document.getElementById('fpsbox'); if(!el){ el=document.createElement('div'); el.id='fpsbox'; document.body.appendChild(el); } FPSV.el=el; }
    s=FPSV.fps+' FPS'; if(el.textContent!==s) el.textContent=s; if(el.className!=='on') el.className='on';
  }
  return true;
}
function gfxTrauma(dt){
'@

SubRx @'
A=18*hr*GFX.tr*GFX.tr*k;
'@ @'
A=18*hr*GFX.tr*GFX.tr*k*shakeK();   // v26.xx (settings5): SCREEN SHAKE
'@

SubRx @'
try{ volApply(); }catch(_va){}   // v17.74: the volume rows, applied at once
'@ @'
try{ volApply(); }catch(_va){}   // v17.74: the volume rows, applied at once
  try{ brightApply(); }catch(_br){}   // v26.xx (settings5): BRIGHTNESS, applied at once
'@

SubRx @'
if(frameCapSkip(ts)) return;   // v17.43: his pick 28, the frame cap
'@ @'
if(frameCapSkip(ts)) return;   // v17.43: his pick 28, the frame cap
  try{ fpsTick(ts); }catch(_fq){}   // v26.xx (settings5): SHOW FPS
'@

SubRx @'
  #root #setlist .setjump + .row[style*="opacity:.7"]{ margin-top:0; border-top:0; padding-top:16px; }
'@ @'
  #root #setlist .setjump + .row[style*="opacity:.7"]{ margin-top:0; border-top:0; padding-top:16px; }
  /* v26.xx (settings5): SHOW FPS, a small graphite plate with an amber number, cut at the top left like the HUD panels, top left of the screen. */
  #fpsbox{ position:fixed; left:8px; top:6px; z-index:60; display:none; padding:3px 10px 2px 14px; background:rgba(11,12,13,.82); border:1px solid var(--ui-line-hi);
    color:var(--acc); font-family:var(--f-cond); font-weight:700; font-size:15px; line-height:1.3; letter-spacing:.14em; pointer-events:none; clip-path:polygon(8px 0,100% 0,100% 100%,0 100%,0 8px); }
  #fpsbox.on{ display:block; }
'@

SubRx @'
var VER='26.45';
'@ @'
var VER='26.46';
'@

$pat = "(?m)^  now:'v26\.45:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v26.46: Display has screen shake, brightness and show fps. Check 26.46 fails on v26.45',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
