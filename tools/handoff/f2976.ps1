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

if ($s.Contains("  {v:'29.76',what:")) { throw "check 29.76 is in the fixture already" }

SubRx @'
  {v:'29.75',what:
'@ @'
  {v:'29.76',what:'while the run over card is up, Press any button is one solid accent button as wide as the card and lined up with it, no pulse, and the score is light text so the amber is spent once (critic on v29.74: muddy ghost button, centred under left aligned text, amber twice; screens 52 55)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof attEl!=='function') return 'SKIP: no arcade attract here';
     var d, oc, wasDisp, ap, ar, cr, cs, res=null, s, sc;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       oc=arcadeAttEl('arcover'); oc.style.display='block'; s=document.createElement('div'); s.className='aos'; s.textContent='Score 1 SP'; oc.appendChild(s);
       ap=d.querySelector('.attpress'); cs=getComputedStyle(ap);
       ar=ap.getBoundingClientRect(); cr=oc.getBoundingClientRect(); sc=getComputedStyle(s).color;
       if(cs.backgroundColor!=='rgb(245, 183, 59)') res='Press any button fill is '+cs.backgroundColor+', not the solid accent';
       else if(cs.animationName!=='none') res='Press any button still pulses ('+cs.animationName+')';
       else if(Math.abs(ar.width-cr.width)>3||Math.abs(ar.left-cr.left)>3) res='Press any button is '+Math.round(ar.width)+'px at '+Math.round(ar.left)+', the card is '+Math.round(cr.width)+'px at '+Math.round(cr.left);
       else if(ar.height<48*(parseFloat(d.style.getPropertyValue('--attz'))||1)-2) res='Press any button is only '+Math.round(ar.height)+'px high';
       else if(ar.top-cr.bottom<0||ar.top-cr.bottom>80) res='Press any button sits '+Math.round(ar.top-cr.bottom)+'px under the card';
       else if(sc==='rgb(245, 183, 59)') res='the score is still the accent colour';
       return res;
     } finally {
       try{ oc.textContent=''; oc.style.display='none'; d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.75',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
