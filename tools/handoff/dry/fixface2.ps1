$SP = 'C:\claudecode\dark raiders\tools\handoff'
$long = "   // v10.18, his answer 20; v10.21: faceMark, because e.face is the facing angle and a string there stopped every pillager firing"
foreach ($n in 1022..1026) {
  $f = Join-Path $SP "p$n.ps1"
  $lines = [IO.File]::ReadAllLines($f)
  $changed = 0
  for ($i = 0; $i -lt $lines.Length; $i++) {
    $l = $lines[$i]
    if ($l.IndexOf('_look.hair') -ge 0 -and $l.IndexOf('_look.eyes') -ge 0) {
      $u = $l.Replace('face:_look.face,', 'faceMark:_look.face,')
      if ($u.IndexOf($long) -lt 0) { $u = $u.Replace('   // v10.18, his answer 20', $long) }
      if ($u -ne $l) { $lines[$i] = $u; $changed++ }
    }
  }
  [IO.File]::WriteAllLines($f, $lines, (New-Object Text.UTF8Encoding $false))
  Write-Output "p$n : $changed lines fixed"
}
