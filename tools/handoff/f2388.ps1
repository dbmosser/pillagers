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

if ($s.Contains("  {v:'23.88',what:")) { throw "check 23.88 is in the fixture already" }

SubRx @'
  {v:'23.87',what:
'@ @'
  {v:'23.88',what:'graphics program gfx4: a lower Render resolution shrinks only the world canvas; the HUD canvas stays at the screen own pixels (1920 across at 1920x1080 with Low, 1600 at DPR 2 on an 800 wide window), its transform stays at the device ratio, and the Render resolution hint says the world only',
   run:function(){
     if(typeof resize!=='function'||typeof gfxScaleNow!=='function'||!window.__forceSize||!window.__pinDPR) return 'SKIP: this fixture cannot size the canvases';
     var bad=[], s0=CFG.gfxScale, a0=CFG.gfxAuto, d0=JSON.stringify(DRS), dp0=window.devicePixelRatio||1,
         st=[cv.style.width,cv.style.height,hcv.style.width,hcv.style.height], m, row=null, i;
     try{
       CFG.gfxAuto=0;
       __pinDPR(1); __forceSize(1920,1080);
       CFG.gfxScale=0.5; resize();
       if(cv.width!==960||cv.height!==540) bad.push('at Low the world canvas is '+cv.width+'x'+cv.height+', not 960x540 (the render scale stopped biting)');
       if(hcv.width!==1920||hcv.height!==1080) bad.push('at Low the HUD canvas is '+hcv.width+'x'+hcv.height+', not the native 1920x1080, so HUD text goes soft');
       m=ctx.getTransform(); if(Math.abs(m.a-1)>1e-6||Math.abs(m.d-1)>1e-6) bad.push('at Low and DPR 1 the HUD transform scales by '+m.a+', not 1');
       m=wc.getTransform(); if(Math.abs(m.a-0.5)>1e-6) bad.push('at Low the world transform scales by '+m.a+', not 0.5');
       __forceSize(800,600); __pinDPR(2);
       CFG.gfxScale=0.5; resize();
       if(cv.width!==800) bad.push('at DPR 2 and Low the world canvas is '+cv.width+' across, not 800');
       if(hcv.width!==1600||hcv.height!==1200) bad.push('at DPR 2 and Low the HUD canvas is '+hcv.width+'x'+hcv.height+', not 1600x1200');
       m=ctx.getTransform(); if(Math.abs(m.a-2)>1e-6) bad.push('at DPR 2 and Low the HUD transform scales by '+m.a+', not 2');
       CFG.gfxScale=1; resize();
       if(cv.width!==1600||hcv.width!==1600) bad.push('at Full and DPR 2 the canvases are '+cv.width+' and '+hcv.width+' across, not both 1600');
       for(i=0;i<(GAMEOPTS||[]).length;i++) if(GAMEOPTS[i].k==='gfxScale') row=GAMEOPTS[i];
       if(!row) bad.push('Settings has no Render resolution row');
       else if(!(/WORLD/.test(String(row.hint))&&/SHARP/.test(String(row.hint)))) bad.push('the Render resolution hint does not say it is the world only and the text stays sharp: '+row.hint);
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       CFG.gfxScale=s0; CFG.gfxAuto=a0;
       try{ var d=JSON.parse(d0), k; for(k in d) DRS[k]=d[k]; }catch(_d){}
       cv.style.width=st[0]; cv.style.height=st[1]; hcv.style.width=st[2]; hcv.style.height=st[3];
       try{ __pinDPR(dp0); }catch(_p){} try{ resize(); }catch(_r){}
       try{ __topClear(); }catch(_t){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'23.87',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
