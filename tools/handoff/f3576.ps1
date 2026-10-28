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

if ($s.Contains("  {v:'35.76',what:")) { throw "check 35.76 is in the fixture already" }

SubRx @'
  {v:'35.75',what:
'@ @'
  {v:'35.76',what:'cw-fpshz: at a 144 cap on a browser that only ever gave 60 frames, the fps plate adds a line naming the browser 60 hz and where to change it; none when the page saw faster frames, at a 60 cap, or in live raid play',
   run:function(){
     if(typeof fpsTick!=='function'||typeof VSYNC==='undefined') return 'no fps counter or screen rate measurement';
     var c0=JSON.stringify(CFG), v0=JSON.stringify(VSYNC), f0={t0:FPSV.t0,n:FPSV.n,fps:FPSV.fps,el:FPSV.el}, box=document.getElementById('fpsbox'), text0=box&&box.textContent, class0=box&&box.className, bad=[], ts=200000, t;
     function read(cap){ CFG.fpsCap=cap; FPSV.t0=0; FPSV.n=0; for(var j=0;j<40;j++) fpsTick(ts+j*16.7); ts+=1000; var el=document.getElementById('fpsbox'), sp=el&&el.querySelector('.fpshz'); return {all:el?el.textContent:'', hint:sp?sp.textContent:''}; }
     try{
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       if(state==='raid'){ try{ __endRaid('abandon'); }catch(_e0){} }
       CFG.showFps=1; VSYNC.ms=1000/60; VSYNC.best=1000/60;
       t=read(144);
       if(t.all.indexOf('60 fps | screen 60')!==0) bad.push('the plate first line changed: '+t.all);
       if(t.hint.indexOf('browser gives 60 hz')!==0) bad.push('no browser line at a 144 cap on a 60 hz browser: '+t.all);
       if(t.hint.indexOf('windows refresh rate')<0||t.hint.indexOf('main display')<0||t.hint.indexOf('hardware acceleration')<0) bad.push('the browser line does not name where to change it: '+t.hint);
       if(t.all!==t.all.toLowerCase()) bad.push('the plate text is not lower case');
       t=read(60); if(t.hint||t.all.indexOf('browser')>=0) bad.push('60 cap shows the browser line: '+t.all);
       VSYNC.best=1000/144; t=read(144);
       if(t.all.indexOf('screen 60')<0) bad.push('the screen 60 callout went away: '+t.all);
       if(t.hint) bad.push('a page that saw 144 hz frames blames the browser: '+t.all);
       VSYNC.best=1000/60; VSYNC.ms=1000/144; t=read(144); if(t.hint) bad.push('144 cap on a 144 screen shows a browser line');
       VSYNC.ms=1000/60;
       __deploy({kit:[],safe:null,mapIx:0,seed:4242});
       if(state==='raid'&&G&&!G.over){ pauseOpen=false; t=read(144); if(t.hint) bad.push('the browser line shows in live raid play: '+t.all); if(t.all.indexOf('screen 60')<0) bad.push('the raid plate lost screen 60: '+t.all); }
       else bad.push('no raid to test live play');
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
  {v:'35.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
