# Shift the queue 1158..1171 to 1159..1172, freeing 1158 for the Undercroft HUD
# erase fix found by the 2026-09-06 menu audit. Two passes, because the plain
# regex cannot see the ESCAPED "11\.NN" inside each p-file's DEVNOW regex.
$SP = 'C:\claudecode\dark raiders\tools\handoff'
$shift = 1
$kinds = @('p','f','d','a','cm')
$exts = @{ p='.ps1'; f='.ps1'; d='.txt'; a='.txt'; cm='.txt' }
$re = [regex]'11\.(\d\d)'
for ($n = 1171; $n -ge 1158; $n--) {
  foreach ($k in $kinds) {
    $src = Join-Path $SP ("$k$n" + $exts[$k])
    if (-not (Test-Path $src)) { Write-Output "missing $k$n"; continue }
    $t = [IO.File]::ReadAllText($src)
    $isFirst = ($n -eq 1158)
    # pass one: plain v11.NN
    $u = $re.Replace($t, { param($m) $v = [int]$m.Groups[1].Value
      if ($v -ge 58 -and $v -le 71) { return '11.' + ($v + $shift) }
      if ($v -eq 57 -and $isFirst) { return '11.58' }
      return $m.Value })
    # pass two: the escaped previous-version reference in the DEVNOW regex
    if ($k -eq 'p') {
      $cur = $n - 1102
      $u = $u.Replace(('11\.' + $cur), ('11\.' + ($cur + $shift)))
    }
    $dst = Join-Path $SP ("$k" + ($n + $shift) + $exts[$k])
    [IO.File]::WriteAllText($dst, $u, (New-Object Text.UTF8Encoding $false))
    Remove-Item $src
    Write-Output ("$k$n -> $k" + ($n + $shift))
  }
}
