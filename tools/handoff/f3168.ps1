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

if ($s.Contains("  {v:'31.68',what:")) { throw "check 31.68 is in the fixture already" }

SubRx @'
  {v:'31.67',what:
'@ @'
  {v:'31.68',what:'the party cards never draw a label under 16px: the how to play table heads and the board seeded night line stay 16px at a small menu scale (critic on 46 52 55 56 64: labels about 14px)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof arcadeAttHow!=='function'||typeof attEl!=='function'||typeof arcadeAttLine!=='function') return 'SKIP: no arcade attract here';
     var d, pg, wasDisp, oz, res=null, th, ap;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       oz=d.style.getPropertyValue('--attz'); d.setAttribute('data-attz','0.7'); d.style.setProperty('--attz','0.7');
       pg=arcadeAttEl('arcpage'); pg.textContent=''; arcadeAttHow(pg); arcadeAttLine(pg,'apb','SEEDED NIGHT'); pg.style.display='block';
       th=pg.querySelector('th'); ap=pg.querySelector('.apb');
       if(!th||!ap) return 'SKIP: no head or line';
       if(parseFloat(getComputedStyle(th).fontSize)<15.99) res='a table head draws at '+getComputedStyle(th).fontSize+', under 16px';
       else if(parseFloat(getComputedStyle(ap).fontSize)<15.99) res='the seeded night line draws at '+getComputedStyle(ap).fontSize+', under 16px';
       return res;
     } finally {
       try{ pg.textContent=''; pg.style.display='none'; d.style.display=wasDisp; d.setAttribute('data-attz',''); if(oz) d.style.setProperty('--attz',oz); else d.style.removeProperty('--attz'); if(typeof attZ==='function') attZ(d); }catch(_f){}
     }
   }},
  {v:'31.67',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
