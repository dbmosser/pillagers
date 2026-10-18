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

if ($s.Contains("  {v:'29.73',what:")) { throw "check 29.73 is in the fixture already" }

SubRx @'
  {v:'29.72',what:
'@ @'
  {v:'29.73',what:'while the run over card is up, Press any button is a plate under the card (a 1px accent line, in the same centred column, under 60px below it), not loose text pinned at the bottom (critic: card floats in a void, prompt detached; screens 52 55)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof attEl!=='function') return 'SKIP: no arcade attract here';
     var d, oc, wasDisp, ap, ar, cr, cs, res=null;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       oc=arcadeAttEl('arcover'); oc.style.display='block';
       ap=d.querySelector('.attpress'); cs=getComputedStyle(ap);
       ar=ap.getBoundingClientRect(); cr=oc.getBoundingClientRect();
       if(cs.position!=='relative') res='Press any button is '+cs.position+', not in the card column';
       else if(parseFloat(cs.borderTopWidth)<1) res='Press any button has no plate line';
       else if(ar.top-cr.bottom<0||ar.top-cr.bottom>80) res='Press any button sits '+Math.round(ar.top-cr.bottom)+'px under the card, not within 80px';
       else if(Math.abs((ar.left+ar.right)/2-(cr.left+cr.right)/2)>3) res='Press any button is not centred under the card';
       return res;
     } finally {
       try{ oc.style.display='none'; d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
