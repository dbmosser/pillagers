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

# SLOW FRAMES SHED EFFECTS FIRST (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
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
    if(!DRS.said){ DRS.said=1; try{ sayWhenFree('RESOLUTION STEPPED DOWN','sys',{sub:'Settings: Auto resolution'}); }catch(_ds){} }   // v22.xx (R36): a system row in caps   // v22.89 (tr7fixa): a short detail, not a sentence
    return true;
  }
  if(DRS.fastT>8000*(1+DRS.bounce)&&DRS.scale<1-1e-6&&now-DRS.last>8000){
    DRS.scale=Math.min(1,Math.round((DRS.scale+DRS.step)*100)/100); DRS.fastT=0; DRS.last=now; DRS.upAt=now; DRS.moves++;
    return true;
  }
  return false;
}
'@ @'
var DRS={scale:1,applied:1,ema:0,slowT:0,fastT:0,last:0,bounce:0,upAt:0,said:0,min:0.5,step:0.1,moves:0,q:0,qa:0};
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
var GFXQ={q:0,post:1,lmap:1,shadow:1};
function gfxqApply(){ var q=DRS.q|0; GFXQ.q=q; GFXQ.post=(q>=1)?0:1; GFXQ.lmap=(q>=2)?0.66:1; GFXQ.shadow=(q>=3)?0:1; return GFXQ; }
function gfxqCan(l){ if(l===1) return CFG.gfxPost!==0; if(l===2) return true; if(l===3) return CFG.gfxLight!==0&&CFG.gfxLight!==1; return false; }
function gfxqNext(q){ var l; for(l=q+1;l<=3;l++){ if(gfxqCan(l)) return l; } return q; }
function gfxqPrev(q){ var l=q-1; while(l>0&&!gfxqCan(l)) l--; return Math.max(0,l); }
function gfxLightNow(){ var l=(CFG.gfxLight===0)?0:((CFG.gfxLight===1)?1:2); if(l===2&&!GFXQ.shadow) l=1; return l; }
function gfxPostNow(){ return CFG.gfxPost!==0&&GFXQ.post!==0; }
function gfxScaleNow(){ var s=+CFG.gfxScale; s=(s>0&&s<=1)?s:1; return (CFG.gfxAuto===0)?s:Math.min(s,DRS.scale); }
function drsTick(gapMs,now){
  if(CFG.gfxAuto===0||!(gapMs>0)||gapMs>250) return false;
  now=(now!==undefined)?now:((typeof performance!=='undefined')?performance.now():Date.now());
  var budget=(CFG.fpsCap>0)?1000/CFG.fpsCap:16.7;
  DRS.ema=DRS.ema?(DRS.ema*0.9+gapMs*0.1):gapMs;
  if(DRS.ema>budget*1.5){ DRS.slowT+=gapMs; DRS.fastT=0; }
  else if(DRS.ema<budget*1.15){ DRS.fastT+=gapMs; DRS.slowT=0; }
  else { DRS.slowT=0; DRS.fastT=0; }
  // v23.xx (gfx6): the ladder first, one rung after a second of slow frames, before any step of the render scale
  if(DRS.slowT>1000&&now-DRS.last>1000){
    var q1=gfxqNext(DRS.q|0);
    if(q1>(DRS.q|0)){
      DRS.q=q1; gfxqApply(); DRS.slowT=0; DRS.moves++;
      if(DRS.upAt&&now-DRS.upAt<20000) DRS.bounce=Math.min(4,DRS.bounce+1);
      DRS.last=now;
      return true;
    }
  }
  if(DRS.slowT>2000&&DRS.scale>DRS.min+1e-6&&now-DRS.last>3000){
    DRS.scale=Math.max(DRS.min,Math.round((DRS.scale-DRS.step)*100)/100); DRS.slowT=0; DRS.moves++;
    if(DRS.upAt&&now-DRS.upAt<20000) DRS.bounce=Math.min(4,DRS.bounce+1);
    DRS.last=now;
    if(!DRS.said){ DRS.said=1; try{ sayWhenFree('RESOLUTION STEPPED DOWN','sys',{sub:'Settings: Auto resolution'}); }catch(_ds){} }   // v22.xx (R36): a system row in caps   // v22.89 (tr7fixa): a short detail, not a sentence
    return true;
  }
  if(DRS.fastT>8000*(1+DRS.bounce)&&DRS.scale<1-1e-6&&now-DRS.last>8000){
    DRS.scale=Math.min(1,Math.round((DRS.scale+DRS.step)*100)/100); DRS.fastT=0; DRS.last=now; DRS.upAt=now; DRS.moves++;
    return true;
  }  // v23.xx (gfx6): at full scale, smooth frames climb the ladder back one rung at a time
  if(DRS.fastT>8000*(1+DRS.bounce)&&DRS.scale>=1-1e-6&&(DRS.q|0)>0&&now-DRS.last>8000){
    DRS.q=gfxqPrev(DRS.q|0); gfxqApply(); DRS.fastT=0; DRS.last=now; DRS.upAt=now; DRS.moves++;
    return true;
  }
  return false;
}
'@

SubRx @'
  DPR=DPRH*gfxScaleNow(); RES_APPLIED=CFG.gfxScale; DRS.applied=DRS.scale;   // v17.43: his pick 28, the render resolution; v18.01: and the auto step
'@ @'
  gfxqApply(); DRS.qa=DRS.q|0;   // v23.xx (gfx6): the quality ladder rung these canvases are built at
  DPR=DPRH*gfxScaleNow(); RES_APPLIED=CFG.gfxScale; DRS.applied=DRS.scale;   // v17.43: his pick 28, the render resolution; v18.01: and the auto step
'@

SubRx @'
  SOFTR=Math.max(0.33,((W*H>2.6e6)?0.5:0.67)*gfxScaleNow());   // v18.03: the soft sheets' share of the screen
'@ @'
  SOFTR=Math.max(0.33,((W*H>2.6e6)?0.5:0.67)*gfxScaleNow()*GFXQ.lmap);   // v18.03: the soft sheets' share of the screen; v23.xx (gfx6): and the ladder's rung 2
'@

SubRx @'
  if((CFG.gfxAuto===0||state!=='raid')&&DRS.scale!==1) DRS.scale=1;   // v18.01: auto resolution rests at full outside a raid and when switched Off
  if(CFG.gfxScale!==RES_APPLIED||DRS.scale!==DRS.applied){ try{ resize(); }catch(_rz){} }   // v17.43: his pick 28, a new render resolution applies at once; v18.01: and an auto step
'@ @'
  if((CFG.gfxAuto===0||state!=='raid')&&(DRS.scale!==1||DRS.q)){ DRS.scale=1; DRS.q=0; }   // v18.01: auto resolution rests at full outside a raid and when switched Off
  if(CFG.gfxScale!==RES_APPLIED||DRS.scale!==DRS.applied||(DRS.q|0)!==(DRS.qa|0)){ try{ resize(); }catch(_rz){} }   // v17.43: his pick 28, a new render resolution applies at once; v18.01: and an auto step
  // v23.xx (gfx6): the quality ladder rung rests at 0 with the scale, and a new rung rebuilds the canvases like a new scale
'@

SubRx @'
var VER='24.46';
'@ @'
var VER='24.47';
'@

$pat = "(?m)^  now:'v24\.46:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v24.47: When frames run slow the game now drops costly effects before it lowers the resolution, and brings them back when it runs smooth. Check 24.47 fails on v24.46',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
