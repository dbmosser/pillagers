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

if ($s.Contains("  {v:'31.79',what:")) { throw "check 31.79 is in the fixture already" }

SubRx @'
  {v:'31.78',what:
'@ @'
  {v:'31.79',what:'a downed partner sounds a clear alert and his edge arrow pulses (his 2.72 a)',
   run:function(){
     if(typeof mateArrowPulse!=='function'||typeof sndMateAlert!=='function') return 'no partner alert sound and no arrow pulse (mateArrowPulse, sndMateAlert missing)';
     var a=mateArrowPulse(1,0), b=mateArrowPulse(1,125), c=mateArrowPulse(0,125), lo=9, hi=0, i, v;
     for(i=0;i<500;i++){ v=mateArrowPulse(1,i*2); if(v<lo) lo=v; if(v>hi) hi=v; }
     if(c!==1) return 'an arrow of a partner who is up pulses';
     if(a===b) return 'the downed arrow does not change over time';
     if(lo<0.99||hi>1.51||hi-lo<0.4) return 'the pulse range is wrong: '+lo+' to '+hi;
     if(String(netOnState).indexOf('sndMateAlert')<0) return 'the partner down word does not play the alert';
     if(String(netMateArrow).indexOf('mateArrowPulse')<0) return 'the edge arrow does not use the pulse';
     var r=sndMateAlert(); if(r!==true&&r!==false) return 'the alert did not return a result';
     return null;
   }},
  {v:'31.78',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
