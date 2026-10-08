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

if ($s.Contains("  {v:'19.81',what:")) { throw "check 19.81 is in the fixture already" }

SubRx @'
  {v:'19.80',what:
'@ @'
  {v:'19.81',what:'the lift page row names are readable: SURFACE and WEATHER beside the day and weather buttons are drawn at 13px or more',
   run:function(){
     var bad=[], a=document.querySelector('#sectorcond > span'), b=document.querySelector('#sectorwx > span');
     if(!a||!b) return 'SKIP: no surface or weather row here';
     [a,b].forEach(function(s){ var f=parseFloat(getComputedStyle(s).fontSize); if(!(f>=12.9)) bad.push(s.textContent.trim()+' is '+f+'px'); });
     return bad.length?bad.join('; '):null; }},
  {v:'19.80',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
