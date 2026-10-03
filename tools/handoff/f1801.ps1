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

if ($s.Contains("  {v:'18.01',what:")) { throw "check 18.01 is in the fixture already" }

SubRx @'
  {v:'18.00',what:
'@ @'
  {v:'18.01',what:'auto resolution: two seconds of slow frames step the render scale down one notch and the canvas shrinks on the next resize, smooth frames step it back up, it never goes under Low, Settings has the row, and with the row Off the scale stays at the Render resolution row',
   run:function(){
     if(typeof drsTick!=='function'||typeof DRS==='undefined') return 'the game has no auto resolution';
     if(typeof resize!=='function'||typeof cv==='undefined') return 'SKIP: no canvas in this fixture';
     var bad=[], c0=CFG.gfxAuto, s0=CFG.gfxScale, f0=CFG.fpsCap, d0=JSON.stringify(DRS), i, w1, w2, sc, ks=(GAMEOPTS||[]).map(function(o){ return o.k; }), oSwf=sayWhenFree, lines=[], t=0;
     if(ks.indexOf('gfxAuto')<0) bad.push('Settings has no Auto resolution row');
     try{
       sayWhenFree=function(s){ lines.push(String(s)); };
       CFG.gfxAuto=1; CFG.gfxScale=1; CFG.fpsCap=0; DRS.scale=1; DRS.ema=0; DRS.slowT=0; DRS.fastT=0; DRS.last=0; DRS.bounce=0; DRS.upAt=0; DRS.said=0;
       resize(); w1=cv.width;
       for(i=0;i<120;i++){ t+=16; drsTick(16,t); }
       if(DRS.scale!==1) bad.push('smooth frames moved the scale to '+DRS.scale);
       for(i=0;i<1500;i++){ t+=40; drsTick(40,t); }
       if(!(DRS.scale<1)) bad.push('slow frames left the scale at '+DRS.scale);
       if(DRS.scale<0.5-1e-6) bad.push('the scale fell under Low: '+DRS.scale);
       if(Math.abs(DRS.scale-0.5)>1e-6) bad.push('a minute of slow frames stopped at '+DRS.scale+', not at Low');
       if(lines.length!==1||!/stepped down/.test(lines[0])) bad.push('the first step down said '+JSON.stringify(lines));
       resize(); w2=cv.width;
       if(!(w2<w1*0.6)) bad.push('the canvas did not shrink ('+w1+' to '+w2+')');
       sc=DRS.scale;
       for(i=0;i<1500;i++){ t+=16; drsTick(16,t); }
       if(!(DRS.scale>sc)) bad.push('smooth frames did not step the scale back up (still '+DRS.scale+')');
       CFG.gfxAuto=0; DRS.scale=0.7; if(gfxScaleNow()!==1) bad.push('with auto Off the scale still bites: '+gfxScaleNow());
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ sayWhenFree=oSwf; CFG.gfxAuto=c0; CFG.gfxScale=s0; CFG.fpsCap=f0; try{ var d=JSON.parse(d0), k; for(k in d) DRS[k]=d[k]; }catch(_d){} try{ resize(); }catch(_r){} }
     return bad.length?bad.join('; '):null; }},
  {v:'18.00',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
