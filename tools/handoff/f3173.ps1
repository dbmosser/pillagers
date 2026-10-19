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

if ($s.Contains("  {v:'31.73',what:")) { throw "check 31.73 is in the fixture already" }

SubRx @'
  {v:'31.72',what:
'@ @'
  {v:'31.73',what:'the party card prompt is 24px (not 20px) so the eye lands on it (critic on 46 55 56 64: press any key is the same size as the table text)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof arcadeAttHow!=='function'||typeof attEl!=='function') return 'SKIP: no arcade attract here';
     var d, pg, wasDisp, oz, res=null, ap, fs;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       oz=d.style.getPropertyValue('--attz'); d.setAttribute('data-attz','1'); d.style.setProperty('--attz','1');
       pg=arcadeAttEl('arcpage'); pg.textContent=''; arcadeAttHow(pg); pg.style.display='block';
       ap=d.querySelector('.attpress'); if(!ap) return 'SKIP: no prompt';
       fs=parseFloat(getComputedStyle(ap).fontSize);
       if(fs<23.9||fs>24.1) res='the card prompt draws at '+fs+'px, not the 24px step';
       return res;
     } finally {
       try{ pg.textContent=''; pg.style.display='none'; d.style.display=wasDisp; d.setAttribute('data-attz',''); if(oz) d.style.setProperty('--attz',oz); else d.style.removeProperty('--attz'); if(typeof attZ==='function') attZ(d); }catch(_f){}
     }
   }},
  {v:'31.72',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
