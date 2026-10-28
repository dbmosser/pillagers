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

if ($s.Contains("  {v:'35.34',what:")) { throw "check 35.34 is in the fixture already" }

SubRx @'
  {v:'35.33',what:
'@ @'
  {v:'35.34',what:'cw-titleplain, his order 2026-10-27 (no graphics behind the title, no robots in the Undercroft): with the title up a frame builds no floor, paints the world canvas one flat dark colour and leaves the HUD canvas empty; the floor never runs the title fight (a pillager and a sentry), not even behind the attract pages; nobody in the crowd wears The Machine; and with the title gone a frame builds and draws the floor as before',
   run:function(){
     if(typeof loop!=='function'||typeof titleOn!=='function'||typeof hubRollLook!=='function'||typeof wc==='undefined'||!wc||typeof hcv==='undefined'||!hcv) return 'SKIP: no loop, title, crowd or canvases in this fixture';
     if(!(window.__loop&&window.__hubEnter&&window.__hubFrame&&window.__forceSize&&window.__pinDPR&&window.__runPrep&&window.__topClear&&window.__resetCfg&&window.__pinDefaults)) return 'SKIP: this fixture cannot drive the frame loop';
     if(typeof ctxLost!=='undefined'&&ctxLost) return 'SKIP: the canvas context is lost in this tab, so no frame draws';
     var bad=[], t=document.getElementById('title'), was=t&&t.classList.contains('on'), st0=state, HB0=HB, TSK0=TSK, att0=ATT.on, i, d, k, f, n=0, sk=0, hl=0, lk, rob=0, dressed=0;
     function px(c){ return c.getContext('2d').getImageData(0,0,c.width,c.height).data; }
     function fr(){ __loop(performance.now()+16.7); __loop(performance.now()+33.4); }
     try{
       if(!t) return 'SKIP: no title in this fixture';
       __runPrep(); __topClear(); __resetCfg(); __pinDefaults(0); __pinDPR(1); __forceSize(1920,1080);
       // 1. the title up and no floor yet, as on boot: two frames of the real loop
       t.classList.add('on'); state='hub'; HB=null; TSK=null;
       fr();
       if(HB) bad.push('a floor was built under the title');
       if(TSK) bad.push('the title fight ran under the title');
       d=px(cv); f=[d[0],d[1],d[2],d[3]];
       for(k=0;k<d.length;k+=4*211){ n++; if(d[k]!==f[0]||d[k+1]!==f[1]||d[k+2]!==f[2]||d[k+3]!==f[3]) sk++; }
       if(sk) bad.push(sk+' of '+n+' world canvas samples under the title differ from its backdrop: something is drawn behind the title');
       if(!(f[3]===255&&f[0]<40&&f[1]<40&&f[2]<40)) bad.push('the backdrop under the title is not a solid dark colour: '+f.join(','));
       d=px(hcv); for(k=3;k<d.length;k+=4*211) if(d[k]>0) hl++;
       if(hl) bad.push(hl+' lit HUD canvas samples under the title');
       // 2. the real floor with the attract pages over it (the arcade attract, the title gone): the fight is never put on it
       t.classList.remove('on'); HB=null; TSK=null;
       __hubEnter();
       if(!HB) bad.push('control: entering the Undercroft built no floor');
       else { ATT.on=true; try{ for(i=0;i<3;i++) __hubFrame(0.016); } finally { ATT.on=att0; } }
       if(TSK) bad.push('the title fight was put on the Undercroft floor behind the attract pages');
       // 3. the crowd: The Machine never rolls, the other outfits still do
       for(i=0;i<400;i++){ lk=hubRollLook(); if(lk.outfit==='outrobot') rob++; else if(lk.outfit&&lk.outfit!=='outnone') dressed++; }
       if(rob) bad.push(rob+' of 400 Undercroft crowd looks wear The Machine (a robot)');
       if(dressed<20) bad.push('control: only '+dressed+' of 400 crowd looks wear an outfit');
       // 4. control: with the title gone the real loop draws the floor as before
       t.classList.remove('on'); state='hub'; fr();
       d=px(cv); f=[d[0],d[1],d[2]]; sk=0;
       for(k=0;k<d.length;k+=4*211) if(d[k]!==f[0]||d[k+1]!==f[1]||d[k+2]!==f[2]) sk++;
       if(sk<100) bad.push('control: with the title gone the floor frame has only '+sk+' varied samples');
     }catch(e){ bad.push('threw: '+(e&&e.message||e)); }
     finally{ ATT.on=att0; TSK=TSK0; if(was&&t) t.classList.add('on'); else if(t) t.classList.remove('on'); state=st0; if(HB0) HB=HB0; try{ __topClear(); }catch(_c){} }
     return bad.length?bad.join('; '):null; }},
  {v:'35.33',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
