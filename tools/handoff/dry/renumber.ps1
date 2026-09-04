# Shift the queued drafts 1022..1037 to 1031..1046 (his notes take 1022..1030).
# Inside each file every v10.NN with 22 <= NN <= 37 moves by +7; in the files of
# the first queued build (1022) the previous-build references to 10.21 become
# 10.28, the last of his-notes builds. Anchors on the 1021 check text and the
# 1021 now-line in the moved 1029 files are fixed by hand afterwards.
$SP = 'C:\claudecode\dark raiders\tools\handoff'
$shift = 1
$kinds = @('p','f','d','a','cm')
$exts = @{ p='.ps1'; f='.ps1'; d='.txt'; a='.txt'; cm='.txt' }
$re = [regex]'10\.(\d\d)'
for ($n = 1046; $n -ge 1031; $n--) {
  foreach ($k in $kinds) {
    $src = Join-Path $SP ("$k$n" + $exts[$k])
    if (-not (Test-Path $src)) { Write-Output "missing $k$n"; continue }
    $t = [IO.File]::ReadAllText($src)
    $isFirst = ($n -eq 1031)
    $u = $re.Replace($t, { param($m) $v = [int]$m.Groups[1].Value
      if ($v -ge 31 -and $v -le 46) { return '10.' + ($v + $shift) }
      if ($v -eq 30 -and $isFirst) { return '10.31' }
      return $m.Value })
    $dst = Join-Path $SP ("$k" + ($n + $shift) + $exts[$k])
    [IO.File]::WriteAllText($dst, $u, (New-Object Text.UTF8Encoding $false))
    Remove-Item $src
    Write-Output ("$k$n -> $k" + ($n + $shift))
  }
}
