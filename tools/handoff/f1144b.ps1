$ErrorActionPreference = 'Stop'
trap { Write-Output "FAILED: $_"; exit 1 }
$p = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$s = [IO.File]::ReadAllText($p)
$n = 0
function SubRx([string]$old, [string]$new) {
  $pat = ($old -split "`n" | ForEach-Object { [regex]::Escape($_.TrimEnd("`r")) }) -join "\r?\n"
  $c = ([regex]::Matches($script:s, $pat)).Count
  if ($c -ne 1) { throw "regex matched $c times: $($old.Substring(0,[Math]::Min(70,$old.Length)))" }
  $script:s = [regex]::Replace($script:s, $pat, { param($m) $new })
  $script:n++
}

# v11.44: the v10.22 check greps loadProfile's source for the menuZoom floor, but
# v11.44 factored the post-load body into applyLoadedProfile, where that clamp now
# lives. Search both functions so the check holds across the refactor and on
# older builds that still have it inline in loadProfile.
SubRx @'
     if(String(loadProfile).indexOf(['menuZoom','<1)P.menuZoom=1'].join(''))<0) bad.push('the profile loader has no floor: a saved size below 1.0 would load as it was');
'@ @'
     var _lpsrc=String(loadProfile)+((typeof applyLoadedProfile==='function')?(' '+String(applyLoadedProfile)):'');
     if(_lpsrc.indexOf(['menuZoom','<1)P.menuZoom=1'].join(''))<0) bad.push('the profile loader has no floor: a saved size below 1.0 would load as it was');
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
