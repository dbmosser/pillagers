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

if ($s.Contains("  {v:'29.69',what:")) { throw "check 29.69 is in the fixture already" }

SubRx @'
  {v:'29.68',what:
'@ @'
  {v:'29.69',what:'while an attract page is up the title and prompt have no dark band and no accent underline, and the operator card has no drop shadow (critic: letterbox bands, two amber stubs, shadow on the guide-banned list; screens 46 56 62 63 64)',
   run:function(){
     if(typeof arcadeAttEl!=='function'||typeof arcadeAttBoard!=='function'||typeof attEl!=='function') return 'SKIP: no arcade attract here';
     var d, pg, wasDisp, res=null, nm, ap, af;
     try{
       __topClear(); __runPrep();
       d=attEl(); wasDisp=d.style.display; d.style.display='block';
       pg=arcadeAttEl('arcpage'); pg.textContent=''; arcadeAttBoard(pg); pg.style.display='block';
       nm=d.querySelector('.attname'); ap=d.querySelector('.attpress');
       if(getComputedStyle(nm).backgroundImage!=='none') res='the title still sits on a dark band';
       else if(getComputedStyle(ap).backgroundImage!=='none') res='the prompt still sits on a dark band';
       else if(getComputedStyle(nm,'::after').display!=='none') res='the wordmark still has the accent underline';
       else if(/box-shadow:0 24px 64px/.test(String(arcadeOpOpen))) res='the operator card still has a drop shadow';
       return res;
     } finally {
       try{ pg.textContent=''; pg.style.display='none'; d.style.display=wasDisp; }catch(_f){}
     }
   }},
  {v:'29.68',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
