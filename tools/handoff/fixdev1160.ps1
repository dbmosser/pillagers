# After renumber1160.ps1: shift the ESCAPED previous-version reference inside
# each moved p-file's DEVNOW regex by the same +1. p(n) for n in 1160..1171
# carries 11\.(n-1102) and needs 11\.(n-1101). Literal replacement, no regex.
$SP = 'C:\claudecode\dark raiders\tools\handoff'
foreach ($n in 1160..1171) {
  $f = Join-Path $SP ("p$n.ps1")
  if (-not (Test-Path $f)) { Write-Output "missing p$n"; continue }
  $cur = $n - 1102
  $t = [IO.File]::ReadAllText($f)
  $old = '11\.' + $cur
  $new = '11\.' + ($cur + 1)
  $c = ([regex]::Matches($t, [regex]::Escape($old))).Count
  if ($c -ne 2) { Write-Output ("p$n : expected 2 escaped refs to '$old', found $c") }
  $t = $t.Replace($old, $new)
  [IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false))
  Write-Output ("p$n : $c x '$old' -> '$new'")
}
