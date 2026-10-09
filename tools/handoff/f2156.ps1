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

if ($s.Contains("  {v:'21.56',what:")) { throw "check 21.56 is in the fixture already" }

SubRx @'
  {v:'21.55',what:
'@ @'
  {v:'21.56',what:'the full controls list names F9, the recorder',
   run:function(){
     if(typeof LEGEND==='undefined') return 'SKIP: no controls list here';
     if(typeof recStart!=='function') return 'SKIP: no recorder here';
     var hit=LEGEND.some(function(g){ return (g[1]||[]).some(function(r){ return r[0]==='F9'; }); });
     return hit?null:'the full controls list does not say F9 records your play';
   }},
  {v:'21.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
