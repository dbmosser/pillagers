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

if ($s.Contains("  {v:'37.07',what:")) { throw "check 37.07 is in the fixture already" }

SubRx @'
  {v:'37.06',what:
'@ @'
  {v:'37.07',what:'the dead title fight code is gone, tskOn stays (cw-dead4)',
   run:function(){
     var bad=[];
     if(typeof tskRnd!=='undefined') bad.push('tskRnd');
     if(typeof tskInit!=='undefined') bad.push('tskInit');
     if(typeof tskSpark!=='undefined') bad.push('tskSpark');
     if(typeof tskShot!=='undefined') bad.push('tskShot');
     if(typeof tskStep!=='undefined') bad.push('tskStep');
     if(typeof tskDraw!=='undefined') bad.push('tskDraw');
     if(typeof tskOn!=='function') bad.push('tskOn is gone');
     if(bad.length) return 'wrong: '+bad.join(', ');
     return null; }},
  {v:'37.06',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
