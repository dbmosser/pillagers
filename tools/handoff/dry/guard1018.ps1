$files = @('C:\claudecode\dark raiders\tools\handoff\f1018.ps1', 'C:\claudecode\dark raiders\tools\mkfixture.ps1')
$old = "  {v:'10.18',what:'pillagers dress from the racks, varied, without spending a seeded roll',`r`n   run:function(){`r`n     var bad=[];`r`n"
$new = "  {v:'10.18',what:'pillagers dress from the racks, varied, without spending a seeded roll',`r`n   run:function(){`r`n     var bad=[];`r`n     if(typeof raiderLook!=='function') return 'pillagers do not draw from the racks: there is no raiderLook';   // THE FINDING on v10.17`r`n"
foreach ($f in $files) {
  $t = [IO.File]::ReadAllText($f)
  $c = ([regex]::Matches($t, [regex]::Escape($old))).Count
  if ($c -ne 1) { $old2 = $old.Replace("`r`n", "`n"); $new2 = $new.Replace("`r`n", "`n"); $c = ([regex]::Matches($t, [regex]::Escape($old2))).Count; if ($c -ne 1) { Write-Output "$f : matched $c"; continue }; $t = $t.Replace($old2, $new2) } else { $t = $t.Replace($old, $new) }
  [IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false)); Write-Output "$f : guarded"
}
