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

if ($s.Contains("  {v:'21.64',what:")) { throw "check 21.64 is in the fixture already" }

SubRx @'
  {v:'21.63',what:
'@ @'
  {v:'21.64',what:'a hit on a weak point says WEAK SPOT, not the part name and a multiplier',
   run:function(){
     var src=[].slice.call(document.scripts).map(function(s){ return s.text||''; }).join(''), nd='WK.name+'+"'  x'+WK.mult";
     if(src.indexOf(nd)>=0) return 'a weak point hit still shows the part name and its multiplier (OPTIC 2X)';
     if(src.indexOf("'WEAK "+"SPOT'")<0) return 'a weak point hit does not say WEAK SPOT';
     return null; }},
  {v:'21.63',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
