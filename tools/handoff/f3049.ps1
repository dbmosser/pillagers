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

if ($s.Contains("  {v:'30.49',what:")) { throw "check 30.49 is in the fixture already" }

SubRx @'
  {v:'30.48',what:
'@ @'
  {v:'30.49',what:'the Run info box shows at most the 3 contracts closest to done (his Q1, 10-18)',
   run:function(){
     if(typeof runInfoCap!=='function') return 'no runInfoCap: the Run info box still lists every contract';
     var r=runInfoCap([{left:5,txt:'e'},{left:1,txt:'a'},{left:3,txt:'c'},{left:2,txt:'b'},{left:4,txt:'d'},{left:6,txt:'f'}]);
     if(r.length!==3) return 'it keeps '+r.length+' contracts, not 3';
     if(r.map(function(x){return x.txt;}).join('')!=='abc') return 'it keeps '+r.map(function(x){return x.txt;}).join('')+', not the 3 closest (abc)';
     if(runInfoCap([{left:2,txt:'x'}]).length!==1) return 'one contract is lost';
     if(String(drawHUD).indexOf('runInfoCap(_live)')<0) return 'drawHUD does not use runInfoCap';
     return null; }},
  {v:'30.48',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
