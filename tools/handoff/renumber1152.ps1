# Shift the queued drafts 1152..1163 to 1153..1164: his 2026-09-05 note (credits
# and XP shown at all times in the upper right) takes 1152. Inside each file every
# v11.NN with 52 <= NN <= 63 moves by +1; in the files of the first queued build
# (1152, the Wirt lot) the previous-build references to 11.51 become 11.52. The
# f-file anchor of that first build names the 11.51 check text and is fixed by
# hand after (it must name the NEW 11.52 check's what-line).
$SP = 'C:\claudecode\dark raiders\tools\handoff'
$shift = 1
$kinds = @('p','f','d','a','cm')
$exts = @{ p='.ps1'; f='.ps1'; d='.txt'; a='.txt'; cm='.txt' }
$re = [regex]'11\.(\d\d)'
for ($n = 1163; $n -ge 1152; $n--) {
  foreach ($k in $kinds) {
    $src = Join-Path $SP ("$k$n" + $exts[$k])
    if (-not (Test-Path $src)) { Write-Output "missing $k$n"; continue }
    $t = [IO.File]::ReadAllText($src)
    $isFirst = ($n -eq 1152)
    $u = $re.Replace($t, { param($m) $v = [int]$m.Groups[1].Value
      if ($v -ge 52 -and $v -le 63) { return '11.' + ($v + $shift) }
      if ($v -eq 51 -and $isFirst) { return '11.52' }
      return $m.Value })
    $dst = Join-Path $SP ("$k" + ($n + $shift) + $exts[$k])
    [IO.File]::WriteAllText($dst, $u, (New-Object Text.UTF8Encoding $false))
    Remove-Item $src
    Write-Output ("$k$n -> $k" + ($n + $shift))
  }
}
