# Correction to renumberHUD.ps1: its escaped pass used the OLD tag number, so
# it looked for 11\.(old-1102) when the file actually carries 11\.(old-1101).
# For a file now at NEW tag m, the stale escaped reference is 11\.(m-1102) and
# it must become 11\.(m-1101). Literal replacement, p-files only.
$SP = 'C:\claudecode\dark raiders\tools\handoff'
foreach ($n in 1159..1172) {
  $f = Join-Path $SP ("p$n.ps1")
  if (-not (Test-Path $f)) { Write-Output "missing p$n"; continue }
  $t = [IO.File]::ReadAllText($f)
  $old = '11\.' + ($n - 1102)
  $new = '11\.' + ($n - 1101)
  $c = ([regex]::Matches($t, [regex]::Escape($old))).Count
  if ($c -eq 0) { Write-Output ("p$n : nothing to do (already 11\." + ($n - 1101) + ")"); continue }
  $t = $t.Replace($old, $new)
  [IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false))
  Write-Output ("p$n : $c x '$old' -> '$new'")
}
