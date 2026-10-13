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

if ($s.Contains("  {v:'24.47',what:")) { throw "check 24.47 is in the fixture already" }

SubRx @'
  {v:'24.46',what:
'@ @'
  {v:'24.47',what:'graphics program gfx6: the quality ladder: slow frames shed the extras before the resolution (post pass off, soft sheets at two thirds, HIGH lighting drawn as STANDARD, one rung a second) and only then step the render scale down; smooth frames climb back scale first, then every rung; a rung already off in Settings is passed over; the rung rests at 0 outside a raid',
   run:function(){
     if(typeof drsTick!=='function'||typeof DRS==='undefined') return 'SKIP: the game has no auto resolution';
     if(typeof GFXQ==='undefined'||typeof gfxqApply!=='function'||typeof gfxLightNow!=='function') return 'auto resolution still sheds only the resolution: no quality ladder (GFXQ)';
     if(typeof resize!=='function'||typeof litC==='undefined') return 'SKIP: no canvas in this fixture';
     var bad=[], c0=CFG.gfxAuto, s0=CFG.gfxScale, f0=CFG.fpsCap, p0=CFG.gfxPost, l0=CFG.gfxLight, d0=JSON.stringify(DRS), oSwf=sayWhenFree, lines=[], t=0, i, seq=[], last='', w0, w2, k;
     function reset(){ DRS.scale=1; DRS.ema=0; DRS.slowT=0; DRS.fastT=0; DRS.last=0; DRS.bounce=0; DRS.upAt=0; DRS.said=0; DRS.q=0; gfxqApply(); }
     function cur(){ return (DRS.q|0)+'/'+DRS.scale; }
     function note(){ var s=cur(); if(s!==last){ seq.push(s); last=s; } }
     function mark(){ seq=[]; last=cur(); }
     try{
       sayWhenFree=function(s,kk,o){ lines.push(String(s)); };
       CFG.gfxAuto=1; CFG.gfxScale=1; CFG.fpsCap=0; CFG.gfxPost=1; CFG.gfxLight=2; reset();
       resize(); w0=litC.width; mark();
       for(i=0;i<63;i++){ t+=40; drsTick(40,t); note(); }
       if(!(GFXQ.post===0)) bad.push('2.5 seconds of slow frames left the post pass on (GFXQ.post '+GFXQ.post+')');
       if(DRS.scale!==1) bad.push('2.5 seconds of slow frames already stepped the render scale to '+DRS.scale+', before the extras');
       if(gfxLightNow()!==2) bad.push('the first rung already changed the lighting (gfxLightNow '+gfxLightNow()+')');
       for(i=0;i<1500&&DRS.scale>=1;i++){ t+=40; drsTick(40,t); note(); }
       if(!(DRS.scale<1)) bad.push('a minute of slow frames never stepped the render scale ('+seq.join(' ')+')');
       if(seq.slice(0,4).join(' ')!=='1/1 2/1 3/1 3/0.9') bad.push('the steps went '+seq.join(' ')+', not post, sheets, shadows, then the scale');
       if(!(GFXQ.lmap<1)) bad.push('rung 2 left the soft sheets at full size (GFXQ.lmap '+GFXQ.lmap+')');
       if(gfxLightNow()!==1) bad.push('rung 3 did not draw HIGH as STANDARD (gfxLightNow '+gfxLightNow()+')');
       if(lines.length!==1) bad.push('the steps said '+JSON.stringify(lines)+', want only the one resolution line');
       resize(); w2=litC.width;
       if(!(w2<w0)) bad.push('the soft sheets did not shrink on rung 2 ('+w0+' to '+w2+')');
       mark();
       for(i=0;i<5000&&((DRS.q|0)>0||DRS.scale<1);i++){ t+=16; drsTick(16,t); note(); }
       if((DRS.q|0)!==0||DRS.scale!==1||GFXQ.post!==1||GFXQ.lmap!==1||GFXQ.shadow!==1) bad.push('smooth frames left the ladder at rung '+DRS.q+' scale '+DRS.scale);
       else if(seq.join(' ')!=='3/1 2/1 1/1 0/1') bad.push('the climb back went '+seq.join(' ')+', not the scale first and then each rung');
       // rungs already off in Settings are passed over: POST FX OFF and LIGHTING STANDARD leave only the sheets rung
       CFG.gfxPost=0; CFG.gfxLight=1; reset(); mark();
       for(i=0;i<1500&&DRS.scale>=1;i++){ t+=40; drsTick(40,t); note(); }
       if(seq.slice(0,2).join(' ')!=='2/1 2/0.9') bad.push('with POST FX OFF and LIGHTING STANDARD the steps went '+seq.join(' ')+', not the sheets then the scale');
       // outside a raid the rung rests at 0 (the frame loop line)
       k=[].slice.call(document.scripts).map(function(s){ return s.textContent||''; }).join('\n');
       if(k.indexOf('DRS.scale'+'!==1||DRS.q)){ DRS.scale=1; DRS.q=0; }')<0) bad.push('the frame loop does not rest the rung with the scale');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{
       sayWhenFree=oSwf; CFG.gfxAuto=c0; CFG.gfxScale=s0; CFG.fpsCap=f0; CFG.gfxPost=p0; CFG.gfxLight=l0;
       try{ var d=JSON.parse(d0), kk; for(kk in d) DRS[kk]=d[kk]; DRS.q=d.q|0; }catch(_d){}
       try{ resize(); }catch(_r){}
     }
     return bad.length?bad.join('; '):null; }},
  {v:'24.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
