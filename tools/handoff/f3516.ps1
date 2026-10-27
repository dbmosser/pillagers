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

if ($s.Contains("  {v:'35.16',what:")) { throw "check 35.16 is in the fixture already" }

SubRx @'
  {v:'35.15',what:
'@ @'
  {v:'35.16',what:'cw-cx-fpsscreen: the fps counter says screen 60 at a 144 cap on a settled 16.7 ms screen; no callout with cap off, at or below the screen rate, within 5 fps, before measurement, or counter off',
   run:function(){
     if(typeof fpsTick!=='function'||typeof VSYNC==='undefined') return 'no fps counter or screen rate measurement';
     var c0=JSON.stringify(CFG), v0=JSON.stringify(VSYNC), f0={t0:FPSV.t0,n:FPSV.n,fps:FPSV.fps,el:FPSV.el}, box=document.getElementById('fpsbox'), text0=box&&box.textContent, class0=box&&box.className, bad=[], ts=100000;
     function read(cap){ CFG.fpsCap=cap; FPSV.t0=0; FPSV.n=0; for(var j=0;j<40;j++) fpsTick(ts+j*16.7); ts+=1000; return document.getElementById('fpsbox').textContent; }
     function noScreen(cap,label){ var text=read(cap); if(text.indexOf('screen')>=0) bad.push(label+' shows '+text); }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       CFG.showFps=1; VSYNC.ms=16.7;
       var text=read(144);
       if(text.indexOf('screen 60')<0) bad.push('144 cap on a 16.7 ms screen reads '+text);
       if(text.indexOf('60 fps')!==0) bad.push('the measured fps changed: '+text);
       if(text!==text.toLowerCase()) bad.push('the counter text is not lower case');
       noScreen(60,'60 cap'); noScreen(30,'30 cap'); noScreen(0,'cap off');
       VSYNC.ms=1000/60; noScreen(65,'cap exactly 5 above screen');
       if(read(66).indexOf('screen 60')<0) bad.push('cap more than 5 above screen has no callout');
       VSYNC.ms=1000/144; noScreen(144,'144 cap on a 144 screen');
       VSYNC.ms=0; noScreen(144,'unsettled screen measurement');
       VSYNC.ms=16.7; read(144); CFG.showFps=0; fpsTick(ts);
       if(document.getElementById('fpsbox').className==='on') bad.push('counter off leaves the plate visible');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       try{ __endRaid('abandon'); }catch(_e){} __topClear();
       var cs=JSON.parse(c0), vs=JSON.parse(v0), k, el=document.getElementById('fpsbox');
       for(k in CFG) if(!(k in cs)) delete CFG[k]; for(k in cs) CFG[k]=cs[k];
       for(k in VSYNC) if(!(k in vs)) delete VSYNC[k]; for(k in vs) VSYNC[k]=vs[k];
       FPSV.t0=f0.t0; FPSV.n=f0.n; FPSV.fps=f0.fps; FPSV.el=f0.el;
       if(box){ box.textContent=text0; box.className=class0; }else if(el&&el.parentNode) el.parentNode.removeChild(el);
     }
     return bad.length?bad.join('; '):null;
   }},
  {v:'35.15',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
