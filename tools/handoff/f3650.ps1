$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
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

if ($s.Contains("  {v:'36.50',what:")) { throw "check 36.50 is in the fixture already" }

SubRx @'
  {v:'36.49',what:
'@ @'
  {v:'36.50',what:'cw-fpswork, the FPS czar (2026-10-29): five raids of 10-28 ran at a steady 30 fps and the run line could not say why. Every live raid frame files the game own work, and the run line prints work p50/p95, the screen rate and the frame cap beside the frame gap (the party run report too)',
   run:function(){
     if(!(window.__deploy&&window.__state&&window.__endRaid&&window.__P)) return 'SKIP: this fixture cannot end a raid';
     if(typeof gfxWorkTel!=='function') return 'a raid files no work per frame: no gfxWorkTel in this build';
     if(String(render2D).indexOf('gfxWorkTel(DRS.workMs)')<0) return 'the frame loop does not file its own work (render2D never calls gfxWorkTel)';
     var cap0=CFG.fpsCap, vs0=VSYNC.ms, P=window.__P(), bad=[], g, i, n0, rec, txt;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __deploy({kit:[],safe:null,mapIx:0,seed:4242}); g=__state();
       if(!g||g.over||g.sim||!g.tel) return 'SKIP: no live raid with telemetry';
       CFG.fpsCap=144; VSYNC.ms=1000/60; GFXT.g=null; delete g.tel.gfx;
       for(i=0;i<20;i++){ gfxTel(33.3); gfxWorkTel(i<18?3:9); }
       if(!g.tel.gfx||g.tel.gfx.w50!==3.25||g.tel.gfx.w95!==9.25) bad.push('the raid filed work '+(g.tel.gfx?g.tel.gfx.w50+'/'+g.tel.gfx.w95:'none')+', not 3.25/9.25 ms');
       if(!g.tel.gfx||g.tel.gfx.scr!==60||g.tel.gfx.cap!==144) bad.push('the raid filed screen '+(g.tel.gfx&&g.tel.gfx.scr)+' and cap '+(g.tel.gfx&&g.tel.gfx.cap)+', not 60 and 144');
       if(P.log&&P.log.length>40) P.log.splice(0,P.log.length-40);
       n0=(P.log||[]).length; g.player.downed=false;
       __endRaid('extract');
       rec=(P.log&&P.log.length>n0)?P.log[P.log.length-1]:null;
       if(!rec||!rec.gfx) bad.push('control: the extraction banked no run with frame numbers');
       else if(rec.gfx.w50!==3.25||rec.gfx.w95!==9.25||rec.gfx.scr!==60||rec.gfx.cap!==144) bad.push('the banked run keeps work '+rec.gfx.w50+'/'+rec.gfx.w95+' screen '+rec.gfx.scr+' cap '+rec.gfx.cap+', not 3.25/9.25, 60, 144');
       txt=String(buildExport());
       if(txt.indexOf('gfx:33.25/33.25ms')<0) bad.push('control: the run line has no 33 ms frame gap');
       if(txt.indexOf(' work:3.25/9.25ms screen:60hz cap:144')<0) bad.push('the run line does not print work:3.25/9.25ms screen:60hz cap:144');
       if(String(demoReportPost).indexOf("' work '")<0) bad.push('the party run report posts no work figure');
       return bad.length?bad.join('; '):null;
     } finally { CFG.fpsCap=cap0; VSYNC.ms=vs0; try{ __topClear(); __cleanProfile(); }catch(_c){} }
   }},
  {v:'36.49',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
