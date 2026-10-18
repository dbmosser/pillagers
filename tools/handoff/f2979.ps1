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

if ($s.Contains("  {v:'29.79',what:")) { throw "check 29.79 is in the fixture already" }

SubRx @'
  {v:'29.78',what:
'@ @'
  {v:'29.79',what:'while the run over card is up, Press any button is a 56px (x scale) accent button, flush right under the card and not as wide as it (critic on v29.76: a 108px full width slab was the loudest thing on screen; screens 52 55)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof attEl!=='function') return 'SKIP: no arcade attract here';
     var d, oc, wasDisp, ap, ar, cr, z, res=null, s;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       oc=arcadeAttEl('arcover'); oc.style.display='block'; s=document.createElement('div'); s.className='aos'; s.textContent='Score 1 SP'; oc.appendChild(s);
       ap=d.querySelector('.attpress'); ar=ap.getBoundingClientRect(); cr=oc.getBoundingClientRect();
       z=parseFloat(d.style.getPropertyValue('--attz'))||1;
       if(Math.abs(ar.height-56*z)>3) res='Press any button is '+Math.round(ar.height)+'px high, not '+Math.round(56*z);
       else if(ar.width>cr.width*0.6) res='Press any button is '+Math.round(ar.width)+'px wide under a '+Math.round(cr.width)+'px card';
       else if(Math.abs(ar.right-cr.right)>3) res='Press any button ends at '+Math.round(ar.right)+', the card at '+Math.round(cr.right);
       return res;
     } finally {
       try{ oc.textContent=''; oc.style.display='none'; d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
