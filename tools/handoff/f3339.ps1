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

if ($s.Contains("  {v:'33.39',what:")) { throw "check 33.39 is in the fixture already" }

SubRx @'
  {v:'33.38',what:
'@ @'
  {v:'33.39',what:'cw-cornercompact2: the first corner cell is labelled cash and the two columns are 20 apart',
   run:function(){
     if(typeof trRow!=='function'||typeof trColDraw!=='function') return 'SKIP: no corner rows here';
     if(String(trColDraw).indexOf("'cash'")<0) return 'the money cell has no cash label';
     if(String(trRow).indexOf('cw+20')<0) return 'the two columns are not 20 apart';
     return null; }},
  {v:'33.38',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
