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

if ($s.Contains("  {v:'23.61',what:")) { throw "check 23.61 is in the fixture already" }

SubRx @'
  {v:'23.60',what:
'@ @'
  {v:'23.61',what:'gfx1, his order 2026-10-12 (the graphics program): frame telemetry, the real frame gap of live raid frames in G.tel.gfx (n, p50, p95, slow, q), one frame in 15 timed per render pass, carried in the run record; a bot raid keeps none',
   run:function(){
     var bad=[], g=null, T, i, nm=['world','light','fog','wx','hud'], cap0=CFG.fpsCap, pre=null, rec=null, sg=null, simOn=false;
     try{
       if(!(window.__gfxStage&&window.__state&&window.__endRaid&&window.__simRaidBegin&&window.__simRaidStep&&window.__simRaidEnd)) return 'SKIP: this fixture has no gfx stage or steppable sim raid';
       CFG.fpsCap=0;
       g=__gfxStage({frames:90});
       if(!g) return 'SKIP: __gfxStage built no raid';
       if(g.sim) return 'SKIP: the staged raid is a sim raid';
       T=g.tel&&g.tel.gfx;
       if(!T) return 'no G.tel.gfx after 90 live raid frames';
       if(!(T.n>=60&&T.n<=91)) bad.push(T.n+' frames counted of 90');
       if(!(T.p50>=10&&T.p50<=30)) bad.push('p50 is '+T.p50+' ms for 16.7 ms frames');
       if(!(T.p95>=T.p50&&T.p95<=100)) bad.push('p95 is '+T.p95+' ms against p50 '+T.p50);
       if(!(T.slow>=0&&T.slow<=2)) bad.push(T.slow+' slow frames among 16.7 ms ones');
       if(!(T.q>0&&T.q<=1)) bad.push('the render scale reads '+T.q);
       if(!T.pass) bad.push('no pass timings after 90 drawn frames');
       else {
         if(!(T.pass.n>=4&&T.pass.n<=8)) bad.push('passes timed on '+T.pass.n+' frames of 90, not one in 15');
         for(i=0;i<nm.length;i++) if(!(typeof T.pass[nm[i]]==='number'&&T.pass[nm[i]]>=0)) bad.push('no '+nm[i]+' pass time');
       }
       pre=(typeof pendingRun!=='undefined')?pendingRun:null;
       __endRaid('abandon');
       rec=(typeof pendingRun!=='undefined')?pendingRun:null;
       if(rec&&rec!==pre){
         if(!rec.gfx) bad.push('the run record carries no gfx row');
         else if(rec.gfx.n!==T.n||rec.gfx.p50!==T.p50) bad.push('the run record gfx row ('+rec.gfx.n+' frames, p50 '+rec.gfx.p50+') is not the raid one');
       }
       __simRaidBegin(4242); simOn=true; sg=G;
       for(i=0;i<20&&__simRaidStep(0.15);i++){}
       if(sg&&sg.tel&&sg.tel.gfx) bad.push('a bot (sim) raid carries tel.gfx');
       __simRaidEnd(); simOn=false;
       if(sg&&sg.simResult&&sg.simResult.gfx) bad.push('a bot raid result carries gfx');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       keys={}; CFG.fpsCap=cap0;
       if(simOn){ try{ __simRaidEnd(); }catch(_se){} }
       try{ var g2=__state(); if(g2&&!g2.over&&!g2.sim) __endRaid('abandon'); }catch(_e){}
       __topClear();
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.60',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
