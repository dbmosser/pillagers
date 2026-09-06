# Shift the queued audit drafts 1153..1164 to 1159..1170: his six in-run notes of
# 2026-09-05 (A to F in START-HERE.md) take 1153 to 1158. Inside each file every
# plain v11.NN with 53 <= NN <= 64 moves by +6; in the files of the first queued
# build (1153, the Wirt lot) the previous-build references to 11.52 become 11.58,
# which will be note F's version. The escaped "11\.NN" inside each p-file's
# DEVNOW regex is NOT matched here: run fixdev1159.ps1 straight after.
$SP = 'C:\claudecode\dark raiders\tools\handoff'
$shift = 6
$kinds = @('p','f','d','a','cm')
$exts = @{ p='.ps1'; f='.ps1'; d='.txt'; a='.txt'; cm='.txt' }
$re = [regex]'11\.(\d\d)'
for ($n = 1164; $n -ge 1153; $n--) {
  foreach ($k in $kinds) {
    $src = Join-Path $SP ("$k$n" + $exts[$k])
    if (-not (Test-Path $src)) { Write-Output "missing $k$n"; continue }
    $t = [IO.File]::ReadAllText($src)
    $isFirst = ($n -eq 1153)
    $u = $re.Replace($t, { param($m) $v = [int]$m.Groups[1].Value
      if ($v -ge 53 -and $v -le 64) { return '11.' + ($v + $shift) }
      if ($v -eq 52 -and $isFirst) { return '11.58' }
      return $m.Value })
    $dst = Join-Path $SP ("$k" + ($n + $shift) + $exts[$k])
    [IO.File]::WriteAllText($dst, $u, (New-Object Text.UTF8Encoding $false))
    Remove-Item $src
    Write-Output ("$k$n -> $k" + ($n + $shift))
  }
}
