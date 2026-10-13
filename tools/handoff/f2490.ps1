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

if ($s.Contains("  {v:'24.89',what:")) { throw "check 24.89 is in the fixture already" }

SubRx @'
  {v:'24.88',what:
'@ @'
  {v:'24.89',what:'his #50 (UI redesign ui5q1y, the 4K attract pictures): the attract name and PRESS ANY BUTTON keep growing past a 1440p size (their caps are at least 160px and 230px)',
   run:function(){
     var src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join(''), bad=[];
     if(src.indexOf('clamp(26px,3.6vw,'+'84px)')>=0) bad.push('PRESS ANY BUTTON stops growing at 84px');
     if(src.indexOf('clamp(30px,5vw,'+'120px)')>=0) bad.push('the attract name stops growing at 120px');
     if(src.indexOf('clamp(26px,3.6vw,'+'168px)')<0) bad.push('control: PRESS ANY BUTTON has no 168px cap');
     return bad.length?bad.join('; '):null; }},
  {v:'24.88',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
