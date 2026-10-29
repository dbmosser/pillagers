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

# RAID REPORTS SAY WHAT HELD THE FRAME RATE (co-op hunt, 2026-09-28; found and drafted by agents, each verified by a second).

SubRx @'
  GFXT.n=0; GFXT.slow=0; GFXT.ps={}; GFXT.pn=0;
'@ @'
  GFXT.n=0; GFXT.slow=0; GFXT.ps={}; GFXT.pn=0; GFXT.wh=[]; for(i=0;i<=200;i++) GFXT.wh.push(0); GFXT.wn=0;   // v28.xx (cw-fpswork): the frame's own work, in the same half-millisecond bins
'@

SubRx @'
  row.pix=pixTelRow();   // v33.51 (cw-pixkit): builds, bake ms, hits, misses, bytes and the device scale S
  return true;
}

'@ @'
  row.pix=pixTelRow();   // v33.51 (cw-pixkit): builds, bake ms, hits, misses, bytes and the device scale S
  return true;
}
// v28.xx (cw-fpswork), THE FPS CZAR (his chat of 2026-10-29, "this thread is the FPS czar, for fixing screenrate issues"): five of his raids on 10-28
// ran at a steady 30 frames a second (gfx 33/33 ms) and the run line could not say why. Its passes were light, but they time only the drawing. Each
// live raid frame now also files the game's own work for that frame (simulation plus drawing, the auto resolution's workMs, from the top of the loop
// to the end of the HUD) in half-millisecond bins, with the screen rate the browser gives (VSYNC) and the frame cap. A slow raid whose own work stays
// far under a frame was held back outside the game (the browser, the graphics card, another program); one whose work fills the frame was the game.
function gfxWorkTel(workMs){
  if(!G||G.sim||!G.tel||!(workMs>=0)||workMs>1000) return false;
  var T=gfxTelFor(), row=gfxTelRow(), i, c=0, a, b, w50=0, w95=0;
  if(!row||!T.wh) return false;
  T.wh[Math.min(200,Math.floor(workMs*2))]++; T.wn++;
  a=Math.max(1,Math.ceil(T.wn*0.5)); b=Math.max(1,Math.ceil(T.wn*0.95));
  for(i=0;i<=200;i++){ c+=T.wh[i]; if(!w50&&c>=a) w50=(i>=200)?100:(i+0.5)/2; if(c>=b){ w95=(i>=200)?100:(i+0.5)/2; break; } }
  row.w50=w50; row.w95=w95;
  row.scr=(VSYNC.ms>0)?Math.round(1000/VSYNC.ms):0; row.cap=+CFG.fpsCap||0;
  return true;
}

'@

SubRx @'
var _drsEnd=performance.now(); DRS.workMs=Math.max(0,_drsEnd-DRS.frameStart);
'@ @'
var _drsEnd=performance.now(); DRS.workMs=Math.max(0,_drsEnd-DRS.frameStart); try{ gfxWorkTel(DRS.workMs); }catch(_gwt){}   // v28.xx (cw-fpswork): the run report keeps this frame's own work
'@

SubRx @'
gfx:(T.gfx&&T.gfx.n)?{n:T.gfx.n,p50:T.gfx.p50,p95:T.gfx.p95,slow:T.gfx.slow,q:T.gfx.q,pass:T.gfx.pass||null}:null,
'@ @'
gfx:(T.gfx&&T.gfx.n)?{n:T.gfx.n,p50:T.gfx.p50,p95:T.gfx.p95,slow:T.gfx.slow,q:T.gfx.q,pass:T.gfx.pass||null,w50:T.gfx.w50||0,w95:T.gfx.w95||0,scr:T.gfx.scr||0,cap:T.gfx.cap||0}:null,   // v28.xx (cw-fpswork): own work p50/p95, screen Hz, frame cap
'@

SubRx @'
      if(r.gfx.pass&&r.gfx.pass.n) line+=' passes:world '+r.gfx.pass.world+' light '+r.gfx.pass.light+' fog '+r.gfx.pass.fog+' wx '+r.gfx.pass.wx+' hud '+r.gfx.pass.hud;
'@ @'
      if(r.gfx.pass&&r.gfx.pass.n) line+=' passes:world '+r.gfx.pass.world+' light '+r.gfx.pass.light+' fog '+r.gfx.pass.fog+' wx '+r.gfx.pass.wx+' hud '+r.gfx.pass.hud;
      if(r.gfx.w95>0) line+=' work:'+r.gfx.w50+'/'+r.gfx.w95+'ms screen:'+(r.gfx.scr||'?')+'hz cap:'+(r.gfx.cap||'off');   // v28.xx (cw-fpswork): what held the frame rate, the game (work near the gap) or something outside it
'@

SubRx @'
gfx:T?{n:T.n,p50:T.p50,p95:T.p95,slow:T.slow,q:T.q}:null};
'@ @'
gfx:T?{n:T.n,p50:T.p50,p95:T.p95,slow:T.slow,q:T.q,w50:T.w50||0,w95:T.w95||0,scr:T.scr||0,cap:T.cap||0}:null};   // v28.xx (cw-fpswork)
'@

SubRx @'
' q '+m.gfx.q):'none')
'@ @'
' q '+m.gfx.q+' work '+m.gfx.w50+'/'+m.gfx.w95+' screen '+m.gfx.scr+' cap '+m.gfx.cap):'none')
'@

SubRx @'
var VER='36.49';
'@ @'
var VER='36.50';
'@

$pat = "(?m)^  now:'v36\.49:.*$"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "DEVNOW now line matched $c times, expected 1" }
$new = "  now:'v36.50: Each raid line in the flight recorder ends its frame numbers with work:p50/p95ms screen:Nhz cap:N, and the party run report carries the same. Check 36.50 fails on v36.49',"
$s = [regex]::Replace($s, $pat, { param($m) $new })
if (([regex]::Matches($s, "(?m)^  now:'")).Count -ne 1) { throw "more than one now key in DEVNOW" }
$script:s = $s

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied plus DEVNOW"
