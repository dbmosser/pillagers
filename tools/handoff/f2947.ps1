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

if ($s.Contains("  {v:'29.47',what:")) { throw "check 29.47 is in the fixture already" }

SubRx @'
  {v:'29.46',what:
'@ @'
  {v:'29.47',what:'the run over card is Panel P on the shared look: 1px panel, 32px Run over, 56px score, 20px rows, centred, left aligned (critic: plain card, huge void, screens 52 and 55)',
   run:function(){
     if(typeof arcadeOverEl!=='function'||typeof attEl!=='function') return 'SKIP: no arcade overlay here';
     var d, c, wasDisp, z, cs, h, s, r, res=null, k;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
       z=parseFloat(getComputedStyle(d).getPropertyValue('--attz'))||1;
       c=arcadeOverEl(); c.textContent=''; c.style.display='block';
       for(k=0;k<3;k++){ h=document.createElement('div'); h.className=['aoh','aos','aor'][k]; h.textContent=['Run over','Score 0 SP','You 0 SP'][k]; c.appendChild(h); }
       cs=getComputedStyle(c); h=getComputedStyle(c.querySelector('.aoh')); s=getComputedStyle(c.querySelector('.aos')); r=getComputedStyle(c.querySelector('.aor'));
       if(Math.abs(parseFloat(cs.borderLeftWidth)-1)>0.6) res='the card has no 1px panel border: '+cs.borderLeftWidth;
       else if(Math.abs(parseFloat(cs.paddingLeft)-32*z)>1.5) res='the card padding is '+cs.paddingLeft+', not 32px x '+z;
       else if(Math.abs(parseFloat(h.fontSize)-32*z)>1.5) res='Run over is '+h.fontSize+', not 32px x '+z;
       else if(Math.abs(parseFloat(s.fontSize)-56*z)>1.5) res='the score is '+s.fontSize+', not 56px x '+z;
       else if(Math.abs(parseFloat(r.fontSize)-20*z)>1.5) res='the player row is '+r.fontSize+', not 20px x '+z;
       else if(cs.textAlign!=='left'&&cs.textAlign!=='start') res='the card is '+cs.textAlign+' aligned, not left';
       else if(parseFloat(cs.width)<500*z) res='the card is only '+cs.width+' wide';
       return res;
     } finally {
       try{ c.style.display='none'; c.textContent=''; c.removeAttribute('data-at'); d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.46',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
