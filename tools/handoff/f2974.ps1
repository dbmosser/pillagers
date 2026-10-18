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

if ($s.Contains("  {v:'29.74',what:")) { throw "check 29.74 is in the fixture already" }

SubRx @'
  {v:'29.73',what:
'@ @'
  {v:'29.74',what:'while the run over card is up, the card and Press any button are one column centred on the screen, the button a plate under the card (a 1px accent line, under 80px below it), not loose text at the bottom and not pushed down by the clip element (critic: card floats in a void, prompt detached; screens 52 55)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof attEl!=='function') return 'SKIP: no arcade attract here';
     var d, oc, wasDisp, ap, ar, cr, cs, res=null, v, mid, half;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       v=d.querySelector('video'); if(!v){ v=document.createElement('video'); v.setAttribute('data-cwtest','1'); d.insertBefore(v,d.firstChild); }
       oc=arcadeAttEl('arcover'); oc.style.display='block';
       ap=d.querySelector('.attpress'); cs=getComputedStyle(ap);
       ar=ap.getBoundingClientRect(); cr=oc.getBoundingClientRect();
       mid=(cr.top+ar.bottom)/2; half=d.getBoundingClientRect().height/2;
       if(cs.position!=='relative') res='Press any button is '+cs.position+', not in the card column';
       else if(parseFloat(cs.borderTopWidth)<1) res='Press any button has no plate line';
       else if(ar.top-cr.bottom<0||ar.top-cr.bottom>80) res='Press any button sits '+Math.round(ar.top-cr.bottom)+'px under the card, not within 80px';
       else if(Math.abs((ar.left+ar.right)/2-(cr.left+cr.right)/2)>3) res='Press any button is not centred under the card';
       else if(Math.abs(mid-half)>60) res='the card and button sit at '+Math.round(mid)+'px, not about the middle of the screen ('+Math.round(half)+')';
       return res;
     } finally {
       try{ oc.style.display='none'; d.style.display=wasDisp; if(v&&v.getAttribute('data-cwtest')) v.remove(); }catch(_f){}
     }
   }},
  {v:'29.73',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
