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

# QUALITY READS REAL FRAMES (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
function gfxqApply(){ var q=DRS.q|0; GFXQ.q=q; GFXQ.post=(q>=1)?0:1; GFXQ.lmap=(q>=2)?0.66:1; GFXQ.shadow=(q>=3)?0:1; return GFXQ; }
function gfxqCan(l){ if(l===1) return CFG.gfxPost!==0; if(l===2) return true; if(l===3) return CFG.gfxLight!==0&&CFG.gfxLight!==1; return false; }
'@ @'
// v28.xx (cw-cx-ladderwindow): empty post and lamp-shadow passes stay off the ladder until they have readers.
function gfxqApply(){ var q=DRS.q|0; GFXQ.q=q; GFXQ.post=1; GFXQ.lmap=(q>=2)?0.66:1; GFXQ.shadow=1; return GFXQ; }
function gfxqCan(l){ return l===2; }
function gfxqSync(){
  gfxqApply();
  if(CFG.gfxScale!==RES_APPLIED||DRS.scale!==DRS.applied||GFXQ.lmap!==DRS.sheet){ resize(); }
  DRS.qa=DRS.q|0;
}
'@

SubRx @'
  var budget=(CFG.fpsCap>0)?1000/CFG.fpsCap:16.7;
  DRS.ema=DRS.ema?(DRS.ema*0.9+gapMs*0.1):gapMs;
  if(DRS.ema>budget*1.5){ DRS.slowT+=gapMs; DRS.fastT=0; }
  else if(DRS.ema<budget*1.15){ DRS.fastT+=gapMs; DRS.slowT=0; }
  else { DRS.slowT=0; DRS.fastT=0; }
'@ @'
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
'@

SubRx @'
  gfxqApply(); DRS.qa=DRS.q|0;   // v23.xx (gfx6): the quality ladder rung these canvases are built at
'@ @'
  gfxqApply(); DRS.qa=DRS.q|0; DRS.sheet=GFXQ.lmap; // v28.xx (cw-cx-ladderwindow): remember the actual sheet size, not an inert rung.
'@

SubRx @'
  if(CFG.gfxScale!==RES_APPLIED||DRS.scale!==DRS.applied||(DRS.q|0)!==(DRS.qa|0)){ try{ resize(); }catch(_rz){} }   // v17.43: his pick 28, a new render resolution applies at once; v18.01: and an auto step
'@ @'
  try{ gfxqSync(); }catch(_rz){} // v28.xx (cw-cx-ladderwindow): resize only when a canvas size changes.
'@

SubRx @'
function loop(ts){
'@ @'
function loop(ts){
  DRS.frameStart=performance.now(); // v28.xx (cw-cx-ladderwindow): own work starts before frame setup and simulation.
'@

SubRx @'
  if(state==='raid'&&G&&!G.over&&!G.sim&&!HID.fromWorker&&!(typeof document!=='undefined'&&document.hidden)){ try{ drsTick(gap0); }catch(_dt){} }   // v18.01: auto resolution, on real frames of a visible window
'@ @'
  DRS.frameGap=gap0; // v28.xx (cw-cx-ladderwindow): pair this frame gap with its work after the HUD pass.
'@

SubRx @'
  gfxpMark('hud'); gfxpEnd();   // v23.xx (gfx1)
'@ @'
  gfxpMark('hud'); gfxpEnd();
  // v28.xx (cw-cx-ladderwindow): only real, visible raid frames steer quality, after their own HUD has finished.
  if(state==='raid'&&G&&!G.over&&!G.sim&&!HID.fromWorker&&!document.hidden&&DRS.frameStart!==undefined){
    var _drsEnd=performance.now(); DRS.workMs=Math.max(0,_drsEnd-DRS.frameStart);
    drsTick(DRS.frameGap,_drsEnd,DRS.workMs);
  }
'@

SubRx @'
var VER='34.12';
'@ @'
var VER='34.13';
'@

$pat = "(?m)^  now:'v34\.12:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v34.13: Quality reads two seconds of frame gaps and own work. Empty passes stay off the ladder and only size changes rebuild canvases. Check 34.13 fails on v34.12',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
