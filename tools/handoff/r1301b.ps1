$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$old = @'
       var bl=document.getElementById('barlist'), bln=document.getElementById('bar_line');
       var bt=((bl&&bl.textContent)||'')+' '+((bln&&bln.textContent)||'');
'@
$new = @'
       // v13.01 moved the live total into its own element, so a number can never take
       // his edited sentence off the line he wrote. All three are what he sees.
       var bl=document.getElementById('barlist'), bln=document.getElementById('bar_line'),
           bnw=document.getElementById('bar_now');
       var bt=((bl&&bl.textContent)||'')+' '+((bln&&bln.textContent)||'')+' '+((bnw&&bnw.textContent)||'');
'@
$pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
$c = ([regex]::Matches($s, $pat)).Count
if ($c -ne 1) { throw "regex matched $c times" }
$s = [regex]::Replace($s, $pat, { param($m) $new })
[IO.File]::WriteAllText($p, $s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, 1 edit applied"
