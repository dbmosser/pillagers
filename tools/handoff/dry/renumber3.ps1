# Shift the queued drafts 1048..1053 to 1049..1054: his night-density note takes
# 1048. Inside each file every v10.NN with 48 <= NN <= 53 moves by +1; in the
# files of the first queued build (1048, the paper doll) the previous-build
# references to 10.47 become 10.48. The now-line anchor and the check-header
# anchor of that first build name the 10.47 text and are fixed by hand after.
$SP = 'C:\claudecode\dark raiders\tools\handoff'
$shift = 1
$kinds = @('p','f','d','a','cm')
$exts = @{ p='.ps1'; f='.ps1'; d='.txt'; a='.txt'; cm='.txt' }
$re = [regex]'10\.(\d\d)'
for ($n = 1053; $n -ge 1048; $n--) {
  foreach ($k in $kinds) {
    $src = Join-Path $SP ("$k$n" + $exts[$k])
    if (-not (Test-Path $src)) { Write-Output "missing $k$n"; continue }
    $t = [IO.File]::ReadAllText($src)
    $isFirst = ($n -eq 1048)
    $u = $re.Replace($t, { param($m) $v = [int]$m.Groups[1].Value
      if ($v -ge 48 -and $v -le 53) { return '10.' + ($v + $shift) }
      if ($v -eq 47 -and $isFirst) { return '10.48' }
      return $m.Value })
    $dst = Join-Path $SP ("$k" + ($n + $shift) + $exts[$k])
    [IO.File]::WriteAllText($dst, $u, (New-Object Text.UTF8Encoding $false))
    Remove-Item $src
    Write-Output ("$k$n -> $k" + ($n + $shift))
  }
}
