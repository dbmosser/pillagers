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

if ($s.Contains("  {v:'29.66',what:")) { throw "check 29.66 is in the fixture already" }

SubRx @'
  {v:'29.65',what:
'@ @'
  {v:'29.66',what:'the attract pages sit on a spotlight backdrop, Press any button is pinned 8 percent from the bottom, the how to play card is 840px x scale with a line under the header row (critic: flat black, 32px prompt, faint headers, screens 46 56 64)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof arcadeAttHow!=='function'||typeof attEl!=='function') return 'SKIP: no arcade attract here';
     var d, pg, wasDisp, z, res=null, ap, th, w;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
       z=parseFloat(getComputedStyle(d).getPropertyValue('--attz'))||1;
       pg=arcadeAttEl('arcpage'); pg.textContent=''; arcadeAttHow(pg); pg.style.display='block';
       ap=d.querySelector('.attpress'); th=pg.querySelector('th'); w=parseFloat(getComputedStyle(pg).width);
       if(getComputedStyle(d).backgroundImage.indexOf('radial-gradient')<0) res='the attract backdrop is still flat black';
       else if(Math.abs(parseFloat(getComputedStyle(d).height)-ap.getBoundingClientRect().bottom-parseFloat(getComputedStyle(d).height)*0.08)>2) res='Press any button is not pinned 8 percent from the bottom';
       else if(Math.abs(w-840*z)>3) res='the how to play card is '+w+'px wide, not 840px x '+z;
       else if(parseFloat(getComputedStyle(th).borderBottomWidth)<1) res='no line under the header row';
       return res;
     } finally {
       try{ pg.textContent=''; pg.style.display='none'; d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.65',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
