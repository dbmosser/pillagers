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

if ($s.Contains("  {v:'25.27',what:")) { throw "check 25.27 is in the fixture already" }

SubRx @'
  {v:'25.26',what:
'@ @'
  {v:'25.27',what:'his #50 (UI redesign ui5q2b): the line under the title and the step cards balance their lines, so no word is left alone on a line',
   run:function(){
     var el=document.querySelector('#title .titlecol > div[style*="max-width:760px"]'), tb=document.querySelector('#title .tcard .tbody'), bad=[];
     function bal(e){ var cs=getComputedStyle(e); return ((cs.textWrap||'')+' '+(cs.textWrapStyle||'')).indexOf('balance')>=0; }
     if(!el) return 'no line under the title';
     if(!bal(el)) bad.push('the line under the title does not balance its lines');
     if(tb&&!bal(tb)) bad.push('a step card does not balance its lines');
     return bad.length?bad.join('; '):null; }},
  {v:'25.26',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
