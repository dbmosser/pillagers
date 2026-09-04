$f = 'C:\claudecode\dark raiders\tools\mkfixture.ps1'
$t = [IO.File]::ReadAllText($f)
$old = "      var mz2=(__P().menuZoom||1);`r`n      wheel(floor,100,false);`r`n      var mz3=(__P().menuZoom||1);"
$new = "      var mz2=(__P().menuZoom||1);`r`n      wheel(floor,-100,false);   // v10.22: upward, because the size floors at 1.0 and this check starts there`r`n      var mz3=(__P().menuZoom||1);"
if ($t.IndexOf($old) -lt 0) { $old = $old.Replace("`r`n", "`n"); $new = $new.Replace("`r`n", "`n") }
$c = ([regex]::Matches($t, [regex]::Escape($old))).Count
if ($c -ne 1) { Write-Output "matched $c"; exit 1 }
$t = $t.Replace($old, $new); [IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false)); Write-Output "9.95 control spins upward"
