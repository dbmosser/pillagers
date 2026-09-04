$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}
SubRx @'
window.__stashRules={sellable:function(k){ return !!sellable(k); },
'@ @'
window.__shelf=function(){ var o={},k;
  for(k in ITEMS) o[k]=(typeof stashTabOf==='function'?stashTabOf(k):'?')+'/'+(sellable(k)?'sells':'kept')+'/'+((typeof itemWanted==='function'&&itemWanted(k))||'-');
  return o; };
window.__stashRules={sellable:function(k){ return !!sellable(k); },
'@
$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
