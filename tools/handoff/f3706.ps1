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

if ($s.Contains("  {v:'37.06',what:")) { throw "check 37.06 is in the fixture already" }

SubRx @'
  {v:'37.05',what:
'@ @'
  {v:'37.06',what:'dead functions with no caller are gone, batch 3 (cw-dead3)',
   run:function(){
     var bad=[];
     if(typeof notoBite!=='undefined') bad.push('notoBite');
     if(typeof mapFirstFoot!=='undefined') bad.push('mapFirstFoot');
     if(typeof autoCull!=='undefined') bad.push('autoCull');
     if(typeof needGlow!=='undefined') bad.push('needGlow');
     if(typeof netSndToggle!=='undefined') bad.push('netSndToggle');
     if(typeof netP2Key!=='undefined') bad.push('netP2Key');
     if(typeof legDock!=='undefined') bad.push('legDock');
     if(typeof pixSwap!=='undefined') bad.push('pixSwap');
     if(bad.length) return 'still defined: '+bad.join(', ');
     return null; }},
  {v:'37.05',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
