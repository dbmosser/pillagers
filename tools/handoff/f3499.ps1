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

if ($s.Contains("  {v:'34.99',what:")) { throw "check 34.99 is in the fixture already" }

SubRx @'
  {v:'34.98',what:
'@ @'
  {v:'34.99',what:'the bulwark wreck is drawn as big as the live bulwark (his note: bulwark too small)',
   run:function(){
     if(typeof wreckBulwarkK!=='function') return 'the bulwark wreck has no size factor (drawn at 1x)';
     var k=wreckBulwarkK(), m=machMul({kind:'bulwark'});
     if(Math.abs(k-m)>1e-6) return 'wreck factor '+k+' differs from live body factor '+m;
     if(k<1.9) return 'wreck factor '+k+' is under 1.9';
     return null; }},
  {v:'34.98',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
