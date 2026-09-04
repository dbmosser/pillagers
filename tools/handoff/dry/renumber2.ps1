# Shift the cosmetics drafts cos/1037..1047 to 1043..1053 (the alpha builds took
# 1037..1042). Inside each file every v10.NN with 37 <= NN <= 47 moves by +6; in
# the files of the first queued build (1037) the previous-build references to
# 10.36 become 10.42. The now-line anchor and the check-header anchor of the
# first build name the 10.36 text and are fixed by hand afterwards. The cos/
# originals are left in place.
$SP = 'C:\claudecode\dark raiders\tools\handoff'
$shift = 6
$kinds = @('p','f','d','a','cm')
$exts = @{ p='.ps1'; f='.ps1'; d='.txt'; a='.txt'; cm='.txt' }
$re = [regex]'10\.(\d\d)'
for ($n = 1047; $n -ge 1037; $n--) {
  foreach ($k in $kinds) {
    $src = Join-Path $SP ("cos\" + "$k$n" + $exts[$k])
    if (-not (Test-Path $src)) { Write-Output "missing $k$n"; continue }
    $t = [IO.File]::ReadAllText($src)
    $isFirst = ($n -eq 1037)
    $u = $re.Replace($t, { param($m) $v = [int]$m.Groups[1].Value
      if ($v -ge 37 -and $v -le 47) { return '10.' + ($v + $shift) }
      if ($v -eq 36 -and $isFirst) { return '10.42' }
      return $m.Value })
    $dst = Join-Path $SP ("$k" + ($n + $shift) + $exts[$k])
    [IO.File]::WriteAllText($dst, $u, (New-Object Text.UTF8Encoding $false))
    Write-Output ("$k$n -> $k" + ($n + $shift))
  }
}
