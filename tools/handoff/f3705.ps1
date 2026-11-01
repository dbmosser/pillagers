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

if ($s.Contains("  {v:'37.05',what:")) { throw "check 37.05 is in the fixture already" }

SubRx @'
  {v:'37.04',what:
'@ @'
  {v:'37.05',what:'dead functions with no caller are gone, batch 2 (cw-dead2)',
   run:function(){
     var bad=[];
     if(typeof gfxLightNow!=='undefined') bad.push('gfxLightNow');
     if(typeof gfxWet!=='undefined') bad.push('gfxWet');
     if(typeof sizeTag!=='undefined') bad.push('sizeTag');
     if(typeof countArmor!=='undefined') bad.push('countArmor');
     if(typeof uiKey!=='undefined') bad.push('uiKey');
     if(typeof goalsHud!=='undefined') bad.push('goalsHud');
     if(typeof arcadeBagFree!=='undefined') bad.push('arcadeBagFree');
     if(typeof arcadeQuickHeal!=='undefined') bad.push('arcadeQuickHeal');
     if(typeof arcadeAutoSrch!=='undefined') bad.push('arcadeAutoSrch');
     if(bad.length) return 'still defined: '+bad.join(', ');
     return null; }},
  {v:'37.04',what:
'@

$src = [IO.File]::ReadAllText($MyInvocation.MyCommand.Definition)
$want = ([regex]::Matches($src, "(?m)^SubRx @'")).Count
if ($n -ne $want) { throw "expected $want edits, made $n" }
[IO.File]::WriteAllText($p, $script:s, (New-Object Text.UTF8Encoding $false))
Write-Output "OK, $n edits applied"
