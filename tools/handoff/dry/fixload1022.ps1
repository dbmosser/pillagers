$files = @('C:\claudecode\dark raiders\tools\handoff\f1022.ps1', 'C:\claudecode\dark raiders\tools\mkfixture.ps1')
$old = "     P2.menuZoom=0.7; try{ saveProfile(); loadProfile(); }catch(e){}`r`n     var P3=__P(); if((P3.menuZoom||0)<1) bad.push('a saved size of 0.7 loads as '+P3.menuZoom+', not 1.0');`r`n     P2=__P();"
$new = "     // The loader is asynchronous (it reads storage and resolves later), so the floor it applies is read from its source rather than awaited.`r`n     if(String(loadProfile).indexOf(['menuZoom','<1)P.menuZoom=1'].join(''))<0) bad.push('the profile loader has no floor: a saved size below 1.0 would load as it was');"
foreach ($f in $files) {
  $t = [IO.File]::ReadAllText($f)
  $o = $old; $nw = $new
  if ($t.IndexOf($o) -lt 0) { $o = $old.Replace("`r`n", "`n"); $nw = $new.Replace("`r`n", "`n") }
  $c = ([regex]::Matches($t, [regex]::Escape($o))).Count
  if ($c -ne 1) { Write-Output "$f : matched $c"; continue }
  $t = $t.Replace($o, $nw); [IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false)); Write-Output "$f : load assertion rewritten"
}
