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

# STEADY QUALITY BETWEEN RAIDS (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
// v18.01, AAA CHECK after his report of 2026-10-03 (frame rate lag while running into new ground): AUTO RESOLUTION. A slow stretch
// used to run slow until he found the Render resolution row. Now, with the Auto resolution row On (the default), two seconds of
// frames running long step the render scale down one notch (never under Low, 0.5) and the canvases shrink on the next frame;
// eight seconds of smooth frames step it back up, waiting longer after each bounce so it does not flap. Measured on the raw
// frame gap against the frame budget (the Frame cap when one is set, 60 a second otherwise). Only real frames count: the worker
// ticks of a covered window (v17.73) and hidden pages are left out at the call. The first step down says so once, so a
// softer picture is never a mystery. The Render resolution row is a ceiling: Auto only ever goes below it.

'@ @'
// v28.xx (cw-cx-laddersteady): his 2.43 a: sustained frames below 60 shed effects before sharpness, measured over two seconds.
// Recovery needs ten clear seconds and waits longer after a bounce. Only a measured fill gain permits lower sharpness, never below 75 percent.
// The manual resolution is the ceiling; each new raid in this page starts one step better than the last raid settled.

'@

SubRx @'
function drsTick(gapMs,now){
  if(CFG.gfxAuto===0||!(gapMs>0)||gapMs>250) return false;
  now=(now!==undefined)?now:((typeof performance!=='undefined')?performance.now():Date.now());
  // v28.xx (cw-cx-ladderwindow): his 2.43 a, react below 60, even with a 120 or 144 cap; keep two seconds of gap and own work.
  var budget=Math.max(16.7,(CFG.fpsCap>0)?1000/CFG.fpsCap:16.7), w=DRS.win||(DRS.win=[]);
  var workMs=arguments.length>2?+arguments[2]:(+DRS.workMs||0);
  if(w.length&&(now<=w[w.length-1][0]||now-w[w.length-1][0]>250)){ w.length=0; DRS.slowT=0; DRS.fastT=0; }
  w.push([now,gapMs,Math.max(0,workMs)]);
  while(w.length>1&&w[1][0]<=now-2000) w.shift();
  var gaps=w.map(function(f){ return f[1]; }).sort(function(a,b){ return a-b; });
  var works=w.map(function(f){ return f[2]; }).sort(function(a,b){ return a-b; });
  DRS.gap95=gaps[Math.ceil(gaps.length*0.95)-1]; DRS.gap50=gaps[Math.ceil(gaps.length*0.5)-1];
  DRS.work95=works[Math.ceil(works.length*0.95)-1]; DRS.ema=DRS.gap95;
  if(now-w[0][0]<1950) return false;
  if(DRS.gap95>20*budget/16.7){ DRS.slowT+=gapMs; DRS.fastT=0; }
  else if(DRS.gap95<17.5*budget/16.7&&DRS.work95<10){ DRS.fastT+=gapMs; DRS.slowT=0; }
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
    if(!DRS.said){ DRS.said=1; try{ sayWhenFree('RESOLUTION STEPPED DOWN','sys'); /* v32.xx (cw-systoastbare): no detail line, the critic (screen 22) read it as an explaining sentence over the map. Old text: sub 'Settings: Auto resolution'. Reason: a system toast is a headline only */ }catch(_ds){} }   // v22.xx (R36): a system row in caps   // v22.89 (tr7fixa): a short detail, not a sentence
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

'@ @'
// v28.xx (cw-cx-laddersteady): page-session quality, never saved into a profile or shared between windows.
var DRSSESSION={raid:null,settled:null};
function drsRemember(){ DRSSESSION.settled={q:DRS.q|0,scale:DRS.scale,fillOK:DRS.fillOK===true,noFillGap:DRS.noFillGap||0,bounce:DRS.bounce||0}; }
function drsBeginRaid(now){
  var s=DRSSESSION.settled, q=s?s.q:0, scale=s?s.scale:1;
  if(scale<1) scale=Math.min(1,Math.round((scale+DRS.step)*100)/100); else q=gfxqPrev(q);
  DRS.q=q; DRS.scale=Math.max(DRS.min,scale); DRS.win=[]; DRS.ema=0; DRS.slowT=0; DRS.fastT=0; DRS.recoverT=0;
  DRS.last=now; DRS.upAt=s&&(q<s.q||scale>s.scale)?now:0; DRS.downAt=0; DRS.bounce=s?s.bounce:0; DRS.decayAt=now+60000; DRS.said=0;
  DRS.fillAt=0; DRS.fillBefore=0; DRS.fillOK=!!(s&&s.fillOK); DRS.noFillGap=s?s.noFillGap:0;
  gfxqApply(); GFXQ.detail=q>=2?0:1;
}
function gfxqRaidSync(now){
  var live=state==='raid'&&G&&!G.over&&!G.sim&&CFG.gfxAuto!==0;
  if(live&&DRSSESSION.raid!==G){
    if(DRSSESSION.raid) drsRemember();
    drsBeginRaid(now); DRSSESSION.raid=G;
  }else if(!live&&DRSSESSION.raid){ drsRemember(); DRSSESSION.raid=null; }
}
function drsMove(dir,now,q,scale){
  if(dir<0){
    if(DRS.upAt&&now-DRS.upAt<30000) DRS.bounce=Math.min(3,(DRS.bounce||0)+1);
    DRS.downAt=now; DRS.decayAt=now+60000;
    if(q===3&&(DRS.q|0)<3){ DRS.fillBefore=DRS.gap50; DRS.fillAt=now; DRS.fillOK=null; }
  }else DRS.upAt=now;
  var softer=scale<DRS.scale;
  DRS.q=q; DRS.scale=scale; DRS.last=now; DRS.slowT=0; DRS.fastT=0; DRS.recoverT=0; DRS.moves++; gfxqApply();
  if(q<3){ DRS.fillOK=false; DRS.fillAt=0; }
  if(softer&&!DRS.said){ DRS.said=1; try{ sayWhenFree('RESOLUTION STEPPED DOWN','sys'); }catch(_ds){} }
  return true;
}
function drsTick(gapMs,now){
  if(CFG.gfxAuto===0||!(gapMs>0)||gapMs>250) return false;
  now=(now!==undefined)?now:performance.now();
  // v28.xx (cw-cx-laddersteady): his 2.43 a: a fast cap is no reason to shed above 60 fps. A deliberately slower cap keeps its own budget.
  var budget=Math.max(16.7,(CFG.fpsCap>0)?1000/CFG.fpsCap:16.7), w=DRS.win||(DRS.win=[]);
  var workMs=arguments.length>2?+arguments[2]:(+DRS.workMs||0);
  if(w.length&&(now<=w[w.length-1][0]||now-w[w.length-1][0]>250)){ w.length=0; DRS.slowT=0; DRS.fastT=0; DRS.recoverT=0; }
  w.push([now,gapMs,Math.max(0,workMs)]);
  while(w.length>1&&w[1][0]<=now-2000) w.shift();
  var gaps=w.map(function(f){ return f[1]; }).sort(function(a,b){ return a-b; });
  var works=w.map(function(f){ return f[2]; }).sort(function(a,b){ return a-b; });
  DRS.gap95=gaps[Math.ceil(gaps.length*0.95)-1]; DRS.gap50=gaps[Math.ceil(gaps.length*0.5)-1];
  DRS.work95=works[Math.ceil(works.length*0.95)-1]; DRS.ema=DRS.gap95;
  var slow=DRS.gap95>20*budget/16.7, clear=DRS.gap95<17.5*budget/16.7&&DRS.work95<10;
  if(slow){ DRS.slowT+=gapMs; DRS.fastT=0; } else if(clear){ DRS.fastT+=gapMs; DRS.slowT=0; } else { DRS.slowT=0; DRS.fastT=0; }
  if(DRS.bounce>0&&DRS.decayAt&&now>=DRS.decayAt){ DRS.bounce--; DRS.decayAt=now+60000; }
  if(now-w[0][0]<1950) return false;
  // v28.xx (cw-cx-laddersteady): compare the window before the fill rung with a complete window after it. No gain means no softer picture.
  if((DRS.q|0)>=3&&DRS.fillOK===null&&now-DRS.fillAt>=2000){
    DRS.fillOK=DRS.fillBefore-DRS.gap50>=1-1e-6;
    if(!DRS.fillOK) DRS.noFillGap=DRS.gap50;
  }
  var stalled=DRS.noFillGap>0&&Math.abs(DRS.gap50-DRS.noFillGap)<1;
  if(DRS.noFillGap&&!stalled){ DRS.noFillGap=0; DRS.recoverT=0; }
  if(stalled) DRS.recoverT=(DRS.recoverT||0)+gapMs; else DRS.recoverT=0;
  var downOK=!DRS.upAt||now-DRS.upAt>=10000, wait=Math.min(60000,10000*Math.pow(2,DRS.bounce||0));
  if(!stalled&&slow&&DRS.slowT>=2000&&downOK){
    var q1=gfxqNext(DRS.q|0);
    if(q1>(DRS.q|0)&&now-DRS.last>=2000) return drsMove(-1,now,q1,DRS.scale);
    if((DRS.q|0)>=3&&DRS.fillOK===true&&DRS.scale>DRS.min+1e-6&&now-DRS.last>=3000){
      return drsMove(-1,now,DRS.q|0,Math.max(DRS.min,Math.round((DRS.scale-DRS.step)*100)/100));
    }
  }
  // v28.xx (cw-cx-laddersteady): ten clear seconds, exponential bounce waits, and at least ten seconds between opposite directions. A proven fixed cadence also recovers.
  if((DRS.fastT>=wait||DRS.recoverT>=wait)&&now-DRS.last>=wait&&(!DRS.downAt||now-DRS.downAt>=10000)){
    if(DRS.scale<1-1e-6) return drsMove(1,now,DRS.q|0,Math.min(1,Math.round((DRS.scale+DRS.step)*100)/100));
    if((DRS.q|0)>0) return drsMove(1,now,gfxqPrev(DRS.q|0),DRS.scale);
  }
  return false;
}

'@

SubRx @'
  if((CFG.gfxAuto===0||state!=='raid')&&(DRS.scale!==1||DRS.q)){ DRS.scale=1; DRS.q=0; }   // v18.01: auto resolution rests at full outside a raid and when switched Off
'@ @'
  // v28.xx (cw-cx-laddersteady): remember the last raid before resting at full outside it; the next starts one step better.
  gfxqRaidSync(performance.now());
  if((CFG.gfxAuto===0||state!=='raid')&&(DRS.scale!==1||DRS.q)){ DRS.scale=1; DRS.q=0; }
'@

SubRx @'
never under Low, and steps back up when frames are smooth again.
'@ @'
never under 75 percent, and steps back up when frames are smooth again.
'@

SubRx @'
  // v23.xx (gfx6): the quality ladder rung rests at 0 with the scale, and a new rung rebuilds the canvases like a new scale
'@ @'
  // v28.xx (cw-cx-laddersteady): outside a raid quality rests at full; only actual canvas sizes can trigger a rebuild.
'@

SubRx @'
var VER='34.14';
'@ @'
var VER='34.15';
'@

$pat = "(?m)^  now:'v34\.14:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.15: Effects shed after two slow seconds. Sharpness only falls after a measured fill gain. Recovery waits ten seconds or longer and the next raid starts one step better. Check 34.15 fails on v34.14',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
