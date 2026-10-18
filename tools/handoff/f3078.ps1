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

if ($s.Contains("  {v:'30.78',what:")) { throw "check 30.78 is in the fixture already" }

SubRx @'
  {v:'30.77',what:
'@ @'
  {v:'30.78',what:'the how to play card has the 48px ghost X in its top right corner (critic 46 56)',
   run:function(){
     if(typeof arcadeAttHow!=='function'||typeof arcadeAttEl!=='function'||typeof attEl!=='function') return 'SKIP: no arcade here';
     var d, pg, wasDisp, cs, w, z=1;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
       pg=arcadeAttEl('arcpage'); pg.textContent='';
       arcadeAttHow(pg); pg.style.display='block'; pg.style.translate='none'; pg.style.opacity='1';
       cs=getComputedStyle(pg,'::after');
       if(!cs||cs.content==='none'||cs.content==='normal') return 'no X drawn on the how to play card: content '+(cs&&cs.content);
       w=parseFloat(cs.width);
       if(!(w>=40)) return 'the X is '+w+'px wide, not 48';
       if(cs.position!=='absolute') return 'the X is not in the corner: '+cs.position;
       return null;
     } finally {
       try{ pg.textContent=''; pg.style.display='none'; d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'30.77',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
