# Shift the queued drafts 1049..1054 to 1052..1057: his three notes take 1049
# (text edits in the run report), 1050 (Depot cosmetics), 1051 (the terminal).
# Inside each file every v10.NN with 49 <= NN <= 54 moves by +3; in the files
# of the first queued build (1049, the paper doll) the previous-build
# references to 10.48 become 10.51. Its now-line and check-header anchors name
# the 10.48 text and are fixed by hand once 1051 exists.
$SP = 'C:\claudecode\dark raiders\tools\handoff'
$shift = 3
$kinds = @('p','f','d','a','cm')
$exts = @{ p='.ps1'; f='.ps1'; d='.txt'; a='.txt'; cm='.txt' }
$re = [regex]'10\.(\d\d)'
for ($n = 1054; $n -ge 1049; $n--) {
  foreach ($k in $kinds) {
    $src = Join-Path $SP ("$k$n" + $exts[$k])
    if (-not (Test-Path $src)) { Write-Output "missing $k$n"; continue }
    $t = [IO.File]::ReadAllText($src)
    $isFirst = ($n -eq 1049)
    $u = $re.Replace($t, { param($m) $v = [int]$m.Groups[1].Value
      if ($v -ge 49 -and $v -le 54) { return '10.' + ($v + $shift) }
      if ($v -eq 48 -and $isFirst) { return '10.51' }
      return $m.Value })
    $dst = Join-Path $SP ("$k" + ($n + $shift) + $exts[$k])
    [IO.File]::WriteAllText($dst, $u, (New-Object Text.UTF8Encoding $false))
    Remove-Item $src
    Write-Output ("$k$n -> $k" + ($n + $shift))
  }
}
