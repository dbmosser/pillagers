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

if ($s.Contains("  {v:'34.47',what:")) { throw "check 34.47 is in the fixture already" }

SubRx @'
  {v:'34.46',what:
'@ @'
  {v:'34.47',what:'cw-cx-pixhub (86b): THE PIXEL UNDERCROFT FLOOR. With the pixel look on the hub floor is half size and holds only the 8 tones of its two ramps, the bake is quick and moves no seeded number, with the look off it is full size, and flipping the switch re-bakes it at the next hub entry',
   run:function(){
     if(typeof pixHubSnap!=='function') return 'no pixel hub floor (pixHubSnap)';
     if(!(window.__hubEnter&&window.__hubFrame&&window.__topClear&&window.__runPrep)) return 'SKIP: this fixture cannot draw the floor';
     var bad=[], g0, g1, r0, r1, t0, im, m={}, k, n, f0, oldPix=CFG.xfPix;
     try{
       __topClear(); __runPrep(); __resetCfg(); __pinDefaults(0); __cleanProfile();
       __hubEnter();
       CFG.xfPix=0; RNGS=777; g0=bakeHubGround(); r0=RNGS;
       if(g0.width!==HUBW||g0.height!==HUBH) bad.push('the look off gives a '+g0.width+'x'+g0.height+' floor, not '+HUBW+'x'+HUBH);
       CFG.xfPix=1; RNGS=777; t0=pixNow(); g1=bakeHubGround(); t0=pixNow()-t0; r1=RNGS;
       if(r1!==r0) bad.push('the seeded stream moved: '+r0+' off, '+r1+' on');
       if(g1.width!==Math.ceil(HUBW/PIX_ENV)||g1.height!==Math.ceil(HUBH/PIX_ENV)) bad.push('the look on gives a '+g1.width+'x'+g1.height+' floor');
       if(t0>250) bad.push('the hub bake took '+Math.round(t0)+' ms (over 250)');
       im=g1.getContext('2d').getImageData(0,0,g1.width,g1.height).data;
       for(k=0;k<im.length;k+=4) m[im[k]*65536+im[k+1]*256+im[k+2]]=1;
       n=Object.keys(m).length;
       var allowed={}; PIXHUB.rgb.forEach(function(rgb){ allowed[rgb[0]*65536+rgb[1]*256+rgb[2]]=1; });
       Object.keys(m).forEach(function(rgb){ if(!allowed[rgb]) bad.push('the hub wrote a colour outside its ramps: '+rgb); });
       if(n>8) bad.push('the hub floor holds '+n+' colours (over the 8 of its ramps)');
       if(n<3) bad.push('the hub floor holds only '+n+' colours, so it is flat');
       f0=pixFaults();
       hubGround=g0; __hubFrame(0.016);
       if(hubGround!==g0) bad.push('the floor changed before hub entry');
       __hubEnter(); __hubFrame(0.016);
       if(!(hubGround._pe>1)) bad.push('the floor did not follow the switch to on');
       CFG.xfPix=0; __hubFrame(0.016);
       if(!(hubGround._pe>1)) bad.push('the floor changed before returning to the hub');
       __hubEnter(); __hubFrame(0.016);
       if(hubGround._pe>1) bad.push('the floor did not follow the switch to off');
       if(pixFaults()>f0) bad.push('the pixel paths logged a fault on the floor');
       return bad.length?bad.join('; '):null;
     } catch(err){
       return 'pixel hub check: '+String(err&&err.message||err);
     } finally {
       CFG.xfPix=oldPix; hubGround=null;
       keys={}; __resetCfg(); __topClear(); __cleanProfile(); CFG.xfPix=oldPix;
     } }},
  {v:'34.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
