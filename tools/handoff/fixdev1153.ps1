# After renumber1152.ps1: that tool matches plain "11.NN" and cannot see the
# ESCAPED form "11\.NN" inside each p-file's DEVNOW regex, so every shifted
# p-file still looked for the previous build's now-line. Shift the escaped
# form too: in p(1102+k) the escaped 11\.(k-1)... becomes 11\.k. Literal
# string replacement, no regex, no shell quoting.
$SP = 'C:\claudecode\dark raiders\tools\handoff'
foreach ($n in 1153..1164) {
  $f = Join-Path $SP ("p$n.ps1")
  $cur = $n - 1102
  $t = [IO.File]::ReadAllText($f)
  $old = '11\.' + $cur
  $new = '11\.' + ($cur + 1)
  $c = ([regex]::Matches($t, [regex]::Escape($old))).Count
  $t = $t.Replace($old, $new)
  [IO.File]::WriteAllText($f, $t, (New-Object Text.UTF8Encoding $false))
  Write-Output ("p$n : $c x '$old' -> '$new'")
}
