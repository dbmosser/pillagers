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

if ($s.Contains("  {v:'29.32',what:")) { throw "check 29.32 is in the fixture already" }

SubRx @'
  {v:'29.31',what:
'@ @'
  {v:'29.32',what:'the title button reads Create a new save, not Create A new save (the article A lowers with its line)',
   run:function(){
     var a=TX('CREATE A NEW SAVE'), b=TX('SECTOR A'), c=TX('ENTER RAID!');
     if(a!=='Create a new save') return 'CREATE A NEW SAVE reads "'+a+'"';
     if(b!=='Sector A') return 'a lone sector letter changed: "'+b+'"';
     if(c!=='Enter raid!') return 'other text changed: "'+c+'"';
     return null;
   }},
  {v:'29.31',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
