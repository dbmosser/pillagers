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

# QUALITY SHEDS REAL EFFECTS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v23.xx (gfx6), HIS ORDER (2026-10-12) on the graphics program: "add ALL of this stuff", item 11, and his answer 21 (b): 60 frames
// a second also on a mid laptop at 1080p. THE QUALITY LADDER. Auto resolution had one lever: a slow stretch made the whole world
// softer, while the costly extras kept drawing at full price. Now a slow stretch sheds the extras first, one rung a second, and
// only then the resolution: rung 1 turns the post pass off (POST FX), rung 2 draws the soft sheets (the darkness and light map
// and the fog of war) at two thirds of their size, rung 3 draws LIGHTING HIGH as STANDARD (the lamp shadows and cookies go, the
// coloured light stays). After the third rung the render scale steps down as before (two seconds slow, never under Low, the
// RESOLUTION STEPPED DOWN line on the first step). Smooth frames climb back in reverse: the resolution first, then each rung, with
// the same wait and bounce guard as the scale. A rung whose extra is already off in Settings is passed over, so it never costs a
// slow second. The rung is kept in DRS (q, and qa for the size the canvases were last built at), so it rests at 0 outside a raid
// and with Auto resolution Off, exactly as the scale does. GFXQ is the view the graphics passes read: post, lmap (the soft sheet
// share) and shadow; gfxLightNow() and gfxPostNow() fold the settings and the rung into one answer.

'@ @'
// v28.xx (cw-cx-laddereffects): his 2.44 b: effects can go down, picture sharpness no lower than 75 percent.
// Rung 1: Reduced particle counts and shorter new decals. Rung 2: decorative corner shade and lighter weather, eased over one second.
// Rung 3: the existing two-thirds soft sheets. Empty post and shadow passes stay off the ladder; lighting colour and gameplay marks stay intact.

'@

SubRx @'
var GFXQ={q:0,post:1,lmap:1,shadow:1};
'@ @'
var GFXQ={q:0,post:1,lmap:1,shadow:1,particles:1,detail:1}; // v28.xx (cw-cx-laddereffects): keep lighting colour and gameplay marks; shed cosmetic work first.
'@

SubRx @'
function gfxqApply(){ var q=DRS.q|0; GFXQ.q=q; GFXQ.post=1; GFXQ.lmap=(q>=2)?0.66:1; GFXQ.shadow=1; return GFXQ; }
function gfxqCan(l){ return l===2; }
'@ @'
// v28.xx (cw-cx-laddereffects): real rungs: spawn counts, HUD/weather, then the existing two-thirds sheets. Empty passes have no rung.
function gfxqApply(){ var q=DRS.q|0; GFXQ.q=q; GFXQ.post=1; GFXQ.shadow=1; GFXQ.particles=q>=1?0:1; GFXQ.lmap=q>=3?0.66:1; return GFXQ; }
function gfxqCan(l){ if(l==='post'||l==='shadow') return false; return l===1||l===2||l===3; }
function gfxqEase(dt){
  var target=GFXQ.q>=2?0:1, step=Math.max(0,+dt||0);
  GFXQ.detail=target<GFXQ.detail?Math.max(target,GFXQ.detail-step):Math.min(target,GFXQ.detail+step);
}
function gfxqRainCount(n){ return Math.round(n*(0.5+0.5*GFXQ.detail)); }
function gfxqFogWeight(i){ return i<3?1:GFXQ.detail; }
function gfxqVignette(){
  if(!(GFXQ.detail>0)) return false;
  var vg=ctx.createRadialGradient(W/2,H/2,H*.42,W/2,H/2,H*.85);
  vg.addColorStop(0,'rgba(0,0,0,0)'); vg.addColorStop(1,'rgba(0,0,0,'+(0.45*GFXQ.detail).toFixed(3)+')');
  ctx.fillStyle=vg; ctx.fillRect(0,0,W,H); return true;
}
'@

SubRx @'
  if(CFG.fxLevel===0) n=Math.ceil(n/3);   // v17.43: his pick 28, reduced effects
'@ @'
  if(CFG.fxLevel===0||GFXQ.particles===0) n=Math.ceil(n/3); // v28.xx (cw-cx-laddereffects): Reduced counts at spawn only; existing sparks finish their lives.
'@

SubRx @'
  G.decals.push({x:x,y:y,c:col,s:size,a:_a0,a0:_a0,rot:fxn(0,3),t:0,life:45});
'@ @'
  G.decals.push({x:x,y:y,c:col,s:size,a:_a0,a0:_a0,rot:fxn(0,3),t:0,life:GFXQ.particles===0?15:45}); // v28.xx (cw-cx-laddereffects): new ground decals only; tracks and gameplay marks keep their lifetimes.
'@

SubRx @'
thin=(CFG.fxLevel===0), i, n, a, vz
'@ @'
thin=(CFG.fxLevel===0||GFXQ.particles===0), i, n, a, vz /* v28.xx (cw-cx-laddereffects): Reduced blast debris and smoke at spawn only */
'@

SubRx @'
function render2D(dt){
'@ @'
function render2D(dt){
  gfxqEase(dt); // v28.xx (cw-cx-laddereffects): ease decorative HUD and weather changes over one second.
'@

SubRx @'
    var drops=Math.round(110+_rr*90);
'@ @'
    var drops=gfxqRainCount(Math.round(110+_rr*90)); // v28.xx (cw-cx-laddereffects): half the rain lines at rung 2, eased over one second.
'@

SubRx @'
    for(var _fi=0;_fi<7;_fi++){
'@ @'
    for(var _fi=0;_fi<7;_fi++){
      var _fq=gfxqFogWeight(_fi); if(!(_fq>0)) continue; // v28.xx (cw-cx-laddereffects): fade the last four banks out; keep the first three.
'@

SubRx @'
(0.11*_fa).toFixed(3)
'@ @'
(0.11*_fa*_fq).toFixed(3)
'@

SubRx @'
  var vg=ctx.createRadialGradient(W/2,H/2,H*.42,W/2,H/2,H*.85);
  vg.addColorStop(0,'rgba(0,0,0,0)'); vg.addColorStop(1,'rgba(0,0,0,.45)');
  ctx.fillStyle=vg; ctx.fillRect(0,0,W,H);
'@ @'
  gfxqVignette(); // v28.xx (cw-cx-laddereffects): only decorative corner shade; low-health, hit and scope edges below stay intact.
'@

SubRx @'
var VER='34.13';
'@ @'
var VER='34.14';
'@

$pat = "(?m)^  now:'v34\.13:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.14: The ladder trims sparks and blast debris, then corner shade and weather, then soft sheets. Lighting colour and gameplay marks stay intact. Check 34.14 fails on v34.13',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
