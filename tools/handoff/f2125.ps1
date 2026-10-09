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

if ($s.Contains("  {v:'21.25',what:")) { throw "check 21.25 is in the fixture already" }

SubRx @'
  {v:'21.24',what:
'@ @'
  {v:'21.25',what:'hit ticks draw with real numbers even when the crosshair is over a HUD panel: the tick block has its own screen factor',
   run:function(){
     if(typeof drawHUD!=='function') return 'SKIP: no HUD here';
     var src=String(drawHUD), i=src.indexOf('var hIn='), seg=src.slice(i,i+260), nd='*'+'_rz';
     if(i<0) return 'SKIP: no hit ticks here';
     if(seg.indexOf(nd)>=0) return 'the hit ticks still use the cross factor, which is not set when the crosshair is over a HUD panel';
     return null; }},
  {v:'21.24',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
