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

if ($s.Contains("  {v:'29.51',what:")) { throw "check 29.51 is in the fixture already" }

SubRx @'
  {v:'29.50',what:
'@ @'
  {v:'29.51',what:'the run over card is centred, 720px x scale wide, content centred (critic: left-aligned box with dead space, screen 55)',
   run:function(){
     if(typeof arcadeOverEl!=='function'||typeof attEl!=='function') return 'SKIP: no arcade overlay here';
     var d, c, wasDisp, z, res=null, w;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       try{ if(typeof attZ==='function') attZ(d); }catch(_z){}
       z=parseFloat(getComputedStyle(d).getPropertyValue('--attz'))||1;
       c=arcadeOverEl(); c.textContent='x'; c.style.display='block';
       w=parseFloat(getComputedStyle(c).width);
       if(getComputedStyle(c).textAlign!=='center') res='the card text is '+getComputedStyle(c).textAlign+', not centre';
       else if(Math.abs(w-720*z)>4 && w<720*z) res='the card is '+w+'px wide, not 720px x '+z;
       return res;
     } finally {
       try{ c.style.display='none'; c.textContent=''; c.removeAttribute('data-at'); d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.50',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
