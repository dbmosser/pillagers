$SP = 'C:\claudecode\dark raiders\tools\handoff'
$old = "eyes:_look.eyes, face:_look.face,   // v10.18, his answer 20"
$new = "eyes:_look.eyes, faceMark:_look.face,   // v10.18, his answer 20; v10.21: faceMark, because e.face is the facing angle and a string there stopped every pillager firing"
foreach ($n in 1022..1026) {
  $f = Join-Path $SP "p$n.ps1"
  $t = [IO.File]::ReadAllText($f)
  $c = ([regex]::Matches($t, [regex]::Escape($old))).Count
  if ($c -gt 0) { $t = $t.Replace($old, $new); [IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false)); Write-Output "p$n : $c replaced" } else { Write-Output "p$n : no old text" }
}
$f = Join-Path $SP 'f1021.ps1'
$t = [IO.File]::ReadAllText($f)
$o2 = "return !e.face||!cosFind(e.face)||cosFind(e.face).kind!=='face';"
$n2 = "return !e.faceMark||!cosFind(e.faceMark)||cosFind(e.faceMark).kind!=='face';"
if ($t.IndexOf($o2) -ge 0) { $t = $t.Replace($o2, $n2); [IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false)); Write-Output "f1021 : control now reads faceMark" } else { Write-Output "f1021 : control text not found" }
