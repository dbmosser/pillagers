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

# AUTO RESOLUTION: A SLOW STRETCH STEPS THE PICTURE DOWN BY ITSELF (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gfxScaleNow(){ var s=+CFG.gfxScale; return (s>0&&s<=1)?s:1; }
'@ @'
// v18.01, AAA CHECK after his report of 2026-10-03 (frame rate lag while running into new ground): AUTO RESOLUTION. A slow stretch
// used to run slow until he found the Render resolution row. Now, with the Auto resolution row On (the default), two seconds of
// frames running long step the render scale down one notch (never under Low, 0.5) and the canvases shrink on the next frame;
// eight seconds of smooth frames step it back up, waiting longer after each bounce so it does not flap. Measured on the raw
// frame gap against the frame budget (the Frame cap when one is set, 60 a second otherwise). Only real frames count: the worker
// ticks of a covered window (v17.73) and hidden pages are left out at the call. The first step down says so once, so a
// softer picture is never a mystery. The Render resolution row is a ceiling: Auto only ever goes below it.
var DRS={scale:1,applied:1,ema:0,slowT:0,fastT:0,last:0,bounce:0,upAt:0,said:0,min:0.5,step:0.1,moves:0};
function gfxScaleNow(){ var s=+CFG.gfxScale; s=(s>0&&s<=1)?s:1; return (CFG.gfxAuto===0)?s:Math.min(s,DRS.scale); }
function drsTick(gapMs,now){
  if(CFG.gfxAuto===0||!(gapMs>0)||gapMs>250) return false;
  now=(now!==undefined)?now:((typeof performance!=='undefined')?performance.now():Date.now());
  var budget=(CFG.fpsCap>0)?1000/CFG.fpsCap:16.7;
  DRS.ema=DRS.ema?(DRS.ema*0.9+gapMs*0.1):gapMs;
  if(DRS.ema>budget*1.5){ DRS.slowT+=gapMs; DRS.fastT=0; }
  else if(DRS.ema<budget*1.15){ DRS.fastT+=gapMs; DRS.slowT=0; }
  else { DRS.slowT=0; DRS.fastT=0; }
  if(DRS.slowT>2000&&DRS.scale>DRS.min+1e-6&&now-DRS.last>3000){
    DRS.scale=Math.max(DRS.min,Math.round((DRS.scale-DRS.step)*100)/100); DRS.slowT=0; DRS.moves++;
    if(DRS.upAt&&now-DRS.upAt<20000) DRS.bounce=Math.min(4,DRS.bounce+1);
    DRS.last=now;
    if(!DRS.said){ DRS.said=1; try{ sayWhenFree('Running slowly: the render resolution stepped down on its own. Settings has Auto resolution and Effects.'); }catch(_ds){} }
    return true;
  }
  if(DRS.fastT>8000*(1+DRS.bounce)&&DRS.scale<1-1e-6&&now-DRS.last>8000){
    DRS.scale=Math.min(1,Math.round((DRS.scale+DRS.step)*100)/100); DRS.fastT=0; DRS.last=now; DRS.upAt=now; DRS.moves++;
    return true;
  }
  return false;
}
'@

SubRx @'
  DPR=Math.min(window.devicePixelRatio||1,2)*gfxScaleNow(); RES_APPLIED=CFG.gfxScale;   // v17.43: his pick 28, the render resolution
'@ @'
  DPR=Math.min(window.devicePixelRatio||1,2)*gfxScaleNow(); RES_APPLIED=CFG.gfxScale; DRS.applied=DRS.scale;   // v17.43: his pick 28, the render resolution; v18.01: and the auto step
'@

SubRx @'
  if(CFG.gfxScale!==RES_APPLIED){ try{ resize(); }catch(_rz){} }   // v17.43: his pick 28, a new render resolution applies at once
'@ @'
  if((CFG.gfxAuto===0||state!=='raid')&&DRS.scale!==1) DRS.scale=1;   // v18.01: auto resolution rests at full outside a raid and when switched Off
  if(CFG.gfxScale!==RES_APPLIED||DRS.scale!==DRS.applied){ try{ resize(); }catch(_rz){} }   // v17.43: his pick 28, a new render resolution applies at once; v18.01: and an auto step
'@

SubRx @'
  if(state==='raid'&&G&&!G.over&&!G.sim&&!(CFG.fpsCap>0)) perfNote(gap0);   // v17.87: a slow PC is told where the levers are
'@ @'
  if(state==='raid'&&G&&!G.over&&!G.sim&&!(CFG.fpsCap>0)) perfNote(gap0);   // v17.87: a slow PC is told where the levers are
  if(state==='raid'&&G&&!G.over&&!G.sim&&!HID.fromWorker&&!(typeof document!=='undefined'&&document.hidden)){ try{ drsTick(gap0); }catch(_dt){} }   // v18.01: auto resolution, on real frames of a visible window
'@

SubRx @'
  {k:'fpsCap', label:'Frame cap',
'@ @'
  {k:'gfxAuto', label:'Auto resolution',
   hint:'When the game runs slowly, the render resolution steps down a notch at a time, never under Low, and steps back up when frames are smooth again. The Render resolution row above is the ceiling.',
   opts:[
     {n:'On',  cfg:{gfxAuto:1}},
     {n:'Off', cfg:{gfxAuto:0}}
   ], def:0},
  {k:'fpsCap', label:'Frame cap',
'@

SubRx @'
var VER='18.00';
'@ @'
var VER='18.01';
'@

$pat = "(?m)^  now:'v18\.00:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v18.01: When the game runs slowly it lowers its own render resolution a notch at a time, and raises it again when frames are smooth (Settings: Auto resolution). Check 18.01 fails on v18.00',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
