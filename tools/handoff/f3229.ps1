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

if ($s.Contains("  {v:'32.29',what:")) { throw "check 32.29 is in the fixture already" }

SubRx @'
  {v:'32.28',what:
'@ @'
  {v:'32.29',what:'the picked item-wheel wedge is a raised neutral grey, not the warm olive fill (critic 61)',
   run:function(){
     if(typeof wheelFill!=='function') return 'the wheel wedge fill has no function (wheelFill)';
     var a=wheelFill(true,true), n=wheelFill(false,false), pr=function(s){ var m=/rgba\((\d+),(\d+),(\d+)/.exec(s); return [+m[1],+m[2],+m[3]]; }, c=pr(a[0]), d=pr(n[0]);
     if(c[0]-c[2]>12) return 'the picked wedge is still warm: '+a[0];
     if(c[0]<=d[0]+12) return 'the picked wedge is not raised above the idle ones';
     return null;
   }},
  {v:'32.28',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
