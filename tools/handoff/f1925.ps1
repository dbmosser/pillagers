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

if ($s.Contains("  {v:'19.25',what:")) { throw "check 19.25 is in the fixture already" }

SubRx @'
  {v:'19.24',what:
'@ @'
  {v:'19.25',what:'the lift small print is readable: what he takes up and the no-armour warning are at least 14 px, and the day and weather hints at least 13',
   run:function(){
     var k=document.getElementById('sectorkit'), c=document.getElementById('condhint'), w=document.getElementById('wxhint'), bad=[], f;
     if(!k||!c||!w) return 'SKIP: no lift page here';
     f=parseFloat(k.style.fontSize); if(!(f>=14)) bad.push('the going up with box is '+f+' px');
     f=parseFloat(c.style.fontSize); if(!(f>=13)) bad.push('the day hint is '+f+' px');
     f=parseFloat(w.style.fontSize); if(!(f>=13)) bad.push('the weather hint is '+f+' px');
     return bad.length?bad.join('; '):null; }},
  {v:'19.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
