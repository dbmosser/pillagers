# Shift the queued audit drafts 1159..1170 to 1160..1171, freeing 1159 for the
# throwable-on-a-belt-key fix found by the 2026-09-06 read-only raid audit.
# Inside each file every plain v11.NN with 59 <= NN <= 70 moves by +1; in the
# files of the first queued build (1159, the Wirt lot) the previous-build
# references to 11.58 become 11.59. The ESCAPED "11\.NN" in each p-file's DEVNOW
# regex is NOT matched here: run fixdev1160.ps1 straight after.
$SP = 'C:\claudecode\dark raiders\tools\handoff'
$shift = 1
$kinds = @('p','f','d','a','cm')
$exts = @{ p='.ps1'; f='.ps1'; d='.txt'; a='.txt'; cm='.txt' }
$re = [regex]'11\.(\d\d)'
for ($n = 1170; $n -ge 1159; $n--) {
  foreach ($k in $kinds) {
    $src = Join-Path $SP ("$k$n" + $exts[$k])
    if (-not (Test-Path $src)) { Write-Output "missing $k$n"; continue }
    $t = [IO.File]::ReadAllText($src)
    $isFirst = ($n -eq 1159)
    $u = $re.Replace($t, { param($m) $v = [int]$m.Groups[1].Value
      if ($v -ge 59 -and $v -le 70) { return '11.' + ($v + $shift) }
      if ($v -eq 58 -and $isFirst) { return '11.59' }
      return $m.Value })
    $dst = Join-Path $SP ("$k" + ($n + $shift) + $exts[$k])
    [IO.File]::WriteAllText($dst, $u, (New-Object Text.UTF8Encoding $false))
    Remove-Item $src
    Write-Output ("$k$n -> $k" + ($n + $shift))
  }
}
