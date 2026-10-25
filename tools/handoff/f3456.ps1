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

if ($s.Contains("  {v:'34.56',what:")) { throw "check 34.56 is in the fixture already" }

SubRx @'
  {v:'34.55',what:
'@ @'
  {v:'34.56',what:'cw-setrevert2 (job 113): the experimental page footer hint size comes from the label token, not a raw px literal',
   run:function(){
     var css=(document.getElementById('ui-shared')||{textContent:''}).textContent;
     if(/settingsmodal\.expmode::after\{[^}]*font-size\s*:\s*[\d.]+px/.test(css)) return 'the expmode footer hint has a raw font-size literal';
     if(!/settingsmodal\.expmode::after\{[^}]*font-size:var\(--fs-label\)/.test(css)) return 'the expmode footer hint is not on the label token';
     return null; }},
  {v:'34.55',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
