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

if ($s.Contains("  {v:'24.93',what:")) { throw "check 24.93 is in the fixture already" }

SubRx @'
  {v:'24.92',what:
'@ @'
  {v:'24.93',what:'his #50 (UI redesign ui5q2e): FEEDBACK in the raid pause row is the same size as SETTINGS (label size and button height)',
   run:function(){
     var f=document.getElementById('fbbtn'), s=document.getElementById('pausesetbtn');
     if(!f||!s) return 'SKIP: no FEEDBACK or SETTINGS in the pause box';
     var cf=getComputedStyle(f), cs=getComputedStyle(s), bad=[];
     if(cf.fontSize!==cs.fontSize) bad.push('FEEDBACK is '+cf.fontSize+' against SETTINGS '+cs.fontSize);
     if(cf.minHeight!==cs.minHeight) bad.push('FEEDBACK is '+cf.minHeight+' high against SETTINGS '+cs.minHeight);
     if(cf.fontWeight!==cs.fontWeight) bad.push('FEEDBACK weight '+cf.fontWeight+' against '+cs.fontWeight);
     return bad.length?bad.join('; '):null; }},
  {v:'24.92',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
