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

if ($s.Contains("  {v:'31.46',what:")) { throw "check 31.46 is in the fixture already" }

SubRx @'
  {v:'31.45',what:
'@ @'
  {v:'31.46',what:'the any-key prompt is body size (20px) so the title leads, and the corner X shares the prompt right line (critic 46 52 64)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof attEl!=='function') return 'SKIP: no arcade here';
     var d, wasDisp, pg, pr, fs, xr, mr, z, res=null;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
       pg=arcadeAttEl('arcpage'); pg.style.display='block';
       pr=d.querySelector('.attpress'); if(!pr) return 'SKIP: no attpress';
       z=parseFloat(getComputedStyle(d).getPropertyValue('--attz'))||1;
       fs=parseFloat(getComputedStyle(pr).fontSize);
       if(fs>20.5*z+0.01) return 'the any-key prompt is '+fs+'px, over the 20px body size (zoom '+z+')';
       xr=getComputedStyle(pg,'::after').right; mr=getComputedStyle(pr).marginRight;
       if(xr!==mr) return 'the corner X right edge is '+xr+' but the prompt right margin is '+mr;
       return res;
     } finally {
       try{ pg.style.display='none'; d.style.display=wasDisp; }catch(_f){}
       __topClear();
     } }},
  {v:'31.45',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
